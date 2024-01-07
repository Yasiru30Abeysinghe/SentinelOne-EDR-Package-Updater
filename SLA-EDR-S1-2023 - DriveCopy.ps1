<#   This Script is written to copy agent installation files from shared drive to a local drive    #>

#Getting user inputs

param (
    [Parameter(Mandatory=$true)][string]$shPath1,
    [Parameter(Mandatory=$true)][string]$prop_app,
    [Parameter(Mandatory=$true)][string]$output
)


#Checking for current app information

$path = "C:\Program Files\SentinelOne"
$s1 = Get-ChildItem $path | Sort-Object LastWriteTime -Descending | Select-Object -First 1 # Checking for latest file
$curr_app = $s1.ToString()


Remove-Item $output -ErrorAction Ignore  #Removing previous outputs from output file


#checking for C space availability

$cS = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'"
$cS = [math]::Round(($cS.FreeSpace/1GB),2)

$dS = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='D:'"
$dS = [math]::Round(($dS.FreeSpace/1GB),2)

if($cS -gt 5){
    $localfolder = "C:\"
    "Output Copied to C:\" | Out-File -FilePath $output -Append
}
elseif($dS -gt 5){
    $localfolder = "F:\"
    "Output Copied to F:\" | Out-File -FilePath $output  -Append
}
else{
    "Insufficient Space" | Out-File -FilePath $output -Append
     Exit
}



#Check whether the application is upto date

$p_app = "Sentinel Agent "+$prop_app
if($curr_app -eq $p_app){
    Write-Host "Version is upto date." | Out-File -FilePath $output -Append
}

else{
    
    write-Host "Version need to be upgrade" | Out-File -FilePath $output -Append

    #Map 1.d information --->
     $arch = if ( [Environment]::Is64BitOperatingSystem ) { "64bit" } else { "32bit" }    #Architecture(32/64)
    

    # Agent current version is already declared as $curr_app

    $s2 = Get-CimInstance -ClassName Win32_OperatingSystem   #OS version  
    $os= $s2.Caption  

    # Generate installer file name
    $prop1 = "$prop_app".Replace(".","_")
    $install_name_exe = "SentinelOneInstaller_windows_"+$arch+"_v"+$prop1+".exe"
    $install_name_msi = "SentinelOneinstaller_windows_"+$arch+"_v"+$prop1+".msi"
    
    $networkfolder1 = "$shPath1\$install_name_exe"
    $networkfolder2 = "$shPath1\$install_name_msi"
       

    #Pull the files over the network
    Copy-Item $networkfolder1 -Destination $localfolder
    Copy-Item $networkfolder2 -Destination $localfolder

}



