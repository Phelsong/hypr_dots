kitten icat $args

# --align <ALIGN>
# Horizontal alignment for the displayed image. Default: center Choices: center, left, right

# --place <PLACE>
# Choose where on the screen to display the image. The image will be scaled to fit into the specified rectangle. The syntax for specifying rectangles is <width>x<height>@<left>x<top>. All measurements are in cells (i.e. cursor positions) with the origin (0, 0) at the top-left corner of the screen. Note that the --align option will horizontally align the image within this rectangle. By default, the image is horizontally centered within the rectangle. Using place will cause the cursor to be positioned at the top left corner of the image, instead of on the line after the image.

# --scale-up
# When used in combination with --place it will cause images that are smaller than the specified area to be scaled up to use as much of the specified area as possible.

# --background <BACKGROUND>
# Specify a background color, this will cause transparent images to be composited on top of the specified color. Default: none

# --mirror <MIRROR>
# Mirror the image about a horizontal or vertical axis or both. Default: none Choices: both, horizontal, none, vertical

# --clear
# Remove all images currently displayed on the screen.

# --transfer-mode <TRANSFER_MODE>
# Which mechanism to use to transfer images to the terminal. The default is to auto-detect. file means to use a temporary file, memory means to use shared memory, stream means to send the data via terminal escape codes. Note that if you use the file or memory transfer modes and you are connecting over a remote session then image display will not work. Default: detect Choices: detect, file, memory, stream

# --detect-support
# Detect support for image display in the terminal. If not supported, will exit with exit code 1, otherwise will exit with code 0 and print the supported transfer mode to stderr, which can be used with the --transfer-mode option.

# --detection-timeout <DETECTION_TIMEOUT>
# The amount of time (in seconds) to wait for a response from the terminal, when detecting image display support. Default: 10

# --print-window-size
# Print out the window size as <width>x<height> (in pixels) and quit. This is a convenience method to query the window size if using kitten icat from a scripting language that cannot make termios calls.

# --stdin <STDIN>
# Read image data from STDIN. The default is to do it automatically, when STDIN is not a terminal, but you can turn it off or on explicitly, if needed. Default: detect Choices: detect, no, yes

# --silent
# Not used, present for legacy compatibility.

# --engine <ENGINE>
# The engine used for decoding and processing of images. The default is to use the most appropriate engine. The builtin engine uses Go’s native imaging libraries. The magick engine uses ImageMagick which requires it to be installed on the system. Default: auto Choices: auto, builtin, magick

# --z-index <Z_INDEX>, -z <Z_INDEX>
# Z-index of the image. When negative, text will be displayed on top of the image. Use a double minus for values under the threshold for drawing images under cell background colors. For example, --1 evaluates as -1,073,741,825. Default: 0

# --loop <LOOP>, -l <LOOP>
# Number of times to loop animations. Negative values loop forever. Zero means only the first frame of the animation is displayed. Otherwise, the animation is looped the specified number of times. Default: -1

# --hold
# Wait for a key press before exiting after displaying the images.

# --unicode-placeholder
# Use the Unicode placeholder method to display the images. Useful to display images from within full screen terminal programs that do not understand the kitty graphics protocol such as multiplexers or editors. See Unicode placeholders for details. Note that when using this method, placed (with --place) images that do not fit on the screen, will get wrapped at the screen edge instead of getting truncated. This wrapping is per line and therefore the image will look like it is interleaved with blank lines.

# --passthrough <PASSTHROUGH>
# Whether to surround graphics commands with escape sequences that allow them to passthrough programs like tmux. The default is to detect when running inside tmux and automatically use the tmux passthrough escape codes. Note that when this option is enabled it implies --unicode-placeholder as well. Default: detect Choices: detect, none, tmux

# --image-id <IMAGE_ID>
# The graphics protocol id to use for the created image. Normally, a random id is created if needed. This option allows control of the id. When multiple images are sent, sequential ids starting from the specified id are used. Valid ids are from 1 to 4294967295. Numbers outside this range are automatically wrapped. Default: 0
