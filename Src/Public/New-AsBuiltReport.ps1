function New-AsBuiltReport {
    <#
    .SYNOPSIS  
        Documents the configuration of IT infrastructure in Word/HTML/XML/Text formats using PScribo.
    .DESCRIPTION
        Documents the configuration of IT infrastructure in Word/HTML/XML/Text formats using PScribo.
    .PARAMETER Report
        Specifies the type of report that will be generated.
    .PARAMETER Target
        Specifies the IP/FQDN of the system to connect.
        Specifying multiple Targets (separated by a comma) is supported for some As-Built reports.
    .PARAMETER Credentials
        Specifies the credentials of the target system.
    .PARAMETER Format
        Specifies the output format of the report.
        The supported output formats are WORD, HTML, XML & TEXT.
        Multiple output formats may be specified, separated by a comma.
    .PARAMETER StyleName
        Specifies the document style name of the report.
    .PARAMETER Path
        Specifies the path to save the report. If not specified the report will be saved in the script folder.
    .PARAMETER Timestamp
        Specifies whether to append a timestamp string to the report filename.
        By default, the timestamp string is not added to the report filename.
    .PARAMETER Healthchecks
        Highlights certain issues within the system report.
        Some reports may not provide this functionality.
    .PARAMETER SendEmail
        Sends report to specified recipients as email attachments.
    .PARAMETER ConfigPath
        Enter the full patch to a configuration JSON file.
        If this parameter is not specified, the user running the script will be prompted for this 
        configuration information on first run, with the option to save the configuration to a file.
    .EXAMPLE
        PS C:\>New-AsBuiltReport -Target 192.168.1.100 -Username admin -Password admin -Format HTML,Word -Type vSphere -Healthchecks

        Creates a VMware vSphere As Built Document in HTML & Word formats. The document will highlight particular issues which exist within the environment.
    .EXAMPLE
        PS C:\>$Creds = Get-Credential
        PS C:\>New-AsBuiltReport -Target 192.168.1.100 -Credentials $Creds -Format Text -Type FlashArray -Timestamp

        Creates a Pure Storage FlashArray As Built document in Text format and appends a timestamp to the filename. Uses stored credentials to connect to system.
    .EXAMPLE
        PS C:\>New-AsBuiltReport -IP 192.168.1.100 -Username admin -Password admin -Type UCS -StyleName ACME

        Creates a Cisco UCS As Built document in default format (Word) with a customised style.
    .EXAMPLE
        PS C:\>New-AsBuiltReport -IP 192.168.1.100 -Username admin -Password admin -Type Nutanix -SendEmail

        Creates a Nutanix As Built document in default format (Word). Report will be attached and sent via email.
    .EXAMPLE
        PS C:\>New-AsBuiltReport -IP 192.168.1.100 -Username admin -Password admin -Format HTML -Type vSphere -AsBuiltConfigPath C:\scripts\asbuilt.json
        
        Creates a VMware vSphere As Built Document in HTML format, using the configuration in the asbuilt.json file located in the C:\scripts\ folder.
    .NOTES
        Version:        0.3.0
        Author:         Tim Carman
        Twitter:        @tpcarman
        Github:         tpcarman
        Credits:        Iain Brighton (@iainbrighton) - PScribo module
                        Carl Webster (@carlwebster) - Documentation Script Concept
    .LINK
        https://github.com/tpcarman/As-Built-Report
        https://github.com/iainbrighton/PScribo
    #>

    #region Script Parameters
    [CmdletBinding()]
    param (
        [Parameter(
            Position  = 0,
            Mandatory = $true,
            HelpMessage = 'Please specify which report type you wish to run.'
        )]
        [ValidateScript({
            $InstalledReportModules = Get-Module -Name "AsBuiltReport.*"
            $ValidReports = foreach ($InstalledReportModule in $InstalledReportModules) {
                $NameArray = $InstalledReportModule.Name.Split('.')
                "$($NameArray[-2]).$($NameArray[-1])"
            }
            if ($ValidReports -contains $_) {
                $true
            } else {
                throw "Invalid report type specified! Please use one of the following [$($ValidReports -Join ', ')]"
            }
        })]
        [string] $Report,

        [Parameter(
            Position = 1,
            Mandatory = $true,
            HelpMessage = 'Please provide the IP/FQDN of the system',
            ParameterSetName = 'Default'
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('Cluster', 'Server', 'IP')]
        [String[]] $Target,

        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = 'Please provide credentails to connect to the system'
        )]
        [ValidateNotNullOrEmpty()]
        [PSCredential] $Credential,

        [Parameter(
            Position = 3,
            Mandatory = $false,
            HelpMessage = 'Please provide the document output format'
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Word', 'HTML', 'Text', 'XML')]
        [Array] $Format = 'Word',

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Please provide the custom style name'
        )]
        [ValidateNotNullOrEmpty()] 
        [String] $StyleName,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Specify whether to append a timestamp to the document filename'
        )]
        [Switch] $Timestamp = $false,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Please provide the path to the document output file'
        )]
        [ValidateNotNullOrEmpty()] 
        [String] $Path,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Specify whether to highlight any configuration issues within the document'
        )]
        [Switch] $Healthchecks = $false,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Specify whether to send report via Email'
        )]
        [Switch] $SendEmail = $false,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Provide the file path to an existing As Built Configuration file'
        )]
        [string] $ConfigPath
    )

    #endregion Script Parameters
    try {
        #region Variable config
        if ($ConfigPath) {
            if (Test-Path -Path $ConfigPath) {
                $Global:AsBuiltConfig = Get-Content -Path $ConfigPath | ConvertFrom-Json
            }
        } else {
            $NewConfigParams = @{
                'Report' = $Report
                'Timestamp' = $Timestamp
                'SendEmail' = $SendEmail
            }
            $Global:AsBuiltConfig = New-AsBuiltReportConfig @NewConfigParams
        }

        $ReportModule = "AsBuiltReport.$Report"
        $ReportModuleBase = (Get-Module -Name $ReportModule).ModuleBase
        $ReportModuleConfig = Join-Path -Path $ReportModuleBase -ChildPath "$ReportModule.json"

        if (Test-Path -Path $ReportModuleConfig) {
            $Global:ReportConfig = Get-Content -Path $ReportModuleConfig | ConvertFrom-Json
        }
        #endregion Variable config

        #region Generate PScribo document
        $AsBuiltReport = Document $Global:AsBuiltConfig.Report.Name -Verbose {
            & "Invoke-$ReportModule" -Target $Target -Credential $Credential
        }
        $AsBuiltReport | Export-Document -Path $Path -Format $Format
        #endregion Generate PScribo document

        #region Globals cleanup
        Clear-Variable AsBuiltConfig
        Clear-Variable ReportConfig
        #endregion Globals cleanup
    } catch {
        $Err = $_
        Write-Error $Err
    }
}

Register-ArgumentCompleter -CommandName 'New-AsBuiltReport' -ParameterName 'Report' -ScriptBlock {
    param (
        $commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameter
    )

    $InstalledReportModules = Get-Module -Name "AsBuiltReport.*"
    $ValidReports = foreach ($InstalledReportModule in $InstalledReportModules) {
        $NameArray = $InstalledReportModule.Name.Split('.')
        "$($NameArray[-2]).$($NameArray[-1])"
    }

    $ValidReports | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
