-- 1. Create the Database
DROP DATABASE IF EXISTS ProjectDB;
CREATE DATABASE IF NOT EXISTS ProjectDB;
USE ProjectDB;

-- 2. Create Tables for the main entities

-- Table: Festival
CREATE TABLE Festival (
    Festival_ID INT AUTO_INCREMENT PRIMARY KEY,
    Year INT NOT NULL,
    Start_Date DATE NOT NULL,
    End_Date DATE NOT NULL,
    Daily_Max_Duration INT NOT NULL  -- in minutes or hours as per your design
);

-- Table: Location
CREATE TABLE Location (
    Location_ID INT AUTO_INCREMENT PRIMARY KEY,
    Address VARCHAR(255) NOT NULL,
    Geo_Coordinates VARCHAR(50),  -- could be POINT type in some DBMS
    City VARCHAR(100),
    Country VARCHAR(100),
    Continent VARCHAR(50)
);

-- Junction Table: FestivalLocation (if a festival can have multiple locations)
CREATE TABLE FestivalLocation (
    Festival_ID INT,
    Location_ID INT,
    PRIMARY KEY (Festival_ID, Location_ID),
    FOREIGN KEY (Festival_ID) REFERENCES Festival(Festival_ID),
    FOREIGN KEY (Location_ID) REFERENCES Location(Location_ID)
);

-- Table: Stage (or Venue)
CREATE TABLE Stage (
    Stage_ID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Description TEXT,
    Maximum_Capacity INT NOT NULL,
    Technical_Requirements TEXT  -- List or JSON description of equipment needed
);

-- Table: Event
CREATE TABLE Event (
    Event_ID INT AUTO_INCREMENT PRIMARY KEY,
    Festival_ID INT NOT NULL,
    Stage_ID INT NOT NULL,
    Event_Name VARCHAR(150) NOT NULL,
    Duration INT NOT NULL, -- maximum 12 hours (in minutes or hours)
    FOREIGN KEY (Festival_ID) REFERENCES Festival(Festival_ID),
    FOREIGN KEY (Stage_ID) REFERENCES Stage(Stage_ID)
);

-- Table: Performance
CREATE TABLE Performance (
    Performance_ID INT AUTO_INCREMENT PRIMARY KEY,
    Event_ID INT NOT NULL,
    Performance_Type VARCHAR(50) NOT NULL,  -- e.g., warm up, headline, special guest
    Start_Time DATETIME NOT NULL,
    Duration INT NOT NULL, -- maximum 3 hours
    Break_Duration INT,  -- break between performances if applicable
    FOREIGN KEY (Event_ID) REFERENCES Event(Event_ID)
);

-- Table: Equipment
CREATE TABLE Equipment (
    Equipment_ID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Description TEXT
);

-- Junction Table: StageEquipment (to capture many-to-many with Quantity)
CREATE TABLE StageEquipment (
    Stage_ID INT,
    Equipment_ID INT,
    Quantity INT NOT NULL,
    PRIMARY KEY (Stage_ID, Equipment_ID),
    FOREIGN KEY (Stage_ID) REFERENCES Stage(Stage_ID),
    FOREIGN KEY (Equipment_ID) REFERENCES Equipment(Equipment_ID)
);

-- Table: Personnel
CREATE TABLE Personnel (
    Personnel_ID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Age INT,
    Role VARCHAR(50) NOT NULL,  -- e.g., technician, security, support
    Experience_Level ENUM('novice', 'beginner', 'intermediate', 'experienced', 'expert') NOT NULL
    -- Additional constraints can be added later based on business rules (e.g., max 2 performances/day for technician)
);

-- Junction Table: PerformancePersonnel (Many-to-many relationship)
CREATE TABLE PerformancePersonnel (
    Performance_ID INT,
    Personnel_ID INT,
    PRIMARY KEY (Performance_ID, Personnel_ID),
    FOREIGN KEY (Performance_ID) REFERENCES Performance(Performance_ID),
    FOREIGN KEY (Personnel_ID) REFERENCES Personnel(Personnel_ID)
);

-- Table: Artist
CREATE TABLE Artist (
    Artist_ID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Stage_Name VARCHAR(100),
    Date_of_Birth DATE,
    Website VARCHAR(255),
    Instagram VARCHAR(255)
    -- Music_Genres could be handled as a separate table for normalization
);

-- Table: Band
CREATE TABLE Band (
    Band_ID INT AUTO_INCREMENT PRIMARY KEY,
    Band_Name VARCHAR(100) NOT NULL,
    Formation_Date DATE,
    Website VARCHAR(255)
);

-- Junction Table: ArtistBand (An artist can belong to multiple bands)
CREATE TABLE ArtistBand (
    Artist_ID INT,
    Band_ID INT,
    PRIMARY KEY (Artist_ID, Band_ID),
    FOREIGN KEY (Artist_ID) REFERENCES Artist(Artist_ID),
    FOREIGN KEY (Band_ID) REFERENCES Band(Band_ID)
);

-- For performances, we need to record which performer (artist or band) is performing.
-- One way is to create a Performer table (as a supertype) or use two nullable foreign keys in the Performance table.
-- Here, we illustrate the two-foreign key approach:

ALTER TABLE Performance
ADD COLUMN Artist_ID INT NULL,
ADD COLUMN Band_ID INT NULL,
ADD CONSTRAINT fk_Performance_Artist
    FOREIGN KEY (Artist_ID) REFERENCES Artist(Artist_ID),
ADD CONSTRAINT fk_Performance_Band
    FOREIGN KEY (Band_ID) REFERENCES Band(Band_ID);
-- Business rule: Only one of Artist_ID or Band_ID should be non-null.

-- Table: Visitor
CREATE TABLE Visitor (
    Visitor_ID INT AUTO_INCREMENT PRIMARY KEY,
    First_Name VARCHAR(100) NOT NULL,
    Last_Name VARCHAR(100) NOT NULL,
    Contact_Details VARCHAR(255),
    Age INT
);

-- Table: Ticket
CREATE TABLE Ticket (
    Ticket_ID INT AUTO_INCREMENT PRIMARY KEY,
    Visitor_ID INT NOT NULL,
    Event_ID INT NOT NULL,
    Purchase_Date DATETIME NOT NULL,
    Cost DECIMAL(10,2) NOT NULL,
    Payment_Method ENUM('credit_card', 'debit_card', 'bank_account', 'cash') NOT NULL,
    EAN_Code BIGINT NOT NULL,
    Category ENUM('General', 'VIP', 'Backstage') NOT NULL,
    Status ENUM('active','used') DEFAULT 'active',
    FOREIGN KEY (Visitor_ID) REFERENCES Visitor(Visitor_ID),
    FOREIGN KEY (Event_ID) REFERENCES Event(Event_ID)
    -- Add a unique constraint to enforce one ticket per visitor per event per day if needed.
);

-- Table: Resale (if a ticket is put on resale)
CREATE TABLE Resale (
    Resale_ID INT AUTO_INCREMENT PRIMARY KEY,
    Ticket_ID INT UNIQUE,  -- one resale record per ticket
    Listing_Date DATETIME NOT NULL,
    FOREIGN KEY (Ticket_ID) REFERENCES Ticket(Ticket_ID)
);

-- Business rule: A ticket can be resold only once.
-- Table: Rating
-- Visitor ratings for performances
-- You can add more fields or normalize this table further based on the rating criteria.


CREATE TABLE Rating (
    Rating_ID INT AUTO_INCREMENT PRIMARY KEY,
    Visitor_ID INT NOT NULL,
    Performance_ID INT NOT NULL,
    Artist_Interpretation TINYINT,  -- Likert scale value, e.g., 1-5
    Sound_Lighting TINYINT,
    Stage_Presence TINYINT,
    Organization TINYINT,
    Overall_Impression TINYINT,
    Rating_Date DATETIME NOT NULL,
    FOREIGN KEY (Visitor_ID) REFERENCES Visitor(Visitor_ID),
    FOREIGN KEY (Performance_ID) REFERENCES Performance(Performance_ID)
);

-- Table: Image (Associating images to various entities)
CREATE TABLE Image (
    Image_ID INT AUTO_INCREMENT PRIMARY KEY,
    File_Path VARCHAR(255) NOT NULL,
    Description VARCHAR(255),
    -- You can use a generic approach with a foreign key and an EntityType field.
    Entity_ID INT NOT NULL,
    Entity_Type VARCHAR(50) NOT NULL
    -- For example, Entity_Type could be 'Festival', 'Artist', 'Equipment', etc.
);

-- 3. Additional Constraints & Indexes
-- Create any necessary indexes to speed up query performance
CREATE INDEX idx_festival_year ON Festival(Year);
CREATE INDEX idx_event_festival ON Event(Festival_ID);
CREATE INDEX idx_ticket_visitor ON Ticket(Visitor_ID);

-- You can also add CHECK constraints if your RDBMS supports them.
-- For example, to ensure the VIP tickets do not exceed 10% of stage capacity,
-- you might need to enforce this with application logic or triggers,
-- as many SQL engines have limited CHECK constraint functionality.

