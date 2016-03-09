#!/bin/bash

# download tarball
if [ $(uname) = "Darwin" ]; then
	curl -k -b oraclelicense=accept-securebackup-cookie -o jdk.dmg -L 'http://download.oracle.com/otn-pub/java/jdk/8u74-b02/jdk-8u74-macosx-x64.dmg'

	# Extract files like in
	# http://stackoverflow.com/questions/15217200/how-to-install-java-7-on-mac-in-custom-location
	hdiutil attach -mountpoint jdk_mount jdk.dmg
	pkgutil --expand jdk_mount/JDK\ 8\ Update\ 74.pkg java
	hdiutil detach jdk_mount
	cat java/jdk18074.pkg/Payload | cpio -zi
	mv Contents/Home "$PREFIX/jdk"
else
	if [ "$ARCH" = "32" ]; then
		curl -k -b oraclelicense=accept-securebackup-cookie -o jdk.tar.gz -L 'http://download.oracle.com/otn-pub/java/jdk/8u74-b02/jdk-8u74-linux-i586.tar.gz'
	else
		curl -k -b oraclelicense=accept-securebackup-cookie -o jdk.tar.gz -L 'http://download.oracle.com/otn-pub/java/jdk/8u74-b02/jdk-8u74-linux-x64.tar.gz'
	fi

	# Extract files
	tar -xzvf jdk.tar.gz
	mv jdk1.8.0_74 "$PREFIX/jdk"
fi

# Make symlinks so that things are in the prefix's bin directory
mkdir -p "$PREFIX/bin"
cd "$PREFIX/bin"
for filename in ../jdk/bin/*; do
	ln -s $filename $(basename $filename)
done
