$logMode = 1;

# log start of script
$msg = "Running script backup version 0.6"
log $msg

$backupSrc = testDirectory "C:\Users\vmadmin\Documents\RatCorp_Backup\Dev\Dat\OrdnerStruc";
$backupDest = testDirectory "C:\Users\vmadmin\Documents\RatCorp_Backup\Dev\Dat\Backup";

$fileCount;
$directoryCount;


$fileCountSrc;
$directoryCountSrc;

$directoryCountDest=0;
$fileCountDest=0;


$date = Get-Date -Format "MM_dd_yyyy_HH_mm_ss";
$srcName = Get-Item $backupSrc | Get-ItemPropertyValue -Name Name;
$backupName = "$srcName-$date"

# create backup folder in the backup directory, named with actual date and the name of the source folder
$backup = New-Item -Path $backupDest -ItemType "directory" -Name "$backupName"

# copy the files from Source to the backup folder
makeBackup $backupSrc $backup

# get path where script is run for creation of log file
$path = Split-Path $script:MyInvocation.MyCommand.Path

# set logFile path and name

$logFile = "$path\"+"$backupName"+".txt"

# Tests if directory exists, if true it returns the path. If false the script will end with an error message.
function testDirectory($dir){
if(-not (Test-Path $dir)){
$msg = "Error: Directory $dir doesn't exist";
log $msg;
exit;
}
else{
return $dir;
}
}

# Copys all files from the Source folder into the destination folder
function makeBackup($src, $dest){

    $msg = "Starting backup of $src to $dest"

    log $msg;

    $directories = Get-ChildItem -Path $src -Force -Recurse -Directory
    $files = Get-ChildItem -Path $src -Force -Recurse -File

    $directoryCountSrc = $directories.Count
    $msg = "$directoryCountSrc Directories in $src"

        log $msg;
    
    $fileCountSrc = $files.Count
    $msg = "$fileCountSrc Files in $src"

        log $msg;

    copyFiles $src $dest;
    
    $msg = "copy of files finished"
        log $msg
   
    $msg = "created $directoryCountDest/$directoryCountSrc directories"
        log $msg

    $msg = "copied $fileCountDest/$fileCountSrc files"
        log $msg

    if($directoryCountDest -eq $directoryCountSrc -and $fileCountDest -eq $fileCountSrc){
        $msg = "Backup SUCCESSFUL, all files have been copied"
        log $msg
        }
        else {
        $msg = "Backup FAILED, some files may have not been copied"
        log $msg
        }
    }



# Copys files from one directory to another. If the directory has a subdirectory it creates it and calls this function for the subdirectory.

function copyFiles($src, $dest){
    Write-Host "Start to copy files in $src";
    $files = Get-ChildItem -Path $src -Force -File

    if($files){
    foreach($file in $files){
    #if($file.Extension -eq ".txt"){
    Copy-Item $src\$file -Destination $dest
    $script:fileCountDest++
    $msg = "Copied $file to $dest"
    log $msg
    #}
    }
     }
    
    $folders = Get-ChildItem -Path $src -Force -Directory

    if($folders){

    foreach($folder in $folders){
    Copy-Item $src\$folder -Destination $dest
    $script:directoryCountDest++
    $msg = "Created directory $folder" 
    log $msg


    copyFiles $src\$folder $dest\$folder
   }
  }    
}

#log 
Function log ($Message) {    
    $Datum=Get-Date -format dd.MM.yyyy-HH:mm:ss
    if (!(Test-Path -Path $logFile)-and $logMode -eq 1) {        
    New-Item -Path $logFile -ItemType File | Out-Null    }    
    $Text="$Datum"+":"+" $Message"
    Write-Host $Text
    if($logMode -eq 1){
    add-Content -Path $logFile -Value $Text    
    }
    }
