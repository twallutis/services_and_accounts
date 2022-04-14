# Autor: Thomas Wallutis
# Erstellungsdatum: 31.03.2022
# Letzte Änderung: 14.04.2022
# Lizenz: GPL 2.0
<#
.SYNOPSIS
    Dienste aus Windows-Systemen auslesen und dazugehörige Benutzerkonten ausgeben. 
.DESCRIPTION
    Das Skript liest eine Liste von Windows-Systemen ein. Bei jedem System werden dann die Dienste abgefragt. 
    Es werden die Dienste zurückgegeben, die unter einem Benutzerkonto laufen. Die Ausgabe wird pro System
    in eine eigene Datei geschrieben.
.PARAMETER
.EXAMPLE
.EXAMPLE
.EXAMPLE
.NOTES
    Verwendung auf eigene Gefahr!
    ToDos:
    Übergabe der Eingabedatei als Parameter
    Abfangen von fehlerhaften Eingaben
    Abfangen von nicht erreichbaren Systemen
.LINK
    github.com/twallutis/services_and_accounts
#>
#
$intuser_a = "NT AUTHORITY\LocalService"
$intuser_b = "localSystem"
$intuser_c = "NT AUTHORITY\NetworkService"
$intuser_d = ""
#
$listexists = $False
$fileexists = $False 
#
# Es erfolgt eine Abfrage des Pfades zur Liste der zur prüfenden Server
# Der übergebene Pfad wird auf Existenz geprüft.
$systemlist = Read-Host "Bitte geben Sie den vollständigen Pfad zur Liste der Systeme ein:"
#
# Die zu prüfenden Systeme werden aus einer Datei ausgelesen.
# In der aktuellen Version des Skriptes muss der Pfad händisch eingetragen werden.
# Es wird geprüft, ob die Datei vorhanden ist
$listexists = Test-Path -Path $systemlist -PathType Leaf
if ($listexists){
    $serverlist = Get-Content $systemlist
     }
else {
    Write-Output ("Eingabedatei existiert nicht am angegebenen Ort. Bitte den korrekten Pfad angeben. Das Skript beendet sich jetzt.")
    break
}
#
# Für jedes Objekt in der Datei werden alle Dienste ausgelesen (unabhängig davon ob sie laufen).
# Danach wird überprüft, ob die Dienste unter einem System-internen Konto laufen bzw. ob kein Konto hinterlegt ist.
# Für Dienste, die unter einem anderen Konto laufen, werden der Anzeigename und das Konto angezeigt.
#
foreach($server in $serverlist){
    $filename = $server + '.txt'
    $serviceslist = Get-CimInstance -ComputerName $server -ClassName Win32_Service 
    $filteredlist = $serviceslist | Where-Object{($_.StartName -notlike $intuser_a -and $_.StartName -notlike $intuser_b) -and $_.StartName -notlike $intuser_c -and $_.StartName -notlike $intuser_d}
    $filteredlistoutput = ($filteredlist | Format-List name, displayname, startname)
    $fileexists = Test-Path -Path C:\Temp\$filename -PathType Leaf
    If ($fileexists){
        Write-Output "Die Ergebnisdatei ist bereits vorhanden. Die Daten werden angehängt."
        $curdate = Get-Date
        Add-Content -Path c:\temp\$filename -Value $curdate
        Add-Content -Path c:\temp\$filename -Value ($filteredlistoutput | Out-String) 
        }
    else{
        Write-Output "Die Ergebnisdatei existiert noch nicht. Sie wird neu neu angelegt."
        $curdate = Get-Date 
        New-Item -Path C:\temp\$filename
        Set-Content -Path c:\temp\$filename -Value $curdate
        Add-Content -Path c:\temp\$filename -Value ($filteredlistoutput | Out-String)
        }
}