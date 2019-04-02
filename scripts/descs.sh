#!/bin/bash

# Extrai desc e cria .desc dos arquivos
for folder in *; do
	cd $folder
	for filename in *.mz; do 
        	tar -xf $filename ./info/desc
	   	mv info/desc $filename.desc
	        rm -rf info
	done
	cd ..
done
