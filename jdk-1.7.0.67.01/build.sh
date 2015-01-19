#!/bin/bash

#### Download in build because we have to set cookies ####
# Check if we're on OS X
if [ $(uname) = "Darwin" ]; then
	curl -k -b oraclelicense=accept-securebackup-cookie -o jdk.dmg -L 'http://download.oracle.com/otn-pub/java/jdk/7u67-b01/jdk-7u67-macosx-x64.dmg'

	# Extract files like in
	# http://stackoverflow.com/questions/15217200/how-to-install-java-7-on-mac-in-custom-location
	hdiutil attach -mountpoint jdk_mount jdk.dmg
	pkgutil --expand jdk_mount/JDK\ 7\ Update\ 67.pkg java
	hdiutil detach jdk_mount
	cat java/jdk17067.pkg/Payload | cpio -zi
	mv Contents/Home "$PREFIX/jdk"
else
	if [ "$ARCH" = "32" ]; then
		curl -k -b oraclelicense=accept-securebackup-cookie -o jdk.tar.gz -L 'http://download.oracle.com/otn-pub/java/jdk/7u67-b01/jdk-7u67-linux-i586.tar.gz'
	else
		curl -k -b oraclelicense=accept-securebackup-cookie -o jdk.tar.gz -L 'http://download.oracle.com/otn-pub/java/jdk/7u67-b01/jdk-7u67-linux-x64.tar.gz'
	fi

	# Extract files
	tar -xzvf jdk.tar.gz
	mv jdk1.7.0_67 "$PREFIX/jdk"
fi

# Make symlinks so that things are in the prefix's bin directory
mkdir -p "$PREFIX/bin"
cd "$PREFIX/bin"
for filename in ../jdk/bin/*; do
	ln -s $filename $(basename $filename)
done

# Make symlinks so that things are in the prefix's lib directory
mkdir -p "$PREFIX/lib"
cd "$PREFIX/lib"
for filename in ../jdk/lib/*; do
	ln -s $filename $(basename $filename)
done

# grrrr... the lib directory has some subdirectories
if [ $(uname) = "Darwin" ]; then
    echo "HEY!  Spencer hasn't fixed this case yet!"
else
	if [ "$ARCH" = "32" ]; then
        echo "HEY!  Spencer hasn't fixed this case yet!"
    else
        cd "$PREFIX/lib"
        for filename in ../jdk/jre/lib/amd64/*; do
        	ln -s $filename $(basename $filename)
        done
        for filename in ../jdk/jre/lib/amd64/jli/*; do
        	ln -s $filename $(basename $filename)
        done
        for filename in ../jdk/jre/lib/amd64/headless/*; do
        	ln -s $filename $(basename $filename)
        done
        for filename in ../jdk/jre/lib/amd64/server/libjvm.so; do
        	ln -s $filename $(basename $filename)
        done
    fi
fi
