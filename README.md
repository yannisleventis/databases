*** Pulse University - Music Festival Database

- Project Overview:

This MySQL database system manages a comprehensive music festival platform, handling artists, performances, ticket sales, and visitor interactions. The system includes robust features for scheduling, capacity management, ticket resales, and performance ratings.

** Installation
1. Connect to your MySQL server: mysql -u username -p
2. Execute the installation script: mysql -u username -p < install.sql

** Loading Sample Data
1. Load the provided sample data: mysql -u username -p < sql/load.sql
2. Sample data includes:
50+ artists, 30+ stages, 100+ performances, 10+ festivals, 200+ tickets

--------------------------------------------------------------------------------
**Database Structure
The database contains the following main components:

Lookup Tables: Performance_Type, Continent, Experience_Level, Personnel_Role, Payment_Method, Ticket_Category, Ticket_Status, Resale_Status, Genre

Entity Tables: Artist, Band, Stage, Event, Performance, Visitor, Equipment, Location, Festival

Relationship Tables: ArtistBand, PerformancePersonnel, StageEquipment, Artist_Genre

Transaction Tables: Ticket, Resale, Rating, Resale_Queue, Resale_Buyer_Interest, Resale_Seller_Queue
--------------------------------------------------------------------------------

** Key Features:

Performance Management:

Prevents scheduling conflicts for artists/bands

Enforces minimum 5-minute and maximum 30-minute breaks between performances

Limits performance duration to 180 minutes

Prevents artists/bands from performing for more than 3 consecutive years
---------------------------

Ticket System:

Automatically limits tickets to stage capacity

Restricts VIP tickets to 10% of total capacity

Different pricing based on festival day

Ticket scanning/validation for event entry
---------------------------

Resale Platform:

Ticket resale queue with automatic matching

Option to express interest in specific tickets or event/category combinations

First-come-first-served matching algorithm
---------------------------

Rating System:

Performance ratings from visitors

Requires ticket to be used before submitting ratings

Multiple rating dimensions (Artist Interpretation, Sound, Stage Presence, etc.)
--------------------------------------------------------------------------------

** System Requirements:

- MySQL Server 5.7+ or MariaDB 10.3+
- UTF-8 character set support
- Minimum 100MB disk space
