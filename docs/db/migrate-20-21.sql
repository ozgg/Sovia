-- Новый тип ключа пользователя
ALTER TABLE `user_key` DROP FOREIGN KEY `fk_user_key_owner`;

alter table `user_key` drop column `event_key`,
   add column `created_at` timestamp DEFAULT current_timestamp NOT NULL COMMENT 'Creation time' after `user_id`,
   add column `body` varchar(32) NOT NULL COMMENT 'Body' after `updated_at`,
   change `id` `id` mediumint(10) UNSIGNED NOT NULL AUTO_INCREMENT comment 'PK',
   change `type` `type_id` tinyint(3) UNSIGNED default '1' NOT NULL comment 'Key type',
   change `owner_id` `user_id` mediumint(8) UNSIGNED NULL  comment 'Owner',
   change `expires_at` `updated_at` datetime NULL  comment 'Update time';

ALTER TABLE `user_key`
    ADD CONSTRAINT `FK_user_key_owner` FOREIGN KEY (`user_id`) REFERENCES `user_item` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

