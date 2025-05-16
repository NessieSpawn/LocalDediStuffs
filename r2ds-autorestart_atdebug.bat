@echo off
:Start
NorthstarLauncher.exe -dedicated -multiple -profile="R2Northstar_LocalDS" +setplaylistvaroverrides "classic_mp 0 run_epilogue 0" +setplaylist at +mp_gamemode at +map mp_glitch
pause
GOTO:Start