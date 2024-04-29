properties {
    # Set this to $true to create a module with a monolithic PSM1
    $PSBPreference.Build.CompileModule = $false
    $PSBPreference.Help.DefaultLocale = 'en-US'
    $PSBPreference.Test.OutputFile = 'out/testResults.xml'
}

task Default -depends updateversion, build, Test

task Test -FromModule PowerShellBuild -minimumVersion '0.6.1' -depends UpdateVersion, build
task build -FromModule PowerShellBuild -minimumVersion '0.6.1' -depends UpdateVersion
Task UpdateVersion  {
    $file = "$env:BHModulePath\$env:BHProjectName.psd1"
    $newVersion = dotnet-gitversion /showvariable MajorMinorPatch
    $prereleaseVersion = (dotnet-gitversion /showvariable NuGetPreReleaseTag) -replace "-",""
    if (! $prereleaseVersion) {
        $prereleaseVersion = ' '
    }
    update-ModuleManifest -Path $file  -ModuleVersion $newVersion -Prerelease $prereleaseVersion
    $moduledata = Import-PowerShellDataFile -Path $file
    $moduleversion = $moduledata.ModuleVersion
    $prereleaseVersion = $moduledata.PrivateData.psdata.prerelease
    if ($prereleaseVersion) {
        $moduleversion = ("{0}-{1}" -f $moduleversion, $prereleaseVersion)
    }
    Write-Host ("Version is: {0}" -f $moduleversion)
} -description 'updates the psd1 version in releases'
