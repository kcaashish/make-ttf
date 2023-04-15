#!/bin/bash

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
