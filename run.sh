#!/bin/bash

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

# create symlinks to the icons
create_symlinks() {
	# get the submodules
	git submodule init &&
		git submodule update --recursive
	ln -s $(readlink -f submodules/octicons/icons) $(pwd)/input-icons/octicons &&
		ln -s $(readlink -f submodules/codicons/src/icons) $(pwd)/input-icons/codicons
}

echo "Creating new symlinks for icons"
create_symlinks

install_requirements() {
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
}

echo "Installing requirements"
install_requirements

echo "Generating ttf files"
npm run generate_icons

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

echo "Downloading fontpatcher"
download_fontpatcher

move_fontpatcher() {
	# if the fontpatcher folder exists, remove it
	if [ -d "fontpatcher" ]; then
		rm -rf fontpatcher
	fi

	# create the fontpatcher folder
	mkdir fontpatcher

	# move the fontpatcher to the root directory
	echo "Copying fontpatcher to root directory..."
	cp -r ./output/fontpatcher/bin ./fontpatcher/
	cp -r ./output/fontpatcher/src ./fontpatcher/
	cp ./output/fontpatcher/font-patcher ./fontpatcher/
	echo "fontpatcher has been copied to the root directory."
}

echo "Moving fontpatcher to root directory"
move_fontpatcher

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

echo "Downloading FiraCode"
download_firacode

move_firacode() {
	# if the firacode folder exists, remove it
	if [ -d "output/FiracodeUnpatched" ]; then
		rm -rf output/FiracodeUnpatched
	fi

	# create the firacode folder
	mkdir -p output/FiracodeUnpatched

	# move the firacode to the root directory
	echo "Copying FiraCode to root directory..."
	cp -r ./output/firacode/ttf/* ./output/FiracodeUnpatched/
	echo "FiraCode has been copied to the root directory."
}

echo "Moving FiraCode to unpatched folder"
move_firacode

move_created_ttfs() {
	# list all the ttf files in output directory in a variable
	ttfs=$(fd -t f -d 1 -e "ttf" . ./output/)

	# search for these ttf files in fontpatcher/src/glyphs or its subfolder and replace them
	for ttf in $ttfs; do
		# get the name of the ttf file
		similar_name=$(basename --suffix=.ttf $ttf)

		new_file=$(fd -t f "$similar_name*" ./fontpatcher/src/glyphs/)
		if [ -f "$new_file" ]; then
			echo "Making a backup of $new_file"
			cp $new_file $new_file.bak
			echo "Replacing $new_file in fontpatcher/src/glyphs with $ttf"
			cp $ttf $new_file
		fi
	done
}

# search for these ttf files in fontpatcher/src/glyphs or its subfolder and replace them
echo "Replacing the ttf files in fontpatcher/src/glyphs with the newly created ones"
move_created_ttfs

patch_firacode() {
	# if the firacode folder exists, remove it
	if [ -d "output/FiracodePatched" ]; then
		rm -rf output/FiracodePatched
	fi

	# create the firacode folder
	mkdir -p output/FiracodePatched

	# patch the font
	echo "Patching FiraCode..."
	# loop over the ttf files in the unpatched folder and patch them
	for ttf in ./output/FiracodeUnpatched/*.ttf; do
		./fontpatcher/font-patcher $ttf --complete --careful --progressbars --quiet -out ./output/FiracodePatched/
	done
	echo "FiraCode has been patched."
}

echo "Patching FiraCode"
patch_firacode

echo "Done"
