# GLM shim - calls the z.ps1 wrapper script
# This provides an alternative naming convention representing the GLM model family

# Get the directory where this script is located
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Call the z.ps1 script with all arguments
& "$ScriptDir\z.ps1" @args

