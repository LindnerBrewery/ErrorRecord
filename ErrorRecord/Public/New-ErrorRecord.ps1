
Function New-ErrorRecord {
    [CmdletBinding(DefaultParameterSetName = 'default',
        SupportsShouldProcess = $false,
        ConfirmImpact = 'low')]
    Param (
        # Error message
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromRemainingArguments = $false,
            ParameterSetName = 'default')]
        [String]
        $Message,

        # Error category
        [Parameter(ParameterSetName = 'default',
            Mandatory = $false)]
        [Management.Automation.ErrorCategory]
        $Category = 'NotSpecified',

        # exception
        [Parameter(ParameterSetName = 'default',
            Mandatory = $true)]
        [string]
        $Exception ,

        # error id
        [Parameter(ParameterSetName = 'default')]
        [string]
        $ErrorID = "NotSpecified",

        # target object
        [Parameter(ParameterSetName = 'default',
            Mandatory = $false)]
        [System.Object]
        $TargetObject = $null,

        # Recommended action string
        [Parameter(ParameterSetName = 'default')]
        [string]
        $RecommendedAction,

        # inner exception
        [Parameter(ParameterSetName = 'default',
            Mandatory = $false)]
        [System.Exception]
        $InnerException

    )

    begin {}
    process {
        # Create a new ErrorRecord object
        # Add the inner exception to the ErrorRecord object if provided
        if ($InnerException) {
            $exceptionObject = New-Object -TypeName $Exception -ArgumentList $message, $InnerException
        }else {
            $exceptionObject = New-Object -TypeName $Exception -ArgumentList $message
        }
        $errorrecord = [System.Management.Automation.ErrorRecord]::new($exceptionObject, $errorID, $Category, $TargetObject)
        if ($recommendedAction) {
            $errorDetails = [System.Management.Automation.ErrorDetails]::new($errorrecord.Exception.Message)
            $errorDetails.RecommendedAction = $recommendedAction
            $errorrecord.ErrorDetails = $errorDetails
        }
        Return $errorrecord
    }
    end {}
}
Register-ArgumentCompleter -CommandName New-ErrorRecord -ParameterName Exception -ScriptBlock {
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

