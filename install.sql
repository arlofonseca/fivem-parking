CREATE TABLE `character_vehicles` (
  `owner` VARCHAR(255) NOT NULL,
  `plate` VARCHAR(8) NOT NULL,
  `model` INT NOT NULL,
  `props` LONGTEXT NOT NULL,
  `type` VARCHAR(255) DEFAULT 'car',
  `location` VARCHAR(255) DEFAULT 'impound',
  `fuel` int(11) DEFAULT 100,
  `body` float DEFAULT 1000,
  `engine` float DEFAULT 1000,
  PRIMARY KEY (`plate`)
); ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `character_parking` (
  `owner` VARCHAR(255) NOT NULL,
  `coords` LONGTEXT DEFAULT NULL,
  PRIMARY KEY (`owner`)
); ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;