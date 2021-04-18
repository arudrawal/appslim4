--
-- keep track of database changes.
--
CREATE TABLE `migrations` (
       `mig_ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
       `mig_UP_SCRIPT` varchar(256) NOT NULL DEFAULT '',
       `mig_DN_SCRIPT` varchar(256) NOT NULL DEFAULT '',
        PRIMARY KEY (`mig_ID`)
        );