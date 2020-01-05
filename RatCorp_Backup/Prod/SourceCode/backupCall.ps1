## Call Backup Skript
## Dieses Skript ruft das Backupscript auf. 
## Die definierten Variablen $src und $dest werden als Parameter für das Quell -und Zielverzeichnis übergeben.
## Für das ein-/ausschalten des Logs $logToFile 1 oder 0.
## Datum: 05.01.2020
## Autor: Gruppe RegenbogenRatten

# backup source directory
$src = "C:\OrdnerStruc"

# backup destination directory
$dest = "C:\Backups"

# log on=1 off=0
[bool]$logToFile = 1

# call backupscript with params
C:\Users\vmadmin\Documents\GitHub\M122-Backup-Project\RatCorp_Backup\Prod\SourceCode\backup_v1.3.ps1 $src $dest $logToFile

