
# Abfrage aller Dienste , die aktuell laufen
Get-WmiObject win32_service | where {$_.state -eq "running"}