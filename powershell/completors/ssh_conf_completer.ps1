# @Typer/Completer
Set-PSReadLineKeyHandler -Chord Tab -Function MenuComplete
$scriptblock = {
    param($wordToComplete, $commandAst, $cursorPosition)
    $Env:_MAIN.SSH_CONF = "complete_powershell"
    $Env:_SSH_CONF_COMPLETE_ARGS = $commandAst.ToString()
    $Env:_SSH_CONF_COMPLETE_WORD_TO_COMPLETE = $wordToComplete
    config | ForEach-Object {
        $commandArray = $_ -Split ":::"
        $command = $commandArray[0]
        $helpString = $commandArray[1]
        [System.Management.Automation.CompletionResult]::new(
            $command, $command, 'ParameterValue', $helpString)
    }
    $Env:_MAIN.SSH_CONF = ""
    $Env:_SSH_CONF_COMPLETE_ARGS = ""
    $Env:_SSH_CONF_COMPLETE_WORD_TO_COMPLETE = ""
}
# -------------------------------------------------------------------------------
Register-ArgumentCompleter -Native -CommandName ~/.ssh/ssh_conf.py -ScriptBlock $scriptblock
