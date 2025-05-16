@echo off
:Start
NorthstarLauncher.exe -dedicated -multiple -profile="R2Northstar_LocalDS" +setplaylist ps +mp_gamemode ps +map mp_homestead +setplaylistvaroverrides "riff_player_bleedout 1 player_bleedout_forceHolster 1 player_bleedout_bleedoutTime 15 player_bleedout_firstAidTime 1 player_bleedout_firstAidTimeSelf 6 player_bleedout_firstAidHealPercent 0.8"
pause
GOTO:Start