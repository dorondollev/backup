-- MySQL dump 10.13  Distrib 8.0.26, for Linux (x86_64)
--
-- Host: localhost    Database: backup
-- ------------------------------------------------------
-- Server version	8.0.26

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `commands`
--

DROP TABLE IF EXISTS `commands`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `commands` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `path` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `target_path` varchar(100) DEFAULT NULL,
  `schedule` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `file_type` varchar(10) DEFAULT NULL,
  `command` varchar(512) DEFAULT NULL,
  `enable` tinyint(1) NOT NULL DEFAULT '0',
  `active` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `commands`
--

LOCK TABLES `commands` WRITE;
/*!40000 ALTER TABLE `commands` DISABLE KEYS */;
INSERT INTO `commands` VALUES (1,'rocky','/boot','/backup/rocky/daily','daily','incremental','xfs.bz2','xfsdump -l 1 - /dev/sda1 | bzip2 > /backup/rocky/daily/rocky.boot.daily.inc.',1,0),(2,'rocky','/boot','/backup/rocky/weekly','weekly','full','xfs.bz2','xfsdump -l 0 - /dev/sda1 | bzip2 > /backup/rocky/weekly/rocky.boot.weekly.full.',1,1),(3,'rocky','/','/backup/rocky/weekly','weekly','full','xfs.bz2','xfsdump -l 0 - / | bzip2 > /backup/rocky/weekly/rocky.root.weekly.full.',1,1),(4,'rocky','/','/backup/rocky/daily','daily','incremental','xfs.bz2',' xfsdump -l 1 - / | bzip2 > /backup/rocky/daily/rocky.root.daily.inc.',1,0);
/*!40000 ALTER TABLE `commands` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `state`
--

DROP TABLE IF EXISTS `state`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `state` (
  `state_id` int NOT NULL AUTO_INCREMENT,
  `command_id` int NOT NULL,
  `date_start` date DEFAULT NULL,
  `time_start` time DEFAULT NULL,
  `date_end` date DEFAULT NULL,
  `time_end` time DEFAULT NULL,
  `logfile` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `backup_file` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `backup_file_size` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `result` smallint DEFAULT '0',
  `output` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  PRIMARY KEY (`state_id`),
  KEY `commands_fk` (`command_id`),
  CONSTRAINT `commands_fk` FOREIGN KEY (`command_id`) REFERENCES `commands` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `state`
--

LOCK TABLES `state` WRITE;
/*!40000 ALTER TABLE `state` DISABLE KEYS */;
INSERT INTO `state` VALUES (45,1,'2022-01-20','11:44:09','2022-01-20','11:44:00','/var/log/syslog.dated/current/rocky.daily.78793.log','/backup/rocky/daily/rocky.boot.daily.inc.Thu.Jan.20.11_44.2022.xfs.bz2','333',NULL,NULL),(46,4,'2022-01-20','11:44:09','2022-01-20','11:44:00','/var/log/syslog.dated/current/rocky.daily.78792.log','/backup/rocky/daily/rocky.root.daily.inc.Thu.Jan.20.11_44.2022.xfs.bz2','14',NULL,NULL),(47,4,'2022-01-20','14:49:25','2022-01-20','14:49:00','/var/log/syslog.dated/current/rocky.daily.log','/backup/rocky/daily/rocky.root.daily.inc.Thu.Jan.20.14_49.2022.xfs.bz2','14',0,NULL),(48,1,'2022-01-20','14:49:25','2022-01-20','14:49:00','/var/log/syslog.dated/current/rocky.daily.log','/backup/rocky/daily/rocky.boot.daily.inc.Thu.Jan.20.14_49.2022.xfs.bz2','336',0,NULL),(49,1,'2022-01-24','18:06:21','2022-01-24','18:06:00','/var/log/syslog.dated/current/rocky.daily.log','/backup/rocky/daily/rocky.boot.daily.inc.Mon.Jan.24.18_6.2022.xfs.bz2','336',0,NULL),(50,4,'2022-01-24','18:06:21','2022-01-24','18:06:00','/var/log/syslog.dated/current/rocky.daily.log','/backup/rocky/daily/rocky.root.daily.inc.Mon.Jan.24.18_6.2022.xfs.bz2','14',0,NULL),(51,4,'2022-01-24','18:08:05','2022-01-24','18:08:00','/var/log/syslog.dated/current/rocky.daily.log','/backup/rocky/daily/rocky.root.daily.inc.Mon.Jan.24.18_8.2022.xfs.bz2','14',0,NULL),(52,1,'2022-01-24','18:08:05','2022-01-24','18:08:00','/var/log/syslog.dated/current/rocky.daily.log','/backup/rocky/daily/rocky.boot.daily.inc.Mon.Jan.24.18_8.2022.xfs.bz2','352',0,NULL);
/*!40000 ALTER TABLE `state` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2022-02-15 13:28:38
