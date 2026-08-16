-- Item priorities for GearSwap. Each entry pairs one item with the number
-- GearSwap sorts swaps by: the highest priority in a set is equipped first, so
-- max HP rises before it falls and no current HP is clamped away mid-swap.
--
-- Which builder an entry uses is its documentation, and decides what is checked:
--
--   hp_gear(name, hp, extra)    The number is the item's total HP -- base HP plus
--                               any HP its augments add. tools/gearsets_check.lua
--                               reconciles every one of these against Windower's
--                               own item data, so a wrong number fails offline.
--
--   mp_gear(name, mp, extra)    The item carries MP but no HP. Pass the raw MP;
--                               priority becomes ceil(mp/10) capped at 10, which
--                               ranks it below every piece carrying real HP.
--
--   rank_gear(name, rank, extra)  The number is a deliberate ordering token, not
--                               HP. Weapons mostly: a two-handed main has to equip
--                               ahead of the offhand so the game clears the sub
--                               slot for it. Never checked against HP.
--
-- Items whose augments are the user's choice -- JSE capes, Divainy-Gimainy, dark
-- matter -- are written out by hand with their augment list. Items with fixed
-- augment paths, such as Souveran, get one entry per path at that path's maximum.
--
-- Item names must match the game exactly. GearSwap compares against the item's
-- name and its log name, case-insensitively; a name matching neither equips
-- nothing and reports nothing.
--
-- Duplicates of one item are separate entries distinguished by bag, so a set can
-- ask for a specific copy.
--
-- Naming: keys are the item name in camelCase (moonlightRing, warderCharm),
-- quality tiers spelled out as PlusOne/PlusTwo/PlusThree/PlusFour, wardrobe
-- copies numbered by bag (rostam2 = wardrobe2). AF/Relic/Empyrean pieces are
-- family + slot + tier (reverenceBodyPlusFour). JSE back capes are job +
-- purpose (rngSnapshot, drkFC), split further by their defensive augment or
-- leading stat when one job builds several of a kind (corDAPdt, brdWSDChr).

gear = {}

local function build(item_name, priority, extra_attributes)
    local gear_table = { name = item_name, priority = priority }
    if extra_attributes then
        for k, v in pairs(extra_attributes) do
            gear_table[k] = v
        end
    end
    return gear_table
end

-- Priority is the item's total HP.
function hp_gear(item_name, hp_val, extra_attributes)
    return build(item_name, hp_val, extra_attributes)
end

-- No HP, but MP. Scaled to 1-10 so these sit below anything carrying real HP.
function mp_gear(item_name, mp_val, extra_attributes)
    local scaled = 0
    if mp_val and mp_val > 0 then
        scaled = math.min(10, math.ceil(mp_val / 10))
    end
    return build(item_name, scaled, extra_attributes)
end

-- Priority is an ordering token rather than HP; keeps a main hand ahead of its offhand.
function rank_gear(item_name, rank_val, extra_attributes)
    return build(item_name, rank_val, extra_attributes)
end

-- [[Begin Gear Definitions]] --
-- [[ JSE Capes ]]            --
--BLU Capes
gear.bluFC = hp_gear("Rosmerta's Cape", 80, {
    augments = { 'HP+60', 'Eva.+20 /Mag. Eva.+20', 'HP+20', '"Fast Cast"+10', 'Damage taken-5%' }, })                  --FC 10, DT 5
gear.bluDW = hp_gear("Rosmerta's Cape", 0, {
    augments = { 'DEX+20', 'Accuracy+20 Attack+20', 'DEX+10', '"Dual Wield"+10', 'Damage taken-5%' }, })               --DW 10
gear.bluWSD = hp_gear("Rosmerta's Cape", 0, {
    augments = { 'STR+20', 'Accuracy+20 Attack+20', 'STR+10', 'Weapon skill damage +10%', 'Phys. dmg. taken-10%' }, }) --WSD 10
gear.bluCast = hp_gear("Rosmerta's Cape", 0, {
    augments = { 'INT+20', 'Mag. Acc+20 /Mag. Dmg.+20', 'Mag. Acc.+10', 'Enmity+10', 'Spell interruption rate down-10%', }, })  --SIRD 10, Enmity 10, Macc 10
gear.bluDA = hp_gear("Rosmerta's Cape", 0, {
    augments = { 'DEX+20', 'Accuracy+20 Attack+20', 'DEX+10', '"Dbl.Atk."+10', 'Damage taken-5%' }, })  --DA 10, DT 5, Acc 20
gear.bluNuke = hp_gear("Rosmerta's Cape", 0, {
    augments = { 'INT+20', 'Mag. Acc+20 /Mag. Dmg.+20', 'INT+10', '"Mag.Atk.Bns."+10', 'Phys. dmg. taken-10%', }, })  --MAB 10, PDT 10

--BRD Capes
gear.brdDW = hp_gear("Intarabus's Cape", 0, {
    augments = { 'DEX+20', 'Accuracy+20 Attack+20', 'Accuracy+10', '"Dual Wield"+10', 'Damage taken-5%', }, })  --DW 10, DT 5, Acc 20, Acc 10
gear.brdFC = hp_gear("Intarabus's Cape", 0, {
    augments = { 'CHR+20', 'Mag. Acc+20 /Mag. Dmg.+20', 'CHR+10', '"Fast Cast"+10', 'Damage taken-5%', }, })  --FC 10, DT 5
gear.brdWSD = hp_gear("Intarabus's Cape", 0, {
    augments = { 'STR+20', 'Accuracy+20 Attack+20', 'STR+10', 'Weapon skill damage +10%', } })                 --Prelude +1, Madrigal +1
gear.brdIdle = hp_gear("Intarabus's Cape", 60,
    { augments = { 'HP+60', 'Eva.+20 /Mag. Eva.+20', 'Enmity-10', 'Damage taken-5%', }, })                     --Prelude +1, Madrigal +1
gear.brdSTP = hp_gear("Intarabus's Cape", 0,
    { augments = { 'DEX+20', 'Accuracy+20 Attack+20', 'Accuracy+10', '"Store TP"+10', 'Damage taken-5%', }, }) --Prelude +1, Madrigal +1
gear.brdFCPdt = hp_gear("Intarabus's Cape", 0, {
    augments = { 'CHR+20', 'Mag. Acc+20 /Mag. Dmg.+20', 'Mag. Acc.+10', '"Fast Cast"+10', 'Phys. dmg. taken-10%' }, })  --FC 10, PDT 10, Macc 10
gear.brdWaltz = hp_gear("Intarabus's Cape", 0, {
    augments = { 'MND+20', 'Eva.+20 /Mag. Eva.+20', 'Mag. Evasion+10', '"Waltz" potency +10%', 'Mag. Evasion+15' }, })  --Waltz 10
gear.brdWSDDt = hp_gear("Intarabus's Cape", 0, {
    augments = { 'STR+20', 'Accuracy+20 Attack+20', 'STR+10', 'Weapon skill damage +10%', 'Damage taken-5%' }, })  --WSD 10, DT 5, Acc 20
gear.brdWSDChr = hp_gear("Intarabus's Cape", 0, {
    augments = { 'CHR+20', 'Accuracy+20 Attack+20', 'CHR+10', 'Weapon skill damage +10%', 'Damage taken-5%' }, })  --WSD 10, DT 5, Acc 20
gear.brdWSDInt = hp_gear("Intarabus's Cape", 0, {
    augments = { 'INT+20', 'Mag. Acc+20 /Mag. Dmg.+20', 'INT+10', 'Weapon skill damage +10%', 'Damage taken-5%' }, })  --WSD 10, DT 5

--COR Capes
gear.corDA = hp_gear("Camulus's Mantle", 0,
    { augments = { 'DEX+20', 'Accuracy+20 Attack+20', 'Accuracy+10', '"Dbl.Atk."+10', 'Damage taken-5%' } })  --DA 10, DT 5, Acc 20, Acc 10
gear.corDA1 = hp_gear("Camulus's Mantle", 0,
    { augments = { 'DEX+20', 'Accuracy+20 Attack+20', '"Dbl.Atk."+10', 'Damage taken-5%' } })  --DA 10, DT 5, Acc 20
gear.corWSD = hp_gear("Camulus's Mantle", 0,
    { augments = { 'STR+20', 'Accuracy+20 Attack+20', 'STR+10', 'Weapon skill damage +10%', } })  --WSD 10, Acc 20
gear.corRMWSD = hp_gear("Camulus's Mantle", 0,
    { augments = { 'AGI+20', 'Mag. Acc+20 /Mag. Dmg.+20', 'AGI+10', 'Weapon skill damage +10%' } })  --WSD 10
gear.corDW = hp_gear("Camulus's Mantle", 0, {
    augments = { 'DEX+20', 'Accuracy+20 Attack+20', 'Accuracy+10', '"Dual Wield"+10', 'Phys. dmg. taken-10%' }, })  --DW 10, PDT 10, Acc 20, Acc 10
gear.corRWSD = hp_gear("Camulus's Mantle", 0,
    { augments = { 'AGI+20', 'Rng.Acc.+20 Rng.Atk.+20', 'AGI+10', 'Weapon skill damage +10%' } })  --WSD 10
gear.corSnapshotHybrid = hp_gear("Camulus's Mantle", 0,
    { augments = { 'AGI+20', 'Rng.Acc.+20 Rng.Atk.+20', 'Rng.Acc.+10', '"Snapshot"+10', 'Damage taken-5%', } })  --Snapshot 10, DT 5
gear.corCrit = hp_gear("Camulus's Mantle", 0, {
    augments = { 'AGI+20', 'Rng.Acc.+20 Rng.Atk.+20', 'Rng.Acc.+10', 'Crit.hit rate+10', 'Damage taken-5%' }, })  --Crit 10, DT 5
gear.corDAPdt = hp_gear("Camulus's Mantle", 0, {
    augments = { 'DEX+20', 'Accuracy+20 Attack+20', 'Accuracy+10', '"Dbl.Atk."+10', 'Phys. dmg. taken-10%' }, })  --DA 10, PDT 10, Acc 20, Acc 10
gear.corWSDDt = hp_gear("Camulus's Mantle", 0, {
    augments = { 'AGI+20', 'Rng.Acc.+20 Rng.Atk.+20', 'AGI+10', 'Weapon skill damage +10%', 'Damage taken-5%' }, })  --WSD 10, DT 5
gear.corFC = hp_gear("Camulus's Mantle", 80, {
    augments = { 'HP+60', 'HP+20', '"Fast Cast"+10' }, })  --HP 60, HP 20, FC 10

--DRG Capes
gear.drgDA = hp_gear("Brigantia's Mantle", 0,
    { augments = { 'DEX+20', 'Accuracy+20 Attack+20', '"Dbl.Atk."+10', 'Damage taken-5%', } })  --DA 20
gear.drgWSD = hp_gear("Brigantia's Mantle", 0,
    { augments = { 'STR+20', 'Accuracy+20 Attack+20', 'Weapon skill damage +10%', 'Damage taken-5%', } })  --DA 20
gear.drgWSDDt = hp_gear("Brigantia's Mantle", 0, {
    augments = { 'STR+20', 'Accuracy+20 Attack+20', 'STR+10', 'Weapon skill damage +10%', 'Damage taken-5%' }, })  --DA 20
gear.drgDADt = hp_gear("Brigantia's Mantle", 0, {
    augments = { 'DEX+20', 'Accuracy+20 Attack+20', 'Accuracy+10', '"Dbl.Atk."+10', 'Damage taken-5%' }, })  --DA 20

--GEO Capes
gear.geoIdle = hp_gear("Nantosuelta's Cape", 60,
    { augments = { 'HP+60', 'Eva.+20 /Mag. Eva.+20', 'Pet: "Regen"+10', 'Pet: Damage taken -5%' } })     --PetDT 5, Pet Regen 10
gear.geoNuke = hp_gear("Nantosuelta's Cape", 0,
    { augments = { 'INT+20', 'Mag. Acc+20 /Mag. Dmg.+20', '"Mag.Atk.Bns."+10', 'Damage taken-5%' } })    --MAB 10
gear.geoFC = hp_gear("Nantosuelta's Cape", 0,
    { augments = { 'MND+20', 'Eva.+20 /Mag. Eva.+20', 'MND+10', '"Fast Cast"+10', 'Damage taken-5%' } }) --FC 10

--MNK Capes
gear.mnkDA = hp_gear("Segomo's Mantle", 0,
    { augments = { 'DEX+20', 'Accuracy+20 Attack+20', 'DEX+10', '"Dbl.Atk."+10', 'Damage taken-5%' } })  --DA 10, DT 5, Acc 20
gear.mnkCrit = hp_gear("Segomo's Mantle", 0,
    { augments = { 'STR+20', 'Accuracy+20 Attack+20', 'STR+10', 'Crit.hit rate+10', 'Damage taken-5%' } })  --Crit 10, DT 5, Acc 20
gear.mnkSTP = hp_gear("Segomo's Mantle", 0,
    { augments = { 'DEX+20', 'Accuracy+20 Attack+20', 'Accuracy+10', '"Store TP"+10', 'Damage taken-5%' } })  --STP 10, DT 5, Acc 20, Acc 10
gear.mnkFC = hp_gear("Segomo's Mantle", 80, {
    augments = { 'HP+60', 'HP+20', '"Fast Cast"+10' }, })  --HP 60, HP 20, FC 10

--NIN Capes
gear.ninDA = hp_gear("Andartia's Mantle", 0,
    { augments = { 'DEX+20', 'Accuracy+20 Attack+20', 'Accuracy+10', '"Dbl.Atk."+10', 'Damage taken-5%', } })  --DA 10, DT 5, Acc 20, Acc 10
gear.ninFC = hp_gear("Andartia's Mantle", 0, {
    augments = { 'INT+20', 'Mag. Acc+20 /Mag. Dmg.+20', 'Mag. Acc.+10', '"Fast Cast"+10' }, })  --FC 10, Macc 10
gear.ninWSD = hp_gear("Andartia's Mantle", 0, {
    augments = { 'AGI+20', 'Accuracy+20 Attack+20', 'AGI+10', 'Weapon skill damage +10%', 'Damage taken-5%' }, })  --WSD 10, DT 5, Acc 20

--PLD Capes
gear.pldEnmity = hp_gear("Rudianos's Mantle", 0,
    { augments = { 'VIT+20', 'Eva.+20 /Mag. Eva.+20', 'Enmity+10', 'Damage taken-5%' } })  --DT 5, Enmity 10
gear.pldFC = hp_gear("Rudianos's Mantle", 60,
    { augments = { 'HP+60', 'Eva.+20 /Mag. Eva.+20', '"Fast Cast"+10' } })  --HP 60, FC 10
gear.pldDA = hp_gear("Rudianos's Mantle", 0, {
    augments = { 'DEX+20', 'Accuracy+20 Attack+20', 'Accuracy+10', '"Dbl.Atk."+10', 'Damage taken-5%' }, })  --DA 10, DT 5, Acc 20, Acc 10
gear.pldCure = hp_gear("Rudianos's Mantle", 80, {
    augments = { 'HP+60', 'Eva.+20 /Mag. Eva.+20', 'HP+20', '"Cure" potency +10%', 'Spell interruption rate down-10%' }, })  --HP 60, HP 20, Cure Pot 10, SIRD 10

--RDM Capes
gear.rdmDW = hp_gear("Sucellos's Cape", 0,
    { augments = { 'DEX+20', 'Accuracy+20 Attack+20', 'Accuracy+10', '"Dual Wield"+10', 'Damage taken-5%', } })  --DW 10, DT 5, Acc 20, Acc 10
gear.rdmFC = hp_gear("Sucellos's Cape", 0,
    { augments = { 'MND+20', 'Mag. Acc+20 /Mag. Dmg.+20', '"Fast Cast"+10', 'Damage taken-5%', } })  --FC 10, DT 5
gear.rdmWSD = hp_gear("Sucellos's Cape", 0,
    { augments = { 'STR+20', 'Accuracy+20 Attack+20', 'STR+10', 'Weapon skill damage +10%', } })  --WSD 10, Acc 20
gear.rdmNuke = hp_gear("Sucellos's Cape", 0,
    { augments = { 'INT+20', 'Mag. Acc+20 /Mag. Dmg.+20', 'INT+10', '"Mag.Atk.Bns."+10', 'Damage taken-5%', } })  --MAB 10, DT 5
gear.rdmSTP = hp_gear("Sucellos's Cape", 0,
    { augments = { 'DEX+20', 'Accuracy+20 Attack+20', 'Accuracy+10', '"Store TP"+10', 'Damage taken-5%', } })  --STP 10, DT 5, Acc 20, Acc 10
gear.rdmCrit = hp_gear("Sucellos's Cape", 0, {
    augments = { 'DEX+20', 'Accuracy+20 Attack+20', 'DEX+10', 'Crit.hit rate+10', 'Damage taken-5%' }, })  --Crit 10, DT 5, Acc 20
gear.rdmFCPdt = hp_gear("Sucellos's Cape", 0, {
    augments = { 'MND+20', 'Mag. Acc+20 /Mag. Dmg.+20', 'Mag. Acc.+10', '"Fast Cast"+10', 'Phys. dmg. taken-10%' }, })  --FC 10, PDT 10, Macc 10

--RNG Capes
gear.rngSnapshot = hp_gear("Belenus's Cape", 80,
    { augments = { 'HP+60', 'Eva.+20 /Mag. Eva.+20', 'HP+20', '"Snapshot"+10', 'Damage taken-5%', } })  --HP 60, HP 20, Snapshot 10, DT 5
gear.rngSTRWSD = hp_gear("Belenus's Cape", 0,
    { augments = { 'STR+20', 'Accuracy+20 Attack+20', 'STR+10', 'Weapon skill damage +10%', 'Damage taken-5%', } })  --WSD 10, DT 5, Acc 20
gear.rngDW = hp_gear("Belenus's Cape", 0,
    { augments = { 'DEX+20', 'Accuracy+20 Attack+20', 'Accuracy+10', '"Dual Wield"+10', 'Damage taken-5%', } })  --DW 10, DT 5, Acc 20, Acc 10
gear.rngRangedSTP = hp_gear("Belenus's Cape", 0,
    { augments = { 'AGI+20', 'Rng.Acc.+20 Rng.Atk.+20', 'AGI+10', '"Store TP"+10', 'Damage taken-5%', } })  --STP 10, DT 5
gear.rngWSD = hp_gear("Belenus's Cape", 0, {
    augments = { 'AGI+20', 'Rng.Acc.+20 Rng.Atk.+20', 'AGI+10', 'Weapon skill damage +10%', 'Damage taken-5%' }, })  --WSD 10, DT 5
gear.rngCrit = hp_gear("Belenus's Cape", 0, {
    augments = { 'AGI+20', 'Rng.Acc.+20 Rng.Atk.+20', 'AGI+10', 'Crit.hit rate+10', 'Damage taken-5%' }, })  --Crit 10, DT 5

--SCH Capes
gear.schCure = hp_gear("Lugh's Cape", 0,
    { augments = { 'MND+20', 'Eva.+20 /Mag. Eva.+20', 'MND+10', '"Cure" potency +10%', 'Damage taken-5%' } }) --Cure Pot 10
gear.schFC = hp_gear("Lugh's Cape", 0,
    { augments = { 'INT+20', 'Mag. Acc+20 /Mag. Dmg.+20', 'INT+10', '"Fast Cast"+10', 'Damage taken-5%' } })  --FC 10
gear.schFCDt = hp_gear("Lugh's Cape", 60, {
    augments = { 'HP+60', 'Eva.+20 /Mag. Eva.+20', 'Mag. Evasion+10', '"Fast Cast"+10', 'Damage taken-5%' }, })  --HP 60, FC 10, DT 5

--WAR Capes
gear.warDA = hp_gear("Cichol's Mantle", 0,
    { augments = { 'DEX+20', 'Accuracy+20 Attack+20', 'DEX+10', '"Dbl.Atk."+10', 'Damage taken-5%' } })  --DA 10, DT 5, Acc 20
gear.warDAAcc = hp_gear("Cichol's Mantle", 0,
    { augments = { 'DEX+20', 'Accuracy+20 Attack+20', 'Accuracy+10', '"Dbl.Atk."+10', 'Damage taken-5%' } })  --DA 10, DT 5, Acc 20, Acc 10
gear.warCrit = hp_gear("Cichol's Mantle", 0,
    { augments = { 'STR+20', 'Accuracy+20 Attack+20', 'STR+10', 'Crit.hit rate+10', 'Damage taken-5%' } })  --Crit 10, DT 5, Acc 20
gear.warWSD = hp_gear("Cichol's Mantle", 0,
    { augments = { 'STR+20', 'Accuracy+20 Attack+20', 'STR+10', 'Weapon skill damage +10%', 'Phys. dmg. taken-10%' } })  --WSD 10, PDT 10, Acc 20
gear.warWSDVIT = hp_gear("Cichol's Mantle", 0, {
    augments = { 'VIT+20', 'Accuracy+20 Attack+20', 'VIT+10', 'Weapon skill damage +10%', 'Damage taken-5%' }, })  --WSD 10, DT 5, Acc 20
gear.warWSDSTR = hp_gear("Cichol's Mantle", 0, {
    augments = { 'STR+20', 'Accuracy+20 Attack+20', 'STR+10', 'Weapon skill damage +10%', 'Damage taken-5%' }, })  --WSD 10, DT 5, Acc 20

--WHM Capes (Set: Increases Accuracy, Ranged Accuracy, and Magic Accuracy)
gear.whmFC = hp_gear("Alaunus's Cape", 80,
    { augments = { 'HP+60', 'Eva.+20 /Mag. Eva.+20', 'HP+20', '"Fast Cast"+10', 'Damage taken-5%', } })        --FC 10, DT 5
gear.whmCure = hp_gear("Alaunus's Cape", 0,
    { augments = { 'MND+20', 'Eva.+20 /Mag. Eva.+20', 'MND+10', '"Cure" potency +10%', 'Damage taken-5%', } }) --FC 10, DT 5


--[[ AF/Relic/Empyrean ]] --

--Assimilator BLU Artifact
gear.assimilatorHeadPlusOne = hp_gear("Assimilator's Keffiyeh +1", 46)   --Macc 18, MAB 18, Int 23
gear.assimilatorBodyPlusOne = hp_gear("Assimilator's Jubbah +1", 69)     --Blue Magic +20, Macc 0, MAB 0, Refresh 2
gear.assimilatorBodyPlusThree = hp_gear("Assimilator's Jubbah +3", 113)    --WSD 10, Blu Magic +24, Refresh 3
gear.assimilatorBodyPlusFour = hp_gear("Assimilator's Jubbah +4", 123)    --WSD 12, Blu Magic +25, Refresh 3
gear.assimilatorHandsPlusOne = hp_gear("Assimilator's Bazubands +1", 25) --Chance to learn blue magic +12
gear.assimilatorLegsPlusOne = hp_gear("Assimilator's Shalwar +1", 62)    --SIRD 20, Burst Affinity 12
gear.assimilatorFeetPlusOne = hp_gear("Assimilator's Charuqs +1", 33)    --Chain Affinity 20

--Luhlaza BLU Relic
gear.luhlazaHeadPlusThree = hp_gear("Luhlaza Keffiyeh +3", 91)   --Blue Magic 17, Macc 37, INT 30, Convergence+
gear.luhlazaBodyPlusOne = hp_gear("Luhlaza Jubbah +1", 59)     --FC 7, Haste 4, Refresh 2, Enchainment+
gear.luhlazaHandsPlusOne = hp_gear("Luhlaza Bazubands +1", 50) --Azure Lore+
gear.luhlazaLegsPlusThree = hp_gear("Luhlaza Shalwar +3", 87)    --WSD 10, Macc 45, MAB 57, Assimilation+
gear.luhlazaLegsPlusFour = hp_gear("Luhlaza Shalwar +4", 97)    --WSD 12, Macc 50, MAB 60, Assimilation+
gear.luhlazaFeetPlusFour = hp_gear("Luhlaza Charuqs +4", 43)    --Blue Magic 13, Macc 41, Diffusion+

--Hashishin BLU Empyrean (Occ. Augments Blu Spells)
gear.hashishinHeadPlusOne = hp_gear("Hashishin Kavuk +1", 36)      --Sword Skill 20, Chain Affinity 24
gear.hashishinHeadPlusTwo = hp_gear("Hashishin Kavuk +2", 56)      --WSD 8, Sword Skill 25, Chain Affinity 26
gear.hashishinHeadPlusThree = hp_gear("Hashishin Kavuk +3", 66)      --WSD 12, Sword Skill 30, Chain Affinity 28
gear.hashishinBodyPlusOne = hp_gear("Hashishin Mintan +1", 57)     --FC 14 Blue Magic, Haste 4, Macc 24, Refresh 2
gear.hashishinBodyPlusTwo = hp_gear("Hashishin Mintan +2", 77)     --DT 12, FC 15 Blue Magic, Haste 4, Macc 24, Refresh 3
gear.hashishinBodyPlusThree = hp_gear("Hashishin Mintan +3", 87)     --DT 13, FC 16 Blue Magic, Haste 4, Macc 24, Refresh 4
gear.hashishinHandsPlusOne = hp_gear("Hashishin Bazubands +1", 25) --Macc 0, MAB 24, INT 19, Blue Magic Recast 14
gear.hashishinHandsPlusTwo = hp_gear("Hashishin Bazubands +2", 45) --DT 9, Macc 52, MAB 49, INT 28, Blue Magic Recast 15
gear.hashishinHandsPlusThree = hp_gear("Hashishin Bazubands +3", 55) --DT 10, Macc 62, MAB 57, INT 45, Blue Magic Recast 16
gear.hashishinLegsPlusOne = hp_gear("Hashishin Tayt +1", 45)       --Blue Magic 23, Macc 0, MAB 0, INT 34, Efflux +700
gear.hashishinLegsPlusTwo = hp_gear("Hashishin Tayt +2", 65)       --DT 11, Blue Magic 28, Macc 53, MAB 48, INT 43, Efflux +750
gear.hashishinLegsPlusThree = hp_gear("Hashishin Tayt +3", 75)       --DT 12, Blue Magic 33, Macc 63, MAB 53, INT 48, Efflux +800
gear.hashishinFeetPlusOne = hp_gear("Hashishin Basmak +1", 15)     --Macc 27, MAB 27, Int 29, Burst Affinity 15, Enmity -8
gear.hashishinFeetPlusTwo = hp_gear("Hashishin Basmak +2", 35)     --Macc 50, MAB 50, Int 34, Burst Affinity 18, Magic Burst Damage 10,
gear.hashishinFeetPlusThree = hp_gear("Hashishin Basmak +3", 45)     --Macc 60, MAB 55, Int 39, Burst Affinity 21, Magic Burst Damage 15

--Brioso BRD Artifact (Set: Acc, Racc, Macc)
gear.briosoHeadPlusTwo = hp_gear("Brioso Roundlet +2", 54) --String Skill 11, Paeon 1, Macc 51
gear.briosoHandsPlusFour = hp_gear("Brioso Cuffs +4", 53)   -- Singing Skill 18, Lullaby 2, Enmity -8, Macc 58
gear.briosoBodyPlusThree = hp_gear("Brioso Justau. +3", 91)  --FC 15 Songs, Singing Skill 17, String Skill 14, Enmity -6
gear.briosoLegsPlusTwo = hp_gear("Brioso Cannions +2", 64) --DT 4, Wind Instrument 17, Enmity -4, Macc 46
gear.briosoFeetPlusFour = hp_gear("Brioso Slippers +4", 84) --Song Dur 15%, Wind Instrument 15, CHR 50

--Fili BRD Empyrean (Set: Augments Songs - Stat+)
gear.filiHead = hp_gear("Fili Calot", 17)               --FC Songs 13, Madrigal 1, Enmity -8
gear.filiHeadPlusOne = hp_gear("Fili Calot +1", 36)       --FC Songs 14, Madrigal 1, Enmity -9
gear.filiHeadPlusTwo = hp_gear("Fili Calot +2", 56)       --DT 10, FC Songs 15, Madrigal 1, Enmity -10
gear.filiHeadPlusThree = hp_gear("Fili Calot +3", 66)       --DT 11, FC Songs 16, Madrigal 1, Enmity -1
gear.filiBody = hp_gear("Fili Hongreline", 25)          --Song Dur 11%, Singing/Wind Instrument 12, Minuet 1
gear.filiBodyPlusOne = hp_gear("Fili Hongreline +1", 54)  --Song Dur 12%, Singing/Wind Instrument 14, Minuet 1
gear.filiBodyPlusTwo = hp_gear("Fili Hongreline +2", 74)  --Song Dur 13%, Singing/Wind Instrument 19, Minuet 1
gear.filiBodyPlusThree = hp_gear("Fili Hongreline +3", 84)  --Song Dur 14%, Singing/Wind Instrument 24, Minuet 1
gear.filiHands = hp_gear("Fili Manchettes", 10)         --March 1, Singing/String/Wind Instrument 10
gear.filiHandsPlusOne = hp_gear("Fili Manchettes +1", 22) --March 1, Singing/String/Wind Instrument 12
gear.filiHandsPlusTwo = hp_gear("Fili Manchettes +2", 42) --DT 10, March 1, Singing/String/Wind Instrument 17
gear.filiHandsPlusThree = hp_gear("Fili Manchettes +3", 52) --DT 11, March 1, Singing/String/Wind Instrument 22
gear.filiFeet = hp_gear("Fili Cothurnes", 6)            --MS 12, Scherzo 1, Regen 2
gear.filiFeetPlusOne = hp_gear("Fili Cothurnes +1", 13)   --Regen 2, MS 18, Scherzo 1
gear.filiFeetPlusTwo = hp_gear("Fili Cothurnes +2", 33)   --FC 10, Regen 3, MS 18, Scherzo 1
gear.filiFeetPlusThree = hp_gear("Fili Cothurnes +3", 43)   --FC 13, Regen 4, MS 18, Scherzo 1

--Corsair/Laksamana COR Artifact
gear.laksamanaBodyPlusFour = hp_gear("Laksa. Frac +4", 108) --WSD 12, Racc 67, Ratt 40, Macc 67, Rapid Shot 20

--Commodore/Lanun COR Relic
gear.commodoreHands = hp_gear("Commodore Gants", 12)   --Snapshot +
gear.lanunHeadPlusThree = hp_gear("Lanun Tricorne +3", 80) --Racc 37, Ratt 87, Macc 37, Phantom Roll 50, Winning Streak+
gear.lanunBodyPlusThree = hp_gear("Lanun Frac +3", 79)     --Ratt 83, Macc 40, Matk 61, Random Deal 50, Loaded Deck+
gear.lanunFeetPlusFour = hp_gear("Lanun Bottes +4", 68)   --WSD 12, Ratt 71, Macc 41, Matk 58, Wild Card+

--Navarch/Chasseur COR Empyrean
gear.navarchHandsPlusOne = hp_gear("Nvrch. Gants +1", 0)       --Phantom Roll Dur 50, Allies Roll+
gear.navarchLegsPlusOne = hp_gear("Nvrch. Culottes +1", 0)     --Snapshot+, Occ Enhance Caster's Roll
gear.navarchFeetPlusOne = hp_gear("Nvrch. Bottes +1", 0)       --Occ Enhance Courser's Roll
gear.chasseurHead = hp_gear("Chasseur's Tricorne", 16)       --Rapid Shot 12, Blitzer's Roll+
gear.chasseurBody = hp_gear("Chasseur's Frac", 27)           --Tactician's Roll+
gear.chasseurHandsPlusOne = hp_gear("Chasseur's Gants +1", 22) -- Phantom Roll Dur 50, Allies Roll+

--Geomancy GEO Artifact
gear.geomancyHead = hp_gear("Geomancy Galero", 17)        --Cardinal Chant+
gear.geomancyBodyPlusThree = hp_gear("Geomancy Tunic +3", 91) --Refresh 3, Life Cycle +14, Macc 50, INT 39
gear.geomancyHandsPlusThree = hp_gear("Geo. Mitaines +3", 80) --PDT 3, Geomancy 18, Luopan DT 13
gear.geomancyFeet = hp_gear("Geomancy Sandals", 6)        --MS 12%

--Gallant/Reverence PLD Artifact
gear.gallantHead = hp_gear("Gallant Coronet", 12)         --Cover+, Enmity 2
gear.gallantFeet = hp_gear("Gallant Leggings", 15)        --Holy Circle+

gear.reverenceHead = hp_gear("Rev. Coronet", 19)          --PDT 5, Cover+, Enmity 5
gear.reverenceBodyPlusFour = hp_gear("Rev. Surcoat +4", 264) --DT 11, FC 10, Enmity 10, Divine Magic 18
gear.reverenceFeet = hp_gear("Rev. Leggings", 38)         --Holy Circle +

--Valor/Caballarius PLD Relic
gear.valorBody = hp_gear("Valor Surcoat", 23)       --Cover+
gear.caballariusHead = hp_gear("Cab. Coronet", 59)  --Rampart Dur 30, Iron Will+, Enmity 6
gear.caballariusLegs = hp_gear("Cab. Breeches", 24) --PDT 4, Enmity 6, Invincible+
gear.caballariusFeet = hp_gear("Cab. Leggings", 33) --MDT 4, Sentinel 10, Guardian+

--Chevalier PLD Empyrean (Set Occasionally Absorbs Damage Taken 2-5% chance)
gear.chevalierHeadPlusOne = hp_gear("Chevalier's Armet +1", 125)     --FC 7, MDB 2 Convert 6% of Physical Damage Taken to MP, Shield Skill 11
gear.chevalierHeadPlusTwo = hp_gear("Chevalier's Armet +2", 135)     --DT 10, FC 8, MDB 5, Convert 7% of Physical Damage Taken to MP, Shield Skill 11
gear.chevalierHeadPlusThree = hp_gear("Chevalier's Armet +3", 145)     --DT 11, FC 9, MDB 6, Convert 8% of Physical Damage Taken to MP, Shield Skill 11
gear.chevalierBodyPlusOne = hp_gear("Chevalier's Cuirass +1", 131)   --Mitigates Damage Taken Based on Enmity, Enmity +12, MDB 4
gear.chevalierBodyPlusTwo = hp_gear("Chevalier's Cuirass +2", 141)   --Mitigates Damage Taken Based on Enmity, Enmity +14, MDB 7, SIRD 15
gear.chevalierBodyPlusThree = hp_gear("Chevalier's Cuirass +3", 151)   --Mitigates Damage Taken Based on Enmity, Enmity +16, MDB 8, SIRD 20
gear.chevalierHandsPlusOne = hp_gear("Chevalier's Gauntlets +1", 34) --Sword Skill 28, Shield Def Bonus 3, MDB 1
gear.chevalierHandsPlusTwo = hp_gear("Chevalier's Gauntlets +2", 54) --DT 10, Sword Skill 33, Shield Def Bonus 4, MDB 4
gear.chevalierHandsPlusThree = hp_gear("Chevalier's Gauntlets +3", 64) --DT 11, Sword Skill 38, Shield Def Bonus 5, MDB 5
gear.chevalierLegsPlusOne = hp_gear("Chevalier's Cuisses +1", 107)   --PDT 6, Reduces Enmity decrease when taking damage 12, MDB 3
gear.chevalierLegsPlusTwo = hp_gear("Chevalier's Cuisses +2", 117)   --DT 12, Reduces Enmity decrease when taking damage 13, MDB 6
gear.chevalierLegsPlusThree = hp_gear("Chevalier's Cuisses +3", 127)   --DT 13, Reduces Enmity decrease when taking damage 14, MDB 7
gear.chevalierFeetPlusOne = hp_gear("Chevalier's Sabatons +1", 22)   --Divine Emblem 15, Enmity +11, MDB 2
gear.chevalierFeetPlusTwo = hp_gear("Chevalier's Sabatons +2", 42)   --FC 10, Divine Emblem 18, Enmity +13, MDB 5
gear.chevalierFeetPlusThree = hp_gear("Chevalier's Sabatons +3", 52)   --FC 13, Divine Emblem 21, Enmity +15, MDB 6

--Atrophy RDM Artifact
gear.atrophyHeadPlusThree = hp_gear("Atrophy Chapeau +3", 64) --FC 16, Elemental Magic 17, Macc 54, MBD 10
gear.atrophyBodyPlusFour = hp_gear("Atrophy Tabard +4", 101) --Enfeebling Magic 22, Refresh Pot 2, Refresh 3
gear.atrophyHandsPlusThree = hp_gear("Atrophy Gloves +3", 43) --WSD 6, Enhancing Dur 20%
gear.atrophyHandsPlusFour = hp_gear("Atrophy Gloves +4", 53) --WSD 9, Enhancing Dur 20%
gear.atrophyLegsPlusThree = hp_gear("Atrophy Tights +3", 74)  --Enhancing Skill 21, Healing Skill 17, Cure Pot 12

--Duelist/Vitiation RDM Relic
gear.duelistBody = mp_gear("Duelist's Tabard", 24) -- FC 10

--Lethargy RDM Empyrean (Set Augments Composure 10-50% Self Enh Duration)
gear.lethargyHeadPlusOne = hp_gear("Lethargy Chappel +1", 36)     --FC Enfeebling 15
gear.lethargyHeadPlusTwo = hp_gear("Lethargy Chappel +2", 56)     --DT 9, FC Enfeebling 16
gear.lethargyHeadPlusThree = hp_gear("Lethargy Chappel +3", 66)     --DT 10, FC Enfeebling 17
gear.lethargyBodyPlusOne = hp_gear("Lethargy Sayon +1", 57)       --Refresh 2, Enfeebling Magic Effect 14
gear.lethargyBodyPlusTwo = hp_gear("Lethargy Sayon +2", 77)       --DT 13, Refresh 3, Enfeebling Magic Effect 16
gear.lethargyBodyPlusThree = hp_gear("Lethargy Sayon +3", 87)       --DT 14, Refresh 4, Enfeebling Magic Effect 18
gear.lethargyHandsPlusOne = hp_gear("Lethargy Gantherots +1", 25) --Enfeebling Magic Skill 19, Saboteur 12
gear.lethargyHandsPlusTwo = hp_gear("Lethargy Gantherots +2", 45) --DT 10, Enfeebling Magic Skill 24, Saboteur 13
gear.lethargyHandsPlusThree = hp_gear("Lethargy Gantherots +3", 55) --DT 11, Enfeebling Magic Skill 29, Saboteur 14
gear.lethargyLegsPlusOne = hp_gear("Lethargy Fuseau +1", 45)      --Refresh Pot 2
gear.lethargyLegsPlusTwo = hp_gear("Lethargy Fuseau +2", 65)      --Refresh Pot 3, Magic Burst Damage 10
gear.lethargyLegsPlusThree = hp_gear("Lethargy Fuseau +3", 75)      --Refresh Pot 4, Magic Burst Damage 15
gear.lethargyFeetPlusOne = hp_gear("Lethargy Houseaux +1", 15)    --Enhancing Dur 30%, Enhancing Magic Skill 25, Enmity -9
gear.lethargyFeetPlusTwo = hp_gear("Lethargy Houseaux +2", 35)    --WSD 8, Enhancing Dur 35%, Enhancing Magic Skill 30, Enmity -10
gear.lethargyFeetPlusThree = hp_gear("Lethargy Houseaux +3", 45)    --WSD 12, Enhancing Dur 40%, Enhancing Magic Skill 35, Enmity -11

--Warrior/Agoge WAR Relic
gear.warriorBody = hp_gear("Warrior's Lorica", 10)   --Aggressor+
gear.warriorFeet = hp_gear("Warrior's Calligae", 10) --Berserk Def Penalty -10% While Equipped
gear.agogeHeadPlusFour = hp_gear("Agoge Mask +4", 68)   --WSD 12, Warcry Dur 30, Savagery+

--Boii WAR Empyrean (Set Augments Double Attack to sometimes deal double damage)
gear.boiiHeadPlusOne = hp_gear("Boii Mask +1", 43)      --DA 5, Crit 4
gear.boiiHeadPlusTwo = hp_gear("Boii Mask +2", 63)      --DT 10, DA 6, Crit 5
gear.boiiHeadPlusThree = hp_gear("Boii Mask +3", 73)      --DT 11, DA 7, Crit 6
gear.boiiBodyPlusOne = hp_gear("Boii Lorica +1", 66)    --STP 9, Blood Rage Dur 34
gear.boiiBodyPlusTwo = hp_gear("Boii Lorica +2", 86)    --DT 13, STP 10, Blood Rage Dur 36
gear.boiiBodyPlusThree = hp_gear("Boii Lorica +3", 96)    --DT 14, STP 11, Blood Rage Dur 38
gear.boiiHandsPlusOne = hp_gear("Boii Mufflers +1", 27) --Restraint +110, Axe Skill 21
gear.boiiHandsPlusTwo = hp_gear("Boii Mufflers +2", 47) --WSD 8, Restraint +120, Axe Skill 26
gear.boiiHandsPlusThree = hp_gear("Boii Mufflers +3", 57) --WSD 12, Restraint +130, Axe Skill 31
gear.boiiLegsPlusOne = hp_gear("Boii Cuisses +1", 50)   --DA 6, Fencer 2
gear.boiiLegsPlusTwo = hp_gear("Boii Cuisses +2", 70)   --PDL 7, DA 7, Fencer 3
gear.boiiLegsPlusThree = hp_gear("Boii Cuisses +3", 80)   --PDL 10, DA 8, Fencer 4, TP Bonus 100
gear.boiiFeetPlusOne = hp_gear("Boii Calligae +1", 15)  --Crit Damage 11, Retaliation 25
gear.boiiFeetPlusTwo = hp_gear("Boii Calligae +2", 35)  --DT 9, Crit Damage 12, Retaliation 28
gear.boiiFeetPlusThree = hp_gear("Boii Calligae +3", 45)  --DT 10, Crit Damage 13, Retaliation 31

--Theophany WHM Artifact
gear.theophanyBodyPlusThree = hp_gear("Theo. Bliaut +3", 91)     --Refresh 3, Enmity -6, Cure Pot II 6
gear.theophanyLegsPlusFour = hp_gear("Theo. Pant. +4", 84)      --Regen Dur 24, Cursna 21, Divine Magic 22
gear.theophanyHandsPlusThree = hp_gear("Theophany Mitts +3", 43) --Healing Magic 21, Cure Pot II 4, MND 48
gear.theophanyFeetPlusThree = hp_gear("Theo. Duckbills +3", 74)  --Enhancing Magic 21, Enfeebling Magic 21, Enhancing Dur 10%, SIRD 29

--Piety WHM relic
gear.pietyBodyPlusOne = hp_gear("Piety Bliaut +1", 54) --Regen Pot 36, Benediction+, Refresh 2, Enmity -6
gear.pietyBodyPlusTwo = hp_gear("Piety Bliaut +2", 64) --Regen Pot 44, Benediction+, Refresh 2, Enmity -7
gear.pietyBodyPlusThree = hp_gear("Piety Bliaut +3", 74) --Regen Pot 52, Benediction+, Refresh 3, Enmity -8
gear.pietyBodyPlusFour = hp_gear("Piety Bliaut +4", 84) --Regen Pot 52, Benediction+, Refresh 3, Enmity -8

--Ebers WHM Empyrean (Set Augments Barspells)
gear.ebersHeadPlusOne = hp_gear("Ebers Cap +1", 34)        --Divine Veil 22, Cure Pot 16
gear.ebersHeadPlusTwo = hp_gear("Ebers Cap +2", 54)        --FC 10, Divine Veil 24, Cure Pot 19
gear.ebersHeadPlusThree = hp_gear("Ebers Cap +3", 64)        --FC 13, Divine Veil 26, Cure Pot 22
gear.ebersBodyPlusOne = hp_gear("Ebers Bliaut +1", 107)    --Refresh 2, Afflatus Solace +14, Healing Magic 24, MND 33
gear.ebersBodyPlusTwo = hp_gear("Ebers Bliaut +2", 117)    --Refresh 3, Regen 4, Afflatus Solace +16, Healing Magic 29, MND 43
gear.ebersBodyPlusThree = hp_gear("Ebers Bliaut +3", 127)    --Refresh 4, Regen 5, Afflatus Solace +18, Healing Magic 34, MND 48
gear.ebersHandsPlusOne = hp_gear("Ebers Mitts +1", 45)     --Divine Caress 3, Regen Dur 22, Enmity -10
gear.ebersHandsPlusTwo = hp_gear("Ebers Mitts +2", 55)     --DT 10, Divine Caress 4, Regen Dur 24, Enmity -11
gear.ebersHandsPlusThree = hp_gear("Ebers Mitts +3", 65)     --DT 11, Divine Caress 5, Regen Dur 26, Enmity -12
gear.ebersLegsPlusOne = hp_gear("Ebers Pantaloons +1", 41) --FC Healing 13, Divine Benison 2, Convert 6% of Cure to MP, MND 33
gear.ebersLegsPlusTwo = hp_gear("Ebers Pantaloons +2", 61) --DT 12, FC Healing 14, Divine Benison 3, Convert 7% of Cure to MP, MND 40
gear.ebersLegsPlusThree = hp_gear("Ebers Pantaloons +3", 71) --DT 13, FC Healing 15, Divine Benison 4, Convert 8% of Cure to MP, MND 45
gear.ebersFeetPlusOne = hp_gear("Ebers Duckbills +1", 51)  --Auspice +15, Enhancing Magic 25
gear.ebersFeetPlusTwo = hp_gear("Ebers Duckbills +2", 61)  --DT 10, Auspice +17, Enhancing Magic 30
gear.ebersFeetPlusThree = hp_gear("Ebers Duckbills +3", 71)  --DT 11, Auspice +19, Enhancing Magic 35

--[==[ Full AF/Relic/Empyrean catalogue -- every variant in the client resources.
     Generated from Windower res/items.lua + item_descriptions.lua; priorities are
     each item base HP. Old-era base/+1/+2 and Reforged 109/+1/+2/+3/+4. ]==]--

--WAR Artifact (75-era)
gear.fighterHead = hp_gear("Fighter's Mask", 15)  --Enmity 1
gear.fighterHeadPlusOne = hp_gear("Ftr. Mask +1", 15)  --Enmity 1
gear.fighterBody = hp_gear("Fighter's Lorica", 20)  --Enmity 8
gear.fighterBodyPlusOne = hp_gear("Ftr. Lorica +1", 20)  --Att 10, Enmity 8
gear.fighterHands = hp_gear("Fighter's Mufflers", 13)  --Enmity 3, Shield Skill 10
gear.fighterHandsPlusOne = hp_gear("Ftr. Mufflers +1", 13)  --Enmity 3, Shield Skill 15
gear.fighterLegs = hp_gear("Fighter's Cuisses", 15)  --Acc 3, Enmity 2
gear.fighterLegsPlusOne = hp_gear("Ftr. Cuisses +1", 15)  --Acc 5, Enmity 3
gear.fighterFeet = hp_gear("Fighter's Calligae", 12)  --Enmity 1
gear.fighterFeetPlusOne = hp_gear("Ftr. Calligae +1", 12)  --Enmity 1

--WAR Artifact Reforged (Set: Increases Accuracy, Ranged Accuracy, and Magic Accuracy)
gear.pummelerHead = hp_gear("Pummeler's Mask", 18)  --Haste 7, MDB 1, Enmity 5
gear.pummelerHeadPlusOne = hp_gear("Pumm. Mask +1", 38)  --Haste 8, MDB 2, Enmity 6
gear.pummelerHeadPlusTwo = hp_gear("Pummeler's Mask +2", 57)  --Haste 8, MDB 2, Acc 37, Enmity 9
gear.pummelerHeadPlusThree = hp_gear("Pummeler's Mask +3", 67)  --Haste 8, MDB 3, Acc 47, Enmity 12
gear.pummelerHeadPlusFour = hp_gear("Pumm. Mask +4", 77)  --Haste 8, Macc 57, MDB 4, Acc 57, Enmity 12
gear.pummelerBody = hp_gear("Pummeler's Lorica", 29)  --Haste 4, MDB 2, Att 12, Enmity 9
gear.pummelerBodyPlusOne = hp_gear("Pumm. Lorica +1", 61)  --Haste 4, MDB 5, Att 12, Enmity 9
gear.pummelerBodyPlusTwo = hp_gear("Pumm. Lorica +2", 91)  --WSD 5, Haste 4, MDB 5, Acc 40, Att 22
gear.pummelerBodyPlusThree = hp_gear("Pumm. Lorica +3", 101)  --WSD 10, Haste 4, MDB 6, Acc 50, Att 32
gear.pummelerBodyPlusFour = hp_gear("Pumm. Lorica +4", 111)  --WSD 12, Haste 4, Macc 60, MDB 7, Acc 60
gear.pummelerHands = hp_gear("Pumm. Mufflers", 22)  --Haste 4, MDB 1, Enmity 4
gear.pummelerHandsPlusOne = hp_gear("Pumm. Mufflers +1", 37)  --Haste 5, MDB 2, Enmity 5
gear.pummelerHandsPlusTwo = hp_gear("Pumm. Mufflers +2", 55)  --Haste 5, MDB 2, Acc 38, Enmity 10
gear.pummelerHandsPlusThree = hp_gear("Pumm. Mufflers +3", 65)  --Haste 5, MDB 3, Acc 48, Enmity 15
gear.pummelerHandsPlusFour = hp_gear("Pumm. Mufflers +4", 75)  --Haste 5, Macc 58, MDB 4, Acc 58, Enmity 15
gear.pummelerLegs = hp_gear("Pumm. Cuisses", 23)  --DA 4, Haste 6, MDB 2, Acc 15, Enmity 4
gear.pummelerLegsPlusOne = hp_gear("Pumm. Cuisses +1", 50)  --DA 5, Haste 6, MDB 4, Acc 15, Enmity 4
gear.pummelerLegsPlusTwo = hp_gear("Pumm. Cuisses +2", 75)  --DA 8, Haste 6, MDB 4, Acc 46
gear.pummelerLegsPlusThree = hp_gear("Pumm. Cuisses +3", 85)  --DA 11, Haste 6, MDB 5, Acc 56
gear.pummelerLegsPlusFour = hp_gear("Pumm. Cuisses +4", 95)  --DA 11, Haste 6, Macc 66, MDB 6, Acc 66
gear.pummelerFeet = hp_gear("Pumm. Calligae", 22)  --DA 3, Haste 4, MDB 1, Att 15
gear.pummelerFeetPlusOne = hp_gear("Pumm. Calligae +1", 30)  --DA 3, Haste 4, MDB 3, Att 20
gear.pummelerFeetPlusTwo = hp_gear("Pumm. Calligae +2", 45)  --STP 2, DA 6, Haste 4, MDB 3, Acc 36
gear.pummelerFeetPlusThree = hp_gear("Pumm. Calligae +3", 55)  --STP 4, DA 9, Haste 4, MDB 4, Acc 46
gear.pummelerFeetPlusFour = hp_gear("Pumm. Calligae +4", 65)  --STP 4, DA 9, Haste 4, Macc 56, MDB 5

--WAR Relic (75-era)
gear.warriorHead = hp_gear("Warrior's Mask", 0)  --Enmity 1, Parrying Skill 5
gear.warriorHeadPlusOne = hp_gear("War. Mask +1", 0)  --Enmity 1, Parrying Skill 7
gear.warriorHeadPlusTwo = hp_gear("War. Mask +2", 0)  --Parrying Skill 9
gear.warriorBodyPlusOne = hp_gear("War. Lorica +1", 30)  --Att 12, Enmity 4
gear.warriorBodyPlusTwo = hp_gear("War. Lorica +2", 42)  --Acc 15, Att 15
gear.warriorHands = hp_gear("Warrior's Mufflers", 20)  --Att 12, Enmity 2
gear.warriorHandsPlusOne = hp_gear("War. Mufflers +1", 20)  --Att 14, Enmity 2
gear.warriorHandsPlusTwo = hp_gear("War. Mufflers +2", 28)  --Att 17
gear.warriorLegs = hp_gear("Warrior's Cuisses", 0)  --DA 1, Enmity 3
gear.warriorLegsPlusOne = hp_gear("War. Cuisses +1", 0)  --DA 1, Enmity 4
gear.warriorLegsPlusTwo = hp_gear("War. Cuisses +2", 0)  --DA 3
gear.warriorFeetPlusOne = hp_gear("War. Calligae +1", 15)  --Enmity 1
gear.warriorFeetPlusTwo = hp_gear("War. Calligae +2", 21)  --DEX 8, AGI 8

--WAR Relic Reforged (REA Set: Augments "Double Attack")
gear.agogeHead = hp_gear("Agoge Mask", 18)  --Haste 7, MDB 1, Att 18, Parrying Skill 15
gear.agogeHeadPlusOne = hp_gear("Agoge Mask +1", 38)  --Haste 8, MDB 2, Att 21, Parrying Skill 17
gear.agogeHeadPlusTwo = hp_gear("Agoge Mask +2", 48)  --WSD 5, Haste 8, Macc 27, MDB 3, Acc 27
gear.agogeHeadPlusThree = hp_gear("Agoge Mask +3", 58)  --WSD 10, Haste 8, Macc 37, MDB 4, Acc 37
gear.agogeBody = hp_gear("Agoge Lorica", 29)  --Haste 4, MDB 2, Acc 17, Att 17
gear.agogeBodyPlusOne = hp_gear("Agoge Lorica +1", 61)  --Haste 4, MDB 5, Acc 20, Att 20
gear.agogeBodyPlusTwo = hp_gear("Agoge Lorica +2", 71)  --DA 5, Haste 4, Macc 30, MDB 6, Acc 40
gear.agogeBodyPlusThree = hp_gear("Agoge Lorica +3", 81)  --DA 7, Haste 4, Macc 40, MDB 7, Acc 50
gear.agogeBodyPlusFour = hp_gear("Agoge Lorica +4", 91)  --DA 7, Haste 4, Macc 45, MDB 8, Acc 55
gear.agogeHands = hp_gear("Agoge Mufflers", 40)  --Haste 4, MDB 1, Att 20
gear.agogeHandsPlusOne = hp_gear("Agoge Mufflers +1", 50)  --Haste 5, MDB 2, Att 23
gear.agogeHandsPlusTwo = hp_gear("Agoge Mufflers +2", 60)  --Haste 5, Macc 28, MDB 3, Acc 28, Att 71
gear.agogeHandsPlusThree = hp_gear("Agoge Mufflers +3", 70)  --Haste 5, Macc 38, MDB 4, Acc 38, Att 86
gear.agogeHandsPlusFour = hp_gear("Agoge Mufflers +4", 80)  --Haste 5, Macc 43, MDB 5, Acc 43, Att 96
gear.agogeLegs = hp_gear("Agoge Cuisses", 23)  --DA 3, Haste 6, MDB 2
gear.agogeLegsPlusOne = hp_gear("Agoge Cuisses +1", 50)  --DA 4, Haste 6, MDB 4
gear.agogeLegsPlusTwo = hp_gear("Agoge Cuisses +2", 60)  --DA 5, Haste 6, Macc 29, MDB 5, Acc 29
gear.agogeLegsPlusThree = hp_gear("Agoge Cuisses +3", 70)  --DA 6, Haste 6, Macc 39, MDB 6, Acc 39
gear.agogeLegsPlusFour = hp_gear("Agoge Cuisses +4", 80)  --DA 6, Haste 6, Macc 44, MDB 7, Acc 44
gear.agogeFeet = hp_gear("Agoge Calligae", 7)  --Haste 4, MDB 1, Acc 10
gear.agogeFeetPlusOne = hp_gear("Agoge Calligae +1", 15)  --Haste 4, MDB 3, Acc 13
gear.agogeFeetPlusTwo = hp_gear("Agoge Calligae +2", 25)  --Haste 4, Macc 26, MDB 4, Acc 33, Att 46
gear.agogeFeetPlusThree = hp_gear("Agoge Calligae +3", 35)  --Haste 4, Macc 36, MDB 5, Acc 43, Att 61
gear.agogeFeetPlusFour = hp_gear("Agoge Calligae +4", 45)  --Haste 4, Macc 41, MDB 6, Acc 48, Att 71

--WAR Empyrean (90-era) (Set: Augments "Double Attack")
gear.ravagerHead = hp_gear("Ravager's Mask", 0)  --Att 5
gear.ravagerHeadPlusOne = hp_gear("Ravager's Mask +1", 0)  --DA 3, Acc 10, Att 10
gear.ravagerHeadPlusTwo = hp_gear("Ravager's Mask +2", 0)  --DA 4, Acc 14, Att 14
gear.ravagerBody = hp_gear("Ravager's Lorica", 0)  --STP 2, Acc 6, Att 6
gear.ravagerBodyPlusOne = hp_gear("Rvg. Lorica +1", 0)  --STP 5, Acc 15, Att 15, Great Axe Skill 5
gear.ravagerBodyPlusTwo = hp_gear("Rvg. Lorica +2", 0)  --STP 8, Acc 20, Att 20, Great Axe Skill 7
gear.ravagerHands = hp_gear("Ravager's Mufflers", 0)  --Acc 4
gear.ravagerHandsPlusOne = hp_gear("Rvg. Mufflers +1", 0)  --Acc 9, Axe Skill 3
gear.ravagerHandsPlusTwo = hp_gear("Rvg. Mufflers +2", 0)  --Acc 12, Axe Skill 5
gear.ravagerLegs = hp_gear("Ravager's Cuisses", 0)  --Att 5
gear.ravagerLegsPlusOne = hp_gear("Rvg. Cuisses +1", 0)  --DA 3, Haste 6, Att 10
gear.ravagerLegsPlusTwo = hp_gear("Rvg. Cuisses +2", 0)  --DA 5, Haste 7, Att 15
gear.ravagerFeet = hp_gear("Ravager's Calligae", 0)  --Acc 2
gear.ravagerFeetPlusOne = hp_gear("Rvg. Calligae +1", 0)  --Haste 4, Acc 5
gear.ravagerFeetPlusTwo = hp_gear("Rvg. Calligae +2", 0)  --Haste 5, Acc 7

--WAR Empyrean Reforged (REA Set: Augments "Double Attack")
gear.boiiHead = hp_gear("Boii Mask", 20)  --DA 4, Haste 6, MDB 1, Acc 14, Att 14
gear.boiiBody = hp_gear("Boii Lorica", 31)  --STP 8, Haste 3, MDB 2, Acc 20, Att 20
gear.boiiHands = hp_gear("Boii Mufflers", 12)  --Haste 3, Acc 12, Axe Skill 18
gear.boiiLegs = hp_gear("Boii Cuisses", 23)  --DA 5, Haste 7, MDB 1, Att 15
gear.boiiFeet = hp_gear("Boii Calligae", 7)  --Haste 5, MDB 1, Acc 17

--MNK Artifact (75-era)
gear.templeHead = hp_gear("Temple Crown", 16)  --MND 5
gear.templeHeadPlusOne = hp_gear("Tpl. Crown +1", 16)  --MND 8
gear.templeBody = hp_gear("Temple Cyclas", 20)  --Acc 5
gear.templeBodyPlusOne = hp_gear("Tpl. Cyclas +1", 20)  --Acc 5
gear.templeHands = hp_gear("Temple Gloves", 14)  --STR 4
gear.templeHandsPlusOne = hp_gear("Tpl. Gloves +1", 14)  --SB 4
gear.templeLegs = hp_gear("Temple Hose", 18)  --Guarding Skill 10
gear.templeLegsPlusOne = hp_gear("Tpl. Hose +1", 18)  --Guarding Skill 15
gear.templeFeet = hp_gear("Temple Gaiters", 12)  --DEX 3
gear.templeFeetPlusOne = hp_gear("Tpl. Gaiters +1", 12)  --DEX 5, MND 5

--MNK Artifact Reforged (Set: Increases Accuracy, Ranged Accuracy, and Magic Accuracy)
gear.anchoriteHead = hp_gear("Anchorite's Crown", 17)  --Haste 7, MDB 2
gear.anchoriteHeadPlusOne = hp_gear("Anchor. Crown +1", 36)  --Haste 8, MDB 4
gear.anchoriteHeadPlusTwo = hp_gear("Anch. Crown +2", 72)  --Haste 8, MDB 4, Acc 37
gear.anchoriteHeadPlusThree = hp_gear("Anch. Crown +3", 82)  --Haste 8, MDB 5, Acc 47
gear.anchoriteHeadPlusFour = hp_gear("Anchor. Crown +4", 92)  --Haste 8, Macc 57, MDB 6, Acc 57
gear.anchoriteBody = hp_gear("Anchorite's Cyclas", 28)  --Haste 4, MDB 2, Acc 10
gear.anchoriteBodyPlusOne = hp_gear("Anch. Cyclas +1", 59)  --Haste 4, MDB 4, Acc 10
gear.anchoriteBodyPlusTwo = hp_gear("Anch. Cyclas +2", 118)  --Haste 4, MDB 4, Acc 45
gear.anchoriteBodyPlusThree = hp_gear("Anch. Cyclas +3", 128)  --Haste 4, MDB 5, Acc 55
gear.anchoriteBodyPlusFour = hp_gear("Anch. Cyclas +4", 138)  --Haste 4, Macc 65, MDB 6, Acc 65
gear.anchoriteHands = hp_gear("Anchorite's Gloves", 26)  --Haste 4, SB 5
gear.anchoriteHandsPlusOne = hp_gear("Anch. Gloves +1", 40)  --Haste 5, MDB 1, SB 5
gear.anchoriteHandsPlusTwo = hp_gear("Anchor. Gloves +2", 80)  --WSD 5, Haste 5, MDB 1, Acc 38, SB 8
gear.anchoriteHandsPlusThree = hp_gear("Anchor. Gloves +3", 90)  --WSD 10, Haste 5, MDB 2, Acc 48, SB 11
gear.anchoriteHandsPlusFour = hp_gear("Anch. Gloves +4", 100)  --WSD 12, Haste 5, Macc 58, MDB 3, Acc 58
gear.anchoriteLegs = hp_gear("Anchorite's Hose", 22)  --Haste 6, MDB 1, Guarding Skill 20
gear.anchoriteLegsPlusOne = hp_gear("Anch. Hose +1", 47)  --Haste 6, MDB 3, Guarding Skill 22
gear.anchoriteLegsPlusTwo = hp_gear("Anch. Hose +2", 94)  --Haste 6, MDB 3, Acc 39, Guarding Skill 24
gear.anchoriteLegsPlusThree = hp_gear("Anch. Hose +3", 104)  --Haste 6, MDB 4, Acc 49, Guarding Skill 26
gear.anchoriteLegsPlusFour = hp_gear("Anch. Hose +4", 114)  --Haste 6, Macc 59, MDB 5, Acc 59, Guarding Skill 27
gear.anchoriteFeet = hp_gear("Anch. Gaiters", 6)  --Haste 4, MDB 1
gear.anchoriteFeetPlusOne = hp_gear("Anch. Gaiters +1", 13)  --Haste 4, MDB 3
gear.anchoriteFeetPlusTwo = hp_gear("Anch. Gaiters +2", 26)  --Haste 4, MDB 3, Acc 36
gear.anchoriteFeetPlusThree = hp_gear("Anch. Gaiters +3", 36)  --Haste 4, MDB 4, Acc 46
gear.anchoriteFeetPlusFour = hp_gear("Anch. Gaiters +4", 46)  --Haste 4, Macc 56, MDB 5, Acc 56, Att 120

--MNK Relic (75-era)
gear.meleeHead = hp_gear("Melee Crown", 5)  --SB 6, Enmity -3
gear.meleeHeadPlusOne = hp_gear("Mel. Crown +1", 5)  --SB 6, Enmity -4
gear.meleeHeadPlusTwo = hp_gear("Mel. Crown +2", 6)  --SB 7, Enmity -5
gear.meleeBody = hp_gear("Melee Cyclas", 5)  --VIT 5
gear.meleeBodyPlusOne = hp_gear("Mel. Cyclas +1", 6)  --VIT 6
gear.meleeBodyPlusTwo = hp_gear("Mel. Cyclas +2", 7)  --VIT 8, AGI 8
gear.meleeHands = hp_gear("Melee Gloves", 3)  --Att 16, SB 4
gear.meleeHandsPlusOne = hp_gear("Mel. Gloves +1", 3)  --Att 18, SB 5
gear.meleeHandsPlusTwo = hp_gear("Mel. Gloves +2", 4)  --Acc 21, Att 21, SB 6
gear.meleeLegs = hp_gear("Melee Hose", 6)  --SB 5
gear.meleeLegsPlusOne = hp_gear("Mel. Hose +1", 6)  --SB 6
gear.meleeLegsPlusTwo = hp_gear("Mel. Hose +2", 7)  --SB 7
gear.meleeFeet = hp_gear("Melee Gaiters", 4)  --Guarding Skill 12
gear.meleeFeetPlusOne = hp_gear("Mel. Gaiters +1", 4)  --Guarding Skill 14
gear.meleeFeetPlusTwo = hp_gear("Mel. Gaiters +2", 5)  --STR 7, DEX 7

--MNK Relic Reforged (REA Set: Augments "Kick Attacks")
gear.bhikkuHead = hp_gear("Bhikku Crown", 17)  --Haste 8, MDB 2, SB 11
gear.bhikkuHeadPlusOne = hp_gear("Bhikku Crown +1", 36)  --Haste 9, MDB 4, SB 12
gear.bhikkuHeadPlusTwo = hp_gear("Bhikku Crown +2", 56)  --Haste 9, Macc 51, MDB 7, Acc 51, Att 51
gear.bhikkuHeadPlusThree = hp_gear("Bhikku Crown +3", 66)  --Haste 9, Macc 61, MDB 8, Acc 61, Att 61
gear.bhikkuBody = hp_gear("Bhikku Cyclas", 28)  --Haste 4, MDB 2, Acc 15, Att 15
gear.bhikkuBodyPlusOne = hp_gear("Bhikku Cyclas +1", 59)  --Haste 4, MDB 4, Acc 23, Att 23
gear.bhikkuBodyPlusTwo = hp_gear("Bhikku Cyclas +2", 79)  --WSD 8, Haste 4, Macc 54, MDB 7, Acc 54
gear.bhikkuBodyPlusThree = hp_gear("Bhikku Cyclas +3", 89)  --WSD 12, Haste 4, Macc 64, MDB 8, Acc 64
gear.bhikkuHands = hp_gear("Bhikku Gloves", 11)  --Haste 4, Acc 13, Hand Skill 9
gear.bhikkuHandsPlusOne = hp_gear("Bhikku Gloves +1", 25)  --Haste 5, MDB 1, Acc 23, Hand Skill 11
gear.bhikkuHandsPlusTwo = hp_gear("Bhikku Gloves +2", 45)  --Haste 5, Macc 52, MDB 4, Acc 52, Att 52
gear.bhikkuHandsPlusThree = hp_gear("Bhikku Gloves +3", 55)  --Haste 5, Macc 62, MDB 5, Acc 62, Att 62
gear.bhikkuLegs = hp_gear("Bhikku Hose", 22)  --STP 6, Haste 6, MDB 2, Acc 13, Att 13
gear.bhikkuLegsPlusOne = hp_gear("Bhikku Hose +1", 47)  --STP 8, Haste 7, MDB 4, Acc 23, Att 23
gear.bhikkuLegsPlusTwo = hp_gear("Bhikku Hose +2", 67)  --STP 9, Haste 7, Macc 53, MDB 7, Acc 53
gear.bhikkuLegsPlusThree = hp_gear("Bhikku Hose +3", 77)  --STP 10, Haste 7, Macc 63, MDB 8, Acc 63
gear.bhikkuFeet = hp_gear("Bhikku Gaiters", 6)  --Haste 4, MDB 1, Acc 14
gear.bhikkuFeetPlusOne = hp_gear("Bhikku Gaiters +1", 13)  --Haste 4, MDB 3, Acc 24
gear.bhikkuFeetPlusTwo = hp_gear("Bhikku Gaiters +2", 33)  --Haste 4, Macc 50, MDB 6, Acc 50, Att 50
gear.bhikkuFeetPlusThree = hp_gear("Bhikku Gaiters +3", 43)  --Haste 4, Macc 60, MDB 7, Acc 60, Att 60

--MNK Empyrean (90-era) (Set: Augments "Kick Attacks")
gear.tantraHead = hp_gear("Tantra Crown", 0)  --SB 3
gear.tantraHeadPlusOne = hp_gear("Tantra Crown +1", 0)  --Haste 6, SB 8
gear.tantraHeadPlusTwo = hp_gear("Tantra Crown +2", 0)  --Haste 7, SB 10
gear.tantraBody = hp_gear("Tantra Cyclas", 0)  --Acc 4, Att 4
gear.tantraBodyPlusOne = hp_gear("Tantra Cyclas +1", 0)  --Acc 12, Att 12
gear.tantraBodyPlusTwo = hp_gear("Tantra Cyclas +2", 0)  --Acc 15, Att 15
gear.tantraHands = hp_gear("Tantra Gloves", 0)  --Acc 3
gear.tantraHandsPlusOne = hp_gear("Tantra Gloves +1", 0)  --Haste 2, Acc 8, hand Skill 5
gear.tantraHandsPlusTwo = hp_gear("Tantra Gloves +2", 0)  --Haste 3, Acc 10, hand Skill 7
gear.tantraLegs = hp_gear("Tantra Hose", 0)  --Acc 3, Att 3
gear.tantraLegsPlusOne = hp_gear("Tantra Hose +1", 0)  --Haste 5, Acc 7, Att 7
gear.tantraLegsPlusTwo = hp_gear("Tantra Hose +2", 0)  --STP 6, Haste 6, Acc 10, Att 10
gear.tantraFeet = hp_gear("Tantra Gaiters", 0)  --Acc 3
gear.tantraFeetPlusOne = hp_gear("Tantra Gaiters +1", 0)  --Acc 6
gear.tantraFeetPlusTwo = hp_gear("Tantra Gaiters +2", 0)  --Acc 8

--MNK Empyrean Reforged (REA Set: Augments "Kick Attacks")
gear.hesychastHead = hp_gear("Hes. Crown", 63)  --Haste 7, MDB 2, SB 9, Enmity -5
gear.hesychastHeadPlusOne = hp_gear("Hes. Crown +1", 82)  --Haste 8, MDB 4, SB 10, Enmity -6
gear.hesychastHeadPlusTwo = hp_gear("Hes. Crown +2", 92)  --WSD 5, Haste 8, Macc 27, MDB 5, Acc 27
gear.hesychastHeadPlusThree = hp_gear("Hes. Crown +3", 102)  --WSD 10, Haste 8, Macc 37, MDB 6, Acc 37
gear.hesychastHeadPlusFour = hp_gear("Hes. Crown +4", 112)  --WSD 12, Haste 8, Macc 42, MDB 7, Acc 42
gear.hesychastBody = hp_gear("Hes. Cyclas", 79)  --Regen 2, Haste 4, MDB 2
gear.hesychastBodyPlusOne = hp_gear("Hes. Cyclas +1", 102)  --Regen 3, Haste 4, MDB 4
gear.hesychastBodyPlusTwo = hp_gear("Hes. Cyclas +2", 112)  --Regen 4, Haste 4, Macc 30, MDB 5, Acc 30
gear.hesychastBodyPlusThree = hp_gear("Hes. Cyclas +3", 122)  --Regen 5, Haste 4, Macc 40, MDB 6, Acc 40
gear.hesychastBodyPlusFour = hp_gear("Hesy. Cyclas +4", 132)  --Regen 5, Haste 4, Macc 45, MDB 7, Acc 45
gear.hesychastHands = hp_gear("Hes. Gloves", 46)  --Haste 4, Acc 21, Att 21, SB 7
gear.hesychastHandsPlusOne = hp_gear("Hes. Gloves +1", 60)  --Haste 4, MDB 1, Acc 23, Att 23, SB 8
gear.hesychastHandsPlusTwo = hp_gear("Hes. Gloves +2", 70)  --STP 5, Haste 4, Macc 28, MDB 2, Acc 39
gear.hesychastHandsPlusThree = hp_gear("Hes. Gloves +3", 80)  --STP 8, Haste 4, Macc 38, MDB 3, Acc 49
gear.hesychastHandsPlusFour = hp_gear("Hesy. Gloves +4", 90)  --STP 8, Haste 4, Macc 43, MDB 4, Acc 54
gear.hesychastLegs = hp_gear("Hes. Hose", 76)  --Haste 6, MDB 1, SB 8
gear.hesychastLegsPlusOne = hp_gear("Hes. Hose +1", 96)  --Haste 6, MDB 3, SB 8
gear.hesychastLegsPlusTwo = hp_gear("Hes. Hose +2", 106)  --Haste 6, Macc 29, MDB 4, Acc 29, Att 49
gear.hesychastLegsPlusThree = hp_gear("Hes. Hose +3", 116)  --Haste 6, Macc 39, MDB 5, Acc 39, Att 64
gear.hesychastLegsPlusFour = hp_gear("Hesy. Hose +4", 126)  --Haste 6, Macc 44, MDB 6, Acc 44, Att 74
gear.hesychastFeet = hp_gear("Hes. Gaiters", 48)  --Haste 4, MDB 1
gear.hesychastFeetPlusOne = hp_gear("Hes. Gaiters +1", 64)  --Haste 4, MDB 3
gear.hesychastFeetPlusTwo = hp_gear("Hes. Gaiters +2", 74)  --Haste 4, Macc 26, MDB 4, Acc 26, Att 46
gear.hesychastFeetPlusThree = hp_gear("Hes. Gaiters +3", 84)  --Haste 4, Macc 36, MDB 5, Acc 36, Att 61
gear.hesychastFeetPlusFour = hp_gear("Hesy. Gaiters +4", 94)  --Haste 4, Macc 41, MDB 6, Acc 41, Att 71

--WHM Artifact (75-era)
gear.healerHead = mp_gear("Healer's Cap", 13)  --Enmity -1
gear.healerHeadPlusOne = mp_gear("Hlr. Cap +1", 28)  --Enmity -1
gear.healerBody = mp_gear("Healer's Bliaut", 15)  --Enmity -4, Enfeebling magic Skill 10
gear.healerBodyPlusOne = mp_gear("Hlr. Bliaut +1", 35)  --Enmity -4, Enfeebling magic Skill 12
gear.healerHands = mp_gear("Healer's Mitts", 10)  --Enmity -4, Healing magic Skill 15
gear.healerHandsPlusOne = mp_gear("Hlr. Mitts +1", 15)  --Enmity -4, Healing magic Skill 15
gear.healerLegs = mp_gear("Healer's Pantaln.", 15)  --Enmity -1, Divine magic Skill 15
gear.healerLegsPlusOne = mp_gear("Hlr. Pantaln. +1", 30)  --Enmity -2, Divine magic Skill 15
gear.healerFeet = mp_gear("Healer's Duckbills", 10)  --SIRD 20
gear.healerFeetPlusOne = mp_gear("Hlr. Duckbills +1", 15)  --SIRD 25

--WHM Artifact Reforged (Set: Increases Accuracy, Ranged Accuracy, and Magic Accuracy)
gear.theophanyHead = hp_gear("Theophany Cap", 17)  --Cure Pot 10, Cure FC 4, MDB 2, Enmity -4
gear.theophanyHeadPlusOne = hp_gear("Theo. Cap +1", 36)  --Cure Pot 10, Cure FC 5, Haste 6, MDB 5, Enmity -4
gear.theophanyHeadPlusTwo = hp_gear("Theophany Cap +2", 54)  --Cure Pot 11, Cure FC 6, Haste 6, Macc 37, MDB 6
gear.theophanyHeadPlusThree = hp_gear("Theophany Cap +3", 64)  --Cure Pot 12, Cure FC 7, Haste 6, Macc 47, MDB 7
gear.theophanyHeadPlusFour = hp_gear("Theo. Cap +4", 74)  --Cure Pot 12, Haste 6, Macc 57, MDB 8, Acc 57
gear.theophanyBody = hp_gear("Theo. Bliaut", 25)  --Cure Pot 6, Haste 2, MDB 3, Enmity -4, Enfeebling magic Skill 17
gear.theophanyBodyPlusOne = hp_gear("Theo. Bliaut +1", 54)  --Refresh 2, Cure Pot 7, Haste 3, MDB 6, Enmity -4
gear.theophanyBodyPlusTwo = hp_gear("Theo. Bliaut +2", 81)  --Refresh 2, Haste 3, Macc 40, MDB 7, Enmity -5
gear.theophanyBodyPlusFour = hp_gear("Theo. Bliaut +4", 101)  --Refresh 3, Haste 3, Macc 60, MDB 9, Acc 60
gear.theophanyHands = hp_gear("Theophany Mitts", 10)  --Haste 3, MDB 1, Enmity -4, Healing magic Skill 17
gear.theophanyHandsPlusOne = hp_gear("Theo. Mitts +1", 22)  --Haste 3, MDB 3, Enmity -5, Healing magic Skill 17
gear.theophanyHandsPlusTwo = hp_gear("Theophany Mitts +2", 33)  --Haste 3, Macc 38, MDB 4, Enmity -6, Healing magic Skill 19
gear.theophanyHandsPlusFour = hp_gear("Theo. Mitts +4", 53)  --Haste 3, Macc 58, MDB 6, Acc 58, Enmity -7
gear.theophanyLegs = hp_gear("Theo. Pantaloons", 20)  --Haste 4, MDB 3, Enmity -4, Divine magic Skill 17
gear.theophanyLegsPlusOne = hp_gear("Theo. Pant. +1", 43)  --Haste 5, MDB 6, Enmity -4, Divine magic Skill 17
gear.theophanyLegsPlusTwo = hp_gear("Th. Pantaloons +2", 64)  --Haste 5, Macc 39, MDB 7, Enmity -5, Divine magic Skill 19
gear.theophanyLegsPlusThree = hp_gear("Th. Pant. +3", 74)  --Haste 5, Macc 49, MDB 8, Enmity -6, Divine magic Skill 21
gear.theophanyFeet = hp_gear("Theo. Duckbills", 36)  --SIRD 25, Haste 3, MDB 2, Enhancing magic Skill 15, Enfeebling magic Skill 15
gear.theophanyFeetPlusOne = hp_gear("Theo. Duckbills +1", 43)  --SIRD 25, Haste 3, MDB 5, Enhancing magic Skill 17, Enfeebling magic Skill 17
gear.theophanyFeetPlusTwo = hp_gear("Theo. Duckbills +2", 64)  --SIRD 27, Haste 3, Macc 36, MDB 6, Enhancing magic Skill 19
gear.theophanyFeetPlusFour = hp_gear("Theo. Duckbills +4", 84)  --Haste 3, Macc 56, MDB 8, Acc 56, Enhancing magic Skill 22

--WHM Relic (75-era)
gear.clericHead = mp_gear("Cleric's Cap", 25)  --Enmity -4
gear.clericHeadPlusOne = mp_gear("Clr. Cap +1", 25)  --Enmity -5
gear.clericHeadPlusTwo = mp_gear("Clr. Cap +2", 35)  --Cure FC 10, Enmity -7
gear.clericBody = mp_gear("Cleric's Bliaut", 24)  --Enmity -2
gear.clericBodyPlusOne = mp_gear("Clr. Bliaut +1", 29)  --Enmity -3
gear.clericBodyPlusTwo = mp_gear("Clr. Bliaut +2", 41)  --Enmity -5
gear.clericHands = mp_gear("Cleric's Mitts", 20)  --Enmity -3, Enfeebling magic Skill 15
gear.clericHandsPlusOne = hp_gear("Clr. Mitts +1", 20)  --Enmity -4, Enfeebling magic Skill 15
gear.clericHandsPlusTwo = hp_gear("Clr. Mitts +2", 28)  --Enmity -6, Divine magic Skill 18, Enfeebling magic Skill 18
gear.clericLegs = mp_gear("Cleric's Pantaln.", 17)  --Enmity -2, Healing magic Skill 15
gear.clericLegsPlusOne = mp_gear("Clr. Pantaln. +1", 17)  --Enmity -3, Healing magic Skill 15
gear.clericLegsPlusTwo = hp_gear("Clr. Pantaln. +2", 24)  --Enmity -5, Healing magic Skill 18, Enhancing magic Skill 18
gear.clericFeet = mp_gear("Cleric's Duckbills", 18)  --Enmity -1, Enhancing magic Skill 10
gear.clericFeetPlusOne = mp_gear("Clr. Duckbills +1", 18)  --Enmity -2, Enhancing magic Skill 10
gear.clericFeetPlusTwo = hp_gear("Clr. Duckbills +2", 25)  --Enmity -4, Enhancing magic Skill 12, Enfeebling magic Skill 12

--WHM Relic Reforged (REA Set: Augments elemental resistance spells)
gear.pietyHead = hp_gear("Piety Cap", 17)  --Cure FC 12, Haste 5, MDB 2, Enmity -7
gear.pietyHeadPlusOne = hp_gear("Piety Cap +1", 36)  --Cure FC 13, Haste 6, MDB 5, Enmity -8
gear.pietyHeadPlusTwo = hp_gear("Piety Cap +2", 46)  --Cure FC 14, Haste 6, Macc 27, MDB 6, Acc 27
gear.pietyHeadPlusThree = hp_gear("Piety Cap +3", 56)  --Cure FC 15, Haste 6, Macc 37, MDB 7, Acc 37
gear.pietyHeadPlusFour = hp_gear("Piety Cap +4", 66)  --Haste 6, Macc 42, MDB 8, Acc 42, Att 72
gear.pietyBody = hp_gear("Piety Bliaut", 25)  --Refresh 2, Haste 2, MDB 3, Enmity -5
gear.pietyHands = hp_gear("Piety Mitts", 40)  --Haste 3, MDB 1, Enmity -6, Divine magic Skill 20, Enfeebling magic Skill 20
gear.pietyHandsPlusOne = hp_gear("Piety Mitts +1", 52)  --Haste 3, MDB 3, Enmity -7, Divine magic Skill 22, Enfeebling magic Skill 22
gear.pietyHandsPlusTwo = hp_gear("Piety Mitts +2", 62)  --Haste 3, Macc 28, MDB 4, Acc 28, Att 48
gear.pietyHandsPlusThree = hp_gear("Piety Mitts +3", 72)  --Haste 3, Macc 38, MDB 5, Acc 38, Att 63
gear.pietyHandsPlusFour = hp_gear("Piety Mitts +4", 82)  --Haste 3, Macc 43, MDB 6, Acc 43, Att 73
gear.pietyLegs = hp_gear("Piety Pantaloons", 50)  --Haste 4, MDB 3, Enmity -5, Healing magic Skill 20, Enhancing magic Skill 20
gear.pietyLegsPlusOne = hp_gear("Piety Pantaln. +1", 73)  --Haste 5, MDB 6, Enmity -6, Healing magic Skill 22, Enhancing magic Skill 22
gear.pietyLegsPlusTwo = hp_gear("Piety Pantaln. +2", 83)  --Haste 5, Macc 29, MDB 7, Acc 29, Att 49
gear.pietyLegsPlusThree = hp_gear("Piety Pantaln. +3", 93)  --Haste 5, Macc 39, MDB 8, Acc 39, Att 64
gear.pietyLegsPlusFour = hp_gear("Piety Panta. +4", 103)  --Haste 5, Macc 44, MDB 9, Acc 44, Att 74
gear.pietyFeet = hp_gear("Piety Duckbills", 31)  --Cure Pot 8, Haste 3, MDB 2, Enmity -4, Enhancing magic Skill 15
gear.pietyFeetPlusOne = hp_gear("Piety Duckbills +1", 38)  --Cure Pot 10, Haste 3, MDB 5, Enmity -5, Enhancing magic Skill 17
gear.pietyFeetPlusTwo = hp_gear("Piety Duckbills +2", 48)  --Cure Pot 12, Haste 3, Macc 26, MDB 6, Acc 26
gear.pietyFeetPlusThree = hp_gear("Piety Duckbills +3", 58)  --Cure Pot 14, Haste 3, Macc 36, MDB 7, Acc 36
gear.pietyFeetPlusFour = hp_gear("Piety Duckbills +4", 68)  --Cure Pot 14, Haste 3, Macc 41, MDB 8, Acc 41

--WHM Empyrean (90-era) (Set: Augments elemental resistance spells)
gear.orisonHead = mp_gear("Orison Cap", 15)  --MND 3
gear.orisonHeadPlusOne = mp_gear("Orison Cap +1", 35)  --Cure Pot 7
gear.orisonHeadPlusTwo = mp_gear("Orison Cap +2", 50)  --Cure Pot 10
gear.orisonBody = hp_gear("Orison Bliaut", 25)
gear.orisonBodyPlusOne = hp_gear("Orison Bliaut +1", 35)  --Healing magic Skill 15
gear.orisonBodyPlusTwo = hp_gear("Orison Bliaut +2", 45)  --Healing magic Skill 20
gear.orisonHands = hp_gear("Orison Mitts", 10)  --Enmity -2
gear.orisonHandsPlusOne = hp_gear("Orison Mitts +1", 20)  --Enmity -4
gear.orisonHandsPlusTwo = hp_gear("Orison Mitts +2", 25)  --Enmity -8
gear.orisonLegs = hp_gear("Orison Pantaloons", 0)  --MND 2
gear.orisonLegsPlusOne = hp_gear("Orsn. Pantaln. +1", 0)  --MND 5
gear.orisonLegsPlusTwo = hp_gear("Orsn. Pantaln. +2", 0)  --MND 7
gear.orisonFeet = hp_gear("Orison Duckbills", 10)  --MND 3
gear.orisonFeetPlusOne = hp_gear("Orsn. Duckbills +1", 20)  --Enhancing magic Skill 15
gear.orisonFeetPlusTwo = hp_gear("Orsn. Duckbills +2", 30)  --Enhancing magic Skill 20

--WHM Empyrean Reforged (REA Set: Augments elemental resistance spells)
gear.ebersHead = hp_gear("Ebers Cap", 16)  --Cure Pot 13, Haste 5, MDB 3
gear.ebersBody = hp_gear("Ebers Bliaut", 69)  --Refresh 2, Haste 2, MDB 3, Healing magic Skill 22
gear.ebersHands = hp_gear("Ebers Mitts", 34)  --Haste 3, MDB 1, Enmity -9
gear.ebersLegs = hp_gear("Ebers Pantaloons", 19)  --Haste 4, MDB 3
gear.ebersFeet = hp_gear("Ebers Duckbills", 45)  --Haste 3, MDB 3, Enhancing magic Skill 22

--BLM Artifact (75-era)
gear.wizardHead = mp_gear("Wizard's Petasos", 25)  --Enmity -4
gear.wizardHeadPlusOne = mp_gear("Wzd. Petasos +1", 30)  --Enmity -4
gear.wizardBody = mp_gear("Wizard's Coat", 16)  --Enmity -3, Enfeebling magic Skill 10
gear.wizardBodyPlusOne = mp_gear("Wzd. Coat +1", 36)  --Enmity -5, Enfeebling magic Skill 12
gear.wizardHands = mp_gear("Wizard's Gloves", 12)  --Enmity -1, Elemental magic Skill 15
gear.wizardHandsPlusOne = mp_gear("Wzd. Gloves +1", 17)  --Enmity -2, Elemental magic Skill 15
gear.wizardLegs = mp_gear("Wizard's Tonban", 14)  --Enmity -1, Dark magic Skill 15
gear.wizardLegsPlusOne = mp_gear("Wzd. Tonban +1", 19)  --Enmity -2, Dark magic Skill 15
gear.wizardFeet = mp_gear("Wizard's Sabots", 10)  --SIRD 20, Enmity -1
gear.wizardFeetPlusOne = mp_gear("Wzd. Sabots +1", 15)  --SIRD 20

--BLM Artifact Reforged (Set: Increases Accuracy, Ranged Accuracy, and Magic Accuracy)
gear.spaekonaHead = hp_gear("Spae. Petasos", 17)  --Haste 5, MAB 13, MDB 2, ConMP 3, Enmity -4
gear.spaekonaHeadPlusOne = hp_gear("Spae. Petasos +1", 36)  --Haste 6, MAB 13, MDB 5, ConMP 4, Enmity -4
gear.spaekonaHeadPlusTwo = hp_gear("Spae. Petasos +2", 54)  --Haste 6, MAB 18, Macc 37, MDmg 32, MDB 5
gear.spaekonaHeadPlusThree = hp_gear("Spae. Petasos +3", 64)  --Haste 6, MAB 23, Macc 47, MDmg 42, MDB 6
gear.spaekonaHeadPlusFour = hp_gear("Spae. Petasos +4", 74)  --Haste 6, Macc 57, MDmg 44, MDB 7, Acc 57
gear.spaekonaBody = hp_gear("Spaekona's Coat", 25)  --Haste 2, Macc 10, MDB 3, Enmity -6, Enfeebling magic Skill 15
gear.spaekonaBodyPlusOne = hp_gear("Spae. Coat +1", 54)  --Haste 3, Macc 10, MDB 6, Enmity -7, Enfeebling magic Skill 15
gear.spaekonaBodyPlusTwo = hp_gear("Spaekona's Coat +2", 81)  --Haste 3, Macc 45, MDmg 38, MDB 6, Enmity -8
gear.spaekonaBodyPlusThree = hp_gear("Spaekona's Coat +3", 91)  --Haste 3, Macc 55, MDmg 48, MDB 7, Enmity -9
gear.spaekonaBodyPlusFour = hp_gear("Spae. Coat +4", 101)  --Haste 3, Macc 65, MDmg 50, MDB 8, Acc 65
gear.spaekonaHands = hp_gear("Spaekona's Gloves", 10)  --Haste 3, Macc 8, MDB 1, Elemental magic Skill 17
gear.spaekonaHandsPlusOne = hp_gear("Spae. Gloves +1", 22)  --Haste 3, Macc 8, MDB 3, Elemental magic Skill 17
gear.spaekonaHandsPlusTwo = hp_gear("Spae. Gloves +2", 33)  --Haste 3, Macc 42, MDmg 34, MDB 3, Elemental magic Skill 19
gear.spaekonaHandsPlusThree = hp_gear("Spae. Gloves +3", 43)  --Haste 3, Macc 52, MDmg 44, MDB 4, Elemental magic Skill 21
gear.spaekonaHandsPlusFour = hp_gear("Spae. Gloves +4", 53)  --Haste 3, Macc 62, MDmg 46, MDB 5, Acc 62
gear.spaekonaLegs = hp_gear("Spaekona's Tonban", 20)  --Haste 4, MAB 15, MDB 3, Enmity -4, Dark magic Skill 17
gear.spaekonaLegsPlusOne = hp_gear("Spae. Tonban +1", 43)  --Haste 5, MAB 20, MDB 6, Enmity -4, Dark magic Skill 17
gear.spaekonaLegsPlusTwo = hp_gear("Spae. Tonban +2", 64)  --Haste 5, MAB 25, Macc 39, MDmg 36, MDB 6
gear.spaekonaLegsPlusThree = hp_gear("Spae. Tonban +3", 74)  --Haste 5, MAB 30, Macc 49, MDmg 46, MDB 7
gear.spaekonaLegsPlusFour = hp_gear("Spae. Tonban +4", 84)  --Haste 5, MAB 32, Macc 59, MDmg 48, MDB 8
gear.spaekonaFeet = hp_gear("Spaekona's Sabots", 14)  --Haste 3, MAB 13, Macc 13, MDB 2
gear.spaekonaFeetPlusOne = hp_gear("Spae. Sabots +1", 21)  --Haste 3, MAB 16, Macc 16, MDB 5
gear.spaekonaFeetPlusTwo = hp_gear("Spae. Sabots +2", 31)  --Haste 3, MAB 21, Macc 44, MDmg 30, MBD 5
gear.spaekonaFeetPlusThree = hp_gear("Spae. Sabots +3", 41)  --Haste 3, MAB 26, Macc 54, MDmg 40, MBD 10
gear.spaekonaFeetPlusFour = hp_gear("Spae. Sabots +4", 51)  --Haste 3, MAB 28, Macc 64, MDmg 42, MBD 10

--BLM Relic (75-era)
gear.sorcererHead = mp_gear("Sorcerer's Petas.", 23)  --Enmity -2, Enfeebling magic Skill 5, Elemental magic Skill 10
gear.sorcererHeadPlusOne = mp_gear("Src. Petasos +1", 29)  --Enmity -3, Enfeebling magic Skill 5, Elemental magic Skill 10
gear.sorcererHeadPlusTwo = mp_gear("Src. Petasos +2", 41)  --MAB 5, Enmity -5, Elemental magic Skill 12
gear.sorcererBody = mp_gear("Sorcerer's Coat", 12)  --Enmity -2, Elemental magic Skill 5
gear.sorcererBodyPlusOne = hp_gear("Src. Coat +1", 12)  --Enmity -2, Elemental magic Skill 7
gear.sorcererBodyPlusTwo = hp_gear("Src. Coat +2", 0)  --Enmity -4, Elemental magic Skill 9
gear.sorcererHands = mp_gear("Sorcerer's Gloves", 24)  --Enmity -2, Dark magic Skill 10
gear.sorcererHandsPlusOne = mp_gear("Src. Gloves +1", 24)  --Enmity -3, Dark magic Skill 12
gear.sorcererHandsPlusTwo = mp_gear("Src. Gloves +2", 34)  --Enmity -5, Elemental magic Skill 15, Dark magic Skill 15
gear.sorcererLegs = mp_gear("Sorcerer's Tonban", 13)  --Enmity -2
gear.sorcererLegsPlusOne = mp_gear("Src. Tonban +1", 20)  --Enmity -3
gear.sorcererLegsPlusTwo = mp_gear("Src. Tonban +2", 28)  --MAB 5, Enmity -5
gear.sorcererFeet = mp_gear("Sorcerer's Sabots", 18)  --ConMP 5, Enmity -1
gear.sorcererFeetPlusOne = mp_gear("Src. Sabots +1", 18)  --ConMP 5, Enmity -2
gear.sorcererFeetPlusTwo = mp_gear("Src. Sabots +2", 25)  --Enmity -4, Elemental magic Skill 7

--BLM Relic Reforged (REA Set: Augments "Conserve MP")
gear.archmageHead = hp_gear("Arch. Petasos", 17)  --Haste 5, MAB 10, Macc 10, MDB 2, Enmity -5
gear.archmageHeadPlusOne = hp_gear("Arch. Petasos +1", 36)  --Haste 6, MAB 12, Macc 12, MDB 5, Enmity -5
gear.archmageHeadPlusTwo = hp_gear("Arch. Petasos +2", 46)  --Haste 6, MAB 48, Macc 33, MDB 6, Acc 27
gear.archmageHeadPlusThree = hp_gear("Arch. Petasos +3", 56)  --Haste 6, MAB 55, Macc 43, MDB 7, Acc 37
gear.archmageHeadPlusFour = hp_gear("Arch. Petasos +4", 66)  --Haste 6, MAB 58, Macc 48, MDB 8, Acc 42
gear.archmageBody = hp_gear("Arch. Coat", 25)  --Refresh 2, Haste 2, MDB 3, Enmity -7, Elemental magic Skill 15
gear.archmageBodyPlusOne = hp_gear("Arch. Coat +1", 54)  --Refresh 2, Haste 3, MDB 6, Enmity -10, Elemental magic Skill 20
gear.archmageBodyPlusTwo = hp_gear("Arch. Coat +2", 64)  --Refresh 2, Haste 3, MAB 45, Macc 30, MDB 7
gear.archmageBodyPlusThree = hp_gear("Arch. Coat +3", 74)  --Refresh 3, Haste 3, MAB 52, Macc 40, MDB 8
gear.archmageBodyPlusFour = hp_gear("Arch. Coat +4", 84)  --Refresh 3, Haste 3, MAB 55, Macc 45, MDB 9
gear.archmageHands = hp_gear("Arch. Gloves", 10)  --Haste 3, MBD 13, MDB 1, Enmity -5, Elemental magic Skill 17
gear.archmageHandsPlusOne = hp_gear("Arch. Gloves +1", 22)  --Haste 3, MBD 16, MDB 3, Enmity -5, Elemental magic Skill 19
gear.archmageHandsPlusTwo = hp_gear("Arch. Gloves +2", 32)  --Haste 3, MAB 43, Macc 28, MBD 18, MDB 4
gear.archmageHandsPlusThree = hp_gear("Arch. Gloves +3", 42)  --Haste 3, MAB 50, Macc 38, MBD 20, MDB 5
gear.archmageHandsPlusFour = hp_gear("Arch. Gloves +4", 52)  --Haste 3, MAB 53, Macc 43, MBD 20, MDB 6
gear.archmageLegs = hp_gear("Arch. Tonban", 20)  --Haste 4, MAB 12, Macc 12, MDB 3, Enmity -5
gear.archmageLegsPlusOne = hp_gear("Arch. Tonban +1", 43)  --Haste 5, MAB 14, Macc 14, MDB 6, Enmity -5
gear.archmageLegsPlusTwo = hp_gear("Arch. Tonban +2", 53)  --Haste 5, MAB 51, Macc 36, MDB 7, Acc 29
gear.archmageLegsPlusThree = hp_gear("Arch. Tonban +3", 63)  --Haste 5, MAB 58, Macc 46, MDB 8, Acc 39
gear.archmageLegsPlusFour = hp_gear("Arch. Tonban +4", 73)  --Haste 5, MAB 61, Macc 51, MDB 9, Acc 44
gear.archmageFeet = hp_gear("Arch. Sabots", 6)  --Haste 3, MAB 10, Macc 10, MDB 2, Enmity -4
gear.archmageFeetPlusOne = hp_gear("Arch. Sabots +1", 13)  --Haste 3, MAB 12, Macc 12, MDB 5, Enmity -4
gear.archmageFeetPlusTwo = hp_gear("Arch. Sabots +2", 23)  --Haste 3, MAB 47, Macc 32, MDB 6, Acc 26
gear.archmageFeetPlusThree = hp_gear("Arch. Sabots +3", 33)  --Haste 3, MAB 54, Macc 42, MDB 7, Acc 36
gear.archmageFeetPlusFour = hp_gear("Arch. Sabots +4", 43)  --Haste 3, MAB 57, Macc 47, MDB 8, Acc 41

--BLM Empyrean (90-era) (Set: Augments "Conserve MP")
gear.goetiaHead = hp_gear("Goetia Petasos", 0)  --Enmity -2
gear.goetiaHeadPlusOne = hp_gear("Goetia Petasos +1", 0)  --Enmity -4, Elemental magic Skill 10
gear.goetiaHeadPlusTwo = hp_gear("Goetia Petasos +2", 0)  --Enmity -6, Elemental magic Skill 15
gear.goetiaBody = mp_gear("Goetia Coat", 15)  --MAB 2
gear.goetiaBodyPlusOne = mp_gear("Goetia Coat +1", 35)  --MAB 8, Macc 8
gear.goetiaBodyPlusTwo = mp_gear("Goetia Coat +2", 45)  --MAB 11, Macc 11
gear.goetiaHands = hp_gear("Goetia Gloves", 0)  --MAB 2
gear.goetiaHandsPlusOne = hp_gear("Goetia Gloves +1", 0)  --MAB 6
gear.goetiaHandsPlusTwo = hp_gear("Goetia Gloves +2", 0)  --MAB 8
gear.goetiaLegs = mp_gear("Goetia Chausses", 20)  --MAB 1
gear.goetiaLegsPlusOne = mp_gear("Goet. Chausses +1", 40)  --MAB 5, Macc 5
gear.goetiaLegsPlusTwo = mp_gear("Goet. Chausses +2", 55)  --MAB 7, Macc 7
gear.goetiaFeet = hp_gear("Goetia Sabots", 0)  --Enmity -2
gear.goetiaFeetPlusOne = hp_gear("Goetia Sabots +1", 0)  --Enmity -6, Dark magic Skill 10
gear.goetiaFeetPlusTwo = hp_gear("Goetia Sabots +2", 0)  --Enmity -10, Dark magic Skill 15

--BLM Empyrean Reforged (REA Set: Augments "Conserve MP")
gear.wicceHead = hp_gear("Wicce Petasos", 15)  --Haste 5, MDB 3, Enmity -7, Elemental magic Skill 15
gear.wicceHeadPlusOne = hp_gear("Wicce Petasos +1", 31)  --Haste 6, MDB 6, Enmity -8, Elemental magic Skill 25
gear.wicceHeadPlusTwo = hp_gear("Wicce Petasos +2", 51)  --Haste 6, MAB 46, Macc 51, MDmg 21, MDB 9
gear.wicceHeadPlusThree = hp_gear("Wicce Petasos +3", 61)  --Haste 6, MAB 51, Macc 61, MDmg 31, MDB 10
gear.wicceBody = hp_gear("Wicce Coat", 23)  --Refresh 2, Haste 2, MAB 14, Macc 14, MDB 3
gear.wicceBodyPlusOne = hp_gear("Wicce Coat +1", 50)  --Refresh 2, Haste 3, MAB 24, Macc 24, MDB 7
gear.wicceBodyPlusTwo = hp_gear("Wicce Coat +2", 70)  --Refresh 3, Haste 3, MAB 54, Macc 54, MDmg 24
gear.wicceBodyPlusThree = hp_gear("Wicce Coat +3", 80)  --Refresh 4, Haste 3, MAB 59, Macc 64, MDmg 34
gear.wicceHands = hp_gear("Wicce Gloves", 8)  --Haste 3, MAB 26, MDB 1
gear.wicceHandsPlusOne = hp_gear("Wicce Gloves +1", 18)  --Haste 3, MAB 36, MDB 3
gear.wicceHandsPlusTwo = hp_gear("Wicce Gloves +2", 38)  --Haste 3, MAB 52, Macc 52, MDmg 22, MDB 6
gear.wicceHandsPlusThree = hp_gear("Wicce Gloves +3", 48)  --Haste 3, MAB 57, Macc 62, MDmg 32, MDB 7
gear.wicceLegs = hp_gear("Wicce Chausses", 18)  --Haste 4, MAB 14, Macc 14, MDB 3
gear.wicceLegsPlusOne = hp_gear("Wicce Chausses +1", 38)  --Haste 5, MAB 24, Macc 24, MDB 6
gear.wicceLegsPlusTwo = hp_gear("Wicce Chausses +2", 58)  --Haste 5, MAB 53, Macc 53, MDmg 23, MBD 10
gear.wicceLegsPlusThree = hp_gear("Wicce Chausses +3", 68)  --Haste 5, MAB 58, Macc 63, MDmg 33, MBD 15
gear.wicceFeet = hp_gear("Wicce Sabots", 4)  --Haste 3, MDB 3, Enmity -12, Dark magic Skill 20
gear.wicceFeetPlusOne = hp_gear("Wicce Sabots +1", 9)  --Haste 3, MDB 6, Enmity -14, Dark magic Skill 25
gear.wicceFeetPlusTwo = hp_gear("Wicce Sabots +2", 29)  --Haste 3, MAB 45, Macc 50, MDmg 20, MDB 9
gear.wicceFeetPlusThree = hp_gear("Wicce Sabots +3", 39)  --Haste 3, MAB 50, Macc 60, MDmg 30, MDB 10

--RDM Artifact (75-era)
gear.warlockHead = mp_gear("Warlock's Chapeau", 20)  --Elemental magic Skill 10
gear.warlockHeadPlusOne = mp_gear("Wlk. Chapeau +1", 25)  --Elemental magic Skill 10
gear.warlockBody = mp_gear("Warlock's Tabard", 14)  --SIRD 10, Enfeebling magic Skill 15
gear.warlockBodyPlusOne = mp_gear("Wlk. Tabard +1", 34)  --SIRD 12, Enfeebling magic Skill 15
gear.warlockHands = mp_gear("Warlock's Gloves", 12)  --Parrying Skill 10
gear.warlockHandsPlusOne = mp_gear("Wlk. Gloves +1", 17)  --Parrying Skill 15
gear.warlockLegs = mp_gear("Warlock's Tights", 13)  --Healing magic Skill 10, Enhancing magic Skill 15
gear.warlockLegsPlusOne = mp_gear("Wlk. Tights +1", 18)  --Healing magic Skill 10, Enhancing magic Skill 15
gear.warlockFeet = mp_gear("Warlock's Boots", 11)  --Shield Skill 10
gear.warlockFeetPlusOne = mp_gear("Wlk. Boots +1", 16)  --Shield Skill 10

--RDM Artifact Reforged (Set: Increases Accuracy, Ranged Accuracy, and Magic Accuracy)
gear.atrophyHead = hp_gear("Atrophy Chapeau", 17)  --Haste 5, Macc 15, MDB 2, Elemental magic Skill 13
gear.atrophyHeadPlusOne = hp_gear("Atro. Chapeau +1", 36)  --FC 12, Haste 6, Macc 15, MDB 5, Elemental magic Skill 13
gear.atrophyHeadPlusTwo = hp_gear("Atro. Chapeau +2", 54)  --FC 14, Haste 6, Macc 44, MBD 5, MDB 6
gear.atrophyHeadPlusFour = hp_gear("Atro. Chapeau +4", 74)  --FC 16, Haste 6, Macc 64, MBD 10, MDB 8
gear.atrophyBody = hp_gear("Atrophy Tabard", 25)  --Haste 2, MAB 7, Macc 7, MDB 3, Enfeebling magic Skill 17
gear.atrophyBodyPlusOne = hp_gear("Atrophy Tabard +1", 54)  --Refresh 2, Haste 3, MAB 10, Macc 10, MDB 6
gear.atrophyBodyPlusTwo = hp_gear("Atrophy Tabard +2", 81)  --Refresh 2, Haste 3, MAB 15, Macc 45, MDB 7
gear.atrophyBodyPlusThree = hp_gear("Atrophy Tabard +3", 91)  --Refresh 3, Haste 3, MAB 20, Macc 55, MDB 8
gear.atrophyHands = hp_gear("Atrophy Gloves", 10)  --Haste 3, MDB 1, Acc 10, Att 10, Parrying Skill 17
gear.atrophyHandsPlusOne = hp_gear("Atrophy Gloves +1", 22)  --Haste 3, MDB 3, Acc 10, Att 10, Parrying Skill 17
gear.atrophyHandsPlusTwo = hp_gear("Atrophy Gloves +2", 33)  --WSD 3, Haste 3, MDB 4, Acc 43, Att 20
gear.atrophyLegs = hp_gear("Atrophy Tights", 20)  --Cure Pot 9, Haste 4, MDB 3, Healing magic Skill 13, Enhancing magic Skill 17
gear.atrophyLegsPlusOne = hp_gear("Atrophy Tights +1", 43)  --Cure Pot 10, Haste 5, MDB 6, Healing magic Skill 13, Enhancing magic Skill 17
gear.atrophyLegsPlusTwo = hp_gear("Atrophy Tights +2", 64)  --Cure Pot 11, Haste 5, MDB 7, Acc 39, Healing magic Skill 15
gear.atrophyLegsPlusFour = hp_gear("Atro. Tights +4", 84)  --Cure Pot 12, Haste 5, Macc 59, MDB 9, Acc 59
gear.atrophyFeet = hp_gear("Atrophy Boots", 41)  --Haste 4, MDB 2, Acc 15, Shield Skill 13
gear.atrophyFeetPlusOne = hp_gear("Atrophy Boots +1", 48)  --Haste 4, MDB 5, Acc 20, Shield Skill 13
gear.atrophyFeetPlusTwo = hp_gear("Atro. Boots +2", 72)  --Haste 4, MDB 6, Acc 46, Shield Skill 15
gear.atrophyFeetPlusThree = hp_gear("Atro. Boots +3", 82)  --Haste 4, MDB 7, Acc 56, Shield Skill 17
gear.atrophyFeetPlusFour = hp_gear("Atro. Boots +4", 92)  --Haste 4, Macc 66, MDB 8, Acc 66, Shield Skill 18

--RDM Relic (75-era)
gear.duelistHead = mp_gear("Duelist's Chapeau", 14)  --Enfeebling magic Skill 15
gear.duelistHeadPlusOne = hp_gear("Dls. Chapeau +1", 14)  --Enfeebling magic Skill 15
gear.duelistHeadPlusTwo = hp_gear("Dls. Chapeau +2", 20)  --Enfeebling magic Skill 18
gear.duelistBodyPlusOne = mp_gear("Dls. Tabard +1", 30)  --Healing magic Skill 12
gear.duelistBodyPlusTwo = mp_gear("Dls. Tabard +2", 42)  --Healing magic Skill 15, Enhancing magic Skill 15
gear.duelistHands = mp_gear("Duelist's Gloves", 18)  --MDB 2, Enhancing magic Skill 15
gear.duelistHandsPlusOne = mp_gear("Dls. Gloves +1", 23)  --MDB 2, Enhancing magic Skill 15
gear.duelistHandsPlusTwo = mp_gear("Dls. Gloves +2", 32)  --MDB 4, Enhancing magic Skill 18
gear.duelistLegs = mp_gear("Duelist's Tights", 16)  --Elemental magic Skill 10
gear.duelistLegsPlusOne = mp_gear("Dls. Tights +1", 16)  --Elemental magic Skill 12
gear.duelistLegsPlusTwo = mp_gear("Dls. Tights +2", 22)  --Elemental magic Skill 15
gear.duelistFeet = mp_gear("Duelist's Boots", 15)  --MAB 4, Evasion Skill 5
gear.duelistFeetPlusOne = mp_gear("Dls. Boots +1", 15)  --MAB 5, Evasion Skill 5
gear.duelistFeetPlusTwo = mp_gear("Dls. Boots +2", 21)  --MAB 7, Macc 4

--RDM Relic Reforged (REA Set: Augments "Composure")
gear.vitiationHead = hp_gear("Vitiation Chapeau", 37)  --Refresh 2, Haste 5, MDB 2, Enfeebling magic Skill 20
gear.vitiationHeadPlusOne = hp_gear("Viti. Chapeau +1", 61)  --Refresh 2, Haste 6, MDB 5, Enfeebling magic Skill 22
gear.vitiationHeadPlusTwo = hp_gear("Viti. Chapeau +2", 71)  --Refresh 2, WSD 3, Haste 6, Macc 27, MDB 6
gear.vitiationHeadPlusThree = hp_gear("Viti. Chapeau +3", 81)  --Refresh 3, WSD 6, Haste 6, Macc 37, MDB 7
gear.vitiationHeadPlusFour = hp_gear("Viti. Chapeau +4", 91)  --Refresh 3, WSD 9, Haste 6, Macc 42, MDB 8
gear.vitiationBody = hp_gear("Vitiation Tabard", 25)  --FC 12, Haste 2, MDB 3, Healing magic Skill 17, Enhancing magic Skill 17
gear.vitiationBodyPlusOne = hp_gear("Viti. Tabard +1", 54)  --FC 13, Haste 3, MDB 6, Healing magic Skill 19, Enhancing magic Skill 19
gear.vitiationBodyPlusTwo = hp_gear("Viti. Tabard +2", 64)  --FC 14, Haste 3, Macc 30, MDB 7, Acc 30
gear.vitiationBodyPlusThree = hp_gear("Viti. Tabard +3", 74)  --FC 15, Haste 3, Macc 40, MDB 8, Acc 40
gear.vitiationBodyPlusFour = hp_gear("Viti. Tabard +4", 84)  --FC 15, Haste 3, Macc 45, MDB 9, Acc 45
gear.vitiationHands = hp_gear("Vitiation Gloves", 10)  --Haste 3, MDB 4, Enhancing magic Skill 18
gear.vitiationHandsPlusOne = hp_gear("Viti. Gloves +1", 22)  --Haste 3, MDB 6, Enhancing magic Skill 20
gear.vitiationHandsPlusTwo = hp_gear("Viti. Gloves +2", 32)  --Haste 3, Macc 28, MDB 7, Acc 28, Att 48
gear.vitiationHandsPlusThree = hp_gear("Viti. Gloves +3", 42)  --Haste 3, Macc 38, MDB 8, Acc 38, Att 63
gear.vitiationHandsPlusFour = hp_gear("Viti. Gloves +4", 52)  --Haste 3, Macc 43, MDB 9, Acc 43, Att 73
gear.vitiationLegs = hp_gear("Vitiation Tights", 20)  --Haste 4, MDB 3, Elemental magic Skill 17
gear.vitiationLegsPlusOne = hp_gear("Viti. Tights +1", 43)  --Haste 5, MDB 6, Elemental magic Skill 19
gear.vitiationLegsPlusTwo = hp_gear("Viti. Tights +2", 53)  --Haste 5, Macc 29, MDB 7, Acc 29, Att 49
gear.vitiationLegsPlusThree = hp_gear("Viti. Tights +3", 63)  --Haste 5, Macc 39, MDB 8, Acc 39, Att 64
gear.vitiationLegsPlusFour = hp_gear("Viti. Tights +4", 73)  --Haste 5, Macc 44, MDB 9, Acc 44, Att 74
gear.vitiationFeet = hp_gear("Vitiation Boots", 6)  --Haste 3, MAB 13, Macc 13, MDB 2, Enfeebling magic Skill 10
gear.vitiationFeetPlusOne = hp_gear("Vitiation Boots +1", 13)  --Haste 3, MAB 15, Macc 15, MDB 5, Enfeebling magic Skill 12
gear.vitiationFeetPlusTwo = hp_gear("Vitiation Boots +2", 23)  --Haste 3, MAB 48, Macc 33, MDB 6, Acc 26
gear.vitiationFeetPlusThree = hp_gear("Vitiation Boots +3", 33)  --Haste 3, MAB 55, Macc 43, MDB 7, Acc 36
gear.vitiationFeetPlusFour = hp_gear("Viti. Boots +4", 43)  --Haste 3, MAB 58, Macc 48, MDB 8, Acc 41

--RDM Empyrean (90-era) (Set: Augments "Composure")
gear.estoqueurHead = mp_gear("Estq. Chappel", 10)  --INT 2, MND 2
gear.estoqueurHeadPlusOne = mp_gear("Estq. Chappel +1", 25)  --MAB 5, Macc 5
gear.estoqueurHeadPlusTwo = mp_gear("Estq. Chappel +2", 40)  --MAB 7, Macc 7
gear.estoqueurBody = hp_gear("Estoqueur's Sayon", 0)  --INT 4, MND 4
gear.estoqueurBodyPlusOne = hp_gear("Estq. Sayon +1", 0)  --Macc 9
gear.estoqueurBodyPlusTwo = hp_gear("Estq. Sayon +2", 0)  --Macc 10
gear.estoqueurHands = hp_gear("Estq. Gantherots", 0)  --Macc 2
gear.estoqueurHandsPlusOne = hp_gear("Estq. Ganthrt. +1", 0)  --Macc 5, Enfeebling magic Skill 10
gear.estoqueurHandsPlusTwo = hp_gear("Estq. Ganthrt. +2", 0)  --Macc 7, Enfeebling magic Skill 15
gear.estoqueurLegs = mp_gear("Estq. Fuseau", 25)  --INT 3
gear.estoqueurLegsPlusOne = mp_gear("Estqr. Fuseau +1", 55)  --MAB 5, Macc 5
gear.estoqueurLegsPlusTwo = mp_gear("Estqr. Fuseau +2", 65)  --MAB 6, Macc 6
gear.estoqueurFeet = hp_gear("Estq. Houseaux", 0)  --Enmity -2
gear.estoqueurFeetPlusOne = hp_gear("Estq. Houseaux +1", 0)  --Enmity -4, Enhancing magic Skill 10
gear.estoqueurFeetPlusTwo = hp_gear("Estq. Houseaux +2", 0)  --Enmity -7, Enhancing magic Skill 15

--RDM Empyrean Reforged (REA Set: Augments "Composure")
gear.lethargyHead = hp_gear("Lethargy Chappel", 17)  --Haste 5, MAB 15, Macc 15, MDB 3
gear.lethargyBody = hp_gear("Lethargy Sayon", 27)  --Refresh 2, Haste 2, Macc 17, MDB 3
gear.lethargyHands = hp_gear("Leth. Gantherots", 11)  --Haste 3, Macc 14, MDB 1, Enfeebling magic Skill 17
gear.lethargyLegs = hp_gear("Leth. Fuseau", 21)  --Haste 4, MAB 12, Macc 12, MDB 3
gear.lethargyFeet = hp_gear("Leth. Houseaux", 7)  --Haste 3, MDB 3, Enmity -8, Enhancing magic Skill 20

--THF Artifact (75-era)
gear.rogueHead = hp_gear("Rogue's Bonnet", 13)  --Parrying Skill 10
gear.rogueHeadPlusOne = hp_gear("Rog. Bonnet +1", 13)  --Racc 8
gear.rogueBody = hp_gear("Rogue's Vest", 20)  --STR 3
gear.rogueBodyPlusOne = hp_gear("Rog. Vest +1", 20)  --Acc 10
gear.rogueHands = hp_gear("Rogue's Armlets", 10)  --DEX 3
gear.rogueHandsPlusOne = hp_gear("Rog. Armlets +1", 10)  --DEX 3
gear.rogueLegs = hp_gear("Rogue's Culottes", 15)  --Shield Skill 10
gear.rogueLegsPlusOne = hp_gear("Rog. Culottes +1", 15)  --AGI 4, DEX 2
gear.rogueFeet = hp_gear("Rogue's Poulaines", 12)  --DEX 3
gear.rogueFeetPlusOne = hp_gear("Rog. Poulaines +1", 0)  --Racc 5

--THF Artifact Reforged (Set: Increases Accuracy, Ranged Accuracy, and Magic Accuracy)
gear.pillagerHead = hp_gear("Pillager's Bonnet", 17)  --Haste 7, MDB 1, Racc 13, Acc 13
gear.pillagerHeadPlusOne = hp_gear("Pill. Bonnet +1", 36)  --Haste 8, MDB 2, Racc 13, Acc 13
gear.pillagerHeadPlusTwo = hp_gear("Pill. Bonnet +2", 54)  --WSD 3, Haste 8, MDB 2, Racc 23, Acc 43
gear.pillagerHeadPlusThree = hp_gear("Pill. Bonnet +3", 64)  --WSD 6, Haste 8, MDB 3, Racc 33, Acc 53
gear.pillagerHeadPlusFour = hp_gear("Pill. Bonnet +4", 74)  --WSD 9, Haste 8, Macc 63, MDB 4, Racc 43
gear.pillagerBody = hp_gear("Pillager's Vest", 28)  --Haste 4, MDB 3, Acc 15
gear.pillagerBodyPlusOne = hp_gear("Pillager's Vest +1", 59)  --Haste 4, MDB 6, Acc 20
gear.pillagerBodyPlusTwo = hp_gear("Pillager's Vest +2", 88)  --TA 4, Haste 4, MDB 6, Acc 50
gear.pillagerBodyPlusThree = hp_gear("Pillager's Vest +3", 98)  --TA 7, Haste 4, MDB 7, Acc 60
gear.pillagerBodyPlusFour = hp_gear("Pill. Vest +4", 108)  --TA 7, Haste 4, Macc 70, MDB 8, Acc 70
gear.pillagerHands = hp_gear("Pillager's Armlets", 11)  --Haste 4, MDB 1
gear.pillagerHandsPlusOne = hp_gear("Pill. Armlets +1", 25)  --Haste 5, MDB 2
gear.pillagerHandsPlusTwo = hp_gear("Pill. Armlets +2", 37)  --DW 3, Haste 5, MDB 2, Acc 38
gear.pillagerHandsPlusThree = hp_gear("Pill. Armlets +3", 47)  --DW 5, Haste 5, MDB 3, Acc 48
gear.pillagerHandsPlusFour = hp_gear("Pill. Armlets +4", 57)  --DW 5, Haste 5, Macc 58, MDB 4, Acc 58
gear.pillagerLegs = hp_gear("Pillager's Culottes", 22)  --MDB 2, Acc 10, Att 10, Enmity 6
gear.pillagerLegsPlusOne = hp_gear("Pill. Culottes +1", 47)  --Haste 6, MDB 5, Acc 10, Att 10
gear.pillagerLegsPlusTwo = hp_gear("Pill. Culottes +2", 70)  --TA 3, Haste 6, MDB 5, Acc 44
gear.pillagerLegsPlusThree = hp_gear("Pill. Culottes +3", 80)  --TA 5, Haste 6, MDB 6, Acc 54, Att 30
gear.pillagerLegsPlusFour = hp_gear("Pill. Culottes +4", 90)  --TA 5, Haste 6, Macc 64, MDB 7, Acc 64
gear.pillagerFeet = hp_gear("Pillager's Poulaines", 6)  --Haste 4, MDB 2, Racc 10, Acc 10
gear.pillagerFeetPlusOne = hp_gear("Pill. Poulaines +1", 13)  --Haste 4, MDB 5, Racc 13, Acc 13
gear.pillagerFeetPlusTwo = hp_gear("Pill. Poulaines +2", 19)  --Haste 4, MDB 5, Racc 23, Acc 42
gear.pillagerFeetPlusThree = hp_gear("Pill. Poulaines +3", 29)  --Haste 4, MDB 6, Racc 33, Acc 52
gear.pillagerFeetPlusFour = hp_gear("Pill. Poulaines +4", 39)  --Haste 4, Macc 62, MDB 7, Racc 43, Acc 62

--THF Relic (75-era)
gear.assassinHead = hp_gear("Assassin's Bonnet", 16)  --Enmity 2
gear.assassinHeadPlusOne = hp_gear("Asn. Bonnet +1", 16)  --Enmity 3
gear.assassinHeadPlusTwo = hp_gear("Asn. Bonnet +2", 0)  --Acc 6, Enmity 4
gear.assassinBody = hp_gear("Assassin's Vest", 22)  --Enmity 3
gear.assassinBodyPlusOne = hp_gear("Asn. Vest +1", 22)  --Enmity 5
gear.assassinBodyPlusTwo = hp_gear("Asn. Vest +2", 0)  --Enmity 6
gear.assassinHands = hp_gear("Assassin's Armlets", 7)  --TH 1, Enmity 3
gear.assassinHandsPlusOne = hp_gear("Asn. Armlets +1", 26)  --TH 1, Enmity 4
gear.assassinHandsPlusTwo = hp_gear("Asn. Armlets +2", 0)  --Acc 9, TH 2, Enmity 5
gear.assassinLegs = hp_gear("Assassin's Culottes", 19)  --Enmity 4
gear.assassinLegsPlusOne = hp_gear("Asn. Culottes +1", 25)  --Enmity 5
gear.assassinLegsPlusTwo = hp_gear("Asn. Culottes +2", 0)  --Acc 10, Enmity 6
gear.assassinFeet = hp_gear("Assassin's Pouln.", 15)  --TA 1, Enmity 2
gear.assassinFeetPlusOne = hp_gear("Asn. Poulaines +1", 15)  --TA 1, Enmity 3
gear.assassinFeetPlusTwo = hp_gear("Asn. Poulaines +2", 0)  --TA 3, Enmity 4

--THF Relic Reforged (REA Set: Augments "Triple Attack")
gear.plundererHead = hp_gear("Plun. Bonnet", 17)  --Haste 7, MDB 1, Acc 10, Enmity 4
gear.plundererHeadPlusOne = hp_gear("Plun. Bonnet +1", 36)  --Haste 8, MDB 2, Acc 15, Enmity 5
gear.plundererHeadPlusTwo = hp_gear("Plun. Bonnet +2", 46)  --TA 3, Haste 8, Macc 27, MDB 3, Acc 34
gear.plundererHeadPlusThree = hp_gear("Plun. Bonnet +3", 56)  --TA 4, Haste 8, Macc 37, MDB 4, Acc 44
gear.plundererHeadPlusFour = hp_gear("Plun. Bonnet +4", 66)  --TA 4, Haste 8, Macc 42, MDB 5, Acc 49
gear.plundererBody = hp_gear("Plunderer's Vest", 28)  --Haste 4, MDB 3, Enmity 6
gear.plundererBodyPlusOne = hp_gear("Plunderer's Vest +1", 59)  --Haste 4, MDB 6, Enmity 7
gear.plundererBodyPlusTwo = hp_gear("Plunderer's Vest +2", 69)  --Haste 4, Macc 30, MDB 7, Acc 30, Att 50
gear.plundererBodyPlusThree = hp_gear("Plunderer's Vest +3", 79)  --Haste 4, Macc 40, MDB 8, Acc 40, Att 65
gear.plundererBodyPlusFour = hp_gear("Plunderer's Vest +4", 89)  --Haste 4, Macc 45, MDB 9, Acc 45, Att 75
gear.plundererHands = hp_gear("Plun. Armlets", 11)  --Haste 4, MDB 1, Acc 12, TH 2, Enmity 5
gear.plundererHandsPlusOne = hp_gear("Plun. Armlets +1", 25)  --Haste 5, MDB 2, Acc 15, TH 3, Enmity 6
gear.plundererHandsPlusTwo = hp_gear("Plun. Armlets +2", 35)  --Haste 5, Macc 28, MDB 3, Acc 35, Att 48
gear.plundererHandsPlusThree = hp_gear("Plun. Armlets +3", 45)  --Haste 5, Macc 38, MDB 4, Acc 45, Att 63
gear.plundererHandsPlusFour = hp_gear("Plun. Armlets +4", 55)  --Haste 5, Macc 43, MDB 5, Acc 50, Att 73
gear.plundererLegs = hp_gear("Plun. Culottes", 22)  --Haste 6, MDB 2, Acc 12, Enmity 6
gear.plundererLegsPlusOne = hp_gear("Plun. Culottes +1", 47)  --Haste 6, MDB 5, Acc 15, Enmity 7
gear.plundererLegsPlusTwo = hp_gear("Plun. Culottes +2", 57)  --WSD 3, Haste 6, Macc 29, MDB 6, Acc 36
gear.plundererLegsPlusThree = hp_gear("Plun. Culottes +3", 67)  --WSD 6, Haste 6, Macc 39, MDB 7, Acc 46
gear.plundererLegsPlusFour = hp_gear("Plun. Culottes +4", 77)  --WSD 9, Haste 6, Macc 44, MDB 8, Acc 51
gear.plundererFeet = hp_gear("Plun. Poulaines", 6)  --TA 3, Haste 4, MDB 2, Enmity 4
gear.plundererFeetPlusOne = hp_gear("Plun. Poulaines +1", 13)  --TA 3, Haste 4, MDB 5, Enmity 5
gear.plundererFeetPlusTwo = hp_gear("Plun. Poulaines +2", 23)  --TA 4, Haste 4, Macc 26, MDB 6, Acc 26
gear.plundererFeetPlusThree = hp_gear("Plun. Poulaines +3", 33)  --TA 5, Haste 4, Macc 36, MDB 7, Acc 36
gear.plundererFeetPlusFour = hp_gear("Plun. Poulaines +4", 43)  --TA 5, Haste 4, Macc 41, MDB 8, Acc 41

--THF Empyrean (90-era) (Set: Augments "Triple Attack")
gear.raiderHead = hp_gear("Raider's Bonnet", 0)  --Acc 4
gear.raiderHeadPlusOne = hp_gear("Raid. Bonnet +1", 0)  --Haste 5, Acc 8
gear.raiderHeadPlusTwo = hp_gear("Raid. Bonnet +2", 0)  --TA 3, Haste 6, Acc 12
gear.raiderBody = hp_gear("Raider's Vest", 0)  --DEX 3
gear.raiderBodyPlusOne = hp_gear("Raider's Vest +1", 0)  --Haste 4, Dagger Skill 3
gear.raiderBodyPlusTwo = hp_gear("Raider's Vest +2", 0)  --Haste 5, Dagger Skill 5
gear.raiderHands = hp_gear("Raider's Armlets", 0)  --Acc 4, Att 5
gear.raiderHandsPlusOne = hp_gear("Raid. Armlets +1", 0)  --Acc 8, Att 10
gear.raiderHandsPlusTwo = hp_gear("Raid. Armlets +2", 0)  --Acc 12, Att 16
gear.raiderLegs = hp_gear("Raider's Culottes", 0)  --DEX 2
gear.raiderLegsPlusOne = hp_gear("Raid. Culottes +1", 0)  --Haste 4
gear.raiderLegsPlusTwo = hp_gear("Raid. Culottes +2", 0)  --Haste 5
gear.raiderFeet = hp_gear("Raider's Poulaines", 0)
gear.raiderFeetPlusOne = hp_gear("Raid. Poulaines +1", 0)  --AGI 12
gear.raiderFeetPlusTwo = hp_gear("Raid. Poulaines +2", 0)  --TH 1

--THF Empyrean Reforged (REA Set: Augments "Triple Attack")
gear.skulkerHead = hp_gear("Skulker's Bonnet", 19)  --TA 3, Haste 7, MDB 1, Acc 22
gear.skulkerHeadPlusOne = hp_gear("Skulker's Bonnet +1", 41)  --TA 4, Haste 8, MDB 3, Acc 32
gear.skulkerHeadPlusTwo = hp_gear("Skulker's Bonnet +2", 61)  --TA 5, Haste 8, Macc 51, MDB 6, Acc 51
gear.skulkerHeadPlusThree = hp_gear("Skulker's Bonnet +3", 71)  --TA 6, Haste 8, Macc 61, MDB 7, Acc 61
gear.skulkerBody = hp_gear("Skulker's Vest", 30)  --Haste 5, MDB 3, Dagger Skill 18
gear.skulkerBodyPlusOne = hp_gear("Skulker's Vest +1", 63)  --Haste 6, MDB 6, Dagger Skill 28
gear.skulkerBodyPlusTwo = hp_gear("Skulker's Vest +2", 83)  --WSD 8, Haste 6, Macc 54, MDB 9, Acc 54
gear.skulkerBodyPlusThree = hp_gear("Skulker's Vest +3", 93)  --WSD 12, Haste 6, Macc 64, MDB 10, Acc 64
gear.skulkerHands = hp_gear("Skulker's Armlets", 12)  --Haste 4, MDB 1, Acc 12, Att 16
gear.skulkerHandsPlusOne = hp_gear("Skulk. Armlets +1", 27)  --Haste 5, MDB 2, Acc 22, Att 25
gear.skulkerHandsPlusTwo = hp_gear("Skulk. Armlets +2", 47)  --Haste 5, Macc 52, MDB 5, Acc 52, Att 62
gear.skulkerHandsPlusThree = hp_gear("Skulk. Armlets +3", 57)  --Haste 5, Macc 62, MDB 6, Acc 62, Att 72
gear.skulkerLegs = hp_gear("Skulker's Culottes", 23)  --Haste 6, MDB 2
gear.skulkerLegsPlusOne = hp_gear("Skulk. Culottes +1", 50)  --Haste 6, MDB 5
gear.skulkerLegsPlusTwo = hp_gear("Skulk. Culottes +2", 70)  --Haste 6, Macc 53, MDB 8, Acc 53, Att 53
gear.skulkerLegsPlusThree = hp_gear("Skulk. Culottes +3", 80)  --Haste 6, Macc 63, MDB 9, Acc 63, Att 63
gear.skulkerFeet = hp_gear("Skulk. Poulaines", 7)  --Haste 4, MDB 2, TH 2
gear.skulkerFeetPlusOne = hp_gear("Skulk. Poulaines +1", 15)  --Haste 4, MDB 5, TH 3
gear.skulkerFeetPlusTwo = hp_gear("Skulk. Poulaines +2", 35)  --Haste 4, Macc 50, MDB 8, Acc 50, Att 50
gear.skulkerFeetPlusThree = hp_gear("Skulk. Poulaines +3", 45)  --Haste 4, Macc 60, MDB 9, Acc 60, Att 60

--PLD Artifact (75-era)
gear.gallantHeadPlusOne = hp_gear("Glt. Coronet +1", 12)  --Enmity 3
gear.gallantBody = hp_gear("Gallant Surcoat", 20)  --Enmity 2, Divine magic Skill 5
gear.gallantBodyPlusOne = hp_gear("Glt. Surcoat +1", 20)  --Enmity 2, Divine magic Skill 8
gear.gallantHands = hp_gear("Gallant Gauntlets", 11)  --Enmity 2
gear.gallantHandsPlusOne = hp_gear("Glt. Gauntlets +1", 11)  --Enmity 2
gear.gallantLegs = hp_gear("Gallant Breeches", 15)  --Enmity 2, Enhancing magic Skill 5
gear.gallantLegsPlusOne = hp_gear("Glt. Breeches +1", 20)  --Enmity 2, Enhancing magic Skill 10
gear.gallantFeetPlusOne = hp_gear("Glt. Leggings +1", 20)  --Shield Skill 12

--PLD Artifact Reforged (Set: Increases Accuracy, Ranged Accuracy, and Magic Accuracy)
gear.reverenceHeadPlusOne = hp_gear("Rev. Coronet +1", 41)  --Haste 7, MDB 2, Enmity 5
gear.reverenceHeadPlusTwo = hp_gear("Rev. Coronet +2", 61)  --Haste 7, MDB 2, Acc 37, Enmity 6
gear.reverenceHeadPlusThree = hp_gear("Rev. Coronet +3", 71)  --Haste 7, MDB 3, Acc 47, Enmity 7
gear.reverenceHeadPlusFour = hp_gear("Rev. Coronet +4", 81)  --Haste 7, Macc 57, MDB 4, Acc 57, Enmity 7
gear.reverenceBody = hp_gear("Reverence Surcoat", 130)  --Haste 3, MDB 2, Enmity 8, Divine magic Skill 13
gear.reverenceBodyPlusOne = hp_gear("Rev. Surcoat +1", 163)  --Haste 3, MDB 4, Enmity 8, Divine magic Skill 13
gear.reverenceBodyPlusTwo = hp_gear("Rev. Surcoat +2", 244)  --FC 5, Haste 3, Macc 40, MDB 4, Enmity 9
gear.reverenceBodyPlusThree = hp_gear("Rev. Surcoat +3", 254)  --FC 10, Haste 3, Macc 50, MDB 5, Enmity 10
gear.reverenceHands = hp_gear("Rev. Gauntlets", 54)  --Haste 3, Enmity 4
gear.reverenceHandsPlusOne = hp_gear("Rev. Gauntlets +1", 69)  --Haste 4, MDB 1, Enmity 4
gear.reverenceHandsPlusTwo = hp_gear("Rev. Gauntlets +2", 103)  --Haste 4, MDB 1, Acc 38, Enmity 5
gear.reverenceHandsPlusThree = hp_gear("Rev. Gauntlets +3", 113)  --Haste 4, MDB 2, Acc 48, Enmity 6
gear.reverenceHandsPlusFour = hp_gear("Rev. Gauntlets +4", 123)  --Haste 4, Macc 58, MDB 3, Acc 58, Enmity 6
gear.reverenceLegs = hp_gear("Rev. Breeches", 74)  --Haste 5, MDB 1, Enmity 4, Enhancing magic Skill 15
gear.reverenceLegsPlusOne = hp_gear("Rev. Breeches +1", 102)  --Haste 5, MDB 3, Enmity 5, Enhancing magic Skill 15
gear.reverenceLegsPlusTwo = hp_gear("Rev. Breeches +2", 153)  --Haste 5, MDB 3, Acc 39, Enmity 6, Enhancing magic Skill 17
gear.reverenceLegsPlusThree = hp_gear("Rev. Breeches +3", 163)  --Haste 5, MDB 4, Acc 49, Enmity 7, Enhancing magic Skill 19
gear.reverenceLegsPlusFour = hp_gear("Rev. Breeches +4", 173)  --Haste 5, Macc 59, MDB 5, Acc 59, Enmity 7
gear.reverenceFeetPlusOne = hp_gear("Rev. Leggings +1", 48)  --Haste 3, MDB 2, Acc 10, Shield Skill 17
gear.reverenceFeetPlusTwo = hp_gear("Rev. Leggings +2", 72)  --Haste 3, MDB 2, Acc 41, Shield Skill 19
gear.reverenceFeetPlusThree = hp_gear("Rev. Leggings +3", 82)  --Haste 3, MDB 3, Acc 51, Shield Skill 21
gear.reverenceFeetPlusFour = hp_gear("Rev. Leggings +4", 92)  --Haste 3, Macc 61, MDB 4, Acc 61, Shield Skill 22

--PLD Relic (75-era)
gear.valorHead = hp_gear("Valor Coronet", 18)  --Enmity 3, Healing magic Skill 10
gear.valorHeadPlusOne = hp_gear("Vlr. Coronet +1", 18)  --Enmity 4, Healing magic Skill 10
gear.valorHeadPlusTwo = hp_gear("Vlr. Coronet +2", 25)  --Enmity 6
gear.valorBodyPlusOne = hp_gear("Vlr. Surcoat +1", 30)  --Enmity 5
gear.valorBodyPlusTwo = hp_gear("Vlr. Surcoat +2", 42)  --Enmity 7
gear.valorHands = hp_gear("Valor Gauntlets", 16)  --Enmity 3
gear.valorHandsPlusOne = hp_gear("Vlr. Gauntlets +1", 16)  --Enmity 4
gear.valorHandsPlusTwo = hp_gear("Vlr. Gauntlets +2", 22)  --Enmity 6
gear.valorLegs = hp_gear("Valor Breeches", 20)  --SIRD 10, Enmity 3
gear.valorLegsPlusOne = hp_gear("Vlr. Breeches +1", 20)  --SIRD 10, Enmity 4
gear.valorLegsPlusTwo = hp_gear("Vlr. Breeches +2", 28)  --Enmity 6
gear.valorFeet = hp_gear("Valor Leggings", 18)  --Enmity 1
gear.valorFeetPlusOne = hp_gear("Vlr. Leggings +1", 18)  --Enmity 2
gear.valorFeetPlusTwo = hp_gear("Vlr. Leggings +2", 25)  --Enmity 4

--PLD Relic Reforged (REA Set: Occ. absorbs damage taken)
gear.caballariusHeadPlusOne = hp_gear("Cab. Coronet +1", 96)  --Haste 7, MDB 2, Enmity 7
gear.caballariusHeadPlusTwo = hp_gear("Cab. Coronet +2", 106)  --Haste 7, Macc 27, MDB 3, Acc 27, Att 47
gear.caballariusHeadPlusThree = hp_gear("Cab. Coronet +3", 116)  --Haste 7, Macc 37, MDB 4, Acc 37, Att 62
gear.caballariusHeadPlusFour = hp_gear("Cab. Coronet +4", 126)  --Haste 7, Macc 42, MDB 5, Acc 42, Att 72
gear.caballariusBody = hp_gear("Cab. Surcoat", 70)  --Haste 3, MDB 2, Enmity 7
gear.caballariusBodyPlusOne = hp_gear("Cab. Surcoat +1", 118)  --Haste 3, MDB 4, Enmity 8
gear.caballariusBodyPlusTwo = hp_gear("Cab. Surcoat +2", 128)  --Haste 3, Macc 30, MDB 5, Acc 30, Att 50
gear.caballariusBodyPlusThree = hp_gear("Cab. Surcoat +3", 138)  --Haste 3, Macc 40, MDB 6, Acc 40, Att 65
gear.caballariusBodyPlusFour = hp_gear("Cab. Surcoat +4", 148)  --Haste 3, Macc 45, MDB 7, Acc 45, Att 75
gear.caballariusHands = hp_gear("Cab. Gauntlets", 74)  --Haste 3, Enmity 6
gear.caballariusHandsPlusOne = hp_gear("Cab. Gauntlets +1", 104)  --Haste 4, MDB 1, Enmity 7
gear.caballariusHandsPlusTwo = hp_gear("Cab. Gauntlets +2", 114)  --Haste 4, Macc 28, MDB 2, Acc 28, Att 48
gear.caballariusHandsPlusThree = hp_gear("Cab. Gauntlets +3", 124)  --Haste 4, Macc 38, MDB 3, Acc 38, Att 63
gear.caballariusHandsPlusFour = hp_gear("Cab. Gauntlets +4", 134)  --Haste 4, Macc 43, MDB 4, Acc 43, Att 73
gear.caballariusLegsPlusOne = hp_gear("Cab. Breeches +1", 52)  --Haste 5, MDB 3, Enmity 7
gear.caballariusLegsPlusTwo = hp_gear("Cab. Breeches +2", 62)  --SIRD 7, Haste 5, Macc 29, MDB 4, Acc 29
gear.caballariusLegsPlusThree = hp_gear("Cab. Breeches +3", 72)  --SIRD 10, Haste 5, Macc 39, MDB 5, Acc 39
gear.caballariusLegsPlusFour = hp_gear("Cab. Breeches +4", 82)  --SIRD 10, Haste 5, Macc 44, MDB 6, Acc 44
gear.caballariusFeetPlusOne = hp_gear("Cab. Leggings +1", 43)  --Haste 3, MDB 2, Enmity 6
gear.caballariusFeetPlusTwo = hp_gear("Cab. Leggings +2", 53)  --Haste 3, Macc 26, MDB 3, Acc 26, Att 46
gear.caballariusFeetPlusThree = hp_gear("Cab. Leggings +3", 63)  --Haste 3, Macc 36, MDB 4, Acc 36, Att 61
gear.caballariusFeetPlusFour = hp_gear("Cab. Leggings +4", 73)  --Haste 3, Macc 41, MDB 5, Acc 41, Att 71

--PLD Empyrean (90-era) (Set: Occasionally absorbs damage taken)
gear.creedHead = hp_gear("Creed Armet", 15)
gear.creedHeadPlusOne = hp_gear("Creed Armet +1", 30)  --Shield Skill 5
gear.creedHeadPlusTwo = hp_gear("Creed Armet +2", 40)  --Shield Skill 7
gear.creedBody = hp_gear("Creed Cuirass", 0)  --Acc 6, Att 6, Enmity 3
gear.creedBodyPlusOne = hp_gear("Creed Cuirass +1", 40)  --Acc 14, Att 14, Enmity 7
gear.creedBodyPlusTwo = hp_gear("Creed Cuirass +2", 65)  --Acc 20, Att 20, Enmity 10
gear.creedHands = hp_gear("Creed Gauntlets", 0)  --STR 3, VIT 3
gear.creedHandsPlusOne = hp_gear("Crd. Gauntlets +1", 0)  --Haste 3, Sword Skill 5
gear.creedHandsPlusTwo = hp_gear("Crd. Gauntlets +2", 0)  --Haste 4, Sword Skill 7
gear.creedLegs = hp_gear("Creed Cuisses", 15)
gear.creedLegsPlusOne = hp_gear("Creed Cuisses +1", 30)  --Haste 3
gear.creedLegsPlusTwo = hp_gear("Creed Cuisses +2", 50)  --Haste 4
gear.creedFeet = hp_gear("Creed Sabatons", 0)  --Acc 4
gear.creedFeetPlusOne = hp_gear("Creed Sabatons +1", 0)  --Haste 3, Acc 10, Enmity 4
gear.creedFeetPlusTwo = hp_gear("Creed Sabatons +2", 0)  --Haste 4, Acc 14, Enmity 7

--PLD Empyrean Reforged (REA Set: Occ. absorbs damage taken)
gear.chevalierHead = hp_gear("Chevalier's Armet", 81)  --FC 6, Haste 6, MDB 1, Shield Skill 9
gear.chevalierBody = hp_gear("Chev. Cuirass", 96)  --Haste 3, MDB 2, Acc 20, Att 20, Enmity 10
gear.chevalierHands = hp_gear("Chev. Gauntlets", 16)  --Haste 4, Sword Skill 18
gear.chevalierLegs = hp_gear("Chevalier's Cuisses", 77)  --Haste 5, MDB 1
gear.chevalierFeet = hp_gear("Chev. Sabatons", 10)  --Haste 4, MDB 1, Acc 16, Enmity 9

--DRK Artifact (75-era)
gear.chaosHead = hp_gear("Chaos Burgeonet", 12)  --Dark magic Skill 5
gear.chaosHeadPlusOne = hp_gear("Chs. Burgeonet +1", 12)  --Dark magic Skill 5
gear.chaosBody = hp_gear("Chaos Cuirass", 20)  --Att 5, Enfeebling magic Skill 5
gear.chaosBodyPlusOne = hp_gear("Chs. Cuirass +1", 20)  --Att 10, Enfeebling magic Skill 5
gear.chaosHands = hp_gear("Chaos Gauntlets", 11)  --DEX 3
gear.chaosHandsPlusOne = hp_gear("Chs. Gauntlets +1", 11)  --Acc 3
gear.chaosLegs = hp_gear("Chaos Flanchard", 15)  --Parrying Skill 10
gear.chaosLegsPlusOne = hp_gear("Chs. Flanchard +1", 15)  --Parrying Skill 15
gear.chaosFeet = hp_gear("Chaos Sollerets", 15)  --MND 5
gear.chaosFeetPlusOne = hp_gear("Chs. Sollerets +1", 15)  --STR 5, MND 5

--DRK Artifact Reforged (Set: Increases Accuracy, Ranged Accuracy, and Magic Accuracy)
gear.ignominyHead = hp_gear("Ignominy Burgeonet", 19)  --Haste 6, MDB 1, Att 18, Dark magic Skill 15
gear.ignominyHeadPlusOne = hp_gear("Igno. Burgeonet +1", 41)  --Haste 7, MDB 2, Att 18, Dark magic Skill 17
gear.ignominyHeadPlusTwo = hp_gear("Ig. Burgeonet +2", 61)  --Haste 7, MDB 2, Acc 37, Att 28, Dark magic Skill 19
gear.ignominyHeadPlusThree = hp_gear("Ig. Burgeonet +3", 71)  --Haste 7, MDB 3, Acc 47, Att 38, Dark magic Skill 21
gear.ignominyHeadPlusFour = hp_gear("Ig. Burgeonet +4", 81)  --Haste 7, Macc 57, MDB 4, Acc 57, Att 43
gear.ignominyBody = hp_gear("Ignominy Cuirass", 70)  --Haste 3, MDB 2, Att 23, Enfeebling magic Skill 18
gear.ignominyBodyPlusOne = hp_gear("Igno. Cuirass +1", 103)  --Haste 3, MDB 4, Att 28, Enfeebling magic Skill 18
gear.ignominyBodyPlusTwo = hp_gear("Ignominy Cuirass +2", 154)  --WSD 5, Haste 3, MDB 4, Acc 40, Att 38
gear.ignominyBodyPlusThree = hp_gear("Ignominy Cuirass +3", 164)  --WSD 10, Haste 3, MDB 5, Acc 50, Att 48
gear.ignominyBodyPlusFour = hp_gear("Ig. Cuirass +4", 174)  --WSD 12, Haste 3, Macc 60, MDB 6, Acc 60
gear.ignominyHands = hp_gear("Igno. Gauntlets", 29)  --Haste 3, Acc 10, Att 10
gear.ignominyHandsPlusOne = hp_gear("Igno. Gauntlets +1", 44)  --Haste 4, MDB 1, Acc 13, Att 13
gear.ignominyHandsPlusTwo = hp_gear("Ig. Gauntlets +2", 66)  --Haste 4, MDB 1, Acc 44, Att 23, SC Bonus 5
gear.ignominyHandsPlusThree = hp_gear("Ig. Gauntlets +3", 76)  --Haste 4, MDB 2, Acc 54, Att 33, SC Bonus 10
gear.ignominyHandsPlusFour = hp_gear("Ig. Fin. Gaunt. +4", 86)  --Haste 4, Macc 64, MDB 3, Acc 64, Att 38
gear.ignominyLegs = hp_gear("Ignominy Flanchard", 24)  --Haste 5, MDB 1, Att 20, Parrying Skill 17
gear.ignominyLegsPlusOne = hp_gear("Igno. Flan. +1", 52)  --Haste 5, MDB 3, Att 25, Parrying Skill 17
gear.ignominyLegsPlusTwo = hp_gear("Ig. Flanchard +2", 78)  --DA 5, Haste 5, MDB 3, Acc 39, Att 35
gear.ignominyLegsPlusThree = hp_gear("Ig. Flanchard +3", 88)  --DA 10, Haste 5, MDB 4, Acc 49, Att 45
gear.ignominyLegsPlusFour = hp_gear("Ig. Flanchard +4", 98)  --DA 10, Haste 5, Macc 59, MDB 5, Acc 59
gear.ignominyFeet = hp_gear("Igno. Sollerets", 28)  --Haste 3, MAB 17, Macc 17, MDB 1, Att 15
gear.ignominyFeetPlusOne = hp_gear("Igno. Sollerets +1", 38)  --Haste 3, MAB 17, Macc 17, MDB 2, Att 20
gear.ignominyFeetPlusTwo = hp_gear("Ig. Sollerets +2", 57)  --Haste 3, MAB 22, Macc 44, MDB 2, Att 30
gear.ignominyFeetPlusThree = hp_gear("Ig. Sollerets +3", 67)  --Haste 3, MAB 27, Macc 54, MDB 3, Att 40
gear.ignominyFeetPlusFour = hp_gear("Ig. Sollerets +4", 77)  --Haste 3, MAB 29, Macc 64, MDB 4, Acc 64

--DRK Relic (75-era)
gear.abyssHead = hp_gear("Abyss Burgeonet", 30)  --Att 10
gear.abyssHeadPlusOne = hp_gear("Abs. Burgeonet +1", 30)  --Att 12
gear.abyssHeadPlusTwo = hp_gear("Abs. Burgeonet +2", 42)  --Att 15
gear.abyssBody = hp_gear("Abyss Cuirass", 20)  --MAB 10, Acc 10
gear.abyssBodyPlusOne = hp_gear("Abs. Cuirass +1", 27)  --MAB 10, Acc 12
gear.abyssBodyPlusTwo = hp_gear("Abs. Cuirass +2", 38)  --MAB 12, Acc 15, Att 15
gear.abyssHands = mp_gear("Abyss Gauntlets", 20)  --Dark magic Skill 5
gear.abyssHandsPlusOne = mp_gear("Abs. Gauntlets +1", 20)  --Dark magic Skill 7
gear.abyssHandsPlusTwo = hp_gear("Abs. Gauntlets +2", 0)  --Att 6, Dark magic Skill 9
gear.abyssLegs = mp_gear("Abyss Flanchard", 18)  --MDB 5, Dark magic Skill 5
gear.abyssLegsPlusOne = hp_gear("Abs. Flanchard +1", 18)  --MDB 5, Dark magic Skill 7
gear.abyssLegsPlusTwo = hp_gear("Abs. Flanchard +2", 25)  --MDB 7, Dark magic Skill 10
gear.abyssFeet = mp_gear("Abyss Sollerets", 12)  --Enfeebling magic Skill 5
gear.abyssFeetPlusOne = mp_gear("Abs. Sollerets +1", 12)  --Acc 2, Enfeebling magic Skill 5
gear.abyssFeetPlusTwo = hp_gear("Abs. Sollerets +2", 0)  --Att 6

--DRK Relic Reforged (REA Set: Attack occ. varies with HP)
gear.fallenHead = hp_gear("Fallen's Burgeonet", 54)  --Haste 6, MDB 1, Acc 15, Att 15
gear.fallenHeadPlusOne = hp_gear("Fall. Burgeonet +1", 76)  --Haste 7, MDB 2, Acc 15, Att 15
gear.fallenHeadPlusTwo = hp_gear("Fall. Burgeonet +2", 86)  --Haste 7, Macc 27, MDB 3, Acc 34, Att 62
gear.fallenHeadPlusThree = hp_gear("Fall. Burgeonet +3", 96)  --Haste 7, Macc 37, MDB 4, Acc 44, Att 77
gear.fallenHeadPlusFour = hp_gear("Fall. Burgeonet +4", 106)  --Haste 7, Macc 42, MDB 5, Acc 49, Att 87
gear.fallenBody = hp_gear("Fallen's Cuirass", 50)  --Haste 3, MAB 15, MDB 2, Acc 15, Att 15
gear.fallenBodyPlusOne = hp_gear("Fall. Cuirass +1", 83)  --Haste 3, MAB 17, MDB 4, Acc 17, Att 17
gear.fallenBodyPlusTwo = hp_gear("Fall. Cuirass +2", 93)  --FC 7, Haste 3, MAB 53, Macc 30, MDB 5
gear.fallenBodyPlusThree = hp_gear("Fall. Cuirass +3", 103)  --FC 10, Haste 3, MAB 60, Macc 40, MDB 6
gear.fallenBodyPlusFour = hp_gear("Fall. Cuirass +4", 113)  --FC 10, Haste 3, MAB 63, Macc 45, MDB 7
gear.fallenHands = hp_gear("Fall. Fin. Gaunt.", 14)  --Haste 3, MAB 12, Att 12, Dark magic Skill 12
gear.fallenHandsPlusOne = hp_gear("Fall. Fin. Gaunt. +1", 29)  --Haste 4, MAB 14, MDB 1, Att 14, Dark magic Skill 14
gear.fallenHandsPlusTwo = hp_gear("Fall. Fin. Gaunt. +2", 39)  --Haste 4, MAB 55, Macc 28, MDB 2, Acc 28
gear.fallenHandsPlusThree = hp_gear("Fall. Fin. Gaunt. +3", 49)  --Haste 4, MAB 62, Macc 38, MDB 3, Acc 38
gear.fallenHandsPlusFour = hp_gear("Fall. Fin. Gaunt. +4", 59)  --Haste 4, MAB 65, Macc 43, MDB 4, Acc 43
gear.fallenLegs = hp_gear("Fallen's Flanchard", 49)  --Haste 5, MDB 7, Dark magic Skill 12
gear.fallenLegsPlusOne = hp_gear("Fall. Flanchard +1", 77)  --Haste 5, MDB 8, Dark magic Skill 14
gear.fallenLegsPlusTwo = hp_gear("Fall. Flanchard +2", 87)  --WSD 5, Haste 5, Macc 29, MDB 9, Acc 29
gear.fallenLegsPlusThree = hp_gear("Fall. Flanchard +3", 97)  --WSD 10, Haste 5, Macc 39, MDB 10, Acc 39
gear.fallenLegsPlusFour = hp_gear("Fall. Flanchard +4", 107)  --WSD 12, Haste 5, Macc 44, MDB 11, Acc 44
gear.fallenFeet = hp_gear("Fallen's Sollerets", 8)  --Haste 3, MDB 1, Att 12
gear.fallenFeetPlusOne = hp_gear("Fall. Sollerets +1", 18)  --Haste 3, MDB 2, Att 15
gear.fallenFeetPlusTwo = hp_gear("Fall. Sollerets +2", 28)  --Haste 3, Macc 26, MDB 3, Acc 26, Att 61
gear.fallenFeetPlusThree = hp_gear("Fall. Sollerets +3", 38)  --Haste 3, Macc 36, MDB 4, Acc 36, Att 76
gear.fallenFeetPlusFour = hp_gear("Fallen's So. +4", 48)  --Haste 3, Macc 41, MDB 5, Acc 41, Att 86

--DRK Empyrean (90-era) (Set: Attack occasionally varies with HP)
gear.baleHead = hp_gear("Bale Burgeonet", 0)  --STR 2, DEX 2
gear.baleHeadPlusOne = hp_gear("Bale Burgeonet +1", 0)  --DA 2, Haste 5
gear.baleHeadPlusTwo = hp_gear("Bale Burgeonet +2", 0)  --DA 3, Haste 6, Scythe Skill 7
gear.baleBody = hp_gear("Bale Cuirass", 0)  --Att 12
gear.baleBodyPlusOne = hp_gear("Bale Cuirass +1", 0)  --Haste 2, Att 28
gear.baleBodyPlusTwo = hp_gear("Bale Cuirass +2", 0)  --Haste 3, Att 38
gear.baleHands = hp_gear("Bale Gauntlets", 0)  --Acc 3, Att 3
gear.baleHandsPlusOne = hp_gear("Bale Gauntlets +1", 0)  --Haste 4, Acc 7, Att 7, Great Sword Skill 3
gear.baleHandsPlusTwo = hp_gear("Bale Gauntlets +2", 0)  --Haste 5, Acc 10, Att 10, Great Sword Skill 5
gear.baleLegs = hp_gear("Bale Flanchard", 0)  --Acc 4, Att 4
gear.baleLegsPlusOne = hp_gear("Bale Flanchard +1", 0)  --Acc 10, Att 10, Dark magic Skill 10
gear.baleLegsPlusTwo = hp_gear("Bale Flanchard +2", 0)  --Acc 15, Att 15, Dark magic Skill 15
gear.baleFeet = hp_gear("Bale Sollerets", 0)  --STR 3, INT 3
gear.baleFeetPlusOne = hp_gear("Bale Sollerets +1", 0)  --MAB 6, Macc 6
gear.baleFeetPlusTwo = hp_gear("Bale Sollerets +2", 0)  --MAB 8, Macc 8

--DRK Empyrean Reforged (REA Set: Attack occ. varies with HP)
gear.heathenHead = hp_gear("Heathen's Burgeonet", 19)  --DA 3, Haste 6, MDB 1, Scythe Skill 18
gear.heathenHeadPlusOne = hp_gear("Heath. Burgeonet +1", 41)  --DA 4, Haste 7, MDB 2, Scythe Skill 28
gear.heathenHeadPlusTwo = hp_gear("Heath. Burgeon. +2", 61)  --DA 5, Haste 7, Macc 51, MDB 5, Acc 51
gear.heathenHeadPlusThree = hp_gear("Heath. Bur. +3", 71)  --DA 6, Haste 7, Macc 61, MDB 6, Acc 61
gear.heathenBody = hp_gear("Heathen's Cuirass", 30)  --Haste 3, MDB 2, Att 38
gear.heathenBodyPlusOne = hp_gear("Heath. Cuirass +1", 63)  --Haste 4, MDB 4, Att 44
gear.heathenBodyPlusTwo = hp_gear("Heath. Cuirass +2", 83)  --Haste 4, Macc 54, MDB 7, Acc 54, Att 64
gear.heathenBodyPlusThree = hp_gear("Heath. Cuirass +3", 93)  --Haste 4, Macc 64, MDB 8, Acc 64, Att 74
gear.heathenHands = hp_gear("Heath. Gauntlets", 14)  --Haste 5, Acc 10, Att 10, Great Sword Skill 15
gear.heathenHandsPlusOne = hp_gear("Heath. Gauntlets +1", 29)  --Haste 6, MDB 1, Acc 18, Att 18, Great Sword Skill 18
gear.heathenHandsPlusTwo = hp_gear("Heath. Gauntlets +2", 49)  --Haste 6, Macc 52, MDB 4, Acc 52, Att 62
gear.heathenHandsPlusThree = hp_gear("Heath. Gauntlets +3", 59)  --Haste 6, Macc 62, MDB 5, Acc 62, Att 72
gear.heathenLegs = hp_gear("Heath. Flanchard", 24)  --Haste 5, MDB 2, Acc 17, Att 17, Dark magic Skill 18
gear.heathenLegsPlusOne = hp_gear("Heath. Flanchard +1", 52)  --Haste 5, MDB 4, Acc 27, Att 27, Dark magic Skill 20
gear.heathenLegsPlusTwo = hp_gear("Heath. Flanchard +2", 72)  --Haste 5, Macc 53, MDB 7, Acc 53, Att 63
gear.heathenLegsPlusThree = hp_gear("Heath. Flanchard +3", 82)  --Haste 5, Macc 63, MDB 8, Acc 63, Att 73
gear.heathenFeet = hp_gear("Heath. Sollerets", 8)  --Haste 3, MAB 10, Macc 10, MDB 1
gear.heathenFeetPlusOne = hp_gear("Heath. Sollerets +1", 18)  --Haste 3, MAB 20, Macc 20, MDB 2
gear.heathenFeetPlusTwo = hp_gear("Heath. Sollerets +2", 38)  --WSD 8, Haste 3, MAB 45, Macc 50, MDB 5
gear.heathenFeetPlusThree = hp_gear("Heath. Sollerets +3", 48)  --WSD 12, Haste 3, MAB 50, Macc 60, MDB 6

--BST Artifact (75-era)
gear.beastHead = hp_gear("Beast Helm", 15)  --INT 5
gear.beastHeadPlusOne = hp_gear("Bst. Helm +1", 15)  --INT 8, MND 8
gear.beastBody = hp_gear("Beast Jackcoat", 20)  --VIT 3
gear.beastBodyPlusOne = hp_gear("Bst. Jackcoat +1", 20)  --VIT 6
gear.beastHands = hp_gear("Beast Gloves", 11)  --Parrying Skill 5
gear.beastHandsPlusOne = hp_gear("Bst. Gloves +1", 11)  --Parrying Skill 10
gear.beastLegs = hp_gear("Beast Trousers", 15)  --CHR 4
gear.beastLegsPlusOne = hp_gear("Bst. Trousers +1", 15)  --STR 6, CHR 6
gear.beastFeet = hp_gear("Beast Gaiters", 11)  --AGI 3
gear.beastFeetPlusOne = hp_gear("Bst. Gaiters +1", 11)  --AGI 5, CHR 5

--BST Artifact Reforged (Set: Increases Accuracy, Ranged Accuracy, and Magic Accuracy)
gear.totemicHead = hp_gear("Totemic Helm", 17)  --Haste 7, MDB 1
gear.totemicHeadPlusOne = hp_gear("Totemic Helm +1", 36)  --Haste 8, MDB 2
gear.totemicHeadPlusTwo = hp_gear("Totemic Helm +2", 54)  --Haste 8, MDB 2, Acc 37
gear.totemicHeadPlusThree = hp_gear("Totemic Helm +3", 64)  --Haste 8, MDB 3, Acc 47
gear.totemicHeadPlusFour = hp_gear("Totemic Helm +4", 74)  --Haste 8, Macc 57, MDB 4, Acc 57
gear.totemicBody = hp_gear("Totemic Jackcoat", 28)  --Haste 4, MDB 3
gear.totemicBodyPlusOne = hp_gear("Tot. Jackcoat +1", 59)  --Haste 4, MDB 6
gear.totemicBodyPlusTwo = hp_gear("Tot. Jackcoat +2", 88)  --Haste 4, MDB 6, Acc 40
gear.totemicBodyPlusThree = hp_gear("Tot. Jackcoat +3", 98)  --Haste 4, MDB 7, Acc 50
gear.totemicBodyPlusFour = hp_gear("Tot. Jackcoat +4", 108)  --Haste 4, Macc 60, MDB 8, Acc 60
gear.totemicHands = hp_gear("Totemic Gloves", 11)  --Haste 4, MDB 1, Parrying Skill 15
gear.totemicHandsPlusOne = hp_gear("Tot. Gloves +1", 25)  --Haste 5, MDB 2, Parrying Skill 15
gear.totemicHandsPlusTwo = hp_gear("Totemic Gloves +2", 37)  --WSD 5, Haste 5, MDB 2, Acc 38, Parrying Skill 17
gear.totemicHandsPlusThree = hp_gear("Totemic Gloves +3", 47)  --WSD 10, Haste 5, MDB 3, Acc 48, Parrying Skill 19
gear.totemicHandsPlusFour = hp_gear("Tot. Gloves +4", 57)  --WSD 12, Haste 5, Macc 58, MDB 4, Acc 58
gear.totemicLegs = hp_gear("Totemic Trousers", 22)  --Haste 6, MDB 2
gear.totemicLegsPlusOne = hp_gear("Tot. Trousers +1", 47)  --Haste 6, MDB 5
gear.totemicLegsPlusTwo = hp_gear("Tot. Trousers +2", 70)  --Haste 6, MDB 5, Acc 39
gear.totemicLegsPlusThree = hp_gear("Tot. Trousers +3", 80)  --Haste 6, MDB 6, Acc 49
gear.totemicLegsPlusFour = hp_gear("Tot. Trousers +4", 90)  --Haste 6, Macc 59, MDB 7, Acc 59
gear.totemicFeet = hp_gear("Totemic Gaiters", 6)  --Haste 4, MDB 2
gear.totemicFeetPlusOne = hp_gear("Tot. Gaiters +1", 13)  --Haste 4, MDB 5
gear.totemicFeetPlusTwo = hp_gear("Tot. Gaiters +2", 19)  --Haste 4, MDB 5, Acc 36
gear.totemicFeetPlusThree = hp_gear("Tot. Gaiters +3", 29)  --Haste 4, MDB 6, Acc 46
gear.totemicFeetPlusFour = hp_gear("Tot. Gaiters +4", 39)  --Haste 4, Macc 56, MDB 7, Acc 56

--BST Relic (75-era)
gear.monsterHead = hp_gear("Monster Helm", 19)  --Parrying Skill 3
gear.monsterHeadPlusOne = hp_gear("Mst. Helm +1", 19)  --Parrying Skill 3
gear.monsterHeadPlusTwo = hp_gear("Mst. Helm +2", 27)  --DEX 7, CHR 7
gear.monsterBody = hp_gear("Monster Jackcoat", 21)  --INT 6
gear.monsterBodyPlusOne = hp_gear("Mst. Jackcoat +1", 21)  --INT 7
gear.monsterBodyPlusTwo = hp_gear("Mst. Jackcoat +2", 29)  --STR 8, DEX 8
gear.monsterHands = hp_gear("Monster Gloves", 14)  --AGI 4
gear.monsterHandsPlusOne = hp_gear("Mst. Gloves +1", 20)  --AGI 5
gear.monsterHandsPlusTwo = hp_gear("Mst. Gloves +2", 28)  --DEX 7, AGI 7
gear.monsterLegs = hp_gear("Monster Trousers", 17)  --DEX 4
gear.monsterLegsPlusOne = hp_gear("Mst. Trousers +1", 17)  --DEX 5
gear.monsterLegsPlusTwo = hp_gear("Mst. Trousers +2", 24)  --STR 7, DEX 7
gear.monsterFeet = hp_gear("Monster Gaiters", 13)  --VIT 4
gear.monsterFeetPlusOne = hp_gear("Mst. Gaiters +1", 13)  --VIT 5
gear.monsterFeetPlusTwo = hp_gear("Mst. Gaiters +2", 18)  --STR 7, VIT 7

--BST Relic Reforged (REA Set: Attack occ. varies with pet's HP)
gear.ankusaHead = hp_gear("Ankusa Helm", 17)  --Haste 7, MDB 1
gear.ankusaHeadPlusOne = hp_gear("Ankusa Helm +1", 36)  --Haste 8, MDB 2
gear.ankusaHeadPlusTwo = hp_gear("Ankusa Helm +2", 46)  --WSD 5, Haste 8, Macc 27, MDB 3, Acc 27
gear.ankusaHeadPlusThree = hp_gear("Ankusa Helm +3", 56)  --WSD 10, Haste 8, Macc 37, MDB 4, Acc 37
gear.ankusaHeadPlusFour = hp_gear("Ankusa Helm +4", 66)  --WSD 12, Haste 8, Macc 42, MDB 5, Acc 42
gear.ankusaBody = hp_gear("Ankusa Jackcoat", 28)  --Haste 4, MDB 3
gear.ankusaBodyPlusOne = hp_gear("An. Jackcoat +1", 59)  --Haste 4, MDB 6
gear.ankusaBodyPlusTwo = hp_gear("An. Jackcoat +2", 69)  --Haste 4, Macc 30, MDB 7, Acc 30, Att 50
gear.ankusaBodyPlusThree = hp_gear("An. Jackcoat +3", 79)  --Haste 4, Macc 40, MDB 8, Acc 40, Att 65
gear.ankusaBodyPlusFour = hp_gear("An. Jackcoat +4", 89)  --Haste 4, Macc 45, MDB 9, Acc 45, Att 75
gear.ankusaHands = hp_gear("Ankusa Gloves", 11)  --Haste 4, MDB 1
gear.ankusaHandsPlusOne = hp_gear("Ankusa Gloves +1", 25)  --Haste 5, MDB 2
gear.ankusaHandsPlusTwo = hp_gear("Ankusa Gloves +2", 35)  --Haste 5, Macc 28, MDB 3, Acc 28, Att 48
gear.ankusaHandsPlusThree = hp_gear("Ankusa Gloves +3", 45)  --Haste 5, Macc 38, MDB 4, Acc 38, Att 63
gear.ankusaHandsPlusFour = hp_gear("Ankusa Gloves +4", 55)  --Haste 5, Macc 43, MDB 5, Acc 43, Att 73
gear.ankusaLegs = hp_gear("Ankusa Trousers", 22)  --Haste 6, MDB 2
gear.ankusaLegsPlusOne = hp_gear("Ankusa Trousers +1", 47)  --Haste 6, MDB 5
gear.ankusaLegsPlusTwo = hp_gear("Ankusa Trousers +2", 57)  --Haste 6, Macc 29, MDB 6, Acc 29, Att 49
gear.ankusaLegsPlusThree = hp_gear("Ankusa Trousers +3", 67)  --Haste 6, Macc 39, MDB 7, Acc 39, Att 64
gear.ankusaLegsPlusFour = hp_gear("An. Trousers +4", 77)  --Haste 6, Macc 44, MDB 8, Acc 44, Att 74
gear.ankusaFeet = hp_gear("Ankusa Gaiters", 6)  --Haste 4, MDB 2
gear.ankusaFeetPlusOne = hp_gear("Ankusa Gaiters +1", 13)  --Haste 4, MDB 5
gear.ankusaFeetPlusTwo = hp_gear("Ankusa Gaiters +2", 23)  --Haste 4, Macc 26, MDB 6, Acc 26, Att 46
gear.ankusaFeetPlusThree = hp_gear("Ankusa Gaiters +3", 33)  --Haste 4, Macc 36, MDB 7, Acc 36, Att 61
gear.ankusaFeetPlusFour = hp_gear("Ankusa Gaiters +4", 43)  --Haste 4, Macc 41, MDB 8, Acc 41, Att 71

--BST Empyrean (90-era) (Set: Attack occ. varies with pet's HP)
gear.ferineHead = hp_gear("Ferine Cabasset", 0)  --Acc 3
gear.ferineHeadPlusOne = hp_gear("Ferine Cabasset +1", 0)  --Haste 5, Acc 6
gear.ferineHeadPlusTwo = hp_gear("Ferine Cabasset +2", 0)  --Haste 6, Acc 8
gear.ferineBody = hp_gear("Ferine Gausape", 0)  --Acc 5, Att 5
gear.ferineBodyPlusOne = hp_gear("Ferine Gausape +1", 0)  --Acc 15, Att 15, Axe Skill 5
gear.ferineBodyPlusTwo = hp_gear("Ferine Gausape +2", 0)  --Haste 2, Acc 18, Att 18, Axe Skill 7
gear.ferineHands = hp_gear("Ferine Manoplas", 0)  --Att 5
gear.ferineHandsPlusOne = hp_gear("Frn. Manoplas +1", 0)  --Att 10
gear.ferineHandsPlusTwo = hp_gear("Frn. Manoplas +2", 0)  --Att 15
gear.ferineLegs = hp_gear("Ferine Quijotes", 0)  --Acc 2, Att 2
gear.ferineLegsPlusOne = hp_gear("Ferine Quijotes +1", 0)  --Haste 6, Acc 5, Att 5
gear.ferineLegsPlusTwo = hp_gear("Ferine Quijotes +2", 0)  --Haste 7, Acc 7, Att 7
gear.ferineFeet = hp_gear("Ferine Ocreae", 0)  --Acc 2
gear.ferineFeetPlusOne = hp_gear("Ferine Ocreae +1", 0)  --DA 2, Acc 5
gear.ferineFeetPlusTwo = hp_gear("Ferine Ocreae +2", 0)  --DA 3, Acc 8

--BST Empyrean Reforged (REA Set: Attack occ. varies with pet's HP)
gear.nukumiHead = hp_gear("Nukumi Cabasset", 20)  --Haste 7, MDB 1, Acc 16
gear.nukumiHeadPlusOne = hp_gear("Nuk. Cabasset +1", 43)  --Haste 8, MDB 2, Acc 26
gear.nukumiHeadPlusTwo = hp_gear("Nuk. Cabasset +2", 63)  --Haste 8, Macc 51, MDB 5, Racc 51, Acc 51
gear.nukumiHeadPlusThree = hp_gear("Nuk. Cabasset +3", 73)  --Haste 8, Macc 61, MDB 6, Racc 61, Acc 61
gear.nukumiBody = hp_gear("Nukumi Gausape", 31)  --Haste 3, MDB 2, Acc 18, Att 18, Axe Skill 9
gear.nukumiBodyPlusOne = hp_gear("Nukumi Gausape +1", 66)  --Haste 3, MDB 4, Acc 25, Att 25, Axe Skill 11
gear.nukumiBodyPlusTwo = hp_gear("Nukumi Gausape +2", 86)  --WSD 8, Haste 3, Macc 54, MDB 7, Racc 54
gear.nukumiBodyPlusThree = hp_gear("Nukumi Gausape +3", 96)  --WSD 12, Haste 3, Macc 64, MDB 8, Racc 64
gear.nukumiHands = hp_gear("Nukumi Manoplas", 12)  --Haste 3, Att 15
gear.nukumiHandsPlusOne = hp_gear("Nukumi Manoplas +1", 27)  --Haste 4, MDB 1, Att 25
gear.nukumiHandsPlusTwo = hp_gear("Nukumi Manoplas +2", 47)  --Haste 4, Macc 52, Racc 52
gear.nukumiHandsPlusThree = hp_gear("Nukumi Manoplas +3", 57)  --Haste 4, Macc 62, Racc 62
gear.nukumiLegs = hp_gear("Nukumi Quijotes", 23)  --Haste 7, MDB 1, Acc 15, Att 15
gear.nukumiLegsPlusOne = hp_gear("Nukumi Quijotes +1", 50)  --Haste 8, MDB 3, Acc 25, Att 25
gear.nukumiLegsPlusTwo = hp_gear("Nukumi Quijotes +2", 70)  --Haste 8, Macc 53, MDB 6, Racc 53, Acc 53
gear.nukumiLegsPlusThree = hp_gear("Nukumi Quijotes +3", 80)  --Haste 8, Macc 63, MDB 7, Racc 63, Acc 63
gear.nukumiFeet = hp_gear("Nukumi Ocreae", 7)  --DA 3, Haste 3, MDB 1, Acc 17
gear.nukumiFeetPlusOne = hp_gear("Nukumi Ocreae +1", 15)  --DA 4, Haste 3, MDB 2, Acc 27
gear.nukumiFeetPlusTwo = hp_gear("Nukumi Ocreae +2", 35)  --DA 5, Haste 3, Macc 50, MDB 5, Racc 50
gear.nukumiFeetPlusThree = hp_gear("Nukumi Ocreae +3", 45)  --DA 6, Haste 3, Macc 60, MDB 6, Racc 60

--BRD Artifact (75-era)
gear.choralHead = hp_gear("Choral Roundlet", 11)  --Enmity -1, Parrying Skill 5
gear.choralHeadPlusOne = hp_gear("Chl. Roundlet +1", 11)  --Enmity -2, Parrying Skill 5
gear.choralBody = hp_gear("Choral Jstcorps", 13)  --Enmity -1, String instrument Skill 3
gear.choralBodyPlusOne = hp_gear("Chl. Jstcorps +1", 20)  --Enmity -3, String instrument Skill 6
gear.choralHands = hp_gear("Choral Cuffs", 14)  --Enmity -1, Singing Skill 5
gear.choralHandsPlusOne = hp_gear("Chl. Cuffs +1", 14)  --Enmity -1, Singing Skill 10
gear.choralLegs = hp_gear("Choral Cannions", 12)  --Enmity -1, Wind instruments Skill 3
gear.choralLegsPlusOne = hp_gear("Chl. Cannions +1", 12)  --Enmity -2, Wind instrument Skill 8
gear.choralFeet = hp_gear("Choral Slippers", 10)  --AGI 3
gear.choralFeetPlusOne = hp_gear("Chl. Slippers +1", 10)  --DEX 5, AGI 5

--BRD Artifact Reforged (Set: Increases Accuracy, Ranged Accuracy, and Magic Accuracy)
gear.briosoHead = hp_gear("Brioso Roundlet", 17)  --Haste 5, Macc 12, MDB 2, Parrying Skill 8, String instrument Skill 7
gear.briosoHeadPlusOne = hp_gear("Brioso Roundlet +1", 36)  --Haste 6, Macc 29, MDB 5, Parrying Skill 8, String instrument Skill 9
gear.briosoHeadPlusThree = hp_gear("Brioso Roundlet +3", 64)  --Haste 6, Macc 61, MDB 6, Parrying Skill 12, String instrument Skill 13
gear.briosoHeadPlusFour = hp_gear("Brioso Roundlet +4", 74)  --Haste 6, Macc 71, MDB 7, Acc 71, Parrying Skill 13
gear.briosoBody = hp_gear("Brioso Just.", 25)  --Haste 2, Macc 12, MDB 3, Enmity -4, Singing Skill 10
gear.briosoBodyPlusOne = hp_gear("Brioso Just. +1", 54)  --Haste 3, Macc 29, MDB 6, Enmity -4, Singing Skill 13
gear.briosoBodyPlusTwo = hp_gear("Brioso Justau. +2", 81)  --Haste 3, Macc 54, MDB 6, Enmity -5, Singing Skill 15
gear.briosoBodyPlusFour = hp_gear("Brioso Just. +4", 101)  --Haste 3, Macc 74, MDB 8, Acc 74, Enmity -6
gear.briosoHands = hp_gear("Brioso Cuffs", 10)  --Haste 3, MDB 1, Enmity -5, Singing Skill 13
gear.briosoHandsPlusOne = hp_gear("Brioso Cuffs +1", 22)  --Haste 3, MDB 3, Enmity -6, Singing Skill 13
gear.briosoHandsPlusTwo = hp_gear("Brioso Cuffs +2", 33)  --Haste 3, Macc 38, MDB 3, Enmity -7, Singing Skill 15
gear.briosoHandsPlusThree = hp_gear("Brioso Cuffs +3", 43)  --Haste 3, Macc 48, MDB 4, Enmity -8, Singing Skill 17
gear.briosoLegs = hp_gear("Brioso Cannions", 20)  --Haste 4, Macc 6, MDB 3, Enmity -3, Wind instrument Skill 13
gear.briosoLegsPlusOne = hp_gear("Brioso Cann. +1", 43)  --Haste 5, Macc 14, MDB 6, Enmity -3, Wind instrument Skill 15
gear.briosoLegsPlusThree = hp_gear("Brioso Cannions +3", 74)  --Haste 5, Macc 56, MDB 7, Enmity -5, Wind instrument Skill 19
gear.briosoLegsPlusFour = hp_gear("Brios. Cann. +4", 84)  --Haste 5, Macc 66, MDB 8, Acc 66, Enmity -5
gear.briosoFeet = hp_gear("Brioso Slippers", 36)  --Haste 3, MDB 2, Wind instrument Skill 10
gear.briosoFeetPlusOne = hp_gear("Brioso Slippers +1", 43)  --Haste 3, MDB 5, Wind instrument Skill 10
gear.briosoFeetPlusTwo = hp_gear("Brioso Slippers +2", 64)  --Haste 3, Macc 36, MDB 5, Wind instrument Skill 12
gear.briosoFeetPlusThree = hp_gear("Brioso Slippers +3", 74)  --Haste 3, Macc 46, MDB 6, Wind instrument Skill 14

--BRD Relic (75-era)
gear.bardHead = hp_gear("Bard's Roundlet", 13)  --Enmity -3, Singing Skill 5
gear.bardHeadPlusOne = hp_gear("Brd. Roundlet +1", 13)  --Enmity -4, Singing Skill 5
gear.bardHeadPlusTwo = hp_gear("Brd. Roundlet +2", 18)  --Enmity -6, Singing Skill 7
gear.bardBody = hp_gear("Bard's Jstcorps", 19)  --Att 18
gear.bardBodyPlusOne = hp_gear("Brd. Jstcorps +1", 19)  --Att 20
gear.bardBodyPlusTwo = hp_gear("Brd. Jstcorps +2", 27)  --Acc 25, Att 25
gear.bardHands = hp_gear("Bard's Cuffs", 16)  --Enmity -3, Wind instrument Skill 3
gear.bardHandsPlusOne = hp_gear("Brd. Cuffs +1", 16)  --Enmity -4, Wind instrument Skill 5
gear.bardHandsPlusTwo = hp_gear("Brd. Cuffs +2", 22)  --Macc 5, Enmity -6, Wind instrument Skill 7
gear.bardLegs = hp_gear("Bard's Cannions", 17)
gear.bardLegsPlusOne = hp_gear("Brd. Cannions +1", 26)
gear.bardLegsPlusTwo = hp_gear("Brd. Cannions +2", 50)  --Macc 6
gear.bardFeet = hp_gear("Bard's Slippers", 12)  --Enmity -2, Parrying Skill 3, String instrument Skill 3
gear.bardFeetPlusOne = hp_gear("Brd. Slippers +1", 12)  --Enmity -3, Parrying Skill 4, String instrument Skill 3
gear.bardFeetPlusTwo = hp_gear("Brd. Slippers +2", 17)  --Enmity -5, String instrument Skill 5

--BRD Relic Reforged (REA Set: Augments songs)
gear.bihuHead = hp_gear("Bihu Roundlet", 17)  --Haste 5, Macc 12, MDB 2, Enmity -6, Singing Skill 12
gear.bihuHeadPlusOne = hp_gear("Bihu Roundlet +1", 36)  --Haste 6, Macc 29, MDB 5, Enmity -7, Singing Skill 14
gear.bihuHeadPlusTwo = hp_gear("Bihu Roundlet +2", 46)  --Haste 6, Macc 41, MDB 6, Acc 27, Att 47
gear.bihuHeadPlusThree = hp_gear("Bihu Roundlet +3", 56)  --Haste 6, Macc 51, MDB 7, Acc 37, Att 62
gear.bihuHeadPlusFour = hp_gear("Bihu Roundlet +4", 66)  --Haste 6, Macc 56, MDB 8, Acc 42, Att 72
gear.bihuBody = hp_gear("Bihu Justaucorps", 40)  --Haste 2, Macc 12, MDB 3, Acc 27, Att 27
gear.bihuBodyPlusOne = hp_gear("Bihu Jstcorps +1", 69)  --Haste 3, Macc 29, MDB 6, Acc 27, Att 27
gear.bihuBodyPlusTwo = hp_gear("Bihu Jstcorps. +2", 79)  --WSD 5, Haste 3, Macc 44, MDB 7, Acc 43
gear.bihuBodyPlusThree = hp_gear("Bihu Jstcorps. +3", 89)  --WSD 10, Haste 3, Macc 54, MDB 8, Acc 53
gear.bihuBodyPlusFour = hp_gear("Bihu Just. +4", 99)  --WSD 12, Haste 3, Macc 59, MDB 9, Acc 58
gear.bihuHands = hp_gear("Bihu Cuffs", 10)  --Haste 3, Macc 10, MDB 1, Enmity -6, Wind instrument Skill 9
gear.bihuHandsPlusOne = hp_gear("Bihu Cuffs +1", 22)  --Haste 3, Macc 13, MDB 3, Enmity -7, Wind instrument Skill 11
gear.bihuHandsPlusTwo = hp_gear("Bihu Cuffs +2", 32)  --Haste 3, Macc 34, MDB 4, Acc 28, Att 48
gear.bihuHandsPlusThree = hp_gear("Bihu Cuffs +3", 42)  --Haste 3, Macc 44, MDB 5, Acc 38, Att 63
gear.bihuHandsPlusFour = hp_gear("Bihu Cuffs +4", 52)  --Haste 3, Macc 49, MDB 6, Acc 43, Att 73
gear.bihuLegs = hp_gear("Bihu Cannions", 60)  --Haste 4, Macc 16, MDB 3
gear.bihuLegsPlusOne = hp_gear("Bihu Cannions +1", 83)  --Haste 5, Macc 27, MDB 6
gear.bihuLegsPlusTwo = hp_gear("Bihu Cannions +2", 93)  --Haste 5, Macc 42, MDB 7, Acc 29, Att 49
gear.bihuLegsPlusThree = hp_gear("Bihu Cannions +3", 103)  --Haste 5, Macc 52, MDB 8, Acc 39, Att 64
gear.bihuLegsPlusFour = hp_gear("Bihu Cann. +4", 113)  --Haste 5, Macc 57, MDB 9, Acc 44, Att 74
gear.bihuFeet = hp_gear("Bihu Slippers", 6)  --Haste 3, MDB 2, Enmity -5, String instrument Skill 9
gear.bihuFeetPlusOne = hp_gear("Bihu Slippers +1", 13)  --Haste 3, MDB 5, Enmity -6, String instrument Skill 11
gear.bihuFeetPlusTwo = hp_gear("Bihu Slippers +2", 23)  --Haste 3, Macc 26, MDB 6, Acc 26, Att 46
gear.bihuFeetPlusThree = hp_gear("Bihu Slippers +3", 33)  --Haste 3, Macc 36, MDB 7, Acc 36, Att 61
gear.bihuFeetPlusFour = hp_gear("Bihu Slippers +4", 43)  --Haste 3, Macc 41, MDB 8, Acc 41, Att 71

--BRD Empyrean (90-era) (Set: Augments songs)
gear.aoidosHead = hp_gear("Aoidos' Calot", 0)  --Enmity -2
gear.aoidosHeadPlusOne = hp_gear("Aoidos' Calot +1", 0)  --Enmity -5
gear.aoidosHeadPlusTwo = hp_gear("Aoidos' Calot +2", 0)  --Enmity -7
gear.aoidosBody = hp_gear("Aoidos' Hongreline", 0)  --CHR 3
gear.aoidosBodyPlusOne = hp_gear("Aoidos' Hngrln. +1", 0)  --Singing Skill 8, Wind instrument Skill 8
gear.aoidosBodyPlusTwo = hp_gear("Aoidos' Hngrln. +2", 0)  --Singing Skill 10, Wind instrument Skill 10
gear.aoidosHands = hp_gear("Aoidos' Mnchtte.", 0)  --Macc 2
gear.aoidosHandsPlusOne = hp_gear("Ad. Mnchtte. +1", 0)  --Macc 6, Singing Skill 6, String instrument Skill 6, Wind instrument Skill 6
gear.aoidosHandsPlusTwo = hp_gear("Ad. Mnchtte. +2", 0)  --Macc 8, Singing Skill 8, String instrument Skill 8, Wind instrument Skill 8
gear.aoidosLegs = hp_gear("Aoidos' Rhingrave", 0)
gear.aoidosLegsPlusOne = hp_gear("Aoidos' Rhing. +1", 0)  --Macc 5, Singing Skill 8
gear.aoidosLegsPlusTwo = hp_gear("Aoidos' Rhing. +2", 0)  --Macc 7, Singing Skill 10
gear.aoidosFeet = hp_gear("Aoidos' Cothurnes", 0)  --CHR 3
gear.aoidosFeetPlusOne = hp_gear("Aoidos' Cothrn. +1", 0)  --CHR 9
gear.aoidosFeetPlusTwo = hp_gear("Aoidos' Cothrn. +2", 0)  --CHR 11

--BRD Empyrean Reforged (REA Set: Augments songs)
gear.filiLegs = hp_gear("Fili Rhingrave", 20)  --Haste 4, Macc 17, MDB 3, Singing Skill 15
gear.filiLegsPlusOne = hp_gear("Fili Rhingrave +1", 43)  --Haste 5, Macc 27, MDB 6, Singing Skill 18
gear.filiLegsPlusTwo = hp_gear("Fili Rhingrave +2", 63)  --Haste 5, Macc 53, MDB 9, Acc 53, Singing Skill 23
gear.filiLegsPlusThree = hp_gear("Fili Rhingrave +3", 73)  --Haste 5, Macc 63, MDB 10, Acc 63, Singing Skill 28

--RNG Artifact (75-era)
gear.hunterHead = hp_gear("Hunter's Beret", 13)  --Ratt 5
gear.hunterHeadPlusOne = hp_gear("Htr. Beret +1", 13)  --Ratt 5
gear.hunterBody = hp_gear("Hunter's Jerkin", 20)  --Racc 10
gear.hunterBodyPlusOne = hp_gear("Htr. Jerkin +1", 20)  --Racc 10
gear.hunterHands = hp_gear("Hunter's Bracers", 10)  --DEX 3
gear.hunterHandsPlusOne = hp_gear("Htr. Bracers +1", 10)  --DEX 6, AGI 6
gear.hunterLegs = hp_gear("Hunter's Braccae", 15)  --MND 5
gear.hunterLegsPlusOne = hp_gear("Htr. Braccae +1", 15)  --Enmity -3
gear.hunterFeet = hp_gear("Hunter's Socks", 10)  --AGI 4
gear.hunterFeetPlusOne = hp_gear("Htr. Socks +1", 10)  --DEX 6, AGI 6

--RNG Artifact Reforged (Set: Increases Accuracy, Ranged Accuracy, and Magic Accuracy)
gear.orionHead = hp_gear("Orion Beret", 17)  --Haste 7, MDB 1, Ratt 14, Enmity -5
gear.orionHeadPlusOne = hp_gear("Orion Beret +1", 36)  --Rapid Shot 14, Haste 8, MDB 2, Ratt 14, Enmity -5
gear.orionHeadPlusTwo = hp_gear("Orion Beret +2", 54)  --WSD 5, Rapid Shot 16, Haste 8, MDB 2, Racc 37
gear.orionHeadPlusThree = hp_gear("Orion Beret +3", 64)  --WSD 10, Rapid Shot 18, Haste 8, MDB 3, Racc 47
gear.orionHeadPlusFour = hp_gear("Orion Beret +4", 74)  --WSD 12, Rapid Shot 18, Haste 8, Macc 57, MDB 4
gear.orionBody = hp_gear("Orion Jerkin", 28)  --Haste 4, MAB 10, Macc 10, MDB 3, Racc 18
gear.orionBodyPlusOne = hp_gear("Orion Jerkin +1", 59)  --Haste 4, MAB 10, Macc 10, MDB 6, Racc 21
gear.orionBodyPlusTwo = hp_gear("Orion Jerkin +2", 88)  --STP 4, Haste 4, MAB 15, Macc 20, MDB 6
gear.orionBodyPlusThree = hp_gear("Orion Jerkin +3", 98)  --STP 8, Haste 4, MAB 20, Macc 30, MDB 7
gear.orionBodyPlusFour = hp_gear("Orion Jerkin +4", 108)  --STP 8, Haste 4, MAB 22, Macc 70, MDB 8
gear.orionHands = hp_gear("Orion Bracers", 11)  --Haste 4, MDB 1, Enmity -4
gear.orionHandsPlusOne = hp_gear("Orion Bracers +1", 25)  --Haste 5, MDB 2, Enmity -4
gear.orionHandsPlusTwo = hp_gear("Orion Bracers +2", 37)  --Haste 5, MDB 2, Racc 38, Enmity -5
gear.orionHandsPlusThree = hp_gear("Orion Bracers +3", 47)  --Haste 5, MDB 3, Racc 48, Enmity -6
gear.orionHandsPlusFour = hp_gear("Orion Bracers +4", 57)  --Haste 5, Macc 58, MDB 4, Racc 58, Enmity -6
gear.orionLegs = hp_gear("Orion Braccae", 22)  --Haste 6, MDB 2, Racc 15, Enmity -4
gear.orionLegsPlusOne = hp_gear("Orion Braccae +1", 47)  --Haste 6, MDB 5, Racc 15, Enmity -5
gear.orionLegsPlusTwo = hp_gear("Orion Braccae +2", 70)  --Snapshot 10, Haste 6, MDB 5, Racc 46, Enmity -6
gear.orionLegsPlusThree = hp_gear("Orion Braccae +3", 80)  --Snapshot 15, Haste 6, MDB 6, Racc 56, Enmity -7
gear.orionLegsPlusFour = hp_gear("Orion Braccae +4", 90)  --Snapshot 15, Haste 6, Macc 66, MDB 7, Racc 66
gear.orionFeet = hp_gear("Orion Socks", 6)  --Haste 4, MDB 2, Racc 13, Ratt 13, Enmity -4
gear.orionFeetPlusOne = hp_gear("Orion Socks +1", 13)  --Haste 4, MDB 5, Racc 16, Ratt 16, Enmity -4
gear.orionFeetPlusTwo = hp_gear("Orion Socks +2", 19)  --Haste 4, MDB 5, Racc 44, Ratt 26, Enmity -5
gear.orionFeetPlusThree = hp_gear("Orion Socks +3", 29)  --Haste 4, MDB 6, Racc 54, Ratt 36, Enmity -6
gear.orionFeetPlusFour = hp_gear("Orion Socks +4", 39)  --Haste 4, Macc 64, MDB 7, Racc 64, Ratt 41

--RNG Relic (75-era)
gear.scoutHead = hp_gear("Scout's Beret", 15)  --Enmity -3
gear.scoutHeadPlusOne = hp_gear("Sct. Beret +1", 15)  --Enmity -4
gear.scoutHeadPlusTwo = hp_gear("Sct. Beret +2", 21)  --Enmity -5
gear.scoutBody = hp_gear("Scout's Jerkin", 23)  --Rapid Shot 5, Enmity -3
gear.scoutBodyPlusOne = hp_gear("Sct. Jerkin +1", 23)  --Rapid Shot 5, Enmity -4
gear.scoutBodyPlusTwo = hp_gear("Sct. Jerkin +2", 0)  --Rapid Shot 7, Enmity -5
gear.scoutHands = hp_gear("Scout's Bracers", 13)  --Enmity -2
gear.scoutHandsPlusOne = hp_gear("Sct. Bracers +1", 13)  --Enmity -2
gear.scoutHandsPlusTwo = hp_gear("Sct. Bracers +2", 18)  --Ratt 11, Enmity -3
gear.scoutLegs = hp_gear("Scout's Braccae", 18)  --Racc 7, Enmity -2, Parrying Skill 10
gear.scoutLegsPlusOne = hp_gear("Sct. Braccae +1", 18)  --Racc 9, Enmity -3, Parrying Skill 10
gear.scoutLegsPlusTwo = hp_gear("Sct. Braccae +2", 25)  --Racc 11, Ratt 11, Enmity -4
gear.scoutFeet = hp_gear("Scout's Socks", 12)  --Ratt 10, Enmity -3
gear.scoutFeetPlusOne = hp_gear("Sct. Socks +1", 12)  --Ratt 12, Enmity -4
gear.scoutFeetPlusTwo = hp_gear("Sct. Socks +2", 17)  --Ratt 15, Enmity -5

--RNG Relic Reforged (REA Set: Augments "Rapid Shot")
gear.arcadianHead = hp_gear("Arcadian Beret", 17)  --Rapid Shot 8, Haste 7, MDB 1, Enmity -5
gear.arcadianHeadPlusOne = hp_gear("Arcadian Beret +1", 36)  --Rapid Shot 10, Haste 8, MDB 2, Enmity -6
gear.arcadianHeadPlusTwo = hp_gear("Arcadian Beret +2", 46)  --Rapid Shot 12, Haste 8, Macc 27, MDB 3, Racc 27
gear.arcadianHeadPlusThree = hp_gear("Arcadian Beret +3", 56)  --Rapid Shot 14, Haste 8, Macc 37, MDB 4, Racc 37
gear.arcadianHeadPlusFour = hp_gear("Arcadian Beret +4", 66)  --Rapid Shot 14, Haste 8, Macc 42, MDB 5, Racc 42
gear.arcadianBody = hp_gear("Arcadian Jerkin", 28)  --Rapid Shot 10, Haste 4, MDB 3, Enmity -5
gear.arcadianBodyPlusOne = hp_gear("Arc. Jerkin +1", 59)  --Rapid Shot 12, Haste 4, MDB 6, Enmity -6
gear.arcadianBodyPlusTwo = hp_gear("Arc. Jerkin +2", 69)  --Rapid Shot 14, Haste 4, Macc 30, MDB 7, Racc 30
gear.arcadianBodyPlusThree = hp_gear("Arc. Jerkin +3", 79)  --Rapid Shot 16, Haste 4, Macc 40, MDB 8, Racc 40
gear.arcadianBodyPlusFour = hp_gear("Arc. Jerkin +4", 89)  --Rapid Shot 16, Haste 4, Macc 45, MDB 9, Racc 45
gear.arcadianHands = hp_gear("Arcadian Bracers", 11)  --Snapshot 3, Haste 4, MDB 1, Ratt 13, Enmity -3
gear.arcadianHandsPlusOne = hp_gear("Arc. Bracers +1", 25)  --Snapshot 4, Haste 5, MDB 2, Ratt 16, Enmity -4
gear.arcadianHandsPlusTwo = hp_gear("Arc. Bracers +2", 35)  --Snapshot 5, Haste 5, Macc 28, MDB 3, Racc 28
gear.arcadianHandsPlusThree = hp_gear("Arc. Bracers +3", 45)  --Snapshot 6, Haste 5, Macc 38, MDB 4, Racc 38
gear.arcadianHandsPlusFour = hp_gear("Arc. Bracers +4", 55)  --Snapshot 6, Haste 5, Macc 43, MDB 5, Racc 43
gear.arcadianLegs = hp_gear("Arcadian Braccae", 42)  --Snapshot 4, Haste 6, MDB 2, Racc 14, Ratt 14
gear.arcadianLegsPlusOne = hp_gear("Arc. Braccae +1", 67)  --Snapshot 5, Haste 6, MDB 5, Racc 17, Ratt 17
gear.arcadianLegsPlusTwo = hp_gear("Arc. Braccae +2", 77)  --WSD 5, Snapshot 6, Haste 6, Macc 29, MDB 6
gear.arcadianLegsPlusThree = hp_gear("Arc. Braccae +3", 87)  --WSD 10, Snapshot 7, Haste 6, Macc 39, MDB 7
gear.arcadianLegsPlusFour = hp_gear("Arc. Braccae +4", 97)  --WSD 12, Snapshot 7, Haste 6, Macc 44, MDB 8
gear.arcadianFeet = hp_gear("Arcadian Socks", 6)  --Rapid Shot 4, Haste 4, MDB 2, Ratt 17, Enmity -5
gear.arcadianFeetPlusOne = hp_gear("Arcadian Socks +1", 13)  --Rapid Shot 6, Haste 4, MDB 5, Ratt 20, Enmity -6
gear.arcadianFeetPlusTwo = hp_gear("Arcadian Socks +2", 23)  --Rapid Shot 8, Haste 4, Macc 26, MDB 6, Racc 26
gear.arcadianFeetPlusThree = hp_gear("Arcadian Socks +3", 33)  --Rapid Shot 10, Haste 4, Macc 36, MDB 7, Racc 36
gear.arcadianFeetPlusFour = hp_gear("Arc. Socks +4", 43)  --Rapid Shot 10, Haste 4, Macc 41, MDB 8, Racc 41

--RNG Empyrean (90-era) (Set: Augments "Rapid Shot")
gear.sylvanHead = hp_gear("Sylvan Gapette", 0)  --Racc 3, Ratt 3
gear.sylvanHeadPlusOne = hp_gear("Sylvan Gapette +1", 0)  --Racc 9, Ratt 9, SB 5
gear.sylvanHeadPlusTwo = hp_gear("Sylvan Gapette +2", 0)  --Racc 13, Ratt 13, SB 10
gear.sylvanBody = hp_gear("Sylvan Caban", 0)  --Racc 6
gear.sylvanBodyPlusOne = hp_gear("Sylvan Caban +1", 0)  --Racc 15, Enmity -7
gear.sylvanBodyPlusTwo = hp_gear("Sylvan Caban +2", 0)  --Racc 20, Enmity -9
gear.sylvanHands = hp_gear("Syl. Glovelettes", 0)  --STR 3
gear.sylvanHandsPlusOne = hp_gear("Syl. Glvltte. +1", 0)  --STP 4, Archery Skill 5
gear.sylvanHandsPlusTwo = hp_gear("Syl. Glvltte. +2", 0)  --STP 7, Archery Skill 7
gear.sylvanLegs = hp_gear("Sylvan Bragues", 0)  --Ratt 3
gear.sylvanLegsPlusOne = hp_gear("Sylvan Bragues +1", 0)  --STP 6, Ratt 9
gear.sylvanLegsPlusTwo = hp_gear("Sylvan Bragues +2", 0)  --STP 9, Ratt 12
gear.sylvanFeet = hp_gear("Sylvan Bottillons", 0)  --AGI 4
gear.sylvanFeetPlusOne = hp_gear("Sylvan Bottln. +1", 0)  --Enmity -5, Marksmanship Skill 5
gear.sylvanFeetPlusTwo = hp_gear("Sylvan Bottln. +2", 0)  --Enmity -8, Marksmanship Skill 7

--RNG Empyrean Reforged (REA Set: Augments "Rapid Shot")
gear.aminiHead = hp_gear("Amini Gapette", 16)  --Snapshot 6, Haste 7, MDB 1, Racc 16, Ratt 16
gear.aminiHeadPlusOne = hp_gear("Amini Gapette +1", 34)  --Snapshot 7, Haste 8, MDB 3, Racc 26, Ratt 26
gear.aminiHeadPlusTwo = hp_gear("Amini Gapette +2", 54)  --Snapshot 8, Haste 8, Macc 51, MDB 6, Racc 51
gear.aminiHeadPlusThree = hp_gear("Amini Gapette +3", 64)  --Snapshot 9, Haste 8, Macc 61, MDB 7, Racc 61
gear.aminiBody = hp_gear("Amini Caban", 27)  --Haste 4, MDB 3, Racc 20, Enmity -10
gear.aminiBodyPlusOne = hp_gear("Amini Caban +1", 57)  --Haste 4, MDB 6, Racc 27, Enmity -11
gear.aminiBodyPlusTwo = hp_gear("Amini Caban +2", 77)  --Haste 4, Macc 54, MDB 9, Racc 54, Ratt 54
gear.aminiBodyPlusThree = hp_gear("Amini Caban +3", 87)  --Haste 4, Macc 64, MDB 10, Racc 64, Ratt 64
gear.aminiHands = hp_gear("Amini Glovelettes", 10)  --STP 8, Haste 4, MDB 1, Archery Skill 18
gear.aminiHandsPlusOne = hp_gear("Amini Glove. +1", 22)  --STP 9, Haste 5, MDB 2, Archery Skill 28
gear.aminiHandsPlusTwo = hp_gear("Amini Glove. +2", 42)  --STP 10, Haste 5, Macc 52, MDB 5, Racc 52
gear.aminiHandsPlusThree = hp_gear("Amini Glove. +3", 52)  --STP 11, Haste 5, Macc 62, MDB 6, Racc 62
gear.aminiLegs = hp_gear("Amini Bragues", 21)  --STP 9, Haste 6, MDB 2, Ratt 13
gear.aminiLegsPlusOne = hp_gear("Amini Bragues +1", 45)  --STP 10, Haste 6, MDB 5, Ratt 23
gear.aminiLegsPlusTwo = hp_gear("Amini Bragues +2", 65)  --STP 11, Haste 6, Macc 53, MDB 8, Racc 53
gear.aminiLegsPlusThree = hp_gear("Amini Bragues +3", 75)  --STP 12, Haste 6, Macc 63, MDB 9, Racc 63
gear.aminiFeet = hp_gear("Amini Bottillons", 5)  --Haste 4, MDB 2, Enmity -9, Marksmanship Skill 18
gear.aminiFeetPlusOne = hp_gear("Amini Bottillons +1", 11)  --Haste 4, MDB 5, Enmity -10, Marksmanship Skill 28
gear.aminiFeetPlusTwo = hp_gear("Amini Bottillons +2", 31)  --WSD 8, Haste 4, Macc 50, MDB 8, Racc 50
gear.aminiFeetPlusThree = hp_gear("Amini Bottillons +3", 41)  --WSD 12, Haste 4, Macc 60, MDB 9, Racc 60

--SAM Artifact (75-era)
gear.myochinHead = hp_gear("Myochin Kabuto", 10)  --MND 5
gear.myochinHeadPlusOne = hp_gear("Myn. Kabuto +1", 13)  --STR 5, MND 5
gear.myochinBody = hp_gear("Myochin Domaru", 10)  --VIT 3
gear.myochinBodyPlusOne = hp_gear("Myn. Domaru +1", 10)  --Acc 12
gear.myochinHands = hp_gear("Myochin Kote", 15)  --Enmity 2
gear.myochinHandsPlusOne = hp_gear("Myn. Kote +1", 15)  --Enmity 2
gear.myochinLegs = hp_gear("Myochin Haidate", 15)  --Parrying Skill 5
gear.myochinLegsPlusOne = hp_gear("Myn. Haidate +1", 15)  --STP 4, Parrying Skill 10
gear.myochinFeet = hp_gear("Myochin Sune-Ate", 20)  --Enmity 5, Evasion Skill 5
gear.myochinFeetPlusOne = hp_gear("Myn. Sune-Ate +1", 20)  --Att 8, Enmity 5

--SAM Artifact Reforged (Set: Increases Accuracy, Ranged Accuracy, and Magic Accuracy)
gear.wakidoHead = hp_gear("Wakido Kabuto", 18)  --Haste 6, MDB 1, Att 16
gear.wakidoHeadPlusOne = hp_gear("Wakido Kabuto +1", 38)  --Haste 7, MDB 2, Att 21
gear.wakidoHeadPlusTwo = hp_gear("Wakido Kabuto +2", 57)  --Haste 7, MDB 2, Acc 37, Att 31
gear.wakidoHeadPlusThree = hp_gear("Wakido Kabuto +3", 67)  --Haste 7, MDB 3, Acc 47, Att 41
gear.wakidoHeadPlusFour = hp_gear("Wakido Kabuto +4", 77)  --Haste 7, Macc 57, MDB 4, Acc 57, Att 46
gear.wakidoBody = hp_gear("Wakido Domaru", 29)  --STP 6, Haste 3, MDB 2, Acc 15
gear.wakidoBodyPlusOne = hp_gear("Wakido Domaru +1", 61)  --STP 7, Haste 3, MDB 4, Acc 15
gear.wakidoBodyPlusTwo = hp_gear("Wakido Domaru +2", 91)  --STP 8, Haste 3, MDB 4, Acc 47
gear.wakidoBodyPlusThree = hp_gear("Wakido Domaru +3", 101)  --STP 9, Haste 3, MDB 5, Acc 57
gear.wakidoBodyPlusFour = hp_gear("Wakido Domaru +4", 111)  --STP 9, Haste 3, Macc 67, MDB 6, Acc 67
gear.wakidoHands = hp_gear("Wakido Kote", 12)  --STP 5, Haste 3
gear.wakidoHandsPlusOne = hp_gear("Wakido Kote +1", 27)  --STP 5, Haste 4, MDB 1
gear.wakidoHandsPlusTwo = hp_gear("Wakido Kote +2", 40)  --STP 6, Haste 4, MDB 1, Acc 38
gear.wakidoHandsPlusThree = hp_gear("Wakido Kote +3", 50)  --STP 7, Haste 4, MDB 2, Acc 48
gear.wakidoHandsPlusFour = hp_gear("Wakido Kote +4", 60)  --STP 7, Haste 4, Macc 58, MDB 3, Acc 58
gear.wakidoLegs = hp_gear("Wakido Haidate", 23)  --STP 6, Haste 5, MDB 1, Ratt 20, Att 20
gear.wakidoLegsPlusOne = hp_gear("Wakido Haidate +1", 50)  --STP 7, Haste 5, MDB 3, Ratt 20, Att 20
gear.wakidoLegsPlusTwo = hp_gear("Wakido Haidate +2", 75)  --STP 8, WSD 5, Haste 5, MDB 3, Ratt 30
gear.wakidoLegsPlusThree = hp_gear("Wakido Haidate +3", 85)  --STP 9, WSD 10, Haste 5, MDB 4, Ratt 40
gear.wakidoLegsPlusFour = hp_gear("Wakido Haidate +4", 95)  --STP 9, WSD 12, Haste 5, Macc 59, MDB 5
gear.wakidoFeet = hp_gear("Wakido Sune-Ate", 7)  --Haste 3, MDB 1, Racc 20, Ratt 15, Acc 20
gear.wakidoFeetPlusOne = hp_gear("Waki. Sune-Ate +1", 15)  --Haste 3, MDB 2, Racc 20, Ratt 18, Acc 20
gear.wakidoFeetPlusTwo = hp_gear("Wakido Sune. +2", 22)  --Haste 3, MDB 2, Racc 30, Ratt 28, Acc 46
gear.wakidoFeetPlusThree = hp_gear("Wakido Sune. +3", 32)  --Haste 3, MDB 3, Racc 40, Ratt 38, Acc 56
gear.wakidoFeetPlusFour = hp_gear("Wakido Sune. +4", 42)  --Haste 3, Macc 66, MDB 4, Racc 50, Ratt 43

--SAM Relic (75-era)
gear.saotomeHead = hp_gear("Saotome Kabuto", 20)  --Racc 5, Acc 10, Enmity 1
gear.saotomeHeadPlusOne = hp_gear("Sao. Kabuto +1", 20)  --Racc 7, Acc 12, Enmity 1
gear.saotomeHeadPlusTwo = hp_gear("Sao. Kabuto +2", 28)  --Racc 9, Ratt 9, Acc 15, Att 15
gear.saotomeBody = hp_gear("Saotome Domaru", 34)  --STP 3, Enmity 1
gear.saotomeBodyPlusOne = hp_gear("Sao. Domaru +1", 34)  --STP 5, Enmity 1
gear.saotomeBodyPlusTwo = hp_gear("Sao. Domaru +2", 48)  --STP 7, Acc 9
gear.saotomeHands = hp_gear("Saotome Kote", 10)  --Att 10, Enmity 1
gear.saotomeHandsPlusOne = hp_gear("Sao. Kote +1", 20)  --Att 12, Enmity 1
gear.saotomeHandsPlusTwo = hp_gear("Sao. Kote +2", 28)  --Acc 15, Att 15
gear.saotomeLegs = hp_gear("Saotome Haidate", 18)  --Enmity 1
gear.saotomeLegsPlusOne = hp_gear("Sao. Haidate +1", 33)  --Enmity 1
gear.saotomeLegsPlusTwo = hp_gear("Sao. Haidate +2", 0)  --Att 8
gear.saotomeFeet = hp_gear("Saotome Sune-Ate", 23)  --Att 8, Enmity 1
gear.saotomeFeetPlusOne = hp_gear("Sao. Sune-Ate +1", 23)  --Att 10, Enmity 1
gear.saotomeFeetPlusTwo = hp_gear("Sao. Sune-Ate +2", 32)  --STP 5, Att 12

--SAM Relic Reforged (REA Set: Augments "Zanshin")
gear.sakonjiHead = hp_gear("Sakonji Kabuto", 38)  --STP 5, Haste 6, MDB 1, Racc 15, Ratt 15
gear.sakonjiHeadPlusOne = hp_gear("Sakonji Kabuto +1", 58)  --STP 6, Haste 7, MDB 2, Racc 17, Ratt 17
gear.sakonjiHeadPlusTwo = hp_gear("Sakonji Kabuto +2", 68)  --STP 7, Snapshot 3, Haste 7, Macc 27, MDB 3
gear.sakonjiHeadPlusThree = hp_gear("Sakonji Kabuto +3", 78)  --STP 8, Snapshot 5, Haste 7, Macc 37, MDB 4
gear.sakonjiHeadPlusFour = hp_gear("Sakonji Kabuto +4", 88)  --STP 8, Snapshot 5, Haste 7, Macc 42, MDB 5
gear.sakonjiBody = hp_gear("Sakonji Domaru", 49)  --STP 7, Haste 3, MDB 2, Acc 12, Att 12
gear.sakonjiBodyPlusOne = hp_gear("Sakonji Domaru +1", 81)  --STP 8, Haste 3, MDB 4, Acc 15, Att 15
gear.sakonjiBodyPlusTwo = hp_gear("Sakonji Domaru +2", 91)  --STP 9, WSD 5, Haste 3, Macc 30, MDB 5
gear.sakonjiBodyPlusThree = hp_gear("Sakonji Domaru +3", 101)  --STP 10, WSD 10, Haste 3, Macc 40, MDB 6
gear.sakonjiBodyPlusFour = hp_gear("Sakonji Do. +4", 111)  --STP 10, WSD 12, Haste 3, Macc 45, MDB 7
gear.sakonjiHands = hp_gear("Sakonji Kote", 12)  --Haste 3, Acc 15, Att 15
gear.sakonjiHandsPlusOne = hp_gear("Sakonji Kote +1", 27)  --Haste 4, MDB 1, Acc 18, Att 18
gear.sakonjiHandsPlusTwo = hp_gear("Sakonji Kote +2", 37)  --Haste 4, Macc 28, MDB 2, Acc 37, Att 66
gear.sakonjiHandsPlusThree = hp_gear("Sakonji Kote +3", 47)  --Haste 4, Macc 38, MDB 3, Acc 47, Att 81
gear.sakonjiHandsPlusFour = hp_gear("Sakonji Kote +4", 57)  --Haste 4, Macc 43, MDB 4, Acc 52, Att 91
gear.sakonjiLegs = hp_gear("Sakonji Haidate", 23)  --Haste 5, MDB 1, Att 15
gear.sakonjiLegsPlusOne = hp_gear("Sakonji Haidate +1", 50)  --Haste 5, MDB 3, Att 18
gear.sakonjiLegsPlusTwo = hp_gear("Sakonji Haidate +2", 60)  --Haste 5, Macc 29, MDB 4, Acc 29, Att 67
gear.sakonjiLegsPlusThree = hp_gear("Sakonji Haidate +3", 70)  --Haste 5, Macc 39, MDB 5, Acc 39, Att 82
gear.sakonjiLegsPlusFour = hp_gear("Sakonji Haidate +4", 80)  --Haste 5, Macc 44, MDB 6, Acc 44, Att 92
gear.sakonjiFeet = hp_gear("Sakonji Sune-Ate", 37)  --STP 7, Haste 3, MDB 1, Att 20
gear.sakonjiFeetPlusOne = hp_gear("Sak. Sune-Ate +1", 45)  --STP 8, Haste 3, MDB 2, Att 23
gear.sakonjiFeetPlusTwo = hp_gear("Sak. Sune-Ate +2", 55)  --STP 9, Haste 3, Macc 26, MDB 3, Acc 26
gear.sakonjiFeetPlusThree = hp_gear("Sak. Sune-Ate +3", 65)  --STP 10, Haste 3, Macc 36, MDB 4, Acc 36
gear.sakonjiFeetPlusFour = hp_gear("Sakonji Sune. +4", 75)  --STP 10, Haste 3, Macc 41, MDB 5, Acc 41

--SAM Empyrean (90-era) (Set: Augments "Zanshin")
gear.unkaiHead = hp_gear("Unkai Kabuto", 0)  --STP 2
gear.unkaiHeadPlusOne = hp_gear("Unkai Kabuto +1", 0)  --STP 5, Haste 5
gear.unkaiHeadPlusTwo = hp_gear("Unkai Kabuto +2", 0)  --STP 8, Haste 6
gear.unkaiBody = hp_gear("Unkai Domaru", 0)  --Acc 6, Att 6
gear.unkaiBodyPlusOne = hp_gear("Unkai Domaru +1", 0)  --STP 7, Acc 12, Att 12, Great Katana Skill 5
gear.unkaiBodyPlusTwo = hp_gear("Unkai Domaru +2", 0)  --STP 10, Acc 17, Att 17, Great Katana Skill 7
gear.unkaiHands = hp_gear("Unkai Kote", 0)  --Racc 3, Ratt 3, Acc 2
gear.unkaiHandsPlusOne = hp_gear("Unkai Kote +1", 0)  --Racc 9, Ratt 9, Acc 5
gear.unkaiHandsPlusTwo = hp_gear("Unkai Kote +2", 0)  --Racc 12, Ratt 12, Acc 8
gear.unkaiLegs = hp_gear("Unkai Haidate", 0)  --STR 2, DEX 2
gear.unkaiLegsPlusOne = hp_gear("Unkai Haidate +1", 0)  --STP 5, Haste 4
gear.unkaiLegsPlusTwo = hp_gear("Unkai Haidate +2", 0)  --STP 7, Haste 4
gear.unkaiFeet = hp_gear("Unkai Sune-Ate", 0)  --Acc 5, Att 5
gear.unkaiFeetPlusOne = hp_gear("Unkai Sune-Ate +1", 0)  --Acc 10, Att 10
gear.unkaiFeetPlusTwo = hp_gear("Unkai Sune-Ate +2", 0)  --Acc 15, Att 15

--SAM Empyrean Reforged (REA Set: Augments "Zanshin")
gear.kasugaHead = hp_gear("Kasuga Kabuto", 20)  --STP 9, Haste 6, MDB 1
gear.kasugaHeadPlusOne = hp_gear("Kasuga Kabuto +1", 43)  --STP 10, Haste 7, MDB 2
gear.kasugaHeadPlusTwo = hp_gear("Kasuga Kabuto +2", 63)  --STP 11, Haste 7, Macc 51, MDB 5, Acc 51
gear.kasugaHeadPlusThree = hp_gear("Kasuga Kabuto +3", 73)  --STP 12, Haste 7, Macc 61, MDB 6, Acc 61
gear.kasugaBody = hp_gear("Kasuga Domaru", 31)  --STP 10, Haste 3, MDB 2, Acc 17, Att 17
gear.kasugaBodyPlusOne = hp_gear("Kasuga Domaru +1", 66)  --STP 12, Haste 3, MDB 4, Acc 22, Att 22
gear.kasugaBodyPlusTwo = hp_gear("Kasuga Domaru +2", 86)  --STP 13, Haste 3, Macc 54, MDB 7, Acc 54
gear.kasugaBodyPlusThree = hp_gear("Kasuga Domaru +3", 96)  --STP 14, Haste 3, Macc 64, MDB 8, Acc 64
gear.kasugaHands = hp_gear("Kasuga Kote", 12)  --Haste 3, Racc 13, Ratt 13, Acc 13
gear.kasugaHandsPlusOne = hp_gear("Kasuga Kote +1", 27)  --Haste 4, MDB 1, Racc 21, Ratt 21, Acc 23
gear.kasugaHandsPlusTwo = hp_gear("Kasuga Kote +2", 47)  --WSD 8, Haste 4, Macc 52, MDB 4, Racc 52
gear.kasugaHandsPlusThree = hp_gear("Kasuga Kote +3", 57)  --WSD 12, Haste 4, Macc 62, MDB 5, Racc 62
gear.kasugaLegs = hp_gear("Kasuga Haidate", 23)  --STP 8, Haste 5, Haste 2, MDB 1
gear.kasugaLegsPlusOne = hp_gear("Kasuga Haidate +1", 50)  --STP 9, Haste 5, Haste 3, MDB 3
gear.kasugaLegsPlusTwo = hp_gear("Kasuga Haidate +2", 70)  --STP 10, Haste 5, Haste 3, Macc 53, MDB 6
gear.kasugaLegsPlusThree = hp_gear("Kasuga Haidate +3", 80)  --STP 11, Haste 5, Haste 3, Macc 63, MDB 7
gear.kasugaFeet = hp_gear("Kasuga Sune-Ate", 7)  --Haste 3, MDB 1, Acc 15, Att 15
gear.kasugaFeetPlusOne = hp_gear("Kas. Sune-Ate +1", 15)  --Haste 3, MDB 2, Acc 21, Att 21
gear.kasugaFeetPlusTwo = hp_gear("Kas. Sune-Ate +2", 35)  --Haste 3, Macc 50, MDB 5, Acc 50, Att 60
gear.kasugaFeetPlusThree = hp_gear("Kas. Sune-Ate +3", 45)  --Haste 3, Macc 60, MDB 6, Acc 60, Att 70

--NIN Artifact (75-era)
gear.ninjaHead = hp_gear("Ninja Hatsuburi", 10)  --Ninjutsu Skill 5
gear.ninjaHeadPlusOne = hp_gear("Nin. Hatsuburi +1", 10)  --Ninjutsu Skill 5
gear.ninjaBody = hp_gear("Ninja Chainmail", 15)  --VIT 3
gear.ninjaBodyPlusOne = hp_gear("Nin. Chainmail +1", 15)  --DEX 5, VIT 5
gear.ninjaHands = hp_gear("Ninja Tekko", 13)  --Ratt 20, Throwing Skill 5
gear.ninjaHandsPlusOne = hp_gear("Nin. Tekko +1", 13)  --Racc 20, Ratt 20, Throwing Skill 5
gear.ninjaLegs = hp_gear("Ninja Hakama", 15)  --Racc 10
gear.ninjaLegsPlusOne = hp_gear("Nin. Hakama +1", 0)  --Racc 10, Acc 5
gear.ninjaFeet = hp_gear("Ninja Kyahan", 12)  --AGI 4
gear.ninjaFeetPlusOne = hp_gear("Nin. Kyahan +1", 12)  --AGI 6, INT 6

--NIN Artifact Reforged (Set: Increases Accuracy, Ranged Accuracy, and Magic Accuracy)
gear.hachiyaHead = hp_gear("Hachiya Hatsuburi", 17)  --Haste 7, Macc 15, MDB 2, SB 7, Ninjutsu Skill 10
gear.hachiyaHeadPlusOne = hp_gear("Hachi. Hatsu. +1", 36)  --Haste 8, Macc 15, MDB 4, SB 7, Ninjutsu Skill 13
gear.hachiyaHeadPlusTwo = hp_gear("Hachiya Hatsu. +2", 54)  --WSD 5, Haste 8, Macc 44, MDB 4, SB 8
gear.hachiyaHeadPlusThree = hp_gear("Hachiya Hatsu. +3", 64)  --WSD 10, Haste 8, Macc 54, MDB 5, SB 9
gear.hachiyaHeadPlusFour = hp_gear("Hachi. Hatsu. +4", 74)  --WSD 12, Haste 8, Macc 64, MDB 6, Acc 64
gear.hachiyaBody = hp_gear("Hachi. Chainmail", 28)  --Haste 4, MDB 2, SB 7
gear.hachiyaBodyPlusOne = hp_gear("Hachi. Chain. +1", 59)  --DW 8, Haste 4, MDB 4, SB 7
gear.hachiyaBodyPlusTwo = hp_gear("Hachiya Chain. +2", 88)  --DW 9, Haste 4, MDB 4, Acc 40, SB 8
gear.hachiyaBodyPlusThree = hp_gear("Hachiya Chain. +3", 98)  --DW 10, Haste 4, MDB 5, Acc 50, SB 9
gear.hachiyaBodyPlusFour = hp_gear("Hachi. Chain. +4", 108)  --DW 10, Haste 4, Macc 60, MDB 6, Acc 60
gear.hachiyaHands = hp_gear("Hachiya Tekko", 11)  --Haste 4, Racc 25, Ratt 25, SB 7, Throwing Skill 10
gear.hachiyaHandsPlusOne = hp_gear("Hachiya Tekko +1", 25)  --Haste 5, MDB 1, Racc 28, Ratt 28, SB 7
gear.hachiyaHandsPlusTwo = hp_gear("Hachiya Tekko +2", 37)  --Haste 5, MDB 1, Racc 38, Ratt 38, Acc 38
gear.hachiyaHandsPlusThree = hp_gear("Hachiya Tekko +3", 47)  --Haste 5, MDB 2, Racc 48, Ratt 48, Acc 48
gear.hachiyaHandsPlusFour = hp_gear("Hachiya Tekko +4", 57)  --Haste 5, Macc 58, MDB 3, Racc 58, Ratt 53
gear.hachiyaLegs = hp_gear("Hachiya Hakama", 22)  --Haste 6, MDB 1, Racc 15, Acc 15, SB 7
gear.hachiyaLegsPlusOne = hp_gear("Hachi. Hakama +1", 47)  --DW 3, Haste 6, MDB 3, Racc 15, Acc 15
gear.hachiyaLegsPlusTwo = hp_gear("Hachiya Hakama +2", 70)  --STP 3, DW 4, Haste 6, MDB 3, Racc 25
gear.hachiyaLegsPlusThree = hp_gear("Hachiya Hakama +3", 80)  --STP 6, DW 5, Haste 6, MDB 4, Racc 35
gear.hachiyaLegsPlusFour = hp_gear("Hachiya Hakama +4", 90)  --STP 6, DW 5, Haste 6, Macc 66, MDB 5
gear.hachiyaFeet = hp_gear("Hachiya Kyahan", 6)  --Haste 4, MAB 10, Macc 10, MDB 1
gear.hachiyaFeetPlusOne = hp_gear("Hachi. Kyahan +1", 13)  --Haste 4, MAB 13, Macc 13, MDB 3
gear.hachiyaFeetPlusTwo = hp_gear("Hachiya Kyahan +2", 19)  --Haste 4, MAB 18, Macc 42, MBD 5, MDB 3
gear.hachiyaFeetPlusThree = hp_gear("Hachiya Kyahan +3", 29)  --Haste 4, MAB 23, Macc 52, MBD 10, MDB 4
gear.hachiyaFeetPlusFour = hp_gear("Hachiya Kyahan +4", 39)  --Haste 4, MAB 25, Macc 62, MBD 10, MDB 5

--NIN Relic (75-era)
gear.kogaHead = hp_gear("Koga Hatsuburi", 20)  --Parrying Skill 10
gear.kogaHeadPlusOne = hp_gear("Kog. Hatsuburi +1", 27)  --Parrying Skill 12
gear.kogaHeadPlusTwo = hp_gear("Kog. Hatsuburi +2", 38)  --Acc 9, Parrying Skill 12
gear.kogaBody = hp_gear("Koga Chainmail", 0)  --Racc 8, Ratt 8, Acc 12, Att 16
gear.kogaBodyPlusOne = hp_gear("Kog. Chainmail +1", 0)  --Racc 10, Ratt 10, Acc 12, Att 16
gear.kogaBodyPlusTwo = hp_gear("Kog. Chainmail +2", 0)  --Racc 12, Ratt 12, Acc 15, Att 20
gear.kogaHands = hp_gear("Koga Tekko", 0)  --Haste 4
gear.kogaHandsPlusOne = hp_gear("Kog. Tekko +1", 0)  --Haste 4
gear.kogaHandsPlusTwo = hp_gear("Kog. Tekko +2", 0)  --Haste 4, SB 5
gear.kogaLegs = hp_gear("Koga Hakama", 40)  --Dual Wield+
gear.kogaLegsPlusOne = hp_gear("Kog. Hakama +1", 40)  --Dual Wield+
gear.kogaLegsPlusTwo = hp_gear("Kog. Hakama +2", 56)  --AGI 6
gear.kogaFeet = hp_gear("Koga Kyahan", 0)  --Ninjutsu Skill 10
gear.kogaFeetPlusOne = hp_gear("Kog. Kyahan +1", 0)  --Ninjutsu Skill 12
gear.kogaFeetPlusTwo = hp_gear("Kog. Kyahan +2", 0)  --Enmity 4, Ninjutsu Skill 15

--NIN Relic Reforged (REA Set: Augments "Dual Wield")
gear.mochizukiHead = hp_gear("Mochi. Hatsuburi", 17)  --Haste 7, MAB 12, MDB 2, Acc 12, Parrying Skill 14
gear.mochizukiHeadPlusOne = hp_gear("Mochi. Hatsuburi +1", 36)  --Haste 8, MAB 15, MDB 4, Acc 15, Parrying Skill 16
gear.mochizukiHeadPlusTwo = hp_gear("Mochi. Hatsuburi +2", 46)  --Haste 8, MAB 54, Macc 27, MDB 5, Acc 34
gear.mochizukiHeadPlusThree = hp_gear("Mochi. Hatsuburi +3", 56)  --Haste 8, MAB 61, Macc 37, MDB 6, Acc 44
gear.mochizukiHeadPlusFour = hp_gear("Mochi. Hatsu. +4", 66)  --Haste 8, MAB 64, Macc 42, MDB 7, Acc 49
gear.mochizukiBody = hp_gear("Mochi. Chainmail", 28)  --DW 6, Haste 4, MDB 2, Racc 12, Ratt 12
gear.mochizukiBodyPlusOne = hp_gear("Mochi. Chainmail +1", 59)  --DW 7, Haste 4, MDB 4, Racc 14, Ratt 14
gear.mochizukiBodyPlusTwo = hp_gear("Mochi. Chainmail +2", 69)  --DW 8, Haste 4, Macc 30, MDB 5, Racc 37
gear.mochizukiBodyPlusThree = hp_gear("Mochi. Chainmail +3", 79)  --DW 9, Haste 4, Macc 40, MDB 6, Racc 47
gear.mochizukiBodyPlusFour = hp_gear("Mochi. Chainmail +4", 89)  --DW 9, Haste 4, Macc 45, MDB 7, Racc 52
gear.mochizukiHands = hp_gear("Mochizuki Tekko", 11)  --Haste 4, Att 13, SB 6
gear.mochizukiHandsPlusOne = hp_gear("Mochizuki Tekko +1", 25)  --Haste 5, MDB 1, Att 16, SB 7
gear.mochizukiHandsPlusTwo = hp_gear("Mochizuki Tekko +2", 35)  --Haste 5, Macc 28, MDB 2, Acc 28, Att 64
gear.mochizukiHandsPlusThree = hp_gear("Mochizuki Tekko +3", 45)  --Haste 5, Macc 38, MDB 3, Acc 38, Att 79
gear.mochizukiHandsPlusFour = hp_gear("Mochi. Tekko +4", 55)  --Haste 5, Macc 43, MDB 4, Acc 43, Att 89
gear.mochizukiLegs = hp_gear("Mochizuki Hakama", 37)  --DW 7, Haste 6, MDB 1
gear.mochizukiLegsPlusOne = hp_gear("Mochi. Hakama +1", 62)  --DW 8, Haste 6, MDB 3
gear.mochizukiLegsPlusTwo = hp_gear("Mochi. Hakama +2", 72)  --WSD 5, DW 9, Haste 6, Macc 29, MDB 4
gear.mochizukiLegsPlusThree = hp_gear("Mochi. Hakama +3", 82)  --WSD 10, DW 10, Haste 6, Macc 39, MDB 5
gear.mochizukiLegsPlusFour = hp_gear("Mochi. Hakama +4", 92)  --WSD 12, DW 10, Haste 6, Macc 44, MDB 6
gear.mochizukiFeet = hp_gear("Mochizuki Kyahan", 6)  --Haste 4, MDB 1, Acc 12, Att 12, Enmity 5
gear.mochizukiFeetPlusOne = hp_gear("Mochi. Kyahan +1", 13)  --Haste 4, MDB 3, Acc 15, Att 15, Enmity 6
gear.mochizukiFeetPlusTwo = hp_gear("Mochi. Kyahan +2", 23)  --Haste 4, Macc 26, MDB 4, Acc 33, Att 61
gear.mochizukiFeetPlusThree = hp_gear("Mochi. Kyahan +3", 33)  --Haste 4, Macc 36, MDB 5, Acc 43, Att 76
gear.mochizukiFeetPlusFour = hp_gear("Mochi. Kyahan +4", 43)  --Haste 4, Macc 41, MDB 6, Acc 48, Att 86

--NIN Empyrean (90-era) (Set: Augments "Dual Wield")
gear.igaHead = hp_gear("Iga Zukin", 0)  --DEX 3
gear.igaHeadPlusOne = hp_gear("Iga Zukin +1", 0)  --Haste 5
gear.igaHeadPlusTwo = hp_gear("Iga Zukin +2", 0)  --Haste 6
gear.igaBody = hp_gear("Iga Ningi", 0)  --Acc 5, Att 5
gear.igaBodyPlusOne = hp_gear("Iga Ningi +1", 0)  --Acc 14, Att 14
gear.igaBodyPlusTwo = hp_gear("Iga Ningi +2", 0)  --Acc 17, Att 17
gear.igaHands = hp_gear("Iga Tekko", 0)  --DEX 3, AGI 3
gear.igaHandsPlusOne = hp_gear("Iga Tekko +1", 0)  --Acc 6
gear.igaHandsPlusTwo = hp_gear("Iga Tekko +2", 0)  --Acc 8
gear.igaLegs = hp_gear("Iga Hakama", 0)  --Acc 3
gear.igaLegsPlusOne = hp_gear("Iga Hakama +1", 0)  --Haste 6, Acc 6, Katana Skill 3
gear.igaLegsPlusTwo = hp_gear("Iga Hakama +2", 0)  --Haste 7, Acc 8, Katana Skill 5
gear.igaFeet = hp_gear("Iga Kyahan", 0)  --Haste 1
gear.igaFeetPlusOne = hp_gear("Iga Kyahan +1", 0)  --Haste 3
gear.igaFeetPlusTwo = hp_gear("Iga Kyahan +2", 0)  --Haste 4

--NIN Empyrean Reforged (REA Set: Augments "Dual Wield")
gear.hattoriHead = hp_gear("Hattori Zukin", 19)  --DA 7, DW 6, Haste 8, MDB 1
gear.hattoriHeadPlusOne = hp_gear("Hattori Zukin +1", 41)  --DA 9, DW 7, Haste 10, MDB 3
gear.hattoriHeadPlusTwo = hp_gear("Hattori Zukin +2", 61)  --DA 11, DW 7, Haste 10, Macc 51, MDB 6
gear.hattoriHeadPlusThree = hp_gear("Hattori Zukin +3", 71)  --DA 13, DW 7, Haste 10, Macc 61, MDB 7
gear.hattoriBody = hp_gear("Hattori Ningi", 30)  --Haste 4, MDB 3, Acc 17, Att 17
gear.hattoriBodyPlusOne = hp_gear("Hattori Ningi +1", 63)  --Haste 4, MDB 6, Acc 24, Att 24
gear.hattoriBodyPlusTwo = hp_gear("Hattori Ningi +2", 83)  --Haste 4, Macc 54, MDB 9, Racc 54, Acc 54
gear.hattoriBodyPlusThree = hp_gear("Hattori Ningi +3", 93)  --Haste 4, Macc 64, MDB 10, Racc 64, Acc 64
gear.hattoriHands = hp_gear("Hattori Tekko", 12)  --Haste 4, Acc 13
gear.hattoriHandsPlusOne = hp_gear("Hattori Tekko +1", 27)  --Haste 5, MDB 2, Acc 23
gear.hattoriHandsPlusTwo = hp_gear("Hattori Tekko +2", 47)  --Haste 5, Macc 52, MBD 10, MDB 5, Racc 52
gear.hattoriHandsPlusThree = hp_gear("Hattori Tekko +3", 57)  --Haste 5, Macc 62, MBD 15, MDB 6, Racc 62
gear.hattoriLegs = hp_gear("Hattori Hakama", 23)  --Haste 7, MDB 2, Acc 10, Katana Skill 13
gear.hattoriLegsPlusOne = hp_gear("Hattori Hakama +1", 50)  --Haste 8, MDB 5, Acc 20, Katana Skill 23
gear.hattoriLegsPlusTwo = hp_gear("Hattori Hakama +2", 70)  --Haste 8, Macc 53, MDB 8, Racc 53, Acc 53
gear.hattoriLegsPlusThree = hp_gear("Hattori Hakama +3", 80)  --Haste 8, Macc 63, MDB 9, Racc 63, Acc 63
gear.hattoriFeet = hp_gear("Hattori Kyahan", 7)  --Haste 4, MDB 2
gear.hattoriFeetPlusOne = hp_gear("Hattori Kyahan +1", 15)  --Haste 5, MDB 5
gear.hattoriFeetPlusTwo = hp_gear("Hattori Kyahan +2", 35)  --WSD 8, Haste 5, Macc 50, MDB 8, Racc 50
gear.hattoriFeetPlusThree = hp_gear("Hattori Kyahan +3", 45)  --WSD 12, Haste 5, Macc 60, MDB 9, Racc 60

--DRG Artifact (75-era)
gear.drachenHead = hp_gear("Drachen Armet", 12)  --MND 5
gear.drachenHeadPlusOne = hp_gear("Drn. Armet +1", 12)  --VIT 8, MND 8
gear.drachenBody = hp_gear("Drachen Mail", 15)  --VIT 4
gear.drachenBodyPlusOne = hp_gear("Drn. Mail +1", 15)  --Att 7
gear.drachenHands = hp_gear("Drachen Fng. Gnt.", 11)  --Parrying Skill 10
gear.drachenHandsPlusOne = hp_gear("Drn. Fng. Gnt. +1", 11)  --Parrying Skill 12
gear.drachenLegs = hp_gear("Drachen Brais", 15)  --Ancient Circle+
gear.drachenLegsPlusOne = hp_gear("Drn. Brais +1", 15)  --Acc 9
gear.drachenFeet = hp_gear("Drachen Greaves", 12)  --Evasion Skill 5
gear.drachenFeetPlusOne = hp_gear("Drn. Greaves +1", 12)  --Evasion Skill 10

--DRG Artifact Reforged (Set: Increases Accuracy, Ranged Accuracy, and Magic Accuracy)
gear.vishapHead = hp_gear("Vishap Armet", 18)  --Haste 6, MDB 1, Att 17
gear.vishapHeadPlusOne = hp_gear("Vishap Armet +1", 38)  --Haste 7, MDB 2, Att 22
gear.vishapHeadPlusTwo = hp_gear("Vishap Armet +2", 57)  --Haste 7, MDB 2, Acc 37, Acc 21, Att 32
gear.vishapHeadPlusThree = hp_gear("Vishap Armet +3", 67)  --Haste 7, MDB 3, Acc 47, Acc 31, Att 42
gear.vishapHeadPlusFour = hp_gear("Vishap Armet +4", 77)  --Haste 7, Macc 57, MDB 4, Acc 57, Att 47
gear.vishapBody = hp_gear("Vishap Mail", 29)  --Haste 3, MDB 2, Acc 15, Att 15
gear.vishapBodyPlusOne = hp_gear("Vishap Mail +1", 61)  --Haste 3, MDB 4, Acc 15, Att 15
gear.vishapBodyPlusTwo = hp_gear("Vishap Mail +2", 91)  --STP 4, Haste 3, MDB 4, Acc 47, Att 25
gear.vishapBodyPlusThree = hp_gear("Vishap Mail +3", 101)  --STP 8, Haste 3, MDB 5, Acc 57, Att 35
gear.vishapBodyPlusFour = hp_gear("Vishap Mail +4", 111)  --STP 8, Haste 3, Macc 67, MDB 6, Acc 67
gear.vishapHands = hp_gear("Vish. Fin. Gaunt", 12)  --Haste 3, Att 15, Parrying Skill 15
gear.vishapHandsPlusOne = hp_gear("Vishap F. G. +1", 27)  --Haste 4, MDB 1, Att 15, Parrying Skill 15
gear.vishapHandsPlusTwo = hp_gear("Vis. Fng. Gaunt. +2", 40)  --Haste 4, MDB 1, Acc 38, Acc 24, Att 25
gear.vishapHandsPlusThree = hp_gear("Vis. Fng. Gaunt. +3", 50)  --Haste 4, MDB 2, Acc 48, Acc 34, Att 35
gear.vishapHandsPlusFour = hp_gear("Vish. Fin. +4", 60)  --Haste 4, Macc 58, MDB 3, Acc 58, Att 40
gear.vishapLegs = hp_gear("Vishap Brais", 23)  --Haste 5, MDB 1
gear.vishapLegsPlusOne = hp_gear("Vishap Brais +1", 50)  --Haste 5, MDB 3
gear.vishapLegsPlusTwo = hp_gear("Vishap Brais +2", 75)  --WSD 5, Haste 5, MDB 3, Acc 39
gear.vishapLegsPlusThree = hp_gear("Vishap Brais +3", 85)  --WSD 10, Haste 5, MDB 4, Acc 49
gear.vishapLegsPlusFour = hp_gear("Vishap Brais +4", 95)  --WSD 12, Haste 5, Macc 59, MDB 5, Acc 59
gear.vishapFeet = hp_gear("Vishap Greaves", 17)  --Haste 3, MDB 1, Att 10, Att 20
gear.vishapFeetPlusOne = hp_gear("Vishap Greaves +1", 25)  --Haste 3, MDB 2, Att 10, Att 22
gear.vishapFeetPlusTwo = hp_gear("Vishap Greaves +2", 37)  --Haste 3, MDB 2, Acc 36, Acc 20, Att 20
gear.vishapFeetPlusThree = hp_gear("Vishap Greaves +3", 47)  --Haste 3, MDB 3, Acc 46, Acc 30, Att 30
gear.vishapFeetPlusFour = hp_gear("Vishap Greaves +4", 57)  --Haste 3, Macc 56, MDB 4, Acc 56, Acc 30

--DRG Relic (75-era)
gear.wyrmHead = hp_gear("Wyrm Armet", 16)  --STR 4
gear.wyrmHeadPlusOne = hp_gear("Wym. Armet +1", 16)  --Att 2
gear.wyrmHeadPlusTwo = hp_gear("Wym. Armet +2", 22)  --Att 4
gear.wyrmBody = hp_gear("Wyrm Mail", 24)  --Parrying Skill 15
gear.wyrmBodyPlusOne = hp_gear("Wym. Mail +1", 33)  --Haste 2, Parrying Skill 15
gear.wyrmBodyPlusTwo = hp_gear("Wym. Mail +2", 46)  --Haste 3, Att 8
gear.wyrmHands = hp_gear("Wyrm Fng.Gnt.", 16)  --Acc 5
gear.wyrmHandsPlusOne = hp_gear("Wym. Fng. Gnt. +1", 16)  --Acc 7
gear.wyrmHandsPlusTwo = hp_gear("Wym. Fng. Gnt. +2", 22)  --Acc 9
gear.wyrmLegs = hp_gear("Wyrm Brais", 13)  --DEX 5
gear.wyrmLegsPlusOne = hp_gear("Wym. Brais +1", 13)  --DEX 6
gear.wyrmLegsPlusTwo = hp_gear("Wym. Brais +2", 18)  --STR 7, DEX 7
gear.wyrmFeet = hp_gear("Wyrm Greaves", 10)  --VIT 4
gear.wyrmFeetPlusOne = hp_gear("Wym. Greaves +1", 10)  --VIT 5
gear.wyrmFeetPlusTwo = hp_gear("Wym. Greaves +2", 14)  --Att 7

--DRG Relic Reforged (REA Set: Attack occ. varies with wyvern's HP)
gear.pteroslaverHead = hp_gear("Ptero. Armet", 40)  --Haste 6, MDB 1, Acc 10, Att 10
gear.pteroslaverHeadPlusOne = hp_gear("Ptero. Armet +1", 60)  --Haste 7, MDB 2, Acc 15, Att 15
gear.pteroslaverHeadPlusTwo = hp_gear("Ptero. Armet +2", 70)  --TA 3, Haste 7, Macc 27, MDB 3, Acc 34
gear.pteroslaverHeadPlusThree = hp_gear("Ptero. Armet +3", 80)  --TA 4, Haste 7, Macc 37, MDB 4, Acc 44
gear.pteroslaverHeadPlusFour = hp_gear("Ptero. Armet +4", 90)  --TA 4, Haste 7, Macc 42, MDB 5, Acc 49
gear.pteroslaverBody = hp_gear("Pteroslaver Mail", 50)  --Haste 3, MDB 2, Att 12
gear.pteroslaverBodyPlusOne = hp_gear("Ptero. Mail +1", 82)  --Haste 3, MDB 4, Att 15
gear.pteroslaverBodyPlusTwo = hp_gear("Ptero. Mail +2", 92)  --Haste 3, Macc 30, MDB 5, Acc 30, Att 65
gear.pteroslaverBodyPlusThree = hp_gear("Ptero. Mail +3", 102)  --Haste 3, Macc 40, MDB 6, Acc 40, Att 80
gear.pteroslaverBodyPlusFour = hp_gear("Ptero. Mail +4", 112)  --Haste 3, Macc 45, MDB 7, Acc 45, Att 90
gear.pteroslaverHands = hp_gear("Ptero. Fin. Gaunt.", 42)  --Haste 3, Acc 14
gear.pteroslaverHandsPlusOne = hp_gear("Ptero. Fin. G. +1", 57)  --Haste 4, MDB 1, Acc 17
gear.pteroslaverHandsPlusTwo = hp_gear("Ptero. Fin. G. +2", 67)  --WSD 5, Haste 4, Macc 28, MDB 2, Acc 36
gear.pteroslaverHandsPlusThree = hp_gear("Ptero. Fin. G. +3", 77)  --WSD 10, Haste 4, Macc 38, MDB 3, Acc 46
gear.pteroslaverHandsPlusFour = hp_gear("Ptero. Fin. G. +4", 87)  --WSD 12, Haste 4, Macc 43, MDB 4, Acc 51
gear.pteroslaverLegs = hp_gear("Pteroslaver Brais", 45)  --Haste 5, MDB 1
gear.pteroslaverLegsPlusOne = hp_gear("Ptero. Brais +1", 65)  --Haste 5, MDB 3
gear.pteroslaverLegsPlusTwo = hp_gear("Ptero. Brais +2", 75)  --STP 7, Haste 5, Macc 29, MDB 4, Acc 29
gear.pteroslaverLegsPlusThree = hp_gear("Ptero. Brais +3", 85)  --STP 10, Haste 5, Macc 39, MDB 5, Acc 39
gear.pteroslaverLegsPlusFour = hp_gear("Ptero. Brais +4", 95)  --STP 10, Haste 5, Macc 44, MDB 6, Acc 44
gear.pteroslaverFeet = hp_gear("Ptero. Greaves", 22)  --Haste 3, MDB 1, Acc 9, Att 9
gear.pteroslaverFeetPlusOne = hp_gear("Ptero. Greaves +1", 35)  --Haste 3, MDB 2, Acc 12, Att 12
gear.pteroslaverFeetPlusTwo = hp_gear("Ptero. Greaves +2", 45)  --Haste 3, Macc 26, MDB 3, Acc 32, Att 58
gear.pteroslaverFeetPlusThree = hp_gear("Ptero. Greaves +3", 55)  --Haste 3, Macc 36, MDB 4, Acc 42, Att 73
gear.pteroslaverFeetPlusFour = hp_gear("Ptero. Greaves +4", 65)  --Haste 3, Macc 41, MDB 5, Acc 47, Att 83

--DRG Empyrean (90-era) (Set: Attack occ. varies with wyvern's HP)
gear.lancerHead = hp_gear("Lancer's Mezail", 0)  --Att 7
gear.lancerHeadPlusOne = hp_gear("Lancer's Mezail +1", 0)  --Haste 5, Att 14
gear.lancerHeadPlusTwo = hp_gear("Lancer's Mezail +2", 0)  --Haste 6, Att 20, Polearm Skill 7
gear.lancerBody = hp_gear("Lncr. Plackart", 0)  --STR 3, DEX 3
gear.lancerBodyPlusOne = hp_gear("Lncr. Plackart +1", 0)  --STP 7, Acc 10, Att 10
gear.lancerBodyPlusTwo = hp_gear("Lncr. Plackart +2", 0)  --STP 10, Acc 14, Att 14
gear.lancerHands = hp_gear("Lancer's Vambraces", 0)  --Acc 3
gear.lancerHandsPlusOne = hp_gear("Lncr. Vmbrc. +1", 0)  --Acc 7
gear.lancerHandsPlusTwo = hp_gear("Lncr. Vmbrc. +2", 0)  --DA 4, Acc 10
gear.lancerLegs = hp_gear("Lancer's Cuissots", 0)  --STR 3, VIT 3
gear.lancerLegsPlusOne = hp_gear("Lncr. Cuissots +1", 0)  --Att 12
gear.lancerLegsPlusTwo = hp_gear("Lncr. Cuissots +2", 0)  --Att 18
gear.lancerFeet = hp_gear("Lncr. Schynbalds", 0)  --Acc 4, Att 4
gear.lancerFeetPlusOne = hp_gear("Lncr. Schynbld. +1", 0)  --Haste 4, Acc 8, Att 8
gear.lancerFeetPlusTwo = hp_gear("Lncr. Schynbld. +2", 0)  --Haste 5, Acc 12, Att 12

--DRG Empyrean Reforged (REA Set: Attack occ. varies with wyvern's HP)
gear.peltastHead = hp_gear("Peltast's Mezail", 20)  --Haste 6, MDB 1, Att 23, Polearm Skill 7
gear.peltastHeadPlusOne = hp_gear("Peltast's Mezail +1", 43)  --Haste 7, MDB 2, Att 28, Polearm Skill 17
gear.peltastHeadPlusTwo = hp_gear("Peltast's Mezail +2", 63)  --WSD 8, Haste 7, Macc 51, MDB 5, Acc 51
gear.peltastHeadPlusThree = hp_gear("Peltast's Mezail +3", 73)  --WSD 12, Haste 7, Macc 61, MDB 6, Acc 61
gear.peltastBody = hp_gear("Peltast's Plackart", 31)  --STP 11, Haste 3, MDB 2, Acc 14, Att 14
gear.peltastBodyPlusOne = hp_gear("Pelt. Plackart +1", 66)  --STP 12, Haste 3, MDB 4, Acc 23, Att 23
gear.peltastBodyPlusTwo = hp_gear("Pelt. Plackart +2", 86)  --STP 13, Haste 3, Macc 54, MDB 7, Acc 54
gear.peltastBodyPlusThree = hp_gear("Pelt. Plackart +3", 96)  --STP 14, Haste 3, Macc 64, MDB 8, Acc 64
gear.peltastHands = hp_gear("Pel. Vambraces", 12)  --DA 4, Haste 3, Acc 13
gear.peltastHandsPlusOne = hp_gear("Pel. Vambraces +1", 27)  --DA 5, Haste 4, MDB 1, Acc 23
gear.peltastHandsPlusTwo = hp_gear("Pel. Vambraces +2", 47)  --DA 6, Haste 4, Macc 52, MDB 4
gear.peltastHandsPlusThree = hp_gear("Pel. Vambraces +3", 57)  --DA 7, Haste 4, Macc 62
gear.peltastLegs = hp_gear("Peltast's Cuissots", 23)  --Haste 5, MDB 1, Att 18, Att 13
gear.peltastLegsPlusOne = hp_gear("Pelt. Cuissots +1", 50)  --Haste 5, MDB 3, Att 28, Att 15
gear.peltastLegsPlusTwo = hp_gear("Pelt. Cuissots +2", 70)  --Haste 5, Macc 53, MDB 6
gear.peltastLegsPlusThree = hp_gear("Pelt. Cuissots +3", 80)  --Haste 5, Macc 63
gear.peltastFeet = hp_gear("Pelt. Schynbalds", 7)  --Haste 5, MDB 1, Acc 14, Att 14
gear.peltastFeetPlusOne = hp_gear("Pelt. Schyn. +1", 15)  --Haste 6, MDB 2, Acc 24, Att 24
gear.peltastFeetPlusTwo = hp_gear("Pelt. Schyn. +2", 35)  --Haste 6, Macc 50, MDB 5, Acc 50, Att 60
gear.peltastFeetPlusThree = hp_gear("Pelt. Schyn. +3", 45)  --Haste 6, Macc 60, MDB 6, Acc 60, Att 70

--SMN Artifact (75-era)
gear.evokerHead = mp_gear("Evoker's Horn", 20)  --Summoning magic Skill 5
gear.evokerHeadPlusOne = mp_gear("Evk. Horn +1", 25)  --Summoning magic Skill 5
gear.evokerBody = mp_gear("Evoker's Doublet", 15)  --MND 3
gear.evokerBodyPlusOne = mp_gear("Evk. Doublet +1", 45)
gear.evokerHands = mp_gear("Evoker's Bracers", 15)  --VIT 4
gear.evokerHandsPlusOne = mp_gear("Evk. Bracers +1", 19)  --Occ. effect
gear.evokerLegs = mp_gear("Evoker's Spats", 15)  --Enmity -2, Evasion Skill 10
gear.evokerLegsPlusOne = mp_gear("Evk. Spats +1", 22)  --Enmity -3
gear.evokerFeet = mp_gear("Evoker's Pigaches", 15)  --AGI 5
gear.evokerFeetPlusOne = mp_gear("Evk. Pigaches +1", 25)

--SMN Artifact Reforged (Set: Inc. Acc., Ranged Acc., and Magic Acc.)
gear.convokerHead = hp_gear("Convoker's Horn", 15)  --Refresh 2, Haste 5, MDB 2, Summoning magic Skill 15
gear.convokerHeadPlusOne = hp_gear("Con. Horn +1", 31)  --Refresh 2, Haste 6, MDB 5, Summoning Skill 15
gear.convokerHeadPlusTwo = hp_gear("Convoker's Horn +2", 46)  --Refresh 2, Haste 6, Haste 5, Macc 31, MDB 5
gear.convokerHeadPlusThree = hp_gear("Convoker's Horn +3", 56)  --Refresh 3, Haste 6, Haste 10, Macc 41, MDB 6
gear.convokerHeadPlusFour = hp_gear("Con. Horn +4", 66)  --Refresh 3, Haste 6, Macc 57, MDB 7, Acc 57
gear.convokerBody = hp_gear("Convo. Doublet", 23)  --Haste 2, MDB 3
gear.convokerBodyPlusOne = hp_gear("Con. Doublet +1", 50)  --Haste 3, MDB 6
gear.convokerBodyPlusTwo = hp_gear("Con. Doublet +2", 75)  --Haste 3, Macc 35, MDB 6, Acc 40
gear.convokerBodyPlusThree = hp_gear("Con. Doublet +3", 85)  --Haste 3, MDB 7, Acc 50
gear.convokerBodyPlusFour = hp_gear("Con. Doublet +4", 95)  --Haste 3, Macc 60, MDB 8, Acc 60
gear.convokerHands = hp_gear("Con. Bracers", 8)  --Haste 3, MDB 1
gear.convokerHandsPlusOne = hp_gear("Con. Bracers +1", 18)  --Haste 3, MDB 3
gear.convokerHandsPlusTwo = hp_gear("Convo. Bracers +2", 27)  --DA 5, Haste 3, Macc 33, MDB 3, Enmity 10
gear.convokerHandsPlusThree = hp_gear("Convo. Bracers +3", 37)  --DA 10, Haste 3, Macc 43, MDB 4, Enmity 15
gear.convokerHandsPlusFour = hp_gear("Con. Bracers +4", 47)  --DA 10, Haste 3, Macc 58, MDB 5, Acc 58
gear.convokerLegs = hp_gear("Convoker's Spats", 18)  --Haste 4, MDB 3, Enmity 4, Enmity -5
gear.convokerLegsPlusOne = hp_gear("Con. Spats +1", 38)  --Haste 5, MDB 6, Enmity -6
gear.convokerLegsPlusTwo = hp_gear("Convo. Spats +2", 57)  --STP 5, Haste 5, Macc 40, MDB 6, Acc 39
gear.convokerLegsPlusThree = hp_gear("Convo. Spats +3", 67)  --STP 10, Haste 5, Macc 50, MDB 7, Acc 49
gear.convokerLegsPlusFour = hp_gear("Con. Spats +4", 77)  --STP 10, Haste 5, Macc 59, Macc 60, MDB 8
gear.convokerFeet = hp_gear("Con. Pigaches", 4)  --Haste 3, MDB 2, Enmity 5
gear.convokerFeetPlusOne = hp_gear("Con. Pigaches +1", 9)  --Haste 3, MDB 5
gear.convokerFeetPlusTwo = hp_gear("Convo. Pigaches +2", 13)  --Haste 3, Macc 30, MDB 5, Acc 36
gear.convokerFeetPlusThree = hp_gear("Convo. Pigaches +3", 23)  --Haste 3, Macc 40, MDB 6, Acc 46
gear.convokerFeetPlusFour = hp_gear("Con. Pigaches +4", 33)  --Haste 3, Macc 56, MDB 7, Acc 56

--SMN Relic (75-era)
gear.summonerHead = mp_gear("Summoner's Horn", 25)  --INT 3
gear.summonerHeadPlusOne = mp_gear("Smn. Horn +1", 30)  --INT 4
gear.summonerHeadPlusTwo = mp_gear("Smn. Horn +2", 42)
gear.summonerBody = mp_gear("Summoner's Dblt.", 20)
gear.summonerBodyPlusOne = mp_gear("Smn. Doublet +1", 20)
gear.summonerBodyPlusTwo = mp_gear("Smn. Doublet +2", 28)
gear.summonerHands = mp_gear("Summoner's Brcr.", 25)  --Summoning magic Skill 10
gear.summonerHandsPlusOne = mp_gear("Smn. Bracers +1", 30)  --Summoning magic Skill 12
gear.summonerHandsPlusTwo = mp_gear("Smn. Bracers +2", 42)  --Summoning magic Skill 15
gear.summonerLegs = mp_gear("Summoner's Spats", 20)  --MND 3
gear.summonerLegsPlusOne = mp_gear("Smn. Spats +1", 25)
gear.summonerLegsPlusTwo = mp_gear("Smn. Spats +2", 35)
gear.summonerFeet = mp_gear("Summoner's Pgch.", 20)  --VIT 3
gear.summonerFeetPlusOne = mp_gear("Smn. Pigaches +1", 25)
gear.summonerFeetPlusTwo = mp_gear("Smn. Pigaches +2", 35)

--SMN Relic Reforged (REA Set: Augments "Blood Boon")
gear.glyphicHead = hp_gear("Glyphic Horn", 15)  --Haste 5, MDB 2
gear.glyphicHeadPlusOne = hp_gear("Glyphic Horn +1", 31)  --Haste 6, MDB 5
gear.glyphicHeadPlusTwo = hp_gear("Glyphic Horn +2", 41)  --Haste 6, MAB 53, Macc 27, MDB 6, Acc 27
gear.glyphicHeadPlusThree = hp_gear("Glyphic Horn +3", 51)  --Haste 6, MAB 60, Macc 37, MDB 7, Acc 37
gear.glyphicHeadPlusFour = hp_gear("Glyphic Horn +4", 61)  --Haste 6, Macc 42, MDB 8, Acc 42, Att 72
gear.glyphicBody = hp_gear("Glyphic Doublet", 23)  --Haste 2, MDB 3
gear.glyphicBodyPlusOne = hp_gear("Glyphic Doublet +1", 50)  --Haste 3, MDB 6
gear.glyphicBodyPlusTwo = hp_gear("Glyphic Doublet +2", 60)  --Haste 3, Macc 30, MDB 7, Acc 30, Att 50
gear.glyphicBodyPlusThree = hp_gear("Glyphic Doublet +3", 70)  --Haste 3, Macc 40, MDB 8, Acc 40, Att 65
gear.glyphicBodyPlusFour = hp_gear("Glyphic Doublet +4", 80)  --Haste 3, Macc 45, MDB 9, Acc 45, Att 75
gear.glyphicHands = hp_gear("Glyphic Bracers", 8)  --Haste 3, MDB 1, Summoning magic Skill 17
gear.glyphicHandsPlusOne = hp_gear("Glyphic Bracers +1", 18)  --Haste 3, MDB 3, Summoning magic Skill 19
gear.glyphicHandsPlusTwo = hp_gear("Glyphic Bracers +2", 28)  --Haste 3, Macc 28, MDB 4, Acc 28, Att 48
gear.glyphicHandsPlusThree = hp_gear("Glyphic Bracers +3", 38)  --Haste 3, Macc 38, MDB 5, Acc 38, Att 63
gear.glyphicHandsPlusFour = hp_gear("Glyph. Bracers +4", 48)  --Haste 3, Haste 9, Macc 43, Macc 57, MDB 6
gear.glyphicLegs = hp_gear("Glyphic Spats", 18)  --Haste 4, MDB 3
gear.glyphicLegsPlusOne = hp_gear("Glyphic Spats +1", 38)  --Haste 5, MDB 6
gear.glyphicLegsPlusTwo = hp_gear("Glyphic Spats +2", 48)  --Haste 5, MAB 44, Macc 29, MDB 7, Acc 29
gear.glyphicLegsPlusThree = hp_gear("Glyphic Spats +3", 58)  --Haste 5, MAB 51, Macc 39, MDB 8, Acc 39
gear.glyphicLegsPlusFour = hp_gear("Glyph. Spats +4", 68)  --Haste 5, MAB 54, Macc 44, Macc 50, MDB 9
gear.glyphicFeet = hp_gear("Glyphic Pigaches", 4)  --Haste 3, MDB 2
gear.glyphicFeetPlusOne = hp_gear("Glyph. Pigaches +1", 9)  --Haste 3, MDB 5
gear.glyphicFeetPlusTwo = hp_gear("Glyph. Pigaches +2", 19)  --Haste 3, Macc 26, MDB 6, Acc 26, Att 46
gear.glyphicFeetPlusThree = hp_gear("Glyph. Pigaches +3", 29)  --Haste 3, Macc 36, MDB 7, Acc 36, Att 61
gear.glyphicFeetPlusFour = hp_gear("Glyph. Pigaches +4", 39)  --Haste 3, Macc 41, MDB 8, Acc 41, Att 71

--SMN Empyrean (90-era) (Set: Augments "Blood Boon")
gear.callerHead = mp_gear("Caller's Horn", 10)  --Summoning magic Skill 3
gear.callerHeadPlusOne = mp_gear("Caller's Horn +1", 20)  --Summoning magic Skill 6
gear.callerHeadPlusTwo = mp_gear("Caller's Horn +2", 30)  --Summoning magic Skill 9
gear.callerBody = mp_gear("Caller's Doublet", 22)  --Summoning magic Skill 3
gear.callerBodyPlusOne = mp_gear("Caller's Doublet +1", 45)  --Summoning magic Skill 7
gear.callerBodyPlusTwo = mp_gear("Call. Doublet +2", 60)  --Summoning magic Skill 10
gear.callerHands = mp_gear("Caller's Bracers", 20)
gear.callerHandsPlusOne = mp_gear("Caller's Bracers +1", 40)  --Mana Cede+
gear.callerHandsPlusTwo = mp_gear("Call. Bracers +2", 50)  --Mana Cede+, Blood Boon+
gear.callerLegs = mp_gear("Caller's Spats", 16)
gear.callerLegsPlusOne = mp_gear("Caller's Spats +1", 33)
gear.callerLegsPlusTwo = mp_gear("Caller's Spats +2", 45)  --Summoning magic Skill 6
gear.callerFeet = mp_gear("Caller's Pigaches", 15)
gear.callerFeetPlusOne = mp_gear("Caller's Pgch. +1", 20)  --Elemental Siphon+
gear.callerFeetPlusTwo = mp_gear("Caller's Pgch. +2", 25)  --Elemental Siphon+, Blood Boon+

--SMN Empyrean Reforged (REA Set: Augments "Blood Boon")
gear.beckonerHead = hp_gear("Beckoner's Horn", 15)  --Refresh 2, Haste 5, MDB 3, Summoning magic Skill 11
gear.beckonerHeadPlusOne = hp_gear("Beckoner's Horn +1", 31)  --Refresh 2, Haste 6, MDB 6, Summoning magic Skill 13
gear.beckonerHeadPlusTwo = hp_gear("Beckoner's Horn +2", 51)  --Refresh 3, Haste 6, Macc 51, MDB 9, Racc 51
gear.beckonerHeadPlusThree = hp_gear("Beckoner's Horn +3", 61)  --Refresh 4, Haste 6, Macc 61, MDB 10, Racc 61
gear.beckonerBody = hp_gear("Beckoner's Doublet", 25)  --Haste 2, MDB 3, Summoning magic Skill 12
gear.beckonerBodyPlusOne = hp_gear("Beck. Doublet +1", 54)  --Haste 3, MDB 6, Summoning magic Skill 14
gear.beckonerBodyPlusTwo = hp_gear("Beck. Doublet +2", 74)  --Haste 3, Macc 54, MDB 9, Racc 54, Summoning magic Skill 19
gear.beckonerBodyPlusThree = hp_gear("Beck. Doublet +3", 84)  --Haste 3, Macc 64, Racc 64, Summoning magic Skill 24
gear.beckonerHands = hp_gear("Beckoner's Bracers", 8)  --Haste 3, MDB 1
gear.beckonerHandsPlusOne = hp_gear("Beck. Bracers +1", 18)  --Haste 3, MDB 3
gear.beckonerHandsPlusTwo = hp_gear("Beck. Bracers +2", 38)  --Haste 3, Macc 52, Racc 52
gear.beckonerHandsPlusThree = hp_gear("Beck. Bracers +3", 48)  --Haste 3, Macc 62, Racc 62
gear.beckonerLegs = hp_gear("Beckoner's Spats", 19)  --Haste 4, MDB 3, Summoning magic Skill 15
gear.beckonerLegsPlusOne = hp_gear("Beck. Spats +1", 41)  --Haste 5, MDB 6, Summoning magic Skill 20
gear.beckonerLegsPlusTwo = hp_gear("Beck. Spats +2", 61)  --Haste 5, Macc 53, MDB 9, Racc 53, Acc 53
gear.beckonerLegsPlusThree = hp_gear("Beck. Spats +3", 71)  --Haste 5, Macc 63, MDB 10, Racc 63, Acc 63
gear.beckonerFeet = hp_gear("Beck. Pigaches", 4)  --Haste 3, MDB 3
gear.beckonerFeetPlusOne = hp_gear("Beck. Pigaches +1", 9)  --Haste 3, MDB 6
gear.beckonerFeetPlusTwo = hp_gear("Beck. Pigaches +2", 29)  --Haste 3, Macc 50, MDB 9, Racc 50, Acc 50
gear.beckonerFeetPlusThree = hp_gear("Beck. Pigaches +3", 39)  --Haste 3, Macc 60, MDB 10, Racc 60

--BLU Artifact (75-era)
gear.magusHead = mp_gear("Magus Keffiyeh", 20)  --INT 3, MND 3
gear.magusHeadPlusOne = mp_gear("Magus Keffiyeh +1", 25)  --INT 5, MND 5
gear.magusBody = hp_gear("Magus Jubbah", 12)  --Blue magic Skill 15
gear.magusBodyPlusOne = hp_gear("Magus Jubbah +1", 17)  --Blue magic Skill 15
gear.magusHands = mp_gear("Magus Bazubands", 15)  --Parrying Skill 10
gear.magusHandsPlusOne = mp_gear("Mag. Bazubands +1", 20)  --Parrying Skill 10
gear.magusLegs = hp_gear("Magus Shalwar", 20)  --SIRD 10
gear.magusLegsPlusOne = hp_gear("Magus Shalwar +1", 25)  --SIRD 12
gear.magusFeet = hp_gear("Magus Charuqs", 13)  --Enmity -3, Evasion Skill 10
gear.magusFeetPlusOne = hp_gear("Magus Charuqs +1", 18)  --Acc 3, Enmity -5, Evasion Skill 10

--BLU Artifact Reforged (Set: Increases Accuracy, Ranged Accuracy, and Magic Accuracy)
gear.assimilatorHead = hp_gear("Assim. Keffiyeh", 27)  --Haste 7, MAB 15, Macc 15, MDB 1
gear.assimilatorHeadPlusTwo = hp_gear("Assim. Keffiyeh +2", 69)  --Haste 8, MAB 23, Macc 46, MDB 2
gear.assimilatorHeadPlusThree = hp_gear("Assim. Keffiyeh +3", 79)  --Haste 8, MAB 28, Macc 56, MDB 3
gear.assimilatorHeadPlusFour = hp_gear("Assim. Keffiyeh +4", 89)  --Haste 8, MAB 30, Macc 66, MDB 4, Acc 66
gear.assimilatorBody = hp_gear("Assim. Jubbah", 38)  --Haste 4, MDB 3, Blue magic Skill 18
gear.assimilatorBodyPlusTwo = hp_gear("Assim. Jubbah +2", 103)  --Refresh 2, WSD 5, Haste 4, MDB 6, Acc 40
gear.assimilatorHands = hp_gear("Assim. Bazu.", 11)  --Haste 4, MDB 1, Parrying Skill 15
gear.assimilatorHandsPlusTwo = hp_gear("Assim. Bazu. +2", 37)  --Haste 5, MDB 2, Acc 38, Parrying Skill 17
gear.assimilatorHandsPlusThree = hp_gear("Assim. Bazu. +3", 47)  --Haste 5, MDB 3, Acc 48, Parrying Skill 19
gear.assimilatorHandsPlusFour = hp_gear("Assim. Bazu. +4", 57)  --Haste 5, Macc 58, MDB 4, Acc 58, Parrying Skill 20
gear.assimilatorLegs = hp_gear("Assim. Shalwar", 37)  --SIRD 20, Haste 6, MDB 2
gear.assimilatorLegsPlusTwo = hp_gear("Assim. Shalwar +2", 93)  --SIRD 22, Haste 6, Macc 39, MBD 5, MDB 5
gear.assimilatorLegsPlusThree = hp_gear("Assim. Shalwar +3", 103)  --SIRD 24, Haste 6, Macc 49, MBD 10, MDB 6
gear.assimilatorLegsPlusFour = hp_gear("Assim. Shalwar +4", 113)  --SIRD 24, Haste 6, Macc 59, MBD 10, MDB 7
gear.assimilatorFeet = hp_gear("Assim. Charuqs", 26)  --Haste 4, MDB 2, Acc 15, Att 15
gear.assimilatorFeetPlusTwo = hp_gear("Assim. Charuqs +2", 49)  --Haste 4, MDB 5, Acc 45, Att 28, SC Bonus 5
gear.assimilatorFeetPlusThree = hp_gear("Assim. Charuqs +3", 59)  --Haste 4, MDB 6, Acc 55, Att 38, SC Bonus 10
gear.assimilatorFeetPlusFour = hp_gear("Assim. Charuqs +4", 69)  --Haste 4, Macc 65, MDB 7, Acc 65, Att 43

--BLU Relic (75-era)
gear.mirageHead = hp_gear("Mirage Keffiyeh", 15)  --Blue magic Skill 5
gear.mirageHeadPlusOne = hp_gear("Mirage Keffiyeh +1", 15)  --Blue magic Skill 5
gear.mirageHeadPlusTwo = hp_gear("Mirage Keffiyeh +2", 21)  --Blue magic Skill 7
gear.mirageBody = mp_gear("Mirage Jubbah", 20)  --Acc 10, Enmity -2
gear.mirageBodyPlusOne = mp_gear("Mirage Jubbah +1", 20)  --Acc 12, Enmity -3
gear.mirageBodyPlusTwo = mp_gear("Mirage Jubbah +2", 28)  --Acc 15, Att 15
gear.mirageHands = hp_gear("Mirage Bazubands", 12)  --DEX 5, MND 5
gear.mirageHandsPlusOne = hp_gear("Mrg. Bazubands +1", 12)  --DEX 6, MND 6
gear.mirageHandsPlusTwo = hp_gear("Mrg. Bazubands +2", 17)  --SB 7
gear.mirageLegs = hp_gear("Mirage Shalwar", 10)  --Macc 3, Acc 5
gear.mirageLegsPlusOne = hp_gear("Mirage Shalwar +1", 15)  --Macc 5, Acc 5
gear.mirageLegsPlusTwo = hp_gear("Mirage Shalwar +2", 21)  --Macc 7, Acc 7
gear.mirageFeet = mp_gear("Mirage Charuqs", 15)  --Att 5, Enmity -2
gear.mirageFeetPlusOne = mp_gear("Mirage Charuqs +1", 15)  --Att 5, Enmity -2
gear.mirageFeetPlusTwo = mp_gear("Mirage Charuqs +2", 21)  --Att 7, Blue magic Skill 3

--BLU Relic Reforged (REA Set: Occ. augments Blue magic spells)
gear.luhlazaHead = hp_gear("Luhlaza Keffiyeh", 37)  --Haste 7, MDB 1, Blue magic Skill 11
gear.luhlazaHeadPlusOne = hp_gear("Luh. Keffiyeh +1", 71)  --Haste 8, MDB 2, Blue magic Skill 13
gear.luhlazaHeadPlusTwo = hp_gear("Luh. Keffiyeh +2", 81)  --Haste 8, Macc 27, MDB 3, Acc 27, Att 47
gear.luhlazaHeadPlusFour = hp_gear("Luhlaza Keffiyeh +4", 101)  --Haste 8, Macc 42, MDB 5, Acc 42, Att 72
gear.luhlazaBody = hp_gear("Luhlaza Jubbah", 28)  --FC 6, Refresh 2, Haste 4, MDB 3, Acc 18
gear.luhlazaBodyPlusTwo = hp_gear("Luhlaza Jubbah +2", 69)  --FC 8, Refresh 2, Haste 4, Macc 30, MDB 7
gear.luhlazaBodyPlusThree = hp_gear("Luhlaza Jubbah +3", 79)  --FC 9, Refresh 3, Haste 4, Macc 40, MDB 8
gear.luhlazaBodyPlusFour = hp_gear("Luhlaza Jubbah +4", 89)  --FC 9, Refresh 3, Haste 4, Macc 45, MDB 9
gear.luhlazaHands = hp_gear("Luhlaza Bazubands", 28)  --Haste 4, MDB 1, Acc 10, SB 8
gear.luhlazaHandsPlusTwo = hp_gear("Luh. Bazubands +2", 60)  --Haste 5, Macc 28, MDB 3, Acc 34, Att 48
gear.luhlazaHandsPlusThree = hp_gear("Luh. Bazubands +3", 70)  --Haste 5, Macc 38, MDB 4, Acc 44, Att 63
gear.luhlazaHandsPlusFour = hp_gear("Luh. Bazu. +4", 80)  --Haste 5, Macc 43, MDB 5, Acc 49, Att 73
gear.luhlazaLegs = hp_gear("Luhlaza Shalwar", 37)  --Haste 6, MAB 10, Macc 10, MDB 2, Acc 10
gear.luhlazaLegsPlusOne = hp_gear("Luhlaza Shalwar +1", 67)  --Haste 6, MAB 13, Macc 13, MDB 5, Acc 13
gear.luhlazaLegsPlusTwo = hp_gear("Luhlaza Shalwar +2", 77)  --WSD 5, Haste 6, MAB 50, Macc 35, MDB 6
gear.luhlazaFeet = hp_gear("Luhlaza Charuqs", 6)  --Haste 4, MDB 2, Att 20, Blue magic Skill 6
gear.luhlazaFeetPlusOne = hp_gear("Luhlaza Charuqs +1", 13)  --Haste 4, MDB 5, Att 25, Blue magic Skill 8
gear.luhlazaFeetPlusTwo = hp_gear("Luhlaza Charuqs +2", 23)  --Haste 4, Macc 26, MDB 6, Acc 26, Att 71
gear.luhlazaFeetPlusThree = hp_gear("Luhlaza Charuqs +3", 33)  --Haste 4, Macc 36, MDB 7, Acc 36, Att 86

--BLU Empyrean (90-era) (Set: Occ. augments Blue magic spells)
gear.maviHead = hp_gear("Mavi Kavuk", 0)  --Acc 4
gear.maviHeadPlusOne = hp_gear("Mavi Kavuk +1", 0)  --Haste 5, Acc 8, Sword Skill 5
gear.maviHeadPlusTwo = hp_gear("Mavi Kavuk +2", 0)  --Haste 6, Acc 12, Sword Skill 7
gear.maviBody = hp_gear("Mavi Mintan", 0)  --Macc 3, Acc 3
gear.maviBodyPlusOne = hp_gear("Mavi Mintan +1", 0)  --Haste 2, Macc 9, Acc 9
gear.maviBodyPlusTwo = hp_gear("Mavi Mintan +2", 0)  --Haste 3, Macc 12, Acc 12
gear.maviHands = hp_gear("Mavi Bazubands", 0)  --MAB 2
gear.maviHandsPlusOne = hp_gear("Mv. Bazubands +1", 0)  --MAB 7, Enmity -3
gear.maviHandsPlusTwo = hp_gear("Mv. Bazubands +2", 0)  --MAB 10, Enmity -4
gear.maviLegs = hp_gear("Mavi Tayt", 0)  --STR 2, DEX 2
gear.maviLegsPlusOne = hp_gear("Mavi Tayt +1", 0)  --Haste 3, Blue magic Skill 10
gear.maviLegsPlusTwo = hp_gear("Mavi Tayt +2", 0)  --Haste 4, Blue magic Skill 15
gear.maviFeet = hp_gear("Mavi Basmak", 0)  --Macc 1
gear.maviFeetPlusOne = hp_gear("Mavi Basmak +1", 0)  --MAB 5, Macc 5, Enmity -4
gear.maviFeetPlusTwo = hp_gear("Mavi Basmak +2", 0)  --MAB 8, Macc 8, Enmity -6

--BLU Empyrean Reforged (REA Set: Occ. augments Blue magic spells)
gear.hashishinHead = hp_gear("Hashishin Kavuk", 17)  --Haste 7, MDB 3, Acc 12, Sword Skill 10
gear.hashishinBody = hp_gear("Hashishin Mintan", 27)  --Refresh 2, Haste 3, Macc 14, MDB 3, Acc 14
gear.hashishinHands = hp_gear("Hashi. Bazubands", 11)  --Haste 3, MAB 14, MDB 1, Enmity -4
gear.hashishinLegs = hp_gear("Hashishin Tayt", 21)  --Haste 4, MDB 3, Blue magic Skill 15
gear.hashishinFeet = hp_gear("Hashishin Basmak", 7)  --Haste 3, MAB 17, Macc 17, MDB 3, Enmity -7

--COR Artifact (75-era)
gear.corsairHead = hp_gear("Corsair's Tricorne", 8)  --Racc 8
gear.corsairHeadPlusOne = hp_gear("Cor. Tricorne +1", 13)  --Racc 9
gear.corsairBody = hp_gear("Corsair's Frac", 15)  --Racc 8
gear.corsairBodyPlusOne = hp_gear("Corsair's Frac +1", 20)  --Racc 10, Ratt 5
gear.corsairHands = hp_gear("Corsair's Gants", 10)  --Parrying Skill 5
gear.corsairHandsPlusOne = hp_gear("Corsair's Gants +1", 15)  --Parrying Skill 5
gear.corsairLegs = hp_gear("Corsair's Culottes", 20)  --Enmity -3
gear.corsairLegsPlusOne = hp_gear("Cor. Culottes +1", 25)  --Enmity -4
gear.corsairFeet = hp_gear("Corsair's Bottes", 10)  --Racc 2
gear.corsairFeetPlusOne = hp_gear("Cor. Bottes +1", 15)  --Racc 4, Acc 4

--COR Artifact Reforged (Set: Increases Accuracy, Ranged Accuracy, and Magic Accuracy)
gear.laksamanaHead = hp_gear("Laksa. Tricorne", 17)  --Haste 7, Macc 15, MDB 1, Racc 15
gear.laksamanaHeadPlusOne = hp_gear("Laksa. Tricorne +1", 36)  --Haste 8, Macc 18, MDB 2, Racc 18
gear.laksamanaHeadPlusTwo = hp_gear("Laksa. Tricorne +2", 54)  --Haste 8, Macc 46, MDB 2, Racc 28
gear.laksamanaHeadPlusThree = hp_gear("Laksa. Tricorne +3", 64)  --Haste 8, Macc 56, MDB 3, Racc 38
gear.laksamanaBody = hp_gear("Laksa. Frac", 28)  --Rapid Shot 15, Haste 4, MDB 3, Racc 15, Ratt 15
gear.laksamanaBodyPlusOne = hp_gear("Laksa. Frac +1", 59)  --Rapid Shot 16, Haste 4, MDB 6, Racc 15, Ratt 15
gear.laksamanaBodyPlusTwo = hp_gear("Laksa. Frac +2", 88)  --WSD 5, Rapid Shot 18, Haste 4, MDB 6, Racc 47
gear.laksamanaBodyPlusThree = hp_gear("Laksa. Frac +3", 98)  --WSD 10, Rapid Shot 20, Haste 4, MDB 7, Racc 57
gear.laksamanaHands = hp_gear("Laksa. Gants", 11)  --Haste 4, Macc 10, MDB 1, Acc 10, Enmity -5
gear.laksamanaHandsPlusOne = hp_gear("Laksa. Gants +1", 25)  --Haste 5, Macc 10, MDB 2, Acc 10, Enmity -6
gear.laksamanaHandsPlusTwo = hp_gear("Laksa. Gants +2", 37)  --Haste 5, Macc 43, MDB 2, Acc 20, SB 5
gear.laksamanaHandsPlusThree = hp_gear("Laksa. Gants +3", 47)  --Haste 5, Macc 53, MDB 3, Acc 30, SB 10
gear.laksamanaHandsPlusFour = hp_gear("Lak. Gants +4", 57)  --Haste 5, Macc 63, MDB 4, Racc 63, Acc 40
gear.laksamanaLegs = hp_gear("Laksa. Trews", 62)  --Haste 6, MAB 15, MDB 2, Att 15, Enmity -5
gear.laksamanaLegsPlusOne = hp_gear("Laksa. Trews +1", 87)  --Haste 6, MAB 15, MDB 5, Att 15, Enmity -6
gear.laksamanaLegsPlusTwo = hp_gear("Laksa. Trews +2", 130)  --Snapshot 8, Haste 6, MAB 20, MDB 5, Racc 39
gear.laksamanaLegsPlusThree = hp_gear("Laksa. Trews +3", 140)  --Snapshot 15, Haste 6, MAB 25, MDB 6, Racc 49
gear.laksamanaLegsPlusFour = hp_gear("Laksa. Trews +4", 150)  --Snapshot 15, Haste 6, MAB 27, Macc 59, MDB 7
gear.laksamanaFeet = hp_gear("Laksa. Bottes", 36)  --Haste 4, MDB 2, Racc 10
gear.laksamanaFeetPlusOne = hp_gear("Laksa. Bottes +1", 43)  --Haste 4, Macc 13, MDB 5, Racc 13
gear.laksamanaFeetPlusTwo = hp_gear("Laksa. Bottes +2", 64)  --Haste 4, Macc 42, MDB 5, Racc 23
gear.laksamanaFeetPlusThree = hp_gear("Laksa. Bottes +3", 74)  --Haste 4, Macc 52, MDB 6, Racc 33

--COR Relic (75-era)
gear.commodoreHead = hp_gear("Comm. Tricorne", 10)  --Ratt 8
gear.commodoreHeadPlusOne = hp_gear("Comm. Tricorne +1", 12)  --Ratt 10
gear.commodoreBody = hp_gear("Commodore Frac", 0)  --Ratt 8, Acc 8
gear.commodoreBodyPlusOne = hp_gear("Comm. Frac +1", 0)  --Ratt 10, Acc 10
gear.commodoreBodyPlusTwo = hp_gear("Comm. Frac +2", 0)  --Ratt 12, Acc 12
gear.commodoreHandsPlusOne = hp_gear("Comm. Gants +1", 15)  --Racc 5
gear.commodoreHandsPlusTwo = hp_gear("Comm. Gants +2", 21)  --Racc 7, Ratt 7
gear.commodoreLegs = hp_gear("Comm. Trews", 22)  --Att 3
gear.commodoreLegsPlusOne = hp_gear("Comm. Trews +1", 22)  --Att 7
gear.commodoreLegsPlusTwo = hp_gear("Comm. Trews +2", 31)  --Racc 5, Ratt 5, Att 9
gear.commodoreFeet = hp_gear("Comm. Bottes", 12)  --Acc 5, Enmity -3
gear.commodoreFeetPlusOne = hp_gear("Comm. Bottes +1", 12)  --Acc 7, Enmity -4
gear.commodoreFeetPlusTwo = hp_gear("Comm. Bottes +2", 17)  --MAB 6, Acc 9

--COR Relic Reforged (REA Set: Augments "Quick Draw")
gear.lanunHead = hp_gear("Lanun Tricorne", 34)  --Haste 7, MDB 1, Ratt 20
gear.lanunHeadPlusOne = hp_gear("Lanun Tricorne +1", 60)  --Haste 8, MDB 2, Ratt 25
gear.lanunHeadPlusTwo = hp_gear("Lanun Tricorne +2", 70)  --Haste 8, Macc 27, MDB 3, Racc 27, Ratt 72
gear.lanunHeadPlusFour = hp_gear("Lanun Tricorne +4", 90)  --Haste 8, Macc 42, MDB 5, Racc 42, Ratt 97
gear.lanunBody = hp_gear("Lanun Frac", 28)  --Haste 4, MAB 15, MDB 3, Ratt 15, Acc 15
gear.lanunBodyPlusOne = hp_gear("Lanun Frac +1", 59)  --Haste 4, MAB 18, MDB 6, Ratt 18, Acc 18
gear.lanunBodyPlusTwo = hp_gear("Lanun Frac +2", 69)  --Haste 4, MAB 54, Macc 30, MDB 7, Ratt 68
gear.lanunBodyPlusFour = hp_gear("Lanun Frac +4", 89)  --Haste 4, MAB 64, Macc 45, MDB 9, Ratt 93
gear.lanunHands = hp_gear("Lanun Gants", 30)  --Snapshot 7, Haste 4, MDB 1, Racc 10, Ratt 10
gear.lanunHandsPlusOne = hp_gear("Lanun Gants +1", 45)  --Snapshot 9, Haste 5, MDB 2, Racc 13, Ratt 13
gear.lanunHandsPlusTwo = hp_gear("Lanun Gants +2", 55)  --Snapshot 11, Haste 5, Macc 28, MDB 3, Racc 34
gear.lanunHandsPlusThree = hp_gear("Lanun Gants +3", 65)  --Snapshot 13, Haste 5, Macc 38, MDB 4, Racc 44
gear.lanunHandsPlusFour = hp_gear("Lanun Gants +4", 75)  --Snapshot 13, Haste 5, Macc 43, MDB 5, Racc 49
gear.lanunLegs = hp_gear("Lanun Trews", 50)  --Snapshot 4, Haste 6, MDB 2, Racc 12, Ratt 12
gear.lanunLegsPlusOne = hp_gear("Lanun Trews +1", 70)  --Snapshot 6, Haste 6, MDB 5, Racc 14, Ratt 14
gear.lanunLegsPlusTwo = hp_gear("Lanun Trews +2", 80)  --Snapshot 8, Haste 6, Macc 29, MDB 6, Racc 36
gear.lanunLegsPlusThree = hp_gear("Lanun Trews +3", 90)  --Snapshot 10, Haste 6, Macc 39, MDB 7, Racc 46
gear.lanunLegsPlusFour = hp_gear("Lanun Trews +4", 100)  --Snapshot 10, Haste 6, Macc 44, MDB 8, Racc 51
gear.lanunFeet = hp_gear("Lanun Bottes", 26)  --Haste 4, MAB 12, MDB 2, Acc 12
gear.lanunFeetPlusOne = hp_gear("Lanun Bottes +1", 38)  --Haste 4, MAB 15, MDB 5, Acc 15
gear.lanunFeetPlusTwo = hp_gear("Lanun Bottes +2", 48)  --WSD 5, Haste 4, MAB 48, Macc 26, MDB 6
gear.lanunFeetPlusThree = hp_gear("Lanun Bottes +3", 58)  --WSD 10, Haste 4, MAB 55, Macc 36, MDB 7

--COR Empyrean (90-era) (Set: Augments "Quick Draw")
gear.navarchHead = hp_gear("Navarch's Tricorne", 0)  --Racc 5
gear.navarchHeadPlusOne = hp_gear("Nvrch. Tricorne +1", 0)  --Rapid Shot 7, Racc 12
gear.navarchHeadPlusTwo = hp_gear("Nvrch. Tricorne +2", 0)  --Rapid Shot 10, Racc 16
gear.navarchBody = hp_gear("Navarch's Frac", 0)  --Racc 5, Ratt 5
gear.navarchBodyPlusOne = hp_gear("Navarch's Frac +1", 0)  --Macc 8, Racc 10, Ratt 10
gear.navarchBodyPlusTwo = hp_gear("Nvrch. Frac +2", 0)  --Macc 10, Racc 14, Ratt 14
gear.navarchHands = hp_gear("Navarch's Gants", 0)  --Racc 5, Acc 5
gear.navarchHandsPlusTwo = hp_gear("Nvrch. Gants +2", 0)  --Racc 16, Acc 16
gear.navarchLegs = hp_gear("Navarch's Culottes", 0)  --DEX 3, AGI 3
gear.navarchLegsPlusTwo = hp_gear("Nvrch. Culottes +2", 0)  --STP 8
gear.navarchFeet = hp_gear("Navarch's Bottes", 0)  --AGI 4
gear.navarchFeetPlusTwo = hp_gear("Nvrch. Bottes +2", 0)  --Macc 10

--COR Empyrean Reforged (REA Set: Augments "Quick Draw")
gear.chasseurHeadPlusOne = hp_gear("Chass. Tricorne +1", 34)  --Rapid Shot 14, Haste 8, MDB 3, Racc 32
gear.chasseurHeadPlusTwo = hp_gear("Chass. Tricorne +2", 54)  --Rapid Shot 16, Haste 8, Macc 51, MDB 6, Racc 51
gear.chasseurHeadPlusThree = hp_gear("Chass. Tricorne +3", 64)  --Rapid Shot 18, Haste 8, Macc 61, MDB 7, Racc 61
gear.chasseurBodyPlusOne = hp_gear("Chasseur's Frac +1", 57)  --Haste 4, Macc 22, MDB 6, Racc 22, Ratt 22
gear.chasseurBodyPlusTwo = hp_gear("Chasseur's Frac +2", 77)  --Haste 4, Macc 54, MDB 9, Racc 54, Ratt 64
gear.chasseurBodyPlusThree = hp_gear("Chasseur's Frac +3", 87)  --Haste 4, Macc 64, MDB 10, Racc 64, Ratt 74
gear.chasseurHands = hp_gear("Chasseur's Gants", 10)  --Haste 4, MDB 1, Racc 16, Acc 16
gear.chasseurHandsPlusTwo = hp_gear("Chasseur's Gants +2", 42)  --WSD 8, Haste 5, Macc 52, MDB 5, Racc 52
gear.chasseurHandsPlusThree = hp_gear("Chasseur's Gants +3", 52)  --WSD 12, Haste 5, Macc 62, Racc 62, Ratt 62
gear.chasseurLegs = hp_gear("Chas. Culottes", 21)  --STP 9, Snapshot 6, Haste 6, MDB 2
gear.chasseurLegsPlusOne = hp_gear("Chas. Culottes +1", 45)  --STP 10, Snapshot 7, Haste 6, MDB 5
gear.chasseurLegsPlusTwo = hp_gear("Chas. Culottes +2", 65)  --STP 11, Snapshot 8, Haste 6, Macc 53, MDB 8
gear.chasseurLegsPlusThree = hp_gear("Chas. Culottes +3", 75)  --STP 12, Snapshot 9, Haste 6, Macc 63, MDB 9
gear.chasseurFeet = hp_gear("Chasseur's Bottes", 5)  --Haste 4, Macc 11, MDB 2
gear.chasseurFeetPlusOne = hp_gear("Chass. Bottes +1", 11)  --Haste 4, Macc 21, MDB 5
gear.chasseurFeetPlusTwo = hp_gear("Chass. Bottes +2", 31)  --Haste 4, MAB 45, Macc 50, MDB 8, Racc 50
gear.chasseurFeetPlusThree = hp_gear("Chass. Bottes +3", 41)  --Haste 4, MAB 50, Macc 60, MDB 9, Racc 60

--PUP Artifact (75-era)
gear.puppetryHead = hp_gear("Pup. Taj", 10)  --DEX 3, MND 3
gear.puppetryHeadPlusOne = hp_gear("Puppetry Taj +1", 15)  --DEX 5, VIT 5
gear.puppetryBody = hp_gear("Pup. Tobe", 12)  --Acc 5
gear.puppetryBodyPlusOne = hp_gear("Pup. Tobe +1", 17)  --Acc 5, Att 5
gear.puppetryHands = hp_gear("Pup. Dastanas", 13)  --AGI 3
gear.puppetryHandsPlusOne = hp_gear("Pup. Dastanas +1", 18)  --STR 5, AGI 5
gear.puppetryLegs = hp_gear("Pup. Churidars", 11)  --CHR 3
gear.puppetryLegsPlusOne = hp_gear("Pup. Churidars +1", 16)  --DEX 5, CHR 5
gear.puppetryFeet = hp_gear("Pup. Babouches", 9)  --STR 3
gear.puppetryFeetPlusOne = hp_gear("Pup. Babouches +1", 19)  --Acc 5

--PUP Artifact Reforged (Set: Increases Accuracy, Ranged Accuracy, and Magic Accuracy)
gear.foireHead = hp_gear("Foire Taj", 17)  --Haste 7, Haste 5, MDB 2
gear.foireHeadPlusOne = hp_gear("Foire Taj +1", 36)  --Haste 8, Haste 5, MDB 4
gear.foireHeadPlusTwo = hp_gear("Foire Taj +2", 54)  --Refresh 1, Haste 8, Haste 6, MDB 4, Acc 37
gear.foireHeadPlusThree = hp_gear("Foire Taj +3", 64)  --Refresh 2, Haste 8, Haste 7, MDB 5, Acc 47
gear.foireHeadPlusFour = hp_gear("Foire Taj +4", 74)  --Refresh 2, Regen 6, Haste 8, Haste 7, Macc 57
gear.foireBody = hp_gear("Foire Tobe", 28)  --Haste 4, Haste 3, MDB 2, Acc 15, Att 15
gear.foireBodyPlusOne = hp_gear("Foire Tobe +1", 59)  --Haste 4, MDB 4, Acc 15, Att 15
gear.foireBodyPlusTwo = hp_gear("Foire Tobe +2", 88)  --WSD 5, Haste 4, MDB 4, Acc 47, Att 25
gear.foireBodyPlusThree = hp_gear("Foire Tobe +3", 99)  --WSD 10, Haste 4, MDB 5, Acc 57, Att 35
gear.foireBodyPlusFour = hp_gear("Foire Tobe +4", 109)  --WSD 12, Haste 4, Macc 67, MDB 6, Acc 67
gear.foireHands = hp_gear("Foire Dastanas", 26)  --Haste 4
gear.foireHandsPlusOne = hp_gear("Foire Dastanas +1", 40)  --Haste 5, MDB 1
gear.foireHandsPlusTwo = hp_gear("Foire Dastanas +2", 60)  --Haste 5, MDB 1, Acc 38
gear.foireHandsPlusThree = hp_gear("Foire Dastanas +3", 70)  --Haste 5, MDB 2, Acc 48
gear.foireHandsPlusFour = hp_gear("Foire Dastanas +4", 80)  --Haste 5, Haste 6, Macc 58, MDB 3, Racc 58
gear.foireLegs = hp_gear("Foire Churidars", 57)  --Haste 6, Haste 3, MDB 1
gear.foireLegsPlusOne = hp_gear("Foire Churidars +1", 82)  --Cure Pot 12, Haste 6, Haste 3, MDB 3
gear.foireLegsPlusTwo = hp_gear("Foire Churidars +2", 123)  --Cure Pot 14, Haste 6, Haste 4, MDB 3, Acc 39
gear.foireLegsPlusThree = hp_gear("Foire Churidars +3", 133)  --Cure Pot 16, Haste 6, Haste 5, MDB 4, Acc 49
gear.foireLegsPlusFour = hp_gear("Foire Churidars +4", 143)  --Cure Pot 16, Haste 6, Haste 5, Macc 59, MDB 5
gear.foireFeet = hp_gear("Foire Babouches", 36)  --Haste 4, MDB 1, Acc 10
gear.foireFeetPlusOne = hp_gear("Foire Bab. +1", 43)  --Haste 4, MDB 3, Acc 10
gear.foireFeetPlusTwo = hp_gear("Foire Babouches +2", 64)  --Haste 4, MAB 20, MDB 3, Acc 41
gear.foireFeetPlusThree = hp_gear("Foire Babouches +3", 74)  --Haste 4, Haste 5, MAB 25, MDB 4, Acc 51
gear.foireFeetPlusFour = hp_gear("Foire Babouches +4", 84)  --Haste 4, Haste 5, MAB 27, Macc 61, MDB 5

--PUP Relic (75-era)
gear.pantinHead = hp_gear("Pantin Taj", 12)  --STR 3, AGI 3
gear.pantinHeadPlusOne = hp_gear("Pantin Taj +1", 12)  --STR 4, AGI 4
gear.pantinHeadPlusTwo = hp_gear("Pantin Taj +2", 0)  --STR 6, AGI 6
gear.pantinBody = hp_gear("Pantin Tobe", 15)  --Acc 10, SB 5
gear.pantinBodyPlusOne = hp_gear("Pantin Tobe +1", 15)  --Acc 12, SB 5
gear.pantinBodyPlusTwo = hp_gear("Pantin Tobe +2", 21)  --Acc 15, Att 15
gear.pantinHands = hp_gear("Pantin Dastanas", 16)  --Haste 3
gear.pantinHandsPlusOne = hp_gear("Pantin Dastanas +1", 25)  --Haste 3
gear.pantinHandsPlusTwo = hp_gear("Pantin Dastanas +2", 0)  --Haste 4
gear.pantinLegs = hp_gear("Pantin Churidars", 13)  --Acc 5
gear.pantinLegsPlusOne = hp_gear("Ptn. Churidars +1", 13)  --Acc 7
gear.pantinLegsPlusTwo = hp_gear("Ptn. Churidars +2", 0)  --Acc 9
gear.pantinFeet = hp_gear("Pantin Babouches", 14)  --Att 5
gear.pantinFeetPlusOne = hp_gear("Ptn. Babouches +1", 22)  --Att 5
gear.pantinFeetPlusTwo = hp_gear("Ptn. Babouches +2", 31)  --MAB 7

--PUP Relic Reforged (REA Set: Attack occ. varies with automaton's HP)
gear.karagozHead = hp_gear("Karagoz Cappello", 17)  --DA 3, Haste 7, MDB 2, Hand Skill 7
gear.karagozHeadPlusOne = hp_gear("Kara. Cappello +1", 36)  --DA 3, Haste 8, MDB 4, Hand Skill 9
gear.karagozHeadPlusTwo = hp_gear("Kara. Cappello +2", 56)  --DA 4, Haste 8, Macc 51, Hand Skill 14
gear.karagozHeadPlusThree = hp_gear("Kara. Cappello +3", 66)  --DA 5, Haste 8, Macc 61, Racc 61, Hand Skill 19
gear.karagozBody = hp_gear("Karagoz Farsetto", 28)  --Haste 4, MDB 2, Acc 20, Att 20
gear.karagozBodyPlusOne = hp_gear("Kara. Farsetto +1", 59)  --Haste 4, MDB 4, Acc 26, Att 26
gear.karagozBodyPlusTwo = hp_gear("Kara. Farsetto +2", 79)  --Haste 4, Macc 54, MDB 7, Racc 54, Acc 54
gear.karagozBodyPlusThree = hp_gear("Kara. Farsetto +3", 89)  --Haste 4, Macc 64, MDB 8, Racc 64, Acc 64
gear.karagozHands = hp_gear("Karagoz Guanti", 11)  --STP 8, Haste 4
gear.karagozHandsPlusOne = hp_gear("Karagoz Guanti +1", 25)  --STP 9, Haste 5, MDB 1
gear.karagozHandsPlusTwo = hp_gear("Karagoz Guanti +2", 45)  --STP 10, Haste 5, Macc 52, MDB 4, Racc 52
gear.karagozHandsPlusThree = hp_gear("Karagoz Guanti +3", 55)  --STP 11, Haste 5, Macc 62, MDB 5, Racc 62
gear.karagozLegs = hp_gear("Karagoz Pantaloni", 22)  --Haste 6, MDB 2, Acc 10, Att 10
gear.karagozLegsPlusOne = hp_gear("Kara. Pantaloni +1", 47)  --Haste 6, MDB 4, Acc 19, Att 19
gear.karagozLegsPlusTwo = hp_gear("Kara. Pantaloni +2", 67)  --Haste 6, Macc 53, MDB 7, Racc 53, Acc 53
gear.karagozLegsPlusThree = hp_gear("Kara. Pantaloni +3", 77)  --Haste 6, Macc 63, MDB 8, Racc 63, Acc 63
gear.karagozFeet = hp_gear("Karagoz Scarpe", 6)  --Haste 4, MDB 1, Acc 19
gear.karagozFeetPlusOne = hp_gear("Karagoz Scarpe +1", 13)  --Haste 4, MDB 3, Acc 29
gear.karagozFeetPlusTwo = hp_gear("Karagoz Scarpe +2", 33)  --WSD 8, Haste 4, Macc 50, MDB 6, Racc 50
gear.karagozFeetPlusThree = hp_gear("Karagoz Scarpe +3", 43)  --WSD 12, Haste 4, Macc 60, Racc 60, Acc 60

--PUP Empyrean (90-era) (Set: Attack occ. varies with automaton's HP)
gear.cirqueHead = hp_gear("Cirque Cappello", 0)  --DA 1
gear.cirqueHeadPlusOne = hp_gear("Cirque Cappello +1", 0)  --DA 2, Haste 5
gear.cirqueHeadPlusTwo = hp_gear("Cirque Cappello +2", 0)  --DA 3, Haste 6, Hand Skill 5
gear.cirqueBody = hp_gear("Cirque Farsetto", 0)  --Acc 7, Att 7
gear.cirqueBodyPlusOne = hp_gear("Cirque Farsetto +1", 0)  --Haste 2, Acc 14, Att 14
gear.cirqueBodyPlusTwo = hp_gear("Cirque Farsetto +2", 0)  --Haste 3, Acc 20, Att 20
gear.cirqueHands = hp_gear("Cirque Guanti", 0)  --STR 2, DEX 2
gear.cirqueHandsPlusOne = hp_gear("Cirque Guanti +1", 0)  --STP 4, Haste 3
gear.cirqueHandsPlusTwo = hp_gear("Cirque Guanti +2", 0)  --STP 6, Haste 4
gear.cirqueLegs = hp_gear("Cirque Pantaloni", 0)  --Acc 3, Att 3
gear.cirqueLegsPlusOne = hp_gear("Cirq. Pantaloni +1", 0)  --Haste 3, Acc 7, Att 7
gear.cirqueLegsPlusTwo = hp_gear("Cirq. Pantaloni +2", 0)  --Haste 4, Acc 10, Att 10
gear.cirqueFeet = hp_gear("Cirque Scarpe", 0)  --STR 2, DEX 2
gear.cirqueFeetPlusOne = hp_gear("Cirque Scarpe +1", 0)  --Acc 8
gear.cirqueFeetPlusTwo = hp_gear("Cirque Scarpe +2", 0)  --Acc 12

--PUP Empyrean Reforged (REA Set: Attack occ. varies with automaton's HP)
gear.pitreHead = hp_gear("Pitre Taj", 17)  --Regen 2, Haste 7, MDB 2
gear.pitreHeadPlusOne = hp_gear("Pitre Taj +1", 36)  --Regen 3, Haste 8, MDB 4
gear.pitreHeadPlusTwo = hp_gear("Pitre Taj +2", 46)  --Refresh 4, Regen 4, Haste 8, Macc 27, MDB 5
gear.pitreHeadPlusThree = hp_gear("Pitre Taj +3", 56)  --Refresh 5, Regen 5, Haste 8, Macc 37, MDB 6
gear.pitreHeadPlusFour = hp_gear("Pitre Taj +4", 66)  --Refresh 5, Regen 5, Haste 8, Macc 42, MDB 7
gear.pitreBody = hp_gear("Pitre Tobe", 50)  --STP 12, Haste 4, MDB 2, Racc 18, Acc 18
gear.pitreBodyPlusOne = hp_gear("Pitre Tobe +1", 80)  --STP 13, Haste 4, MDB 4, Racc 21, Acc 21
gear.pitreBodyPlusTwo = hp_gear("Pitre Tobe +2", 90)  --STP 14, Haste 4, Macc 30, MDB 5, Racc 40
gear.pitreBodyPlusThree = hp_gear("Pitre Tobe +3", 100)  --STP 15, Haste 4, Macc 40, MDB 6, Racc 50
gear.pitreBodyPlusFour = hp_gear("Pitre Tobe +4", 110)  --STP 15, Haste 4, Macc 45, Macc 55, MDB 7
gear.pitreHands = hp_gear("Pitre Dastanas", 11)  --Haste 4
gear.pitreHandsPlusOne = hp_gear("Pitre Dastanas +1", 25)  --Haste 5, MDB 1
gear.pitreHandsPlusTwo = hp_gear("Pitre Dastanas +2", 35)  --WSD 5, Haste 5, Macc 28, MDB 2, Acc 28
gear.pitreHandsPlusThree = hp_gear("Pitre Dastanas +3", 45)  --WSD 10, Haste 5, Macc 38, MDB 3, Acc 38
gear.pitreHandsPlusFour = hp_gear("Pitre Dastanas +4", 55)  --WSD 12, Haste 5, Macc 43, MDB 4, Acc 43
gear.pitreLegs = hp_gear("Pitre Churidars", 22)  --FC 7, Haste 6, MDB 1, Acc 12
gear.pitreLegsPlusOne = hp_gear("Pitre Churidars +1", 47)  --FC 8, Haste 6, MDB 3, Acc 15
gear.pitreLegsPlusTwo = hp_gear("Pitre Churidars +2", 57)  --FC 9, Haste 6, MAB 44, Macc 29, MDB 4
gear.pitreLegsPlusThree = hp_gear("Pitre Churidars +3", 67)  --FC 10, Haste 6, MAB 51, Macc 39, MDB 5
gear.pitreLegsPlusFour = hp_gear("Pitre Churidars +4", 77)  --FC 10, Haste 6, MAB 54, Macc 44, Macc 53
gear.pitreFeet = hp_gear("Pitre Babouches", 46)  --Haste 4, MAB 15, MDB 1
gear.pitreFeetPlusOne = hp_gear("Pitre Babouches +1", 63)  --Haste 4, MAB 18, MDB 3
gear.pitreFeetPlusTwo = hp_gear("Pitre Babouches +2", 73)  --Haste 4, MAB 50, Macc 26, MDB 4, Acc 26
gear.pitreFeetPlusThree = hp_gear("Pitre Babouches +3", 83)  --Haste 4, MAB 57, Macc 36, MDB 5, Acc 36
gear.pitreFeetPlusFour = hp_gear("Pitre Babouches +4", 93)  --Haste 4, MAB 60, Macc 41, Macc 48, MDB 6

--DNC Artifact (75-era)
gear.dancerHead = hp_gear("Dancer's Tiara", 10)  --Enmity -2
gear.dancerHeadPlusOne = hp_gear("Dancer's Tiara +1", 15)  --Enmity -2
gear.dancerBody = hp_gear("Dancer's Casaque", 20)  --Enmity -2
gear.dancerBodyPlusOne = hp_gear("Dnc. Casaque +1", 25)  --Enmity -2
gear.dancerHands = hp_gear("Dancer's Bangles", 12)  --DEX 2, AGI 2
gear.dancerHandsPlusOne = hp_gear("Dnc. Bangles +1", 17)  --Att 5
gear.dancerLegs = hp_gear("Dancer's Tights", 10)  --Acc 3, Enmity -1
gear.dancerLegsPlusOne = hp_gear("Dancer's Tights +1", 15)  --Acc 5, Att 5, Enmity -1
gear.dancerFeet = hp_gear("Dancer's Toe Shoes", 7)  --Att 5
gear.dancerFeetPlusOne = hp_gear("Dnc. Toe Shoes +1", 12)  --Att 5

--DNC Artifact Reforged (Set: Increases Accuracy, Ranged Accuracy, and Magic Accuracy)
gear.maxixiHead = hp_gear("Maxixi Tiara", 17)  --Haste 7, MDB 1
gear.maxixiHeadPlusOne = hp_gear("Maxixi Tiara +1", 36)  --Haste 8, MDB 2
gear.maxixiHeadPlusTwo = hp_gear("Maxixi Tiara +2", 54)  --DW 4, Haste 8, MDB 2, Acc 37
gear.maxixiHeadPlusThree = hp_gear("Maxixi Tiara +3", 64)  --DW 8, Haste 8, MDB 3, Acc 47
gear.maxixiHeadPlusFour = hp_gear("Maxixi Tiara +4", 74)  --DW 8, Haste 8, Macc 57, MDB 4, Acc 57
gear.maxixiBody = hp_gear("Maxixi Casaque", 28)  --Haste 4, MDB 3, Acc 13, Att 13
gear.maxixiBodyPlusOne = hp_gear("Maxixi Casaque +1", 59)  --Haste 4, MDB 6, Acc 13, Att 13
gear.maxixiBodyPlusTwo = hp_gear("Maxixi Casaque +2", 88)  --Haste 4, MDB 6, Acc 46, Att 23
gear.maxixiBodyPlusThree = hp_gear("Maxixi Casaque +3", 98)  --Haste 4, MDB 7, Acc 56, Att 33
gear.maxixiBodyPlusFour = hp_gear("Maxixi Casaque +4", 108)  --Haste 4, Macc 66, MDB 8, Acc 66, Att 38
gear.maxixiHands = hp_gear("Maxixi Bangles", 31)  --Haste 4, MDB 1, Att 15
gear.maxixiHandsPlusOne = hp_gear("Maxixi Bangles +1", 45)  --Haste 5, MDB 2, Att 15
gear.maxixiHandsPlusTwo = hp_gear("Maxixi Bangles +2", 67)  --WSD 5, Haste 5, MDB 2, Acc 38, Att 25
gear.maxixiHandsPlusThree = hp_gear("Maxixi Bangles +3", 77)  --WSD 10, Haste 5, MDB 3, Acc 48, Att 35
gear.maxixiHandsPlusFour = hp_gear("Maxixi Bangles +4", 87)  --WSD 12, Haste 5, Macc 58, MDB 4, Acc 58
gear.maxixiLegs = hp_gear("Maxixi Tights", 22)  --Haste 6, MDB 2, Acc 15, Att 15
gear.maxixiLegsPlusOne = hp_gear("Maxixi Tights +1", 47)  --Haste 6, MDB 5, Acc 15, Att 15, SC Bonus 12
gear.maxixiLegsPlusTwo = hp_gear("Maxixi Tights +2", 70)  --Haste 6, MDB 5, Acc 46, Att 25, SC Bonus 14
gear.maxixiLegsPlusThree = hp_gear("Maxixi Tights +3", 80)  --Haste 6, MDB 6, Acc 56, Att 35, SC Bonus 16
gear.maxixiLegsPlusFour = hp_gear("Maxixi Tights +4", 90)  --Haste 6, Macc 66, MDB 7, Acc 66, Att 40
gear.maxixiFeet = hp_gear("Maxixi Toe Shoes", 26)  --Haste 4, MDB 2, Att 10
gear.maxixiFeetPlusOne = hp_gear("Maxixi Toe Shoes +1", 33)  --Haste 4, MDB 5, Att 10
gear.maxixiFeetPlusTwo = hp_gear("Maxixi Toe Shoes +2", 49)  --Haste 4, MDB 5, Acc 36, Att 20
gear.maxixiFeetPlusThree = hp_gear("Maxixi Toe Shoes +3", 59)  --Haste 4, MDB 6, Acc 46, Att 30
gear.maxixiFeetPlusFour = hp_gear("Maxixi Toe Sh. +4", 69)  --Haste 4, Macc 56, MDB 7, Acc 56, Att 35

--DNC Relic (75-era)
gear.etoileHead = hp_gear("Etoile Tiara", 20)  --Att 5
gear.etoileHeadPlusOne = hp_gear("Etoile Tiara +1", 20)  --Att 7
gear.etoileHeadPlusTwo = hp_gear("Etoile Tiara +2", 28)  --Acc 9, Att 9
gear.etoileBody = hp_gear("Etoile Casaque", 0)  --Acc 10, Att 12
gear.etoileBodyPlusOne = hp_gear("Etoile Casaque +1", 0)  --Acc 12, Att 14
gear.etoileBodyPlusTwo = hp_gear("Etoile Casaque +2", 0)  --Acc 15, Att 17
gear.etoileHands = hp_gear("Etoile Bangles", 15)  --Att 5, Enmity 2
gear.etoileHandsPlusOne = hp_gear("Etoile Bangles +1", 15)  --Att 5, Enmity 3
gear.etoileHandsPlusTwo = hp_gear("Etoile Bangles +2", 21)  --Acc 7, Att 7, Enmity 4
gear.etoileLegs = hp_gear("Etoile Tights", 0)  --Haste 3
gear.etoileLegsPlusOne = hp_gear("Etoile Tights +1", 0)  --Haste 3
gear.etoileLegsPlusTwo = hp_gear("Etoile Tights +2", 0)  --Haste 4, Acc 6
gear.etoileFeet = hp_gear("Etoile Toe Shoes", 15)  --Acc 3
gear.etoileFeetPlusOne = hp_gear("Etoile Toe Shoes +1", 20)  --Acc 5
gear.etoileFeetPlusTwo = hp_gear("Etoile Toe Shoes +2", 28)  --Acc 7

--DNC Relic Reforged (REA Set: Augments "Samba")
gear.horosHead = hp_gear("Horos Tiara", 37)  --Haste 7, MDB 1, Acc 12, Att 12
gear.horosHeadPlusOne = hp_gear("Horos Tiara +1", 66)  --Haste 8, MDB 2, Acc 15, Att 15
gear.horosHeadPlusTwo = hp_gear("Horos Tiara +2", 76)  --Haste 8, Macc 27, MDB 3, Acc 34, Att 62
gear.horosHeadPlusThree = hp_gear("Horos Tiara +3", 86)  --Haste 8, Macc 37, MDB 4, Acc 44, Att 77
gear.horosHeadPlusFour = hp_gear("Horos Tiara +4", 96)  --Haste 8, Macc 42, MDB 5, Acc 49, Att 87
gear.horosBody = hp_gear("Horos Casaque", 28)  --Haste 4, MDB 3, Acc 18, Att 18
gear.horosBodyPlusOne = hp_gear("Horos Casaque +1", 59)  --Haste 4, MDB 6, Acc 21, Att 21
gear.horosBodyPlusTwo = hp_gear("Horos Casaque +2", 69)  --TA 3, Haste 4, Macc 30, MDB 7, Acc 40
gear.horosBodyPlusThree = hp_gear("Horos Casaque +3", 79)  --TA 4, Haste 4, Macc 40, MDB 8, Acc 50
gear.horosBodyPlusFour = hp_gear("Horos Casaque +4", 89)  --TA 4, Haste 4, Macc 45, MDB 9, Acc 55
gear.horosHands = hp_gear("Horos Bangles", 41)  --Haste 4, MDB 1, Acc 9, Att 9, Enmity 6
gear.horosHandsPlusOne = hp_gear("Horos Bangles +1", 65)  --Haste 5, MDB 2, Acc 11, Att 11, Enmity 7
gear.horosHandsPlusTwo = hp_gear("Horos Bangles +2", 75)  --Haste 5, Macc 28, MDB 3, Acc 33, Att 59
gear.horosHandsPlusThree = hp_gear("Horos Bangles +3", 85)  --Haste 5, Macc 38, MDB 4, Acc 43, Att 74
gear.horosHandsPlusFour = hp_gear("Horos Bangles +4", 95)  --Haste 5, Macc 43, MDB 5, Acc 48, Att 84
gear.horosLegs = hp_gear("Horos Tights", 22)  --Haste 6, Macc 9, MDB 4, Acc 9
gear.horosLegsPlusOne = hp_gear("Horos Tights +1", 47)  --Haste 6, Macc 12, MDB 8, Acc 12
gear.horosLegsPlusTwo = hp_gear("Horos Tights +2", 57)  --WSD 5, Haste 6, Macc 35, MDB 9, Acc 35
gear.horosLegsPlusThree = hp_gear("Horos Tights +3", 67)  --WSD 10, Haste 6, Macc 45, MDB 10, Acc 45
gear.horosLegsPlusFour = hp_gear("Horos Tights +4", 77)  --WSD 12, Haste 6, Macc 50, MDB 11, Acc 50
gear.horosFeet = hp_gear("Horos Toe Shoes", 36)  --STP 4, Haste 4, MDB 2, Acc 10
gear.horosFeetPlusOne = hp_gear("Horos Toe Shoes +1", 53)  --STP 5, Haste 4, MDB 5, Acc 13
gear.horosFeetPlusTwo = hp_gear("Horos T. Shoes +2", 63)  --STP 6, Haste 4, Macc 26, MDB 6, Acc 32
gear.horosFeetPlusThree = hp_gear("Horos T. Shoes +3", 73)  --STP 7, Haste 4, Macc 36, MDB 7, Acc 42
gear.horosFeetPlusFour = hp_gear("Horos Toe Sh. +4", 83)  --STP 7, Haste 4, Macc 41, MDB 8, Acc 47

--DNC Empyrean (90-era) (Set: Augments "Samba")
gear.charisHead = hp_gear("Charis Tiara", 0)  --STP 2
gear.charisHeadPlusOne = hp_gear("Charis Tiara +1", 0)  --STP 4, Haste 5, Acc 3, Att 3
gear.charisHeadPlusTwo = hp_gear("Charis Tiara +2", 0)  --STP 7, Haste 6, Acc 8, Att 8
gear.charisBody = hp_gear("Charis Casaque", 0)  --DEX 4, CHR 4
gear.charisBodyPlusOne = hp_gear("Charis Casaque +1", 0)  --SB 7
gear.charisBodyPlusTwo = hp_gear("Charis Casaque +2", 0)  --SB 10
gear.charisHands = hp_gear("Charis Bangles", 0)  --Acc 2
gear.charisHandsPlusOne = hp_gear("Charis Bangles +1", 0)  --Acc 5
gear.charisHandsPlusTwo = hp_gear("Charis Bangles +2", 0)  --Acc 8
gear.charisLegs = hp_gear("Charis Tights", 0)
gear.charisLegsPlusOne = hp_gear("Charis Tights +1", 0)  --Haste 4
gear.charisLegsPlusTwo = hp_gear("Charis Tights +2", 0)  --Haste 5, Dagger Skill 5
gear.charisFeet = hp_gear("Charis Toe Shoes", 0)  --DEX 3, CHR 3
gear.charisFeetPlusOne = hp_gear("Charis Toe Shoes +1", 0)  --STP 4, Haste 3
gear.charisFeetPlusTwo = hp_gear("Charis Toe Shoes +2", 0)  --STP 8, Haste 4

--DNC Empyrean Reforged (REA Set: Augments "Samba")
gear.maculeleHead = hp_gear("Maculele Tiara", 19)  --STP 7, Haste 7, MDB 1, Acc 13, Att 13
gear.maculeleHeadPlusOne = hp_gear("Maculele Tiara +1", 41)  --STP 8, Haste 8, MDB 3, Acc 23, Att 23
gear.maculeleHeadPlusTwo = hp_gear("Maculele Tiara +2", 61)  --STP 9, WSD 8, Haste 8, Macc 51, MDB 6
gear.maculeleHeadPlusThree = hp_gear("Maculele Tiara +3", 71)  --STP 10, WSD 12, Haste 8, Macc 61, MDB 7
gear.maculeleBody = hp_gear("Maculele Casaque", 30)  --DW 10, Haste 4, MDB 3, SB 11
gear.maculeleBodyPlusOne = hp_gear("Macu. Casaque +1", 63)  --DW 11, Haste 4, MDB 6, SB 12
gear.maculeleBodyPlusTwo = hp_gear("Macu. Casaque +2", 83)  --DW 11, Haste 4, Macc 54, MDB 9, Acc 54
gear.maculeleBodyPlusThree = hp_gear("Macu. Casaque +3", 93)  --DW 11, Haste 4, Macc 64, MDB 10, Acc 64
gear.maculeleHands = hp_gear("Maculele Bangles", 12)  --Haste 4, MDB 1, Acc 16, SC Bonus 10
gear.maculeleHandsPlusOne = hp_gear("Macu. Bangles +1", 27)  --Haste 5, MDB 2, Acc 26, SC Bonus 11
gear.maculeleHandsPlusTwo = hp_gear("Macu. Bangles +2", 47)  --Haste 5, Macc 52, MDB 5, Acc 52, Att 52
gear.maculeleHandsPlusThree = hp_gear("Macu. Bangles +3", 57)  --Haste 5, Macc 62, MDB 6, Acc 62, Att 62
gear.maculeleLegs = hp_gear("Maculele Tights", 23)  --Haste 6, MDB 2, Dagger Skill 18
gear.maculeleLegsPlusOne = hp_gear("Maculele Tights +1", 50)  --Haste 6, MDB 5, Dagger Skill 28
gear.maculeleLegsPlusTwo = hp_gear("Maculele Tights +2", 70)  --Haste 6, Macc 53, MDB 8, Acc 53, Att 53
gear.maculeleLegsPlusThree = hp_gear("Maculele Tights +3", 80)  --Haste 6, Macc 63, MDB 9, Acc 63, Att 63
gear.maculeleFeet = hp_gear("Macu. Toe Shoes", 7)  --STP 9, Haste 4, MDB 2
gear.maculeleFeetPlusOne = hp_gear("Macu. Toe Shoes +1", 15)  --STP 10, Haste 5, MDB 5
gear.maculeleFeetPlusTwo = hp_gear("Macu. Toe Sh. +2", 35)  --STP 11, Haste 5, Macc 50, MDB 8, Acc 50
gear.maculeleFeetPlusThree = hp_gear("Macu. Toe Sh. +3", 45)  --STP 12, Haste 5, Macc 60, MDB 9, Acc 60

--SCH Artifact (75-era)
gear.scholarHead = mp_gear("Scholar's M.board", 15)  --INT 4
gear.scholarHeadPlusOne = mp_gear("Sch. M.board +1", 20)  --Enmity -1
gear.scholarBody = mp_gear("Scholar's Gown", 13)  --INT 1, MND 1
gear.scholarBodyPlusOne = mp_gear("Scholar's Gown +1", 18)  --INT 3, MND 3
gear.scholarHands = mp_gear("Scholar's Bracers", 15)  --SIRD 20, Enmity -2
gear.scholarHandsPlusOne = mp_gear("Sch. Bracers +1", 20)  --SIRD 20, Enmity -3
gear.scholarLegs = mp_gear("Scholar's Pants", 20)  --Enmity -1
gear.scholarLegsPlusOne = mp_gear("Scholar's Pants +1", 25)  --Enmity -2
gear.scholarFeet = mp_gear("Scholar's Loafers", 15)  --Enmity -2
gear.scholarFeetPlusOne = mp_gear("Sch. Loafers +1", 20)  --Enmity -2

--SCH Artifact Reforged (Set: Increases Accuracy, Ranged Accuracy, and Magic Accuracy)
gear.academicHead = hp_gear("Acad. Mortarboard", 17)  --Haste 5, MAB 10, Macc 10, MDB 2, Enmity -4
gear.academicHeadPlusOne = hp_gear("Acad. Mortar. +1", 36)  --Haste 6, MAB 10, Macc 10, MDB 5, Enmity -5
gear.academicHeadPlusTwo = hp_gear("Acad. Mortar. +2", 54)  --FC 4, Haste 6, MAB 15, Macc 42, MDB 5
gear.academicHeadPlusThree = hp_gear("Acad. Mortar. +3", 64)  --FC 8, Haste 6, MAB 20, Macc 52, MDB 6
gear.academicHeadPlusFour = hp_gear("Acad. Mortar. +4", 74)  --FC 8, Haste 6, MAB 22, Macc 62, MDB 7
gear.academicBody = hp_gear("Academic's Gown", 25)  --Haste 2, MDB 3
gear.academicBodyPlusOne = hp_gear("Acad. Gown +1", 54)  --Refresh 2, Haste 3, MDB 6
gear.academicBodyPlusTwo = hp_gear("Acad. Gown +2", 81)  --Refresh 2, Haste 3, Macc 40, MBD 5, MDB 6
gear.academicBodyPlusThree = hp_gear("Acad. Gown +3", 91)  --Refresh 3, Haste 3, Macc 50, MBD 10, MDB 7
gear.academicBodyPlusFour = hp_gear("Acad. Gown +4", 101)  --Refresh 3, Haste 3, Macc 60, MBD 10, MDB 8
gear.academicHands = hp_gear("Acad. Bracers", 10)  --Haste 3, MDB 1, ConMP 3, Enmity -4
gear.academicHandsPlusOne = hp_gear("Acad. Bracers +1", 22)  --FC 5, Haste 3, MDB 3, ConMP 4, Enmity -4
gear.academicHandsPlusTwo = hp_gear("Acad. Bracers +2", 33)  --FC 7, Haste 3, Macc 38, MDB 3, ConMP 6
gear.academicHandsPlusThree = hp_gear("Acad. Bracers +3", 43)  --FC 9, Haste 3, Macc 48, MDB 4, ConMP 8
gear.academicHandsPlusFour = hp_gear("Acad. Bracers +4", 53)  --FC 9, Haste 3, Macc 58, MDB 5, Acc 58
gear.academicLegs = hp_gear("Academic's Pants", 30)  --Haste 4, MDB 3, Enmity -4
gear.academicLegsPlusOne = hp_gear("Acad. Pants +1", 53)  --Haste 5, MDB 6, Enmity -4
gear.academicLegsPlusTwo = hp_gear("Acad. Pants +2", 79)  --Cure Pot 8, Haste 5, Macc 39, MDB 6, Enmity -5
gear.academicLegsPlusThree = hp_gear("Acad. Pants +3", 89)  --Cure Pot 15, Haste 5, Macc 49, MDB 7, Enmity -6
gear.academicLegsPlusFour = hp_gear("Acad. Pants +4", 99)  --Cure Pot 15, Haste 5, Macc 59, MDB 8, Acc 59
gear.academicFeet = hp_gear("Acad. Loafers", 6)  --Haste 3, MDB 2, Enmity -5
gear.academicFeetPlusOne = hp_gear("Acad. Loafers +1", 13)  --Haste 3, MDB 5, Enmity -6
gear.academicFeetPlusTwo = hp_gear("Acad. Loafers +2", 19)  --Haste 3, Macc 36, Macc 10, MDB 5, Enmity -7
gear.academicFeetPlusThree = hp_gear("Acad. Loafers +3", 29)  --Haste 3, Macc 46, Macc 20, MDB 6, Enmity -8
gear.academicFeetPlusFour = hp_gear("Acad. Loafers +4", 39)  --Haste 3, Macc 56, Macc 20, MDB 7, Acc 56

--SCH Relic (75-era)
gear.arguteArmorHead = hp_gear("Argute M.board", 10)  --Elemental magic Skill 7
gear.arguteArmorHeadPlusOne = hp_gear("Argute M.board +1", 12)  --Elemental magic Skill 7
gear.arguteArmorHeadPlusTwo = hp_gear("Argute M.board +2", 17)  --Elemental magic Skill 9
gear.arguteArmorBody = hp_gear("Argute Gown", 15)  --MDB 5, Enhancing magic Skill 7
gear.arguteArmorBodyPlusOne = hp_gear("Argute Gown +1", 17)  --MDB 6, Enhancing magic Skill 7
gear.arguteArmorBodyPlusTwo = hp_gear("Argute Gown +2", 24)  --MDB 8, Healing magic Skill 9, Enhancing magic Skill 9
gear.arguteArmorHands = mp_gear("Argute Bracers", 20)  --Enmity -2, Enfeebling magic Skill 7
gear.arguteArmorHandsPlusOne = mp_gear("Argute Bracers +1", 20)  --Enmity -3, Enfeebling magic Skill 7
gear.arguteArmorHandsPlusTwo = mp_gear("Argute Bracers +2", 28)  --Enmity -5, Healing magic Skill 9, Enfeebling magic Skill 9
gear.arguteArmorLegs = hp_gear("Argute Pants", 15)  --Enmity -2, Dark magic Skill 7
gear.arguteArmorLegsPlusOne = hp_gear("Argute Pants +1", 17)  --Enmity -3, Dark magic Skill 7
gear.arguteArmorLegsPlusTwo = hp_gear("Argute Pants +2", 24)  --Enmity -5, Elemental magic Skill 9, Dark magic Skill 9
gear.arguteArmorFeet = mp_gear("Argute Loafers", 20)  --Healing magic Skill 7
gear.arguteArmorFeetPlusOne = mp_gear("Argute Loafers +1", 25)  --Healing magic Skill 9
gear.arguteArmorFeetPlusTwo = mp_gear("Argute Loafers +2", 35)  --Healing magic Skill 12

--SCH Relic Reforged (REA Set: Augments grimoire)
gear.pedagogyHead = hp_gear("Peda. M.Board", 37)  --Haste 5, MDB 2, Elemental magic Skill 12
gear.pedagogyHeadPlusOne = hp_gear("Peda. M.Board +1", 66)  --Haste 6, MDB 5, Elemental magic Skill 15
gear.pedagogyHeadPlusTwo = hp_gear("Peda. M.Board +2", 76)  --Haste 6, MAB 42, Macc 27, MDB 6, Acc 27
gear.pedagogyHeadPlusThree = hp_gear("Peda. M.Board +3", 86)  --Haste 6, MAB 49, Macc 37, MDB 7, Acc 37
gear.pedagogyHeadPlusFour = hp_gear("Peda. Mortar. +4", 96)  --Haste 6, MAB 52, Macc 42, MDB 8, Acc 42
gear.pedagogyBody = hp_gear("Pedagogy Gown", 50)  --Haste 2, MDB 5, Healing magic Skill 12, Enhancing magic Skill 12
gear.pedagogyBodyPlusOne = hp_gear("Peda. Gown +1", 79)  --Haste 3, MDB 8, Healing magic Skill 15, Enhancing magic Skill 15
gear.pedagogyBodyPlusTwo = hp_gear("Peda. Gown +2", 89)  --Haste 3, MAB 45, Macc 30, MDB 9, Acc 30
gear.pedagogyBodyPlusThree = hp_gear("Peda. Gown +3", 99)  --Haste 3, MAB 52, Macc 40, MDB 10, Acc 40
gear.pedagogyBodyPlusFour = hp_gear("Peda. Gown +4", 109)  --Haste 3, MAB 55, Macc 45, MDB 11, Acc 45
gear.pedagogyHands = hp_gear("Peda. Bracers", 10)  --Haste 3, MDB 1, Enmity -5, Healing magic Skill 12, Enfeebling magic Skill 12
gear.pedagogyHandsPlusOne = hp_gear("Peda. Bracers +1", 22)  --Haste 3, MDB 3, Enmity -5, Healing magic Skill 15, Enfeebling magic Skill 15
gear.pedagogyHandsPlusTwo = hp_gear("Peda. Bracers +2", 32)  --Haste 3, MAB 43, Macc 28, MDB 4, Acc 28
gear.pedagogyHandsPlusThree = hp_gear("Peda. Bracers +3", 42)  --Haste 3, MAB 50, Macc 38, MDB 5, Acc 38
gear.pedagogyHandsPlusFour = hp_gear("Peda. Bracers +4", 52)  --Haste 3, MAB 53, Macc 43, MDB 6, Acc 43
gear.pedagogyLegs = hp_gear("Pedagogy Pants", 40)  --Haste 4, MDB 3, Enmity -5, Elemental magic Skill 12, Dark magic Skill 12
gear.pedagogyLegsPlusOne = hp_gear("Peda. Pants +1", 63)  --Haste 5, MDB 6, Enmity -5, Elemental magic Skill 15, Dark magic Skill 15
gear.pedagogyLegsPlusTwo = hp_gear("Peda. Pants +2", 73)  --Haste 5, MAB 44, Macc 29, MDB 7, Acc 29
gear.pedagogyLegsPlusThree = hp_gear("Peda. Pants +3", 83)  --Haste 5, MAB 51, Macc 39, MDB 8, Acc 39
gear.pedagogyLegsPlusFour = hp_gear("Peda. Pants +4", 93)  --Haste 5, MAB 54, Macc 44, MDB 9, Acc 44
gear.pedagogyFeet = hp_gear("Peda. Loafers", 6)  --FC 5, Haste 3, MDB 2, Healing magic Skill 14
gear.pedagogyFeetPlusOne = hp_gear("Peda. Loafers +1", 13)  --FC 6, Haste 3, MDB 5, Healing magic Skill 16
gear.pedagogyFeetPlusTwo = hp_gear("Peda. Loafers +2", 23)  --FC 7, Haste 3, MAB 41, Macc 26, MDB 6
gear.pedagogyFeetPlusThree = hp_gear("Peda. Loafers +3", 33)  --FC 8, Haste 3, MAB 48, Macc 36, MDB 7
gear.pedagogyFeetPlusFour = hp_gear("Peda. Loafers +4", 43)  --FC 8, Haste 3, MAB 51, Macc 41, MDB 8

--SCH Empyrean (90-era) (Set: Augments grimoire)
gear.savantHead = mp_gear("Savant's Bonnet", 16)
gear.savantHeadPlusOne = mp_gear("Svnt. Bonnet +1", 35)  --Enhancing magic Skill 8
gear.savantHeadPlusTwo = mp_gear("Svnt. Bonnet +2", 45)  --Enhancing magic Skill 10
gear.savantBody = hp_gear("Savant's Gown", 0)  --INT 4, MND 4
gear.savantBodyPlusOne = hp_gear("Savant's Gown +1", 0)  --MAB 8, Macc 8
gear.savantBodyPlusTwo = hp_gear("Savant's Gown +2", 0)  --MAB 11
gear.savantHands = mp_gear("Savant's Bracers", 7)  --INT 3, MND 3
gear.savantHandsPlusOne = mp_gear("Svnt. Bracers +1", 14)  --Enmity -3
gear.savantHandsPlusTwo = mp_gear("Svnt. Bracers +2", 20)  --Enmity -4
gear.savantLegs = hp_gear("Savant's Pants", 0)  --MND 4
gear.savantLegsPlusOne = hp_gear("Savant's Pants +1", 0)  --Macc 7, Enfeebling magic Skill 7
gear.savantLegsPlusTwo = hp_gear("Savant's Pants +2", 0)  --Macc 15, Enfeebling magic Skill 10
gear.savantFeet = mp_gear("Savant's Loafers", 10)  --INT 3
gear.savantFeetPlusOne = mp_gear("Svnt. Loafers +1", 22)  --Elemental magic Skill 7
gear.savantFeetPlusTwo = mp_gear("Svnt. Loafers +2", 35)  --Elemental magic Skill 10

--SCH Empyrean Reforged (REA Set: Augments grimoire)
gear.arbatelHead = hp_gear("Arbatel Bonnet", 15)  --Haste 5, MDB 3, Enhancing magic Skill 12
gear.arbatelHeadPlusOne = hp_gear("Arbatel Bonnet +1", 31)  --Haste 6, MDB 6, Enhancing magic Skill 14
gear.arbatelHeadPlusTwo = hp_gear("Arbatel Bonnet +2", 51)  --Haste 6, MAB 46, Macc 51, MDmg 21, MDB 9
gear.arbatelHeadPlusThree = hp_gear("Arbatel Bonnet +3", 61)  --Haste 6, MAB 51, Macc 61, MDmg 31, MDB 10
gear.arbatelBody = hp_gear("Arbatel Gown", 23)  --Refresh 2, Haste 2, MAB 15, Macc 15, MDB 3
gear.arbatelBodyPlusOne = hp_gear("Arbatel Gown +1", 50)  --Refresh 2, Haste 3, MAB 25, Macc 25, MDB 7
gear.arbatelBodyPlusTwo = hp_gear("Arbatel Gown +2", 70)  --Refresh 3, Haste 3, MAB 54, Macc 54, MDmg 24
gear.arbatelBodyPlusThree = hp_gear("Arbatel Gown +3", 80)  --Refresh 4, Haste 3, MAB 59, Macc 64, MDmg 34
gear.arbatelHands = hp_gear("Arbatel Bracers", 8)  --Haste 3, MDB 1, Enmity -6
gear.arbatelHandsPlusOne = hp_gear("Arbatel Bracers +1", 18)  --Haste 3, MDB 3, Enmity -8
gear.arbatelHandsPlusTwo = hp_gear("Arbatel Bracers +2", 38)  --Haste 3, MAB 47, Macc 52, MDmg 22, MBD 10
gear.arbatelHandsPlusThree = hp_gear("Arbatel Bracers +3", 48)  --Haste 3, MAB 52, Macc 62, MDmg 32, MBD 15
gear.arbatelLegs = hp_gear("Arbatel Pants", 18)  --Haste 4, Macc 21, MDB 3, Enfeebling magic Skill 10
gear.arbatelLegsPlusOne = hp_gear("Arbatel Pants +1", 38)  --Haste 5, Macc 26, MDB 6, Enfeebling magic Skill 18
gear.arbatelLegsPlusTwo = hp_gear("Arbatel Pants +2", 58)  --Haste 5, MAB 48, Macc 53, Macc 31, MDmg 23
gear.arbatelLegsPlusThree = hp_gear("Arbatel Pants +3", 68)  --Haste 5, MAB 54, Macc 63, Macc 36, MDmg 33
gear.arbatelFeet = hp_gear("Arbatel Loafers", 4)  --Haste 3, MDB 3, Elemental magic Skill 13
gear.arbatelFeetPlusOne = hp_gear("Arbatel Loafers +1", 9)  --Haste 3, MDB 6, Elemental magic Skill 23
gear.arbatelFeetPlusTwo = hp_gear("Arbatel Loafers +2", 29)  --Haste 3, MAB 45, Macc 50, MDmg 20, MDB 9
gear.arbatelFeetPlusThree = hp_gear("Arbatel Loafers +3", 39)  --Haste 3, MAB 50, Macc 60, MDmg 30, MDB 10

--GEO Artifact Reforged (Set: Increases Accuracy, Ranged Accuracy, and Magic Accuracy)
gear.geomancyHeadPlusOne = hp_gear("Geo. Galero +1", 36)  --Haste 6, MDB 5, Elemental magic Skill 15
gear.geomancyHeadPlusTwo = hp_gear("Geo. Galero +2", 54)  --Haste 6, Macc 37, MDB 5, Elemental magic Skill 17
gear.geomancyHeadPlusThree = hp_gear("Geo. Galero +3", 64)  --Haste 6, Macc 47, MDB 6, Elemental magic Skill 19
gear.geomancyHeadPlusFour = hp_gear("Geo. Galero +4", 74)  --Haste 6, Macc 57, MDB 7, Acc 57, Elemental magic Skill 20
gear.geomancyBody = hp_gear("Geomancy Tunic", 25)  --Haste 2, Dark magic Skill 15
gear.geomancyBodyPlusOne = hp_gear("Geo. Tunic +1", 54)  --Refresh 2, Haste 3, MDB 6, Dark magic Skill 17
gear.geomancyBodyPlusTwo = hp_gear("Geomancy Tunic +2", 81)  --Refresh 2, Haste 3, Macc 40, MDB 6, Dark magic Skill 19
gear.geomancyBodyPlusFour = hp_gear("Geo. Tunic +4", 101)  --Refresh 3, Haste 3, Macc 60, MDB 8, Acc 60
gear.geomancyHands = hp_gear("Geomancy Mitaines", 35)  --Haste 3, MDB 1, Geomancy Skill 15
gear.geomancyHandsPlusOne = hp_gear("Geo. Mitaines +1", 47)  --Haste 3, MDB 3, Geomancy Skill 15
gear.geomancyHandsPlusTwo = hp_gear("Geo. Mitaines +2", 70)  --Haste 3, Macc 38, MDB 3, Geomancy Skill 17
gear.geomancyHandsPlusFour = hp_gear("Geo. Mitaines +4", 90)  --Haste 3, Macc 58, MDB 5, Acc 58, Geomancy Skill 20
gear.geomancyLegs = hp_gear("Geomancy Pants", 55)  --SIRD 20, Haste 4, MDB 3
gear.geomancyLegsPlusOne = hp_gear("Geo. Pants +1", 78)  --FC 11, SIRD 20, Haste 5, MDB 6
gear.geomancyLegsPlusTwo = hp_gear("Geomancy Pants +2", 117)  --FC 13, SIRD 22, Haste 5, Macc 39, MDB 6
gear.geomancyLegsPlusThree = hp_gear("Geomancy Pants +3", 127)  --FC 15, SIRD 24, Haste 5, Macc 49, MDB 7
gear.geomancyLegsPlusFour = hp_gear("Geo. Pants +4", 137)  --FC 15, SIRD 24, Haste 5, Macc 59, MDB 8
gear.geomancyFeetPlusOne = hp_gear("Geo. Sandals +1", 13)  --Haste 3, MDB 5
gear.geomancyFeetPlusTwo = hp_gear("Geo. Sandals +2", 19)  --Haste 3, Macc 36, MDB 5
gear.geomancyFeetPlusThree = hp_gear("Geo. Sandals +3", 29)  --Haste 3, Macc 46, MDB 6
gear.geomancyFeetPlusFour = hp_gear("Geo. Sandals +4", 39)  --Haste 3, Macc 56, MDB 7, Acc 56

--GEO Relic Reforged (REA Set: MP occasionally not depleted when using geomancy spells)
gear.baguaArmorHead = hp_gear("Bagua Galero", 52)  --Haste 5, Macc 15, MDB 2
gear.baguaArmorHeadPlusOne = hp_gear("Bagua Galero +1", 71)  --Haste 6, Macc 18, MDB 5
gear.baguaArmorHeadPlusTwo = hp_gear("Bagua Galero +2", 81)  --Haste 6, MAB 42, Macc 36, MDB 6, Acc 27
gear.baguaArmorHeadPlusThree = hp_gear("Bagua Galero +3", 91)  --Haste 6, MAB 49, Macc 46, MDB 7, Acc 37
gear.baguaArmorHeadPlusFour = hp_gear("Bagua Galero +4", 101)  --Haste 6, MAB 52, Macc 51, MDB 8, Acc 42
gear.baguaArmorBody = hp_gear("Bagua Tunic", 65)  --Haste 2, MAB 20, MDB 3, Geomancy Skill 10
gear.baguaArmorBodyPlusOne = hp_gear("Bagua Tunic +1", 94)  --Haste 3, MAB 23, MDB 6, Geomancy Skill 12
gear.baguaArmorBodyPlusTwo = hp_gear("Bagua Tunic +2", 104)  --Haste 3, MAB 56, Macc 30, MDB 7, Acc 30
gear.baguaArmorBodyPlusThree = hp_gear("Bagua Tunic +3", 114)  --Haste 3, MAB 63, Macc 40, MDB 8, Acc 40
gear.baguaArmorBodyPlusFour = hp_gear("Bagua Tunic +4", 124)  --Haste 3, MAB 66, Macc 45, MDB 9, Acc 45
gear.baguaArmorHands = hp_gear("Bagua Mitaines", 10)  --Refresh 1, Haste 3, MDB 1, Enmity -5
gear.baguaArmorHandsPlusOne = hp_gear("Bagua Mitaines +1", 22)  --Refresh 1, Haste 3, MDB 3, Enmity -6
gear.baguaArmorHandsPlusTwo = hp_gear("Bagua Mitaines +2", 32)  --Refresh 1, Haste 3, MAB 43, Macc 28, MBD 8
gear.baguaArmorHandsPlusThree = hp_gear("Bagua Mitaines +3", 42)  --Refresh 2, Haste 3, MAB 50, Macc 38, MBD 12
gear.baguaArmorHandsPlusFour = hp_gear("Bagua Mitaines +4", 52)  --Refresh 2, Haste 3, MAB 53, Macc 43, MBD 12
gear.baguaArmorLegs = hp_gear("Bagua Pants", 60)  --Haste 4, MDB 3
gear.baguaArmorLegsPlusOne = hp_gear("Bagua Pants +1", 98)  --Haste 5, MDB 6
gear.baguaArmorLegsPlusTwo = hp_gear("Bagua Pants +2", 108)  --Haste 5, MAB 44, Macc 29, MDB 7, Acc 29
gear.baguaArmorLegsPlusThree = hp_gear("Bagua Pants +3", 118)  --Haste 5, MAB 51, Macc 39, MDB 8, Acc 39
gear.baguaArmorLegsPlusFour = hp_gear("Bagua Pants +4", 128)  --Haste 5, MAB 54, Macc 44, MDB 9, Acc 44
gear.baguaArmorFeet = hp_gear("Bagua Sandals", 36)  --Haste 3, MDB 2, Enfeebling magic Skill 15
gear.baguaArmorFeetPlusOne = hp_gear("Bagua Sandals +1", 43)  --Haste 3, MDB 5, Enfeebling magic Skill 17
gear.baguaArmorFeetPlusTwo = hp_gear("Bagua Sandals +2", 53)  --Haste 3, MAB 41, Macc 26, MDB 6, Acc 26
gear.baguaArmorFeetPlusThree = hp_gear("Bagua Sandals +3", 63)  --Haste 3, MAB 48, Macc 36, MDB 7, Acc 36
gear.baguaArmorFeetPlusFour = hp_gear("Bagua Sandals +4", 73)  --Haste 3, MAB 51, Macc 41, MDB 8, Acc 41

--GEO Empyrean Reforged (REA Set: MP occasionally not depleted when using geomancy spells)
gear.azimuthHead = hp_gear("Azimuth Hood", 15)  --Haste 5, MDB 3, Geomancy Skill 10
gear.azimuthHeadPlusOne = hp_gear("Azimuth Hood +1", 31)  --Haste 6, MDB 6, Geomancy Skill 15
gear.azimuthHeadPlusTwo = hp_gear("Azimuth Hood +2", 51)  --Haste 6, MAB 46, Macc 51, MDmg 21, MDB 9
gear.azimuthHeadPlusThree = hp_gear("Azimuth Hood +3", 61)  --Haste 6, MAB 51, Macc 61, MDmg 31, MDB 10
gear.azimuthBody = hp_gear("Azimuth Coat", 23)  --Refresh 2, Haste 2, MAB 13, Macc 13, MDB 3
gear.azimuthBodyPlusOne = hp_gear("Azimuth Coat +1", 50)  --Refresh 2, Haste 3, MAB 23, Macc 23, MDB 7
gear.azimuthBodyPlusTwo = hp_gear("Azimuth Coat +2", 70)  --Refresh 3, Haste 3, MAB 54, Macc 54, MDmg 24
gear.azimuthBodyPlusThree = hp_gear("Azimuth Coat +3", 80)  --Refresh 4, Haste 3, MAB 59, Macc 64, MDmg 34
gear.azimuthHands = hp_gear("Azimuth Gloves", 8)  --Haste 3, Macc 17, MDB 1, Enmity -10, Enfeebling magic Skill 13
gear.azimuthHandsPlusOne = hp_gear("Azimuth Gloves +1", 18)  --Haste 3, Macc 27, MDB 3, Enmity -11, Enfeebling magic Skill 18
gear.azimuthHandsPlusTwo = hp_gear("Azimuth Gloves +2", 38)  --Haste 3, MAB 47, Macc 52, MDmg 22, MDB 6
gear.azimuthHandsPlusThree = hp_gear("Azimuth Gloves +3", 48)  --Haste 3, MAB 52, Macc 62, MDmg 32, MDB 7
gear.azimuthLegs = hp_gear("Azimuth Tights", 18)  --Haste 4, MAB 10, Macc 10, MDB 3, Dark magic Skill 15
gear.azimuthLegsPlusOne = hp_gear("Azimuth Tights +1", 38)  --Haste 5, MAB 20, Macc 20, MDB 6, Dark magic Skill 20
gear.azimuthLegsPlusTwo = hp_gear("Azimuth Tights +2", 58)  --Haste 5, MAB 53, Macc 53, MDmg 23, MBD 10
gear.azimuthLegsPlusThree = hp_gear("Azimuth Tights +3", 68)  --Haste 5, MAB 58, Macc 63, MDmg 33, MBD 15
gear.azimuthFeet = hp_gear("Azimuth Gaiters", 34)  --Haste 3, MDB 3
gear.azimuthFeetPlusOne = hp_gear("Azimuth Gaiters +1", 39)  --Haste 3, MDB 6
gear.azimuthFeetPlusTwo = hp_gear("Azimuth Gaiters +2", 49)  --Haste 3, MAB 45, Macc 50, MDmg 20, MDB 9
gear.azimuthFeetPlusThree = hp_gear("Azimuth Gaiters +3", 59)  --Haste 3, MAB 50, Macc 60, MDmg 30, MDB 10

--RUN Artifact Reforged (Set: Increases Accuracy, Ranged Accuracy, and Magic Accuracy)
gear.runeistHead = hp_gear("Runeist Bandeau", 47)  --Haste 7, MDB 1
gear.runeistHeadPlusOne = hp_gear("Rune. Bandeau +1", 66)  --FC 10, Haste 8, MDB 2
gear.runeistHeadPlusTwo = hp_gear("Rune. Bandeau +2", 99)  --FC 12, Haste 8, MDB 2, Acc 37
gear.runeistHeadPlusThree = hp_gear("Rune. Bandeau +3", 109)  --FC 14, Haste 8, MDB 3, Acc 47
gear.runeistHeadPlusFour = hp_gear("Runeist Bandeau +4", 119)  --FC 14, Haste 8, Macc 57, MDB 4, Acc 57
gear.runeistBody = hp_gear("Runeist Coat", 108)  --Haste 3
gear.runeistBodyPlusOne = hp_gear("Runeist Coat +1", 139)  --Refresh 2, Haste 4, MDB 6
gear.runeistBodyPlusTwo = hp_gear("Runeist Coat +2", 208)  --Refresh 2, Haste 4, MDB 6, Acc 40
gear.runeistBodyPlusThree = hp_gear("Runeist Coat +3", 218)  --Refresh 3, Haste 4, MDB 7, Acc 50
gear.runeistBodyPlusFour = hp_gear("Runeist Coat +4", 228)  --Refresh 3, Haste 4, Macc 60, MDB 8, Acc 60
gear.runeistHands = hp_gear("Runeist Mitons", 36)  --Haste 4, MDB 1, Enhancing magic Skill 15
gear.runeistHandsPlusOne = hp_gear("Runeist Mitons +1", 50)  --Haste 5, MDB 2, Enhancing magic Skill 15
gear.runeistHandsPlusTwo = hp_gear("Runeist Mitons +2", 75)  --Haste 5, MDB 2, Acc 38, Enhancing magic Skill 17
gear.runeistHandsPlusThree = hp_gear("Runeist Mitons +3", 85)  --Haste 5, MDB 3, Acc 48, Enhancing magic Skill 19
gear.runeistHandsPlusFour = hp_gear("Rune. Mitons +4", 95)  --Haste 5, Macc 58, MDB 4, Acc 58, Enhancing magic Skill 20
gear.runeistLegs = hp_gear("Runeist Trousers", 22)  --PDT 3, Haste 6
gear.runeistLegsPlusOne = hp_gear("Rune. Trousers +1", 47)  --Haste 6, MDB 5, Divine magic Skill 15
gear.runeistLegsPlusTwo = hp_gear("Rune. Trousers +2", 70)  --Haste 6, MDB 5, Acc 39, Divine magic Skill 17
gear.runeistLegsPlusThree = hp_gear("Rune. Trousers +3", 80)  --Haste 6, MDB 6, Acc 49, Divine magic Skill 19
gear.runeistLegsPlusFour = hp_gear("Rune. Trousers +4", 90)  --Haste 6, Macc 59, MDB 7, Acc 59, Divine magic Skill 20
gear.runeistFeet = hp_gear("Runeist Bottes", 36)  --Haste 4, MDB 2
gear.runeistFeetPlusOne = hp_gear("Runeist Bottes +1", 43)  --Haste 4, MDB 5
gear.runeistFeetPlusTwo = hp_gear("Runeist Bottes +2", 64)  --Haste 4, MDB 5, Acc 36
gear.runeistFeetPlusThree = hp_gear("Runeist Bottes +3", 74)  --Haste 4, MDB 6, Acc 46
gear.runeistFeetPlusFour = hp_gear("Runeist Boots +4", 84)  --Haste 4, Macc 56, MDB 7, Acc 56

--RUN Relic Reforged (REA Set: Occ. absorbs damage taken)
gear.futharkHead = hp_gear("Futhark Bandeau", 17)  --Haste 7, MDB 1
gear.futharkHeadPlusOne = hp_gear("Fu. Bandeau +1", 36)  --Haste 8, MDB 2
gear.futharkHeadPlusTwo = hp_gear("Fu. Bandeau +2", 46)  --Haste 8, Macc 27, MDB 3, Acc 27, Att 47
gear.futharkHeadPlusThree = hp_gear("Fu. Bandeau +3", 56)  --Haste 8, Macc 37, MDB 4, Acc 37, Att 62
gear.futharkHeadPlusFour = hp_gear("Fu. Bandeau +4", 66)  --Haste 8, Macc 42, MDB 5, Acc 42, Att 72
gear.futharkBody = hp_gear("Futhark Coat", 68)  --Regen 2, Haste 4, MDB 3
gear.futharkBodyPlusOne = hp_gear("Futhark Coat +1", 99)  --Regen 3, Haste 4, MDB 6
gear.futharkBodyPlusTwo = hp_gear("Futhark Coat +2", 109)  --Regen 4, Haste 4, Macc 30, MDB 7, Acc 30
gear.futharkBodyPlusThree = hp_gear("Futhark Coat +3", 119)  --Regen 5, Haste 4, Macc 40, MDB 8, Acc 40
gear.futharkBodyPlusFour = hp_gear("Futhark Coat +4", 129)  --Regen 5, Haste 4, Macc 45, MDB 9, Acc 45
gear.futharkHands = hp_gear("Futhark Mitons", 11)  --Haste 4, MDB 4, Att 15, Enmity 3
gear.futharkHandsPlusOne = hp_gear("Futhark Mitons +1", 25)  --Haste 5, MDB 6, Att 18, Enmity 4
gear.futharkHandsPlusTwo = hp_gear("Futhark Mitons +2", 35)  --Haste 5, Macc 28, MDB 7, Acc 28, Att 66
gear.futharkHandsPlusThree = hp_gear("Futhark Mitons +3", 45)  --Haste 5, Macc 38, MDB 8, Acc 38, Att 81
gear.futharkHandsPlusFour = hp_gear("Futhark Mitons +4", 55)  --Haste 5, Macc 43, MDB 9, Acc 43, Att 91
gear.futharkLegs = hp_gear("Futhark Trousers", 62)  --Haste 6, MDB 2
gear.futharkLegsPlusOne = hp_gear("Futhark Trousers +1", 87)  --Haste 6, MDB 5
gear.futharkLegsPlusTwo = hp_gear("Futhark Trousers +2", 97)  --Haste 6, Macc 29, MDB 6, Acc 29, Att 49
gear.futharkLegsPlusThree = hp_gear("Futhark Trousers +3", 107)  --Haste 6, Macc 39, MDB 7, Acc 39, Att 64
gear.futharkLegsPlusFour = hp_gear("Futh. Trousers +4", 117)  --Haste 6, Macc 44, MDB 8, Acc 44, Att 74
gear.futharkFeet = hp_gear("Futhark Boots", 6)  --Haste 4, MDB 2, Acc 15, Parrying Skill 13
gear.futharkFeetPlusOne = hp_gear("Futhark Boots +1", 13)  --Haste 4, MDB 5, Acc 18, Parrying Skill 15
gear.futharkFeetPlusTwo = hp_gear("Futhark Boots +2", 23)  --Haste 4, Macc 26, MDB 6, Acc 35, Att 46
gear.futharkFeetPlusThree = hp_gear("Futhark Boots +3", 33)  --Haste 4, Macc 36, MDB 7, Acc 45, Att 61
gear.futharkFeetPlusFour = hp_gear("Futh. Boots +4", 43)  --Haste 4, Macc 41, MDB 8, Acc 50, Att 71

--RUN Empyrean Reforged (REA Set: Occ. absorbs damage taken)
gear.erilazHead = hp_gear("Erilaz Galea", 69)  --Haste 7, MDB 2
gear.erilazHeadPlusOne = hp_gear("Erilaz Galea +1", 91)  --Haste 8, MDB 5
gear.erilazHeadPlusTwo = hp_gear("Erilaz Galea +2", 101)  --SIRD 15, Haste 8, Macc 51, MDB 8, Acc 51
gear.erilazHeadPlusThree = hp_gear("Erilaz Galea +3", 111)  --SIRD 20, Haste 8, Macc 61, MDB 9, Acc 61
gear.erilazBody = hp_gear("Erilaz Surcoat", 90)  --Haste 4, MDB 3, Acc 18, Att 18
gear.erilazBodyPlusOne = hp_gear("Erilaz Surcoat +1", 123)  --Haste 4, MDB 6, Acc 28, Att 28
gear.erilazBodyPlusTwo = hp_gear("Erilaz Surcoat +2", 133)  --FC 10, Haste 4, Macc 54, MDB 9, Acc 54
gear.erilazBodyPlusThree = hp_gear("Erilaz Surcoat +3", 143)  --FC 13, Haste 4, Macc 64, MDB 10, Acc 64
gear.erilazHands = hp_gear("Erilaz Gauntlets", 14)  --Haste 4, MDB 1, Great Sword Skill 18
gear.erilazHandsPlusOne = hp_gear("Erilaz Gauntlets +1", 29)  --Haste 5, MDB 3, Great Sword Skill 28
gear.erilazHandsPlusTwo = hp_gear("Erilaz Gauntlets +2", 49)  --Haste 5, Macc 52, MDB 6, Acc 52, Att 52
gear.erilazHandsPlusThree = hp_gear("Erilaz Gauntlets +3", 59)  --Haste 5, Macc 62, MDB 7, Acc 62, Att 62
gear.erilazLegs = hp_gear("Erilaz Leg Guards", 53)  --PDT 6, Haste 6, MDB 3, Enmity 10
gear.erilazLegsPlusOne = hp_gear("Eri. Leg Guards +1", 80)  --PDT 7, Haste 6, MDB 6, Enmity 11
gear.erilazLegsPlusTwo = hp_gear("Eri. Leg Guards +2", 90)  --Haste 6, Macc 53, MDB 9, Acc 53, Att 53
gear.erilazLegsPlusThree = hp_gear("Eri. Leg Guards +3", 100)  --Haste 6, Macc 63, MDB 10, Acc 63, Att 63
gear.erilazFeet = hp_gear("Erilaz Greaves", 8)  --Haste 4, MDB 2, Enmity 5
gear.erilazFeetPlusOne = hp_gear("Erilaz Greaves +1", 18)  --Haste 4, MDB 5, Enmity 6
gear.erilazFeetPlusTwo = hp_gear("Erilaz Greaves +2", 38)  --Haste 4, Macc 50, MDB 8, Acc 50, Att 50
gear.erilazFeetPlusThree = hp_gear("Erilaz Greaves +3", 48)  --Haste 4, Macc 60, MDB 9, Acc 60, Att 60

--[[ Sets ]]                                             --

--Adhemar
gear.adhemarHeadPlusOnePathA = hp_gear("Adhemar Bonnet +1", 41,
    { augments = { 'DEX+12', 'AGI+12', 'Accuracy+20' } }) --TA 4, SB 8, Crit Dmg 6
gear.adhemarBodyPlusOnePathA = hp_gear("Adhemar Jacket +1", 63,
    { augments = { 'DEX+12', 'AGI+12', 'Accuracy+20' } }) --TA 4, DW 6, Enmity -8
gear.adhemarHandsPlusOnePathA = hp_gear("Adhemar Wrist. +1", 22,
    { augments = { 'DEX+12', 'AGI+12', 'Accuracy+20' } }) --TA 4, STP 7

--Agwu
gear.agwuHead = hp_gear("Agwu's Cap", 38)      --FC 5, Macc 40, MAB 35, MDmg 20, Magic Burst 7, SIRD 10
gear.agwuBody = hp_gear("Agwu's Robe", 61)     --FC 8, Macc 40, MAB 35, MDmg 20, Magic Burst 10, Refresh 3
gear.agwuHands = hp_gear("Agwu's Gages", 38)   --FC 6, Macc 40, MAB 35, MDmg 20, Magic Burst 8, Cure Rec 10
gear.agwuLegs = hp_gear("Agwu's Slops", 50)    --FC 7, Macc 40, MAB 35, MDmg 20, Magic Burst 9, Elemental Status Ailment Effect 10
gear.agwuFeet = hp_gear("Agwu's Pigaches", 27) --FC 4, Macc 40, MAB 35, MDmg 20, Magic Burst 6, Drain/Aspir 20

--Amalric
gear.amalricHandsPathD = hp_gear("Amalric Gages", 13, {
    augments = { 'INT+10', 'Mag. Acc.+15', '"Mag.Atk.Bns."+15', }, }) --SIRD 10, Macc 15, MAB 38, Elemental Magic 13, Magic Burst Damage II 5,

--Ayanmo (Set Increases STR/VIT/MND)
gear.ayanmoHeadPlusTwo = hp_gear("Aya. Zucchetto +2", 45)  --DT 3, STP 6, Acc 44, Macc 44, DEX 39
gear.ayanmoBodyPlusTwo = hp_gear("Ayanmo Corazza +2", 57)  --DT 6, DA 7, Acc 46, Macc 46, DEX 48
gear.ayanmoHandsPlusTwo = hp_gear("Aya. Manopolas +2", 22) --DT 3, Acc 43, Macc 43, Dex 53, Sword Enhancment Spell Damage 17
gear.ayanmoLegsPlusTwo = hp_gear("Aya. Cosciales +2", 45)  --DT 5, FC 6, Acc 45, Macc 45, DEX 11
gear.ayanmoFeetPlusTwo = hp_gear("Aya. Gambieras +2", 11)  --DT 3, Crit 6, Acc 42, Macc 42, DEX 37

--Bunzi
gear.bunziHead = hp_gear("Bunzi's Hat", 50)     --FC 10, DT 7, Macc 40, MAB 30, MDmg 30, Magic Burst 7, Enmity -7
gear.bunziBody = hp_gear("Bunzi's Robe", 72)    --DT 10, Macc 40, MAB 30, MDmg 30, Cure Pot 15, Magic Burst 10, Enmity -10
gear.bunziHands = hp_gear("Bunzi's Gloves", 50) --DT 8, DA 8, Macc 40, MAB 30, MDmg 30, Magic Burst 8, Enmity -8
gear.bunziLegs = hp_gear("Bunzi's Pants", 61)   --DT 9 Macc 40, MAB 30, MDmg 30, SIRD 20, Magic Burst 9, Enmity -9
gear.bunziFeet = hp_gear("Bunzi's Sabots", 38)  --DT 6, Macc 40, MAB 30, MDmg 30, Magic Burst 6, Avatar Lvl+ 1

--Carmine
gear.carmineHeadPlusOnePathD = hp_gear("Carmine Mask +1", 38, {
    augments = { 'Accuracy+20', 'Mag. Acc.+12', '"Fast Cast"+4' }, }) --FC 14, Haste 8
gear.carmineLegsPlusOnePathD = hp_gear("Carmine Cuisses +1", 50, {
    augments = { 'Accuracy+20', 'Attack+12', '"Dual Wield"+6' }, })   --DW 6, SIRD 20, MS 18
gear.carmineLegsPlusOnePathA = hp_gear("Carmine Cuisses +1", 130, {
    augments = { 'HP+80', 'STR+12', 'INT+12' }, })                    --SIRD 20, MS 18
gear.carmineFeetPlusOnePathD = hp_gear("Carmine Greaves +1", 95, {
    augments = { 'HP+80', 'MP+80', 'Phys. dmg. taken -4' }, })        --FC 8, Haste 4

--Doyen
gear.doyenLegs = hp_gear("Doyen Pants", 43) --Cure FC 15, Stoneskin FC 10, Song FC 6

--Enif
gear.enifLegs = hp_gear("Enif Cosciales", 40) --FC 8, Haste 5

--Flamma (Set Increases STR, DEX, VIT)
gear.flammaHeadPlusTwo = hp_gear("Flam. Zucchetto +2", 80) --TA 5, STP 6
gear.flammaBodyPlusTwo = hp_gear("Flamma Korazin +2", 140) --STP 9, SB 17
gear.flammaFeetPlusTwo = hp_gear("Flam. Gambieras +2", 40) --DA 6, STP 6

--Gazu
gear.gazuHandsPlusOne = hp_gear("Gazu Bracelets +1", 27) --Acc 81, Haste 15, DEX 42

--Gleti
gear.gletiHead = hp_gear("Gleti's Mask", 68)       --PDT 6, PDL 6, Enmity -8, Crit 5
gear.gletiBody = hp_gear("Gleti's Cuirass", 91)    --PDT 9, PDL 9, Waltz 10, Crit 8
gear.gletiHands = hp_gear("Gleti's Gauntlets", 68) --PDT 7, PDL 7, Crit 6
gear.gletiLegs = hp_gear("Gleti's Breeches", 79)   --PDT 8, PDL 8, Sic/Ready Delay -5, Crit 7
gear.gletiFeet = hp_gear("Gleti's Boots", 57)      --PDT 5, PDL 5, Pet Lvl +1, Crit 4

--Hjarrandi
gear.hjarrandiHead = hp_gear("Hjarrandi Helm", 114)    --DT 10, STP 7, DA 6
gear.hjarrandiBody = hp_gear("Hjarrandi Breast.", 228) --DT 12, Crit 13, STP 10

--Ikenga
gear.ikengaHead = hp_gear("Ikenga's Hat", 57)      --Snapshot 6, Enmity -7, STP 8, PDL 4, Racc 40, AGI 29
gear.ikengaBody = hp_gear("Ikenga's Vest", 79)     --Snapshot 9, Enmity -10, STP 11, PDL 7, Racc 40, AGI 39
gear.ikengaHands = hp_gear("Ikenga's Gloves", 57)  --Snapshot 7, Enmity -8, STP 9, PDL 5, Racc 40, AGI 19
gear.ikengaLegs = hp_gear("Ikenga's Trousers", 68) --Snapshot 8, Enmity -9, STP 10, PDL 6, Racc 40, AGI 40
gear.ikengaFeet = hp_gear("Ikenga's Clogs", 45)    --Snapshot 5, Enmity -6, STP 7, PDL 3, Racc 40, AGI 52

--Inyanga (Set Refresh)
gear.inyangaHeadPlusTwo = hp_gear("Inyanga Tiara +2", 45)     --MDT 5, Regen Pot 14
gear.inyangaBodyPlusTwo = hp_gear("Inyanga Jubbah +2", 85)    --MDT 8, FC 14
gear.inyangaHandsPlusTwo = hp_gear("Inyanga Dastanas +2", 35) --MDT 4, Magic Skills +20
gear.inyangaLegsPlusTwo = hp_gear("Inyanga Shalwar +2", 55)   --MDT 6, Song Dur 17
gear.inyangaFeetPlusTwo = hp_gear("Inyanga Crackows +2", 25)  --MDT 3, Blood Pact +9

--Jhakri (Set Enhances Fast Cast)
gear.jhakriHeadPlusTwo = hp_gear("Jhakri Coronal +2", 0)  --Macc 44, MAB 41
gear.jhakriBodyPlusTwo = hp_gear("Jhakri Robe +2", 0)     --Macc 46, MAB 43, Refresh 4
gear.jhakriHandsPlusTwo = hp_gear("Jhakri Cuffs +2", 0)   --WSD 7, Macc 43, MAB 40
gear.jhakriLegsPlusTwo = hp_gear("Jhakri Slops +2", 0)    --STP 9, Macc 45, MAB 42
gear.jhakriFeetPlusTwo = hp_gear("Jhakri Pigaches +2", 0) --Macc 42, MAB 39

--Kaykaus (Set enhances Cure Pot II Effect)
gear.kaykausLegsPlusOnePathC = hp_gear("Kaykaus Tights +1", 41, {
    augments = { 'MP+80', 'Spell interruption rate down +12%', '"Cure" spellcasting time -7%' }, })                       --FC 7, Cure Pot 11, SIRD 12, FC Cure 7, MP 80
gear.kaykausFeetPathB = hp_gear("Kaykaus Boots", 11, { augments = { 'MP+60', '"Cure" spellcasting time -5%', 'Enmity-5', } }) --Cure FC 5, Cure Pot 10, Enmity -5, Enhancing Magic 20

--Kendatsuba
gear.kendatsubaFeetPlusOne = hp_gear("Ken. Sune-Ate +1", 70) --TA 4, SB 8, Crit 5

--Malignance
gear.malignanceHead = hp_gear("Malignance Chapeau", 45) --DT 6, STP 8
gear.malignanceBody = hp_gear("Malignance Tabard", 68)  --DT 9, STP 11
gear.malignanceHands = hp_gear("Malignance Gloves", 57) --DT 5, STP 12
gear.malignanceLegs = hp_gear("Malignance Tights", 45)  --DT 7, STP 10
gear.malignanceFeet = hp_gear("Malignance Boots", 34)   --DT 4, STP 9

--Meghanada (Set Regen+)
gear.meghanadaHeadPlusTwo = hp_gear("Meghanada Visor +2", 25) --PDT 5, Racc 48, Ratt 44, Dead Aim 12
gear.meghanadaBodyPlusTwo = hp_gear("Meg. Cuirie +2", 40)     --PDT 8, Crit Dam 6
gear.meghanadaHandsPlusTwo = hp_gear("Meg. Gloves +2", 30)    --PDT 4, WSD 7, PDT 4, Acc 47, Att 43, STR 23
gear.meghanadaLegsPlusTwo = hp_gear("Meg. Chausses +2", 35)   --PDT 6, TA 5, Racc 49, Ratt 45
gear.meghanadaFeetPlusTwo = hp_gear("Meg. Jam. +2", 20)       --PDT 3, AGI 54, Racc 46, Ratt 42, Snapshot 10

--Mousai
gear.mousaiLegsPlusOne = hp_gear("Mou. Seraweels +1", 156) --Minne 2

--Mpaca
gear.mpacaHead = hp_gear("Mpaca's Cap", 61)     --PDT 7, TA 3, Crit 4, TP Bonus 200
gear.mpacaBody = hp_gear("Mpaca's Doublet", 84) --PDT 10, TA 4, Crit 7, Counter 10
gear.mpacaHands = hp_gear("Mpaca's Gloves", 61) --PDT 8, TA 3, Crit 5, Automaton WSD 10
gear.mpacaLegs = hp_gear("Mpaca's Hose", 72)    --PDT 9, TA 4, Crit 6, SB II 5
gear.mpacaFeet = hp_gear("Mpaca's Boots", 50)   --PDT 6, TA 3, Crit 3, Automaton Lvl +1

--Mrigavyadha Gloves
gear.mrigavyadhaHands = hp_gear("Mrigavyadha Gloves", 22) --Rapid Shot 15, STP 8

--Nisroch
gear.nisrochBody = hp_gear("Nisroch Jerkin", 91) --STP 7, Racc/Ratk 45, AGI 40

--Nyame
gear.nyameHead = hp_gear("Nyame Helm", 91)       --DT 7
gear.nyameBody = hp_gear("Nyame Mail", 136)      --DT 9
gear.nyameHands = hp_gear("Nyame Gauntlets", 91) --DT 7
gear.nyameLegs = hp_gear("Nyame Flanchard", 114) --DT 8
gear.nyameFeet = hp_gear("Nyame Sollerets", 68)  --DT 7

--Odyssean
gear.odysseanFCFeet = hp_gear("Odyssean Greaves", 20, {
    augments = { '"Blood Boon"+2', '"Fast Cast"+5', 'Phalanx +2', 'Accuracy+18 Attack+18' }, }) --FC 10, SIRD 20, Cure Pot 7, Phalanx Rec 2

--Oshosi
gear.oshosiLegs = hp_gear("Oshosi Trousers", 84) --Racc 36, Snapshot 10, True Shot 4, DS 6, TS 5

--Pixie
gear.pixieHead = hp_gear("Pixie Hairpin +1", -35) --Dark MAB 28, INT 27

--Rawhide
gear.rawhideFeet = hp_gear("Rawhide Boots", 13) --Waltz 8%

--Sacro
gear.sacroBody = hp_gear("Sacro Breastplate", 182) --FC 10, Regen 13, SB 15

--Sakpata
gear.sakpataHead = hp_gear("Sakpata's Helm", 91)       --DT 7, FC 8, DA 5, PDL 5
gear.sakpataBody = hp_gear("Sakpata's Plate", 136)     --DT 10, DA 8, PDL 8, Cure Rec 10
gear.sakpataHands = hp_gear("Sakpata's Gauntlets", 91) --DT 8, DA 6, SB 8, PDL 6
gear.sakpataLegs = hp_gear("Sakpata's Cuisses", 114)   --DT 9, DA 7, PDL 7, Phalanx Rec 5
gear.sakpataFeet = hp_gear("Sakpata's Leggings", 68)   --DT 6, DA 4, PDL 4, Counter 5

--Shamash
gear.shamashRobe = hp_gear("Shamash Robe", 57) --Macc 45, MAB 45, INT 40, Enmity -10

--Souveran
gear.souveranHeadPlusOnePathC = hp_gear("Souv. Schaller +1", 280,
    { augments = { 'HP+105', 'Enmity+9', 'Potency of "Cure" effect received +15%', }, }) --SIRD 20, Enmity 9, Cure Rec 15
gear.souveranBodyPlusOnePathC = hp_gear("Souv. Cuirass +1", 171,
    { augments = { 'HP+105', 'Enmity+9', 'Potency of "Cure" effect received +15%', }, }) --DT 10, Enmity 20, Cure Pot 11, Cure Rec 15
gear.souveranHandsPlusOnePathC = hp_gear("Souv. Handsch. +1", 239,
    { augments = { 'HP+105', 'Enmity+9', 'Potency of "Cure" effect received +15%' }, })  --MDT 5, Enmity 9, Cure Rec 15, Phalanx Rec 5
gear.souveranLegsPlusOnePathC = hp_gear("Souv. Diechlings +1", 162,
    { augments = { 'HP+105', 'Enmity+9', 'Potency of "Cure" effect received +15%' }, })  --DT 4, Enmity 9, Cure Rec 23
gear.souveranFeetPlusOnePathC = hp_gear("Souveran Schuhs +1", 227,
    { augments = { 'HP+105', 'Enmity+9', 'Potency of "Cure" effect received +15%', }, }) --PDT 5, Enmity 9, Cure Rec 15, Phalanx Rec 5

gear.souveranHeadPlusOnePathD = hp_gear("Souv. Schaller +1", 280,
    { augments = { 'HP+105', 'VIT+12', 'Phys. dmg. taken -4', }, })          --PDT 4, SIRD 20
gear.souveranHandsPlusOnePathD = hp_gear("Souv. Handsch. +1", 199,
    { augments = { 'HP+65', 'Shield skill +15', 'Phys. dmg. taken -4', }, }) --PDT 4, MDT 5, Shield Skill 15

--Sulevia (Set Enhances Subtle Blow)
gear.suleviaHandsPlusTwo = hp_gear("Sulev. Gauntlets +2", 30) --DT 5, DA 6
gear.suleviaLegsPlusTwo = hp_gear("Sulev. Cuisses +2", 50)    --DT 7, TA 4
gear.suleviaFeetPlusTwo = hp_gear("Sulev. Leggings +2", 20)   --DT 4, WSD 7

--Taeon
gear.taeonBody = hp_gear("Taeon Tabard", 59, { augments = { '"Fast Cast"+4' }, }) --FC 4

--Tatenashi
gear.tatenashiFeetPlusOne = hp_gear("Tatena. Sune. +1", 15) --TA 3, STP 4-8, Acc 60, Dex 29, Zanshin 6

--Vanya
gear.vanyaBodyPathA = hp_gear("Vanya Robe", 54,
    { augments = { 'MP+50', '"Cure" potency +7%', 'Enmity-6', }, }) --DT 1, MDT 3, Cure Pot 7, Enmity -6, MP 50
gear.vanyaHandsPathA = hp_gear("Vanya Cuffs", 22,
    { augments = { 'MP+50', '"Cure" potency +7%', 'Enmity-6', }, }) --MDT 3, Singing 15, Cure Pot 7, Enmity -6, MP 50


gear.vanyaBodyPathB = hp_gear("Vanya Robe", 54,
    { augments = { 'Healing magic skill +20', '"Cure" spellcasting time -7%', 'Magic dmg. taken -3', }, }) --DT 1, MDT 3, Cure FC 7, Healing Magic 20, Divine Magic 20
gear.vanyaHandsPathB = hp_gear("Vanya Cuffs", 22,
    { augments = { 'Healing magic skill +20', '"Cure" spellcasting time -7%', 'Magic dmg. taken -3', }, }) --MDT 3, Singing 15, Cure FC 7, Healing Magic 20
gear.vanyaLegsPathB = hp_gear("Vanya Slops", 43,
    { augments = { 'Healing magic skill +20', '"Cure" spellcasting time -7%', 'Magic dmg. taken -3', }, }) --MDT 3, Cure FC 7, Healing Magic 20

gear.vanyaHeadPathD = hp_gear("Vanya Hood", 36, { augments = { 'MP+50', '"Fast Cast"+10', 'Haste+2%' }, })     --DT 2, FC 10, Cure Pot 10, MP 82
gear.vanyaFeetPathD = hp_gear("Vanya Clogs", 13,
    { augments = { '"Cure" potency +5%', '"Cure" spellcasting time -15%', '"Conserve MP"+6', }, })         --Cure Pot 10, Cure FC 15, Healing Magic 20, Conserve MP 6, Cursna +5

--Volte
gear.volteLegs = hp_gear("Volte Brais", 54) --FC 8, Refresh 1

-- [[ Non-Set Pieces ]] --

--Weapons
gear.aegis = hp_gear("Aegis", 0)                                             --MDT II 50
gear.anarchyPlusTwo = hp_gear("Anarchy +2", 0)                               --TP Bonus 1000
gear.ammurapi = hp_gear("Ammurapi Shield", 22)                               --Macc 38, MAB 38, Enhancing Dur 10%
gear.blurredHarp = hp_gear("Blurred Harp +1", 0)                             --All Songs 2, Ballad 2, Lullaby 2, 1 Additional Song
gear.blurredKnife = hp_gear("Blurred Knife +1", 0)                           --OAT
gear.blurredShield = hp_gear("Blurred Shield +1", 0)                         --WSD 7, Fencer 1
gear.bunzi = rank_gear("Bunzi's Rod", 23)                                      --Cure Pot 30, Macc 40, MAB 35, Prio above Ammurapi Shield (22)
gear.chango = rank_gear("Chango", 71)                                          --STP 10, TP Bonus 500, Prio above grips
gear.compensator = hp_gear("Compensator", 0)                                 --Phantom Roll Dur 20, TS 20, Snapshot 10
gear.daurdabla = hp_gear("Daurdabla", 0)                                     --2 Additional Songs, Singing 20, String 20, Song Duration+
gear.daybreak = rank_gear("Daybreak", 101)                                      --Cure Pot 30%, Refresh 1, Dispelga, MND 30
gear.debahocho = rank_gear("Debahocho", 25)                                    --1Dmg Katana, Main Hand
gear.diamondAspis = hp_gear("Diamond Aspis", 0)                              --Self Ability Dur +25%
gear.dullahanAxe = rank_gear("Dullahan Axe", 25)                               --1Dmg Axe, Main Hand
gear.dunna = rank_gear("Dunna", 2)                                             --FC 3, Handbell 18, Geomancy 5, Luopan DT 5
gear.duplus = hp_gear("Duplus Grip", 0)                                      --DA 3
gear.enki = hp_gear("Enki Strap", 0)                                         --INT/MND 10, Macc 10, Meva 10
gear.extinction = rank_gear("Extinction", 24)                                  --1Dmg Wep, either hand; tied with Nihility so main always equips first
gear.fomalhaut = hp_gear("Fomalhaut", 0)                                     --TP Bonus 500, Last Stand, STP 10
gear.fourthStaff = rank_gear("Fourth Staff", 1)                                --1Dmg Staff, Retrace 24 Hours
gear.fusettoPlusTwo = hp_gear("Fusetto +2", 0)                                 --TP Bonus 1000
gear.gada = rank_gear("Gada", 24)                                              --Cure Pot 18, Healing/Enhancing/Enfeebling 18
gear.yagrush = rank_gear("Yagrush", 23)                                        --No HP; ranked above Ammurapi Shield (22) so the main equips first
gear.genbu = hp_gear("Genbu's Shield", 0)                                    --PDT 10, Eva 10, Fire Res -10, Earth Res +10
gear.gjallarhorn = hp_gear("Gjallarhorn", 0)                                 --Songs +4, CHR 10, Singing/Wind Instrument 25
gear.gleti = rank_gear("Gleti's Knife", 101)                                    --DEX/AGI 15, TA 6, Crit 5
gear.godhands = hp_gear("Godhands", 0)                                       --STP 10, TP Bonus 500
gear.hoe = rank_gear("Hoe", 1)                                                 --1Dmg Scythe, 999 Delay
gear.impatiens = hp_gear("Impatiens", 0)                                     --QC 2, SIRD 10
gear.kajaKnife = rank_gear("Kaja Knife", 101)                                   --Evisceration+ 50%
gear.kajaKatana = rank_gear("Kaja Katana", 101)                                 --Blade: Ku 60%
gear.kajaRod = rank_gear("Kaja Rod", 101)                                      --Black Halo +50%, substitutes for Maxentius; same rank so either beats HP offhands
gear.kajaTachi = rank_gear("Kaja Tachi", 71)  --Macc 35, Acc 35, Att 25, Great Katana Skill 242, Parrying Skill 242
gear.kali = rank_gear("Kali", 24)                                              --FC 7, Macc 30, MAB 14, Song Dur 5, Singing 10, Refresh 1, MP 60
gear.knobkierrie = hp_gear("Knobkierrie", 0)                                 --WSD 6, Atk 23
gear.linosMelee = hp_gear("Linos", 0, {
    augments = { 'Accuracy+15', '"Dbl.Atk."+3', 'Quadruple Attack +3' }, })  --Accuracy+15, "Dbl.Atk."+3, Quadruple Attack +3
gear.linosWSD = hp_gear("Linos", 0, {
    augments = { 'Attack+17', 'Weapon skill damage +3%', 'STR+6 DEX+6' }, }) --Attack+17, Weapon skill damage +3%, STR+6 DEX+6
gear.loxoticPlusOne = rank_gear("Loxotic Mace +1", 26)                           --WSD 10
gear.machaera = hp_gear("Machaera +2", 0)                                    --TP Bonus 1000
gear.malignancePole = hp_gear("Malignance Pole", 150)                        --DT 20
gear.marsyas = hp_gear("Marsyas", 0)                                         --Honor March, Song Dur 50%
gear.maxentius = rank_gear("Maxentius", 101)                                   --Black Halo +50%, Prio above Sakpata's Sword (100) and Bunzi's Rod when offhanded
gear.mumeito = rank_gear("Mumeito", 1)                                         --12 Dmg Great Katana SAM only
gear.nihility = rank_gear("Nihility", 24)                                      --1Dmg Wep, either hand; tied with Extinction so main always equips first
gear.miracleCheer = hp_gear("Miracle Cheer", 0)                              --1 Additional Song, All Songs +3, Song Dur 15 Min
gear.mpacaStaff = rank_gear("Mpaca's Staff", 71)                               --FC 5, Refresh 2, Magic Burst II 2, Keep prio over grips
gear.musa = hp_gear("Musa", 130)                                             --FC 9-10, Regen 24-25, Cure 24-25
gear.naegling = rank_gear("Naegling", 101)                                     --Prio above Shields, Offhands and Sakpata\x27s Sword (100)
gear.nusku = hp_gear("Nusku Shield", 22)                                     --Racc 20, Ratt 20, STP 3
gear.ophidian = rank_gear("Ophidian Sword", 1)                                 --1Dmg Great Sword
gear.priwen = hp_gear("Priwen", 80)                                             --HP 30 base + Oboro augment HP+50, DT 6, Phalanx Rec 2, Reprisal+
gear.qutrubKnife = rank_gear("Qutrub Knife", 24)                               --1Dmg Dagger
gear.sakpataSword = hp_gear("Sakpata's Sword", 100)                          --DT 10, FC 10, Phalanx Rec 5
gear.shiningOne = rank_gear("Shining One", 71)                                 --Prio Higher than Utu
gear.solstice = rank_gear("Solstice", 24)                                      --FC 5, Handbell 5, Indicolure Dur 15, PetDT 4
gear.soulflayerWand = rank_gear("Soulflayer's Wand", 25)                       --1Dmg Club, Main Hand
gear.sparrowhawk = hp_gear("Sparrowhawk", 0)                                 --Magian Bow
gear.sparrowhawkPlusOne = hp_gear("Sparrowhawk +1", 0)                         --Magian Bow
gear.sparrowhawkPlusTwo = hp_gear("Sparrowhawk +2", 0)                         --TP Bonus 1000
gear.tauret = rank_gear("Tauret", 101)                                          --Evisceration+ 50%
gear.terpander = rank_gear("Terpander", 30)                                    --DT 3, Macc 10
gear.tzeeXicu = rank_gear("Tzee Xicu's Blade", 1)                              --1Dmg Polearm
gear.uchigatana = rank_gear("Uchigatana", 1)                                   --24 Dmg Great Katana SAM or NIN
gear.utu = hp_gear("Utu Grip", 70)                                           --Weapon Skill DEX 10%, Acc 30, Att 30
gear.zaDhaChopper = rank_gear("Za'Dha Chopper", 1)                             --1Dmg Great Axe

gear.rostam1 = rank_gear("Rostam", 101, { bag = "wardrobe" })  --Macc 50, MDmg 217, Racc 50, Acc 50, Dagger Skill 269
gear.rostam2 = rank_gear("Rostam", 101, { bag = "wardrobe2" })  --Macc 50, MDmg 217, Racc 50, Acc 50, Dagger Skill 269
gear.rostam3 = rank_gear("Rostam", 101, { bag = "wardrobe3" })  --Macc 50, MDmg 217, Racc 50, Acc 50, Dagger Skill 269
gear.rostam4 = rank_gear("Rostam", 101, { bag = "wardrobe4" })  --Macc 50, MDmg 217, Racc 50, Acc 50, Dagger Skill 269
gear.rostam5 = rank_gear("Rostam", 101, { bag = "wardrobe5" })  --Macc 50, MDmg 217, Racc 50, Acc 50, Dagger Skill 269
gear.rostam6 = rank_gear("Rostam", 101, { bag = "wardrobe6" })  --Macc 50, MDmg 217, Racc 50, Acc 50, Dagger Skill 269

--Ammo
gear.coiste = hp_gear("Coiste Bodhar", 0)              --DA 3, STP 3
gear.hydrocera = mp_gear("Hydrocera", 20)               --MND 3, Macc 6, MP 20
gear.sapience = hp_gear("Sapience Orb", 0)             --FC 2, Enmity 2
gear.staunchPlusOne = hp_gear("Staunch Tathlum +1", 0) --DT 3, SIRD 11

--Neck
gear.anu = hp_gear("Anu Torque", 0)                       --STP 7, Atk 20
gear.arguteStole = hp_gear("Argute Stole +2", 0)          --Macc 30, MDmg 4-7, Magic Burst Damage 10, Helix Effect Dur 4-7
gear.aurgelmir = hp_gear("Aurgelmir Orb", 0)              --STR/DEX/VIT 5, Atk 7, STP 4
gear.bathy = hp_gear("Bathy Choker", 30)                  --SB 10, Regen 2
gear.bathyPlusOne = hp_gear("Bathy Choker +1", 35)        --SB 11, Regen 3
gear.bardCharm = hp_gear("Bard's Charm +2", 0)            --QA 4, STP 7, PDL 10, Acc 30, DEX/CHR 25
gear.baguaCharm = mp_gear("Bagua Charm +2", 50)            --Augment MP+50, Macc 30, Geomancy 7, Luopan Dur 25, Luopan DT 10
gear.commodoreCharm = hp_gear("Comm. Charm +2", 0)        --Racc 25, Macc 25, MAB 6, Snapshot 4, STR/AGI 14
gear.dampeners = hp_gear("Dampener's Torque", 25)         --MDT 4, HP Swap
gear.debilis = hp_gear("Debilis Medallion", 0)            --Cursna+
gear.diemer = hp_gear("Diemer Gorget", 0)                 --PDT 6, FC Cure 4, Shield Skill 7
gear.dragoonCollar = hp_gear("Dgn. Collar +2", 0)         --Acc 25, Att 25, Crit 4, STR/VIT 15, PDL 10, Wyvern DT 25
gear.duelistTorque = hp_gear("Dls. Torque +2", 0)         --Enhancing Dur 25%, Enfeebling Dur 25%, Enfeebling 10, Dispel +1,
gear.erra = hp_gear("Erra Pendant", 0)                    --Drain/Aspir/Absorb 5, Dark Magic Skill 10
gear.eschan = hp_gear("Eschan Stone", 20)                 --Macc 7, MAB 7
gear.fotiaNeck = hp_gear("Fotia Gorget", 0)               --Latent WSD 10
gear.hoxneNeck = hp_gear("Hoxne Ampulla", 0)              --Enchantment 100% DT costs 1000gil per hit
gear.iskur = hp_gear("Iskur Gorget", 30)                  --STP 8, Racc 30, Ratt 30
gear.knightsBead = hp_gear("Kgt. Beads +2", 60)           --Augment HP+60, VIT/MND 15, DT 7, Enmity 10
gear.loricatePlusOne = hp_gear("Loricate Torque +1", 0)   --DT 6, SIRD 5
gear.lugalbanda = hp_gear("Lugalbanda Earring", 0)        --Meva 10, MDef 5, Blood Pact 10
gear.mirageStole = hp_gear("Mirage Stole +2", 0)          --STP 6, Crit 4
gear.monkNodowa = hp_gear("Monk's Nodowa +2", 0)          --Kick Attacks +45, PDL 10, DEX/MND 15, Acc 30
gear.moonbowWhistlePlusOne = hp_gear("Mnbw. Whistle +1", 0) --All Songs +3, Macc 23, CHR 23
gear.moonlightNeck = hp_gear("Moonlight Necklace", 0)     --Enmity 15, SIRD 15
gear.nicander = hp_gear("Nicander's Necklace", 0)         --Cursna Rec 20, PDT -10, Holy Water 30
gear.nodens = hp_gear("Nodens Gorget", 25)                --Cure Pot 5, Stoneskin 30
gear.nullLoop = hp_gear("Null Loop", 50)                  --DT 5, Macc 50
gear.unmovingPlusOne = hp_gear("Unmoving Collar +1", 200)                    --Augment HP+200, VIT/CHR 9, Enmity 10
gear.quanpur = hp_gear("Quanpur Necklace", 0)             --MAB 7, Earth MAB 5
gear.regalNeck = hp_gear("Regal Necklace", 0)             --Phantom Roll 7, Phantom Roll Dur 20
gear.reti = hp_gear("Reti Pendant", 0)                    --String Instrument 9, Handbell 5, Conserve MP 4, CHR 7
gear.sanctity = hp_gear("Sanctity Necklace", 35)          --Macc 10, MAB 10, Regen 2
gear.scoutGorget = hp_gear("Scout's Gorget +2", 0)        --Racc 25, Macc 25, Snapshot 4, AGI 13-25, STP 4-10, PDL 5-10
gear.vim = hp_gear("Vim Torque", 0)                       --Refresh 1-2, Latent Regain 15
gear.vimPlusOne = hp_gear("Vim Torque +1", 0)               --Refresh 1-3, Latent Regain 20
gear.voltsurge = hp_gear("Voltsurge Torque", 0)           --FC 4
gear.warriorsBead = hp_gear("War. Beads +2", 100)         --Augment HP+100, STR/DEX 15, DA 7, Fencer 1

--Waist
gear.audumbla = hp_gear("Audumbla Sash", 0)               --PDT 4, SIRD 10
gear.austerityPlusOne = hp_gear("Austerity Belt +1", 0)     --Conserve MP 9, Drain/Aspir 5
gear.carriers = hp_gear("Carrier's Sash", 20)             --All Elemental Resists +15
gear.embla = hp_gear("Embla Sash", 0)                     --FC 5, Sublimation 3, Enhancing Dur 10
gear.flumeBelt = hp_gear("Flume Belt", 0)                 --PDT 4, Convert 2% Dam to MP
gear.fotiaWaist = hp_gear("Fotia Belt", 0)                --Latent WSD 10
gear.gishdubar = hp_gear("Gishdubar Sash", 0)             --Cursna Rec +10
gear.ioskeha = hp_gear("Ioskeha Belt", 0)                 --DA 8, Haste 7, Acc 12
gear.moonbowBeltPlusOne = hp_gear("Moonbow Belt +1", 0)     --DT 6, TA 8, SB II 15, STR/DEX 20
gear.nullWaist = hp_gear("Null Belt", 0)                  --Acc/Racc/Macc 30, Eva/MEva 30, MDB 3, Regen 3
gear.olympus = hp_gear("Olympus Sash", 0)                 --Enhancing 5, Elemental 5
gear.orpheusWaist = hp_gear("Orpheus's Sash", 0)          --Elemental Attacks 1-15 Based on Distance
gear.patentia = hp_gear("Patentia Sash", 0)               --DW x?, STP 5
gear.porous = hp_gear("Porous Rope", 20)                  --INT/MND/CHR 7, Macc 5, MP 20
gear.reiki = hp_gear("Reiki Yotai", 0)                    --DW 7, STP 4
gear.sailfi = hp_gear("Sailfi Belt +1", 0)                --DA 5, TA 2, STR 15
gear.sarissaphoroi = hp_gear("Sarissaphoroi Belt", 0)     --DA 2, TA2, SB 5, Haste 3
gear.siegel = hp_gear("Siegel Sash", 0)                   --FC Enhancing 8, Stoneskin+
gear.sulla = hp_gear("Sulla Belt", 0)                     --Enmity 3, Atk 30
gear.windbuffetPlusOne = hp_gear("Windbuffet Belt +1", 0) --TA 2, QA 2
gear.witful = hp_gear("Witful Belt", 0)                   --FC 3, QC 3
gear.yemaya = hp_gear("Yemaya Belt", 0)                   --Rapid Shot 5, STP 4, Racc 10, Ratt 10

--Ear
gear.alabaster = hp_gear("Alabaster Earring", 100)      --DT 5, Haste 5
gear.brutal = hp_gear("Brutal Earring", 0)              --DA 5, STP 1
gear.cessance = hp_gear("Cessance Earring", 0)          --DA 3, STP 3
gear.crepuscularEar = hp_gear("Crepuscular Earring", 0) --STP 5
gear.eabani = hp_gear("Eabani Earring", 45)             --DW 4
gear.enmerkar = hp_gear("Enmerkar Earring", 0)           --Pet DT 3, Pet STP 8, Pet Acc/Macc 15
gear.etiolation = hp_gear("Etiolation Earring", 50)     --MDT 3, FC 1
gear.flashward = mp_gear("Flashward Earring", 10)        --MND 2, MP 10, Meva 8
gear.friomisi = hp_gear("Friomisi Earring", 0)          --MAB 10, Enmity 2
gear.halasz = mp_gear("Halasz Earring", 45)             --SIRD 5, Magic Crit 14, Enmity -3, MP 45
gear.hecates = hp_gear("Hecate's Earring", 0)           --MAB 6, Magic Crit 3
gear.hermetic = hp_gear("Hermetic Earring", 0)          --Macc 7, MAB 3
gear.hetairoi = hp_gear("Hetairoi Ring", 0)             --TA 2, TA Dmg 5, Crit 1
gear.hoxneEar = hp_gear("Hoxne Earring", 0)             --30 All Stats at MR 10
gear.ishvara = hp_gear("Ishvara Earring", 0)            --WSD 2
gear.lempo = hp_gear("Lempo Earring", 0)                --Acc 5, Macc 5, Enmity -3, Conserve MP 2
gear.loquacious = mp_gear("Loquacious Earring", 30)      --FC 2
gear.odnowaPlusOne = hp_gear("Odnowa Earring +1", 110)  --DT 3 if upgraded, Convert 110 MP to HP
gear.malignanceEar = hp_gear("Malignance Earring", 0)   --FC 4
gear.meili = hp_gear("Meili Earring", 0)                --Healing Magic Skill 10
gear.mimir = hp_gear("Mimir Earring", 0)                --Enhancing Magic Skill 10
gear.moonshade = hp_gear("Moonshade Earring", 0)        --TP Bonus 250
gear.niqmaddu = hp_gear("Niqmaddu Ring", 0)             --QA 3, SB II 5, STR/DEX/VIT 10
gear.odr = hp_gear("Odr Earring", 0)                    --Crit 5, Acc 10, DEX 10
gear.schere = hp_gear("Schere Earring", 0)              --DA 6, SB 3, STR 5
gear.sherida = hp_gear("Sherida Earring", 0)            --DA 5, STP 5, SB II 5, STR/DEX 5
gear.snotra = hp_gear("Snotra Earring")                 --Macc 10, MND 8, Enfeebling Duration 10%
gear.sortiarius = hp_gear("Sortiarius Earring", 0)      --MAB 6, Enmity -2
gear.srodaEarring = hp_gear("Sroda Earring", 0)         --Pet Alive: DA 7 Pet DMG 10
gear.suppanomimi = hp_gear("Suppanomimi", 0)            --DW 5, Sword Skill 5
gear.telos = hp_gear("Telos Earring", 0)                --DA 1, STP 5
gear.thrud = hp_gear("Thrud Earring", 0)                --WSD 3, STR/VIT 10
gear.tuisto = hp_gear("Tuisto Earring", 150)            --Convert 150 MP to HP, DEF 20, VIT 10
gear.vertigo = hp_gear("Vertigo Ring", 0)               --PDT 2, Macc 5, INT 5, MND 5

--Ring
gear.apate = hp_gear("Apate Ring", 0)                             --STP 3, SB 5, STR/DEX/AGI 6
gear.arvina = hp_gear("Arvina Ringlet", 0)                        --AGI 4, Marksmanship 3
gear.ayanmoRing = hp_gear("Ayanmo Ring", 0)                       --DT 3, Acc 6, Macc 6
gear.barataria = hp_gear("Barataria Ring", 0)                     --Phantom Roll 5
gear.crepuscularRing = hp_gear("Crepuscular Ring", 0)             --Macc 10, RAcc 10, Snapshot 3, STP 6
gear.defending = hp_gear("Defending Ring", 0)                     --DT 10
gear.dignitary = hp_gear("Digni. Earring", 0)                     --SB 5, STP 3, Acc 10, Macc 10
gear.dingir = hp_gear("Dingir Ring", 0)                           --AGI 10, Ratt 25, MAB 10, Recycle 10
gear.epimanondas = hp_gear("Epaminondas's Ring", 0)               --WSD 5
gear.eponas = hp_gear("Epona's Ring", 0)                          --DA 3, TA 3
gear.evanescence = hp_gear("Evanescence Ring", 0)                 --Dark Magic 10, SIRD 5, Drain/Aspir 10
gear.fenrir = mp_gear("Fenrir Ring", 50)                           --Dark +15, MAB 2
gear.flammaRing = hp_gear("Flamma Ring", 0)                       --Acc 6, Macc 6, STP 5
gear.fortifiedRing = mp_gear("Fortified Ring", 50)                 --MDT 5, Enemy Crit -7, MP 50
gear.gelatinousPlusOne = hp_gear("Gelatinous Ring +1", 135)         --Unity Ranking HP+10~35 at top rank, plus rank-15 augment HP+100; PDT 7, MDT +1
gear.freke = hp_gear("Freke Ring", 0)                             --Int 10, MAB 8, SIRD 10
gear.gereRing = hp_gear("Gere Ring", 0)                           --TA 5, STR 10
gear.ilabrat = hp_gear("Ilabrat Ring", 60)                        --STP 5, AGI 10 , DEX 10, Att 25
gear.jhakriRing = hp_gear("Jhakri Ring", 0)                       --MAB 3, MB 2, Macc 6
gear.jubileeRing = hp_gear("Jubilee Ring", 0)                     --Skill Up +100%, EXP + 50%
gear.inyangaRing = hp_gear("Inyanga Ring", 0)                     --MDT 2, Macc 6, Meva 12, Set Refresh
gear.karieyh = hp_gear("Karieyh Ring", 0)                         --WSD 5, Regain 5
gear.kishar = hp_gear("Kishar Ring", 0)                           --FC 4, Macc 5, Enfeebling Dur 10
gear.luzaf = hp_gear("Luzaf's Ring", 0)                           --Phantom Roll Range 16
gear.moonlightRing = hp_gear("Moonlight Ring", 110)               --DT 5, STP 5, Acc 8, Att 8
gear.murky = mp_gear("Murky Ring", 30)                             --DT 10, SIRD 3
gear.metamorphPlusOne = hp_gear("Metamor. Ring +1", -60)                     --Converts 60 HP to MP, INT/MND/CHR 6
gear.overbearing = hp_gear("Overbearing Ring", 45)                --HP Swap
gear.petrov = hp_gear("Petrov Ring", 0)                           --DA 1, STP 5, Enmity 4
gear.praan = hp_gear("Praan Ring", 60)                            --HP 60, MP 20 (HP/MP Swap Ring)
gear.prolix = mp_gear("Prolix Ring", 20)                           --FC 2
gear.rajas = hp_gear("Rajas Ring", 0)                             --STP 5, SB 5
gear.sroda = hp_gear("Sroda Ring", 0)                             --PDL +3, STR +15, DEX -20
gear.svelt = hp_gear("Svelt. Gouriz +1", 0)                       --AGI 10
gear.stikiniPlusOne = hp_gear("Stikini Ring +1", 0)               --Refresh 1
gear.suleviasRing = hp_gear("Sulevia's Ring", 0)                  --DT 3
gear.vengeful = hp_gear("Vengeful Ring", 20)                      --HP swap for FC
gear.weatherspoon = hp_gear("Weather. Ring", 0)                   --FC 5, QM 3, Light MAB 10, Macc 10

gear.chirich1 = hp_gear("Chirich Ring", 0, { bag = "wardrobe" }) --SB 7, STP 5, Regen 1
gear.chirich2 = hp_gear("Chirich Ring", 0, { bag = "wardrobe2" })  --Regen 1, STP 5, Acc 7, SB 7
gear.chirich3 = hp_gear("Chirich Ring", 0, { bag = "wardrobe3" })  --Regen 1, STP 5, Acc 7, SB 7

gear.chirichPlusOne1 = hp_gear("Chirich Ring +1", 0, { bag = "wardrobe" }) --SB 10, STP 6, Regen 2
gear.chirichPlusOne2 = hp_gear("Chirich Ring +1", 0, { bag = "wardrobe2" })  --Regen 2, STP 6, Acc 10, SB 10
gear.chirichPlusOne3 = hp_gear("Chirich Ring +1", 0, { bag = "wardrobe3" })  --Regen 2, STP 6, Acc 10, SB 10

gear.saida1 = hp_gear("Saida Ring", 0, { bag = "wardrobe" })
gear.saida2 = hp_gear("Saida Ring", 0, { bag = "wardrobe2" })
gear.saida3 = hp_gear("Saida Ring", 0, { bag = "wardrobe3" })
gear.saida4 = hp_gear("Saida Ring", 0, { bag = "wardrobe4" })
gear.saida5 = hp_gear("Saida Ring", 0, { bag = "wardrobe5" })

gear.shivaRingPlusOne1 = hp_gear("Shiva Ring +1", 0, { bag = "wardrobe" }) --9 Int, 3 MAB
gear.shivaRingPlusOne2 = hp_gear("Shiva Ring +1", 0, { bag = "wardrobe2" }) --9 Int, 3 MAB
gear.shivaRingPlusOne3 = hp_gear("Shiva Ring +1", 0, { bag = "wardrobe3" }) --9 Int, 3 MAB
gear.shivaRingPlusOne4 = hp_gear("Shiva Ring +1", 0, { bag = "wardrobe4" }) --9 Int, 3 MAB
gear.shivaRingPlusOne5 = hp_gear("Shiva Ring +1", 0, { bag = "wardrobe5" }) --9 Int, 3 MAB

gear.eshmun1 = hp_gear("Eshmun's Ring", 0, { bag = "wardrobe" })
gear.eshmun2 = hp_gear("Eshmun's Ring", 0, { bag = "wardrobe2" })
gear.eshmun3 = hp_gear("Eshmun's Ring", 0, { bag = "wardrobe3" })
gear.eshmun4 = hp_gear("Eshmun's Ring", 0, { bag = "wardrobe4" })
gear.eshmun5 = hp_gear("Eshmun's Ring", 0, { bag = "wardrobe5" })

--Back
gear.aptitude = hp_gear("Aptitude Mantle", 0)       --CP 25
gear.navarchMantle = hp_gear("Navarch's Mantle", 0) --Snapshot
gear.sokolski = hp_gear("Sokolski Mantle", 70)      --HP Swap

--Treasure Hunter
gear.chaac = hp_gear("Chaac Belt", 0)          --TH 1
gear.hoxneRing = hp_gear("Hoxne Ring", -150)   --TH 2, TH +5%
gear.perfectEgg = hp_gear("Per. Lucky Egg", 0) --TH 1
gear.volteHead = hp_gear("Volte Cap", 57)      --TH 1

--[==[ Items referenced by job files -- entries minted from the references
     themselves: an inline augment list is carried verbatim, a bag choice is
     kept, and a variant of an item priced above inherits that price. ]==]--

gear.abyssalBeadNecklacePlusTwo = hp_gear("Abyssal Beads +2", 0)  --Macc 15, Acc 15, Att 40
gear.acroBreechesRapidShot = hp_gear("Acro Breeches", 50, {
    augments = {'"Rapid Shot"+5','"Snapshot"+5',}, })  --STP 4, Haste 5, MDB 3, Acc 10
gear.acroGauntletsRapidShot = hp_gear("Acro Gauntlets", 57, {
    augments = {'"Rapid Shot"+5','"Snapshot"+5',}, })  --STP 4, Haste 4, MDB 1, Att 7
gear.acroHelmRapidShot = hp_gear("Acro Helm", 38, {
    augments = {'"Rapid Shot"+5','"Snapshot"+5',}, })  --STP 3, Haste 7, MDB 2, Att 15
gear.acroLeggingsRapidShot = hp_gear("Acro Leggings", 15, {
    augments = {'"Rapid Shot"+5','"Snapshot"+5',}, })  --DA 2, Haste 3, MDB 2, Acc 7
gear.acroSurcoatRapidShot = hp_gear("Acro Surcoat", 61, {
    augments = {'"Rapid Shot"+5','"Snapshot"+5',}, })  --DA 2, Haste 3, MDB 4, Acc 10, Att 10
gear.acuityBeltPlusOne = mp_gear("Acuity Belt +1", 35)  --INT 6, INT 3
gear.adamantiteArmor = hp_gear("Adamantite Armor", 182)  --Macc 40, MDB 20, Acc 40
gear.adhemarFeetPlusOnePathD = hp_gear("Adhe. Gamashes +1", 76, {
    augments = {'HP+65','"Store TP"+7','"Snapshot"+10',}, })  --Haste 4, MAB 35, MDB 5, Ratt 34, Att 34
gear.adhemarLegsPlusOnePathD = hp_gear("Adhemar Kecks +1", 41, {
    augments = {'AGI+12','"Rapid Shot"+13','Enmity-6',}, })  --STP 8, Snapshot 10, Haste 6, MDB 5, Racc 34
gear.aeneas = rank_gear("Aeneas", 101)  --STP 10, MDmg 155, Dagger Skill 269, Parrying Skill 269, Magic Accuracy Skill 228
gear.ahosiLeggings = hp_gear("Ahosi Leggings", 18)  --Haste 4, MDB 5, Acc 35, Enmity 7
gear.alberStrap = hp_gear("Alber Strap", 0)  --PDT 2, DA 2, MAB 7, Enmity 5
gear.almace = rank_gear("Almace", 100)
gear.amalricCoifPlusOne = hp_gear("Amalric Coif +1", 27)  --FC 11, Haste 6, Macc 36, MDB 6
gear.amalricHeadPlusOnePathA = hp_gear("Amalric Coif +1", 27, {
    augments = {'MP+80','Mag. Acc.+20','"Mag.Atk.Bns."+20',}, })  --FC 11, Haste 6, Macc 36, MDB 6
gear.amalricBodyPlusOnePathA = hp_gear("Amalric Doublet +1", 45, {
    augments = {'MP+80','Mag. Acc.+20','"Mag.Atk.Bns."+20',}, })  --Refresh 3, Haste 3, MAB 33, Macc 33, MDB 7
gear.amalricLegsPlusOnePathA = hp_gear("Amalric Slops +1", 34, {
    augments = {'MP+80','Mag. Acc.+20','"Mag.Atk.Bns."+20',}, })  --Haste 5, MAB 40, MDB 6, SC Bonus 9
gear.anarchyPlusTwoB = hp_gear("Anarchy +2", 0, {
    augments = {'Delay:+60','TP Bonus +1000',}, })
gear.andoaaEarring = mp_gear("Andoaa Earring", 30)  --Enhancing magic Skill 5, Summoning magic Skill 5
gear.angon = hp_gear("Angon", 0)
gear.anguta = rank_gear("Anguta", 70)  --STP 10, MDmg 186, Scythe Skill 269, Parrying Skill 269, Magic Accuracy Skill 242
gear.annihilator = hp_gear("Annihilator", 0)  --Racc 35, Ratt 25
gear.apeileRingPlusOne = hp_gear("Apeile Ring +1", 0)  --Enmity 5
gear.apogeeFeetPlusOnePathB = hp_gear("Apogee Pumps +1", -90, {
    augments = {'MP+80','Pet: Attack+35','Blood Pact Dmg.+8',}, })  --Haste 3, MDB 6
gear.archonRing = hp_gear("Archon Ring", 0)  --MAB 5, Macc 5
gear.bstSTP = hp_gear("Artio's Mantle", 0, {
    augments = {'Pet: Acc.+20 Pet: R.Acc.+20 Pet: Atk.+20 Pet: R.Atk.+20','Accuracy+20 Attack+20','Accuracy+10','"Store TP"+10','Damage taken-5%',}, })  --STP 10, DT 5, Acc 20, Acc 10
gear.bstPetRegen = hp_gear("Artio's Mantle", 0, {
    augments = {'Pet: M.Acc.+20 Pet: M.Dmg.+20','Eva.+20 /Mag. Eva.+20','Pet: Mag. Acc.+10','Pet: "Regen"+10','Pet: Damage taken -5%',}, })  --Regen 10, Macc 10
gear.asclepius = hp_gear("Asclepius", 130)  --Macc 50, MDmg 248, Acc 50, Club Skill 255, Parrying Skill 255
gear.asheraHarness = hp_gear("Ashera Harness", 182)  --STP 10, Haste 4, MDB 5, Racc 45, Acc 45
gear.askSash = hp_gear("Ask Sash", 0)  --WSD 5
gear.assiduityPants = hp_gear("Assiduity Pants", 43)  --Refresh 1, Haste 5, MDB 6, Enmity -5
gear.canOfAutomatonOilPlusThree = hp_gear("Automat. Oil +3", 0)
gear.baayamiSabotsPlusOne = hp_gear("Baaya. Sabots +1", 30)  --Refresh 3, Haste 3, MDB 6, Summoning magic Skill 29
gear.baayamiCuffsPlusOne = hp_gear("Baayami Cuffs +1", 21)  --Haste 3, MDB 5, Summoning magic Skill 33
gear.baayamiHatPlusOne = hp_gear("Baayami Hat +1", 49)  --Haste 6, MDB 6, Summoning magic Skill 31
gear.baayamiRobePlusOne = hp_gear("Baayami Robe +1", 83)  --FC 12, Haste 3, MDB 9, Summoning magic Skill 37
gear.baayamiSlops = hp_gear("Baayami Slops", 61)  --Haste 5, MDB 7, Summoning magic Skill 30
gear.baetylPendant = hp_gear("Baetyl Pendant", 0)  --FC 4, MAB 13
gear.balderEarringPlusOne = hp_gear("Balder Earring +1", 0)  --STP 3, Att 10
gear.beckonerEarringPlusOne = hp_gear("Beck. Earring +1", 0)  --Refresh 2
gear.befouledCrown = hp_gear("Befouled Crown", 36)  --Refresh 1, Haste 6, Macc 20, MDB 5, Enhancing magic Skill 16
gear.rngSnapshotB = hp_gear("Belenus's Cape", 80, {
    augments = {'HP+60','HP+20','"Snapshot"+10',}, })  --HP 60, HP 20, Snapshot 10
gear.beneficus = hp_gear("Beneficus", 0)  --Healing magic Skill 15, Enhancing magic Skill 15
gear.berylliumArrow = hp_gear("Beryllium Arrow", 0)  --Racc 12
gear.berylliumMacePlusOne = hp_gear("Beryllium Mace +1", 0)  --Acc 32, Acc 20, Club Skill 242, Parrying Skill 242, Magic Accuracy Skill 188
gear.bisonWarbonnet = mp_gear("Bison Warbonnet", 8)  --Enmity -1
gear.blisteringSalletPlusOne = hp_gear("Blistering Sallet +1", 80)  --DA 3, Haste 8, MDB 2, Acc 8
gear.boiiEarringPlusOne = hp_gear("Boii Earring +1", 0)  --DA 8, SB 6
gear.boiiEarringPlusOneCrit = hp_gear("Boii Earring +1", 0, {
    augments = {'System: 1 ID: 1676 Val: 0','Accuracy+12','Mag. Acc.+12','Crit.hit rate+4',}, })  --DA 8, SB 6
gear.bolelabunga = rank_gear("Bolelabunga", 22)  --Refresh 1, Regen 1, MAB 16, MDmg 124, Club Skill 242
gear.bookwormCape = hp_gear("Bookworm's Cape", 0, {
    augments = {'INT+1','MND+2','Helix eff. dur. +10','"Regen" potency+10',}, })  --MAB 10, MDmg 10, Elemental magic Skill 8, Dark magic Skill 8
gear.beastmasterCollarPlusTwo = hp_gear("Bst. Collar +2", 0)  --Macc 25, Acc 25
gear.burtgang = hp_gear("Burtgang", 0)  --Enmity 18
gear.cathPalugCrown = hp_gear("C. Palug Crown", 45)  --FC 8, Haste 6, MAB 45, MAB 38, Macc 50
gear.cathPalugEarring = hp_gear("C. Palug Earring", 0)  --Refresh 1, Macc 7, Racc 7, Summoning magic Skill 5
gear.cathPalugHammer = hp_gear("C. Palug Hammer", 0)  --FC 7, DA 7, MAB 18, Macc 35, MDmg 232
gear.cathPalugRing = hp_gear("C. Palug Ring", 40)  --DA 5, Macc 12, Racc 12
gear.jugOfCurdledPlasmaBroth = hp_gear("C. Plasma Broth", 0)
gear.caliburnus = hp_gear("Caliburnus", 0)  --DT 10, Refresh 4, Macc 35, MDmg 263, Acc 35
gear.corSTP = hp_gear("Camulus's Mantle", 0, {
    augments = {'AGI+20','Rng.Acc.+20 Rng.Atk.+20','Rng.Acc.+10','"Store TP"+10','Phys. dmg. taken-10%',}, })  --STP 10, PDT 10
gear.corWSDAgi = hp_gear("Camulus's Mantle", 0, {
    augments = {'AGI+20','Mag. Acc+20 /Mag. Dmg.+20','AGI+10','Weapon skill damage +10%','Damage taken-5%',}, })  --WSD 10, DT 5
gear.carbuncleRingPlusOne = hp_gear("Carb. Ring +1", 35)  --Macc 4
gear.carmineHandsPlusOnePathD = hp_gear("Carmine Fin. Ga. +1", 27, {
    augments = {'Rng.Atk.+20','"Mag.Atk.Bns."+12','"Store TP"+6',}, })  --Snapshot 8, Rapid Shot 11, Haste 5, MAB 30, MDB 2
gear.carnwenhan = rank_gear("Carnwenhan", 101)  --Macc 25
gear.chasseurEarringPlusOne = hp_gear("Chas. Earring +1", 0)  --Enmity -8
gear.chatoyantStaff = hp_gear("Chatoyant Staff", 0)  --Cure Pot 10
gear.chevalierEarringPlusOne = hp_gear("Chev. Earring +1", 0)  --Cure Pot 11, Shield Skill 11
gear.chirichRingPlusOne = hp_gear("Chirich Ring +1", 0)  --Regen 2, STP 6, Acc 10, SB 10
gear.chironicHatFC = hp_gear("Chironic Hat", 25, {
    augments = {'STR+4','Mag. Acc.+13','"Fast Cast"+1','Mag. Acc.+18 "Mag.Atk.Bns."+18',}, })  --Haste 6, Macc 15, MDB 6, Acc 15
gear.chironicSlippersRefresh = hp_gear("Chironic Slippers", 4, {
    augments = {'CHR+4','Attack+21','"Refresh"+2','Mag. Acc.+19 "Mag.Atk.Bns."+19',}, })  --Haste 3, MAB 20, MDB 6, Att 20, Enmity -5
gear.clerisyStrapPlusOne = hp_gear("Clerisy Strap +1", 0)  --FC 3, Macc 15
gear.clothariusTorque = hp_gear("Clotharius Torque", 0)  --TA 1, Racc 8, Acc 8, SB 4, Enmity -4
gear.clericTorquePlusTwo = mp_gear("Clr. Torque +2", 50)  --Cure Pot 10
gear.combatantTorque = hp_gear("Combatant's Torque", 0)  --STP 4
gear.corneliaRing = hp_gear("Cornelia's Ring", 0)  --WSD 10, Acc 10
gear.creedBaudrier = hp_gear("Creed Baudrier", 40)  --MDB 4, Enmity 5
gear.crematioEarring = hp_gear("Crematio Earring", 0)  --MAB 6, MDmg 6, Staff Skill 5
gear.crepuscularCloak = hp_gear("Crepuscular Cloak", 97)  --Haste 9, MAB 85, Macc 85, MDB 16, Acc 85
gear.crepuscularKnife = hp_gear("Crepuscular Knife", 0)  --Macc 40, Acc 40, Dagger Skill 248, Parrying Skill 248, Magic Accuracy Skill 248
gear.crepuscularPebble = hp_gear("Crepuscular Pebble", 0)  --DT 3
gear.crepuscularScythe = hp_gear("Crepuscular Scythe", 0)  --Macc 40, Acc 40, Att 55, Scythe Skill 248, Parrying Skill 248
gear.croceaMors = hp_gear("Crocea Mors", 130)  --FC 20, Macc 50, MDmg 217, Acc 50, Sword Skill 269
gear.crypticEarring = hp_gear("Cryptic Earring", 40)  --Enmity 4
gear.culminus = hp_gear("Culminus", 57)  --SIRD 10, MAB 20, MDmg 75, Shield Skill 107
gear.dagonBreastplate = hp_gear("Dagon Breast.", 136)  --TA 5, Haste 1, MDB 5, Acc 45, Att 45
gear.danzoSuneAte = hp_gear("Danzo Sune-Ate", 0)  --Enmity -2
gear.dashingSubligar = hp_gear("Dashing Subligar", 47)  --Haste 6, MDB 5
gear.deathPenalty = hp_gear("Death Penalty", 0)  --Quick Draw+
gear.demersalDegenPlusOne = hp_gear("Demers. Degen +1", 0)  --FC 1, Sword Skill 242, Parrying Skill 242, Magic Accuracy Skill 188
gear.jugOfDireBroth = hp_gear("Dire Broth", 0)
gear.dojikiriYasutsuna = rank_gear("Dojikiri Yasutsuna", 70)  --STP 10, MDmg 155, Great Katana Skill 269, Parrying Skill 269, Magic Accuracy Skill 228
gear.dolichenus = rank_gear("Dolichenus", 101)  --MAB 16, Macc 40, MDmg 217, Acc 40, Att 30
gear.duban = hp_gear("Duban", 0)  --Shield Skill 123
gear.eaHatPlusOne = hp_gear("Ea Hat +1", 54)  --Haste 6, MAB 38, Macc 50, MBD 7, MDB 6
gear.eaHouppelandePlusOne = hp_gear("Ea Houppe. +1", 88)  --Haste 3, MAB 44, Macc 52, MBD 9, MDB 9
gear.earp = hp_gear("Earp", 0)  --Crit 15, Macc 35, Acc 35, Marksmanship Skill 277
gear.earthcryEarring = hp_gear("Earthcry Earring", 0)  --Stoneskin+
gear.ebersEarringPlusOne = hp_gear("Ebers Earring +1", 0)  --Enmity -8, Healing magic Skill 11
gear.ebersEarringPlusOneMacc = hp_gear("Ebers Earring +1", 0, {
    augments = {'System: 1 ID: 1676 Val: 0','Accuracy+14','Mag. Acc.+14','Damage taken-5%',}, })  --Enmity -8, Healing magic Skill 11
gear.eihwazRing = hp_gear("Eihwaz Ring", 70)  --Enmity 5
gear.elanStrapPlusOne = hp_gear("Elan Strap +1", 0)  --MAB 7
gear.emetHarnessPlusOne = hp_gear("Emet Harness +1", 61)  --Haste 4, MDB 5, Acc 10, Enmity 10
gear.enchanterEarringPlusOne = hp_gear("Enchntr. Earring +1", 0)  --FC 2, Macc 6
gear.enervatingEarring = hp_gear("Enervating Earring", 0)  --STP 4, Racc 7, Ratt 7, Enmity -3
gear.enticerPants = hp_gear("Enticer's Pants", 38)  --Haste 5, MDB 6
gear.epeolatry = rank_gear("Epeolatry", 70)  --Enmity 18, Great Sword Skill 242, Parrying Skill 242, Magic Accuracy Skill 215
gear.etanaRing = hp_gear("Etana Ring", 60)  --Macc 7, Acc 7
gear.etherealEarring = hp_gear("Ethereal Earring", 15)  --Att 5
gear.etoileGorgetPlusOne = hp_gear("Etoile Gorget +1", 0)  --Macc 20, Acc 20
gear.failNot = hp_gear("Fail-Not", 0)  --STP 10, Macc 40, MDmg 155, Archery Skill 269
gear.fajinBoots = hp_gear("Fajin Boots", 0)
gear.fanaticGlovesFC = hp_gear("Fanatic Gloves", 22, {
    augments = {'MP+50','Healing magic skill +8','"Conserve MP"+5','"Fast Cast"+5',}, })  --Haste 3, MAB 20, Macc 20, MDB 3, Divine magic Skill 20
gear.ferineEarring = hp_gear("Ferine Earring", 0)  --Reward+
gear.flammaManopolasPlusTwo = hp_gear("Flam. Manopolas +2", 60)  --STP 6, Haste 4, Macc 43, MDB 2, Acc 43
gear.flumeBeltPlusOne = hp_gear("Flume Belt +1", 0)  --VIT 4
gear.fusettoPlusTwoB = hp_gear("Fusetto +2", 0, {
    augments = {'TP Bonus +1000',}, })
gear.gadaNuke = rank_gear("Gada", 24, {
    augments = {'Indi. eff. dur. +11','Mag. Acc.+2','"Mag.Atk.Bns."+13',}, })  --Cure Pot 18, MAB 16, Macc 20, MDmg 124, Club Skill 242
gear.gastraphetes = hp_gear("Gastraphetes", 0)  --Snapshot+
gear.gendewithaGagesPlusOne = hp_gear("Gende. Gages +1", 30)  --FC 7, Haste 1, Macc 15, MDB 3
gear.gendewithaGaloshesPlusOne = hp_gear("Gende. Galosh. +1", 26)  --Haste 4, MAB 8, MDB 5
gear.gendewithaGaloshesPlusOneBCureFC = hp_gear("Gende. Galosh. +1", 26, {
    augments = {'Phys. dmg. taken -3%','"Cure" spellcasting time -5%',}, })  --Haste 4, MAB 8, MDB 5
gear.genmeiShield = hp_gear("Genmei Shield", 0)  --Acc 15, Att 15, Shield Skill 112
gear.ghastlyTathlumPlusOne = mp_gear("Ghastly Tathlum +1", 35)  --MDmg 11
gear.ginsen = hp_gear("Ginsen", 0)  --STP 3, Acc 5, Att 10
gear.gokotai = hp_gear("Gokotai", 0)  --MAB 16, Macc 40, MDmg 217, Racc 40, Acc 40
gear.grunfeldRope = hp_gear("Grunfeld Rope", 0)  --DA 2, Acc 10, Att 20
gear.hachirinNoObi = hp_gear("Hachirin-no-Obi", 0)
gear.haomaRing = hp_gear("Haoma's Ring", 0)  --Healing magic Skill 8
gear.happoShurikenPlusOne = hp_gear("Happo Shuriken +1", 0)  --Crit 2, Racc 11, Acc 6, Att 6, Throwing Skill 228
gear.hashishinEarringPlusOne = hp_gear("Hashi. Earring +1", 0)  --Sword Skill 11, Blue magic Skill 11
gear.hastyPinionPlusOne = hp_gear("Hasty Pinion +1", 0)  --Haste 2, Acc 10, Att 10
gear.hattoriEarringPlusOne = hp_gear("Hattori Earring +1", 0)  --Katana Skill 11, Throwing Skill 11
gear.heartyEarring = hp_gear("Hearty Earring", 0)
gear.heraldGaiters = mp_gear("Herald's Gaiters", 12)
gear.hermesSandals = hp_gear("Hermes' Sandals", 12)  --Enmity 3
gear.hesperiidae = hp_gear("Hesperiidae", 0)  --Macc 10, Racc 10, Acc 10, Enmity -3
gear.homiliary = hp_gear("Homiliary", 0)  --Refresh 1
gear.idris = rank_gear("Idris", 22)  --MAB 25, Macc 25, MDmg 155, Club Skill 242, Parrying Skill 242
gear.ikengaAxe = hp_gear("Ikenga's Axe", 0)  --Crit 10, WSD 5, Macc 40, Acc 40, Att 30
gear.incanterTorque = hp_gear("Incanter's Torque", 0)
gear.incarnationSash = hp_gear("Incarnation Sash", 0)  --DA 4, Macc 15
gear.infusedEarring = hp_gear("Infused Earring", 0)  --Regen 1
gear.ioskehaBeltPlusOne = hp_gear("Ioskeha Belt +1", 0)  --DA 9, Haste 8, Acc 17
gear.ironGobbet = hp_gear("Iron Gobbet", 0)  --Enmity 2
gear.kwahuKachinaBeltPlusOne = hp_gear("K. Kachina Belt +1", 0)  --Macc 20, Racc 20
gear.kannagi = hp_gear("Kannagi", 0)
gear.karagozEarringPlusOne = hp_gear("Kara. Earring +1", 0)  --SB 6, Hand Skill 11
gear.karambit = hp_gear("Karambit", 0)  --STP 50, Macc 40, Acc 40, Att 30, Hand Skill 250
gear.karieyhRingPlusOne = hp_gear("Karieyh Ring +1", 0)  --WSD 4, Acc 10
gear.kasiriBelt = hp_gear("Kasiri Belt", 30)  --Haste 4, Enmity 3
gear.kaykausHeadPlusOnePathB = hp_gear("Kaykaus Mitra +1", 34, {
    augments = {'MP+80','"Cure" spellcasting time -7%','Enmity-6',}, })  --Cure Pot 11, Haste 6, Macc 32, MDB 6, Healing magic Skill 16
gear.kaykausLegsPlusOnePathB = hp_gear("Kaykaus Tights +1", 41, {
    augments = {'MP+80','"Cure" spellcasting time -7%','Enmity-6',}, })  --FC 7, Cure Pot 11, Haste 5, MAB 34, MDB 6
gear.kendatsubaHakamaPlusOne = hp_gear("Ken. Hakama +1", 115)  --TA 5, Haste 9, MDB 8, Racc 46, Acc 51
gear.kendatsubaJinpachiPlusOne = hp_gear("Ken. Jinpachi +1", 88)  --TA 4, Haste 6, MDB 6, Racc 45, Acc 50
gear.kendatsubaSamuePlusOne = hp_gear("Ken. Samue +1", 122)  --TA 6, Haste 4, MDB 9, Racc 47, Acc 52
gear.kendatsubaTekkoPlusOne = hp_gear("Ken. Tekko +1", 61)  --TA 4, Haste 4, MDB 5, Racc 44, Acc 49
gear.kurysGloves = hp_gear("Kurys Gloves", 25)  --Haste 5, MDB 2, Acc 20, Enmity 9
gear.kustawiPlusOne = hp_gear("Kustawi +1", 0)  --Rapid Shot 3, Racc 25, Ratt 16, Enmity -5, Dagger Skill 242
gear.kyreneEarring = hp_gear("Kyrene's Earring", 0)  --DA 3, Macc 15, Racc 15
gear.labraunda = hp_gear("Labraunda", 150)  --Crit 10, Macc 50, Acc 50, Great Axe Skill 269, Parrying Skill 269
gear.lebecheRing = mp_gear("Lebeche Ring", 40)  --Cure Pot 3, Enmity -5
gear.lehkoHabhokaRing = hp_gear("Lehko's Ring", 0)  --STP 10, Haste 10
gear.lethargyEarringPlusOne = hp_gear("Leth. Earring +1", 0)  --FC 8
gear.lethargyEarringPlusOneDA = hp_gear("Leth. Earring +1", 0, {
    augments = {'System: 1 ID: 1676 Val: 0','Accuracy+14','Mag. Acc.+14','"Dbl.Atk."+5',}, })  --FC 8
gear.leylineGlovesFCB = hp_gear("Leyline Gloves", 25, {
    augments = {'Accuracy+15','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Fast Cast"+3',}, })  --FC 5, Haste 5, MAB 15, Macc 18, MDB 2
gear.linosFC = hp_gear("Linos", 20, {
    augments = {'Mag. Evasion+15','"Fast Cast"+6','HP+20',}, })  --HP 20, FC 6
gear.lorgMor = hp_gear("Lorg Mor", 0)  --DT 7, Regen 6, MAB 50, Macc 30, MDmg 248
gear.loughnashade = hp_gear("Loughnashade", 0)  --CHR 20
gear.luciditySash = hp_gear("Lucidity Sash", 0)  --Summoning magic Skill 7
gear.schNuke = hp_gear("Lugh's Cape", 0, {
    augments = {'INT+20','Mag. Acc+20 /Mag. Dmg.+20','INT+10','"Mag.Atk.Bns."+10','Damage taken-5%',}, })  --MAB 10, DT 5
gear.luminarySash = mp_gear("Luminary Sash", 45)  --Macc 10, ConMP 4
gear.lycurgos = rank_gear("Lycurgos", 70)  --Macc 40, Acc 40, Att 30, Great Axe Skill 250, Parrying Skill 250
gear.machaeraPlusTwo = hp_gear("Machaera +2", 0, {
    augments = {'TP Bonus +1000',}, })
gear.macheEarringPlusOne = hp_gear("Mache Earring +1", 0)  --DA 2, Acc 10
gear.magneticEarring = mp_gear("Magnetic Earring", 20)  --SIRD 8, ConMP 5
gear.magoragaBeadNecklace = hp_gear("Magoraga Beads", 0)  --AGI 2
gear.masamune = rank_gear("Masamune", 70)
gear.jugOfMeatyBroth = hp_gear("Meaty Broth", 0)
gear.mendicantEarring = mp_gear("Mendi. Earring", 30)  --Cure Pot 5, Cure FC 5, ConMP 2
gear.menelausRing = hp_gear("Menelaus's Ring", 0)  --Cure Pot 5, Healing magic Skill 15
gear.metamorphRing = hp_gear("Metamorph Ring", -50)  --Macc 1, Converts 50 HP to MP
gear.mizukageNoKubikazari = hp_gear("Mizu. Kubikazari", 0)  --MAB 8, MBD 10
gear.moonlightCape = hp_gear("Moonlight Cape", 275)
gear.moonlightRing2 = hp_gear("Moonlight Ring", 110, { bag = "wardrobe2" })  --STP 5, Acc 8, Att 8
gear.moonlightRing1 = hp_gear("Moonlight Ring", 110, { bag = "wardrobe" })  --STP 5, Acc 8, Att 8
gear.moonshadeEarringAcc = hp_gear("Moonshade Earring", 0, {
    augments = {'Accuracy+4','TP Bonus +250',}, })  --Acc 4
gear.moonshadeEarringBAtt = hp_gear("Moonshade Earring", 0, {
    augments = {'Attack+4','TP Bonus +250',}, })
gear.mousaiManteelPlusOne = hp_gear("Mou. Manteel +1", 191)  --Haste 3, Macc 52, MDB 9
gear.mousaiGagesPlusOne = hp_gear("Mousai Gages +1", 88)  --Haste 3, MDB 5
gear.mousaiTurbanPlusOne = hp_gear("Mousai Turban +1", 122)  --Haste 6, MDB 7
gear.mpuGandring = hp_gear("Mpu Gandring", 0)  --Dagger Skill 252, Parrying Skill 252, Magic Accuracy Skill 252
gear.mujinBand = hp_gear("Mujin Band", 0)  --SC Bonus 5
gear.najiLoop = hp_gear("Naji's Loop", 0)  --FC 1, Cure Pot 1, Enmity -1
gear.geoPetRegen = hp_gear("Nantosuelta's Cape", 60, {
    augments = {'HP+60','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Pet: "Regen"+10','Pet: "Regen"+5',}, })  --HP 60, Regen 10, Regen 5
gear.neoAnimator = hp_gear("Neo Animator", 60)  --WSD 5, Acc 10
gear.nibiruCudgelNuke = hp_gear("Nibiru Cudgel", 0, {
    augments = {'MP+50','INT+10','"Mag.Atk.Bns."+15',}, })  --Cure Pot 10, MAB 16, Macc 7, MDmg 124, Club Skill 242
gear.ninjaNodowaPlusTwo = hp_gear("Ninja Nodowa +2", 0)  --STP 7, Racc 25, Acc 25
gear.nirvana = hp_gear("Nirvana", 0)  --MDmg 279, Acc 30, Staff Skill 269, Parrying Skill 269, Magic Accuracy Skill 269
gear.nukumiEarringPlusOne = hp_gear("Nukumi Earring +1", 0)  --Axe Skill 11
gear.nullMasque = hp_gear("Null Masque", 100)  --Refresh 1, Regen 3, Macc 50, MDB 8, Acc 50
gear.nullShawl = hp_gear("Null Shawl", 0)  --STP 7, DA 7, Macc 50, Racc 50, Acc 50
gear.obstinateSash = hp_gear("Obstin. Sash", 0)  --MND 5
gear.ochain = hp_gear("Ochain", 0)  --VIT 25
gear.runFC = hp_gear("Ogma's Cape", 80, {
    augments = {'HP+60','Eva.+20 /Mag. Eva.+20','HP+20','"Fast Cast"+10','Spell interruption rate down-10%',}, })  --HP 60, HP 20, FC 10, SIRD 10
gear.runSTP = hp_gear("Ogma's Cape", 60, {
    augments = {'HP+60','Accuracy+20 Attack+20','Accuracy+10','"Store TP"+10','Damage taken-5%',}, })  --HP 60, STP 10, DT 5, Acc 20, Acc 10
gear.runEnmity = hp_gear("Ogma's Cape", 60, {
    augments = {'HP+60','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Enmity+10','Damage taken-5%',}, })  --HP 60, DT 5, Enmity 10
gear.opashoro = hp_gear("Opashoro", 0)  --Staff Skill 252, Parrying Skill 252, Magic Accuracy Skill 252
gear.oshosiLeggingsPlusOne = hp_gear("Osh. Leggings +1", 58)  --Macc 48, MDB 7, Racc 43, Enmity -15
gear.oshosiTrousersPlusOne = hp_gear("Osh. Trousers +1", 104)  --Snapshot 12, Macc 51, MDB 9, Racc 46
gear.oshashaTreatise = hp_gear("Oshasha's Treatise", 0)  --WSD 3, Acc 5, Att 5
gear.oshosiGlovesPlusOne = hp_gear("Oshosi Gloves +1", 49)  --Snapshot 10, Macc 49, MDB 5, Racc 44, SB 15
gear.oshosiMaskPlusOne = hp_gear("Oshosi Mask +1", 77)  --Macc 50, MDB 7, Racc 45
gear.oshosiVestPlusOne = hp_gear("Oshosi Vest +1", 111)  --STP 10, Snapshot 14, Macc 52, MDB 9, Racc 47
gear.pangu = hp_gear("Pangu", 150)  --Macc 50, MDmg 217, Racc 50, Acc 50, Axe Skill 269
gear.peltastEarringPlusOne = hp_gear("Pel. Earring +1", 0)  --SB 6
gear.pemphredoTathlum = hp_gear("Pemphredo Tathlum", 0)  --MAB 4, Macc 8, ConMP 4
gear.perimedeCape = hp_gear("Perimede Cape", 0)  --Enhancing magic Skill 7, Dark magic Skill 7
gear.perunPlusOne = rank_gear("Perun +1", 101)  --STP 4, Racc 15, Ratt 15, Enmity -3, Axe Skill 242
gear.petFoodThetaBiscuit = hp_gear("Pet Food Theta", 0)
gear.pingaPantsPlusOne = hp_gear("Pinga Pants +1", 84)  --FC 13, Cure Pot 13, MDB 8, Enmity -8
gear.pingaTunicPlusOne = hp_gear("Pinga Tunic +1", 101)  --FC 15, Cure Pot 15, MDB 9, Enmity -9
gear.platinumMoogleBelt = hp_gear("Plat. Mog. Belt", 10)
gear.potentGrip = hp_gear("Potent Grip", 0)  --STR 5, DEX 5
gear.psilomene = hp_gear("Psilomene", 15)  --Enmity -3
gear.purityRing = hp_gear("Purity Ring", 0)
gear.pursuerFeetPathD = hp_gear("Pursuer's Gaiters", 13, {
    augments = {'Rng.Acc.+10','"Rapid Shot"+10','"Recycle"+15',}, })  --Haste 4, Macc 15, MDB 5, Racc 20, Enmity -7
gear.rahabRing = mp_gear("Rahab Ring", 30)  --FC 2, Macc 5
gear.ratriGadlingsPlusOne = hp_gear("Rat. Gadlings +1", 499)  --WSD 8, Haste 4, Macc 44, Enmity -10, Scythe Skill 53
gear.ratriSolleretsPlusOne = hp_gear("Rat. Sollerets +1", 487)  --WSD 8, Haste 3, Macc 43, Scythe Skill 52
gear.ratriCuissesPlusOne = hp_gear("Ratri Cuisses +1", 521)  --STP 10, WSD 9, Haste 5, Macc 46, Scythe Skill 55
gear.ratriBreastplatePlusOne = hp_gear("Ratri Plate +1", 533)  --WSD 10, Haste 3, Macc 47, Scythe Skill 56
gear.ratriSalletPlusOne = hp_gear("Ratri Sallet +1", 510)  --WSD 8, Haste 7, Macc 45, Scythe Skill 54
gear.regalBelt = hp_gear("Regal Belt", 88)  --MAB 10, REA set additive
gear.regalCuffs = hp_gear("Regal Cuffs", 91)  --Haste 4, Macc 45, MDB 2, REA set additive
gear.regalEarring = mp_gear("Regal Earring", 20)  --MAB 7, REA set additive
gear.regalGauntlets = hp_gear("Regal Gauntlets", 205)  --Refresh 1, Regen 10, SIRD 10, Haste 4, MDB 2, REA set additive
gear.regalGem = hp_gear("Regal Gem", 0)  --Macc 15, REA set additive
gear.regalRing = hp_gear("Regal Ring", 50)  --Ratt 20, Att 20, REA set additive
gear.republicanPlatinumMedal = hp_gear("Rep. Plat. Medal", 0)  --Ratt 30, Att 30
gear.bluFCSird = hp_gear("Rosmerta's Cape", 0, {
    augments = {'INT+20','Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+10','"Fast Cast"+10','Spell interruption rate down-10%',}, })  --FC 10, SIRD 10, Macc 10
gear.bluWSDDt = hp_gear("Rosmerta's Cape", 0, {
    augments = {'MND+20','Accuracy+20 Attack+20','MND+10','Weapon skill damage +10%','Damage taken-5%',}, })  --WSD 10, DT 5, Acc 20
gear.roundelEarring = hp_gear("Roundel Earring", 0)  --Cure Pot 5
gear.ruminationSash = hp_gear("Rumination Sash", 0)  --SIRD 10, Macc 3, Enfeebling magic Skill 7
gear.sacroBulwark = hp_gear("Sacro Bulwark", 0)  --SIRD 7, Cure Pot 5, Shield Skill 112
gear.sacroCord = hp_gear("Sacro Cord", 0)  --MAB 8, Macc 8, Enmity -3
gear.sacroMantle = hp_gear("Sacro Mantle", 0)  --WSD 6, Macc 20, Racc 20, Ratt 20, Acc 20
gear.samuraiNodowaPlusTwo = hp_gear("Sam. Nodowa +2", 0)  --STP 7, Acc 30
gear.sanareEarring = hp_gear("Sanare Earring", 0)  --MDB 4, Club Skill 5
gear.sancusSachetPlusOne = hp_gear("Sancus Sachet +1", 0)  --Macc 20, Racc 20, Acc 20
gear.seethingBombletPlusOne = hp_gear("Seeth. Bomblet +1", 0)  --MAB 7, Acc 13, Att 13
gear.mnkDADex = hp_gear("Segomo's Mantle", 0, {
    augments = {'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Dbl.Atk."+10','Magic dmg. taken-10%',}, })  --DA 10, Acc 20, Acc 10
gear.shadowRing = hp_gear("Shadow Ring", 0)  --Occ. effect
gear.shedirSeraweels = hp_gear("Shedir Seraweels", 0)  --Enhancing magic Skill 15
gear.shivaRingPlusOne = hp_gear("Shiva Ring +1", 0)  --MAB 3
gear.shneddickRing = hp_gear("Shneddick Ring", 0)
gear.sibylScarf = hp_gear("Sibyl Scarf", 0)  --Refresh 1, MAB 10
gear.silverMoogleBelt = hp_gear("Silver Mog. Belt", 2)
gear.skulkerEarringPlusOne = hp_gear("Skulk. Earring +1", 0)  --TA 4, SB 6
gear.slitherGlovesPlusOne = hp_gear("Slither Gloves +1", 23)  --Haste 4, MDB 2, Ratt 12, Att 12, SB 5
gear.samSnapshot = hp_gear("Smertrios's Mantle", 60, {
    augments = {'HP+60','Rng.Acc.+20 Rng.Atk.+20','"Snapshot"+10','Damage taken-5%',}, })  --HP 60, Snapshot 10, DT 5
gear.samSTP = hp_gear("Smertrios's Mantle", 0, {
    augments = {'AGI+20','Rng.Acc.+20 Rng.Atk.+20','Rng.Acc.+10','"Store TP"+10','Damage taken-5%',}, })  --STP 10, DT 5
gear.samSTPDt = hp_gear("Smertrios's Mantle", 0, {
    augments = {'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Store TP"+10','Damage taken-5%',}, })  --STP 10, DT 5, Acc 20, Acc 10
gear.soboroSukehiro = rank_gear("Soboro Sukehiro", 70)  --Occ. effect
gear.solemnityCape = hp_gear("Solemnity Cape", 0)  --Cure Pot 7, ConMP 5
gear.jugOfSpicyBroth = hp_gear("Spicy Broth", 0)
gear.stikiniRingPlusOne2 = hp_gear("Stikini Ring +1", 0, { bag = "wardrobe2" })  --Refresh 1, Macc 11
gear.stikiniRingPlusOne3 = hp_gear("Stikini Ring +1", 0, { bag = "wardrobe3" })  --Refresh 1, Macc 11
gear.stikiniRingPlusOne1 = hp_gear("Stikini Ring +1", 0, { bag = "wardrobe" })  --Refresh 1, Macc 11
gear.taeonChapeauSnapshot = hp_gear("Taeon Chapeau", 36, {
    augments = {'"Snapshot"+5','"Snapshot"+5',}, })  --Haste 8, MDB 2, Racc 10, Acc 10
gear.blmNuke = hp_gear("Taranus's Cape", 0, {
    augments = {'INT+20','Mag. Acc+20 /Mag. Dmg.+20','INT+10','"Mag.Atk.Bns."+10','Phys. dmg. taken-10%',}, })  --MBD 5
gear.telchineChasubleRegen = hp_gear("Telchine Chas.", 54, {
    augments = {'"Regen"+2','Enh. Mag. eff. dur. +10',}, })  --Haste 3, MDB 6, Enhancing magic Skill 12
gear.tellenBelt = hp_gear("Tellen Belt", 0)  --STP 4
gear.tempusFugit = hp_gear("Tempus Fugit", 0)  --Haste 14
gear.ternionDaggerPlusOne = rank_gear("Ternion Dagger +1", 101)  --TA 4, Acc 27, SB 9, Dagger Skill 228, Parrying Skill 228
gear.thereoidGreaves = hp_gear("Thereoid Greaves", 13)  --Haste 4, MDB 5, Ratt 25, Att 25
gear.throwingTomahawk = hp_gear("Thr. Tomahawk", 0)
gear.thfDA = hp_gear("Toutatis's Cape", 0, {
    augments = {'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Dbl.Atk."+10','Damage taken-5%',}, })  --DA 10, DT 5, Acc 20, Acc 10
gear.thfWSD = hp_gear("Toutatis's Cape", 0, {
    augments = {'INT+20','Mag. Acc+20 /Mag. Dmg.+20','INT+10','Weapon skill damage +10%','Damage taken-5%',}, })  --WSD 10, DT 5
gear.trishula = rank_gear("Trishula", 70)  --STP 10, MDmg 155, Polearm Skill 269, Parrying Skill 269, Magic Accuracy Skill 228
gear.truxEarring = hp_gear("Trux Earring", 0)  --DA 3, Enmity 5, Katana Skill 5
gear.turmsMittensPlusOne = hp_gear("Turms Mittens +1", 74)  --Regen 6, Haste 4, MDB 5, Acc 49
gear.twilightCloak = mp_gear("Twilight Cloak", 75)  --MAB 15, Enmity -15
gear.ullr = hp_gear("Ullr", 0)  --Macc 40, Racc 40, Ratt 30, Archery Skill 250
gear.umuthiHat = hp_gear("Umuthi Hat", 36)  --Haste 6, MDB 5, Enhancing magic Skill 13
gear.vadoseRod = rank_gear("Vadose Rod", 22)  --Cure Pot 16, MAB 16, MDmg 124, Club Skill 242, Parrying Skill 242
gear.vanyaFeetPathA = hp_gear("Vanya Clogs", 13, {
    augments = {'MP+50','"Cure" potency +7%','Enmity-6',}, })  --Cure Pot 5, Haste 3, MDB 5, Healing magic Skill 20
gear.vararRingPlusOne = hp_gear("Varar Ring +1", 0)  --STP 6, Racc 10, Acc 10
gear.jugOfVenomousBroth = hp_gear("Venomous Broth", 0)
gear.verethragna = hp_gear("Verethragna", 0)  --STR 15
gear.vitiationChapeauPlusFour = hp_gear("Viti. Chapeau +4", 91, {
    augments = {'Enfeebling Magic duration','Magic Accuracy',}, })  --Refresh 3, WSD 9, Haste 6, Macc 42, MDB 8
gear.vitiationGlovesPlusThree = hp_gear("Viti. Gloves +3", 42, {
    augments = {'Enhancing Magic duration',}, })  --Haste 3, Macc 38, MDB 8, Acc 38, Att 63
gear.vitiationTightsPlusThree = hp_gear("Viti. Tights +3", 63, {
    augments = {'Enspell Damage','Accuracy',}, })  --Haste 5, Macc 39, MDB 8, Acc 39, Att 64
gear.vitiationBootsPlusThree = hp_gear("Vitiation Boots +3", 33, {
    augments = {'Immunobreak Chance',}, })  --Haste 3, MAB 55, Macc 43, MDB 7, Acc 36
gear.volteBoots = hp_gear("Volte Boots", 57)  --Haste 5, Macc 37, MDB 7, Racc 37, Acc 37
gear.volteGaiters = hp_gear("Volte Gaiters", 9)  --FC 6, Refresh 1, Haste 3, MAB 27, Macc 35
gear.volteHose = hp_gear("Volte Hose", 57)  --Haste 5, Macc 37, MDB 7, Racc 37, Acc 37
gear.volteJupon = hp_gear("Volte Jupon", 57)  --Haste 5, Macc 37, MDB 7, Racc 37, Acc 37
gear.volteMittens = hp_gear("Volte Mittens", 63)  --STP 6, Snapshot 2, Haste 4, MDB 3, Racc 36
gear.volteSpats = hp_gear("Volte Spats", 72)  --STP 6, Snapshot 2, Haste 3, MDB 6, Racc 35
gear.volteTiara = hp_gear("Volte Tiara", 91)  --STP 6, Snapshot 3, Haste 6, MDB 4, Racc 37
gear.volteTights = hp_gear("Volte Tights", 118)  --STP 8, Snapshot 5, Haste 9, MDB 6, Racc 38
gear.wardenRing = hp_gear("Warden's Ring", 0)
gear.warderCharmPlusOne = hp_gear("Warder's Charm +1", 0)  --Enmity 1
gear.warpCudgel = hp_gear("Warp Cudgel", 0)
gear.wicceEarringPlusOne = hp_gear("Wicce Earring +1", 0)  --MAB 8, MDmg 8
gear.xoanon = hp_gear("Xoanon", 0)  --MAB 26, Macc 40, MDmg 241, Acc 40, Staff Skill 250
gear.yamarang = hp_gear("Yamarang", 0)  --STP 3, Macc 15, Acc 15
gear.yetshilaPlusOne = hp_gear("Yetshila +1", 0)  --Crit 2
gear.yoichiArrow = hp_gear("Yoichi's Arrow", 0)  --Racc 35, Ratt 25
gear.yoichinoyumi = hp_gear("Yoichinoyumi", 0)  --Racc 40, Ratt 30
gear.zantetsuken = hp_gear("Zantetsuken", 0)  --Haste 4, Acc 27, Att 33, Sword Skill 242, Parrying Skill 242
gear.zendikRobe = hp_gear("Zendik Robe", 57)  --FC 13, Haste 4, MAB 10, Macc 45, MDB 7

gear.whmDA = hp_gear("Alaunus's Cape", 0, {
    augments = {'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Dbl.Atk."+10','Damage taken-5%',}, })  --DA 10, DT 5, Acc 20, Acc 10
gear.amalricHandsPlusOnePathD = hp_gear("Amalric Gages +1", 13, {
    augments = {'INT+12','Mag. Acc.+20','"Mag.Atk.Bns."+20',}, })  --SIRD 11, Haste 3, MAB 33, MDB 3, Elemental magic Skill 14
gear.amalricFeetPlusOnePathA = hp_gear("Amalric Nails +1", 4, {
    augments = {'MP+80','Mag. Acc.+20','"Mag.Atk.Bns."+20',}, })  --FC 6, SIRD 16, Haste 3, MAB 32, MDmg 20
gear.drkDA = hp_gear("Ankou's Mantle", 0, {
    augments = {'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Dbl.Atk."+10','Damage taken-5%',}, })  --DA 10, DT 5, Acc 20, Acc 10
gear.drkFC = hp_gear("Ankou's Mantle", 60, {
    augments = {'HP+60','Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+10','"Fast Cast"+10','Damage taken-5%',}, })  --HP 60, FC 10, DT 5, Macc 10
gear.drkWSD = hp_gear("Ankou's Mantle", 0, {
    augments = {'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%','Damage taken-5%',}, })  --WSD 10, DT 5, Acc 20
gear.apogeeHeadPlusOnePathB = hp_gear("Apogee Crown +1", -110, {
    augments = {'MP+80','Pet: Attack+35','Blood Pact Dmg.+8',}, })  --Haste 6, MDB 6
gear.apogeeFeetPlusOnePathC = hp_gear("Apogee Pumps +1", -90, {
    augments = {'Pet: Attack+25','Pet: "Mag.Atk.Bns."+25','Blood Pact Dmg.+8',}, })  --Haste 3, MDB 6
gear.apogeeLegsPlusOnePathD = hp_gear("Apogee Slacks +1", -110, {
    augments = {'Pet: STR+20','Blood Pact Dmg.+14','Pet: "Dbl. Atk."+4',}, })  --Haste 5, MDB 6
gear.bstDA = hp_gear("Artio's Mantle", 0, {
    augments = {'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','Damage taken-5%',}, })  --DA 10, DT 5, Acc 20
gear.assassinGorgetPlusTwo = hp_gear("Asn. Gorget +2", 0)  --Macc 25, Acc 25
gear.smnFC = hp_gear("Campestres's Cape", 0, {
    augments = {'Pet: M.Acc.+20 Pet: M.Dmg.+20','Mag. Acc+20 /Mag. Dmg.+20','Pet: Magic Damage+10','"Fast Cast"+10',}, })  --FC 10
gear.smnFCB = hp_gear("Campestres's Cape", 0, {
    augments = {'Pet: M.Acc.+20 Pet: M.Dmg.+20','Pet: Magic Damage+10','"Fast Cast"+10',}, })  --FC 10
gear.smnPetRegen = hp_gear("Campestres's Cape", 0, {
    augments = {'Pet: Acc.+20 Pet: R.Acc.+20 Pet: Atk.+20 Pet: R.Atk.+20','Eva.+20 /Mag. Eva.+20','Pet: "Regen"+10',}, })  --Regen 10
gear.smnPetRegenB = hp_gear("Campestres's Cape", 0, {
    augments = {'Pet: Acc.+20 Pet: R.Acc.+20 Pet: Atk.+20 Pet: R.Atk.+20','Eva.+20 /Mag. Eva.+20','Pet: Attack+10 Pet: Rng.Atk.+10','Pet: "Regen"+10','Pet: Damage taken -5%',}, })  --Regen 10
gear.corSnapshot = hp_gear("Camulus's Mantle", 80, {
    augments = {'HP+60','HP+20','"Snapshot"+10',}, })  --HP 60, HP 20, Snapshot 10
gear.corWSDStr = hp_gear("Camulus's Mantle", 0, {
    augments = {'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%','Damage taken-5%',}, })  --WSD 10, DT 5, Acc 20
gear.chironicHoseNukeB = hp_gear("Chironic Hose", 31, {
    augments = {'Mag. Acc.+24 "Mag.Atk.Bns."+24','"Conserve MP"+1','Mag. Acc.+15',}, })  --Cure Pot 8, Haste 5, Macc 20, MDB 6, Enfeebling magic Skill 13
gear.chironicHoseNuke = hp_gear("Chironic Hose", 31, {
    augments = {'Mag. Acc.+23 "Mag.Atk.Bns."+23','"Drain" and "Aspir" potency +8','MND+1','Mag. Acc.+12',}, })  --Cure Pot 8, Haste 5, Macc 20, MDB 6, Enfeebling magic Skill 13
gear.dunnaFC = rank_gear("Dunna", 2, {
    augments = {'MP+20','Mag. Acc.+10','"Fast Cast"+3',}, })  --Handbell Skill 18
gear.enticerPantsMaccPetMacc = hp_gear("Enticer's Pants", 38, {
    augments = {'MP+50','Pet: Accuracy+15 Pet: Rng. Acc.+15','Pet: Mag. Acc.+15','Pet: Damage taken -5%',}, })  --Haste 5, MDB 6
gear.evasionistCapeDA = hp_gear("Evasionist's Cape", 0, {
    augments = {'Enmity+1','"Embolden"+15','"Dbl.Atk."+1',}, })  --MAB 10, Acc 15
gear.founderHoseMacc = hp_gear("Founder's Hose", 54, {
    augments = {'MND+8','Mag. Acc.+14','Attack+13','Breath dmg. taken -3%',}, })  --DA 2, SIRD 30, Haste 5, Macc 20, MDB 3
gear.futharkTorquePlusTwo = hp_gear("Futhark Torque +2", 60)  --Enmity 10
gear.gendewithaGagesPlusOneBCureFC = hp_gear("Gende. Gages +1", 30, {
    augments = {'Phys. dmg. taken -3%','Magic dmg. taken -2%','"Cure" spellcasting time -5%',}, })  --FC 7, Haste 1, Macc 15, MDB 3
gear.grioavolrNukeB = hp_gear("Grioavolr", 0, {
    augments = {'Enfb.mag. skill +13','Mag. Acc.+24','"Mag.Atk.Bns."+27',}, })  --FC 4, MAB 30, MAB 115, Macc 14, MDmg 217
gear.grioavolrNukeBloodPact = hp_gear("Grioavolr", 0, {
    augments = {'Blood Pact Dmg.+9','Pet: STR+7','Pet: Mag. Acc.+26','Pet: "Mag.Atk.Bns."+30',}, })  --FC 4, MAB 30, MAB 115, Macc 14, MDmg 217
gear.grioavolrMaccBloodPact = hp_gear("Grioavolr", 0, {
    augments = {'Blood Pact Dmg.+9','Pet: INT+15','Pet: Mag. Acc.+24',}, })  --FC 4, MAB 30, MAB 115, Macc 14, MDmg 217
gear.hashishinEarringPlusOneDA = hp_gear("Hashi. Earring +1", 0, {
    augments = {'System: 1 ID: 1676 Val: 0','Accuracy+15','Mag. Acc.+15','"Dbl.Atk."+5',}, })  --Sword Skill 11, Blue magic Skill 11
gear.herculeanBootsFC = hp_gear("Herculean Boots", 9, {
    augments = {'"Fast Cast"+6',}, })  --TA 2, Haste 4, MAB 10, Macc 10, MDB 5
gear.herculeanBootsCrit = hp_gear("Herculean Boots", 9, {
    augments = {'AGI+6','Crit.hit rate+3','Quadruple Attack +2','Accuracy+6 Attack+6',}, })  --TA 2, Haste 4, MAB 10, Macc 10, MDB 5
gear.herculeanHelmFC = hp_gear("Herculean Helm", 38, {
    augments = {'"Mag.Atk.Bns."+21','"Fast Cast"+6',}, })  --FC 7, Haste 8, MAB 10, MDB 3, Ratt 15
gear.herculeanHelmNuke = hp_gear("Herculean Helm", 38, {
    augments = {'"Subtle Blow"+1','STR+3','"Treasure Hunter"+2','Mag. Acc.+10 "Mag.Atk.Bns."+10',}, })  --FC 7, Haste 8, MAB 10, MDB 3, Ratt 15
gear.herculeanTrousersFCB = hp_gear("Herculean Trousers", 38, {
    augments = {'"Mag.Atk.Bns."+11','"Fast Cast"+6',}, })  --STP 4, Haste 6, MDB 5, Ratt 15, Att 15
gear.herculeanTrousersFC = hp_gear("Herculean Trousers", 38, {
    augments = {'Mag. Acc.+17','"Fast Cast"+6','STR+9',}, })  --STP 4, Haste 6, MDB 5, Ratt 15, Att 15
gear.herculeanTrousersBFC = hp_gear("Herculean Trousers", 38, {
    augments = {'Mag. Acc.+7','"Fast Cast"+6',}, })  --STP 4, Haste 6, MDB 5, Ratt 15, Att 15
gear.herculeanTrousersAccEnmityDown = hp_gear("Herculean Trousers", 38, {
    augments = {'Enmity-2','Pet: Haste+3','"Treasure Hunter"+1','Accuracy+9 Attack+9',}, })  --STP 4, Haste 6, MDB 5, Ratt 15, Att 15
gear.kaliMacc = rank_gear("Kali", 24, {
    augments = {'Mag. Acc.+15','String instrument skill +10','Wind instrument skill +10',}, })  --FC 7, MAB 14, Macc 10, MDmg 108, Acc 10
gear.karagozEarringPlusOneSTP = hp_gear("Kara. Earring +1", 0, {
    augments = {'System: 1 ID: 1676 Val: 0','Accuracy+12','Mag. Acc.+12','"Store TP"+4',}, })  --SB 6, Hand Skill 11
gear.kasugaEarringPlusOneWSD = hp_gear("Kasuga Earring +1", 0, {
    augments = {'System: 1 ID: 1676 Val: 0','Accuracy+12','Mag. Acc.+12','Weapon skill damage +2%',}, })  --STP 8, SC Bonus 6
gear.kaykausBodyPlusOnePathD = hp_gear("Kaykaus Bliaut +1", 52, {
    augments = {'MP+80','"Cure" potency +6%','"Conserve MP"+7',}, })  --Refresh 3, Haste 3, MAB 28, Macc 28, MDB 7
gear.kaykausFeetPlusOnePathB = hp_gear("Kaykaus Boots +1", 11, {
    augments = {'MP+80','"Cure" spellcasting time -7%','Enmity-6',}, })  --Cure Pot 11, Haste 3, MDB 6, ConMP 7, Enmity -6
gear.kaykausHandsPlusOnePathB = hp_gear("Kaykaus Cuffs +1", 20, {
    augments = {'MP+80','"Cure" spellcasting time -7%','Enmity-6',}, })  --Cure Pot 11, Haste 3, Macc 33, MDB 3, Enmity -6
gear.leylineGlovesFC = hp_gear("Leyline Gloves", 25, {
    augments = {'Accuracy+14','Mag. Acc.+13','"Mag.Atk.Bns."+13','"Fast Cast"+2',}, })  --FC 5, Haste 5, MAB 15, Macc 18, MDB 2
gear.lifestreamCape = hp_gear("Lifestream Cape", 50, {
    augments = {'Geomancy Skill +8','Indi. eff. dur. +20','Pet: Damage taken -3%',}, })  --Enfeebling magic Skill 10, Geomancy Skill 5
gear.loessBarbutaPlusOne = hp_gear("Loess Barbuta +1", 105)  --Enmity 9
gear.mediumSabotsCureB = hp_gear("Medium's Sabots", 11, {
    augments = {'MP+45','MND+9','"Conserve MP"+5','"Cure" potency +4%',}, })  --Cure Pot 7, Haste 3, Macc 25, MDB 6, Divine magic Skill 15
gear.mediumSabotsCure = hp_gear("Medium's Sabots", 11, {
    augments = {'MP+50','MND+10','"Conserve MP"+7','"Cure" potency +5%',}, })  --Cure Pot 7, Haste 3, Macc 25, MDB 6, Divine magic Skill 15
gear.merlinicCrackowsFCB = hp_gear("Merlinic Crackows", 4, {
    augments = {'"Mag.Atk.Bns."+29','"Fast Cast"+6','DEX+7','Mag. Acc.+14',}, })  --FC 5, Haste 3, MAB 15, MDB 6, ConMP 4
gear.merlinicCrackowsFC = hp_gear("Merlinic Crackows", 4, {
    augments = {'Mag. Acc.+12','"Fast Cast"+7','INT+9','"Mag.Atk.Bns."+8',}, })  --FC 5, Haste 3, MAB 15, MDB 6, ConMP 4
gear.merlinicCrackowsBFC = hp_gear("Merlinic Crackows", 4, {
    augments = {'"Fast Cast"+7','CHR+10','Mag. Acc.+8',}, })  --FC 5, Haste 3, MAB 15, MDB 6, ConMP 4
gear.merlinicDastanasNukeB = hp_gear("Merlinic Dastanas", 9, {
    augments = {'Accuracy+20','"Conserve MP"+4','"Treasure Hunter"+2','Accuracy+18 Attack+18','Mag. Acc.+16 "Mag.Atk.Bns."+16',}, })  --Haste 3, MAB 20, MDB 3, Enmity 5
gear.merlinicDastanasFC = hp_gear("Merlinic Dastanas", 9, {
    augments = {'"Mag.Atk.Bns."+26','"Fast Cast"+7',}, })  --Haste 3, MAB 20, MDB 3, Enmity 5
gear.merlinicDastanasBFC = hp_gear("Merlinic Dastanas", 9, {
    augments = {'"Fast Cast"+7','"Mag.Atk.Bns."+5',}, })  --Haste 3, MAB 20, MDB 3, Enmity 5
gear.merlinicDastanasNukeBloodPact = hp_gear("Merlinic Dastanas", 9, {
    augments = {'Pet: Mag. Acc.+23 Pet: "Mag.Atk.Bns."+23','Blood Pact Dmg.+9','Pet: INT+3',}, })  --Haste 3, MAB 20, MDB 3, Enmity 5
gear.merlinicHoodFCB = hp_gear("Merlinic Hood", 22, {
    augments = {'"Mag.Atk.Bns."+27','"Fast Cast"+6','INT+2','Mag. Acc.+8',}, })  --FC 8, Haste 6, MAB 10, Macc 15, MDB 6
gear.merlinicHoodFC = hp_gear("Merlinic Hood", 22, {
    augments = {'"Mag.Atk.Bns."+22','"Fast Cast"+7','STR+6',}, })  --FC 8, Haste 6, MAB 10, Macc 15, MDB 6
gear.merlinicJubbahFC = hp_gear("Merlinic Jubbah", 41, {
    augments = {'Mag. Acc.+23','"Fast Cast"+7','"Mag.Atk.Bns."+14',}, })  --FC 6, Haste 3, MAB 20, Macc 20, MDB 7
gear.merlinicShalwarFC = hp_gear("Merlinic Shalwar", 29, {
    augments = {'Mag. Acc.+23','"Fast Cast"+7','VIT+3','"Mag.Atk.Bns."+13',}, })  --Haste 5, MAB 15, Macc 20, MDmg 13, MDB 6
gear.mochizukiTekkoPlusThree = hp_gear("Mochizuki Tekko +3", 45, {
    augments = {'Enh. "Ninja Tool Expertise" effect',}, })  --Haste 5, Macc 38, MDB 3, Acc 38, Att 79
gear.moonlightRing4 = hp_gear("Moonlight Ring", 110, { bag = "wardrobe4" })  --STP 5, Acc 8, Att 8
gear.geoCure = hp_gear("Nantosuelta's Cape", 60, {
    augments = {'HP+60','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','"Cure" potency +10%','Phys. dmg. taken-10%',}, })  --HP 60, Cure Pot 10, PDT 10
gear.geoFCB = hp_gear("Nantosuelta's Cape", 80, {
    augments = {'HP+60','HP+20','"Fast Cast"+10',}, })  --HP 60, HP 20, FC 10
gear.geoNukePdt = hp_gear("Nantosuelta's Cape", 0, {
    augments = {'INT+20','Mag. Acc+20 /Mag. Dmg.+20','INT+10','"Mag.Atk.Bns."+10','Phys. dmg. taken-10%',}, })  --MAB 10, PDT 10
gear.nourishingEarringPlusOne = hp_gear("Nourish. Earring +1", 0)  --Cure Pot 3, Cure FC 4
gear.odysseanCuissesFCB = hp_gear("Odyssean Cuisses", 54, {
    augments = {'"Fast Cast"+6','Accuracy+13','Attack+2',}, })  --STP 5, DA 2, Haste 5, MDB 4, Acc 15
gear.odysseanCuissesFC = hp_gear("Odyssean Cuisses", 54, {
    augments = {'Mag. Acc.+23','"Fast Cast"+6',}, })  --STP 5, DA 2, Haste 5, MDB 4, Acc 15
gear.odysseanGreavesCure = hp_gear("Odyssean Greaves", 20, {
    augments = {'"Cure" potency +6%','MND+9','"Mag.Atk.Bns."+11',}, })  --FC 5, SIRD 20, Cure Pot 7, Haste 3, Macc 10
gear.odysseanGreavesFC = hp_gear("Odyssean Greaves", 20, {
    augments = {'Rng.Acc.+14','MND+8','"Fast Cast"+6','Accuracy+19 Attack+19',}, })  --FC 5, SIRD 20, Cure Pot 7, Haste 3, Macc 10
gear.odysseanGreavesBFC = hp_gear("Odyssean Greaves", 20, {
    augments = {'Mag. Acc.+16','"Fast Cast"+6','CHR+10',}, })  --FC 5, SIRD 20, Cure Pot 7, Haste 3, Macc 10
gear.runWSD = hp_gear("Ogma's Cape", 0, {
    augments = {'DEX+20','Accuracy+20 Attack+20','DEX+10','Weapon skill damage +10%','Damage taken-5%',}, })  --WSD 10, DT 5, Acc 20
gear.pedagogyMortarboardPlusThree = hp_gear("Peda. M.Board +3", 86, {
    augments = {'Enh. "Altruism" and "Focalization"',}, })  --Haste 6, MAB 49, Macc 37, MDB 7, Acc 37
gear.pldFCB = hp_gear("Rudianos's Mantle", 80, {
    augments = {'HP+60','HP+20','"Fast Cast"+10',}, })  --HP 60, HP 20, FC 10
gear.pldWSD = hp_gear("Rudianos's Mantle", 0, {
    augments = {'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%','Damage taken-5%',}, })  --WSD 10, DT 5, Acc 20
gear.pldEnmityMeva = hp_gear("Rudianos's Mantle", 80, {
    augments = {'HP+60','Eva.+20 /Mag. Eva.+20','HP+20','Enmity+10','Mag. Evasion+15',}, })  --HP 60, HP 20, Enmity 10
gear.ryuoHandsPlusOnePathA = hp_gear("Ryuo Tekko +1", 29, {
    augments = {'STR+12','DEX+12','Accuracy+20',}, })  --Haste 4, MDB 1, Racc 33, Acc 33
gear.samnuhaTightsDAB = hp_gear("Samnuha Tights", 41, {
    augments = {'STR+8','DEX+9','"Dbl.Atk."+3','"Triple Atk."+2',}, })  --STP 7, Haste 6, MDB 5, Racc 15, Acc 15
gear.samnuhaTightsDA = hp_gear("Samnuha Tights", 41, {
    augments = {'STR+10','DEX+10','"Dbl.Atk."+3','"Triple Atk."+3',}, })  --STP 7, Haste 6, MDB 5, Racc 15, Acc 15
gear.samWSD = hp_gear("Smertrios's Mantle", 0, {
    augments = {'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%','Damage taken-5%',}, })  --WSD 10, DT 5, Acc 20
gear.summonerCollarPlusTwo = hp_gear("Smn. Collar +2", 50)  --Macc 25, Racc 25
gear.sorcererStolePlusTwo = hp_gear("Src. Stole +2", 0)  --MAB 7, Macc 30
gear.rdmWSDDt = hp_gear("Sucellos's Cape", 0, {
    augments = {'MND+20','Mag. Acc+20 /Mag. Dmg.+20','MND+10','Weapon skill damage +10%','Damage taken-5%',}, })  --WSD 10, DT 5
gear.taeonTabardFCB = hp_gear("Taeon Tabard", 99, {
    augments = {'"Fast Cast"+5','HP+40',}, })  --FC 4, Haste 4, MDB 6, Ratt 10, Att 10
gear.taeonTabardFC = hp_gear("Taeon Tabard", 103, {
    augments = {'"Fast Cast"+5','HP+44',}, })  --FC 4, Haste 4, MDB 6, Ratt 10, Att 10
gear.taeonTabardBFC = hp_gear("Taeon Tabard", 106, {
    augments = {'"Fast Cast"+5','HP+47',}, })  --FC 4, Haste 4, MDB 6, Ratt 10, Att 10
gear.blmFC = hp_gear("Taranus's Cape", 80, {
    augments = {'HP+60','HP+20','"Fast Cast"+10',}, })  --MBD 5
gear.telchineBraconiRegen = hp_gear("Telchine Braconi", 43, {
    augments = {'"Regen"+2','Enh. Mag. eff. dur. +10',}, })  --DA 3, Haste 5, MAB 15, MDB 6
gear.telchineBraconiBEnhDur = hp_gear("Telchine Braconi", 43, {
    augments = {'Enh. Mag. eff. dur. +10',}, })  --DA 3, Haste 5, MAB 15, MDB 6
gear.telchineCapRegen = hp_gear("Telchine Cap", 36, {
    augments = {'"Regen"+2','Enh. Mag. eff. dur. +10',}, })  --Haste 6, Macc 10, MDB 5, ConMP 4
gear.telchineCapBEnhDur = hp_gear("Telchine Cap", 36, {
    augments = {'Enh. Mag. eff. dur. +10',}, })  --Haste 6, Macc 10, MDB 5, ConMP 4
gear.telchineChasubleBEnhDur = hp_gear("Telchine Chas.", 54, {
    augments = {'Enh. Mag. eff. dur. +10',}, })  --Haste 3, MDB 6, Enhancing magic Skill 12
gear.telchineGlovesRegen = hp_gear("Telchine Gloves", 52, {
    augments = {'"Regen"+2','Enh. Mag. eff. dur. +10',}, })  --Cure Pot 10, Haste 3, MDB 3
gear.telchineGlovesBRegen = hp_gear("Telchine Gloves", 52, {
    augments = {'Mag. Evasion+24','"Regen"+2','Enh. Mag. eff. dur. +10',}, })  --Cure Pot 10, Haste 3, MDB 3
gear.telchineGlovesCEnhDur = hp_gear("Telchine Gloves", 52, {
    augments = {'Enh. Mag. eff. dur. +10',}, })  --Cure Pot 10, Haste 3, MDB 3
gear.telchinePigachesRegen = hp_gear("Telchine Pigaches", 13, {
    augments = {'Evasion+19','"Regen"+2','Enh. Mag. eff. dur. +10',}, })  --Haste 3, MDB 5, Enmity -4
gear.telchinePigachesBEnhDur = hp_gear("Telchine Pigaches", 13, {
    augments = {'Enh. Mag. eff. dur. +10',}, })  --Haste 3, MDB 5, Enmity -4
gear.telchinePigachesC = hp_gear("Telchine Pigaches", 13, {
    augments = {'Song spellcasting time -6%',}, })  --Haste 3, MDB 5, Enmity -4
gear.vanyaFeetPathB = hp_gear("Vanya Clogs", 13, {
    augments = {'Healing magic skill +20','"Cure" spellcasting time -7%','Magic dmg. taken -3',}, })  --Cure Pot 5, Haste 3, MDB 5, Healing magic Skill 20
gear.vanyaHeadPathB = hp_gear("Vanya Hood", 36, {
    augments = {'Healing magic skill +20','"Cure" spellcasting time -7%','Magic dmg. taken -3',}, })  --Cure Pot 10, Haste 6, MDB 5, ConMP 6
gear.vararRingPlusOne2 = hp_gear("Varar Ring +1", 0, { bag = "wardrobe2" })  --STP 6, Racc 10, Acc 10
gear.vararRingPlusOne1 = hp_gear("Varar Ring +1", 0, { bag = "wardrobe" })  --STP 6, Racc 10, Acc 10
gear.pupDA = hp_gear("Visucius's Mantle", 0, {
    augments = {'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Dbl.Atk."+10','Damage taken-5%',}, })  --DA 10, DT 5, Acc 20, Acc 10

--[==[ Aliases: keys the live job files were already using for items whose
     entries carry a different key. Same item, same priority. ]==]--

--[==[ Escha / Geas Fete sets -- the four Nolan augment paths per piece,
     at maximum rank, named nameSlot[PlusOne]PathX. ]==]--

--Despair Armor Set -- Nolan paths
gear.despairHeadPathA = hp_gear("Despair Helm", 88, {
    augments = { 'HP+50', 'VIT+10', 'Potency of "Cure" effect received +5%' }, })  --HP 50
gear.despairHeadPathB = hp_gear("Despair Helm", 38, {
    augments = { 'STR+12', 'VIT+7', 'Haste+2%' }, })
gear.despairHeadPathC = hp_gear("Despair Helm", 38, {
    augments = { 'Accuracy+10', 'Pet: VIT+7', 'Pet: Damage taken -3%' }, })  --Acc 10
gear.despairHeadPathD = hp_gear("Despair Helm", 38, {
    augments = { 'STR+15', 'Enmity+7', '"Store TP"+3' }, })  --STP 3, Enmity 7
gear.despairBodyPathA = hp_gear("Despair Mail", 171, {
    augments = { 'HP+50', 'VIT+10', 'Potency of "Cure" effect received +5%' }, })  --HP 50
gear.despairBodyPathB = hp_gear("Despair Mail", 121, {
    augments = { 'STR+12', 'VIT+7', 'Haste+2%' }, })
gear.despairBodyPathC = hp_gear("Despair Mail", 121, {
    augments = { 'Accuracy+10', 'Pet: VIT+7', 'Pet: Damage taken -3%' }, })  --Acc 10
gear.despairBodyPathD = hp_gear("Despair Mail", 121, {
    augments = { 'Attack+25', 'Mag. Evasion+20', '"Double Attack"+3%' }, })
gear.despairHandsPathA = hp_gear("Despair Fin. Gaunt.", 107, {
    augments = { 'HP+50', 'VIT+10', 'Potency of "Cure" effect received +5%' }, })  --HP 50
gear.despairHandsPathB = hp_gear("Despair Fin. Gaunt.", 57, {
    augments = { 'STR+12', 'VIT+7', 'Haste+2%' }, })
gear.despairHandsPathC = hp_gear("Despair Fin. Gaunt.", 57, {
    augments = { 'Accuracy+10', 'Pet: VIT+7', 'Pet: Damage taken -3%' }, })  --Acc 10
gear.despairHandsPathD = hp_gear("Despair Fin. Gaunt.", 57, {
    augments = { 'Ranged Acc.+25', 'Ranged Atk.+20', '"Recycle"+10' }, })
gear.despairLegsPathA = hp_gear("Despair Cuisses", 100, {
    augments = { 'HP+50', 'VIT+10', 'Potency of "Cure" effect received +5%' }, })  --HP 50
gear.despairLegsPathB = hp_gear("Despair Cuisses", 50, {
    augments = { 'STR+12', 'VIT+7', 'Haste+2%' }, })
gear.despairLegsPathC = hp_gear("Despair Cuisses", 50, {
    augments = { 'Accuracy+10', 'Pet: VIT+7', 'Pet: Damage taken -3%' }, })  --Acc 10
gear.despairLegsPathD = hp_gear("Despair Cuisses", 50, {
    augments = { 'AGI+10', 'Evasion+20', '"Subtle Blow"+7' }, })
gear.despairFeetPathA = hp_gear("Despair Greaves", 65, {
    augments = { 'HP+50', 'VIT+10', 'Potency of "Cure" effect received +5%' }, })  --HP 50
gear.despairFeetPathB = hp_gear("Despair Greaves", 15, {
    augments = { 'STR+12', 'VIT+7', 'Haste+2%' }, })
gear.despairFeetPathC = hp_gear("Despair Greaves", 15, {
    augments = { 'Accuracy+10', 'Pet: VIT+7', 'Pet: Damage taken -3%' }, })  --Acc 10
gear.despairFeetPathD = hp_gear("Despair Greaves", 15, {
    augments = { 'DEX+10', 'STR+7', 'Phys. dmg. taken -3%' }, })  --PDT 3

--Eschite Armor Set -- Nolan paths
gear.eschiteHeadPathA = hp_gear("Eschite Helm", 121, {
    augments = { 'HP+80', 'Enmity+7', 'Phys. dmg. taken -4%' }, })  --HP 80, PDT 4, Enmity 7
gear.eschiteHeadPathB = hp_gear("Eschite Helm", 41, {
    augments = { 'MP+80', 'Accuracy+10', 'Enmity+7' }, })  --MP 80, Enmity 7, Acc 10
gear.eschiteHeadPathC = hp_gear("Eschite Helm", 41, {
    augments = { 'Mag. Evasion+15', 'Spell interruption rate down +15%', 'Enmity+7' }, })  --Enmity 7
gear.eschiteHeadPathD = hp_gear("Eschite Helm", 41, {
    augments = { 'STR+9', 'VIT+7', '"Cure" potency +7%' }, })  --Cure Pot 7
gear.eschiteBodyPathA = hp_gear("Eschite Breast.", 233, {
    augments = { 'HP+80', 'Enmity+7', 'Phys. dmg. taken -4%' }, })  --HP 80, PDT 4, Enmity 7
gear.eschiteBodyPathB = hp_gear("Eschite Breast.", 153, {
    augments = { 'MP+80', 'Accuracy+10', 'Enmity+7' }, })  --MP 80, Enmity 7, Acc 10
gear.eschiteBodyPathC = hp_gear("Eschite Breast.", 153, {
    augments = { 'Mag. Evasion+15', 'Spell interruption rate down +15%', 'Enmity+7' }, })  --Enmity 7
gear.eschiteBodyPathD = hp_gear("Eschite Breast.", 153, {
    augments = { 'Attack+15', 'VIT+7', 'Damage taken -4%' }, })
gear.eschiteHandsPathA = hp_gear("Eschite Gauntlets", 109, {
    augments = { 'HP+80', 'Enmity+7', 'Phys. dmg. taken -4%' }, })  --HP 80, PDT 4, Enmity 7
gear.eschiteHandsPathB = hp_gear("Eschite Gauntlets", 29, {
    augments = { 'MP+80', 'Accuracy+10', 'Enmity+7' }, })  --MP 80, Enmity 7, Acc 10
gear.eschiteHandsPathC = hp_gear("Eschite Gauntlets", 29, {
    augments = { 'Mag. Evasion+15', 'Spell interruption rate down +15%', 'Enmity+7' }, })  --Enmity 7
gear.eschiteHandsPathD = hp_gear("Eschite Gauntlets", 29, {
    augments = { 'Accuracy+20', '"Double Attack"+4%', 'Enmity+7' }, })  --Enmity 7, Acc 20
gear.eschiteLegsPathA = hp_gear("Eschite Cuisses", 132, {
    augments = { 'HP+80', 'Enmity+7', 'Phys. dmg. taken -4%' }, })  --HP 80, PDT 4, Enmity 7
gear.eschiteLegsPathB = hp_gear("Eschite Cuisses", 52, {
    augments = { 'MP+80', 'Accuracy+10', 'Enmity+7' }, })  --MP 80, Enmity 7, Acc 10
gear.eschiteLegsPathC = hp_gear("Eschite Cuisses", 52, {
    augments = { 'Mag. Evasion+15', 'Spell interruption rate down +15%', 'Enmity+7' }, })  --Enmity 7
gear.eschiteLegsPathD = hp_gear("Eschite Cuisses", 52, {
    augments = { '"Mag.Atk.Bns."+25', '"Conserve MP"+6', '"Fast Cast"+5%' }, })  --FC 5, MAB 25
gear.eschiteFeetPathA = hp_gear("Eschite Greaves", 98, {
    augments = { 'HP+80', 'Enmity+7', 'Phys. dmg. taken -4%' }, })  --HP 80, PDT 4, Enmity 7
gear.eschiteFeetPathB = hp_gear("Eschite Greaves", 18, {
    augments = { 'MP+80', 'Accuracy+10', 'Enmity+7' }, })  --MP 80, Enmity 7, Acc 10
gear.eschiteFeetPathC = hp_gear("Eschite Greaves", 18, {
    augments = { 'Mag. Evasion+15', 'Spell interruption rate down +15%', 'Enmity+7' }, })  --Enmity 7
gear.eschiteFeetPathD = hp_gear("Eschite Greaves", 68, {
    augments = { 'STR+15', 'HP+50', '"Store TP"+5' }, })  --HP 50, STP 5

--Naga Garb Set -- Nolan paths
gear.nagaHeadPathA = hp_gear("Naga Somen", 86, {
    augments = { 'STR+10', 'Accuracy+15', '"Subtle Blow"+7' }, })  --Acc 15
gear.nagaHeadPathB = hp_gear("Naga Somen", 136, {
    augments = { 'HP+50', 'VIT+10', 'Evasion+20' }, })  --HP 50
gear.nagaHeadPathC = hp_gear("Naga Somen", 86, {
    augments = { 'Pet: MP+80', '"Cure" potency +4%', '"Fast Cast"+3%' }, })  --MP 80, FC 3, Cure Pot 4
gear.nagaHeadPathD = hp_gear("Naga Somen", 86, {
    augments = { 'Accuracy+15', 'Ranged Acc.+25', 'Enmity-6' }, })  --Enmity -6, Acc 15
gear.nagaBodyPathA = hp_gear("Naga Samue", 119, {
    augments = { 'STR+10', 'Accuracy+15', '"Subtle Blow"+7' }, })  --Acc 15
gear.nagaBodyPathB = hp_gear("Naga Samue", 169, {
    augments = { 'HP+50', 'VIT+10', 'Evasion+20' }, })  --HP 50
gear.nagaBodyPathC = hp_gear("Naga Samue", 119, {
    augments = { 'Pet: MP+80', '"Cure" potency +4%', '"Fast Cast"+3%' }, })  --MP 80, FC 3, Cure Pot 4
gear.nagaBodyPathD = hp_gear("Naga Samue", 199, {
    augments = { 'HP+80', 'DEX+10', 'Attack+20' }, })  --HP 80
gear.nagaHandsPathA = hp_gear("Naga Tekko", 65, {
    augments = { 'STR+10', 'Accuracy+15', '"Subtle Blow"+7' }, })  --Acc 15
gear.nagaHandsPathB = hp_gear("Naga Tekko", 115, {
    augments = { 'HP+50', 'VIT+10', 'Evasion+20' }, })  --HP 50
gear.nagaHandsPathC = hp_gear("Naga Tekko", 65, {
    augments = { 'Pet: MP+80', '"Cure" potency +4%', '"Fast Cast"+3%' }, })  --MP 80, FC 3, Cure Pot 4
gear.nagaHandsPathD = hp_gear("Naga Tekko", 65, {
    augments = { 'Pet: MP+80', 'Pet: "Mag.Atk.Bns."+20', 'Pet: Mag. Acc.+20' }, })  --MP 80, MAB 20, Macc 20
gear.nagaLegsPathA = hp_gear("Naga Hakama", 97, {
    augments = { 'STR+10', 'Accuracy+15', '"Subtle Blow"+7' }, })  --Acc 15
gear.nagaLegsPathB = hp_gear("Naga Hakama", 147, {
    augments = { 'HP+50', 'VIT+10', 'Evasion+20' }, })  --HP 50
gear.nagaLegsPathC = hp_gear("Naga Hakama", 97, {
    augments = { 'Pet: MP+80', '"Cure" potency +4%', '"Fast Cast"+3%' }, })  --MP 80, FC 3, Cure Pot 4
gear.nagaLegsPathD = hp_gear("Naga Hakama", 97, {
    augments = { 'Attack+20', 'Ranged Atk.+25', 'Critical hit rate +4%' }, })
gear.nagaFeetPathA = hp_gear("Naga Kyahan", 63, {
    augments = { 'STR+10', 'Accuracy+15', '"Subtle Blow"+7' }, })  --Acc 15
gear.nagaFeetPathB = hp_gear("Naga Kyahan", 113, {
    augments = { 'HP+50', 'VIT+10', 'Evasion+20' }, })  --HP 50
gear.nagaFeetPathC = hp_gear("Naga Kyahan", 63, {
    augments = { 'Pet: MP+80', '"Cure" potency +4%', '"Fast Cast"+3%' }, })  --MP 80, FC 3, Cure Pot 4
gear.nagaFeetPathD = hp_gear("Naga Kyahan", 163, {
    augments = { 'Pet: HP+100', 'Pet: Accuracy+25', 'Pet: Attack+25' }, })  --HP 100, Acc 25

--Psycloth Attire Set -- Nolan paths
gear.psyclothHeadPathA = hp_gear("Psycloth Tiara", 36, {
    augments = { 'MP+50', 'INT+7', '"Conserve MP"+6' }, })  --MP 50
gear.psyclothHeadPathB = hp_gear("Psycloth Tiara", 36, {
    augments = { 'Mag. Acc.+10', 'Spell interruption rate down +15%', 'MND+7' }, })  --Macc 10
gear.psyclothHeadPathC = hp_gear("Psycloth Tiara", 36, {
    augments = { 'Pet: Attack+25', 'Pet: "Mag.Atk.Bns."+15', 'Pet: Enmity+7' }, })  --MAB 15, Enmity 7
gear.psyclothHeadPathD = hp_gear("Psycloth Tiara", 36, {
    augments = { 'Mag. Acc.+20', '"Fast Cast"+10%', 'INT+7' }, })  --FC 10, Macc 20
gear.psyclothBodyPathA = hp_gear("Psycloth Vest", 54, {
    augments = { 'MP+50', 'INT+7', '"Conserve MP"+6' }, })  --MP 50
gear.psyclothBodyPathB = hp_gear("Psycloth Vest", 54, {
    augments = { 'Mag. Acc.+10', 'Spell interruption rate down +15%', 'MND+7' }, })  --Macc 10
gear.psyclothBodyPathC = hp_gear("Psycloth Vest", 54, {
    augments = { 'Pet: Attack+25', 'Pet: "Mag.Atk.Bns."+15', 'Pet: Enmity+7' }, })  --MAB 15, Enmity 7
gear.psyclothBodyPathD = hp_gear("Psycloth Vest", 54, {
    augments = { 'Elem. magic skill +20', 'INT+7', 'Enmity-6' }, })  --Enmity -6
gear.psyclothHandsPathA = hp_gear("Psycloth Manillas", 22, {
    augments = { 'MP+50', 'INT+7', '"Conserve MP"+6' }, })  --MP 50
gear.psyclothHandsPathB = hp_gear("Psycloth Manillas", 22, {
    augments = { 'Mag. Acc.+10', 'Spell interruption rate down +15%', 'MND+7' }, })  --Macc 10
gear.psyclothHandsPathC = hp_gear("Psycloth Manillas", 22, {
    augments = { 'Pet: Attack+25', 'Pet: "Mag.Atk.Bns."+15', 'Pet: Enmity+7' }, })  --MAB 15, Enmity 7
gear.psyclothHandsPathD = hp_gear("Psycloth Manillas", 22, {
    augments = { 'MP+80', '"Blood Boon"+4', 'Pet: "Mag.Atk.Bns."+25' }, })  --MP 80, MAB 25
gear.psyclothLegsPathA = hp_gear("Psycloth Lappas", 43, {
    augments = { 'MP+50', 'INT+7', '"Conserve MP"+6' }, })  --MP 50
gear.psyclothLegsPathB = hp_gear("Psycloth Lappas", 43, {
    augments = { 'Mag. Acc.+10', 'Spell interruption rate down +15%', 'MND+7' }, })  --Macc 10
gear.psyclothLegsPathC = hp_gear("Psycloth Lappas", 43, {
    augments = { 'Pet: Attack+25', 'Pet: "Mag.Atk.Bns."+15', 'Pet: Enmity+7' }, })  --MAB 15, Enmity 7
gear.psyclothLegsPathD = hp_gear("Psycloth Lappas", 43, {
    augments = { 'MP+80', 'Mag. Acc.+15', '"Fast Cast"+7%' }, })  --MP 80, FC 7, Macc 15
gear.psyclothFeetPathA = hp_gear("Psycloth Boots", 13, {
    augments = { 'MP+50', 'INT+7', '"Conserve MP"+6' }, })  --MP 50
gear.psyclothFeetPathB = hp_gear("Psycloth Boots", 13, {
    augments = { 'Mag. Acc.+10', 'Spell interruption rate down +15%', 'MND+7' }, })  --Macc 10
gear.psyclothFeetPathC = hp_gear("Psycloth Boots", 13, {
    augments = { 'Pet: Attack+25', 'Pet: "Mag.Atk.Bns."+15', 'Pet: Enmity+7' }, })  --MAB 15, Enmity 7
gear.psyclothFeetPathD = hp_gear("Psycloth Boots", 13, {
    augments = { 'Pet: Mag. Acc.+20', 'Pet: "Mag.Atk.Bns."+20', 'Pet: Enmity+7' }, })  --MAB 20, Enmity 7, Macc 20

--Pursuer's Attire Set -- Nolan paths
gear.pursuerHeadPathA = hp_gear("Pursuer's Beret", 36, {
    augments = { 'AGI+10', '"Rapid Shot"+10', '"Subtle Blow"+7' }, })  --Rapid Shot 10
gear.pursuerHeadPathB = hp_gear("Pursuer's Beret", 36, {
    augments = { 'DEX+7', 'AGI+10', '"Recycle"+15' }, })
gear.pursuerHeadPathC = hp_gear("Pursuer's Beret", 86, {
    augments = { 'HP+50', 'Accuracy+20', 'Attack+15' }, })  --HP 50, Acc 20
gear.pursuerHeadPathD = hp_gear("Pursuer's Beret", 36, {
    augments = { 'Ranged Atk.+15', 'Enmity-6', '"Subtle Blow"+7' }, })  --Enmity -6
gear.pursuerBodyPathA = hp_gear("Pursuer's Doublet", 109, {
    augments = { 'AGI+10', '"Rapid Shot"+10', '"Subtle Blow"+7' }, })  --Rapid Shot 10
gear.pursuerBodyPathB = hp_gear("Pursuer's Doublet", 109, {
    augments = { 'DEX+7', 'AGI+10', '"Recycle"+15' }, })
gear.pursuerBodyPathC = hp_gear("Pursuer's Doublet", 159, {
    augments = { 'HP+50', 'Accuracy+20', 'Attack+15' }, })  --HP 50, Acc 20
gear.pursuerBodyPathD = hp_gear("Pursuer's Doublet", 159, {
    augments = { 'HP+50', 'Critical hit rate +4%', '"Snapshot"+6' }, })  --HP 50, Snapshot 6
gear.pursuerHandsPathA = hp_gear("Pursuer's Cuffs", 25, {
    augments = { 'AGI+10', '"Rapid Shot"+10', '"Subtle Blow"+7' }, })  --Rapid Shot 10
gear.pursuerHandsPathB = hp_gear("Pursuer's Cuffs", 25, {
    augments = { 'DEX+7', 'AGI+10', '"Recycle"+15' }, })
gear.pursuerHandsPathC = hp_gear("Pursuer's Cuffs", 75, {
    augments = { 'HP+50', 'Accuracy+20', 'Attack+15' }, })  --HP 50, Acc 20
gear.pursuerHandsPathD = hp_gear("Pursuer's Cuffs", 25, {
    augments = { 'Ranged Atk.+15', 'STR+7', 'Phys. dmg. taken -4%' }, })  --PDT 4
gear.pursuerLegsPathA = hp_gear("Pursuer's Pants", 47, {
    augments = { 'AGI+10', '"Rapid Shot"+10', '"Subtle Blow"+7' }, })  --Rapid Shot 10
gear.pursuerLegsPathB = hp_gear("Pursuer's Pants", 47, {
    augments = { 'DEX+7', 'AGI+10', '"Recycle"+15' }, })
gear.pursuerLegsPathC = hp_gear("Pursuer's Pants", 97, {
    augments = { 'HP+50', 'Accuracy+20', 'Attack+15' }, })  --HP 50, Acc 20
gear.pursuerLegsPathD = hp_gear("Pursuer's Pants", 47, {
    augments = { 'DEX+7', 'AGI+10', 'STR+7' }, })
gear.pursuerFeetPathA = hp_gear("Pursuer's Gaiters", 13, {
    augments = { 'AGI+10', '"Rapid Shot"+10', '"Subtle Blow"+7' }, })  --Rapid Shot 10
gear.pursuerFeetPathB = hp_gear("Pursuer's Gaiters", 13, {
    augments = { 'DEX+7', 'AGI+10', '"Recycle"+15' }, })
gear.pursuerFeetPathC = hp_gear("Pursuer's Gaiters", 63, {
    augments = { 'HP+50', 'Accuracy+20', 'Attack+15' }, })  --HP 50, Acc 20

--Rawhide Armor Set -- Nolan paths
gear.rawhideHeadPathA = hp_gear("Rawhide Mask", 36, {
    augments = { 'DEX+10', 'STR+7', 'INT+7' }, })
gear.rawhideHeadPathB = hp_gear("Rawhide Mask", 86, {
    augments = { 'HP+50', 'Accuracy+15', 'Evasion+20' }, })  --HP 50, Acc 15
gear.rawhideHeadPathC = hp_gear("Rawhide Mask", 36, {
    augments = { 'Accuracy+15', 'Pet: Accuracy+15', 'Pet: "Dbl. Atk."+3' }, })  --Acc 15
gear.rawhideHeadPathD = hp_gear("Rawhide Mask", 36, {
    augments = { 'Attack+15', 'Pet: Mag. Acc.+20', 'Pet: "Mag.Atk.Bns."+15' }, })  --MAB 15, Macc 20
gear.rawhideBodyPathA = hp_gear("Rawhide Vest", 59, {
    augments = { 'DEX+10', 'STR+7', 'INT+7' }, })
gear.rawhideBodyPathB = hp_gear("Rawhide Vest", 109, {
    augments = { 'HP+50', 'Accuracy+15', 'Evasion+20' }, })  --HP 50, Acc 15
gear.rawhideBodyPathC = hp_gear("Rawhide Vest", 59, {
    augments = { 'Accuracy+15', 'Pet: Accuracy+15', 'Pet: "Dbl. Atk."+3' }, })  --Acc 15
gear.rawhideBodyPathD = hp_gear("Rawhide Vest", 109, {
    augments = { 'HP+50', '"Subtle Blow"+7', 'Triple Attack+2' }, })  --HP 50
gear.rawhideHandsPathA = hp_gear("Rawhide Gloves", 25, {
    augments = { 'DEX+10', 'STR+7', 'INT+7' }, })
gear.rawhideHandsPathB = hp_gear("Rawhide Gloves", 75, {
    augments = { 'HP+50', 'Accuracy+15', 'Evasion+20' }, })  --HP 50, Acc 15
gear.rawhideHandsPathC = hp_gear("Rawhide Gloves", 25, {
    augments = { 'Accuracy+15', 'Pet: Accuracy+15', 'Pet: "Dbl. Atk."+3' }, })  --Acc 15
gear.rawhideHandsPathD = hp_gear("Rawhide Gloves", 25, {
    augments = { 'Mag. Acc.+15', 'INT+7', 'MND+7' }, })  --Macc 15
gear.rawhideLegsPathA = hp_gear("Rawhide Trousers", 47, {
    augments = { 'DEX+10', 'STR+7', 'INT+7' }, })
gear.rawhideLegsPathB = hp_gear("Rawhide Trousers", 97, {
    augments = { 'HP+50', 'Accuracy+15', 'Evasion+20' }, })  --HP 50, Acc 15
gear.rawhideLegsPathC = hp_gear("Rawhide Trousers", 47, {
    augments = { 'Accuracy+15', 'Pet: Accuracy+15', 'Pet: "Dbl. Atk."+3' }, })  --Acc 15
gear.rawhideLegsPathD = hp_gear("Rawhide Trousers", 47, {
    augments = { 'MP+50', '"Fast Cast"+5%', 'Refresh+1' }, })  --MP 50, FC 5
gear.rawhideFeetPathA = hp_gear("Rawhide Boots", 13, {
    augments = { 'DEX+10', 'STR+7', 'INT+7' }, })
gear.rawhideFeetPathB = hp_gear("Rawhide Boots", 63, {
    augments = { 'HP+50', 'Accuracy+15', 'Evasion+20' }, })  --HP 50, Acc 15
gear.rawhideFeetPathC = hp_gear("Rawhide Boots", 13, {
    augments = { 'Accuracy+15', 'Pet: Accuracy+15', 'Pet: "Dbl. Atk."+3' }, })  --Acc 15
gear.rawhideFeetPathD = hp_gear("Rawhide Boots", 13, {
    augments = { 'STR+10', 'Attack+15', '"Store TP"+5' }, })  --STP 5

--Vanya Attire Set -- Nolan paths
gear.vanyaHeadPathA = hp_gear("Vanya Hood", 36, {
    augments = { 'MP+50', '"Cure" potency +7%', 'Enmity-6' }, })  --MP 50, Cure Pot 7, Enmity -6
gear.vanyaHeadPathC = hp_gear("Vanya Hood", 36, {
    augments = { 'MND+10', 'Spell interruption rate down +15%', '"Conserve MP"+6' }, })
gear.vanyaBodyPathC = hp_gear("Vanya Robe", 54, {
    augments = { 'MND+10', 'Spell interruption rate down +15%', '"Conserve MP"+6' }, })
gear.vanyaBodyPathD = hp_gear("Vanya Robe", 104, {
    augments = { 'HP+50', 'MP+50', 'Refresh+2' }, })  --HP 50, MP 50
gear.vanyaHandsPathC = hp_gear("Vanya Cuffs", 22, {
    augments = { 'MND+10', 'Spell interruption rate down +15%', '"Conserve MP"+6' }, })
gear.vanyaHandsPathD = hp_gear("Vanya Cuffs", 22, {
    augments = { 'CHR+10', 'String Skill+10', 'Mag. Acc.+20' }, })  --Macc 20
gear.vanyaLegsPathA = hp_gear("Vanya Slops", 43, {
    augments = { 'MP+50', '"Cure" potency +7%', 'Enmity-6' }, })  --MP 50, Cure Pot 7, Enmity -6
gear.vanyaLegsPathC = hp_gear("Vanya Slops", 43, {
    augments = { 'MND+10', 'Spell interruption rate down +15%', '"Conserve MP"+6' }, })
gear.vanyaLegsPathD = hp_gear("Vanya Slops", 93, {
    augments = { 'HP+50', 'Mag. Evasion+15', 'Phys. dmg. taken -3%' }, })  --HP 50, PDT 3
gear.vanyaFeetPathC = hp_gear("Vanya Clogs", 13, {
    augments = { 'MND+10', 'Spell interruption rate down +15%', '"Conserve MP"+6' }, })

--Adhemar Attire Set -- Nolan paths
gear.adhemarHeadPathA = hp_gear("Adhemar Bonnet", 41, {
    augments = { 'AGI+10', 'DEX+10', 'Accuracy+15' }, })  --Acc 15
gear.adhemarHeadPathB = hp_gear("Adhemar Bonnet", 41, {
    augments = { 'STR+10', 'DEX+10', 'Attack+15' }, })
gear.adhemarHeadPathC = hp_gear("Adhemar Bonnet", 41, {
    augments = { 'AGI+10', 'Ranged Acc.+15', 'Ranged Atk.+15' }, })
gear.adhemarHeadPathD = hp_gear("Adhemar Bonnet", 121, {
    augments = { 'HP+80', 'Attack+10', 'Phys. dmg. taken -3%' }, })  --HP 80, PDT 3
gear.adhemarBodyPathA = hp_gear("Adhemar Jacket", 63, {
    augments = { 'AGI+10', 'DEX+10', 'Accuracy+15' }, })  --Acc 15
gear.adhemarBodyPathB = hp_gear("Adhemar Jacket", 63, {
    augments = { 'STR+10', 'DEX+10', 'Attack+15' }, })
gear.adhemarBodyPathC = hp_gear("Adhemar Jacket", 63, {
    augments = { 'AGI+10', 'Ranged Acc.+15', 'Ranged Atk.+15' }, })
gear.adhemarBodyPathD = hp_gear("Adhemar Jacket", 143, {
    augments = { 'HP+80', '"Fast Cast"+7%', 'Magic dmg. taken -3%' }, })  --HP 80, FC 7
gear.adhemarHandsPathA = hp_gear("Adhemar Wristbands", 22, {
    augments = { 'AGI+10', 'DEX+10', 'Accuracy+15' }, })  --Acc 15
gear.adhemarHandsPathB = hp_gear("Adhemar Wristbands", 22, {
    augments = { 'STR+10', 'DEX+10', 'Attack+15' }, })
gear.adhemarHandsPathC = hp_gear("Adhemar Wristbands", 22, {
    augments = { 'AGI+10', 'Ranged Acc.+15', 'Ranged Atk.+15' }, })
gear.adhemarHandsPathD = hp_gear("Adhemar Wristbands", 22, {
    augments = { 'Accuracy+15', 'Attack+15', '"Subtle Blow"+7' }, })  --Acc 15
gear.adhemarLegsPathA = hp_gear("Adhemar Kecks", 41, {
    augments = { 'AGI+10', 'DEX+10', 'Accuracy+15' }, })  --Acc 15
gear.adhemarLegsPathB = hp_gear("Adhemar Kecks", 41, {
    augments = { 'STR+10', 'DEX+10', 'Attack+15' }, })
gear.adhemarLegsPathC = hp_gear("Adhemar Kecks", 41, {
    augments = { 'AGI+10', 'Ranged Acc.+15', 'Ranged Atk.+15' }, })
gear.adhemarLegsPathD = hp_gear("Adhemar Kecks", 41, {
    augments = { 'AGI+10', '"Rapid Shot"+10', 'Enmity-5' }, })  --Rapid Shot 10, Enmity -5
gear.adhemarFeetPathA = hp_gear("Adhemar Gamashes", 11, {
    augments = { 'AGI+10', 'DEX+10', 'Accuracy+15' }, })  --Acc 15
gear.adhemarFeetPathB = hp_gear("Adhemar Gamashes", 11, {
    augments = { 'STR+10', 'DEX+10', 'Attack+15' }, })
gear.adhemarFeetPathC = hp_gear("Adhemar Gamashes", 11, {
    augments = { 'AGI+10', 'Ranged Acc.+15', 'Ranged Atk.+15' }, })
gear.adhemarFeetPathD = hp_gear("Adhemar Gamashes", 61, {
    augments = { 'HP+50', '"Store TP"+6', '"Snapshot"+8' }, })  --HP 50, STP 6, Snapshot 8

--Amalric Attire Set -- Nolan paths
gear.amalricHeadPathA = hp_gear("Amalric Coif", 27, {
    augments = { 'MP+60', 'Mag. Acc.+15', '"Mag.Atk.Bns."+15' }, })  --MP 60, MAB 15, Macc 15
gear.amalricHeadPathB = hp_gear("Amalric Coif", 27, {
    augments = { 'MP+60', 'INT+10', 'Enmity-5' }, })  --MP 60, Enmity -5
gear.amalricHeadPathC = hp_gear("Amalric Coif", 27, {
    augments = { 'INT+10', 'Elem. magic skill +15', 'Dark magic skill +15' }, })
gear.amalricHeadPathD = hp_gear("Amalric Coif", 27, {
    augments = { 'INT+10', 'Mag. Acc.+20', 'Enmity-5' }, })  --Enmity -5, Macc 20
gear.amalricBodyPathA = hp_gear("Amalric Doublet", 45, {
    augments = { 'MP+60', 'Mag. Acc.+15', '"Mag.Atk.Bns."+15' }, })  --MP 60, MAB 15, Macc 15
gear.amalricBodyPathB = hp_gear("Amalric Doublet", 45, {
    augments = { 'MP+60', 'INT+10', 'Enmity-5' }, })  --MP 60, Enmity -5
gear.amalricBodyPathC = hp_gear("Amalric Doublet", 45, {
    augments = { 'INT+10', 'Elem. magic skill +15', 'Dark magic skill +15' }, })
gear.amalricBodyPathD = hp_gear("Amalric Doublet", 45, {
    augments = { 'MP+60', '"Mag.Atk.Bns."+20', '"Fast Cast"+3%' }, })  --MP 60, FC 3, MAB 20
gear.amalricHandsPathA = hp_gear("Amalric Gages", 13, {
    augments = { 'MP+60', 'Mag. Acc.+15', '"Mag.Atk.Bns."+15' }, })  --MP 60, MAB 15, Macc 15
gear.amalricHandsPathB = hp_gear("Amalric Gages", 13, {
    augments = { 'MP+60', 'INT+10', 'Enmity-5' }, })  --MP 60, Enmity -5
gear.amalricHandsPathC = hp_gear("Amalric Gages", 13, {
    augments = { 'INT+10', 'Elem. magic skill +15', 'Dark magic skill +15' }, })
gear.amalricLegsPathA = hp_gear("Amalric Slops", 34, {
    augments = { 'MP+60', 'Mag. Acc.+15', '"Mag.Atk.Bns."+15' }, })  --MP 60, MAB 15, Macc 15
gear.amalricLegsPathB = hp_gear("Amalric Slops", 34, {
    augments = { 'MP+60', 'INT+10', 'Enmity-5' }, })  --MP 60, Enmity -5
gear.amalricLegsPathC = hp_gear("Amalric Slops", 34, {
    augments = { 'INT+10', 'Elem. magic skill +15', 'Dark magic skill +15' }, })
gear.amalricLegsPathD = hp_gear("Amalric Slops", 34, {
    augments = { 'MP+60', '"Mag.Atk.Bns."+20', 'Enmity-5' }, })  --MP 60, MAB 20, Enmity -5
gear.amalricFeetPathA = hp_gear("Amalric Nails", 4, {
    augments = { 'MP+60', 'Mag. Acc.+15', '"Mag.Atk.Bns."+15' }, })  --MP 60, MAB 15, Macc 15
gear.amalricFeetPathB = hp_gear("Amalric Nails", 4, {
    augments = { 'MP+60', 'INT+10', 'Enmity-5' }, })  --MP 60, Enmity -5
gear.amalricFeetPathC = hp_gear("Amalric Nails", 4, {
    augments = { 'INT+10', 'Elem. magic skill +15', 'Dark magic skill +15' }, })
gear.amalricFeetPathD = hp_gear("Amalric Nails", 4, {
    augments = { 'Mag. Acc.+15', '"Mag.Atk.Bns."+15', '"Conserve MP"+6' }, })  --MAB 15, Macc 15

--Apogee Attire Set -- Nolan paths
gear.apogeeHeadPathA = hp_gear("Apogee Crown", -100, {
    augments = { 'MP+60', 'Pet: "Mag.Atk.Bns."+30', 'Blood Pact Dmg.+7' }, })  --MP 60, MAB 30, BP Dmg 7
gear.apogeeHeadPathB = hp_gear("Apogee Crown", -100, {
    augments = { 'MP+60', 'Pet: Attack+30', 'Blood Pact Dmg.+7' }, })  --MP 60, BP Dmg 7
gear.apogeeHeadPathC = hp_gear("Apogee Crown", -100, {
    augments = { 'Pet: Attack+20', 'Pet: "Mag.Atk.Bns."+20', 'Blood Pact Dmg.+7' }, })  --MAB 20, BP Dmg 7
gear.apogeeHeadPathD = hp_gear("Apogee Crown", -100, {
    augments = { 'Pet: Accuracy+20', 'Avatar perpetuation cost -5', 'Pet: Damage taken -3%' }, })  --Acc 20
gear.apogeeBodyPathA = hp_gear("Apogee Dalmatica", -150, {
    augments = { 'MP+60', 'Pet: "Mag.Atk.Bns."+30', 'Blood Pact Dmg.+7' }, })  --MP 60, MAB 30, BP Dmg 7
gear.apogeeBodyPathB = hp_gear("Apogee Dalmatica", -150, {
    augments = { 'MP+60', 'Pet: Attack+30', 'Blood Pact Dmg.+7' }, })  --MP 60, BP Dmg 7
gear.apogeeBodyPathC = hp_gear("Apogee Dalmatica", -150, {
    augments = { 'Pet: Attack+20', 'Pet: "Mag.Atk.Bns."+20', 'Blood Pact Dmg.+7' }, })  --MAB 20, BP Dmg 7
gear.apogeeBodyPathD = hp_gear("Apogee Dalmatica", -150, {
    augments = { 'Summoning magic skill +15', 'Enmity-5', 'Pet: Damage taken -3%' }, })  --Enmity -5
gear.apogeeHandsPathA = hp_gear("Apogee Mitts", -80, {
    augments = { 'MP+60', 'Pet: "Mag.Atk.Bns."+30', 'Blood Pact Dmg.+7' }, })  --MP 60, MAB 30, BP Dmg 7
gear.apogeeHandsPathB = hp_gear("Apogee Mitts", -80, {
    augments = { 'MP+60', 'Pet: Attack+30', 'Blood Pact Dmg.+7' }, })  --MP 60, BP Dmg 7
gear.apogeeHandsPathC = hp_gear("Apogee Mitts", -80, {
    augments = { 'Pet: Attack+20', 'Pet: "Mag.Atk.Bns."+20', 'Blood Pact Dmg.+7' }, })  --MAB 20, BP Dmg 7
gear.apogeeHandsPathD = hp_gear("Apogee Mitts", -80, {
    augments = { 'Pet: Mag. Acc.+20', 'Blood Pact ab. del. -5', 'Blood Pact Dmg.+7' }, })  --BP Dmg 7, Macc 20
gear.apogeeLegsPathA = hp_gear("Apogee Slacks", -100, {
    augments = { 'MP+60', 'Pet: "Mag.Atk.Bns."+30', 'Blood Pact Dmg.+7' }, })  --MP 60, MAB 30, BP Dmg 7
gear.apogeeLegsPathB = hp_gear("Apogee Slacks", -100, {
    augments = { 'MP+60', 'Pet: Attack+30', 'Blood Pact Dmg.+7' }, })  --MP 60, BP Dmg 7
gear.apogeeLegsPathC = hp_gear("Apogee Slacks", -100, {
    augments = { 'Pet: Attack+20', 'Pet: "Mag.Atk.Bns."+20', 'Blood Pact Dmg.+7' }, })  --MAB 20, BP Dmg 7
gear.apogeeLegsPathD = hp_gear("Apogee Slacks", -100, {
    augments = { 'Pet: STR+15', 'Blood Pact Dmg.+13', 'Pet: "Dbl. Atk."+3' }, })  --BP Dmg 13
gear.apogeeFeetPathA = hp_gear("Apogee Pumps", -80, {
    augments = { 'MP+60', 'Pet: "Mag.Atk.Bns."+30', 'Blood Pact Dmg.+7' }, })  --MP 60, MAB 30, BP Dmg 7
gear.apogeeFeetPathB = hp_gear("Apogee Pumps", -80, {
    augments = { 'MP+60', 'Pet: Attack+30', 'Blood Pact Dmg.+7' }, })  --MP 60, BP Dmg 7
gear.apogeeFeetPathC = hp_gear("Apogee Pumps", -80, {
    augments = { 'Pet: Attack+20', 'Pet: "Mag.Atk.Bns."+20', 'Blood Pact Dmg.+7' }, })  --MAB 20, BP Dmg 7
gear.apogeeFeetPathD = hp_gear("Apogee Pumps", -80, {
    augments = { 'MP+70', 'Summoning magic skill +15', 'Blood Pact Dmg.+7' }, })  --MP 70, BP Dmg 7

--Argosy Armor Set -- Nolan paths
gear.argosyHeadPathA = hp_gear("Argosy Celata", 50, {
    augments = { 'STR+10', 'DEX+10', 'Attack+15' }, })
gear.argosyHeadPathB = hp_gear("Argosy Celata", 100, {
    augments = { 'HP+50', 'Accuracy+10', 'Attack+15' }, })  --HP 50, Acc 10
gear.argosyHeadPathC = hp_gear("Argosy Celata", 100, {
    augments = { 'HP+50', 'STR+12', 'Phys. dmg. taken -3%' }, })  --HP 50, PDT 3
gear.argosyHeadPathD = hp_gear("Argosy Celata", 50, {
    augments = { 'DEX+10', 'Accuracy+15', '"Double Attack"+2%' }, })  --Acc 15
gear.argosyBodyPathA = hp_gear("Argosy Hauberk", 68, {
    augments = { 'STR+10', 'DEX+10', 'Attack+15' }, })
gear.argosyBodyPathB = hp_gear("Argosy Hauberk", 118, {
    augments = { 'HP+50', 'Accuracy+10', 'Attack+15' }, })  --HP 50, Acc 10
gear.argosyBodyPathC = hp_gear("Argosy Hauberk", 118, {
    augments = { 'HP+50', 'STR+12', 'Phys. dmg. taken -3%' }, })  --HP 50, PDT 3
gear.argosyBodyPathD = hp_gear("Argosy Hauberk", 68, {
    augments = { 'STR+10', 'Attack+15', '"Store TP"+5' }, })  --STP 5
gear.argosyHandsPathA = hp_gear("Argosy Mufflers", 34, {
    augments = { 'STR+10', 'DEX+10', 'Attack+15' }, })
gear.argosyHandsPathB = hp_gear("Argosy Mufflers", 84, {
    augments = { 'HP+50', 'Accuracy+10', 'Attack+15' }, })  --HP 50, Acc 10
gear.argosyHandsPathC = hp_gear("Argosy Mufflers", 84, {
    augments = { 'HP+50', 'STR+12', 'Phys. dmg. taken -3%' }, })  --HP 50, PDT 3
gear.argosyHandsPathD = hp_gear("Argosy Mufflers", 34, {
    augments = { 'STR+15', '"Double Attack"+2%', 'Haste+2%' }, })
gear.argosyLegsPathA = hp_gear("Argosy Breeches", 57, {
    augments = { 'STR+10', 'DEX+10', 'Attack+15' }, })
gear.argosyLegsPathB = hp_gear("Argosy Breeches", 107, {
    augments = { 'HP+50', 'Accuracy+10', 'Attack+15' }, })  --HP 50, Acc 10
gear.argosyLegsPathC = hp_gear("Argosy Breeches", 107, {
    augments = { 'HP+50', 'STR+12', 'Phys. dmg. taken -3%' }, })  --HP 50, PDT 3
gear.argosyLegsPathD = hp_gear("Argosy Breeches", 57, {
    augments = { 'STR+10', 'Attack+20', '"Store TP"+5' }, })  --STP 5
gear.argosyFeetPathA = hp_gear("Argosy Sollerets", 22, {
    augments = { 'STR+10', 'DEX+10', 'Attack+15' }, })
gear.argosyFeetPathB = hp_gear("Argosy Sollerets", 72, {
    augments = { 'HP+50', 'Accuracy+10', 'Attack+15' }, })  --HP 50, Acc 10
gear.argosyFeetPathC = hp_gear("Argosy Sollerets", 72, {
    augments = { 'HP+50', 'STR+12', 'Phys. dmg. taken -3%' }, })  --HP 50, PDT 3
gear.argosyFeetPathD = hp_gear("Argosy Sollerets", 82, {
    augments = { 'HP+60', '"Double Attack"+2%', '"Store TP"+3' }, })  --HP 60, STP 3

--Carmine Armor Set -- Nolan paths
gear.carmineHeadPathA = hp_gear("Carmine Mask", 98, {
    augments = { 'HP+60', 'STR+10', 'INT+10' }, })  --HP 60
gear.carmineHeadPathB = hp_gear("Carmine Mask", 38, {
    augments = { 'Accuracy+10', 'DEX+10', 'MND+15' }, })  --Acc 10
gear.carmineHeadPathC = hp_gear("Carmine Mask", 38, {
    augments = { 'MP+60', 'INT+10', 'MND+10' }, })  --MP 60
gear.carmineHeadPathD = hp_gear("Carmine Mask", 38, {
    augments = { 'Accuracy+15', 'Mag. Acc.+10', '"Fast Cast"+3%' }, })  --FC 3, Macc 10, Acc 15
gear.carmineBodyPathA = hp_gear("Carm. Scale Mail", 151, {
    augments = { 'HP+60', 'STR+10', 'INT+10' }, })  --HP 60
gear.carmineBodyPathB = hp_gear("Carm. Scale Mail", 91, {
    augments = { 'Accuracy+10', 'DEX+10', 'MND+15' }, })  --Acc 10
gear.carmineBodyPathC = hp_gear("Carm. Scale Mail", 91, {
    augments = { 'MP+60', 'INT+10', 'MND+10' }, })  --MP 60
gear.carmineBodyPathD = hp_gear("Carm. Scale Mail", 91, {
    augments = { 'Attack+15', '"Mag.Atk.Bns."+10', '"Double Attack"+2%' }, })  --MAB 10
gear.carmineHandsPathA = hp_gear("Carmine Fin. Ga.", 87, {
    augments = { 'HP+60', 'STR+10', 'INT+10' }, })  --HP 60
gear.carmineHandsPathB = hp_gear("Carmine Fin. Ga.", 27, {
    augments = { 'Accuracy+10', 'DEX+10', 'MND+15' }, })  --Acc 10
gear.carmineHandsPathC = hp_gear("Carmine Fin. Ga.", 27, {
    augments = { 'MP+60', 'INT+10', 'MND+10' }, })  --MP 60
gear.carmineHandsPathD = hp_gear("Carmine Fin. Ga.", 27, {
    augments = { 'Ranged Atk.+15', '"Mag.Atk.Bns."+10', '"Store TP"+5' }, })  --STP 5, MAB 10
gear.carmineLegsPathA = hp_gear("Carmine Cuisses", 110, {
    augments = { 'HP+60', 'STR+10', 'INT+10' }, })  --HP 60
gear.carmineLegsPathB = hp_gear("Carmine Cuisses", 50, {
    augments = { 'Accuracy+10', 'DEX+10', 'MND+15' }, })  --Acc 10
gear.carmineLegsPathC = hp_gear("Carmine Cuisses", 50, {
    augments = { 'MP+60', 'INT+10', 'MND+10' }, })  --MP 60
gear.carmineLegsPathD = hp_gear("Carmine Cuisses", 50, {
    augments = { 'Accuracy+15', 'Attack+10', '"Dual Wield"+5' }, })  --DW 5, Acc 15
gear.carmineFeetPathA = hp_gear("Carmine Greaves", 75, {
    augments = { 'HP+60', 'STR+10', 'INT+10' }, })  --HP 60
gear.carmineFeetPathB = hp_gear("Carmine Greaves", 15, {
    augments = { 'Accuracy+10', 'DEX+10', 'MND+15' }, })  --Acc 10
gear.carmineFeetPathC = hp_gear("Carmine Greaves", 15, {
    augments = { 'MP+60', 'INT+10', 'MND+10' }, })  --MP 60
gear.carmineFeetPathD = hp_gear("Carmine Greaves", 75, {
    augments = { 'HP+60', 'MP+60', 'Phys. dmg. taken -3%' }, })  --HP 60, MP 60, PDT 3

--Emicho Armor Set -- Nolan paths
gear.emichoHeadPathA = hp_gear("Emicho Coronet", 95, {
    augments = { 'HP+50', 'STR+10', 'Attack+15' }, })  --HP 50
gear.emichoHeadPathB = hp_gear("Emicho Coronet", 95, {
    augments = { 'HP+50', 'DEX+10', 'Accuracy+15' }, })  --HP 50, Acc 15
gear.emichoHeadPathC = hp_gear("Emicho Coronet", 45, {
    augments = { 'Pet: Accuracy+15', 'Pet: Attack+15', 'Pet: "Dbl. Atk."+3' }, })  --Acc 15
gear.emichoHeadPathD = hp_gear("Emicho Coronet", 45, {
    augments = { 'Attack+20', '"Store TP"+6', 'Pet: STR+15' }, })  --STP 6
gear.emichoBodyPathA = hp_gear("Emicho Haubert", 113, {
    augments = { 'HP+50', 'STR+10', 'Attack+15' }, })  --HP 50
gear.emichoBodyPathB = hp_gear("Emicho Haubert", 113, {
    augments = { 'HP+50', 'DEX+10', 'Accuracy+15' }, })  --HP 50, Acc 15
gear.emichoBodyPathC = hp_gear("Emicho Haubert", 63, {
    augments = { 'Pet: Accuracy+15', 'Pet: Attack+15', 'Pet: "Dbl. Atk."+3' }, })  --Acc 15
gear.emichoBodyPathD = hp_gear("Emicho Haubert", 163, {
    augments = { 'Pet: HP+100', 'Pet: INT+15', 'Pet: "Regen"+2' }, })  --HP 100, Regen 2
gear.emichoHandsPathA = hp_gear("Emicho Gauntlets", 84, {
    augments = { 'HP+50', 'STR+10', 'Attack+15' }, })  --HP 50
gear.emichoHandsPathB = hp_gear("Emicho Gauntlets", 84, {
    augments = { 'HP+50', 'DEX+10', 'Accuracy+15' }, })  --HP 50, Acc 15
gear.emichoHandsPathC = hp_gear("Emicho Gauntlets", 34, {
    augments = { 'Pet: Accuracy+15', 'Pet: Attack+15', 'Pet: "Dbl. Atk."+3' }, })  --Acc 15
gear.emichoHandsPathD = hp_gear("Emicho Gauntlets", 34, {
    augments = { 'Accuracy+20', '"Dual Wield"+5', 'Pet: Accuracy+20' }, })  --DW 5, Acc 20
gear.emichoLegsPathA = hp_gear("Emicho Hose", 100, {
    augments = { 'HP+50', 'STR+10', 'Attack+15' }, })  --HP 50
gear.emichoLegsPathB = hp_gear("Emicho Hose", 100, {
    augments = { 'HP+50', 'DEX+10', 'Accuracy+15' }, })  --HP 50, Acc 15
gear.emichoLegsPathC = hp_gear("Emicho Hose", 50, {
    augments = { 'Pet: Accuracy+15', 'Pet: Attack+15', 'Pet: "Dbl. Atk."+3' }, })  --Acc 15
gear.emichoLegsPathD = hp_gear("Emicho Hose", 50, {
    augments = { 'STR+10', 'Accuracy+20', 'Attack+20' }, })  --Acc 20
gear.emichoFeetPathA = hp_gear("Emicho Gambieras", 72, {
    augments = { 'HP+50', 'STR+10', 'Attack+15' }, })  --HP 50
gear.emichoFeetPathB = hp_gear("Emicho Gambieras", 72, {
    augments = { 'HP+50', 'DEX+10', 'Accuracy+15' }, })  --HP 50, Acc 15
gear.emichoFeetPathC = hp_gear("Emicho Gambieras", 22, {
    augments = { 'Pet: Accuracy+15', 'Pet: Attack+15', 'Pet: "Dbl. Atk."+3' }, })  --Acc 15
gear.emichoFeetPathD = hp_gear("Emicho Gambieras", 22, {
    augments = { 'Attack+20', '"Subtle Blow"+4', 'Pet: Attack+25' }, })

--Kaykaus Attire Set -- Nolan paths
gear.kaykausHeadPathA = hp_gear("Kaykaus Mitra", 34, {
    augments = { 'MP+60', 'MND+10', 'Mag. Acc.+15' }, })  --MP 60, Macc 15
gear.kaykausHeadPathB = hp_gear("Kaykaus Mitra", 34, {
    augments = { 'MP+60', '"Cure" spellcasting time -5%', 'Enmity-5' }, })  --MP 60, Enmity -5
gear.kaykausHeadPathC = hp_gear("Kaykaus Mitra", 34, {
    augments = { 'MP+60', 'Spell interruption rate down +10%', '"Cure" spellcasting time -5%' }, })  --MP 60
gear.kaykausHeadPathD = hp_gear("Kaykaus Mitra", 34, {
    augments = { 'MND+10', 'Mag. Acc.+15', '"Mag.Atk.Bns."+15' }, })  --MAB 15, Macc 15
gear.kaykausBodyPathA = hp_gear("Kaykaus Bliaut", 52, {
    augments = { 'MP+60', 'MND+10', 'Mag. Acc.+15' }, })  --MP 60, Macc 15
gear.kaykausBodyPathB = hp_gear("Kaykaus Bliaut", 52, {
    augments = { 'MP+60', '"Cure" spellcasting time -5%', 'Enmity-5' }, })  --MP 60, Enmity -5
gear.kaykausBodyPathC = hp_gear("Kaykaus Bliaut", 52, {
    augments = { 'MP+60', 'Spell interruption rate down +10%', '"Cure" spellcasting time -5%' }, })  --MP 60
gear.kaykausBodyPathD = hp_gear("Kaykaus Bliaut", 52, {
    augments = { 'MP+60', '"Cure" potency +5%', '"Conserve MP"+6' }, })  --MP 60, Cure Pot 5
gear.kaykausHandsPathA = hp_gear("Kaykaus Cuffs", 20, {
    augments = { 'MP+60', 'MND+10', 'Mag. Acc.+15' }, })  --MP 60, Macc 15
gear.kaykausHandsPathB = hp_gear("Kaykaus Cuffs", 20, {
    augments = { 'MP+60', '"Cure" spellcasting time -5%', 'Enmity-5' }, })  --MP 60, Enmity -5
gear.kaykausHandsPathC = hp_gear("Kaykaus Cuffs", 20, {
    augments = { 'MP+60', 'Spell interruption rate down +10%', '"Cure" spellcasting time -5%' }, })  --MP 60
gear.kaykausHandsPathD = hp_gear("Kaykaus Cuffs", 20, {
    augments = { 'MP+60', '"Conserve MP"+6', '"Fast Cast"+3%' }, })  --MP 60, FC 3
gear.kaykausLegsPathA = hp_gear("Kaykaus Tights", 41, {
    augments = { 'MP+60', 'MND+10', 'Mag. Acc.+15' }, })  --MP 60, Macc 15
gear.kaykausLegsPathB = hp_gear("Kaykaus Tights", 41, {
    augments = { 'MP+60', '"Cure" spellcasting time -5%', 'Enmity-5' }, })  --MP 60, Enmity -5
gear.kaykausLegsPathC = hp_gear("Kaykaus Tights", 41, {
    augments = { 'MP+60', 'Spell interruption rate down +10%', '"Cure" spellcasting time -5%' }, })  --MP 60
gear.kaykausLegsPathD = hp_gear("Kaykaus Tights", 41, {
    augments = { 'INT+10', '"Mag.Atk.Bns."+15', 'Enmity-5' }, })  --MAB 15, Enmity -5
gear.kaykausFeetPathA = hp_gear("Kaykaus Boots", 11, {
    augments = { 'MP+60', 'MND+10', 'Mag. Acc.+15' }, })  --MP 60, Macc 15
gear.kaykausFeetPathC = hp_gear("Kaykaus Boots", 11, {
    augments = { 'MP+60', 'Spell interruption rate down +10%', '"Cure" spellcasting time -5%' }, })  --MP 60
gear.kaykausFeetPathD = hp_gear("Kaykaus Boots", 11, {
    augments = { 'Mag. Acc.+15', '"Cure" potency +5%', '"Fast Cast"+3%' }, })  --FC 3, Cure Pot 5, Macc 15

--Lustratio Armor Set -- Nolan paths
gear.lustratioHeadPathA = hp_gear("Lustratio Cap", 22, {
    augments = { 'Attack+15', 'STR+5', '"Double Attack"+2%' }, })
gear.lustratioHeadPathB = hp_gear("Lustratio Cap", 22, {
    augments = { 'Accuracy+15', 'DEX+5', 'Critical hit rate +2%' }, })  --Acc 15
gear.lustratioHeadPathC = hp_gear("Lustratio Cap", 22, {
    augments = { 'Accuracy+8', '"Store TP"+4', 'Attack+8' }, })  --STP 4, Acc 8
gear.lustratioHeadPathD = hp_gear("Lustratio Cap", 22, {
    augments = { 'INT+30', 'STR+5', 'DEX+5' }, })
gear.lustratioBodyPathA = hp_gear("Lustratio Harness", 34, {
    augments = { 'Attack+15', 'STR+5', '"Double Attack"+2%' }, })
gear.lustratioBodyPathB = hp_gear("Lustratio Harness", 34, {
    augments = { 'Accuracy+15', 'DEX+5', 'Critical hit rate +2%' }, })  --Acc 15
gear.lustratioBodyPathC = hp_gear("Lustratio Harness", 34, {
    augments = { 'Accuracy+8', '"Store TP"+4', 'Attack+8' }, })  --STP 4, Acc 8
gear.lustratioBodyPathD = hp_gear("Lustratio Harness", 34, {
    augments = { 'Accuracy+8', 'Attack+10', '"Double Attack"+2%' }, })  --Acc 8
gear.lustratioHandsPathA = hp_gear("Lustratio Mittens", 15, {
    augments = { 'Attack+15', 'STR+5', '"Double Attack"+2%' }, })
gear.lustratioHandsPathB = hp_gear("Lustratio Mittens", 15, {
    augments = { 'Accuracy+15', 'DEX+5', 'Critical hit rate +2%' }, })  --Acc 15
gear.lustratioHandsPathC = hp_gear("Lustratio Mittens", 15, {
    augments = { 'Accuracy+8', '"Store TP"+4', 'Attack+8' }, })  --STP 4, Acc 8
gear.lustratioHandsPathD = hp_gear("Lustratio Mittens", 15, {
    augments = { 'Accuracy+25', 'VIT+10', 'DEX+7' }, })  --Acc 25
gear.lustratioLegsPathA = hp_gear("Lustratio Subligar", 27, {
    augments = { 'Attack+15', 'STR+5', '"Double Attack"+2%' }, })
gear.lustratioLegsPathB = hp_gear("Lustratio Subligar", 27, {
    augments = { 'Accuracy+15', 'DEX+5', 'Critical hit rate +2%' }, })  --Acc 15
gear.lustratioLegsPathC = hp_gear("Lustratio Subligar", 27, {
    augments = { 'Accuracy+8', '"Store TP"+4', 'Attack+8' }, })  --STP 4, Acc 8
gear.lustratioLegsPathD = hp_gear("Lustratio Subligar", 77, {
    augments = { 'HP+50', 'Attack+25', 'Enmity-5' }, })  --HP 50, Enmity -5
gear.lustratioFeetPathA = hp_gear("Lustratio Leggings", 11, {
    augments = { 'Attack+15', 'STR+5', '"Double Attack"+2%' }, })
gear.lustratioFeetPathB = hp_gear("Lustratio Leggings", 11, {
    augments = { 'Accuracy+15', 'DEX+5', 'Critical hit rate +2%' }, })  --Acc 15
gear.lustratioFeetPathC = hp_gear("Lustratio Leggings", 11, {
    augments = { 'Accuracy+8', '"Store TP"+4', 'Attack+8' }, })  --STP 4, Acc 8
gear.lustratioFeetPathD = hp_gear("Lustratio Leggings", 61, {
    augments = { 'HP+50', 'STR+10', 'DEX+10' }, })  --HP 50

--Rao Armor Set -- Nolan paths
gear.raoHeadPathA = hp_gear("Rao Kabuto", 0, {
    augments = { 'Accuracy+10', 'Attack+10', 'Evasion+15' }, })  --Acc 10
gear.raoHeadPathB = hp_gear("Rao Kabuto", 0, {
    augments = { 'STR+10', 'DEX+10', 'Attack+15' }, })
gear.raoHeadPathC = hp_gear("Rao Kabuto", 100, {
    augments = { 'Pet: HP+100', 'Pet: Accuracy+15', 'Pet: Damage taken -3%' }, })  --HP 100, Acc 15
gear.raoHeadPathD = hp_gear("Rao Kabuto", 0, {
    augments = { 'VIT+10', 'Attack+20', 'Counter+3' }, })
gear.raoBodyPathA = hp_gear("Rao Togi", 0, {
    augments = { 'Accuracy+10', 'Attack+10', 'Evasion+15' }, })  --Acc 10
gear.raoBodyPathB = hp_gear("Rao Togi", 0, {
    augments = { 'STR+10', 'DEX+10', 'Attack+15' }, })
gear.raoBodyPathC = hp_gear("Rao Togi", 100, {
    augments = { 'Pet: HP+100', 'Pet: Accuracy+15', 'Pet: Damage taken -3%' }, })  --HP 100, Acc 15
gear.raoBodyPathD = hp_gear("Rao Togi", 0, {
    augments = { 'Attack+15', '"Subtle Blow"+7', 'Phys. dmg. taken -3%' }, })  --PDT 3
gear.raoHandsPathA = hp_gear("Rao Kote", 0, {
    augments = { 'Accuracy+10', 'Attack+10', 'Evasion+15' }, })  --Acc 10
gear.raoHandsPathB = hp_gear("Rao Kote", 0, {
    augments = { 'STR+10', 'DEX+10', 'Attack+15' }, })
gear.raoHandsPathC = hp_gear("Rao Kote", 100, {
    augments = { 'Pet: HP+100', 'Pet: Accuracy+15', 'Pet: Damage taken -3%' }, })  --HP 100, Acc 15
gear.raoHandsPathD = hp_gear("Rao Kote", 0, {
    augments = { 'MND+10', 'Mag. Evasion+15', 'Magic dmg. taken -3%' }, })
gear.raoLegsPathA = hp_gear("Rao Haidate", 0, {
    augments = { 'Accuracy+10', 'Attack+10', 'Evasion+15' }, })  --Acc 10
gear.raoLegsPathB = hp_gear("Rao Haidate", 0, {
    augments = { 'STR+10', 'DEX+10', 'Attack+15' }, })
gear.raoLegsPathC = hp_gear("Rao Haidate", 100, {
    augments = { 'Pet: HP+100', 'Pet: Accuracy+15', 'Pet: Damage taken -3%' }, })  --HP 100, Acc 15
gear.raoLegsPathD = hp_gear("Rao Haidate", 0, {
    augments = { 'Accuracy+20', '"Double Attack"+3%', 'Pet: Accuracy+20' }, })  --Acc 20
gear.raoFeetPathA = hp_gear("Rao Sune-Ate", 0, {
    augments = { 'Accuracy+10', 'Attack+10', 'Evasion+15' }, })  --Acc 10
gear.raoFeetPathB = hp_gear("Rao Sune-Ate", 0, {
    augments = { 'STR+10', 'DEX+10', 'Attack+15' }, })
gear.raoFeetPathC = hp_gear("Rao Sune-Ate", 100, {
    augments = { 'Pet: HP+100', 'Pet: Accuracy+15', 'Pet: Damage taken -3%' }, })  --HP 100, Acc 15
gear.raoFeetPathD = hp_gear("Rao Sune-Ate", 50, {
    augments = { 'HP+50', 'Critical hit rate +3%', '"Double Attack"+2%' }, })  --HP 50

--Ryuo Armor Set -- Nolan paths
gear.ryuoHeadPathA = hp_gear("Ryuo Somen", 41, {
    augments = { 'STR+10', 'DEX+10', 'Accuracy+15' }, })  --Acc 15
gear.ryuoHeadPathB = hp_gear("Ryuo Somen", 91, {
    augments = { 'HP+50', 'Accuracy+15', 'Attack+15' }, })  --HP 50, Acc 15
gear.ryuoHeadPathC = hp_gear("Ryuo Somen", 91, {
    augments = { 'HP+50', '"Store TP"+4', '"Subtle Blow"+7' }, })  --HP 50, STP 4
gear.ryuoHeadPathD = hp_gear("Ryuo Somen", 41, {
    augments = { 'Ninjutsu skill +15', 'Mag. Acc.+20', '"Mag.Atk.Bns."+20' }, })  --MAB 20, Macc 20
gear.ryuoBodyPathA = hp_gear("Ryuo Domaru", 163, {
    augments = { 'STR+10', 'DEX+10', 'Accuracy+15' }, })  --Acc 15
gear.ryuoBodyPathB = hp_gear("Ryuo Domaru", 213, {
    augments = { 'HP+50', 'Accuracy+15', 'Attack+15' }, })  --HP 50, Acc 15
gear.ryuoBodyPathC = hp_gear("Ryuo Domaru", 213, {
    augments = { 'HP+50', '"Store TP"+4', '"Subtle Blow"+7' }, })  --HP 50, STP 4
gear.ryuoBodyPathD = hp_gear("Ryuo Domaru", 213, {
    augments = { 'HP+50', '"Store TP"+5', '"Double Attack"+2%' }, })  --HP 50, STP 5
gear.ryuoHandsPathA = hp_gear("Ryuo Tekko", 29, {
    augments = { 'STR+10', 'DEX+10', 'Accuracy+15' }, })  --Acc 15
gear.ryuoHandsPathB = hp_gear("Ryuo Tekko", 79, {
    augments = { 'HP+50', 'Accuracy+15', 'Attack+15' }, })  --HP 50, Acc 15
gear.ryuoHandsPathC = hp_gear("Ryuo Tekko", 79, {
    augments = { 'HP+50', '"Store TP"+4', '"Subtle Blow"+7' }, })  --HP 50, STP 4
gear.ryuoHandsPathD = hp_gear("Ryuo Tekko", 29, {
    augments = { 'DEX+10', 'Accuracy+20', '"Double Attack"+3%' }, })  --Acc 20
gear.ryuoLegsPathA = hp_gear("Ryuo Hakama", 50, {
    augments = { 'STR+10', 'DEX+10', 'Accuracy+15' }, })  --Acc 15
gear.ryuoLegsPathB = hp_gear("Ryuo Hakama", 100, {
    augments = { 'HP+50', 'Accuracy+15', 'Attack+15' }, })  --HP 50, Acc 15
gear.ryuoLegsPathC = hp_gear("Ryuo Hakama", 100, {
    augments = { 'HP+50', '"Store TP"+4', '"Subtle Blow"+7' }, })  --HP 50, STP 4
gear.ryuoLegsPathD = hp_gear("Ryuo Hakama", 50, {
    augments = { 'Accuracy+20', '"Store TP"+4', 'Phys. dmg. taken -3%' }, })  --STP 4, PDT 3, Acc 20
gear.ryuoFeetPathA = hp_gear("Ryuo Sune-Ate", 18, {
    augments = { 'STR+10', 'DEX+10', 'Accuracy+15' }, })  --Acc 15
gear.ryuoFeetPathB = hp_gear("Ryuo Sune-Ate", 68, {
    augments = { 'HP+50', 'Accuracy+15', 'Attack+15' }, })  --HP 50, Acc 15
gear.ryuoFeetPathC = hp_gear("Ryuo Sune-Ate", 68, {
    augments = { 'HP+50', '"Store TP"+4', '"Subtle Blow"+7' }, })  --HP 50, STP 4
gear.ryuoFeetPathD = hp_gear("Ryuo Sune-Ate", 18, {
    augments = { 'STR+10', 'Attack+20', 'Critical hit rate +3%' }, })

--Souveran Armor Set -- Nolan paths
gear.souveranHeadPathA = hp_gear("Souveran Schaller", 125, {
    augments = { 'Accuracy+10', 'Attack+10', 'Enmity+4' }, })  --Enmity 4, Acc 10
gear.souveranHeadPathB = hp_gear("Souveran Schaller", 175, {
    augments = { 'HP+50', 'STR+10', 'Accuracy+10' }, })  --HP 50, Acc 10
gear.souveranHeadPathC = hp_gear("Souveran Schaller", 205, {
    augments = { 'HP+80', 'Enmity+7', 'Potency of "Cure" effect received +10%' }, })  --HP 80, Enmity 7
gear.souveranHeadPathD = hp_gear("Souveran Schaller", 205, {
    augments = { 'HP+80', 'VIT+10', 'Phys. dmg. taken -3%' }, })  --HP 80, PDT 3
gear.souveranBodyPathA = hp_gear("Souveran Cuirass", 66, {
    augments = { 'Accuracy+10', 'Attack+10', 'Enmity+4' }, })  --Enmity 4, Acc 10
gear.souveranBodyPathB = hp_gear("Souveran Cuirass", 116, {
    augments = { 'HP+50', 'STR+10', 'Accuracy+10' }, })  --HP 50, Acc 10
gear.souveranBodyPathC = hp_gear("Souveran Cuirass", 146, {
    augments = { 'HP+80', 'Enmity+7', 'Potency of "Cure" effect received +10%' }, })  --HP 80, Enmity 7
gear.souveranBodyPathD = hp_gear("Souveran Cuirass", 66, {
    augments = { 'VIT+10', 'Attack+20', 'Refresh+2' }, })
gear.souveranHandsPathA = hp_gear("Souv. Handschuhs", 84, {
    augments = { 'Accuracy+10', 'Attack+10', 'Enmity+4' }, })  --Enmity 4, Acc 10
gear.souveranHandsPathB = hp_gear("Souv. Handschuhs", 134, {
    augments = { 'HP+50', 'STR+10', 'Accuracy+10' }, })  --HP 50, Acc 10
gear.souveranHandsPathC = hp_gear("Souv. Handschuhs", 164, {
    augments = { 'HP+80', 'Enmity+7', 'Potency of "Cure" effect received +10%' }, })  --HP 80, Enmity 7
gear.souveranLegsPathA = hp_gear("Souveran Diechlings", 57, {
    augments = { 'Accuracy+10', 'Attack+10', 'Enmity+4' }, })  --Enmity 4, Acc 10
gear.souveranLegsPathB = hp_gear("Souveran Diechlings", 107, {
    augments = { 'HP+50', 'STR+10', 'Accuracy+10' }, })  --HP 50, Acc 10
gear.souveranLegsPathC = hp_gear("Souveran Diechlings", 137, {
    augments = { 'HP+80', 'Enmity+7', 'Potency of "Cure" effect received +10%' }, })  --HP 80, Enmity 7
gear.souveranLegsPathD = hp_gear("Souveran Diechlings", 57, {
    augments = { 'STR+10', 'VIT+10', 'Accuracy+15' }, })  --Acc 15
gear.souveranFeetPathA = hp_gear("Souveran Schuhs", 72, {
    augments = { 'Accuracy+10', 'Attack+10', 'Enmity+4' }, })  --Enmity 4, Acc 10
gear.souveranFeetPathB = hp_gear("Souveran Schuhs", 122, {
    augments = { 'HP+50', 'STR+10', 'Accuracy+10' }, })  --HP 50, Acc 10
gear.souveranFeetPathC = hp_gear("Souveran Schuhs", 152, {
    augments = { 'HP+80', 'Enmity+7', 'Potency of "Cure" effect received +10%' }, })  --HP 80, Enmity 7
gear.souveranFeetPathD = hp_gear("Souveran Schuhs", 122, {
    augments = { 'HP+50', 'Attack+20', 'Magic dmg. taken -3%' }, })  --HP 50

--Adhemar Attire Set +1 -- Nolan paths (Set: Increases rate of critical hits)
gear.adhemarHeadPlusOnePathB = hp_gear("Adhemar Bonnet +1", 41, {
    augments = { 'STR+12', 'DEX+12', 'Attack+20' }, })
gear.adhemarHeadPlusOnePathC = hp_gear("Adhemar Bonnet +1", 41, {
    augments = { 'AGI+12', 'Ranged Acc.+20', 'Ranged Atk.+20' }, })
gear.adhemarHeadPlusOnePathD = hp_gear("Adhemar Bonnet +1", 146, {
    augments = { 'HP+105', 'Attack+13', 'Phys. dmg. taken -4%' }, })  --HP 105, PDT 4
gear.adhemarBodyPlusOnePathB = hp_gear("Adhemar Jacket +1", 63, {
    augments = { 'STR+12', 'DEX+12', 'Attack+20' }, })
gear.adhemarBodyPlusOnePathC = hp_gear("Adhemar Jacket +1", 63, {
    augments = { 'AGI+12', 'Ranged Acc.+20', 'Ranged Atk.+20' }, })
gear.adhemarBodyPlusOnePathD = hp_gear("Adhemar Jacket +1", 168, {
    augments = { 'HP+105', '"Fast Cast"+10%', 'Magic dmg. taken -4%' }, })  --HP 105, FC 10
gear.adhemarHandsPlusOnePathB = hp_gear("Adhemar Wrist. +1", 22, {
    augments = { 'STR+12', 'DEX+12', 'Attack+20' }, })
gear.adhemarHandsPlusOnePathC = hp_gear("Adhemar Wrist. +1", 22, {
    augments = { 'AGI+12', 'Ranged Acc.+20', 'Ranged Atk.+20' }, })
gear.adhemarHandsPlusOnePathD = hp_gear("Adhemar Wrist. +1", 22, {
    augments = { 'Accuracy+20', 'Attack+20', '"Subtle Blow"+8' }, })  --Acc 20
gear.adhemarLegsPlusOnePathA = hp_gear("Adhemar Kecks +1", 41, {
    augments = { 'DEX+12', 'AGI+12', 'Accuracy+20' }, })  --Acc 20
gear.adhemarLegsPlusOnePathB = hp_gear("Adhemar Kecks +1", 41, {
    augments = { 'STR+12', 'DEX+12', 'Attack+20' }, })
gear.adhemarLegsPlusOnePathC = hp_gear("Adhemar Kecks +1", 41, {
    augments = { 'AGI+12', 'Ranged Acc.+20', 'Ranged Atk.+20' }, })
gear.adhemarFeetPlusOnePathA = hp_gear("Adhe. Gamashes +1", 11, {
    augments = { 'DEX+12', 'AGI+12', 'Accuracy+20' }, })  --Acc 20
gear.adhemarFeetPlusOnePathB = hp_gear("Adhe. Gamashes +1", 11, {
    augments = { 'STR+12', 'DEX+12', 'Attack+20' }, })
gear.adhemarFeetPlusOnePathC = hp_gear("Adhe. Gamashes +1", 11, {
    augments = { 'AGI+12', 'Ranged Acc.+20', 'Ranged Atk.+20' }, })

--Amalric Attire Set +1 -- Nolan paths (Set: Enhances "Magic Atk. Bonus" effect)
gear.amalricHeadPlusOnePathB = hp_gear("Amalric Coif +1", 27, {
    augments = { 'MP+80', 'INT+12', 'Enmity-6' }, })  --MP 80, Enmity -6
gear.amalricHeadPlusOnePathC = hp_gear("Amalric Coif +1", 27, {
    augments = { 'INT+12', 'Elem. magic skill +20', 'Dark magic skill +20' }, })
gear.amalricHeadPlusOnePathD = hp_gear("Amalric Coif +1", 27, {
    augments = { 'INT+12', 'Mag. Acc.+25', 'Enmity-6' }, })  --Enmity -6, Macc 25
gear.amalricBodyPlusOnePathB = hp_gear("Amalric Doublet +1", 45, {
    augments = { 'MP+80', 'INT+12', 'Enmity-6' }, })  --MP 80, Enmity -6
gear.amalricBodyPlusOnePathC = hp_gear("Amalric Doublet +1", 45, {
    augments = { 'INT+12', 'Elem. magic skill +20', 'Dark magic skill +20' }, })
gear.amalricBodyPlusOnePathD = hp_gear("Amalric Doublet +1", 45, {
    augments = { 'MP+80', '"Mag.Atk.Bns."+25', '"Fast Cast"+4%' }, })  --MP 80, FC 4, MAB 25
gear.amalricHandsPlusOnePathA = hp_gear("Amalric Gages +1", 13, {
    augments = { 'MP+80', 'Mag. Acc.+20', '"Mag.Atk.Bns."+20' }, })  --MP 80, MAB 20, Macc 20
gear.amalricHandsPlusOnePathB = hp_gear("Amalric Gages +1", 13, {
    augments = { 'MP+80', 'INT+12', 'Enmity-6' }, })  --MP 80, Enmity -6
gear.amalricHandsPlusOnePathC = hp_gear("Amalric Gages +1", 13, {
    augments = { 'INT+12', 'Elem. magic skill +20', 'Dark magic skill +20' }, })
gear.amalricLegsPlusOnePathB = hp_gear("Amalric Slops +1", 34, {
    augments = { 'MP+80', 'INT+12', 'Enmity-6' }, })  --MP 80, Enmity -6
gear.amalricLegsPlusOnePathC = hp_gear("Amalric Slops +1", 34, {
    augments = { 'INT+12', 'Elem. magic skill +20', 'Dark magic skill +20' }, })
gear.amalricLegsPlusOnePathD = hp_gear("Amalric Slops +1", 34, {
    augments = { 'MP+80', '"Mag.Atk.Bns."+25', 'Enmity-6' }, })  --MP 80, MAB 25, Enmity -6
gear.amalricFeetPlusOnePathB = hp_gear("Amalric Nails +1", 4, {
    augments = { 'MP+80', 'INT+12', 'Enmity-6' }, })  --MP 80, Enmity -6
gear.amalricFeetPlusOnePathC = hp_gear("Amalric Nails +1", 4, {
    augments = { 'INT+12', 'Elem. magic skill +20', 'Dark magic skill +20' }, })
gear.amalricFeetPlusOnePathD = hp_gear("Amalric Nails +1", 4, {
    augments = { 'Mag. Acc.+20', '"Mag.Atk.Bns."+20', '"Conserve MP"+7' }, })  --MAB 20, Macc 20

--Apogee Attire Set +1 -- Nolan paths (Set: Increases "Blood Pact" damage)
gear.apogeeHeadPlusOnePathA = hp_gear("Apogee Crown +1", -110, {
    augments = { 'MP+80', 'Pet: "Mag.Atk.Bns."+35', 'Blood Pact Dmg.+8' }, })  --MP 80, MAB 35, BP Dmg 8
gear.apogeeHeadPlusOnePathC = hp_gear("Apogee Crown +1", -110, {
    augments = { 'Pet: Attack+25', 'Pet: "Mag.Atk.Bns."+25', 'Blood Pact Dmg.+8' }, })  --MAB 25, BP Dmg 8
gear.apogeeHeadPlusOnePathD = hp_gear("Apogee Crown +1", -110, {
    augments = { 'Pet: Accuracy+25', 'Avatar perpetuation cost -7', 'Pet: Damage taken -4%' }, })  --Acc 25
gear.apogeeBodyPlusOnePathA = hp_gear("Apo. Dalmatica +1", -160, {
    augments = { 'MP+80', 'Pet: "Mag.Atk.Bns."+35', 'Blood Pact Dmg.+8' }, })  --MP 80, MAB 35, BP Dmg 8
gear.apogeeBodyPlusOnePathB = hp_gear("Apo. Dalmatica +1", -160, {
    augments = { 'MP+80', 'Pet: Attack+35', 'Blood Pact Dmg.+8' }, })  --MP 80, BP Dmg 8
gear.apogeeBodyPlusOnePathC = hp_gear("Apo. Dalmatica +1", -160, {
    augments = { 'Pet: Attack+25', 'Pet: "Mag.Atk.Bns."+25', 'Blood Pact Dmg.+8' }, })  --MAB 25, BP Dmg 8
gear.apogeeBodyPlusOnePathD = hp_gear("Apo. Dalmatica +1", -160, {
    augments = { 'Summoning magic skill +20', 'Enmity-6', 'Pet: Damage taken -4%' }, })  --Enmity -6
gear.apogeeHandsPlusOnePathA = hp_gear("Apogee Mitts +1", -90, {
    augments = { 'MP+80', 'Pet: "Mag.Atk.Bns."+35', 'Blood Pact Dmg.+8' }, })  --MP 80, MAB 35, BP Dmg 8
gear.apogeeHandsPlusOnePathB = hp_gear("Apogee Mitts +1", -90, {
    augments = { 'MP+80', 'Pet: Attack+35', 'Blood Pact Dmg.+8' }, })  --MP 80, BP Dmg 8
gear.apogeeHandsPlusOnePathC = hp_gear("Apogee Mitts +1", -90, {
    augments = { 'Pet: Attack+25', 'Pet: "Mag.Atk.Bns."+25', 'Blood Pact Dmg.+8' }, })  --MAB 25, BP Dmg 8
gear.apogeeHandsPlusOnePathD = hp_gear("Apogee Mitts +1", -90, {
    augments = { 'Pet: Mag. Acc.+25', 'Blood Pact ab. del. -7', 'Blood Pact Dmg.+8' }, })  --BP Dmg 8, Macc 25
gear.apogeeLegsPlusOnePathA = hp_gear("Apogee Slacks +1", -110, {
    augments = { 'MP+80', 'Pet: "Mag.Atk.Bns."+35', 'Blood Pact Dmg.+8' }, })  --MP 80, MAB 35, BP Dmg 8
gear.apogeeLegsPlusOnePathB = hp_gear("Apogee Slacks +1", -110, {
    augments = { 'MP+80', 'Pet: Attack+35', 'Blood Pact Dmg.+8' }, })  --MP 80, BP Dmg 8
gear.apogeeLegsPlusOnePathC = hp_gear("Apogee Slacks +1", -110, {
    augments = { 'Pet: Attack+25', 'Pet: "Mag.Atk.Bns."+25', 'Blood Pact Dmg.+8' }, })  --MAB 25, BP Dmg 8
gear.apogeeFeetPlusOnePathA = hp_gear("Apogee Pumps +1", -90, {
    augments = { 'MP+80', 'Pet: "Mag.Atk.Bns."+35', 'Blood Pact Dmg.+8' }, })  --MP 80, MAB 35, BP Dmg 8
gear.apogeeFeetPlusOnePathD = hp_gear("Apogee Pumps +1", -90, {
    augments = { 'MP+80', 'Summoning magic skill +20', 'Blood Pact Dmg.+8' }, })  --MP 80, BP Dmg 8

--Argosy Armor Set +1 -- Nolan paths (Set: Enhances "Double Attack" effect)
gear.argosyHeadPlusOnePathA = hp_gear("Argosy Celata +1", 50, {
    augments = { 'STR+12', 'DEX+12', 'Attack+20' }, })
gear.argosyHeadPlusOnePathB = hp_gear("Argosy Celata +1", 115, {
    augments = { 'HP+65', 'Accuracy+13', 'Attack+20' }, })  --HP 65, Acc 13
gear.argosyHeadPlusOnePathC = hp_gear("Argosy Celata +1", 115, {
    augments = { 'HP+65', 'STR+15', 'Phys. dmg. taken -4%' }, })  --HP 65, PDT 4
gear.argosyHeadPlusOnePathD = hp_gear("Argosy Celata +1", 50, {
    augments = { 'DEX+12', 'Accuracy+20', '"Double Attack"+3%' }, })  --Acc 20
gear.argosyBodyPlusOnePathA = hp_gear("Argosy Hauberk +1", 68, {
    augments = { 'STR+12', 'DEX+12', 'Attack+20' }, })
gear.argosyBodyPlusOnePathB = hp_gear("Argosy Hauberk +1", 133, {
    augments = { 'HP+65', 'Accuracy+13', 'Attack+20' }, })  --HP 65, Acc 13
gear.argosyBodyPlusOnePathC = hp_gear("Argosy Hauberk +1", 133, {
    augments = { 'HP+65', 'STR+15', 'Phys. dmg. taken -4%' }, })  --HP 65, PDT 4
gear.argosyBodyPlusOnePathD = hp_gear("Argosy Hauberk +1", 68, {
    augments = { 'STR+12', 'Attack+20', '"Store TP"+6' }, })  --STP 6
gear.argosyHandsPlusOnePathA = hp_gear("Argosy Mufflers +1", 34, {
    augments = { 'STR+12', 'DEX+12', 'Attack+20' }, })
gear.argosyHandsPlusOnePathB = hp_gear("Argosy Mufflers +1", 99, {
    augments = { 'HP+65', 'Accuracy+13', 'Attack+20' }, })  --HP 65, Acc 13
gear.argosyHandsPlusOnePathC = hp_gear("Argosy Mufflers +1", 99, {
    augments = { 'HP+65', 'STR+15', 'Phys. dmg. taken -4%' }, })  --HP 65, PDT 4
gear.argosyHandsPlusOnePathD = hp_gear("Argosy Mufflers +1", 34, {
    augments = { 'STR+20', '"Double Attack"+3%', 'Haste+3%' }, })
gear.argosyLegsPlusOnePathA = hp_gear("Argosy Breeches +1", 57, {
    augments = { 'STR+12', 'DEX+12', 'Attack+20' }, })
gear.argosyLegsPlusOnePathB = hp_gear("Argosy Breeches +1", 122, {
    augments = { 'HP+65', 'Accuracy+13', 'Attack+20' }, })  --HP 65, Acc 13
gear.argosyLegsPlusOnePathC = hp_gear("Argosy Breeches +1", 122, {
    augments = { 'HP+65', 'STR+15', 'Phys. dmg. taken -4%' }, })  --HP 65, PDT 4
gear.argosyLegsPlusOnePathD = hp_gear("Argosy Breeches +1", 57, {
    augments = { 'STR+12', 'Attack+25', '"Store TP"+6' }, })  --STP 6
gear.argosyFeetPlusOnePathA = hp_gear("Argosy Sollerets +1", 22, {
    augments = { 'STR+12', 'DEX+12', 'Attack+20' }, })
gear.argosyFeetPlusOnePathB = hp_gear("Argosy Sollerets +1", 87, {
    augments = { 'HP+65', 'Accuracy+13', 'Attack+20' }, })  --HP 65, Acc 13
gear.argosyFeetPlusOnePathC = hp_gear("Argosy Sollerets +1", 87, {
    augments = { 'HP+65', 'STR+15', 'Phys. dmg. taken -4%' }, })  --HP 65, PDT 4
gear.argosyFeetPlusOnePathD = hp_gear("Argosy Sollerets +1", 87, {
    augments = { 'HP+65', '"Double Attack"+3%', '"Store TP"+5' }, })  --HP 65, STP 5

--Carmine Armor Set +1 -- Nolan paths (Set: Increases Accuracy)
gear.carmineHeadPlusOnePathA = hp_gear("Carmine Mask +1", 118, {
    augments = { 'HP+80', 'STR+12', 'INT+12' }, })  --HP 80
gear.carmineHeadPlusOnePathB = hp_gear("Carmine Mask +1", 38, {
    augments = { 'Accuracy+12', 'DEX+12', 'MND+20' }, })  --Acc 12
gear.carmineHeadPlusOnePathC = hp_gear("Carmine Mask +1", 38, {
    augments = { 'MP+80', 'INT+12', 'MND+12' }, })  --MP 80
gear.carmineBodyPlusOnePathA = hp_gear("Carm. Sc. Mail +1", 176, {
    augments = { 'HP+80', 'STR+12', 'INT+12' }, })  --HP 80
gear.carmineBodyPlusOnePathB = hp_gear("Carm. Sc. Mail +1", 96, {
    augments = { 'Accuracy+12', 'DEX+12', 'MND+20' }, })  --Acc 12
gear.carmineBodyPlusOnePathC = hp_gear("Carm. Sc. Mail +1", 96, {
    augments = { 'MP+80', 'INT+12', 'MND+12' }, })  --MP 80
gear.carmineBodyPlusOnePathD = hp_gear("Carm. Sc. Mail +1", 96, {
    augments = { '"Mag.Atk.Bns."+12', 'Attack+20', '"Double Attack"+4%' }, })  --MAB 12
gear.carmineHandsPlusOnePathA = hp_gear("Carmine Fin. Ga. +1", 107, {
    augments = { 'HP+80', 'STR+12', 'INT+12' }, })  --HP 80
gear.carmineHandsPlusOnePathB = hp_gear("Carmine Fin. Ga. +1", 27, {
    augments = { 'Accuracy+12', 'DEX+12', 'MND+20' }, })  --Acc 12
gear.carmineHandsPlusOnePathC = hp_gear("Carmine Fin. Ga. +1", 27, {
    augments = { 'MP+80', 'INT+12', 'MND+12' }, })  --MP 80
gear.carmineLegsPlusOnePathB = hp_gear("Carmine Cuisses +1", 50, {
    augments = { 'Accuracy+12', 'DEX+12', 'MND+20' }, })  --Acc 12
gear.carmineLegsPlusOnePathC = hp_gear("Carmine Cuisses +1", 50, {
    augments = { 'MP+80', 'INT+12', 'MND+12' }, })  --MP 80
gear.carmineFeetPlusOnePathA = hp_gear("Carmine Greaves +1", 95, {
    augments = { 'HP+80', 'STR+12', 'INT+12' }, })  --HP 80
gear.carmineFeetPlusOnePathB = hp_gear("Carmine Greaves +1", 15, {
    augments = { 'Accuracy+12', 'DEX+12', 'MND+20' }, })  --Acc 12
gear.carmineFeetPlusOnePathC = hp_gear("Carmine Greaves +1", 15, {
    augments = { 'MP+80', 'INT+12', 'MND+12' }, })  --MP 80

--Emicho Armor Set +1 -- Nolan paths (Set: Enhances "Double Attack" effect)
gear.emichoHeadPlusOnePathA = hp_gear("Emicho Coronet +1", 110, {
    augments = { 'HP+65', 'STR+12', 'Attack+20' }, })  --HP 65
gear.emichoHeadPlusOnePathB = hp_gear("Emicho Coronet +1", 110, {
    augments = { 'HP+65', 'DEX+12', 'Accuracy+20' }, })  --HP 65, Acc 20
gear.emichoHeadPlusOnePathC = hp_gear("Emicho Coronet +1", 45, {
    augments = { 'Pet: Accuracy+20', 'Pet: Attack+20', 'Pet: "Dbl. Atk."+4' }, })  --Acc 20
gear.emichoHeadPlusOnePathD = hp_gear("Emicho Coronet +1", 45, {
    augments = { 'Attack+25', '"Store TP"+7', 'Pet: STR+20' }, })  --STP 7
gear.emichoBodyPlusOnePathA = hp_gear("Emicho Haubert +1", 128, {
    augments = { 'HP+65', 'STR+12', 'Attack+20' }, })  --HP 65
gear.emichoBodyPlusOnePathB = hp_gear("Emicho Haubert +1", 128, {
    augments = { 'HP+65', 'DEX+12', 'Accuracy+20' }, })  --HP 65, Acc 20
gear.emichoBodyPlusOnePathC = hp_gear("Emicho Haubert +1", 63, {
    augments = { 'Pet: Accuracy+20', 'Pet: Attack+20', 'Pet: "Dbl. Atk."+4' }, })  --Acc 20
gear.emichoBodyPlusOnePathD = hp_gear("Emicho Haubert +1", 188, {
    augments = { 'Pet: HP+125', 'Pet: INT+20', 'Pet: "Regen"+3' }, })  --HP 125, Regen 3
gear.emichoHandsPlusOnePathA = hp_gear("Emi. Gauntlets +1", 99, {
    augments = { 'HP+65', 'STR+12', 'Attack+20' }, })  --HP 65
gear.emichoHandsPlusOnePathB = hp_gear("Emi. Gauntlets +1", 99, {
    augments = { 'HP+65', 'DEX+12', 'Accuracy+20' }, })  --HP 65, Acc 20
gear.emichoHandsPlusOnePathC = hp_gear("Emi. Gauntlets +1", 34, {
    augments = { 'Pet: Accuracy+20', 'Pet: Attack+20', 'Pet: "Dbl. Atk."+4' }, })  --Acc 20
gear.emichoHandsPlusOnePathD = hp_gear("Emi. Gauntlets +1", 34, {
    augments = { 'Accuracy+25', '"Dual Wield"+6', 'Pet: Accuracy+25' }, })  --DW 6, Acc 25
gear.emichoLegsPlusOnePathA = hp_gear("Emicho Hose +1", 115, {
    augments = { 'HP+65', 'STR+12', 'Attack+20' }, })  --HP 65
gear.emichoLegsPlusOnePathB = hp_gear("Emicho Hose +1", 115, {
    augments = { 'HP+65', 'DEX+12', 'Accuracy+20' }, })  --HP 65, Acc 20
gear.emichoLegsPlusOnePathC = hp_gear("Emicho Hose +1", 50, {
    augments = { 'Pet: Accuracy+20', 'Pet: Attack+20', 'Pet: "Dbl. Atk."+4' }, })  --Acc 20
gear.emichoLegsPlusOnePathD = hp_gear("Emicho Hose +1", 50, {
    augments = { 'STR+12', 'Accuracy+25', 'Attack+25' }, })  --Acc 25
gear.emichoFeetPlusOnePathA = hp_gear("Emi. Gambieras +1", 87, {
    augments = { 'HP+65', 'STR+12', 'Attack+20' }, })  --HP 65
gear.emichoFeetPlusOnePathB = hp_gear("Emi. Gambieras +1", 87, {
    augments = { 'HP+65', 'DEX+12', 'Accuracy+20' }, })  --HP 65, Acc 20
gear.emichoFeetPlusOnePathC = hp_gear("Emi. Gambieras +1", 22, {
    augments = { 'Pet: Accuracy+20', 'Pet: Attack+20', 'Pet: "Dbl. Atk."+4' }, })  --Acc 20
gear.emichoFeetPlusOnePathD = hp_gear("Emi. Gambieras +1", 22, {
    augments = { 'Attack+25', '"Subtle Blow"+5', 'Pet: Attack+30' }, })

--Kaykaus Attire Set +1 -- Nolan paths (Set: Enhances "Cure" potency II effect)
gear.kaykausHeadPlusOnePathA = hp_gear("Kaykaus Mitra +1", 34, {
    augments = { 'MP+80', 'MND+12', 'Mag. Acc.+20' }, })  --MP 80, Macc 20
gear.kaykausHeadPlusOnePathC = hp_gear("Kaykaus Mitra +1", 34, {
    augments = { 'MP+80', 'Spell interruption rate down +12%', '"Cure" spellcasting time -7%' }, })  --MP 80
gear.kaykausHeadPlusOnePathD = hp_gear("Kaykaus Mitra +1", 34, {
    augments = { 'MND+12', 'Mag. Acc.+20', '"Mag.Atk.Bns."+20' }, })  --MAB 20, Macc 20
gear.kaykausBodyPlusOnePathA = hp_gear("Kaykaus Bliaut +1", 52, {
    augments = { 'MP+80', 'MND+12', 'Mag. Acc.+20' }, })  --MP 80, Macc 20
gear.kaykausBodyPlusOnePathB = hp_gear("Kaykaus Bliaut +1", 52, {
    augments = { 'MP+80', '"Cure" spellcasting time -7%', 'Enmity-6' }, })  --MP 80, Enmity -6
gear.kaykausBodyPlusOnePathC = hp_gear("Kaykaus Bliaut +1", 52, {
    augments = { 'MP+80', 'Spell interruption rate down +12%', '"Cure" spellcasting time -7%' }, })  --MP 80
gear.kaykausHandsPlusOnePathA = hp_gear("Kaykaus Cuffs +1", 20, {
    augments = { 'MP+80', 'MND+12', 'Mag. Acc.+20' }, })  --MP 80, Macc 20
gear.kaykausHandsPlusOnePathC = hp_gear("Kaykaus Cuffs +1", 20, {
    augments = { 'MP+80', 'Spell interruption rate down +12%', '"Cure" spellcasting time -7%' }, })  --MP 80
gear.kaykausHandsPlusOnePathD = hp_gear("Kaykaus Cuffs +1", 20, {
    augments = { 'MP+80', '"Conserve MP"+7', '"Fast Cast"+4%' }, })  --MP 80, FC 4
gear.kaykausLegsPlusOnePathA = hp_gear("Kaykaus Tights +1", 41, {
    augments = { 'MP+80', 'MND+12', 'Mag. Acc.+20' }, })  --MP 80, Macc 20
gear.kaykausLegsPlusOnePathD = hp_gear("Kaykaus Tights +1", 41, {
    augments = { 'INT+12', '"Mag.Atk.Bns."+20', 'Enmity-6' }, })  --MAB 20, Enmity -6
gear.kaykausFeetPlusOnePathA = hp_gear("Kaykaus Boots +1", 11, {
    augments = { 'MP+80', 'MND+12', 'Mag. Acc.+20' }, })  --MP 80, Macc 20
gear.kaykausFeetPlusOnePathC = hp_gear("Kaykaus Boots +1", 11, {
    augments = { 'MP+80', 'Spell interruption rate down +12%', '"Cure" spellcasting time -7%' }, })  --MP 80
gear.kaykausFeetPlusOnePathD = hp_gear("Kaykaus Boots +1", 11, {
    augments = { 'Mag. Acc.+20', '"Cure" potency +6%', '"Fast Cast"+4%' }, })  --FC 4, Cure Pot 6, Macc 20

--Lustratio Armor Set +1 -- Nolan paths (Set: Increases weapon skill damage)
gear.lustratioHeadPlusOnePathA = hp_gear("Lustratio Cap +1", 23, {
    augments = { 'Attack+20', 'STR+8', '"Double Attack"+3%' }, })
gear.lustratioHeadPlusOnePathB = hp_gear("Lustratio Cap +1", 23, {
    augments = { 'Accuracy+20', 'DEX+8', 'Critical hit rate +3%' }, })  --Acc 20
gear.lustratioHeadPlusOnePathC = hp_gear("Lustratio Cap +1", 23, {
    augments = { 'Accuracy+10', '"Store TP"+5', 'Attack+10' }, })  --STP 5, Acc 10
gear.lustratioHeadPlusOnePathD = hp_gear("Lustratio Cap +1", 23, {
    augments = { 'STR+8', 'DEX+8', 'INT+35' }, })
gear.lustratioBodyPlusOnePathA = hp_gear("Lustr. Harness +1", 35, {
    augments = { 'Attack+20', 'STR+8', '"Double Attack"+3%' }, })
gear.lustratioBodyPlusOnePathB = hp_gear("Lustr. Harness +1", 35, {
    augments = { 'Accuracy+20', 'DEX+8', 'Critical hit rate +3%' }, })  --Acc 20
gear.lustratioBodyPlusOnePathC = hp_gear("Lustr. Harness +1", 35, {
    augments = { 'Accuracy+10', '"Store TP"+5', 'Attack+10' }, })  --STP 5, Acc 10
gear.lustratioBodyPlusOnePathD = hp_gear("Lustr. Harness +1", 35, {
    augments = { 'Accuracy+10', 'Attack+13', '"Double Attack"+4%' }, })  --Acc 10
gear.lustratioHandsPlusOnePathA = hp_gear("Lustr. Mittens +1", 16, {
    augments = { 'Attack+20', 'STR+8', '"Double Attack"+3%' }, })
gear.lustratioHandsPlusOnePathB = hp_gear("Lustr. Mittens +1", 16, {
    augments = { 'Accuracy+20', 'DEX+8', 'Critical hit rate +3%' }, })  --Acc 20
gear.lustratioHandsPlusOnePathC = hp_gear("Lustr. Mittens +1", 16, {
    augments = { 'Accuracy+10', '"Store TP"+5', 'Attack+10' }, })  --STP 5, Acc 10
gear.lustratioHandsPlusOnePathD = hp_gear("Lustr. Mittens +1", 16, {
    augments = { 'Accuracy+30', 'VIT+13', 'DEX+10' }, })  --Acc 30
gear.lustratioLegsPlusOnePathA = hp_gear("Lustr. Subligar +1", 28, {
    augments = { 'Attack+20', 'STR+8', '"Double Attack"+3%' }, })
gear.lustratioLegsPlusOnePathB = hp_gear("Lustr. Subligar +1", 28, {
    augments = { 'Accuracy+20', 'DEX+8', 'Critical hit rate +3%' }, })  --Acc 20
gear.lustratioLegsPlusOnePathC = hp_gear("Lustr. Subligar +1", 28, {
    augments = { 'Accuracy+10', '"Store TP"+5', 'Attack+10' }, })  --STP 5, Acc 10
gear.lustratioLegsPlusOnePathD = hp_gear("Lustr. Subligar +1", 93, {
    augments = { 'HP+65', 'Attack+30', 'Enmity-6' }, })  --HP 65, Enmity -6
gear.lustratioFeetPlusOnePathA = hp_gear("Lustra. Leggings +1", 12, {
    augments = { 'Attack+20', 'STR+8', '"Double Attack"+3%' }, })
gear.lustratioFeetPlusOnePathB = hp_gear("Lustra. Leggings +1", 12, {
    augments = { 'Accuracy+20', 'DEX+8', 'Critical hit rate +3%' }, })  --Acc 20
gear.lustratioFeetPlusOnePathC = hp_gear("Lustra. Leggings +1", 12, {
    augments = { 'Accuracy+10', '"Store TP"+5', 'Attack+10' }, })  --STP 5, Acc 10
gear.lustratioFeetPlusOnePathD = hp_gear("Lustra. Leggings +1", 77, {
    augments = { 'HP+65', 'STR+15', 'DEX+15' }, })  --HP 65

--Rao Armor Set +1 -- Nolan paths (Set: Augments "Martial Arts")
gear.raoHeadPlusOnePathA = hp_gear("Rao Kabuto +1", 0, {
    augments = { 'Accuracy+12', 'Attack+12', 'Evasion+20' }, })  --Acc 12
gear.raoHeadPlusOnePathB = hp_gear("Rao Kabuto +1", 0, {
    augments = { 'STR+12', 'DEX+12', 'Attack+20' }, })
gear.raoHeadPlusOnePathC = hp_gear("Rao Kabuto +1", 125, {
    augments = { 'Pet: HP+125', 'Pet: Accuracy+20', 'Pet: Damage taken -4%' }, })  --HP 125, Acc 20
gear.raoHeadPlusOnePathD = hp_gear("Rao Kabuto +1", 0, {
    augments = { 'VIT+12', 'Attack+25', 'Counter+4' }, })
gear.raoBodyPlusOnePathA = hp_gear("Rao Togi +1", 0, {
    augments = { 'Accuracy+12', 'Attack+12', 'Evasion+20' }, })  --Acc 12
gear.raoBodyPlusOnePathB = hp_gear("Rao Togi +1", 0, {
    augments = { 'STR+12', 'DEX+12', 'Attack+20' }, })
gear.raoBodyPlusOnePathC = hp_gear("Rao Togi +1", 125, {
    augments = { 'Pet: HP+125', 'Pet: Accuracy+20', 'Pet: Damage taken -4%' }, })  --HP 125, Acc 20
gear.raoBodyPlusOnePathD = hp_gear("Rao Togi +1", 0, {
    augments = { 'Attack+20', '"Subtle Blow"+8', 'Phys. dmg. taken -4%' }, })  --PDT 4
gear.raoHandsPlusOnePathA = hp_gear("Rao Kote +1", 0, {
    augments = { 'Accuracy+12', 'Attack+12', 'Evasion+20' }, })  --Acc 12
gear.raoHandsPlusOnePathB = hp_gear("Rao Kote +1", 0, {
    augments = { 'STR+12', 'DEX+12', 'Attack+20' }, })
gear.raoHandsPlusOnePathC = hp_gear("Rao Kote +1", 125, {
    augments = { 'Pet: HP+125', 'Pet: Accuracy+20', 'Pet: Damage taken -4%' }, })  --HP 125, Acc 20
gear.raoHandsPlusOnePathD = hp_gear("Rao Kote +1", 0, {
    augments = { 'MND+12', 'Mag. Evasion+20', 'Magic dmg. taken -5%' }, })
gear.raoLegsPlusOnePathA = hp_gear("Rao Haidate +1", 0, {
    augments = { 'Accuracy+12', 'Attack+12', 'Evasion+20' }, })  --Acc 12
gear.raoLegsPlusOnePathB = hp_gear("Rao Haidate +1", 0, {
    augments = { 'STR+12', 'DEX+12', 'Attack+20' }, })
gear.raoLegsPlusOnePathC = hp_gear("Rao Haidate +1", 125, {
    augments = { 'Pet: HP+125', 'Pet: Accuracy+20', 'Pet: Damage taken -4%' }, })  --HP 125, Acc 20
gear.raoLegsPlusOnePathD = hp_gear("Rao Haidate +1", 0, {
    augments = { 'Accuracy+25', '"Double Attack"+4%', 'Pet: Accuracy+25' }, })  --Acc 25
gear.raoFeetPlusOnePathA = hp_gear("Rao Sune-Ate +1", 0, {
    augments = { 'Accuracy+12', 'Attack+12', 'Evasion+20' }, })  --Acc 12
gear.raoFeetPlusOnePathB = hp_gear("Rao Sune-Ate +1", 0, {
    augments = { 'STR+12', 'DEX+12', 'Attack+20' }, })
gear.raoFeetPlusOnePathC = hp_gear("Rao Sune-Ate +1", 125, {
    augments = { 'Pet: HP+125', 'Pet: Accuracy+20', 'Pet: Damage taken -4%' }, })  --HP 125, Acc 20
gear.raoFeetPlusOnePathD = hp_gear("Rao Sune-Ate +1", 65, {
    augments = { 'HP+65', 'Critical hit rate +4%', '"Double Attack"+4%' }, })  --HP 65

--Ryuo Armor Set +1 -- Nolan paths (Set: Increases Attack)
gear.ryuoHeadPlusOnePathA = hp_gear("Ryuo Somen +1", 41, {
    augments = { 'STR+12', 'DEX+12', 'Accuracy+20' }, })  --Acc 20
gear.ryuoHeadPlusOnePathB = hp_gear("Ryuo Somen +1", 106, {
    augments = { 'HP+65', 'Accuracy+20', 'Attack+20' }, })  --HP 65, Acc 20
gear.ryuoHeadPlusOnePathC = hp_gear("Ryuo Somen +1", 106, {
    augments = { 'HP+65', '"Store TP"+5', '"Subtle Blow"+8' }, })  --HP 65, STP 5
gear.ryuoHeadPlusOnePathD = hp_gear("Ryuo Somen +1", 41, {
    augments = { 'Ninjutsu skill +20', 'Mag. Acc.+25', '"Mag.Atk.Bns."+25' }, })  --MAB 25, Macc 25
gear.ryuoBodyPlusOnePathA = hp_gear("Ryuo Domaru +1", 168, {
    augments = { 'STR+12', 'DEX+12', 'Accuracy+20' }, })  --Acc 20
gear.ryuoBodyPlusOnePathB = hp_gear("Ryuo Domaru +1", 233, {
    augments = { 'HP+65', 'Accuracy+20', 'Attack+20' }, })  --HP 65, Acc 20
gear.ryuoBodyPlusOnePathC = hp_gear("Ryuo Domaru +1", 233, {
    augments = { 'HP+65', '"Store TP"+5', '"Subtle Blow"+8' }, })  --HP 65, STP 5
gear.ryuoBodyPlusOnePathD = hp_gear("Ryuo Domaru +1", 233, {
    augments = { 'HP+65', '"Store TP"+8', '"Double Attack"+4%' }, })  --HP 65, STP 8
gear.ryuoHandsPlusOnePathB = hp_gear("Ryuo Tekko +1", 94, {
    augments = { 'HP+65', 'Accuracy+20', 'Attack+20' }, })  --HP 65, Acc 20
gear.ryuoHandsPlusOnePathC = hp_gear("Ryuo Tekko +1", 94, {
    augments = { 'HP+65', '"Store TP"+5', '"Subtle Blow"+8' }, })  --HP 65, STP 5
gear.ryuoHandsPlusOnePathD = hp_gear("Ryuo Tekko +1", 29, {
    augments = { 'DEX+12', 'Accuracy+25', '"Double Attack"+4%' }, })  --Acc 25
gear.ryuoLegsPlusOnePathA = hp_gear("Ryuo Hakama +1", 50, {
    augments = { 'STR+12', 'DEX+12', 'Accuracy+20' }, })  --Acc 20
gear.ryuoLegsPlusOnePathB = hp_gear("Ryuo Hakama +1", 115, {
    augments = { 'HP+65', 'Accuracy+20', 'Attack+20' }, })  --HP 65, Acc 20
gear.ryuoLegsPlusOnePathC = hp_gear("Ryuo Hakama +1", 115, {
    augments = { 'HP+65', '"Store TP"+5', '"Subtle Blow"+8' }, })  --HP 65, STP 5
gear.ryuoLegsPlusOnePathD = hp_gear("Ryuo Hakama +1", 50, {
    augments = { 'Accuracy+25', '"Store TP"+5', 'Phys. dmg. taken -4%' }, })  --STP 5, PDT 4, Acc 25
gear.ryuoFeetPlusOnePathA = hp_gear("Ryuo Sune-Ate +1", 18, {
    augments = { 'STR+12', 'DEX+12', 'Accuracy+20' }, })  --Acc 20
gear.ryuoFeetPlusOnePathB = hp_gear("Ryuo Sune-Ate +1", 83, {
    augments = { 'HP+65', 'Accuracy+20', 'Attack+20' }, })  --HP 65, Acc 20
gear.ryuoFeetPlusOnePathC = hp_gear("Ryuo Sune-Ate +1", 83, {
    augments = { 'HP+65', '"Store TP"+5', '"Subtle Blow"+8' }, })  --HP 65, STP 5
gear.ryuoFeetPlusOnePathD = hp_gear("Ryuo Sune-Ate +1", 18, {
    augments = { 'STR+12', 'Attack+25', 'Critical hit rate +4%' }, })

--Souveran Armor Set +1 -- Nolan paths (Set: Reduces damage taken)
gear.souveranHeadPlusOnePathA = hp_gear("Souv. Schaller +1", 175, {
    augments = { 'Accuracy+13', 'Attack+12', 'Enmity+5' }, })  --Enmity 5, Acc 13
gear.souveranHeadPlusOnePathB = hp_gear("Souv. Schaller +1", 240, {
    augments = { 'HP+65', 'STR+12', 'Accuracy+13' }, })  --HP 65, Acc 13
gear.souveranBodyPlusOnePathA = hp_gear("Souv. Cuirass +1", 66, {
    augments = { 'Accuracy+13', 'Attack+12', 'Enmity+5' }, })  --Enmity 5, Acc 13
gear.souveranBodyPlusOnePathB = hp_gear("Souv. Cuirass +1", 131, {
    augments = { 'HP+65', 'STR+12', 'Accuracy+13' }, })  --HP 65, Acc 13
gear.souveranBodyPlusOnePathD = hp_gear("Souv. Cuirass +1", 66, {
    augments = { 'VIT+12', 'Attack+25', 'Refresh+3' }, })
gear.souveranHandsPlusOnePathA = hp_gear("Souv. Handsch. +1", 134, {
    augments = { 'Accuracy+13', 'Attack+12', 'Enmity+5' }, })  --Enmity 5, Acc 13
gear.souveranHandsPlusOnePathB = hp_gear("Souv. Handsch. +1", 199, {
    augments = { 'HP+65', 'STR+12', 'Accuracy+13' }, })  --HP 65, Acc 13
gear.souveranLegsPlusOnePathA = hp_gear("Souv. Diechlings +1", 57, {
    augments = { 'Accuracy+13', 'Attack+12', 'Enmity+5' }, })  --Enmity 5, Acc 13
gear.souveranLegsPlusOnePathB = hp_gear("Souv. Diechlings +1", 122, {
    augments = { 'HP+65', 'STR+12', 'Accuracy+13' }, })  --HP 65, Acc 13
gear.souveranLegsPlusOnePathD = hp_gear("Souv. Diechlings +1", 57, {
    augments = { 'STR+12', 'VIT+12', 'Accuracy+20' }, })  --Acc 20
gear.souveranFeetPlusOnePathA = hp_gear("Souveran Schuhs +1", 122, {
    augments = { 'Accuracy+13', 'Attack+12', 'Enmity+5' }, })  --Enmity 5, Acc 13
gear.souveranFeetPlusOnePathB = hp_gear("Souveran Schuhs +1", 187, {
    augments = { 'HP+65', 'STR+12', 'Accuracy+13' }, })  --HP 65, Acc 13
gear.souveranFeetPlusOnePathD = hp_gear("Souveran Schuhs +1", 187, {
    augments = { 'HP+65', 'Attack+25', 'Magic dmg. taken -4%' }, })  --HP 65

