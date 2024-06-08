# Get Computer Information
$ComputerInformation = Get-WmiObject -Class Win32_ComputerSystem
$OS = Get-WmiObject -Class Win32_OperatingSystem
Write-Output "Domain: $ComputerInformation.Domain"
Write-Output "Manufacturer: $ComputerInformation.Manufacturer"
Write-Output "Model: $ComputerInformation.Model"
Write-Output "Computer Name: $ComputerInformation.Name"
Write-Output "Operating System: $($OS.Caption), Version: $($OS.Version)"

# Get CPU Information
$CPU = Get-WmiObject -Class Win32_Processor
Write-Output "CPU: $($CPU.Name), Cores: $($CPU.NumberOfCores), Threads: $($CPU.ThreadCount)"

# Get GPU Information
$GPU = Get-WmiObject -Class Win32_VideoController
Write-Output "GPU: $($GPU.Name)"
Write-Output "Video Processor: $($GPU.VideoProcessor)"
Write-Output "Driver Version: $($GPU.DriverVersion)"
Write-Output "Current Refresh Rate: $($GPU.CurrentRefreshRate)"

# Get RAM Information
$RAM = Get-WmiObject -Class Win32_ComputerSystem
Write-Output "Total Physical Memory (RAM): $($RAM.TotalPhysicalMemory / 1GB) GB"

# Get Disk Information
$Disks = Get-WmiObject -Class Win32_LogicalDisk
foreach ($d in $Disks) {
    $FreeSpaceGB = [math]::Round($d.FreeSpace / 1GB, 2)
    $SizeGB = [math]::Round($d.Size / 1GB, 2)
    Write-Output "Disk $($d.DeviceID): Total Size: $SizeGB GB, Free Space: $FreeSpaceGB GB"
}

# Get Physical Disk (SMART) Information
$PhysicalDisks = Get-WmiObject -Class Win32_DiskDrive
foreach ($pd in $PhysicalDisks) {
    $SmartStatus = if ($pd.SmartStatus -eq "OK") { "Healthy" } else { "Unhealthy" }
    Write-Output "Physical Disk $($pd.DeviceID): Model: $($pd.Model), SMART Status: $SmartStatus"
}

# Get Network Information
$Network = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled = TRUE"
foreach ($n in $Network) {
    Write-Output "Network Adapter: $($n.Description), IP Address: $($n.IPAddress)"
}

# Get BIOS Information
$BIOS = Get-WmiObject -Class Win32_BIOS
Write-Output "BIOS: $($BIOS.Manufacturer), Version: $($BIOS.SMBIOSBIOSVersion), Serial Number: $($BIOS.SerialNumber)"

# Get Motherboard Information
$Motherboard = Get-WmiObject -Class Win32_BaseBoard
Write-Output "Motherboard: $($Motherboard.Manufacturer), Product: $($Motherboard.Product), Serial Number: $($Motherboard.SerialNumber)"

# Get Monitor Information
$Monitor = Get-WmiObject -Class Win32_DesktopMonitor
Write-Output "Monitor: $($Monitor.Name), Screen Resolution: $($Monitor.ScreenWidth)x$($Monitor.ScreenHeight)"

# Get Printer Information
#$Printer = Get-WmiObject -Class Win32_Printer
#foreach ($p in $Printer) {
#    Write-Output "Printer: $($p.Name), Status: $($p.Status)"
#}

# Get Software Information
#$Software = Get-WmiObject -Class Win32_Product
#foreach ($s in $Software) {
#    Write-Output "Software: $($s.Name), Version: $($s.Version)"
#}

# Get User Account Information
$UserAccounts = Get-WmiObject -Class Win32_UserAccount
$EnabledAccounts = $UserAccounts | Where-Object { $_.Disabled -eq $false }
$DisabledAccounts = $UserAccounts | Where-Object { $_.Disabled -eq $true }

Write-Output "Enabled User Accounts:"
foreach ($u in $EnabledAccounts) {
    Write-Output "User Account: $($u.Name)"
}

Write-Output "Disabled User Accounts:"
foreach ($u in $DisabledAccounts) {
    Write-Output "User Account: $($u.Name)"
}

# Get Accounts in the Administrator Group
$AdminGroup = Get-WmiObject -Class Win32_Group -Filter "Name='Administrators'"
$AdminGroupUsers = Get-WmiObject -Class Win32_GroupUser -Filter "GroupComponent=`"Win32_Group.Domain='$($AdminGroup.Domain)',Name='$($AdminGroup.Name)'`""
Write-Output "Accounts in the Administrator Group:"
foreach ($u in $AdminGroupUsers) {
    $User = ($u.PartComponent -split (",")[1]).Replace("`"", "")
    Write-Output "User Account: $User"
}

# Get Network Interface Information
#$NetworkInterface = Get-WmiObject -Class Win32_NetworkAdapter
#foreach ($ni in $NetworkInterface) {
#    Write-Output "Network Interface: $($ni.Name), Status: $($ni.Status)"
#}

# Get Battery Information
$Battery = Get-WmiObject -Class Win32_Battery
if ($Battery) {
    Write-Output "Battery: $($Battery.Name)"
    Write-Output "Status: $($Battery.Status)"
    Write-Output "Battery Full Charged Capacity: $($Battery.FullChargeCapacity)"
    Write-Output "Battery Current Capacity: $($Battery.EstimatedChargeRemaining)"
    Write-Output "Battery Health: $(($Battery.EstimatedChargeRemaining/$Battery.FullChargeCapacity)*100)%"
    Write-Output "Battery Life Time: $($Battery.ExpectedLife)"
    Write-Output "Battery Voltage: $($Battery.Voltage)"
}

# Get System Uptime
$UptimeInSeconds = (Get-WmiObject -Class Win32_PerfFormattedData_PerfOS_System).SystemUpTime
$Uptime = [TimeSpan]::FromSeconds($UptimeInSeconds)
Write-Output "System Uptime: $($Uptime.ToString('hh\:mm\:ss'))"

# Get Performance Data
$CPUUsage = (Get-WmiObject -Class Win32_PerfFormattedData_PerfOS_Processor | Where-Object { $_.Name -eq "_Total" }).PercentProcessorTime
$MemoryUsage = (Get-WmiObject -Class Win32_PerfFormattedData_PerfOS_Memory).PercentCommittedBytesInUse

# Get Disk Read/Write in MB
$DiskRead = [Math]::Round((Get-Counter -Counter "\LogicalDisk(_Total)\Disk Read Bytes/sec").CounterSamples.CookedValue / 1MB, 2)
$DiskWrite = [Math]::Round((Get-Counter -Counter "\LogicalDisk(_Total)\Disk Write Bytes/sec").CounterSamples.CookedValue / 1MB, 2)

# Get Network Download/Upload in MB/sec
$NetworkDownload = [Math]::Round(((Get-Counter -Counter "\Network Interface(*)\Bytes Received/sec").CounterSamples | Where-Object { $_.InstanceName -eq 'your_network_interface' } | Select-Object -ExpandProperty CookedValue) / 1MB, 2)
$NetworkUpload = [Math]::Round(((Get-Counter -Counter "\Network Interface(*)\Bytes Sent/sec").CounterSamples | Where-Object { $_.InstanceName -eq 'your_network_interface' } | Select-Object -ExpandProperty CookedValue) / 1MB, 2)

Write-Output "Average CPU Usage: $($CPUUsage)% , Memory Usage: $($MemoryUsage)% , Disk Read: $($DiskRead) MB/sec, Disk Write: $($DiskWrite) MB/sec, Network Download: $($NetworkDownload) MB/sec, Network Upload: $($NetworkUpload) MB/sec"

# Get Security Settings
# Get Firewall Status
$FirewallProfiles = Get-NetFirewallProfile
foreach ($fp in $FirewallProfiles) {
    Write-Output "Firewall Profile: $($fp.Name), Enabled: $($fp.Enabled)"
}

# Get Windows Defender Status
$DefenderService = Get-Service -Name WinDefend
Write-Output "Windows Defender Status: $($DefenderService.Status)"

# Get UAC Status
$UAC = (Get-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System).EnableLUA
if ($UAC -eq 1) {
    Write-Output "User Account Control (UAC): Enabled"
}
else {
    Write-Output "User Account Control (UAC): Disabled"
}

# Get Scheduled Tasks
$ScheduledJobs = Get-WmiObject -Class Win32_ScheduledJob
foreach ($j in $ScheduledJobs) {
    Write-Output "Scheduled Job: $($j.JobId), Command: $($j.Command), Next Run Time: $($j.NextRunTime)"
}