#!/bin/bash

# SET BUILD OPTIONS
ASM_OPTIONS=""
case ${ARCH} in
*-mac-catalyst)
  ASM_OPTIONS="--disable-video-cocoa --disable-render-metal --disable-diskaudio"
  ;;
arm64 | armv7 | armv7s | arm64e | i386 | x86-64 | arm64-simulator)
  # For iOS (non-catalyst), disable macOS-specific frameworks
  ASM_OPTIONS="--disable-video-cocoa --disable-render-metal"
  ;;
esac

# ALWAYS CLEAN THE PREVIOUS BUILD
make distclean 2>/dev/null 1>/dev/null

# WORKAROUND TO FIX AUTOMATICALLY ENABLED LIBRARIES IN CONFIGURE
overwrite_file "${BASEDIR}/tools/patch/make/sdl/configure.in" "${BASEDIR}/src/${LIB_NAME}/configure.in"

# ALWAYS REGENERATE BUILD FILES - NECESSARY TO APPLY THE WORKAROUNDS
./autogen.sh || return 1

# WORKAROUND TO EXCLUDE libunwind.h ON LTS BUILDS
if [[ -n ${FFMPEG_KIT_LTS_BUILD} ]]; then
  export ac_cv_header_libunwind_h=no
fi

# UPDATE CONFIG FILES TO SUPPORT APPLE ARCHITECTURES
overwrite_file "${FFMPEG_KIT_TMPDIR}"/source/config/config.guess "${BASEDIR}"/src/"${LIB_NAME}"/build-scripts/config.guess || return 1
overwrite_file "${FFMPEG_KIT_TMPDIR}"/source/config/config.sub "${BASEDIR}"/src/"${LIB_NAME}"/build-scripts/config.sub || return 1

./configure \
  --prefix="${LIB_INSTALL_PREFIX}" \
  --with-pic \
  --with-sysroot="${SDK_PATH}" \
  --enable-static \
  --disable-shared \
  --disable-video-opengl \
  --disable-video-x11 \
  --disable-joystick \
  --disable-haptic \
  --disable-power \
  ${ASM_OPTIONS} \
  --host="${HOST}" || return 1

make -j$(get_cpu_count) || return 1

make install || return 1

# MANUALLY COPY PKG-CONFIG FILES
cp ./*.pc "${INSTALL_PKG_CONFIG_DIR}" || return 1

# PATCH sdl2.pc to remove macOS-only frameworks for iOS builds  
if [[ "${FFMPEG_KIT_BUILD_TYPE}" == "ios" ]] || [[ "${FFMPEG_KIT_BUILD_TYPE}" == "tvos" ]]; then
  ${SED_INLINE} 's/-Wl,-framework,Cocoa//g' "${INSTALL_PKG_CONFIG_DIR}/sdl2.pc" || return 1
  ${SED_INLINE} 's/-Wl,-framework,Carbon//g' "${INSTALL_PKG_CONFIG_DIR}/sdl2.pc" || return 1
  ${SED_INLINE} 's/-Wl,-framework,IOKit//g' "${INSTALL_PKG_CONFIG_DIR}/sdl2.pc" || return 1
  # Add iOS-specific frameworks required by SDL
  ${SED_INLINE} 's/\(Libs.private:.*\)/\1 -Wl,-framework,AVFoundation -Wl,-framework,UIKit/g' "${INSTALL_PKG_CONFIG_DIR}/sdl2.pc" || return 1
  # Clean up any resulting double spaces
  ${SED_INLINE} 's/  */ /g' "${INSTALL_PKG_CONFIG_DIR}/sdl2.pc" || return 1
fi
