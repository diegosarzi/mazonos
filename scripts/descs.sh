#!/bin/bash

# Creating files for description.
for folder in $(ls); do
	cd $folder
	for filename in *.mz; do
        	tar -xf $filename ./info/desc
	   	mv info/desc $filename.desc
		echo "$folder $filename.desc"
	        rm -rf info
	done
	cd -
done
