SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

DROP SCHEMA IF EXISTS `Electorus` ;
CREATE SCHEMA IF NOT EXISTS `Electorus` ;
SHOW WARNINGS;
USE `Electorus` ;

-- -----------------------------------------------------
-- Table `Electorus`.`Elections`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Electorus`.`Elections` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `Electorus`.`Elections` (
  `Id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Election\'s (internal) id' ,
  `Name` VARCHAR(256) NOT NULL COMMENT 'Description' ,
  `Date` DATE NOT NULL COMMENT 'Date of the election' ,
  PRIMARY KEY (`Id`) )
ENGINE = InnoDB
AUTO_INCREMENT = 1
DEFAULT CHARACTER SET = utf8;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `Electorus`.`Candidates`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Electorus`.`Candidates` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `Electorus`.`Candidates` (
  `Id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `Name` VARCHAR(256) NOT NULL ,
  `Elections_id` INT(10) UNSIGNED NOT NULL ,
  PRIMARY KEY (`Id`, `Elections_id`) ,
  CONSTRAINT `fk_Candidates_Elections1`
    FOREIGN KEY (`Elections_id` )
    REFERENCES `Electorus`.`Elections` (`Id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 1
DEFAULT CHARACTER SET = utf8;

SHOW WARNINGS;
CREATE INDEX `fk_Candidates_Elections1` ON `Electorus`.`Candidates` (`Elections_id` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `Electorus`.`Regions`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Electorus`.`Regions` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `Electorus`.`Regions` (
  `Id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Region\'s (internal) id' ,
  `Name` VARCHAR(256) NOT NULL COMMENT 'Region\'s name' ,
  PRIMARY KEY (`Id`) )
ENGINE = InnoDB
AUTO_INCREMENT = 1
DEFAULT CHARACTER SET = utf8, 
COMMENT = 'Regions' ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `Electorus`.`Committees`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Electorus`.`Committees` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `Electorus`.`Committees` (
  `Id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `Parent_id` INT(11) NULL DEFAULT NULL ,
  `Name` VARCHAR(256) NOT NULL ,
  `Regions_id` INT(10) UNSIGNED NOT NULL ,
  PRIMARY KEY (`Id`, `Regions_id`) ,
  CONSTRAINT `fk_Committees_Regions`
    FOREIGN KEY (`Regions_id` )
    REFERENCES `Electorus`.`Regions` (`Id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 1
DEFAULT CHARACTER SET = utf8;

SHOW WARNINGS;
CREATE INDEX `fk_Committees_Regions` ON `Electorus`.`Committees` (`Regions_id` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `Electorus`.`Communities`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Electorus`.`Communities` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `Electorus`.`Communities` (
  `Id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Communuty (internal) id ' ,
  `Name` VARCHAR(256) NOT NULL COMMENT 'Community name' ,
  PRIMARY KEY (`Id`) )
ENGINE = InnoDB
AUTO_INCREMENT = 1
DEFAULT CHARACTER SET = utf8, 
COMMENT = 'Internal communities' ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `Electorus`.`Protocols`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Electorus`.`Protocols` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `Electorus`.`Protocols` (
  `Id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `Name` VARCHAR(256) NOT NULL ,
  `User_id` INT(10) UNSIGNED NOT NULL ,
  `Scan` LONGBLOB NULL DEFAULT NULL ,
  `Committees_id` INT(10) UNSIGNED NOT NULL ,
  `Communities_id` INT(10) UNSIGNED NOT NULL ,
  `Elections_Id` INT(10) UNSIGNED NOT NULL ,
  `Electors_qty` INT NOT NULL COMMENT 'Число избирателей, внесенных в список избирателей на момент окончания голосования' ,
  `Electors_remote_qty` INT NOT NULL COMMENT 'Число избирателей, проголосовавших по открепительным удостоверениям на избирательном участке' ,
  `Ballot_total_qty` INT NOT NULL COMMENT 'Число избирательных бюллетеней, полученных участковой избирательной комиссией' ,
  `Ballot_early_qty` INT NOT NULL COMMENT 'Число избирательных бюллетеней, выданных избирателям, проголосовавшим досрочно' ,
  `Ballot_regular_qty` INT NOT NULL COMMENT 'Число избирательных бюллетеней, выданных участковой избирательной комиссией избирателям в помещении для голосования в день голосования' ,
  `Ballot_outdoor_qty` INT NOT NULL COMMENT 'Число бюллетеней, выданных избирателям, проголосовавшим вне помещения для голосования в день голосования' ,
  `Ballot_deactive_qty` INT NOT NULL COMMENT 'Число погашенных бюллетеней' ,
  `Ballot_mobile_qty` INT NOT NULL COMMENT 'Число бюллетеней, содержащихся в переносных ящиках для голосования' ,
  `Ballot_land_qty` INT NOT NULL COMMENT 'Число избирательных бюллетеней, содержащихся в стационарных ящиках для голосования' ,
  `Ballot_wrong_qty` INT NOT NULL COMMENT 'Число недействительных избирательных бюллетеней' ,
  `Ballot_right_qty` INT NOT NULL COMMENT 'Число действительных избирательных бюллетеней' ,
  `Ballot_lost_qty` INT NOT NULL COMMENT 'Число утраченных избирательных бюллетеней' ,
  `Remote_doc_rcvd_qty` INT NOT NULL COMMENT 'Число открепительных удостоверений, полученных участковой избирательной комиссией' ,
  `Remote_doc_given_qty` INT NOT NULL COMMENT 'Число открепительных удостоверений, выданных участковой избирательной комиссией избирателям на избирательном участке до дня голосования' ,
  `Remote_doc_unused_qty` INT NOT NULL COMMENT 'Число погашенных неиспользованных открепительных удостоверений' ,
  `Remote_doc_given_upper_layer_qty` INT NOT NULL COMMENT 'Число открепительных удостоверений, выданных избирателям территориальной избирательной комиссией' ,
  `Remote_doc_lost_qty` INT NOT NULL COMMENT 'Число утраченных открепительных удостоверений' ,
  `Ballot_not_accounted_qty` INT NOT NULL COMMENT 'Число избирательных бюллетеней, не учтенных при получении' ,
  PRIMARY KEY (`Id`, `Committees_id`, `Communities_id`, `Elections_Id`) ,
  CONSTRAINT `fk_Protocols_Committees1`
    FOREIGN KEY (`Committees_id` )
    REFERENCES `Electorus`.`Committees` (`Id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Protocols_Communities1`
    FOREIGN KEY (`Communities_id` )
    REFERENCES `Electorus`.`Communities` (`Id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Protocols_Elections1`
    FOREIGN KEY (`Elections_Id` )
    REFERENCES `Electorus`.`Elections` (`Id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 1
DEFAULT CHARACTER SET = utf8;

SHOW WARNINGS;
CREATE INDEX `fk_Protocols_Committees1` ON `Electorus`.`Protocols` (`Committees_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_Protocols_Communities1` ON `Electorus`.`Protocols` (`Communities_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_Protocols_Elections1` ON `Electorus`.`Protocols` (`Elections_Id` ASC) ;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `Electorus`.`Votes`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Electorus`.`Votes` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `Electorus`.`Votes` (
  `Id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `Value` INT(11) UNSIGNED NOT NULL ,
  `Candidates_id` INT(10) UNSIGNED NOT NULL ,
  `Protocols_id` INT(10) UNSIGNED NOT NULL ,
  PRIMARY KEY (`Id`, `Candidates_id`, `Protocols_id`) ,
  CONSTRAINT `fk_Votes_Candidates1`
    FOREIGN KEY (`Candidates_id` )
    REFERENCES `Electorus`.`Candidates` (`Id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Votes_Protocols1`
    FOREIGN KEY (`Protocols_id` )
    REFERENCES `Electorus`.`Protocols` (`Id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 1
DEFAULT CHARACTER SET = utf8;

SHOW WARNINGS;
CREATE INDEX `fk_Votes_Candidates1` ON `Electorus`.`Votes` (`Candidates_id` ASC) ;

SHOW WARNINGS;
CREATE INDEX `fk_Votes_Protocols1` ON `Electorus`.`Votes` (`Protocols_id` ASC) ;

SHOW WARNINGS;

CREATE USER `Electorus-admin` IDENTIFIED BY 'Erectorus';

SHOW WARNINGS;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
