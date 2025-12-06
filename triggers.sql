CREATE OR REPLACE FUNCTION fn_check_preformance_overlap()
RETURNS TRIGGER AS $$
BEGIN
        IF EXISTS (
            SELECT 1 FROM preformance p
            WHERE p.id IS DISTINCT FROM NEW.id
            AND p.festival_id = NEW.festival_id
            AND p.stage_id = NEW.stage_id
            AND NOT (
                NEW.end_time <= p.start_time
             OR NEW.start_time >= p.end_time
            )
        ) THEN 
            RAISE EXCEPTION 'Preklapanje nastupa na istoj pozornici u zadanom vremenu.';
        END IF;
        RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_preformance_no_overlap
BEFORE INSERT OR UPDATE ON preformance
FOR EACH ROW EXECUTE FUNCTION fn_check_preformance_overlap();



CREATE OR REPLACE FUNCTION  fn_check_workshop_capacity()
RETURNS TRIGGER AS $$
DECLARE
    cnt INT;
    max INT;
BEGIN
    SELECT max_atendee INTO max FROM workshop WHERE id = NEW.workshop_id;
    IF max IS NULL THEN
        RAISE EXCEPTION 'Radionica ne postoji (id=%).', NEW.workshop_id;
    END IF;

   
    SELECT COUNT(*) INTO cnt
    FROM signin_workshop pr
    WHERE pr.workshop_id = NEW.workshop_id
      AND pr.workshop_status <> 'otkazan';

    
    IF TG_OP = 'INSERT' THEN
        IF cnt + 1 > max THEN
            RAISE EXCEPTION 'Kapacitet radionice premašen (max=%).', max;
        END IF;
    ELSE
        
        IF cnt + 1 > max AND (OLD.workshop_status = 'otkazan' OR OLD.workshop_id <> NEW.workshop_id) THEN
            RAISE EXCEPTION 'Kapacitet radionice premašen na UPDATE (max=%).', max;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_workshop_capacity
BEFORE INSERT OR UPDATE ON signin_workshop
FOR EACH ROW EXECUTE FUNCTION fn_check_workshop_capacity();



CREATE OR REPLACE FUNCTION fn_check_staff_single_festival()
RETURNS TRIGGER AS $$
DECLARE
    f_start DATE;
    f_end DATE;
    conflict_count INT;
BEGIN
    
    SELECT official_start, official_end INTO f_start, f_end FROM festival WHERE id = NEW.festival_id;
    IF f_start IS NULL THEN
        RAISE EXCEPTION 'Festival id=% ne postoji', NEW.festival_id;
    END IF;

    SELECT COUNT(*) INTO conflict_count
    FROM staff s
    JOIN festival f ON f.id = s.festival_id
    WHERE (s.staff_name = NEW.staff_name)
      AND (s.staff_surname = NEW.staff_surname)
      AND (s.date_of_birth = NEW.date_of_birth)
      AND s.festival_id <> NEW.festival_id
      AND NOT (f.official_end < f_start OR f.official_start > f_end);

    IF conflict_count > 0 THEN
        RAISE EXCEPTION 'Zaposlenik već radi na događaju koji se vremenski preklapa.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_staff_single_festival
BEFORE INSERT OR UPDATE ON staff
FOR EACH ROW EXECUTE FUNCTION fn_check_staff_single_festival();



CREATE OR REPLACE FUNCTION fn_check_ticket_consistency() RETURNS TRIGGER AS $$
BEGIN
    
    IF NEW.is_valid_whole_festival = FALSE AND NEW.validation_date IS NULL THEN
        RAISE EXCEPTION 'Ako ulaznica ne vrijedi cijeli festival, mora imati polje validation_date (vrijedi_dan).';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_ticket_consistency
BEFORE INSERT OR UPDATE ON ticket
FOR EACH ROW EXECUTE FUNCTION fn_check_ticket_consistency();




CREATE OR REPLACE FUNCTION fn_update_purchase_total(p_purchase_id INT)
RETURNS VOID AS $$
DECLARE
    total DECIMAL(12,2);
BEGIN
    SELECT COALESCE(SUM(oi.amount * t.amount),0)
    INTO total
    FROM order_item oi
    JOIN ticket t ON t.id = oi.ticket_id
    WHERE oi.purchase_id = p_purchase_id;

    UPDATE purchase SET total_price = total WHERE id = p_purchase_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_order_change()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        PERFORM fn_update_purchase_total(NEW.purchase_id);
    ELSIF TG_OP = 'UPDATE' THEN
        PERFORM fn_update_purchase_total(NEW.purchase_id);
        IF OLD.purchase_id IS DISTINCT FROM NEW.purchase_id THEN
            PERFORM fn_update_purchase_total(OLD.purchse_id);
        END IF;
    ELSIF TG_OP = 'DELETE' THEN
        PERFORM fn_update_purchase_total(OLD.purchase_id);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_narudzba_change
AFTER INSERT OR UPDATE OR DELETE ON order_item
FOR EACH ROW EXECUTE FUNCTION fn_order_change();




CREATE OR REPLACE FUNCTION fn_evaluate_membership(p_visitor_id INT)
RETURNS VOID AS $$
DECLARE
    festivals_count INT;
    total_spent DECIMAL(12,2);
BEGIN
    SELECT COUNT(DISTINCT festival_id), COALESCE(SUM(total_price),0)
    INTO festivals_count, total_spent
    FROM purchase
    WHERE visitor_id = p_visitor_id;

    IF festivals_count >= 3 AND total_spent >= 600 THEN
        IF EXISTS (SELECT 1 FROM membership WHERE visitor_id = p_visitor_id) THEN
            UPDATE membership
            SET status = 'aktivan',
                activation_date = COALESCE(activation_date, CURRENT_DATE)
            WHERE visitor_id = p_visitor_id;
        ELSE
            INSERT INTO membership (visitor_id, activation_date, membership_status)
            VALUES (p_visitor_id, CURRENT_DATE, 'aktivan');
        END IF;
    ELSE
       
        IF EXISTS (SELECT 1 FROM membership WHERE visitor_id = p_visitor_id) THEN
            UPDATE membership
            SET status = 'istekao'
            WHERE visitor_id = p_visitor_id;
        END IF;
    END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION fn_purchase_change_membership()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        PERFORM fn_evaluate_membership(NEW.visitor_id);
    ELSIF TG_OP = 'UPDATE' THEN
        PERFORM fn_evaluate_membership(NEW.visitor_id);
        IF OLD.visitor_id IS DISTINCT FROM NEW.visitor_id THEN
            PERFORM fn_evaluate_membership(OLD.visitor_id);
        END IF;
    ELSIF TG_OP = 'DELETE' THEN
        PERFORM fn_evaluate_membership(OLD.visitor_id);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_purchase_membership
AFTER INSERT OR UPDATE OR DELETE ON purchase
FOR EACH ROW EXECUTE FUNCTION fn_purchase_change_membership();



CREATE OR REPLACE FUNCTION fn_check_mentor() RETURNS TRIGGER AS $$
DECLARE
    mentor_age INTEGER;
BEGIN
    IF NEW.date_of_birth IS NOT NULL THEN
        mentor_age := DATE_PART('year', AGE(NEW.date_of_birth));

        IF mentor_age < 18 THEN
            RAISE EXCEPTION 'Mentor mora biti stariji od 18 godina.';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_mentor_checks
BEFORE INSERT OR UPDATE ON mentor
FOR EACH ROW EXECUTE FUNCTION fn_check_mentor();