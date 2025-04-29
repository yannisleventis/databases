-- Save settings and disable checks
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

-- Drop and recreate schema
DROP SCHEMA IF EXISTS musicfestival;
CREATE SCHEMA musicfestival;
USE musicfestival;


-- Table: Festival
CREATE TABLE Festival (
    Festival_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Year INT NOT NULL,
    Start_Date DATE NOT NULL,
    End_Date DATE NOT NULL,
    Daily_Max_Duration INT NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (Festival_ID),
    UNIQUE KEY uq_festival_year (Year), -- Each year can have only 1 pulse university festival.
    KEY idx_festival_year (Year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Table: Location
CREATE TABLE Location (
    Location_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Location_Address VARCHAR(255) NOT NULL,
    Geo_Coordinates VARCHAR(50),
    City VARCHAR(100),
    Country VARCHAR(100),
    Continent_ID INT UNSIGNED NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (Location_ID),
    FOREIGN KEY (Continent_ID) REFERENCES Continent(Continent_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Table: FestivalLocation
CREATE TABLE FestivalLocation (
    Festival_ID INT UNSIGNED NOT NULL,
    Location_ID INT UNSIGNED NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (Festival_ID, Location_ID),
    FOREIGN KEY (Festival_ID) REFERENCES Festival(Festival_ID),
    FOREIGN KEY (Location_ID) REFERENCES Location(Location_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
    Performance_Type VARCHAR(50) NOT NULL,
    Start_Time DATETIME NOT NULL,
    Duration INT NOT NULL CHECK (Duration <= 180),
    Break_Duration INT,
    Stage_ID INT UNSIGNED NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (Performance_ID),
    KEY idx_performance_event (Event_ID),
    FOREIGN KEY (Event_ID) REFERENCES Event(Event_ID),
    FOREIGN KEY (Stage_ID) REFERENCES Stage(Stage_ID),
    UNIQUE KEY uq_stage_starttime (Stage_ID, Start_Time) -- Each Stage ID must have unique start time
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Table: Equipment
CREATE TABLE Equipment (
    Equipment_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    Description TEXT,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (Equipment_ID)
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

-- Table: Personnel
CREATE TABLE Personnel (
    Personnel_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Personnel_Name VARCHAR(90) NOT NULL,
    Age INT,
    Personnel_Role VARCHAR(45) NOT NULL,
    Experience_Level_ID INT UNSIGNED NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (Personnel_ID),
    FOREIGN KEY (Experience_Level_ID) REFERENCES Experience_Level(Level_ID)
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

-- Table: Artist
CREATE TABLE Artist (
    Artist_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Artist_Name VARCHAR(100) NOT NULL,
    Date_of_Birth DATE,
    Website VARCHAR(255),
    Instagram VARCHAR(255),
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (Artist_ID)
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

-- Alter Table: Performance (add Artist and Band)
ALTER TABLE Performance
ADD COLUMN Artist_ID INT UNSIGNED NULL,
ADD COLUMN Band_ID INT UNSIGNED NULL,
ADD CONSTRAINT fk_Performance_Artist FOREIGN KEY (Artist_ID) REFERENCES Artist(Artist_ID),
ADD CONSTRAINT fk_Performance_Band FOREIGN KEY (Band_ID) REFERENCES Band(Band_ID);

-- If sold out: Start resale
ALTER TABLE Performance
ADD COLUMN Resale_Active BOOLEAN NOT NULL DEFAULT FALSE;

-- Table: Visitor
CREATE TABLE Visitor (
    Visitor_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    First_Name VARCHAR(45) NOT NULL,
    Last_Name VARCHAR(45) NOT NULL,
    Contact_Details VARCHAR(255),
    Age INT,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (Visitor_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Table: Ticket
CREATE TABLE Ticket (
    Ticket_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Visitor_ID INT UNSIGNED NOT NULL,
    Performance_ID INT UNSIGNED NOT NULL,
    Purchase_Date DATETIME NOT NULL,
    Cost DECIMAL(10,2) NOT NULL,
    Payment_Method_ID INT UNSIGNED NOT NULL,
    EAN_Code BIGINT NOT NULL,
    Category_ID INT UNSIGNED NOT NULL,
    Ticket_Status_ID INT UNSIGNED NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (Ticket_ID),
    UNIQUE KEY uq_ticket_visitor_performance (Visitor_ID, Performance_ID), -- one for each performance
    KEY idx_ticket_visitor (Visitor_ID),
    KEY idx_ticket_performance (Performance_ID),
    FOREIGN KEY (Visitor_ID) REFERENCES Visitor(Visitor_ID),
    FOREIGN KEY (Performance_ID) REFERENCES Performance(Performance_ID), 
    FOREIGN KEY (Payment_Method_ID) REFERENCES Payment_Method(Method_ID),
    FOREIGN KEY (Category_ID) REFERENCES Ticket_Category(Category_ID),
    FOREIGN KEY (Ticket_Status_ID) REFERENCES Ticket_Status(Status_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Table: Resale
CREATE TABLE Resale (
    Resale_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Ticket_ID INT UNSIGNED NOT NULL UNIQUE,
    Listing_Date DATETIME NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (Resale_ID),
    KEY idx_resale_ticket (Ticket_ID),
    FOREIGN KEY (Ticket_ID) REFERENCES Ticket(Ticket_ID)
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
    Rating_Date DATETIME NOT NULL,
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



-- Table: Resale queue
CREATE TABLE Resale_Queue (
    Resale_Queue_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Ticket_ID INT UNSIGNED NOT NULL,
    Listed_Date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Sale_Status_ID INT UNSIGNED NOT NULL,
    PRIMARY KEY (Resale_Queue_ID),
    FOREIGN KEY (Ticket_ID) REFERENCES Ticket(Ticket_ID),
    FOREIGN KEY (Sale_Status_ID) REFERENCES Resale_Status(Status_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Table: Buyers
CREATE TABLE Resale_Buyer_Interest (
    Interest_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Visitor_ID INT UNSIGNED NOT NULL, -- Ποιος επισκέπτης ενδιαφέρεται
    Specific_Ticket_ID INT UNSIGNED NULL, -- Συγκεκριμένο εισιτήριο (αν θέλει συγκεκριμένο)
    Performance_ID INT UNSIGNED NULL,     -- Εναλλακτικά: Παράσταση
    Category_ID INT UNSIGNED NULL,         -- Και κατηγορία εισιτηρίου (VIP / General κτλ)
    Interest_Date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Interest_ID),
    FOREIGN KEY (Visitor_ID) REFERENCES Visitor(Visitor_ID),
    FOREIGN KEY (Specific_Ticket_ID) REFERENCES Ticket(Ticket_ID),
    FOREIGN KEY (Performance_ID) REFERENCES Performance(Performance_ID),
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


-- Lookup Tables

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
    Status_Name VARCHAR(50) NOT NULL, -- π.χ. 'available', 'sold'
    PRIMARY KEY (Status_ID)
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

CREATE TRIGGER trg_check_performance_sequence
BEFORE INSERT ON Performance
FOR EACH ROW
BEGIN
    DECLARE v_Last_End DATETIME;
    DECLARE v_Last_Performance_ID INT;
    DECLARE v_Last_Break_Duration INT;

    -- Βρες την τελευταία εμφάνιση σε αυτό το Event
    SELECT Performance_ID, DATE_ADD(Start_Time, INTERVAL Duration + IFNULL(Break_Duration, 0) MINUTE)
    INTO v_Last_Performance_ID, v_Last_End
    FROM Performance
    WHERE Event_ID = NEW.Event_ID
    ORDER BY Start_Time DESC
    LIMIT 1;

    -- Αν υπάρχει προηγούμενο performance
    IF v_Last_End IS NOT NULL THEN
        -- Εξασφάλισε ότι ξεκινάει μετά το τέλος
        IF NEW.Start_Time <= v_Last_End THEN
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
    SELECT Performance_ID, DATE_ADD(Start_Time, INTERVAL Duration + IFNULL(Break_Duration, 0) MINUTE)
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

    -- Βρες Stage_ID της Performance
    SELECT Stage_ID INTO v_Stage_ID
    FROM Performance
    WHERE Performance_ID = NEW.Performance_ID;

    -- Βρες Maximum Capacity της Stage
    SELECT Maximum_Capacity INTO v_Max_Capacity
    FROM Stage
    WHERE Stage_ID = v_Stage_ID;

    -- Πόσα Tickets έχουν πωληθεί για την Performance
    SELECT COUNT(*)
    INTO v_Current_Tickets
    FROM Ticket
    WHERE Performance_ID = NEW.Performance_ID;

    -- Αν γεμίσαμε -> ενεργοποίησε Resale Mode
    IF v_Current_Tickets >= v_Max_Capacity THEN
        UPDATE Performance
        SET Resale_Active = TRUE
        WHERE Performance_ID = NEW.Performance_ID;
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
          AND ((NEW.Start_Time BETWEEN Start_Time AND DATE_ADD(Start_Time, INTERVAL Duration MINUTE))
            OR (Start_Time BETWEEN NEW.Start_Time AND DATE_ADD(NEW.Start_Time, INTERVAL NEW.Duration MINUTE)));
        
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
          AND ((NEW.Start_Time BETWEEN Start_Time AND DATE_ADD(Start_Time, INTERVAL Duration MINUTE))
            OR (Start_Time BETWEEN NEW.Start_Time AND DATE_ADD(NEW.Start_Time, INTERVAL NEW.Duration MINUTE)));
        
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
          AND ((NEW.Start_Time BETWEEN Start_Time AND DATE_ADD(Start_Time, INTERVAL Duration MINUTE))
            OR (Start_Time BETWEEN NEW.Start_Time AND DATE_ADD(NEW.Start_Time, INTERVAL NEW.Duration MINUTE)));
        
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
          AND ((NEW.Start_Time BETWEEN Start_Time AND DATE_ADD(Start_Time, INTERVAL Duration MINUTE))
            OR (Start_Time BETWEEN NEW.Start_Time AND DATE_ADD(NEW.Start_Time, INTERVAL NEW.Duration MINUTE)));
        
        IF v_count > 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Band is already scheduled for another performance at that time (update).';
        END IF;
    END IF;
END //

DELIMITER ;



-- Max 3 years consecutively for an artist


DELIMITER //

CREATE TRIGGER trg_check_artist_band_years
BEFORE INSERT ON Performance
FOR EACH ROW
BEGIN
    DECLARE v_count INT;

    -- Αν υπάρχει Artist
    IF NEW.Artist_ID IS NOT NULL THEN
        SELECT COUNT(DISTINCT f.Year)
        INTO v_count
        FROM Performance p
        JOIN Event e ON p.Event_ID = e.Event_ID
        JOIN Festival f ON e.Festival_ID = f.Festival_ID
        WHERE p.Artist_ID = NEW.Artist_ID
          AND (f.Year BETWEEN (SELECT Year FROM Festival WHERE Festival_ID = (SELECT Festival_ID FROM Event WHERE Event_ID = NEW.Event_ID)) - 2
                       AND (SELECT Year FROM Festival WHERE Festival_ID = (SELECT Festival_ID FROM Event WHERE Event_ID = NEW.Event_ID)));
        
        IF v_count >= 3 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Artist cannot participate in more than 3 consecutive years.';
        END IF;
    END IF;

    -- Αν υπάρχει Band
    IF NEW.Band_ID IS NOT NULL THEN
        SELECT COUNT(DISTINCT f.Year)
        INTO v_count
        FROM Performance p
        JOIN Event e ON p.Event_ID = e.Event_ID
        JOIN Festival f ON e.Festival_ID = f.Festival_ID
        WHERE p.Band_ID = NEW.Band_ID
          AND (f.Year BETWEEN (SELECT Year FROM Festival WHERE Festival_ID = (SELECT Festival_ID FROM Event WHERE Event_ID = NEW.Event_ID)) - 2
                       AND (SELECT Year FROM Festival WHERE Festival_ID = (SELECT Festival_ID FROM Event WHERE Event_ID = NEW.Event_ID)));
        
        IF v_count >= 3 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Band cannot participate in more than 3 consecutive years.';
        END IF;
    END IF;
END //

DELIMITER ;

-- On update

DELIMITER //

CREATE TRIGGER trg_check_artist_band_years_update
BEFORE UPDATE ON Performance
FOR EACH ROW
BEGIN
    DECLARE v_count INT;

    -- Αν υπάρχει Artist
    IF NEW.Artist_ID IS NOT NULL THEN
        SELECT COUNT(DISTINCT f.Year)
        INTO v_count
        FROM Performance p
        JOIN Event e ON p.Event_ID = e.Event_ID
        JOIN Festival f ON e.Festival_ID = f.Festival_ID
        WHERE p.Artist_ID = NEW.Artist_ID
          AND p.Performance_ID != NEW.Performance_ID
          AND (f.Year BETWEEN (SELECT Year FROM Festival WHERE Festival_ID = (SELECT Festival_ID FROM Event WHERE Event_ID = NEW.Event_ID)) - 2
                       AND (SELECT Year FROM Festival WHERE Festival_ID = (SELECT Festival_ID FROM Event WHERE Event_ID = NEW.Event_ID)));
        
        IF v_count >= 3 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Artist cannot participate in more than 3 consecutive years (update).';
        END IF;
    END IF;

    -- Αν υπάρχει Band
    IF NEW.Band_ID IS NOT NULL THEN
        SELECT COUNT(DISTINCT f.Year)
        INTO v_count
        FROM Performance p
        JOIN Event e ON p.Event_ID = e.Event_ID
        JOIN Festival f ON e.Festival_ID = f.Festival_ID
        WHERE p.Band_ID = NEW.Band_ID
          AND p.Performance_ID != NEW.Performance_ID
          AND (f.Year BETWEEN (SELECT Year FROM Festival WHERE Festival_ID = (SELECT Festival_ID FROM Event WHERE Event_ID = NEW.Event_ID)) - 2
                       AND (SELECT Year FROM Festival WHERE Festival_ID = (SELECT Festival_ID FROM Event WHERE Event_ID = NEW.Event_ID)));
        
        IF v_count >= 3 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Band cannot participate in more than 3 consecutive years (update).';
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
    DECLARE v_stage_id INT;
    DECLARE v_max_capacity INT;
    DECLARE v_current_tickets INT;

    -- Βρες τη σκηνή του Performance
    SELECT Stage_ID INTO v_stage_id
    FROM Performance
    WHERE Performance_ID = NEW.Performance_ID;

    -- Βρες τη μέγιστη χωρητικότητα της σκηνής
    SELECT Maximum_Capacity INTO v_max_capacity
    FROM Stage
    WHERE Stage_ID = v_stage_id;

    -- Μέτρα πόσα Tickets υπάρχουν ήδη για αυτό το Performance
    SELECT COUNT(*) INTO v_current_tickets
    FROM Ticket
    WHERE Performance_ID = NEW.Performance_ID;

    -- Αν είναι πλήρης, σκάσε ERROR
    IF (v_current_tickets + 1) > v_max_capacity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = CONCAT('Cannot sell ticket: stage capacity exceeded (', v_current_tickets, '/', v_max_capacity, ').');
    END IF;
END //

DELIMITER ;

-- On update

DELIMITER //

CREATE TRIGGER trg_check_stage_capacity_update
BEFORE UPDATE ON Ticket
FOR EACH ROW
BEGIN
    DECLARE v_stage_id INT;
    DECLARE v_max_capacity INT;
    DECLARE v_current_tickets INT;

    -- Αν αλλάζει Performance_ID
    IF OLD.Performance_ID != NEW.Performance_ID THEN

        -- Βρες τη νέα σκηνή του νέου Performance
        SELECT Stage_ID INTO v_stage_id
        FROM Performance
        WHERE Performance_ID = NEW.Performance_ID;

        -- Βρες τη μέγιστη χωρητικότητα της νέας σκηνής
        SELECT Maximum_Capacity INTO v_max_capacity
        FROM Stage
        WHERE Stage_ID = v_stage_id;

        -- Μέτρα πόσα Tickets υπάρχουν ήδη για το νέο Performance
        SELECT COUNT(*) INTO v_current_tickets
        FROM Ticket
        WHERE Performance_ID = NEW.Performance_ID;

        -- Αν ξεπερνάμε τη χωρητικότητα, σκάμε ERROR
        IF (v_current_tickets + 1) > v_max_capacity THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = CONCAT('Cannot update ticket: stage capacity exceeded (', v_current_tickets, '/', v_max_capacity, ').');
        END IF;
        
    END IF;
END //

DELIMITER ;


-- Trigger for (5% attendance) = security personnel 


DELIMITER //

CREATE TRIGGER trg_check_security_personnel
AFTER INSERT ON PerformancePersonnel
FOR EACH ROW
BEGIN
    CALL validate_security_for_performance(NEW.Performance_ID);
END //

CREATE TRIGGER trg_check_security_personnel_update
AFTER UPDATE ON PerformancePersonnel
FOR EACH ROW
BEGIN
    CALL validate_security_for_performance(NEW.Performance_ID);
END //

DELIMITER ;


-- Trigger for VIP tickets <= 10%


DELIMITER //

CREATE TRIGGER trg_check_vip_ticket_capacity
BEFORE INSERT ON Ticket
FOR EACH ROW
BEGIN
    DECLARE v_stage_id INT;
    DECLARE v_max_capacity INT;
    DECLARE v_max_vip_tickets INT;
    DECLARE v_current_vip_tickets INT;

    -- Πάρε Stage_ID του Performance
    SELECT Stage_ID INTO v_stage_id
    FROM Performance
    WHERE Performance_ID = NEW.Performance_ID;

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
    WHERE Performance_ID = NEW.Performance_ID
      AND Category_ID = (SELECT Category_ID FROM Ticket_Category WHERE Category_Name = 'VIP');

    -- Αν πάμε να ξεπεράσουμε το 10%, πετάμε ERROR
    IF NEW.Category_ID = (SELECT Category_ID FROM Ticket_Category WHERE Category_Name = 'VIP')
    AND (v_current_vip_tickets + 1) > v_max_vip_tickets THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = CONCAT('Cannot sell VIP ticket: limit exceeded (', v_current_vip_tickets, '/', v_max_vip_tickets, ').');
    END IF;
END //

DELIMITER ;

-- On update

DELIMITER //

CREATE TRIGGER trg_check_vip_ticket_capacity_update
BEFORE UPDATE ON Ticket
FOR EACH ROW
BEGIN
    DECLARE v_stage_id INT;
    DECLARE v_max_capacity INT;
    DECLARE v_max_vip_tickets INT;
    DECLARE v_current_vip_tickets INT;

    -- Μόνο αν το νέο Category είναι VIP και παλιά δεν ήταν VIP
    IF NEW.Category_ID != OLD.Category_ID THEN
    
        -- Πάρε Stage_ID του Performance
        SELECT Stage_ID INTO v_stage_id
        FROM Performance
        WHERE Performance_ID = NEW.Performance_ID;

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
        WHERE Performance_ID = NEW.Performance_ID
          AND Category_ID = (SELECT Category_ID FROM Ticket_Category WHERE Category_Name = 'VIP');

        -- Αν το νέο Category είναι VIP και ξεπερνάμε το 10%, πετάμε ERROR
        IF NEW.Category_ID = (SELECT Category_ID FROM Ticket_Category WHERE Category_Name = 'VIP')
        AND (v_current_vip_tickets + 1) > v_max_vip_tickets THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = CONCAT('Cannot update to VIP ticket: limit exceeded (', v_current_vip_tickets, '/', v_max_vip_tickets, ').');
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
    -- Αν γέμισαν και τα δύο (Specific Ticket + Performance/Category)
    IF (NEW.Specific_Ticket_ID IS NOT NULL AND (NEW.Performance_ID IS NOT NULL OR NEW.Category_ID IS NOT NULL)) 
       OR
       (NEW.Specific_Ticket_ID IS NULL AND (NEW.Performance_ID IS NULL OR NEW.Category_ID IS NULL)) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'You must either specify Specific_Ticket_ID OR (Performance_ID AND Category_ID), but not both or none.';
    END IF;
END //

DELIMITER ;


-- On update


DELIMITER //

CREATE TRIGGER trg_check_resale_buyer_interest_update
BEFORE UPDATE ON Resale_Buyer_Interest
FOR EACH ROW
BEGIN
    IF (NEW.Specific_Ticket_ID IS NOT NULL AND (NEW.Performance_ID IS NOT NULL OR NEW.Category_ID IS NOT NULL)) 
       OR
       (NEW.Specific_Ticket_ID IS NULL AND (NEW.Performance_ID IS NULL OR NEW.Category_ID IS NULL)) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'You must either specify Specific_Ticket_ID OR (Performance_ID AND Category_ID), but not both or none.';
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


-- Trigger όταν ένας νέος αγοραστής εκδηλώνει ενδιαφέρον
DELIMITER //

CREATE TRIGGER trg_auto_match_after_buyer
AFTER INSERT ON Resale_Buyer_Interest
FOR EACH ROW
BEGIN
    CALL match_resale(NULL);
END //

DELIMITER ;


-- Check that rating matches a used ticket


DELIMITER //

CREATE TRIGGER trg_check_rating_permission
BEFORE INSERT ON Rating
FOR EACH ROW
BEGIN
    DECLARE v_Ticket_Status_ID INT;
    
    -- Έλεγχος αν υπάρχει ενεργοποιημένο εισιτήριο για το Visitor και την Performance
    SELECT Ticket_Status_ID
    INTO v_Ticket_Status_ID
    FROM Ticket
    WHERE Visitor_ID = NEW.Visitor_ID
      AND Event_ID = (SELECT Event_ID FROM Performance WHERE Performance_ID = NEW.Performance_ID)
    LIMIT 1;

    -- Αν δεν βρέθηκε ή το εισιτήριο δεν είναι "used"
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


-- Check rating value


DELIMITER //

CREATE TRIGGER trg_check_rating_permission
BEFORE INSERT ON Rating
FOR EACH ROW
BEGIN
    DECLARE v_Ticket_Status_ID INT;
    
    -- Έλεγχος αν υπάρχει ΕΝΕΡΓΟΠΟΙΗΜΕΝΟ εισιτήριο για το Visitor και το Event του Performance
    SELECT Ticket_Status_ID
    INTO v_Ticket_Status_ID
    FROM Ticket
    WHERE Visitor_ID = NEW.Visitor_ID
      AND Event_ID = (SELECT Event_ID FROM Performance WHERE Performance_ID = NEW.Performance_ID)
    LIMIT 1;

    -- Αν δεν βρέθηκε ή δεν είναι 'used'
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


-- Insert ticker (every day different price)


DELIMITER //

CREATE PROCEDURE buy_ticket(
    IN p_Visitor_ID INT,
    IN p_Performance_ID INT,
    IN p_Payment_Method_ID INT,
    IN p_EAN_Code BIGINT,
    IN p_Category_ID INT
)
BEGIN
    DECLARE v_Start_Date DATE;
    DECLARE v_Festival_Start DATE;
    DECLARE v_Cost DECIMAL(10,2);
    DECLARE v_Days_Difference INT;

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
        SET v_Cost = 30.00; -- Πρώτη μέρα
    ELSEIF v_Days_Difference = 1 THEN
        SET v_Cost = 40.00; -- Δεύτερη μέρα
    ELSE
        SET v_Cost = 50.00; -- Από τρίτη μέρα και μετά
    END IF;

    -- Εισαγωγή εισιτηρίου
    INSERT INTO Ticket (
        Visitor_ID,
        Performance_ID,
        Purchase_Date,
        Cost,
        Payment_Method_ID,
        EAN_Code,
        Category_ID,
        Ticket_Status_ID
    )
    VALUES (
        p_Visitor_ID,
        p_Performance_ID,
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


DELIMITER //

CREATE PROCEDURE validate_security_for_performance(IN p_Performance_ID INT)
BEGIN
    DECLARE v_Stage_ID INT;
    DECLARE v_Max_Capacity INT;
    DECLARE v_Required_Security INT;
    DECLARE v_Required_Support INT;
    DECLARE v_Security_Count INT;
    DECLARE v_Support_Count INT;

    -- Βρες Stage_ID από Performance
    SELECT Stage_ID INTO v_Stage_ID
    FROM Performance
    WHERE Performance_ID = p_Performance_ID;

    -- Βρες τη μέγιστη χωρητικότητα της σκηνής
    SELECT Maximum_Capacity INTO v_Max_Capacity
    FROM Stage
    WHERE Stage_ID = v_Stage_ID;

    -- Υπολόγισε απαιτούμενους security και support
    SET v_Required_Security = CEIL(v_Max_Capacity * 0.05); -- 5%
    SET v_Required_Support = CEIL(v_Max_Capacity * 0.02);  -- 2%

    -- Πόσοι security υπάρχουν
    SELECT COUNT(*) INTO v_Security_Count
    FROM PerformancePersonnel
    JOIN Personnel ON PerformancePersonnel.Personnel_ID = Personnel.Personnel_ID
    WHERE PerformancePersonnel.Performance_ID = p_Performance_ID
      AND Personnel.Personnel_Role = 'security';

    -- Πόσοι support υπάρχουν
    SELECT COUNT(*) INTO v_Support_Count
    FROM PerformancePersonnel
    JOIN Personnel ON PerformancePersonnel.Personnel_ID = Personnel.Personnel_ID
    WHERE PerformancePersonnel.Performance_ID = p_Performance_ID
      AND Personnel.Personnel_Role = 'support';

    -- Έλεγχος
    IF v_Security_Count < v_Required_Security THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = CONCAT('Not enough security personnel: ', v_Security_Count, '/', v_Required_Security, ' required.');
    END IF;

    IF v_Support_Count < v_Required_Support THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = CONCAT('Not enough support personnel: ', v_Support_Count, '/', v_Required_Support, ' required.');
    END IF;

END //

DELIMITER ;


DELIMITER ;

-- Check the security on a stage

DELIMITER //

CREATE PROCEDURE validate_stage_security(IN p_Stage_ID INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE perf_id INT;
    DECLARE cur CURSOR FOR
        SELECT Performance_ID
        FROM Performance
        WHERE Stage_ID = p_Stage_ID;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO perf_id;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Για κάθε Performance στη Stage κάνε έλεγχο
        CALL validate_security_for_performance(perf_id);
    END LOOP;

    CLOSE cur;
END //

DELIMITER ;


-- Procedure: put ticket on sale


DELIMITER //

CREATE PROCEDURE offer_ticket_for_resale(IN p_Ticket_ID INT)
BEGIN
    DECLARE v_Status_Name VARCHAR(50);

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
        INSERT INTO Resale_Queue (Ticket_ID)
        VALUES (p_Ticket_ID);
    END IF;
END //

DELIMITER ;


-- Interest for a ticket


DELIMITER //

CREATE PROCEDURE create_resale_interest(
    IN p_Visitor_ID INT,
    IN p_Specific_Ticket_ID INT,
    IN p_Performance_ID INT,
    IN p_Category_ID INT
)
BEGIN
    -- Λογικός έλεγχος: πρέπει να δώσει ΜΟΝΟ ΕΝΑΝ τύπο ενδιαφέροντος
    IF (p_Specific_Ticket_ID IS NOT NULL AND (p_Performance_ID IS NOT NULL OR p_Category_ID IS NOT NULL))
        OR (p_Specific_Ticket_ID IS NULL AND (p_Performance_ID IS NULL OR p_Category_ID IS NULL)) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'You must either specify a Specific Ticket OR (Performance and Category), but not both or none.';
    ELSE
        INSERT INTO Resale_Buyer_Interest (
            Visitor_ID,
            Specific_Ticket_ID,
            Performance_ID,
            Category_ID
        )
        VALUES (
            p_Visitor_ID,
            p_Specific_Ticket_ID,
            p_Performance_ID,
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
    DECLARE v_Performance_ID INT;
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
        INTO v_Performance_ID, v_Category_ID
        FROM Ticket
        WHERE Ticket_ID = p_Ticket_ID;
        
        -- Βρες αγοραστή που το ζητάει
        SELECT Visitor_ID
        INTO v_Buyer_Visitor_ID
        FROM Resale_Buyer_Interest
        WHERE (Specific_Ticket_ID = p_Ticket_ID 
            OR (Performance_ID = v_Performance_ID AND Category_ID = v_Category_ID))
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

            -- Αν υπάρχει και στη Resale Queue update
            UPDATE Resale_Queue
            SET Sale_Status_ID = (SELECT Status_ID FROM Resale_Status WHERE Status_Name = 'sold')
            WHERE Ticket_ID = p_Ticket_ID;

            -- Σβήσε τον αγοραστή
            DELETE FROM Resale_Buyer_Interest
            WHERE Visitor_ID = v_Buyer_Visitor_ID
              AND (Specific_Ticket_ID = p_Ticket_ID 
                  OR (Performance_ID = v_Performance_ID AND Category_ID = v_Category_ID));
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
            INTO v_Performance_ID, v_Category_ID
            FROM Ticket
            WHERE Ticket_ID = v_Ticket_ID;

            -- Βρες αγοραστή
            SELECT Visitor_ID
            INTO v_Buyer_Visitor_ID
            FROM Resale_Buyer_Interest
            WHERE (Specific_Ticket_ID = v_Ticket_ID 
                OR (Performance_ID = v_Performance_ID AND Category_ID = v_Category_ID))
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

                UPDATE Resale_Queue
                SET Sale_Status_ID = (SELECT Status_ID FROM Resale_Status WHERE Status_Name = 'sold')
                WHERE Ticket_ID = v_Ticket_ID;

                -- Σβήσε τον αγοραστή
                DELETE FROM Resale_Buyer_Interest
                WHERE Visitor_ID = v_Buyer_Visitor_ID
                  AND (Specific_Ticket_ID = v_Ticket_ID 
                      OR (Performance_ID = v_Performance_ID AND Category_ID = v_Category_ID));
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
