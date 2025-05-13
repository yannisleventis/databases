-- Save settings and disable checks
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

-- Drop and recreate schema
DROP SCHEMA IF EXISTS musicfestival;
CREATE SCHEMA musicfestival;
USE musicfestival;

-- Lookup Tables

-- Table: Performance_Type
CREATE TABLE Performance_Type (
    Performance_Type_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Performance_Type VARCHAR(50) NOT NULL,
    PRIMARY KEY (Performance_Type_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Table: Continent
CREATE TABLE Continent (
    Continent_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Continent_Name VARCHAR(50) NOT NULL,
    PRIMARY KEY (Continent_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Table: Experience_Level
CREATE TABLE Experience_Level (
    Level_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Level_Name VARCHAR(50) NOT NULL,
    PRIMARY KEY (Level_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Table: Personnel_Role
CREATE TABLE Personnel_Role (
    Role_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Personnel_Role VARCHAR(50) NOT NULL,
    PRIMARY KEY (Role_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Table: Payment_Method
CREATE TABLE Payment_Method (
    Method_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Method_Name VARCHAR(50) NOT NULL,
    PRIMARY KEY (Method_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Table: Ticket_Category
CREATE TABLE Ticket_Category (
    Category_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Category_Name VARCHAR(50) NOT NULL,
    PRIMARY KEY (Category_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Table: Ticket_Status
CREATE TABLE Ticket_Status (
    Status_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Status_Name VARCHAR(50) NOT NULL,
    PRIMARY KEY (Status_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Resale status
CREATE TABLE Resale_Status (
    Status_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Status_Name VARCHAR(50) NOT NULL, 
    -- π.χ. 'available', 'sold'
    PRIMARY KEY (Status_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- Πίνακας για τα μουσικά είδη
CREATE TABLE Genre (
    Genre_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Genre_Name VARCHAR(50) NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (Genre_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- Tables with no foreign keys

-- Table: Stage
CREATE TABLE Stage (
    Stage_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    Description TEXT,
    Maximum_Capacity INT NOT NULL,
    Technical_Requirements TEXT,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (Stage_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Table: Equipment
CREATE TABLE Equipment (
    Equipment_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    Description TEXT,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (Equipment_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Table: Artist
CREATE TABLE Artist (
    Artist_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    First_Name VARCHAR(50) NOT NULL,
    Last_Name VARCHAR(50) NOT NULL,
    Stage_Name VARCHAR(50),
    Date_of_Birth DATE,
    Website VARCHAR(255),
    Instagram VARCHAR(255),
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (Artist_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- Πίνακας σύνδεσης Artists με Genres (many-to-many)
CREATE TABLE Artist_Genre (
    Artist_ID INT UNSIGNED NOT NULL,
    Genre_ID INT UNSIGNED NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (Artist_ID, Genre_ID),
    KEY idx_artist_genre_genre (Genre_ID),
    FOREIGN KEY (Artist_ID) REFERENCES Artist(Artist_ID),
    FOREIGN KEY (Genre_ID) REFERENCES Genre(Genre_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- Table: Band
CREATE TABLE Band (
    Band_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Band_Name VARCHAR(100) NOT NULL,
    Formation_Date DATE,
    Website VARCHAR(255),
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (Band_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Table: Visitor
CREATE TABLE Visitor (
    Visitor_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    First_Name VARCHAR(45) NOT NULL,
    Last_Name VARCHAR(45) NOT NULL,
    Email VARCHAR(320),
    Phone_Number VARCHAR(20),
    Age INT,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (Visitor_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Tables that reference lookup tables

-- Table: Location
CREATE TABLE Location (
    Location_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Location_Address VARCHAR(255) NOT NULL,
    Longitude FLOAT(10,7) NOT NULL,
    Latitude FLOAT(10,7) NOT NULL,
    City VARCHAR(100),
    Country VARCHAR(100),
    Continent_ID INT UNSIGNED NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (Location_ID),
    FOREIGN KEY (Continent_ID) REFERENCES Continent(Continent_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Table: ArtistBand
CREATE TABLE ArtistBand (
    Artist_ID INT UNSIGNED NOT NULL,
    Band_ID INT UNSIGNED NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (Artist_ID, Band_ID),
    KEY idx_artistband_band (Band_ID),
    FOREIGN KEY (Artist_ID) REFERENCES Artist(Artist_ID),
    FOREIGN KEY (Band_ID) REFERENCES Band(Band_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Table: Personnel
CREATE TABLE Personnel (
    Personnel_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Personnel_Name VARCHAR(90) NOT NULL,
    Age INT,
    Personnel_Role_ID INT UNSIGNED NOT NULL,
    Experience_Level_ID INT UNSIGNED NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (Personnel_ID),
    FOREIGN KEY (Personnel_Role_ID) REFERENCES Personnel_Role(Role_ID),
    FOREIGN KEY (Experience_Level_ID) REFERENCES Experience_Level(Level_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Rest of the tables

-- Table: Festival
CREATE TABLE Festival (
    Festival_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Location_ID INT UNSIGNED NOT NULL,
    Name VARCHAR(50) NOT NULL,
    Start_Date DATE NOT NULL,
    End_Date DATE NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (Festival_ID),
    FOREIGN KEY (Location_ID) REFERENCES Location(Location_ID),
    UNIQUE KEY uq_festival_year (Start_Date),
    -- Each year can have only 1 pulse university festival.
    KEY idx_festival_year (Start_Date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Table: Event
CREATE TABLE Event (
    Event_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Festival_ID INT UNSIGNED NOT NULL,
    Stage_ID INT UNSIGNED NOT NULL,
    Event_Name VARCHAR(150) NOT NULL,
    Duration INT NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (Event_ID),
    KEY idx_event_festival (Festival_ID),
    KEY idx_event_stage (Stage_ID),
    FOREIGN KEY (Festival_ID) REFERENCES Festival(Festival_ID),
    FOREIGN KEY (Stage_ID) REFERENCES Stage(Stage_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Table: Performance
CREATE TABLE Performance (
    Performance_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Event_ID INT UNSIGNED NOT NULL,
    Stage_ID INT UNSIGNED NOT NULL,
    Performance_Type_ID INT UNSIGNED NOT NULL,
    Start_Time DATETIME NOT NULL,
    Duration INT NOT NULL CHECK (Duration <= 180),
    Break_Duration INT,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (Performance_ID),
    KEY idx_performance_event (Event_ID),
    FOREIGN KEY (Event_ID) REFERENCES Event(Event_ID),
    FOREIGN KEY (Stage_ID) REFERENCES Stage(Stage_ID),
    FOREIGN KEY (Performance_Type_ID) REFERENCES Performance_Type(Performance_Type_ID),
    UNIQUE KEY uq_stage_starttime (Event_ID, Start_Time)
    -- Each Stage ID must have unique start time
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- Table: StageEquipment
CREATE TABLE StageEquipment (
    Stage_ID INT UNSIGNED NOT NULL,
    Equipment_ID INT UNSIGNED NOT NULL,
    Quantity INT NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (Stage_ID, Equipment_ID),
    KEY idx_stageequipment_equipment (Equipment_ID),
    FOREIGN KEY (Stage_ID) REFERENCES Stage(Stage_ID),
    FOREIGN KEY (Equipment_ID) REFERENCES Equipment(Equipment_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Table: PerformancePersonnel
CREATE TABLE PerformancePersonnel (
    Performance_ID INT UNSIGNED NOT NULL,
    Personnel_ID INT UNSIGNED NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (Performance_ID, Personnel_ID),
    KEY idx_performancepersonnel_personnel (Personnel_ID),
    FOREIGN KEY (Performance_ID) REFERENCES Performance(Performance_ID),
    FOREIGN KEY (Personnel_ID) REFERENCES Personnel(Personnel_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Alter Table: Performance (add Artist and Band)
ALTER TABLE Performance
ADD COLUMN Artist_ID INT UNSIGNED NULL,
ADD COLUMN Band_ID INT UNSIGNED NULL,
ADD CONSTRAINT fk_Performance_Artist FOREIGN KEY (Artist_ID) REFERENCES Artist(Artist_ID),
ADD CONSTRAINT fk_Performance_Band FOREIGN KEY (Band_ID) REFERENCES Band(Band_ID);

-- If sold out: Start resale

ALTER TABLE Event
ADD COLUMN Resale_Active BOOLEAN NOT NULL DEFAULT FALSE;

-- Table: Ticket
CREATE TABLE Ticket (
    Ticket_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Visitor_ID INT UNSIGNED NOT NULL,
    Event_ID INT UNSIGNED NOT NULL,
    Purchase_Date DATETIME NOT NULL,
    Cost DECIMAL(10,2) NOT NULL,
    Payment_Method_ID INT UNSIGNED NOT NULL,
    EAN_Code VARCHAR(20) NOT NULL,
    Category_ID INT UNSIGNED NOT NULL,
    Ticket_Status_ID INT UNSIGNED NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (Ticket_ID),
    UNIQUE KEY uq_ticket_visitor_performance (Visitor_ID, Event_ID),
     -- one for each event ;
    KEY idx_ticket_visitor (Visitor_ID),
    KEY idx_ticket_event (Event_ID),
    FOREIGN KEY (Visitor_ID) REFERENCES Visitor(Visitor_ID),
    FOREIGN KEY (Event_ID) REFERENCES Event(Event_ID), 
    FOREIGN KEY (Payment_Method_ID) REFERENCES Payment_Method(Method_ID),
    FOREIGN KEY (Category_ID) REFERENCES Ticket_Category(Category_ID),
    FOREIGN KEY (Ticket_Status_ID) REFERENCES Ticket_Status(Status_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Table: Rating
CREATE TABLE Rating (
    Rating_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Visitor_ID INT UNSIGNED NOT NULL,
    Performance_ID INT UNSIGNED NOT NULL,
    Artist_Interpretation TINYINT NOT NULL,
    Sound_Lighting TINYINT NOT NULL,
    Stage_Presence TINYINT NOT NULL,
    Organization TINYINT NOT NULL,
    Overall_Impression TINYINT NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (Rating_ID),
    KEY idx_rating_performance (Performance_ID),
    FOREIGN KEY (Visitor_ID) REFERENCES Visitor(Visitor_ID),
    FOREIGN KEY (Performance_ID) REFERENCES Performance(Performance_ID),
    
    -- Check constraints για 1-5 βαθμολογίες
    CONSTRAINT chk_artist_interpretation CHECK (Artist_Interpretation BETWEEN 1 AND 5),
    CONSTRAINT chk_sound_lighting CHECK (Sound_Lighting BETWEEN 1 AND 5),
    CONSTRAINT chk_stage_presence CHECK (Stage_Presence BETWEEN 1 AND 5),
    CONSTRAINT chk_organization CHECK (Organization BETWEEN 1 AND 5),
    CONSTRAINT chk_overall_impression CHECK (Overall_Impression BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;




-- Table: Buyers
CREATE TABLE Resale_Buyer_Interest (
    Interest_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Visitor_ID INT UNSIGNED NOT NULL,
    -- Ποιος επισκέπτης ενδιαφέρεται
    Specific_Ticket_ID INT UNSIGNED NULL,
    -- Συγκεκριμένο εισιτήριο (αν θέλει συγκεκριμένο)
    Event_ID INT UNSIGNED NULL,
    -- Εναλλακτικά: Παράσταση
    Category_ID INT UNSIGNED NULL,
    -- Και κατηγορία εισιτηρίου (VIP / General κτλ)
    Interest_Date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Interest_ID),
    FOREIGN KEY (Visitor_ID) REFERENCES Visitor(Visitor_ID),
    FOREIGN KEY (Specific_Ticket_ID) REFERENCES Ticket(Ticket_ID),
    FOREIGN KEY (Event_ID) REFERENCES Event(EVENT_ID),
    FOREIGN KEY (Category_ID) REFERENCES Ticket_Category(Category_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- Table: Sellers


CREATE TABLE Resale_Seller_Queue (
    Seller_Queue_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Ticket_ID INT UNSIGNED NOT NULL,
    Listed_Date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Sale_Status_ID INT UNSIGNED NOT NULL,
    PRIMARY KEY (Seller_Queue_ID),
    FOREIGN KEY (Ticket_ID) REFERENCES Ticket(Ticket_ID),
    FOREIGN KEY (Sale_Status_ID) REFERENCES Resale_Status(Status_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Table: Image
CREATE TABLE Image (
    Image_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    File_Path VARCHAR(255) NOT NULL,
    Image_Description VARCHAR(255),
    Entity_ID INT UNSIGNED NOT NULL,
    Entity_Type VARCHAR(50) NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (Image_ID),
    KEY idx_image_entity (Entity_ID, Entity_Type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Triggers

-- Festivals & Performances cannot be canceled

DELIMITER //

-- Για το Festival
CREATE TRIGGER trg_prevent_delete_festival
BEFORE DELETE ON Festival
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Festival entries cannot be deleted.';
END //

-- Για το Performance
CREATE TRIGGER trg_prevent_delete_performance
BEFORE DELETE ON Performance
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Performance entries cannot be deleted.';
END //

DELIMITER ;

-- Trigger for consecutive performances (Start_Time + Duration + Break_Duration)
DELIMITER //

DROP TRIGGER IF EXISTS trg_check_performance_sequence//
CREATE TRIGGER trg_check_performance_sequence
BEFORE INSERT ON Performance
FOR EACH ROW
BEGIN
    DECLARE v_Last_End DATETIME;
    DECLARE v_Last_Performance_ID INT;
    DECLARE v_Last_Break_Duration INT;

    -- Changed to include Break_Duration like in the UPDATE trigger
    SELECT Performance_ID, DATE_ADD(Start_Time, INTERVAL Duration MINUTE)
    INTO v_Last_Performance_ID, v_Last_End
    FROM Performance
    WHERE Event_ID = NEW.Event_ID
    ORDER BY Start_Time DESC
    LIMIT 1;
    
    -- Αν υπάρχει προηγούμενο performance
    IF v_Last_End IS NOT NULL THEN
        -- Εξασφάλισε ότι ξεκινάει μετά το τέλος
        IF NEW.Start_Time < v_Last_End THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'New performance must start after the previous one ends (including break).';
        END IF;

        -- Υπολόγισε το διάλειμμα σε λεπτά
        SET v_Last_Break_Duration = TIMESTAMPDIFF(MINUTE, v_Last_End, NEW.Start_Time);

        -- Έλεγχος ελάχιστου και μέγιστου διαλείμματος
        IF v_Last_Break_Duration < 5 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Break between performances must be at least 5 minutes.';
        END IF;

        IF v_Last_Break_Duration > 30 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Break between performances must not exceed 30 minutes.';
        END IF;
    END IF;
END //

DELIMITER ;

-- On update

DELIMITER //

CREATE TRIGGER trg_check_performance_sequence_update
BEFORE UPDATE ON Performance
FOR EACH ROW
BEGIN
    DECLARE v_Last_End DATETIME;
    DECLARE v_Last_Performance_ID INT;
    DECLARE v_Last_Break_Duration INT;

    -- Βρες την τελευταία εμφάνιση σε αυτό το Event, εκτός από την ίδια την εμφάνιση που κάνουμε update
    SELECT Performance_ID, DATE_ADD(Start_Time, INTERVAL Duration MINUTE)
    INTO v_Last_Performance_ID, v_Last_End
    FROM Performance
    WHERE Event_ID = NEW.Event_ID
      AND Performance_ID != NEW.Performance_ID
    ORDER BY Start_Time DESC
    LIMIT 1;

    -- Αν υπάρχει προηγούμενο performance
    IF v_Last_End IS NOT NULL THEN
        -- Εξασφάλισε ότι ξεκινάει μετά το τέλος
        IF NEW.Start_Time <= v_Last_End THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Updated performance must start after the previous one ends (including break).';
        END IF;

        -- Υπολόγισε το διάλειμμα σε λεπτά
        SET v_Last_Break_Duration = TIMESTAMPDIFF(MINUTE, v_Last_End, NEW.Start_Time);

        -- Έλεγχος ελάχιστου και μέγιστου διαλείμματος
        IF v_Last_Break_Duration < 5 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Break between performances must be at least 5 minutes.';
        END IF;

        IF v_Last_Break_Duration > 30 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Break between performances must not exceed 30 minutes.';
        END IF;
    END IF;
END //


DELIMITER ;

-- Each performance must have an artist/band

DELIMITER //

CREATE TRIGGER trg_check_artist_band
BEFORE INSERT ON Performance
FOR EACH ROW
BEGIN
    IF (NEW.Artist_ID IS NULL AND NEW.Band_ID IS NULL)
       OR (NEW.Artist_ID IS NOT NULL AND NEW.Band_ID IS NOT NULL) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Each performance must be linked to exactly one Artist OR one Band.';
    END IF;
END //

DELIMITER ;

-- On Update 

DELIMITER //

CREATE TRIGGER trg_check_artist_band_update
BEFORE UPDATE ON Performance
FOR EACH ROW
BEGIN
    IF (NEW.Artist_ID IS NULL AND NEW.Band_ID IS NULL)
       OR (NEW.Artist_ID IS NOT NULL AND NEW.Band_ID IS NOT NULL) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Each performance must be linked to exactly one Artist OR one Band.';
    END IF;
END //

DELIMITER ;


-- Resale queue starts on sold out trigger


DELIMITER //

CREATE TRIGGER trg_activate_resale_mode
AFTER INSERT ON Ticket
FOR EACH ROW
BEGIN
    DECLARE v_Stage_ID INT;
    DECLARE v_Max_Capacity INT;
    DECLARE v_Current_Tickets INT;

    -- Βρες Stage_ID της event
    SELECT Stage_ID INTO v_Stage_ID
    FROM Event
    WHERE Event_ID = NEW.Event_ID;

    -- Βρες Maximum Capacity της Stage
    SELECT Maximum_Capacity INTO v_Max_Capacity
    FROM Stage
    WHERE Stage_ID = v_Stage_ID;

    -- Πόσα Tickets έχουν πωληθεί για την Event
    SELECT COUNT(*)
    INTO v_Current_Tickets
    FROM Ticket
    WHERE Event_ID = NEW.Event_ID;

    -- Αν γεμίσαμε -> ενεργοποίησε Resale Mode
    IF v_Current_Tickets >= v_Max_Capacity THEN
        UPDATE Event
        SET Resale_Active = TRUE
        WHERE Event_ID = NEW.Event_ID;
    END IF;
END //

DELIMITER ;



-- Artist one performance per time period / no overlap



DELIMITER //

CREATE TRIGGER trg_check_artist_band_overlap
BEFORE INSERT ON Performance
FOR EACH ROW
BEGIN
    DECLARE v_count INT;

    -- Check overlap για Artist
    IF NEW.Artist_ID IS NOT NULL THEN
        SELECT COUNT(*)
        INTO v_count
        FROM Performance
        WHERE Artist_ID = NEW.Artist_ID
          AND NOT (NEW.Start_Time >= DATE_ADD(Start_Time, INTERVAL Duration MINUTE) OR 
                   Start_Time >= DATE_ADD(NEW.Start_Time, INTERVAL NEW.Duration MINUTE));
        
        IF v_count > 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Artist is already scheduled for another performance at that time.';
        END IF;
    END IF;

    -- Check overlap για Band
    IF NEW.Band_ID IS NOT NULL THEN
        SELECT COUNT(*)
        INTO v_count
        FROM Performance
        WHERE Band_ID = NEW.Band_ID
          AND NOT (NEW.Start_Time >= DATE_ADD(Start_Time, INTERVAL Duration MINUTE) OR 
                   Start_Time >= DATE_ADD(NEW.Start_Time, INTERVAL NEW.Duration MINUTE));
        
        IF v_count > 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Band is already scheduled for another performance at that time.';
        END IF;
    END IF;
END //

DELIMITER ;

-- On update

DELIMITER //

CREATE TRIGGER trg_check_artist_band_overlap_update
BEFORE UPDATE ON Performance
FOR EACH ROW
BEGIN
    DECLARE v_count INT;

    -- Check overlap για Artist
    IF NEW.Artist_ID IS NOT NULL THEN
        SELECT COUNT(*)
        INTO v_count
        FROM Performance
        WHERE Artist_ID = NEW.Artist_ID
          AND Performance_ID != NEW.Performance_ID
          AND NOT (NEW.Start_Time >= DATE_ADD(Start_Time, INTERVAL Duration MINUTE) OR 
                   Start_Time >= DATE_ADD(NEW.Start_Time, INTERVAL NEW.Duration MINUTE));
        
        IF v_count > 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Artist is already scheduled for another performance at that time (update).';
        END IF;
    END IF;

    -- Check overlap για Band
    IF NEW.Band_ID IS NOT NULL THEN
        SELECT COUNT(*)
        INTO v_count
        FROM Performance
        WHERE Band_ID = NEW.Band_ID
          AND Performance_ID != NEW.Performance_ID
          AND NOT (NEW.Start_Time >= DATE_ADD(Start_Time, INTERVAL Duration MINUTE) OR 
                   Start_Time >= DATE_ADD(NEW.Start_Time, INTERVAL NEW.Duration MINUTE));
        
        IF v_count > 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Band is already scheduled for another performance at that time (update).';
        END IF;
    END IF;
END //

DELIMITER ;


-- Band/Artist cannot perform 3 years in a row

DELIMITER //

CREATE TRIGGER trg_check_consecutive_years
BEFORE INSERT ON Performance
FOR EACH ROW
BEGIN
    DECLARE v_consecutive_years INT;
    DECLARE v_current_year INT;
    
    -- Get year of current performance
    SET v_current_year = YEAR(NEW.Start_Time);
    
    -- Check for artists
    IF NEW.Artist_ID IS NOT NULL THEN
        -- Count distinct years in the last 3 years
        SELECT COUNT(DISTINCT YEAR(p.Start_Time)) INTO v_consecutive_years
        FROM Performance p
        JOIN Event e ON p.Event_ID = e.Event_ID
        JOIN Festival f ON e.Festival_ID = f.Festival_ID
        WHERE p.Artist_ID = NEW.Artist_ID
        AND YEAR(p.Start_Time) BETWEEN (v_current_year - 3) AND (v_current_year - 1);
        
        IF v_consecutive_years >= 3 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Artist cannot perform in more than 3 consecutive years.';
        END IF;
    END IF;
    
    -- Similar check for bands
    IF NEW.Band_ID IS NOT NULL THEN
        SELECT COUNT(DISTINCT YEAR(p.Start_Time)) INTO v_consecutive_years
        FROM Performance p
        JOIN Event e ON p.Event_ID = e.Event_ID
        JOIN Festival f ON e.Festival_ID = f.Festival_ID
        WHERE p.Band_ID = NEW.Band_ID
        AND YEAR(p.Start_Time) BETWEEN (v_current_year - 3) AND (v_current_year - 1);
        
        IF v_consecutive_years >= 3 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Band cannot perform in more than 3 consecutive years.';
        END IF;
    END IF;
END //

DELIMITER ;

-- On update

DELIMITER //

CREATE TRIGGER trg_check_consecutive_years_update
BEFORE UPDATE ON Performance
FOR EACH ROW
BEGIN
    DECLARE v_consecutive_years INT;
    DECLARE v_current_year INT;
    
    -- Get year of current performance
    SET v_current_year = YEAR(NEW.Start_Time);
    
    -- Check for artists
    IF NEW.Artist_ID IS NOT NULL THEN
        -- Count distinct years in the last 3 years
        SELECT COUNT(DISTINCT YEAR(p.Start_Time)) INTO v_consecutive_years
        FROM Performance p
        JOIN Event e ON p.Event_ID = e.Event_ID
        JOIN Festival f ON e.Festival_ID = f.Festival_ID
        WHERE p.Artist_ID = NEW.Artist_ID
        AND YEAR(p.Start_Time) BETWEEN (v_current_year - 3) AND (v_current_year - 1);
        
        IF v_consecutive_years >= 3 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Artist cannot perform in more than 3 consecutive years.';
        END IF;
    END IF;
    
    -- Similar check for bands
    IF NEW.Band_ID IS NOT NULL THEN
        SELECT COUNT(DISTINCT YEAR(p.Start_Time)) INTO v_consecutive_years
        FROM Performance p
        JOIN Event e ON p.Event_ID = e.Event_ID
        JOIN Festival f ON e.Festival_ID = f.Festival_ID
        WHERE p.Band_ID = NEW.Band_ID
        AND YEAR(p.Start_Time) BETWEEN (v_current_year - 3) AND (v_current_year - 1);
        
        IF v_consecutive_years >= 3 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Band cannot perform in more than 3 consecutive years.';
        END IF;
    END IF;
END //

DELIMITER ;




-- Tickets <= capacity

DELIMITER //

CREATE TRIGGER trg_check_stage_capacity
BEFORE INSERT ON Ticket
FOR EACH ROW
BEGIN
    DECLARE msg TEXT;
    DECLARE v_stage_id INT;
    DECLARE v_max_capacity INT;
    DECLARE v_current_tickets INT;

    -- Βρες τη σκηνή του Event
    SELECT Stage_ID INTO v_stage_id
    FROM Event
    WHERE Event_ID = NEW.Event_ID;

    -- Βρες τη μέγιστη χωρητικότητα της σκηνής
    SELECT Maximum_Capacity INTO v_max_capacity
    FROM Stage
    WHERE Stage_ID = v_stage_id;

    -- Μέτρα πόσα Tickets υπάρχουν ήδη για αυτό το event
    SELECT COUNT(*) INTO v_current_tickets
    FROM Ticket
    WHERE Event_ID = NEW.Event_ID;

    -- Αν είναι πλήρης, σκάσε ERROR
    IF (v_current_tickets + 1) > v_max_capacity THEN
        SET msg = CONCAT('Cannot sell ticket: stage capacity exceeded (', v_current_tickets, '/', v_max_capacity, ').');
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = msg;

    END IF;
END //

DELIMITER ;

-- On update

DELIMITER //

CREATE TRIGGER trg_check_stage_capacity_update
BEFORE UPDATE ON Ticket
FOR EACH ROW
BEGIN
    DECLARE msg TEXT;
    DECLARE v_stage_id INT;
    DECLARE v_max_capacity INT;
    DECLARE v_current_tickets INT;

    -- Αν αλλάζει Event_id
    IF OLD.Event_ID != NEW.Event_ID THEN

        -- Βρες τη νέα σκηνή του νέου Performance
        SELECT Stage_ID INTO v_stage_id
        FROM Event
        WHERE Event_ID = NEW.Event_ID;

        -- Βρες τη μέγιστη χωρητικότητα της νέας σκηνής
        SELECT Maximum_Capacity INTO v_max_capacity
        FROM Stage
        WHERE Stage_ID = v_stage_id;

        -- Μέτρα πόσα Tickets υπάρχουν ήδη για το νέο Event
        SELECT COUNT(*) INTO v_current_tickets
        FROM Ticket
        WHERE Event_ID = NEW.Event_ID;

        -- Αν ξεπερνάμε τη χωρητικότητα, σκάμε ERROR
        IF (v_current_tickets + 1) > v_max_capacity THEN
            SET msg = CONCAT('Cannot update ticket: stage capacity exceeded (', v_current_tickets, '/', v_max_capacity, ').');
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = msg;
        END IF;
        
    END IF;
END //

DELIMITER ;





-- Trigger for VIP tickets <= 10%


DELIMITER //

CREATE TRIGGER trg_check_vip_ticket_capacity
BEFORE INSERT ON Ticket
FOR EACH ROW
BEGIN
    DECLARE msg TEXT;
    DECLARE v_stage_id INT;
    DECLARE v_max_capacity INT;
    DECLARE v_max_vip_tickets INT;
    DECLARE v_current_vip_tickets INT;

    -- Πάρε Stage_ID του event
    SELECT Stage_ID INTO v_stage_id
    FROM Event
    WHERE Event_ID = NEW.Event_ID;

    -- Πάρε Maximum_Capacity της Stage
    SELECT Maximum_Capacity INTO v_max_capacity
    FROM Stage
    WHERE Stage_ID = v_stage_id;

    -- Υπολόγισε 10% της χωρητικότητας
    SET v_max_vip_tickets = CEIL(v_max_capacity * 0.10);

    -- Μέτρα πόσα VIP εισιτήρια υπάρχουν ήδη για αυτό το Performance
    SELECT COUNT(*)
    INTO v_current_vip_tickets
    FROM Ticket
    WHERE Event_ID = NEW.Event_ID
      AND Category_ID = (SELECT Category_ID FROM Ticket_Category WHERE Category_Name = 'VIP');

    -- Αν πάμε να ξεπεράσουμε το 10%, πετάμε ERROR
    IF NEW.Category_ID = (SELECT Category_ID FROM Ticket_Category WHERE Category_Name = 'VIP')
    AND (v_current_vip_tickets + 1) > v_max_vip_tickets THEN
        SET msg = CONCAT('Cannot sell VIP ticket: limit exceeded (', v_current_vip_tickets, '/', v_max_vip_tickets, ').');
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = msg;
    END IF;
END //

DELIMITER ;

-- On update

DELIMITER //

CREATE TRIGGER trg_check_vip_ticket_capacity_update
BEFORE UPDATE ON Ticket
FOR EACH ROW
BEGIN
    DECLARE msg TEXT;
    DECLARE v_stage_id INT;
    DECLARE v_max_capacity INT;
    DECLARE v_max_vip_tickets INT;
    DECLARE v_current_vip_tickets INT;

    -- Μόνο αν το νέο Category είναι VIP και παλιά δεν ήταν VIP
    IF NEW.Category_ID != OLD.Category_ID THEN
    
        -- Πάρε Stage_ID του Event
        SELECT Stage_ID INTO v_stage_id
        FROM Event
        WHERE Event_ID = NEW.Event_ID;

        -- Πάρε Maximum_Capacity της Stage
        SELECT Maximum_Capacity INTO v_max_capacity
        FROM Stage
        WHERE Stage_ID = v_stage_id;

        -- Υπολόγισε 10% της χωρητικότητας
        SET v_max_vip_tickets = CEIL(v_max_capacity * 0.10);

        -- Μέτρα πόσα VIP εισιτήρια υπάρχουν ήδη για αυτό το Event
        SELECT COUNT(*)
        INTO v_current_vip_tickets
        FROM Ticket
        WHERE Event_ID = NEW.Event_ID
          AND Category_ID = (SELECT Category_ID FROM Ticket_Category WHERE Category_Name = 'VIP');

        -- Αν το νέο Category είναι VIP και ξεπερνάμε το 10%, πετάμε ERROR
        IF NEW.Category_ID = (SELECT Category_ID FROM Ticket_Category WHERE Category_Name = 'VIP')
        AND (v_current_vip_tickets + 1) > v_max_vip_tickets THEN
            SET msg = CONCAT('Cannot update to VIP ticket: limit exceeded (', v_current_vip_tickets, '/', v_max_vip_tickets, ').');
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = msg;
        END IF;
        
    END IF;
END //

DELIMITER ;


-- Buyer interest for ticket => 2 options => One is true


DELIMITER //

CREATE TRIGGER trg_check_resale_buyer_interest_insert
BEFORE INSERT ON Resale_Buyer_Interest
FOR EACH ROW
BEGIN
    -- Αν γέμισαν και τα δύο (Specific Ticket + Event/Category)
    IF (NEW.Specific_Ticket_ID IS NOT NULL AND (NEW.Event_ID IS NOT NULL OR NEW.Category_ID IS NOT NULL)) 
       OR
       (NEW.Specific_Ticket_ID IS NULL AND (NEW.Event_ID IS NULL OR NEW.Category_ID IS NULL)) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'You must either specify Specific_Ticket_ID OR (Event_ID AND Category_ID), but not both or none.';
    END IF;
END //

DELIMITER ;


-- On update


DELIMITER //

CREATE TRIGGER trg_check_resale_buyer_interest_update
BEFORE UPDATE ON Resale_Buyer_Interest
FOR EACH ROW
BEGIN
    IF (NEW.Specific_Ticket_ID IS NOT NULL AND (NEW.Event_ID IS NOT NULL OR NEW.Category_ID IS NOT NULL)) 
       OR
       (NEW.Specific_Ticket_ID IS NULL AND (NEW.Event_ID IS NULL OR NEW.Category_ID IS NULL)) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'You must either specify Specific_Ticket_ID OR (Event_ID AND Category_ID), but not both or none.';
    END IF;
END //

DELIMITER ;


-- Trigger: Call auto match

-- Trigger όταν ένας νέος πωλητής μπαίνει στην ουρά
DELIMITER //

CREATE TRIGGER trg_auto_match_after_seller
AFTER INSERT ON Resale_Seller_Queue
FOR EACH ROW
BEGIN
    CALL match_resale(NULL);
END //

DELIMITER ;





-- Check that rating matches a used ticket


DELIMITER //

CREATE TRIGGER trg_check_rating_permission_ticket
BEFORE INSERT ON Rating
FOR EACH ROW
BEGIN
    DECLARE v_Ticket_Status_ID INT;
    DECLARE CONTINUE HANDLER FOR NOT FOUND 
        SET v_Ticket_Status_ID = NULL;
    
    SELECT Ticket_Status_ID
    INTO v_Ticket_Status_ID
    FROM Ticket
    WHERE Visitor_ID = NEW.Visitor_ID
      AND Event_ID = (SELECT Event_ID FROM Performance WHERE Performance_ID = NEW.Performance_ID)
    LIMIT 1;

    IF v_Ticket_Status_ID IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Visitor does not have a ticket for this performance.';
    END IF;
    
    IF v_Ticket_Status_ID != (SELECT Status_ID FROM Ticket_Status WHERE Status_Name = 'used') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ticket is not activated (used). Cannot submit rating.';
    END IF;
END //

DELIMITER ;



-- Stored Procedures



-- Check ticket (valid or invalid)


DELIMITER //

CREATE PROCEDURE scan_ticket(IN p_Ticket_ID INT)
BEGIN
    DECLARE v_Status_Name VARCHAR(50);

    -- Πάρε την κατάσταση του εισιτηρίου
    SELECT Status_Name INTO v_Status_Name
    FROM Ticket_Status
    JOIN Ticket ON Ticket.Ticket_Status_ID = Ticket_Status.Status_ID
    WHERE Ticket.Ticket_ID = p_Ticket_ID;

    -- Αν είναι ήδη used, ρίξε error
    IF v_Status_Name = 'used' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ticket has already been used for entry!';
    ELSE
        -- Αλλιώς, κάνε update το status σε 'used'
        UPDATE Ticket
        SET Ticket_Status_ID = (SELECT Status_ID FROM Ticket_Status WHERE Status_Name = 'used')
        WHERE Ticket_ID = p_Ticket_ID;
    END IF;
END //

DELIMITER ;


-- Insert ticket (every day different price)


DELIMITER //

CREATE PROCEDURE buy_ticket(
    IN p_Visitor_ID INT,
    IN p_Performance_ID INT,
    IN p_Payment_Method_ID INT,
    IN p_EAN_Code VARCHAR(20),
    IN p_Category_ID INT
)
BEGIN
    DECLARE v_Start_Date DATE;
    DECLARE v_Festival_Start DATE;
    DECLARE v_Cost DECIMAL(10,2);
    DECLARE v_Days_Difference INT;
    DECLARE v_Event_ID INT;

    -- Get the Event_ID associated with this Performance
    SELECT Event_ID INTO v_Event_ID
    FROM Performance
    WHERE Performance_ID = p_Performance_ID;

    -- Πάρε την Start_Time της Performance
    SELECT Start_Time INTO v_Start_Date
    FROM Performance
    WHERE Performance_ID = p_Performance_ID;

    -- Πάρε την Start_Date του Festival
    SELECT Start_Date INTO v_Festival_Start
    FROM Festival
    JOIN Event ON Festival.Festival_ID = Event.Festival_ID
    JOIN Performance ON Event.Event_ID = Performance.Event_ID
    WHERE Performance.Performance_ID = p_Performance_ID;

    -- Υπολόγισε πόσες μέρες διαφορά
    SET v_Days_Difference = DATEDIFF(v_Start_Date, v_Festival_Start);

    -- Ορισμός τιμής βάσει ημέρας
    IF v_Days_Difference = 0 THEN
        SET v_Cost = 30.00;
        -- Πρώτη μέρα
    ELSEIF v_Days_Difference = 1 THEN
        SET v_Cost = 40.00;
        -- Δεύτερη μέρα
    ELSE
        SET v_Cost = 50.00;
        -- Από τρίτη μέρα και μετά
    END IF;

    -- Εισαγωγή εισιτηρίου
    INSERT INTO Ticket (
        Visitor_ID,
        Event_ID,
        Purchase_Date,
        Cost,
        Payment_Method_ID,
        EAN_Code,
        Category_ID,
        Ticket_Status_ID
    )
    VALUES (
        p_Visitor_ID,
        v_Event_ID,
        NOW(),
        v_Cost,
        p_Payment_Method_ID,
        p_EAN_Code,
        p_Category_ID,
        (SELECT Status_ID FROM Ticket_Status WHERE Status_Name = 'active')
    );
END //

DELIMITER ;


-- Stored procedure for securite/attendance in a performance




-- Procedure: put ticket on sale


DELIMITER //

CREATE PROCEDURE offer_ticket_for_resale(IN p_Ticket_ID INT)
BEGIN
    DECLARE v_Status_Name VARCHAR(50);
    DECLARE v_Available_Status_ID INT;
    
    -- Get the "available" status ID
    SELECT Status_ID INTO v_Available_Status_ID
    FROM Resale_Status 
    WHERE Status_Name = 'available';

    -- Βρες την κατάσταση του εισιτηρίου
    SELECT Status_Name INTO v_Status_Name
    FROM Ticket_Status
    JOIN Ticket ON Ticket.Ticket_Status_ID = Ticket_Status.Status_ID
    WHERE Ticket.Ticket_ID = p_Ticket_ID;

    -- Αν είναι ήδη used ➔ ERROR
    IF v_Status_Name = 'used' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot resale a used ticket!';
    ELSE
        -- Αν είναι ενεργό (active), τότε καταχωρείται στη Resale Queue
        INSERT INTO Resale_Queue (Ticket_ID, Sale_Status_ID)
        VALUES (p_Ticket_ID, v_Available_Status_ID);
    END IF;
END //

DELIMITER ;


-- Interest for a ticket


DELIMITER //

CREATE PROCEDURE create_resale_interest(
    IN p_Visitor_ID INT,
    IN p_Specific_Ticket_ID INT,
    IN p_Event_ID INT,
    IN p_Category_ID INT
)
BEGIN
    -- Λογικός έλεγχος: πρέπει να δώσει ΜΟΝΟ ΕΝΑΝ τύπο ενδιαφέροντος
    IF (p_Specific_Ticket_ID IS NOT NULL AND (p_Event_ID IS NOT NULL OR p_Category_ID IS NOT NULL))
        OR (p_Specific_Ticket_ID IS NULL AND (p_Event_ID IS NULL OR p_Category_ID IS NULL)) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'You must either specify a Specific Ticket OR (Event and Category), but not both or none.';
    ELSE
        INSERT INTO Resale_Buyer_Interest (
            Visitor_ID,
            Specific_Ticket_ID,
            Event_ID,
            Category_ID
        )
        VALUES (
            p_Visitor_ID,
            p_Specific_Ticket_ID,
            p_Event_ID,
            p_Category_ID
        );
    END IF;
END //

DELIMITER ;


-- Automatch Resale ticket with buyer and seller.


DELIMITER //

CREATE PROCEDURE match_resale(IN p_Ticket_ID INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_Ticket_ID INT;
    DECLARE v_Event_ID INT;
    DECLARE v_Category_ID INT;
    DECLARE v_Buyer_Visitor_ID INT;
    DECLARE v_Seller_Queue_ID INT;

    -- Cursor για να διαβάσει όλους τους διαθέσιμους πωλητές αν δεν δοθεί συγκεκριμένο εισιτήριο
    DECLARE seller_cursor CURSOR FOR
        SELECT Seller_Queue_ID, Ticket_ID
        FROM Resale_Seller_Queue
        WHERE Sale_Status_ID = (SELECT Status_ID FROM Resale_Status WHERE Status_Name = 'available')
        ORDER BY Listed_Date ASC;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Αν δώθηκε συγκεκριμένο εισιτήριο
    IF p_Ticket_ID IS NOT NULL THEN

        -- Βρες Performance και Category
        SELECT Event_ID, Category_ID
        INTO v_Event_ID, v_Category_ID
        FROM Ticket
        WHERE Ticket_ID = p_Ticket_ID;
        
        -- Βρες αγοραστή που το ζητάει
        SELECT Visitor_ID
        INTO v_Buyer_Visitor_ID
        FROM Resale_Buyer_Interest
        WHERE (Specific_Ticket_ID = p_Ticket_ID 
            OR (Event_ID = v_Event_ID AND Category_ID = v_Category_ID))
        ORDER BY Interest_Date ASC
        LIMIT 1;

        IF v_Buyer_Visitor_ID IS NOT NULL THEN
            -- Κάνε μεταβίβαση
            UPDATE Ticket
            SET Visitor_ID = v_Buyer_Visitor_ID
            WHERE Ticket_ID = p_Ticket_ID;

            -- Σήμανε ότι πουλήθηκε στο Seller Queue
            UPDATE Resale_Seller_Queue
            SET Sale_Status_ID = (SELECT Status_ID FROM Resale_Status WHERE Status_Name = 'sold')
            WHERE Ticket_ID = p_Ticket_ID;


            -- Σβήσε τον αγοραστή
            DELETE FROM Resale_Buyer_Interest
            WHERE Visitor_ID = v_Buyer_Visitor_ID
              AND (Specific_Ticket_ID = p_Ticket_ID 
                  OR (Event_ID = v_Event_ID AND Category_ID = v_Category_ID));
        END IF;

    ELSE 
        -- Αν δεν δώθηκε Ticket_ID ➔ scan όλους τους διαθέσιμους sellers
        OPEN seller_cursor;

        read_loop: LOOP
            FETCH seller_cursor INTO v_Seller_Queue_ID, v_Ticket_ID;
            IF done THEN
                LEAVE read_loop;
            END IF;

            -- Βρες Performance και Category
            SELECT Event_ID, Category_ID
            INTO v_Event_ID, v_Category_ID
            FROM Ticket
            WHERE Ticket_ID = v_Ticket_ID;

            -- Βρες αγοραστή
            SELECT Visitor_ID
            INTO v_Buyer_Visitor_ID
            FROM Resale_Buyer_Interest
            WHERE (Specific_Ticket_ID = v_Ticket_ID 
                OR (Event_ID = v_Event_ID AND Category_ID = v_Category_ID))
            ORDER BY Interest_Date ASC
            LIMIT 1;

            IF v_Buyer_Visitor_ID IS NOT NULL THEN
                -- Μεταβίβασε
                UPDATE Ticket
                SET Visitor_ID = v_Buyer_Visitor_ID
                WHERE Ticket_ID = v_Ticket_ID;

                -- Σήμανε πουλήθηκε
                UPDATE Resale_Seller_Queue
                SET Sale_Status_ID = (SELECT Status_ID FROM Resale_Status WHERE Status_Name = 'sold')
                WHERE Seller_Queue_ID = v_Seller_Queue_ID;


                -- Σβήσε τον αγοραστή
                DELETE FROM Resale_Buyer_Interest
                WHERE Visitor_ID = v_Buyer_Visitor_ID
                  AND (Specific_Ticket_ID = v_Ticket_ID 
                      OR (Event_ID = v_Event_ID AND Category_ID = v_Category_ID));
            END IF;
        END LOOP;

        CLOSE seller_cursor;
    END IF;
END //

DELIMITER ;



-- Restore original settings
SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
