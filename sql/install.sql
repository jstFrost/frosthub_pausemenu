-- Frost Hub - Pause Menu
-- Run once. Independent from every framework's own tables on purpose, so the
-- resource works the same way whether you're on ESX, QBCore or QBox.

CREATE TABLE IF NOT EXISTS `frosthub_playtime` (
    `identifier` VARCHAR(64) NOT NULL,
    `seconds` INT UNSIGNED NOT NULL DEFAULT 0,
    PRIMARY KEY (`identifier`)
);
