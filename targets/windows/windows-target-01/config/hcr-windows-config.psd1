@{
    ComputerName = "WIN-TARGET-01"

    HCRServer = "192.168.100.10"

    Wazuh = @{
        Manager = "192.168.100.10"

        AgentName = "WIN-TARGET-01"

        Installer = "wazuh-agent-4.14.7-1.msi"
    }

    Sysmon = @{
        Directory = "C:\HCR\Sysmon"

        Config = "sysmonconfig.xml"
    }

    Caldera = @{
        Server = "http://192.168.100.10:8888"
    }

    HCR = @{
        Root = "C:\HCR"
    }
}
