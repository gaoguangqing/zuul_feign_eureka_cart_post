CREATE DATABASE spoonshop CHARSET utf8;
USE spoonshop;
CREATE TABLE `tb_cart` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT(20) DEFAULT NULL,
  `item_id` BIGINT(20) DEFAULT NULL,
  `item_title` VARCHAR(100) DEFAULT NULL,
  `item_image` VARCHAR(200) DEFAULT NULL,
  `item_price` BIGINT(20) DEFAULT NULL COMMENT '单位：分',
  `num` INT(10) DEFAULT NULL,
  `created` DATETIME DEFAULT NULL,
  `updated` DATETIME DEFAULT NULL,
  PRIMARY KEY  (`id`),
  KEY `AK_user_itemId` (`user_id`,`item_id`)
) ENGINE=INNODB DEFAULT CHARSET=utf8;
INSERT  INTO tb_cart
(`user_id`,`item_id`,`item_title`,`item_image`,`item_price`,`num`,`created`,`updated`) 
VALUES
(7,562378,'苹果','9944a.jpg',4299000,3,'2018-02-09 10:50:52','2018-11-14 13:44:04'),
(7,562379,'爱立信','2233b.jpg',5339000,11,'2018-10-23 11:42:03','2018-11-14 13:44:37');