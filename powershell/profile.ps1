# Configuration
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete



# Functions
function TextWithColor {
    param (
        [string]
        $Text,

        [ValidateSet(
            "Black",
            "Red",
            "Green",
            "Yellow",
            "Blue",
            "Magenta",
            "Cyan",
            "White"
        )]
        [string]
        $Color = "Default",

        [switch]
        $Bold
    )
    
    $SEQ_ESC = [char]27
    $SEQ_RESET = "$SEQ_ESC[0m"
    $SEQ_COLOR = switch ($Color) {
        "Black"   { "$SEQ_ESC[30m" }
        "Red"     { "$SEQ_ESC[31m" }
        "Green"   { "$SEQ_ESC[32m" }
        "Yellow"  { "$SEQ_ESC[33m" }
        "Blue"    { "$SEQ_ESC[34m" }
        "Magenta" { "$SEQ_ESC[35m" }
        "Cyan"    { "$SEQ_ESC[36m" }
        "White"   { "$SEQ_ESC[37m" }
        "Default" { "$SEQ_ESC[39m" }
    }
    
    $SEQ = $SEQ_COLOR
    if ($Bold) {
        $SEQ = "$SEQ_ESC[1m" + $SEQ
    }

    "$SEQ$Text$SEQ_RESET"
}

function Copy-SshId {
    param(
        [Parameter(Mandatory)]
        [String]$Username,

        [Parameter(Mandatory)]
        [String]$Hostname,

        [Parameter()]
        [String]$Port="22",

        [Parameter()]
        [String]$IdentityFile="$env:USERPROFILE\.ssh\id_rsa.pub"
    )

    if (Test-Path $IdentityFile -PathType Leaf) {
        Get-Content $IdentityFile | ssh $Username@$Hostname -p $Port "mkdir -p ~/.ssh && touch ~/.ssh/authorized_keys && chmod -R go= ~/.ssh && cat >> ~/.ssh/authorized_keys"
    } else {
        "Path not found."
    }
}

function Start-WorkDirectory {
    param(
        [Parameter(Mandatory)]
        [String]$DirectoryName
    )

    Set-Location -Path (New-Item -Path $DirectoryName -ItemType Directory).Name
}

function Find-Element {
    param(
        [Parameter(Mandatory)]
        [String]$Path
    )

    (Get-Command $Path).Source
}

function Get-LocationAsString {
    return (Get-Location).Path
}

function New-File {
	param(
		[Parameter(Mandatory)]
		[String]$Path
	)

	return New-Item -Type File -Path $Path
}

function New-Directory {
	param(
		[Parameter(Mandatory)]
		[String]$Path
	)

	return New-Item -Type Directory -Path $Path
}



# Aliases
Set-Alias -Name "ssh-copy-id" -Value Copy-SshId
Set-Alias -Name "mdcd" -Value Start-WorkDirectory
Set-Alias -Name "which" -Value Find-Element
Set-Alias -Name "pwd" -Value Get-LocationAsString
Set-Alias -Name "touch" -Value New-File
Set-Alias -Name "touchd" -Value New-Directory



# Session variables
$STARTUP_DIRECTORY = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
$TERMINAL_SETTINGS = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"



# Environment variables
$env:Path += ';C:\Program Files\Oracle\VirtualBox\'



# Prompt
function prompt {
    $location = (Get-Location).Path
    # $location = $location.replace($env:USERPROFILE, $(TextWithColor "~" -Color Magenta))
    # $location = $location.replace("\", $(TextWithColor "\" -Color Magenta))
    $location = $location.replace($env:USERPROFILE, "~")
    # $location = Split-Path -leaf -path (Get-Location)
    # $timestamp = Get-Date -Format "yyyy/MM/dd HH:mm:ss"	
    # $username = $env:USERNAME
    # $hostname = $env:COMPUTERNAME
    # $promptChar = [char]::ConvertFromUtf32(0x25BA)
    
    "$(TextWithColor "[" -Color Magenta)$location$(TextWithColor "]>" -Color Magenta) "
}



# Load custom scripts
$customScripts = "$env:USERPROFILE\Documents\PowerShell\CustomScripts"
if (Test-Path -Path $customScripts) {
    foreach ($script in Get-ChildItem -Path $customScripts\*.ps1 -File) {
        . $script.FullName
    }
} else {
    [void](New-Item -ItemType Directory -Path $customScripts)
}
