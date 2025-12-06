# Internship-5-FestivalDB

This project involves the design, implementation, and populating of a PostgreSQL database system for managing multiple music festivals, including details about venues, performers, workshops, visitors, staff, and ticket purchases.

The project fulfills the requirements of a database homework assignment, including schema design, data seeding with over 1000 entries per entity, and a set of specific analytical SQL queries.

## Features

The database system supports the management of:

*   **Festivals:** Information on location, capacity, dates, status (planned, active, finished), and camping options.
*   **Stages & Performances:** Details about individual stages within a festival and the scheduled performances, ensuring no overlaps on the same stage at the same time.
*   **Performers (Artists):** Information on artists, their country of origin, genre, and activity status.
*   **Visitors & Tickets:** Visitor information and a system for purchasing tickets, including various ticket types (day, festival, VIP, camp) and robust validation logic.
*   **Workshops & Mentors:** Management of workshops, skill levels, capacity, and mentors with specific experience/age constraints.
*   **Staff:** Details on festival personnel (security, technicians, organizers, volunteers) with role-specific rules (e.g., age limits for security).
*   **Purchases & Order Items:** A transactional system for tracking sales and total price calculations.
*   **Membership:** A system to track visitor membership status based on loyalty rules (spending/attendance).

## Project Structure

The repository typically contains the following files:

*   `schema.sql`: Contains all `CREATE TABLE` statements, constraints (primary/foreign keys, CHECK constraints), triggers, and functions necessary to define the database structure.
*   `seed.sql`: A comprehensive SQL script using `INSERT INTO ... SELECT FROM generate_series` to populate all tables with realistic, internally consistent test data (over 1000 rows per major entity).
*   `queries.sql`: Contains the 15 required analytical queries for data retrieval.

## Setup and Usage

To run this project locally:

1.  **Set up PostgreSQL:** Ensure you have a running PostgreSQL instance (version 12+ recommended).
2.  **Create a Database:** Create a new, empty database (e.g., `festival_db`).
3.  **Create Schema:** Run the contents of `schema.sql` within your PostgreSQL client (e.g., pgAdmin Query Tool) to create all tables and constraints.
4.  **Seed Data:** Run the contents of `seed.sql` to populate the database with test data. The script is wrapped in a `BEGIN;` and `COMMIT;` block for transactional integrity.
5.  **Run Queries:** Execute the queries found in `queries.sql` to retrieve specific data insights as required by the assignment.

## Assignment Requirements

The assignment required:

*   A functional database schema design.
*   Triggers and constraints implementing specific business rules (e.g., mentor age, ticket validation dates, performance overlaps).
*   Data seeding with high volume (1000+ records per entity).
*   **15 specific SQL queries** covering various aspects of the data (filtering workshops by level/year, performances by attendance, mentors by experience, visitor demographics, ticket prices/types, etc.).
