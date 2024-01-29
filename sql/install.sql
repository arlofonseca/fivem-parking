-- CreateTable
CREATE TABLE 
  IF NOT EXISTS `bgarage_ownedvehicles` (
    `owner` VARCHAR(255) NOT NULL,
    `plate` VARCHAR(8) NOT NULL,
    `model` INT NOT NULL,
    `props` LONGTEXT NOT NULL,
    `location` VARCHAR(255) DEFAULT 'impound',
    `type` VARCHAR(255) DEFAULT 'car',
  
    PRIMARY KEY (`plate`)
  );

-- CreateTable
CREATE TABLE 
  IF NOT EXISTS `bgarage_parkingspots` (
    `owner` VARCHAR(255) NOT NULL,
    `coords` LONGTEXT DEFAULT NULL,

    PRIMARY KEY (`owner`)
  );
