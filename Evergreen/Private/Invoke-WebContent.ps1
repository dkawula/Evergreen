Function Invoke-WebContent {
    <#
        .SYNOPSIS
            Return content from Invoke-WebRequest.
    #>
    [OutputType([Microsoft.PowerShell.Commands.WebResponseObject])]
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Uri,

        [Parameter(Position = 1)]
        [ValidateNotNullOrEmpty()]
        [System.String] $ContentType,

        [Parameter(Position = 2)]
        [ValidateNotNullOrEmpty()]
        [System.Collections.Hashtable] $Headers,

        [Parameter(Position = 3)]
        [ValidateNotNullOrEmpty()]
        [System.String] $UserAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome,

        [Parameter()]
        [System.Management.Automation.SwitchParameter] $Raw
    )

    # Use TLS 1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Write-Verbose -Message "$($MyInvocation.MyCommand): reading: $Uri."

    If ($script:resourceStrings.Preferences.ErrorAction) {
        $errorAction = $script:resourceStrings.Preferences.ErrorAction
    } Else {
        $errorAction = "SilentlyContinue"
    }

    try {
        If ($Raw.IsPresent) {
            $tempFile = New-TemporaryFile
            Write-Verbose -Message "$($MyInvocation.MyCommand): Using temp file $tempFile]."
            $iwrParams = @{
                Uri             = $Uri
                OutFile         = $tempFile
                UserAgent       = $UserAgent
                UseBasicParsing = $True
                ErrorAction     = $errorAction
            }
            If ($ContentType.IsPresent) {
                $iwrParams.ContentType = $ContentType
            }
            If ($Headers.IsPresent) {
                $iwrParams.Headers = $Headers
            }
            $Response = Invoke-WebRequest @iwrParams
            $Content = Get-Content -Path $TempFile
        }
        Else {
            $iwrParams = @{
                Uri             = $Uri
                UserAgent       = $UserAgent
                UseBasicParsing = $True
                ErrorAction     = $errorAction
            }
            If ($ContentType.IsPresent) {
                $iwrParams.ContentType = $ContentType
            }
            If ($Headers.IsPresent) {
                $iwrParams.Headers = $Headers
            }
            $Response = Invoke-WebRequest @iwrParams
            $Content = $Response.Content
        }
    }
    catch [System.Net.WebException] {
        Write-Warning -Message "$($MyInvocation.MyCommand): Error at: $Uri."
        Write-Warning -Message ([string]::Format("Error : {0}", $_.Exception.Message))
    }
    catch [System.Exception] {
        Write-Warning -Message "$($MyInvocation.MyCommand): Error at: $Uri."
        Write-Warning -Message "$($MyInvocation.MyCommand): failed to invoke request to: $Uri."
    }
    finally {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Returning object of length [$($Content.Length)]."
        Write-Output -InputObject $Content
    }
}
