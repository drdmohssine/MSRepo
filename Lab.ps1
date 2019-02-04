
#sdn02
Set-WinUserLanguageList -LanguageList en-us,fr-fr -Force
New-VM -Name "TestVM" -Generation 2 -VHDPath "C:\ClusterStorage\Volume01\Hyper-V\VM1\Virtual Hard Disks\VM1.vhdx" -MemoryStartupBytes 2GB  |Set-VM -ProcessorCount 4 -DynamicMemory 
Set-VMFirmware -VMName "TestVM" -EnableSecureBoot Off
$User = "Administrator"
$PWord = ConvertTo-SecureString -String "Passw0rd!" -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord


Invoke-Command -ScriptBlock {
 C:\Windows\System32\Sysprep\sysprep.exe /generalize /shutdown /oobe
} -VMName "TestVM" -Credential $Credential
Remove-VM -VMName "TestVM"


$SwName = "MS-MSLab"
New-VMSwitch -SwitchName $SwName -SwitchType Internal
$SWNetAdp = Get-NetAdapter |where name -Match "MS-MSLab"
New-NetIPAddress -IPAddress 192.168.0.1 -PrefixLength 24 -InterfaceIndex $SWNetAdp.ifIndex
New-NetNat -Name MyNATnetwork -InternalIPInterfaceAddressPrefix 192.168.0.0/24
New-Item C:\ClusterStorage\Volume01\Hyper-V\ChildVhd -ItemType Directory
for ($i = 10; $i -le 14; $i++)
{ 
  New-VHD -Path "C:\ClusterStorage\Volume01\Hyper-V\ChildVhd\ChildVM$i.vhdx" -ParentPath "C:\ClusterStorage\Volume01\Hyper-V\VM1\Virtual Hard Disks\VM1.vhdx"
  New-VM -Name "VM-$i" -Generation 2 -VHDPath "C:\ClusterStorage\Volume01\Hyper-V\ChildVhd\ChildVM$i.vhdx" -MemoryStartupBytes 2GB |Set-VM -ProcessorCount 4 -DynamicMemory
  Enable-VMIntegrationService -VMName "VM-$i" -Name "Guest Service Interface"
  Get-VMNetworkAdapter |Remove-VMNetworkAdapter
  Set-VMFirmware -VMName "VM-$i" -EnableSecureBoot Off
  Add-VMNetworkAdapter -SwitchName "MS-MSLab" -VMName "VM-$i"
  Start-VM -VMName "VM-$i"
}

$vmlist=get-vm |where name -Match 'VM-'
for ($i = 10; $i -le 14; $i++)
{ 

 Invoke-Command -ScriptBlock {
$if=Get-NetIPAddress -AddressFamily IPv4 |select InterfaceAlias,InterfaceIndex,IPAddress |where InterfaceAlias -Match ethernet
New-NetIPAddress -IPAddress "192.168.0.$($Using:i)" -DefaultGateway '192.168.0.1' -InterfaceIndex $if.InterfaceIndex -PrefixLength 24 
Set-DnsClientServerAddress -InterfaceIndex $if.InterfaceIndex -ServerAddresses '192.168.10.1'
Enable-NetFirewallRule -Name "FPS-ICMP4-ERQ-In"

#Join to the domain and rename
Add-Computer -DomainName contoso.com -Credential $Using:Credential 
Rename-Computer -NewName "VM-$($Using:i)" -Restart

} -VMName "VM-$i" -Credential $Credential
}

$User = "Administrator"
$PWord = ConvertTo-SecureString -String "Passw0rd!" -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord






Set-NetConnectionProfile -InterfaceAlias "vEthernet (InternalSW)" -NetworkCategory Private
Set-WSManQuickConfig
get-item wsman:\localhost\Client\TrustedHosts
set-item wsman:\localhost\Client\TrustedHosts -value 172.16.1.0
set-item wsman:\localhost\Client\TrustedHosts -value "DC, ServerCore1, ServerCore2, ServerCore3"
set-item wsman:\localhost\Client\TrustedHosts -value "DC, Server*"

$Cred=Get-Credential -UserName "Administrator" -Message "Local Admin"
$DomainCred=Get-Credential -UserName "Contoso.com\Administrator"

$nodes = ("DC", "Host1", , "Host2", "Host3", "Host4")
icm $nodes {
set-DisplayResolution -width 1280 -height 700 -Force
Set-WinUserLanguageList fr-fr -Force
}

$Cim =New-CimSession -ComputerName DC01,SRV01,SRV02

New-Alias -Name Enter -Value Enter-PSSession




Rename-VM -Name "" -NewName ""


Rename-Computer -NewName 'MSHost2' 
Invoke-Command -ScriptBlock {
Install-WindowsFeature -Name Failover-Clustering -IncludeAllSubFeature -IncludeManagementTools
} -ComputerName MSHost1,MSHost2


Add-VMHardDiskDrive -VMName "" -Path ""


Get-NetIPConfiguration -computerName SRV02

Add-WindowsFeature AD-Domain-Services 
Install-ADDSDomainController -CreateDnsDelegation:$false -DatabasePath 'C:\Windows\NTDS' -DomainName 'contoso.com' -InstallDns:$true -LogPath 'C:\Windows\NTDS' -NoGlobalCatalog:$false -SiteName 'Fes' -SysvolPath 'C:\Windows\SYSVOL' -NoRebootOnCompletion:$true -Force:$true -Credential $DomainCred

#remote Desktop
mstsc /v:10.10.10.10:3389

Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
Add-Computer -DomainName contoso.com -Credential $DomainCred -NewName 'DFS' -Restart


function Set-DefaultGW ($OldGW,$NewGW,$IfIndex,$ComputerName)
{
$ChngGWCim=New-CimSession $ComputerName
Remove-NetRoute -ifindex $IfIndex -NextHop $OldGW -CimSession $ChngGWCim
New-NetRoute -interfaceindex $IfIndex -NextHop $NewGW -destinationprefix "0.0.0.0/0" -CimSession $ChngGWCim
Remove-CimSession $ChngGWCim
}

$nodes = ("DC", "Host1", "Host2", "Host3", "Host4")
$oldGW = "192.168.10.254"
foreach ($node in $nodes)
{
   $IPConfig =Get-NetIPConfiguration -ComputerName $node
   $IPConfig.IPv4DefaultGateway  |where NextHop -EQ $oldGW
   Set-DefaultGW -OldGW $IPConfig.IPv4DefaultGateway.NextHop -NewGW "192.168.10.100" -IfIndex $IPConfig.IPv4DefaultGateway.ifIndex -ComputerName $node
   Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
}

Invoke-Command -ScriptBlock {
$NewName = 'ISCSI2'
Add-Computer -DomainName contoso.com -Credential $DomainCred -NewName $NewName -ComputerName vm-1 -Restart } -ComputerName '' -Credential $DomainCred



