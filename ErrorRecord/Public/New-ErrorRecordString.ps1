using namespace System.Management.Automation

<#
.SYNOPSIS
Creates a new ErrorRecord string that you can paste into your function.

.DESCRIPTION
The New-ErrorRecordString function creates a new ErrorRecord string with the specified error message, category, exception, error ID, target object, and recommended action.

.PARAMETER Message
The error message.

.PARAMETER Category
The error category. Default value is 'NotSpecified'.

.PARAMETER Exception
The exception type.

.PARAMETER ErrorID
The error ID. Default value is 'NotSpecified'.

.PARAMETER TargetObject
The target object.

.PARAMETER RecommendedAction
The recommended action string.

.EXAMPLE
New-ErrorRecordString -Message "An error occurred" -Exception "System.Exception" -ErrorID "12345" -RecommendedAction "Please try again" -Category WriteError
Creates a new ErrorRecord string with the specified parameters.
#>
Function New-ErrorRecordString {
    [CmdletBinding(DefaultParameterSetName = 'default',
        SupportsShouldProcess = $false,
        ConfirmImpact = 'low')]
    Param (
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromRemainingArguments = $false,
            ParameterSetName = 'default')]
        [String]
        $Message,

        [Parameter(ParameterSetName = 'default',
            Mandatory = $false)]
        [Management.Automation.ErrorCategory]
        $Category = 'NotSpecified',

        [Parameter(ParameterSetName = 'default',
            Mandatory = $true)]
        [string]
        $Exception ,

        [Parameter(ParameterSetName = 'default')]
        [string]
        $ErrorID = "NotSpecified",

        [Parameter(ParameterSetName = 'default',
            Mandatory = $false)]
        [String]
        $TargetObject = '$null',

        [Parameter(ParameterSetName = 'default')]
        [string]
        $RecommendedAction,

        [Parameter(ParameterSetName = 'default')]
        [switch]
        $CopyToClipboard

    )

    begin {}
    process {
        $errorString = "`$err = [System.Management.Automation.ErrorRecord]::new(`n"
        $errorString += "           [$Exception]::new('$Message'),`n"
        $errorString += "           '$ErrorID',`n"
        $errorString += "           '$Category',`n"
        $errorString += "           $TargetObject`n"
        $errorString += "       )`n"
        if ($recommendedAction) {
            $errorString += "`$errorDetails = [System.Management.Automation.ErrorDetails]::new('$Message')`n"
            $errorString += "`$errorDetails.RecommendedAction = '$recommendedAction'`n"
            $errorString += "`$err.ErrorDetails = `$errorDetails"
        }
        if ($CopyToClipboard) {
            Set-Clipboard -Value $errorString
            return
        }
        Return $errorString
    }
    end {}
}
Register-ArgumentCompleter -CommandName New-ErrorRecordString -ParameterName Exception -ScriptBlock {
    param($commandName, $parameterName, $stringMatch)
    $stringMatch = $stringMatch.trim("'") # remove ' from search string if there was an space in the word
    ([appdomain]::CurrentDomain.GetAssemblies() | ForEach-Object {
        Try {
            $_.GetExportedTypes() | Where-Object {
                $_.Fullname -like '*Exception'
            }
        }
        Catch {}
    } ) | Where-Object Fullname -Like *$stringMatch* | Sort-Object -Property fullname | Select-Object -ExpandProperty fullname

}

