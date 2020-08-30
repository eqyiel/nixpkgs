{ clangStdenv
, cmake
, coreutils
, gccForLibs
, which
, perl
, libedit
, ninja
, pkgconfig
, sqlite
, swig
, bash
, libxml2
, python
, ncurses
, libuuid
, libossp_uuid
, libbsd
, icu
, autoconf
, libtool
, automake
, libblocksruntime
, curl
, rsync
, git
, libgit2
, fetchFromGitHub
, fetchpatch
, findutils
, makeWrapper
, gnumake
, file
, darwin
, writeScriptBin
, xcbuild
}:
let
  version = "5.1.1";

  stdenv = clangStdenv;

  _libuuid = if stdenv.hostPlatform.isDarwin then libossp_uuid else libuuid;

  sysctl = writeScriptBin "sysctl" ''
    #!${stdenv.shell}

    # Hack to reduce impurities
    echo "hw.memsize: 17179869184"
  '';

  fetch = { repo, sha256, fetchSubmodules ? false }:
    fetchFromGitHub {
      owner = "apple";
      inherit repo sha256 fetchSubmodules;
      rev = "swift-${version}-RELEASE";
      name = "${repo}-${version}-src";
    };

  sources = {
    llvm = fetch {
      repo = "swift-llvm";
      sha256 = "00ldd9dby6fl6nk3z17148fvb7g9x4jkn1afx26y51v8rwgm1i7f";
    };
    compilerrt = fetch {
      repo = "swift-compiler-rt";
      sha256 = "1431f74l0n2dxn728qp65nc6hivx88fax1wzfrnrv19y77br05wj";
    };
    clang = fetch {
      repo = "swift-clang";
      sha256 = "0n7k6nvzgqp6h6bfqcmna484w90db3zv4sh5rdh89wxyhdz6rk4v";
    };
    clangtools = fetch {
      repo = "swift-clang-tools-extra";
      sha256 = "0snp2rpd60z239pr7fxpkj332rkdjhg63adqvqdkjsbrxcqqcgqa";
    };
    indexstore = fetch {
      repo = "indexstore-db";
      sha256 = "1gwkqkdmpd5hn7555dpdkys0z50yh00hjry2886h6rx7avh5p05n";
    };
    sourcekit = fetch {
      repo = "sourcekit-lsp";
      sha256 = "0k84ssr1k7grbvpk81rr21ii8csnixn9dp0cga98h6i1gshn8ml4";
    };
    cmark = fetch {
      repo = "swift-cmark";
      sha256 = "079smm79hbwr06bvghd2sb86b8gpkprnzlyj9kh95jy38xhlhdnj";
    };
    lldb = fetch {
      repo = "swift-lldb";
      sha256 = "0j787475f0nlmvxqblkhn3yrvn9qhcb2jcijwijxwq95ar2jdygs";
    };
    llbuild = fetch {
      repo = "swift-llbuild";
      sha256 = "1n2s5isxyl6b6ya617gdzjbw68shbvd52vsfqc1256rk4g448v8b";
    };
    pm = fetch {
      repo = "swift-package-manager";
      sha256 = "1a49jmag5mpld9zr96g8a773334mrz1c4nyw38gf4p6sckf4jp29";
    };
    xctest = fetch {
      repo = "swift-corelibs-xctest";
      sha256 = "0rxy9sq7i0s0kxfkz0hvdp8zyb40h31f7g4m0kry36qk82gzzh89";
    };
    foundation = fetch {
      repo = "swift-corelibs-foundation";
      sha256 = "1iiiijsnys0r3hjcj1jlkn3yszzi7hwb2041cnm5z306nl9sybzp";
    };
    libcxx = fetch {
      repo = "swift-libcxx";
      sha256 = "01q6m13cqa7d74l2sbci90rwk34ysjn81zb9ikfq8qnhh85rd6vv";
    };
    libdispatch = fetch {
      repo = "swift-corelibs-libdispatch";
      sha256 = "0laqsizsikyjhrzn0rghvxd8afg4yav7cbghvnf7ywk9wc6kpkmn";
      fetchSubmodules = true;
    };
    syntax = fetch {
      repo = "swift-syntax";
      sha256 = "1cb3k43p17nxmm03yhf2kjrmb2bmmzsdfiibx0qh5rinns3x1454";
    };
    xcode-playground-support = fetch {
      repo = "swift-xcode-playground-support";
      sha256 = "1bbi6w3gvc3n07nghmz1spbm3p2clsg7fgaia7i7az75l88i2kka";
    };
    stress-tester = fetch {
      repo = "swift-stress-tester";
      sha256 = "15hlc0yha9rda6v2bmhwjy1azf52mhmnmxpvnzpkiz7pfkpa4jik";
    };
    swift = fetch {
      repo = "swift";
      sha256 = "0m4r1gzrnn0s1c7haqq9dlmvpqxbgbkbdfmq6qaph869wcmvdkvy";
    };
  };

  devInputs = [
    curl
    icu
    libblocksruntime
    libbsd
    libedit
    _libuuid
    libxml2
    ncurses
    sqlite
    swig
  ] ++ stdenv.lib.optionals stdenv.isDarwin [
    darwin.PowerManagement # for the "caffeinate" utility used by the build script
    darwin.apple_sdk.frameworks.CoreFoundation
    sysctl
    xcbuild
  ];

  cmakeFlags = [
    "-DGLIBC_INCLUDE_PATH=${stdenv.cc.libc.dev}/include"
    "-DC_INCLUDE_DIRS=${stdenv.lib.makeSearchPathOutput "dev" "include" devInputs}:${libxml2.dev}/include/libxml2"
    "-DGCC_INSTALL_PREFIX=${gccForLibs}"
  ];

  preset = if stdenv.hostPlatform.isDarwin then "buildbot_osx_package,no_assertions,no_test" else "buildbot_linux";
in
stdenv.mkDerivation {
  name = "swift-${version}";

  nativeBuildInputs = [
    autoconf
    automake
    bash
    cmake
    coreutils
    findutils
    gnumake
    makeWrapper
    ninja
    perl
    pkgconfig
    python
    rsync
    which
  ] ++ stdenv.lib.optionals stdenv.isLinux [
    libtool # darwin needs to use the libtool from pkgs/development/tools/xcbuild/toolchains.nix
  ];
  buildInputs = devInputs;
  #  ++ [
  #   not needed if using clangStdenv
  #   clang
  # ];

  # TODO: Revisit what's propagated and how
  propagatedBuildInputs = [
    libgit2
    python
  ];
  propagatedUserEnvPkgs = [ git pkgconfig ];

  hardeningDisable = [ "format" ]; # for LLDB

  # TODO: it should be possible to build all of these individually and cache the
  # results using nix
  unpackPhase = ''
    mkdir src
    cd src
    export SWIFT_SOURCE_ROOT=$PWD

    cp -r ${sources.llvm} llvm
    cp -r ${sources.compilerrt} compiler-rt
    cp -r ${sources.clang} clang
    cp -r ${sources.clangtools} clang-tools-extra
    cp -r ${sources.indexstore} indexstore-db
    cp -r ${sources.sourcekit} sourcekit-lsp
    cp -r ${sources.cmark} cmark
    cp -r ${sources.lldb} lldb
    cp -r ${sources.llbuild} llbuild
    cp -r ${sources.pm} swiftpm
    cp -r ${sources.xctest} swift-corelibs-xctest
    cp -r ${sources.foundation} swift-corelibs-foundation
    cp -r ${sources.libcxx} libcxx
    cp -r ${sources.syntax} swift-syntax
    cp -r ${sources.stress-tester} swift-stress-tester
    cp -r ${sources.xcode-playground-support} swift-xcode-playground-support
    cp -r ${sources.libdispatch} swift-corelibs-libdispatch
    cp -r ${sources.swift} swift

    chmod -R u+w .
  '';

  patchPhase = ''
        # Glibc 2.31 fix
        patch -p1 -i ${./patches/swift-llvm.patch}

        # Just patch all the things for now, we can focus this later
        patchShebangs $SWIFT_SOURCE_ROOT

        # TODO eliminate use of env.
        find -type f -print0 | xargs -0 sed -i \
          -e 's|/usr/bin/env|${coreutils}/bin/env|g' \
          -e 's|/usr/bin/make|${gnumake}/bin/make|g' \
          -e 's|/bin/mkdir|${coreutils}/bin/mkdir|g' \
          -e 's|/bin/cp|${coreutils}/bin/cp|g' \
          -e 's|/usr/bin/file|${file}/bin/file|g'

        substituteInPlace swift/stdlib/public/Platform/CMakeLists.txt \
          --replace '/usr/include' "${stdenv.cc.libc}/include"
        substituteInPlace swift/utils/build-script-impl \
    <<<<<<< HEAD
          --replace '/usr/include/c++' "${gccForLibs}/include/c++"
    ||||||| parent of dc17c4b11de... fixup! package swift for darwin
          --replace '/usr/include/c++' "${clang.cc.gcc}/include/c++"
    =======
          --replace '/usr/include/c++' "${stdenv.cc}/include/c++"
    >>>>>>> dc17c4b11de... fixup! package swift for darwin
        patch -p1 -d swift -i ${./patches/glibc-arch-headers.patch}
        patch -p1 -d swift -i ${./patches/0001-build-presets-linux-don-t-require-using-Ninja.patch}
        patch -p1 -d swift -i ${./patches/0002-build-presets-linux-allow-custom-install-prefix.patch}
        patch -p1 -d swift -i ${./patches/0003-build-presets-linux-don-t-build-extra-libs.patch}
        patch -p1 -d swift -i ${./patches/0004-build-presets-linux-plumb-extra-cmake-options.patch}

        sed -i swift/utils/build-presets.ini \
          -e 's/^test-installable-package$/# \0/' \
          -e 's/^test$/# \0/' \
          -e 's/^validation-test$/# \0/' \
          -e 's/^long-test$/# \0/' \
          -e 's/^stress-test$/# \0/' \
          -e 's/^test-optimized$/# \0/' \
          \
          -e 's/^swift-install-components=autolink.*$/\0;editor-integration/'

        substituteInPlace clang/lib/Driver/ToolChains/Linux.cpp \
          --replace 'SysRoot + "/lib' '"${stdenv.libc}/lib" "'
        substituteInPlace clang/lib/Driver/ToolChains/Linux.cpp \
          --replace 'SysRoot + "/usr/lib' '"${stdenv.libc}/lib" "'
        patch -p1 -d clang -i ${./patches/llvm-toolchain-dir.patch}
        patch -p1 -d clang -i ${./purity.patch}

        # Workaround hardcoded dep on "libcurses" (vs "libncurses"):
        sed -i 's/curses/ncurses/' llbuild/*/*/CMakeLists.txt
        # uuid.h is not part of glibc, but of libuuid
        sed -i 's|''${GLIBC_INCLUDE_PATH}/uuid/uuid.h|${_libuuid}/include/uuid/uuid.h|' swift/stdlib/public/Platform/glibc.modulemap.gyb

        # Compatibility with glibc 2.30
        # Adapted from https://github.com/apple/swift-package-manager/pull/2408
        patch -p1 -d swiftpm -i ${./patches/swift-package-manager-glibc-2.30.patch}
        # https://github.com/apple/swift/pull/27288
        patch -p1 -d swift -i ${fetchpatch {
          url = "https://github.com/apple/swift/commit/f968f4282d53f487b29cf456415df46f9adf8748.patch";
          sha256 = "1aa7l66wlgip63i4r0zvi9072392bnj03s4cn12p706hbpq0k37c";
        }}

        PREFIX=''${out/#\/}
        substituteInPlace indexstore-db/Utilities/build-script-helper.py \
          --replace usr "$PREFIX"
        substituteInPlace sourcekit-lsp/Utilities/build-script-helper.py \
          --replace usr "$PREFIX"
        substituteInPlace swift-corelibs-xctest/build_script.py \
          --replace usr "$PREFIX"
        substituteInPlace swift-corelibs-foundation/CoreFoundation/PlugIn.subproj/CFBundle_InfoPlist.c \
          --replace "if !TARGET_OS_ANDROID" "if TARGET_OS_MAC || TARGET_OS_BSD"
        substituteInPlace swift-corelibs-foundation/CoreFoundation/PlugIn.subproj/CFBundle_Resources.c \
          --replace "if !TARGET_OS_ANDROID" "if TARGET_OS_MAC || TARGET_OS_BSD"

        patch -p1 -d swift -i ${./patches/debug.patch}

        patch -p1 -d compiler-rt -i ${./patches/compiler-rt.patch}
        patch -p1 -d clang -i ${./patches/swift-clang.patch}
  '';

  configurePhase = ''
    cd ..
    mkdir build install symroot
    export SWIFT_BUILD_ROOT=$PWD/build
    export SWIFT_INSTALL_DIR=$PWD/install
    export SWIFT_INSTALL_SYMROOT=$PWD/symroot
    export INSTALLABLE_PACKAGE=$PWD/swift.tar.gz
    export SYMBOLS_PACKAGE=$PWD/symbols.tar.gz
    cd $SWIFT_BUILD_ROOT
  '';

  buildPhase = ''
    # explicitly include C++ headers to prevent errors where stdlib.h is not found from cstdlib
    export NIX_CFLAGS_COMPILE="$(< ${clang}/nix-support/libcxx-cxxflags) $NIX_CFLAGS_COMPILE"
    # During the Swift build, a full local LLVM build is performed and the resulting clang is invoked.
    # This compiler is not using the Nix wrappers, so it needs some help to find things.
    export NIX_LDFLAGS_BEFORE="-rpath ${gccForLibs.lib}/lib -L${gccForLibs.lib}/lib $NIX_LDFLAGS_BEFORE"
    # However, we want to use the wrapped compiler whenever possible.
    export CC="${clang}/bin/clang"

    # fix for https://bugs.llvm.org/show_bug.cgi?id=39743
    # see also https://forums.swift.org/t/18138/15
    export CCC_OVERRIDE_OPTIONS="#x-fmodules s/-fmodules-cache-path.*//"
    $SWIFT_SOURCE_ROOT/swift/utils/build-script \
      --preset=${preset} \
      extra_cmake_options="${stdenv.lib.concatStringsSep "," cmakeFlags}" \
      install_destdir="$SWIFT_INSTALL_DIR" \
      install_prefix="$out" \
      installable_package="$INSTALLABLE_PACKAGE"
  '' else ''
    $SWIFT_SOURCE_ROOT/swift/utils/build-script \
      --preset="${preset}" \
      darwin_toolchain_alias="Local" \
      darwin_toolchain_bundle_identifier="swift-${version}" \
      darwin_toolchain_display_name="swift-${version}" \
      darwin_toolchain_display_name_short="swift-${version}" \
      darwin_toolchain_version="${version}" \
      darwin_toolchain_xctoolchain_name="Local" \
      extra_cmake_options="${stdenv.lib.concatStringsSep "," cmakeFlags}" \
      install_destdir="$SWIFT_INSTALL_DIR" \
      install_prefix="$out" \
      install_symroot="$SWIFT_INSTALL_SYMROOT" \
      installable_package="$INSTALLABLE_PACKAGE" \
      symbols_package="$SYMBOLS_PACKAGE"
  '';

  doCheck = true;

  checkInputs = [ file ];

  checkPhase = ''
    # FIXME: disable non-working tests
    rm $SWIFT_SOURCE_ROOT/swift/test/Driver/static-stdlib-linux.swift  # static linkage of libatomic.a complains about missing PIC
    rm $SWIFT_SOURCE_ROOT/swift/validation-test/Python/build_swift.swift  # install_prefix not passed properly

    # match the swift wrapper in the install phase
    export LIBRARY_PATH=${icu}/lib:${_libuuid}/lib

    checkTarget=check-swift-all
    ninjaFlags='-C ${preset}/swift-${stdenv.hostPlatform.parsed.kernel.name}-${stdenv.hostPlatform.parsed.cpu.name}'
    ninjaCheckPhase
  '';

  installPhase = ''
    mkdir -p $out

    # Extract the generated tarball into the store
    tar xf $INSTALLABLE_PACKAGE -C $out --strip-components=3 ''${out/#\/}
    find $out -type d -empty -delete

    # fix installation weirdness, also present in Apple’s official tarballs
    mv $out/local/include/indexstore $out/include
    rmdir $out/local/include $out/local
    rm -r $out/bin/sdk-module-lists $out/bin/swift-api-checker.py

    wrapProgram $out/bin/swift \
      --suffix C_INCLUDE_PATH : $out/lib/swift/clang/include \
      --suffix CPLUS_INCLUDE_PATH : $out/lib/swift/clang/include \
      --suffix LIBRARY_PATH : ${icu}/lib:${_libuuid}/lib
  '';

  # Hack to avoid build and install directories in RPATHs.
  preFixup = ''rm -rf $SWIFT_BUILD_ROOT $SWIFT_INSTALL_DIR'';

  meta = with stdenv.lib; {
    description = "The Swift Programming Language";
    homepage = "https://github.com/apple/swift";
    maintainers = with maintainers; [ dtzWill ];
    license = licenses.asl20;
    # Swift doesn't support 32bit Linux, unknown on other platforms.
    platforms = platforms.unix;
    badPlatforms = platforms.i686;
    broken = stdenv.isAarch64; # 2018-09-04, never built on Hydra
  };
}
