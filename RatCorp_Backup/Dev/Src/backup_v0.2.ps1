Function Get-FolderName($initialDirectory) {
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    Write-Host "initial dir $initialDirectory"
    $OpenFolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
 
    $Topmost = New-Object System.Windows.Forms.Form
    $Topmost.TopMost = $True
    $Topmost.MinimizeBox = $True

    $OpenFolderDialog.SelectedPath = $initialDirectory
    $OpenFolderDialog.ShowDialog($Topmost) | Out-Null
    return $OpenFolderDialog.SelectedPath
}

# get path where script is run for folder picker default
$path = Split-Path $script:MyInvocation.MyCommand.Path
Write-Host "$path"
#Variables, only Change here
$Destination=Get-FolderName $path #Copy the Files to this Location
$Versions="5" #How many of the last Backups you want to keep
$BackupDirs=Get-FolderName $path #What Folders you want to backup
 
$ExcludeDirs="" #This list of Directories will not be copied
 
$LogName="Log.txt" #Log Name
$LoggingLevel="3" #LoggingLevel only for Output in Powershell Window, 1=smart, 3=Heavy

 
#Logging "INFO" "Use orig Backup Dir"
$Backupdir=$Destination +"\Backup-"+ (Get-Date -format yyyy-MM-dd)+"-"+(Get-Random -Maximum 100000)+"\"
 
 
#$BackupdirTemp=$Temp +"\Backup-"+ (Get-Date -format yyyy-MM-dd)+"-"+(Get-Random -Maximum 100000)+"\"
$Log=$Backupdir+$LogName
$Log
$Items=0
$Count=0
$ErrorCount=0
$StartDate=Get-Date #-format dd.MM.yyyy-HH:mm:ss
 
#FUNCTION
#Logging
Function Logging ($State, $Message) {
    $Datum=Get-Date -format dd.MM.yyyy-HH:mm:ss
 
    if (!(Test-Path -Path $Log)) {
        New-Item -Path $Log -ItemType File | Out-Null
    }
    $Text="$Datum - $State"+":"+" $Message"
 
    if ($LoggingLevel -eq "1" -and $Message -notmatch "was copied") {Write-Host $Text}
    elseif ($LoggingLevel -eq "3") {Write-Host $Text}
   
    add-Content -Path $Log -Value $Text
    
}
 
 
#Create Backupdir
Function Create-Backupdir {
    New-Item -Path $Backupdir -ItemType Directory | Out-Null
    sleep -Seconds 5
    Logging "INFO" "Create Backupdir $Backupdir"
}
 
#Delete Backupdir
Function Delete-Backupdir {
    $Folder=Get-ChildItem $Destination | where {$_.Attributes -eq "Directory"} | Sort-Object -Property CreationTime -Descending:$false | Select-Object -First 1
 
    Logging "INFO" "Remove Dir: $Folder"
    
    $Folder.FullName | Remove-Item -Recurse -Force 
}
 
 
 
#Check if Backupdirs and Destination is available
function Check-Dir {
    Logging "INFO" "Check if BackupDir and Destination exists"
    if (!(Test-Path $BackupDirs)) {
        return $false
        Logging "Error" "$BackupDirs does not exist"
    }
    if (!(Test-Path $Destination)) {
        return $false
        Logging "Error" "$Destination does not exist"
    }
}
 
#Save all the Files
Function Make-Backup {
    Logging "INFO" "Started the Backup"
    $Files=@()
    $SumMB=0
    $SumItems=0
    $SumCount=0
    $colItems=0
    Logging "INFO" "Count all files and create the Top Level Directories"
 
    foreach ($Backup in $BackupDirs) {
        $colItems = (Get-ChildItem $Backup -recurse | Where-Object {$_.mode -notmatch "h"} | Measure-Object -property length -sum) 
        $Items=0
        $FilesCount += Get-ChildItem $Backup -Recurse | Where-Object {$_.mode -notmatch "h"}  
        Copy-Item -Path $Backup -Destination $Backupdir -Force -ErrorAction SilentlyContinue
        $SumMB+=$colItems.Sum.ToString()
        $SumItems+=$colItems.Count
    }
 
    $TotalMB="{0:N2}" -f ($SumMB / 1MB) + " MB of Files"
    Logging "INFO" "There are $SumItems Files with  $TotalMB to copy"
 
    foreach ($Backup in $BackupDirs) {
        $Index=$Backup.LastIndexOf("\")
        $SplitBackup=$Backup.substring(0,$Index)
        $Files = Get-ChildItem $Backup -Recurse  | select * | Where-Object {$_.mode -notmatch "h"} | select fullname #$_.mode -notmatch "h" -and 
 
        foreach ($File in $Files) {
            $restpath = $file.fullname.replace($SplitBackup,"")
            try {
                Copy-Item  $file.fullname $($Backupdir+$restpath) -Force -ErrorAction SilentlyContinue |Out-Null
                Logging "INFO" "$file was copied"
            }
            catch {
                $ErrorCount++
                Logging "ERROR" "$file returned an error an was not copied"
            }
            $Items += (Get-item $file.fullname).Length
            $status = "Copy file {0} of {1} and copied {3} MB of {4} MB: {2}" -f $count,$SumItems,$file.Name,("{0:N2}" -f ($Items / 1MB)).ToString(),("{0:N2}" -f ($SumMB / 1MB)).ToString()
            $Index=[array]::IndexOf($BackupDirs,$Backup)+1
            $Text="Copy data Location {0} of {1}" -f $Index ,$BackupDirs.Count
            Write-Progress -Activity $Text $status -PercentComplete ($Items / $SumMB*100)  
            if ($File.Attributes -ne "Directory") {$count++}
        }
    }
    $SumCount+=$Count
    $SumTotalMB="{0:N2}" -f ($Items / 1MB) + " MB of Files"
    Logging "INFO" "----------------------"
    Logging "INFO" "Copied $SumCount files with $SumTotalMB"
    Logging "INFO" "$ErrorCount Files could not be copied"

#Check if Backupdir needs to be cleaned and create Backupdir
$Count=(Get-ChildItem $Destination | where {$_.Attributes -eq "Directory"}).count
Logging "INFO" "Check if there are more than $Versions Directories in the Backupdir"
 
if ($count -gt $Versions) 
{
 
    Delete-Backupdir
}

 
}
 
 
#create Backup Dir
 
 
 
Create-Backupdir
Logging "INFO" "----------------------"
Logging "INFO" "Start the Script"
 
#Check if all Dir are existing and do the Backup
$CheckDir=Check-Dir
 
if ($CheckDir -eq $false) {
    Logging "ERROR" "One of the Directory are not available, Script has stopped"
} else {
    Make-Backup
 
    $Enddate=Get-Date #-format dd.MM.yyyy-HH:mm:ss
    $span = $EndDate - $StartDate
    $Minutes=$span.Minutes
    $Seconds=$Span.Seconds
 
    Logging "INFO" "Backupduration $Minutes Minutes and $Seconds Seconds"
    Logging "INFO" "----------------------"
    Logging "INFO" "----------------------"
}