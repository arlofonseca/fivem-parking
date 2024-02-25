CREATE TABLE `bgarage_owned_vehicles` (
  `owner` VARCHAR(255) NOT NULL,
  `plate` VARCHAR(8) NOT NULL,
  `model` INT NOT NULL,
  `props` LONGTEXT NOT NULL,
  `location` VARCHAR(255) DEFAULT 'impound',
  `type` VARCHAR(255) DEFAULT 'car',
  PRIMARY KEY (`plate`)
); ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `bgarage_parking_locations` (
  `owner` VARCHAR(255) NOT NULL,
  `coords` LONGTEXT DEFAULT NULL,
  PRIMARY KEY (`owner`)
); ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
