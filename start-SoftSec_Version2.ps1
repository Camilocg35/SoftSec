# --- Bloque de elevación automática ---
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Test-IsAdmin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdmin)) {
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = 'powershell.exe'
    $psi.Arguments = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    $psi.Verb = 'runas'
    try {
        [System.Diagnostics.Process]::Start($psi) | Out-Null
    } catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Se requieren permisos de administrador para ejecutar SoftSec.",
            "Permiso requerido",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
    }
    exit
}
# --- Fin del bloque de elevación ---

# El resto de tu código original sigue aquí...
# Importar funciones de la carpeta "Lógica"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
Import-Module "$scriptDir\Logic\Funciones.psm1"

# ... y todo el código que ya tienes en este archivo ...