Function Get-mRemoteNG {
    <#
        .SYNOPSIS
            Returns the available mRemoteNG versions.

        .DESCRIPTION
            Returns the available mRemoteNG versions.

        .NOTES
            Author: Trond Eirik Haavarstein 
            Twitter: @xenappblog
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-mRemoteNG

            Description:
            Returns the released mRemoteNG version and download URI.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name    

    # Query the mRemoteNG repository for releases, keeping the latest release
    $iwcParams = @{
        Uri         = $res.Get.Uri
        ContentType = $res.Get.ContentType
    }
    $Content = Invoke-WebContent @iwcParams

    # If something is returned
    If ($Null -ne $Content) {
        $json = $Content | ConvertFrom-Json
        $releases = $json | Where-Object { $_.prerelease -ne $True }
        $latestRelease = $releases | Select-Object -First 1

        # Match version number
        $latestRelease.tag_name -match $res.Get.MatchVersion | Out-Null
        $Version = $Matches[0]

        # Build an array of the latest release and download URLs
        ForEach ($release in $latestRelease.assets) {
            $PSObject = [PSCustomObject] @{
                Version = $Version
                Date    = (ConvertTo-DateTime -DateTime $release.created_at)
                Size    = $release.size
                URI     = $release.browser_download_url
            }
            Write-Output -InputObject $PSObject
        }
    }
    Else {
        Write-Warning -Message "$($MyInvocation.MyCommand): Check update URL: $($res.Get.Uri)."
        $PSObject = [PSCustomObject] @{
            Error = "Check update URL"
        }
        Write-Output -InputObject $PSObject
    }
}
