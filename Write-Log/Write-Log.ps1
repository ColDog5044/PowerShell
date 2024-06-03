function Write-Log {
    param(
        [Parameter(Mandatory = $true)]
        [string]$message,

        [ValidateSet("Info", "Warning", "Error")]
        [string]$level = "Info",

        [string]$logFile = "path\to\log\file.extension"
    )

    $logEntry = "[$(Get-Date)] [$level] $message"
    Add-Content -Path $logFile -Value $logEntry

    #    # Example usage:
    #    try {
    #        # Some operation that might fail
    #        Get-ChildItem -Path "NonExistentFolder"
    #    }
    #    catch {
    #        # Log the error
    #        Write-Log -Message "An error occurred: $_" -Level "Error"
    #    }
    #
    #    # Log an informational message
    #    Write-Log -Message "Script executed successfully" -Level "Info" # the -Level parameter can be left off since it is set by default
}
