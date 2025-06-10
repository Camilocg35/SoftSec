Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Formulario Central
$form = New-Object System.Windows.Forms.Form
$form.Text = "SoftSec 1.0"
$form.Size = New-Object System.Drawing.Size(900, 650)
$form.FormBorderStyle = 'Sizable'
$form.MaximizeBox = $true
$form.MinimizeBox = $true
$form.StartPosition = 'CenterScreen'
$form.BackColor = [System.Drawing.Color]::Silver

# Label SoftSec 1.0
$label0 = New-Object System.Windows.Forms.Label
$label0.Text = "SoftSec 1.0 Suite Informática"
$label0.Location = New-Object System.Drawing.Point(250,30)
$label0.Size = New-Object System.Drawing.Size(600, 30)
$label0.Font = New-Object System.Drawing.Font("Segoe UI", 15)

$form.Controls.Add($label0)

# DataGrid Central
$gridMain = New-Object Windows.Forms.DataGridView
$gridMain.Size = New-Object System.Drawing.Size(870, 250)
$gridMain.Anchor = 'Top, Left, Right'
$gridMain.Location = '10,70'
$gridMain.BackColor = [System.Drawing.Color]::Black
$gridMain.ReadOnly = $true
$gridMain.AutoSizeColumnsMode = 'Fill'
$gridMain.AllowUserToAddRows = $false
$form.Controls.Add($gridMain)

# TabControl
$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.Size = New-Object System.Drawing.Size(900, 25)
$tabControl.Anchor = 'Top, Left, Right'
$form.Controls.Add($tabControl)

# Archivo
$tab1 = New-Object System.Windows.Forms.TabPage
$tab1.Text = "Archivo"

# Edición
$tab2 = New-Object System.Windows.Forms.TabPage
$tab2.Text = "Edición"

# Opciones
$tab3 = New-Object System.Windows.Forms.TabPage
$tab3.Text = "Opciones"

$tabControl.TabPages.Add($tab1)
$tabControl.TabPages.Add($tab2)
$tabControl.TabPages.Add($tab3)

# Label Opciones
$label1 = New-Object System.Windows.Forms.Label
$label1.Text = "Opciones"
$label1.Location = New-Object System.Drawing.Point(10, 325)
$label1.Size = New-Object System.Drawing.Size(100, 20)
$label1.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$form.Controls.Add($label1)

# ComboBox opciones
$comboBox = New-Object System.Windows.Forms.ComboBox
$comboBox.Location = New-Object System.Drawing.Point(10, 350)
$comboBox.Size = New-Object System.Drawing.Size(200, 20)
$comboBox.DropDownStyle = 'DropDownList' # O 'DropDown' si querés editable
$comboBox.Items.AddRange(@("Optimización", "Seguridad", "Monitorización", "Recuperación"))
$comboBox.SelectedIndex = 0  # Primer ítem
$form.Controls.Add($comboBox)

# Panel Optimización
$panel0 = New-Object System.Windows.Forms.Panel
$panel0.Size = New-Object System.Drawing.Size(870, 200)
$panel0.Location = New-Object System.Drawing.Point(10,390)
$Panel0.Anchor = 'Top, Left, Right'
$panel0.BackColor = [System.Drawing.Color]::White
$panel0.BorderStyle = 'FixedSingle'
$panel0.Visible = $true
$form.Controls.Add($panel0)

######################################################################################
##### Vista Optimización #############################################################
######################################################################################

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(10,175)
$progressBar.Size = New-Object System.Drawing.Size(900, 15)
$progressBar.Style = 'Blocks'
$progressBar.Minimum = 0
$progressBar.Maximum = 100
$progressBar.Value = 0

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object System.Drawing.Point(10, 160)
$statusLabel.Size = New-Object System.Drawing.Size(900, 20)
$statusLabel.Text = "Estatus."

$btnO_0 = New-Object System.Windows.Forms.Button
$btnO_0.Text = "Limpiar Caché Navegador"
$btnO_0.Location = New-Object System.Drawing.Point(10,25)
$btnO_0.Size = New-Object System.Drawing.Size(200, 25)
$btnO_0.Add_Click({
 
try {
        $progressBar.Value = 0
        $statusLabel.Text = "Limpiando caché..."

        Start-Sleep -Milliseconds 200
        $progressBar.Value = 20
        $statusLabel.Text = "Procesando Chrome..."
        Remove-Item "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue

        Start-Sleep -Milliseconds 300
        $progressBar.Value = 50
        $statusLabel.Text = "Procesando Edge..."
        Remove-Item "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue

        Start-Sleep -Milliseconds 300
        $progressBar.Value = 80
        $statusLabel.Text = "Procesando Firefox..."
        Remove-Item "$env:APPDATA\Mozilla\Firefox\Profiles\*\cache2\entries\*" -Recurse -Force -ErrorAction SilentlyContinue

        $progressBar.Value = 100
        $statusLabel.Text = "Caché limpiada correctamente"
    }
    catch {
        $statusLabel.Text = "Error: $_"
    }

})

$btnO_1 = New-Object System.Windows.Forms.Button
$btnO_1.Text = "Liberar Mermória"
$btnO_1.Location = New-Object System.Drawing.Point(10,55)
$btnO_1.Size = New-Object System.Drawing.Size(200, 25)
$btnO_1.Add_Click({
 
	try {
        $progressBar.Value = 0
        $statusLabel.Text = "Liberando memoria..."

        Start-Sleep -Milliseconds 200
        $progressBar.Value = 30
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()

        Start-Sleep -Milliseconds 300
        $progressBar.Value = 100
        $statusLabel.Text = "Memoria liberada (GC)"
    }
    catch {
        $statusLabel.Text = "Error: $_"
    }

})

$btnO_2 = New-Object System.Windows.Forms.Button
$btnO_2.Text = "Administrar Inicio Sistema"
$btnO_2.Location = New-Object System.Drawing.Point(10,90)
$btnO_2.Size = New-Object System.Drawing.Size(200, 25)
$btnO_2.Add_Click({
    $progressBar.Value = 0
    $statusLabel.Text = "Cargando programas de inicio..."
    Start-Sleep -Milliseconds 300
    $progressBar.Value = 30

    $inicioListView = New-Object System.Windows.Forms.ListView
    $inicioListView.View = 'Details'
    $inicioListView.FullRowSelect = $true
    $inicioListView.Size = New-Object System.Drawing.Size(900, 100)
    $inicioListView.Location = New-Object System.Drawing.Point(10,30)
    $inicioListView.Columns.Add("Nombre", 150)
    $inicioListView.Columns.Add("Ruta", 320)

    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    $items = Get-ItemProperty -Path $regPath

foreach ($prop in $items.PSObject.Properties) {
    if ($prop.Value -is [string]) {
        $entry = New-Object System.Windows.Forms.ListViewItem($prop.Name)
        $entry.SubItems.Add($prop.Value)
        $inicioListView.Items.Add($entry)
    }
}

    $btnEliminar = New-Object System.Windows.Forms.Button
    $btnEliminar.Text = "Eliminar Selección"
    $btnEliminar.Location = New-Object System.Drawing.Point(10,10)
    $btnEliminar.Size = New-Object System.Drawing.Size(140, 25)

    $btnEliminar.Add_Click({
        if ($inicioListView.SelectedItems.Count -gt 0) {
            $nombre = $inicioListView.SelectedItems[0].Text
            Remove-ItemProperty -Path $regPath -Name $nombre -ErrorAction SilentlyContinue
            $inicioListView.Items.Remove($inicioListView.SelectedItems[0])
            $statusLabel.Text = "Elemento eliminado: $nombre"
        }
    })

    $panel0.Controls.Clear()
    $panel0.Controls.Add($inicioListView)
    $panel0.Controls.Add($btnEliminar)
    $panel0.Controls.Add($progressBar)
    $panel0.Controls.Add($statusLabel)

    $progressBar.Value = 100
    $statusLabel.Text = "Programas de inicio cargados"
})

$btnO_3 = New-Object System.Windows.Forms.Button
$btnO_3.Text = "Rendimiento"
$btnO_3.Location = New-Object System.Drawing.Point(210,25)
$btnO_3.Size = New-Object System.Drawing.Size(200, 25)

$btnO_3.Add_Click({
    $progressBar.Value = 0
    $statusLabel.Text = "Cargando servicios..."
    Start-Sleep -Milliseconds 300
    $progressBar.Value = 30

    $serviceList = New-Object System.Windows.Forms.ListView
    $serviceList.View = 'Details'
    $serviceList.FullRowSelect = $true
    $serviceList.CheckBoxes = $true
    $serviceList.Size = New-Object System.Drawing.Size(500, 120)
    $serviceList.Location = New-Object System.Drawing.Point(10,30)
    $serviceList.Columns.Add("Servicio", 150)
    $serviceList.Columns.Add("Estado", 100)
    $serviceList.Columns.Add("Tipo de Inicio", 120)

    $servicios = Get-Service | Where-Object {
        $_.Status -eq 'Running' -and
        $_.Name -notmatch 'Windows|Update|Defender|W32Time|WSearch|Audio|PlugPlay'
    }

    foreach ($svc in $servicios) {
        $item = New-Object System.Windows.Forms.ListViewItem($svc.Name)
        $item.SubItems.Add($svc.Status.ToString())
        $item.SubItems.Add($svc.StartType.ToString())
        $serviceList.Items.Add($item)
    }

    $btnDetener = New-Object System.Windows.Forms.Button
    $btnDetener.Text = "Detener Seleccionados"
    $btnDetener.Location = New-Object System.Drawing.Point(10,10)
    $btnDetener.Size = New-Object System.Drawing.Size(250,20)

$btnDetener.Add_Click({
    
    $seleccionados = @()
        Write-Host "Total seleccionados: $($seleccionados.Count)"
    foreach ($item in $serviceList.Items) {
        if ($item.Checked) {
            $seleccionados += $item
        }
    }

    foreach ($item in $seleccionados) {
        $nombre = $item.Text
        $statusLabel.Text = "Deteniendo: $nombre"
        try {
            Stop-Service -Name $nombre -Force -ErrorAction SilentlyContinue
            Set-Service -Name $nombre -StartupType "Disabled" -ErrorAction SilentlyContinue

            $nuevo = New-Object System.Windows.Forms.ListViewItem($item.Text)
            $nuevo.SubItems.Add("Stopped")
            $nuevo.SubItems.Add("Disabled")
            $nuevo.Checked = $true

            $idx = $serviceList.Items.IndexOf($item)
            $serviceList.Items.RemoveAt($idx)
            $serviceList.Items.Insert($idx, $nuevo)
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show("Error deteniendo: $nombre")
        }
    }
    $statusLabel.Text = "Servicios optimizados"
})


    $panel0.Controls.Clear()
    $panel0.Controls.Add($serviceList)
    $panel0.Controls.Add($btnDetener)
    $panel0.Controls.Add($progressBar)
    $panel0.Controls.Add($statusLabel)

    $progressBar.Value = 100
    $statusLabel.Text = "Servicios cargados"
})

$btnO_4 = New-Object System.Windows.Forms.Button
$btnO_4.Text = "Archivos Basura"
$btnO_4.Location = New-Object System.Drawing.Point(210,55)
$btnO_4.Size = New-Object System.Drawing.Size(200, 25)
$btnO_4.Add_Click({
 
[System.Windows.Forms.MessageBox]::Show("Botón presionado") 

})

# Función para actualizar contenido
$updatePanel = {
    $panel0.Controls.Clear()
    switch ($comboBox.SelectedItem) {
        "Optimización" {
	$panel0.Controls.Add($progressBar)# Barra de progreso.
	$panel0.Controls.Add($statusLabel)# Label para el estatus de funciones.
	$panel0.Controls.Add($btnO_0)# Limpiar Cache Navegador.
	$panel0.Controls.Add($btnO_1)# Liberar Memoria.
	$panel0.Controls.Add($btnO_2)# Administrar Inicio Sistema.
        $panel0.Controls.Add($btnO_3)# Optimizar Servicios.
        $panel0.Controls.Add($btnO_4)# Archivos Basura.
        }
        "Seguridad" { 
	#$panel0.Controls.Add() 
        }
	"Monitorización" { 
	#$panel0.Controls.Add() 
        }
	"Recuperación" { 
	#$panel0.Controls.Add() 
        }
    }
}



$comboBox.Add_SelectedIndexChanged($updatePanel)
$updatePanel.Invoke()


$form.ShowDialog()