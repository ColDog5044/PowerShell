function Get-SystemInformation {

    <#
    .SYNOPSIS
    Retrieves system information such as operating system details, processor information, memory details, GPU information, and network adapter information.

    .DESCRIPTION
    This function retrieves various system information based on the detected operating system (Windows or Linux). It displays the system name, operating system details, processor information, memory details, GPU information, and network adapter information. The output can be optionally dumped into a text file.

    .PARAMETER OutputFile
    Specifies the name of the text file to which the output should be dumped. If this parameter is not provided, the output will be displayed in the console.

    .PARAMETER OperatingSystem
    Specifies whether to display only operating system information.

    .PARAMETER Processor
    Specifies whether to display only processor information.

    .PARAMETER Memory
    Specifies whether to display only memory information.

    .PARAMETER GPU
    Specifies whether to display only GPU information.

    .PARAMETER NetworkAdapter
    Specifies whether to display only network adapter information.

    .EXAMPLE
    Get-SystemInformation -OutputFile "system_info.txt"
    This command retrieves system information and dumps it into a text file named "system_info.txt".

    .EXAMPLE
    Get-SystemInformation -Memory
    This command retrieves only memory information and displays it in the console.
    #>

    [CmdletBinding()]
    param (
        [string]$OutputFile = "",
        [switch]$OperatingSystem,
        [switch]$Processor,
        [switch]$Memory,
        [switch]$GPU,
        [switch]$NetworkAdapter
    )

    # Detect the operating system
    if ($env:OS -like "*Windows*") {
        $os = "Windows"
    } elseif ($env:OS -like "*Linux*") {
        $os = "Linux"
    } else {
        Write-Output "Unable to determine the operating system."
        exit
    }

    # Get the system name
    $systemName = hostname

    # Display system information based on the operating system
    if ($os -eq "Windows") {
        $osInfo = Get-WmiObject Win32_OperatingSystem | Select-Object Caption, Version, OSArchitecture, Manufacturer
        $processorInfo = Get-WmiObject Win32_Processor | Select-Object Name, Manufacturer, MaxClockSpeed, NumberOfCores
        $memoryInfo = Get-WmiObject Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum | ForEach-Object { "{0:N2} GB" -f ($_.Sum / 1GB) }
        $gpuInfo = Get-WmiObject Win32_VideoController | Select-Object Name, AdapterRAM, DriverVersion
        $networkInfo = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true } | Select-Object Description, IPAddress
    } elseif ($os -eq "Linux") {
        $osInfo = cat /etc/os-release
        $processorInfo = cat /proc/cpuinfo
        $memoryInfo = free -h
        $gpuInfo = lspci | grep -i vga
        $networkInfo = ip addr show
    }

    # Display system name
    Write-Output "System Name: $systemName`n"

    # Display system information based on specified categories
    if ($OperatingSystem) {
        Write-Output "Operating System Information"
        $osInfo | Format-Table -AutoSize
    }
    if ($Processor) {
        Write-Output "Processor Information"
        $processorInfo | Format-Table -AutoSize
    }
    if ($Memory) {
        Write-Output "Memory Information"
        $memoryInfo | Format-Table -AutoSize
    }
    if ($GPU) {
        Write-Output "GPU Information"
        $gpuInfo | Format-Table -AutoSize
    }
    if ($NetworkAdapter) {
        Write-Output "Network Adapter Information"
        $networkInfo | Format-Table -AutoSize
    }

    # Dump output to a text file if specified
    if ($OutputFile -ne "") {
        Out-File -FilePath $OutputFile -InputObject $("System Name: $systemName`n" +
                                                      $(if ($OperatingSystem) {"Operating System Information`n" + ($osInfo | Out-String)})
                                                      $(if ($Processor) {"Processor Information`n" + ($processorInfo | Out-String)})
                                                      $(if ($Memory) {"Memory Information`n" + ($memoryInfo | Out-String)})
                                                      $(if ($GPU) {"GPU Information`n" + ($gpuInfo | Out-String)})
                                                      $(if ($NetworkAdapter) {"Network Adapter Information`n" + ($networkInfo | Out-String)}))
        Write-Output "Output has been dumped to $OutputFile"
    }
}
