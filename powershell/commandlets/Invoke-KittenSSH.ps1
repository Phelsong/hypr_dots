kitten ssh $args

# hostname
# hostname *
# The hostname that the following options apply to. A glob pattern to match multiple hosts can be used. Multiple hostnames can also be specified, separated by spaces. The hostname can include an optional username in the form user@host. When not specified options apply to all hosts, until the first hostname specification is found. Note that matching of hostname is done against the name you specify on the command line to connect to the remote host. If you wish to include the same basic configuration for many different hosts, you can do so with the include directive. In version 0.28.0 the behavior of this option was changed slightly, now, when a hostname is encountered all its config values are set to defaults instead of being inherited from a previous matching hostname block. In particular it means hostnames dont inherit configurations, thereby avoiding hard to understand action-at-a-distance.

# interpreter
# interpreter sh
# The interpreter to use on the remote host. Must be either a POSIX complaint shell or a python executable. If the default sh is not available or broken, using an alternate interpreter can be useful.

# remote_dir
# remote_dir .local/share/kitty-ssh-kitten
# The location on the remote host where the files needed for this kitten are installed. Relative paths are resolved with respect to $HOME.

# Copy-Item
# Copy-Item files and directories from local to remote hosts. The specified files are assumed to be relative to the HOME directory and copied to the HOME on the remote. Directories are copied recursively. If absolute paths are used, they are copied as is. For example:

# Copy-Item .vimrc .zshrc .config/some-dir
# Use --dest to copy a file to some other destination on the remote host:

# Copy-Item --dest some-other-name some-file
# Glob patterns can be specified to copy multiple files, with --glob:

# Copy-Item --glob images/*.png
# Files can be excluded when copying with --exclude:

# Copy-Item --glob --exclude *.jpg --exclude *.bmp images/*
# Files whose remote name matches the exclude pattern will not be copied. For more details, see The copy command.

# Login shell environment
# shell_integration
# shell_integration inherited
# Control the shell integration on the remote host. See Shell integration for details on how this setting works. The special value inherited means use the setting from kitty.conf. This setting is useful for overriding integration on a per-host basis.

# login_shell
# The login shell to execute on the remote host. By default, the remote user account’s login shell is used.

# env
# Specify the environment variables to be set on the remote host. Using the name with an equal sign (e.g. env VAR=) will set it to the empty string. Specifying only the name (e.g. env VAR) will remove the variable from the remote shell environment. The special value _kitty_copy_env_var_ will cause the value of the variable to be copied from the local environment. The definitions are processed alphabetically. Note that environment variables are expanded recursively, for example:

# env VAR1=a
# env VAR2=${HOME}/${VAR1}/b
# The value of VAR2 will be <path to home directory>/a/b.

# cwd
# The working directory on the remote host to change to. Environment variables in this value are expanded. The default is empty so no changing is done, which usually means the HOME directory is used.

# color_scheme
# Specify a color scheme to use when connecting to the remote host. If this option ends with .conf, it is assumed to be the name of a config file to load from the kitty config directory, otherwise it is assumed to be the name of a color theme to load via the themes kitten. Note that only colors applying to the text/background are changed, other config settings in the .conf files/themes are ignored.

# remote_kitty
# remote_kitty if-needed
# Make kitten available on the remote host. Useful to run kittens such as the icat kitten to display images or the transfer file kitten to transfer files. Only works if the remote host has an architecture for which pre-compiled kitten binaries are available. Note that kitten is not actually copied to the remote host, instead a small bootstrap script is copied which will download and run kitten when kitten is first executed on the remote host. A value of if-needed means kitten is installed only if not already present in the system-wide PATH. A value of yes means that kitten is installed even if already present, and the installed kitten takes precedence. Finally, no means no kitten is installed on the remote host. The installed kitten can be updated by running: kitten update-self on the remote host.

# SSH configuration
# share_connections
# share_connections yes
# Within a single kitty instance, all connections to a particular server can be shared. This reduces startup latency for subsequent connections and means that you have to enter the password only once. Under the hood, it uses SSH ControlMasters and these are automatically cleaned up by kitty when it quits. You can map a shortcut to close_shared_ssh_connections to disconnect all active shared connections.

# askpass
# askpass unless-set
# Control the program SSH uses to ask for passwords or confirmation of host keys etc. The default is to use kitty’s native askpass, unless the SSH_ASKPASS environment variable is set. Set this option to ssh to not interfere with the normal ssh askpass mechanism at all, which typically means that ssh will prompt at the terminal. Set it to native to always use kitty’s native, built-in askpass implementation. Note that not using the kitty askpass implementation means that SSH might need to use the terminal before the connection is established, so the kitten cannot use the terminal to send data without an extra roundtrip, adding to initial connection latency.

# delegate
# Do not use the SSH kitten for this host. Instead run the command specified as the delegate. For example using delegate ssh will run the ssh command with all arguments passed to the kitten, except kitten specific ones. This is useful if some hosts are not capable of supporting the ssh kitten.

# forward_remote_control
# forward_remote_control no
# Forward the kitty remote control socket to the remote host. This allows using the kitty remote control facilities from the remote host. WARNING: This allows any software on the remote host full access to the local computer, so only do it for trusted remote hosts. Note that this does not work with abstract UNIX sockets such as @mykitty because of SSH limitations. This option uses SSH socket forwarding to forward the socket pointed to by the KITTY_LISTEN_ON environment variable.

# The copy command
# copy [options] file-or-dir-to-copy ...
# Copy files and directories from local to remote hosts. The specified files are assumed to be relative to the HOME directory and copied to the HOME on the remote. Directories are copied recursively. If absolute paths are used, they are copied as is.

# Options
# --glob
# Interpret file arguments as glob patterns. Globbing is based on standard wildcards with the addition that /**/ matches any number of directories. See the detailed syntax.

# --dest <DEST>
# The destination on the remote host to copy to. Relative paths are resolved relative to HOME on the remote host. When this option is not specified, the local file path is used as the remote destination (with the HOME directory getting automatically replaced by the remote HOME). Note that environment variables and ~ are not expanded.

# --exclude <EXCLUDE>
# A glob pattern. Files with names matching this pattern are excluded from being transferred. Only used when copying directories. Can be specified multiple times, if any of the patterns match the file will be excluded. If the pattern includes a / then it will match against the full path, not just the filename. In such patterns you can use /**/ to match zero or more directories. For example, to exclude a directory and everything under it use **/directory_name. See the detailed syntax for how wildcards match.

# --symlink-strategy <SYMLINK_STRATEGY>
# Control what happens if the specified path is a symlink. The default is to preserve the symlink, re-creating it on the remote machine. Setting this to resolve will cause the symlink to be followed and its target used as the file/directory to copy. The value of keep-path is the same as resolve except that the remote file path is derived from the symlink’s path instead of the path of the symlink’s target. Note that this option does not apply to symlinks encountered while recursively copying directories, those are always preserved. Default: preserve Choices: keep-path, preserve, resolve
