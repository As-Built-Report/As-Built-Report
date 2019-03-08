function New-AsBuiltReportConfig {
    param (
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'Please provide the name of the report to generate the JSON configuration for'
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateSet(
            'all',
            'VMware.vSphere',
            'VMware.NSXv',
            'PureStorage.FlashArray',
            'Cisco.UCSManager',
            'HPE.NimbleStorage'
        )]
        [String] $Report,

        [Parameter(
            Mandatory = $true,
            HelpMessage = 'Please provide the path to save the JSON configuration file'
        )]
        [ValidateNotNullOrEmpty()]
        [String] $Path
    )

    #Test to ensure the path the user has specified does exist
    if (!(Test-Path -Path $Path)) {
        Write-Error "The Path $Path does not exist. Please create the folder and re-run New-AsBuiltReportConfig"
        break
    }
    #Find the root folder where the module is located for the report that has been specified
    if ($Report -eq "all") {
        try {
            $AsBuiltReportModules = Get-Module -Name "AsBuiltReport.*"
            Foreach ($AsBuiltReportModule in $AsBuiltReportModules) {
                Copy-Item -Path "$($AsBuiltReportModule.ModuleBase)\$($AsBuiltReportModule.Name).json" -Destination $Path -Force
            }
        }
        catch {
            Write-Error $_
        }
    } else {
        try {
            $Module = Get-Module "AsBuiltReport.$Report"
            Copy-Item -Path "$($Module.ModuleBase)\$($Module.Name).json" -Destination $Path -Force
        }
        catch {
            Write-Error $_
        }
    }
}
