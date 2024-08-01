# @Typer/Completer
Set-PSReadLineKeyHandler -Chord Tab -Function MenuComplete
$scriptblock = {
	param($wordToComplete, $commandAst, $cursorPosition)
	$Env:_MAIN.PY_COMPLETE = "complete_powershell"
	$Env:_TYPER_COMPLETE_ARGS = $commandAst.ToString()
	$Env:_TYPER_COMPLETE_WORD_TO_COMPLETE = $wordToComplete
	main.py | ForEach-Object {
		$commandArray = $_ -Split ":::"
		$command = $commandArray[0]
		$helpString = $commandArray[1]
		[System.Management.Automation.CompletionResult]::new(
			$command, $command, 'ParameterValue', $helpString)
	}
	$Env:_MAIN.PY_COMPLETE = ""
	$Env:_TYPER_COMPLETE_ARGS = ""
	$Env:_TYPER_COMPLETE_WORD_TO_COMPLETE = ""
}
# -------------------------------------------------------------------------------
Register-ArgumentCompleter -Native -CommandName main.py -ScriptBlock $scriptblock