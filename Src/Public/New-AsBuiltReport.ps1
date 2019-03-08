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
    .PARAMETER Username
    Specifies the username for the target system.
    .PARAMETER Password
    Specifies the password for the target system.
    .PARAMETER Format
        Specifies the output format of the report.
        The supported output formats are WORD, HTML, XML & TEXT.
        Multiple output formats may be specified, separated by a comma.
    .PARAMETER Orientation
        Sets the report page orientation to Portrait or Landscape
        By default, page orientation will be set to Portrait
    .PARAMETER StylePath
        Specifies the path to a custom style script for the report to use.
    .PARAMETER OutputPath
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
    .PARAMETER ReportConfigPath
        Enter the full path to a report JSON configuration file
        If this parameter is not specified, the script will attempt to use a default configuration JSON in the
        specified in the UserFolder.Path section of the AsbuiltReport configuration
        If this paramter is specified and the path to a JSON file is invalid, the script will terminate
    .EXAMPLE
        PS C:\>New-AsBuiltReport -Target 192.168.1.100 -Username admin -Password admin -Format HTML,Word -Report VMware.vSphere -Healthchecks

        Creates a VMware vSphere As Built Document in HTML & Word formats. The document will highlight particular issues which exist within the environment.
    .EXAMPLE
        PS C:\>$Creds = Get-Credential
        PS C:\>New-AsBuiltReport -Target 192.168.1.100 -Credential $Creds -Format Text -Report PureStorage.FlashArray -Timestamp

        Creates a Pure Storage FlashArray As Built document in Text format and appends a timestamp to the filename. Uses stored credentials to connect to system.
    .EXAMPLE
        PS C:\>New-AsBuiltReport -Target 192.168.1.100 -Username admin -Password admin -Report Cisco.UCSManager -StylePath c:\scripts\AsBuiltReport\Styles\ACME.ps1

        Creates a Cisco UCS As Built document in default format (Word) with a customised style.
    .EXAMPLE
        PS C:\>New-AsBuiltReport -Target 192.168.1.100 -Username admin -Password admin -Report Nutanix.AOS -SendEmail

        Creates a Nutanix AOS As Built document in default format (Word). Report will be attached and sent via email.
    .EXAMPLE
        PS C:\>New-AsBuiltReport -Target 192.168.1.100 -Username admin -Password admin -Format HTML -Report VMware.vSphere -AsBuiltConfigPath C:\scripts\asbuilt.json
        
        Creates a VMware vSphere As Built Document in HTML format, using the configuration in the asbuilt.json file located in the C:\scripts\ folder.
    .NOTES
        Version:        0.3.0
        Author(s):      Tim Carman / Matt Allford
        Twitter:        @tpcarman / @mattallford
        Github:         AsBuiltReport
        Credits:        Iain Brighton (@iainbrighton) - PScribo module
                        
    .LINK
        https://github.com/AsBuiltReport
        https://github.com/iainbrighton/PScribo
    #>

    #region Script Parameters
    [CmdletBinding()]
    param (
        [Parameter(
            Position = 0,
            Mandatory = $true,
            HelpMessage = 'Please specify which report type you wish to run.'
        )]
        [ValidateScript( {
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
            Position = 4,
            Mandatory = $false,
            HelpMessage = 'Determines the document page orientation'
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Portrait', 'Landscape')]
        [String] $Orientation = 'Portrait',

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Please provide the username to connect to the target system'
        )]
        [ValidateNotNullOrEmpty()]
        [String] $Username,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Please provide the password to connect to the target system'
        )]
        [ValidateNotNullOrEmpty()]
        [String] $Password,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Please provide the path to the custom style script'
        )]
        [ValidateNotNullOrEmpty()] 
        [String] $StylePath,

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
        [String] $OutputPath,

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
            HelpMessage = 'Provide the file path to an existing As Built JSON Configuration file'
        )]
        [string] $AsBuiltConfigPath,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Provide the file path to an existing report JSON Configuration file'
        )]
        [string] $ReportConfigPath
    )

    #endregion Script Parameters
    try {

        # Check credentials have been supplied
        if ($Credential -and (!($Username -and !($Password)))) {
        } Elseif (($Username -and $Password) -and !($Credential)) {
            # Convert specified Password to secure string
            $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ($Username, $SecurePassword)
        } Elseif (!$Credential -and (!($Username -and !($Password)))) {
            Write-Error "Please supply credentials to connect to $Target"
            Break
        }

        #region Variable config

        #Import the AsBuiltReport JSON configuration file
        #If no path was specified, or the specified file doesn't exist, call New-AsBuiltConfig to walk the user through the menu prompt to create a config JSON
        if ($AsbuiltConfigPath) {
            if (Test-Path -Path $AsBuiltConfigPath) {
                $Global:AsBuiltConfig = Get-Content -Path $AsBuiltConfigPath | ConvertFrom-Json
                <#
                if ($Timestamp) {
                    $FileName = $Global:AsBuiltConfig.Report.Name + " - " + (Get-Date -Format 'yyyy-MM-dd_HH.mm.ss')
                } else {
                    $FileName = $Global:AsBuiltConfig.Report.Name
                }
                #>
            }
        } else {
            $Global:AsBuiltConfig = New-AsBuiltConfig
        }

        #If Stylepath was specified, ensure the file provided in the path exists, otherwise exit with error
        if ($StylePath) {
            if (!(Test-Path -Path $StylePath)) {
                Write-Error "Could not find a style script at $StylePath"
                break
            }
        }

        $ReportModule = "AsBuiltReport.$Report"

        if ($ReportConfigPath) {
            #If ReportConfigPath was specified, ensure the file provided in the path exists, otherwise exit with error
            if (!(Test-Path -Path $ReportConfigPath)) {
                Write-Error "Could not find a style script at $ReportConfigPath"
                break
            } else {
                #Import the Report Configuration in to a variable
                $Global:ReportConfig = Get-Content -Path $ReportConfigPath | ConvertFrom-Json
            }
        } else {
            #If a report config hasn't been provided, check for the existance of the default JSON in the paths the user specified in base config
            $ReportConfigPath = Join-Path -Path $AsBuiltConfig.UserFolder.Path -ChildPath "$ReportModule.json"
            
            if (Test-Path -Path $ReportConfigPath) {
                $Global:ReportConfig = Get-Content -Path $ReportConfigPath | ConvertFrom-Json
                if ($Timestamp) {
                    $FileName = $Global:ReportConfig.Report.Name + " - " + (Get-Date -Format 'yyyy-MM-dd_HH.mm.ss')
                } else {
                    $FileName = $Global:ReportConfig.Report.Name
                }
            } else {
                #Create the report JSON and save it in the UserFolder specified in the Base Config
                New-AsBuiltReportConfig -Report $Report -Path $AsBuiltConfig.UserFolder.Path
                $Global:ReportConfig = Get-Content -Path $ReportConfigPath | ConvertFrom-Json
                if ($Timestamp) {
                    $FileName = $Global:ReportConfig.Report.Name + " - " + (Get-Date -Format 'yyyy-MM-dd_HH.mm.ss')
                } else {
                    $FileName = $Global:ReportConfig.Report.Name
                }
            }#End if test-path
        }#End if ReportConfigPath

        #endregion Variable config

        #region Generate PScribo document
        $AsBuiltReport = Document $FileName -Verbose {
            #Set Document Style
            if ($StylePath) {
                .$StylePath
            }

            & "Invoke-$($ReportModule)" -Target $Target -Credential $Credential -StyleName $StylePath
        }
        Try {
            $AsBuiltReport | Export-Document -Path $OutputPath -Format $Format
            Write-Output "$FileName has been saved to $OutputPath"
        } catch {
            $Err = $_
            Write-Error $Err
        }
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
