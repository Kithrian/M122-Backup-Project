New-Item -Path "C:\Users\vmadmin\Documents\GitHub\M122-Backup-Project\RatCorp_Backup\Dev\OrdnerStruc" -ItemType "directory"
Set-Location -Path "C:\Users\vmadmin\Documents\GitHub\M122-Backup-Project\RatCorp_Backup\Dev\OrdnerStruc"

"User Eins", "User Zwei", "User Drei" | ForEach-Object -Process {

    New-Item -Path . -Name $_ -ItemType "directory"

    Set-Location -Path "C:\Users\vmadmin\Documents\GitHub\M122-Backup-Project\RatCorp_Backup\Dev\OrdnerStruc/$_"


    "Ordner Eins", "Ordner Zwei" , "Ordner Drei" | ForEach-Object {
    
    New-Item -Path . -Name $_ -ItemType "directory"

    Set-Location -Path $_

    for($d=0; $d -le 19; $d++) {

    Get-Random -Maximum 10000 | Out-File -FilePath ".\$d.txt"
    
    }

    Set-Location -Path ..
    
    }

    Set-Location -Path "C:\Users\vmadmin\Documents\GitHub\M122-Backup-Project\RatCorp_Backup\Dev\OrdnerStruc"

}