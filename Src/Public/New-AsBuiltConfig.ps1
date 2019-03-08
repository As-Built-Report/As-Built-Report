function New-AsBuiltConfig {
    #Run section to prompt user for information about the As Built Report to be exported to JSON format (if saved)
    $global:Config = @{}

    #region Report configuration
    Clear-Host
    Write-Host '---------------------------------------------' -ForegroundColor Cyan
    Write-Host '  <      As Built Report Information      >  ' -ForegroundColor Cyan
    Write-Host '---------------------------------------------' -ForegroundColor Cyan
    #$DefaultReportName = "$($Report.Split('.')[0]) $($Report.Split('.')[1]) - As Built Report"
    $ReportName = Read-Host -Prompt "Enter the name of the As Built report [As Built Report]"
    if (($ReportName -like $null) -or ($ReportName -eq "")) {
        $ReportName = "As Built Report"
    }
    $ReportVersion = Read-Host -Prompt "Enter the As Built report version [1.0]"
    if (($ReportVersion -like $null) -or ($ReportVersion -eq "")) {
        $ReportVersion = "1.0"
    }
    $ReportStatus = Read-Host -Prompt "Enter the As Built report status [Released]"
    if (($ReportStatus -like $null) -or ($ReportStatus -eq "")) {
        $ReportStatus = "Released"
    }
    $ReportAuthor = Read-Host -Prompt "Enter the name of the Author for this As Built report [$env:USERNAME]"
    if (($ReportAuthor -like $null) -or ($ReportAuthor -eq "")) {
        $ReportAuthor = $env:USERNAME
    }

    $Config.Report = @{
        'Name' = $ReportName
        'Version' = $ReportVersion
        'Status' = $ReportStatus
        'Author' = $ReportAuthor
    }
    #endregion Report configuration

    #region Company configuration
    Clear-Host
    Write-Host '---------------------------------------------' -ForegroundColor Cyan
    Write-Host '  <          Company Information          >  ' -ForegroundColor Cyan
    Write-Host '---------------------------------------------' -ForegroundColor Cyan
    $CompanyInfo = Read-Host -Prompt "Would you like to enter Company information for the As Built report? (y/n)"
    $CompanyInfoResponse = Test-ReadHostResponse -Response $CompanyInfo

    if ($CompanyInfoResponse) {
        $CompanyFullName = Read-Host -Prompt "Enter the Full Company Name"
        $CompanyShortName = Read-Host -Prompt "Enter the Company Short Name"
        $CompanyContact = Read-Host -Prompt "Enter the Company Contact"
        $CompanyEmail = Read-Host -Prompt "Enter the Company Email Address"
        $CompanyPhone = Read-Host -Prompt "Enter the Company Phone"
        $CompanyAddress = Read-Host -Prompt "Enter the Company Address"
    }

    $Config.Company = @{
        'FullName' = $CompanyFullName
        'ShortName' = $CompanyShortName
        'Contact' = $CompanyContact
        'Email' = $CompanyEmail
        'Phone' = $CompanyPhone
        'Address' = $CompanyAddress
    }
    #endregion Company configuration

    #region Email configuration
    Clear-Host
    Write-Host '---------------------------------------------' -ForegroundColor Cyan
    Write-Host '  <          Email Configuration          >  ' -ForegroundColor Cyan
    Write-Host '---------------------------------------------' -ForegroundColor Cyan

    $MailInfo = Read-Host -Prompt "Would you like to enter SMTP information for the As Built report? (y/n)"
    $MailInfoResponse = Test-ReadHostResponse -Response $MailInfo

    if ($MailInfoResponse) {
        $MailServer = Read-Host -Prompt "Enter the mail server FQDN / IP address"
        $MailServerPort = Read-Host -Prompt "Enter the mail server port number [25/587]"
        $MailServerUseSSL = Read-Host -Prompt "Use SSL for mail server connection? (true/false)"
        $MailCredentials = Read-Host -Prompt "Require mail server authentication? (true/false)"
        $MailFrom = Read-Host -Prompt "Enter the mail sender address ['Some Person <some.person@example.com']"
        [array] $MailTo = Read-Host -Prompt "Enter one or more recipient email addresses ['person.one@example.com', 'Person Two <person.two@example.com>']"
        $MailBody = Read-Host -Prompt "Enter the email message body content [$ReportName attached]"
    }

    $Config.Email = @{
        'Server' = $MailServer
        'Port' = $MailServerPort
        'UseSSL' = $MailServerUseSSL
        'Credentials' = $MailCredentials
        'From' = $MailFrom
        'To' = $MailTo
        'Body' = $MailBody
    }
    #endregion Email Configuration

    #region Report Configuration Folder
    Clear-Host
    Write-Host '---------------------------------------------' -ForegroundColor Cyan
    Write-Host '  <     Report Configuration Folder       >  ' -ForegroundColor Cyan
    Write-Host '---------------------------------------------' -ForegroundColor Cyan
    $ReportConfigFolder = Read-Host -Prompt "Enter the full path of the folder to use for storing report JSON configuration Files and custom style scripts [$env:USERPROFILE\AsBuiltFiles]"
    if(($ReportConfigFolder -like $null) -or ($ReportConfigFolder -eq "")) {
        $ReportConfigFolder = "$env:USERPROFILE\AsBuiltFiles"
    }

    #If the folder doesn't exist, create it
    if (!(Test-Path -Path $ReportConfigFolder)) {
        New-Item -Path $ReportConfigFolder -ItemType Directory
    }

    #Add the path to the folder to the JSON configuration
    $Config.UserFolder = @{
        'Path' = $ReportConfigFolder
    }

    #Test to see if the Report Configuration folder is empty. If it is, generate all report JSON files.
    #If the folder is not empty, do a foreach loop through each currently installed report module and check if the
    #report json specific to that module exists. If it does, prompt the user to see if they want to overwrite the
    #JSON. If it doesn't exist, generate the JSON
    if (!(Get-ChildItem -Path $ReportConfigFolder -Force)) {
        New-AsBuiltReportConfig -Report all -Path $ReportConfigFolder
    } else {
        try {
            $AsBuiltReportModules = Get-Module -Name "AsBuiltReport.*"
            Foreach ($AsBuiltReportModule in $AsBuiltReportModules) {
                $AsBuiltReportName = $AsBuiltReportModule.Name.Replace("AsBuiltReport.","")
                if (Test-Path -Path "$($ReportConfigFolder)\$($AsBuiltReportModule.Name).json") {
                    Clear-Host
                    Write-Host '---------------------------------------------' -ForegroundColor Cyan
                    Write-Host '  <      Report Configuration JSON        >  ' -ForegroundColor Cyan
                    Write-Host '---------------------------------------------' -ForegroundColor Cyan
                    $OverwriteReportJSON = Read-Host -Prompt "A report JSON already exists in the specified folder for $($AsBuiltReportModule.Name). Would you like to overwrite it? (y/n)"
                    $OverwriteReportJSON = Test-ReadHostResponse -Response $OverwriteReportJSON
                    if ($OverwriteReportJSON) {
                        New-AsBuiltReportConfig -Report $AsBuiltReportName -Path $ReportConfigFolder
                    }
                } else {
                    New-AsBuiltReportConfig -Report $AsBuiltReportName -Path $ReportConfigFolder
                }
            }
        }
        catch {
            Write-Error $_
        }
    }
    #endregion Report Configuration Folder

    #region Save configuration
    Clear-Host
    Write-Host '---------------------------------------------' -ForegroundColor Cyan
    Write-Host '  <     As Built Report Configuration     >  ' -ForegroundColor Cyan
    Write-Host '---------------------------------------------' -ForegroundColor Cyan
    $SaveAsBuiltConfig = Read-Host -Prompt "Would you like to save the As Built configuration file? (y/N)"
    $Save = Test-ReadHostResponse -Response $SaveAsBuiltConfig

    if ($Save) {
        $AsBuiltName = Read-Host -Prompt "Enter a name for the As Built report configuration file [AsBuiltReport]"
        if (($AsBuiltName -like $null) -or ($AsBuiltName -eq "")) {
            $AsBuiltName = "AsBuiltReport"
        }
        $AsBuiltExportPath = Read-Host -Prompt "Enter the path to save the As Built report configuration file [$env:USERPROFILE]"
        if (($AsBuiltExportPath -like $null) -or ($AsBuiltExportPath -eq "")) {
            $AsBuiltExportPath = $env:USERPROFILE
        }
        $AsBuiltConfigPath = Join-Path -Path $AsBuiltExportPath -ChildPath "$AsBuiltName.json"
        $Config | ConvertTo-Json | Out-File $AsBuiltConfigPath
    } else {
        break
    }
    $Config
    #endregion Save configuration
}#End New-AsBuiltConfig Function