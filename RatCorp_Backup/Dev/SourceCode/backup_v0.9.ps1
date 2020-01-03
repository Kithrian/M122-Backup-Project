
param(
  [Parameter(Mandatory=$false)] [string]$SourceFolder = "C:\Users\vmadmin\Documents\GitHub\M122-Backup-Project\RatCorp_Backup\Dev\BackupDataFiles\BackupSource",
  [Parameter(Mandatory=$false)] [string]$DestinationFolder = "C:\Users\vmadmin\Documents\GitHub\M122-Backup-Project\RatCorp_Backup\Dev\BackupDataFiles\BackupTarget",
  [Parameter(Mandatory=$false)] [string]$LogFolder = "./"
)

Set-Location $SourceFolder

[string]$CurrentDate = (Get-Date -Format "yyyy''MM''dd'T'HH''mm''ss").ToString()
New-Item -Path $DestinationFolder -Name $CurrentDate -ItemType "Directory"
$DestinationFolder += "\" + $CurrentDate

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

#MakeBackup $SourceFolder $DestinationFolder



#Improved Backup Function
function Iterate {
  param (
    $Folder,
    $DestinationFolder
  )

  Get-ChildItem $Folder | ForEach-Object {
    Write-Host $_.FullName
  
    if ($_.GetType().FullName -eq [System.IO.DirectoryInfo]) {
      
      Set-Location $SourceFolder
      [string]$ItemRelativPath = Resolve-Path -Relative $_.FullName
      Set-Location $DestinationFolder
      New-Item -Path $ItemRelativPath -ItemType "directory"
      Iterate $_.FullName $DestinationFolder
    } else {
      Set-Location $SourceFolder
      [string]$ItemRelativPath2 = Resolve-Path -Relative $_.FullName
      Set-Location $DestinationFolder
      Copy-Item $_.FullName $ItemRelativPath2
      Write-Host $_.FullName
    }
  }
}



Iterate $SourceFolder $DestinationFolder