# Auto-elevación del script si no está en modo Administrador
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Importa el módulo de funciones con recuperación integrada
Import-Module "$PSScriptRoot\Logic\Funciones.psm1"

# Ventana principal
$form = New-Object System.Windows.Forms.Form
$form.Text = "SoftSec Optimizer"
$form.Size = New-Object System.Drawing.Size(800, 600)
$form.StartPosition = "CenterScreen"

# Panel principal donde se muestran los módulos
$Panel = New-Object System.Windows.Forms.Panel
$Panel.Size = New-Object System.Drawing.Size(760, 420)
$Panel.Location = New-Object System.Drawing.Point(10,70)
$form.Controls.Add($Panel)

# Barra de progreso y status
$ProgressBar = New-Object System.Windows.Forms.ProgressBar
$ProgressBar.Size = New-Object System.Drawing.Size(740, 20)
$ProgressBar.Location = New-Object System.Drawing.Point(10,500)
$form.Controls.Add($ProgressBar)

$StatusLabel = New-Object System.Windows.Forms.Label
$StatusLabel.Size = New-Object System.Drawing.Size(740, 30)
$StatusLabel.Location = New-Object System.Drawing.Point(10,530)
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

# Acciones de los botones
$btnStartup.Add_Click({
    Manage-Startup -Panel $Panel -ProgressBar $ProgressBar -StatusLabel $StatusLabel
})
$btnServicios.Add_Click({
    Optimize-Services -Panel $Panel -ProgressBar $ProgressBar -StatusLabel $StatusLabel
})
$btnTemp.Add_Click({
    Remove-JunkFiles -ProgressBar $ProgressBar -StatusLabel $StatusLabel
})
$btnCache.Add_Click({
    Clear-BrowserCache -ProgressBar $ProgressBar -StatusLabel $StatusLabel
})
$btnMem.Add_Click({
    Free-SystemMemory -ProgressBar $ProgressBar -StatusLabel $StatusLabel
})
$btnRecuperacion.Add_Click({
    Start-WinFR-Recovery -Panel $Panel -ProgressBar $ProgressBar -StatusLabel $StatusLabel
})

# Mostrar la ventana
[void]$form.ShowDialog()