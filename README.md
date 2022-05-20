# ps-vmhost-firewall
Set VMhost Firewall 

This function is used for updating ESXi Host Firewall with multiple IPs and Networks without ESXCLI

# Usage

Get-VMHost -Name <esxi> | Set-VMHost-Firewall -Service "sshServer" -IPSet @("10.0.0.0/8", "192.168.0.0/16")

  
$services = @("webAccess","vSphereClient","sshServer","ntpClient")

foreach($service in $services){
    Get-VMHost -Name 10.5.213.134 | Set-VMHost-Firewall -Service $service -IPSet @("10.0.0.0/8", "192.168.0.0/16", "1.2.3.4", "1.2.3.5")
}
