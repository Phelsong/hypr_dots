if ($PSVersionTable.PSVersion.Major -lt 4) {
    Write-Host "PowerShell version $($PSVersionTable.PSVersion) too old, kitty shell integration disabled"
    return
}

if ($MyInvocation.Interactive -ne $true) { return }
if ([string]::IsNullOrEmpty($Env:KITTY_SHELL_INTEGRATION)) { return }

# Load the normal PowerShell startup files
if ([string]::IsNullOrEmpty($Env:KITTY_BASH_INJECT) -ne $true) {
    $kitty_bash_inject = $Env:KITTY_BASH_INJECT
    $ksi_val = $Env:KITTY_SHELL_INTEGRATION
    Remove-Variable Env:KITTY_SHELL_INTEGRATION
    Remove-Variable Env:KITTY_BASH_INJECT
    Remove-Variable Env:ENV

    if ([string]::IsNullOrEmpty($Env:HOME)) { $Env:HOME = "~" }
    if ([string]::IsNullOrEmpty($Env:KITTY_BASH_ETC_LOCATION)) { $Env:KITTY_BASH_ETC_LOCATION = "/etc" }

    function _ksi_sourceable([string]$file) {
        return (Test-Path $file -PathType Leaf)
    }

    if ($kitty_bash_inject.Contains("posix")) {
        if (_ksi_sourceable($Env:KITTY_BASH_POSIX_ENV)) {
            . $Env:KITTY_BASH_POSIX_ENV
            $Env:ENV = $Env:KITTY_BASH_POSIX_ENV
        }
    } else {
        Set-StrictMode -Off

        if ([string]::IsNullOrEmpty($Env:KITTY_BASH_UNEXPORT_HISTFILE) -ne $true) {
            Remove-Variable Env:HISTFILE
            Remove-Variable Env:KITTY_BASH_UNEXPORT_HISTFILE
        }

        # See run_startup_files() in shell.c in the Bash source code
        if ($host.Name -eq "ConsoleHost") {
            if ($kitty_bash_inject.Contains("no-profile") -ne $true) {
                if (_ksi_sourceable("$($Env:KITTY_BASH_ETC_LOCATION)/profile")) { . "$($Env:KITTY_BASH_ETC_LOCATION)/profile" }
                foreach ($file in "$($Env:HOME)/.bash_profile", "$($Env:HOME)/.bash_login", "$($Env:HOME)/.profile") {
                    if (_ksi_sourceable($file)) { . $file; break }
                }
            }
        } else {
            if ($kitty_bash_inject.Contains("no-rc") -ne $true) {
                # Linux distros build bash with -DSYS_BASHRC. Unfortunately, there is
                # no way to to probe bash for it and different distros use different files
                # Arch, Debian, Ubuntu use /etc/bash.bashrc
                # Fedora uses /etc/bashrc sourced from ~/.bashrc instead of SYS_BASHRC
                # Void Linux uses /etc/bash/bashrc
                foreach ($file in "$($Env:KITTY_BASH_ETC_LOCATION)/bash.bashrc", "$($Env:KITTY_BASH_ETC_LOCATION)/bash/bashrc") {
                    if (_ksi_sourceable($file)) { . $file; break }
                }
                if ([string]::IsNullOrEmpty($Env:KITTY_BASH_RCFILE)) { $Env:KITTY_BASH_RCFILE = "$($Env:HOME)/.bashrc" }
                if (_ksi_sourceable($Env:KITTY_BASH_RCFILE)) { . $Env:KITTY_BASH_RCFILE }
            }
        }
    }

    Remove-Variable Env:KITTY_BASH_RCFILE
    Remove-Variable Env:KITTY_BASH_POSIX_ENV
    Remove-Variable Env:KITTY_BASH_ETC_LOCATION

    Remove-Item Function:_ksi_sourceable

    $Env:KITTY_SHELL_INTEGRATION = $ksi_val

    Remove-Variable _ksi_i, ksi_val, kitty_bash_inject
}

if ($PSBoundParameters.ContainsKey("_ksi_prompt")) {
    # we have already run
    Remove-Variable Env:KITTY_SHELL_INTEGRATION
    return
}

# this is defined outside _ksi_main to make it global without using declare -g
# which is not available on older bash

$_ksi_prompt = @{
  cursor='y'; title='y'; mark='y'; complete='y'; cwd='y'; ps0=''; ps0_suffix=''; ps1=''; ps1_suffix=''; ps2='';
  hostname_prefix=''; sourced='y'; last_reported_cwd=''
}

function _ksi_main() {
  foreach ($i in @($Env:KITTY_SHELL_INTEGRATION)) {
    switch ($i) {
      "no-cursor" { $_ksi_prompt.cursor = 'n' }
      "no-title" { $_ksi_prompt.title = 'n' }
      "no-prompt-mark" { $_ksi_prompt.mark = 'n' }
      "no-complete" { $_ksi_prompt.complete = 'n' }
      "no-cwd" { $_ksi_prompt.cwd = 'n' }
    }
  }
}



$ifs = $OFS

Remove-Variable Env:KITTY_SHELL_INTEGRATION

function _ksi_debug_print {
    # print a line to STDERR of parent kitty process
    $b = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($args))
    Write-Host "`eP@kitty-print|$b`e\\"
}

function _ksi_set_mark {
    $_ksi_prompt["$($args[0])_mark"] = "`e]133;k;$($args[0])_kitty`a"
}

_ksi_set_mark "start"
_ksi_set_mark "end"
_ksi_set_mark "start_secondary"
_ksi_set_mark "end_secondary"
_ksi_set_mark "start_suffix"
_ksi_set_mark "end_suffix"

Remove-Item Function:_ksi_set_mark

$_ksi_prompt.secondary_prompt = "`n$($_ksi_prompt.start_secondary_mark)`e]133;A;k=s`a$($_ksi_prompt.end_secondary_mark)"

function _ksi_prompt_command {
    # we first remove any previously added kitty code from the prompt variables and then add
    # it back, to ensure we have only a single instance
    if ([string]::IsNullOrEmpty($_ksi_prompt.ps0) -ne $true) {
        $global:PS0 = $global:PS0 -replace "\\\[\\e\]133;k;start_kitty\\a\\\]\*end_kitty\\a\\\]"
        $global:PS0 = "$($_ksi_prompt.ps0)$global:PS0"
    }
    if ([string]::IsNullOrEmpty($_ksi_prompt.ps0_suffix) -ne $true) {
        $global:PS0 = $global:PS0 -replace "\\\[\\e\]133;k;start_suffix_kitty\\a\\\]\*end_suffix_kitty\\a\\\]"
        $global:PS0 = "$global:PS0$($_ksi_prompt.ps0_suffix)"
    }
    # restore PS1 to its pristine state without our additions
    if ([string]::IsNullOrEmpty($_ksi_prompt.ps1) -ne $true) {
        $global:PS1 = $global:PS1 -replace "\\\[\\e\]133;k;start_kitty\\a\\\]\*end_kitty\\a\\\]"
        $global:PS1 = $global:PS1 -replace "\\\[\\e\]133;k;start_secondary_kitty\\a\\\]\*end_secondary_kitty\\a\\\]"
    }
    if ([string]::IsNullOrEmpty($_ksi_prompt.ps1_suffix) -ne $true) {
        $global:PS1 = $global:PS1 -replace "\\\[\\e\]133;k;start_suffix_kitty\\a\\\]\*end_suffix_kitty\\a\\\]"
    }
    if ([string]::IsNullOrEmpty($_ksi_prompt.ps1) -ne $true) {
        if (($_ksi_prompt.mark -eq "y") -and ($global:PS1.Contains("`n"))) {
            # PowerShell does not redraw the leading lines in a multiline prompt so
            # mark the last line as a secondary prompt. Otherwise on resize the
            # lines before the last line will be erased by kitty.
            # the first part removes everything from the last \n onwards
            # the second part appends a newline with the secondary marking
            # the third part appends everything after the last newline
            $global:PS1 = "$($global:PS1.Split("`n")[0..($global:PS1.Split("`n").Length-2)] -join "`n")$($_ksi_prompt.secondary_prompt)$($global:PS1.Split("`n")[-1])"
        }
        $global:PS1 = "$($_ksi_prompt.ps1)$global:PS1"
    }
    if ([string]::IsNullOrEmpty($_ksi_prompt.ps1_suffix) -ne $true) {
        $global:PS1 = "$global:PS1$($_ksi_prompt.ps1_suffix)"
    }
    if ([string]::IsNullOrEmpty($_ksi_prompt.ps2) -ne $true) {
        $global:PS2 = $global:PS2 -replace "\\\[\\e\]133;k;start_kitty\\a\\\]\*end_kitty\\a\\\]"
        $global:PS2 = "$($_ksi_prompt.ps2)$global:PS2"
    }

    if ($_ksi_prompt.cwd -eq "y") {
        # unfortunately PowerShell provides no hooks to detect cwd changes
        # in particular this means cwd reporting will not happen for a
        # command like cd /test && cat. PS0 is evaluated before cd is run.
        if ($_ksi_prompt.last_reported_cwd -ne (Get-Location).Path) {
            $_ksi_prompt.last_reported_cwd = (Get-Location).Path
            Write-Host "`e]7;kitty-shell-cwd://$($env:COMPUTERNAME)$(Get-Location)`a"
        }
    }
}



if ($_ksi_prompt.cursor -eq "y") {
    $_ksi_prompt.ps1_suffix += "`e[5 q"
    $_ksi_prompt.ps0_suffix += "`e[0 q"
}

if ($_ksi_prompt.title -eq "y") {
    if ([string]::IsNullOrEmpty($Env:KITTY_PID)) {
        if (([string]::IsNullOrEmpty($Env:SSH_TTY) -ne $true) -or ([string]::IsNullOrEmpty($Env:SSH2_TTY) -ne $true) -or ([string]::IsNullOrEmpty($Env:KITTY_WINDOW_ID) -ne $true)) {
            # connected to most SSH servers
            # or use ssh kitten to connected to some SSH servers that do not set SSH_TTY
            $_ksi_prompt.hostname_prefix = "$($env:COMPUTERNAME): "
        } elseif ((Get-Command who -ErrorAction SilentlyContinue) -and ((who -m 2>&1 | Out-String) -match "\([a-fA-F.:0-9]+\)$")) {
            # the shell integration script is installed manually on the remote system
            # the environment variables are cleared after sudo
            # OpenSSH's sshd creates entries in utmp for every login so use those
            $_ksi_prompt.hostname_prefix = "$($env:COMPUTERNAME): "
        }
    }
    # see https://www.gnu.org/software/bash/manual/html_node/Controlling-the-Prompt.html#Controlling-the-Prompt
    # we use suffix here because some distros add title setting to their bashrc files by default
    $_ksi_prompt.ps1_suffix += "`e]2;$($_ksi_prompt.hostname_prefix)$PWD`a"
    if (($Env:HISTCONTROL.Contains("ignoreboth")) -or ($Env:HISTCONTROL.Contains("ignorespace"))) {
        _ksi_debug_print "ignoreboth or ignorespace present in bash HISTCONTROL setting, showing running command in window title will not be robust"
    }
    function _ksi_get_current_command {
        $last_cmd = Get-History | Select-Object -Last 1 | ForEach-Object CommandLine
        Write-Host "`e]2;$($_ksi_prompt.hostname_prefix)$last_cmd`a"
    }
    $_ksi_prompt.ps0_suffix += '$(_ksi_get_current_command)'
}

if ($_ksi_prompt.mark -eq "y") {
    $_ksi_prompt.ps1 += "`e]133;A`a"
    $_ksi_prompt.ps2 += "`e]133;A;k=s`a"
    $_ksi_prompt.ps0 += "`e]133;C`a"
}

Set-Alias edit-in-kitty "kitten edit-in-kitty"

if ($_ksi_prompt.complete -eq "y") {
    function _ksi_completions {
        $limit = $args.Count + 1
        $src = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String((kitten __complete__ bash @args[0..$limit]).Split("|")[1]))
        if ($LASTEXITCODE -eq 0) { Invoke-Expression $src }
    }
    Register-ArgumentCompleter -CommandName kitty, edit-in-kitty, clone-in-kitty, kitten -ScriptBlock ${function:_ksi_completions}
}





# wrap our prompt additions in markers we can use to remove them using
# PowerShell's anemic pattern substitution
if ([string]::IsNullOrEmpty($_ksi_prompt.ps0) -ne $true) {
    $_ksi_prompt.ps0 = "$($_ksi_prompt.start_mark)$($_ksi_prompt.ps0)$($_ksi_prompt.end_mark)"
}
if ([string]::IsNullOrEmpty($_ksi_prompt.ps0_suffix) -ne $true) {
    $_ksi_prompt.ps0_suffix = "$($_ksi_prompt.start_suffix_mark)$($_ksi_prompt.ps0_suffix)$($_ksi_prompt.end_suffix_mark)"
}
if ([string]::IsNullOrEmpty($_ksi_prompt.ps1) -ne $true) {
    $_ksi_prompt.ps1 = "$($_ksi_prompt.start_mark)$($_ksi_prompt.ps1)$($_ksi_prompt.end_mark)"
}
if ([string]::IsNullOrEmpty($_ksi_prompt.ps1_suffix) -ne $true) {
    $_ksi_prompt.ps1_suffix = "$($_ksi_prompt.start_suffix_mark)$($_ksi_prompt.ps1_suffix)$($_ksi_prompt.end_suffix_mark)"
}
if ([string]::IsNullOrEmpty($_ksi_prompt.ps2) -ne $true) {
    $_ksi_prompt.ps2 = "$($_ksi_prompt.start_mark)$($_ksi_prompt.ps2)$($_ksi_prompt.end_mark)"
}

Remove-Variable _ksi_prompt.start_mark, _ksi_prompt.end_mark, _ksi_prompt.start_suffix_mark, _ksi_prompt.end_suffix_mark, _ksi_prompt.start_secondary_mark, _ksi_prompt.end_secondary_mark

# install our prompt command, using an array if it is unset or already an array,
# otherwise append a string. We check if _ksi_prompt_command exists as some shell
# scripts stupidly export PROMPT_COMMAND making it inherited by all programs launched
# from the shell
$pc = 'if (Test-Path Function:_ksi_prompt_command) { _ksi_prompt_command }'
if ([string]::IsNullOrEmpty($global:PROMPT_COMMAND)) {
    $global:PROMPT_COMMAND = @($pc)
} elseif ($global:PROMPT_COMMAND -is [Array]) {
    $global:PROMPT_COMMAND += $pc
} else {
    $global:PROMPT_COMMAND = $global:PROMPT_COMMAND.TrimEnd().TrimEnd(";") + "; $pc"
}

if ([string]::IsNullOrEmpty($Env:KITTY_IS_CLONE_LAUNCH) -ne $true) {
    $orig_conda_env = $Env:CONDA_DEFAULT_ENV
    Invoke-Expression $Env:KITTY_IS_CLONE_LAUNCH
    Remove-Variable Env:VIRTUAL_ENV

    function _ksi_s_is_ok([string]$arg) {
        return (([string]::IsNullOrEmpty($sourced)) -and ($Env:KITTY_CLONE_SOURCE_STRATEGIES.Contains(",$arg,")))
    }

    if (_ksi_s_is_ok("venv") -and ([string]::IsNullOrEmpty($Env:VIRTUAL_ENV) -ne $true) -and (Test-Path "$($Env:VIRTUAL_ENV)/bin/activate")) {
        $sourced = "y"
        . "$($Env:VIRTUAL_ENV)/bin/activate"
    }
    if (_ksi_s_is_ok("conda") -and ([string]::IsNullOrEmpty($Env:CONDA_DEFAULT_ENV) -ne $true) -and (Get-Command conda -ErrorAction SilentlyContinue) -and ($Env:CONDA_DEFAULT_ENV -ne $orig_conda_env)) {
        $sourced = "y"
        conda activate $Env:CONDA_DEFAULT_ENV
    }
    if (_ksi_s_is_ok("env_var") -and ([string]::IsNullOrEmpty($Env:KITTY_CLONE_SOURCE_CODE) -ne $true)) {
        $sourced = "y"
        Invoke-Expression $Env:KITTY_CLONE_SOURCE_CODE
    }
    if (_ksi_s_is_ok("path") -and (Test-Path $Env:KITTY_CLONE_SOURCE_PATH)) {
        $sourced = "y"
        . $Env:KITTY_CLONE_SOURCE_PATH
    }

    Remove-Item Function:_ksi_s_is_ok
}







# Ensure PATH has no duplicate entries
if ([string]::IsNullOrEmpty($Env:PATH) -ne $true) {
    $old_PATH = "$($Env:PATH):"
    $Env:PATH = ""
    while ([string]::IsNullOrEmpty($old_PATH) -ne $true) {
        $x = $old_PATH.Split(":")[0]
        if ($Env:PATH.Split(":") -notcontains $x) { $Env:PATH += ":$x" }
        $old_PATH = $old_PATH.Substring($old_PATH.IndexOf(":") + 1)
    }
    $Env:PATH = $Env:PATH.TrimStart(":")
}

Remove-Variable Env:KITTY_IS_CLONE_LAUNCH, Env:KITTY_CLONE_SOURCE_STRATEGIES

_ksi_main

Remove-Item Function:_ksi_main

if ($SHELLOPTS.Contains("posix") -ne $true) {
    function _ksi_transmit_data {
        $data = $args[0] -replace "\s"
        $pos = 0
        $chunk_num = 0
        while ($pos -lt $data.Length) {
            $chunk = $data.Substring($pos, [Math]::Min(2048, $data.Length - $pos))
            $pos += 2048
            Write-Host "`eP@kitty-$($args[1])|$chunk_num:$chunk`e\\"
            $chunk_num++
        }
        # save history so it is available in new shell
        if ($args[2] -eq "save_history") { Add-History }
        Write-Host "`eP@kitty-$($args[1])|`e\\"
    }

    function clone-in-kitty {
        param(
            [Parameter(ValueFromRemainingArguments=$true)]
            [string[]]$RemainingArguments
        )

        $bv = "$PSVersionTable.PSVersion.Major.$PSVersionTable.PSVersion.Minor.$PSVersionTable.PSVersion.Build"
        $data = "shell=powershell,pid=$PID,powershell_version=$bv,cwd=$([Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes((Get-Location).Path))),envfmt=powershell,env=$([Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes((Get-ChildItem Env: | ForEach-Object { '$Env:' + $_.Name + '="' + $_.Value + '"' }) -join "`n")))"
        foreach ($arg in @($RemainingArguments)) {
            switch ($arg) {
                "" { break }
                "-h", "--help" {
                    Write-Host "Clone the current PowerShell session into a new kitty window.`n`nFor usage instructions see: https://sw.kovidgoyal.net/kitty/shell-integration/#clone-shell"
                    return
                }
                default { $data += ",a=$([Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($arg)))" }
            }
        }
        _ksi_transmit_data "$data" "clone" "save_history"
    }
}
