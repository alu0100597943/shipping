DROP TABLE IF EXISTS `purchases`;
CREATE TABLE `purchases` (
  `id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `creator_id` INT(11) UNSIGNED NOT NULL,
  `billing_address_id` INT(11) UNSIGNED NOT NULL,
  `shipping_address_id` INT(11) UNSIGNED NOT NULL,
  `shipping_same_as_billing` INT(1) NOT NULL DEFAULT 0,
  `number` VARCHAR(40) NOT NULL,
  `currency` VARCHAR(3) NOT NULL,
  `monetary` TEXT,
  `is_frozen` INT(1) UNSIGNED NOT NULL DEFAULT 0,
  `is_deleted` INT(1) UNSIGNED NOT NULL DEFAULT 0,
  `created_at` DATETIME,
  `updated_at` DATETIME,
  PRIMARY KEY  (`id`),
  KEY `fk_user_id` (`creator_id`)
) ENGINE=INNODB  DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `store_purchases`;
CREATE TABLE `store_purchases` (
  `id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `number` VARCHAR(40) NOT NULL,
  `store_id` INT(10) UNSIGNED NULL,
  `purchase_id` INT(10) UNSIGNED NULL,
  `is_deleted` INT(1) UNSIGNED NOT NULL,
  `created_at` DATETIME,
  `updated_at` DATETIME,
  PRIMARY KEY  (`id`)
) ENGINE=INNODB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `store_refunds`;
CREATE TABLE `store_refunds` (
  `id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `store_purchase_id` INT(10) UNSIGNED NULL,
  `created_at` DATETIME,
  `raw_response` TEXT,
  `reason` TEXT,
  `is_deleted` INT(1) UNSIGNED NOT NULL,
  `status` VARCHAR(20) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=INNODB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `store_refund_items`;
CREATE TABLE `store_refund_items` (
  `id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `store_refund_id` INT(10) UNSIGNED NULL,
  `purchase_item_id` INT(10) UNSIGNED NULL,
  `amount` DECIMAL(10,2) NULL,
  `is_deleted` INT(1) UNSIGNED NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=INNODB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `payments`;
CREATE TABLE `payments` (
  `id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `purchase_id` INT(10) UNSIGNED NULL,
  `payment_id` VARCHAR(255) NOT NULL,
  `model` VARCHAR(20) NOT NULL,
  `status` VARCHAR(20) NOT NULL,
  `raw_response` TEXT,
  `is_deleted` INT(1) UNSIGNED NOT NULL,
  `created_at` DATETIME,
  `updated_at` DATETIME,
  PRIMARY KEY  (`id`)
) ENGINE=INNODB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `purchase_items`;
CREATE TABLE `purchase_items` (
  `id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `store_purchase_id` INT(10) UNSIGNED NULL,
  `reference_id` INT(10) UNSIGNED NULL,
  `reference_model` VARCHAR(40) NULL,
  `price` DECIMAL(10,2) NULL,
  `quantity` INT(11) NULL,
  `model` VARCHAR(255) NULL,
  `is_payable` INT(1) UNSIGNED NOT NULL,
  `is_discount` INT(1) UNSIGNED NOT NULL,
  `is_deleted` INT(1) UNSIGNED NOT NULL,
  `created_at` DATETIME,
  `updated_at` DATETIME,
  PRIMARY KEY  (`id`)
) ENGINE=INNODB  DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `email` VARCHAR(254) NOT NULL,
  `username` VARCHAR(32) NOT NULL DEFAULT '',
  `password` VARCHAR(64) NOT NULL,
  `logins` INT(10) UNSIGNED NOT NULL DEFAULT '0',
  `last_login` INT(10) UNSIGNED,
  `facebook_uid` VARCHAR(100),
  `twitter_uid` VARCHAR(100),
  `last_login_ip` VARCHAR(40),
  PRIMARY KEY  (`id`),
  UNIQUE KEY `uniq_username` (`username`),
  UNIQUE KEY `uniq_email` (`email`)
) ENGINE=INNODB  DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `stores`;
CREATE TABLE `stores` (
  `id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(254) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=INNODB  DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `products`;
CREATE TABLE `products` (
  `id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(254) NOT NULL,
  `price` DECIMAL(10,2) NOT NULL,
  `currency` VARCHAR(3) NOT NULL,
  `store_id` INT(10) UNSIGNED NULL,
  `shipping_id` INT(10) UNSIGNED NULL,
  PRIMARY KEY  (`id`)
) ENGINE=INNODB  DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `variations`;
CREATE TABLE `variations` (
  `id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(254) NOT NULL,
  `price` DECIMAL(10,2) NOT NULL,
  `product_id` INT(10) UNSIGNED NULL,
  PRIMARY KEY  (`id`)
) ENGINE=INNODB  DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `locations`;
CREATE TABLE `locations` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `short_name` varchar(10) NOT NULL,
  `type` varchar(100) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `locations_branches`;
CREATE TABLE `locations_branches` (
  `ansestor_id` int(11) UNSIGNED NOT NULL,
  `descendant_id` int(11) UNSIGNED NOT NULL,
  `depth` int(11) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `shippings`;
CREATE TABLE `shippings` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `currency` varchar(3) NOT NULL,
  `processing_time` varchar(100) NOT NULL,
  `ships_from_id` int(11) UNSIGNED NOT NULL,
  `store_id` int(11) UNSIGNED NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `shipping_groups`;
CREATE TABLE `shipping_groups` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `price` DECIMAL(10,2) NOT NULL,
  `additional_item_price` DECIMAL(10,2) NULL,
  `discount_threshold` DECIMAL(10,2) NULL,
  `delivery_time` varchar(100) NOT NULL,
  `shipping_id` int(11) UNSIGNED NOT NULL,
  `method_id` int(11) UNSIGNED NOT NULL,
  `location_id` int(11) UNSIGNED NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `shipping_methods`;
CREATE TABLE `shipping_methods` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `store_id` int(11) UNSIGNED NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `store_purchase_shippings`;
CREATE TABLE `store_purchase_shippings` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `location_id` int(11) UNSIGNED NOT NULL,
  `store_purchase_id` int(11) UNSIGNED NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `shipping_items`;
CREATE TABLE `shipping_items` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `purchase_item_id` int(11) UNSIGNED NULL,
  `shipping_group_id` int(11) UNSIGNED NULL,
  `delivery_time` varchar(100) NULL,
  `processing_time` varchar(100) NULL,
  `store_purchase_shipping_id` int(11) UNSIGNED NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `addresses`;
CREATE TABLE `addresses` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `country_id` int(11) UNSIGNED NULL,
  `city_id` int(11) UNSIGNED NULL,
  `email` varchar(100) NULL,
  `first_name` varchar(100) NULL,
  `last_name` varchar(100) NULL,
  `phone` varchar(100) NULL,
  `zip` varchar(100) NULL,
  `line1` varchar(100) NULL,
  `line2` varchar(100) NULL,
  `state` varchar(100) NULL,
  `fax` varchar(100) NULL,
  `is_deleted` int(1) NOT NULL DEFAULT 0,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `locations` (`id`, `name`, `short_name`, `type`)
VALUES
  (1,'Everywhere', NULL, 'region'),
  (2,'Europe', NULL, 'region'),
  (3,'France', 'FR', 'country'),
  (4,'Turkey', 'TR', 'country'),
  (5,'Germany', 'GR', 'country'),
  (6,'Australia', 'AU', 'country'),
  (7,'United Kingdom', 'GB', 'country'),
  (8,'Russia', 'RU', 'country');

INSERT INTO `locations_branches` (`ansestor_id`, `descendant_id`, `depth`)
VALUES
  (1,1,0),
  (2,2,0),
  (3,3,0),
  (4,4,0),
  (5,5,0),
  (6,6,0),
  (7,7,0),
  (8,8,0),
  (1,2,1),
  (1,4,1),
  (1,5,1),
  (1,6,1),
  (1,7,1),
  (1,3,2),
  (2,3,1),
  (2,5,1),
  (2,7,1);

# Dump of table payments
# ------------------------------------------------------------

INSERT INTO `payments` (`id`, `purchase_id`, `payment_id`, `model`, `status`, `raw_response`, `is_deleted`)
VALUES
  (1,1,'11111','payment_emp','paid','{"order_id":"5580812","order_total":"400.00","order_datetime":"2013-08-13 15:04:37","order_status":"Paid","cart":{"item":[{"id":"5657022","code":"1","name":"Chair","description":{},"qty":"1","digital":"0","discount":"0","predefined":"0","unit_price":"200.00"},{"id":"5657032","code":2,"name":"Rug","description":{},"qty":"1","digital":"0","discount":"0","predefined":"0","unit_price":"200.00"}]},"transaction":{"type":"sale","response":"A","response_code":"0","response_text":"approved","trans_id":"1078663342","account_id":"635172"}}',0);

# Dump of table products
# ------------------------------------------------------------

INSERT INTO `products` (`id`, `name`, `price`, `currency`, `store_id`, `shipping_id`)
VALUES
  (1,'Chair',290.40,'GBP',1, 1),
  (2,'Rug',30.00,'GBP',1, 1),
  (3,'Matrass',130.99,'EUR',1, 2),
  (4,'Bed',200.00,'EUR',1, 3);

# Dump of table purchases
# ------------------------------------------------------------

INSERT INTO `purchases` (`id`, `creator_id`, `number`, `currency`, `billing_address_id`, `shipping_same_as_billing`, `monetary`, `is_frozen`, `is_deleted`)
VALUES
  (1,1,'CNV7IC','EUR',1,1,'O:31:\"OpenBuildings\\Monetary\\Monetary\":4:{s:18:\"currency_templates\";a:5:{s:3:\"USD\";s:8:\"$:amount\";s:3:\"EUR\";s:10:\"€:amount\";s:3:\"GBP\";s:9:\"£:amount\";s:3:\"BGN\";s:12:\":amount лв\";s:3:\"JPY\";s:9:\"¥:amount\";}s:20:\"\0*\0_default_currency\";s:3:\"GBP\";s:10:\"\0*\0_source\";C:33:\"OpenBuildings\\Monetary\\Source_ECB\":775:{a:33:{s:3:\"USD\";s:6:\"1.3357\";s:3:\"JPY\";s:6:\"132.05\";s:3:\"BGN\";s:6:\"1.9558\";s:3:\"CZK\";s:6:\"25.769\";s:3:\"DKK\";s:6:\"7.4566\";s:3:\"GBP\";s:7:\"0.83850\";s:3:\"HUF\";s:6:\"298.78\";s:3:\"LTL\";s:6:\"3.4528\";s:3:\"LVL\";s:6:\"0.7025\";s:3:\"PLN\";s:6:\"4.1944\";s:3:\"RON\";s:6:\"4.4588\";s:3:\"SEK\";s:6:\"8.6943\";s:3:\"CHF\";s:6:\"1.2374\";s:3:\"NOK\";s:6:\"7.8920\";s:3:\"HRK\";s:6:\"7.5955\";s:3:\"RUB\";s:7:\"43.0625\";s:3:\"TRY\";s:6:\"2.6592\";s:3:\"AUD\";s:6:\"1.4248\";s:3:\"BRL\";s:6:\"3.0086\";s:3:\"CAD\";s:6:\"1.3759\";s:3:\"CNY\";s:6:\"8.1748\";s:3:\"HKD\";s:7:\"10.3570\";s:3:\"IDR\";s:8:\"14855.82\";s:3:\"ILS\";s:6:\"4.7205\";s:3:\"INR\";s:7:\"83.9450\";s:3:\"KRW\";s:7:\"1444.54\";s:3:\"MXN\";s:7:\"17.2205\";s:3:\"MYR\";s:6:\"4.3945\";s:3:\"NZD\";s:6:\"1.6267\";s:3:\"PHP\";s:6:\"58.090\";s:3:\"SGD\";s:6:\"1.6824\";s:3:\"THB\";s:6:\"42.342\";s:3:\"ZAR\";s:7:\"13.0230\";}}s:13:\"\0*\0_precision\";i:2;}',1,0),
  (2,1,'AAV7IC','GBP',1,1,'',0,0);

INSERT INTO `addresses` (`id`,`country_id`,`city_id`,`email`,`first_name`,`last_name`,`phone`,`zip`,`line1`,`line2`,`state`,`fax`,`is_deleted`)
VALUES
  (1,7,9,'user@example.com','name1', 'name2','phone123','ZIP','Street 1', 'House 1', '', 'faz123', 0),
  (2,7,9,'user@example.com','name1', 'name2','phone123','ZIP','Street 1', 'House 1', '', 'faz123', 0);
# Dump of table store_purchases
# ------------------------------------------------------------

INSERT INTO `store_purchases` (`id`, `number`, `store_id`, `purchase_id`, `is_deleted`)
VALUES
  (1,'3S2GJG',1,1,0),
  (2,'AA2GJG',1,2,0);

# Dump of table purchase_items
# ------------------------------------------------------------

INSERT INTO `purchase_items` (`id`, `store_purchase_id`, `reference_id`, `reference_model`, `price`, `quantity`, `model`, `is_payable`, `is_discount`, `is_deleted`)
VALUES
  (1,1,1,'product',200.00,1,'purchase_item_product',1,0,0),
  (2,1,1,'variation',200.00,1,'purchase_item_product',1,0,0),
  (3,1,2,'variation',100.00,1,'purchase_item_product',1,0,0),
  (4,1,1,'store_purchase_shipping',10,1,'purchase_item_shipping',1,0,0),
  (5,2,1,'product',NULL,1,'purchase_item_product',1,0,0);

# Dump of table stores
# ------------------------------------------------------------

INSERT INTO `stores` (`id`, `name`)
VALUES
  (1,'Example Store'),
  (2,'Empty Store');

# Dump of table users
# ------------------------------------------------------------

INSERT INTO `users` (`id`, `email`, `username`, `password`, `logins`, `last_login`, `facebook_uid`, `twitter_uid`, `last_login_ip`)
VALUES
  (1,'admin@example.com','admin','f02c9f1f724ebcf9db6784175cb6bd82663380a5f8bd78c57ad20d5dfd953f15',5,1374320224,'facebook-test','','10.20.10.1');


# Dump of table variations
# ------------------------------------------------------------
INSERT INTO `variations` (`id`, `name`, `price`, `product_id`)
VALUES
  (1,'Red',295.40,1),
  (2,'Green',298.90,1);


INSERT INTO `shipping_methods` (`id`, `name`, `store_id`)
VALUES
  (1,'Post', 0),
  (2,'Courier', 0),
  (3,'Custom', 0);


INSERT INTO `shippings` (`id`, `name`, `currency`, `processing_time`, `ships_from_id`, `store_id`)
VALUES
  (1,'Normal', 'GBP', '2|3', 3, 1),
  (2,'Custom', 'GBP', '1|5', 4, 1),
  (3,'Normal', 'GBP', '1|5', 4, 2);


INSERT INTO `shipping_groups` (`id`, `price`, `delivery_time`, `shipping_id`, `method_id`, `location_id`)
VALUES
  (1, '10.00', '2|4', 1, 1, 1),
  (2, '20.00', '1|2', 1, 2, 2),
  (3, '15.00', '2|4', 1, 3, 4),
  (4, '15.00', '2|4', 1, 2, 3),
  (5, '12.00', '2|4', 1, 1, 3),
  (6, '5.00', '2|3', 2, 1, 3),
  (7, '15.00', '2|3', 3, 1, 3);

INSERT INTO `store_purchase_shippings` (`id`, `store_purchase_id`, `location_id`)
VALUES
  (1, 1, 3);

INSERT INTO `shipping_items` (`id`, `store_purchase_shipping_id`, `purchase_item_id`, `shipping_group_id`)
VALUES
  (1, 1, 1, 1),
  (2, 1, 2, 2);



