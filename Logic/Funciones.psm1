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
        $itemsToRemove = @()
        foreach ($item in @($serviceList.CheckedItems)) {
            $nombre = $item.SubItems[0].Text
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

function Start-WinFR-Recovery {
    param(
        [System.Windows.Forms.Panel]$Panel,
        [System.Windows.Forms.ProgressBar]$ProgressBar,
        [System.Windows.Forms.Label]$StatusLabel
    )

    $Panel.Controls.Clear()

    # Variables de script para los controles, accesibles en los eventos
    $script:txtSource = New-Object System.Windows.Forms.TextBox
    $script:txtDest = New-Object System.Windows.Forms.TextBox
    $script:txtFilter = New-Object System.Windows.Forms.TextBox
    $script:cbMode = New-Object System.Windows.Forms.ComboBox
    $script:txtAdvanced = New-Object System.Windows.Forms.TextBox

    # Título
    $lblTitle = New-Object System.Windows.Forms.Label
    $lblTitle.Text = "Recuperación avanzada de archivos (Windows File Recovery)"
    $lblTitle.Font = New-Object System.Drawing.Font("Segoe UI",12,[System.Drawing.FontStyle]::Bold)
    $lblTitle.Size = New-Object System.Drawing.Size(500,24)
    $lblTitle.Location = New-Object System.Drawing.Point(10,5)
    $Panel.Controls.Add($lblTitle)

    # Unidad origen
    $lblSource = New-Object System.Windows.Forms.Label
    $lblSource.Text = "Unidad de origen (ej: C:)"
    $lblSource.Location = New-Object System.Drawing.Point(10,40)
    $Panel.Controls.Add($lblSource)

    $script:txtSource.Location = New-Object System.Drawing.Point(200,38)
    $script:txtSource.Width = 40
    $script:txtSource.Text = "C:"
    $Panel.Controls.Add($script:txtSource)

    # Carpeta destino
    $lblDest = New-Object System.Windows.Forms.Label
    $lblDest.Text = "Carpeta destino (debe ser otra unidad, ej: E:\Recuperado)"
    $lblDest.Location = New-Object System.Drawing.Point(10,70)
    $Panel.Controls.Add($lblDest)

    $script:txtDest.Location = New-Object System.Drawing.Point(310,68)
    $script:txtDest.Width = 220
    $script:txtDest.Text = "E:\Recuperado"
    $Panel.Controls.Add($script:txtDest)

    $btnChooseDest = New-Object System.Windows.Forms.Button
    $btnChooseDest.Text = "Elegir carpeta"
    $btnChooseDest.Location = New-Object System.Drawing.Point(540,68)
    $btnChooseDest.Width = 100
    $Panel.Controls.Add($btnChooseDest)

    # Filtro de archivos
    $lblFilter = New-Object System.Windows.Forms.Label
    $lblFilter.Text = "Filtro de archivos (ej: *.docx, *.jpg, *.*)"
    $lblFilter.Location = New-Object System.Drawing.Point(10,100)
    $Panel.Controls.Add($lblFilter)

    $script:txtFilter.Location = New-Object System.Drawing.Point(200,98)
    $script:txtFilter.Width = 140
    $script:txtFilter.Text = "*.*"
    $Panel.Controls.Add($script:txtFilter)

    # Modo de recuperación
    $lblMode = New-Object System.Windows.Forms.Label
    $lblMode.Text = "Modo de recuperación"
    $lblMode.Location = New-Object System.Drawing.Point(10,130)
    $Panel.Controls.Add($lblMode)

    $script:cbMode.Location = New-Object System.Drawing.Point(200,128)
    $script:cbMode.Width = 120
    $script:cbMode.Items.AddRange(@(
        "Regular (Rápido, NTFS)",
        "Extensive (Lento, profundidad máxima)",
        "Segment (Por segmentos, NTFS avanzado)"
    ))
    $script:cbMode.SelectedIndex = 0
    $Panel.Controls.Add($script:cbMode)

    # Botón ayuda sobre modos
    $btnHelp = New-Object System.Windows.Forms.Button
    $btnHelp.Text = "¿Modos?"
    $btnHelp.Location = New-Object System.Drawing.Point(330,128)
    $btnHelp.Width = 70
    $Panel.Controls.Add($btnHelp)

    $btnHelp.Add_Click({
        [System.Windows.Forms.MessageBox]::Show(
@"
Modo Regular: Rápido, para archivos borrados recientemente en discos NTFS.
Modo Extensive: Escaneo profundo, para archivos borrados hace tiempo, discos formateados o FAT/exFAT.
Modo Segment: Usa segmentos NTFS (avanzado), útil si el MFT sigue presente.
Más info: https://aka.ms/winfr
"@, "Ayuda de modos de recuperación", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    })

    # Otros parámetros de WinFR
    $lblAdvanced = New-Object System.Windows.Forms.Label
    $lblAdvanced.Text = "Opciones avanzadas WinFR (opcional):"
    $lblAdvanced.Location = New-Object System.Drawing.Point(10,170)
    $Panel.Controls.Add($lblAdvanced)

    $script:txtAdvanced.Location = New-Object System.Drawing.Point(230,168)
    $script:txtAdvanced.Width = 400
    $script:txtAdvanced.Text = ""
    $Panel.Controls.Add($script:txtAdvanced)

    # Botón para ayuda avanzada
    $btnAdvHelp = New-Object System.Windows.Forms.Button
    $btnAdvHelp.Text = "Opciones WinFR"
    $btnAdvHelp.Location = New-Object System.Drawing.Point(640,168)
    $btnAdvHelp.Width = 110
    $Panel.Controls.Add($btnAdvHelp)

    $btnAdvHelp.Add_Click({
        [System.Windows.Forms.MessageBox]::Show(
@"
WinFR soporta opciones como:
/y:<carpeta>   Recupera solo desde una carpeta específica
/u             Recupera archivos comprimidos
/x             Recupera archivos fragmentados
/!             No sobrescribe archivos existentes en destino
/n <filtro>    Filtro de nombre (usa varios /n para varios filtros)
/r             Recupera archivos de sólo lectura
Más info: Ejecuta winfr.exe /? en consola.
"@, "Opciones avanzadas WinFR", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    })

    # Botón para elegir carpeta de destino
    $btnChooseDest.Add_Click({
        $fbd = New-Object System.Windows.Forms.FolderBrowserDialog
        if ($fbd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $script:txtDest.Text = $fbd.SelectedPath
        }
    })

    # Barra de progreso visual
    $ProgressBar.Location = New-Object System.Drawing.Point(10, 210)
    $ProgressBar.Width = 740
    $ProgressBar.Value = 0
    $Panel.Controls.Add($ProgressBar)

    # Etiqueta de estado
    $StatusLabel.Location = New-Object System.Drawing.Point(10, 240)
    $StatusLabel.Width = 740
    $StatusLabel.Text = ""
    $Panel.Controls.Add($StatusLabel)

    # Botón de recuperación
    $btnRecover = New-Object System.Windows.Forms.Button
    $btnRecover.Text = "Iniciar recuperación"
    $btnRecover.Location = New-Object System.Drawing.Point(10, 270)
    $btnRecover.Width = 200
    $btnRecover.Height = 40
    $btnRecover.Font = New-Object System.Drawing.Font("Segoe UI",11,[System.Drawing.FontStyle]::Bold)
    $Panel.Controls.Add($btnRecover)

    # Botón para abrir carpeta destino
    $btnOpenDest = New-Object System.Windows.Forms.Button
    $btnOpenDest.Text = "Abrir carpeta destino"
    $btnOpenDest.Location = New-Object System.Drawing.Point(220, 270)
    $btnOpenDest.Width = 200
    $btnOpenDest.Height = 40
    $btnOpenDest.Font = New-Object System.Drawing.Font("Segoe UI",11)
    $Panel.Controls.Add($btnOpenDest)

    $btnOpenDest.Add_Click({
        if ($script:txtDest.Text -and (Test-Path $script:txtDest.Text)) {
            Start-Process explorer.exe $script:txtDest.Text
        }
    })

    # Acción principal del botón de recuperación
    $btnRecover.Add_Click({
        $ProgressBar.Value = 0

        $src = $script:txtSource.Text
        $dst = $script:txtDest.Text
        $filter = $script:txtFilter.Text
        $modeIdx = $script:cbMode.SelectedIndex
        $mode = switch ($modeIdx) {
            0 { "regular" }
            1 { "extensive" }
            2 { "segment" }
            default { "regular" }
        }
        $advanced = $script:txtAdvanced.Text

        if ([string]::IsNullOrWhiteSpace($src) -or [string]::IsNullOrWhiteSpace($dst)) {
            Set-StatusText $StatusLabel "Debe completar origen y destino."
            return
        }

        $winfr = (Get-Command winfr.exe -ErrorAction SilentlyContinue).Source
        if (-not $winfr) {
            [System.Windows.Forms.MessageBox]::Show("No se encontró winfr.exe. Instale 'Windows File Recovery' desde Microsoft Store.","WinFR no encontrado")
            Set-StatusText $StatusLabel "winfr.exe no está instalado"
            return
        }

        if (!(Test-Path $dst)) { New-Item -Path $dst -ItemType Directory -Force | Out-Null }

        $args = "$src $dst /$mode /n $filter"
        if ($advanced -and $advanced.Trim() -ne "") {
            $args += " $advanced"
        }

        Set-StatusText $StatusLabel "Ejecutando Windows File Recovery..."
        $ProgressBar.Value = 25

        Start-Process -FilePath $winfr -ArgumentList $args -Wait -WindowStyle Normal

        $ProgressBar.Value = 100
        Set-StatusText $StatusLabel "Recuperación finalizada. Revise la carpeta destino."
    })
}