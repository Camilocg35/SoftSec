# Función para mostrar mensajes de error con opción de copiar
function Show-Exception {
    param($e)
    Add-Type -AssemblyName System.Windows.Forms
    $msg = "ERROR: $($e.Exception.Message)`r`n$($e.InvocationInfo.PositionMessage)`r`n`r`n$($e.Exception.ToString())"
    $form = New-Object Windows.Forms.Form
    $form.Text = "Error fatal"
    $form.Size = New-Object Drawing.Size(700, 400)
    $form.StartPosition = "CenterScreen"
    $txt = New-Object Windows.Forms.TextBox
    $txt.Multiline = $true
    $txt.ReadOnly = $true
    $txt.ScrollBars = "Both"
    $txt.WordWrap = $false
    $txt.Size = New-Object Drawing.Size(660, 280)
    $txt.Location = New-Object Drawing.Point(10,10)
    $txt.Text = $msg
    $form.Controls.Add($txt)
    $btnCopy = New-Object Windows.Forms.Button
    $btnCopy.Text = "Copiar"
    $btnCopy.Location = New-Object Drawing.Point(10, 300)
    $btnCopy.Add_Click({ [Windows.Forms.Clipboard]::SetText($txt.Text) })
    $form.Controls.Add($btnCopy)
    $btnClose = New-Object Windows.Forms.Button
    $btnClose.Text = "Cerrar"
    $btnClose.Location = New-Object Drawing.Point(100, 300)
    $btnClose.Add_Click({ $form.Close() })
    $form.Controls.Add($btnClose)
    $form.Topmost = $true
    $form.ShowDialog() | Out-Null
}

$ErrorActionPreference = "Stop"
trap { Show-Exception $_; continue }

# Auto-elevación
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Import-Module "$PSScriptRoot\Logic\Funciones.psm1" -Force
Import-Module "$PSScriptRoot\Logic\Funciones-Admin.psm1" -Force

# Ventana principal
$form = New-Object System.Windows.Forms.Form
$form.Text = "SoftSec Optimizer"
$form.Size = New-Object System.Drawing.Size(900, 720)
$form.StartPosition = "CenterScreen"

# Panel central
$script:Panel = New-Object System.Windows.Forms.Panel
$script:Panel.Size = New-Object System.Drawing.Size(860, 570)
$script:Panel.Location = New-Object System.Drawing.Point(10, 70)
$script:Panel.AutoScroll = $true
$form.Controls.Add($script:Panel)

# Barra de progreso y status
$ProgressBar = New-Object System.Windows.Forms.ProgressBar
$ProgressBar.Size = New-Object System.Drawing.Size(840, 20)
$ProgressBar.Location = New-Object System.Drawing.Point(10, 650)
$form.Controls.Add($ProgressBar)

$StatusLabel = New-Object System.Windows.Forms.Label
$StatusLabel.Size = New-Object System.Drawing.Size(840, 30)
$StatusLabel.Location = New-Object System.Drawing.Point(10, 675)
$form.Controls.Add($StatusLabel)

# Botones de menú superior
$btnStartup = New-Object System.Windows.Forms.Button
$btnStartup.Text = "Programas de Inicio"
$btnStartup.Size = New-Object System.Drawing.Size(140,40)
$btnStartup.Location = New-Object System.Drawing.Point(10,10)
$form.Controls.Add($btnStartup)

$btnServicios = New-Object System.Windows.Forms.Button
$btnServicios.Text = "Servicios"
$btnServicios.Size = New-Object System.Drawing.Size(140,40)
$btnServicios.Location = New-Object System.Drawing.Point(160,10)
$form.Controls.Add($btnServicios)

$btnTemp = New-Object System.Windows.Forms.Button
$btnTemp.Text = "Limpiar Basura"
$btnTemp.Size = New-Object System.Drawing.Size(140,40)
$btnTemp.Location = New-Object System.Drawing.Point(310,10)
$form.Controls.Add($btnTemp)

$btnCache = New-Object System.Windows.Forms.Button
$btnCache.Text = "Limpiar Caché"
$btnCache.Size = New-Object System.Drawing.Size(140,40)
$btnCache.Location = New-Object System.Drawing.Point(460,10)
$form.Controls.Add($btnCache)

$btnMem = New-Object System.Windows.Forms.Button
$btnMem.Text = "Liberar Memoria"
$btnMem.Size = New-Object System.Drawing.Size(140,40)
$btnMem.Location = New-Object System.Drawing.Point(610,10)
$form.Controls.Add($btnMem)

$btnRecuperacion = New-Object System.Windows.Forms.Button
$btnRecuperacion.Text = "Recuperación"
$btnRecuperacion.Size = New-Object System.Drawing.Size(140,40)
$btnRecuperacion.Location = New-Object System.Drawing.Point(10, 50)
$form.Controls.Add($btnRecuperacion)

$btnAdminSoporte = New-Object System.Windows.Forms.Button
$btnAdminSoporte.Text = "Admin/soporte"
$btnAdminSoporte.Size = New-Object System.Drawing.Size(140,40)
$btnAdminSoporte.Location = New-Object System.Drawing.Point(160, 50)
$form.Controls.Add($btnAdminSoporte)

####### Panel Admin/Soporte ##########
function Show-AdminSoportePanel {
    $script:Panel.Controls.Clear()

    $tabControl = New-Object System.Windows.Forms.TabControl
    $tabControl.Size = New-Object System.Drawing.Size(850,540)
    $tabControl.Location = New-Object System.Drawing.Point(0,0)

    # 1. Gestión de red
    $tabNet = New-Object System.Windows.Forms.TabPage
    $tabNet.Text = "Gestión de red"

    $script:listNet = New-Object System.Windows.Forms.ListView
    $script:listNet.View = 'Details'
    $script:listNet.Size = New-Object System.Drawing.Size(780, 120)
    $script:listNet.Location = New-Object System.Drawing.Point(10,50)
    $script:listNet.Columns.Add("Nombre",120)
    $script:listNet.Columns.Add("Estado",70)
    $script:listNet.Columns.Add("MAC",160)
    $script:listNet.Columns.Add("Velocidad",80)
    $tabNet.Controls.Add($script:listNet)

    $btnListAdapters = New-Object System.Windows.Forms.Button
    $btnListAdapters.Text = "Listar adaptadores"
    $btnListAdapters.Location = New-Object System.Drawing.Point(10,10)
    $tabNet.Controls.Add($btnListAdapters)

    $btnListAdapters.Add_Click({
        try {
            $script:listNet.Items.Clear()
            foreach ($a in Get-NetworkAdapters) {
                $it = New-Object System.Windows.Forms.ListViewItem([string]$a.Name)
                $it.SubItems.Add([string]$a.Status)
                $it.SubItems.Add([string]$a.MacAddress)
                $it.SubItems.Add([string]$a.LinkSpeed)
                $script:listNet.Items.Add($it)
            }
        } catch { Show-Exception $_ }
    })

    # 2. Gestión de usuarios
    $tabUsers = New-Object System.Windows.Forms.TabPage
    $tabUsers.Text = "Gestión de usuarios"

    $script:listUsers = New-Object System.Windows.Forms.ListView
    $script:listUsers.View = 'Details'
    $script:listUsers.FullRowSelect = $true
    $script:listUsers.MultiSelect = $false
    $script:listUsers.Size = New-Object System.Drawing.Size(400, 180)
    $script:listUsers.Location = New-Object System.Drawing.Point(10,45)
    $script:listUsers.Columns.Add("Usuario",120)
    $script:listUsers.Columns.Add("Activo",50)
    $script:listUsers.Columns.Add("Último logon",140)
    $tabUsers.Controls.Add($script:listUsers)

    $btnListUsers = New-Object System.Windows.Forms.Button
    $btnListUsers.Text = "Listar usuarios"
    $btnListUsers.Location = New-Object System.Drawing.Point(10,10)
    $tabUsers.Controls.Add($btnListUsers)

    $btnAddUser = New-Object System.Windows.Forms.Button
    $btnAddUser.Text = "Agregar usuario"
    $btnAddUser.Location = New-Object System.Drawing.Point(130,10)
    $tabUsers.Controls.Add($btnAddUser)

    $btnRemoveUser = New-Object System.Windows.Forms.Button
    $btnRemoveUser.Text = "Eliminar usuario"
    $btnRemoveUser.Location = New-Object System.Drawing.Point(250,10)
    $tabUsers.Controls.Add($btnRemoveUser)

    $lblUser = New-Object System.Windows.Forms.Label
    $lblUser.Text = "Usuario:"
    $lblUser.Location = New-Object System.Drawing.Point(10,240)
    $tabUsers.Controls.Add($lblUser)

    $txtUser = New-Object System.Windows.Forms.TextBox
    $txtUser.Location = New-Object System.Drawing.Point(70,240)
    $txtUser.Width = 100
    $tabUsers.Controls.Add($txtUser)

    $lblPass = New-Object System.Windows.Forms.Label
    $lblPass.Text = "Contraseña:"
    $lblPass.Location = New-Object System.Drawing.Point(190,240)
    $tabUsers.Controls.Add($lblPass)

    $txtPass = New-Object System.Windows.Forms.TextBox
    $txtPass.Location = New-Object System.Drawing.Point(270,240)
    $txtPass.Width = 100
    $txtPass.PasswordChar = "*"
    $tabUsers.Controls.Add($txtPass)

    $btnSetPassword = New-Object System.Windows.Forms.Button
    $btnSetPassword.Text = "Cambiar contraseña"
    $btnSetPassword.Location = New-Object System.Drawing.Point(380,240)
    $tabUsers.Controls.Add($btnSetPassword)

    # --- USUARIOS: Listar ---
    $btnListUsers.Add_Click({
        try {
            $script:listUsers.Items.Clear()
            foreach ($u in Get-LocalUser) {
                $it = New-Object System.Windows.Forms.ListViewItem([string]$u.Name)
                $enabledText = if ($u.Enabled) { "Sí" } else { "No" }
                $it.SubItems.Add($enabledText)
                $lastLogon = if ($u.LastLogon) { [string]$u.LastLogon } else { "n/a" }
                $it.SubItems.Add($lastLogon)
                $script:listUsers.Items.Add($it)
            }
        } catch { Show-Exception $_ }
    })

    # --- USUARIOS: Agregar ---
    $btnAddUser.Add_Click({
        try {
            $user = $txtUser.Text
            $pw = $txtPass.Text
            if ($user -and $pw) {
                if (Get-LocalUser -Name $user -ErrorAction SilentlyContinue) {
                    [System.Windows.Forms.MessageBox]::Show("El usuario ya existe.")
                } else {
                    Add-LocalUser -UserName $user -Password $pw
                    [System.Windows.Forms.MessageBox]::Show("Usuario agregado.")
                    $btnListUsers.PerformClick()
                }
            } else {
                [System.Windows.Forms.MessageBox]::Show("Ingresa usuario y contraseña.")
            }
        } catch { Show-Exception $_ }
    })

    # --- USUARIOS: Eliminar ---
    $btnRemoveUser.Add_Click({
        try {
            if ($script:listUsers.SelectedItems.Count -gt 0) {
                $selected = $script:listUsers.SelectedItems[0].Text
                if ($selected -eq $env:USERNAME -or $selected -eq "SYSTEM" -or $selected -eq "Administrador") {
                    [System.Windows.Forms.MessageBox]::Show("No se puede eliminar el usuario actual, 'SYSTEM' o 'Administrador'.")
                } else {
                    Remove-LocalUser -Name $selected
                    [System.Windows.Forms.MessageBox]::Show("Usuario eliminado.")
                    $btnListUsers.PerformClick()
                }
            } else {
                [System.Windows.Forms.MessageBox]::Show("Selecciona un usuario para eliminar.")
            }
        } catch { Show-Exception $_ }
    })

    # --- USUARIOS: Cambiar contraseña ---
    $btnSetPassword.Add_Click({
        try {
            $user = $txtUser.Text
            $pw = $txtPass.Text
            if ($user -and $pw) {
                if (Get-LocalUser -Name $user -ErrorAction SilentlyContinue) {
                    Set-LocalUserPassword -UserName $user -Password $pw
                    [System.Windows.Forms.MessageBox]::Show("Contraseña actualizada.")
                } else {
                    [System.Windows.Forms.MessageBox]::Show("Usuario no existe.")
                }
            } else {
                [System.Windows.Forms.MessageBox]::Show("Ingresa usuario y nueva contraseña.")
            }
        } catch { Show-Exception $_ }
    })

    # 3. Gestión de servicios
    $tabServicios = New-Object System.Windows.Forms.TabPage
    $tabServicios.Text = "Gestión de servicios"

    $script:lblFiltro = New-Object System.Windows.Forms.Label
    $script:lblFiltro.Text = "Filtrar por tipo de inicio:"
    $script:lblFiltro.Location = New-Object System.Drawing.Point(10,10)
    $tabServicios.Controls.Add($lblFiltro)

    $script:cbFiltro = New-Object System.Windows.Forms.ComboBox
    $script:cbFiltro.Location = New-Object System.Drawing.Point(130,8)
    $script:cbFiltro.Width = 120
    $script:cbFiltro.Items.AddRange(@("Todos","Auto","Manual","Deshabilitado"))
    $script:cbFiltro.SelectedIndex = 0
    $tabServicios.Controls.Add($cbFiltro)

    $script:btnRefrescarServ = New-Object System.Windows.Forms.Button
    $script:btnRefrescarServ.Text = "Refrescar"
    $script:btnRefrescarServ.Location = New-Object System.Drawing.Point(270,8)
    $tabServicios.Controls.Add($btnRefrescarServ)

    $script:listServicios = New-Object System.Windows.Forms.ListView
    $script:listServicios.View = 'Details'
    $script:listServicios.CheckBoxes = $true
    $script:listServicios.FullRowSelect = $true
    $script:listServicios.MultiSelect = $false
    $script:listServicios.Size = New-Object System.Drawing.Size(700, 220)
    $script:listServicios.Location = New-Object System.Drawing.Point(10,40)
    $script:listServicios.Columns.Add("Nombre",160)
    $script:listServicios.Columns.Add("Estado",70)
    $script:listServicios.Columns.Add("Tipo de inicio",90)
    $script:listServicios.Columns.Add("Descripción",350)
    $tabServicios.Controls.Add($script:listServicios)

    $script:btnIniciar = New-Object System.Windows.Forms.Button
    $script:btnIniciar.Text = "Iniciar"
    $script:btnIniciar.Location = New-Object System.Drawing.Point(720,40)
    $tabServicios.Controls.Add($btnIniciar)

    $script:btnDetener = New-Object System.Windows.Forms.Button
    $script:btnDetener.Text = "Detener"
    $script:btnDetener.Location = New-Object System.Drawing.Point(720,80)
    $tabServicios.Controls.Add($btnDetener)

    $script:btnReiniciar = New-Object System.Windows.Forms.Button
    $script:btnReiniciar.Text = "Reiniciar"
    $script:btnReiniciar.Location = New-Object System.Drawing.Point(720,120)
    $tabServicios.Controls.Add($btnReiniciar)

    # ScriptBlock para refrescar servicios
    $RefrescaListaServicios = {
        try {
            $script:listServicios.Items.Clear()
            $filtro = $script:cbFiltro.Text
            if ($filtro -eq "Todos") {
                foreach ($s in Get-Service | Sort-Object DisplayName) {
                    $desc = ""
                    try { $desc = (Get-WmiObject Win32_Service -Filter "Name='$($s.Name)'" | Select-Object -ExpandProperty Description) } catch {}
                    $startMode = ""
                    try { $startMode = (Get-WmiObject Win32_Service -Filter "Name='$($s.Name)'" | Select-Object -ExpandProperty StartMode) } catch {}
                    $it = New-Object System.Windows.Forms.ListViewItem([string]$s.DisplayName)
                    $it.SubItems.Add([string]$s.Status)
                    $it.SubItems.Add([string]$startMode)
                    $it.SubItems.Add([string]$desc)
                    $it.Tag = $s.Name
                    $script:listServicios.Items.Add($it)
                }
            } else {
                $mode = switch ($filtro) {
                    "Auto" { "Automatic" }
                    "Manual" { "Manual" }
                    "Deshabilitado" { "Disabled" }
                }
                foreach ($s in Get-WmiObject Win32_Service | Where-Object { $_.StartMode -eq $mode }) {
                    $it = New-Object System.Windows.Forms.ListViewItem([string]$s.DisplayName)
                    $it.SubItems.Add([string]$s.State)
                    $it.SubItems.Add([string]$s.StartMode)
                    $it.SubItems.Add([string]$s.Description)
                    $it.Tag = $s.Name
                    $script:listServicios.Items.Add($it)
                }
            }
        } catch { Show-Exception $_ }
    }
    $script:btnRefrescarServ.Add_Click($RefrescaListaServicios)
    $script:cbFiltro.Add_SelectedIndexChanged($RefrescaListaServicios)

    $script:btnIniciar.Add_Click({
        try {
            foreach ($item in $script:listServicios.CheckedItems) {
                Control-Service -ServiceName $item.Tag -Action "Start"
                $item.SubItems[1].Text = "Running"
            }
        } catch { Show-Exception $_ }
    })
    $script:btnDetener.Add_Click({
        try {
            foreach ($item in $script:listServicios.CheckedItems) {
                Control-Service -ServiceName $item.Tag -Action "Stop"
                $item.SubItems[1].Text = "Stopped"
            }
        } catch { Show-Exception $_ }
    })
    $script:btnReiniciar.Add_Click({
        try {
            foreach ($item in $script:listServicios.CheckedItems) {
                Control-Service -ServiceName $item.Tag -Action "Restart"
                $item.SubItems[1].Text = "Running"
            }
        } catch { Show-Exception $_ }
    })

    # 4. Administración de impresoras
    $tabPrint = New-Object System.Windows.Forms.TabPage
    $tabPrint.Text = "Administración de impresoras"

    $script:listPrint = New-Object System.Windows.Forms.ListView
    $script:listPrint.View = 'Details'
    $script:listPrint.Size = New-Object System.Drawing.Size(500, 140)
    $script:listPrint.Location = New-Object System.Drawing.Point(10,40)
    $script:listPrint.Columns.Add("Nombre",200)
    $script:listPrint.Columns.Add("Por defecto",90)
    $script:listPrint.Columns.Add("Compartida",80)
    $script:listPrint.Columns.Add("Estado",100)
    $tabPrint.Controls.Add($script:listPrint)

    $btnListPrinters = New-Object System.Windows.Forms.Button
    $btnListPrinters.Text = "Listar impresoras"
    $btnListPrinters.Location = New-Object System.Drawing.Point(10,10)
    $tabPrint.Controls.Add($btnListPrinters)

    $btnListPrinters.Add_Click({
        try {
            $script:listPrint.Items.Clear()
            foreach ($p in Get-Printers) {
                $it = New-Object System.Windows.Forms.ListViewItem([string]$p.Name)
                $defaultText = if ($p.Default) { "Sí" } else { "No" }
                $sharedText = if ($p.Shared) { "Sí" } else { "No" }
                $it.SubItems.Add($defaultText)
                $it.SubItems.Add($sharedText)
                $it.SubItems.Add([string]$p.PrinterStatus)
                $script:listPrint.Items.Add($it)
            }
        } catch { Show-Exception $_ }
    })

    # 5. Información del sistema
    $tabSys = New-Object System.Windows.Forms.TabPage
    $tabSys.Text = "Información del sistema"

    $btnInfo = New-Object System.Windows.Forms.Button
    $btnInfo.Text = "Actualizar info"
    $btnInfo.Location = New-Object System.Drawing.Point(10,10)
    $tabSys.Controls.Add($btnInfo)

    $script:txtInfo = New-Object System.Windows.Forms.TextBox
    $script:txtInfo.Multiline = $true
    $script:txtInfo.ScrollBars = "Vertical"
    $script:txtInfo.Size = New-Object System.Drawing.Size(800, 180)
    $script:txtInfo.Location = New-Object System.Drawing.Point(10,45)
    $tabSys.Controls.Add($txtInfo)

    $btnInfo.Add_Click({
        try {
            $script:sys = Get-SystemInfo
            $script:drives = Get-Drives
            $script:out = @()
            $script:out += "Nombre PC: $($sys.ComputerName)"
            $script:out += "Usuario: $($sys.UserName)"
            $script:out += "SO: $($sys.OS)"
            $script:out += "Versión: $($sys.Version)"
            $script:out += "CPU: $($sys.CPU)"
            $script:out += "RAM: $($sys.RAM)"
            $script:out += "Uptime: $($sys.Uptime)"
            $script:out += "IPs: $($sys.IPs)"
            $script:out += ""
            $script:out += "Unidades:"
            foreach ($d in $script:drives) {
                $script:out += " $($d.Name): Usado=$([math]::Round($d.Used/1GB,2))GB Libre=$([math]::Round($d.Free/1GB,2))GB Total=$([math]::Round($d.Total/1GB,2))GB"
            }
            $script:txtInfo.Text = $out -join "`r`n"
        } catch { Show-Exception $_ }
    })

    # Agrega las pestañas al TabControl
    $tabControl.TabPages.Add($tabNet)
    $tabControl.TabPages.Add($tabUsers)
    $tabControl.TabPages.Add($tabServicios)
    $tabControl.TabPages.Add($tabPrint)
    $tabControl.TabPages.Add($tabSys)
    $script:Panel.Controls.Add($tabControl)
}

# Acciones de los botones principales
$btnStartup.Add_Click({
    try { Manage-Startup -Panel $script:Panel -ProgressBar $ProgressBar -StatusLabel $StatusLabel }
    catch { Show-Exception $_ }
})
$btnServicios.Add_Click({
    try { Optimize-Services -Panel $script:Panel -ProgressBar $ProgressBar -StatusLabel $StatusLabel }
    catch { Show-Exception $_ }
})
$btnTemp.Add_Click({
    try { Remove-JunkFiles -ProgressBar $ProgressBar -StatusLabel $StatusLabel }
    catch { Show-Exception $_ }
})
$btnCache.Add_Click({
    try { Clear-BrowserCache -ProgressBar $ProgressBar -StatusLabel $StatusLabel }
    catch { Show-Exception $_ }
})
$btnMem.Add_Click({
    try { Free-SystemMemory -ProgressBar $ProgressBar -StatusLabel $StatusLabel }
    catch { Show-Exception $_ }
})
$btnRecuperacion.Add_Click({
    try { Start-WinFR-Recovery -Panel $script:Panel -ProgressBar $ProgressBar -StatusLabel $StatusLabel }
    catch { Show-Exception $_ }
})
$btnAdminSoporte.Add_Click({ try { Show-AdminSoportePanel } catch { Show-Exception $_ } })

# Mostrar la ventana principal
[void]$form.ShowDialog()