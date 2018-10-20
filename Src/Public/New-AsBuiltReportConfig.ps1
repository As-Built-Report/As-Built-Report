function New-AsBuiltReportConfig {
    param (
        [string] $Report,
        [switch] $Timestamp = $false,
        [switch] $SendEmail = $false
    )

    $Config = @{}

    #region Report configuration
    Clear-Host
    Write-Host '---------------------------------------------' -ForegroundColor Cyan
    Write-Host '  <      As Built Report Information      >  ' -ForegroundColor Cyan
    Write-Host '---------------------------------------------' -ForegroundColor Cyan
    $DefaultReportName = "$($Report.Split('.')[0]) $($Report.Split('.')[1]) - As Built Report"
    $ReportName = Read-Host -Prompt "Enter the name of the As Built report [$DefaultReportName]"
    if (($ReportName -like $null) -or ($ReportName -eq "")) {
        $ReportName = $DefaultReportName
    }
    if ($Timestamp) {
        $FileName = "$ReportName - $((Get-Date).ToString('yyyy-MM-dd_HH.mm.ss'))"
    } else {
        $FileName = $ReportName
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
    $CompanyInfo = Read-Host -Prompt "Would you like to enter Company information for the As Built report? (y/N)"
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
    if ($SendEmail) {
        Clear-Host
        Write-Host '---------------------------------------------' -ForegroundColor Cyan
        Write-Host '  <          Email Configuration          >  ' -ForegroundColor Cyan
        Write-Host '---------------------------------------------' -ForegroundColor Cyan

        $MailServer = Read-Host -Prompt "Enter the mail server FQDN / IP address"
        $MailServerPort = Read-Host -Prompt "Enter the mail server port number [25/587]"
        $MailServerUseSSL = Read-Host -Prompt "Use SSL for mail server connection? (true/false)"
        $MailCredentials = Read-Host -Prompt "Require mail server authentication? (true/false)"
        $MailFrom = Read-Host -Prompt "Enter the mail sender address ['Some Person <some.person@example.com']"
        [array] $MailTo = Read-Host -Prompt "Enter one or more recipient email addresses ['person.one@example.com', 'Person Two <person.two@example.com>']"
        $MailBody = Read-Host -Prompt "Enter the email message body content [$ReportName attached]"

        $Config.Email = @{
            'Server' = $MailServer
            'Port' = $MailServerPort
            'UseSSL' = $MailServerUseSSL
            'Credentials' = $MailCredentials
            'From' = $MailFrom
            'To' = $MailTo
            'Body' = $MailBody
        }
    }
    #endregion Email Configuration

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
    }

    $Config
    #endregion Save configuration
}
