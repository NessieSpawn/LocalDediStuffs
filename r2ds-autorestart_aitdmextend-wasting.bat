@echo off
:Start
NorthstarLauncher.exe -dedicated -multiple -profile="R2Northstar_LocalDS" +sv_max_props_multiplayer 500000 +sv_max_prop_data_dwords_multiplayer 800000 +setplaylist aitdm +mp_gamemode aitdm +map mp_rise +setplaylistvaroverrides "max_players 10 random_titan_execution 1 aitdm_extended_spawns 1 modaitdm_squad_count 5 modaitdm_squad_count_high_level 4 modaitdm_prowler_count 3 modaitdm_reaper_count 3 modaitdm_gunship_count 0 modaitdm_pilot_count 4 modaitdm_spectre_spawn_score 481 modaitdm_stalker_spawn_score 795 modaitdm_reaper_spawn_score 1213 modaitdm_titan_spawn_score 0 scorelimit 2537 timelimit 32"
pause
GOTO:Start