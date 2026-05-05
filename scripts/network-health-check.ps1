# Basic Network Health Check Script

$devices = @(
    "8.8.8.8",
    "1.1.1.1"
)

foreach ($device in $devices) {

    $result = Test-Connection -ComputerName $device -Count 2 -Quiet

    if ($result) {
        Write-Host "$device is reachable"
    }
    else {
        Write-Host "$device is NOT reachable"
    }
}

# Check DNS resolution
Write-Output "`nChecking DNS resolution..."

try {
    Resolve-DnsName google.com -ErrorAction Stop
    Write-Output "DNS resolution working"
} catch {
    Write-Output "DNS resolution failed"
}

# End of script
Write-Output "`nHealth check completed."
