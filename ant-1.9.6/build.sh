#!/bin/bash

mkdir -vp ${PREFIX}/bin;
mkdir -vp ${PREFIX}/share;

if [ "$(uname)" == "Darwin" ]; then
    echo "Spencer hasn't fixed this yet!!!"
    #export JAVA_HOME=$(/usr/libexec/java_home)
    #export JRE_HOME=${JAVA_HOME}/jre
else
    export JAVA_HOME="${PREFIX}/jdk"
    export JRE_HOME="${PREFIX}/jdk/jre"
fi

cat > ${PREFIX}/bin/ant <<EOF
#!/bin/bash

CWD="\$(cd "\$(dirname "\${0}")" && pwd -P)"
export ANT_HOME="\$(cd "\${CWD}/../share/${PKG_NAME}" && pwd -P)"

echo -e ""
echo -e "Setting up ANT_HOME for ant to \${ANT_HOME} ..."
echo -e "Launching ant ..."
echo -e ""
\${ANT_HOME}/bin/ant "\${@}"
EOF

chmod 755 ${PREFIX}/bin/ant || exit 1;

if [ "$(uname)" == "Darwin" ]; then
    mkdir ${PREFIX}/share/${PKG_NAME}
    cp -va ${SRC_DIR}/* ${PREFIX}/share/${PKG_NAME}/ || exit 1;
else
    mkdir ${PREFIX}/share/${PKG_NAME}
    cp -var ${SRC_DIR}/* ${PREFIX}/share/${PKG_NAME}/ || exit 1;
fi

pushd ${PREFIX}/share || exit 1;
ln -sv ${PKG_NAME}-${PKG_VERSION} ${PKG_NAME} || exit  1;
popd || exit 1;

chmod 755 ${PREFIX}/share/${PKG_NAME}/bin/* || exit 1;

