param(
    [Parameter(Mandatory=$true)]
    [string]$ServiceName
)

Write-Host "=================================================="
Write-Host "Checking status of: $ServiceName"
Write-Host "=================================================="
try {
    $service = Get-Service -Name $ServiceName -ErrorAction Stop
    Write-Host "Service Display Name: $($service.DisplayName)"
    Write-Host "Service Status: $($service.Status)"
} catch {
    Write-Host "Service $ServiceName not found."
    exit 1
}
Write-Host

Write-Host "=================================================="
Write-Host "Is the service enabled (i.e., startup type)?"
Write-Host "=================================================="
$cimService = Get-CimInstance Win32_Service -Filter "Name='$ServiceName'"
if ($cimService) {
    Write-Host "Start Mode: $($cimService.StartMode)" # "Auto", "Manual", or "Disabled"
} else {
    Write-Host "No additional information available."
}
Write-Host

Write-Host "=================================================="
Write-Host "Current state (running, stopped, etc.)"
Write-Host "=================================================="
Write-Host "Status: $($service.Status)"
Write-Host

Write-Host "=================================================="
Write-Host "Dependencies for $ServiceName:"
Write-Host "=================================================="
# sc.exe qc will list the service configuration including dependencies
$scOutput = sc.exe qc $ServiceName
Write-Host $scOutput
Write-Host

Write-Host "=================================================="
Write-Host "Recent logs for $ServiceName:"
Write-Host "=================================================="
# Attempt to filter recent System events for mentions of the service
# Adjust -MaxEvents or use a different filter depending on the service.
$events = Get-WinEvent -LogName System -MaxEvents 50 | Where-Object { $_.Message -like "*$ServiceName*" }
if ($events) {
    $events | Select-Object TimeCreated,Id,LevelDisplayName,Message | Format-Table
} else {
    Write-Host "No recent log events found matching $ServiceName."
}
