#!/bin/bash

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
