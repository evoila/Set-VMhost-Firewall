function Set-VMHost-Firewall {
<#
.SYNOPSIS
    This function is used for updating ESXi Host Firewall with multiple IPs and Networks without ESXCLI
 
.NOTES
    Name: Set-VMHost-Firewall
    Author: Peter Summa
    Version: 1.0
    DateCreated: 2022-May-16
 
.EXAMPLE
    Get-VMHost -Name 192.168.1.10 | Set-VMHost-Firewall -Service "sshServer" -IPSet @("10.0.0.0/8", "192.168.0.0/16", "1.2.3.4", "1.2.3.5", "1.2.3.6")
    Set-VMHost-Firewall -VMHost (Get-VMHost -Name 192.168.1.10) -Service "sshServer" -IPSet @("10.0.0.0/8", "192.168.0.0/16", "1.2.3.4", "1.2.3.5", "1.2.3.6")

    services:
    "webAccess","vSphereClient","bfdDP","bridgeHA","DHCPv6","DVFilter","DVSSync","dynamicruleset","esxupdate","etcdClientComm","etcdPeerComm","gdbserver","gstored","HBR","httpClient","hyperbus","iofiltervp","iwarp-pm","netopa","NFC","nfs41Client","nsx-mpa","nsx-opsagent","nsxMPAPI","nsxOverlay","nsxProxyRule","nsxRMQ","nvmetcp","pvrdma","settingsd","syslog","trusted-infrastructure-kmxa","trusted-infrastructure-kmxd","vdfs","vic-engine","vit","vMotion","vsanEncryption","vsanhealth-unicasttest","vShield-Endpoint-Mux","vShield-Endpoint-Mux-Partners","vvold","WOL","activeDirectoryAll","CIMHttpsServer","CIMHttpServer","CIMSLP","dhcp","dns","faultTolerance","ftpClient","nfsClient","ipfam","ntpClient","ptpd","snmp","iSCSI","sshClient","sshServer","fdm","cmmds","rdt","vpxHeartbeats","remoteSerialPort","vSPC","updateManager","sshClient","sshServer","ntpClient","ptpd","dfwipfix6"

.LINK
    https://www.evoila.de/
    https://github.com/evoila
#>
    param (
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Impl.V1.Inventory.InventoryItemImpl] $VMHost,
        [Parameter(Mandatory = $true, ValueFromPipeline = $false)]
        [String] $Service,
        [Parameter(Mandatory = $true, ValueFromPipeline = $false)]
        [Array] $IPSet
    )

    #Split $IPSet
    $IPs = @()
    $Networks = @()

    foreach ($item in $IPSet) {
        if ($item -like "*/*") {
            $Networks += $item
        }else {
            $IPs += $item
        }
    }

    $_this = Get-View -Id $VMHost.Id

    $spec = New-Object VMware.Vim.HostFirewallRulesetRulesetSpec
    $spec.AllowedHosts = New-Object VMware.Vim.HostFirewallRulesetIpList
    $spec.AllowedHosts.AllIp = $false

    #build ips
    $spec.AllowedHosts.IpAddress = New-Object string[] ($IPs.Length)
    for ($i = 0; $i -lt $IPs.Length; $i++) {
        $spec.AllowedHosts.IpAddress[$i] = $IPs[$i]
    }

    #build networks
    $spec.AllowedHosts.IpNetwork = New-Object VMware.Vim.HostFirewallRulesetIpNetwork[] ($Networks.Length)
    for ($i = 0; $i -lt $Networks.Length; $i++) {
        $spec.AllowedHosts.IpNetwork[$i] = New-Object VMware.Vim.HostFirewallRulesetIpNetwork
        $spec.AllowedHosts.IpNetwork[$i].PrefixLength = $Networks[$i].Split("/")[1]
        $spec.AllowedHosts.IpNetwork[$i].Network = $Networks[$i].Split("/")[0]
    }

    $id = $($VMHost.Id.Split("-")[2])
    $_this = Get-View -Id "HostFirewallSystem-firewallSystem-$($id)"

    #Update Ruleset
    $_this.UpdateRuleset($Service, $spec)
}