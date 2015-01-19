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

cat > ${PREFIX}/bin/mvn <<EOF
#!/bin/bash

CWD="\$(cd "\$(dirname "\${0}")" && pwd -P)"
export M2_HOME="\$(cd "\${CWD}/../share/${PKG_NAME}" && pwd -P)"
export M2="\${M2_HOME}/bin"
export MAVEN_OPTS="-Xms256m -Xmx512m"

echo -e ""
echo -e "Setting up M2_HOME for mvn to \${M2_HOME} ..."
echo -e "Launching mvn ..."
echo -e ""
\${M2}/mvn "\${@}"
EOF

chmod 755 ${PREFIX}/bin/mvn || exit 1;

if [ "$(uname)" == "Darwin" ]; then
    mkdir ${PREFIX}/share/${PKG_NAME}
    cp -va ${SRC_DIR}/* ${PREFIX}/share/${PKG_NAME}/ || exit 1;
else
    mkdir ${PREFIX}/share/maven
    cp -var ${SRC_DIR}/* ${PREFIX}/share/${PKG_NAME}/ || exit 1;
fi

pushd ${PREFIX}/share || exit 1;
ln -sv ${PKG_NAME}-${PKG_VERSION} ${PKG_NAME} || exit  1;
popd || exit 1;

chmod 755 ${PREFIX}/share/${PKG_NAME}/bin/* || exit 1;

