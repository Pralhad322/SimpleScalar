#!/usr/bin/env bash
set -euo pipefail

TARGET="sslittle-na-sstrix"
INSTALL_DEPS=0
FORCE=0
RUN_TEST=1
JOBS=1
HOST_CC=""

usage() {
  cat <<'USAGE'
Install the SimpleScalar PISA little-endian cross compiler locally.

Run from the simplesim-3.0 workspace:

  bash scripts/install_pisa_cross_compiler.sh

Optional:

  bash scripts/install_pisa_cross_compiler.sh --install-deps
  bash scripts/install_pisa_cross_compiler.sh --force
  bash scripts/install_pisa_cross_compiler.sh --skip-test

Options:
  --install-deps  Install Ubuntu/Debian build packages using apt-get.
  --force         Remove the local toolchain build/install directories first.
  --skip-test     Build/install only; do not compile and run hello.c.
  -j N            Pass N jobs to make. Default is 1 for old-toolchain safety.
  -h, --help      Show this help.
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --install-deps) INSTALL_DEPS=1 ;;
    --force) FORCE=1 ;;
    --skip-test) RUN_TEST=0 ;;
    -j)
      shift
      JOBS="${1:-1}"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ZIP="$ROOT/SimpleScalar/SimpleScalar.zip"
TOOLCHAIN_DIR="$ROOT/toolchain"
SRC_BASE="$TOOLCHAIN_DIR/src"
SRCROOT="$SRC_BASE/SimpleScalar/simplesim"
BUILDROOT="$TOOLCHAIN_DIR/build"
PREFIX="$TOOLCHAIN_DIR/$TARGET"
BINUTILS_SRC="$SRCROOT/binutils-2.5.2"
GCC_SRC="$SRCROOT/gcc-2.7.2.3"
RUNTIME_SRC="$SRCROOT/$TARGET"

log() {
  printf '\n==> %s\n' "$*"
}

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    return 1
  fi
}

install_deps() {
  log "Installing host build dependencies"
  if ! command -v apt-get >/dev/null 2>&1; then
    echo "This automatic dependency step supports apt-get systems only." >&2
    echo "Install these packages manually: build-essential gcc make flex bison unzip file perl gawk sed grep coreutils findutils" >&2
    exit 1
  fi

  SUDO=""
  if [ "$(id -u)" -ne 0 ]; then
    SUDO="sudo"
  fi

  $SUDO apt-get update
  $SUDO apt-get install -y \
    build-essential gcc make flex bison unzip file perl gawk \
    sed grep coreutils findutils
}

check_deps() {
  log "Checking host build tools"
  local missing=0
  for cmd in gcc make flex bison unzip file perl awk sed grep find chmod cp mkdir ln rm; do
    if ! need_cmd "$cmd"; then
      missing=1
    fi
  done

  if [ "$missing" -ne 0 ]; then
    echo "Install missing packages, or rerun with --install-deps on Ubuntu/Debian." >&2
    exit 1
  fi

  if [ -x /usr/bin/gcc ]; then
    HOST_CC=/usr/bin/gcc
  else
    HOST_CC="$(command -v gcc)"
  fi
  echo "Host C compiler: $HOST_CC"
}

extract_sources() {
  log "Extracting bundled SimpleScalar toolchain sources"
  if [ ! -f "$ZIP" ]; then
    echo "Cannot find $ZIP" >&2
    exit 1
  fi

  if [ "$FORCE" -eq 1 ]; then
    rm -rf "$PREFIX"
  fi

  rm -rf "$BUILDROOT/binutils-$TARGET" "$BINUTILS_SRC" "$GCC_SRC" "$RUNTIME_SRC"
  mkdir -p "$SRC_BASE" "$BUILDROOT" "$PREFIX"
  unzip -oq "$ZIP" \
    'SimpleScalar/simplesim/binutils-2.5.2/*' \
    'SimpleScalar/simplesim/gcc-2.7.2.3/*' \
    'SimpleScalar/simplesim/sslittle-na-sstrix/*' \
    -d "$SRC_BASE"

  chmod -R u+w "$BINUTILS_SRC" "$GCC_SRC" "$RUNTIME_SRC"
}

patch_binutils() {
  log "Patching binutils-2.5.2 for modern Linux hosts"

  perl -0pi -e 's|/\* Fall back on clock and hope it'\''s correctly implemented\. \*/\n#if CLOCKS_PER_SEC <= 1000000\n  return clock \(\) \* \(1000000 / CLOCKS_PER_SEC\);\n#else\n  return clock \(\) / CLOCKS_PER_SEC;\n#endif|/* Fall back on clock and hope it'\''s correctly implemented.\n     Modern libc headers may define CLOCKS_PER_SEC in a form that is not\n     usable in preprocessor arithmetic, so do the conversion at run time. */\n  return (long) ((double) clock () * (1000000.0 / (double) CLOCKS_PER_SEC));|s' \
    "$BINUTILS_SRC/libiberty/getruntime.c"

  if ! grep -q '#include <stdlib.h>' "$BINUTILS_SRC/libiberty/vasprintf.c"; then
    sed -i '/#include <string.h>/a #include <stdlib.h>' "$BINUTILS_SRC/libiberty/vasprintf.c"
  fi
  sed -i '/^char \*malloc ();$/d' "$BINUTILS_SRC/libiberty/vasprintf.c"
  perl -0pi -e 's/  va_list ap = args;/  va_list ap;\n\n#ifdef va_copy\n  va_copy (ap, args);\n#else\n  __va_copy (ap, args);\n#endif/s' \
    "$BINUTILS_SRC/libiberty/vasprintf.c"
  if ! grep -q 'va_end (ap);' "$BINUTILS_SRC/libiberty/vasprintf.c"; then
    perl -0pi -e 's/(\n#ifdef TEST\n  global_total_width = total_width;)/\n  va_end (ap);\1/s' \
      "$BINUTILS_SRC/libiberty/vasprintf.c"
  fi

  sed -i 's| /usr/include/sys/errno.h||g' "$BINUTILS_SRC/gas/Makefile.in"

  sed -i 's|#include <varargs.h>|#include <stdarg.h>|' "$BINUTILS_SRC/ld/ldmisc.c"
  sed -i 's|static void finfo ();|static void finfo PARAMS ((FILE *, char *, ...));|' "$BINUTILS_SRC/ld/ldmisc.c"
  perl -0pi -e 's/void info_msg\(va_alist\)\n     va_dcl\n\{\n  char \*fmt;\n  va_list arg;\n  va_start\(arg\);\n  fmt = va_arg\(arg, char \*\);/void\ninfo_msg (char *fmt, ...)\n{\n  va_list arg;\n  va_start(arg, fmt);/s' "$BINUTILS_SRC/ld/ldmisc.c"
  perl -0pi -e 's/void einfo\(va_alist\)\n     va_dcl\n\{\n  char \*fmt;\n  va_list arg;\n  va_start\(arg\);\n  fmt = va_arg\(arg, char \*\);/void\neinfo (char *fmt, ...)\n{\n  va_list arg;\n  va_start(arg, fmt);/s' "$BINUTILS_SRC/ld/ldmisc.c"
  perl -0pi -e 's/void minfo\(va_alist\)\n     va_dcl\n\{\n  char \*fmt;\n  va_list arg;\n  va_start\(arg\);\n  fmt = va_arg\(arg, char \*\);/void\nminfo (char *fmt, ...)\n{\n  va_list arg;\n  va_start(arg, fmt);/s' "$BINUTILS_SRC/ld/ldmisc.c"
  perl -0pi -e 's/static void\nfinfo \(va_alist\)\n     va_dcl\n\{\n  char \*fmt;\n  FILE \*file;\n  va_list arg;\n  va_start \(arg\);\n  file = va_arg \(arg, FILE \*\);\n  fmt = va_arg \(arg, char \*\);/static void\nfinfo (FILE *file, char *fmt, ...)\n{\n  va_list arg;\n  va_start (arg, fmt);/s' "$BINUTILS_SRC/ld/ldmisc.c"

  sed -i 's|extern void einfo ();|extern void einfo PARAMS ((char *, ...));|' "$BINUTILS_SRC/ld/ldmisc.h"
  sed -i 's|extern void minfo ();|extern void minfo PARAMS ((char *, ...));|' "$BINUTILS_SRC/ld/ldmisc.h"
  sed -i 's|extern void info_msg ();|extern void info_msg PARAMS ((char *, ...));|' "$BINUTILS_SRC/ld/ldmisc.h"
}

patch_gcc() {
  log "Patching gcc-2.7.2.3 for little-endian PISA and modern Linux hosts"

  perl -0pi -e 's/return \\"FIXME\\\\n\n/return \\"FIXME\\\\n\\\\\n/g' \
    "$GCC_SRC/config/ss/ss.md"

  if ! grep -q '#include <string.h>' "$GCC_SRC/gcc.c"; then
    sed -i '/#include <stdio.h>/a #include <string.h>' "$GCC_SRC/gcc.c"
  fi

  perl -0pi -e 's/\nextern int sys_nerr;\n#ifndef HAVE_STRERROR\n#if defined\(bsd4_4\)\nextern const char \*const sys_errlist\[\];\n#else\nextern char \*sys_errlist\[\];\n#endif\n#else\nextern char \*strerror\(\);\n#endif\n/\n/s' "$GCC_SRC/gcc.c"

  perl -0pi -e 's/char \*\nmy_strerror\(e\)\n     int e;\n\{\n\n#ifdef HAVE_STRERROR\n  return strerror\(e\);\n\n#else\n\n  static char buffer\[30\];\n  if \(!e\)\n    return "";\n\n  if \(e > 0 && e < sys_nerr\)\n    return sys_errlist\[e\];\n\n  sprintf \(buffer, "Unknown error %d", e\);\n  return buffer;\n#endif\n\}/char *\nmy_strerror(e)\n     int e;\n{\n  if (!e)\n    return "";\n\n  return strerror(e);\n}/s' "$GCC_SRC/gcc.c"

  perl -0pi -e 's/  if \(errno < sys_nerr\)\n    s = concat \("%s: ", my_strerror\( errno \)\);\n  else\n    s = "cannot open `%s\x27";/  s = concat ("%s: ", my_strerror( errno ));/g' "$GCC_SRC/gcc.c"
  perl -0pi -e 's/  if \(errno < sys_nerr\)\n    s = concat \("installation problem, cannot exec `%s\x27: ",\n\t\tmy_strerror \(errno\)\);\n  else\n    s = "installation problem, cannot exec `%s\x27";/  s = concat ("installation problem, cannot exec `%s\x27: ",\n\t      my_strerror (errno));/s' "$GCC_SRC/gcc.c"
}

install_runtime_headers() {
  log "Installing SimpleScalar little-endian runtime headers and libraries"
  mkdir -p "$PREFIX" "$PREFIX/$TARGET/include" "$PREFIX/$TARGET/lib"
  cp -a "$RUNTIME_SRC/." "$PREFIX/"
  cp -a "$RUNTIME_SRC/include/." "$PREFIX/$TARGET/include/"
  cp -a "$RUNTIME_SRC/lib/crt0.o" "$RUNTIME_SRC/lib/libc.a" "$PREFIX/$TARGET/lib/"

  if [ -f "$GCC_SRC/patched/sys/cdefs.h" ]; then
    cp "$GCC_SRC/patched/sys/cdefs.h" "$PREFIX/include/sys/cdefs.h"
    cp "$GCC_SRC/patched/sys/cdefs.h" "$PREFIX/$TARGET/include/sys/cdefs.h"
  fi
}

build_binutils() {
  log "Building SimpleScalar binutils for $TARGET"
  mkdir -p "$BUILDROOT/binutils-$TARGET"
  cd "$BUILDROOT/binutils-$TARGET"
  CC="$HOST_CC" "$BINUTILS_SRC/configure" \
    --host=i386-unknown-linux \
    --target="$TARGET" \
    --prefix="$PREFIX"
  make -j "$JOBS" CC="$HOST_CC"
  make install CC="$HOST_CC"
}

build_gcc() {
  log "Building SimpleScalar GCC 2.7.2.3 for $TARGET"
  cd "$GCC_SRC"
  CC="$HOST_CC" PATH="$PREFIX/bin:$PATH" ./configure \
    --host=i386-unknown-linux \
    --target="$TARGET" \
    --with-gnu-as \
    --with-gnu-ld \
    --prefix="$PREFIX"
  PATH="$PREFIX/bin:$PATH" make -j "$JOBS" LANGUAGES=c CFLAGS="-O2 -fcommon" CC="$HOST_CC"
  PATH="$PREFIX/bin:$PATH" make install LANGUAGES=c CFLAGS="-O2 -fcommon" CC="$HOST_CC"

  cat > "$PREFIX/bin/gcc" <<'EOF'
#!/bin/sh
exec "$(dirname "$0")/sslittle-na-sstrix-gcc" "$@"
EOF
  chmod +x "$PREFIX/bin/gcc"
}

smoke_test() {
  log "Running compiler and simulator smoke test"
  mkdir -p "$ROOT/labs"
  cat > "$ROOT/labs/hello_toolchain_test.c" <<'EOF'
#include <stdio.h>

int
main(void)
{
  int i;
  int sum = 0;

  for (i = 1; i <= 10; i++)
    sum += i * i;

  printf("Hello from SimpleScalar PISA little-endian\n");
  printf("sum_of_squares_1_to_10 = %d\n", sum);
  return 0;
}
EOF

  "$PREFIX/bin/gcc" -O2 -static -o "$ROOT/labs/hello_toolchain_test.pisa" "$ROOT/labs/hello_toolchain_test.c"
  file "$ROOT/labs/hello_toolchain_test.pisa"

  if [ -x "$ROOT/sim-safe" ]; then
    "$ROOT/sim-safe" "$ROOT/labs/hello_toolchain_test.pisa"
  else
    echo "sim-safe not found; skipping simulator smoke run."
  fi

  if [ -x "$ROOT/sim-singlecycle" ]; then
    "$ROOT/sim-singlecycle" -redir:sim "$ROOT/labs/hello_toolchain_singlecycle.out" "$ROOT/labs/hello_toolchain_test.pisa"
    grep -E "sim_num_insn|sim_cycle|sim_IPC|sim_CPI" "$ROOT/labs/hello_toolchain_singlecycle.out"
  fi
}

main() {
  log "SimpleScalar PISA little-endian cross compiler installer"
  echo "Workspace: $ROOT"
  echo "Install prefix: $PREFIX"

  if [ "$INSTALL_DEPS" -eq 1 ]; then
    install_deps
  fi

  check_deps
  extract_sources
  patch_binutils
  patch_gcc
  install_runtime_headers
  build_binutils
  install_runtime_headers
  build_gcc

  if [ "$RUN_TEST" -eq 1 ]; then
    smoke_test
  fi

  log "Done"
  echo "Compiler: $PREFIX/bin/gcc"
  echo "Example:  $PREFIX/bin/gcc -O2 -static -o labs/hello.pisa labs/hello.c"
}

main "$@"
