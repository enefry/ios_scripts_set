

VERSION='8.41'

URL='https://ftp.pcre.org/pub/pcre/pcre-$VERSION.tar.gz'
CURRENTPATH=`pwd`
SRCROOT="${CURRENTPATH}/src/pcre-${VERSION}"


set -e
if [ ! -e pcre-${VERSION}.tar.gz ]; then
echo "Downloading pcre-${VERSION}.tar.gz"
curl -O https://ftp.pcre.org/pub/pcre/pcre-$VERSION.tar.gz
else
echo "Using pcre-${VERSION}.tar.gz"
fi


mkdir -p "${CURRENTPATH}/src"
mkdir -p "${CURRENTPATH}/bin"
mkdir -p "${CURRENTPATH}/lib"

tar zxf pcre-$VERSION.tar.gz -C "${CURRENTPATH}/src"
cd bin

cmake \
-DCMAKE_TOOLCHAIN_FILE=../../ios.toolchain.cmake  \
-DIOS_PLATFORM=ALL  \
-DPCRE_BUILD_TESTS=OFF  \
-DPCRE_REBUILD_CHARTABLES=OFF \
-DPCRE_BUILD_PCREGREP=OFF   \
-GXcode "../src/pcre-${VERSION}"

sleep 1

xcodebuild -project PCRE.xcodeproj -configuration RelWithDebInfo -target pcre  			-sdk iphoneos10.3
xcodebuild -project PCRE.xcodeproj -configuration RelWithDebInfo -target pcrecpp  		-sdk iphoneos10.3
xcodebuild -project PCRE.xcodeproj -configuration RelWithDebInfo -target pcreposix  	-sdk iphoneos10.3

xcodebuild -project PCRE.xcodeproj -configuration RelWithDebInfo -target pcre  			-sdk iphonesimulator10.3
xcodebuild -project PCRE.xcodeproj -configuration RelWithDebInfo -target pcrecpp  		-sdk iphonesimulator10.3
xcodebuild -project PCRE.xcodeproj -configuration RelWithDebInfo -target pcreposix  	-sdk iphonesimulator10.3



echo "Build library..."

lipo -create ./RelWithDebInfo-iphonesimulator/libpcre.a 		./RelWithDebInfo-iphoneos/libpcre.a 		-output ../lib/libpcre.a
lipo -create ./RelWithDebInfo-iphonesimulator/libpcrecpp.a 		./RelWithDebInfo-iphoneos/libpcrecpp.a		-output ../lib/libpcrecpp.a
lipo -create ./RelWithDebInfo-iphonesimulator/libpcreposix.a 	./RelWithDebInfo-iphoneos/libpcreposix.a 	-output ../lib/libpcreposix.a

mkdir -p ../include
mkdir -p ../include/pcre
find . -name "*.h" -exec cp {} ../include/pcre \;
echo "Done."
