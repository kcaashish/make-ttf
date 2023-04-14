#!/bin/bash

source "./scripts/spinner.sh"

# check if input-icons folder exists and create it if it doesn't
if [ ! -d "input-icons" ]; then
	mkdir input-icons
fi

# check if output folder exists and create it if it doesn't
if [ ! -d "output" ]; then
	mkdir output
fi

remove_symlinks() {
	# remove the old symlinks unlink
	for f in $(pwd)/input-icons/*; do
		# if input-icons is empty, skip
		if [ ! -e "$f" ] || [ -z "$(ls -A $f)" ]; then
			break
		fi
		if [ -L "$f" ]; then
			unlink "$f"
			rm -rf "$f"
		fi
	done
}

echo "Removing old symlinks for icons"
remove_symlinks
echo "Done"

# create symlinks to the icons
create_symlinks() {
	# get the submodules
	git submodule init &&
		git submodule update --recursive
	ln -s $(readlink -f submodules/octicons/icons) $(pwd)/input-icons/octicons &&
		ln -s $(readlink -f submodules/codicons/src/icons) $(pwd)/input-icons/codicons
}

echo "Creating new symlinks for icons"
create_symlinks &
spinner $!
echo "Done"

echo "Generating icons"
npm run generate_icons
echo "Done"

download_firacode() {
	# Get the latest release of FiraCode
	LATEST_RELEASE=$(curl -s https://api.github.com/repos/tonsky/FiraCode/releases/latest | grep "browser_download_url.*zip" | cut -d '"' -f 4)

	# If firacode folder exists, remove it
	if [ -d "output/firacode" ]; then
		rm -rf output/firacode
	fi

	# If the zip file exists, remove it
	if [ -f "output/firacode.zip" ]; then
		rm -rf output/firacode.zip
	fi

	# Download the latest release
	echo "Downloading FiraCode..."
	curl -L -o output/firacode.zip $LATEST_RELEASE

	# Unzip the downloaded file
	echo "Unzipping FiraCode..."
	unzip -q output/firacode.zip -d output/firacode

	echo "FiraCode has been downloaded and unzipped to the 'firacode' folder."
}

echo "Downloading FiraCode"
download_firacode
echo "Done"
