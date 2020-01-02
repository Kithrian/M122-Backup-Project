param(
  [Parameter(Mandatory = $false)] [string]$SourceFolder = "..\BackupDataFiles\BackupSource",
  [Parameter(Mandatory = $false)] [string]$DestinationFolder = "..\BackupDataFiles\BackupTarget",
  # logMode 0 = only console, 1 = console and logfile
  [Parameter(Mandatory = $false)] [bool]$logMode = 1
)

# Tests if directory exists, if true it returns the path. If false the script will end with an error message.
function testDirectory ($Path) {
  if (-not (Test-Path $Path)) {
    log "Error: Directory $Path doesn't exist";
    exit;
  }
  else {
    return $Path;
  }
}

# Copys all files from the Source folder into the destination folder
function makeBackup($SourceFolder, $DestinationFolder) {

  log "Starting backup of $SourceFolder to $DestinationFolder"

  $directories = Get-ChildItem -Path $SourceFolder -Force -Recurse -Directory
  $files = Get-ChildItem -Path $SourceFolder -Force -Recurse -File
  
  $directoryCountSrc = $directories.Count
    
  log "$directoryCountSrc Directories in $SourceFolder"
  
  $fileCountSrc = $files.Count
  
  log "$fileCountSrc Files in $SourceFolder";
  
  copyFiles $SourceFolder $DestinationFolder;
  
  log "copy of files finished"
  
  log "created $directoryCountDest/$directoryCountSrc directories"
  
  log "copied $fileCountDest/$fileCountSrc files"
  
  if ($directoryCountDest -eq $directoryCountSrc -and $fileCountDest -eq $fileCountSrc) {
    log "Backup SUCCESSFUL, all files have been copied"
  }
  else {
    log "Backup FAILED, some files may have not been copied"
  }
}

# Copys files from one directory to another. If the directory has a subdirectory it creates it and calls this function for the subdirectory.

function copyFiles($SourceFolder, $DestinationFolder) {
  Write-Host "Start to copy files in $SourceFolder";
  $files = Get-ChildItem -Path $SourceFolder -Force -File

  if ($files) {
    foreach ($file in $files) {
      try {
        Copy-Item $SourceFolder\$file -Destination $DestinationFolder -ErrorAction Stop
        $script:fileCountDest++
        log "Copied $file to $DestinationFolder"
      }
      catch {
        log "Failed to copy $file to $DestinationFolder"
      }
    }
  }
    
  $folders = Get-ChildItem -Path $SourceFolder -Force -Directory

  if ($folders) {

    foreach ($folder in $folders) {
      try {
        Copy-Item $SourceFolder\$folder -Destination $DestinationFolder -ErrorAction Stop
        $script:directoryCountDest++
        log "Created directory $folder" 
        copyFiles $SourceFolder\$folder $DestinationFolder\$folder
      }
      catch {
        log "Failed to create directory $folder" 
      }    
    }
  }    
}

#log 
function log {
  param (
    [Parameter(Mandatory = $true)] $message
  )
  $date = Get-Date -format dd.MM.yyyy-HH:mm:ss
  if (-not (Test-Path -Path $logFile) -and $logMode -eq 1) {
    New-Item -Path $logFile -ItemType File | Out-Null 
  }
  $text = "$date" + ":" + " $message"
  Write-Host $text
  if ($logMode -eq 1) {
    Add-Content -Path $logFile -Value $text
  }
}
 

$date = Get-Date -Format "MM_dd_yyyy_HH_mm_ss";
$srcName = Get-Item $SourceFolder | Get-ItemPropertyValue -Name Name;
$backupName = "$srcName-$date"


# get path where script is run for creation of log file
[string]$path = Split-Path $script:MyInvocation.MyCommand.Path

# set logFile path and name

[string]$logFile = "$path\" + "$backupName" + ".txt"

# log start of script
log "Running script backup version 0.7.1"

$backupSrc = testDirectory $SourceFolder;



[int]$fileCount;
[int]$directoryCount;

[string]$fileCountSrc;
[string]$directoryCountSrc;

[int]$directoryCountDest = 0;
[int]$fileCountDest = 0;

# create backup folder in the backup directory, named with actual date and the name of the source folder
[string]$backup = testDirectory(New-Item -Path $DestinationFolder -ItemType "directory" -Name "$backupName")

# copy the files from Source to the backup folder
makeBackup $backupSrc $backup

Write-Output $backupName
