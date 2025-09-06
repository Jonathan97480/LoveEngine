@echo off
echo Lancement de l'editeur de scenes LoveEngine...
cd /d "%~dp0"
love . --mode=dev
pause
