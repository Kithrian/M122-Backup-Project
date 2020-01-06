 New-Item -Path 'C:\RatCorp' -ItemType Directory
 Set-Location -Path 'C:\RatCorp'
 'Ruedi', 'Hans', 'Rosi' | ForEach-Object { 
    $folder = New-Item -Path C:\RatCorp\$_\tax -ItemType Directory 
    
      for ($x=0;$x -lt 10; $x++)
      
      {
        $year = Get-Random -Minimum 2010 -Maximum 2019
        $filename=”$($Folder)\$($year)_$((Get-Random 100000).tostring()).txt”
      
        $randomNr=Get-Random -Minimum 1500 -Maximum 15000
        Add-Content -Value $randomNr -Path $filename
      }

    $folder = New-Item -Path C:\RatCorp\$_\account -ItemType Directory

    for ($x=0;$x -lt 10; $x++)
      
      {
        $year = Get-Random -Minimum 2010 -Maximum 2019
        $filename=”$($Folder)\$($year)_$((Get-Random 100000).tostring()).txt”
      
        $randomFp=Get-Random -Minimum 1500 -Maximum 15000
        Add-Content -Value $randomFp -Path $filename
      }

    $folder = New-Item -Path C:\RatCorp\$_\hr -ItemType Directory

        for ($x=0;$x -lt 10; $x++)
      
      {
        $names = 'Rosi', 'Hansruedi', 'Jörg', 'Isabelle', 'Margreth', 'Hans', 'Ruedi', 'Vreni'
        $filename=”$($Folder)\$($year)_$((Get-Random 100000).tostring()).txt”
      
        $randomName=Get-Random -InputObject $names
        Add-Content -Value $randomName -Path $filename
      }

      $backupFilesList = "C:\RatCorp\backupFiles.txt"
      $fileNames = Get-ChildItem -Path  "C:\RatCorp" -Force -Recurse -File | Get-ItemPropertyValue -Name Name | Out-File -FilePath $backupFilesList
 }
