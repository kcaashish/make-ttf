#!/bin/bash

setup() {
	# check if input-icons folder exists and create it if it doesn't
	# if it does exist, delete it and create a new one
	echo "Creating input-icons folder..."
	if [ -d "input-icons" ]; then
		rm -rf input-icons
		mkdir input-icons
	else
		mkdir input-icons
	fi

	# check if output folder exists and create it if it doesn't
	# if it does exist, delete it and create a new one
	echo "Creating output folder..."
	if [ -d "output" ]; then
		rm -rf output
		mkdir output
	else
		mkdir output
	fi

	# install the requirements
	echo "Installing requirements for generating ttf files..."
	npm install

	# install fontforge
	echo "Installing fontforge..."
	# check if fontforge is installed
	if ! command -v fontforge &>/dev/null; then
		echo "fontforge could not be found. Installing fontforge..."
		sudo dnf install fontforge -y || sudo apt install fontforge python3-fontforge -y || brew install fontforge || sudo pacman -S fontforge
	else
		echo "fontforge is already installed."
	fi

	# remove the old symlinks unlink
	echo "Removing old symlinks..."
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

	# clone the submodules
	echo "Cloning submodules..."
	git submodule update --init --recursive

	# create the new symlinks
	echo "Creating new symlinks..."
	ln -s $(readlink -f submodules/octicons/icons) $(pwd)/input-icons/octicons &&
		ln -s $(readlink -f submodules/codicons/src/icons) $(pwd)/input-icons/codicons

}
