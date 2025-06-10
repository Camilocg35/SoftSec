function Set-StatusText {
    param(
        $Label,
        [string]$Text
    )
    if ($null -ne $Label -and $Label.PSObject.Properties['Text']) {
        $Label.Text = $Text
    }
}

function Clear-BrowserCache {
    param(
        [System.Windows.Forms.ProgressBar]$ProgressBar,
        [System.Windows.Forms.Label]$StatusLabel
    )
    try {
        $ProgressBar.Value = 0
        Set-StatusText $StatusLabel "Limpiando caché..."

        Start-Sleep -Milliseconds 200
        $ProgressBar.Value = 20
        Set-StatusText $StatusLabel "Procesando Chrome..."
        Remove-Item "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue

        Start-Sleep -Milliseconds 300
        $ProgressBar.Value = 50
        Set-StatusText $StatusLabel "Procesando Edge..."
        Remove-Item "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue

        Start-Sleep -Milliseconds 300
        $ProgressBar.Value = 80
        Set-StatusText $StatusLabel "Procesando Firefox..."
        Remove-Item "$env:APPDATA\Mozilla\Firefox\Profiles\*\cache2\entries\*" -Recurse -Force -ErrorAction SilentlyContinue

        $ProgressBar.Value = 100
        Set-StatusText $StatusLabel "Caché limpiada correctamente"
    }
    catch {
        Set-StatusText $StatusLabel "Error: $_"
    }
}

function Free-SystemMemory {
    param(
        [System.Windows.Forms.ProgressBar]$ProgressBar,
        [System.Windows.Forms.Label]$StatusLabel
    )
    try {
        $ProgressBar.Value = 0
        Set-StatusText $StatusLabel "Liberando memoria..."

        Start-Sleep -Milliseconds 200
        $ProgressBar.Value = 30
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()

        Start-Sleep -Milliseconds 300
        $ProgressBar.Value = 100
        Set-StatusText $StatusLabel "Memoria liberada (GC)"
    }
    catch {
        Set-StatusText $StatusLabel "Error: $_"
    }
}

function Manage-Startup {
    param(
        [System.Windows.Forms.Panel]$Panel,
        [System.Windows.Forms.ProgressBar]$ProgressBar,
        [System.Windows.Forms.Label]$StatusLabel
    )
    $ProgressBar.Value = 0
    Set-StatusText $StatusLabel "Cargando programas de inicio..."
    Start-Sleep -Milliseconds 300
    $ProgressBar.Value = 30

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
            Set-StatusText $StatusLabel "Elemento eliminado: $nombre"
        }
    })

    $Panel.Controls.Clear()
    $Panel.Controls.Add($inicioListView)
    $Panel.Controls.Add($btnEliminar)
    $Panel.Controls.Add($ProgressBar)
    $Panel.Controls.Add($StatusLabel)

    $ProgressBar.Value = 100
    Set-StatusText $StatusLabel "Programas de inicio cargados"
}

function Optimize-Services {
    param(
        [System.Windows.Forms.Panel]$Panel,
        [System.Windows.Forms.ProgressBar]$ProgressBar,
        [System.Windows.Forms.Label]$StatusLabel
    )
    $ProgressBar.Value = 0
    Set-StatusText $StatusLabel "Cargando servicios..."
    Start-Sleep -Milliseconds 300
    $ProgressBar.Value = 30

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
        foreach ($item in $serviceList.Items) {
            if ($item.Checked) {
                $seleccionados += $item
            }
        }

        foreach ($item in $seleccionados) {
            $nombre = $item.Text
            Set-StatusText $StatusLabel "Deteniendo: $nombre"
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
        Set-StatusText $StatusLabel "Servicios optimizados"
    })

    $Panel.Controls.Clear()
    $Panel.Controls.Add($serviceList)
    $Panel.Controls.Add($btnDetener)
    $Panel.Controls.Add($ProgressBar)
    $Panel.Controls.Add($StatusLabel)

    $ProgressBar.Value = 100
    Set-StatusText $StatusLabel "Servicios cargados"
}

function Remove-JunkFiles {
    param(
        [System.Windows.Forms.ProgressBar]$ProgressBar,
        [System.Windows.Forms.Label]$StatusLabel
    )
    try {
        $ProgressBar.Value = 0
        Set-StatusText $StatusLabel "Eliminando archivos temporales..."
        Start-Sleep -Milliseconds 300
        $ProgressBar.Value = 30
        Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
        Start-Sleep -Milliseconds 300
        $ProgressBar.Value = 60
        Remove-Item "$env:WINDIR\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
        Start-Sleep -Milliseconds 300
        $ProgressBar.Value = 90
        try {
            $shell = New-Object -ComObject Shell.Application
            $recycle = $shell.NameSpace(0xa)
            $recycle.Items() | ForEach-Object {
                Remove-Item $_.Path -Recurse -Force -ErrorAction SilentlyContinue
            }
        } catch {}
        $ProgressBar.Value = 100
        Set-StatusText $StatusLabel "Archivos basura eliminados"
    }
    catch {
        Set-StatusText $StatusLabel "Error: $_"
    }
}


