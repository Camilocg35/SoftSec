function Set-StatusText {
    param(
        $Label,
        [string]$Text
    )
    if ($null -ne $Label -and $Label.PSObject.Properties.Match('Text')) {
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
    $Panel.Controls.Clear()

    $script:serviceList = New-Object System.Windows.Forms.ListView
    $script:serviceList.View = 'Details'
    $script:serviceList.FullRowSelect = $true
    $script:serviceList.CheckBoxes = $true
    $script:serviceList.Size = New-Object System.Drawing.Size(500, 120)
    $script:serviceList.Location = New-Object System.Drawing.Point(10,30)
    $script:serviceList.Columns.Add("Servicio", 150)
    $script:serviceList.Columns.Add("Estado", 100)
    $script:serviceList.Columns.Add("Tipo de Inicio", 120)

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
        $itemsToRemove = @()
        foreach ($item in @($serviceList.CheckedItems)) {
            $nombre = $item.Text
            Set-StatusText $StatusLabel "Deteniendo: $nombre"
            try {
                $svc = Get-Service -Name "$nombre" -ErrorAction Stop
                if ($svc.Status -eq 'Running') {
                    if ($svc.CanStop) {
                        Stop-Service -Name "$nombre" -Force -ErrorAction Stop
                        Set-Service -Name "$nombre" -StartupType Disabled -ErrorAction Stop
                        $itemsToRemove += $item
                        Set-StatusText $StatusLabel "Servicio detenido: $nombre"
                    } else {
                        [System.Windows.Forms.MessageBox]::Show(
                            "El servicio $nombre no puede ser detenido manualmente por el sistema.",
                            "No se puede detener",
                            [System.Windows.Forms.MessageBoxButtons]::OK,
                            [System.Windows.Forms.MessageBoxIcon]::Warning
                        )
                        Set-StatusText $StatusLabel "No se puede detener $nombre"
                    }
                } else {
                    Set-StatusText $StatusLabel "El servicio $nombre no está en ejecución."
                }
            } catch {
                [System.Windows.Forms.MessageBox]::Show(
                    "Error al detener el servicio: $nombre`n$($_.Exception.Message)",
                    "Error",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Error
                )
                Set-StatusText $StatusLabel "Error al detener $nombre"
            }
        }
        foreach ($item in $itemsToRemove) {
            $serviceList.Items.Remove($item)
        }
    })

    $Panel.Controls.Add($btnDetener)
    $Panel.Controls.Add($serviceList)
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