useful_scripts
==============



iOS_build_static_library_to_framework.sh 
一个将静态库打包为通用静态 framework 的脚本.

build_shadowsocksr-libev.sh
build ssr 脚本 依赖 ios.supports 中的 cmake 支持 , 需要在sodium工程移除 runtime 文件


ios.supports\
ios.toolchain.cmake
cmake toolchain 支持. IOS_PLATFORM=ALL 可以编译 arm x86 x64 平台 自动选 xcode 自动选 sdk (先安装commandline 支持,  xcodebuild 可用情况下)
    
build-libssl.sh
编译 openssl 脚本

build-pcre.sh
编译 pcre 脚本 , 依赖 cmake



