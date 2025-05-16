@echo off
:Start
NorthstarLauncher.exe -dedicated -multiple -profile="R2Northstar_LocalDS" +sv_max_props_multiplayer 500000 +sv_max_prop_data_dwords_multiplayer 800000 +setplaylist aitdm +mp_gamemode aitdm +map mp_wargames +setplaylistvaroverrides "aitdm_extended_spawns 1"
pause
GOTO:Start