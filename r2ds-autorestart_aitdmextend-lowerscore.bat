@echo off
:Start
NorthstarLauncher.exe -dedicated -multiple -profile="R2Northstar_LocalDS" +sv_max_props_multiplayer 500000 +sv_max_prop_data_dwords_multiplayer 800000 +setplaylist aitdm +mp_gamemode aitdm +map mp_rise +setplaylistvaroverrides "max_players 10 modaitdm_stalker_spawn_score 230 modaitdm_reaper_spawn_score 350 shoulder_rockets_fix 1 laser_lite_fix 1 rocketeer_rocketstream_fix 1 random_titan_execution 1 aitdm_extended_spawns 1 aitdm_extended_april_fools 1 aitdm_april_fools_nessy_weapons 0 aitdm_extended_extreme_npc_weapons 1"
pause
GOTO:Start