﻿
$backupSrc = "C:\Users\vmadmin\Documents\RatCorp_Backup\Dev\Dat\OrdnerStruc";
$backupDest = "C:\Users\vmadmin\Documents\RatCorp_Backup\Dev\Dat\Backup";

$date = Get-Date -Format "MM_dd_yyyy_HH_mm_ss";
$srcName = Get-Item $backupSrc | Get-ItemPropertyValue -Name Name;
$backupName = "$srcName-$date"

# create backup folder in the backup directory, named with actual date and the name of the source folder
$backup = New-Item -Path $backupDest -ItemType "directory" -Name "$backupName"

# copy the files from Source to the backup folder
makeBackup $backupSrc $backup

# Tests if directory exists, if true it returns the path. If false the script will end with an error message.
function testDirectory($dir){
if(-not (Test-Path $dir)){
$msg = "Error: Directory $dir doesn't exist";
Write-Host $msg;
exit;
}
else{
return $dir;
}
}

# Copys all files from the Source folder into the destination folder
function makeBackup($src, $dest){

    $msg = "Starting backup of $src to $dest"

    Write-Host $msg;

    $directories = Get-ChildItem -Path $src -Force -Recurse -Directory
    $files = Get-ChildItem -Path $src -Force -Recurse -File
    
        Write-Host $msg;

    copyFiles $src $dest;
    
    $msg = "copy of files finished"
        Write-Host $msg
   
    }



# Copys files from one directory to another. If the directory has a subdirectory it creates it and calls this function for the subdirectory.

function copyFiles($src, $dest){
    Write-Host "Start to copy files in $src";
    $files = Get-ChildItem -Path $src -Force -File

    if($files){
    foreach($file in $files){
    #if($file.Extension -eq ".txt"){
    Copy-Item $src\$file -Destination $dest
    $msg = "Copied $file to $dest"
    Write-Host $msg
    #}
    }
     }
    
    $folders = Get-ChildItem -Path $src -Force -Directory

    if($folders){

    foreach($folder in $folders){
    Copy-Item $src\$folder -Destination $dest
    $msg = "Created directory $folder" 
    Write-Host $msg


    copyFiles $src\$folder $dest\$folder
   }
  }    
}
