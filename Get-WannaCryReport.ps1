#This will run a report for windows10 computers to see if they are patched against wannacry.
#will export a CSV report to the same directory you run the script from
#Example .\Get-WannaCryReport.ps1 -computers computer1
#Example .\Get-WannaCryReport.ps1 -computers computer1,computer2
#Example - search all computers in a specific OU:
#$computers = (Get-ADComputer -Filter * -SearchBase "OU=Windows10,DC=contoso,DC=org").name
#.\Get-WannaCryReport.ps1 -computers $computers

Param ([string[]]$computers)

$resultsArr = @()
foreach ($computer in $computers)
{

    $HKEY_LOCAL_MACHINE = 2147483650 
    $Reg = [WMIClass]"\\$computer\ROOT\DEFAULT:StdRegProv" 
    $Key = "SOFTWARE\Microsoft\Windows NT\CurrentVersion"
    $version = ($reg.GetStringValue($HKEY_LOCAL_MACHINE,$key,'ReleaseID')).sValue
    $minorBuild = ($reg.GetDwordValue($HKEY_LOCAL_MACHINE,$key,'UBR')).uValue
    $majorBuild = (Get-WmiObject win32_operatingsystem -ComputerName $computer).BuildNumber

    switch($version)
    {
        "1703" {write-host "$env:COMPUTERNAME is up to date" -ForegroundColor Green;$patched = $true}
        "1607" {if ($build_minor -le 953){
                    write-host "$env:COMPUTERNAME is NOT up to date" -ForegroundColor Red;$patched = $fale}
                else{
                    write-host "$env:COMPUTERNAME is up to date" -ForegroundColor Green;$patched = $true}}
        "1511" {if ($build_minor -le 839){
                    write-host "$env:COMPUTERNAME is NOT up to date" -ForegroundColor Red;$patched = $false}
                else{
                    write-host "$env:COMPUTERNAME is up to date" -ForegroundColor Green;$patched = $true}}
        "1507" {if ($build_minor -le 17319){
                    write-host "$env:COMPUTERNAME is NOT up to date" -ForegroundColor Red;$patched = $false}
                else{
                    write-host "$env:COMPUTERNAME is up to date" -ForegroundColor Green;$patched = $true}}
    }
    $obj = New-Object psobject
    $obj | Add-Member -MemberType NoteProperty -Name Computer -Value $env:COMPUTERNAME
    $obj | Add-Member -MemberType NoteProperty -Name Version -Value $version
    $obj | Add-Member -MemberType NoteProperty -Name MajorBuild -Value $majorBuild
    $obj | Add-Member -MemberType NoteProperty -Name MinorBuild -Value $minorBuild
    $obj | Add-Member -MemberType NoteProperty -Name Patched -Value $patched

    $resultsArr += $obj
}

$resultsArr | Export-Csv -Force -NoTypeInformation -Path .\wannacry.csv
.\wannacry.csv
