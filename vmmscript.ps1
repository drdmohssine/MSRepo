break;

#region 1 Create Vnet
$logicalNetwork = Get-SCLogicalNetwork -ID "b62766f8-5b57-4809-bbd5-9b1ef4e5b9d7"
$vmNetwork = New-SCVMNetwork -Name "MSVnet1" -LogicalNetwork $logicalNetwork -IsolationType "WindowsNetworkVirtualization" -CAIPAddressPoolType "IPV4" -PAIPAddressPoolType "IPV4"
Write-Output $vmNetwork

for ($i = 1; $i -le 5; $i++)
{ 
    $subnet = New-SCSubnetVLan -Subnet "192.168.1$i.0/24"
$vmSubnet = New-SCVMSubnet -Name "Sub-$i" -VMNetwork $vmNetwork -SubnetVLan $subnet 

# Gateways
$allGateways = @()

# DNS servers
$allDnsServer = @()

# DNS suffixes
$allDnsSuffixes = @()

# WINS servers
$allWinsServers = @()

New-SCStaticIPAddressPool -Name "Pool$i-$($subnet.Subnet)" -VMSubnet $vmSubnet -Subnet "192.168.1$i.0/24" -IPAddressRangeStart "192.168.1$i.4" -IPAddressRangeEnd "192.168.1$i.254" -DefaultGateway $allGateways -DNSServer $allDnsServer -DNSSuffix "" -DNSSearchSuffix $allDnsSuffixes -RunAsynchronously
 

}


#endregion


#region 3 Create Create VM Template
# ------------------------------------------------------------------------------
# Create VM Template Wizard Script
# ------------------------------------------------------------------------------
# Script generated on Saturday, October 5, 2019 10:48:14 AM by Virtual Machine Manager
# 
# For additional help on cmdlet usage, type get-help <cmdlet name>
# ------------------------------------------------------------------------------
$cred = Get-Credential

New-SCVirtualScsiAdapter -VMMServer scvmm.contoso.com -JobGroup 7611688d-6f75-4d94-91b1-682d659bcec6 -AdapterID 7 -ShareVirtualScsiAdapter $false -ScsiControllerType DefaultTypeNoType 


New-SCVirtualDVDDrive -VMMServer scvmm.contoso.com -JobGroup 7611688d-6f75-4d94-91b1-682d659bcec6 -Bus 0 -LUN 1 

$VMNetwork = Get-SCVMNetwork -VMMServer scvmm.contoso.com -Name "MSVnet1" 

$VMSubnet = Get-SCVMSubnet -VMMServer scvmm.contoso.com -Name "Sub-1" | where {$_.VMNetwork.ID -eq $vmNetwork.ID}


New-SCVirtualNetworkAdapter -VMMServer scvmm.contoso.com -JobGroup 7611688d-6f75-4d94-91b1-682d659bcec6 -MACAddress "00:00:00:00:00:00" -MACAddressType Static -Synthetic -EnableVMNetworkOptimization $false -EnableMACAddressSpoofing $false -EnableGuestIPNetworkVirtualizationUpdates $false -IPv4AddressType Dynamic -IPv6AddressType Dynamic -VMSubnet $VMSubnet -VMNetwork $VMNetwork 

$CPUType = Get-SCCPUType -VMMServer scvmm.contoso.com | where {$_.Name -eq "3.60 GHz Xeon (2 MB L2 cache)"}
$CapabilityProfile = Get-SCCapabilityProfile -VMMServer scvmm.contoso.com | where {$_.Name -eq "Hyper-V"}

New-SCHardwareProfile -VMMServer scvmm.contoso.com -CPUType $CPUType -Name "Profile653094d7-9501-4bce-b6db-49fc3969f080" -Description "Profile used to create a VM/Template" -CPUCount 4 -MemoryMB 2048 -DynamicMemoryEnabled $true -DynamicMemoryMinimumMB 32 -DynamicMemoryMaximumMB 1048576 -DynamicMemoryBufferPercentage 20 -MemoryWeight 5000 -CPUExpectedUtilizationPercent 20 -DiskIops 0 -CPUMaximumPercent 100 -CPUReserve 0 -NumaIsolationRequired $false -NetworkUtilizationMbps 0 -CPURelativeWeight 100 -HighlyAvailable $false -DRProtectionRequired $false -SecureBootEnabled $true -SecureBootTemplate "MicrosoftWindows" -CPULimitFunctionality $false -CPULimitForMigration $false -CheckpointType Production -CapabilityProfile $CapabilityProfile -Generation 2 -JobGroup 7611688d-6f75-4d94-91b1-682d659bcec6 



$VirtualHardDisk = Get-SCVirtualHardDisk -VMMServer scvmm.contoso.com | where {$_.Location -eq "\\SCVMM.contoso.com\MSSCVMMLibrary\VHDs\WS2016-Datacenter.vhdx"} | where {$_.HostName -eq "SCVMM.contoso.com"}

New-SCVirtualDiskDrive -VMMServer scvmm.contoso.com -SCSI -Bus 0 -LUN 0 -JobGroup 49767453-f563-4f81-a818-a9d4024335c2 -CreateDiffDisk $false -VirtualHardDisk $VirtualHardDisk -VolumeType BootAndSystem 

$HardwareProfile = Get-SCHardwareProfile -VMMServer scvmm.contoso.com | where {$_.Name -eq "Profile653094d7-9501-4bce-b6db-49fc3969f080"}
$LocalAdministratorCredential = $cred

$OperatingSystem = Get-SCOperatingSystem -VMMServer scvmm.contoso.com -ID "0a393d1e-9050-4142-8e55-a86e4a555013" | where {$_.Name -eq "Windows Server 2016 Datacenter"}

$mstemplate = New-SCVMTemplate -Name "VMTemplate" -RunAsynchronously -Generation 2 -HardwareProfile $HardwareProfile -JobGroup 49767453-f563-4f81-a818-a9d4024335c2 -ComputerName "*" -TimeZone 4 -LocalAdministratorCredential $LocalAdministratorCredential  -FullName "" -ProductKey $null -OrganizationName "" -Workgroup "WORKGROUP" -AnswerFile $null -OperatingSystem $OperatingSystem 


$mstemplate= Get-SCVMTemplate -Name "VMTemplate"
#endregion

#region 4 Create VM1
# ------------------------------------------------------------------------------
# Create Virtual Machine Wizard Script
# ------------------------------------------------------------------------------
# Script generated on Saturday, October 5, 2019 10:50:48 AM by Virtual Machine Manager
# 
# For additional help on cmdlet usage, type get-help <cmdlet name>
# ------------------------------------------------------------------------------


New-SCVirtualScsiAdapter -VMMServer scvmm.contoso.com -JobGroup e94fb48a-6195-43dc-8471-0d15d31fb7c8 -AdapterID 7 -ShareVirtualScsiAdapter $false -ScsiControllerType DefaultTypeNoType 


New-SCVirtualDVDDrive -VMMServer scvmm.contoso.com -JobGroup e94fb48a-6195-43dc-8471-0d15d31fb7c8 -Bus 0 -LUN 1 

$VMSubnet = Get-SCVMSubnet -VMMServer scvmm.contoso.com -Name "Sub1" | where {$_.VMNetwork.ID -eq "65340cd8-bea8-44e0-b39f-782b42fc8187"}
$VMNetwork = Get-SCVMNetwork -VMMServer scvmm.contoso.com -Name "MSVnet1" -ID "65340cd8-bea8-44e0-b39f-782b42fc8187"

New-SCVirtualNetworkAdapter -VMMServer scvmm.contoso.com -JobGroup e94fb48a-6195-43dc-8471-0d15d31fb7c8 -MACAddress "00:00:00:00:00:00" -MACAddressType Static -Synthetic -EnableVMNetworkOptimization $false -EnableMACAddressSpoofing $false -EnableGuestIPNetworkVirtualizationUpdates $false -IPv4AddressType Dynamic -IPv6AddressType Dynamic -VMSubnet $VMSubnet -VMNetwork $VMNetwork -DevicePropertiesAdapterNameMode Disabled 

$CPUType = Get-SCCPUType -VMMServer scvmm.contoso.com | where {$_.Name -eq "3.60 GHz Xeon (2 MB L2 cache)"}
$CapabilityProfile = Get-SCCapabilityProfile -VMMServer scvmm.contoso.com | where {$_.Name -eq "Hyper-V"}

New-SCHardwareProfile -VMMServer scvmm.contoso.com -CPUType $CPUType -Name "Profile372ebb1f-b94a-44ea-8a6e-e21f93b4dfa0" -Description "Profile used to create a VM/Template" -CPUCount 4 -MemoryMB 2048 -DynamicMemoryEnabled $true -DynamicMemoryMinimumMB 32 -DynamicMemoryMaximumMB 1048576 -DynamicMemoryBufferPercentage 20 -MemoryWeight 5000 -CPUExpectedUtilizationPercent 20 -DiskIops 0 -CPUMaximumPercent 100 -CPUReserve 0 -NumaIsolationRequired $false -NetworkUtilizationMbps 0 -CPURelativeWeight 100 -HighlyAvailable $false -DRProtectionRequired $false -SecureBootEnabled $true -SecureBootTemplate "MicrosoftWindows" -CPULimitFunctionality $false -CPULimitForMigration $false -CheckpointType Production -CapabilityProfile $CapabilityProfile -Generation 2 -JobGroup e94fb48a-6195-43dc-8471-0d15d31fb7c8 



$Template = Get-SCVMTemplate -VMMServer scvmm.contoso.com -ID "ddbc35a6-33c2-47f0-a815-75ef9fb716f3" | where {$_.Name -eq "VMTemplate"}
$HardwareProfile = Get-SCHardwareProfile -VMMServer scvmm.contoso.com | where {$_.Name -eq "Profile372ebb1f-b94a-44ea-8a6e-e21f93b4dfa0"}

$OperatingSystem = Get-SCOperatingSystem -VMMServer scvmm.contoso.com -ID "0a393d1e-9050-4142-8e55-a86e4a555013" | where {$_.Name -eq "Windows Server 2016 Datacenter"}

New-SCVMTemplate -Name "Temporary Template4d8e0515-1db5-44d8-b7fe-fac40b7d016c" -Template $Template -HardwareProfile $HardwareProfile -JobGroup d116a2a0-7e35-440b-a221-933f9b94bfb9 -ComputerName "*" -TimeZone 4  -FullName "" -OrganizationName "" -Workgroup "WORKGROUP" -AnswerFile $null -OperatingSystem $OperatingSystem 



$template = Get-SCVMTemplate -All | where { $_.Name -eq "Temporary Template4d8e0515-1db5-44d8-b7fe-fac40b7d016c" }
$virtualMachineConfiguration = New-SCVMConfiguration -VMTemplate $template -Name "VM1"
Write-Output $virtualMachineConfiguration
$vmHost = Get-SCVMHost -ID "4ff085d1-d95a-4251-bf0a-b399e3db943d"
Set-SCVMConfiguration -VMConfiguration $virtualMachineConfiguration -VMHost $vmHost
Update-SCVMConfiguration -VMConfiguration $virtualMachineConfiguration

$AllNICConfigurations = Get-SCVirtualNetworkAdapterConfiguration -VMConfiguration $virtualMachineConfiguration



Update-SCVMConfiguration -VMConfiguration $virtualMachineConfiguration
New-SCVirtualMachine -Name "VM1" -VMConfiguration $virtualMachineConfiguration -Description "" -BlockDynamicOptimization $false -JobGroup "d116a2a0-7e35-440b-a221-933f9b94bfb9" -ReturnImmediately -StartAction "NeverAutoTurnOnVM" -StopAction "SaveVM"

#endregion

#region 5 Create VM2 (Change Subnet)

# ------------------------------------------------------------------------------
# Create Virtual Machine Wizard Script
# ------------------------------------------------------------------------------
# Script generated on Saturday, October 5, 2019 10:52:42 AM by Virtual Machine Manager
# 
# For additional help on cmdlet usage, type get-help <cmdlet name>
# ------------------------------------------------------------------------------

function Create-MSSCVMMVM ($VMName,$VMNet, $VMSub,$HostName)
{


$Guid = New-Guid
New-SCVirtualScsiAdapter -VMMServer scvmm.contoso.com -JobGroup $Guid -AdapterID 7 -ShareVirtualScsiAdapter $false -ScsiControllerType DefaultTypeNoType 


New-SCVirtualDVDDrive -VMMServer scvmm.contoso.com -JobGroup $Guid -Bus 0 -LUN 1 

$VMNetwork = Get-SCVMNetwork -VMMServer scvmm.contoso.com -Name $VMNet
$VMSubnet = Get-SCVMSubnet -VMMServer scvmm.contoso.com -Name $VMSub | where {$_.VMNetwork.ID -eq $vmNetwork.ID}


New-SCVirtualNetworkAdapter -VMMServer scvmm.contoso.com -JobGroup $Guid -MACAddress "00:00:00:00:00:00" -MACAddressType Static -Synthetic -EnableVMNetworkOptimization $false -EnableMACAddressSpoofing $false -EnableGuestIPNetworkVirtualizationUpdates $false -IPv4AddressType Dynamic -IPv6AddressType Dynamic -VMSubnet $VMSubnet -VMNetwork $VMNetwork 

$CPUType = Get-SCCPUType -VMMServer scvmm.contoso.com | where {$_.Name -eq "3.60 GHz Xeon (2 MB L2 cache)"}
$CapabilityProfile = Get-SCCapabilityProfile -VMMServer scvmm.contoso.com | where {$_.Name -eq "Hyper-V"}

New-SCHardwareProfile -VMMServer scvmm.contoso.com -CPUType $CPUType -Name "Profile$Guid" -Description "Profile used to create a VM/Template" -CPUCount 4 -MemoryMB 4096 -DynamicMemoryEnabled $true -DynamicMemoryMinimumMB 32 -DynamicMemoryMaximumMB 1048576 -DynamicMemoryBufferPercentage 20 -MemoryWeight 5000 -CPUExpectedUtilizationPercent 20 -DiskIops 0 -CPUMaximumPercent 100 -CPUReserve 0 -NumaIsolationRequired $false -NetworkUtilizationMbps 0 -CPURelativeWeight 100 -HighlyAvailable $false -DRProtectionRequired $false -SecureBootEnabled $true -SecureBootTemplate "MicrosoftWindows" -CPULimitFunctionality $false -CPULimitForMigration $false -CheckpointType Production -CapabilityProfile $CapabilityProfile -Generation 2 -JobGroup 02df8636-2ea2-45a2-adeb-2eb34ceca8e6 



$VirtualHardDisk = Get-SCVirtualHardDisk -VMMServer scvmm.contoso.com | where {$_.Location -eq "\\SCVMM.contoso.com\MSSCVMMLibrary\VHDs\WS2016-Datacenter.vhdx"} | where {$_.HostName -eq "SCVMM.contoso.com"}

New-SCVirtualDiskDrive -VMMServer scvmm.contoso.com -SCSI -Bus 0 -LUN 0 -JobGroup $Guid -CreateDiffDisk $false -VirtualHardDisk $VirtualHardDisk -FileName "VM-1_WS2016-Datacenter.vhdx" -VolumeType BootAndSystem 

$HardwareProfile = Get-SCHardwareProfile -VMMServer scvmm.contoso.com | where {$_.Name -eq "Profile$Guid"}

New-SCVMTemplate -Name "Temporary Template$Guid" -Generation 2 -HardwareProfile $HardwareProfile -JobGroup $Guid -NoCustomization 



$template = Get-SCVMTemplate -All | where { $_.Name -eq "Temporary Template$Guid" }
$virtualMachineConfiguration = New-SCVMConfiguration -VMTemplate $template -Name $VMName
Write-Output $virtualMachineConfiguration
$vmHost = Get-SCVMHost -ComputerName $HostName
Set-SCVMConfiguration -VMConfiguration $virtualMachineConfiguration -VMHost $vmHost
Update-SCVMConfiguration -VMConfiguration $virtualMachineConfiguration

$AllNICConfigurations = Get-SCVirtualNetworkAdapterConfiguration -VMConfiguration $virtualMachineConfiguration



Update-SCVMConfiguration -VMConfiguration $virtualMachineConfiguration
$operatingSystem = Get-SCOperatingSystem | where { $_.Name -eq "Windows Server 2016 Standard" }
New-SCVirtualMachine -Name $VMName -VMConfiguration $virtualMachineConfiguration -Description "" -BlockDynamicOptimization $false -JobGroup $Guid -ReturnImmediately -StartAction "NeverAutoTurnOnVM" -StopAction "SaveVM" -OperatingSystem $operatingSystem
    
}

Create-MSSCVMMVM -VMName "VM-2" -HostName "host2" -VMNet "MSVnet1" -VMSub "Sub-2"

#endregion

New-SCVMHostGroup -Name "S2DStorage"