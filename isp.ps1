param (
    [string]$Target1 = "8.8.4.4",
    [string]$Target2 = "1.0.0.1"
)

Clear-Host
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " Перевірка зв'язку з ISP лініями (Ctrl+C для виходу)" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Шлюз 1 / Хост: $Target1"
Write-Host "Шлюз 2 / Хост: $Target2"
Write-Host "--------------------------------------------------" -ForegroundColor Gray

# Ініціалізація лічильників статистики
$Global:TotalChecks = 0
$Global:LostISP1 = 0
$Global:LostISP2 = 0

$PingSender = New-Object System.Net.NetworkInformation.Ping
$Timeout = 1000 # Таймаут в мс

while ($true) {
    $time = Get-Date -Format "HH:mm:ss"
    $Global:TotalChecks++

    # --- ТЕСТ ISP 1 ---
    try {
        $reply1 = $PingSender.Send($Target1, $Timeout)
        if ($reply1.Status -eq "Success") {
            Write-Host "[$time] ISP-1 ($Target1): " -NoNewline -ForegroundColor Gray
            Write-Host "OK " -NoNewline -ForegroundColor Green
            Write-Host "($($reply1.RoundtripTime)ms)" -ForegroundColor Gray
        } else {
            $Global:LostISP1++
            Write-Host "[$time] ISP-1 ($Target1): " -NoNewline -ForegroundColor Gray
            Write-Host "DOWN ❌ ($($reply1.Status))" -ForegroundColor Red
        }
    } catch {
        $Global:LostISP1++
        Write-Host "[$time] ISP-1 ($Target1): " -NoNewline -ForegroundColor Gray
        Write-Host "ERROR ❌ (Помилка хоста)" -ForegroundColor Red
    }

    # --- ТЕСТ ISP 2 ---
    try {
        $reply2 = $PingSender.Send($Target2, $Timeout)
        if ($reply2.Status -eq "Success") {
            Write-Host "[$time] ISP-2 ($Target2): " -NoNewline -ForegroundColor Gray
            Write-Host "OK " -NoNewline -ForegroundColor Green
            Write-Host "($($reply2.RoundtripTime)ms)" -ForegroundColor Gray
        } else {
            $Global:LostISP2++
            Write-Host "[$time] ISP-2 ($Target2): " -NoNewline -ForegroundColor Gray
            Write-Host "DOWN ❌ ($($reply2.Status))" -ForegroundColor Red
        }
    } catch {
        $Global:LostISP2++
        Write-Host "[$time] ISP-2 ($Target2): " -NoNewline -ForegroundColor Gray
        Write-Host "ERROR ❌ (Помилка хоста)" -ForegroundColor Red
    }

    # --- РОЗРАХУНОК СТАТИСТИКИ ---
    $LossPercent1 = [Math]::Round(($Global:LostISP1 / $Global:TotalChecks) * 100, 1)
    $LossPercent2 = [Math]::Round(($Global:LostISP2 / $Global:TotalChecks) * 100, 1)

    # Визначення кольору тексту (якщо є втрати — підсвічуємо Yellow, якщо все супер — DarkGray)
    $Color1 = if ($Global:LostISP1 -gt 0) { "Yellow" } else { "DarkGray" }
    $Color2 = if ($Global:LostISP2 -gt 0) { "Yellow" } else { "DarkGray" }

    # Вивід статистики в консоль
    Write-Host "Статистика пакетів (Всього: $Global:TotalChecks) | " -NoNewline -ForegroundColor DarkGray
    Write-Host "ISP-1 Втрачено: $Global:LostISP1 ($LossPercent1%) | " -NoNewline -ForegroundColor $Color1
    Write-Host "ISP-2 Втрачено: $Global:LostISP2 ($LossPercent2%)" -ForegroundColor $Color2

    Write-Host "--------------------------------------------------" -ForegroundColor DarkGray
    Start-Sleep -Seconds 2
}
