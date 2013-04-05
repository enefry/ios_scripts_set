#
# 将需要共享的 头文件 放在 copy Headers 里面 , 编译后在xcodeprj文件同级目录下生成 Debug 目录 / Release 目录, 里面有 模拟器和真机 都可以使用的 framework , 并有单独存在的framework 内容
#
#
#
#
#

set -e

mkdir -p "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.framework/Versions/A/Headers"

# Link the "Current" version to "A"
/bin/ln -sfh A "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.framework/Versions/Current"
/bin/ln -sfh Versions/Current/Headers "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.framework/Headers"
/bin/ln -sfh "Versions/Current/${PRODUCT_NAME}" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.framework/${PRODUCT_NAME}"

# The -a ensures that the headers maintain the source modification date so that we don't constantly
# cause propagating rebuilds of files that import these headers.
if [ -d "${TARGET_BUILD_DIR}/${PUBLIC_HEADERS_FOLDER_PATH}/" ]; then
/bin/cp -a "${TARGET_BUILD_DIR}/${PUBLIC_HEADERS_FOLDER_PATH}/" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.framework/Versions/A/Headers"
fi

#set -e
set +u
# Avoid recursively calling this script.
if [[ $SF_MASTER_SCRIPT_RUNNING ]]
then
exit 0
fi
set -u
export SF_MASTER_SCRIPT_RUNNING=1

SF_TARGET_NAME="${TARGET_NAME}"
SF_EXECUTABLE_PATH="lib${SF_TARGET_NAME}.a"
SF_WRAPPER_NAME="${SF_TARGET_NAME}.framework"

# The following conditionals come from
# https://github.com/kstenerud/iOS-Universal-Framework

if [[ "$SDK_NAME" =~ ([A-Za-z]+) ]]
then
SF_SDK_PLATFORM=${BASH_REMATCH[1]}
else
echo "Could not find platform name from SDK_NAME: $SDK_NAME"
exit 1
fi

if [[ "$SDK_NAME" =~ ([0-9]+.*$) ]]
then
SF_SDK_VERSION=${BASH_REMATCH[1]}
else
echo "Could not find sdk version from SDK_NAME: $SDK_NAME"
exit 1
fi

if [[ "$SF_SDK_PLATFORM" = "iphoneos" ]]
then
SF_OTHER_PLATFORM=iphonesimulator
else
SF_OTHER_PLATFORM=iphoneos
fi

if [[ "$BUILT_PRODUCTS_DIR" =~ (.*)$SF_SDK_PLATFORM$ ]]
then
SF_OTHER_BUILT_PRODUCTS_DIR="${BASH_REMATCH[1]}${SF_OTHER_PLATFORM}"
else
echo "Could not find platform name from build products directory: $BUILT_PRODUCTS_DIR"
exit 1
fi

# Build the other platform.
xcodebuild -project "${PROJECT_FILE_PATH}" -target "${TARGET_NAME}" -configuration "${CONFIGURATION}" -sdk ${SF_OTHER_PLATFORM}${SF_SDK_VERSION} BUILD_DIR="${BUILD_DIR}" OBJROOT="${OBJROOT}" BUILD_ROOT="${BUILD_ROOT}" SYMROOT="${SYMROOT}" $ACTION

# Smash the two static libraries into one fat binary and store it in the .framework

#lipo -create "${BUILT_PRODUCTS_DIR}/${SF_EXECUTABLE_PATH}" "${SF_OTHER_BUILT_PRODUCTS_DIR}/${SF_EXECUTABLE_PATH}" -output "${BUILT_PRODUCTS_DIR}/${SF_WRAPPER_NAME}/Versions/A/${SF_TARGET_NAME}"


# Copy the binary to the other architecture folder to have a complete framework in both.
#cp -a "${BUILT_PRODUCTS_DIR}/${SF_WRAPPER_NAME}/Versions/A/${SF_TARGET_NAME}" "${SF_OTHER_BUILT_PRODUCTS_DIR}/${SF_WRAPPER_NAME}/Versions/A/${SF_TARGET_NAME}"





# 创建通用的 Framework
FRAMEWORK="${BUILD_DIR}/${SF_WRAPPER_NAME}/Versions/A/${SF_TARGET_NAME}"

if [ -d "${BUILD_DIR}/${SF_WRAPPER_NAME}" ]; then
rm -r "${BUILD_DIR}/${SF_WRAPPER_NAME}"
fi

cp -a "${BUILT_PRODUCTS_DIR}/${SF_WRAPPER_NAME}" "${BUILD_DIR}"

lipo -create "${BUILT_PRODUCTS_DIR}/${SF_EXECUTABLE_PATH}" "${SF_OTHER_BUILT_PRODUCTS_DIR}/${SF_EXECUTABLE_PATH}" -output "${BUILD_DIR}/${SF_WRAPPER_NAME}/Versions/A/${SF_TARGET_NAME}"

# 创建各自的 Framework
mv "${BUILT_PRODUCTS_DIR}/${SF_EXECUTABLE_PATH}" "${BUILT_PRODUCTS_DIR}/${SF_WRAPPER_NAME}/Versions/A/${SF_TARGET_NAME}"
mv "${SF_OTHER_BUILT_PRODUCTS_DIR}/${SF_EXECUTABLE_PATH}" "${SF_OTHER_BUILT_PRODUCTS_DIR}/${SF_WRAPPER_NAME}/Versions/A/${SF_TARGET_NAME}"

# 移动 framework
if [ -d "${PROJECT_FILE_PATH}/../${CONFIGURATION}" ]; then
rm -r "${PROJECT_FILE_PATH}/../${CONFIGURATION}"
fi
mkdir "${PROJECT_FILE_PATH}/../${CONFIGURATION}"

mv  "${BUILT_PRODUCTS_DIR}/${SF_WRAPPER_NAME}" "${PROJECT_FILE_PATH}/../${CONFIGURATION}/iphoneos"
mv  "${SF_OTHER_BUILT_PRODUCTS_DIR}/${SF_WRAPPER_NAME}" "${PROJECT_FILE_PATH}/../${CONFIGURATION}/iphonesimulator"
mv  "${BUILD_DIR}/${SF_WRAPPER_NAME}" "${PROJECT_FILE_PATH}/../${CONFIGURATION}"



