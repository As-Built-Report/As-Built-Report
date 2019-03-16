@{
    RootModule = 'AsBuiltReport.psm1'
    ModuleVersion = '0.4.0'
    GUID = 'a1c8a406-8896-4d7d-8e23-68cbd06eb570'
    Author = 'Tim Carman'
    Copyright = '(c) 2018 Tim Carman. All rights reserved.'
    Description = 'A PowerShell module to generate as built reports on the configuration of datacentre infrastucture.'
    PowerShellVersion = '3.0'
    RequiredModules = @(
        @{
            ModuleName = 'PScribo'
            ModuleVersion = '0.7.24'
        },
        'AsBuiltReport.VMware.vSphere'
        'AsBuiltReport.VMware.NSXv'
        'AsBuiltReport.PureStorage.FlashArray'
    )
    FunctionsToExport = @(
        'New-AsBuiltReport'
        'New-AsBuiltConfig'
        'New-AsBuiltReportConfig'
    )
    PrivateData = @{

        PSData = @{
            Tags = @('AsBuiltReport', 'Report', 'Documentation', 'PScribo')
            LicenseUri = 'https://raw.githubusercontent.com/AsBuiltReport/AsBuiltReport/master/LICENSE'
            ProjectUri = 'https://github.com/AsBuiltReport'
            # IconUri = ''
            # ReleaseNotes = ''
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}