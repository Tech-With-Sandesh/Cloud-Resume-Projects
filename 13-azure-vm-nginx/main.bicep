// ──────────────────────────────────────────
// Azure VM with Nginx — Bicep Template
// ──────────────────────────────────────────
@description('Location for all resources')
param location string = resourceGroup().location

@description('VM name')
param vmName string = 'nginx-vm'

@description('Admin username')
param adminUsername string = 'azureuser'

@description('Admin SSH public key')
@secure()
param adminPublicKey string

@description('VM size')
param vmSize string = 'Standard_B1s'

// ──────────────────────────────────────────
// Virtual Network
// ──────────────────────────────────────────
resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: '${vmName}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: { id: nsg.id }
        }
      }
    ]
  }
}

// ──────────────────────────────────────────
// Network Security Group
// ──────────────────────────────────────────
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: '${vmName}-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowHTTP'
        properties: {
          priority: 100
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '80'
        }
      }
      {
        name: 'AllowHTTPS'
        properties: {
          priority: 110
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
        }
      }
      {
        name: 'AllowSSH'
        properties: {
          priority: 120
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: 'YOUR_IP/32'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
        }
      }
    ]
  }
}

// ──────────────────────────────────────────
// Public IP
// ──────────────────────────────────────────
resource publicIP 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: '${vmName}-pip'
  location: location
  sku: { name: 'Standard' }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: '${vmName}-${uniqueString(resourceGroup().id)}'
    }
  }
}

// ──────────────────────────────────────────
// Network Interface
// ──────────────────────────────────────────
resource nic 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: { id: publicIP.id }
          subnet: { id: vnet.properties.subnets[0].id }
        }
      }
    ]
  }
}

// ──────────────────────────────────────────
// Virtual Machine
// ──────────────────────────────────────────
resource vm 'Microsoft.Compute/virtualMachines@2023-07-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: { vmSize: vmSize }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer:     '0001-com-ubuntu-server-jammy'
        sku:       '22_04-lts-gen2'
        version:   'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: { storageAccountType: 'Standard_LRS' }
      }
    }
    osProfile: {
      computerName:  vmName
      adminUsername: adminUsername
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path:    '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: adminPublicKey
            }
          ]
        }
      }
    }
    networkProfile: {
      networkInterfaces: [{ id: nic.id }]
    }
  }
}

// ──────────────────────────────────────────
// Custom Script Extension — Install Nginx
// ──────────────────────────────────────────
resource nginxExtension 'Microsoft.Compute/virtualMachines/extensions@2023-07-01' = {
  parent: vm
  name: 'InstallNginx'
  location: location
  properties: {
    publisher:               'Microsoft.Azure.Extensions'
    type:                    'CustomScript'
    typeHandlerVersion:      '2.1'
    autoUpgradeMinorVersion: true
    settings: {
      script: loadFileAsBase64('scripts/install-nginx.sh')
    }
  }
}

// ──────────────────────────────────────────
// Outputs
// ──────────────────────────────────────────
output publicIPAddress string = publicIP.properties.ipAddress
output fqdn           string = publicIP.properties.dnsSettings.fqdn
output sshCommand     string = 'ssh ${adminUsername}@${publicIP.properties.ipAddress}'
