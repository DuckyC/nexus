-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               5.6.15-log - MySQL Community Server (GPL)
-- Server OS:                    Win32
-- HeidiSQL Version:             8.3.0.4694
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping database structure for nexus
CREATE DATABASE IF NOT EXISTS `nexus` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `nexus`;


-- Dumping structure for function nexus.64toID
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `64toID`(`SteamID64` BIGINT) RETURNS varchar(20) CHARSET latin1
    NO SQL
BEGIN
	DECLARE parta TINYINT;
	DECLARE partb BIGINT;
	SET parta = (SteamID64%2);
	SET partb = (SteamID64-76561197960265728-parta)/2;
	RETURN CONCAT('STEAM_0:',parta,':',partb);
END//
DELIMITER ;


-- Dumping structure for function nexus.IDto64
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `IDto64`(`SteamID` VARCHAR(20)) RETURNS bigint(20)
    NO SQL
BEGIN
	DECLARE parta TINYINT;
	DECLARE partb BIGINT;
	SET parta = CAST(SUBSTR(SteamID,9,1) AS UNSIGNED);
	SET partb = CAST(SUBSTR(SteamID,11) AS UNSIGNED);
	RETURN (partb*2) + parta + 76561197960265728;
END//
DELIMITER ;


-- Dumping structure for table nexus.nx_bans
CREATE TABLE IF NOT EXISTS `nx_bans` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `steamid` bigint(20) unsigned NOT NULL,
  `admin` bigint(20) unsigned NOT NULL,
  `reason` tinytext,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `length` time NOT NULL DEFAULT '00:00:00',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;

-- Dumping data for table nexus.nx_bans: ~0 rows (approximately)
DELETE FROM `nx_bans`;
/*!40000 ALTER TABLE `nx_bans` DISABLE KEYS */;
/*!40000 ALTER TABLE `nx_bans` ENABLE KEYS */;


-- Dumping structure for table nexus.nx_users
CREATE TABLE IF NOT EXISTS `nx_users` (
  `steamid` bigint(20) unsigned NOT NULL,
  `rank` tinyint(4) unsigned NOT NULL DEFAULT '1',
  `name` varchar(50) NOT NULL DEFAULT 'None',
  `timeplayed` time NOT NULL DEFAULT '00:00:00',
  `lastseen` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`steamid`),
  UNIQUE KEY `steamid_UNIQUE` (`steamid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table nexus.nx_users: ~0 rows (approximately)
DELETE FROM `nx_users`;
/*!40000 ALTER TABLE `nx_users` DISABLE KEYS */;
INSERT INTO `nx_users` (`steamid`, `rank`, `name`, `timeplayed`, `lastseen`) VALUES
	(76561198027099859, 1, 'Ducky', '00:00:00', '2014-09-05 19:46:34');
/*!40000 ALTER TABLE `nx_users` ENABLE KEYS */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
