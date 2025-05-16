@echo off
:Start
NorthstarLauncher.exe -dedicated -multiple -profile="R2Northstar_LocalDS" +setplaylist ps +mp_gamemode ps +map mp_angel_city +setplaylistvaroverrides ""
pause
GOTO:Start