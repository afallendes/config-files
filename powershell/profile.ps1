# Init

function ImportInstall-Module {
    param (
        [string[]]$List
    )

    foreach($module in $List) {
        if (Get-Module -ListAvailable $module) {
            Import-Module $module
        } else {
            # Module does not exist, install it
            Write-Host "Installing... '$module'"
            Install-Module $module -Scope CurrentUser -Force
            Import-Module $module
        }
    }
}

ImportInstall-Module -List (
    "PSReadLine",
    "Posh-Git",
    "Terminal-Icons"
)



# Configuration

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineOption -PredictionSource History



# Helpers

function Reload-Profile { . $PROFILE; Clear-Host }

function Format-Text {
    <#
    .SYNOPSIS
        Returnes customized/formatted text.
    .DESCRIPTION
        The Format-Text cmdlet returns the passed text as a formatted version
        following the params privded based on $PSStyle.
    #>
    [CmdletBinding()]
    param (
        [string]$Text,
        
        [string]$ForegroundColor = "Default",
        [string]$BackgroundColor = "Default",

        [ValidateSet('Bold', 'Italic', 'Underline', 'Strikethrough')]
        [string]$Style = "Default"
    )

    function Test-ValidateColorSet {
        
        param (
            [ValidateSet(
                "Default",
                "Black",
                "BrightBlack",
                "White",
                "BrightWhite",
                "Red",
                "BrightRed",
                "Magenta",
                "BrightMagenta",                                                                                                                                                                                                                                                         
                "Blue",
                "BrightBlue",
                "Cyan",
                "BrightCyan",
                "Green",
                "BrightGreen",
                "Yellow"
            )]

            [string]$Value
        )

    }

    Test-ValidateColorSet -Value $ForegroundColor
    Test-ValidateColorSet -Value $BackgroundColor

    return Join-String -Input (
        $($PSStyle.$Style),
        $($PSStyle.Background.$BackgroundColor),
        $($PSStyle.Foreground.$ForegroundColor),
        $Text,
        $($PSStyle.Reset)
    )
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

	return New-Item -Type File -Path $Path -Force
}

function New-Directory {
	param(
		[Parameter(Mandatory)]
		[String]$Path
	)

	return New-Item -Type Directory -Path $Path -Force
}



# Aliases

Set-Alias -Name "ssh-copy-id" -Value Copy-SshId
Set-Alias -Name "mdcd" -Value Start-WorkDirectory
Set-Alias -Name "which" -Value Find-Element
Set-Alias -Name "pwd" -Value Get-LocationAsString
Set-Alias -Name "touch" -Value New-File
Set-Alias -Name "touchd" -Value New-Directory
Set-Alias -Name "cat" -Value bat # scoop
Set-Alias -Name "reload" -Value Reload-Profile



# Environment variables

$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$PROFILE = $MyInvocation.MyCommand.Path
$STARTUPDIR = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
$PWSH_PROFILE_PS1 = $PROFILE
$PWSH_PROFILE_DIR = Split-Path $PROFILE
$WINDOWSTERMINAL_SETTINGS_JSON = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"



# Posh-Git Prompt

function CustomPoshGitPrompt {

    $user = Join-String -Input (
        "$(if ($env:UserDomain -ne $env:ComputerName) { "$env:UserDomain\" })",
        "$env:UserName@$env:ComputerName"
    )
    $timestamp = '$(Get-Date -f "HH:mm:ss")' # single quote to be evaluated each time
    $logo = "$(Format-Text -Text "PS" -ForegroundColor "Magenta" -Style "Bold")"
    $path = '$($(Get-Location).Path.replace($env:USERPROFILE, "~"))' # single quote to be evaluated each time

    $promptPrefix = "[$timestamp] $logo "
    $promptPath = "[$(Format-Text -Text $path -ForegroundColor "BrightBlack")]"
    $promptSuffix = "$(":" * ($nestedPromptLevel + 1))"


    $GitPromptSettings.DefaultPromptPrefix.Text = $promptPrefix
    $GitPromptSettings.DefaultPromptPath.Text = $promptPath
    $GitPromptSettings.DefaultPromptSuffix.Text = $promptSuffix
}

CustomPoshGitPrompt
        


# Load extra scripts

$PWSH_SCRIPTS_DIR = "$PWSH_PROFILE_DIR\Scripts"
if (Test-Path -Path $PWSH_SCRIPTS_DIR) {
    foreach ($script in Get-ChildItem -Path $PWSH_SCRIPTS_DIR\*.ps1 -File) {
        . $script.FullName
    }
} else {
    [void](New-Item -ItemType Directory -Path $PWSH_SCRIPTS_DIR)
}
