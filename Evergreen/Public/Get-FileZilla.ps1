Function Get-FileZilla {
    <#
        .NOTES
            Author: Trond Eirik Haavarstein / Iain Brighton
            Twitter: @xenappblog / @iainbrighton
    #>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject])]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    try {
        $web = Invoke-WebRequest -Uri $res.Get.Uri -UseBasicParsing -ErrorAction Stop
        $regexMatch = [Regex]::Match($web.Content, '(?<=<p>The latest stable version of FileZilla Client is )\d{1,}\.\d{1,}\.\d{1,}(?=</p>)')
        if ($regexMatch.Success -eq $true) {
            $version = $regexMatch.Value
            foreach ($platform in 'win32', 'win64') {
                ## The link we want is signed - hence the \? match
                $setupRegex = 'FileZilla_{0}_{1}-setup.exe\?' -f $version, $platform
                $web.Links | Where-Object { $_.href -match $setupRegex } |
                ForEach-Object {
                    [PSCustomObject] @{
                        Version  = $version
                        Platform = $platform
                        URI      = $_.href
                    }
                }
            }
        }
    }
    catch {
        Throw "Failed to connect to URL: $url with error $_."
    }
}
