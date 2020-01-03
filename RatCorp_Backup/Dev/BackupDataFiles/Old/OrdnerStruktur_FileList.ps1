$backupFilesList = "C:\Users\vmadmin\Documents\GitHub\M122-Backup-Project\RatCorp_Backup\Dev\backupFiles.txt"


$fileNames = Get-ChildItem -Path  "C:\Users\vmadmin\Documents\GitHub\M122-Backup-Project\RatCorp_Backup\Dev\OrdnerStruc" -Force -Recurse -File | Get-ItemPropertyValue -Name Name | Out-File -FilePath $backupFilesList

