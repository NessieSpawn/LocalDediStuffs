@echo off
:Start
NorthstarLauncher.exe -dedicated -multiple -profile="R2Northstar_LocalDS" +sv_max_props_multiplayer 500000 +sv_max_prop_data_dwords_multiplayer 800000 +setplaylist aitdm +mp_gamemode aitdm +map mp_relic02 +setplaylistvaroverrides "classic_mp 0 night_enabled 1 enable_friendly_fire 1 random_titan_execution 1 aitdm_extended_spawns 1 modaitdm_rare_specialist_chance 0.3 modaitdm_boss_replace_chance 0.2 modaitdm_squad_count 5 modaitdm_squad_count_high_level 4 modaitdm_prowler_count 3 modaitdm_reaper_count 3 modaitdm_gunship_count 0 modaitdm_pilot_count 4 modaitdm_spectre_spawn_score 0 modaitdm_stalker_spawn_score 0 modaitdm_reaper_spawn_score 0 modaitdm_titan_spawn_score 0 scorelimit 2537 timelimit 22"
pause
GOTO:Start