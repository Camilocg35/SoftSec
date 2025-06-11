function Get-NetworkAdapters {
    Get-NetAdapter | Select-Object Name, Status, MacAddress, LinkSpeed
}

function Get-NetIP {
    Get-NetIPAddress | Where-Object {$_.AddressFamily -eq "IPv4"} | Select-Object InterfaceAlias, IPAddress, PrefixLength
}

function Set-NetIP {
    param($InterfaceAlias, $IPAddress, $PrefixLength, $Gateway)
    Set-NetIPAddress -InterfaceAlias $InterfaceAlias -IPAddress $IPAddress -PrefixLength $PrefixLength -DefaultGateway $Gateway -ErrorAction Stop
}

function Set-NetDNS {
    param($InterfaceAlias, $DNSServers)
    Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ServerAddresses $DNSServers -ErrorAction Stop
}

function Get-LocalUsers {
    Get-LocalUser | Select-Object Name, Enabled, LastLogon
}

function Add-LocalUser {
    param($UserName, $Password)
    $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
    New-LocalUser -Name $UserName -Password $SecurePassword -FullName $UserName -ErrorAction Stop
}

function Remove-LocalUser {
    param([string]$UserName)
    if (-not $UserName) {
        throw "El argumento UserName está vacío o nulo."
    }

    # 1. No permitir borrar usuario especial o propio
    if ($UserName -eq $env:USERNAME -or $UserName -eq "SYSTEM" -or $UserName -eq "Administrador") {
        throw "No se puede eliminar el usuario actual, SYSTEM o Administrador."
    }

    # 2. Revisar si tiene sesión activa
    try {
        $sessions = (& quser 2>$null) -match "^\s*\w+\s+$UserName\b"
        if ($sessions) {
            throw "No se puede eliminar el usuario '$UserName' porque tiene una sesión iniciada en el sistema."
        }
    } catch { }

    # 3. Intentar eliminar y capturar error específico
    try {
        Microsoft.PowerShell.LocalAccounts\Remove-LocalUser -Name $UserName -ErrorAction Stop
    } catch {
        if ($_.Exception.Message -like "*estado = 3221225764*") {
            throw "No se puede eliminar el usuario '$UserName' porque tiene sesión iniciada, un proceso activo o está en uso por el sistema."
        } else {
            throw $_
        }
    }
}

function Set-LocalUserPassword {
    param($UserName, $Password)
    $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
    Set-LocalUser -Name $UserName -Password $SecurePassword -ErrorAction Stop
}

function Get-Services {
    Get-Service | Sort-Object DisplayName
}

function Get-ServicesByStartType {
    param([string]$StartType)
    $mode = switch ($StartType) {
        "Auto"      { "Automatic" }
        "Manual"    { "Manual" }
        "Disabled"  { "Disabled" }
        default     { "Automatic" }
    }
    Get-WmiObject Win32_Service | Where-Object { $_.StartMode -eq $mode } | Select-Object Name, DisplayName, State, StartMode, Description
}

function Control-Service {
    param($ServiceName, [ValidateSet("Start","Stop","Restart")]$Action)
    switch ($Action) {
        "Start"   { Start-Service -Name $ServiceName }
        "Stop"    { Stop-Service -Name $ServiceName }
        "Restart" { Restart-Service -Name $ServiceName }
    }
}

function Get-Printers {
    Get-Printer | Select-Object Name, Default, Shared, PrinterStatus
}

function Set-DefaultPrinter {
    param($PrinterName)
    Set-Printer -Name $PrinterName -IsDefault $true
}

function Remove-PrinterByName {
    param($PrinterName)
    Remove-Printer -Name $PrinterName
}

function Get-SystemInfo {
    [PSCustomObject]@{
        ComputerName = $env:COMPUTERNAME
        OS           = (Get-CimInstance Win32_OperatingSystem).Caption
        Version      = (Get-CimInstance Win32_OperatingSystem).Version
        Uptime       = ((Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime).ToString("dd\.hh\:mm\:ss")
        RAM          = "{0:N2} GB" -f ((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory/1GB)
        CPU          = (Get-CimInstance Win32_Processor).Name
        UserName     = $env:USERNAME
        IPs          = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike '169.*'} | Select-Object -ExpandProperty IPAddress) -join ", "
    }
}

function Get-Drives {
    Get-PSDrive -PSProvider 'FileSystem' | Select-Object Name, Used, Free, @{Name="Total";Expression={($_.Used + $_.Free)}}
}