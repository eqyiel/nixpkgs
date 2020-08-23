```
-- Build files have been written to: /tmp/nix-build-swift-5.1.1.drv-0/build/buildbot_osx/llvm-macosx-x86_64/tools/clang/runtime/compiler-rt-bins
[3400/3403][ 99%][3331.794s] cd /tmp/nix-build-swift-5.1.1.drv-0/build/buildbot_osx/llvm-macosx-x86_64/tools/clang/runtime/compiler-rt-bins && /nix/store/a9i8cqd3kcl7pijv27q0zmch2zsfhv6h-cmake-3.17.2/bin/cmake --build . --target clean --config RelWithDebInfo && /nix/store/a9i8cqd3kcl7pijv27q0zmch2zsfhv6h-cmake-3.17.2/bin/cmake -E touch /tmp/nix-build-swift-5.1.1.drv-0/build/buildbot_osx/llvm-macosx-x86_64/tools/clang/runtime/compiler-rt-stamps//compiler-rt-clean
[1/1][100%][0.039s] Cleaning all built files...
Cleaning... 0 files.
[3400/3403][ 99%][3331.794s] cd /tmp/nix-build-swift-5.1.1.drv-0/build/buildbot_osx/llvm-macosx-x86_64/tools/clang/runtime/compiler-rt-bins && /nix/store/a9i8cqd3kcl7pijv27q0zmch2zsfhv6h-cmake-3.17.2/bin/cmake --build . && /nix/store/a9i8cqd3kcl7pijv27q0zmch2zsfhv6h-cmake-3.17.2/bin/cmake -E touch /tmp/nix-build-swift-5.1.1.drv-0/build/buildbot_osx/llvm-macosx-x86_64/tools/clang/runtime/compiler-rt-stamps//compiler-rt-build
[761/962][ 79%][9.951s] Building CXX object lib/lsan/CMakeFiles/clang_rt.lsan_osx_dynamic.dir/lsan_malloc_mac.cc.o6_64/lib/clang/7.0.0/lib/darwin/libclang_rt.stats_client_osx.a
FAILED: lib/lsan/CMakeFiles/clang_rt.lsan_osx_dynamic.dir/lsan_malloc_mac.cc.o
/tmp/nix-build-swift-5.1.1.drv-0/build/buildbot_osx/llvm-macosx-x86_64/./bin/clang++  -Dclang_rt_lsan_osx_dynamic_EXPORTS -I/tmp/nix-build-swift-5.1.1.drv-0/src/llvm/projects/compiler-rt/lib/lsan/.. -Wall -std=c++11 -Wno-unused-parameter -O2 -g -DNDEBUG -arch x86_64 -arch x86_64h -isysroot /nix/store/aq5pbm91xnmnhs9zvc2rzg2g767axphj-SDKs/MacOSX10.12.sdk -fPIC    -stdlib=libc++ -mmacosx-version-min=10.9 -isysroot /nix/store/aq5pbm91xnmnhs9zvc2rzg2g767axphj-SDKs/MacOSX10.12.sdk -fno-lto -fPIC -fno-builtin -fno-exceptions -funwind-tables -fno-stack-protector -fno-sanitize=safe-stack -fvisibility=hidden -fno-lto -O3 -gline-tables-only -Wno-gnu -Wno-variadic-macros -Wno-c99-extensions -Wno-non-virtual-dtor -fno-rtti -MD -MT lib/lsan/CMakeFiles/clang_rt.lsan_osx_dynamic.dir/lsan_malloc_mac.cc.o -MF lib/lsan/CMakeFiles/clang_rt.lsan_osx_dynamic.dir/lsan_malloc_mac.cc.o.d -o lib/lsan/CMakeFiles/clang_rt.lsan_osx_dynamic.dir/lsan_malloc_mac.cc.o -c /tmp/nix-build-swift-5.1.1.drv-0/src/llvm/projects/compiler-rt/lib/lsan/lsan_malloc_mac.cc
In file included from /tmp/nix-build-swift-5.1.1.drv-0/src/llvm/projects/compiler-rt/lib/lsan/lsan_malloc_mac.cc:56:
/tmp/nix-build-swift-5.1.1.drv-0/src/llvm/projects/compiler-rt/lib/lsan/../sanitizer_common/sanitizer_malloc_mac.inc:21:10: fatal error: 'CoreFoundation/CFBase.h' file not found
#include <CoreFoundation/CFBase.h>
         ^~~~~~~~~~~~~~~~~~~~~~~~~
1 error generated.
[770/962][ 80%][10.749s] Building CXX object lib/lsan/CMakeFiles/clang_rt.lsan_osx_dynamic.dir/lsan_allocator.cc.o
ninja: build stopped: subcommand failed.
FAILED: tools/clang/runtime/compiler-rt-stamps/compiler-rt-build
cd /tmp/nix-build-swift-5.1.1.drv-0/build/buildbot_osx/llvm-macosx-x86_64/tools/clang/runtime/compiler-rt-bins && /nix/store/a9i8cqd3kcl7pijv27q0zmch2zsfhv6h-cmake-3.17.2/bin/cmake --build . && /nix/store/a9i8cqd3kcl7pijv27q0zmch2zsfhv6h-cmake-3.17.2/bin/cmake -E touch /tmp/nix-build-swift-5.1.1.drv-0/build/buildbot_osx/llvm-macosx-x86_64/tools/clang/runtime/compiler-rt-stamps//compiler-rt-build
ninja: build stopped: subcommand failed.
/private/tmp/nix-build-swift-5.1.1.drv-0/src/swift/utils/build-script: fatal error: command terminated with a non-zero exit status 1, aborting
/private/tmp/nix-build-swift-5.1.1.drv-0/src/swift/utils/build-script: fatal error: command terminated with a non-zero exit status 1, aborting
note: keeping build directory '/private/tmp/nix-build-swift-5.1.1.drv-0'
builder for '/nix/store/4n23lv8mba57f3ksx8f95qcwf9s0wya6-swift-5.1.1.drv' failed with exit code 1
error: build of '/nix/store/4n23lv8mba57f3ksx8f95qcwf9s0wya6-swift-5.1.1.drv' failed
```

# TODO
- [ ] see `COMPILER_RT_HAS_TSAN` in `pkgs/development/compilers/llvm/6/compiler-rt.nix`
