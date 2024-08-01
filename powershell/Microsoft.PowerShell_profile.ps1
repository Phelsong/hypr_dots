### --- @Phelsong - Arch Linux  --- ###
# -----------------------
#$Env:PYTHON_KEYRING_BACKEND = "keyring.backends.fail.Keyring"
$ENV:PATH += ":~/.config/powershell/commandlets:"
$ENV:Editor = "hx"
# ------------------------------------------------------------------------------- 
# @Shortcuts
Set-Alias ci "code-insiders" 
Set-Alias py python
Set-Alias dots Enter-Dots.ps1
Set-Alias code Enter-Code.ps1
Set-Alias icat Invoke-KittenCat.ps1
Set-Alias kssh Invoke-KittenSSH.ps1
Set-Alias kclip Invoke-KittenClip.ps1
Set-Alias fp Find-Package.ps1
Set-Alias hyc Get-Clients.ps1
Set-Alias supw Invoke-WithSudo.ps1
Set-Alias clients Get-Clients.ps1
# -------------------------------------------------------------------------------
# @Terminal Icons
Import-Module -Name Terminal-Icons
# -------------------------------------------------------------------------------
# @Oh-My-Posh 
oh-my-posh init pwsh --config "~/.config/powershell/MyPosh.toml" | Invoke-Expression
# -------------------------------------------------------------------------------
Import-Module $PSScriptRootio/completors/gh_completor.ps1
Import-Module $PSScriptRoot/completors/zoxide.ps1
# Import-Module $PSScriptRoot/completors/typer_completor.ps1
# Import-Module $PSScriptRoot/completors/pip_completor.ps1
# -------------------------------------------------------------------------------

function yz {
	
	$tmp = [System.IO.Path]::GetTempFileName()
	if ($args) {
		yazi $args --cwd-file="$tmp"	
	}
 else {
		$location = Get-Location
		yazi $location --cwd-file="$tmp" 
	}
    
	$cwd = Get-Content -Path $tmp
	if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
		Set-Location -Path $cwd
	}
	Remove-Item -Path $tmp
}
#$ENV:TEST_VAR="hello"
