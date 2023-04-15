#!/bin/bash

download_fontpatcher() {
	# Get the latest release of fontpatcher
	LATEST_RELEASE=https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FontPatcher.zip

	# If fontpatcher folder exists, remove it
	if [ -d "output/fontpatcher" ]; then
		rm -rf output/fontpatcher
	fi

	# If the zip file exists, remove it
	if [ -f "output/fontpatcher.zip" ]; then
		rm -rf output/fontpatcher.zip
	fi

	# Download the latest release
	echo "Downloading fontpatcher..."
	curl -L -o output/fontpatcher.zip $LATEST_RELEASE

	# Unzip the downloaded file
	echo "Unzipping fontpatcher..."
	unzip -q output/fontpatcher.zip -d output/fontpatcher

	# Remove the zip file
	echo "Removing the zip file..."
	rm -rf output/fontpatcher.zip

	echo "fontpatcher has been downloaded and unzipped to the 'fontpatcher' folder."
}

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

	# Remove the zip file
	echo "Removing the zip file..."
	rm -rf output/firacode.zip

	echo "FiraCode has been downloaded and unzipped to the 'firacode' folder."
}
