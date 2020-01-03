# log 
function log {
    param (
        [Parameter(Mandatory=$true)] $message
    )
    $date=Get-Date -format dd.MM.yyyy-HH:mm:ss
    if (-not (Test-Path -Path $logFile)) {
        New-Item -Path $logFile -ItemType File | Out-Null }
        $text="$date"+":"+" $message"
      Write-Host $text
      Add-Content -Path $logFile -Value $text
    }

$date = Get-Date -Format "MM_dd_yyyy_HH_mm_ss";

# get path where script is run for creation of log file
[string]$path = Split-Path $script:MyInvocation.MyCommand.Path

# set logFile path and name

[string]$logFile = "$path\"+"$date"+"_Testfall01"+".txt"

# log start of script
log "Running Testfall01"

[string]$src = "C:\Users\vmadmin\Documents\GitHub\M122-Backup-Project\RatCorp_Backup\Dev\BackupDataFiles\BackupSource" 
[string]$dest = "C:\Users\vmadmin\Documents\GitHub\M122-Backup-Project\RatCorp_Backup\Dev\BackupDataFiles\BackupTarget"

$result = C:\Users\vmadmin\Documents\GitHub\M122-Backup-Project\RatCorp_Backup\Dev\SourceCode\backup_v1.0.ps1 $src $dest 1

$backupName = $result | select -Last 1

Write-Host "Backupname $backupName"
$filesSrc = Get-ChildItem -Path $src -Force -Recurse -File

$filesDest = Get-ChildItem -Path $dest\$backupName -Force -Recurse -File
log $filesDest
log $filesSrc
$different = Compare-Object -ReferenceObject $filesSrc -DifferenceObject $filesDest
if($different){
    log "Backup Failed"
}else {
    log "Backup Successful"
}

