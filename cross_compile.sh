#!/bin/bash

export STAGING_DIR="/lede/staging_dir"

export BUILD_DIR="$1"
shift

if [ "$BUILD_DIR" = "" ]
then
 echo "$0 BUILD_DIR"
 exit
fi

# define the toolchain and target names
TOOLCHAIN_NAME="toolchain-mipsel_24kc_gcc-5.4.0_musl"
TARGET_NAME="target-mipsel_24kc_musl"

# toolchain paths
TOOLCHAIN="$STAGING_DIR/$TOOLCHAIN_NAME"
TOOLCHAIN_BIN="$TOOLCHAIN/bin"
TOOLCHAIN_INCLUDE="$TOOLCHAIN/include"
TOOLCHAIN_LIB="$TOOLCHAIN/lib"
TOOLCHAIN_USR_INCLUDE="$TOOLCHAIN/usr/include"
TOOLCHAIN_USR_LIB="$TOOLCHAIN/usr/lib"

# target paths
TARGET="$STAGING_DIR/$TARGET_NAME"
TARGET_INCLUDE="$TARGET/include"
TARGET_LIB="$TARGET/lib"
TARGET_USR_INCLUDE="$TARGET/usr/include"
TARGET_USR_LIB="$TARGET/usr/lib"

# define the compilers and such
TOOLCHAIN_CC="$TOOLCHAIN_BIN/mipsel-openwrt-linux-gcc"
TOOLCHAIN_CXX="$TOOLCHAIN_BIN/mipsel-openwrt-linux-g++"
TOOLCHAIN_LD="$TOOLCHAIN_BIN/mipsel-openwrt-linux-ld"

TOOLCHAIN_AR="$TOOLCHAIN_BIN/mipsel-openwrt-linux-ar"
TOOLCHAIN_RANLIB="$TOOLCHAIN_BIN/mipsel-openwrt-linux-ranlib"

# define the FLAGS
INCLUDE_LINES="-I $TOOLCHAIN_USR_INCLUDE -I $TOOLCHAIN_INCLUDE -I $TARGET_USR_INCLUDE -I $TARGET_INCLUDE -I $BUILD_DIR/includes"
TOOLCHAIN_CFLAGS="-Os -pipe -mno-branch-likely -mips32r2 -mtune=24kc -fno-caller-saves -fno-plt -fhonour-copts -Wno-error=unused-but-set-variable -Wno-error=unused-result -msoft-float -mips16 -minterlink-mips16 -Wformat -Werror=format-security -fstack-protector -D_FORTIFY_SOURCE=1 -D_GNU_SOURCE=1 -DPREFIX='\"\"' -Wl,-z,now -Wl,-z,relro"
PYTHON_CFLAGS="-DKORE_USE_PYTHON -I $TARGET_USR_INCLUDE/python3.6"
TOOLCHAIN_CFLAGS="$TOOLCHAIN_CFLAGS $INCLUDE_LINES $PYTHON_CFLAGS"

TOOLCHAIN_CXXFLAGS="$TOOLCHAIN_CFLAGS"
TOOLCHAIN_CXXFLAGS="$TOOLCHAIN_CXXFLAGS $INCLUDE_LINES"

KORE_LDFLAGS="-lcrypto -lssl"
PYTHON_LDFLAGS="-lpython3.6 -ldl -lpthread -lm -lz -Xlinker -export-dynamic"
TOOLCHAIN_LDFLAGS="-L$TOOLCHAIN_USR_LIB -L$TOOLCHAIN_LIB -L$TARGET_USR_LIB -L$TARGET_LIB $KORE_LDFLAGS $PYTHON_LDFLAGS"

echo "Cross compiling $BUILD_DIR:"
echo "  CC=$TOOLCHAIN_CC"
echo "  CXX=$TOOLCHAIN_CXX"
echo "  LD=$TOOLCHAIN_LD"
echo "  CFLAGS=$TOOLCHAIN_CFLAGS"
echo "  LDFLAGS=$TOOLCHAIN_LDFLAGS"

cd $BUILD_DIR
#make clean
make \
    CC="$TOOLCHAIN_CC" \
    CXX="$TOOLCHAIN_CXX" \
    LD="$TOOLCHAIN_LD" \
    CFLAGS="$TOOLCHAIN_CFLAGS" \
    LDFLAGS="$TOOLCHAIN_LDFLAGS" \
    PREFIX="$TARGET" \
    PYTHON=1 $@

