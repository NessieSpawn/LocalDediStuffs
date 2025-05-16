@echo off
:Start
NorthstarLauncher.exe -dedicated -multiple -profile="R2Northstar_LocalDS" +sv_max_props_multiplayer 500000 +sv_max_prop_data_dwords_multiplayer 800000 +setplaylist aitdm +mp_gamemode aitdm +map mp_crashsite3 +setplaylistvaroverrides "classic_rodeo 1 random_titan_execution 1 titan_health_bar_display triple titan_health_chicklet_fx 1 aitdm_extended_spawns 1 modaitdm_squad_count 6 modaitdm_squad_count_high_level 5 modaitdm_prowler_count 4 modaitdm_reaper_count 3 modaitdm_gunship_count 3 modaitdm_pilot_count 4 modaitdm_spectre_spawn_score 150 modaitdm_stalker_spawn_score 330 modaitdm_reaper_spawn_score 500 modaitdm_titan_spawn_score 0 scorelimit 99999 timelimit 9999"
pause
GOTO:Start