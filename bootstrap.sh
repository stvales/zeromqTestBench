#!/bin/sh

if [ -e /usr/local/bin/brew ]; then
    echo "Removing zeromq stack from homebrew if needed"
    brew remove -f zyre czmq zeromq libsodium
else
    echo "Installing homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi
echo "Checking and installing system dependencies"
brew install autoconf automake cmake libtool pkgconfig
brew upgrade autoconf automake cmake libtool pkgconfig

cd ..
mkdir sysroot
WORKPATH=$PWD

if [ ! -e libsodium ]; then
    echo "Cloning libsodium"
    git clone -b stable ssh://git@gitlab.ingescape.com:2222/third-party/libsodium.git
fi
cd libsodium
./autogen.sh && ./configure --prefix=$WORKPATH/sysroot/usr/local/ && make -j8
make install
make clean
cd ..

if [ ! -e libzmq ]; then
    echo "Cloning libzmq"
    git clone git@github.com:stvales/libzmq.git
    git remote add zeromq git@github.com:zeromq/libzmq.git
fi
cd libzmq
mkdir build
cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug -DWITH_LIBSODIUM=ON -DENABLE_DRAFTS=ON -DWITH_TLS=OFF -DCMAKE_PREFIX_PATH=$WORKPATH/sysroot/usr/local/
make -j8 -C build DESTDIR=$WORKPATH/sysroot/ install
rm -Rf build
mkdir -p builds/xcode
cmake -S . -B builds/xcode -DCMAKE_BUILD_TYPE=Debug -DWITH_LIBSODIUM=ON -DENABLE_DRAFTS=ON -DWITH_TLS=OFF -DCMAKE_PREFIX_PATH=$WORKPATH/sysroot/usr/local/ -G "Xcode"
cd ..

if [ ! -e czmq ]; then
    echo "Cloning czmq"
    git clone git@github.com:stvales/czmq.git
    git remote add zeromq git@github.com:zeromq/czmq.git
fi
cd czmq
mkdir build
cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug -DENABLE_DRAFTS=ON -DCMAKE_PREFIX_PATH=$WORKPATH/sysroot/usr/local/
make -j8 -C build DESTDIR=$WORKPATH/sysroot/ install
mkdir -p builds/xcode
cmake -S . -B builds/xcode -DCMAKE_BUILD_TYPE=Debug -DENABLE_DRAFTS=ON -DCMAKE_PREFIX_PATH=$WORKPATH/sysroot/usr/local/ -G "Xcode"
#Hack to enable xcode project embedding
#because scripts acommpanying the xcode project do not manage
#target folder properly:
mkdir -p builds/xcode/Debug
cp build/libczmq.?.?.?.dylib builds/xcode/Debug
rm -Rf build
cd ..

if [ ! -e zyre ]; then
    echo "Cloning zyre"
    git clone git@github.com:stvales/zyre.git
    git remote add zeromq git@github.com:zeromq/zyre.git
fi
cd zyre
mkdir build
cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug -DENABLE_DRAFTS=ON -DCMAKE_PREFIX_PATH=$WORKPATH/sysroot/usr/local/
make -j8 -C build DESTDIR=$WORKPATH/sysroot/ install
mkdir -p builds/xcode
cmake -S . -B builds/xcode -DCMAKE_BUILD_TYPE=Debug -DENABLE_DRAFTS=ON -DCMAKE_PREFIX_PATH=$WORKPATH/sysroot/usr/local/ -G "Xcode"
#Hack to enable xcode project embedding
#because scripts acommpanying the xcode project do not manage
#target folder properly:
mkdir -p builds/xcode/Debug
cp build/libzyre.?.?.?.dylib builds/xcode/Debug
rm -Rf build
cd ..
