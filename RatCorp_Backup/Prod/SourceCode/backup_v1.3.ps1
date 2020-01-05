## Backup Skript
## Dieses Skript erstellt ein Backup eines Quellverzeichnis in ein Zielverzeichnis
## Als Parameter wird das Quell -und Zielverzeichnis erwartet und 0 oder 1 für den Log in eine Datei
## Das Skript gibt am Ende folgende Werte zurück:  - den Namen des erstellten Backups im Zielverzeichnis
##                                                 - die Anzahl der erfolgreich kopierten Dateien
##                                                 - die Dateinamen der erfolgreich kopierten Dateien
## Datum: 06.01.2020
## Autor: Gruppe RegenbogenRatten
## Version: 1.3

#Paramter die dem Skript übergeben werden
param(
  #Gibt den Quellordner an
  [Parameter(Mandatory = $false)] [string]$SourceFolder = "C:\OrdnerStruc",

  #Gibt den Zielordner des Backups an
  [Parameter(Mandatory = $false)] [string]$DestinationFolder = "C:\Backups",

  #Stellt die log Funktion ein oder aus 1 = Ein, 0 = Aus
  [Parameter(Mandatory = $false)] [bool]$logToFile = 1
)

# tests if directory exists, if true it returns the path. If false the script will end with an error message.
function testDirectory ($Path) {
  if (-not (Test-Path $Path)) {
    log "Error: Directory $Path doesn't exist";
    exit;
  }
  else {
    return $Path;
  }
}

# backup function
function MakeBackup {
  param (
    [Parameter(Mandatory=$true)] [string]$SourceFolder,
    [Parameter(Mandatory=$true)] [string]$DestinationFolder
  )
  
  # log start of backup and information about the source and destination
  log "Starting backup of $SourceFolder to $DestinationFolder"
  log "$directoryCountSrc Directories in $SourceFolder"
  log "$fileCountSrc Files in $SourceFolder";
  
  # call copy function to copy all files from source to destination folder
  copyFiles $SourceFolder $DestinationFolder;
  
  # log end of backup and summary
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

# copys files from one directory to another. If the directory has subdirectories it creates them and calls this function for the subdirectory.
function copyFiles($SourceFolder, $DestinationFolder) {
  Write-Host "Start to copy files in $SourceFolder";
  $files = Get-ChildItem -Path $SourceFolder -Force -File

  if ($files) {
    foreach ($file in $files) {
      try {
        Copy-Item $SourceFolder\$file -Destination $DestinationFolder -ErrorAction Stop
        $script:fileNames += $file | Get-ItemPropertyValue -Name Name
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

# log function, if logToFile ist true it writes to a log file
function log {
  param (
    [Parameter(Mandatory = $true)] $message
  )
  [string]$date = Get-Date -format dd.MM.yyyy-HH:mm:ss
  if (-not (Test-Path -Path $logFile) -and $logToFile -eq 1) {
    New-Item -Path $logFile -ItemType File | Out-Null 
  }
  [string]$text = "$date" + ":" + " $message"
  Write-Host $text
  if ($logToFile -eq 1) {
    Add-Content -Path $logFile -Value $text
  }
}
 
# Set name for backup
[string]$date = Get-Date -Format "MM_dd_yyyy_HH_mm_ss";
[string]$srcName = Get-Item $SourceFolder | Get-ItemPropertyValue -Name Name;
[string]$backupName = "$srcName-$date"

# get path where script is run for creation of log file
[string]$path = Split-Path $script:MyInvocation.MyCommand.Path

# set logFile path and name
[string]$logFile = "$path\" + "$backupName" + ".txt"

# log start of script
log "Running script backup version 1.3"

# test if source directory exists
[string]$backupSrc = testDirectory $SourceFolder;

# test if destination directory exists
[string]$backupDest = testDirectory $DestinationFolder;

# count files and directories in src
[int]$fileCountSrc = Get-ChildItem -Path $SourceFolder -Force -Recurse -File | Measure-Object | %{$_.Count};
[int]$directoryCountSrc = Get-ChildItem -Path $SourceFolder -Force -Recurse -Directory | Measure-Object | %{$_.Count};

# variables to count backup process
[int]$directoryCountDest = 0;
[int]$fileCountDest = 0;

# array for names of copied files
[array]$fileNames=@()

# create backup folder in the backup directory, named with actual date and the name of the source folder
[string]$backup = testDirectory(New-Item -Path $backupDest -ItemType "directory" -Name "$backupName")

# call the backup function
makeBackup $backupSrc $backup

# script returns the backupname, file count and file names
Write-Output $backupName, $fileCountDest, $fileNames
