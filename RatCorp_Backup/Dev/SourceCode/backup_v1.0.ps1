
param(
  [Parameter(Mandatory=$false)] [string]$SourceFolder = "C:\Users\vmadmin\Documents\GitHub\M122-Backup-Project\RatCorp_Backup\Dev\BackupDataFiles\BackupSource3",
  [Parameter(Mandatory=$false)] [string]$DestinationFolder = "C:\Users\vmadmin\Documents\GitHub\M122-Backup-Project\RatCorp_Backup\Dev\BackupDataFiles\BackupTarget",
  [Parameter(Mandatory=$false)] [bool]$LogToFile= 1
)

Set-Location $SourceFolder

#$SourceFolderr = $SourceFolder
#$DestinationFolderr = $DestinationFolder

function MakeBackup {
  param (
    [Parameter(Mandatory=$true)] [string]$SourceFolder,
    [Parameter(Mandatory=$true)] [string]$DestinationFolder
  )

    # Create backup directory
    $DestinationFolder = New-Item -Path $DestinationFolder -Name $BackupName -ItemType "Directory"

    # Log start of backup
    log "Start backup of $SourceFolder to $DestinationFolder"

    # Get all items in backup source directory
    Get-ChildItem -Path $SourceFolder -Recurse -File | ForEach-Object {
    #Get path of file
    [string]$ItemRelativPath = Resolve-Path -Relative $_.Directory
    $FullItemPath = $_.FullName
    [string]$DestinationPath
    Set-Location $DestinationFolder
    if(Test-Path $ItemRelativPath -PathType Container)
    {

    } else {
      #Create folder Structure if not exists
      try {
        New-Item -Path $ItemRelativPath -ItemType "directory" -ErrorAction Stop
        log "Created folder $ItemRelativPath in $DestinationFolder"
      }
      catch {
        log "Failed to create folder $ItemRelativPath"
      }

    }
    
    # call copy function for file
    copyFile $FullItemPath $ItemRelativPath

    Set-Location $SourceFolder
    }
    # Log backup summary
    log "Copied $FileCountDest/$FileCountSrc files"
    if ($FileCountDest -eq $FileCountSrc) {
      log "Backup SUCCESSFUL, all files have been copied"
    }
    else {
      log "Backup FAILED, some files may have not been copied"
    }
}

# Copy file from backup source to destination
function copyFile{
  param(
    [Parameter(Mandatory=$true)] [string]$src,
    [Parameter(Mandatory=$true)] [string]$dest
  )
  try {
    Copy-Item -Path $src -Destination $dest -ErrorAction Stop
    $script:FileCountDest++
    log "Copied $src"
  }
  catch {
      log "Failed to copy $src"
  }
}

# Log if $LogToFile = true create log file and write log messages into it
function log {
  param (
      [Parameter(Mandatory=$true)] $Message
  )
  $Date=Get-Date -format dd.MM.yyyy-HH:mm:ss
  if (-not (Test-Path -Path $LogFile) -and $LogToFile -eq 1) {
      New-Item -Path $LogFile -ItemType File | Out-Null }
      $Text="$Date"+":"+" $Message"
    Write-Host $Text
    if ($LogToFile -eq 1) {
      Add-Content -Path $LogFile -Value $Text
    }
  }

# Set name for backup
$Date = Get-Date -Format "MM_dd_yyyy_HH_mm_ss";
$SrcName = Get-Item $SourceFolder | Get-ItemPropertyValue -Name Name;
$BackupName = "$SrcName-$Date"

# Get path where script is run for creation of log file
[string]$Path = Split-Path $script:MyInvocation.MyCommand.Path

# Set logFile path and name

[string]$LogFile = "$Path\"+"$BackupName"+".txt"

# Log start of script
log "Running script backup version 1.0"

# Count files and directories in src
[int]$FileCountSrc = Get-ChildItem -Path $SourceFolder -Force -Recurse -File | Measure-Object | %{$_.Count}

# Variables to count backup process
[int]$FileCountDest = 0;

MakeBackup $SourceFolder $DestinationFolder

# Script returns the backupname
Write-Output $BackupName
