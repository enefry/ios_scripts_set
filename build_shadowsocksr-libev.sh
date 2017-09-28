
pushd .

if [ ! -d 'build-iOS' ];then
    mkdir build-iOS
fi
pushd .
cd ios.supports/openssl
if [ ! -d include/openssl -o ! -f lib/libcrypto.a -o ! -f lib/libssl.a  ];then
    source ./build-libssl.sh
else
    echo 'openssl is build before'
fi
popd

pushd .
cd ios.supports/pcre
if [ ! -d include -o ! -f lib/libpcre.a ];then
    source ./build-pcre.sh
else
    echo 'pcre is build before'
fi
popd

echo "using simulator , iPhoneos sdk must codesign !!"
cd build-iOS
cmake \
-DCMAKE_TOOLCHAIN_FILE=../ios.supports/ios.toolchain.cmake  \
-DOPENSSL_ROOT_DIR=../ios.supports/openssl/ \
-DOPENSSL_CRYPTO_LIBRARY=../ios.supports/openssl/lib \
-DOPENSSL_INCLUDE_DIR=../ios.supports/openssl/include \
-DPCRE_INCLUDE_DIR=../ios.supports/pcre/include	\
-DPCRE_LIBRARY=../ios.supports/pcre/lib \
-DIOS_PLATFORM=ALL \
-GXcode ../

echo 'please remove runtime from sodium !! '
sleep 3

echo current pas is `pwd`
targets="sodium libcork libipset ev udns libshadowsocks-libev"
project="shadowsocks-libev"
for target in ${targets}
do
echo "^^^^^^^^^^^^^^^^^^^^^^^ build target=${target} ^^^^^^^^^^^^^^^^^^^^^^^"
xcodebuild -project $project.xcodeproj -configuration RelWithDebInfo -target $target -sdk iphoneos10.3   DSTROOT=$(pwd)/xb_out OBJROOT=$(pwd)/xb_out/objects SYMROOT=$(pwd)/xb_out  2>&1|tee build_log.txt
if [ $? != 0 ];then
echo "build target ${target} fail !"
exit $?
fi


xcodebuild -project $project.xcodeproj -configuration RelWithDebInfo -target $target -sdk iphonesimulator10.3  DSTROOT=$(pwd)/xb_out OBJROOT=$(pwd)/xb_out/objects SYMROOT=$(pwd)/xb_out  2>&1|tee build_log.txt
if [ $? != 0 ];then
echo "build target ${target} fail !"
exit $?
fi

done


if [ ! -d RelWithDebInfo ];then
    mkdir RelWithDebInfo/
fi

targets="sodium cork ipset ev udns shadowsocks-libev"
for target in ${targets}
do
echo "^^^^^^^^^^^^^^^^^^^^^^^ lipo ${target} ^^^^^^^^^^^^^^^^^^^^^^^"
lipo -create ./xb_out/RelWithDebInfo-iphoneos/lib$target.a ./xb_out/RelWithDebInfo-iphonesimulator/lib$target.a -output ./RelWithDebInfo/lib$target.a
done

cd ../

popd

