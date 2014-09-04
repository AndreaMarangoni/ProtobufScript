
#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd )";

function protocExists {
	{ hash protoc 2>/dev/null; return 0; } || { echo >&2 "genProto.sh requires 'protoc' but it's not installed.  Aborting."; exit 1; }
}

function compileProto {
	if protocExists; then
		for i in *.proto; do
			protoc -I=$1 --cpp_out=$2 $1/$i;
		done;
		saveDest $2;
	fi;
	return
}

function dirExists {
	if [ -d "$1" ]; then
		return 0;
	fi;
	return 1;
}

function cleanDestination {
	file="$DIR"/.build;
	destination=$(<$file)
	if [ -f "$file" ]; then		
		rm -f "$file"
	fi;
	cd "$destination"
	if [ $(ls -A "$destination") ]; then
		rm *.pb.h *.pb.cc
	fi
	return;
}

function saveDest {
	echo $1 > "$DIR"/.build;
	return;
}

function createDefines {
	cd "$dest"
	defines="defineMessages.h"
	if [ -f "$defines" ]; then
		rm "$defines";
	fi;
	echo "#ifndef DEFINE_MESSAGES_HH" >> "$defines"
	echo "#define DEFINE_MESSAGES_HH" >> "$defines"
	echo "" >> "$defines"
	echo "" >> "$defines"
	echo "/* DON'T EDIT THIS FILE. THIS FILE IS AUTOGENERATED */" >> "$defines"
	echo "" >> "$defines"
	echo "" >> "$defines"
	for i in $(ls *.pb.h); do 
		echo "#include \"protocol/""$i"\" >> "$defines"
	done
	echo "" >> "$defines"
	echo "" >> "$defines"
	echo "#endif" >> "$defines"
	echo "" >> "$defines"
	cd "$DIR";
	return;
}

function help {
	echo "Use:";
	echo " ./compileProto [-i sourceDir] [-o destDir] ";
	echo " "
	echo " -i sourceDir [--input sourceDir]"
	echo "        directory where .proto files are located"
	echo " "
	echo " -o destDir [--output destDir]"
	echo "        destination directory where generated files will be located"
	echo " "
	echo " --clean"
	echo "        if compilation already took place we clean everything on destination directory" 
	echo " "
	echo " -h or --help "
	echo "        show this help"
	
	return;
}

source=$(pwd)
dest=$(pwd)
cleaned=0;

while [[ $# > 0 ]];
do
	param="$1"
	shift
	case $param in 
		-i|--input)
		if dirExists $1; then
			source="$1"
			shift
		fi;
		;;
		-o|--output)
		if dirExists $1; then
			dest="$1"
			shift
		fi;
		;;
		-h|--help)
		help;
		;;
		--clean)
		cleaned=1;
		cleanDestination;
		;;
	esac
done;

[ ! $cleaned -eq 1 ] && compileProto $source $dest; createDefines;
