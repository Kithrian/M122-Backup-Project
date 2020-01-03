$backupFilesList = "C:\Users\vmadmin\Documents\GitHub\M122-Backup-Project\RatCorp_Backup\Dev\backupFiles_RC.txt"


$fileNames = Get-ChildItem -Path  "C:\Users\vmadmin\Documents\GitHub\M122-Backup-Project\RatCorp_Backup\Dev\RatCorp" -Force -Recurse -File | Get-ItemPropertyValue -Name Name | Out-File -FilePath $backupFilesList

