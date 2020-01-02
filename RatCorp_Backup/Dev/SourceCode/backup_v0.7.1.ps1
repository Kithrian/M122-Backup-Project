param(
    $src,
    $dest,
    # logMode 0 = only console, 1 = console and logfile
    [int]$logMode
  )

  # Tests if directory exists, if true it returns the path. If false the script will end with an error message.
  function testDirectory ($dir) {
    if (-not (Test-Path $dir)) {
      log "Error: Directory $dir doesn't exist";
      exit;
    }
    else {
      return $dir;
    }
  }

# Copys all files from the Source folder into the destination folder
function makeBackup($src, $dest){

    log "Starting backup of $src to $dest"

    $directories = Get-ChildItem -Path $src -Force -Recurse -Directory
    $files = Get-ChildItem -Path $src -Force -Recurse -File
  
    $directoryCountSrc = $directories.Count
    
    log "$directoryCountSrc Directories in $src"
  
    $fileCountSrc = $files.Count
  
    log "$fileCountSrc Files in $src";
  
    copyFiles $src $dest;
  
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

function copyFiles($src, $dest){
    Write-Host "Start to copy files in $src";
    $files = Get-ChildItem -Path $src -Force -File

    if($files){
    foreach($file in $files){
    try {
        Copy-Item $src\$file -Destination $dest -ErrorAction Stop
        $script:fileCountDest++
        log "Copied $file to $dest"
    }
    catch {
        log "Failed to copy $file to $dest"
    }


    }
     }
    
    $folders = Get-ChildItem -Path $src -Force -Directory

    if($folders){

    foreach($folder in $folders){
    try {
        Copy-Item $src\$folder -Destination $dest -ErrorAction Stop
        $script:directoryCountDest++
        log "Created directory $folder" 
        copyFiles $src\$folder $dest\$folder
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
        [Parameter(Mandatory=$true)] $message
    )
    $date=Get-Date -format dd.MM.yyyy-HH:mm:ss
    if (-not (Test-Path -Path $logFile) -and $logMode -eq 1) {
        New-Item -Path $logFile -ItemType File | Out-Null }
        $text="$date"+":"+" $message"
      Write-Host $text
      if ($logMode -eq 1) {
        Add-Content -Path $logFile -Value $text
      }
    }
 

$date = Get-Date -Format "MM_dd_yyyy_HH_mm_ss";
$srcName = Get-Item $src | Get-ItemPropertyValue -Name Name;
$backupName = "$srcName-$date"


# get path where script is run for creation of log file
[string]$path = Split-Path $script:MyInvocation.MyCommand.Path

# set logFile path and name

[string]$logFile = "$path\"+"$backupName"+".txt"

# log start of script
log "Running script backup version 0.7"

$backupSrc = testDirectory $src;



[int]$fileCount;
[int]$directoryCount;

[string]$fileCountSrc;
[string]$directoryCountSrc;

[int]$directoryCountDest = 0;
[int]$fileCountDest = 0;

# create backup folder in the backup directory, named with actual date and the name of the source folder
[string]$backup = testDirectory(New-Item -Path $dest -ItemType "directory" -Name "$backupName")

# copy the files from Source to the backup folder
makeBackup $backupSrc $backup

