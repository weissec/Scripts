# Usage: .\PSPinger.ps1 -startIP "192.168.1.1" -endIP "192.168.1.50" -outFile "C:\temp\Pingresults.txt"

param (
    [string]$startIP = "192.168.1.1",
    [string]$endIP = "192.168.1.254",
    [string]$outFile = "PingResults.txt"
)

Write-Host "------------------------------------------------------------------"
Write-Host "           PSPINGER - Quick IP Range ICMP Discovery`n"
Write-Host "------------------------------------------------------------------"

function ConvertTo-IPAddress {
    param (
        [string]$ip
    )
    return [System.Net.IPAddress]::Parse($ip)
}

function IPAddressToLong {
    param (
        [System.Net.IPAddress]$ip
    )
    $bytes = $ip.GetAddressBytes()
    [System.Array]::Reverse($bytes)
    return [BitConverter]::ToUInt32($bytes, 0)
}

function LongToIPAddress {
    param (
        [uint32]$long
    )
    $bytes = [BitConverter]::GetBytes($long)
    [System.Array]::Reverse($bytes)
    return [System.Net.IPAddress]::new($bytes)
}

function Get-IPRange {
    param (
        [string]$startIP,
        [string]$endIP
    )
    $start = IPAddressToLong (ConvertTo-IPAddress $startIP)
    $end = IPAddressToLong (ConvertTo-IPAddress $endIP)
    $ips = @()

    for ($i = $start; $i -le $end; $i++) {
        $ips += (LongToIPAddress $i).ToString()
    }
    return $ips
}

$ips = Get-IPRange -startIP $startIP -endIP $endIP
$totalIPs = $ips.Count
$jobs = @()
Write-Host "[-] Total number of IP Addresses to check: $totalIPs"

ForEach ($i in $ips) {
    $jobs += Start-Job -ScriptBlock {
        param ($ip)
        $result = ""
        $ping = Test-Connection -ComputerName $ip -Count 1 -Quiet
        If ($ping) {
            try {
                $hostname = [System.Net.Dns]::GetHostEntry($ip).HostName
            } catch {
                $hostname = "Hostname not found"
            }
            $result = "$ip - $hostname"
        }
        $result
    } -ArgumentList $i
}

For ($j = 0; $j -lt $jobs.Count; $j++) {
    $current = $j + 1
    $percentComplete = [math]::Round(($current / $totalIPs) * 100, 2)
    Write-Host "[+] Checked: $current of $totalIPs IP Addresses ($percentComplete%)             `r" -NoNewline

    $jobs[$j] | Wait-Job | Out-Null
    $result = Receive-Job -Job $jobs[$j]
    If ($result) {
        $pingResults += $result
	Add-Content -Path $outFile -Value $result
    }
    Remove-Job -Job $jobs[$j]
}

Write-Host "`n[-] All done. Number of Live Hosts found: $($pingResults.Count)"
Write-Host "[-] Ping results saved to: $outFile"

