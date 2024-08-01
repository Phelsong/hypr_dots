#alias dir="ls -luF --color"
alias dir="eza -lh --color always --icons always"
alias sysu="systemctl --user"
alias sys="sudo systemctl"
alias cls=clear
alias ni=touch
alias rni=mv
alias ci=code-insiders
alias py=python
alias lg=lazygit
alias lad=lazydocker
#
function yz() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

#
eval "$(zoxide init bash)"
