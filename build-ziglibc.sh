#!/bin/sh
set -eu

# tool used to download. url as argument, output to stdout.
DOWNLOAD_BIN=${DOWNLOAD_BIN:-ftp -Vo-}
#DOWNLOAD_BIN=${DOWNLOAD_BIN:-curl -s}

if [ $# -ne 2 ]; then
    cat >&2 <<EOF
usage: ${0} url output-dir

  examples:
    - ${0} https://cdn.openbsd.org/pub/OpenBSD/6.9/amd64/ \${PWD}/6.9/amd64
    - ${0} https://cdn.openbsd.org/pub/OpenBSD/snapshots/i386/ \${PWD}/snapshots/i386

EOF
    exit 1
fi

url="${1}"
target_directory="${2}"

if [ -r "${target_directory}/libc.conf" ] ; then
    echo "warn: ${target_directory}/libc.conf already exists" >&2
    exit 0
fi

echo "- Getting OpenBSD version" >&2
target_version=`${DOWNLOAD_BIN} "${url}/SHA256" \
    | sed -ne 's,.*(base\([0-9]\)\([0-9]\)\.tgz).*,\1\2,p'`

echo "- Downloading and extracting libc environment" >&2
mkdir -p "${target_directory}"
cat >"${target_directory}/CACHEDIR.TAG" <<EOF
Signature: 8a477f597d28d172789f06886806bc55
# This file is a cache directory tag created by ${0}.
# For information about cache directory tags see https://bford.info/cachedir/
EOF

${DOWNLOAD_BIN} "${url}/base${target_version}.tgz" \
    | tar zxf - -C "${target_directory}" ./usr/include ./usr/lib
${DOWNLOAD_BIN} "${url}/comp${target_version}.tgz" \
    | tar zxf - -C "${target_directory}" ./usr/include ./usr/lib

echo "- Creating linux-like library links" >&2
for lib in "${target_directory}"/usr/lib/lib*.so.*.* ; do
    ln -fs -- "${lib}" "${lib%.*.*}"
done

echo "- Creating ZIG_LIBC file" >&2
cat >"${target_directory}/libc.conf" <<EOF
# The directory that contains \`stdlib.h\`.
# On POSIX-like systems, include directories be found with: \`cc -E -Wp,-v -xc /dev/null\`
include_dir=${target_directory}/usr/include

# The system-specific include directory. May be the same as \`include_dir\`.
# On Windows it's the directory that includes \`vcruntime.h\`.
# On POSIX it's the directory that includes \`sys/errno.h\`.
sys_include_dir=${target_directory}/usr/include

# The directory that contains \`crt1.o\` or \`crt2.o\`.
# On POSIX, can be found with \`cc -print-file-name=crt1.o\`.
# Not needed when targeting MacOS.
crt_dir=${target_directory}/usr/lib

# The directory that contains \`vcruntime.lib\`.
# Only needed when targeting MSVC on Windows.
msvc_lib_dir=

# The directory that contains \`kernel32.lib\`.
# Only needed when targeting MSVC on Windows.
kernel32_lib_dir=

# The directory that contains \`crtbeginS.o\` and \`crtendS.o\`
# Only needed when targeting Haiku.
gcc_dir=
EOF

echo "ZIG_LIBC=${target_directory}/libc.conf"
