# New-AsBuiltReport Changelog

## [0.4.1] - 2019-03-16
### Changed
- Implemented  -ListAvailable parameter on Get-Module validation in New-AsBuiltReport and New-AsbuiltReportConfig

## [0.4.0] - 2019-03-16
### Added
- `New-AsbuiltConfig` cmdlet to generate a base As Built Report JSON configuration file
- `New-AsBuiltReport` cmdlet to generate a report JSON configuration file
- Username and Password parameters on `New-AsBuiltReport`
- Support for setting the document orientation for the output report
- ReportConfigPath parameter to `New-AsBuiltReport`

### Changed
- Full refactor of the project to support modules
- Rewrote the menu prompting process and system to analyse read-host responses
- Renamed several parameters on `New-AsBuiltReport` to be consistent and provide more meaning


## 0.3.0

### What's New

- This minor version contains a complete refactor of the project so that it is now an official PowerShell module.

- We will now aim to host this module on PSGallery in the near future to allow for easier installation and usage.

## 0.2.0
### What's New
- New As-Built JSON configuration structure
  - new `AsBuiltConfigPath` parameter
  - allows unique configuration files to be created and saved
  - if `AsBuiltConfigPath` parameter is not specified, user is prompted for As Built report configuration information
  - `New-AsBuiltConfig.ps1` & `Config.json` files are no longer required

## All Releases
### Known Issues
- Table Of Contents (TOC) may be missing in Word formatted report

    When opening the DOC report, MS Word prompts the following 
    
    `"This document contains fields that may refer to other files. Do you want to update the fields in this document?"`
    
    `Yes / No`

    Clicking `No` will prevent the TOC fields being updated and leaving the TOC empty.

    Always reply `Yes` to this message when prompted by MS Word.

- In HTML documents, word-wrap of table cell contents is not working, causing the following issues;
  - Cell contents may overflow table columns
  - Tables may overflow page margin
  - [PScribo Issue #83](https://github.com/iainbrighton/PScribo/issues/83)

- In Word documents, some tables are not sized proportionately. To prevent cell overflow issues in HTML documents, most tables are auto-sized, this causes some tables to be out of proportion.
    
    - [PScribo Issue #83](https://github.com/iainbrighton/PScribo/issues/83)