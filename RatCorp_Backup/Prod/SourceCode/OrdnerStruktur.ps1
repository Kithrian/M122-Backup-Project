New-Item -Path "C:/OrdnerStruc" -ItemType "directory"
Set-Location -Path "C:/OrdnerStruc"

"User Eins", "User Zwei", "User Drei" | ForEach-Object -Process {

    New-Item -Path . -Name $_ -ItemType "directory"

    Set-Location -Path "C:/OrdnerStruc/$_"


    "Ordner Eins", "Ordner Zwei" , "Ordner Drei" | ForEach-Object {
    
    New-Item -Path . -Name $_ -ItemType "directory"

    Set-Location -Path $_

    for($d=0; $d -le 19; $d++) {

    Get-Random -Maximum 10000 | Out-File -FilePath ".\$d.txt"
    
    }

    Set-Location -Path ..
    
    }

    Set-Location -Path "C:/OrdnerStruc"

}