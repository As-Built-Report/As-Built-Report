function Test-ReadHostResponse {
    <#
        .SYNOPSIS
        Test whether a user answers yes or no to a Read-Host prompt.
    #>

    param (
        $Response
    )

    switch ($Response) {
        'y' {$true}
        'ye' {$true}
        'yes' {$true}
        'n' {$false}
        'no' {$false}
        Default {$false}
    }
}
