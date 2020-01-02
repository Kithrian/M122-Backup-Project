
param(
  [Parameter(Mandatory=$false)] [string]$SourceFolder = "C:\Users\reyco\Documents\GitHub\M122-Backup-Project\RatCorp_Backup\Dev\BackupDataFiles\BackupSource",
  [Parameter(Mandatory=$false)] [string]$DestinationFolder = "C:\Users\reyco\Documents\GitHub\M122-Backup-Project\RatCorp_Backup\Dev\BackupDataFiles\BackupTarget",
  [Parameter(Mandatory=$false)] [string]$LogFolder = "./"
)

Set-Location $SourceFolder

#$SourceFolderr = $SourceFolder
#$DestinationFolderr = $DestinationFolder

function MakeBackup {
  param (
    [Parameter(Mandatory=$true)] [string]$SourceFolder,
    [Parameter(Mandatory=$true)] [string]$DestinationFolder
  )

    [string]$CurrentDate = (Get-Date -Format "yyyy''MM''dd'T'HH''mm''ss").ToString()
    New-Item -Path $DestinationFolder -Name $CurrentDate -ItemType "Directory"
    $DestinationFolder += "\" + $CurrentDate

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
      New-Item -Path $ItemRelativPath -ItemType "directory"
    }
    
    Copy-Item -Path $FullItemPath -Destination $ItemRelativPath
    Set-Location $SourceFolder
  }

}

MakeBackup $SourceFolder $DestinationFolder
