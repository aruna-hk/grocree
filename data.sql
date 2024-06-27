-- MySQL dump 10.13  Distrib 8.0.36, for Linux (x86_64)
--
-- Host: localhost    Database: grocree
-- ------------------------------------------------------
-- Server version	8.0.36-2ubuntu3

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
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customers` (
  `name` varchar(35) NOT NULL,
  `username` varchar(25) NOT NULL,
  `password` varchar(15) NOT NULL,
  `email` varchar(35) NOT NULL,
  `phone` varchar(18) NOT NULL,
  `latitude` decimal(8,3) DEFAULT NULL,
  `longitude` decimal(8,3) DEFAULT NULL,
  `id` varchar(60) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `phone` (`phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` VALUES ('adasa','adsa','Aa48904890plmn','adasa@gmal.com','0706252312',-1.000,3.000,'adsa12',NULL,NULL),('anderson','andi','Aa48904890plmn','anderson@gmal.com','0706252323',2.000,3.000,'andi123',NULL,NULL),('beatrice','btric','Aa48904890plmn','btrice@gmal.com','0706252327',3.000,3.000,'btric123',NULL,NULL),('bukayo','bkyo','Aa48904890plmn','bukayo@gmal.com','0706252325',3.000,1.000,'bukayo12',NULL,NULL),('kirchov','chov','Aa48904890plmn','chov@gmal.com','0706252321',2.000,0.000,'chovr',NULL,NULL),('dan','dante','Aa48904890plmn','dante@gmal.com','07062ew52320',1.000,0.000,'dantedan',NULL,NULL),('edwin','edu','Aa48904890plmn','edwin@gmal.com','0706252313',-2.000,0.000,'edwin',NULL,NULL),('gilbert','gilbt','Aa48904890plmn','gilbert@gmal.com','0706252315',-2.000,2.000,'gilbert12',NULL,NULL),('haron','haroo','Aa48904890plmn','haron@gmal.com','0706252316',-3.000,3.000,'haroo123',NULL,NULL),('jared','jrd','Aa48904890plmn','jr@gmal.com','07142601221',0.000,0.000,'jare12',NULL,NULL),('jerald','jrld','Aa48904890plmn','jerald@gmal.com','0706252319',2.000,-1.000,'jeraldjrld',NULL,NULL),('joy','jooy','Aa48904890plmn','joy@gmal.com','0706252311',-1.000,2.000,'joy12',NULL,NULL),('kevo','kv','Aa48904890plmn','kv@gmal.com','071261231',-1.000,3.000,'kevokv',NULL,NULL),('kiptoo','hk','Aa48904890plmn','hk@gmal.com','0714261231',0.000,2.000,'kiptoohk',NULL,NULL),('koko','kk','Aa48904890plmn','kk@gmal.com','071426121',2.000,2.000,'kokokk',NULL,NULL),('leslie','les','Aa48904890plmn','les@gmal.com','071426e12',-1.000,0.000,'leslieles',NULL,NULL),('lawrence','lorro','Aa48904890plmn','lorro@gmal.com','0706252318',1.000,-1.000,'lorrro',NULL,NULL),('mill','meek','Aa48904890plmn','meek@gmal.com','0706252322',2.000,1.000,'millm',NULL,NULL),('mitch','mtch','Aa48904890plmn','mtch@gmal.com','714261231',3.000,3.000,'mitchmtch',NULL,NULL),('moses','mosee','Aa48904890plmn','mosee@gmal.com','1234',3.000,-1.000,'mos123',NULL,NULL),('moureen','mr','Aa48904890plmn','mr@gmal.com','07062523',1.000,2.000,'mrch',NULL,NULL),('muhamed','mhmed','Aa48904890plmn','muhammed@gmal.com','0706252326',3.000,2.000,'muhammed123',NULL,NULL),('naomi','naom','Aa48904890plmn','naomi@gmal.com','0706252328',-1.000,0.000,'naomi123',NULL,NULL),('nely','nl','Aa48904890plmn','nl@gmal.com','0714261232',-1.000,2.000,'nelynl',NULL,NULL),('nerd','nerdd','Aa48904890plmn','nerdd@gmal.com','0706252',1.000,3.000,'nnerd',NULL,NULL),('prudence','prude','Aa48904890plmn','prudence@gmal.com','0706252310',-1.000,1.000,'prude123',NULL,NULL),('rasi','rsi','Aa48904890plmn','rs@gmal.com','07142231',-1.000,1.000,'rasirsi',NULL,NULL),('recude','rcd','Aa48904890plmn','rc@gmal.com','0714211231',1.000,0.000,'recudercd',NULL,NULL),('rose','ros','Aa48904890plmn','ros@gmal.com','0714261',0.000,3.000,'roseros',NULL,NULL),('sifa','esifa','Aa48904890plmn','esifa@gmal.com','070625232',1.000,1.000,'sifaesifa',NULL,NULL),('smith','smth','Aa48904890plmn','smith@gmal.com','0706252324',3.000,0.000,'smith12',NULL,NULL),('steve','stve','Aa48904890plmn','steve@gmal.com','1426w1231',0.000,1.000,'stevestv',NULL,NULL),('steward','stwrd','Aa48904890plmn','steward@gmal.com','0706252314',-2.000,1.000,'stw123',NULL,NULL),('torvalds','tvrlds','Aa48904890plmn','tvrlds@gmal.com','072we61231',0.000,2.000,'tvrlds',NULL,NULL),('varun','vrn','Aa48904890plmn','varun@gmal.com','0706252317',0.000,-1.000,'varunvrn',NULL,NULL),('zubayr','zby','Aa48904890plmn','zbyr@gmal.com','0714296121',-1.000,2.000,'zubayrzby',NULL,NULL);
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `delivery`
--

DROP TABLE IF EXISTS `delivery`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delivery` (
  `nationalId` int NOT NULL,
  `name` varchar(30) NOT NULL,
  `username` varchar(60) NOT NULL,
  `password` varchar(15) NOT NULL,
  `email` varchar(35) NOT NULL,
  `phone` varchar(18) NOT NULL,
  `latitude` decimal(8,3) DEFAULT NULL,
  `longitude` decimal(8,3) DEFAULT NULL,
  `id` varchar(60) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nationalId` (`nationalId`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `phone` (`phone`),
  UNIQUE KEY `ix_delivery_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `delivery`
--

LOCK TABLES `delivery` WRITE;
/*!40000 ALTER TABLE `delivery` DISABLE KEYS */;
INSERT INTO `delivery` VALUES (10,'aa','bb','cc','aabbcc@gmail.cm','0010',2.000,1.000,'aabbcc',NULL,NULL),(1,'a','b','c','abc@gmail.cm','0001',0.000,0.000,'abc',NULL,NULL),(11,'dd','ee','ff','ddeeff@gmail.cm','0011',2.000,2.000,'ddeeff',NULL,NULL),(2,'d','e','f','def@gmail.cm','0002',0.000,1.000,'def',NULL,NULL),(12,'gg','hh','ii','gghhii@gmail.cm','0012',2.000,3.000,'gghhii',NULL,NULL),(3,'g','h','i','ghi@gmail.cm','0003',0.000,2.000,'ghi',NULL,NULL),(13,'jj','kk','ll','jjkkll@gmail.cm','0013',3.000,0.000,'jjkkll',NULL,NULL),(4,'j','k','l','jkl@gmail.cm','0004',0.000,3.000,'jkl',NULL,NULL),(14,'mm','nn','oo','mmnnoo@gmail.cm','0014',-1.000,3.000,'mmnnoo',NULL,NULL),(5,'m','n','o','mno@gmail.cm','0005',-1.000,0.000,'mno',NULL,NULL),(15,'pp','qq','rr','ppqqrr@gmail.cm','0015',2.000,-3.000,'ppqqrr',NULL,NULL),(6,'p','q','r','pqr@gmail.cm','0006',-1.000,1.000,'pqr',NULL,NULL),(16,'ss','tt','uu','ssttuu@gmail.cm','0016',-2.000,-1.000,'ssttuu',NULL,NULL),(7,'s','t','u','stu@gmail.cm','0007',-1.000,2.000,'stu',NULL,NULL),(8,'v','w','x','vwx@gmail.cm','0008',-1.000,3.000,'vwx',NULL,NULL),(9,'y','z','zz','yzz@gmail.cm','0009',2.000,0.000,'yzz',NULL,NULL);
/*!40000 ALTER TABLE `delivery` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `groceries`
--

DROP TABLE IF EXISTS `groceries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `groceries` (
  `name` varchar(20) NOT NULL,
  `description` text NOT NULL,
  `category` varchar(20) NOT NULL,
  `id` varchar(60) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_groceries_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `groceries`
--

LOCK TABLES `groceries` WRITE;
/*!40000 ALTER TABLE `groceries` DISABLE KEYS */;
INSERT INTO `groceries` VALUES ('bananas','blablabla','fruits','bn1',NULL,NULL),('cherry','blablabla','fruits','cr1',NULL,NULL),('cow meat','blablabla','meat','cwm1',NULL,NULL),('kales','blablabla','vegatables','kal1',NULL,NULL),('mangos','blablabla','fruits','mn1',NULL,NULL),('pumkin','blablabla','vegetables','pm1',NULL,NULL),('pork','blablabla','meat','prk1',NULL,NULL),('spinach','blablabla','vigetables','spn1',NULL,NULL),('strawbaries','blablabla','fruits','str1',NULL,NULL);
/*!40000 ALTER TABLE `groceries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory`
--

DROP TABLE IF EXISTS `inventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory` (
  `storedId` varchar(60) DEFAULT NULL,
  `groceryId` varchar(60) DEFAULT NULL,
  `stock` decimal(12,3) NOT NULL,
  `price` decimal(12,3) NOT NULL,
  `updated_at` datetime DEFAULT NULL,
  `id` varchar(60) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `storedId` (`storedId`),
  KEY `groceryId` (`groceryId`),
  CONSTRAINT `inventory_ibfk_1` FOREIGN KEY (`storedId`) REFERENCES `stores` (`id`),
  CONSTRAINT `inventory_ibfk_2` FOREIGN KEY (`groceryId`) REFERENCES `groceries` (`id`),
  CONSTRAINT `stock_level` CHECK ((`stock` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory`
--

LOCK TABLES `inventory` WRITE;
/*!40000 ALTER TABLE `inventory` DISABLE KEYS */;
INSERT INTO `inventory` VALUES ('ps','bn1',500.000,10.000,NULL,'inv0',NULL),('gws','bn1',500.000,10.000,NULL,'inv1',NULL),('gws','cr1',500.000,10.000,NULL,'inv10',NULL),('gws','spn1',500.000,10.000,NULL,'inv11',NULL),('eq1','spn1',500.000,10.000,NULL,'inv12',NULL),('eq1','cr1',500.000,10.000,NULL,'inv13',NULL),('eq1','prk1',500.000,10.000,NULL,'inv14',NULL),('eq1','cwm1',500.000,10.000,NULL,'inv15',NULL),('rs','prk1',500.000,10.000,NULL,'inv16',NULL),('rs','cwm1',500.000,10.000,NULL,'inv17',NULL),('rs','cr1',500.000,10.000,NULL,'inv18',NULL),('rs','pm1',500.000,10.000,NULL,'inv19',NULL),('ps','mn1',100.000,20.000,NULL,'inv2',NULL),('ps','cr1',500.000,50.000,NULL,'inv3',NULL),('ps','str1',456.000,60.600,NULL,'inv4',NULL),('ps','pm1',20.000,100.000,NULL,'inv5',NULL),('ps','spn1',500.000,30.000,NULL,'inv6',NULL),('gws','cwm1',600.800,450.000,NULL,'inv7',NULL),('gws','prk1',500.000,10.000,NULL,'inv8',NULL),('gws','kal1',500.000,10.000,NULL,'inv9',NULL);
/*!40000 ALTER TABLE `inventory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orderLine`
--

DROP TABLE IF EXISTS `orderLine`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orderLine` (
  `orderId` varchar(60) DEFAULT NULL,
  `groceryId` varchar(60) DEFAULT NULL,
  `quantity` decimal(12,2) DEFAULT NULL,
  `id` varchar(60) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `orderId` (`orderId`),
  KEY `groceryId` (`groceryId`),
  CONSTRAINT `orderLine_ibfk_1` FOREIGN KEY (`orderId`) REFERENCES `orders` (`id`),
  CONSTRAINT `orderLine_ibfk_2` FOREIGN KEY (`groceryId`) REFERENCES `groceries` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orderLine`
--

LOCK TABLES `orderLine` WRITE;
/*!40000 ALTER TABLE `orderLine` DISABLE KEYS */;
/*!40000 ALTER TABLE `orderLine` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `customerId` varchar(60) DEFAULT NULL,
  `storeId` varchar(60) DEFAULT NULL,
  `deliveryPersonId` varchar(60) DEFAULT NULL,
  `orderStatus` varchar(12) NOT NULL,
  `id` varchar(60) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `customerId` (`customerId`),
  KEY `storeId` (`storeId`),
  KEY `deliveryPersonId` (`deliveryPersonId`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`customerId`) REFERENCES `customers` (`id`),
  CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`storeId`) REFERENCES `stores` (`id`),
  CONSTRAINT `orders_ibfk_3` FOREIGN KEY (`deliveryPersonId`) REFERENCES `delivery` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stores`
--

DROP TABLE IF EXISTS `stores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stores` (
  `name` varchar(30) NOT NULL,
  `areaName` varchar(30) NOT NULL,
  `latitude` decimal(8,3) DEFAULT NULL,
  `longitude` decimal(8,3) DEFAULT NULL,
  `id` varchar(60) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_stores_areaName` (`areaName`),
  KEY `ix_stores_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stores`
--

LOCK TABLES `stores` WRITE;
/*!40000 ALTER TABLE `stores` DISABLE KEYS */;
INSERT INTO `stores` VALUES ('upperEq','equatorUp',1.000,1.000,'eq1',NULL,NULL),('gw','greenwich',-1.000,-2.000,'gws',NULL,NULL),('polar1','tactic',0.000,-3.000,'ps',NULL,NULL),('polarN','russia',2.000,-2.000,'rs',NULL,NULL);
/*!40000 ALTER TABLE `stores` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-06-17 14:29:13
