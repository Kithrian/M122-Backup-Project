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

[string]$src = "C:\Users\vmadmin\Documents\GitHub\M122-Backup-Project\RatCorp_Backup\Test\OrdnerStruc" 
[string]$dest = "C:\Users\vmadmin\Documents\GitHub\M122-Backup-Project\RatCorp_Backup\Test\Backup"

[bool]$logToFile = 1
log "Quellverzeichnis: $src"
log "Zielverzeichnis: $dest"

$result = C:\Users\vmadmin\Documents\GitHub\M122-Backup-Project\RatCorp_Backup\Test\backup_v1.1.ps1 $src $dest $logToFile
$backupName = $result | select -index 0
$countCopiedFiles = $result | select -index 1
$copiedFilesNames = $result | select -index 2

[string]$backdupFilesList = "$path\"+"$date"+"_Backdupfiles"+".txt"
$copiedFilesNames | Out-File -FilePath $backdupFilesList

log "Backupname: $backupName"
log "Anzahl kopierter Dateien: $countCopiedFiles"
log "Backedupfiles-List: $backdupFilesList"

$filesSrc = Get-ChildItem -Path $src -Force -Recurse -File
$filesDest = Get-ChildItem -Path $dest\$backupName -Force -Recurse -File 
$different = Compare-Object -ReferenceObject $filesSrc -DifferenceObject $filesDest
if($different){
    log "Backup Failed"
}else {
    log "Backup Successful"
}

