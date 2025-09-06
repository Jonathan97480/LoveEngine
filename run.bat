@echo off
REM Scripts de lancement pour LoveEngine

if "%1"=="dev" goto dev
if "%1"=="game" goto game
if "%1"=="help" goto help

echo Usage: run.bat [dev|game|help]
echo.
echo Modes disponibles:
echo   dev  - Mode développement (par défaut)
echo   game - Mode jeu normal
echo   help - Afficher cette aide
echo.
echo Exemples:
echo   run.bat dev
echo   run.bat game
goto end

:dev
echo Lancement du mode Développement...
love . --dev
goto end

:game
echo Lancement du mode Jeu...
love . --game
goto end

:help
echo.
echo === LoveEngine Launcher ===
echo.
echo Ce script facilite le lancement des différents modes de LoveEngine.
echo.
echo MODES:
echo ------
echo dev: Mode développement avec interface d'outils
echo      - Console de debug (F1)
echo      - Éditeur de scènes (F2)
echo      - Inspecteur d'objets (F3)
echo      - Fond bleu foncé
echo.
echo game: Mode jeu normal
echo       - Jeu sans outils de développement
echo       - Fond gris
echo       - ESC pour retourner au mode dev
echo.
echo UTILISATION:
echo -----------
echo run.bat dev   - Lancer le mode développement
echo run.bat game  - Lancer le mode jeu
echo run.bat help  - Afficher cette aide
echo.
echo SANS ARGUMENT:
echo -------------
echo run.bat       - Lance automatiquement le mode dev (par défaut)
echo.
goto end

:end
