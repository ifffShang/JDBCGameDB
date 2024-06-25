drop schema if exists CS5200Project;
create schema CS5200Project;
use CS5200Project;


create table Item (
	itemID int primary key auto_increment,
    `name` varchar(255) not null,
    maxStackSize int not null,
    price double,
    itemLevel int not null
);

create table Gear (
	itemID int primary key,
    requiredBodySlot enum('head','body','hand','legs','feet','off-hand','earring','wrist','ring'),
    defenseRating int not null,
    magicDefenseRating int not null,
	requiredLevel int not null,
    constraint fk_gear_itemID foreign key (itemID)
		references Item (itemID)
        on update cascade
        on delete cascade
);

create table Weapon (
	itemID int primary key,
    physicalDamage int not null,
    magicDamage int not null,
    autoAttack int not null,
    delay int not null,
    requiredLevel int not null,
    constraint fk_weapon_itemID foreign key (itemID)
		references Item (itemID)
        on update cascade
        on delete cascade
);

create table Consumable (
	itemID int primary key,
    `description` longtext not null,
    constraint fk_consumable_itemID foreign key (itemID)
		references Item (itemID)
        on update cascade
        on delete cascade
);

create table Player (
	playerID int primary key auto_increment,
    username varchar(255) not null unique,
    emailAddress varchar(255) not null unique
);

create table `Character`(
	characterID int primary key auto_increment,
    playerID int not null,
    firstName varchar(255) not null,
    lastName varchar(255) not null,
    mainHandWeapon int default 1,
    constraint uq_Character_firstname_lastname unique (firstName, lastName),
    constraint fk_Character_playerID foreign key (playerID)
		references Player (playerID)
        on update cascade
        on delete cascade,
	constraint fk__Character_mainHandWeapon foreign key (mainHandWeapon)
		references Weapon (itemID)
        on update cascade
        on delete set null
);

-- it will set mainHandWeapon to 1 for all characters whose mainHandWeapon is NULL 
-- after any deletion in the Weapon table.
-- weapon iwth itemID = 1 cannot be deleted
DELIMITER $$

CREATE TRIGGER after_weapon_delete
AFTER DELETE ON Weapon
FOR EACH ROW
BEGIN
    UPDATE `Character`
    SET mainHandWeapon = 1
    WHERE mainHandWeapon IS NULL;
END$$

DELIMITER ;


create table Currency(
	currencyID int auto_increment primary key,
    `name` varchar(255) not null,
    `description` longtext not null,
    cap int not null,
    weeklyCap int
);

create table CharacterCurrency(
    characterID int,
    currencyID int,
    ownedAmount int not null,
    weeklyOwnedAmount int,
    constraint pk_charactercurrency_characterid_currencyid primary key (characterID, currencyID),
    constraint fk_charactercurrency_characterid foreign key (characterID)
        references `Character` (characterID)
        on update cascade
        on delete cascade,
    constraint fk_charactercurrency_currencyid foreign key (currencyID)
        references Currency (currencyID)
        on update cascade
        on delete cascade
);


create table EquipedGear (
	characterID int,
    bodySlot enum( 'head', 'body', 'hand','legs','feet','off-hand','earring','wrist','ring'),
    itemID int,
    constraint pk_equipedEquipment_characterID_bodySlot primary key (characterID, bodySlot),
    constraint fk_equipedEquipment_characterID foreign key (characterID)
		references `Character` (characterID)
        on update cascade
        on delete cascade,
    constraint fk_equipedEquipment_itemID foreign key (itemID)
		references gear (itemID)
        on update cascade
        on delete set null
);

create table CharacterItem (
	characterID int,
    slotID int, 
    itemID int not null,
    quantity int not null,
    constraint pk_characteritem_characterid_slotid primary key (characterID, slotID),
    constraint fk_characteritem_characterid foreign key (characterID)
		references `Character` (characterID)
        on update cascade
        on delete cascade,
    constraint fk_characteritem_itemid foreign key (itemID)
		references Item (itemID)
        on update cascade
        on delete cascade
);

create table Job (
	jobID int auto_increment primary key,
    `name` varchar(255) not null,
    `description` longtext not null
);

create table CharacterJob (
    characterID int,
    jobID int,
    `level` int not null default 1,
    constraint pk_characterjob_characterid_jobid primary key (characterID, jobID),
    constraint fk_characterjob_characterid foreign key (characterID)
        references `Character` (characterID)
        on update cascade
        on delete cascade,
    constraint fk_characterjob_jobid foreign key (jobID)
        references Job (jobID)
        on update cascade
        on delete cascade
);
-- do not store unplayed jobs in the CharacterJob table. The absence of a jobID for a characterID 
-- implies the character has not played that job, effectively treating it as level 0. 
-- When you need to display the information, you'll calculate unplayed jobs by finding 
-- which jobs are missing for a character and displaying them as level 0.

create table GearAllowedJob(
    jobID int,
    gearID int,
    constraint pk_gearAllowedJob_geard_jobid primary key (gearID, jobID),
    constraint fk_gearAllowedJob_gearid foreign key (gearID)
        references Gear (itemID)
        on update cascade
        on delete cascade,
    constraint fk_gearAllowedJob_jobid foreign key (jobID)
        references Job (jobID)
        on update cascade
        on delete cascade
);

create table WeaponAllowedJob(
    jobID int,
    weaponID int,
    constraint pk_weaponAllowedJob_weaponid_jobid primary key (weaponID, jobID),
    constraint fk_weaponAllowedJob_weaponid foreign key (weaponID)
        references Weapon (itemID)
        on update cascade
        on delete cascade,
    constraint fk_weaponAllowedJob_jobid foreign key (jobID)
        references Job (jobID)
        on update cascade
        on delete cascade
);

create table CharacterAttribute (
	characterID int,
    attribute enum ('strength','dexterity','vitality','intelligence','mind','criticalHit','determination','directHitRate','defense','magicDefense','attackPower','skillSpeed','attackMagicPotency','healingMagicPotency','spellSpeed','averageItemLevel','tenacity','piety'),
    `value` int not null,
    constraint pk_characterattribtue_characterid_attribute primary key (characterID, attribute),
	constraint fk_characterattribute_characterid foreign key (characterID)
		references `Character` (characterID)
		on update cascade
		on delete cascade
);

create table GearBonus (
	gearID int,
    attribute enum ('strength','dexterity','vitality','intelligence','mind','criticalHit','determination','directHitRate','defense','magicDefense','attackPower','skillSpeed','attackMagicPotency','healingMagicPotency','spellSpeed','averageItemLevel','tenacity','piety'),
    bonus int not null,
    constraint pk_gearbouns_gearid primary key (gearID, attribute),
    constraint fk_gearbonus_attribute foreign key (gearID)
		references Gear (itemID)
        on update cascade
        on delete cascade
);

create table WeaponBonus (
	weaponID int,
    attribute enum ('strength','dexterity','vitality','intelligence','mind','criticalHit','determination','directHitRate','defense','magicDefense','attackPower','skillSpeed','attackMagicPotency','healingMagicPotency','spellSpeed','averageItemLevel','tenacity','piety'),
    bonus int not null,
    constraint pk_weaponbouns_gearid primary key (weaponID, attribute),
    constraint fk_weaponbonus_attribute foreign key (weaponID)
		references Weapon (itemID)
        on update cascade
        on delete cascade
);

create table ConsumableBonus(
	consumableID int, 
    attribute enum ('strength','dexterity','vitality','intelligence','mind','criticalHit','determination','directHitRate','defense','magicDefense','attackPower','skillSpeed','attackMagicPotency','healingMagicPotency','spellSpeed','averageItemLevel','tenacity','piety'),
    bonus int not null,
    cap int not null,
    constraint pk_conbouns_itemid_attribute primary key (consumableID, attribute),
    constraint fk_conbonus_itemid foreign key (consumableID)
		references Consumable (itemID)
        on update cascade
        on delete cascade
);

-- Weapon
INSERT INTO Item (`name`, maxStackSize, price, itemLevel) VALUES ('Weapon1', 1, 100.0, 1);
INSERT INTO Item (`name`, maxStackSize, price, itemLevel) VALUES ('Weapon2', 1, 200.0, 22);
INSERT INTO Item (`name`, maxStackSize, price, itemLevel) VALUES ('Weapon3', 1, 300.0, 13);
INSERT INTO Item (`name`, maxStackSize, price, itemLevel) VALUES ('Weapon4', 1, 400.0, 41);
INSERT INTO Item (`name`, maxStackSize, price, itemLevel) VALUES ('Weapon5', 1, 500.0, 75);
INSERT INTO Item (`name`, maxStackSize, price, itemLevel) VALUES ('Weapon6', 1, 600.0, 106);
INSERT INTO Item (`name`, maxStackSize, price, itemLevel) VALUES ('Weapon7', 1, 700.0, 27);
INSERT INTO Item (`name`, maxStackSize, price, itemLevel) VALUES ('Weapon8', 1, 800.0, 18);
INSERT INTO Item (`name`, maxStackSize, price, itemLevel) VALUES ('Weapon9', 1, 900.0, 9);
INSERT INTO Item (`name`, maxStackSize, price, itemLevel) VALUES ('Weapon10', 1, 1000.0, 102);
INSERT INTO Weapon (itemID, physicalDamage, magicDamage, autoAttack, delay, requiredLevel) VALUES (1, 10, 557, 1, 1000, 1);
INSERT INTO Weapon (itemID, physicalDamage, magicDamage, autoAttack, delay, requiredLevel) VALUES (2, 243, 17250, 2, 1500, 2);
INSERT INTO Weapon (itemID, physicalDamage, magicDamage, autoAttack, delay, requiredLevel) VALUES (3, 30, 1535, 3, 2000, 3);
INSERT INTO Weapon (itemID, physicalDamage, magicDamage, autoAttack, delay, requiredLevel) VALUES (4, 40, 2570, 4, 2500, 4);
INSERT INTO Weapon (itemID, physicalDamage, magicDamage, autoAttack, delay, requiredLevel) VALUES (5, 5320, 2573, 5, 3000, 5);
INSERT INTO Weapon (itemID, physicalDamage, magicDamage, autoAttack, delay, requiredLevel) VALUES (6, 66320, 3550, 6, 3500, 6);
INSERT INTO Weapon (itemID, physicalDamage, magicDamage, autoAttack, delay, requiredLevel) VALUES (7, 740, 35, 75777, 4000, 7);
INSERT INTO Weapon (itemID, physicalDamage, magicDamage, autoAttack, delay, requiredLevel) VALUES (8, 860, 40, 83573, 4500, 8);
INSERT INTO Weapon (itemID, physicalDamage, magicDamage, autoAttack, delay, requiredLevel) VALUES (9, 930, 45, 95, 5000, 9);
INSERT INTO Weapon (itemID, physicalDamage, magicDamage, autoAttack, delay, requiredLevel) VALUES (10, 1300, 50, 17370, 5500, 10);

-- Item
INSERT INTO Item (`name`, maxStackSize, price, itemLevel) VALUES ('Item1', 10, 100.0, 1);
INSERT INTO Item (`name`, maxStackSize, price, itemLevel) VALUES ('Item2', 20, 200.0, 2);
INSERT INTO Item (`name`, maxStackSize, price, itemLevel) VALUES ('Item3', 30, 300.0, 3);
INSERT INTO Item (`name`, maxStackSize, price, itemLevel) VALUES ('Item4', 40, 400.0, 4);
INSERT INTO Item (`name`, maxStackSize, price, itemLevel) VALUES ('Item5', 50, 500.0, 5);
INSERT INTO Item (`name`, maxStackSize, price, itemLevel) VALUES ('Item6', 60, 600.0, 6);
INSERT INTO Item (`name`, maxStackSize, price, itemLevel) VALUES ('Item7', 70, 700.0, 7);
INSERT INTO Item (`name`, maxStackSize, price, itemLevel) VALUES ('Item8', 80, 800.0, 8);
INSERT INTO Item (`name`, maxStackSize, price, itemLevel) VALUES ('Item9', 90, 900.0, 9);
INSERT INTO Item (`name`, maxStackSize, price, itemLevel) VALUES ('Item10', 100, 1000.0, 10);

-- Gear
INSERT INTO Item (`name`, maxStackSize, price, itemLevel) VALUES ('GearItem1', 1, 100.0, 1);
INSERT INTO Item (`name`, maxStackSize, price, itemLevel) VALUES ('GearItem2', 1, 200.0, 2);
INSERT INTO Item (`name`, maxStackSize, price, itemLevel) VALUES ('GearItem3', 1, 300.0, 3);
INSERT INTO Item (`name`, maxStackSize, price, itemLevel) VALUES ('GearItem4', 1, 400.0, 4);
INSERT INTO Item (`name`, maxStackSize, price, itemLevel) VALUES ('GearItem5', 1, 500.0, 5);
INSERT INTO Item (`name`, maxStackSize, price, itemLevel) VALUES ('GearItem6', 1, 600.0, 6);
INSERT INTO Item (`name`, maxStackSize, price, itemLevel) VALUES ('GearItem7', 1, 700.0, 7);
INSERT INTO Item (`name`, maxStackSize, price, itemLevel) VALUES ('GearItem8', 1, 800.0, 8);
INSERT INTO Item (`name`, maxStackSize, price, itemLevel) VALUES ('GearItem9', 1, 900.0, 9);
INSERT INTO Item (`name`, maxStackSize, price, itemLevel) VALUES ('GearItem10', 1, 1000.0, 10);
INSERT INTO Gear (itemID, requiredBodySlot, defenseRating, magicDefenseRating, requiredLevel) VALUES (11, 'head', 10, 5, 1);
INSERT INTO Gear (itemID, requiredBodySlot, defenseRating, magicDefenseRating, requiredLevel) VALUES (12, 'body', 20, 10, 2);
INSERT INTO Gear (itemID, requiredBodySlot, defenseRating, magicDefenseRating, requiredLevel) VALUES (13, 'legs', 30, 15, 3);
INSERT INTO Gear (itemID, requiredBodySlot, defenseRating, magicDefenseRating, requiredLevel) VALUES (14, 'head', 40, 20, 4);
INSERT INTO Gear (itemID, requiredBodySlot, defenseRating, magicDefenseRating, requiredLevel) VALUES (15, 'body', 50, 25, 5);
INSERT INTO Gear (itemID, requiredBodySlot, defenseRating, magicDefenseRating, requiredLevel) VALUES (16, 'legs', 60, 30, 6);
INSERT INTO Gear (itemID, requiredBodySlot, defenseRating, magicDefenseRating, requiredLevel) VALUES (17, 'feet', 70, 35, 7);
INSERT INTO Gear (itemID, requiredBodySlot, defenseRating, magicDefenseRating, requiredLevel) VALUES (18, 'hand', 80, 40, 8);
INSERT INTO Gear (itemID, requiredBodySlot, defenseRating, magicDefenseRating, requiredLevel) VALUES (19, 'head', 90, 45, 9);
INSERT INTO Gear (itemID, requiredBodySlot, defenseRating, magicDefenseRating, requiredLevel) VALUES (20, 'body', 100, 50, 10);

-- Consumable
INSERT INTO Item (`name`, maxStackSize, price, itemLevel) VALUES ('ConsumableItem1', 1, 10.0, 1);
INSERT INTO Item (`name`, maxStackSize, price, itemLevel) VALUES ('ConsumableItem2', 1, 20.0, 2);
INSERT INTO Item (`name`, maxStackSize, price, itemLevel) VALUES ('ConsumableItem3', 1, 30.0, 3);
INSERT INTO Item (`name`, maxStackSize, price, itemLevel) VALUES ('ConsumableItem4', 1, 40.0, 4);
INSERT INTO Item (`name`, maxStackSize, price, itemLevel) VALUES ('ConsumableItem5', 1, 50.0, 5);
INSERT INTO Item (`name`, maxStackSize, price, itemLevel) VALUES ('ConsumableItem6', 1, 60.0, 6);
INSERT INTO Item (`name`, maxStackSize, price, itemLevel) VALUES ('ConsumableItem7', 1, 70.0, 7);
INSERT INTO Item (`name`, maxStackSize, price, itemLevel) VALUES ('ConsumableItem8', 1, 80.0, 8);
INSERT INTO Item (`name`, maxStackSize, price, itemLevel) VALUES ('ConsumableItem9', 1, 90.0, 9);
INSERT INTO Item (`name`, maxStackSize, price, itemLevel) VALUES ('ConsumableItem10', 1, 100.0, 10);
INSERT INTO Consumable (itemID, `description`) VALUES (21, 'Description for Consumable1');
INSERT INTO Consumable (itemID, `description`) VALUES (22, 'Description for Consumable2');
INSERT INTO Consumable (itemID, `description`) VALUES (23, 'Description for Consumable3');
INSERT INTO Consumable (itemID, `description`) VALUES (24, 'Description for Consumable4');
INSERT INTO Consumable (itemID, `description`) VALUES (25, 'Description for Consumable5');
INSERT INTO Consumable (itemID, `description`) VALUES (26, 'Description for Consumable6');
INSERT INTO Consumable (itemID, `description`) VALUES (27, 'Description for Consumable7');
INSERT INTO Consumable (itemID, `description`) VALUES (28, 'Description for Consumable8');
INSERT INTO Consumable (itemID, `description`) VALUES (29, 'Description for Consumable9');
INSERT INTO Consumable (itemID, `description`) VALUES (30, 'Description for Consumable10');

-- Player
INSERT INTO Player (username, emailAddress) VALUES ('player1', 'player1@example.com');
INSERT INTO Player (username, emailAddress) VALUES ('player2', 'player2@example.com');
INSERT INTO Player (username, emailAddress) VALUES ('player3', 'player3@example.com');
INSERT INTO Player (username, emailAddress) VALUES ('player4', 'player4@example.com');
INSERT INTO Player (username, emailAddress) VALUES ('player5', 'player5@example.com');
INSERT INTO Player (username, emailAddress) VALUES ('player6', 'player6@example.com');
INSERT INTO Player (username, emailAddress) VALUES ('player7', 'player7@example.com');
INSERT INTO Player (username, emailAddress) VALUES ('player8', 'player8@example.com');
INSERT INTO Player (username, emailAddress) VALUES ('player9', 'player9@example.com');
INSERT INTO Player (username, emailAddress) VALUES ('player10', 'player10@example.com');

-- Character
INSERT INTO `Character` (playerID, firstName, lastName, mainHandWeapon) VALUES (1, 'firstName1', 'lastName1', 1);
INSERT INTO `Character` (playerID, firstName, lastName, mainHandWeapon) VALUES (2, 'firstName2', 'lastName2', 2);
INSERT INTO `Character` (playerID, firstName, lastName, mainHandWeapon) VALUES (3, 'firstName3', 'lastName3', 3);
INSERT INTO `Character` (playerID, firstName, lastName, mainHandWeapon) VALUES (4, 'firstName4', 'lastName4', 4);
INSERT INTO `Character` (playerID, firstName, lastName, mainHandWeapon) VALUES (5, 'firstName5', 'lastName5', 5);
INSERT INTO `Character` (playerID, firstName, lastName, mainHandWeapon) VALUES (6, 'firstName6', 'lastName6', 6);
INSERT INTO `Character` (playerID, firstName, lastName, mainHandWeapon) VALUES (7, 'firstName7', 'lastName7', 7);
INSERT INTO `Character` (playerID, firstName, lastName, mainHandWeapon) VALUES (8, 'firstName8', 'lastName8', 8);
INSERT INTO `Character` (playerID, firstName, lastName, mainHandWeapon) VALUES (9, 'firstName9', 'lastName9', 9);
INSERT INTO `Character` (playerID, firstName, lastName, mainHandWeapon) VALUES (10, 'firstName10', 'lastName10', 10);

-- Currency
INSERT INTO Currency (`name`, `description`, cap, weeklyCap) VALUES ('Currency1', 'Description1', 1000, 500);
INSERT INTO Currency (`name`, `description`, cap, weeklyCap) VALUES ('Currency2', 'Description2', 2000, 1000);
INSERT INTO Currency (`name`, `description`, cap, weeklyCap) VALUES ('Currency3', 'Description3', 99999, 99999);
INSERT INTO Currency (`name`, `description`, cap, weeklyCap) VALUES ('Currency4', 'Description4', 3000, 1500);
INSERT INTO Currency (`name`, `description`, cap, weeklyCap) VALUES ('Currency5', 'Description5', 4000, 2000);
INSERT INTO Currency (`name`, `description`, cap, weeklyCap) VALUES ('Currency6', 'Description6', 5000, 2500);
INSERT INTO Currency (`name`, `description`, cap, weeklyCap) VALUES ('Currency7', 'Description7', 6000, 3000);
INSERT INTO Currency (`name`, `description`, cap, weeklyCap) VALUES ('Currency8', 'Description8', 7000, 3500);
INSERT INTO Currency (`name`, `description`, cap, weeklyCap) VALUES ('Currency9', 'Description9', 8000, 4000);
INSERT INTO Currency (`name`, `description`, cap, weeklyCap) VALUES ('Currency10', 'Description10', 9000, 4500);

-- CharacterCurrency
INSERT INTO CharacterCurrency (characterID, currencyID, ownedAmount, weeklyOwnedAmount) VALUES (1, 1, 100, 50);
INSERT INTO CharacterCurrency (characterID, currencyID, ownedAmount, weeklyOwnedAmount) VALUES (2, 2, 200, 100);
INSERT INTO CharacterCurrency (characterID, currencyID, ownedAmount, weeklyOwnedAmount) VALUES (3, 3, 9999, 999);
INSERT INTO CharacterCurrency (characterID, currencyID, ownedAmount, weeklyOwnedAmount) VALUES (4, 4, 300, 150);
INSERT INTO CharacterCurrency (characterID, currencyID, ownedAmount, weeklyOwnedAmount) VALUES (5, 5, 400, 200);
INSERT INTO CharacterCurrency (characterID, currencyID, ownedAmount, weeklyOwnedAmount) VALUES (6, 6, 500, 250);
INSERT INTO CharacterCurrency (characterID, currencyID, ownedAmount, weeklyOwnedAmount) VALUES (7, 7, 600, 300);
INSERT INTO CharacterCurrency (characterID, currencyID, ownedAmount, weeklyOwnedAmount) VALUES (8, 8, 700, 350);
INSERT INTO CharacterCurrency (characterID, currencyID, ownedAmount, weeklyOwnedAmount) VALUES (9, 9, 800, 400);
INSERT INTO CharacterCurrency (characterID, currencyID, ownedAmount, weeklyOwnedAmount) VALUES (10, 10, 900, 450);

-- EquipedGear
INSERT INTO EquipedGear (characterID, bodySlot, itemID) VALUES (1, 'head', 11);
INSERT INTO EquipedGear (characterID, bodySlot, itemID) VALUES (2, 'body', 12);
INSERT INTO EquipedGear (characterID, bodySlot, itemID) VALUES (3, 'hand', 13);
INSERT INTO EquipedGear (characterID, bodySlot, itemID) VALUES (4, 'legs', 14);
INSERT INTO EquipedGear (characterID, bodySlot, itemID) VALUES (5, 'feet', 15);
INSERT INTO EquipedGear (characterID, bodySlot, itemID) VALUES (6, 'hand', 16);
INSERT INTO EquipedGear (characterID, bodySlot, itemID) VALUES (7, 'body', 17);
INSERT INTO EquipedGear (characterID, bodySlot, itemID) VALUES (8, 'head', 18);
INSERT INTO EquipedGear (characterID, bodySlot, itemID) VALUES (9, 'head', 19);
INSERT INTO EquipedGear (characterID, bodySlot, itemID) VALUES (10, 'body', 20);

-- CharacterItem
INSERT INTO CharacterItem (characterID, slotID, itemID, quantity) VALUES (1, 1, 1, 10);
INSERT INTO CharacterItem (characterID, slotID, itemID, quantity) VALUES (2, 2, 2, 5);
INSERT INTO CharacterItem (characterID, slotID, itemID, quantity) VALUES (3, 3, 3, 20);
INSERT INTO CharacterItem (characterID, slotID, itemID, quantity) VALUES (4, 4, 4, 8);
INSERT INTO CharacterItem (characterID, slotID, itemID, quantity) VALUES (5, 5, 5, 15);
INSERT INTO CharacterItem (characterID, slotID, itemID, quantity) VALUES (6, 6, 6, 12);
INSERT INTO CharacterItem (characterID, slotID, itemID, quantity) VALUES (7, 7, 7, 14);
INSERT INTO CharacterItem (characterID, slotID, itemID, quantity) VALUES (8, 8, 8, 16);
INSERT INTO CharacterItem (characterID, slotID, itemID, quantity) VALUES (9, 9, 9, 18);
INSERT INTO CharacterItem (characterID, slotID, itemID, quantity) VALUES (10, 10, 10, 20);

-- Job
INSERT INTO Job (`name`, `description`) VALUES ('name1', 'description1');
INSERT INTO Job (`name`, `description`) VALUES ('name2', 'description2');
INSERT INTO Job (`name`, `description`) VALUES ('name3', 'description3');
INSERT INTO Job (`name`, `description`) VALUES ('name4', 'description4');
INSERT INTO Job (`name`, `description`) VALUES ('name5', 'description5');
INSERT INTO Job (`name`, `description`) VALUES ('name6', 'description6');
INSERT INTO Job (`name`, `description`) VALUES ('name7', 'description7');
INSERT INTO Job (`name`, `description`) VALUES ('name8', 'description8');
INSERT INTO Job (`name`, `description`) VALUES ('name9', 'description9');
INSERT INTO Job (`name`, `description`) VALUES ('name10', 'description10');

-- CharacterJob
INSERT INTO CharacterJob (characterID, jobID, `level`) VALUES (1, 1, 10);
INSERT INTO CharacterJob (characterID, jobID, `level`) VALUES (2, 2, 5);
INSERT INTO CharacterJob (characterID, jobID, `level`) VALUES (3, 3, 8);
INSERT INTO CharacterJob (characterID, jobID, `level`) VALUES (4, 4, 12);
INSERT INTO CharacterJob (characterID, jobID, `level`) VALUES (5, 5, 14);
INSERT INTO CharacterJob (characterID, jobID, `level`) VALUES (6, 6, 16);
INSERT INTO CharacterJob (characterID, jobID, `level`) VALUES (7, 7, 18);
INSERT INTO CharacterJob (characterID, jobID, `level`) VALUES (8, 8, 20);
INSERT INTO CharacterJob (characterID, jobID, `level`) VALUES (9, 9, 22);
INSERT INTO CharacterJob (characterID, jobID, `level`) VALUES (10, 10, 24);

-- GearAllowedJob
INSERT INTO GearAllowedJob (jobID, gearID) VALUES (1, 11);
INSERT INTO GearAllowedJob (jobID, gearID) VALUES (2, 12);
INSERT INTO GearAllowedJob (jobID, gearID) VALUES (3, 13);
INSERT INTO GearAllowedJob (jobID, gearID) VALUES (4, 14);
INSERT INTO GearAllowedJob (jobID, gearID) VALUES (5, 15);
INSERT INTO GearAllowedJob (jobID, gearID) VALUES (6, 16);
INSERT INTO GearAllowedJob (jobID, gearID) VALUES (7, 17);
INSERT INTO GearAllowedJob (jobID, gearID) VALUES (8, 18);
INSERT INTO GearAllowedJob (jobID, gearID) VALUES (9, 19);
INSERT INTO GearAllowedJob (jobID, gearID) VALUES (10, 20);

-- WeaponAllowedJob
INSERT INTO WeaponAllowedJob (jobID, weaponID) VALUES (1, 1);
INSERT INTO WeaponAllowedJob (jobID, weaponID) VALUES (2, 2);
INSERT INTO WeaponAllowedJob (jobID, weaponID) VALUES (3, 3);
INSERT INTO WeaponAllowedJob (jobID, weaponID) VALUES (4, 4);
INSERT INTO WeaponAllowedJob (jobID, weaponID) VALUES (5, 5);
INSERT INTO WeaponAllowedJob (jobID, weaponID) VALUES (6, 6);
INSERT INTO WeaponAllowedJob (jobID, weaponID) VALUES (7, 7);
INSERT INTO WeaponAllowedJob (jobID, weaponID) VALUES (8, 8);
INSERT INTO WeaponAllowedJob (jobID, weaponID) VALUES (9, 9);
INSERT INTO WeaponAllowedJob (jobID, weaponID) VALUES (10, 10);

-- CharacterAttribute
INSERT INTO CharacterAttribute (characterID, attribute, `value`) VALUES (1, 'strength', 10);
INSERT INTO CharacterAttribute (characterID, attribute, `value`) VALUES (2, 'dexterity', 8);
INSERT INTO CharacterAttribute (characterID, attribute, `value`) VALUES (3, 'intelligence', 12);
INSERT INTO CharacterAttribute (characterID, attribute, `value`) VALUES (4, 'mind', 11);
INSERT INTO CharacterAttribute (characterID, attribute, `value`) VALUES (5, 'criticalHit', 13);
INSERT INTO CharacterAttribute (characterID, attribute, `value`) VALUES (6, 'determination', 15);
INSERT INTO CharacterAttribute (characterID, attribute, `value`) VALUES (7, 'directHitRate', 17);
INSERT INTO CharacterAttribute (characterID, attribute, `value`) VALUES (8, 'defense', 19);
INSERT INTO CharacterAttribute (characterID, attribute, `value`) VALUES (9, 'magicDefense', 21);
INSERT INTO CharacterAttribute (characterID, attribute, `value`) VALUES (10, 'attackPower', 23);

-- GearBonus
INSERT INTO GearBonus (gearID, attribute, bonus) VALUES (11, 'strength', 5);
INSERT INTO GearBonus (gearID, attribute, bonus) VALUES (12, 'dexterity', 3);
INSERT INTO GearBonus (gearID, attribute, bonus) VALUES (13, 'intelligence', 6);
INSERT INTO GearBonus (gearID, attribute, bonus) VALUES (14, 'strength', 7);
INSERT INTO GearBonus (gearID, attribute, bonus) VALUES (15, 'dexterity', 9);
INSERT INTO GearBonus (gearID, attribute, bonus) VALUES (16, 'intelligence', 11);
INSERT INTO GearBonus (gearID, attribute, bonus) VALUES (17, 'vitality', 13);
INSERT INTO GearBonus (gearID, attribute, bonus) VALUES (18, 'mind', 15);
INSERT INTO GearBonus (gearID, attribute, bonus) VALUES (19, 'criticalHit', 17);
INSERT INTO GearBonus (gearID, attribute, bonus) VALUES (20, 'determination', 19);

-- WeaponBonus
INSERT INTO WeaponBonus (weaponID, attribute, bonus) VALUES (1, 'attackPower', 10);
INSERT INTO WeaponBonus (weaponID, attribute, bonus) VALUES (2, 'spellSpeed', 5);
INSERT INTO WeaponBonus (weaponID, attribute, bonus) VALUES (3, 'criticalHit', 8);
INSERT INTO WeaponBonus (weaponID, attribute, bonus) VALUES (4, 'attackPower', 12);
INSERT INTO WeaponBonus (weaponID, attribute, bonus) VALUES (5, 'skillSpeed', 14);
INSERT INTO WeaponBonus (weaponID, attribute, bonus) VALUES (6, 'spellSpeed', 16);
INSERT INTO WeaponBonus (weaponID, attribute, bonus) VALUES (7, 'criticalHit', 18);
INSERT INTO WeaponBonus (weaponID, attribute, bonus) VALUES (8, 'healingMagicPotency', 20);
INSERT INTO WeaponBonus (weaponID, attribute, bonus) VALUES (9, 'attackMagicPotency', 22);
INSERT INTO WeaponBonus (weaponID, attribute, bonus) VALUES (10, 'directHitRate', 24);

-- ConsumableBonus
INSERT INTO ConsumableBonus (consumableID, attribute, bonus, cap) VALUES (21, 'vitality', 50, 100);
INSERT INTO ConsumableBonus (consumableID, attribute, bonus, cap) VALUES (22, 'mind', 30, 80);
INSERT INTO ConsumableBonus (consumableID, attribute, bonus, cap) VALUES (23, 'determination', 20, 60);
INSERT INTO ConsumableBonus (consumableID, attribute, bonus, cap) VALUES (24, 'vitality', 60, 120);
INSERT INTO ConsumableBonus (consumableID, attribute, bonus, cap) VALUES (25, 'intelligence', 70, 140);
INSERT INTO ConsumableBonus (consumableID, attribute, bonus, cap) VALUES (26, 'mind', 80, 160);
INSERT INTO ConsumableBonus (consumableID, attribute, bonus, cap) VALUES (27, 'determination', 90, 180);
INSERT INTO ConsumableBonus (consumableID, attribute, bonus, cap) VALUES (28, 'defense', 100, 200);
INSERT INTO ConsumableBonus (consumableID, attribute, bonus, cap) VALUES (29, 'magicDefense', 110, 220);
INSERT INTO ConsumableBonus (consumableID, attribute, bonus, cap) VALUES (30, 'tenacity', 120, 240);

