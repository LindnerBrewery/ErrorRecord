properties {
    # Set this to $true to create a module with a monolithic PSM1
    $PSBPreference.Build.CompileModule = $false
    $PSBPreference.Help.DefaultLocale = 'en-US'
    $PSBPreference.Test.OutputFile = 'out/testResults.xml'
}

task Default -depends Test

task Test -FromModule PowerShellBuild -minimumVersion '0.6.1'
task build -FromModule PowerShellBuild -minimumVersion '0.6.1' -depends UpdateVersion
Task UpdateVersion  {
    $file = "$env:BHModulePath\$env:BHProjectName.psd1"
    $newVersion = dotnet-gitversion /showvariable MajorMinorPatch
    $prereleaseVersion = (dotnet-gitversion /showvariable NuGetPreReleaseTag) -replace "-",""
    update-ModuleManifest -Path $file  -ModuleVersion $newVersion
} -description 'updates the psd1 version in releases'
