# Autor: Thomas Wallutis
# Erstellungsdatum: 31.03.2022
# Letzte Änderung: 31.03.2022
# Lizenz: frei zur internen Verwendung
#
# ToDos:
# Übergabe der Eingabedatei als Parameter
# Ausgabe in Datei 
# Abfangen von fehlerhaften Eingaben
# Abfangen von nicht erreichbaren Systemen
#
# Aus einer Datei die Servernamen bzw. IP-Adressen auslesen
# Die Datei enthält einen Eintrag pro Zeile
# Achtung! Eine Prüfung findet nicht statt!
#
$intuser_a = "NT AUTHORITY\LocalService"
$intuser_b = "localSystem"
$intuser_c = "NT AUTHORITY\NetworkService"
$intuser_d = ""
#
$listexists = $False
$fileexists = $False 
#
# Die zu prüfenden Systeme werden aus einer Datei ausgelesen.
# In der aktuellen Version des Skriptes muss der Pfad händisch eingetragen werden.
# Es wird geprüft, ob die Datei vorhanden ist
$listexists = Test-Path -Path C:\Temp\liste.txt -PathType Leaf
if ($listexists){
    $serverlist = Get-Content "C:\Temp\liste.txt"
     }
else {
    echo ("Eingabedatei existiert nicht am angegebenen Ort. Bitte im Kopf des Skriptes die korrekte Datei angeben.")
    break
}
#
# Für jedes Objekt in der Datei werden alle Dienste ausgelesen (unabhängig davon ob sie laufen).
# Danach wird überprüft, ob die Dienste unter einem System-internen Konto laufen bzw. ob kein Konto hinterlegt ist.
# Für Dienste, die unter einem anderen Konto laufen, werden der Anzeigename und das Konto angezeigt.
#
foreach($server in $serverlist){
$filename = $server + '.txt'
# $services = Get-WmiObject Win32_Service  | select-object -Property  * | Where-Object{($_.StartName -notlike "NT AUTHORITY\LocalService" -and $_.StartName -notlike "localSystem") -and $_.StartName -notlike "NT AUTHORITY\NetworkService" -and $_.StartName -notlike ""}   | Format-List name, displayname, startname
$services = Get-WmiObject Win32_Service  | select-object -Property  * | Where-Object{($_.StartName -notlike $intuser_a -and $_.StartName -notlike $intuser_b) -and $_.StartName -notlike $intuser_c -and $_.StartName -notlike $intuser_d}   | Format-List name, displayname, startname
$fileexists = Test-Path -Path C:\Temp\$filename -PathType Leaf
# echo $fileexists
If ($fileexists){
    echo "Die Ergebnisdatei ist bereits vorhanden. Die Daten werden angehängt."
    $curdate = Get-Date
    Add-Content -Path $filename -Value $curdate
    Add-Content -Path $filename -Value $services
}
else{
    echo "Die Ergebnisdatei existiert noch nicht. Sie wird neu neu angelegt."
    $curdate = Get-Date 
    New-Item -Path C:\temp\$filename
    Set-Content -Path $filename -Value $curdate
    Add-Content -Path $filename -Value $services
}}