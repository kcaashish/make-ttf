#!/bin/bash

# source all the functions from the scripts/ folder
for file in ./scripts/*.sh; do
	source $file
done

echo "Setting up the environment for running the script"
setup

echo "Generating ttf files"
npm run generate_icons

echo "Downloading fontpatcher"
download_fontpatcher

echo "Moving fontpatcher to root directory"
move_fontpatcher

echo "Downloading FiraCode"
download_firacode

echo "Moving FiraCode to unpatched folder"
move_firacode

# search for these ttf files in fontpatcher/src/glyphs or its subfolder and replace them
echo "Replacing the ttf files in fontpatcher/src/glyphs with the newly created ones"
move_created_ttfs

echo "Patching FiraCode"
patch_firacode

echo "Done"
