function Get-SystemInfo {
    [CmdletBinding()]
    param(
        [switch]$Processor,
        [switch]$Memory,
        [switch]$Graphics,
        [switch]$Disk,
        [switch]$Network,
        [switch]$System
    )

    # Determine the operating system
    if ($env:OS -like 'Windows*') {
        $OperatingSystem = "Windows"
    } elseif ($IsLinux -eq $true) {
        $OperatingSystem = "Linux"
    } else {
        $OperatingSystem = "Unknown"
    }

    # Define an empty hashtable to store system information
    $SystemInfo = @{}

    # Function to get BIOS information
    function Get-BIOSInfo {
        if ($OperatingSystem -eq "Windows") {
            $biosInfo = Get-WmiObject -Class Win32_BIOS
            $SystemInfo.Add("BIOS", @{
                "Manufacturer" = $biosInfo.Manufacturer
                "Version" = $biosInfo.SMBIOSBIOSVersion
                "ReleaseDate" = $biosInfo.ReleaseDate
            })
        }
    }

    # Function to get operating system information
    function Get-OSInfo {
        if ($OperatingSystem -eq "Windows") {
            $osInfo = Get-WmiObject -Class Win32_OperatingSystem
            $SystemInfo.Add("OperatingSystem", @{
                "Caption" = $osInfo.Caption
                "Version" = $osInfo.Version
                "BuildNumber" = $osInfo.BuildNumber
            })
        } elseif ($OperatingSystem -eq "Linux") {
            $SystemInfo.Add("OperatingSystem", @{
                "Kernel" = "$(uname -s)"
                "KernelVersion" = "$(uname -r)"
            })
        }
    }

    # Function to get processor information
    function Get-ProcessorInfo {
        if ($OperatingSystem -eq "Windows") {
            $processorInfo = Get-WmiObject -Class Win32_Processor
            $SystemInfo.Add("Processor", @{
                "Name" = $processorInfo.Name
                "NumberOfCores" = $processorInfo.NumberOfCores
                "MaxClockSpeed(GHz)" = "{0:N2}" -f ($processorInfo.MaxClockSpeed / 1GB)
            })
        } elseif ($OperatingSystem -eq "Linux") {
            $processorInfo = $(grep 'model name' /proc/cpuinfo | sort -u | awk -F': ' '{print $2}')
            $SystemInfo.Add("Processor", @{
                "Name" = $processorInfo
            })
        }
    }

    # Function to get memory information
    function Get-MemoryInfo {
        if ($OperatingSystem -eq "Windows") {
            $memoryInfo = Get-WmiObject -Class Win32_PhysicalMemory
            $TotalMemoryGB = ($memoryInfo | Measure-Object -Property Capacity -Sum).Sum / 1GB
            $SystemInfo.Add("Memory", @{
                "TotalMemory(GB)" = "{0:N2}" -f $TotalMemoryGB
            })
        } elseif ($OperatingSystem -eq "Linux") {
            $memoryInfo = $(grep MemTotal /proc/meminfo | awk '{print $2}')
            $TotalMemoryGB = $memoryInfo / 1024 / 1024
            $SystemInfo.Add("Memory", @{
                "TotalMemory(GB)" = "{0:N2}" -f $TotalMemoryGB
            })
        }
    }

    function Get-GraphicsInfo {
        if ($OperatingSystem -eq "Windows") {
            $graphicsInfo = Get-WmiObject -Class Win32_VideoController
            $GraphicsList = @()
            foreach ($graphics in $graphicsInfo) {
                $GraphicsList += @{
                    "Name" = $graphics.Name
                    "AdapterRAM(MB)" = "{0:N2}" -f ($graphics.AdapterRAM / 1MB)
                    "DriverVersion" = $graphics.DriverVersion
                }
            }
            $SystemInfo.Add("Graphics", $GraphicsList)
        }
    }
    
    function Get-DiskInfo {
        if ($OperatingSystem -eq "Windows") {
            $diskInfo = Get-WmiObject -Class Win32_DiskDrive
            $DiskList = @()
            foreach ($disk in $diskInfo) {
                $DiskList += @{
                    "Model" = $disk.Model
                    "Size(GB)" = "{0:N2}" -f ($disk.Size / 1GB)
                    "InterfaceType" = $disk.InterfaceType
                }
            }
            $SystemInfo.Add("Disk", $DiskList)
        }
    }
    
    function Get-NetworkInfo {
        if ($OperatingSystem -eq "Windows") {
            $networkInfo = Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled }
            $NetworkList = @()
            foreach ($network in $networkInfo) {
                $NetworkList += @{
                    "Adapter" = $network.Description
                    "IPAddress" = $network.IPAddress -join ","
                    "MACAddress" = $network.MACAddress
                }
            }
            $SystemInfo.Add("Network", $NetworkList)
        }
    }    

    # Call functions based on specified parameters
    if ($System) { Get-OSInfo }
    if ($Processor) { Get-ProcessorInfo }
    if ($Memory) { Get-MemoryInfo }
    if ($Graphics) { Get-GraphicsInfo }
    if ($Disk) { Get-DiskInfo }
    if ($Network) { Get-NetworkInfo }
    if (-not ($System -or $Processor -or $Memory -or $Graphics -or $Disk -or $Network)) {
        Get-BIOSInfo
        Get-OSInfo
        Get-ProcessorInfo
        Get-MemoryInfo
        Get-GraphicsInfo
        Get-DiskInfo
        Get-NetworkInfo
    }

    # Generate the filename with current date and time
    $DateTime = Get-Date -Format "yyyy-MM-dd-HH-mm-ss"
    $FileName = "$DateTime.json"

    # Export system information to JSON file
    $SystemInfo | ConvertTo-Json | Out-File -FilePath $FileName
}
