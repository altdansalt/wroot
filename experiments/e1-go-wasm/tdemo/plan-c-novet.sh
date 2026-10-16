mkdir -p $WORK/b001/
mkdir -p $WORK/b006/

#
# internal/goarch
#

echo '# import config' > $WORK/b006/importcfg # internal
cd /home/exedev/e1/tdemo
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b006/_pkg_.a -trimpath "$WORK/b006=>" -p internal/goarch -lang=go1.27 -std -complete -buildid oBKgFnFEWGdF8IuuBuoY/oBKgFnFEWGdF8IuuBuoY -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b006/importcfg -pack /home/exedev/e1/goroot/src/internal/goarch/goarch.go /home/exedev/e1/goroot/src/internal/goarch/goarch_wasm.go /home/exedev/e1/goroot/src/internal/goarch/zgoarch_wasm.go
go tool buildid -w $WORK/b006/_pkg_.a # internal
mkdir -p $WORK/b005/

#
# internal/abi
#

echo -n > $WORK/b005/go_asm.h # internal
cd /home/exedev/e1/goroot/src/internal/abi
/home/exedev/e1/goroot/pkg/tool/linux_amd64/asm -p internal/abi -trimpath "$WORK/b005=>" -I $WORK/b005/ -I /home/exedev/e1/goroot/pkg/include -D GOOS_wasip1 -D GOARCH_wasm -std -gensymabis -o $WORK/b005/symabis ./abi_test.s ./stub.s
cat >$WORK/b005/importcfg << 'EOF' # internal
# import config
packagefile internal/goarch=$WORK/b006/_pkg_.a
EOF
cd /home/exedev/e1/tdemo
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b005/_pkg_.a -trimpath "$WORK/b005=>" -p internal/abi -lang=go1.27 -std -buildid QJphr4WA11lvIqEfTCy2/QJphr4WA11lvIqEfTCy2 -dwarf=false -goversion go1.27.2 -symabis $WORK/b005/symabis -c=2 -nolocalimports -importcfg $WORK/b005/importcfg -pack -asmhdr $WORK/b005/go_asm.h /home/exedev/e1/goroot/src/internal/abi/abi.go /home/exedev/e1/goroot/src/internal/abi/abi_generic.go /home/exedev/e1/goroot/src/internal/abi/bounds.go /home/exedev/e1/goroot/src/internal/abi/compiletype.go /home/exedev/e1/goroot/src/internal/abi/escape.go /home/exedev/e1/goroot/src/internal/abi/funcpc.go /home/exedev/e1/goroot/src/internal/abi/iface.go /home/exedev/e1/goroot/src/internal/abi/map.go /home/exedev/e1/goroot/src/internal/abi/rangefuncconsts.go /home/exedev/e1/goroot/src/internal/abi/runtime.go /home/exedev/e1/goroot/src/internal/abi/stack.go /home/exedev/e1/goroot/src/internal/abi/switch.go /home/exedev/e1/goroot/src/internal/abi/symtab.go /home/exedev/e1/goroot/src/internal/abi/type.go
cd /home/exedev/e1/goroot/src/internal/abi
/home/exedev/e1/goroot/pkg/tool/linux_amd64/asm -p internal/abi -trimpath "$WORK/b005=>" -I $WORK/b005/ -I /home/exedev/e1/goroot/pkg/include -D GOOS_wasip1 -D GOARCH_wasm -std -o $WORK/b005/abi_test.o ./abi_test.s
/home/exedev/e1/goroot/pkg/tool/linux_amd64/asm -p internal/abi -trimpath "$WORK/b005=>" -I $WORK/b005/ -I /home/exedev/e1/goroot/pkg/include -D GOOS_wasip1 -D GOARCH_wasm -std -o $WORK/b005/stub.o ./stub.s
go tool pack r $WORK/b005/_pkg_.a $WORK/b005/abi_test.o $WORK/b005/stub.o # internal
go tool buildid -w $WORK/b005/_pkg_.a # internal
mkdir -p $WORK/b008/

#
# internal/unsafeheader
#

echo '# import config' > $WORK/b008/importcfg # internal
cd /home/exedev/e1/tdemo
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b008/_pkg_.a -trimpath "$WORK/b008=>" -p internal/unsafeheader -lang=go1.27 -std -complete -buildid _1nXQrVr9mj8ErL7mZUD/_1nXQrVr9mj8ErL7mZUD -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b008/importcfg -pack /home/exedev/e1/goroot/src/internal/unsafeheader/unsafeheader.go
go tool buildid -w $WORK/b008/_pkg_.a # internal
mkdir -p $WORK/b011/

#
# internal/cpu
#

echo -n > $WORK/b011/go_asm.h # internal
cd /home/exedev/e1/goroot/src/internal/cpu
/home/exedev/e1/goroot/pkg/tool/linux_amd64/asm -p internal/cpu -trimpath "$WORK/b011=>" -I $WORK/b011/ -I /home/exedev/e1/goroot/pkg/include -D GOOS_wasip1 -D GOARCH_wasm -std -gensymabis -o $WORK/b011/symabis ./cpu.s
echo '# import config' > $WORK/b011/importcfg # internal
cd /home/exedev/e1/tdemo
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b011/_pkg_.a -trimpath "$WORK/b011=>" -p internal/cpu -lang=go1.27 -std -buildid ZGm9xB8L6Lqh12qU1ePt/ZGm9xB8L6Lqh12qU1ePt -dwarf=false -goversion go1.27.2 -symabis $WORK/b011/symabis -c=2 -nolocalimports -importcfg $WORK/b011/importcfg -pack -asmhdr $WORK/b011/go_asm.h /home/exedev/e1/goroot/src/internal/cpu/cpu.go /home/exedev/e1/goroot/src/internal/cpu/cpu_no_name.go /home/exedev/e1/goroot/src/internal/cpu/cpu_wasm.go /home/exedev/e1/goroot/src/internal/cpu/datacache_unsupported.go
cd /home/exedev/e1/goroot/src/internal/cpu
/home/exedev/e1/goroot/pkg/tool/linux_amd64/asm -p internal/cpu -trimpath "$WORK/b011=>" -I $WORK/b011/ -I /home/exedev/e1/goroot/pkg/include -D GOOS_wasip1 -D GOARCH_wasm -std -o $WORK/b011/cpu.o ./cpu.s
go tool pack r $WORK/b011/_pkg_.a $WORK/b011/cpu.o # internal
go tool buildid -w $WORK/b011/_pkg_.a # internal
mkdir -p $WORK/b010/

#
# internal/bytealg
#

echo -n > $WORK/b010/go_asm.h # internal
cd /home/exedev/e1/goroot/src/internal/bytealg
/home/exedev/e1/goroot/pkg/tool/linux_amd64/asm -p internal/bytealg -trimpath "$WORK/b010=>" -I $WORK/b010/ -I /home/exedev/e1/goroot/pkg/include -D GOOS_wasip1 -D GOARCH_wasm -std -gensymabis -o $WORK/b010/symabis ./compare_wasm.s ./equal_wasm.s ./indexbyte_wasm.s
cat >$WORK/b010/importcfg << 'EOF' # internal
# import config
packagefile internal/cpu=$WORK/b011/_pkg_.a
EOF
cd /home/exedev/e1/tdemo
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b010/_pkg_.a -trimpath "$WORK/b010=>" -p internal/bytealg -lang=go1.27 -std -buildid uzrXtk-Ct9RXt7op7YBY/uzrXtk-Ct9RXt7op7YBY -dwarf=false -goversion go1.27.2 -symabis $WORK/b010/symabis -c=2 -nolocalimports -importcfg $WORK/b010/importcfg -pack -asmhdr $WORK/b010/go_asm.h /home/exedev/e1/goroot/src/internal/bytealg/bytealg.go /home/exedev/e1/goroot/src/internal/bytealg/compare_native.go /home/exedev/e1/goroot/src/internal/bytealg/count_generic.go /home/exedev/e1/goroot/src/internal/bytealg/equal_generic.go /home/exedev/e1/goroot/src/internal/bytealg/equal_native.go /home/exedev/e1/goroot/src/internal/bytealg/index_generic.go /home/exedev/e1/goroot/src/internal/bytealg/indexbyte_native.go /home/exedev/e1/goroot/src/internal/bytealg/lastindexbyte_generic.go
cd /home/exedev/e1/goroot/src/internal/bytealg
/home/exedev/e1/goroot/pkg/tool/linux_amd64/asm -p internal/bytealg -trimpath "$WORK/b010=>" -I $WORK/b010/ -I /home/exedev/e1/goroot/pkg/include -D GOOS_wasip1 -D GOARCH_wasm -std -o $WORK/b010/compare_wasm.o ./compare_wasm.s
/home/exedev/e1/goroot/pkg/tool/linux_amd64/asm -p internal/bytealg -trimpath "$WORK/b010=>" -I $WORK/b010/ -I /home/exedev/e1/goroot/pkg/include -D GOOS_wasip1 -D GOARCH_wasm -std -o $WORK/b010/equal_wasm.o ./equal_wasm.s
/home/exedev/e1/goroot/pkg/tool/linux_amd64/asm -p internal/bytealg -trimpath "$WORK/b010=>" -I $WORK/b010/ -I /home/exedev/e1/goroot/pkg/include -D GOOS_wasip1 -D GOARCH_wasm -std -o $WORK/b010/indexbyte_wasm.o ./indexbyte_wasm.s
go tool pack r $WORK/b010/_pkg_.a $WORK/b010/compare_wasm.o $WORK/b010/equal_wasm.o $WORK/b010/indexbyte_wasm.o # internal
go tool buildid -w $WORK/b010/_pkg_.a # internal
mkdir -p $WORK/b012/

#
# internal/byteorder
#

echo '# import config' > $WORK/b012/importcfg # internal
cd /home/exedev/e1/tdemo
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b012/_pkg_.a -trimpath "$WORK/b012=>" -p internal/byteorder -lang=go1.27 -std -complete -buildid svXB2UM_cTbtsxW23T8N/svXB2UM_cTbtsxW23T8N -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b012/importcfg -pack /home/exedev/e1/goroot/src/internal/byteorder/byteorder.go
go tool buildid -w $WORK/b012/_pkg_.a # internal
mkdir -p $WORK/b013/

#
# internal/chacha8rand
#

echo -n > $WORK/b013/go_asm.h # internal
cd /home/exedev/e1/goroot/src/internal/chacha8rand
/home/exedev/e1/goroot/pkg/tool/linux_amd64/asm -p internal/chacha8rand -trimpath "$WORK/b013=>" -I $WORK/b013/ -I /home/exedev/e1/goroot/pkg/include -D GOOS_wasip1 -D GOARCH_wasm -std -gensymabis -o $WORK/b013/symabis ./chacha8_stub.s
cat >$WORK/b013/importcfg << 'EOF' # internal
# import config
packagefile internal/byteorder=$WORK/b012/_pkg_.a
packagefile internal/cpu=$WORK/b011/_pkg_.a
packagefile internal/goarch=$WORK/b006/_pkg_.a
EOF
cd /home/exedev/e1/tdemo
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b013/_pkg_.a -trimpath "$WORK/b013=>" -p internal/chacha8rand -lang=go1.27 -std -buildid iJxljzQjo09Fj-mTpe_e/iJxljzQjo09Fj-mTpe_e -dwarf=false -goversion go1.27.2 -symabis $WORK/b013/symabis -c=2 -nolocalimports -importcfg $WORK/b013/importcfg -pack -asmhdr $WORK/b013/go_asm.h /home/exedev/e1/goroot/src/internal/chacha8rand/chacha8.go /home/exedev/e1/goroot/src/internal/chacha8rand/chacha8_generic.go
cd /home/exedev/e1/goroot/src/internal/chacha8rand
/home/exedev/e1/goroot/pkg/tool/linux_amd64/asm -p internal/chacha8rand -trimpath "$WORK/b013=>" -I $WORK/b013/ -I /home/exedev/e1/goroot/pkg/include -D GOOS_wasip1 -D GOARCH_wasm -std -o $WORK/b013/chacha8_stub.o ./chacha8_stub.s
go tool pack r $WORK/b013/_pkg_.a $WORK/b013/chacha8_stub.o # internal
go tool buildid -w $WORK/b013/_pkg_.a # internal
mkdir -p $WORK/b014/

#
# internal/coverage/rtcov
#

echo '# import config' > $WORK/b014/importcfg # internal
cd /home/exedev/e1/tdemo
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b014/_pkg_.a -trimpath "$WORK/b014=>" -p internal/coverage/rtcov -lang=go1.27 -std -complete -buildid yohyobLDXW2rMAsQ4VnL/yohyobLDXW2rMAsQ4VnL -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b014/importcfg -pack /home/exedev/e1/goroot/src/internal/coverage/rtcov/rtcov.go
go tool buildid -w $WORK/b014/_pkg_.a # internal
mkdir -p $WORK/b015/

#
# internal/godebugs
#

echo '# import config' > $WORK/b015/importcfg # internal
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b015/_pkg_.a -trimpath "$WORK/b015=>" -p internal/godebugs -lang=go1.27 -std -complete -buildid dGVi-JnY-ClJFBe5hnAk/dGVi-JnY-ClJFBe5hnAk -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b015/importcfg -pack /home/exedev/e1/goroot/src/internal/godebugs/table.go
go tool buildid -w $WORK/b015/_pkg_.a # internal
mkdir -p $WORK/b016/

#
# internal/goexperiment
#

echo '# import config' > $WORK/b016/importcfg # internal
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b016/_pkg_.a -trimpath "$WORK/b016=>" -p internal/goexperiment -lang=go1.27 -std -complete -buildid lVbBg6l9aCMx3YEPUE7O/lVbBg6l9aCMx3YEPUE7O -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b016/importcfg -pack /home/exedev/e1/goroot/src/internal/goexperiment/exp_arenas_off.go /home/exedev/e1/goroot/src/internal/goexperiment/exp_boringcrypto_off.go /home/exedev/e1/goroot/src/internal/goexperiment/exp_cgocheck2_off.go /home/exedev/e1/goroot/src/internal/goexperiment/exp_dwarf5_on.go /home/exedev/e1/goroot/src/internal/goexperiment/exp_fieldtrack_off.go /home/exedev/e1/goroot/src/internal/goexperiment/exp_greenteagc_on.go /home/exedev/e1/goroot/src/internal/goexperiment/exp_heapminimum512kib_off.go /home/exedev/e1/goroot/src/internal/goexperiment/exp_jsonv2_on.go /home/exedev/e1/goroot/src/internal/goexperiment/exp_loopvar_off.go /home/exedev/e1/goroot/src/internal/goexperiment/exp_mapsplitgroup_off.go /home/exedev/e1/goroot/src/internal/goexperiment/exp_newinliner_off.go /home/exedev/e1/goroot/src/internal/goexperiment/exp_preemptibleloops_off.go /home/exedev/e1/goroot/src/internal/goexperiment/exp_randomizedheapbase64_on.go /home/exedev/e1/goroot/src/internal/goexperiment/exp_regabiargs_off.go /home/exedev/e1/goroot/src/internal/goexperiment/exp_regabiwrappers_off.go /home/exedev/e1/goroot/src/internal/goexperiment/exp_runtimefreegc_off.go /home/exedev/e1/goroot/src/internal/goexperiment/exp_runtimesecret_off.go /home/exedev/e1/goroot/src/internal/goexperiment/exp_simd_off.go /home/exedev/e1/goroot/src/internal/goexperiment/exp_sizespecializedmalloc_on.go /home/exedev/e1/goroot/src/internal/goexperiment/exp_staticlockranking_off.go /home/exedev/e1/goroot/src/internal/goexperiment/flags.go
go tool buildid -w $WORK/b016/_pkg_.a # internal
mkdir -p $WORK/b017/

#
# internal/goos
#

echo '# import config' > $WORK/b017/importcfg # internal
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b017/_pkg_.a -trimpath "$WORK/b017=>" -p internal/goos -lang=go1.27 -std -complete -buildid Tq2dqCqQLPfExjlNmMKN/Tq2dqCqQLPfExjlNmMKN -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b017/importcfg -pack /home/exedev/e1/goroot/src/internal/goos/goos.go /home/exedev/e1/goroot/src/internal/goos/nonunix.go /home/exedev/e1/goroot/src/internal/goos/zgoos_wasip1.go
go tool buildid -w $WORK/b017/_pkg_.a # internal
mkdir -p $WORK/b018/

#
# internal/profilerecord
#

echo '# import config' > $WORK/b018/importcfg # internal
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b018/_pkg_.a -trimpath "$WORK/b018=>" -p internal/profilerecord -lang=go1.27 -std -complete -buildid J-xHyfWGoO4bQlrCEizp/J-xHyfWGoO4bQlrCEizp -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b018/importcfg -pack /home/exedev/e1/goroot/src/internal/profilerecord/profilerecord.go
go tool buildid -w $WORK/b018/_pkg_.a # internal
mkdir -p $WORK/b019/

#
# internal/runtime/atomic
#

echo -n > $WORK/b019/go_asm.h # internal
cd /home/exedev/e1/goroot/src/internal/runtime/atomic
/home/exedev/e1/goroot/pkg/tool/linux_amd64/asm -p internal/runtime/atomic -trimpath "$WORK/b019=>" -I $WORK/b019/ -I /home/exedev/e1/goroot/pkg/include -D GOOS_wasip1 -D GOARCH_wasm -std -gensymabis -o $WORK/b019/symabis ./atomic_wasm.s
cat >$WORK/b019/importcfg << 'EOF' # internal
# import config
packagefile internal/goarch=$WORK/b006/_pkg_.a
EOF
cd /home/exedev/e1/tdemo
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b019/_pkg_.a -trimpath "$WORK/b019=>" -p internal/runtime/atomic -lang=go1.27 -std -buildid VxuVzHasgdEWEQTUjhU4/VxuVzHasgdEWEQTUjhU4 -dwarf=false -goversion go1.27.2 -symabis $WORK/b019/symabis -c=2 -nolocalimports -importcfg $WORK/b019/importcfg -pack -asmhdr $WORK/b019/go_asm.h /home/exedev/e1/goroot/src/internal/runtime/atomic/atomic_andor_generic.go /home/exedev/e1/goroot/src/internal/runtime/atomic/atomic_wasm.go /home/exedev/e1/goroot/src/internal/runtime/atomic/doc.go /home/exedev/e1/goroot/src/internal/runtime/atomic/linkname.go /home/exedev/e1/goroot/src/internal/runtime/atomic/types.go /home/exedev/e1/goroot/src/internal/runtime/atomic/types_64bit.go /home/exedev/e1/goroot/src/internal/runtime/atomic/unaligned.go /home/exedev/e1/goroot/src/internal/runtime/atomic/xchg8.go
cd /home/exedev/e1/goroot/src/internal/runtime/atomic
/home/exedev/e1/goroot/pkg/tool/linux_amd64/asm -p internal/runtime/atomic -trimpath "$WORK/b019=>" -I $WORK/b019/ -I /home/exedev/e1/goroot/pkg/include -D GOOS_wasip1 -D GOARCH_wasm -std -o $WORK/b019/atomic_wasm.o ./atomic_wasm.s
go tool pack r $WORK/b019/_pkg_.a $WORK/b019/atomic_wasm.o # internal
go tool buildid -w $WORK/b019/_pkg_.a # internal
mkdir -p $WORK/b020/

#
# internal/runtime/exithook
#

cat >$WORK/b020/importcfg << 'EOF' # internal
# import config
packagefile internal/runtime/atomic=$WORK/b019/_pkg_.a
EOF
cd /home/exedev/e1/tdemo
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b020/_pkg_.a -trimpath "$WORK/b020=>" -p internal/runtime/exithook -lang=go1.27 -std -complete -buildid LrtByoMzbjvaPvWOAbjz/LrtByoMzbjvaPvWOAbjz -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b020/importcfg -pack /home/exedev/e1/goroot/src/internal/runtime/exithook/hooks.go
go tool buildid -w $WORK/b020/_pkg_.a # internal
mkdir -p $WORK/b021/

#
# internal/runtime/gc
#

cat >$WORK/b021/importcfg << 'EOF' # internal
# import config
packagefile internal/goarch=$WORK/b006/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b021/_pkg_.a -trimpath "$WORK/b021=>" -p internal/runtime/gc -lang=go1.27 -std -complete -buildid D4yTga8Clmv73277C8YK/D4yTga8Clmv73277C8YK -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b021/importcfg -pack /home/exedev/e1/goroot/src/internal/runtime/gc/malloc.go /home/exedev/e1/goroot/src/internal/runtime/gc/scan.go /home/exedev/e1/goroot/src/internal/runtime/gc/sizeclasses.go
go tool buildid -w $WORK/b021/_pkg_.a # internal
mkdir -p $WORK/b023/

#
# internal/runtime/sys
#

echo -n > $WORK/b023/go_asm.h # internal
cd /home/exedev/e1/goroot/src/internal/runtime/sys
/home/exedev/e1/goroot/pkg/tool/linux_amd64/asm -p internal/runtime/sys -trimpath "$WORK/b023=>" -I $WORK/b023/ -I /home/exedev/e1/goroot/pkg/include -D GOOS_wasip1 -D GOARCH_wasm -std -gensymabis -o $WORK/b023/symabis ./empty.s
cat >$WORK/b023/importcfg << 'EOF' # internal
# import config
packagefile internal/goarch=$WORK/b006/_pkg_.a
packagefile internal/goos=$WORK/b017/_pkg_.a
EOF
cd /home/exedev/e1/tdemo
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b023/_pkg_.a -trimpath "$WORK/b023=>" -p internal/runtime/sys -lang=go1.27 -std -buildid sVJUT02HZbp_uTJ1U5Oz/sVJUT02HZbp_uTJ1U5Oz -dwarf=false -goversion go1.27.2 -symabis $WORK/b023/symabis -c=2 -nolocalimports -importcfg $WORK/b023/importcfg -pack -asmhdr $WORK/b023/go_asm.h /home/exedev/e1/goroot/src/internal/runtime/sys/consts.go /home/exedev/e1/goroot/src/internal/runtime/sys/consts_norace.go /home/exedev/e1/goroot/src/internal/runtime/sys/intrinsics.go /home/exedev/e1/goroot/src/internal/runtime/sys/nih.go /home/exedev/e1/goroot/src/internal/runtime/sys/no_dit.go /home/exedev/e1/goroot/src/internal/runtime/sys/sys.go /home/exedev/e1/goroot/src/internal/runtime/sys/zversion.go
cd /home/exedev/e1/goroot/src/internal/runtime/sys
/home/exedev/e1/goroot/pkg/tool/linux_amd64/asm -p internal/runtime/sys -trimpath "$WORK/b023=>" -I $WORK/b023/ -I /home/exedev/e1/goroot/pkg/include -D GOOS_wasip1 -D GOARCH_wasm -std -o $WORK/b023/empty.o ./empty.s
go tool pack r $WORK/b023/_pkg_.a $WORK/b023/empty.o # internal
go tool buildid -w $WORK/b023/_pkg_.a # internal
mkdir -p $WORK/b022/

#
# internal/runtime/gc/scan
#

cat >$WORK/b022/importcfg << 'EOF' # internal
# import config
packagefile internal/goarch=$WORK/b006/_pkg_.a
packagefile internal/runtime/gc=$WORK/b021/_pkg_.a
packagefile internal/runtime/sys=$WORK/b023/_pkg_.a
EOF
cd /home/exedev/e1/tdemo
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b022/_pkg_.a -trimpath "$WORK/b022=>" -p internal/runtime/gc/scan -lang=go1.27 -std -complete -buildid KhySlTfWXehXPvr39lRd/KhySlTfWXehXPvr39lRd -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b022/importcfg -pack /home/exedev/e1/goroot/src/internal/runtime/gc/scan/expand_reference.go /home/exedev/e1/goroot/src/internal/runtime/gc/scan/filter.go /home/exedev/e1/goroot/src/internal/runtime/gc/scan/scan_generic.go /home/exedev/e1/goroot/src/internal/runtime/gc/scan/scan_go.go /home/exedev/e1/goroot/src/internal/runtime/gc/scan/scan_reference.go
go tool buildid -w $WORK/b022/_pkg_.a # internal
mkdir -p $WORK/b025/

#
# internal/asan
#

echo '# import config' > $WORK/b025/importcfg # internal
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b025/_pkg_.a -trimpath "$WORK/b025=>" -p internal/asan -lang=go1.27 -std -complete -buildid 4IpBr7GRjXsGqDPx70ep/4IpBr7GRjXsGqDPx70ep -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b025/importcfg -pack /home/exedev/e1/goroot/src/internal/asan/doc.go /home/exedev/e1/goroot/src/internal/asan/noasan.go
go tool buildid -w $WORK/b025/_pkg_.a # internal
mkdir -p $WORK/b026/

#
# internal/msan
#

echo '# import config' > $WORK/b026/importcfg # internal
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b026/_pkg_.a -trimpath "$WORK/b026=>" -p internal/msan -lang=go1.27 -std -complete -buildid 4DhJnYtlyZQT6Pz1a1o3/4DhJnYtlyZQT6Pz1a1o3 -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b026/importcfg -pack /home/exedev/e1/goroot/src/internal/msan/doc.go /home/exedev/e1/goroot/src/internal/msan/nomsan.go
go tool buildid -w $WORK/b026/_pkg_.a # internal
mkdir -p $WORK/b027/

#
# internal/race
#

cat >$WORK/b027/importcfg << 'EOF' # internal
# import config
packagefile internal/abi=$WORK/b005/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b027/_pkg_.a -trimpath "$WORK/b027=>" -p internal/race -lang=go1.27 -std -complete -buildid yjz8QJcAyvdXlCLFuEwy/yjz8QJcAyvdXlCLFuEwy -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b027/importcfg -pack /home/exedev/e1/goroot/src/internal/race/doc.go /home/exedev/e1/goroot/src/internal/race/norace.go
go tool buildid -w $WORK/b027/_pkg_.a # internal
mkdir -p $WORK/b028/

#
# internal/runtime/math
#

cat >$WORK/b028/importcfg << 'EOF' # internal
# import config
packagefile internal/goarch=$WORK/b006/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b028/_pkg_.a -trimpath "$WORK/b028=>" -p internal/runtime/math -lang=go1.27 -std -complete -buildid QVYPrSA1V1VzSqCXfg8q/QVYPrSA1V1VzSqCXfg8q -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b028/importcfg -pack /home/exedev/e1/goroot/src/internal/runtime/math/math.go
go tool buildid -w $WORK/b028/_pkg_.a # internal
mkdir -p $WORK/b024/

#
# internal/runtime/maps
#

cat >$WORK/b024/importcfg << 'EOF' # internal
# import config
packagefile internal/abi=$WORK/b005/_pkg_.a
packagefile internal/asan=$WORK/b025/_pkg_.a
packagefile internal/byteorder=$WORK/b012/_pkg_.a
packagefile internal/cpu=$WORK/b011/_pkg_.a
packagefile internal/goarch=$WORK/b006/_pkg_.a
packagefile internal/goexperiment=$WORK/b016/_pkg_.a
packagefile internal/msan=$WORK/b026/_pkg_.a
packagefile internal/race=$WORK/b027/_pkg_.a
packagefile internal/runtime/math=$WORK/b028/_pkg_.a
packagefile internal/runtime/sys=$WORK/b023/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b024/_pkg_.a -trimpath "$WORK/b024=>" -p internal/runtime/maps -lang=go1.27 -std -complete -buildid vROFl3xEkDd4rf3eOllg/vROFl3xEkDd4rf3eOllg -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b024/importcfg -pack /home/exedev/e1/goroot/src/internal/runtime/maps/group.go /home/exedev/e1/goroot/src/internal/runtime/maps/map.go /home/exedev/e1/goroot/src/internal/runtime/maps/memhash_align_nocheck.go /home/exedev/e1/goroot/src/internal/runtime/maps/memhash_noaes.go /home/exedev/e1/goroot/src/internal/runtime/maps/runtime.go /home/exedev/e1/goroot/src/internal/runtime/maps/runtime_alg.go /home/exedev/e1/goroot/src/internal/runtime/maps/runtime_fast32.go /home/exedev/e1/goroot/src/internal/runtime/maps/runtime_fast64.go /home/exedev/e1/goroot/src/internal/runtime/maps/runtime_faststr.go /home/exedev/e1/goroot/src/internal/runtime/maps/runtime_hash32.go /home/exedev/e1/goroot/src/internal/runtime/maps/table.go /home/exedev/e1/goroot/src/internal/runtime/maps/table_debug.go
go tool buildid -w $WORK/b024/_pkg_.a # internal
mkdir -p $WORK/b029/

#
# internal/runtime/pprof/label
#

echo '# import config' > $WORK/b029/importcfg # internal
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b029/_pkg_.a -trimpath "$WORK/b029=>" -p internal/runtime/pprof/label -lang=go1.27 -std -complete -buildid suVvGZt8IrkevBR8SHpM/suVvGZt8IrkevBR8SHpM -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b029/importcfg -pack /home/exedev/e1/goroot/src/internal/runtime/pprof/label/labelset.go
go tool buildid -w $WORK/b029/_pkg_.a # internal
mkdir -p $WORK/b031/

#
# math/bits
#

echo '# import config' > $WORK/b031/importcfg # internal
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b031/_pkg_.a -trimpath "$WORK/b031=>" -p math/bits -lang=go1.27 -std -complete -buildid jFO9OtmDM2_FNYBXl4yW/jFO9OtmDM2_FNYBXl4yW -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b031/importcfg -pack /home/exedev/e1/goroot/src/math/bits/bits.go /home/exedev/e1/goroot/src/math/bits/bits_errors.go /home/exedev/e1/goroot/src/math/bits/bits_tables.go
go tool buildid -w $WORK/b031/_pkg_.a # internal
mkdir -p $WORK/b030/

#
# internal/strconv
#

cat >$WORK/b030/importcfg << 'EOF' # internal
# import config
packagefile math/bits=$WORK/b031/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b030/_pkg_.a -trimpath "$WORK/b030=>" -p internal/strconv -lang=go1.27 -std -complete -buildid GstdqG995YiwwoZxYG0d/GstdqG995YiwwoZxYG0d -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b030/importcfg -pack /home/exedev/e1/goroot/src/internal/strconv/atob.go /home/exedev/e1/goroot/src/internal/strconv/atoc.go /home/exedev/e1/goroot/src/internal/strconv/atof.go /home/exedev/e1/goroot/src/internal/strconv/atoi.go /home/exedev/e1/goroot/src/internal/strconv/ctoa.go /home/exedev/e1/goroot/src/internal/strconv/decimal.go /home/exedev/e1/goroot/src/internal/strconv/deps.go /home/exedev/e1/goroot/src/internal/strconv/ftoa.go /home/exedev/e1/goroot/src/internal/strconv/itoa.go /home/exedev/e1/goroot/src/internal/strconv/pow10tab.go /home/exedev/e1/goroot/src/internal/strconv/uscale.go
go tool buildid -w $WORK/b030/_pkg_.a # internal
mkdir -p $WORK/b032/

#
# internal/stringslite
#

cat >$WORK/b032/importcfg << 'EOF' # internal
# import config
packagefile internal/bytealg=$WORK/b010/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b032/_pkg_.a -trimpath "$WORK/b032=>" -p internal/stringslite -lang=go1.27 -std -complete -buildid MfCC8f_ZscDf6Nt2YrXW/MfCC8f_ZscDf6Nt2YrXW -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b032/importcfg -pack /home/exedev/e1/goroot/src/internal/stringslite/strings.go
go tool buildid -w $WORK/b032/_pkg_.a # internal
mkdir -p $WORK/b033/

#
# internal/trace/tracev2
#

echo '# import config' > $WORK/b033/importcfg # internal
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b033/_pkg_.a -trimpath "$WORK/b033=>" -p internal/trace/tracev2 -lang=go1.27 -std -complete -buildid Oekf_bzbTibg7pzXH4f-/Oekf_bzbTibg7pzXH4f- -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b033/importcfg -pack /home/exedev/e1/goroot/src/internal/trace/tracev2/doc.go /home/exedev/e1/goroot/src/internal/trace/tracev2/events.go /home/exedev/e1/goroot/src/internal/trace/tracev2/spec.go
go tool buildid -w $WORK/b033/_pkg_.a # internal
mkdir -p $WORK/b034/

#
# structs
#

echo '# import config' > $WORK/b034/importcfg # internal
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b034/_pkg_.a -trimpath "$WORK/b034=>" -p structs -lang=go1.27 -std -complete -buildid wG2yErSF9OlD_UxLXkDm/wG2yErSF9OlD_UxLXkDm -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b034/importcfg -pack /home/exedev/e1/goroot/src/structs/doc.go /home/exedev/e1/goroot/src/structs/hostlayout.go
go tool buildid -w $WORK/b034/_pkg_.a # internal
mkdir -p $WORK/b009/

#
# runtime
#

echo -n > $WORK/b009/go_asm.h # internal
cd /home/exedev/e1/goroot/src/runtime
/home/exedev/e1/goroot/pkg/tool/linux_amd64/asm -p runtime -trimpath "$WORK/b009=>" -I $WORK/b009/ -I /home/exedev/e1/goroot/pkg/include -D GOOS_wasip1 -D GOARCH_wasm -std -gensymabis -o $WORK/b009/symabis ./asm.s ./asm_wasm.s ./ints.s ./memclr_wasm.s ./memmove_wasm.s ./preempt_wasm.s ./rt0_wasip1_wasm.s ./sys_wasm.s
cat >$WORK/b009/importcfg << 'EOF' # internal
# import config
packagefile internal/abi=$WORK/b005/_pkg_.a
packagefile internal/bytealg=$WORK/b010/_pkg_.a
packagefile internal/byteorder=$WORK/b012/_pkg_.a
packagefile internal/chacha8rand=$WORK/b013/_pkg_.a
packagefile internal/coverage/rtcov=$WORK/b014/_pkg_.a
packagefile internal/cpu=$WORK/b011/_pkg_.a
packagefile internal/goarch=$WORK/b006/_pkg_.a
packagefile internal/godebugs=$WORK/b015/_pkg_.a
packagefile internal/goexperiment=$WORK/b016/_pkg_.a
packagefile internal/goos=$WORK/b017/_pkg_.a
packagefile internal/profilerecord=$WORK/b018/_pkg_.a
packagefile internal/runtime/atomic=$WORK/b019/_pkg_.a
packagefile internal/runtime/exithook=$WORK/b020/_pkg_.a
packagefile internal/runtime/gc=$WORK/b021/_pkg_.a
packagefile internal/runtime/gc/scan=$WORK/b022/_pkg_.a
packagefile internal/runtime/maps=$WORK/b024/_pkg_.a
packagefile internal/runtime/math=$WORK/b028/_pkg_.a
packagefile internal/runtime/pprof/label=$WORK/b029/_pkg_.a
packagefile internal/runtime/sys=$WORK/b023/_pkg_.a
packagefile internal/strconv=$WORK/b030/_pkg_.a
packagefile internal/stringslite=$WORK/b032/_pkg_.a
packagefile internal/trace/tracev2=$WORK/b033/_pkg_.a
packagefile math/bits=$WORK/b031/_pkg_.a
packagefile structs=$WORK/b034/_pkg_.a
EOF
cd /home/exedev/e1/tdemo
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b009/_pkg_.a -trimpath "$WORK/b009=>" -p runtime -lang=go1.27 -std -buildid r7ZP8pna73kJV8xBI2Cq/r7ZP8pna73kJV8xBI2Cq -dwarf=false -goversion go1.27.2 -symabis $WORK/b009/symabis -c=2 -nolocalimports -importcfg $WORK/b009/importcfg -pack -asmhdr $WORK/b009/go_asm.h /home/exedev/e1/goroot/src/runtime/alg.go /home/exedev/e1/goroot/src/runtime/arena.go /home/exedev/e1/goroot/src/runtime/asan0.go /home/exedev/e1/goroot/src/runtime/atomic_pointer.go /home/exedev/e1/goroot/src/runtime/auxv_none.go /home/exedev/e1/goroot/src/runtime/badlinkname.go /home/exedev/e1/goroot/src/runtime/cgo.go /home/exedev/e1/goroot/src/runtime/cgocall.go /home/exedev/e1/goroot/src/runtime/cgocallback.go /home/exedev/e1/goroot/src/runtime/cgocheck.go /home/exedev/e1/goroot/src/runtime/cgroup_stubs.go /home/exedev/e1/goroot/src/runtime/chan.go /home/exedev/e1/goroot/src/runtime/checkptr.go /home/exedev/e1/goroot/src/runtime/compiler.go /home/exedev/e1/goroot/src/runtime/complex.go /home/exedev/e1/goroot/src/runtime/coro.go /home/exedev/e1/goroot/src/runtime/covercounter.go /home/exedev/e1/goroot/src/runtime/covermeta.go /home/exedev/e1/goroot/src/runtime/cpuflags.go /home/exedev/e1/goroot/src/runtime/cpuprof.go /home/exedev/e1/goroot/src/runtime/create_file_nounix.go /home/exedev/e1/goroot/src/runtime/debug.go /home/exedev/e1/goroot/src/runtime/debuglog.go /home/exedev/e1/goroot/src/runtime/debuglog_off.go /home/exedev/e1/goroot/src/runtime/dit.go /home/exedev/e1/goroot/src/runtime/env_posix.go /home/exedev/e1/goroot/src/runtime/error.go /home/exedev/e1/goroot/src/runtime/extern.go /home/exedev/e1/goroot/src/runtime/fastlog2.go /home/exedev/e1/goroot/src/runtime/fastlog2table.go /home/exedev/e1/goroot/src/runtime/fds_nonunix.go /home/exedev/e1/goroot/src/runtime/fipsbypass.go /home/exedev/e1/goroot/src/runtime/float.go /home/exedev/e1/goroot/src/runtime/heapdump.go /home/exedev/e1/goroot/src/runtime/hexdump.go /home/exedev/e1/goroot/src/runtime/histogram.go /home/exedev/e1/goroot/src/runtime/iface.go /home/exedev/e1/goroot/src/runtime/lfstack.go /home/exedev/e1/goroot/src/runtime/linkname.go /home/exedev/e1/goroot/src/runtime/linkname_shim.go /home/exedev/e1/goroot/src/runtime/list.go /home/exedev/e1/goroot/src/runtime/list_manual.go /home/exedev/e1/goroot/src/runtime/lock_wasip1.go /home/exedev/e1/goroot/src/runtime/lockrank.go /home/exedev/e1/goroot/src/runtime/lockrank_off.go /home/exedev/e1/goroot/src/runtime/malloc.go /home/exedev/e1/goroot/src/runtime/malloc_generated.go /home/exedev/e1/goroot/src/runtime/malloc_stubs.go /home/exedev/e1/goroot/src/runtime/malloc_tables_generated.go /home/exedev/e1/goroot/src/runtime/map.go /home/exedev/e1/goroot/src/runtime/map_fast32.go /home/exedev/e1/goroot/src/runtime/map_fast64.go /home/exedev/e1/goroot/src/runtime/map_faststr.go /home/exedev/e1/goroot/src/runtime/mbarrier.go /home/exedev/e1/goroot/src/runtime/mbitmap.go /home/exedev/e1/goroot/src/runtime/mcache.go /home/exedev/e1/goroot/src/runtime/mcentral.go /home/exedev/e1/goroot/src/runtime/mcheckmark.go /home/exedev/e1/goroot/src/runtime/mcleanup.go /home/exedev/e1/goroot/src/runtime/mem.go /home/exedev/e1/goroot/src/runtime/mem_sbrk.go /home/exedev/e1/goroot/src/runtime/mem_wasip1.go /home/exedev/e1/goroot/src/runtime/mem_wasm.go /home/exedev/e1/goroot/src/runtime/metrics.go /home/exedev/e1/goroot/src/runtime/mfinal.go /home/exedev/e1/goroot/src/runtime/mfixalloc.go /home/exedev/e1/goroot/src/runtime/mgc.go /home/exedev/e1/goroot/src/runtime/mgclimit.go /home/exedev/e1/goroot/src/runtime/mgcmark.go /home/exedev/e1/goroot/src/runtime/mgcmark_greenteagc.go /home/exedev/e1/goroot/src/runtime/mgcpacer.go /home/exedev/e1/goroot/src/runtime/mgcscavenge.go /home/exedev/e1/goroot/src/runtime/mgcstack.go /home/exedev/e1/goroot/src/runtime/mgcsweep.go /home/exedev/e1/goroot/src/runtime/mgcwork.go /home/exedev/e1/goroot/src/runtime/mheap.go /home/exedev/e1/goroot/src/runtime/minmax.go /home/exedev/e1/goroot/src/runtime/mmap.go /home/exedev/e1/goroot/src/runtime/mpagealloc.go /home/exedev/e1/goroot/src/runtime/mpagealloc_32bit.go /home/exedev/e1/goroot/src/runtime/mpagecache.go /home/exedev/e1/goroot/src/runtime/mpallocbits.go /home/exedev/e1/goroot/src/runtime/mprof.go /home/exedev/e1/goroot/src/runtime/mranges.go /home/exedev/e1/goroot/src/runtime/msan0.go /home/exedev/e1/goroot/src/runtime/msize.go /home/exedev/e1/goroot/src/runtime/mspanset.go /home/exedev/e1/goroot/src/runtime/mstats.go /home/exedev/e1/goroot/src/runtime/mwbbuf.go /home/exedev/e1/goroot/src/runtime/netpoll.go /home/exedev/e1/goroot/src/runtime/netpoll_wasip1.go /home/exedev/e1/goroot/src/runtime/nonwindows_stub.go /home/exedev/e1/goroot/src/runtime/note_other.go /home/exedev/e1/goroot/src/runtime/os_nonopenbsd.go /home/exedev/e1/goroot/src/runtime/os_wasip1.go /home/exedev/e1/goroot/src/runtime/os_wasm.go /home/exedev/e1/goroot/src/runtime/panic.go /home/exedev/e1/goroot/src/runtime/pinner.go /home/exedev/e1/goroot/src/runtime/plugin.go /home/exedev/e1/goroot/src/runtime/preempt.go /home/exedev/e1/goroot/src/runtime/preempt_nonwindows.go /home/exedev/e1/goroot/src/runtime/preempt_noxreg.go /home/exedev/e1/goroot/src/runtime/print.go /home/exedev/e1/goroot/src/runtime/proc.go /home/exedev/e1/goroot/src/runtime/profbuf.go /home/exedev/e1/goroot/src/runtime/proflabel.go /home/exedev/e1/goroot/src/runtime/race0.go /home/exedev/e1/goroot/src/runtime/rand.go /home/exedev/e1/goroot/src/runtime/rdebug.go /home/exedev/e1/goroot/src/runtime/runtime.go /home/exedev/e1/goroot/src/runtime/runtime1.go /home/exedev/e1/goroot/src/runtime/runtime2.go /home/exedev/e1/goroot/src/runtime/runtime_boring.go /home/exedev/e1/goroot/src/runtime/runtime_noclearenv.go /home/exedev/e1/goroot/src/runtime/rwmutex.go /home/exedev/e1/goroot/src/runtime/secret_noasm.go /home/exedev/e1/goroot/src/runtime/secret_nosecret.go /home/exedev/e1/goroot/src/runtime/security_nonunix.go /home/exedev/e1/goroot/src/runtime/select.go /home/exedev/e1/goroot/src/runtime/sema.go /home/exedev/e1/goroot/src/runtime/set_vma_name_stub.go /home/exedev/e1/goroot/src/runtime/sigqueue.go /home/exedev/e1/goroot/src/runtime/sigqueue_note.go /home/exedev/e1/goroot/src/runtime/slice.go /home/exedev/e1/goroot/src/runtime/softfloat64.go /home/exedev/e1/goroot/src/runtime/stack.go /home/exedev/e1/goroot/src/runtime/stkframe.go /home/exedev/e1/goroot/src/runtime/string.go /home/exedev/e1/goroot/src/runtime/stubs.go /home/exedev/e1/goroot/src/runtime/stubs_nonlinux.go /home/exedev/e1/goroot/src/runtime/stubs_wasm.go /home/exedev/e1/goroot/src/runtime/symtab.go /home/exedev/e1/goroot/src/runtime/symtabinl.go /home/exedev/e1/goroot/src/runtime/synctest.go /home/exedev/e1/goroot/src/runtime/sys_nonppc64x.go /home/exedev/e1/goroot/src/runtime/sys_wasm.go /home/exedev/e1/goroot/src/runtime/tagptr.go /home/exedev/e1/goroot/src/runtime/tagptr_64bit.go /home/exedev/e1/goroot/src/runtime/test_stubs.go /home/exedev/e1/goroot/src/runtime/time.go /home/exedev/e1/goroot/src/runtime/time_nofake.go /home/exedev/e1/goroot/src/runtime/timestub.go /home/exedev/e1/goroot/src/runtime/tls_stub.go /home/exedev/e1/goroot/src/runtime/trace.go /home/exedev/e1/goroot/src/runtime/traceallocfree.go /home/exedev/e1/goroot/src/runtime/traceback.go /home/exedev/e1/goroot/src/runtime/tracebuf.go /home/exedev/e1/goroot/src/runtime/tracecpu.go /home/exedev/e1/goroot/src/runtime/traceevent.go /home/exedev/e1/goroot/src/runtime/tracemap.go /home/exedev/e1/goroot/src/runtime/traceregion.go /home/exedev/e1/goroot/src/runtime/traceruntime.go /home/exedev/e1/goroot/src/runtime/tracestack.go /home/exedev/e1/goroot/src/runtime/tracestatus.go /home/exedev/e1/goroot/src/runtime/tracestring.go /home/exedev/e1/goroot/src/runtime/tracetime.go /home/exedev/e1/goroot/src/runtime/tracetype.go /home/exedev/e1/goroot/src/runtime/type.go /home/exedev/e1/goroot/src/runtime/unsafe.go /home/exedev/e1/goroot/src/runtime/utf8.go /home/exedev/e1/goroot/src/runtime/valgrind0.go /home/exedev/e1/goroot/src/runtime/vdso_in_none.go /home/exedev/e1/goroot/src/runtime/vgetrandom_unsupported.go /home/exedev/e1/goroot/src/runtime/write_err.go
cd /home/exedev/e1/goroot/src/runtime
/home/exedev/e1/goroot/pkg/tool/linux_amd64/asm -p runtime -trimpath "$WORK/b009=>" -I $WORK/b009/ -I /home/exedev/e1/goroot/pkg/include -D GOOS_wasip1 -D GOARCH_wasm -std -o $WORK/b009/asm.o ./asm.s
/home/exedev/e1/goroot/pkg/tool/linux_amd64/asm -p runtime -trimpath "$WORK/b009=>" -I $WORK/b009/ -I /home/exedev/e1/goroot/pkg/include -D GOOS_wasip1 -D GOARCH_wasm -std -o $WORK/b009/asm_wasm.o ./asm_wasm.s
/home/exedev/e1/goroot/pkg/tool/linux_amd64/asm -p runtime -trimpath "$WORK/b009=>" -I $WORK/b009/ -I /home/exedev/e1/goroot/pkg/include -D GOOS_wasip1 -D GOARCH_wasm -std -o $WORK/b009/ints.o ./ints.s
/home/exedev/e1/goroot/pkg/tool/linux_amd64/asm -p runtime -trimpath "$WORK/b009=>" -I $WORK/b009/ -I /home/exedev/e1/goroot/pkg/include -D GOOS_wasip1 -D GOARCH_wasm -std -o $WORK/b009/memclr_wasm.o ./memclr_wasm.s
/home/exedev/e1/goroot/pkg/tool/linux_amd64/asm -p runtime -trimpath "$WORK/b009=>" -I $WORK/b009/ -I /home/exedev/e1/goroot/pkg/include -D GOOS_wasip1 -D GOARCH_wasm -std -o $WORK/b009/memmove_wasm.o ./memmove_wasm.s
/home/exedev/e1/goroot/pkg/tool/linux_amd64/asm -p runtime -trimpath "$WORK/b009=>" -I $WORK/b009/ -I /home/exedev/e1/goroot/pkg/include -D GOOS_wasip1 -D GOARCH_wasm -std -o $WORK/b009/preempt_wasm.o ./preempt_wasm.s
/home/exedev/e1/goroot/pkg/tool/linux_amd64/asm -p runtime -trimpath "$WORK/b009=>" -I $WORK/b009/ -I /home/exedev/e1/goroot/pkg/include -D GOOS_wasip1 -D GOARCH_wasm -std -o $WORK/b009/rt0_wasip1_wasm.o ./rt0_wasip1_wasm.s
/home/exedev/e1/goroot/pkg/tool/linux_amd64/asm -p runtime -trimpath "$WORK/b009=>" -I $WORK/b009/ -I /home/exedev/e1/goroot/pkg/include -D GOOS_wasip1 -D GOARCH_wasm -std -o $WORK/b009/sys_wasm.o ./sys_wasm.s
go tool pack r $WORK/b009/_pkg_.a $WORK/b009/asm.o $WORK/b009/asm_wasm.o $WORK/b009/ints.o $WORK/b009/memclr_wasm.o $WORK/b009/memmove_wasm.o $WORK/b009/preempt_wasm.o $WORK/b009/rt0_wasip1_wasm.o $WORK/b009/sys_wasm.o # internal
go tool buildid -w $WORK/b009/_pkg_.a # internal
mkdir -p $WORK/b004/

#
# internal/reflectlite
#

echo -n > $WORK/b004/go_asm.h # internal
cd /home/exedev/e1/goroot/src/internal/reflectlite
/home/exedev/e1/goroot/pkg/tool/linux_amd64/asm -p internal/reflectlite -trimpath "$WORK/b004=>" -I $WORK/b004/ -I /home/exedev/e1/goroot/pkg/include -D GOOS_wasip1 -D GOARCH_wasm -std -gensymabis -o $WORK/b004/symabis ./asm.s
cat >$WORK/b004/importcfg << 'EOF' # internal
# import config
packagefile internal/abi=$WORK/b005/_pkg_.a
packagefile internal/goarch=$WORK/b006/_pkg_.a
packagefile internal/unsafeheader=$WORK/b008/_pkg_.a
packagefile runtime=$WORK/b009/_pkg_.a
EOF
cd /home/exedev/e1/tdemo
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b004/_pkg_.a -trimpath "$WORK/b004=>" -p internal/reflectlite -lang=go1.27 -std -buildid h9lv-Km-tANTMGoastvk/h9lv-Km-tANTMGoastvk -dwarf=false -goversion go1.27.2 -symabis $WORK/b004/symabis -c=2 -nolocalimports -importcfg $WORK/b004/importcfg -pack -asmhdr $WORK/b004/go_asm.h /home/exedev/e1/goroot/src/internal/reflectlite/swapper.go /home/exedev/e1/goroot/src/internal/reflectlite/type.go /home/exedev/e1/goroot/src/internal/reflectlite/value.go
cd /home/exedev/e1/goroot/src/internal/reflectlite
/home/exedev/e1/goroot/pkg/tool/linux_amd64/asm -p internal/reflectlite -trimpath "$WORK/b004=>" -I $WORK/b004/ -I /home/exedev/e1/goroot/pkg/include -D GOOS_wasip1 -D GOARCH_wasm -std -o $WORK/b004/asm.o ./asm.s
go tool pack r $WORK/b004/_pkg_.a $WORK/b004/asm.o # internal
go tool buildid -w $WORK/b004/_pkg_.a # internal
mkdir -p $WORK/b003/

#
# errors
#

cat >$WORK/b003/importcfg << 'EOF' # internal
# import config
packagefile internal/reflectlite=$WORK/b004/_pkg_.a
EOF
cd /home/exedev/e1/tdemo
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b003/_pkg_.a -trimpath "$WORK/b003=>" -p errors -lang=go1.27 -std -complete -buildid pH1HPneggWze8Uf7FupE/pH1HPneggWze8Uf7FupE -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b003/importcfg -pack /home/exedev/e1/goroot/src/errors/errors.go /home/exedev/e1/goroot/src/errors/join.go /home/exedev/e1/goroot/src/errors/wrap.go
go tool buildid -w $WORK/b003/_pkg_.a # internal
mkdir -p $WORK/b037/

#
# internal/oserror
#

cat >$WORK/b037/importcfg << 'EOF' # internal
# import config
packagefile errors=$WORK/b003/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b037/_pkg_.a -trimpath "$WORK/b037=>" -p internal/oserror -lang=go1.27 -std -complete -buildid pjvpT3OJDcZtthVOnVrv/pjvpT3OJDcZtthVOnVrv -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b037/importcfg -pack /home/exedev/e1/goroot/src/internal/oserror/errors.go
go tool buildid -w $WORK/b037/_pkg_.a # internal
mkdir -p $WORK/b041/

#
# sync/atomic
#

echo -n > $WORK/b041/go_asm.h # internal
cd /home/exedev/e1/goroot/src/sync/atomic
/home/exedev/e1/goroot/pkg/tool/linux_amd64/asm -p sync/atomic -trimpath "$WORK/b041=>" -I $WORK/b041/ -I /home/exedev/e1/goroot/pkg/include -D GOOS_wasip1 -D GOARCH_wasm -std -gensymabis -o $WORK/b041/symabis ./asm.s
echo '# import config' > $WORK/b041/importcfg # internal
cd /home/exedev/e1/tdemo
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b041/_pkg_.a -trimpath "$WORK/b041=>" -p sync/atomic -lang=go1.27 -std -buildid nB0e3cZzu9c7qraDvcW_/nB0e3cZzu9c7qraDvcW_ -dwarf=false -goversion go1.27.2 -symabis $WORK/b041/symabis -c=2 -nolocalimports -importcfg $WORK/b041/importcfg -pack -asmhdr $WORK/b041/go_asm.h /home/exedev/e1/goroot/src/sync/atomic/doc.go /home/exedev/e1/goroot/src/sync/atomic/doc_64.go /home/exedev/e1/goroot/src/sync/atomic/type.go /home/exedev/e1/goroot/src/sync/atomic/value.go
cd /home/exedev/e1/goroot/src/sync/atomic
/home/exedev/e1/goroot/pkg/tool/linux_amd64/asm -p sync/atomic -trimpath "$WORK/b041=>" -I $WORK/b041/ -I /home/exedev/e1/goroot/pkg/include -D GOOS_wasip1 -D GOARCH_wasm -std -o $WORK/b041/asm.o ./asm.s
go tool pack r $WORK/b041/_pkg_.a $WORK/b041/asm.o # internal
go tool buildid -w $WORK/b041/_pkg_.a # internal
mkdir -p $WORK/b040/

#
# internal/sync
#

cat >$WORK/b040/importcfg << 'EOF' # internal
# import config
packagefile internal/abi=$WORK/b005/_pkg_.a
packagefile internal/goarch=$WORK/b006/_pkg_.a
packagefile internal/race=$WORK/b027/_pkg_.a
packagefile sync/atomic=$WORK/b041/_pkg_.a
EOF
cd /home/exedev/e1/tdemo
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b040/_pkg_.a -trimpath "$WORK/b040=>" -p internal/sync -lang=go1.27 -std -complete -buildid 5TALmfVxl4FwR3XsvrOD/5TALmfVxl4FwR3XsvrOD -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b040/importcfg -pack /home/exedev/e1/goroot/src/internal/sync/hashtriemap.go /home/exedev/e1/goroot/src/internal/sync/mutex.go /home/exedev/e1/goroot/src/internal/sync/runtime.go
go tool buildid -w $WORK/b040/_pkg_.a # internal
mkdir -p $WORK/b042/

#
# internal/synctest
#

cat >$WORK/b042/importcfg << 'EOF' # internal
# import config
packagefile internal/abi=$WORK/b005/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b042/_pkg_.a -trimpath "$WORK/b042=>" -p internal/synctest -lang=go1.27 -std -complete -buildid bqjkgzvyU5cRLZjIQQzR/bqjkgzvyU5cRLZjIQQzR -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b042/importcfg -pack /home/exedev/e1/goroot/src/internal/synctest/synctest.go
go tool buildid -w $WORK/b042/_pkg_.a # internal
mkdir -p $WORK/b039/

#
# sync
#

cat >$WORK/b039/importcfg << 'EOF' # internal
# import config
packagefile internal/race=$WORK/b027/_pkg_.a
packagefile internal/runtime/atomic=$WORK/b019/_pkg_.a
packagefile internal/sync=$WORK/b040/_pkg_.a
packagefile internal/synctest=$WORK/b042/_pkg_.a
packagefile runtime=$WORK/b009/_pkg_.a
packagefile sync/atomic=$WORK/b041/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b039/_pkg_.a -trimpath "$WORK/b039=>" -p sync -lang=go1.27 -std -buildid Oh03-KQchBF_PSFKhL-D/Oh03-KQchBF_PSFKhL-D -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b039/importcfg -pack /home/exedev/e1/goroot/src/sync/cond.go /home/exedev/e1/goroot/src/sync/map.go /home/exedev/e1/goroot/src/sync/mutex.go /home/exedev/e1/goroot/src/sync/once.go /home/exedev/e1/goroot/src/sync/oncefunc.go /home/exedev/e1/goroot/src/sync/pool.go /home/exedev/e1/goroot/src/sync/poolqueue.go /home/exedev/e1/goroot/src/sync/runtime.go /home/exedev/e1/goroot/src/sync/runtime2.go /home/exedev/e1/goroot/src/sync/rwmutex.go /home/exedev/e1/goroot/src/sync/waitgroup.go
go tool buildid -w $WORK/b039/_pkg_.a # internal
mkdir -p $WORK/b038/

#
# io
#

cat >$WORK/b038/importcfg << 'EOF' # internal
# import config
packagefile errors=$WORK/b003/_pkg_.a
packagefile sync=$WORK/b039/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b038/_pkg_.a -trimpath "$WORK/b038=>" -p io -lang=go1.27 -std -complete -buildid 5GGBiD4IoXQFcTKCqH7O/5GGBiD4IoXQFcTKCqH7O -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b038/importcfg -pack /home/exedev/e1/goroot/src/io/io.go /home/exedev/e1/goroot/src/io/multi.go /home/exedev/e1/goroot/src/io/pipe.go
go tool buildid -w $WORK/b038/_pkg_.a # internal
mkdir -p $WORK/b044/

#
# unicode/utf8
#

echo '# import config' > $WORK/b044/importcfg # internal
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b044/_pkg_.a -trimpath "$WORK/b044=>" -p unicode/utf8 -lang=go1.27 -std -complete -buildid NSMspE_AB9cRPDuPi4Ks/NSMspE_AB9cRPDuPi4Ks -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b044/importcfg -pack /home/exedev/e1/goroot/src/unicode/utf8/utf8.go
go tool buildid -w $WORK/b044/_pkg_.a # internal
mkdir -p $WORK/b043/

#
# path
#

cat >$WORK/b043/importcfg << 'EOF' # internal
# import config
packagefile errors=$WORK/b003/_pkg_.a
packagefile internal/bytealg=$WORK/b010/_pkg_.a
packagefile unicode/utf8=$WORK/b044/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b043/_pkg_.a -trimpath "$WORK/b043=>" -p path -lang=go1.27 -std -complete -buildid D3ihfESChZHNZGBdieQv/D3ihfESChZHNZGBdieQv -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b043/importcfg -pack /home/exedev/e1/goroot/src/path/match.go /home/exedev/e1/goroot/src/path/path.go
go tool buildid -w $WORK/b043/_pkg_.a # internal
mkdir -p $WORK/b046/

#
# cmp
#

echo '# import config' > $WORK/b046/importcfg # internal
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b046/_pkg_.a -trimpath "$WORK/b046=>" -p cmp -lang=go1.27 -std -complete -buildid aVqp2tvNVDgkVrfNOWOU/aVqp2tvNVDgkVrfNOWOU -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b046/importcfg -pack /home/exedev/e1/goroot/src/cmp/cmp.go
go tool buildid -w $WORK/b046/_pkg_.a # internal
mkdir -p $WORK/b047/

#
# iter
#

cat >$WORK/b047/importcfg << 'EOF' # internal
# import config
packagefile internal/race=$WORK/b027/_pkg_.a
packagefile runtime=$WORK/b009/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b047/_pkg_.a -trimpath "$WORK/b047=>" -p iter -lang=go1.27 -std -complete -buildid 4ZQwa5bHI1OSqtH83FEC/4ZQwa5bHI1OSqtH83FEC -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b047/importcfg -pack /home/exedev/e1/goroot/src/iter/iter.go
go tool buildid -w $WORK/b047/_pkg_.a # internal
mkdir -p $WORK/b045/

#
# slices
#

cat >$WORK/b045/importcfg << 'EOF' # internal
# import config
packagefile cmp=$WORK/b046/_pkg_.a
packagefile iter=$WORK/b047/_pkg_.a
packagefile math/bits=$WORK/b031/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b045/_pkg_.a -trimpath "$WORK/b045=>" -p slices -lang=go1.27 -std -complete -buildid 72OYAzUn6Mm11bu0sd7U/72OYAzUn6Mm11bu0sd7U -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b045/importcfg -pack /home/exedev/e1/goroot/src/slices/iter.go /home/exedev/e1/goroot/src/slices/slices.go /home/exedev/e1/goroot/src/slices/sort.go /home/exedev/e1/goroot/src/slices/zsortanyfunc.go /home/exedev/e1/goroot/src/slices/zsortordered.go
go tool buildid -w $WORK/b045/_pkg_.a # internal
mkdir -p $WORK/b049/

#
# syscall
#

cat >$WORK/b049/importcfg << 'EOF' # internal
# import config
packagefile errors=$WORK/b003/_pkg_.a
packagefile internal/bytealg=$WORK/b010/_pkg_.a
packagefile internal/byteorder=$WORK/b012/_pkg_.a
packagefile internal/goarch=$WORK/b006/_pkg_.a
packagefile internal/oserror=$WORK/b037/_pkg_.a
packagefile internal/strconv=$WORK/b030/_pkg_.a
packagefile internal/stringslite=$WORK/b032/_pkg_.a
packagefile runtime=$WORK/b009/_pkg_.a
packagefile structs=$WORK/b034/_pkg_.a
packagefile sync=$WORK/b039/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b049/_pkg_.a -trimpath "$WORK/b049=>" -p syscall -lang=go1.27 -std -buildid LoPca-NmX4h9SO41f3Ix/LoPca-NmX4h9SO41f3Ix -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b049/importcfg -pack /home/exedev/e1/goroot/src/syscall/dirent.go /home/exedev/e1/goroot/src/syscall/env_unix.go /home/exedev/e1/goroot/src/syscall/fs_wasip1.go /home/exedev/e1/goroot/src/syscall/net.go /home/exedev/e1/goroot/src/syscall/net_fake.go /home/exedev/e1/goroot/src/syscall/net_wasip1.go /home/exedev/e1/goroot/src/syscall/os_wasip1.go /home/exedev/e1/goroot/src/syscall/syscall.go /home/exedev/e1/goroot/src/syscall/syscall_wasip1.go /home/exedev/e1/goroot/src/syscall/tables_wasip1.go /home/exedev/e1/goroot/src/syscall/time_nofake.go /home/exedev/e1/goroot/src/syscall/timestruct.go
go tool buildid -w $WORK/b049/_pkg_.a # internal
mkdir -p $WORK/b048/

#
# time
#

cat >$WORK/b048/importcfg << 'EOF' # internal
# import config
packagefile errors=$WORK/b003/_pkg_.a
packagefile internal/bytealg=$WORK/b010/_pkg_.a
packagefile internal/stringslite=$WORK/b032/_pkg_.a
packagefile math/bits=$WORK/b031/_pkg_.a
packagefile runtime=$WORK/b009/_pkg_.a
packagefile sync=$WORK/b039/_pkg_.a
packagefile syscall=$WORK/b049/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b048/_pkg_.a -trimpath "$WORK/b048=>" -p time -lang=go1.27 -std -buildid zhrOuipVht_IOcC4ezWN/zhrOuipVht_IOcC4ezWN -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b048/importcfg -pack /home/exedev/e1/goroot/src/time/format.go /home/exedev/e1/goroot/src/time/format_rfc3339.go /home/exedev/e1/goroot/src/time/sleep.go /home/exedev/e1/goroot/src/time/sys_unix.go /home/exedev/e1/goroot/src/time/tick.go /home/exedev/e1/goroot/src/time/time.go /home/exedev/e1/goroot/src/time/zoneinfo.go /home/exedev/e1/goroot/src/time/zoneinfo_goroot.go /home/exedev/e1/goroot/src/time/zoneinfo_read.go /home/exedev/e1/goroot/src/time/zoneinfo_wasip1.go
go tool buildid -w $WORK/b048/_pkg_.a # internal
mkdir -p $WORK/b036/

#
# io/fs
#

cat >$WORK/b036/importcfg << 'EOF' # internal
# import config
packagefile errors=$WORK/b003/_pkg_.a
packagefile internal/bytealg=$WORK/b010/_pkg_.a
packagefile internal/oserror=$WORK/b037/_pkg_.a
packagefile io=$WORK/b038/_pkg_.a
packagefile path=$WORK/b043/_pkg_.a
packagefile slices=$WORK/b045/_pkg_.a
packagefile time=$WORK/b048/_pkg_.a
packagefile unicode/utf8=$WORK/b044/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b036/_pkg_.a -trimpath "$WORK/b036=>" -p io/fs -lang=go1.27 -std -complete -buildid WB9r36iyAEgKaQTH2gvo/WB9r36iyAEgKaQTH2gvo -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b036/importcfg -pack /home/exedev/e1/goroot/src/io/fs/format.go /home/exedev/e1/goroot/src/io/fs/fs.go /home/exedev/e1/goroot/src/io/fs/glob.go /home/exedev/e1/goroot/src/io/fs/readdir.go /home/exedev/e1/goroot/src/io/fs/readfile.go /home/exedev/e1/goroot/src/io/fs/readlink.go /home/exedev/e1/goroot/src/io/fs/stat.go /home/exedev/e1/goroot/src/io/fs/sub.go /home/exedev/e1/goroot/src/io/fs/walk.go
go tool buildid -w $WORK/b036/_pkg_.a # internal
mkdir -p $WORK/b035/

#
# internal/filepathlite
#

cat >$WORK/b035/importcfg << 'EOF' # internal
# import config
packagefile errors=$WORK/b003/_pkg_.a
packagefile internal/bytealg=$WORK/b010/_pkg_.a
packagefile internal/stringslite=$WORK/b032/_pkg_.a
packagefile io/fs=$WORK/b036/_pkg_.a
packagefile slices=$WORK/b045/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b035/_pkg_.a -trimpath "$WORK/b035=>" -p internal/filepathlite -lang=go1.27 -std -complete -buildid fFXYEzvDrXITelv8hpcn/fFXYEzvDrXITelv8hpcn -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b035/importcfg -pack /home/exedev/e1/goroot/src/internal/filepathlite/path.go /home/exedev/e1/goroot/src/internal/filepathlite/path_nonwindows.go /home/exedev/e1/goroot/src/internal/filepathlite/path_unix.go
go tool buildid -w $WORK/b035/_pkg_.a # internal
mkdir -p $WORK/b051/

#
# internal/syscall/unix
#

cat >$WORK/b051/importcfg << 'EOF' # internal
# import config
packagefile syscall=$WORK/b049/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b051/_pkg_.a -trimpath "$WORK/b051=>" -p internal/syscall/unix -lang=go1.27 -std -complete -buildid H19T6bpthgMW_YmheGSp/H19T6bpthgMW_YmheGSp -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b051/importcfg -pack /home/exedev/e1/goroot/src/internal/syscall/unix/at_wasip1.go /home/exedev/e1/goroot/src/internal/syscall/unix/constants.go /home/exedev/e1/goroot/src/internal/syscall/unix/fcntl_wasip1.go /home/exedev/e1/goroot/src/internal/syscall/unix/kernel_version_ge.go /home/exedev/e1/goroot/src/internal/syscall/unix/kernel_version_other.go /home/exedev/e1/goroot/src/internal/syscall/unix/net_wasip1.go /home/exedev/e1/goroot/src/internal/syscall/unix/nofollow_posix.go /home/exedev/e1/goroot/src/internal/syscall/unix/nonblocking_wasip1.go /home/exedev/e1/goroot/src/internal/syscall/unix/syscall.go /home/exedev/e1/goroot/src/internal/syscall/unix/utimes_wasip1.go
go tool buildid -w $WORK/b051/_pkg_.a # internal
mkdir -p $WORK/b050/

#
# internal/poll
#

cat >$WORK/b050/importcfg << 'EOF' # internal
# import config
packagefile errors=$WORK/b003/_pkg_.a
packagefile internal/byteorder=$WORK/b012/_pkg_.a
packagefile internal/strconv=$WORK/b030/_pkg_.a
packagefile internal/syscall/unix=$WORK/b051/_pkg_.a
packagefile io=$WORK/b038/_pkg_.a
packagefile sync=$WORK/b039/_pkg_.a
packagefile sync/atomic=$WORK/b041/_pkg_.a
packagefile syscall=$WORK/b049/_pkg_.a
packagefile time=$WORK/b048/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b050/_pkg_.a -trimpath "$WORK/b050=>" -p internal/poll -lang=go1.27 -std -buildid EPjCFUXH2oSMWqF6owdg/EPjCFUXH2oSMWqF6owdg -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b050/importcfg -pack /home/exedev/e1/goroot/src/internal/poll/errno_unix.go /home/exedev/e1/goroot/src/internal/poll/fd.go /home/exedev/e1/goroot/src/internal/poll/fd_fsync_posix.go /home/exedev/e1/goroot/src/internal/poll/fd_mutex.go /home/exedev/e1/goroot/src/internal/poll/fd_poll_runtime.go /home/exedev/e1/goroot/src/internal/poll/fd_posix.go /home/exedev/e1/goroot/src/internal/poll/fd_unix.go /home/exedev/e1/goroot/src/internal/poll/fd_wasip1.go /home/exedev/e1/goroot/src/internal/poll/fstatat_unix.go /home/exedev/e1/goroot/src/internal/poll/hook_unix.go /home/exedev/e1/goroot/src/internal/poll/sendfile.go /home/exedev/e1/goroot/src/internal/poll/sys_cloexec.go
go tool buildid -w $WORK/b050/_pkg_.a # internal
mkdir -p $WORK/b052/

#
# internal/syscall/execenv
#

cat >$WORK/b052/importcfg << 'EOF' # internal
# import config
packagefile syscall=$WORK/b049/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b052/_pkg_.a -trimpath "$WORK/b052=>" -p internal/syscall/execenv -lang=go1.27 -std -complete -buildid iVYj6CRGZ17bmsLO-bu9/iVYj6CRGZ17bmsLO-bu9 -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b052/importcfg -pack /home/exedev/e1/goroot/src/internal/syscall/execenv/execenv_default.go
go tool buildid -w $WORK/b052/_pkg_.a # internal
mkdir -p $WORK/b053/

#
# internal/testlog
#

cat >$WORK/b053/importcfg << 'EOF' # internal
# import config
packagefile sync=$WORK/b039/_pkg_.a
packagefile sync/atomic=$WORK/b041/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b053/_pkg_.a -trimpath "$WORK/b053=>" -p internal/testlog -lang=go1.27 -std -complete -buildid 4Zx9GrMuasPgf5wKuQzg/4Zx9GrMuasPgf5wKuQzg -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b053/importcfg -pack /home/exedev/e1/goroot/src/internal/testlog/exit.go /home/exedev/e1/goroot/src/internal/testlog/log.go
go tool buildid -w $WORK/b053/_pkg_.a # internal
mkdir -p $WORK/b002/

#
# os
#

cat >$WORK/b002/importcfg << 'EOF' # internal
# import config
packagefile errors=$WORK/b003/_pkg_.a
packagefile internal/bytealg=$WORK/b010/_pkg_.a
packagefile internal/byteorder=$WORK/b012/_pkg_.a
packagefile internal/filepathlite=$WORK/b035/_pkg_.a
packagefile internal/goarch=$WORK/b006/_pkg_.a
packagefile internal/poll=$WORK/b050/_pkg_.a
packagefile internal/strconv=$WORK/b030/_pkg_.a
packagefile internal/stringslite=$WORK/b032/_pkg_.a
packagefile internal/syscall/execenv=$WORK/b052/_pkg_.a
packagefile internal/syscall/unix=$WORK/b051/_pkg_.a
packagefile internal/testlog=$WORK/b053/_pkg_.a
packagefile io=$WORK/b038/_pkg_.a
packagefile io/fs=$WORK/b036/_pkg_.a
packagefile runtime=$WORK/b009/_pkg_.a
packagefile slices=$WORK/b045/_pkg_.a
packagefile sync=$WORK/b039/_pkg_.a
packagefile sync/atomic=$WORK/b041/_pkg_.a
packagefile syscall=$WORK/b049/_pkg_.a
packagefile time=$WORK/b048/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b002/_pkg_.a -trimpath "$WORK/b002=>" -p os -lang=go1.27 -std -buildid rHjDD0Vk6DaCQq2Ks963/rHjDD0Vk6DaCQq2Ks963 -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b002/importcfg -pack /home/exedev/e1/goroot/src/os/dir.go /home/exedev/e1/goroot/src/os/dir_unix.go /home/exedev/e1/goroot/src/os/dirent_wasip1.go /home/exedev/e1/goroot/src/os/eloop_other.go /home/exedev/e1/goroot/src/os/env.go /home/exedev/e1/goroot/src/os/error.go /home/exedev/e1/goroot/src/os/error_errno.go /home/exedev/e1/goroot/src/os/exec.go /home/exedev/e1/goroot/src/os/exec_nohandle.go /home/exedev/e1/goroot/src/os/exec_posix.go /home/exedev/e1/goroot/src/os/exec_unix.go /home/exedev/e1/goroot/src/os/executable.go /home/exedev/e1/goroot/src/os/executable_wasm.go /home/exedev/e1/goroot/src/os/file.go /home/exedev/e1/goroot/src/os/file_open_wasip1.go /home/exedev/e1/goroot/src/os/file_posix.go /home/exedev/e1/goroot/src/os/file_unix.go /home/exedev/e1/goroot/src/os/file_wasip1.go /home/exedev/e1/goroot/src/os/getwd.go /home/exedev/e1/goroot/src/os/path.go /home/exedev/e1/goroot/src/os/path_unix.go /home/exedev/e1/goroot/src/os/pidfd_other.go /home/exedev/e1/goroot/src/os/pipe_wasm.go /home/exedev/e1/goroot/src/os/proc.go /home/exedev/e1/goroot/src/os/rawconn.go /home/exedev/e1/goroot/src/os/removeall_at.go /home/exedev/e1/goroot/src/os/removeall_unix.go /home/exedev/e1/goroot/src/os/root.go /home/exedev/e1/goroot/src/os/root_nonwindows.go /home/exedev/e1/goroot/src/os/root_openat.go /home/exedev/e1/goroot/src/os/root_unix.go /home/exedev/e1/goroot/src/os/stat.go /home/exedev/e1/goroot/src/os/stat_unix.go /home/exedev/e1/goroot/src/os/stat_wasip1.go /home/exedev/e1/goroot/src/os/statat.go /home/exedev/e1/goroot/src/os/statat_unix.go /home/exedev/e1/goroot/src/os/sticky_bsd.go /home/exedev/e1/goroot/src/os/sys.go /home/exedev/e1/goroot/src/os/sys_bsd.go /home/exedev/e1/goroot/src/os/sys_wasip1.go /home/exedev/e1/goroot/src/os/tempfile.go /home/exedev/e1/goroot/src/os/types.go /home/exedev/e1/goroot/src/os/types_unix.go /home/exedev/e1/goroot/src/os/wait_unimp.go /home/exedev/e1/goroot/src/os/zero_copy_posix.go /home/exedev/e1/goroot/src/os/zero_copy_stub.go
go tool buildid -w $WORK/b002/_pkg_.a # internal
mkdir -p $WORK/b055/

#
# math
#

echo -n > $WORK/b055/go_asm.h # internal
cd /home/exedev/e1/goroot/src/math
/home/exedev/e1/goroot/pkg/tool/linux_amd64/asm -p math -trimpath "$WORK/b055=>" -I $WORK/b055/ -I /home/exedev/e1/goroot/pkg/include -D GOOS_wasip1 -D GOARCH_wasm -std -gensymabis -o $WORK/b055/symabis ./floor_wasm.s
cat >$WORK/b055/importcfg << 'EOF' # internal
# import config
packagefile math/bits=$WORK/b031/_pkg_.a
EOF
cd /home/exedev/e1/tdemo
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b055/_pkg_.a -trimpath "$WORK/b055=>" -p math -lang=go1.27 -std -buildid 3ilY946KU-t4n8uF_fPX/3ilY946KU-t4n8uF_fPX -dwarf=false -goversion go1.27.2 -symabis $WORK/b055/symabis -c=2 -nolocalimports -importcfg $WORK/b055/importcfg -pack -asmhdr $WORK/b055/go_asm.h /home/exedev/e1/goroot/src/math/abs.go /home/exedev/e1/goroot/src/math/acosh.go /home/exedev/e1/goroot/src/math/asin.go /home/exedev/e1/goroot/src/math/asinh.go /home/exedev/e1/goroot/src/math/atan.go /home/exedev/e1/goroot/src/math/atan2.go /home/exedev/e1/goroot/src/math/atanh.go /home/exedev/e1/goroot/src/math/bits.go /home/exedev/e1/goroot/src/math/cbrt.go /home/exedev/e1/goroot/src/math/const.go /home/exedev/e1/goroot/src/math/copysign.go /home/exedev/e1/goroot/src/math/dim.go /home/exedev/e1/goroot/src/math/dim_noasm.go /home/exedev/e1/goroot/src/math/erf.go /home/exedev/e1/goroot/src/math/erfinv.go /home/exedev/e1/goroot/src/math/exp.go /home/exedev/e1/goroot/src/math/exp2_noasm.go /home/exedev/e1/goroot/src/math/exp_noasm.go /home/exedev/e1/goroot/src/math/expm1.go /home/exedev/e1/goroot/src/math/floor.go /home/exedev/e1/goroot/src/math/floor_asm.go /home/exedev/e1/goroot/src/math/fma.go /home/exedev/e1/goroot/src/math/frexp.go /home/exedev/e1/goroot/src/math/gamma.go /home/exedev/e1/goroot/src/math/hypot.go /home/exedev/e1/goroot/src/math/hypot_noasm.go /home/exedev/e1/goroot/src/math/j0.go /home/exedev/e1/goroot/src/math/j1.go /home/exedev/e1/goroot/src/math/jn.go /home/exedev/e1/goroot/src/math/ldexp.go /home/exedev/e1/goroot/src/math/lgamma.go /home/exedev/e1/goroot/src/math/log.go /home/exedev/e1/goroot/src/math/log10.go /home/exedev/e1/goroot/src/math/log1p.go /home/exedev/e1/goroot/src/math/log_stub.go /home/exedev/e1/goroot/src/math/logb.go /home/exedev/e1/goroot/src/math/mod.go /home/exedev/e1/goroot/src/math/modf.go /home/exedev/e1/goroot/src/math/nextafter.go /home/exedev/e1/goroot/src/math/pow.go /home/exedev/e1/goroot/src/math/pow10.go /home/exedev/e1/goroot/src/math/remainder.go /home/exedev/e1/goroot/src/math/signbit.go /home/exedev/e1/goroot/src/math/sin.go /home/exedev/e1/goroot/src/math/sincos.go /home/exedev/e1/goroot/src/math/sinh.go /home/exedev/e1/goroot/src/math/sqrt.go /home/exedev/e1/goroot/src/math/stubs.go /home/exedev/e1/goroot/src/math/tan.go /home/exedev/e1/goroot/src/math/tanh.go /home/exedev/e1/goroot/src/math/trig_reduce.go /home/exedev/e1/goroot/src/math/unsafe.go
cd /home/exedev/e1/goroot/src/math
/home/exedev/e1/goroot/pkg/tool/linux_amd64/asm -p math -trimpath "$WORK/b055=>" -I $WORK/b055/ -I /home/exedev/e1/goroot/pkg/include -D GOOS_wasip1 -D GOARCH_wasm -std -o $WORK/b055/floor_wasm.o ./floor_wasm.s
go tool pack r $WORK/b055/_pkg_.a $WORK/b055/floor_wasm.o # internal
go tool buildid -w $WORK/b055/_pkg_.a # internal
mkdir -p $WORK/b056/

#
# strconv
#

cat >$WORK/b056/importcfg << 'EOF' # internal
# import config
packagefile errors=$WORK/b003/_pkg_.a
packagefile internal/bytealg=$WORK/b010/_pkg_.a
packagefile internal/strconv=$WORK/b030/_pkg_.a
packagefile internal/stringslite=$WORK/b032/_pkg_.a
packagefile unicode/utf8=$WORK/b044/_pkg_.a
EOF
cd /home/exedev/e1/tdemo
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b056/_pkg_.a -trimpath "$WORK/b056=>" -p strconv -lang=go1.27 -std -complete -buildid eiuEHUsWHHiiNtLRDMO4/eiuEHUsWHHiiNtLRDMO4 -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b056/importcfg -pack /home/exedev/e1/goroot/src/strconv/bytealg.go /home/exedev/e1/goroot/src/strconv/doc.go /home/exedev/e1/goroot/src/strconv/isprint.go /home/exedev/e1/goroot/src/strconv/number.go /home/exedev/e1/goroot/src/strconv/quote.go
go tool buildid -w $WORK/b056/_pkg_.a # internal
mkdir -p $WORK/b057/

#
# unicode
#

echo '# import config' > $WORK/b057/importcfg # internal
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b057/_pkg_.a -trimpath "$WORK/b057=>" -p unicode -lang=go1.27 -std -complete -buildid jlDMKBlygkIijswQWNt_/jlDMKBlygkIijswQWNt_ -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b057/importcfg -pack /home/exedev/e1/goroot/src/unicode/casetables.go /home/exedev/e1/goroot/src/unicode/digit.go /home/exedev/e1/goroot/src/unicode/graphic.go /home/exedev/e1/goroot/src/unicode/letter.go /home/exedev/e1/goroot/src/unicode/tables.go
go tool buildid -w $WORK/b057/_pkg_.a # internal
mkdir -p $WORK/b054/

#
# reflect
#

echo -n > $WORK/b054/go_asm.h # internal
cd /home/exedev/e1/goroot/src/reflect
/home/exedev/e1/goroot/pkg/tool/linux_amd64/asm -p reflect -trimpath "$WORK/b054=>" -I $WORK/b054/ -I /home/exedev/e1/goroot/pkg/include -D GOOS_wasip1 -D GOARCH_wasm -std -gensymabis -o $WORK/b054/symabis ./asm_wasm.s
cat >$WORK/b054/importcfg << 'EOF' # internal
# import config
packagefile errors=$WORK/b003/_pkg_.a
packagefile internal/abi=$WORK/b005/_pkg_.a
packagefile internal/bytealg=$WORK/b010/_pkg_.a
packagefile internal/goarch=$WORK/b006/_pkg_.a
packagefile internal/goexperiment=$WORK/b016/_pkg_.a
packagefile internal/race=$WORK/b027/_pkg_.a
packagefile internal/runtime/maps=$WORK/b024/_pkg_.a
packagefile internal/runtime/sys=$WORK/b023/_pkg_.a
packagefile internal/strconv=$WORK/b030/_pkg_.a
packagefile internal/unsafeheader=$WORK/b008/_pkg_.a
packagefile iter=$WORK/b047/_pkg_.a
packagefile math=$WORK/b055/_pkg_.a
packagefile runtime=$WORK/b009/_pkg_.a
packagefile strconv=$WORK/b056/_pkg_.a
packagefile sync=$WORK/b039/_pkg_.a
packagefile unicode=$WORK/b057/_pkg_.a
packagefile unicode/utf8=$WORK/b044/_pkg_.a
EOF
cd /home/exedev/e1/tdemo
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b054/_pkg_.a -trimpath "$WORK/b054=>" -p reflect -lang=go1.27 -std -buildid _utVX1Guhj5cGZ7hdFhX/_utVX1Guhj5cGZ7hdFhX -dwarf=false -goversion go1.27.2 -symabis $WORK/b054/symabis -c=2 -nolocalimports -importcfg $WORK/b054/importcfg -pack -asmhdr $WORK/b054/go_asm.h /home/exedev/e1/goroot/src/reflect/abi.go /home/exedev/e1/goroot/src/reflect/badlinkname.go /home/exedev/e1/goroot/src/reflect/deepequal.go /home/exedev/e1/goroot/src/reflect/float32reg_generic.go /home/exedev/e1/goroot/src/reflect/iter.go /home/exedev/e1/goroot/src/reflect/makefunc.go /home/exedev/e1/goroot/src/reflect/map.go /home/exedev/e1/goroot/src/reflect/swapper.go /home/exedev/e1/goroot/src/reflect/type.go /home/exedev/e1/goroot/src/reflect/value.go /home/exedev/e1/goroot/src/reflect/visiblefields.go
cd /home/exedev/e1/goroot/src/reflect
/home/exedev/e1/goroot/pkg/tool/linux_amd64/asm -p reflect -trimpath "$WORK/b054=>" -I $WORK/b054/ -I /home/exedev/e1/goroot/pkg/include -D GOOS_wasip1 -D GOARCH_wasm -std -o $WORK/b054/asm_wasm.o ./asm_wasm.s
go tool pack r $WORK/b054/_pkg_.a $WORK/b054/asm_wasm.o # internal
go tool buildid -w $WORK/b054/_pkg_.a # internal
mkdir -p $WORK/b059/

#
# bytes
#

cat >$WORK/b059/importcfg << 'EOF' # internal
# import config
packagefile errors=$WORK/b003/_pkg_.a
packagefile internal/bytealg=$WORK/b010/_pkg_.a
packagefile io=$WORK/b038/_pkg_.a
packagefile iter=$WORK/b047/_pkg_.a
packagefile math/bits=$WORK/b031/_pkg_.a
packagefile unicode=$WORK/b057/_pkg_.a
packagefile unicode/utf8=$WORK/b044/_pkg_.a
EOF
cd /home/exedev/e1/tdemo
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b059/_pkg_.a -trimpath "$WORK/b059=>" -p bytes -lang=go1.27 -std -buildid M-mf6rRzO_l7-Q66iVBT/M-mf6rRzO_l7-Q66iVBT -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b059/importcfg -pack /home/exedev/e1/goroot/src/bytes/buffer.go /home/exedev/e1/goroot/src/bytes/bytes.go /home/exedev/e1/goroot/src/bytes/iter.go /home/exedev/e1/goroot/src/bytes/reader.go
go tool buildid -w $WORK/b059/_pkg_.a # internal
mkdir -p $WORK/b060/

#
# context
#

cat >$WORK/b060/importcfg << 'EOF' # internal
# import config
packagefile errors=$WORK/b003/_pkg_.a
packagefile internal/reflectlite=$WORK/b004/_pkg_.a
packagefile sync=$WORK/b039/_pkg_.a
packagefile sync/atomic=$WORK/b041/_pkg_.a
packagefile time=$WORK/b048/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b060/_pkg_.a -trimpath "$WORK/b060=>" -p context -lang=go1.27 -std -complete -buildid YMxQsIKiubhVl2dOpzCp/YMxQsIKiubhVl2dOpzCp -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b060/importcfg -pack /home/exedev/e1/goroot/src/context/context.go
go tool buildid -w $WORK/b060/_pkg_.a # internal
mkdir -p $WORK/b062/

#
# encoding
#

echo '# import config' > $WORK/b062/importcfg # internal
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b062/_pkg_.a -trimpath "$WORK/b062=>" -p encoding -lang=go1.27 -std -complete -buildid CbrLRRlcbeR-689kut9u/CbrLRRlcbeR-689kut9u -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b062/importcfg -pack /home/exedev/e1/goroot/src/encoding/encoding.go
go tool buildid -w $WORK/b062/_pkg_.a # internal
mkdir -p $WORK/b064/

#
# internal/fmtsort
#

cat >$WORK/b064/importcfg << 'EOF' # internal
# import config
packagefile cmp=$WORK/b046/_pkg_.a
packagefile reflect=$WORK/b054/_pkg_.a
packagefile slices=$WORK/b045/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b064/_pkg_.a -trimpath "$WORK/b064=>" -p internal/fmtsort -lang=go1.27 -std -complete -buildid jr1KxWisZN6H1NAjhoko/jr1KxWisZN6H1NAjhoko -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b064/importcfg -pack /home/exedev/e1/goroot/src/internal/fmtsort/sort.go
go tool buildid -w $WORK/b064/_pkg_.a # internal
mkdir -p $WORK/b063/

#
# fmt
#

cat >$WORK/b063/importcfg << 'EOF' # internal
# import config
packagefile errors=$WORK/b003/_pkg_.a
packagefile internal/fmtsort=$WORK/b064/_pkg_.a
packagefile internal/stringslite=$WORK/b032/_pkg_.a
packagefile io=$WORK/b038/_pkg_.a
packagefile math=$WORK/b055/_pkg_.a
packagefile os=$WORK/b002/_pkg_.a
packagefile reflect=$WORK/b054/_pkg_.a
packagefile slices=$WORK/b045/_pkg_.a
packagefile strconv=$WORK/b056/_pkg_.a
packagefile sync=$WORK/b039/_pkg_.a
packagefile unicode/utf8=$WORK/b044/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b063/_pkg_.a -trimpath "$WORK/b063=>" -p fmt -lang=go1.27 -std -complete -buildid qd89w8Eo-JJ1EzGuffFg/qd89w8Eo-JJ1EzGuffFg -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b063/importcfg -pack /home/exedev/e1/goroot/src/fmt/doc.go /home/exedev/e1/goroot/src/fmt/errors.go /home/exedev/e1/goroot/src/fmt/format.go /home/exedev/e1/goroot/src/fmt/print.go /home/exedev/e1/goroot/src/fmt/scan.go
go tool buildid -w $WORK/b063/_pkg_.a # internal
mkdir -p $WORK/b065/

#
# strings
#

cat >$WORK/b065/importcfg << 'EOF' # internal
# import config
packagefile errors=$WORK/b003/_pkg_.a
packagefile internal/abi=$WORK/b005/_pkg_.a
packagefile internal/bytealg=$WORK/b010/_pkg_.a
packagefile internal/stringslite=$WORK/b032/_pkg_.a
packagefile io=$WORK/b038/_pkg_.a
packagefile iter=$WORK/b047/_pkg_.a
packagefile math/bits=$WORK/b031/_pkg_.a
packagefile sync=$WORK/b039/_pkg_.a
packagefile unicode=$WORK/b057/_pkg_.a
packagefile unicode/utf8=$WORK/b044/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b065/_pkg_.a -trimpath "$WORK/b065=>" -p strings -lang=go1.27 -std -complete -buildid pLVWp_ZK7DLo-gvVMGNm/pLVWp_ZK7DLo-gvVMGNm -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b065/importcfg -pack /home/exedev/e1/goroot/src/strings/builder.go /home/exedev/e1/goroot/src/strings/clone.go /home/exedev/e1/goroot/src/strings/compare.go /home/exedev/e1/goroot/src/strings/iter.go /home/exedev/e1/goroot/src/strings/reader.go /home/exedev/e1/goroot/src/strings/replace.go /home/exedev/e1/goroot/src/strings/search.go /home/exedev/e1/goroot/src/strings/strings.go
go tool buildid -w $WORK/b065/_pkg_.a # internal
mkdir -p $WORK/b061/

#
# flag
#

cat >$WORK/b061/importcfg << 'EOF' # internal
# import config
packagefile encoding=$WORK/b062/_pkg_.a
packagefile errors=$WORK/b003/_pkg_.a
packagefile fmt=$WORK/b063/_pkg_.a
packagefile io=$WORK/b038/_pkg_.a
packagefile os=$WORK/b002/_pkg_.a
packagefile reflect=$WORK/b054/_pkg_.a
packagefile runtime=$WORK/b009/_pkg_.a
packagefile slices=$WORK/b045/_pkg_.a
packagefile strconv=$WORK/b056/_pkg_.a
packagefile strings=$WORK/b065/_pkg_.a
packagefile time=$WORK/b048/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b061/_pkg_.a -trimpath "$WORK/b061=>" -p flag -lang=go1.27 -std -complete -buildid ArWz8A7NOrOF3ZCfz0iQ/ArWz8A7NOrOF3ZCfz0iQ -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b061/importcfg -pack /home/exedev/e1/goroot/src/flag/flag.go
go tool buildid -w $WORK/b061/_pkg_.a # internal
mkdir -p $WORK/b066/

#
# internal/sysinfo
#

cat >$WORK/b066/importcfg << 'EOF' # internal
# import config
packagefile internal/cpu=$WORK/b011/_pkg_.a
packagefile sync=$WORK/b039/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b066/_pkg_.a -trimpath "$WORK/b066=>" -p internal/sysinfo -lang=go1.27 -std -complete -buildid 9sIfJ5u-Gejb3AavdcK2/9sIfJ5u-Gejb3AavdcK2 -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b066/importcfg -pack /home/exedev/e1/goroot/src/internal/sysinfo/cpuinfo_stub.go /home/exedev/e1/goroot/src/internal/sysinfo/sysinfo.go
go tool buildid -w $WORK/b066/_pkg_.a # internal
mkdir -p $WORK/b069/

#
# internal/bisect
#

cat >$WORK/b069/importcfg << 'EOF' # internal
# import config
packagefile runtime=$WORK/b009/_pkg_.a
packagefile sync=$WORK/b039/_pkg_.a
packagefile sync/atomic=$WORK/b041/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b069/_pkg_.a -trimpath "$WORK/b069=>" -p internal/bisect -lang=go1.27 -std -complete -buildid k7wIkQI-SHiDImIC6irr/k7wIkQI-SHiDImIC6irr -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b069/importcfg -pack /home/exedev/e1/goroot/src/internal/bisect/bisect.go
go tool buildid -w $WORK/b069/_pkg_.a # internal
mkdir -p $WORK/b068/

#
# internal/godebug
#

cat >$WORK/b068/importcfg << 'EOF' # internal
# import config
packagefile internal/bisect=$WORK/b069/_pkg_.a
packagefile internal/godebugs=$WORK/b015/_pkg_.a
packagefile sync=$WORK/b039/_pkg_.a
packagefile sync/atomic=$WORK/b041/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b068/_pkg_.a -trimpath "$WORK/b068=>" -p internal/godebug -lang=go1.27 -std -complete -buildid FnGFLIiGCI5OMTbPkOfZ/FnGFLIiGCI5OMTbPkOfZ -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b068/importcfg -pack /home/exedev/e1/goroot/src/internal/godebug/godebug.go
go tool buildid -w $WORK/b068/_pkg_.a # internal
mkdir -p $WORK/b067/

#
# math/rand
#

cat >$WORK/b067/importcfg << 'EOF' # internal
# import config
packagefile internal/godebug=$WORK/b068/_pkg_.a
packagefile math=$WORK/b055/_pkg_.a
packagefile sync=$WORK/b039/_pkg_.a
packagefile sync/atomic=$WORK/b041/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b067/_pkg_.a -trimpath "$WORK/b067=>" -p math/rand -lang=go1.27 -std -complete -buildid -zt-fyigJhs00EL56I55/-zt-fyigJhs00EL56I55 -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b067/importcfg -pack /home/exedev/e1/goroot/src/math/rand/exp.go /home/exedev/e1/goroot/src/math/rand/normal.go /home/exedev/e1/goroot/src/math/rand/rand.go /home/exedev/e1/goroot/src/math/rand/rng.go /home/exedev/e1/goroot/src/math/rand/zipf.go
go tool buildid -w $WORK/b067/_pkg_.a # internal
mkdir -p $WORK/b070/

#
# path/filepath
#

cat >$WORK/b070/importcfg << 'EOF' # internal
# import config
packagefile errors=$WORK/b003/_pkg_.a
packagefile internal/bytealg=$WORK/b010/_pkg_.a
packagefile internal/filepathlite=$WORK/b035/_pkg_.a
packagefile io/fs=$WORK/b036/_pkg_.a
packagefile os=$WORK/b002/_pkg_.a
packagefile runtime=$WORK/b009/_pkg_.a
packagefile slices=$WORK/b045/_pkg_.a
packagefile strings=$WORK/b065/_pkg_.a
packagefile syscall=$WORK/b049/_pkg_.a
packagefile unicode/utf8=$WORK/b044/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b070/_pkg_.a -trimpath "$WORK/b070=>" -p path/filepath -lang=go1.27 -std -complete -buildid YVMu5sqdPzekRRI8V7OX/YVMu5sqdPzekRRI8V7OX -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b070/importcfg -pack /home/exedev/e1/goroot/src/path/filepath/match.go /home/exedev/e1/goroot/src/path/filepath/path.go /home/exedev/e1/goroot/src/path/filepath/path_unix.go /home/exedev/e1/goroot/src/path/filepath/symlink.go /home/exedev/e1/goroot/src/path/filepath/symlink_unix.go
go tool buildid -w $WORK/b070/_pkg_.a # internal
mkdir -p $WORK/b071/

#
# runtime/debug
#

echo -n > $WORK/b071/go_asm.h # internal
cd /home/exedev/e1/goroot/src/runtime/debug
/home/exedev/e1/goroot/pkg/tool/linux_amd64/asm -p runtime/debug -trimpath "$WORK/b071=>" -I $WORK/b071/ -I /home/exedev/e1/goroot/pkg/include -D GOOS_wasip1 -D GOARCH_wasm -std -gensymabis -o $WORK/b071/symabis ./debug.s
cat >$WORK/b071/importcfg << 'EOF' # internal
# import config
packagefile fmt=$WORK/b063/_pkg_.a
packagefile internal/poll=$WORK/b050/_pkg_.a
packagefile os=$WORK/b002/_pkg_.a
packagefile runtime=$WORK/b009/_pkg_.a
packagefile slices=$WORK/b045/_pkg_.a
packagefile strconv=$WORK/b056/_pkg_.a
packagefile strings=$WORK/b065/_pkg_.a
packagefile time=$WORK/b048/_pkg_.a
EOF
cd /home/exedev/e1/tdemo
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b071/_pkg_.a -trimpath "$WORK/b071=>" -p runtime/debug -lang=go1.27 -std -buildid jYjCZr-2PssPrfCcsl26/jYjCZr-2PssPrfCcsl26 -dwarf=false -goversion go1.27.2 -symabis $WORK/b071/symabis -c=2 -nolocalimports -importcfg $WORK/b071/importcfg -pack -asmhdr $WORK/b071/go_asm.h /home/exedev/e1/goroot/src/runtime/debug/garbage.go /home/exedev/e1/goroot/src/runtime/debug/mod.go /home/exedev/e1/goroot/src/runtime/debug/stack.go /home/exedev/e1/goroot/src/runtime/debug/stubs.go
cd /home/exedev/e1/goroot/src/runtime/debug
/home/exedev/e1/goroot/pkg/tool/linux_amd64/asm -p runtime/debug -trimpath "$WORK/b071=>" -I $WORK/b071/ -I /home/exedev/e1/goroot/pkg/include -D GOOS_wasip1 -D GOARCH_wasm -std -o $WORK/b071/debug.o ./debug.s
go tool pack r $WORK/b071/_pkg_.a $WORK/b071/debug.o # internal
go tool buildid -w $WORK/b071/_pkg_.a # internal
mkdir -p $WORK/b072/

#
# runtime/trace
#

cat >$WORK/b072/importcfg << 'EOF' # internal
# import config
packagefile context=$WORK/b060/_pkg_.a
packagefile errors=$WORK/b003/_pkg_.a
packagefile fmt=$WORK/b063/_pkg_.a
packagefile internal/trace/tracev2=$WORK/b033/_pkg_.a
packagefile io=$WORK/b038/_pkg_.a
packagefile runtime=$WORK/b009/_pkg_.a
packagefile slices=$WORK/b045/_pkg_.a
packagefile sync=$WORK/b039/_pkg_.a
packagefile sync/atomic=$WORK/b041/_pkg_.a
packagefile time=$WORK/b048/_pkg_.a
EOF
cd /home/exedev/e1/tdemo
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b072/_pkg_.a -trimpath "$WORK/b072=>" -p runtime/trace -lang=go1.27 -std -buildid 42Jt5AnxRb-0zCy1y1gk/42Jt5AnxRb-0zCy1y1gk -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b072/importcfg -pack /home/exedev/e1/goroot/src/runtime/trace/annotation.go /home/exedev/e1/goroot/src/runtime/trace/batch.go /home/exedev/e1/goroot/src/runtime/trace/encoding.go /home/exedev/e1/goroot/src/runtime/trace/flightrecorder.go /home/exedev/e1/goroot/src/runtime/trace/recorder.go /home/exedev/e1/goroot/src/runtime/trace/subscribe.go /home/exedev/e1/goroot/src/runtime/trace/trace.go
go tool buildid -w $WORK/b072/_pkg_.a # internal
mkdir -p $WORK/b058/

#
# testing
#

cat >$WORK/b058/importcfg << 'EOF' # internal
# import config
packagefile bytes=$WORK/b059/_pkg_.a
packagefile context=$WORK/b060/_pkg_.a
packagefile errors=$WORK/b003/_pkg_.a
packagefile flag=$WORK/b061/_pkg_.a
packagefile fmt=$WORK/b063/_pkg_.a
packagefile internal/race=$WORK/b027/_pkg_.a
packagefile internal/sysinfo=$WORK/b066/_pkg_.a
packagefile io=$WORK/b038/_pkg_.a
packagefile math=$WORK/b055/_pkg_.a
packagefile math/rand=$WORK/b067/_pkg_.a
packagefile os=$WORK/b002/_pkg_.a
packagefile path/filepath=$WORK/b070/_pkg_.a
packagefile reflect=$WORK/b054/_pkg_.a
packagefile runtime=$WORK/b009/_pkg_.a
packagefile runtime/debug=$WORK/b071/_pkg_.a
packagefile runtime/trace=$WORK/b072/_pkg_.a
packagefile slices=$WORK/b045/_pkg_.a
packagefile strconv=$WORK/b056/_pkg_.a
packagefile strings=$WORK/b065/_pkg_.a
packagefile sync=$WORK/b039/_pkg_.a
packagefile sync/atomic=$WORK/b041/_pkg_.a
packagefile time=$WORK/b048/_pkg_.a
packagefile unicode=$WORK/b057/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b058/_pkg_.a -trimpath "$WORK/b058=>" -p testing -lang=go1.27 -std -complete -buildid faYJYiqGym8jW9-RHeth/faYJYiqGym8jW9-RHeth -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b058/importcfg -pack /home/exedev/e1/goroot/src/testing/allocs.go /home/exedev/e1/goroot/src/testing/benchmark.go /home/exedev/e1/goroot/src/testing/cover.go /home/exedev/e1/goroot/src/testing/example.go /home/exedev/e1/goroot/src/testing/fuzz.go /home/exedev/e1/goroot/src/testing/match.go /home/exedev/e1/goroot/src/testing/newcover.go /home/exedev/e1/goroot/src/testing/run_example_wasm.go /home/exedev/e1/goroot/src/testing/testing.go /home/exedev/e1/goroot/src/testing/testing_other.go
go tool buildid -w $WORK/b058/_pkg_.a # internal
mkdir -p $WORK/b074/

#
# bufio
#

cat >$WORK/b074/importcfg << 'EOF' # internal
# import config
packagefile bytes=$WORK/b059/_pkg_.a
packagefile errors=$WORK/b003/_pkg_.a
packagefile io=$WORK/b038/_pkg_.a
packagefile strings=$WORK/b065/_pkg_.a
packagefile unicode/utf8=$WORK/b044/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b074/_pkg_.a -trimpath "$WORK/b074=>" -p bufio -lang=go1.27 -std -complete -buildid i5NEsUteEx0gok23eM-N/i5NEsUteEx0gok23eM-N -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b074/importcfg -pack /home/exedev/e1/goroot/src/bufio/bufio.go /home/exedev/e1/goroot/src/bufio/scan.go
go tool buildid -w $WORK/b074/_pkg_.a # internal
mkdir -p $WORK/b078/

#
# hash
#

cat >$WORK/b078/importcfg << 'EOF' # internal
# import config
packagefile io=$WORK/b038/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b078/_pkg_.a -trimpath "$WORK/b078=>" -p hash -lang=go1.27 -std -complete -buildid nnHG6eXkuGEOUIi6JU3Y/nnHG6eXkuGEOUIi6JU3Y -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b078/importcfg -pack /home/exedev/e1/goroot/src/hash/hash.go
go tool buildid -w $WORK/b078/_pkg_.a # internal
mkdir -p $WORK/b077/

#
# crypto
#

cat >$WORK/b077/importcfg << 'EOF' # internal
# import config
packagefile hash=$WORK/b078/_pkg_.a
packagefile io=$WORK/b038/_pkg_.a
packagefile strconv=$WORK/b056/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b077/_pkg_.a -trimpath "$WORK/b077=>" -p crypto -lang=go1.27 -std -complete -buildid dv0aY5DtASzkZ3VvSklc/dv0aY5DtASzkZ3VvSklc -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b077/importcfg -pack /home/exedev/e1/goroot/src/crypto/crypto.go
go tool buildid -w $WORK/b077/_pkg_.a # internal
mkdir -p $WORK/b083/

#
# crypto/internal/fips140deps/godebug
#

cat >$WORK/b083/importcfg << 'EOF' # internal
# import config
packagefile internal/godebug=$WORK/b068/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b083/_pkg_.a -trimpath "$WORK/b083=>" -p crypto/internal/fips140deps/godebug -lang=go1.27 -std -complete -buildid Kap2r2GNP7pg0YCafESl/Kap2r2GNP7pg0YCafESl -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b083/importcfg -pack /home/exedev/e1/goroot/src/crypto/internal/fips140deps/godebug/godebug.go
go tool buildid -w $WORK/b083/_pkg_.a # internal
mkdir -p $WORK/b082/

#
# crypto/internal/fips140
#

cat >$WORK/b082/importcfg << 'EOF' # internal
# import config
packagefile crypto/internal/fips140deps/godebug=$WORK/b083/_pkg_.a
packagefile errors=$WORK/b003/_pkg_.a
packagefile runtime=$WORK/b009/_pkg_.a
packagefile strings=$WORK/b065/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b082/_pkg_.a -trimpath "$WORK/b082=>" -p crypto/internal/fips140 -lang=go1.27 -std -complete -buildid JBECSY2yDykfF2xbjMSt/JBECSY2yDykfF2xbjMSt -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b082/importcfg -pack /home/exedev/e1/goroot/src/crypto/internal/fips140/cast.go /home/exedev/e1/goroot/src/crypto/internal/fips140/fips140.go /home/exedev/e1/goroot/src/crypto/internal/fips140/indicator.go /home/exedev/e1/goroot/src/crypto/internal/fips140/notasan.go /home/exedev/e1/goroot/src/crypto/internal/fips140/notboring.go /home/exedev/e1/goroot/src/crypto/internal/fips140/notpurego.go
go tool buildid -w $WORK/b082/_pkg_.a # internal
mkdir -p $WORK/b084/

#
# crypto/internal/fips140/alias
#

echo '# import config' > $WORK/b084/importcfg # internal
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b084/_pkg_.a -trimpath "$WORK/b084=>" -p crypto/internal/fips140/alias -lang=go1.27 -std -complete -buildid dRr7e0JvBRWdjfkQIpXO/dRr7e0JvBRWdjfkQIpXO -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b084/importcfg -pack /home/exedev/e1/goroot/src/crypto/internal/fips140/alias/alias.go
go tool buildid -w $WORK/b084/_pkg_.a # internal
mkdir -p $WORK/b088/

#
# crypto/internal/fips140deps/byteorder
#

cat >$WORK/b088/importcfg << 'EOF' # internal
# import config
packagefile internal/byteorder=$WORK/b012/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b088/_pkg_.a -trimpath "$WORK/b088=>" -p crypto/internal/fips140deps/byteorder -lang=go1.27 -std -complete -buildid ngZIO97VLSKUVDLNe-RF/ngZIO97VLSKUVDLNe-RF -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b088/importcfg -pack /home/exedev/e1/goroot/src/crypto/internal/fips140deps/byteorder/byteorder.go
go tool buildid -w $WORK/b088/_pkg_.a # internal
mkdir -p $WORK/b087/

#
# crypto/internal/fips140/sha256
#

cat >$WORK/b087/importcfg << 'EOF' # internal
# import config
packagefile bytes=$WORK/b059/_pkg_.a
packagefile crypto/internal/fips140=$WORK/b082/_pkg_.a
packagefile crypto/internal/fips140deps/byteorder=$WORK/b088/_pkg_.a
packagefile errors=$WORK/b003/_pkg_.a
packagefile hash=$WORK/b078/_pkg_.a
packagefile math/bits=$WORK/b031/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b087/_pkg_.a -trimpath "$WORK/b087=>" -p crypto/internal/fips140/sha256 -lang=go1.27 -std -complete -buildid fYOjjf0WhUc_62_Vk-nQ/fYOjjf0WhUc_62_Vk-nQ -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b087/importcfg -pack /home/exedev/e1/goroot/src/crypto/internal/fips140/sha256/cast.go /home/exedev/e1/goroot/src/crypto/internal/fips140/sha256/sha256.go /home/exedev/e1/goroot/src/crypto/internal/fips140/sha256/sha256block.go /home/exedev/e1/goroot/src/crypto/internal/fips140/sha256/sha256block_noasm.go
go tool buildid -w $WORK/b087/_pkg_.a # internal
mkdir -p $WORK/b091/

#
# crypto/internal/constanttime
#

echo '# import config' > $WORK/b091/importcfg # internal
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b091/_pkg_.a -trimpath "$WORK/b091=>" -p crypto/internal/constanttime -lang=go1.27 -std -complete -buildid 34KLsG8X6PnzKHGEJhKm/34KLsG8X6PnzKHGEJhKm -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b091/importcfg -pack /home/exedev/e1/goroot/src/crypto/internal/constanttime/constant_time.go
go tool buildid -w $WORK/b091/_pkg_.a # internal
mkdir -p $WORK/b090/

#
# crypto/internal/fips140/subtle
#

cat >$WORK/b090/importcfg << 'EOF' # internal
# import config
packagefile crypto/internal/constanttime=$WORK/b091/_pkg_.a
packagefile crypto/internal/fips140/alias=$WORK/b084/_pkg_.a
packagefile crypto/internal/fips140deps/byteorder=$WORK/b088/_pkg_.a
packagefile math/bits=$WORK/b031/_pkg_.a
packagefile runtime=$WORK/b009/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b090/_pkg_.a -trimpath "$WORK/b090=>" -p crypto/internal/fips140/subtle -lang=go1.27 -std -complete -buildid Ild0pXT9gYtqoqcoaH5k/Ild0pXT9gYtqoqcoaH5k -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b090/importcfg -pack /home/exedev/e1/goroot/src/crypto/internal/fips140/subtle/constant_time.go /home/exedev/e1/goroot/src/crypto/internal/fips140/subtle/xor.go /home/exedev/e1/goroot/src/crypto/internal/fips140/subtle/xor_generic.go
go tool buildid -w $WORK/b090/_pkg_.a # internal
mkdir -p $WORK/b092/

#
# crypto/internal/fips140deps/cpu
#

cat >$WORK/b092/importcfg << 'EOF' # internal
# import config
packagefile internal/cpu=$WORK/b011/_pkg_.a
packagefile internal/goarch=$WORK/b006/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b092/_pkg_.a -trimpath "$WORK/b092=>" -p crypto/internal/fips140deps/cpu -lang=go1.27 -std -complete -buildid 3Im8SCkRiCgisFfChWOL/3Im8SCkRiCgisFfChWOL -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b092/importcfg -pack /home/exedev/e1/goroot/src/crypto/internal/fips140deps/cpu/cpu.go
go tool buildid -w $WORK/b092/_pkg_.a # internal
mkdir -p $WORK/b089/

#
# crypto/internal/fips140/sha3
#

cat >$WORK/b089/importcfg << 'EOF' # internal
# import config
packagefile bytes=$WORK/b059/_pkg_.a
packagefile crypto/internal/fips140=$WORK/b082/_pkg_.a
packagefile crypto/internal/fips140/subtle=$WORK/b090/_pkg_.a
packagefile crypto/internal/fips140deps/byteorder=$WORK/b088/_pkg_.a
packagefile crypto/internal/fips140deps/cpu=$WORK/b092/_pkg_.a
packagefile errors=$WORK/b003/_pkg_.a
packagefile math/bits=$WORK/b031/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b089/_pkg_.a -trimpath "$WORK/b089=>" -p crypto/internal/fips140/sha3 -lang=go1.27 -std -complete -buildid V4IOSZLJMeUUB0QMSc3Y/V4IOSZLJMeUUB0QMSc3Y -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b089/importcfg -pack /home/exedev/e1/goroot/src/crypto/internal/fips140/sha3/cast.go /home/exedev/e1/goroot/src/crypto/internal/fips140/sha3/hashes.go /home/exedev/e1/goroot/src/crypto/internal/fips140/sha3/keccakf.go /home/exedev/e1/goroot/src/crypto/internal/fips140/sha3/sha3.go /home/exedev/e1/goroot/src/crypto/internal/fips140/sha3/sha3_noasm.go /home/exedev/e1/goroot/src/crypto/internal/fips140/sha3/shake.go
go tool buildid -w $WORK/b089/_pkg_.a # internal
mkdir -p $WORK/b093/

#
# crypto/internal/fips140/sha512
#

cat >$WORK/b093/importcfg << 'EOF' # internal
# import config
packagefile bytes=$WORK/b059/_pkg_.a
packagefile crypto/internal/fips140=$WORK/b082/_pkg_.a
packagefile crypto/internal/fips140deps/byteorder=$WORK/b088/_pkg_.a
packagefile errors=$WORK/b003/_pkg_.a
packagefile hash=$WORK/b078/_pkg_.a
packagefile math/bits=$WORK/b031/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b093/_pkg_.a -trimpath "$WORK/b093=>" -p crypto/internal/fips140/sha512 -lang=go1.27 -std -complete -buildid i-bZhga-vh4HjtAvY-k1/i-bZhga-vh4HjtAvY-k1 -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b093/importcfg -pack /home/exedev/e1/goroot/src/crypto/internal/fips140/sha512/cast.go /home/exedev/e1/goroot/src/crypto/internal/fips140/sha512/sha512.go /home/exedev/e1/goroot/src/crypto/internal/fips140/sha512/sha512block.go /home/exedev/e1/goroot/src/crypto/internal/fips140/sha512/sha512block_noasm.go
go tool buildid -w $WORK/b093/_pkg_.a # internal
mkdir -p $WORK/b086/

#
# crypto/internal/fips140/hmac
#

cat >$WORK/b086/importcfg << 'EOF' # internal
# import config
packagefile bytes=$WORK/b059/_pkg_.a
packagefile crypto/internal/fips140=$WORK/b082/_pkg_.a
packagefile crypto/internal/fips140/sha256=$WORK/b087/_pkg_.a
packagefile crypto/internal/fips140/sha3=$WORK/b089/_pkg_.a
packagefile crypto/internal/fips140/sha512=$WORK/b093/_pkg_.a
packagefile errors=$WORK/b003/_pkg_.a
packagefile hash=$WORK/b078/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b086/_pkg_.a -trimpath "$WORK/b086=>" -p crypto/internal/fips140/hmac -lang=go1.27 -std -complete -buildid mN92IGbQTfWobSq-1lfd/mN92IGbQTfWobSq-1lfd -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b086/importcfg -pack /home/exedev/e1/goroot/src/crypto/internal/fips140/hmac/cast.go /home/exedev/e1/goroot/src/crypto/internal/fips140/hmac/hmac.go
go tool buildid -w $WORK/b086/_pkg_.a # internal
mkdir -p $WORK/b085/

#
# crypto/internal/fips140/check
#

cat >$WORK/b085/importcfg << 'EOF' # internal
# import config
packagefile crypto/internal/fips140=$WORK/b082/_pkg_.a
packagefile crypto/internal/fips140/hmac=$WORK/b086/_pkg_.a
packagefile crypto/internal/fips140/sha256=$WORK/b087/_pkg_.a
packagefile crypto/internal/fips140deps/byteorder=$WORK/b088/_pkg_.a
packagefile crypto/internal/fips140deps/godebug=$WORK/b083/_pkg_.a
packagefile io=$WORK/b038/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b085/_pkg_.a -trimpath "$WORK/b085=>" -p crypto/internal/fips140/check -lang=go1.27 -std -complete -buildid CCkbNgMvocBekmYsVWtN/CCkbNgMvocBekmYsVWtN -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b085/importcfg -pack /home/exedev/e1/goroot/src/crypto/internal/fips140/check/check.go
go tool buildid -w $WORK/b085/_pkg_.a # internal
mkdir -p $WORK/b081/

#
# crypto/internal/fips140/aes
#

cat >$WORK/b081/importcfg << 'EOF' # internal
# import config
packagefile bytes=$WORK/b059/_pkg_.a
packagefile crypto/internal/fips140=$WORK/b082/_pkg_.a
packagefile crypto/internal/fips140/alias=$WORK/b084/_pkg_.a
packagefile crypto/internal/fips140/check=$WORK/b085/_pkg_.a
packagefile crypto/internal/fips140/subtle=$WORK/b090/_pkg_.a
packagefile crypto/internal/fips140deps/byteorder=$WORK/b088/_pkg_.a
packagefile errors=$WORK/b003/_pkg_.a
packagefile math/bits=$WORK/b031/_pkg_.a
packagefile strconv=$WORK/b056/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b081/_pkg_.a -trimpath "$WORK/b081=>" -p crypto/internal/fips140/aes -lang=go1.27 -std -complete -buildid V9tpen3kQKKh7_ppWnN9/V9tpen3kQKKh7_ppWnN9 -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b081/importcfg -pack /home/exedev/e1/goroot/src/crypto/internal/fips140/aes/aes.go /home/exedev/e1/goroot/src/crypto/internal/fips140/aes/aes_generic.go /home/exedev/e1/goroot/src/crypto/internal/fips140/aes/aes_noasm.go /home/exedev/e1/goroot/src/crypto/internal/fips140/aes/cast.go /home/exedev/e1/goroot/src/crypto/internal/fips140/aes/cbc.go /home/exedev/e1/goroot/src/crypto/internal/fips140/aes/cbc_noasm.go /home/exedev/e1/goroot/src/crypto/internal/fips140/aes/const.go /home/exedev/e1/goroot/src/crypto/internal/fips140/aes/ctr.go /home/exedev/e1/goroot/src/crypto/internal/fips140/aes/ctr_noasm.go
go tool buildid -w $WORK/b081/_pkg_.a # internal
mkdir -p $WORK/b096/

#
# crypto/internal/sysrand
#

cat >$WORK/b096/importcfg << 'EOF' # internal
# import config
packagefile os=$WORK/b002/_pkg_.a
packagefile sync=$WORK/b039/_pkg_.a
packagefile sync/atomic=$WORK/b041/_pkg_.a
packagefile syscall=$WORK/b049/_pkg_.a
packagefile time=$WORK/b048/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b096/_pkg_.a -trimpath "$WORK/b096=>" -p crypto/internal/sysrand -lang=go1.27 -std -complete -buildid JBgZZwTAS6blX-q_TQb3/JBgZZwTAS6blX-q_TQb3 -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b096/importcfg -pack /home/exedev/e1/goroot/src/crypto/internal/sysrand/rand.go /home/exedev/e1/goroot/src/crypto/internal/sysrand/rand_wasip1.go
go tool buildid -w $WORK/b096/_pkg_.a # internal
mkdir -p $WORK/b095/

#
# crypto/internal/fips140/drbg
#

cat >$WORK/b095/importcfg << 'EOF' # internal
# import config
packagefile bytes=$WORK/b059/_pkg_.a
packagefile crypto/internal/fips140=$WORK/b082/_pkg_.a
packagefile crypto/internal/fips140/aes=$WORK/b081/_pkg_.a
packagefile crypto/internal/fips140/check=$WORK/b085/_pkg_.a
packagefile crypto/internal/fips140/subtle=$WORK/b090/_pkg_.a
packagefile crypto/internal/fips140deps/byteorder=$WORK/b088/_pkg_.a
packagefile crypto/internal/sysrand=$WORK/b096/_pkg_.a
packagefile errors=$WORK/b003/_pkg_.a
packagefile io=$WORK/b038/_pkg_.a
packagefile math/bits=$WORK/b031/_pkg_.a
packagefile sync=$WORK/b039/_pkg_.a
packagefile sync/atomic=$WORK/b041/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b095/_pkg_.a -trimpath "$WORK/b095=>" -p crypto/internal/fips140/drbg -lang=go1.27 -std -complete -buildid dxEOJiRw1Y2IEmCvGdqr/dxEOJiRw1Y2IEmCvGdqr -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b095/importcfg -pack /home/exedev/e1/goroot/src/crypto/internal/fips140/drbg/cast.go /home/exedev/e1/goroot/src/crypto/internal/fips140/drbg/ctrdrbg.go /home/exedev/e1/goroot/src/crypto/internal/fips140/drbg/entropy_wasm.go /home/exedev/e1/goroot/src/crypto/internal/fips140/drbg/rand.go
go tool buildid -w $WORK/b095/_pkg_.a # internal
mkdir -p $WORK/b094/

#
# crypto/internal/fips140/aes/gcm
#

cat >$WORK/b094/importcfg << 'EOF' # internal
# import config
packagefile crypto/internal/fips140=$WORK/b082/_pkg_.a
packagefile crypto/internal/fips140/aes=$WORK/b081/_pkg_.a
packagefile crypto/internal/fips140/alias=$WORK/b084/_pkg_.a
packagefile crypto/internal/fips140/check=$WORK/b085/_pkg_.a
packagefile crypto/internal/fips140/drbg=$WORK/b095/_pkg_.a
packagefile crypto/internal/fips140/subtle=$WORK/b090/_pkg_.a
packagefile crypto/internal/fips140deps/byteorder=$WORK/b088/_pkg_.a
packagefile errors=$WORK/b003/_pkg_.a
packagefile math=$WORK/b055/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b094/_pkg_.a -trimpath "$WORK/b094=>" -p crypto/internal/fips140/aes/gcm -lang=go1.27 -std -complete -buildid FlAjS93dX3sL-TX4tQB3/FlAjS93dX3sL-TX4tQB3 -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b094/importcfg -pack /home/exedev/e1/goroot/src/crypto/internal/fips140/aes/gcm/cast.go /home/exedev/e1/goroot/src/crypto/internal/fips140/aes/gcm/cmac.go /home/exedev/e1/goroot/src/crypto/internal/fips140/aes/gcm/ctrkdf.go /home/exedev/e1/goroot/src/crypto/internal/fips140/aes/gcm/gcm.go /home/exedev/e1/goroot/src/crypto/internal/fips140/aes/gcm/gcm_generic.go /home/exedev/e1/goroot/src/crypto/internal/fips140/aes/gcm/gcm_noasm.go /home/exedev/e1/goroot/src/crypto/internal/fips140/aes/gcm/gcm_nonces.go /home/exedev/e1/goroot/src/crypto/internal/fips140/aes/gcm/ghash.go
go tool buildid -w $WORK/b094/_pkg_.a # internal
mkdir -p $WORK/b098/

#
# crypto/fips140
#

cat >$WORK/b098/importcfg << 'EOF' # internal
# import config
packagefile crypto/internal/fips140=$WORK/b082/_pkg_.a
packagefile crypto/internal/fips140/check=$WORK/b085/_pkg_.a
packagefile internal/godebug=$WORK/b068/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b098/_pkg_.a -trimpath "$WORK/b098=>" -p crypto/fips140 -lang=go1.27 -std -complete -buildid hrhdirHkXNFbLBY3DeHT/hrhdirHkXNFbLBY3DeHT -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b098/importcfg -pack /home/exedev/e1/goroot/src/crypto/fips140/enforcement.go /home/exedev/e1/goroot/src/crypto/fips140/fips140.go
go tool buildid -w $WORK/b098/_pkg_.a # internal
mkdir -p $WORK/b097/

#
# crypto/internal/fips140only
#

cat >$WORK/b097/importcfg << 'EOF' # internal
# import config
packagefile crypto/fips140=$WORK/b098/_pkg_.a
packagefile crypto/internal/fips140/drbg=$WORK/b095/_pkg_.a
packagefile crypto/internal/fips140/sha256=$WORK/b087/_pkg_.a
packagefile crypto/internal/fips140/sha3=$WORK/b089/_pkg_.a
packagefile crypto/internal/fips140/sha512=$WORK/b093/_pkg_.a
packagefile hash=$WORK/b078/_pkg_.a
packagefile io=$WORK/b038/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b097/_pkg_.a -trimpath "$WORK/b097=>" -p crypto/internal/fips140only -lang=go1.27 -std -complete -buildid I2f_7UhueKbhIZxCR-8q/I2f_7UhueKbhIZxCR-8q -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b097/importcfg -pack /home/exedev/e1/goroot/src/crypto/internal/fips140only/fips140only.go /home/exedev/e1/goroot/src/crypto/internal/fips140only/random_fips140v1.28.go
go tool buildid -w $WORK/b097/_pkg_.a # internal
mkdir -p $WORK/b099/

#
# crypto/subtle
#

cat >$WORK/b099/importcfg << 'EOF' # internal
# import config
packagefile crypto/internal/constanttime=$WORK/b091/_pkg_.a
packagefile crypto/internal/fips140/subtle=$WORK/b090/_pkg_.a
packagefile internal/runtime/sys=$WORK/b023/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b099/_pkg_.a -trimpath "$WORK/b099=>" -p crypto/subtle -lang=go1.27 -std -complete -buildid VpsOK5veTagmR3sta6E9/VpsOK5veTagmR3sta6E9 -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b099/importcfg -pack /home/exedev/e1/goroot/src/crypto/subtle/constant_time.go /home/exedev/e1/goroot/src/crypto/subtle/dit.go /home/exedev/e1/goroot/src/crypto/subtle/xor.go
go tool buildid -w $WORK/b099/_pkg_.a # internal
mkdir -p $WORK/b080/

#
# crypto/cipher
#

cat >$WORK/b080/importcfg << 'EOF' # internal
# import config
packagefile bytes=$WORK/b059/_pkg_.a
packagefile crypto/internal/fips140/aes=$WORK/b081/_pkg_.a
packagefile crypto/internal/fips140/aes/gcm=$WORK/b094/_pkg_.a
packagefile crypto/internal/fips140/alias=$WORK/b084/_pkg_.a
packagefile crypto/internal/fips140only=$WORK/b097/_pkg_.a
packagefile crypto/subtle=$WORK/b099/_pkg_.a
packagefile errors=$WORK/b003/_pkg_.a
packagefile internal/byteorder=$WORK/b012/_pkg_.a
packagefile io=$WORK/b038/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b080/_pkg_.a -trimpath "$WORK/b080=>" -p crypto/cipher -lang=go1.27 -std -complete -buildid IhJqsAaw7dRKNhay0Yrq/IhJqsAaw7dRKNhay0Yrq -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b080/importcfg -pack /home/exedev/e1/goroot/src/crypto/cipher/cbc.go /home/exedev/e1/goroot/src/crypto/cipher/cfb.go /home/exedev/e1/goroot/src/crypto/cipher/cipher.go /home/exedev/e1/goroot/src/crypto/cipher/ctr.go /home/exedev/e1/goroot/src/crypto/cipher/gcm.go /home/exedev/e1/goroot/src/crypto/cipher/io.go /home/exedev/e1/goroot/src/crypto/cipher/ofb.go
go tool buildid -w $WORK/b080/_pkg_.a # internal
mkdir -p $WORK/b100/

#
# crypto/internal/boring/sig
#

echo -n > $WORK/b100/go_asm.h # internal
cd /home/exedev/e1/goroot/src/crypto/internal/boring/sig
/home/exedev/e1/goroot/pkg/tool/linux_amd64/asm -p crypto/internal/boring/sig -trimpath "$WORK/b100=>" -I $WORK/b100/ -I /home/exedev/e1/goroot/pkg/include -D GOOS_wasip1 -D GOARCH_wasm -std -gensymabis -o $WORK/b100/symabis ./sig_other.s
echo '# import config' > $WORK/b100/importcfg # internal
cd /home/exedev/e1/tdemo
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b100/_pkg_.a -trimpath "$WORK/b100=>" -p crypto/internal/boring/sig -lang=go1.27 -std -buildid FHuLmR580Q2m4X_cXrQh/FHuLmR580Q2m4X_cXrQh -dwarf=false -goversion go1.27.2 -symabis $WORK/b100/symabis -c=2 -nolocalimports -importcfg $WORK/b100/importcfg -pack -asmhdr $WORK/b100/go_asm.h /home/exedev/e1/goroot/src/crypto/internal/boring/sig/sig.go
cd /home/exedev/e1/goroot/src/crypto/internal/boring/sig
/home/exedev/e1/goroot/pkg/tool/linux_amd64/asm -p crypto/internal/boring/sig -trimpath "$WORK/b100=>" -I $WORK/b100/ -I /home/exedev/e1/goroot/pkg/include -D GOOS_wasip1 -D GOARCH_wasm -std -o $WORK/b100/sig_other.o ./sig_other.s
go tool pack r $WORK/b100/_pkg_.a $WORK/b100/sig_other.o # internal
go tool buildid -w $WORK/b100/_pkg_.a # internal
mkdir -p $WORK/b079/

#
# crypto/internal/boring
#

cat >$WORK/b079/importcfg << 'EOF' # internal
# import config
packagefile crypto=$WORK/b077/_pkg_.a
packagefile crypto/cipher=$WORK/b080/_pkg_.a
packagefile crypto/internal/boring/sig=$WORK/b100/_pkg_.a
packagefile hash=$WORK/b078/_pkg_.a
EOF
cd /home/exedev/e1/tdemo
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b079/_pkg_.a -trimpath "$WORK/b079=>" -p crypto/internal/boring -lang=go1.27 -std -complete -buildid EtYNGiifZ2AasBEWoDwi/EtYNGiifZ2AasBEWoDwi -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b079/importcfg -pack /home/exedev/e1/goroot/src/crypto/internal/boring/doc.go /home/exedev/e1/goroot/src/crypto/internal/boring/notboring.go
go tool buildid -w $WORK/b079/_pkg_.a # internal
mkdir -p $WORK/b076/

#
# crypto/sha256
#

cat >$WORK/b076/importcfg << 'EOF' # internal
# import config
packagefile crypto=$WORK/b077/_pkg_.a
packagefile crypto/internal/boring=$WORK/b079/_pkg_.a
packagefile crypto/internal/fips140/sha256=$WORK/b087/_pkg_.a
packagefile hash=$WORK/b078/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b076/_pkg_.a -trimpath "$WORK/b076=>" -p crypto/sha256 -lang=go1.27 -std -complete -buildid uUbAvnH6taf98L7Y2w8s/uUbAvnH6taf98L7Y2w8s -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b076/importcfg -pack /home/exedev/e1/goroot/src/crypto/sha256/sha256.go
go tool buildid -w $WORK/b076/_pkg_.a # internal
mkdir -p $WORK/b101/

#
# encoding/binary
#

cat >$WORK/b101/importcfg << 'EOF' # internal
# import config
packagefile errors=$WORK/b003/_pkg_.a
packagefile io=$WORK/b038/_pkg_.a
packagefile math=$WORK/b055/_pkg_.a
packagefile reflect=$WORK/b054/_pkg_.a
packagefile slices=$WORK/b045/_pkg_.a
packagefile sync=$WORK/b039/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b101/_pkg_.a -trimpath "$WORK/b101=>" -p encoding/binary -lang=go1.27 -std -complete -buildid FxNLAo06F90FgYfUdPIK/FxNLAo06F90FgYfUdPIK -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b101/importcfg -pack /home/exedev/e1/goroot/src/encoding/binary/binary.go /home/exedev/e1/goroot/src/encoding/binary/native_endian_little.go /home/exedev/e1/goroot/src/encoding/binary/varint.go
go tool buildid -w $WORK/b101/_pkg_.a # internal
mkdir -p $WORK/b103/

#
# encoding/json/internal
#

cat >$WORK/b103/importcfg << 'EOF' # internal
# import config
packagefile errors=$WORK/b003/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b103/_pkg_.a -trimpath "$WORK/b103=>" -p encoding/json/internal -lang=go1.27 -std -complete -buildid Ym6dp7l1dbBRPai5-KUs/Ym6dp7l1dbBRPai5-KUs -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b103/importcfg -pack /home/exedev/e1/goroot/src/encoding/json/internal/internal.go
go tool buildid -w $WORK/b103/_pkg_.a # internal
mkdir -p $WORK/b104/

#
# encoding/json/internal/jsonflags
#

cat >$WORK/b104/importcfg << 'EOF' # internal
# import config
packagefile encoding/json/internal=$WORK/b103/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b104/_pkg_.a -trimpath "$WORK/b104=>" -p encoding/json/internal/jsonflags -lang=go1.27 -std -complete -buildid R52DTcnYPoykbYkKnzYN/R52DTcnYPoykbYkKnzYN -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b104/importcfg -pack /home/exedev/e1/goroot/src/encoding/json/internal/jsonflags/flags.go
go tool buildid -w $WORK/b104/_pkg_.a # internal
mkdir -p $WORK/b105/

#
# encoding/json/internal/jsonopts
#

cat >$WORK/b105/importcfg << 'EOF' # internal
# import config
packagefile encoding/json/internal=$WORK/b103/_pkg_.a
packagefile encoding/json/internal/jsonflags=$WORK/b104/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b105/_pkg_.a -trimpath "$WORK/b105=>" -p encoding/json/internal/jsonopts -lang=go1.27 -std -complete -buildid lFCodgeD73pF5a6y7N-f/lFCodgeD73pF5a6y7N-f -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b105/importcfg -pack /home/exedev/e1/goroot/src/encoding/json/internal/jsonopts/options.go /home/exedev/e1/goroot/src/encoding/json/internal/jsonopts/options_format.go
go tool buildid -w $WORK/b105/_pkg_.a # internal
mkdir -p $WORK/b107/

#
# unicode/utf16
#

echo '# import config' > $WORK/b107/importcfg # internal
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b107/_pkg_.a -trimpath "$WORK/b107=>" -p unicode/utf16 -lang=go1.27 -std -complete -buildid zmDe91XMt_J9_-Ivjmp7/zmDe91XMt_J9_-Ivjmp7 -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b107/importcfg -pack /home/exedev/e1/goroot/src/unicode/utf16/utf16.go
go tool buildid -w $WORK/b107/_pkg_.a # internal
mkdir -p $WORK/b106/

#
# encoding/json/internal/jsonwire
#

cat >$WORK/b106/importcfg << 'EOF' # internal
# import config
packagefile cmp=$WORK/b046/_pkg_.a
packagefile encoding/json/internal/jsonflags=$WORK/b104/_pkg_.a
packagefile errors=$WORK/b003/_pkg_.a
packagefile io=$WORK/b038/_pkg_.a
packagefile math=$WORK/b055/_pkg_.a
packagefile slices=$WORK/b045/_pkg_.a
packagefile strconv=$WORK/b056/_pkg_.a
packagefile strings=$WORK/b065/_pkg_.a
packagefile unicode=$WORK/b057/_pkg_.a
packagefile unicode/utf16=$WORK/b107/_pkg_.a
packagefile unicode/utf8=$WORK/b044/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b106/_pkg_.a -trimpath "$WORK/b106=>" -p encoding/json/internal/jsonwire -lang=go1.27 -std -complete -buildid HpQtcQOfsAVORNX4aroY/HpQtcQOfsAVORNX4aroY -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b106/importcfg -pack /home/exedev/e1/goroot/src/encoding/json/internal/jsonwire/decode.go /home/exedev/e1/goroot/src/encoding/json/internal/jsonwire/encode.go /home/exedev/e1/goroot/src/encoding/json/internal/jsonwire/wire.go
go tool buildid -w $WORK/b106/_pkg_.a # internal
mkdir -p $WORK/b108/

#
# encoding/json/jsontext
#

cat >$WORK/b108/importcfg << 'EOF' # internal
# import config
packagefile bytes=$WORK/b059/_pkg_.a
packagefile encoding/json/internal=$WORK/b103/_pkg_.a
packagefile encoding/json/internal/jsonflags=$WORK/b104/_pkg_.a
packagefile encoding/json/internal/jsonopts=$WORK/b105/_pkg_.a
packagefile encoding/json/internal/jsonwire=$WORK/b106/_pkg_.a
packagefile errors=$WORK/b003/_pkg_.a
packagefile io=$WORK/b038/_pkg_.a
packagefile iter=$WORK/b047/_pkg_.a
packagefile math=$WORK/b055/_pkg_.a
packagefile math/bits=$WORK/b031/_pkg_.a
packagefile slices=$WORK/b045/_pkg_.a
packagefile strconv=$WORK/b056/_pkg_.a
packagefile strings=$WORK/b065/_pkg_.a
packagefile sync=$WORK/b039/_pkg_.a
packagefile unicode/utf8=$WORK/b044/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b108/_pkg_.a -trimpath "$WORK/b108=>" -p encoding/json/jsontext -lang=go1.27 -std -complete -buildid UjXn4UORvdeQ0I9HDBZo/UjXn4UORvdeQ0I9HDBZo -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b108/importcfg -pack /home/exedev/e1/goroot/src/encoding/json/jsontext/decode.go /home/exedev/e1/goroot/src/encoding/json/jsontext/doc.go /home/exedev/e1/goroot/src/encoding/json/jsontext/encode.go /home/exedev/e1/goroot/src/encoding/json/jsontext/errors.go /home/exedev/e1/goroot/src/encoding/json/jsontext/export.go /home/exedev/e1/goroot/src/encoding/json/jsontext/options.go /home/exedev/e1/goroot/src/encoding/json/jsontext/pools.go /home/exedev/e1/goroot/src/encoding/json/jsontext/quote.go /home/exedev/e1/goroot/src/encoding/json/jsontext/state.go /home/exedev/e1/goroot/src/encoding/json/jsontext/token.go /home/exedev/e1/goroot/src/encoding/json/jsontext/value.go
go tool buildid -w $WORK/b108/_pkg_.a # internal
mkdir -p $WORK/b110/

#
# encoding/base32
#

cat >$WORK/b110/importcfg << 'EOF' # internal
# import config
packagefile io=$WORK/b038/_pkg_.a
packagefile slices=$WORK/b045/_pkg_.a
packagefile strconv=$WORK/b056/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b110/_pkg_.a -trimpath "$WORK/b110=>" -p encoding/base32 -lang=go1.27 -std -complete -buildid gSIpwCsvegG56BiIUbKh/gSIpwCsvegG56BiIUbKh -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b110/importcfg -pack /home/exedev/e1/goroot/src/encoding/base32/base32.go
go tool buildid -w $WORK/b110/_pkg_.a # internal
mkdir -p $WORK/b111/

#
# encoding/base64
#

cat >$WORK/b111/importcfg << 'EOF' # internal
# import config
packagefile internal/byteorder=$WORK/b012/_pkg_.a
packagefile io=$WORK/b038/_pkg_.a
packagefile slices=$WORK/b045/_pkg_.a
packagefile strconv=$WORK/b056/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b111/_pkg_.a -trimpath "$WORK/b111=>" -p encoding/base64 -lang=go1.27 -std -complete -buildid EXz0Sf5mYgBNLTEXW4sy/EXz0Sf5mYgBNLTEXW4sy -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b111/importcfg -pack /home/exedev/e1/goroot/src/encoding/base64/base64.go
go tool buildid -w $WORK/b111/_pkg_.a # internal
mkdir -p $WORK/b112/

#
# encoding/hex
#

cat >$WORK/b112/importcfg << 'EOF' # internal
# import config
packagefile errors=$WORK/b003/_pkg_.a
packagefile fmt=$WORK/b063/_pkg_.a
packagefile io=$WORK/b038/_pkg_.a
packagefile slices=$WORK/b045/_pkg_.a
packagefile strings=$WORK/b065/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b112/_pkg_.a -trimpath "$WORK/b112=>" -p encoding/hex -lang=go1.27 -std -complete -buildid 5HlQ_dh5_YEzV6rKvWhY/5HlQ_dh5_YEzV6rKvWhY -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b112/importcfg -pack /home/exedev/e1/goroot/src/encoding/hex/hex.go
go tool buildid -w $WORK/b112/_pkg_.a # internal
mkdir -p $WORK/b109/

#
# encoding/json/v2
#

cat >$WORK/b109/importcfg << 'EOF' # internal
# import config
packagefile bytes=$WORK/b059/_pkg_.a
packagefile cmp=$WORK/b046/_pkg_.a
packagefile encoding=$WORK/b062/_pkg_.a
packagefile encoding/base32=$WORK/b110/_pkg_.a
packagefile encoding/base64=$WORK/b111/_pkg_.a
packagefile encoding/binary=$WORK/b101/_pkg_.a
packagefile encoding/hex=$WORK/b112/_pkg_.a
packagefile encoding/json/internal=$WORK/b103/_pkg_.a
packagefile encoding/json/internal/jsonflags=$WORK/b104/_pkg_.a
packagefile encoding/json/internal/jsonopts=$WORK/b105/_pkg_.a
packagefile encoding/json/internal/jsonwire=$WORK/b106/_pkg_.a
packagefile encoding/json/jsontext=$WORK/b108/_pkg_.a
packagefile errors=$WORK/b003/_pkg_.a
packagefile fmt=$WORK/b063/_pkg_.a
packagefile io=$WORK/b038/_pkg_.a
packagefile math=$WORK/b055/_pkg_.a
packagefile math/bits=$WORK/b031/_pkg_.a
packagefile reflect=$WORK/b054/_pkg_.a
packagefile slices=$WORK/b045/_pkg_.a
packagefile strconv=$WORK/b056/_pkg_.a
packagefile strings=$WORK/b065/_pkg_.a
packagefile sync=$WORK/b039/_pkg_.a
packagefile time=$WORK/b048/_pkg_.a
packagefile unicode=$WORK/b057/_pkg_.a
packagefile unicode/utf8=$WORK/b044/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b109/_pkg_.a -trimpath "$WORK/b109=>" -p encoding/json/v2 -lang=go1.27 -std -complete -buildid wsJ_EKFwTnaS1eyzwxku/wsJ_EKFwTnaS1eyzwxku -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b109/importcfg -pack /home/exedev/e1/goroot/src/encoding/json/v2/arshal.go /home/exedev/e1/goroot/src/encoding/json/v2/arshal_any.go /home/exedev/e1/goroot/src/encoding/json/v2/arshal_default.go /home/exedev/e1/goroot/src/encoding/json/v2/arshal_embedded.go /home/exedev/e1/goroot/src/encoding/json/v2/arshal_funcs.go /home/exedev/e1/goroot/src/encoding/json/v2/arshal_methods.go /home/exedev/e1/goroot/src/encoding/json/v2/arshal_time.go /home/exedev/e1/goroot/src/encoding/json/v2/doc.go /home/exedev/e1/goroot/src/encoding/json/v2/errors.go /home/exedev/e1/goroot/src/encoding/json/v2/fields.go /home/exedev/e1/goroot/src/encoding/json/v2/fold.go /home/exedev/e1/goroot/src/encoding/json/v2/intern.go /home/exedev/e1/goroot/src/encoding/json/v2/options.go
go tool buildid -w $WORK/b109/_pkg_.a # internal
mkdir -p $WORK/b102/

#
# encoding/json
#

cat >$WORK/b102/importcfg << 'EOF' # internal
# import config
packagefile bytes=$WORK/b059/_pkg_.a
packagefile cmp=$WORK/b046/_pkg_.a
packagefile encoding=$WORK/b062/_pkg_.a
packagefile encoding/json/internal=$WORK/b103/_pkg_.a
packagefile encoding/json/internal/jsonflags=$WORK/b104/_pkg_.a
packagefile encoding/json/internal/jsonopts=$WORK/b105/_pkg_.a
packagefile encoding/json/internal/jsonwire=$WORK/b106/_pkg_.a
packagefile encoding/json/jsontext=$WORK/b108/_pkg_.a
packagefile encoding/json/v2=$WORK/b109/_pkg_.a
packagefile errors=$WORK/b003/_pkg_.a
packagefile fmt=$WORK/b063/_pkg_.a
packagefile io=$WORK/b038/_pkg_.a
packagefile reflect=$WORK/b054/_pkg_.a
packagefile strconv=$WORK/b056/_pkg_.a
packagefile strings=$WORK/b065/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b102/_pkg_.a -trimpath "$WORK/b102=>" -p encoding/json -lang=go1.27 -std -complete -buildid ZM67yroKsTXAAdfldGn8/ZM67yroKsTXAAdfldGn8 -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b102/importcfg -pack /home/exedev/e1/goroot/src/encoding/json/v2_decode.go /home/exedev/e1/goroot/src/encoding/json/v2_encode.go /home/exedev/e1/goroot/src/encoding/json/v2_indent.go /home/exedev/e1/goroot/src/encoding/json/v2_inject.go /home/exedev/e1/goroot/src/encoding/json/v2_options.go /home/exedev/e1/goroot/src/encoding/json/v2_scanner.go /home/exedev/e1/goroot/src/encoding/json/v2_stream.go
go tool buildid -w $WORK/b102/_pkg_.a # internal
mkdir -p $WORK/b115/

#
# go/token
#

cat >$WORK/b115/importcfg << 'EOF' # internal
# import config
packagefile cmp=$WORK/b046/_pkg_.a
packagefile fmt=$WORK/b063/_pkg_.a
packagefile iter=$WORK/b047/_pkg_.a
packagefile slices=$WORK/b045/_pkg_.a
packagefile strconv=$WORK/b056/_pkg_.a
packagefile sync=$WORK/b039/_pkg_.a
packagefile sync/atomic=$WORK/b041/_pkg_.a
packagefile unicode=$WORK/b057/_pkg_.a
packagefile unicode/utf8=$WORK/b044/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b115/_pkg_.a -trimpath "$WORK/b115=>" -p go/token -lang=go1.27 -std -complete -buildid a1_iXqyVj446ZrUb_rB7/a1_iXqyVj446ZrUb_rB7 -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b115/importcfg -pack /home/exedev/e1/goroot/src/go/token/position.go /home/exedev/e1/goroot/src/go/token/serialize.go /home/exedev/e1/goroot/src/go/token/token.go /home/exedev/e1/goroot/src/go/token/tree.go
go tool buildid -w $WORK/b115/_pkg_.a # internal
mkdir -p $WORK/b116/

#
# sort
#

cat >$WORK/b116/importcfg << 'EOF' # internal
# import config
packagefile internal/reflectlite=$WORK/b004/_pkg_.a
packagefile math/bits=$WORK/b031/_pkg_.a
packagefile slices=$WORK/b045/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b116/_pkg_.a -trimpath "$WORK/b116=>" -p sort -lang=go1.27 -std -complete -buildid V6VfzaLnJzE-TR77RNeP/V6VfzaLnJzE-TR77RNeP -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b116/importcfg -pack /home/exedev/e1/goroot/src/sort/search.go /home/exedev/e1/goroot/src/sort/slice.go /home/exedev/e1/goroot/src/sort/sort.go /home/exedev/e1/goroot/src/sort/zsortfunc.go /home/exedev/e1/goroot/src/sort/zsortinterface.go
go tool buildid -w $WORK/b116/_pkg_.a # internal
mkdir -p $WORK/b114/

#
# go/scanner
#

cat >$WORK/b114/importcfg << 'EOF' # internal
# import config
packagefile bytes=$WORK/b059/_pkg_.a
packagefile fmt=$WORK/b063/_pkg_.a
packagefile go/token=$WORK/b115/_pkg_.a
packagefile io=$WORK/b038/_pkg_.a
packagefile path/filepath=$WORK/b070/_pkg_.a
packagefile sort=$WORK/b116/_pkg_.a
packagefile strconv=$WORK/b056/_pkg_.a
packagefile unicode=$WORK/b057/_pkg_.a
packagefile unicode/utf8=$WORK/b044/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b114/_pkg_.a -trimpath "$WORK/b114=>" -p go/scanner -lang=go1.27 -std -complete -buildid F3yuvVlobq_joXjRuGu3/F3yuvVlobq_joXjRuGu3 -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b114/importcfg -pack /home/exedev/e1/goroot/src/go/scanner/errors.go /home/exedev/e1/goroot/src/go/scanner/scanner.go
go tool buildid -w $WORK/b114/_pkg_.a # internal
mkdir -p $WORK/b113/

#
# go/ast
#

cat >$WORK/b113/importcfg << 'EOF' # internal
# import config
packagefile bytes=$WORK/b059/_pkg_.a
packagefile cmp=$WORK/b046/_pkg_.a
packagefile fmt=$WORK/b063/_pkg_.a
packagefile go/scanner=$WORK/b114/_pkg_.a
packagefile go/token=$WORK/b115/_pkg_.a
packagefile io=$WORK/b038/_pkg_.a
packagefile iter=$WORK/b047/_pkg_.a
packagefile os=$WORK/b002/_pkg_.a
packagefile reflect=$WORK/b054/_pkg_.a
packagefile slices=$WORK/b045/_pkg_.a
packagefile strconv=$WORK/b056/_pkg_.a
packagefile strings=$WORK/b065/_pkg_.a
packagefile unicode=$WORK/b057/_pkg_.a
packagefile unicode/utf8=$WORK/b044/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b113/_pkg_.a -trimpath "$WORK/b113=>" -p go/ast -lang=go1.27 -std -complete -buildid 2vbecgvvEtCxhNZLzoHR/2vbecgvvEtCxhNZLzoHR -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b113/importcfg -pack /home/exedev/e1/goroot/src/go/ast/ast.go /home/exedev/e1/goroot/src/go/ast/commentmap.go /home/exedev/e1/goroot/src/go/ast/directive.go /home/exedev/e1/goroot/src/go/ast/filter.go /home/exedev/e1/goroot/src/go/ast/import.go /home/exedev/e1/goroot/src/go/ast/print.go /home/exedev/e1/goroot/src/go/ast/resolve.go /home/exedev/e1/goroot/src/go/ast/scope.go /home/exedev/e1/goroot/src/go/ast/walk.go
go tool buildid -w $WORK/b113/_pkg_.a # internal
mkdir -p $WORK/b118/

#
# go/build/constraint
#

cat >$WORK/b118/importcfg << 'EOF' # internal
# import config
packagefile errors=$WORK/b003/_pkg_.a
packagefile strconv=$WORK/b056/_pkg_.a
packagefile strings=$WORK/b065/_pkg_.a
packagefile unicode=$WORK/b057/_pkg_.a
packagefile unicode/utf8=$WORK/b044/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b118/_pkg_.a -trimpath "$WORK/b118=>" -p go/build/constraint -lang=go1.27 -std -complete -buildid WznpfCm_ooRLkd6H5Ovb/WznpfCm_ooRLkd6H5Ovb -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b118/importcfg -pack /home/exedev/e1/goroot/src/go/build/constraint/expr.go /home/exedev/e1/goroot/src/go/build/constraint/vers.go
go tool buildid -w $WORK/b118/_pkg_.a # internal
mkdir -p $WORK/b117/

#
# go/parser
#

cat >$WORK/b117/importcfg << 'EOF' # internal
# import config
packagefile bytes=$WORK/b059/_pkg_.a
packagefile errors=$WORK/b003/_pkg_.a
packagefile fmt=$WORK/b063/_pkg_.a
packagefile go/ast=$WORK/b113/_pkg_.a
packagefile go/build/constraint=$WORK/b118/_pkg_.a
packagefile go/scanner=$WORK/b114/_pkg_.a
packagefile go/token=$WORK/b115/_pkg_.a
packagefile io=$WORK/b038/_pkg_.a
packagefile io/fs=$WORK/b036/_pkg_.a
packagefile os=$WORK/b002/_pkg_.a
packagefile path/filepath=$WORK/b070/_pkg_.a
packagefile strings=$WORK/b065/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b117/_pkg_.a -trimpath "$WORK/b117=>" -p go/parser -lang=go1.27 -std -complete -buildid Ufe5sYzY-OhA-k08EbnE/Ufe5sYzY-OhA-k08EbnE -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b117/importcfg -pack /home/exedev/e1/goroot/src/go/parser/interface.go /home/exedev/e1/goroot/src/go/parser/parser.go /home/exedev/e1/goroot/src/go/parser/resolver.go
go tool buildid -w $WORK/b117/_pkg_.a # internal
mkdir -p $WORK/b119/

#
# os/exec
#

cat >$WORK/b119/importcfg << 'EOF' # internal
# import config
packagefile bytes=$WORK/b059/_pkg_.a
packagefile context=$WORK/b060/_pkg_.a
packagefile errors=$WORK/b003/_pkg_.a
packagefile internal/godebug=$WORK/b068/_pkg_.a
packagefile internal/syscall/execenv=$WORK/b052/_pkg_.a
packagefile io=$WORK/b038/_pkg_.a
packagefile io/fs=$WORK/b036/_pkg_.a
packagefile os=$WORK/b002/_pkg_.a
packagefile path/filepath=$WORK/b070/_pkg_.a
packagefile runtime=$WORK/b009/_pkg_.a
packagefile strconv=$WORK/b056/_pkg_.a
packagefile strings=$WORK/b065/_pkg_.a
packagefile sync/atomic=$WORK/b041/_pkg_.a
packagefile syscall=$WORK/b049/_pkg_.a
packagefile time=$WORK/b048/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b119/_pkg_.a -trimpath "$WORK/b119=>" -p os/exec -lang=go1.27 -std -complete -buildid -AYVM_88BUGVV-17Vq5k/-AYVM_88BUGVV-17Vq5k -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b119/importcfg -pack /home/exedev/e1/goroot/src/os/exec/exec.go /home/exedev/e1/goroot/src/os/exec/exec_unix.go /home/exedev/e1/goroot/src/os/exec/lookpath.go /home/exedev/e1/goroot/src/os/exec/lp_wasm.go
go tool buildid -w $WORK/b119/_pkg_.a # internal
mkdir -p $WORK/b075/

#
# internal/fuzz
#

cat >$WORK/b075/importcfg << 'EOF' # internal
# import config
packagefile bytes=$WORK/b059/_pkg_.a
packagefile context=$WORK/b060/_pkg_.a
packagefile crypto/sha256=$WORK/b076/_pkg_.a
packagefile encoding/binary=$WORK/b101/_pkg_.a
packagefile encoding/json=$WORK/b102/_pkg_.a
packagefile errors=$WORK/b003/_pkg_.a
packagefile fmt=$WORK/b063/_pkg_.a
packagefile go/ast=$WORK/b113/_pkg_.a
packagefile go/parser=$WORK/b117/_pkg_.a
packagefile go/token=$WORK/b115/_pkg_.a
packagefile internal/godebug=$WORK/b068/_pkg_.a
packagefile io=$WORK/b038/_pkg_.a
packagefile math=$WORK/b055/_pkg_.a
packagefile math/bits=$WORK/b031/_pkg_.a
packagefile os=$WORK/b002/_pkg_.a
packagefile os/exec=$WORK/b119/_pkg_.a
packagefile path/filepath=$WORK/b070/_pkg_.a
packagefile reflect=$WORK/b054/_pkg_.a
packagefile runtime=$WORK/b009/_pkg_.a
packagefile strconv=$WORK/b056/_pkg_.a
packagefile strings=$WORK/b065/_pkg_.a
packagefile sync=$WORK/b039/_pkg_.a
packagefile sync/atomic=$WORK/b041/_pkg_.a
packagefile time=$WORK/b048/_pkg_.a
packagefile unicode/utf8=$WORK/b044/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b075/_pkg_.a -trimpath "$WORK/b075=>" -p internal/fuzz -lang=go1.27 -std -complete -buildid nQEloBrWMqC2fbJrhGuN/nQEloBrWMqC2fbJrhGuN -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b075/importcfg -pack /home/exedev/e1/goroot/src/internal/fuzz/counters_unsupported.go /home/exedev/e1/goroot/src/internal/fuzz/coverage.go /home/exedev/e1/goroot/src/internal/fuzz/encoding.go /home/exedev/e1/goroot/src/internal/fuzz/fuzz.go /home/exedev/e1/goroot/src/internal/fuzz/mem.go /home/exedev/e1/goroot/src/internal/fuzz/minimize.go /home/exedev/e1/goroot/src/internal/fuzz/mutator.go /home/exedev/e1/goroot/src/internal/fuzz/mutators_byteslice.go /home/exedev/e1/goroot/src/internal/fuzz/pcg.go /home/exedev/e1/goroot/src/internal/fuzz/queue.go /home/exedev/e1/goroot/src/internal/fuzz/sys_unimplemented.go /home/exedev/e1/goroot/src/internal/fuzz/trace.go /home/exedev/e1/goroot/src/internal/fuzz/worker.go
go tool buildid -w $WORK/b075/_pkg_.a # internal
mkdir -p $WORK/b120/

#
# os/signal
#

echo -n > $WORK/b120/go_asm.h # internal
cd /home/exedev/e1/goroot/src/os/signal
/home/exedev/e1/goroot/pkg/tool/linux_amd64/asm -p os/signal -trimpath "$WORK/b120=>" -I $WORK/b120/ -I /home/exedev/e1/goroot/pkg/include -D GOOS_wasip1 -D GOARCH_wasm -std -gensymabis -o $WORK/b120/symabis ./sig.s
cat >$WORK/b120/importcfg << 'EOF' # internal
# import config
packagefile context=$WORK/b060/_pkg_.a
packagefile os=$WORK/b002/_pkg_.a
packagefile slices=$WORK/b045/_pkg_.a
packagefile sync=$WORK/b039/_pkg_.a
packagefile syscall=$WORK/b049/_pkg_.a
EOF
cd /home/exedev/e1/tdemo
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b120/_pkg_.a -trimpath "$WORK/b120=>" -p os/signal -lang=go1.27 -std -buildid aeogxLmFml7wSADukRkI/aeogxLmFml7wSADukRkI -dwarf=false -goversion go1.27.2 -symabis $WORK/b120/symabis -c=2 -nolocalimports -importcfg $WORK/b120/importcfg -pack -asmhdr $WORK/b120/go_asm.h /home/exedev/e1/goroot/src/os/signal/doc.go /home/exedev/e1/goroot/src/os/signal/signal.go /home/exedev/e1/goroot/src/os/signal/signal_unix.go
cd /home/exedev/e1/goroot/src/os/signal
/home/exedev/e1/goroot/pkg/tool/linux_amd64/asm -p os/signal -trimpath "$WORK/b120=>" -I $WORK/b120/ -I /home/exedev/e1/goroot/pkg/include -D GOOS_wasip1 -D GOARCH_wasm -std -o $WORK/b120/sig.o ./sig.s
go tool pack r $WORK/b120/_pkg_.a $WORK/b120/sig.o # internal
go tool buildid -w $WORK/b120/_pkg_.a # internal
mkdir -p $WORK/b122/

#
# regexp/syntax
#

cat >$WORK/b122/importcfg << 'EOF' # internal
# import config
packagefile slices=$WORK/b045/_pkg_.a
packagefile sort=$WORK/b116/_pkg_.a
packagefile strconv=$WORK/b056/_pkg_.a
packagefile strings=$WORK/b065/_pkg_.a
packagefile sync=$WORK/b039/_pkg_.a
packagefile unicode=$WORK/b057/_pkg_.a
packagefile unicode/utf8=$WORK/b044/_pkg_.a
EOF
cd /home/exedev/e1/tdemo
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b122/_pkg_.a -trimpath "$WORK/b122=>" -p regexp/syntax -lang=go1.27 -std -complete -buildid 2CmipMxPGqNI1RCYAzV_/2CmipMxPGqNI1RCYAzV_ -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b122/importcfg -pack /home/exedev/e1/goroot/src/regexp/syntax/compile.go /home/exedev/e1/goroot/src/regexp/syntax/doc.go /home/exedev/e1/goroot/src/regexp/syntax/op_string.go /home/exedev/e1/goroot/src/regexp/syntax/parse.go /home/exedev/e1/goroot/src/regexp/syntax/perl_groups.go /home/exedev/e1/goroot/src/regexp/syntax/prog.go /home/exedev/e1/goroot/src/regexp/syntax/regexp.go /home/exedev/e1/goroot/src/regexp/syntax/simplify.go
go tool buildid -w $WORK/b122/_pkg_.a # internal
mkdir -p $WORK/b121/

#
# regexp
#

cat >$WORK/b121/importcfg << 'EOF' # internal
# import config
packagefile bytes=$WORK/b059/_pkg_.a
packagefile io=$WORK/b038/_pkg_.a
packagefile iter=$WORK/b047/_pkg_.a
packagefile regexp/syntax=$WORK/b122/_pkg_.a
packagefile slices=$WORK/b045/_pkg_.a
packagefile strconv=$WORK/b056/_pkg_.a
packagefile strings=$WORK/b065/_pkg_.a
packagefile sync=$WORK/b039/_pkg_.a
packagefile unicode=$WORK/b057/_pkg_.a
packagefile unicode/utf8=$WORK/b044/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b121/_pkg_.a -trimpath "$WORK/b121=>" -p regexp -lang=go1.27 -std -complete -buildid THsXFwgzQyaF-I0j4ETz/THsXFwgzQyaF-I0j4ETz -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b121/importcfg -pack /home/exedev/e1/goroot/src/regexp/backtrack.go /home/exedev/e1/goroot/src/regexp/exec.go /home/exedev/e1/goroot/src/regexp/onepass.go /home/exedev/e1/goroot/src/regexp/regexp.go
go tool buildid -w $WORK/b121/_pkg_.a # internal
mkdir -p $WORK/b125/

#
# compress/flate
#

cat >$WORK/b125/importcfg << 'EOF' # internal
# import config
packagefile bufio=$WORK/b074/_pkg_.a
packagefile errors=$WORK/b003/_pkg_.a
packagefile fmt=$WORK/b063/_pkg_.a
packagefile io=$WORK/b038/_pkg_.a
packagefile math=$WORK/b055/_pkg_.a
packagefile math/bits=$WORK/b031/_pkg_.a
packagefile slices=$WORK/b045/_pkg_.a
packagefile strconv=$WORK/b056/_pkg_.a
packagefile sync=$WORK/b039/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b125/_pkg_.a -trimpath "$WORK/b125=>" -p compress/flate -lang=go1.27 -std -complete -buildid TTSmIw_8ztiDTqWLxwzW/TTSmIw_8ztiDTqWLxwzW -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b125/importcfg -pack /home/exedev/e1/goroot/src/compress/flate/deflate.go /home/exedev/e1/goroot/src/compress/flate/deflatefast.go /home/exedev/e1/goroot/src/compress/flate/dict_decoder.go /home/exedev/e1/goroot/src/compress/flate/huffman_bit_writer.go /home/exedev/e1/goroot/src/compress/flate/huffman_code.go /home/exedev/e1/goroot/src/compress/flate/inflate.go /home/exedev/e1/goroot/src/compress/flate/level1.go /home/exedev/e1/goroot/src/compress/flate/level2.go /home/exedev/e1/goroot/src/compress/flate/level3.go /home/exedev/e1/goroot/src/compress/flate/level4.go /home/exedev/e1/goroot/src/compress/flate/level5.go /home/exedev/e1/goroot/src/compress/flate/level6.go /home/exedev/e1/goroot/src/compress/flate/load_store.go /home/exedev/e1/goroot/src/compress/flate/regmask_other.go /home/exedev/e1/goroot/src/compress/flate/token.go
go tool buildid -w $WORK/b125/_pkg_.a # internal
mkdir -p $WORK/b126/

#
# hash/crc32
#

cat >$WORK/b126/importcfg << 'EOF' # internal
# import config
packagefile errors=$WORK/b003/_pkg_.a
packagefile hash=$WORK/b078/_pkg_.a
packagefile internal/byteorder=$WORK/b012/_pkg_.a
packagefile sync=$WORK/b039/_pkg_.a
packagefile sync/atomic=$WORK/b041/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b126/_pkg_.a -trimpath "$WORK/b126=>" -p hash/crc32 -lang=go1.27 -std -complete -buildid iWUQki_I_GDpPC8O65I-/iWUQki_I_GDpPC8O65I- -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b126/importcfg -pack /home/exedev/e1/goroot/src/hash/crc32/crc32.go /home/exedev/e1/goroot/src/hash/crc32/crc32_generic.go /home/exedev/e1/goroot/src/hash/crc32/crc32_otherarch.go /home/exedev/e1/goroot/src/hash/crc32/gen.go
go tool buildid -w $WORK/b126/_pkg_.a # internal
mkdir -p $WORK/b124/

#
# compress/gzip
#

cat >$WORK/b124/importcfg << 'EOF' # internal
# import config
packagefile bufio=$WORK/b074/_pkg_.a
packagefile compress/flate=$WORK/b125/_pkg_.a
packagefile encoding/binary=$WORK/b101/_pkg_.a
packagefile errors=$WORK/b003/_pkg_.a
packagefile fmt=$WORK/b063/_pkg_.a
packagefile hash/crc32=$WORK/b126/_pkg_.a
packagefile io=$WORK/b038/_pkg_.a
packagefile time=$WORK/b048/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b124/_pkg_.a -trimpath "$WORK/b124=>" -p compress/gzip -lang=go1.27 -std -complete -buildid C9SHIQ5wVVNclIi8Fh8E/C9SHIQ5wVVNclIi8Fh8E -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b124/importcfg -pack /home/exedev/e1/goroot/src/compress/gzip/gunzip.go /home/exedev/e1/goroot/src/compress/gzip/gzip.go
go tool buildid -w $WORK/b124/_pkg_.a # internal
mkdir -p $WORK/b127/

#
# text/tabwriter
#

cat >$WORK/b127/importcfg << 'EOF' # internal
# import config
packagefile fmt=$WORK/b063/_pkg_.a
packagefile io=$WORK/b038/_pkg_.a
packagefile unicode/utf8=$WORK/b044/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b127/_pkg_.a -trimpath "$WORK/b127=>" -p text/tabwriter -lang=go1.27 -std -complete -buildid yFCh5CR4_6BNl00vkzej/yFCh5CR4_6BNl00vkzej -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b127/importcfg -pack /home/exedev/e1/goroot/src/text/tabwriter/tabwriter.go
go tool buildid -w $WORK/b127/_pkg_.a # internal
mkdir -p $WORK/b123/

#
# runtime/pprof
#

cat >$WORK/b123/importcfg << 'EOF' # internal
# import config
packagefile bufio=$WORK/b074/_pkg_.a
packagefile bytes=$WORK/b059/_pkg_.a
packagefile cmp=$WORK/b046/_pkg_.a
packagefile compress/gzip=$WORK/b124/_pkg_.a
packagefile context=$WORK/b060/_pkg_.a
packagefile encoding/binary=$WORK/b101/_pkg_.a
packagefile errors=$WORK/b003/_pkg_.a
packagefile fmt=$WORK/b063/_pkg_.a
packagefile internal/abi=$WORK/b005/_pkg_.a
packagefile internal/profilerecord=$WORK/b018/_pkg_.a
packagefile internal/runtime/pprof/label=$WORK/b029/_pkg_.a
packagefile io=$WORK/b038/_pkg_.a
packagefile math=$WORK/b055/_pkg_.a
packagefile os=$WORK/b002/_pkg_.a
packagefile runtime=$WORK/b009/_pkg_.a
packagefile slices=$WORK/b045/_pkg_.a
packagefile sort=$WORK/b116/_pkg_.a
packagefile strconv=$WORK/b056/_pkg_.a
packagefile strings=$WORK/b065/_pkg_.a
packagefile sync=$WORK/b039/_pkg_.a
packagefile text/tabwriter=$WORK/b127/_pkg_.a
packagefile time=$WORK/b048/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b123/_pkg_.a -trimpath "$WORK/b123=>" -p runtime/pprof -lang=go1.27 -std -buildid vtI3gIcQdhCRYoKv3CfQ/vtI3gIcQdhCRYoKv3CfQ -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b123/importcfg -pack /home/exedev/e1/goroot/src/runtime/pprof/elf.go /home/exedev/e1/goroot/src/runtime/pprof/label.go /home/exedev/e1/goroot/src/runtime/pprof/map.go /home/exedev/e1/goroot/src/runtime/pprof/pe.go /home/exedev/e1/goroot/src/runtime/pprof/pprof.go /home/exedev/e1/goroot/src/runtime/pprof/pprof_norusage.go /home/exedev/e1/goroot/src/runtime/pprof/proto.go /home/exedev/e1/goroot/src/runtime/pprof/proto_other.go /home/exedev/e1/goroot/src/runtime/pprof/protobuf.go /home/exedev/e1/goroot/src/runtime/pprof/protomem.go /home/exedev/e1/goroot/src/runtime/pprof/runtime.go
go tool buildid -w $WORK/b123/_pkg_.a # internal
mkdir -p $WORK/b073/

#
# testing/internal/testdeps
#

cat >$WORK/b073/importcfg << 'EOF' # internal
# import config
packagefile bufio=$WORK/b074/_pkg_.a
packagefile context=$WORK/b060/_pkg_.a
packagefile internal/fuzz=$WORK/b075/_pkg_.a
packagefile internal/testlog=$WORK/b053/_pkg_.a
packagefile io=$WORK/b038/_pkg_.a
packagefile os=$WORK/b002/_pkg_.a
packagefile os/signal=$WORK/b120/_pkg_.a
packagefile reflect=$WORK/b054/_pkg_.a
packagefile regexp=$WORK/b121/_pkg_.a
packagefile runtime/pprof=$WORK/b123/_pkg_.a
packagefile strings=$WORK/b065/_pkg_.a
packagefile sync=$WORK/b039/_pkg_.a
packagefile time=$WORK/b048/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b073/_pkg_.a -trimpath "$WORK/b073=>" -p testing/internal/testdeps -lang=go1.27 -std -complete -buildid Q6vtNS49xN8F9VOAOt_D/Q6vtNS49xN8F9VOAOt_D -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b073/importcfg -pack /home/exedev/e1/goroot/src/testing/internal/testdeps/deps.go
go tool buildid -w $WORK/b073/_pkg_.a # internal
mkdir -p $WORK/b128/

#
# tdemo
#

cat >$WORK/b128/importcfg << 'EOF' # internal
# import config
packagefile testing=$WORK/b058/_pkg_.a
EOF
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b128/_pkg_.a -trimpath "$WORK/b128=>" -p tdemo -lang=go1.27 -complete -buildid FKVdvyn2zvA8-D_P8t3F/FKVdvyn2zvA8-D_P8t3F -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b128/importcfg -pack ./add.go ./add_test.go
go tool buildid -w $WORK/b128/_pkg_.a # internal

#
# tdemo.test
#

cat >$WORK/b001/importcfg << 'EOF' # internal
# import config
packagefile os=$WORK/b002/_pkg_.a
packagefile reflect=$WORK/b054/_pkg_.a
packagefile testing=$WORK/b058/_pkg_.a
packagefile testing/internal/testdeps=$WORK/b073/_pkg_.a
packagefile runtime=$WORK/b009/_pkg_.a
packagefile tdemo=$WORK/b128/_pkg_.a
EOF
cp /home/exedev/e1/tdemo/_testmain.go $WORK/b001/_testmain.go
/home/exedev/e1/goroot/pkg/tool/linux_amd64/compile -o $WORK/b001/_pkg_.a -trimpath "$WORK/b001=>" -p main -lang=go1.27 -complete -buildid Fr3EiUBJDzK98qmafZ_Z/Fr3EiUBJDzK98qmafZ_Z -dwarf=false -goversion go1.27.2 -c=2 -nolocalimports -importcfg $WORK/b001/importcfg -pack $WORK/b001/_testmain.go
go tool buildid -w $WORK/b001/_pkg_.a # internal
cat >$WORK/b001/importcfg.link << 'EOF' # internal
packagefile tdemo.test=$WORK/b001/_pkg_.a
packagefile os=$WORK/b002/_pkg_.a
packagefile reflect=$WORK/b054/_pkg_.a
packagefile testing=$WORK/b058/_pkg_.a
packagefile testing/internal/testdeps=$WORK/b073/_pkg_.a
packagefile runtime=$WORK/b009/_pkg_.a
packagefile tdemo=$WORK/b128/_pkg_.a
packagefile errors=$WORK/b003/_pkg_.a
packagefile internal/bytealg=$WORK/b010/_pkg_.a
packagefile internal/byteorder=$WORK/b012/_pkg_.a
packagefile internal/filepathlite=$WORK/b035/_pkg_.a
packagefile internal/goarch=$WORK/b006/_pkg_.a
packagefile internal/poll=$WORK/b050/_pkg_.a
packagefile internal/strconv=$WORK/b030/_pkg_.a
packagefile internal/stringslite=$WORK/b032/_pkg_.a
packagefile internal/syscall/execenv=$WORK/b052/_pkg_.a
packagefile internal/syscall/unix=$WORK/b051/_pkg_.a
packagefile internal/testlog=$WORK/b053/_pkg_.a
packagefile io=$WORK/b038/_pkg_.a
packagefile io/fs=$WORK/b036/_pkg_.a
packagefile slices=$WORK/b045/_pkg_.a
packagefile sync=$WORK/b039/_pkg_.a
packagefile sync/atomic=$WORK/b041/_pkg_.a
packagefile syscall=$WORK/b049/_pkg_.a
packagefile time=$WORK/b048/_pkg_.a
packagefile internal/abi=$WORK/b005/_pkg_.a
packagefile internal/goexperiment=$WORK/b016/_pkg_.a
packagefile internal/race=$WORK/b027/_pkg_.a
packagefile internal/runtime/maps=$WORK/b024/_pkg_.a
packagefile internal/runtime/sys=$WORK/b023/_pkg_.a
packagefile internal/unsafeheader=$WORK/b008/_pkg_.a
packagefile iter=$WORK/b047/_pkg_.a
packagefile math=$WORK/b055/_pkg_.a
packagefile strconv=$WORK/b056/_pkg_.a
packagefile unicode=$WORK/b057/_pkg_.a
packagefile unicode/utf8=$WORK/b044/_pkg_.a
packagefile bytes=$WORK/b059/_pkg_.a
packagefile context=$WORK/b060/_pkg_.a
packagefile flag=$WORK/b061/_pkg_.a
packagefile fmt=$WORK/b063/_pkg_.a
packagefile internal/sysinfo=$WORK/b066/_pkg_.a
packagefile math/rand=$WORK/b067/_pkg_.a
packagefile path/filepath=$WORK/b070/_pkg_.a
packagefile runtime/debug=$WORK/b071/_pkg_.a
packagefile runtime/trace=$WORK/b072/_pkg_.a
packagefile strings=$WORK/b065/_pkg_.a
packagefile bufio=$WORK/b074/_pkg_.a
packagefile internal/fuzz=$WORK/b075/_pkg_.a
packagefile os/signal=$WORK/b120/_pkg_.a
packagefile regexp=$WORK/b121/_pkg_.a
packagefile runtime/pprof=$WORK/b123/_pkg_.a
packagefile internal/chacha8rand=$WORK/b013/_pkg_.a
packagefile internal/coverage/rtcov=$WORK/b014/_pkg_.a
packagefile internal/cpu=$WORK/b011/_pkg_.a
packagefile internal/godebugs=$WORK/b015/_pkg_.a
packagefile internal/goos=$WORK/b017/_pkg_.a
packagefile internal/profilerecord=$WORK/b018/_pkg_.a
packagefile internal/runtime/atomic=$WORK/b019/_pkg_.a
packagefile internal/runtime/exithook=$WORK/b020/_pkg_.a
packagefile internal/runtime/gc=$WORK/b021/_pkg_.a
packagefile internal/runtime/gc/scan=$WORK/b022/_pkg_.a
packagefile internal/runtime/math=$WORK/b028/_pkg_.a
packagefile internal/runtime/pprof/label=$WORK/b029/_pkg_.a
packagefile internal/trace/tracev2=$WORK/b033/_pkg_.a
packagefile math/bits=$WORK/b031/_pkg_.a
packagefile structs=$WORK/b034/_pkg_.a
packagefile internal/reflectlite=$WORK/b004/_pkg_.a
packagefile internal/oserror=$WORK/b037/_pkg_.a
packagefile path=$WORK/b043/_pkg_.a
packagefile cmp=$WORK/b046/_pkg_.a
packagefile internal/sync=$WORK/b040/_pkg_.a
packagefile internal/synctest=$WORK/b042/_pkg_.a
packagefile internal/asan=$WORK/b025/_pkg_.a
packagefile internal/msan=$WORK/b026/_pkg_.a
packagefile encoding=$WORK/b062/_pkg_.a
packagefile internal/fmtsort=$WORK/b064/_pkg_.a
packagefile internal/godebug=$WORK/b068/_pkg_.a
packagefile crypto/sha256=$WORK/b076/_pkg_.a
packagefile encoding/binary=$WORK/b101/_pkg_.a
packagefile encoding/json=$WORK/b102/_pkg_.a
packagefile go/ast=$WORK/b113/_pkg_.a
packagefile go/parser=$WORK/b117/_pkg_.a
packagefile go/token=$WORK/b115/_pkg_.a
packagefile os/exec=$WORK/b119/_pkg_.a
packagefile regexp/syntax=$WORK/b122/_pkg_.a
packagefile compress/gzip=$WORK/b124/_pkg_.a
packagefile sort=$WORK/b116/_pkg_.a
packagefile text/tabwriter=$WORK/b127/_pkg_.a
packagefile internal/bisect=$WORK/b069/_pkg_.a
packagefile crypto=$WORK/b077/_pkg_.a
packagefile crypto/internal/boring=$WORK/b079/_pkg_.a
packagefile crypto/internal/fips140/sha256=$WORK/b087/_pkg_.a
packagefile hash=$WORK/b078/_pkg_.a
packagefile encoding/json/internal=$WORK/b103/_pkg_.a
packagefile encoding/json/internal/jsonflags=$WORK/b104/_pkg_.a
packagefile encoding/json/internal/jsonopts=$WORK/b105/_pkg_.a
packagefile encoding/json/internal/jsonwire=$WORK/b106/_pkg_.a
packagefile encoding/json/jsontext=$WORK/b108/_pkg_.a
packagefile encoding/json/v2=$WORK/b109/_pkg_.a
packagefile go/scanner=$WORK/b114/_pkg_.a
packagefile go/build/constraint=$WORK/b118/_pkg_.a
packagefile compress/flate=$WORK/b125/_pkg_.a
packagefile hash/crc32=$WORK/b126/_pkg_.a
packagefile crypto/cipher=$WORK/b080/_pkg_.a
packagefile crypto/internal/boring/sig=$WORK/b100/_pkg_.a
packagefile crypto/internal/fips140=$WORK/b082/_pkg_.a
packagefile crypto/internal/fips140deps/byteorder=$WORK/b088/_pkg_.a
packagefile unicode/utf16=$WORK/b107/_pkg_.a
packagefile encoding/base32=$WORK/b110/_pkg_.a
packagefile encoding/base64=$WORK/b111/_pkg_.a
packagefile encoding/hex=$WORK/b112/_pkg_.a
packagefile crypto/internal/fips140/aes=$WORK/b081/_pkg_.a
packagefile crypto/internal/fips140/aes/gcm=$WORK/b094/_pkg_.a
packagefile crypto/internal/fips140/alias=$WORK/b084/_pkg_.a
packagefile crypto/internal/fips140only=$WORK/b097/_pkg_.a
packagefile crypto/subtle=$WORK/b099/_pkg_.a
packagefile crypto/internal/fips140deps/godebug=$WORK/b083/_pkg_.a
packagefile crypto/internal/fips140/check=$WORK/b085/_pkg_.a
packagefile crypto/internal/fips140/subtle=$WORK/b090/_pkg_.a
packagefile crypto/internal/fips140/drbg=$WORK/b095/_pkg_.a
packagefile crypto/fips140=$WORK/b098/_pkg_.a
packagefile crypto/internal/fips140/sha3=$WORK/b089/_pkg_.a
packagefile crypto/internal/fips140/sha512=$WORK/b093/_pkg_.a
packagefile crypto/internal/constanttime=$WORK/b091/_pkg_.a
packagefile crypto/internal/fips140/hmac=$WORK/b086/_pkg_.a
packagefile crypto/internal/sysrand=$WORK/b096/_pkg_.a
packagefile crypto/internal/fips140deps/cpu=$WORK/b092/_pkg_.a
modinfo "0w\xaf\f\x92t\b\x02A\xe1\xc1\a\xe6\xd6\x18\xe6path\ttdemo.test\nmod\ttdemo\t(devel)\t\nbuild\t-buildmode=exe\nbuild\t-compiler=gc\nbuild\tCGO_ENABLED=0\nbuild\tGOARCH=wasm\nbuild\tGOOS=wasip1\n\xf92C1\x86\x18 r\x00\x82B\x10A\x16\xd8\xf2"
EOF
cd .
GOROOT='/home/exedev/e1/goroot' /home/exedev/e1/goroot/pkg/tool/linux_amd64/link -o $WORK/b001/tdemo.test -importcfg $WORK/b001/importcfg.link -buildmode=exe -buildid=9Lptnb8x7b4bIdDN7sxw/Fr3EiUBJDzK98qmafZ_Z/Fr3EiUBJDzK98qmafZ_Z/9Lptnb8x7b4bIdDN7sxw -X testing.testBinary=1 -extld=gcc $WORK/b001/_pkg_.a
go tool buildid -w $WORK/b001/tdemo.test # internal
cat >$WORK/b006/vet.cfg << 'EOF' # internal
{
	"ID": "internal/goarch",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/internal/goarch",
	"ImportPath": "internal/goarch",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/internal/goarch/goarch.go",
		"/home/exedev/e1/goroot/src/internal/goarch/goarch_wasm.go",
		"/home/exedev/e1/goroot/src/internal/goarch/zgoarch_wasm.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [
		"/home/exedev/e1/goroot/src/internal/goarch/gengoarch.go",
		"/home/exedev/e1/goroot/src/internal/goarch/goarch_386.go",
		"/home/exedev/e1/goroot/src/internal/goarch/goarch_amd64.go",
		"/home/exedev/e1/goroot/src/internal/goarch/goarch_arm.go",
		"/home/exedev/e1/goroot/src/internal/goarch/goarch_arm64.go",
		"/home/exedev/e1/goroot/src/internal/goarch/goarch_loong64.go",
		"/home/exedev/e1/goroot/src/internal/goarch/goarch_mips.go",
		"/home/exedev/e1/goroot/src/internal/goarch/goarch_mips64.go",
		"/home/exedev/e1/goroot/src/internal/goarch/goarch_mips64le.go",
		"/home/exedev/e1/goroot/src/internal/goarch/goarch_mipsle.go",
		"/home/exedev/e1/goroot/src/internal/goarch/goarch_ppc64.go",
		"/home/exedev/e1/goroot/src/internal/goarch/goarch_ppc64le.go",
		"/home/exedev/e1/goroot/src/internal/goarch/goarch_riscv64.go",
		"/home/exedev/e1/goroot/src/internal/goarch/goarch_s390x.go",
		"/home/exedev/e1/goroot/src/internal/goarch/zgoarch_386.go",
		"/home/exedev/e1/goroot/src/internal/goarch/zgoarch_amd64.go",
		"/home/exedev/e1/goroot/src/internal/goarch/zgoarch_arm.go",
		"/home/exedev/e1/goroot/src/internal/goarch/zgoarch_arm64.go",
		"/home/exedev/e1/goroot/src/internal/goarch/zgoarch_arm64be.go",
		"/home/exedev/e1/goroot/src/internal/goarch/zgoarch_armbe.go",
		"/home/exedev/e1/goroot/src/internal/goarch/zgoarch_loong64.go",
		"/home/exedev/e1/goroot/src/internal/goarch/zgoarch_mips.go",
		"/home/exedev/e1/goroot/src/internal/goarch/zgoarch_mips64.go",
		"/home/exedev/e1/goroot/src/internal/goarch/zgoarch_mips64le.go",
		"/home/exedev/e1/goroot/src/internal/goarch/zgoarch_mips64p32.go",
		"/home/exedev/e1/goroot/src/internal/goarch/zgoarch_mips64p32le.go",
		"/home/exedev/e1/goroot/src/internal/goarch/zgoarch_mipsle.go",
		"/home/exedev/e1/goroot/src/internal/goarch/zgoarch_ppc.go",
		"/home/exedev/e1/goroot/src/internal/goarch/zgoarch_ppc64.go",
		"/home/exedev/e1/goroot/src/internal/goarch/zgoarch_ppc64le.go",
		"/home/exedev/e1/goroot/src/internal/goarch/zgoarch_riscv.go",
		"/home/exedev/e1/goroot/src/internal/goarch/zgoarch_riscv64.go",
		"/home/exedev/e1/goroot/src/internal/goarch/zgoarch_s390.go",
		"/home/exedev/e1/goroot/src/internal/goarch/zgoarch_s390x.go",
		"/home/exedev/e1/goroot/src/internal/goarch/zgoarch_sparc.go",
		"/home/exedev/e1/goroot/src/internal/goarch/zgoarch_sparc64.go"
	],
	"Module": null,
	"ImportMap": {},
	"PackageFile": {},
	"Standard": {},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b006/vet.out",
	"Stdout": "$WORK/b006/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/internal/goarch
cat >$WORK/b005/vet.cfg << 'EOF' # internal
{
	"ID": "internal/abi",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/internal/abi",
	"ImportPath": "internal/abi",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/internal/abi/abi.go",
		"/home/exedev/e1/goroot/src/internal/abi/abi_generic.go",
		"/home/exedev/e1/goroot/src/internal/abi/bounds.go",
		"/home/exedev/e1/goroot/src/internal/abi/compiletype.go",
		"/home/exedev/e1/goroot/src/internal/abi/escape.go",
		"/home/exedev/e1/goroot/src/internal/abi/funcpc.go",
		"/home/exedev/e1/goroot/src/internal/abi/iface.go",
		"/home/exedev/e1/goroot/src/internal/abi/map.go",
		"/home/exedev/e1/goroot/src/internal/abi/rangefuncconsts.go",
		"/home/exedev/e1/goroot/src/internal/abi/runtime.go",
		"/home/exedev/e1/goroot/src/internal/abi/stack.go",
		"/home/exedev/e1/goroot/src/internal/abi/switch.go",
		"/home/exedev/e1/goroot/src/internal/abi/symtab.go",
		"/home/exedev/e1/goroot/src/internal/abi/type.go"
	],
	"NonGoFiles": [
		"/home/exedev/e1/goroot/src/internal/abi/abi_test.s",
		"/home/exedev/e1/goroot/src/internal/abi/stub.s"
	],
	"IgnoredFiles": [
		"/home/exedev/e1/goroot/src/internal/abi/abi_amd64.go",
		"/home/exedev/e1/goroot/src/internal/abi/abi_arm64.go",
		"/home/exedev/e1/goroot/src/internal/abi/abi_loong64.go",
		"/home/exedev/e1/goroot/src/internal/abi/abi_ppc64x.go",
		"/home/exedev/e1/goroot/src/internal/abi/abi_riscv64.go",
		"/home/exedev/e1/goroot/src/internal/abi/abi_s390x.go",
		"/home/exedev/e1/goroot/src/internal/abi/funcpc_gccgo.go"
	],
	"Module": null,
	"ImportMap": {
		"internal/goarch": "internal/goarch",
		"unsafe": "unsafe"
	},
	"PackageFile": {
		"internal/goarch": "$WORK/b006/_pkg_.a"
	},
	"Standard": {
		"internal/goarch": true,
		"unsafe": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b005/vet.out",
	"Stdout": "$WORK/b005/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/internal/abi
cat >$WORK/b008/vet.cfg << 'EOF' # internal
{
	"ID": "internal/unsafeheader",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/internal/unsafeheader",
	"ImportPath": "internal/unsafeheader",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/internal/unsafeheader/unsafeheader.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [],
	"Module": null,
	"ImportMap": {
		"unsafe": "unsafe"
	},
	"PackageFile": {},
	"Standard": {
		"unsafe": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b008/vet.out",
	"Stdout": "$WORK/b008/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/internal/unsafeheader
cat >$WORK/b011/vet.cfg << 'EOF' # internal
{
	"ID": "internal/cpu",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/internal/cpu",
	"ImportPath": "internal/cpu",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/internal/cpu/cpu.go",
		"/home/exedev/e1/goroot/src/internal/cpu/cpu_no_name.go",
		"/home/exedev/e1/goroot/src/internal/cpu/cpu_wasm.go",
		"/home/exedev/e1/goroot/src/internal/cpu/datacache_unsupported.go"
	],
	"NonGoFiles": [
		"/home/exedev/e1/goroot/src/internal/cpu/cpu.s"
	],
	"IgnoredFiles": [
		"/home/exedev/e1/goroot/src/internal/cpu/cpu_arm.go",
		"/home/exedev/e1/goroot/src/internal/cpu/cpu_arm64.go",
		"/home/exedev/e1/goroot/src/internal/cpu/cpu_arm64_android.go",
		"/home/exedev/e1/goroot/src/internal/cpu/cpu_arm64_darwin.go",
		"/home/exedev/e1/goroot/src/internal/cpu/cpu_arm64_freebsd.go",
		"/home/exedev/e1/goroot/src/internal/cpu/cpu_arm64_hwcap.go",
		"/home/exedev/e1/goroot/src/internal/cpu/cpu_arm64_linux.go",
		"/home/exedev/e1/goroot/src/internal/cpu/cpu_arm64_openbsd.go",
		"/home/exedev/e1/goroot/src/internal/cpu/cpu_arm64_other.go",
		"/home/exedev/e1/goroot/src/internal/cpu/cpu_arm64_windows.go",
		"/home/exedev/e1/goroot/src/internal/cpu/cpu_darwin.go",
		"/home/exedev/e1/goroot/src/internal/cpu/cpu_loong64.go",
		"/home/exedev/e1/goroot/src/internal/cpu/cpu_loong64_hwcap.go",
		"/home/exedev/e1/goroot/src/internal/cpu/cpu_loong64_linux.go",
		"/home/exedev/e1/goroot/src/internal/cpu/cpu_mips.go",
		"/home/exedev/e1/goroot/src/internal/cpu/cpu_mips64x.go",
		"/home/exedev/e1/goroot/src/internal/cpu/cpu_mipsle.go",
		"/home/exedev/e1/goroot/src/internal/cpu/cpu_ppc64x.go",
		"/home/exedev/e1/goroot/src/internal/cpu/cpu_ppc64x_aix.go",
		"/home/exedev/e1/goroot/src/internal/cpu/cpu_ppc64x_linux.go",
		"/home/exedev/e1/goroot/src/internal/cpu/cpu_ppc64x_other.go",
		"/home/exedev/e1/goroot/src/internal/cpu/cpu_riscv64.go",
		"/home/exedev/e1/goroot/src/internal/cpu/cpu_riscv64_linux.go",
		"/home/exedev/e1/goroot/src/internal/cpu/cpu_riscv64_other.go",
		"/home/exedev/e1/goroot/src/internal/cpu/cpu_s390x.go",
		"/home/exedev/e1/goroot/src/internal/cpu/cpu_s390x_test.go",
		"/home/exedev/e1/goroot/src/internal/cpu/cpu_windows.go",
		"/home/exedev/e1/goroot/src/internal/cpu/cpu_windows_test.go",
		"/home/exedev/e1/goroot/src/internal/cpu/cpu_x86.go",
		"/home/exedev/e1/goroot/src/internal/cpu/cpu_x86_darwin.go",
		"/home/exedev/e1/goroot/src/internal/cpu/cpu_x86_netbsd.go",
		"/home/exedev/e1/goroot/src/internal/cpu/cpu_x86_other.go",
		"/home/exedev/e1/goroot/src/internal/cpu/cpu_x86_test.go",
		"/home/exedev/e1/goroot/src/internal/cpu/datacache_x86.go",
		"/home/exedev/e1/goroot/src/internal/cpu/datacache_x86_test.go",
		"/home/exedev/e1/goroot/src/internal/cpu/export_x86_test.go",
		"/home/exedev/e1/goroot/src/internal/cpu/cpu_arm64.s",
		"/home/exedev/e1/goroot/src/internal/cpu/cpu_loong64.s",
		"/home/exedev/e1/goroot/src/internal/cpu/cpu_s390x.s",
		"/home/exedev/e1/goroot/src/internal/cpu/cpu_x86.s"
	],
	"Module": null,
	"ImportMap": {
		"unsafe": "unsafe"
	},
	"PackageFile": {},
	"Standard": {
		"unsafe": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b011/vet.out",
	"Stdout": "$WORK/b011/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/internal/cpu
cat >$WORK/b010/vet.cfg << 'EOF' # internal
{
	"ID": "internal/bytealg",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/internal/bytealg",
	"ImportPath": "internal/bytealg",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/internal/bytealg/bytealg.go",
		"/home/exedev/e1/goroot/src/internal/bytealg/compare_native.go",
		"/home/exedev/e1/goroot/src/internal/bytealg/count_generic.go",
		"/home/exedev/e1/goroot/src/internal/bytealg/equal_generic.go",
		"/home/exedev/e1/goroot/src/internal/bytealg/equal_native.go",
		"/home/exedev/e1/goroot/src/internal/bytealg/index_generic.go",
		"/home/exedev/e1/goroot/src/internal/bytealg/indexbyte_native.go",
		"/home/exedev/e1/goroot/src/internal/bytealg/lastindexbyte_generic.go"
	],
	"NonGoFiles": [
		"/home/exedev/e1/goroot/src/internal/bytealg/compare_wasm.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/equal_wasm.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/indexbyte_wasm.s"
	],
	"IgnoredFiles": [
		"/home/exedev/e1/goroot/src/internal/bytealg/compare_generic.go",
		"/home/exedev/e1/goroot/src/internal/bytealg/count_native.go",
		"/home/exedev/e1/goroot/src/internal/bytealg/index_amd64.go",
		"/home/exedev/e1/goroot/src/internal/bytealg/index_arm64.go",
		"/home/exedev/e1/goroot/src/internal/bytealg/index_loong64.go",
		"/home/exedev/e1/goroot/src/internal/bytealg/index_native.go",
		"/home/exedev/e1/goroot/src/internal/bytealg/index_ppc64x.go",
		"/home/exedev/e1/goroot/src/internal/bytealg/index_s390x.go",
		"/home/exedev/e1/goroot/src/internal/bytealg/indexbyte_generic.go",
		"/home/exedev/e1/goroot/src/internal/bytealg/compare_386.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/compare_amd64.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/compare_arm.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/compare_arm64.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/compare_loong64.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/compare_mips64x.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/compare_mipsx.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/compare_ppc64x.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/compare_riscv64.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/compare_s390x.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/count_amd64.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/count_arm.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/count_arm64.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/count_loong64.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/count_mips64x.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/count_ppc64x.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/count_riscv64.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/count_s390x.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/equal_386.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/equal_amd64.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/equal_arm.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/equal_arm64.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/equal_loong64.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/equal_mips64x.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/equal_mipsx.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/equal_ppc64x.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/equal_riscv64.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/equal_s390x.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/index_amd64.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/index_arm64.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/index_loong64.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/index_ppc64x.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/index_s390x.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/indexbyte_386.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/indexbyte_amd64.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/indexbyte_arm.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/indexbyte_arm64.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/indexbyte_loong64.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/indexbyte_mips64x.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/indexbyte_mipsx.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/indexbyte_ppc64x.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/indexbyte_riscv64.s",
		"/home/exedev/e1/goroot/src/internal/bytealg/indexbyte_s390x.s"
	],
	"Module": null,
	"ImportMap": {
		"internal/cpu": "internal/cpu",
		"unsafe": "unsafe"
	},
	"PackageFile": {
		"internal/cpu": "$WORK/b011/_pkg_.a"
	},
	"Standard": {
		"internal/cpu": true,
		"unsafe": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b010/vet.out",
	"Stdout": "$WORK/b010/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/internal/bytealg
cat >$WORK/b012/vet.cfg << 'EOF' # internal
{
	"ID": "internal/byteorder",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/internal/byteorder",
	"ImportPath": "internal/byteorder",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/internal/byteorder/byteorder.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [],
	"Module": null,
	"ImportMap": {},
	"PackageFile": {},
	"Standard": {},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b012/vet.out",
	"Stdout": "$WORK/b012/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/internal/byteorder
cat >$WORK/b013/vet.cfg << 'EOF' # internal
{
	"ID": "internal/chacha8rand",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/internal/chacha8rand",
	"ImportPath": "internal/chacha8rand",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/internal/chacha8rand/chacha8.go",
		"/home/exedev/e1/goroot/src/internal/chacha8rand/chacha8_generic.go"
	],
	"NonGoFiles": [
		"/home/exedev/e1/goroot/src/internal/chacha8rand/chacha8_stub.s"
	],
	"IgnoredFiles": [
		"/home/exedev/e1/goroot/src/internal/chacha8rand/chacha8_amd64.s",
		"/home/exedev/e1/goroot/src/internal/chacha8rand/chacha8_arm64.s",
		"/home/exedev/e1/goroot/src/internal/chacha8rand/chacha8_loong64.s",
		"/home/exedev/e1/goroot/src/internal/chacha8rand/chacha8_riscv64.s"
	],
	"Module": null,
	"ImportMap": {
		"internal/byteorder": "internal/byteorder",
		"internal/cpu": "internal/cpu",
		"internal/goarch": "internal/goarch",
		"unsafe": "unsafe"
	},
	"PackageFile": {
		"internal/byteorder": "$WORK/b012/_pkg_.a",
		"internal/cpu": "$WORK/b011/_pkg_.a",
		"internal/goarch": "$WORK/b006/_pkg_.a"
	},
	"Standard": {
		"internal/byteorder": true,
		"internal/cpu": true,
		"internal/goarch": true,
		"unsafe": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b013/vet.out",
	"Stdout": "$WORK/b013/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/internal/chacha8rand
cat >$WORK/b014/vet.cfg << 'EOF' # internal
{
	"ID": "internal/coverage/rtcov",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/internal/coverage/rtcov",
	"ImportPath": "internal/coverage/rtcov",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/internal/coverage/rtcov/rtcov.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [],
	"Module": null,
	"ImportMap": {
		"unsafe": "unsafe"
	},
	"PackageFile": {},
	"Standard": {
		"unsafe": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b014/vet.out",
	"Stdout": "$WORK/b014/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/internal/coverage/rtcov
cat >$WORK/b015/vet.cfg << 'EOF' # internal
{
	"ID": "internal/godebugs",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/internal/godebugs",
	"ImportPath": "internal/godebugs",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/internal/godebugs/table.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [],
	"Module": null,
	"ImportMap": {},
	"PackageFile": {},
	"Standard": {},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b015/vet.out",
	"Stdout": "$WORK/b015/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/internal/godebugs
cat >$WORK/b016/vet.cfg << 'EOF' # internal
{
	"ID": "internal/goexperiment",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/internal/goexperiment",
	"ImportPath": "internal/goexperiment",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/internal/goexperiment/exp_arenas_off.go",
		"/home/exedev/e1/goroot/src/internal/goexperiment/exp_boringcrypto_off.go",
		"/home/exedev/e1/goroot/src/internal/goexperiment/exp_cgocheck2_off.go",
		"/home/exedev/e1/goroot/src/internal/goexperiment/exp_dwarf5_on.go",
		"/home/exedev/e1/goroot/src/internal/goexperiment/exp_fieldtrack_off.go",
		"/home/exedev/e1/goroot/src/internal/goexperiment/exp_greenteagc_on.go",
		"/home/exedev/e1/goroot/src/internal/goexperiment/exp_heapminimum512kib_off.go",
		"/home/exedev/e1/goroot/src/internal/goexperiment/exp_jsonv2_on.go",
		"/home/exedev/e1/goroot/src/internal/goexperiment/exp_loopvar_off.go",
		"/home/exedev/e1/goroot/src/internal/goexperiment/exp_mapsplitgroup_off.go",
		"/home/exedev/e1/goroot/src/internal/goexperiment/exp_newinliner_off.go",
		"/home/exedev/e1/goroot/src/internal/goexperiment/exp_preemptibleloops_off.go",
		"/home/exedev/e1/goroot/src/internal/goexperiment/exp_randomizedheapbase64_on.go",
		"/home/exedev/e1/goroot/src/internal/goexperiment/exp_regabiargs_off.go",
		"/home/exedev/e1/goroot/src/internal/goexperiment/exp_regabiwrappers_off.go",
		"/home/exedev/e1/goroot/src/internal/goexperiment/exp_runtimefreegc_off.go",
		"/home/exedev/e1/goroot/src/internal/goexperiment/exp_runtimesecret_off.go",
		"/home/exedev/e1/goroot/src/internal/goexperiment/exp_simd_off.go",
		"/home/exedev/e1/goroot/src/internal/goexperiment/exp_sizespecializedmalloc_on.go",
		"/home/exedev/e1/goroot/src/internal/goexperiment/exp_staticlockranking_off.go",
		"/home/exedev/e1/goroot/src/internal/goexperiment/flags.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [
		"/home/exedev/e1/goroot/src/internal/goexperiment/exp_arenas_on.go",
		"/home/exedev/e1/goroot/src/internal/goexperiment/exp_boringcrypto_on.go",
		"/home/exedev/e1/goroot/src/internal/goexperiment/exp_cgocheck2_on.go",
		"/home/exedev/e1/goroot/src/internal/goexperiment/exp_dwarf5_off.go",
		"/home/exedev/e1/goroot/src/internal/goexperiment/exp_fieldtrack_on.go",
		"/home/exedev/e1/goroot/src/internal/goexperiment/exp_greenteagc_off.go",
		"/home/exedev/e1/goroot/src/internal/goexperiment/exp_heapminimum512kib_on.go",
		"/home/exedev/e1/goroot/src/internal/goexperiment/exp_jsonv2_off.go",
		"/home/exedev/e1/goroot/src/internal/goexperiment/exp_loopvar_on.go",
		"/home/exedev/e1/goroot/src/internal/goexperiment/exp_mapsplitgroup_on.go",
		"/home/exedev/e1/goroot/src/internal/goexperiment/exp_newinliner_on.go",
		"/home/exedev/e1/goroot/src/internal/goexperiment/exp_preemptibleloops_on.go",
		"/home/exedev/e1/goroot/src/internal/goexperiment/exp_randomizedheapbase64_off.go",
		"/home/exedev/e1/goroot/src/internal/goexperiment/exp_regabiargs_on.go",
		"/home/exedev/e1/goroot/src/internal/goexperiment/exp_regabiwrappers_on.go",
		"/home/exedev/e1/goroot/src/internal/goexperiment/exp_runtimefreegc_on.go",
		"/home/exedev/e1/goroot/src/internal/goexperiment/exp_runtimesecret_on.go",
		"/home/exedev/e1/goroot/src/internal/goexperiment/exp_simd_on.go",
		"/home/exedev/e1/goroot/src/internal/goexperiment/exp_sizespecializedmalloc_off.go",
		"/home/exedev/e1/goroot/src/internal/goexperiment/exp_staticlockranking_on.go",
		"/home/exedev/e1/goroot/src/internal/goexperiment/mkconsts.go"
	],
	"Module": null,
	"ImportMap": {},
	"PackageFile": {},
	"Standard": {},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b016/vet.out",
	"Stdout": "$WORK/b016/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/internal/goexperiment
cat >$WORK/b017/vet.cfg << 'EOF' # internal
{
	"ID": "internal/goos",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/internal/goos",
	"ImportPath": "internal/goos",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/internal/goos/goos.go",
		"/home/exedev/e1/goroot/src/internal/goos/nonunix.go",
		"/home/exedev/e1/goroot/src/internal/goos/zgoos_wasip1.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [
		"/home/exedev/e1/goroot/src/internal/goos/gengoos.go",
		"/home/exedev/e1/goroot/src/internal/goos/unix.go",
		"/home/exedev/e1/goroot/src/internal/goos/zgoos_aix.go",
		"/home/exedev/e1/goroot/src/internal/goos/zgoos_android.go",
		"/home/exedev/e1/goroot/src/internal/goos/zgoos_darwin.go",
		"/home/exedev/e1/goroot/src/internal/goos/zgoos_dragonfly.go",
		"/home/exedev/e1/goroot/src/internal/goos/zgoos_freebsd.go",
		"/home/exedev/e1/goroot/src/internal/goos/zgoos_hurd.go",
		"/home/exedev/e1/goroot/src/internal/goos/zgoos_illumos.go",
		"/home/exedev/e1/goroot/src/internal/goos/zgoos_ios.go",
		"/home/exedev/e1/goroot/src/internal/goos/zgoos_js.go",
		"/home/exedev/e1/goroot/src/internal/goos/zgoos_linux.go",
		"/home/exedev/e1/goroot/src/internal/goos/zgoos_netbsd.go",
		"/home/exedev/e1/goroot/src/internal/goos/zgoos_openbsd.go",
		"/home/exedev/e1/goroot/src/internal/goos/zgoos_plan9.go",
		"/home/exedev/e1/goroot/src/internal/goos/zgoos_solaris.go",
		"/home/exedev/e1/goroot/src/internal/goos/zgoos_windows.go",
		"/home/exedev/e1/goroot/src/internal/goos/zgoos_zos.go"
	],
	"Module": null,
	"ImportMap": {},
	"PackageFile": {},
	"Standard": {},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b017/vet.out",
	"Stdout": "$WORK/b017/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/internal/goos
cat >$WORK/b018/vet.cfg << 'EOF' # internal
{
	"ID": "internal/profilerecord",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/internal/profilerecord",
	"ImportPath": "internal/profilerecord",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/internal/profilerecord/profilerecord.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [],
	"Module": null,
	"ImportMap": {},
	"PackageFile": {},
	"Standard": {},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b018/vet.out",
	"Stdout": "$WORK/b018/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/internal/profilerecord
cat >$WORK/b019/vet.cfg << 'EOF' # internal
{
	"ID": "internal/runtime/atomic",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/internal/runtime/atomic",
	"ImportPath": "internal/runtime/atomic",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/internal/runtime/atomic/atomic_andor_generic.go",
		"/home/exedev/e1/goroot/src/internal/runtime/atomic/atomic_wasm.go",
		"/home/exedev/e1/goroot/src/internal/runtime/atomic/doc.go",
		"/home/exedev/e1/goroot/src/internal/runtime/atomic/linkname.go",
		"/home/exedev/e1/goroot/src/internal/runtime/atomic/types.go",
		"/home/exedev/e1/goroot/src/internal/runtime/atomic/types_64bit.go",
		"/home/exedev/e1/goroot/src/internal/runtime/atomic/unaligned.go",
		"/home/exedev/e1/goroot/src/internal/runtime/atomic/xchg8.go"
	],
	"NonGoFiles": [
		"/home/exedev/e1/goroot/src/internal/runtime/atomic/atomic_wasm.s"
	],
	"IgnoredFiles": [
		"/home/exedev/e1/goroot/src/internal/runtime/atomic/atomic_386.go",
		"/home/exedev/e1/goroot/src/internal/runtime/atomic/atomic_amd64.go",
		"/home/exedev/e1/goroot/src/internal/runtime/atomic/atomic_arm.go",
		"/home/exedev/e1/goroot/src/internal/runtime/atomic/atomic_arm64.go",
		"/home/exedev/e1/goroot/src/internal/runtime/atomic/atomic_loong64.go",
		"/home/exedev/e1/goroot/src/internal/runtime/atomic/atomic_mips64x.go",
		"/home/exedev/e1/goroot/src/internal/runtime/atomic/atomic_mipsx.go",
		"/home/exedev/e1/goroot/src/internal/runtime/atomic/atomic_ppc64x.go",
		"/home/exedev/e1/goroot/src/internal/runtime/atomic/atomic_riscv64.go",
		"/home/exedev/e1/goroot/src/internal/runtime/atomic/atomic_s390x.go",
		"/home/exedev/e1/goroot/src/internal/runtime/atomic/stubs.go",
		"/home/exedev/e1/goroot/src/internal/runtime/atomic/atomic_386.s",
		"/home/exedev/e1/goroot/src/internal/runtime/atomic/atomic_amd64.s",
		"/home/exedev/e1/goroot/src/internal/runtime/atomic/atomic_arm.s",
		"/home/exedev/e1/goroot/src/internal/runtime/atomic/atomic_arm64.s",
		"/home/exedev/e1/goroot/src/internal/runtime/atomic/atomic_loong64.s",
		"/home/exedev/e1/goroot/src/internal/runtime/atomic/atomic_mips64x.s",
		"/home/exedev/e1/goroot/src/internal/runtime/atomic/atomic_mipsx.s",
		"/home/exedev/e1/goroot/src/internal/runtime/atomic/atomic_ppc64x.s",
		"/home/exedev/e1/goroot/src/internal/runtime/atomic/atomic_riscv64.s",
		"/home/exedev/e1/goroot/src/internal/runtime/atomic/atomic_s390x.s",
		"/home/exedev/e1/goroot/src/internal/runtime/atomic/sys_linux_arm.s",
		"/home/exedev/e1/goroot/src/internal/runtime/atomic/sys_nonlinux_arm.s"
	],
	"Module": null,
	"ImportMap": {
		"internal/goarch": "internal/goarch",
		"unsafe": "unsafe"
	},
	"PackageFile": {
		"internal/goarch": "$WORK/b006/_pkg_.a"
	},
	"Standard": {
		"internal/goarch": true,
		"unsafe": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b019/vet.out",
	"Stdout": "$WORK/b019/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/internal/runtime/atomic
cat >$WORK/b020/vet.cfg << 'EOF' # internal
{
	"ID": "internal/runtime/exithook",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/internal/runtime/exithook",
	"ImportPath": "internal/runtime/exithook",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/internal/runtime/exithook/hooks.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [],
	"Module": null,
	"ImportMap": {
		"internal/runtime/atomic": "internal/runtime/atomic",
		"unsafe": "unsafe"
	},
	"PackageFile": {
		"internal/runtime/atomic": "$WORK/b019/_pkg_.a"
	},
	"Standard": {
		"internal/runtime/atomic": true,
		"unsafe": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b020/vet.out",
	"Stdout": "$WORK/b020/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/internal/runtime/exithook
cat >$WORK/b021/vet.cfg << 'EOF' # internal
{
	"ID": "internal/runtime/gc",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/internal/runtime/gc",
	"ImportPath": "internal/runtime/gc",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/internal/runtime/gc/malloc.go",
		"/home/exedev/e1/goroot/src/internal/runtime/gc/scan.go",
		"/home/exedev/e1/goroot/src/internal/runtime/gc/sizeclasses.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [],
	"Module": null,
	"ImportMap": {
		"internal/goarch": "internal/goarch"
	},
	"PackageFile": {
		"internal/goarch": "$WORK/b006/_pkg_.a"
	},
	"Standard": {
		"internal/goarch": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b021/vet.out",
	"Stdout": "$WORK/b021/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/internal/runtime/gc
cat >$WORK/b023/vet.cfg << 'EOF' # internal
{
	"ID": "internal/runtime/sys",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/internal/runtime/sys",
	"ImportPath": "internal/runtime/sys",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/internal/runtime/sys/consts.go",
		"/home/exedev/e1/goroot/src/internal/runtime/sys/consts_norace.go",
		"/home/exedev/e1/goroot/src/internal/runtime/sys/intrinsics.go",
		"/home/exedev/e1/goroot/src/internal/runtime/sys/nih.go",
		"/home/exedev/e1/goroot/src/internal/runtime/sys/no_dit.go",
		"/home/exedev/e1/goroot/src/internal/runtime/sys/sys.go",
		"/home/exedev/e1/goroot/src/internal/runtime/sys/zversion.go"
	],
	"NonGoFiles": [
		"/home/exedev/e1/goroot/src/internal/runtime/sys/empty.s"
	],
	"IgnoredFiles": [
		"/home/exedev/e1/goroot/src/internal/runtime/sys/consts_race.go",
		"/home/exedev/e1/goroot/src/internal/runtime/sys/dit_arm64.go",
		"/home/exedev/e1/goroot/src/internal/runtime/sys/dit_arm64.s"
	],
	"Module": null,
	"ImportMap": {
		"internal/goarch": "internal/goarch",
		"internal/goos": "internal/goos"
	},
	"PackageFile": {
		"internal/goarch": "$WORK/b006/_pkg_.a",
		"internal/goos": "$WORK/b017/_pkg_.a"
	},
	"Standard": {
		"internal/goarch": true,
		"internal/goos": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b023/vet.out",
	"Stdout": "$WORK/b023/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/internal/runtime/sys
cat >$WORK/b022/vet.cfg << 'EOF' # internal
{
	"ID": "internal/runtime/gc/scan",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/internal/runtime/gc/scan",
	"ImportPath": "internal/runtime/gc/scan",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/internal/runtime/gc/scan/expand_reference.go",
		"/home/exedev/e1/goroot/src/internal/runtime/gc/scan/filter.go",
		"/home/exedev/e1/goroot/src/internal/runtime/gc/scan/scan_generic.go",
		"/home/exedev/e1/goroot/src/internal/runtime/gc/scan/scan_go.go",
		"/home/exedev/e1/goroot/src/internal/runtime/gc/scan/scan_reference.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [
		"/home/exedev/e1/goroot/src/internal/runtime/gc/scan/expand_amd64.go",
		"/home/exedev/e1/goroot/src/internal/runtime/gc/scan/expand_amd64_test.go",
		"/home/exedev/e1/goroot/src/internal/runtime/gc/scan/filter_amd64.go",
		"/home/exedev/e1/goroot/src/internal/runtime/gc/scan/filter_amd64_test.go",
		"/home/exedev/e1/goroot/src/internal/runtime/gc/scan/mem_unix_test.go",
		"/home/exedev/e1/goroot/src/internal/runtime/gc/scan/mkasm.go",
		"/home/exedev/e1/goroot/src/internal/runtime/gc/scan/scan_amd64.go",
		"/home/exedev/e1/goroot/src/internal/runtime/gc/scan/scan_amd64_test.go",
		"/home/exedev/e1/goroot/src/internal/runtime/gc/scan/expand_amd64.s",
		"/home/exedev/e1/goroot/src/internal/runtime/gc/scan/filter_amd64.s",
		"/home/exedev/e1/goroot/src/internal/runtime/gc/scan/scan_amd64.s"
	],
	"Module": null,
	"ImportMap": {
		"internal/goarch": "internal/goarch",
		"internal/runtime/gc": "internal/runtime/gc",
		"internal/runtime/sys": "internal/runtime/sys",
		"unsafe": "unsafe"
	},
	"PackageFile": {
		"internal/goarch": "$WORK/b006/_pkg_.a",
		"internal/runtime/gc": "$WORK/b021/_pkg_.a",
		"internal/runtime/sys": "$WORK/b023/_pkg_.a"
	},
	"Standard": {
		"internal/goarch": true,
		"internal/runtime/gc": true,
		"internal/runtime/sys": true,
		"unsafe": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b022/vet.out",
	"Stdout": "$WORK/b022/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/internal/runtime/gc/scan
cat >$WORK/b025/vet.cfg << 'EOF' # internal
{
	"ID": "internal/asan",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/internal/asan",
	"ImportPath": "internal/asan",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/internal/asan/doc.go",
		"/home/exedev/e1/goroot/src/internal/asan/noasan.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [
		"/home/exedev/e1/goroot/src/internal/asan/asan.go"
	],
	"Module": null,
	"ImportMap": {
		"unsafe": "unsafe"
	},
	"PackageFile": {},
	"Standard": {
		"unsafe": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b025/vet.out",
	"Stdout": "$WORK/b025/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/internal/asan
cat >$WORK/b026/vet.cfg << 'EOF' # internal
{
	"ID": "internal/msan",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/internal/msan",
	"ImportPath": "internal/msan",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/internal/msan/doc.go",
		"/home/exedev/e1/goroot/src/internal/msan/nomsan.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [
		"/home/exedev/e1/goroot/src/internal/msan/msan.go"
	],
	"Module": null,
	"ImportMap": {
		"unsafe": "unsafe"
	},
	"PackageFile": {},
	"Standard": {
		"unsafe": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b026/vet.out",
	"Stdout": "$WORK/b026/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/internal/msan
cat >$WORK/b027/vet.cfg << 'EOF' # internal
{
	"ID": "internal/race",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/internal/race",
	"ImportPath": "internal/race",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/internal/race/doc.go",
		"/home/exedev/e1/goroot/src/internal/race/norace.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [
		"/home/exedev/e1/goroot/src/internal/race/race.go"
	],
	"Module": null,
	"ImportMap": {
		"internal/abi": "internal/abi",
		"unsafe": "unsafe"
	},
	"PackageFile": {
		"internal/abi": "$WORK/b005/_pkg_.a"
	},
	"Standard": {
		"internal/abi": true,
		"unsafe": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b027/vet.out",
	"Stdout": "$WORK/b027/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/internal/race
cat >$WORK/b028/vet.cfg << 'EOF' # internal
{
	"ID": "internal/runtime/math",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/internal/runtime/math",
	"ImportPath": "internal/runtime/math",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/internal/runtime/math/math.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [],
	"Module": null,
	"ImportMap": {
		"internal/goarch": "internal/goarch"
	},
	"PackageFile": {
		"internal/goarch": "$WORK/b006/_pkg_.a"
	},
	"Standard": {
		"internal/goarch": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b028/vet.out",
	"Stdout": "$WORK/b028/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/internal/runtime/math
cat >$WORK/b024/vet.cfg << 'EOF' # internal
{
	"ID": "internal/runtime/maps",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/internal/runtime/maps",
	"ImportPath": "internal/runtime/maps",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/internal/runtime/maps/group.go",
		"/home/exedev/e1/goroot/src/internal/runtime/maps/map.go",
		"/home/exedev/e1/goroot/src/internal/runtime/maps/memhash_align_nocheck.go",
		"/home/exedev/e1/goroot/src/internal/runtime/maps/memhash_noaes.go",
		"/home/exedev/e1/goroot/src/internal/runtime/maps/runtime.go",
		"/home/exedev/e1/goroot/src/internal/runtime/maps/runtime_alg.go",
		"/home/exedev/e1/goroot/src/internal/runtime/maps/runtime_fast32.go",
		"/home/exedev/e1/goroot/src/internal/runtime/maps/runtime_fast64.go",
		"/home/exedev/e1/goroot/src/internal/runtime/maps/runtime_faststr.go",
		"/home/exedev/e1/goroot/src/internal/runtime/maps/runtime_hash32.go",
		"/home/exedev/e1/goroot/src/internal/runtime/maps/table.go",
		"/home/exedev/e1/goroot/src/internal/runtime/maps/table_debug.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [
		"/home/exedev/e1/goroot/src/internal/runtime/maps/memhash_aes.go",
		"/home/exedev/e1/goroot/src/internal/runtime/maps/memhash_aes_asm.go",
		"/home/exedev/e1/goroot/src/internal/runtime/maps/memhash_aes_simd.go",
		"/home/exedev/e1/goroot/src/internal/runtime/maps/memhash_align_check.go",
		"/home/exedev/e1/goroot/src/internal/runtime/maps/runtime_hash64.go",
		"/home/exedev/e1/goroot/src/internal/runtime/maps/memhash_386.s",
		"/home/exedev/e1/goroot/src/internal/runtime/maps/memhash_amd64.s",
		"/home/exedev/e1/goroot/src/internal/runtime/maps/memhash_arm64.s",
		"/home/exedev/e1/goroot/src/internal/runtime/maps/memhash_nosimd_amd64.s"
	],
	"Module": null,
	"ImportMap": {
		"internal/abi": "internal/abi",
		"internal/asan": "internal/asan",
		"internal/byteorder": "internal/byteorder",
		"internal/cpu": "internal/cpu",
		"internal/goarch": "internal/goarch",
		"internal/goexperiment": "internal/goexperiment",
		"internal/msan": "internal/msan",
		"internal/race": "internal/race",
		"internal/runtime/math": "internal/runtime/math",
		"internal/runtime/sys": "internal/runtime/sys",
		"unsafe": "unsafe"
	},
	"PackageFile": {
		"internal/abi": "$WORK/b005/_pkg_.a",
		"internal/asan": "$WORK/b025/_pkg_.a",
		"internal/byteorder": "$WORK/b012/_pkg_.a",
		"internal/cpu": "$WORK/b011/_pkg_.a",
		"internal/goarch": "$WORK/b006/_pkg_.a",
		"internal/goexperiment": "$WORK/b016/_pkg_.a",
		"internal/msan": "$WORK/b026/_pkg_.a",
		"internal/race": "$WORK/b027/_pkg_.a",
		"internal/runtime/math": "$WORK/b028/_pkg_.a",
		"internal/runtime/sys": "$WORK/b023/_pkg_.a"
	},
	"Standard": {
		"internal/abi": true,
		"internal/asan": true,
		"internal/byteorder": true,
		"internal/cpu": true,
		"internal/goarch": true,
		"internal/goexperiment": true,
		"internal/msan": true,
		"internal/race": true,
		"internal/runtime/math": true,
		"internal/runtime/sys": true,
		"unsafe": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b024/vet.out",
	"Stdout": "$WORK/b024/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/internal/runtime/maps
cat >$WORK/b029/vet.cfg << 'EOF' # internal
{
	"ID": "internal/runtime/pprof/label",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/internal/runtime/pprof/label",
	"ImportPath": "internal/runtime/pprof/label",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/internal/runtime/pprof/label/labelset.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [],
	"Module": null,
	"ImportMap": {},
	"PackageFile": {},
	"Standard": {},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b029/vet.out",
	"Stdout": "$WORK/b029/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/internal/runtime/pprof/label
cat >$WORK/b031/vet.cfg << 'EOF' # internal
{
	"ID": "math/bits",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/math/bits",
	"ImportPath": "math/bits",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/math/bits/bits.go",
		"/home/exedev/e1/goroot/src/math/bits/bits_errors.go",
		"/home/exedev/e1/goroot/src/math/bits/bits_tables.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [
		"/home/exedev/e1/goroot/src/math/bits/bits_errors_bootstrap.go",
		"/home/exedev/e1/goroot/src/math/bits/make_examples.go",
		"/home/exedev/e1/goroot/src/math/bits/make_tables.go"
	],
	"Module": null,
	"ImportMap": {
		"unsafe": "unsafe"
	},
	"PackageFile": {},
	"Standard": {
		"unsafe": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b031/vet.out",
	"Stdout": "$WORK/b031/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/math/bits
cat >$WORK/b030/vet.cfg << 'EOF' # internal
{
	"ID": "internal/strconv",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/internal/strconv",
	"ImportPath": "internal/strconv",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/internal/strconv/atob.go",
		"/home/exedev/e1/goroot/src/internal/strconv/atoc.go",
		"/home/exedev/e1/goroot/src/internal/strconv/atof.go",
		"/home/exedev/e1/goroot/src/internal/strconv/atoi.go",
		"/home/exedev/e1/goroot/src/internal/strconv/ctoa.go",
		"/home/exedev/e1/goroot/src/internal/strconv/decimal.go",
		"/home/exedev/e1/goroot/src/internal/strconv/deps.go",
		"/home/exedev/e1/goroot/src/internal/strconv/ftoa.go",
		"/home/exedev/e1/goroot/src/internal/strconv/itoa.go",
		"/home/exedev/e1/goroot/src/internal/strconv/pow10tab.go",
		"/home/exedev/e1/goroot/src/internal/strconv/uscale.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [
		"/home/exedev/e1/goroot/src/internal/strconv/pow10gen.go"
	],
	"Module": null,
	"ImportMap": {
		"math/bits": "math/bits",
		"unsafe": "unsafe"
	},
	"PackageFile": {
		"math/bits": "$WORK/b031/_pkg_.a"
	},
	"Standard": {
		"math/bits": true,
		"unsafe": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b030/vet.out",
	"Stdout": "$WORK/b030/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/internal/strconv
cat >$WORK/b032/vet.cfg << 'EOF' # internal
{
	"ID": "internal/stringslite",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/internal/stringslite",
	"ImportPath": "internal/stringslite",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/internal/stringslite/strings.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [],
	"Module": null,
	"ImportMap": {
		"internal/bytealg": "internal/bytealg",
		"unsafe": "unsafe"
	},
	"PackageFile": {
		"internal/bytealg": "$WORK/b010/_pkg_.a"
	},
	"Standard": {
		"internal/bytealg": true,
		"unsafe": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b032/vet.out",
	"Stdout": "$WORK/b032/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/internal/stringslite
cat >$WORK/b033/vet.cfg << 'EOF' # internal
{
	"ID": "internal/trace/tracev2",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/internal/trace/tracev2",
	"ImportPath": "internal/trace/tracev2",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/internal/trace/tracev2/doc.go",
		"/home/exedev/e1/goroot/src/internal/trace/tracev2/events.go",
		"/home/exedev/e1/goroot/src/internal/trace/tracev2/spec.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [],
	"Module": null,
	"ImportMap": {},
	"PackageFile": {},
	"Standard": {},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b033/vet.out",
	"Stdout": "$WORK/b033/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/internal/trace/tracev2
cat >$WORK/b034/vet.cfg << 'EOF' # internal
{
	"ID": "structs",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/structs",
	"ImportPath": "structs",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/structs/doc.go",
		"/home/exedev/e1/goroot/src/structs/hostlayout.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [],
	"Module": null,
	"ImportMap": {},
	"PackageFile": {},
	"Standard": {},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b034/vet.out",
	"Stdout": "$WORK/b034/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/structs
cat >$WORK/b009/vet.cfg << 'EOF' # internal
{
	"ID": "runtime",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/runtime",
	"ImportPath": "runtime",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/runtime/alg.go",
		"/home/exedev/e1/goroot/src/runtime/arena.go",
		"/home/exedev/e1/goroot/src/runtime/asan0.go",
		"/home/exedev/e1/goroot/src/runtime/atomic_pointer.go",
		"/home/exedev/e1/goroot/src/runtime/auxv_none.go",
		"/home/exedev/e1/goroot/src/runtime/badlinkname.go",
		"/home/exedev/e1/goroot/src/runtime/cgo.go",
		"/home/exedev/e1/goroot/src/runtime/cgocall.go",
		"/home/exedev/e1/goroot/src/runtime/cgocallback.go",
		"/home/exedev/e1/goroot/src/runtime/cgocheck.go",
		"/home/exedev/e1/goroot/src/runtime/cgroup_stubs.go",
		"/home/exedev/e1/goroot/src/runtime/chan.go",
		"/home/exedev/e1/goroot/src/runtime/checkptr.go",
		"/home/exedev/e1/goroot/src/runtime/compiler.go",
		"/home/exedev/e1/goroot/src/runtime/complex.go",
		"/home/exedev/e1/goroot/src/runtime/coro.go",
		"/home/exedev/e1/goroot/src/runtime/covercounter.go",
		"/home/exedev/e1/goroot/src/runtime/covermeta.go",
		"/home/exedev/e1/goroot/src/runtime/cpuflags.go",
		"/home/exedev/e1/goroot/src/runtime/cpuprof.go",
		"/home/exedev/e1/goroot/src/runtime/create_file_nounix.go",
		"/home/exedev/e1/goroot/src/runtime/debug.go",
		"/home/exedev/e1/goroot/src/runtime/debuglog.go",
		"/home/exedev/e1/goroot/src/runtime/debuglog_off.go",
		"/home/exedev/e1/goroot/src/runtime/dit.go",
		"/home/exedev/e1/goroot/src/runtime/env_posix.go",
		"/home/exedev/e1/goroot/src/runtime/error.go",
		"/home/exedev/e1/goroot/src/runtime/extern.go",
		"/home/exedev/e1/goroot/src/runtime/fastlog2.go",
		"/home/exedev/e1/goroot/src/runtime/fastlog2table.go",
		"/home/exedev/e1/goroot/src/runtime/fds_nonunix.go",
		"/home/exedev/e1/goroot/src/runtime/fipsbypass.go",
		"/home/exedev/e1/goroot/src/runtime/float.go",
		"/home/exedev/e1/goroot/src/runtime/heapdump.go",
		"/home/exedev/e1/goroot/src/runtime/hexdump.go",
		"/home/exedev/e1/goroot/src/runtime/histogram.go",
		"/home/exedev/e1/goroot/src/runtime/iface.go",
		"/home/exedev/e1/goroot/src/runtime/lfstack.go",
		"/home/exedev/e1/goroot/src/runtime/linkname.go",
		"/home/exedev/e1/goroot/src/runtime/linkname_shim.go",
		"/home/exedev/e1/goroot/src/runtime/list.go",
		"/home/exedev/e1/goroot/src/runtime/list_manual.go",
		"/home/exedev/e1/goroot/src/runtime/lock_wasip1.go",
		"/home/exedev/e1/goroot/src/runtime/lockrank.go",
		"/home/exedev/e1/goroot/src/runtime/lockrank_off.go",
		"/home/exedev/e1/goroot/src/runtime/malloc.go",
		"/home/exedev/e1/goroot/src/runtime/malloc_generated.go",
		"/home/exedev/e1/goroot/src/runtime/malloc_stubs.go",
		"/home/exedev/e1/goroot/src/runtime/malloc_tables_generated.go",
		"/home/exedev/e1/goroot/src/runtime/map.go",
		"/home/exedev/e1/goroot/src/runtime/map_fast32.go",
		"/home/exedev/e1/goroot/src/runtime/map_fast64.go",
		"/home/exedev/e1/goroot/src/runtime/map_faststr.go",
		"/home/exedev/e1/goroot/src/runtime/mbarrier.go",
		"/home/exedev/e1/goroot/src/runtime/mbitmap.go",
		"/home/exedev/e1/goroot/src/runtime/mcache.go",
		"/home/exedev/e1/goroot/src/runtime/mcentral.go",
		"/home/exedev/e1/goroot/src/runtime/mcheckmark.go",
		"/home/exedev/e1/goroot/src/runtime/mcleanup.go",
		"/home/exedev/e1/goroot/src/runtime/mem.go",
		"/home/exedev/e1/goroot/src/runtime/mem_sbrk.go",
		"/home/exedev/e1/goroot/src/runtime/mem_wasip1.go",
		"/home/exedev/e1/goroot/src/runtime/mem_wasm.go",
		"/home/exedev/e1/goroot/src/runtime/metrics.go",
		"/home/exedev/e1/goroot/src/runtime/mfinal.go",
		"/home/exedev/e1/goroot/src/runtime/mfixalloc.go",
		"/home/exedev/e1/goroot/src/runtime/mgc.go",
		"/home/exedev/e1/goroot/src/runtime/mgclimit.go",
		"/home/exedev/e1/goroot/src/runtime/mgcmark.go",
		"/home/exedev/e1/goroot/src/runtime/mgcmark_greenteagc.go",
		"/home/exedev/e1/goroot/src/runtime/mgcpacer.go",
		"/home/exedev/e1/goroot/src/runtime/mgcscavenge.go",
		"/home/exedev/e1/goroot/src/runtime/mgcstack.go",
		"/home/exedev/e1/goroot/src/runtime/mgcsweep.go",
		"/home/exedev/e1/goroot/src/runtime/mgcwork.go",
		"/home/exedev/e1/goroot/src/runtime/mheap.go",
		"/home/exedev/e1/goroot/src/runtime/minmax.go",
		"/home/exedev/e1/goroot/src/runtime/mmap.go",
		"/home/exedev/e1/goroot/src/runtime/mpagealloc.go",
		"/home/exedev/e1/goroot/src/runtime/mpagealloc_32bit.go",
		"/home/exedev/e1/goroot/src/runtime/mpagecache.go",
		"/home/exedev/e1/goroot/src/runtime/mpallocbits.go",
		"/home/exedev/e1/goroot/src/runtime/mprof.go",
		"/home/exedev/e1/goroot/src/runtime/mranges.go",
		"/home/exedev/e1/goroot/src/runtime/msan0.go",
		"/home/exedev/e1/goroot/src/runtime/msize.go",
		"/home/exedev/e1/goroot/src/runtime/mspanset.go",
		"/home/exedev/e1/goroot/src/runtime/mstats.go",
		"/home/exedev/e1/goroot/src/runtime/mwbbuf.go",
		"/home/exedev/e1/goroot/src/runtime/netpoll.go",
		"/home/exedev/e1/goroot/src/runtime/netpoll_wasip1.go",
		"/home/exedev/e1/goroot/src/runtime/nonwindows_stub.go",
		"/home/exedev/e1/goroot/src/runtime/note_other.go",
		"/home/exedev/e1/goroot/src/runtime/os_nonopenbsd.go",
		"/home/exedev/e1/goroot/src/runtime/os_wasip1.go",
		"/home/exedev/e1/goroot/src/runtime/os_wasm.go",
		"/home/exedev/e1/goroot/src/runtime/panic.go",
		"/home/exedev/e1/goroot/src/runtime/pinner.go",
		"/home/exedev/e1/goroot/src/runtime/plugin.go",
		"/home/exedev/e1/goroot/src/runtime/preempt.go",
		"/home/exedev/e1/goroot/src/runtime/preempt_nonwindows.go",
		"/home/exedev/e1/goroot/src/runtime/preempt_noxreg.go",
		"/home/exedev/e1/goroot/src/runtime/print.go",
		"/home/exedev/e1/goroot/src/runtime/proc.go",
		"/home/exedev/e1/goroot/src/runtime/profbuf.go",
		"/home/exedev/e1/goroot/src/runtime/proflabel.go",
		"/home/exedev/e1/goroot/src/runtime/race0.go",
		"/home/exedev/e1/goroot/src/runtime/rand.go",
		"/home/exedev/e1/goroot/src/runtime/rdebug.go",
		"/home/exedev/e1/goroot/src/runtime/runtime.go",
		"/home/exedev/e1/goroot/src/runtime/runtime1.go",
		"/home/exedev/e1/goroot/src/runtime/runtime2.go",
		"/home/exedev/e1/goroot/src/runtime/runtime_boring.go",
		"/home/exedev/e1/goroot/src/runtime/runtime_noclearenv.go",
		"/home/exedev/e1/goroot/src/runtime/rwmutex.go",
		"/home/exedev/e1/goroot/src/runtime/secret_noasm.go",
		"/home/exedev/e1/goroot/src/runtime/secret_nosecret.go",
		"/home/exedev/e1/goroot/src/runtime/security_nonunix.go",
		"/home/exedev/e1/goroot/src/runtime/select.go",
		"/home/exedev/e1/goroot/src/runtime/sema.go",
		"/home/exedev/e1/goroot/src/runtime/set_vma_name_stub.go",
		"/home/exedev/e1/goroot/src/runtime/sigqueue.go",
		"/home/exedev/e1/goroot/src/runtime/sigqueue_note.go",
		"/home/exedev/e1/goroot/src/runtime/slice.go",
		"/home/exedev/e1/goroot/src/runtime/softfloat64.go",
		"/home/exedev/e1/goroot/src/runtime/stack.go",
		"/home/exedev/e1/goroot/src/runtime/stkframe.go",
		"/home/exedev/e1/goroot/src/runtime/string.go",
		"/home/exedev/e1/goroot/src/runtime/stubs.go",
		"/home/exedev/e1/goroot/src/runtime/stubs_nonlinux.go",
		"/home/exedev/e1/goroot/src/runtime/stubs_wasm.go",
		"/home/exedev/e1/goroot/src/runtime/symtab.go",
		"/home/exedev/e1/goroot/src/runtime/symtabinl.go",
		"/home/exedev/e1/goroot/src/runtime/synctest.go",
		"/home/exedev/e1/goroot/src/runtime/sys_nonppc64x.go",
		"/home/exedev/e1/goroot/src/runtime/sys_wasm.go",
		"/home/exedev/e1/goroot/src/runtime/tagptr.go",
		"/home/exedev/e1/goroot/src/runtime/tagptr_64bit.go",
		"/home/exedev/e1/goroot/src/runtime/test_stubs.go",
		"/home/exedev/e1/goroot/src/runtime/time.go",
		"/home/exedev/e1/goroot/src/runtime/time_nofake.go",
		"/home/exedev/e1/goroot/src/runtime/timestub.go",
		"/home/exedev/e1/goroot/src/runtime/tls_stub.go",
		"/home/exedev/e1/goroot/src/runtime/trace.go",
		"/home/exedev/e1/goroot/src/runtime/traceallocfree.go",
		"/home/exedev/e1/goroot/src/runtime/traceback.go",
		"/home/exedev/e1/goroot/src/runtime/tracebuf.go",
		"/home/exedev/e1/goroot/src/runtime/tracecpu.go",
		"/home/exedev/e1/goroot/src/runtime/traceevent.go",
		"/home/exedev/e1/goroot/src/runtime/tracemap.go",
		"/home/exedev/e1/goroot/src/runtime/traceregion.go",
		"/home/exedev/e1/goroot/src/runtime/traceruntime.go",
		"/home/exedev/e1/goroot/src/runtime/tracestack.go",
		"/home/exedev/e1/goroot/src/runtime/tracestatus.go",
		"/home/exedev/e1/goroot/src/runtime/tracestring.go",
		"/home/exedev/e1/goroot/src/runtime/tracetime.go",
		"/home/exedev/e1/goroot/src/runtime/tracetype.go",
		"/home/exedev/e1/goroot/src/runtime/type.go",
		"/home/exedev/e1/goroot/src/runtime/unsafe.go",
		"/home/exedev/e1/goroot/src/runtime/utf8.go",
		"/home/exedev/e1/goroot/src/runtime/valgrind0.go",
		"/home/exedev/e1/goroot/src/runtime/vdso_in_none.go",
		"/home/exedev/e1/goroot/src/runtime/vgetrandom_unsupported.go",
		"/home/exedev/e1/goroot/src/runtime/write_err.go"
	],
	"NonGoFiles": [
		"/home/exedev/e1/goroot/src/runtime/asm.s",
		"/home/exedev/e1/goroot/src/runtime/asm_wasm.s",
		"/home/exedev/e1/goroot/src/runtime/ints.s",
		"/home/exedev/e1/goroot/src/runtime/memclr_wasm.s",
		"/home/exedev/e1/goroot/src/runtime/memmove_wasm.s",
		"/home/exedev/e1/goroot/src/runtime/preempt_wasm.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_wasip1_wasm.s",
		"/home/exedev/e1/goroot/src/runtime/sys_wasm.s"
	],
	"IgnoredFiles": [
		"/home/exedev/e1/goroot/src/runtime/abi_test.go",
		"/home/exedev/e1/goroot/src/runtime/asan.go",
		"/home/exedev/e1/goroot/src/runtime/badlinkname_linux.go",
		"/home/exedev/e1/goroot/src/runtime/cgo_mmap.go",
		"/home/exedev/e1/goroot/src/runtime/cgo_ppc64x.go",
		"/home/exedev/e1/goroot/src/runtime/cgo_sigaction.go",
		"/home/exedev/e1/goroot/src/runtime/cgroup_linux.go",
		"/home/exedev/e1/goroot/src/runtime/cgroup_linux_test.go",
		"/home/exedev/e1/goroot/src/runtime/cpuflags_amd64.go",
		"/home/exedev/e1/goroot/src/runtime/cpuflags_amd64_test.go",
		"/home/exedev/e1/goroot/src/runtime/cpuflags_arm64.go",
		"/home/exedev/e1/goroot/src/runtime/cputicks.go",
		"/home/exedev/e1/goroot/src/runtime/crash_cgo_test.go",
		"/home/exedev/e1/goroot/src/runtime/crash_unix_test.go",
		"/home/exedev/e1/goroot/src/runtime/create_file_unix.go",
		"/home/exedev/e1/goroot/src/runtime/debug_test.go",
		"/home/exedev/e1/goroot/src/runtime/debugcall.go",
		"/home/exedev/e1/goroot/src/runtime/debuglog_on.go",
		"/home/exedev/e1/goroot/src/runtime/defs1_linux.go",
		"/home/exedev/e1/goroot/src/runtime/defs1_netbsd_386.go",
		"/home/exedev/e1/goroot/src/runtime/defs1_netbsd_amd64.go",
		"/home/exedev/e1/goroot/src/runtime/defs1_netbsd_arm.go",
		"/home/exedev/e1/goroot/src/runtime/defs1_netbsd_arm64.go",
		"/home/exedev/e1/goroot/src/runtime/defs1_solaris_amd64.go",
		"/home/exedev/e1/goroot/src/runtime/defs2_linux.go",
		"/home/exedev/e1/goroot/src/runtime/defs3_linux.go",
		"/home/exedev/e1/goroot/src/runtime/defs_aix.go",
		"/home/exedev/e1/goroot/src/runtime/defs_aix_ppc64.go",
		"/home/exedev/e1/goroot/src/runtime/defs_arm_linux.go",
		"/home/exedev/e1/goroot/src/runtime/defs_darwin.go",
		"/home/exedev/e1/goroot/src/runtime/defs_darwin_amd64.go",
		"/home/exedev/e1/goroot/src/runtime/defs_darwin_arm64.go",
		"/home/exedev/e1/goroot/src/runtime/defs_dragonfly.go",
		"/home/exedev/e1/goroot/src/runtime/defs_dragonfly_amd64.go",
		"/home/exedev/e1/goroot/src/runtime/defs_freebsd.go",
		"/home/exedev/e1/goroot/src/runtime/defs_freebsd_386.go",
		"/home/exedev/e1/goroot/src/runtime/defs_freebsd_amd64.go",
		"/home/exedev/e1/goroot/src/runtime/defs_freebsd_arm.go",
		"/home/exedev/e1/goroot/src/runtime/defs_freebsd_arm64.go",
		"/home/exedev/e1/goroot/src/runtime/defs_freebsd_riscv64.go",
		"/home/exedev/e1/goroot/src/runtime/defs_illumos_amd64.go",
		"/home/exedev/e1/goroot/src/runtime/defs_linux.go",
		"/home/exedev/e1/goroot/src/runtime/defs_linux_386.go",
		"/home/exedev/e1/goroot/src/runtime/defs_linux_amd64.go",
		"/home/exedev/e1/goroot/src/runtime/defs_linux_arm.go",
		"/home/exedev/e1/goroot/src/runtime/defs_linux_arm64.go",
		"/home/exedev/e1/goroot/src/runtime/defs_linux_loong64.go",
		"/home/exedev/e1/goroot/src/runtime/defs_linux_mips64x.go",
		"/home/exedev/e1/goroot/src/runtime/defs_linux_mipsx.go",
		"/home/exedev/e1/goroot/src/runtime/defs_linux_ppc64.go",
		"/home/exedev/e1/goroot/src/runtime/defs_linux_ppc64le.go",
		"/home/exedev/e1/goroot/src/runtime/defs_linux_riscv64.go",
		"/home/exedev/e1/goroot/src/runtime/defs_linux_s390x.go",
		"/home/exedev/e1/goroot/src/runtime/defs_netbsd.go",
		"/home/exedev/e1/goroot/src/runtime/defs_netbsd_386.go",
		"/home/exedev/e1/goroot/src/runtime/defs_netbsd_amd64.go",
		"/home/exedev/e1/goroot/src/runtime/defs_netbsd_arm.go",
		"/home/exedev/e1/goroot/src/runtime/defs_openbsd.go",
		"/home/exedev/e1/goroot/src/runtime/defs_openbsd_386.go",
		"/home/exedev/e1/goroot/src/runtime/defs_openbsd_amd64.go",
		"/home/exedev/e1/goroot/src/runtime/defs_openbsd_arm.go",
		"/home/exedev/e1/goroot/src/runtime/defs_openbsd_arm64.go",
		"/home/exedev/e1/goroot/src/runtime/defs_openbsd_ppc64.go",
		"/home/exedev/e1/goroot/src/runtime/defs_openbsd_riscv64.go",
		"/home/exedev/e1/goroot/src/runtime/defs_plan9_386.go",
		"/home/exedev/e1/goroot/src/runtime/defs_plan9_amd64.go",
		"/home/exedev/e1/goroot/src/runtime/defs_plan9_arm.go",
		"/home/exedev/e1/goroot/src/runtime/defs_solaris.go",
		"/home/exedev/e1/goroot/src/runtime/defs_solaris_amd64.go",
		"/home/exedev/e1/goroot/src/runtime/env_plan9.go",
		"/home/exedev/e1/goroot/src/runtime/export_aix_test.go",
		"/home/exedev/e1/goroot/src/runtime/export_arm_test.go",
		"/home/exedev/e1/goroot/src/runtime/export_darwin_test.go",
		"/home/exedev/e1/goroot/src/runtime/export_debug_amd64_test.go",
		"/home/exedev/e1/goroot/src/runtime/export_debug_arm64_test.go",
		"/home/exedev/e1/goroot/src/runtime/export_debug_loong64_test.go",
		"/home/exedev/e1/goroot/src/runtime/export_debug_ppc64x_test.go",
		"/home/exedev/e1/goroot/src/runtime/export_debug_test.go",
		"/home/exedev/e1/goroot/src/runtime/export_linux_test.go",
		"/home/exedev/e1/goroot/src/runtime/export_mmap_test.go",
		"/home/exedev/e1/goroot/src/runtime/export_pipe2_test.go",
		"/home/exedev/e1/goroot/src/runtime/export_pipe_test.go",
		"/home/exedev/e1/goroot/src/runtime/export_unix_test.go",
		"/home/exedev/e1/goroot/src/runtime/export_vdso_linux_test.go",
		"/home/exedev/e1/goroot/src/runtime/export_windows_test.go",
		"/home/exedev/e1/goroot/src/runtime/fds_test.go",
		"/home/exedev/e1/goroot/src/runtime/fds_unix.go",
		"/home/exedev/e1/goroot/src/runtime/gomaxprocs_windows_test.go",
		"/home/exedev/e1/goroot/src/runtime/libfuzzer.go",
		"/home/exedev/e1/goroot/src/runtime/libinit.go",
		"/home/exedev/e1/goroot/src/runtime/linkname_unix.go",
		"/home/exedev/e1/goroot/src/runtime/lock_futex.go",
		"/home/exedev/e1/goroot/src/runtime/lock_js.go",
		"/home/exedev/e1/goroot/src/runtime/lock_sema.go",
		"/home/exedev/e1/goroot/src/runtime/lock_spinbit.go",
		"/home/exedev/e1/goroot/src/runtime/lockrank_on.go",
		"/home/exedev/e1/goroot/src/runtime/malloc_tables_plan9.go",
		"/home/exedev/e1/goroot/src/runtime/mem_aix.go",
		"/home/exedev/e1/goroot/src/runtime/mem_bsd.go",
		"/home/exedev/e1/goroot/src/runtime/mem_darwin.go",
		"/home/exedev/e1/goroot/src/runtime/mem_js.go",
		"/home/exedev/e1/goroot/src/runtime/mem_linux.go",
		"/home/exedev/e1/goroot/src/runtime/mem_nonsbrk.go",
		"/home/exedev/e1/goroot/src/runtime/mem_plan9.go",
		"/home/exedev/e1/goroot/src/runtime/mem_windows.go",
		"/home/exedev/e1/goroot/src/runtime/memmove_linux_amd64_test.go",
		"/home/exedev/e1/goroot/src/runtime/metrics_cgo_test.go",
		"/home/exedev/e1/goroot/src/runtime/mgcmark_nogreenteagc.go",
		"/home/exedev/e1/goroot/src/runtime/mkduff.go",
		"/home/exedev/e1/goroot/src/runtime/mkfastlog2table.go",
		"/home/exedev/e1/goroot/src/runtime/mklockrank.go",
		"/home/exedev/e1/goroot/src/runtime/mkpreempt.go",
		"/home/exedev/e1/goroot/src/runtime/mpagealloc_64bit.go",
		"/home/exedev/e1/goroot/src/runtime/msan.go",
		"/home/exedev/e1/goroot/src/runtime/nbpipe_pipe.go",
		"/home/exedev/e1/goroot/src/runtime/nbpipe_pipe2.go",
		"/home/exedev/e1/goroot/src/runtime/nbpipe_pipe_test.go",
		"/home/exedev/e1/goroot/src/runtime/nbpipe_test.go",
		"/home/exedev/e1/goroot/src/runtime/net_plan9.go",
		"/home/exedev/e1/goroot/src/runtime/netpoll_aix.go",
		"/home/exedev/e1/goroot/src/runtime/netpoll_epoll.go",
		"/home/exedev/e1/goroot/src/runtime/netpoll_fake.go",
		"/home/exedev/e1/goroot/src/runtime/netpoll_kqueue.go",
		"/home/exedev/e1/goroot/src/runtime/netpoll_kqueue_event.go",
		"/home/exedev/e1/goroot/src/runtime/netpoll_kqueue_pipe.go",
		"/home/exedev/e1/goroot/src/runtime/netpoll_solaris.go",
		"/home/exedev/e1/goroot/src/runtime/netpoll_stub.go",
		"/home/exedev/e1/goroot/src/runtime/netpoll_windows.go",
		"/home/exedev/e1/goroot/src/runtime/nosan_linux_test.go",
		"/home/exedev/e1/goroot/src/runtime/note_js.go",
		"/home/exedev/e1/goroot/src/runtime/numcpu_freebsd_test.go",
		"/home/exedev/e1/goroot/src/runtime/os2_aix.go",
		"/home/exedev/e1/goroot/src/runtime/os2_freebsd.go",
		"/home/exedev/e1/goroot/src/runtime/os2_openbsd.go",
		"/home/exedev/e1/goroot/src/runtime/os2_plan9.go",
		"/home/exedev/e1/goroot/src/runtime/os2_solaris.go",
		"/home/exedev/e1/goroot/src/runtime/os3_plan9.go",
		"/home/exedev/e1/goroot/src/runtime/os3_solaris.go",
		"/home/exedev/e1/goroot/src/runtime/os_aix.go",
		"/home/exedev/e1/goroot/src/runtime/os_android.go",
		"/home/exedev/e1/goroot/src/runtime/os_darwin.go",
		"/home/exedev/e1/goroot/src/runtime/os_darwin_arm64.go",
		"/home/exedev/e1/goroot/src/runtime/os_dragonfly.go",
		"/home/exedev/e1/goroot/src/runtime/os_freebsd.go",
		"/home/exedev/e1/goroot/src/runtime/os_freebsd2.go",
		"/home/exedev/e1/goroot/src/runtime/os_freebsd_amd64.go",
		"/home/exedev/e1/goroot/src/runtime/os_freebsd_arm.go",
		"/home/exedev/e1/goroot/src/runtime/os_freebsd_arm64.go",
		"/home/exedev/e1/goroot/src/runtime/os_freebsd_noauxv.go",
		"/home/exedev/e1/goroot/src/runtime/os_illumos.go",
		"/home/exedev/e1/goroot/src/runtime/os_js.go",
		"/home/exedev/e1/goroot/src/runtime/os_linux.go",
		"/home/exedev/e1/goroot/src/runtime/os_linux32.go",
		"/home/exedev/e1/goroot/src/runtime/os_linux64.go",
		"/home/exedev/e1/goroot/src/runtime/os_linux_arm.go",
		"/home/exedev/e1/goroot/src/runtime/os_linux_arm64.go",
		"/home/exedev/e1/goroot/src/runtime/os_linux_be64.go",
		"/home/exedev/e1/goroot/src/runtime/os_linux_generic.go",
		"/home/exedev/e1/goroot/src/runtime/os_linux_loong64.go",
		"/home/exedev/e1/goroot/src/runtime/os_linux_mips64x.go",
		"/home/exedev/e1/goroot/src/runtime/os_linux_mipsx.go",
		"/home/exedev/e1/goroot/src/runtime/os_linux_noauxv.go",
		"/home/exedev/e1/goroot/src/runtime/os_linux_novdso.go",
		"/home/exedev/e1/goroot/src/runtime/os_linux_ppc64x.go",
		"/home/exedev/e1/goroot/src/runtime/os_linux_riscv64.go",
		"/home/exedev/e1/goroot/src/runtime/os_linux_s390x.go",
		"/home/exedev/e1/goroot/src/runtime/os_netbsd.go",
		"/home/exedev/e1/goroot/src/runtime/os_netbsd_386.go",
		"/home/exedev/e1/goroot/src/runtime/os_netbsd_amd64.go",
		"/home/exedev/e1/goroot/src/runtime/os_netbsd_arm.go",
		"/home/exedev/e1/goroot/src/runtime/os_netbsd_arm64.go",
		"/home/exedev/e1/goroot/src/runtime/os_only_solaris.go",
		"/home/exedev/e1/goroot/src/runtime/os_openbsd.go",
		"/home/exedev/e1/goroot/src/runtime/os_openbsd_arm.go",
		"/home/exedev/e1/goroot/src/runtime/os_openbsd_arm64.go",
		"/home/exedev/e1/goroot/src/runtime/os_plan9.go",
		"/home/exedev/e1/goroot/src/runtime/os_plan9_arm.go",
		"/home/exedev/e1/goroot/src/runtime/os_solaris.go",
		"/home/exedev/e1/goroot/src/runtime/os_unix.go",
		"/home/exedev/e1/goroot/src/runtime/os_unix_nonlinux.go",
		"/home/exedev/e1/goroot/src/runtime/os_windows.go",
		"/home/exedev/e1/goroot/src/runtime/os_windows_arm64.go",
		"/home/exedev/e1/goroot/src/runtime/os_workdir_ios_arm64.go",
		"/home/exedev/e1/goroot/src/runtime/os_workdir_stub.go",
		"/home/exedev/e1/goroot/src/runtime/panic32.go",
		"/home/exedev/e1/goroot/src/runtime/preempt_amd64.go",
		"/home/exedev/e1/goroot/src/runtime/preempt_arm64.go",
		"/home/exedev/e1/goroot/src/runtime/preempt_loong64.go",
		"/home/exedev/e1/goroot/src/runtime/preempt_xreg.go",
		"/home/exedev/e1/goroot/src/runtime/race.go",
		"/home/exedev/e1/goroot/src/runtime/retry.go",
		"/home/exedev/e1/goroot/src/runtime/runtime-gdb_unix_test.go",
		"/home/exedev/e1/goroot/src/runtime/runtime-seh_windows_test.go",
		"/home/exedev/e1/goroot/src/runtime/runtime_clearenv.go",
		"/home/exedev/e1/goroot/src/runtime/runtime_linux_test.go",
		"/home/exedev/e1/goroot/src/runtime/runtime_mmap_test.go",
		"/home/exedev/e1/goroot/src/runtime/runtime_unix_test.go",
		"/home/exedev/e1/goroot/src/runtime/secret.go",
		"/home/exedev/e1/goroot/src/runtime/secret_asm.go",
		"/home/exedev/e1/goroot/src/runtime/security_aix.go",
		"/home/exedev/e1/goroot/src/runtime/security_issetugid.go",
		"/home/exedev/e1/goroot/src/runtime/security_linux.go",
		"/home/exedev/e1/goroot/src/runtime/security_test.go",
		"/home/exedev/e1/goroot/src/runtime/security_unix.go",
		"/home/exedev/e1/goroot/src/runtime/semasleep_test.go",
		"/home/exedev/e1/goroot/src/runtime/set_vma_name_linux.go",
		"/home/exedev/e1/goroot/src/runtime/sigaction.go",
		"/home/exedev/e1/goroot/src/runtime/signal_386.go",
		"/home/exedev/e1/goroot/src/runtime/signal_aix_ppc64.go",
		"/home/exedev/e1/goroot/src/runtime/signal_amd64.go",
		"/home/exedev/e1/goroot/src/runtime/signal_arm.go",
		"/home/exedev/e1/goroot/src/runtime/signal_arm64.go",
		"/home/exedev/e1/goroot/src/runtime/signal_darwin.go",
		"/home/exedev/e1/goroot/src/runtime/signal_darwin_amd64.go",
		"/home/exedev/e1/goroot/src/runtime/signal_darwin_arm64.go",
		"/home/exedev/e1/goroot/src/runtime/signal_dragonfly.go",
		"/home/exedev/e1/goroot/src/runtime/signal_dragonfly_amd64.go",
		"/home/exedev/e1/goroot/src/runtime/signal_freebsd.go",
		"/home/exedev/e1/goroot/src/runtime/signal_freebsd_386.go",
		"/home/exedev/e1/goroot/src/runtime/signal_freebsd_amd64.go",
		"/home/exedev/e1/goroot/src/runtime/signal_freebsd_arm.go",
		"/home/exedev/e1/goroot/src/runtime/signal_freebsd_arm64.go",
		"/home/exedev/e1/goroot/src/runtime/signal_freebsd_riscv64.go",
		"/home/exedev/e1/goroot/src/runtime/signal_linux_386.go",
		"/home/exedev/e1/goroot/src/runtime/signal_linux_amd64.go",
		"/home/exedev/e1/goroot/src/runtime/signal_linux_arm.go",
		"/home/exedev/e1/goroot/src/runtime/signal_linux_arm64.go",
		"/home/exedev/e1/goroot/src/runtime/signal_linux_loong64.go",
		"/home/exedev/e1/goroot/src/runtime/signal_linux_mips64x.go",
		"/home/exedev/e1/goroot/src/runtime/signal_linux_mipsx.go",
		"/home/exedev/e1/goroot/src/runtime/signal_linux_ppc64x.go",
		"/home/exedev/e1/goroot/src/runtime/signal_linux_riscv64.go",
		"/home/exedev/e1/goroot/src/runtime/signal_linux_s390x.go",
		"/home/exedev/e1/goroot/src/runtime/signal_linux_test.go",
		"/home/exedev/e1/goroot/src/runtime/signal_loong64.go",
		"/home/exedev/e1/goroot/src/runtime/signal_mips64x.go",
		"/home/exedev/e1/goroot/src/runtime/signal_mipsx.go",
		"/home/exedev/e1/goroot/src/runtime/signal_netbsd.go",
		"/home/exedev/e1/goroot/src/runtime/signal_netbsd_386.go",
		"/home/exedev/e1/goroot/src/runtime/signal_netbsd_amd64.go",
		"/home/exedev/e1/goroot/src/runtime/signal_netbsd_arm.go",
		"/home/exedev/e1/goroot/src/runtime/signal_netbsd_arm64.go",
		"/home/exedev/e1/goroot/src/runtime/signal_openbsd.go",
		"/home/exedev/e1/goroot/src/runtime/signal_openbsd_386.go",
		"/home/exedev/e1/goroot/src/runtime/signal_openbsd_amd64.go",
		"/home/exedev/e1/goroot/src/runtime/signal_openbsd_arm.go",
		"/home/exedev/e1/goroot/src/runtime/signal_openbsd_arm64.go",
		"/home/exedev/e1/goroot/src/runtime/signal_openbsd_ppc64.go",
		"/home/exedev/e1/goroot/src/runtime/signal_openbsd_riscv64.go",
		"/home/exedev/e1/goroot/src/runtime/signal_plan9.go",
		"/home/exedev/e1/goroot/src/runtime/signal_ppc64x.go",
		"/home/exedev/e1/goroot/src/runtime/signal_riscv64.go",
		"/home/exedev/e1/goroot/src/runtime/signal_solaris.go",
		"/home/exedev/e1/goroot/src/runtime/signal_solaris_amd64.go",
		"/home/exedev/e1/goroot/src/runtime/signal_unix.go",
		"/home/exedev/e1/goroot/src/runtime/signal_windows.go",
		"/home/exedev/e1/goroot/src/runtime/signal_windows_386.go",
		"/home/exedev/e1/goroot/src/runtime/signal_windows_amd64.go",
		"/home/exedev/e1/goroot/src/runtime/signal_windows_arm64.go",
		"/home/exedev/e1/goroot/src/runtime/signal_windows_test.go",
		"/home/exedev/e1/goroot/src/runtime/sigqueue_plan9.go",
		"/home/exedev/e1/goroot/src/runtime/sigtab_aix.go",
		"/home/exedev/e1/goroot/src/runtime/sigtab_linux_generic.go",
		"/home/exedev/e1/goroot/src/runtime/sigtab_linux_mipsx.go",
		"/home/exedev/e1/goroot/src/runtime/start_line_amd64_test.go",
		"/home/exedev/e1/goroot/src/runtime/stubs2.go",
		"/home/exedev/e1/goroot/src/runtime/stubs3.go",
		"/home/exedev/e1/goroot/src/runtime/stubs_386.go",
		"/home/exedev/e1/goroot/src/runtime/stubs_amd64.go",
		"/home/exedev/e1/goroot/src/runtime/stubs_arm.go",
		"/home/exedev/e1/goroot/src/runtime/stubs_arm64.go",
		"/home/exedev/e1/goroot/src/runtime/stubs_linux.go",
		"/home/exedev/e1/goroot/src/runtime/stubs_loong64.go",
		"/home/exedev/e1/goroot/src/runtime/stubs_mips64x.go",
		"/home/exedev/e1/goroot/src/runtime/stubs_mipsx.go",
		"/home/exedev/e1/goroot/src/runtime/stubs_nonwasm.go",
		"/home/exedev/e1/goroot/src/runtime/stubs_ppc64x.go",
		"/home/exedev/e1/goroot/src/runtime/stubs_riscv64.go",
		"/home/exedev/e1/goroot/src/runtime/stubs_s390x.go",
		"/home/exedev/e1/goroot/src/runtime/sys_arm.go",
		"/home/exedev/e1/goroot/src/runtime/sys_arm64.go",
		"/home/exedev/e1/goroot/src/runtime/sys_darwin.go",
		"/home/exedev/e1/goroot/src/runtime/sys_darwin_arm64.go",
		"/home/exedev/e1/goroot/src/runtime/sys_ios_arm64.go",
		"/home/exedev/e1/goroot/src/runtime/sys_libc.go",
		"/home/exedev/e1/goroot/src/runtime/sys_loong64.go",
		"/home/exedev/e1/goroot/src/runtime/sys_mips64x.go",
		"/home/exedev/e1/goroot/src/runtime/sys_mipsx.go",
		"/home/exedev/e1/goroot/src/runtime/sys_openbsd.go",
		"/home/exedev/e1/goroot/src/runtime/sys_ppc64x.go",
		"/home/exedev/e1/goroot/src/runtime/sys_riscv64.go",
		"/home/exedev/e1/goroot/src/runtime/sys_s390x.go",
		"/home/exedev/e1/goroot/src/runtime/sys_x86.go",
		"/home/exedev/e1/goroot/src/runtime/syscall2_solaris.go",
		"/home/exedev/e1/goroot/src/runtime/syscall_aix.go",
		"/home/exedev/e1/goroot/src/runtime/syscall_solaris.go",
		"/home/exedev/e1/goroot/src/runtime/syscall_unix_test.go",
		"/home/exedev/e1/goroot/src/runtime/syscall_windows.go",
		"/home/exedev/e1/goroot/src/runtime/syscall_windows_test.go",
		"/home/exedev/e1/goroot/src/runtime/tagptr_32bit.go",
		"/home/exedev/e1/goroot/src/runtime/test_amd64.go",
		"/home/exedev/e1/goroot/src/runtime/time_fake.go",
		"/home/exedev/e1/goroot/src/runtime/time_plan9.go",
		"/home/exedev/e1/goroot/src/runtime/timeasm.go",
		"/home/exedev/e1/goroot/src/runtime/timestub2.go",
		"/home/exedev/e1/goroot/src/runtime/tls_windows_amd64.go",
		"/home/exedev/e1/goroot/src/runtime/trace_cgo_test.go",
		"/home/exedev/e1/goroot/src/runtime/valgrind.go",
		"/home/exedev/e1/goroot/src/runtime/vdso_elf32.go",
		"/home/exedev/e1/goroot/src/runtime/vdso_elf64.go",
		"/home/exedev/e1/goroot/src/runtime/vdso_freebsd.go",
		"/home/exedev/e1/goroot/src/runtime/vdso_freebsd_arm.go",
		"/home/exedev/e1/goroot/src/runtime/vdso_freebsd_arm64.go",
		"/home/exedev/e1/goroot/src/runtime/vdso_freebsd_riscv64.go",
		"/home/exedev/e1/goroot/src/runtime/vdso_freebsd_x86.go",
		"/home/exedev/e1/goroot/src/runtime/vdso_linux.go",
		"/home/exedev/e1/goroot/src/runtime/vdso_linux_386.go",
		"/home/exedev/e1/goroot/src/runtime/vdso_linux_amd64.go",
		"/home/exedev/e1/goroot/src/runtime/vdso_linux_arm.go",
		"/home/exedev/e1/goroot/src/runtime/vdso_linux_arm64.go",
		"/home/exedev/e1/goroot/src/runtime/vdso_linux_loong64.go",
		"/home/exedev/e1/goroot/src/runtime/vdso_linux_mips64x.go",
		"/home/exedev/e1/goroot/src/runtime/vdso_linux_ppc64x.go",
		"/home/exedev/e1/goroot/src/runtime/vdso_linux_riscv64.go",
		"/home/exedev/e1/goroot/src/runtime/vdso_linux_s390x.go",
		"/home/exedev/e1/goroot/src/runtime/vdso_linux_test.go",
		"/home/exedev/e1/goroot/src/runtime/vdso_test.go",
		"/home/exedev/e1/goroot/src/runtime/vgetrandom_linux.go",
		"/home/exedev/e1/goroot/src/runtime/vlop_arm_test.go",
		"/home/exedev/e1/goroot/src/runtime/vlrt.go",
		"/home/exedev/e1/goroot/src/runtime/wincallback.go",
		"/home/exedev/e1/goroot/src/runtime/write_err_android.go",
		"/home/exedev/e1/goroot/src/runtime/zcallback_windows.go",
		"/home/exedev/e1/goroot/src/runtime/asan_amd64.s",
		"/home/exedev/e1/goroot/src/runtime/asan_arm64.s",
		"/home/exedev/e1/goroot/src/runtime/asan_loong64.s",
		"/home/exedev/e1/goroot/src/runtime/asan_ppc64le.s",
		"/home/exedev/e1/goroot/src/runtime/asan_riscv64.s",
		"/home/exedev/e1/goroot/src/runtime/asm_386.s",
		"/home/exedev/e1/goroot/src/runtime/asm_amd64.h",
		"/home/exedev/e1/goroot/src/runtime/asm_amd64.s",
		"/home/exedev/e1/goroot/src/runtime/asm_arm.s",
		"/home/exedev/e1/goroot/src/runtime/asm_arm64.s",
		"/home/exedev/e1/goroot/src/runtime/asm_loong64.s",
		"/home/exedev/e1/goroot/src/runtime/asm_mips64x.s",
		"/home/exedev/e1/goroot/src/runtime/asm_mipsx.s",
		"/home/exedev/e1/goroot/src/runtime/asm_ppc64x.s",
		"/home/exedev/e1/goroot/src/runtime/asm_riscv64.h",
		"/home/exedev/e1/goroot/src/runtime/asm_riscv64.s",
		"/home/exedev/e1/goroot/src/runtime/asm_s390x.s",
		"/home/exedev/e1/goroot/src/runtime/atomic_arm64.s",
		"/home/exedev/e1/goroot/src/runtime/atomic_loong64.s",
		"/home/exedev/e1/goroot/src/runtime/atomic_mips64x.s",
		"/home/exedev/e1/goroot/src/runtime/atomic_mipsx.s",
		"/home/exedev/e1/goroot/src/runtime/atomic_ppc64x.s",
		"/home/exedev/e1/goroot/src/runtime/atomic_riscv64.s",
		"/home/exedev/e1/goroot/src/runtime/duff_386.s",
		"/home/exedev/e1/goroot/src/runtime/duff_arm.s",
		"/home/exedev/e1/goroot/src/runtime/duff_mips64x.s",
		"/home/exedev/e1/goroot/src/runtime/duff_ppc64x.s",
		"/home/exedev/e1/goroot/src/runtime/duff_s390x.s",
		"/home/exedev/e1/goroot/src/runtime/libfuzzer_amd64.s",
		"/home/exedev/e1/goroot/src/runtime/libfuzzer_arm64.s",
		"/home/exedev/e1/goroot/src/runtime/libfuzzer_loong64.s",
		"/home/exedev/e1/goroot/src/runtime/memclr_386.s",
		"/home/exedev/e1/goroot/src/runtime/memclr_amd64.s",
		"/home/exedev/e1/goroot/src/runtime/memclr_arm.s",
		"/home/exedev/e1/goroot/src/runtime/memclr_arm64.s",
		"/home/exedev/e1/goroot/src/runtime/memclr_loong64.s",
		"/home/exedev/e1/goroot/src/runtime/memclr_mips64x.s",
		"/home/exedev/e1/goroot/src/runtime/memclr_mipsx.s",
		"/home/exedev/e1/goroot/src/runtime/memclr_plan9_386.s",
		"/home/exedev/e1/goroot/src/runtime/memclr_plan9_amd64.s",
		"/home/exedev/e1/goroot/src/runtime/memclr_ppc64x.s",
		"/home/exedev/e1/goroot/src/runtime/memclr_riscv64.s",
		"/home/exedev/e1/goroot/src/runtime/memclr_s390x.s",
		"/home/exedev/e1/goroot/src/runtime/memmove_386.s",
		"/home/exedev/e1/goroot/src/runtime/memmove_amd64.s",
		"/home/exedev/e1/goroot/src/runtime/memmove_arm.s",
		"/home/exedev/e1/goroot/src/runtime/memmove_arm64.s",
		"/home/exedev/e1/goroot/src/runtime/memmove_loong64.s",
		"/home/exedev/e1/goroot/src/runtime/memmove_mips64x.s",
		"/home/exedev/e1/goroot/src/runtime/memmove_mipsx.s",
		"/home/exedev/e1/goroot/src/runtime/memmove_plan9_386.s",
		"/home/exedev/e1/goroot/src/runtime/memmove_plan9_amd64.s",
		"/home/exedev/e1/goroot/src/runtime/memmove_ppc64x.s",
		"/home/exedev/e1/goroot/src/runtime/memmove_riscv64.s",
		"/home/exedev/e1/goroot/src/runtime/memmove_s390x.s",
		"/home/exedev/e1/goroot/src/runtime/msan_amd64.s",
		"/home/exedev/e1/goroot/src/runtime/msan_arm64.s",
		"/home/exedev/e1/goroot/src/runtime/msan_loong64.s",
		"/home/exedev/e1/goroot/src/runtime/preempt_386.s",
		"/home/exedev/e1/goroot/src/runtime/preempt_amd64.s",
		"/home/exedev/e1/goroot/src/runtime/preempt_arm.s",
		"/home/exedev/e1/goroot/src/runtime/preempt_arm64.s",
		"/home/exedev/e1/goroot/src/runtime/preempt_loong64.s",
		"/home/exedev/e1/goroot/src/runtime/preempt_mips64x.s",
		"/home/exedev/e1/goroot/src/runtime/preempt_mipsx.s",
		"/home/exedev/e1/goroot/src/runtime/preempt_ppc64x.s",
		"/home/exedev/e1/goroot/src/runtime/preempt_riscv64.s",
		"/home/exedev/e1/goroot/src/runtime/preempt_s390x.s",
		"/home/exedev/e1/goroot/src/runtime/race_amd64.s",
		"/home/exedev/e1/goroot/src/runtime/race_arm64.s",
		"/home/exedev/e1/goroot/src/runtime/race_loong64.s",
		"/home/exedev/e1/goroot/src/runtime/race_ppc64le.s",
		"/home/exedev/e1/goroot/src/runtime/race_riscv64.s",
		"/home/exedev/e1/goroot/src/runtime/race_s390x.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_aix_ppc64.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_android_386.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_android_amd64.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_android_arm.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_android_arm64.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_darwin_amd64.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_darwin_arm64.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_dragonfly_amd64.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_freebsd_386.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_freebsd_amd64.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_freebsd_arm.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_freebsd_arm64.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_freebsd_riscv64.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_illumos_amd64.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_ios_amd64.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_ios_arm64.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_js_wasm.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_linux_386.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_linux_amd64.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_linux_arm.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_linux_arm64.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_linux_loong64.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_linux_mips64x.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_linux_mipsx.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_linux_ppc64x.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_linux_riscv64.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_linux_s390x.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_netbsd_386.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_netbsd_amd64.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_netbsd_arm.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_netbsd_arm64.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_openbsd_386.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_openbsd_amd64.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_openbsd_arm.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_openbsd_arm64.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_openbsd_ppc64.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_openbsd_riscv64.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_plan9_386.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_plan9_amd64.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_plan9_arm.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_solaris_amd64.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_windows_386.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_windows_amd64.s",
		"/home/exedev/e1/goroot/src/runtime/rt0_windows_arm64.s",
		"/home/exedev/e1/goroot/src/runtime/secret_amd64.s",
		"/home/exedev/e1/goroot/src/runtime/secret_arm64.s",
		"/home/exedev/e1/goroot/src/runtime/sys_aix_ppc64.s",
		"/home/exedev/e1/goroot/src/runtime/sys_darwin_amd64.s",
		"/home/exedev/e1/goroot/src/runtime/sys_darwin_arm64.s",
		"/home/exedev/e1/goroot/src/runtime/sys_dragonfly_amd64.s",
		"/home/exedev/e1/goroot/src/runtime/sys_freebsd_386.s",
		"/home/exedev/e1/goroot/src/runtime/sys_freebsd_amd64.s",
		"/home/exedev/e1/goroot/src/runtime/sys_freebsd_arm.s",
		"/home/exedev/e1/goroot/src/runtime/sys_freebsd_arm64.s",
		"/home/exedev/e1/goroot/src/runtime/sys_freebsd_riscv64.s",
		"/home/exedev/e1/goroot/src/runtime/sys_ios_arm64.s",
		"/home/exedev/e1/goroot/src/runtime/sys_linux_386.s",
		"/home/exedev/e1/goroot/src/runtime/sys_linux_amd64.s",
		"/home/exedev/e1/goroot/src/runtime/sys_linux_arm.s",
		"/home/exedev/e1/goroot/src/runtime/sys_linux_arm64.s",
		"/home/exedev/e1/goroot/src/runtime/sys_linux_loong64.s",
		"/home/exedev/e1/goroot/src/runtime/sys_linux_mips64x.s",
		"/home/exedev/e1/goroot/src/runtime/sys_linux_mipsx.s",
		"/home/exedev/e1/goroot/src/runtime/sys_linux_ppc64x.s",
		"/home/exedev/e1/goroot/src/runtime/sys_linux_riscv64.s",
		"/home/exedev/e1/goroot/src/runtime/sys_linux_s390x.s",
		"/home/exedev/e1/goroot/src/runtime/sys_netbsd_386.s",
		"/home/exedev/e1/goroot/src/runtime/sys_netbsd_amd64.s",
		"/home/exedev/e1/goroot/src/runtime/sys_netbsd_arm.s",
		"/home/exedev/e1/goroot/src/runtime/sys_netbsd_arm64.s",
		"/home/exedev/e1/goroot/src/runtime/sys_openbsd_386.s",
		"/home/exedev/e1/goroot/src/runtime/sys_openbsd_amd64.s",
		"/home/exedev/e1/goroot/src/runtime/sys_openbsd_arm.s",
		"/home/exedev/e1/goroot/src/runtime/sys_openbsd_arm64.s",
		"/home/exedev/e1/goroot/src/runtime/sys_openbsd_ppc64.s",
		"/home/exedev/e1/goroot/src/runtime/sys_openbsd_riscv64.s",
		"/home/exedev/e1/goroot/src/runtime/sys_plan9_386.s",
		"/home/exedev/e1/goroot/src/runtime/sys_plan9_amd64.s",
		"/home/exedev/e1/goroot/src/runtime/sys_plan9_arm.s",
		"/home/exedev/e1/goroot/src/runtime/sys_solaris_amd64.s",
		"/home/exedev/e1/goroot/src/runtime/sys_windows_386.s",
		"/home/exedev/e1/goroot/src/runtime/sys_windows_amd64.s",
		"/home/exedev/e1/goroot/src/runtime/sys_windows_arm64.s",
		"/home/exedev/e1/goroot/src/runtime/test_amd64.s",
		"/home/exedev/e1/goroot/src/runtime/time_linux_amd64.s",
		"/home/exedev/e1/goroot/src/runtime/time_windows.h",
		"/home/exedev/e1/goroot/src/runtime/time_windows_386.s",
		"/home/exedev/e1/goroot/src/runtime/time_windows_amd64.s",
		"/home/exedev/e1/goroot/src/runtime/time_windows_arm64.s",
		"/home/exedev/e1/goroot/src/runtime/tls_arm.s",
		"/home/exedev/e1/goroot/src/runtime/tls_arm64.h",
		"/home/exedev/e1/goroot/src/runtime/tls_arm64.s",
		"/home/exedev/e1/goroot/src/runtime/tls_loong64.s",
		"/home/exedev/e1/goroot/src/runtime/tls_mips64x.s",
		"/home/exedev/e1/goroot/src/runtime/tls_mipsx.s",
		"/home/exedev/e1/goroot/src/runtime/tls_ppc64x.s",
		"/home/exedev/e1/goroot/src/runtime/tls_riscv64.s",
		"/home/exedev/e1/goroot/src/runtime/tls_s390x.s",
		"/home/exedev/e1/goroot/src/runtime/valgrind_amd64.s",
		"/home/exedev/e1/goroot/src/runtime/valgrind_arm64.s",
		"/home/exedev/e1/goroot/src/runtime/vlop_386.s",
		"/home/exedev/e1/goroot/src/runtime/vlop_arm.s",
		"/home/exedev/e1/goroot/src/runtime/zcallback_windows.s",
		"/home/exedev/e1/goroot/src/runtime/zcallback_windows_arm64.s"
	],
	"Module": null,
	"ImportMap": {
		"internal/abi": "internal/abi",
		"internal/bytealg": "internal/bytealg",
		"internal/byteorder": "internal/byteorder",
		"internal/chacha8rand": "internal/chacha8rand",
		"internal/coverage/rtcov": "internal/coverage/rtcov",
		"internal/cpu": "internal/cpu",
		"internal/goarch": "internal/goarch",
		"internal/godebugs": "internal/godebugs",
		"internal/goexperiment": "internal/goexperiment",
		"internal/goos": "internal/goos",
		"internal/profilerecord": "internal/profilerecord",
		"internal/runtime/atomic": "internal/runtime/atomic",
		"internal/runtime/exithook": "internal/runtime/exithook",
		"internal/runtime/gc": "internal/runtime/gc",
		"internal/runtime/gc/scan": "internal/runtime/gc/scan",
		"internal/runtime/maps": "internal/runtime/maps",
		"internal/runtime/math": "internal/runtime/math",
		"internal/runtime/pprof/label": "internal/runtime/pprof/label",
		"internal/runtime/sys": "internal/runtime/sys",
		"internal/strconv": "internal/strconv",
		"internal/stringslite": "internal/stringslite",
		"internal/trace/tracev2": "internal/trace/tracev2",
		"math/bits": "math/bits",
		"structs": "structs",
		"unsafe": "unsafe"
	},
	"PackageFile": {
		"internal/abi": "$WORK/b005/_pkg_.a",
		"internal/bytealg": "$WORK/b010/_pkg_.a",
		"internal/byteorder": "$WORK/b012/_pkg_.a",
		"internal/chacha8rand": "$WORK/b013/_pkg_.a",
		"internal/coverage/rtcov": "$WORK/b014/_pkg_.a",
		"internal/cpu": "$WORK/b011/_pkg_.a",
		"internal/goarch": "$WORK/b006/_pkg_.a",
		"internal/godebugs": "$WORK/b015/_pkg_.a",
		"internal/goexperiment": "$WORK/b016/_pkg_.a",
		"internal/goos": "$WORK/b017/_pkg_.a",
		"internal/profilerecord": "$WORK/b018/_pkg_.a",
		"internal/runtime/atomic": "$WORK/b019/_pkg_.a",
		"internal/runtime/exithook": "$WORK/b020/_pkg_.a",
		"internal/runtime/gc": "$WORK/b021/_pkg_.a",
		"internal/runtime/gc/scan": "$WORK/b022/_pkg_.a",
		"internal/runtime/maps": "$WORK/b024/_pkg_.a",
		"internal/runtime/math": "$WORK/b028/_pkg_.a",
		"internal/runtime/pprof/label": "$WORK/b029/_pkg_.a",
		"internal/runtime/sys": "$WORK/b023/_pkg_.a",
		"internal/strconv": "$WORK/b030/_pkg_.a",
		"internal/stringslite": "$WORK/b032/_pkg_.a",
		"internal/trace/tracev2": "$WORK/b033/_pkg_.a",
		"math/bits": "$WORK/b031/_pkg_.a",
		"structs": "$WORK/b034/_pkg_.a"
	},
	"Standard": {
		"internal/abi": true,
		"internal/bytealg": true,
		"internal/byteorder": true,
		"internal/chacha8rand": true,
		"internal/coverage/rtcov": true,
		"internal/cpu": true,
		"internal/goarch": true,
		"internal/godebugs": true,
		"internal/goexperiment": true,
		"internal/goos": true,
		"internal/profilerecord": true,
		"internal/runtime/atomic": true,
		"internal/runtime/exithook": true,
		"internal/runtime/gc": true,
		"internal/runtime/gc/scan": true,
		"internal/runtime/maps": true,
		"internal/runtime/math": true,
		"internal/runtime/pprof/label": true,
		"internal/runtime/sys": true,
		"internal/strconv": true,
		"internal/stringslite": true,
		"internal/trace/tracev2": true,
		"math/bits": true,
		"structs": true,
		"unsafe": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b009/vet.out",
	"Stdout": "$WORK/b009/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/runtime
cat >$WORK/b004/vet.cfg << 'EOF' # internal
{
	"ID": "internal/reflectlite",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/internal/reflectlite",
	"ImportPath": "internal/reflectlite",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/internal/reflectlite/swapper.go",
		"/home/exedev/e1/goroot/src/internal/reflectlite/type.go",
		"/home/exedev/e1/goroot/src/internal/reflectlite/value.go"
	],
	"NonGoFiles": [
		"/home/exedev/e1/goroot/src/internal/reflectlite/asm.s"
	],
	"IgnoredFiles": [],
	"Module": null,
	"ImportMap": {
		"internal/abi": "internal/abi",
		"internal/goarch": "internal/goarch",
		"internal/unsafeheader": "internal/unsafeheader",
		"runtime": "runtime",
		"unsafe": "unsafe"
	},
	"PackageFile": {
		"internal/abi": "$WORK/b005/_pkg_.a",
		"internal/goarch": "$WORK/b006/_pkg_.a",
		"internal/unsafeheader": "$WORK/b008/_pkg_.a",
		"runtime": "$WORK/b009/_pkg_.a"
	},
	"Standard": {
		"internal/abi": true,
		"internal/goarch": true,
		"internal/unsafeheader": true,
		"runtime": true,
		"unsafe": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b004/vet.out",
	"Stdout": "$WORK/b004/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/internal/reflectlite
cat >$WORK/b003/vet.cfg << 'EOF' # internal
{
	"ID": "errors",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/errors",
	"ImportPath": "errors",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/errors/errors.go",
		"/home/exedev/e1/goroot/src/errors/join.go",
		"/home/exedev/e1/goroot/src/errors/wrap.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [],
	"Module": null,
	"ImportMap": {
		"internal/reflectlite": "internal/reflectlite",
		"unsafe": "unsafe"
	},
	"PackageFile": {
		"internal/reflectlite": "$WORK/b004/_pkg_.a"
	},
	"Standard": {
		"internal/reflectlite": true,
		"unsafe": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b003/vet.out",
	"Stdout": "$WORK/b003/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/errors
cat >$WORK/b041/vet.cfg << 'EOF' # internal
{
	"ID": "sync/atomic",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/sync/atomic",
	"ImportPath": "sync/atomic",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/sync/atomic/doc.go",
		"/home/exedev/e1/goroot/src/sync/atomic/doc_64.go",
		"/home/exedev/e1/goroot/src/sync/atomic/type.go",
		"/home/exedev/e1/goroot/src/sync/atomic/value.go"
	],
	"NonGoFiles": [
		"/home/exedev/e1/goroot/src/sync/atomic/asm.s"
	],
	"IgnoredFiles": [
		"/home/exedev/e1/goroot/src/sync/atomic/doc_32.go",
		"/home/exedev/e1/goroot/src/sync/atomic/race.s"
	],
	"Module": null,
	"ImportMap": {
		"unsafe": "unsafe"
	},
	"PackageFile": {},
	"Standard": {
		"unsafe": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b041/vet.out",
	"Stdout": "$WORK/b041/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/sync/atomic
cat >$WORK/b040/vet.cfg << 'EOF' # internal
{
	"ID": "internal/sync",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/internal/sync",
	"ImportPath": "internal/sync",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/internal/sync/hashtriemap.go",
		"/home/exedev/e1/goroot/src/internal/sync/mutex.go",
		"/home/exedev/e1/goroot/src/internal/sync/runtime.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [],
	"Module": null,
	"ImportMap": {
		"internal/abi": "internal/abi",
		"internal/goarch": "internal/goarch",
		"internal/race": "internal/race",
		"sync/atomic": "sync/atomic",
		"unsafe": "unsafe"
	},
	"PackageFile": {
		"internal/abi": "$WORK/b005/_pkg_.a",
		"internal/goarch": "$WORK/b006/_pkg_.a",
		"internal/race": "$WORK/b027/_pkg_.a",
		"sync/atomic": "$WORK/b041/_pkg_.a"
	},
	"Standard": {
		"internal/abi": true,
		"internal/goarch": true,
		"internal/race": true,
		"sync/atomic": true,
		"unsafe": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b040/vet.out",
	"Stdout": "$WORK/b040/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/internal/sync
cat >$WORK/b042/vet.cfg << 'EOF' # internal
{
	"ID": "internal/synctest",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/internal/synctest",
	"ImportPath": "internal/synctest",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/internal/synctest/synctest.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [],
	"Module": null,
	"ImportMap": {
		"internal/abi": "internal/abi",
		"unsafe": "unsafe"
	},
	"PackageFile": {
		"internal/abi": "$WORK/b005/_pkg_.a"
	},
	"Standard": {
		"internal/abi": true,
		"unsafe": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b042/vet.out",
	"Stdout": "$WORK/b042/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/internal/synctest
cat >$WORK/b039/vet.cfg << 'EOF' # internal
{
	"ID": "sync",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/sync",
	"ImportPath": "sync",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/sync/cond.go",
		"/home/exedev/e1/goroot/src/sync/map.go",
		"/home/exedev/e1/goroot/src/sync/mutex.go",
		"/home/exedev/e1/goroot/src/sync/once.go",
		"/home/exedev/e1/goroot/src/sync/oncefunc.go",
		"/home/exedev/e1/goroot/src/sync/pool.go",
		"/home/exedev/e1/goroot/src/sync/poolqueue.go",
		"/home/exedev/e1/goroot/src/sync/runtime.go",
		"/home/exedev/e1/goroot/src/sync/runtime2.go",
		"/home/exedev/e1/goroot/src/sync/rwmutex.go",
		"/home/exedev/e1/goroot/src/sync/waitgroup.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [
		"/home/exedev/e1/goroot/src/sync/runtime2_lockrank.go"
	],
	"Module": null,
	"ImportMap": {
		"internal/race": "internal/race",
		"internal/runtime/atomic": "internal/runtime/atomic",
		"internal/sync": "internal/sync",
		"internal/synctest": "internal/synctest",
		"runtime": "runtime",
		"sync/atomic": "sync/atomic",
		"unsafe": "unsafe"
	},
	"PackageFile": {
		"internal/race": "$WORK/b027/_pkg_.a",
		"internal/runtime/atomic": "$WORK/b019/_pkg_.a",
		"internal/sync": "$WORK/b040/_pkg_.a",
		"internal/synctest": "$WORK/b042/_pkg_.a",
		"runtime": "$WORK/b009/_pkg_.a",
		"sync/atomic": "$WORK/b041/_pkg_.a"
	},
	"Standard": {
		"internal/race": true,
		"internal/runtime/atomic": true,
		"internal/sync": true,
		"internal/synctest": true,
		"runtime": true,
		"sync/atomic": true,
		"unsafe": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b039/vet.out",
	"Stdout": "$WORK/b039/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/sync
cat >$WORK/b038/vet.cfg << 'EOF' # internal
{
	"ID": "io",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/io",
	"ImportPath": "io",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/io/io.go",
		"/home/exedev/e1/goroot/src/io/multi.go",
		"/home/exedev/e1/goroot/src/io/pipe.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [],
	"Module": null,
	"ImportMap": {
		"errors": "errors",
		"sync": "sync"
	},
	"PackageFile": {
		"errors": "$WORK/b003/_pkg_.a",
		"sync": "$WORK/b039/_pkg_.a"
	},
	"Standard": {
		"errors": true,
		"sync": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b038/vet.out",
	"Stdout": "$WORK/b038/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/io
cat >$WORK/b047/vet.cfg << 'EOF' # internal
{
	"ID": "iter",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/iter",
	"ImportPath": "iter",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/iter/iter.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [],
	"Module": null,
	"ImportMap": {
		"internal/race": "internal/race",
		"runtime": "runtime",
		"unsafe": "unsafe"
	},
	"PackageFile": {
		"internal/race": "$WORK/b027/_pkg_.a",
		"runtime": "$WORK/b009/_pkg_.a"
	},
	"Standard": {
		"internal/race": true,
		"runtime": true,
		"unsafe": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b047/vet.out",
	"Stdout": "$WORK/b047/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/iter
cat >$WORK/b057/vet.cfg << 'EOF' # internal
{
	"ID": "unicode",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/unicode",
	"ImportPath": "unicode",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/unicode/casetables.go",
		"/home/exedev/e1/goroot/src/unicode/digit.go",
		"/home/exedev/e1/goroot/src/unicode/graphic.go",
		"/home/exedev/e1/goroot/src/unicode/letter.go",
		"/home/exedev/e1/goroot/src/unicode/tables.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [],
	"Module": null,
	"ImportMap": {},
	"PackageFile": {},
	"Standard": {},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b057/vet.out",
	"Stdout": "$WORK/b057/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/unicode
cat >$WORK/b044/vet.cfg << 'EOF' # internal
{
	"ID": "unicode/utf8",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/unicode/utf8",
	"ImportPath": "unicode/utf8",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/unicode/utf8/utf8.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [],
	"Module": null,
	"ImportMap": {},
	"PackageFile": {},
	"Standard": {},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b044/vet.out",
	"Stdout": "$WORK/b044/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/unicode/utf8
cat >$WORK/b059/vet.cfg << 'EOF' # internal
{
	"ID": "bytes",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/bytes",
	"ImportPath": "bytes",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/bytes/buffer.go",
		"/home/exedev/e1/goroot/src/bytes/bytes.go",
		"/home/exedev/e1/goroot/src/bytes/iter.go",
		"/home/exedev/e1/goroot/src/bytes/reader.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [
		"/home/exedev/e1/goroot/src/bytes/boundary_test.go",
		"/home/exedev/e1/goroot/src/bytes/bytes_js_wasm_test.go"
	],
	"Module": null,
	"ImportMap": {
		"errors": "errors",
		"internal/bytealg": "internal/bytealg",
		"io": "io",
		"iter": "iter",
		"math/bits": "math/bits",
		"unicode": "unicode",
		"unicode/utf8": "unicode/utf8",
		"unsafe": "unsafe"
	},
	"PackageFile": {
		"errors": "$WORK/b003/_pkg_.a",
		"internal/bytealg": "$WORK/b010/_pkg_.a",
		"io": "$WORK/b038/_pkg_.a",
		"iter": "$WORK/b047/_pkg_.a",
		"math/bits": "$WORK/b031/_pkg_.a",
		"unicode": "$WORK/b057/_pkg_.a",
		"unicode/utf8": "$WORK/b044/_pkg_.a"
	},
	"Standard": {
		"errors": true,
		"internal/bytealg": true,
		"io": true,
		"iter": true,
		"math/bits": true,
		"unicode": true,
		"unicode/utf8": true,
		"unsafe": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b059/vet.out",
	"Stdout": "$WORK/b059/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/bytes
cat >$WORK/b037/vet.cfg << 'EOF' # internal
{
	"ID": "internal/oserror",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/internal/oserror",
	"ImportPath": "internal/oserror",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/internal/oserror/errors.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [],
	"Module": null,
	"ImportMap": {
		"errors": "errors"
	},
	"PackageFile": {
		"errors": "$WORK/b003/_pkg_.a"
	},
	"Standard": {
		"errors": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b037/vet.out",
	"Stdout": "$WORK/b037/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/internal/oserror
cat >$WORK/b049/vet.cfg << 'EOF' # internal
{
	"ID": "syscall",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/syscall",
	"ImportPath": "syscall",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/syscall/dirent.go",
		"/home/exedev/e1/goroot/src/syscall/env_unix.go",
		"/home/exedev/e1/goroot/src/syscall/fs_wasip1.go",
		"/home/exedev/e1/goroot/src/syscall/net.go",
		"/home/exedev/e1/goroot/src/syscall/net_fake.go",
		"/home/exedev/e1/goroot/src/syscall/net_wasip1.go",
		"/home/exedev/e1/goroot/src/syscall/os_wasip1.go",
		"/home/exedev/e1/goroot/src/syscall/syscall.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_wasip1.go",
		"/home/exedev/e1/goroot/src/syscall/tables_wasip1.go",
		"/home/exedev/e1/goroot/src/syscall/time_nofake.go",
		"/home/exedev/e1/goroot/src/syscall/timestruct.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [
		"/home/exedev/e1/goroot/src/syscall/badlinkname_unix.go",
		"/home/exedev/e1/goroot/src/syscall/bpf_bsd.go",
		"/home/exedev/e1/goroot/src/syscall/const_plan9.go",
		"/home/exedev/e1/goroot/src/syscall/creds_test.go",
		"/home/exedev/e1/goroot/src/syscall/dir_plan9.go",
		"/home/exedev/e1/goroot/src/syscall/dirent_test.go",
		"/home/exedev/e1/goroot/src/syscall/dll_windows.go",
		"/home/exedev/e1/goroot/src/syscall/env_windows.go",
		"/home/exedev/e1/goroot/src/syscall/errors_plan9.go",
		"/home/exedev/e1/goroot/src/syscall/exec_aix_test.go",
		"/home/exedev/e1/goroot/src/syscall/exec_bsd.go",
		"/home/exedev/e1/goroot/src/syscall/exec_freebsd.go",
		"/home/exedev/e1/goroot/src/syscall/exec_freebsd_test.go",
		"/home/exedev/e1/goroot/src/syscall/exec_libc.go",
		"/home/exedev/e1/goroot/src/syscall/exec_libc2.go",
		"/home/exedev/e1/goroot/src/syscall/exec_linux.go",
		"/home/exedev/e1/goroot/src/syscall/exec_linux_test.go",
		"/home/exedev/e1/goroot/src/syscall/exec_pdeathsig_test.go",
		"/home/exedev/e1/goroot/src/syscall/exec_plan9.go",
		"/home/exedev/e1/goroot/src/syscall/exec_solaris_test.go",
		"/home/exedev/e1/goroot/src/syscall/exec_unix.go",
		"/home/exedev/e1/goroot/src/syscall/exec_unix_test.go",
		"/home/exedev/e1/goroot/src/syscall/exec_windows.go",
		"/home/exedev/e1/goroot/src/syscall/exec_windows_test.go",
		"/home/exedev/e1/goroot/src/syscall/export_bsd_test.go",
		"/home/exedev/e1/goroot/src/syscall/export_linux_test.go",
		"/home/exedev/e1/goroot/src/syscall/export_rlimit_test.go",
		"/home/exedev/e1/goroot/src/syscall/export_windows_test.go",
		"/home/exedev/e1/goroot/src/syscall/flock_aix.go",
		"/home/exedev/e1/goroot/src/syscall/flock_bsd.go",
		"/home/exedev/e1/goroot/src/syscall/flock_linux.go",
		"/home/exedev/e1/goroot/src/syscall/flock_linux_32bit.go",
		"/home/exedev/e1/goroot/src/syscall/forkpipe.go",
		"/home/exedev/e1/goroot/src/syscall/forkpipe2.go",
		"/home/exedev/e1/goroot/src/syscall/fs_js.go",
		"/home/exedev/e1/goroot/src/syscall/getdirentries_test.go",
		"/home/exedev/e1/goroot/src/syscall/linkname_bsd.go",
		"/home/exedev/e1/goroot/src/syscall/linkname_darwin.go",
		"/home/exedev/e1/goroot/src/syscall/linkname_libc.go",
		"/home/exedev/e1/goroot/src/syscall/linkname_openbsd.go",
		"/home/exedev/e1/goroot/src/syscall/linkname_unix.go",
		"/home/exedev/e1/goroot/src/syscall/lsf_linux.go",
		"/home/exedev/e1/goroot/src/syscall/mkasm.go",
		"/home/exedev/e1/goroot/src/syscall/mkpost.go",
		"/home/exedev/e1/goroot/src/syscall/mksyscall_windows.go",
		"/home/exedev/e1/goroot/src/syscall/mmap_unix_test.go",
		"/home/exedev/e1/goroot/src/syscall/net_js.go",
		"/home/exedev/e1/goroot/src/syscall/netlink_linux.go",
		"/home/exedev/e1/goroot/src/syscall/pwd_plan9.go",
		"/home/exedev/e1/goroot/src/syscall/rlimit.go",
		"/home/exedev/e1/goroot/src/syscall/rlimit_darwin.go",
		"/home/exedev/e1/goroot/src/syscall/rlimit_stub.go",
		"/home/exedev/e1/goroot/src/syscall/rlimit_test.go",
		"/home/exedev/e1/goroot/src/syscall/route_bsd.go",
		"/home/exedev/e1/goroot/src/syscall/route_darwin.go",
		"/home/exedev/e1/goroot/src/syscall/route_dragonfly.go",
		"/home/exedev/e1/goroot/src/syscall/route_freebsd.go",
		"/home/exedev/e1/goroot/src/syscall/route_freebsd_32bit.go",
		"/home/exedev/e1/goroot/src/syscall/route_freebsd_64bit.go",
		"/home/exedev/e1/goroot/src/syscall/route_netbsd.go",
		"/home/exedev/e1/goroot/src/syscall/route_openbsd.go",
		"/home/exedev/e1/goroot/src/syscall/security_windows.go",
		"/home/exedev/e1/goroot/src/syscall/setuidgid_32_linux.go",
		"/home/exedev/e1/goroot/src/syscall/setuidgid_linux.go",
		"/home/exedev/e1/goroot/src/syscall/sockcmsg_dragonfly.go",
		"/home/exedev/e1/goroot/src/syscall/sockcmsg_linux.go",
		"/home/exedev/e1/goroot/src/syscall/sockcmsg_unix.go",
		"/home/exedev/e1/goroot/src/syscall/sockcmsg_unix_other.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_aix.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_aix_ppc64.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_bsd.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_bsd_test.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_darwin.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_darwin_amd64.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_darwin_arm64.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_dragonfly.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_dragonfly_amd64.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_freebsd.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_freebsd_386.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_freebsd_amd64.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_freebsd_arm.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_freebsd_arm64.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_freebsd_riscv64.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_freebsd_test.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_illumos.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_js.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_linux.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_linux_386.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_linux_amd64.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_linux_arm.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_linux_arm64.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_linux_loong64.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_linux_mips64x.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_linux_mipsx.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_linux_ppc64x.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_linux_riscv64.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_linux_s390x.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_linux_test.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_netbsd.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_netbsd_386.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_netbsd_amd64.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_netbsd_arm.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_netbsd_arm64.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_openbsd.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_openbsd_386.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_openbsd_amd64.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_openbsd_arm.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_openbsd_arm64.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_openbsd_ppc64.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_openbsd_riscv64.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_plan9.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_plan9_test.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_ptrace_test.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_solaris.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_solaris_amd64.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_solarisonly.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_unix.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_unix_test.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_windows.go",
		"/home/exedev/e1/goroot/src/syscall/syscall_windows_test.go",
		"/home/exedev/e1/goroot/src/syscall/tables_js.go",
		"/home/exedev/e1/goroot/src/syscall/time_fake.go",
		"/home/exedev/e1/goroot/src/syscall/types_aix.go",
		"/home/exedev/e1/goroot/src/syscall/types_darwin.go",
		"/home/exedev/e1/goroot/src/syscall/types_dragonfly.go",
		"/home/exedev/e1/goroot/src/syscall/types_freebsd.go",
		"/home/exedev/e1/goroot/src/syscall/types_illumos_amd64.go",
		"/home/exedev/e1/goroot/src/syscall/types_linux.go",
		"/home/exedev/e1/goroot/src/syscall/types_netbsd.go",
		"/home/exedev/e1/goroot/src/syscall/types_openbsd.go",
		"/home/exedev/e1/goroot/src/syscall/types_solaris.go",
		"/home/exedev/e1/goroot/src/syscall/types_windows.go",
		"/home/exedev/e1/goroot/src/syscall/types_windows_386.go",
		"/home/exedev/e1/goroot/src/syscall/types_windows_amd64.go",
		"/home/exedev/e1/goroot/src/syscall/types_windows_arm64.go",
		"/home/exedev/e1/goroot/src/syscall/wtf8_windows.go",
		"/home/exedev/e1/goroot/src/syscall/wtf8_windows_test.go",
		"/home/exedev/e1/goroot/src/syscall/zerrors_aix_ppc64.go",
		"/home/exedev/e1/goroot/src/syscall/zerrors_darwin_amd64.go",
		"/home/exedev/e1/goroot/src/syscall/zerrors_darwin_arm64.go",
		"/home/exedev/e1/goroot/src/syscall/zerrors_dragonfly_amd64.go",
		"/home/exedev/e1/goroot/src/syscall/zerrors_freebsd_386.go",
		"/home/exedev/e1/goroot/src/syscall/zerrors_freebsd_amd64.go",
		"/home/exedev/e1/goroot/src/syscall/zerrors_freebsd_arm.go",
		"/home/exedev/e1/goroot/src/syscall/zerrors_freebsd_arm64.go",
		"/home/exedev/e1/goroot/src/syscall/zerrors_freebsd_riscv64.go",
		"/home/exedev/e1/goroot/src/syscall/zerrors_linux_386.go",
		"/home/exedev/e1/goroot/src/syscall/zerrors_linux_amd64.go",
		"/home/exedev/e1/goroot/src/syscall/zerrors_linux_arm.go",
		"/home/exedev/e1/goroot/src/syscall/zerrors_linux_arm64.go",
		"/home/exedev/e1/goroot/src/syscall/zerrors_linux_loong64.go",
		"/home/exedev/e1/goroot/src/syscall/zerrors_linux_mips.go",
		"/home/exedev/e1/goroot/src/syscall/zerrors_linux_mips64.go",
		"/home/exedev/e1/goroot/src/syscall/zerrors_linux_mips64le.go",
		"/home/exedev/e1/goroot/src/syscall/zerrors_linux_mipsle.go",
		"/home/exedev/e1/goroot/src/syscall/zerrors_linux_ppc64.go",
		"/home/exedev/e1/goroot/src/syscall/zerrors_linux_ppc64le.go",
		"/home/exedev/e1/goroot/src/syscall/zerrors_linux_riscv64.go",
		"/home/exedev/e1/goroot/src/syscall/zerrors_linux_s390x.go",
		"/home/exedev/e1/goroot/src/syscall/zerrors_netbsd_386.go",
		"/home/exedev/e1/goroot/src/syscall/zerrors_netbsd_amd64.go",
		"/home/exedev/e1/goroot/src/syscall/zerrors_netbsd_arm.go",
		"/home/exedev/e1/goroot/src/syscall/zerrors_netbsd_arm64.go",
		"/home/exedev/e1/goroot/src/syscall/zerrors_openbsd_386.go",
		"/home/exedev/e1/goroot/src/syscall/zerrors_openbsd_amd64.go",
		"/home/exedev/e1/goroot/src/syscall/zerrors_openbsd_arm.go",
		"/home/exedev/e1/goroot/src/syscall/zerrors_openbsd_arm64.go",
		"/home/exedev/e1/goroot/src/syscall/zerrors_openbsd_ppc64.go",
		"/home/exedev/e1/goroot/src/syscall/zerrors_openbsd_riscv64.go",
		"/home/exedev/e1/goroot/src/syscall/zerrors_solaris_amd64.go",
		"/home/exedev/e1/goroot/src/syscall/zerrors_windows.go",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_aix_ppc64.go",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_darwin_amd64.go",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_darwin_arm64.go",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_dragonfly_amd64.go",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_freebsd_386.go",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_freebsd_amd64.go",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_freebsd_arm.go",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_freebsd_arm64.go",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_freebsd_riscv64.go",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_linux_386.go",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_linux_amd64.go",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_linux_arm.go",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_linux_arm64.go",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_linux_loong64.go",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_linux_mips.go",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_linux_mips64.go",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_linux_mips64le.go",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_linux_mipsle.go",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_linux_ppc64.go",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_linux_ppc64le.go",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_linux_riscv64.go",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_linux_s390x.go",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_netbsd_386.go",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_netbsd_amd64.go",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_netbsd_arm.go",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_netbsd_arm64.go",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_openbsd_386.go",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_openbsd_amd64.go",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_openbsd_arm.go",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_openbsd_arm64.go",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_openbsd_ppc64.go",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_openbsd_riscv64.go",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_plan9_386.go",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_plan9_amd64.go",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_plan9_arm.go",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_solaris_amd64.go",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_windows.go",
		"/home/exedev/e1/goroot/src/syscall/zsysctl_openbsd.go",
		"/home/exedev/e1/goroot/src/syscall/zsysnum_darwin_amd64.go",
		"/home/exedev/e1/goroot/src/syscall/zsysnum_darwin_arm64.go",
		"/home/exedev/e1/goroot/src/syscall/zsysnum_dragonfly_amd64.go",
		"/home/exedev/e1/goroot/src/syscall/zsysnum_freebsd_386.go",
		"/home/exedev/e1/goroot/src/syscall/zsysnum_freebsd_amd64.go",
		"/home/exedev/e1/goroot/src/syscall/zsysnum_freebsd_arm.go",
		"/home/exedev/e1/goroot/src/syscall/zsysnum_freebsd_arm64.go",
		"/home/exedev/e1/goroot/src/syscall/zsysnum_freebsd_riscv64.go",
		"/home/exedev/e1/goroot/src/syscall/zsysnum_linux_386.go",
		"/home/exedev/e1/goroot/src/syscall/zsysnum_linux_amd64.go",
		"/home/exedev/e1/goroot/src/syscall/zsysnum_linux_arm.go",
		"/home/exedev/e1/goroot/src/syscall/zsysnum_linux_arm64.go",
		"/home/exedev/e1/goroot/src/syscall/zsysnum_linux_loong64.go",
		"/home/exedev/e1/goroot/src/syscall/zsysnum_linux_mips.go",
		"/home/exedev/e1/goroot/src/syscall/zsysnum_linux_mips64.go",
		"/home/exedev/e1/goroot/src/syscall/zsysnum_linux_mips64le.go",
		"/home/exedev/e1/goroot/src/syscall/zsysnum_linux_mipsle.go",
		"/home/exedev/e1/goroot/src/syscall/zsysnum_linux_ppc64.go",
		"/home/exedev/e1/goroot/src/syscall/zsysnum_linux_ppc64le.go",
		"/home/exedev/e1/goroot/src/syscall/zsysnum_linux_riscv64.go",
		"/home/exedev/e1/goroot/src/syscall/zsysnum_linux_s390x.go",
		"/home/exedev/e1/goroot/src/syscall/zsysnum_netbsd_386.go",
		"/home/exedev/e1/goroot/src/syscall/zsysnum_netbsd_amd64.go",
		"/home/exedev/e1/goroot/src/syscall/zsysnum_netbsd_arm.go",
		"/home/exedev/e1/goroot/src/syscall/zsysnum_netbsd_arm64.go",
		"/home/exedev/e1/goroot/src/syscall/zsysnum_openbsd_386.go",
		"/home/exedev/e1/goroot/src/syscall/zsysnum_openbsd_amd64.go",
		"/home/exedev/e1/goroot/src/syscall/zsysnum_openbsd_arm.go",
		"/home/exedev/e1/goroot/src/syscall/zsysnum_openbsd_arm64.go",
		"/home/exedev/e1/goroot/src/syscall/zsysnum_openbsd_ppc64.go",
		"/home/exedev/e1/goroot/src/syscall/zsysnum_openbsd_riscv64.go",
		"/home/exedev/e1/goroot/src/syscall/zsysnum_plan9.go",
		"/home/exedev/e1/goroot/src/syscall/zsysnum_solaris_amd64.go",
		"/home/exedev/e1/goroot/src/syscall/ztypes_aix_ppc64.go",
		"/home/exedev/e1/goroot/src/syscall/ztypes_darwin_amd64.go",
		"/home/exedev/e1/goroot/src/syscall/ztypes_darwin_arm64.go",
		"/home/exedev/e1/goroot/src/syscall/ztypes_dragonfly_amd64.go",
		"/home/exedev/e1/goroot/src/syscall/ztypes_freebsd_386.go",
		"/home/exedev/e1/goroot/src/syscall/ztypes_freebsd_amd64.go",
		"/home/exedev/e1/goroot/src/syscall/ztypes_freebsd_arm.go",
		"/home/exedev/e1/goroot/src/syscall/ztypes_freebsd_arm64.go",
		"/home/exedev/e1/goroot/src/syscall/ztypes_freebsd_riscv64.go",
		"/home/exedev/e1/goroot/src/syscall/ztypes_linux_386.go",
		"/home/exedev/e1/goroot/src/syscall/ztypes_linux_amd64.go",
		"/home/exedev/e1/goroot/src/syscall/ztypes_linux_arm.go",
		"/home/exedev/e1/goroot/src/syscall/ztypes_linux_arm64.go",
		"/home/exedev/e1/goroot/src/syscall/ztypes_linux_loong64.go",
		"/home/exedev/e1/goroot/src/syscall/ztypes_linux_mips.go",
		"/home/exedev/e1/goroot/src/syscall/ztypes_linux_mips64.go",
		"/home/exedev/e1/goroot/src/syscall/ztypes_linux_mips64le.go",
		"/home/exedev/e1/goroot/src/syscall/ztypes_linux_mipsle.go",
		"/home/exedev/e1/goroot/src/syscall/ztypes_linux_ppc64.go",
		"/home/exedev/e1/goroot/src/syscall/ztypes_linux_ppc64le.go",
		"/home/exedev/e1/goroot/src/syscall/ztypes_linux_riscv64.go",
		"/home/exedev/e1/goroot/src/syscall/ztypes_linux_s390x.go",
		"/home/exedev/e1/goroot/src/syscall/ztypes_netbsd_386.go",
		"/home/exedev/e1/goroot/src/syscall/ztypes_netbsd_amd64.go",
		"/home/exedev/e1/goroot/src/syscall/ztypes_netbsd_arm.go",
		"/home/exedev/e1/goroot/src/syscall/ztypes_netbsd_arm64.go",
		"/home/exedev/e1/goroot/src/syscall/ztypes_openbsd_386.go",
		"/home/exedev/e1/goroot/src/syscall/ztypes_openbsd_amd64.go",
		"/home/exedev/e1/goroot/src/syscall/ztypes_openbsd_arm.go",
		"/home/exedev/e1/goroot/src/syscall/ztypes_openbsd_arm64.go",
		"/home/exedev/e1/goroot/src/syscall/ztypes_openbsd_ppc64.go",
		"/home/exedev/e1/goroot/src/syscall/ztypes_openbsd_riscv64.go",
		"/home/exedev/e1/goroot/src/syscall/ztypes_solaris_amd64.go",
		"/home/exedev/e1/goroot/src/syscall/asm9_unix2_amd64.s",
		"/home/exedev/e1/goroot/src/syscall/asm_aix_ppc64.s",
		"/home/exedev/e1/goroot/src/syscall/asm_darwin_amd64.s",
		"/home/exedev/e1/goroot/src/syscall/asm_darwin_arm64.s",
		"/home/exedev/e1/goroot/src/syscall/asm_freebsd_arm.s",
		"/home/exedev/e1/goroot/src/syscall/asm_freebsd_arm64.s",
		"/home/exedev/e1/goroot/src/syscall/asm_freebsd_riscv64.s",
		"/home/exedev/e1/goroot/src/syscall/asm_linux_386.s",
		"/home/exedev/e1/goroot/src/syscall/asm_linux_amd64.s",
		"/home/exedev/e1/goroot/src/syscall/asm_linux_arm.s",
		"/home/exedev/e1/goroot/src/syscall/asm_linux_arm64.s",
		"/home/exedev/e1/goroot/src/syscall/asm_linux_loong64.s",
		"/home/exedev/e1/goroot/src/syscall/asm_linux_mips64x.s",
		"/home/exedev/e1/goroot/src/syscall/asm_linux_mipsx.s",
		"/home/exedev/e1/goroot/src/syscall/asm_linux_ppc64x.s",
		"/home/exedev/e1/goroot/src/syscall/asm_linux_riscv64.s",
		"/home/exedev/e1/goroot/src/syscall/asm_linux_s390x.s",
		"/home/exedev/e1/goroot/src/syscall/asm_netbsd_arm.s",
		"/home/exedev/e1/goroot/src/syscall/asm_netbsd_arm64.s",
		"/home/exedev/e1/goroot/src/syscall/asm_openbsd_386.s",
		"/home/exedev/e1/goroot/src/syscall/asm_openbsd_amd64.s",
		"/home/exedev/e1/goroot/src/syscall/asm_openbsd_arm.s",
		"/home/exedev/e1/goroot/src/syscall/asm_openbsd_arm64.s",
		"/home/exedev/e1/goroot/src/syscall/asm_openbsd_ppc64.s",
		"/home/exedev/e1/goroot/src/syscall/asm_openbsd_riscv64.s",
		"/home/exedev/e1/goroot/src/syscall/asm_plan9_386.s",
		"/home/exedev/e1/goroot/src/syscall/asm_plan9_amd64.s",
		"/home/exedev/e1/goroot/src/syscall/asm_plan9_arm.s",
		"/home/exedev/e1/goroot/src/syscall/asm_solaris_amd64.s",
		"/home/exedev/e1/goroot/src/syscall/asm_unix_386.s",
		"/home/exedev/e1/goroot/src/syscall/asm_unix_amd64.s",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_darwin_amd64.s",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_darwin_arm64.s",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_openbsd_386.s",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_openbsd_amd64.s",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_openbsd_arm.s",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_openbsd_arm64.s",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_openbsd_ppc64.s",
		"/home/exedev/e1/goroot/src/syscall/zsyscall_openbsd_riscv64.s"
	],
	"Module": null,
	"ImportMap": {
		"errors": "errors",
		"internal/bytealg": "internal/bytealg",
		"internal/byteorder": "internal/byteorder",
		"internal/goarch": "internal/goarch",
		"internal/oserror": "internal/oserror",
		"internal/strconv": "internal/strconv",
		"internal/stringslite": "internal/stringslite",
		"runtime": "runtime",
		"structs": "structs",
		"sync": "sync",
		"unsafe": "unsafe"
	},
	"PackageFile": {
		"errors": "$WORK/b003/_pkg_.a",
		"internal/bytealg": "$WORK/b010/_pkg_.a",
		"internal/byteorder": "$WORK/b012/_pkg_.a",
		"internal/goarch": "$WORK/b006/_pkg_.a",
		"internal/oserror": "$WORK/b037/_pkg_.a",
		"internal/strconv": "$WORK/b030/_pkg_.a",
		"internal/stringslite": "$WORK/b032/_pkg_.a",
		"runtime": "$WORK/b009/_pkg_.a",
		"structs": "$WORK/b034/_pkg_.a",
		"sync": "$WORK/b039/_pkg_.a"
	},
	"Standard": {
		"errors": true,
		"internal/bytealg": true,
		"internal/byteorder": true,
		"internal/goarch": true,
		"internal/oserror": true,
		"internal/strconv": true,
		"internal/stringslite": true,
		"runtime": true,
		"structs": true,
		"sync": true,
		"unsafe": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b049/vet.out",
	"Stdout": "$WORK/b049/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/syscall
cat >$WORK/b048/vet.cfg << 'EOF' # internal
{
	"ID": "time",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/time",
	"ImportPath": "time",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/time/format.go",
		"/home/exedev/e1/goroot/src/time/format_rfc3339.go",
		"/home/exedev/e1/goroot/src/time/sleep.go",
		"/home/exedev/e1/goroot/src/time/sys_unix.go",
		"/home/exedev/e1/goroot/src/time/tick.go",
		"/home/exedev/e1/goroot/src/time/time.go",
		"/home/exedev/e1/goroot/src/time/zoneinfo.go",
		"/home/exedev/e1/goroot/src/time/zoneinfo_goroot.go",
		"/home/exedev/e1/goroot/src/time/zoneinfo_read.go",
		"/home/exedev/e1/goroot/src/time/zoneinfo_wasip1.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [
		"/home/exedev/e1/goroot/src/time/embed.go",
		"/home/exedev/e1/goroot/src/time/export_android_test.go",
		"/home/exedev/e1/goroot/src/time/export_windows_test.go",
		"/home/exedev/e1/goroot/src/time/genzabbrs.go",
		"/home/exedev/e1/goroot/src/time/sys_plan9.go",
		"/home/exedev/e1/goroot/src/time/sys_windows.go",
		"/home/exedev/e1/goroot/src/time/zoneinfo_abbrs_windows.go",
		"/home/exedev/e1/goroot/src/time/zoneinfo_android.go",
		"/home/exedev/e1/goroot/src/time/zoneinfo_android_test.go",
		"/home/exedev/e1/goroot/src/time/zoneinfo_ios.go",
		"/home/exedev/e1/goroot/src/time/zoneinfo_js.go",
		"/home/exedev/e1/goroot/src/time/zoneinfo_plan9.go",
		"/home/exedev/e1/goroot/src/time/zoneinfo_unix.go",
		"/home/exedev/e1/goroot/src/time/zoneinfo_unix_test.go",
		"/home/exedev/e1/goroot/src/time/zoneinfo_windows.go",
		"/home/exedev/e1/goroot/src/time/zoneinfo_windows_test.go"
	],
	"Module": null,
	"ImportMap": {
		"errors": "errors",
		"internal/bytealg": "internal/bytealg",
		"internal/stringslite": "internal/stringslite",
		"math/bits": "math/bits",
		"runtime": "runtime",
		"sync": "sync",
		"syscall": "syscall",
		"unsafe": "unsafe"
	},
	"PackageFile": {
		"errors": "$WORK/b003/_pkg_.a",
		"internal/bytealg": "$WORK/b010/_pkg_.a",
		"internal/stringslite": "$WORK/b032/_pkg_.a",
		"math/bits": "$WORK/b031/_pkg_.a",
		"runtime": "$WORK/b009/_pkg_.a",
		"sync": "$WORK/b039/_pkg_.a",
		"syscall": "$WORK/b049/_pkg_.a"
	},
	"Standard": {
		"errors": true,
		"internal/bytealg": true,
		"internal/stringslite": true,
		"math/bits": true,
		"runtime": true,
		"sync": true,
		"syscall": true,
		"unsafe": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b048/vet.out",
	"Stdout": "$WORK/b048/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/time
cat >$WORK/b060/vet.cfg << 'EOF' # internal
{
	"ID": "context",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/context",
	"ImportPath": "context",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/context/context.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [],
	"Module": null,
	"ImportMap": {
		"errors": "errors",
		"internal/reflectlite": "internal/reflectlite",
		"sync": "sync",
		"sync/atomic": "sync/atomic",
		"time": "time"
	},
	"PackageFile": {
		"errors": "$WORK/b003/_pkg_.a",
		"internal/reflectlite": "$WORK/b004/_pkg_.a",
		"sync": "$WORK/b039/_pkg_.a",
		"sync/atomic": "$WORK/b041/_pkg_.a",
		"time": "$WORK/b048/_pkg_.a"
	},
	"Standard": {
		"errors": true,
		"internal/reflectlite": true,
		"sync": true,
		"sync/atomic": true,
		"time": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b060/vet.out",
	"Stdout": "$WORK/b060/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/context
cat >$WORK/b062/vet.cfg << 'EOF' # internal
{
	"ID": "encoding",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/encoding",
	"ImportPath": "encoding",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/encoding/encoding.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [],
	"Module": null,
	"ImportMap": {},
	"PackageFile": {},
	"Standard": {},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b062/vet.out",
	"Stdout": "$WORK/b062/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/encoding
cat >$WORK/b046/vet.cfg << 'EOF' # internal
{
	"ID": "cmp",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/cmp",
	"ImportPath": "cmp",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/cmp/cmp.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [],
	"Module": null,
	"ImportMap": {},
	"PackageFile": {},
	"Standard": {},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b046/vet.out",
	"Stdout": "$WORK/b046/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/cmp
cat >$WORK/b055/vet.cfg << 'EOF' # internal
{
	"ID": "math",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/math",
	"ImportPath": "math",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/math/abs.go",
		"/home/exedev/e1/goroot/src/math/acosh.go",
		"/home/exedev/e1/goroot/src/math/asin.go",
		"/home/exedev/e1/goroot/src/math/asinh.go",
		"/home/exedev/e1/goroot/src/math/atan.go",
		"/home/exedev/e1/goroot/src/math/atan2.go",
		"/home/exedev/e1/goroot/src/math/atanh.go",
		"/home/exedev/e1/goroot/src/math/bits.go",
		"/home/exedev/e1/goroot/src/math/cbrt.go",
		"/home/exedev/e1/goroot/src/math/const.go",
		"/home/exedev/e1/goroot/src/math/copysign.go",
		"/home/exedev/e1/goroot/src/math/dim.go",
		"/home/exedev/e1/goroot/src/math/dim_noasm.go",
		"/home/exedev/e1/goroot/src/math/erf.go",
		"/home/exedev/e1/goroot/src/math/erfinv.go",
		"/home/exedev/e1/goroot/src/math/exp.go",
		"/home/exedev/e1/goroot/src/math/exp2_noasm.go",
		"/home/exedev/e1/goroot/src/math/exp_noasm.go",
		"/home/exedev/e1/goroot/src/math/expm1.go",
		"/home/exedev/e1/goroot/src/math/floor.go",
		"/home/exedev/e1/goroot/src/math/floor_asm.go",
		"/home/exedev/e1/goroot/src/math/fma.go",
		"/home/exedev/e1/goroot/src/math/frexp.go",
		"/home/exedev/e1/goroot/src/math/gamma.go",
		"/home/exedev/e1/goroot/src/math/hypot.go",
		"/home/exedev/e1/goroot/src/math/hypot_noasm.go",
		"/home/exedev/e1/goroot/src/math/j0.go",
		"/home/exedev/e1/goroot/src/math/j1.go",
		"/home/exedev/e1/goroot/src/math/jn.go",
		"/home/exedev/e1/goroot/src/math/ldexp.go",
		"/home/exedev/e1/goroot/src/math/lgamma.go",
		"/home/exedev/e1/goroot/src/math/log.go",
		"/home/exedev/e1/goroot/src/math/log10.go",
		"/home/exedev/e1/goroot/src/math/log1p.go",
		"/home/exedev/e1/goroot/src/math/log_stub.go",
		"/home/exedev/e1/goroot/src/math/logb.go",
		"/home/exedev/e1/goroot/src/math/mod.go",
		"/home/exedev/e1/goroot/src/math/modf.go",
		"/home/exedev/e1/goroot/src/math/nextafter.go",
		"/home/exedev/e1/goroot/src/math/pow.go",
		"/home/exedev/e1/goroot/src/math/pow10.go",
		"/home/exedev/e1/goroot/src/math/remainder.go",
		"/home/exedev/e1/goroot/src/math/signbit.go",
		"/home/exedev/e1/goroot/src/math/sin.go",
		"/home/exedev/e1/goroot/src/math/sincos.go",
		"/home/exedev/e1/goroot/src/math/sinh.go",
		"/home/exedev/e1/goroot/src/math/sqrt.go",
		"/home/exedev/e1/goroot/src/math/stubs.go",
		"/home/exedev/e1/goroot/src/math/tan.go",
		"/home/exedev/e1/goroot/src/math/tanh.go",
		"/home/exedev/e1/goroot/src/math/trig_reduce.go",
		"/home/exedev/e1/goroot/src/math/unsafe.go"
	],
	"NonGoFiles": [
		"/home/exedev/e1/goroot/src/math/floor_wasm.s"
	],
	"IgnoredFiles": [
		"/home/exedev/e1/goroot/src/math/arith_s390x.go",
		"/home/exedev/e1/goroot/src/math/arith_s390x_test.go",
		"/home/exedev/e1/goroot/src/math/dim_asm.go",
		"/home/exedev/e1/goroot/src/math/exp2_asm.go",
		"/home/exedev/e1/goroot/src/math/exp_amd64.go",
		"/home/exedev/e1/goroot/src/math/exp_asm.go",
		"/home/exedev/e1/goroot/src/math/export_s390x_test.go",
		"/home/exedev/e1/goroot/src/math/floor_noasm.go",
		"/home/exedev/e1/goroot/src/math/hypot_asm.go",
		"/home/exedev/e1/goroot/src/math/log_asm.go",
		"/home/exedev/e1/goroot/src/math/acos_s390x.s",
		"/home/exedev/e1/goroot/src/math/acosh_s390x.s",
		"/home/exedev/e1/goroot/src/math/asin_s390x.s",
		"/home/exedev/e1/goroot/src/math/asinh_s390x.s",
		"/home/exedev/e1/goroot/src/math/atan2_s390x.s",
		"/home/exedev/e1/goroot/src/math/atan_s390x.s",
		"/home/exedev/e1/goroot/src/math/atanh_s390x.s",
		"/home/exedev/e1/goroot/src/math/cbrt_s390x.s",
		"/home/exedev/e1/goroot/src/math/cosh_s390x.s",
		"/home/exedev/e1/goroot/src/math/dim_amd64.s",
		"/home/exedev/e1/goroot/src/math/dim_arm64.s",
		"/home/exedev/e1/goroot/src/math/dim_loong64.s",
		"/home/exedev/e1/goroot/src/math/dim_riscv64.s",
		"/home/exedev/e1/goroot/src/math/dim_s390x.s",
		"/home/exedev/e1/goroot/src/math/erf_s390x.s",
		"/home/exedev/e1/goroot/src/math/erfc_s390x.s",
		"/home/exedev/e1/goroot/src/math/exp_amd64.s",
		"/home/exedev/e1/goroot/src/math/exp_arm64.s",
		"/home/exedev/e1/goroot/src/math/exp_loong64.s",
		"/home/exedev/e1/goroot/src/math/exp_riscv64.s",
		"/home/exedev/e1/goroot/src/math/exp_s390x.s",
		"/home/exedev/e1/goroot/src/math/expm1_s390x.s",
		"/home/exedev/e1/goroot/src/math/floor_386.s",
		"/home/exedev/e1/goroot/src/math/floor_amd64.s",
		"/home/exedev/e1/goroot/src/math/floor_arm64.s",
		"/home/exedev/e1/goroot/src/math/floor_loong64.s",
		"/home/exedev/e1/goroot/src/math/floor_ppc64x.s",
		"/home/exedev/e1/goroot/src/math/floor_riscv64.s",
		"/home/exedev/e1/goroot/src/math/floor_s390x.s",
		"/home/exedev/e1/goroot/src/math/hypot_386.s",
		"/home/exedev/e1/goroot/src/math/hypot_amd64.s",
		"/home/exedev/e1/goroot/src/math/log10_s390x.s",
		"/home/exedev/e1/goroot/src/math/log1p_s390x.s",
		"/home/exedev/e1/goroot/src/math/log_amd64.s",
		"/home/exedev/e1/goroot/src/math/log_s390x.s",
		"/home/exedev/e1/goroot/src/math/pow_s390x.s",
		"/home/exedev/e1/goroot/src/math/sin_s390x.s",
		"/home/exedev/e1/goroot/src/math/sinh_s390x.s",
		"/home/exedev/e1/goroot/src/math/stubs_s390x.s",
		"/home/exedev/e1/goroot/src/math/tan_s390x.s",
		"/home/exedev/e1/goroot/src/math/tanh_s390x.s"
	],
	"Module": null,
	"ImportMap": {
		"math/bits": "math/bits",
		"unsafe": "unsafe"
	},
	"PackageFile": {
		"math/bits": "$WORK/b031/_pkg_.a"
	},
	"Standard": {
		"math/bits": true,
		"unsafe": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b055/vet.out",
	"Stdout": "$WORK/b055/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/math
cat >$WORK/b056/vet.cfg << 'EOF' # internal
{
	"ID": "strconv",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/strconv",
	"ImportPath": "strconv",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/strconv/bytealg.go",
		"/home/exedev/e1/goroot/src/strconv/doc.go",
		"/home/exedev/e1/goroot/src/strconv/isprint.go",
		"/home/exedev/e1/goroot/src/strconv/number.go",
		"/home/exedev/e1/goroot/src/strconv/quote.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [
		"/home/exedev/e1/goroot/src/strconv/bytealg_bootstrap.go",
		"/home/exedev/e1/goroot/src/strconv/makeisprint.go"
	],
	"Module": null,
	"ImportMap": {
		"errors": "errors",
		"internal/bytealg": "internal/bytealg",
		"internal/strconv": "internal/strconv",
		"internal/stringslite": "internal/stringslite",
		"unicode/utf8": "unicode/utf8"
	},
	"PackageFile": {
		"errors": "$WORK/b003/_pkg_.a",
		"internal/bytealg": "$WORK/b010/_pkg_.a",
		"internal/strconv": "$WORK/b030/_pkg_.a",
		"internal/stringslite": "$WORK/b032/_pkg_.a",
		"unicode/utf8": "$WORK/b044/_pkg_.a"
	},
	"Standard": {
		"errors": true,
		"internal/bytealg": true,
		"internal/strconv": true,
		"internal/stringslite": true,
		"unicode/utf8": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b056/vet.out",
	"Stdout": "$WORK/b056/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/strconv
cat >$WORK/b054/vet.cfg << 'EOF' # internal
{
	"ID": "reflect",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/reflect",
	"ImportPath": "reflect",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/reflect/abi.go",
		"/home/exedev/e1/goroot/src/reflect/badlinkname.go",
		"/home/exedev/e1/goroot/src/reflect/deepequal.go",
		"/home/exedev/e1/goroot/src/reflect/float32reg_generic.go",
		"/home/exedev/e1/goroot/src/reflect/iter.go",
		"/home/exedev/e1/goroot/src/reflect/makefunc.go",
		"/home/exedev/e1/goroot/src/reflect/map.go",
		"/home/exedev/e1/goroot/src/reflect/swapper.go",
		"/home/exedev/e1/goroot/src/reflect/type.go",
		"/home/exedev/e1/goroot/src/reflect/value.go",
		"/home/exedev/e1/goroot/src/reflect/visiblefields.go"
	],
	"NonGoFiles": [
		"/home/exedev/e1/goroot/src/reflect/asm_wasm.s"
	],
	"IgnoredFiles": [
		"/home/exedev/e1/goroot/src/reflect/abi_test.go",
		"/home/exedev/e1/goroot/src/reflect/arena.go",
		"/home/exedev/e1/goroot/src/reflect/nih_test.go",
		"/home/exedev/e1/goroot/src/reflect/stubs_ppc64x.go",
		"/home/exedev/e1/goroot/src/reflect/stubs_riscv64.go",
		"/home/exedev/e1/goroot/src/reflect/stubs_s390x.go",
		"/home/exedev/e1/goroot/src/reflect/asm_386.s",
		"/home/exedev/e1/goroot/src/reflect/asm_amd64.s",
		"/home/exedev/e1/goroot/src/reflect/asm_arm.s",
		"/home/exedev/e1/goroot/src/reflect/asm_arm64.s",
		"/home/exedev/e1/goroot/src/reflect/asm_loong64.s",
		"/home/exedev/e1/goroot/src/reflect/asm_mips64x.s",
		"/home/exedev/e1/goroot/src/reflect/asm_mipsx.s",
		"/home/exedev/e1/goroot/src/reflect/asm_ppc64x.s",
		"/home/exedev/e1/goroot/src/reflect/asm_riscv64.s",
		"/home/exedev/e1/goroot/src/reflect/asm_s390x.s",
		"/home/exedev/e1/goroot/src/reflect/float32reg_ppc64x.s",
		"/home/exedev/e1/goroot/src/reflect/float32reg_riscv64.s",
		"/home/exedev/e1/goroot/src/reflect/float32reg_s390x.s"
	],
	"Module": null,
	"ImportMap": {
		"errors": "errors",
		"internal/abi": "internal/abi",
		"internal/bytealg": "internal/bytealg",
		"internal/goarch": "internal/goarch",
		"internal/goexperiment": "internal/goexperiment",
		"internal/race": "internal/race",
		"internal/runtime/maps": "internal/runtime/maps",
		"internal/runtime/sys": "internal/runtime/sys",
		"internal/strconv": "internal/strconv",
		"internal/unsafeheader": "internal/unsafeheader",
		"iter": "iter",
		"math": "math",
		"runtime": "runtime",
		"strconv": "strconv",
		"sync": "sync",
		"unicode": "unicode",
		"unicode/utf8": "unicode/utf8",
		"unsafe": "unsafe"
	},
	"PackageFile": {
		"errors": "$WORK/b003/_pkg_.a",
		"internal/abi": "$WORK/b005/_pkg_.a",
		"internal/bytealg": "$WORK/b010/_pkg_.a",
		"internal/goarch": "$WORK/b006/_pkg_.a",
		"internal/goexperiment": "$WORK/b016/_pkg_.a",
		"internal/race": "$WORK/b027/_pkg_.a",
		"internal/runtime/maps": "$WORK/b024/_pkg_.a",
		"internal/runtime/sys": "$WORK/b023/_pkg_.a",
		"internal/strconv": "$WORK/b030/_pkg_.a",
		"internal/unsafeheader": "$WORK/b008/_pkg_.a",
		"iter": "$WORK/b047/_pkg_.a",
		"math": "$WORK/b055/_pkg_.a",
		"runtime": "$WORK/b009/_pkg_.a",
		"strconv": "$WORK/b056/_pkg_.a",
		"sync": "$WORK/b039/_pkg_.a",
		"unicode": "$WORK/b057/_pkg_.a",
		"unicode/utf8": "$WORK/b044/_pkg_.a"
	},
	"Standard": {
		"errors": true,
		"internal/abi": true,
		"internal/bytealg": true,
		"internal/goarch": true,
		"internal/goexperiment": true,
		"internal/race": true,
		"internal/runtime/maps": true,
		"internal/runtime/sys": true,
		"internal/strconv": true,
		"internal/unsafeheader": true,
		"iter": true,
		"math": true,
		"runtime": true,
		"strconv": true,
		"sync": true,
		"unicode": true,
		"unicode/utf8": true,
		"unsafe": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b054/vet.out",
	"Stdout": "$WORK/b054/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/reflect
cat >$WORK/b045/vet.cfg << 'EOF' # internal
{
	"ID": "slices",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/slices",
	"ImportPath": "slices",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/slices/iter.go",
		"/home/exedev/e1/goroot/src/slices/slices.go",
		"/home/exedev/e1/goroot/src/slices/sort.go",
		"/home/exedev/e1/goroot/src/slices/zsortanyfunc.go",
		"/home/exedev/e1/goroot/src/slices/zsortordered.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [],
	"Module": null,
	"ImportMap": {
		"cmp": "cmp",
		"iter": "iter",
		"math/bits": "math/bits",
		"unsafe": "unsafe"
	},
	"PackageFile": {
		"cmp": "$WORK/b046/_pkg_.a",
		"iter": "$WORK/b047/_pkg_.a",
		"math/bits": "$WORK/b031/_pkg_.a"
	},
	"Standard": {
		"cmp": true,
		"iter": true,
		"math/bits": true,
		"unsafe": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b045/vet.out",
	"Stdout": "$WORK/b045/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/slices
cat >$WORK/b064/vet.cfg << 'EOF' # internal
{
	"ID": "internal/fmtsort",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/internal/fmtsort",
	"ImportPath": "internal/fmtsort",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/internal/fmtsort/sort.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [],
	"Module": null,
	"ImportMap": {
		"cmp": "cmp",
		"reflect": "reflect",
		"slices": "slices"
	},
	"PackageFile": {
		"cmp": "$WORK/b046/_pkg_.a",
		"reflect": "$WORK/b054/_pkg_.a",
		"slices": "$WORK/b045/_pkg_.a"
	},
	"Standard": {
		"cmp": true,
		"reflect": true,
		"slices": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b064/vet.out",
	"Stdout": "$WORK/b064/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/internal/fmtsort
cat >$WORK/b043/vet.cfg << 'EOF' # internal
{
	"ID": "path",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/path",
	"ImportPath": "path",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/path/match.go",
		"/home/exedev/e1/goroot/src/path/path.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [],
	"Module": null,
	"ImportMap": {
		"errors": "errors",
		"internal/bytealg": "internal/bytealg",
		"unicode/utf8": "unicode/utf8"
	},
	"PackageFile": {
		"errors": "$WORK/b003/_pkg_.a",
		"internal/bytealg": "$WORK/b010/_pkg_.a",
		"unicode/utf8": "$WORK/b044/_pkg_.a"
	},
	"Standard": {
		"errors": true,
		"internal/bytealg": true,
		"unicode/utf8": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b043/vet.out",
	"Stdout": "$WORK/b043/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/path
cat >$WORK/b036/vet.cfg << 'EOF' # internal
{
	"ID": "io/fs",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/io/fs",
	"ImportPath": "io/fs",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/io/fs/format.go",
		"/home/exedev/e1/goroot/src/io/fs/fs.go",
		"/home/exedev/e1/goroot/src/io/fs/glob.go",
		"/home/exedev/e1/goroot/src/io/fs/readdir.go",
		"/home/exedev/e1/goroot/src/io/fs/readfile.go",
		"/home/exedev/e1/goroot/src/io/fs/readlink.go",
		"/home/exedev/e1/goroot/src/io/fs/stat.go",
		"/home/exedev/e1/goroot/src/io/fs/sub.go",
		"/home/exedev/e1/goroot/src/io/fs/walk.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [],
	"Module": null,
	"ImportMap": {
		"errors": "errors",
		"internal/bytealg": "internal/bytealg",
		"internal/oserror": "internal/oserror",
		"io": "io",
		"path": "path",
		"slices": "slices",
		"time": "time",
		"unicode/utf8": "unicode/utf8"
	},
	"PackageFile": {
		"errors": "$WORK/b003/_pkg_.a",
		"internal/bytealg": "$WORK/b010/_pkg_.a",
		"internal/oserror": "$WORK/b037/_pkg_.a",
		"io": "$WORK/b038/_pkg_.a",
		"path": "$WORK/b043/_pkg_.a",
		"slices": "$WORK/b045/_pkg_.a",
		"time": "$WORK/b048/_pkg_.a",
		"unicode/utf8": "$WORK/b044/_pkg_.a"
	},
	"Standard": {
		"errors": true,
		"internal/bytealg": true,
		"internal/oserror": true,
		"io": true,
		"path": true,
		"slices": true,
		"time": true,
		"unicode/utf8": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b036/vet.out",
	"Stdout": "$WORK/b036/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/io/fs
cat >$WORK/b035/vet.cfg << 'EOF' # internal
{
	"ID": "internal/filepathlite",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/internal/filepathlite",
	"ImportPath": "internal/filepathlite",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/internal/filepathlite/path.go",
		"/home/exedev/e1/goroot/src/internal/filepathlite/path_nonwindows.go",
		"/home/exedev/e1/goroot/src/internal/filepathlite/path_unix.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [
		"/home/exedev/e1/goroot/src/internal/filepathlite/path_plan9.go",
		"/home/exedev/e1/goroot/src/internal/filepathlite/path_windows.go"
	],
	"Module": null,
	"ImportMap": {
		"errors": "errors",
		"internal/bytealg": "internal/bytealg",
		"internal/stringslite": "internal/stringslite",
		"io/fs": "io/fs",
		"slices": "slices"
	},
	"PackageFile": {
		"errors": "$WORK/b003/_pkg_.a",
		"internal/bytealg": "$WORK/b010/_pkg_.a",
		"internal/stringslite": "$WORK/b032/_pkg_.a",
		"io/fs": "$WORK/b036/_pkg_.a",
		"slices": "$WORK/b045/_pkg_.a"
	},
	"Standard": {
		"errors": true,
		"internal/bytealg": true,
		"internal/stringslite": true,
		"io/fs": true,
		"slices": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b035/vet.out",
	"Stdout": "$WORK/b035/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/internal/filepathlite
cat >$WORK/b051/vet.cfg << 'EOF' # internal
{
	"ID": "internal/syscall/unix",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/internal/syscall/unix",
	"ImportPath": "internal/syscall/unix",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/internal/syscall/unix/at_wasip1.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/constants.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/fcntl_wasip1.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/kernel_version_ge.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/kernel_version_other.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/net_wasip1.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/nofollow_posix.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/nonblocking_wasip1.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/syscall.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/utimes_wasip1.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [
		"/home/exedev/e1/goroot/src/internal/syscall/unix/arandom_netbsd.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/arc4random_darwin.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/arc4random_openbsd.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/at.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/at_aix.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/at_darwin.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/at_fstatat.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/at_fstatat2.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/at_js.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/at_libc.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/at_libc2.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/at_openbsd.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/at_solaris.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/at_sysnum_darwin.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/at_sysnum_dragonfly.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/at_sysnum_freebsd.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/at_sysnum_fstatat64_linux.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/at_sysnum_fstatat_linux.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/at_sysnum_linux.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/at_sysnum_netbsd.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/at_sysnum_newfstatat_linux.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/at_sysnum_openbsd.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/copy_file_range_unix.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/eaccess.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/faccessat_bsd.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/faccessat_darwin.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/faccessat_openbsd.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/faccessat_solaris.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/faccessat_syscall.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/fallocate_bsd_386.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/fallocate_bsd_64bit.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/fallocate_bsd_arm.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/fchmodat_linux.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/fchmodat_other.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/fcntl_js.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/fcntl_unix.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/getrandom.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/getrandom_dragonfly.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/getrandom_freebsd.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/getrandom_linux.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/getrandom_linux_test.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/getrandom_solaris.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/ioctl_aix.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/kernel_version_freebsd.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/kernel_version_freebsd_test.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/kernel_version_linux.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/kernel_version_solaris.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/kernel_version_solaris_test.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/net.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/net_darwin.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/net_js.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/nofollow_bsd.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/nofollow_netbsd.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/nonblocking_js.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/nonblocking_unix.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/pidfd_linux.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/pty_darwin.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/renameat2_sysnum_linux.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/renameat_sysnum_linux.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/siginfo_linux.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/siginfo_linux_mipsx.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/siginfo_linux_other.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/siginfo_linux_test.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/sysnum_freebsd.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/sysnum_linux_386.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/sysnum_linux_amd64.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/sysnum_linux_arm.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/sysnum_linux_generic.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/sysnum_linux_mips64x.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/sysnum_linux_mipsx.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/sysnum_linux_ppc64x.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/sysnum_linux_s390x.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/tcsetpgrp_bsd.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/tcsetpgrp_linux.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/user_darwin.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/utimes.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/waitid_linux.go",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/asm_aix_ppc64.s",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/asm_darwin.s",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/asm_openbsd.s",
		"/home/exedev/e1/goroot/src/internal/syscall/unix/asm_solaris.s"
	],
	"Module": null,
	"ImportMap": {
		"syscall": "syscall",
		"unsafe": "unsafe"
	},
	"PackageFile": {
		"syscall": "$WORK/b049/_pkg_.a"
	},
	"Standard": {
		"syscall": true,
		"unsafe": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b051/vet.out",
	"Stdout": "$WORK/b051/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/internal/syscall/unix
cat >$WORK/b050/vet.cfg << 'EOF' # internal
{
	"ID": "internal/poll",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/internal/poll",
	"ImportPath": "internal/poll",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/internal/poll/errno_unix.go",
		"/home/exedev/e1/goroot/src/internal/poll/fd.go",
		"/home/exedev/e1/goroot/src/internal/poll/fd_fsync_posix.go",
		"/home/exedev/e1/goroot/src/internal/poll/fd_mutex.go",
		"/home/exedev/e1/goroot/src/internal/poll/fd_poll_runtime.go",
		"/home/exedev/e1/goroot/src/internal/poll/fd_posix.go",
		"/home/exedev/e1/goroot/src/internal/poll/fd_unix.go",
		"/home/exedev/e1/goroot/src/internal/poll/fd_wasip1.go",
		"/home/exedev/e1/goroot/src/internal/poll/fstatat_unix.go",
		"/home/exedev/e1/goroot/src/internal/poll/hook_unix.go",
		"/home/exedev/e1/goroot/src/internal/poll/sendfile.go",
		"/home/exedev/e1/goroot/src/internal/poll/sys_cloexec.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [
		"/home/exedev/e1/goroot/src/internal/poll/copy_file_range_freebsd.go",
		"/home/exedev/e1/goroot/src/internal/poll/copy_file_range_linux.go",
		"/home/exedev/e1/goroot/src/internal/poll/copy_file_range_unix.go",
		"/home/exedev/e1/goroot/src/internal/poll/errno_windows.go",
		"/home/exedev/e1/goroot/src/internal/poll/error_linux_test.go",
		"/home/exedev/e1/goroot/src/internal/poll/export_linux_test.go",
		"/home/exedev/e1/goroot/src/internal/poll/export_posix_test.go",
		"/home/exedev/e1/goroot/src/internal/poll/export_windows_test.go",
		"/home/exedev/e1/goroot/src/internal/poll/fd_fsync_darwin.go",
		"/home/exedev/e1/goroot/src/internal/poll/fd_fsync_windows.go",
		"/home/exedev/e1/goroot/src/internal/poll/fd_io_plan9.go",
		"/home/exedev/e1/goroot/src/internal/poll/fd_opendir_darwin.go",
		"/home/exedev/e1/goroot/src/internal/poll/fd_plan9.go",
		"/home/exedev/e1/goroot/src/internal/poll/fd_poll_js.go",
		"/home/exedev/e1/goroot/src/internal/poll/fd_posix_test.go",
		"/home/exedev/e1/goroot/src/internal/poll/fd_unixjs.go",
		"/home/exedev/e1/goroot/src/internal/poll/fd_windows.go",
		"/home/exedev/e1/goroot/src/internal/poll/fd_windows_test.go",
		"/home/exedev/e1/goroot/src/internal/poll/fd_writev_libc.go",
		"/home/exedev/e1/goroot/src/internal/poll/fd_writev_unix.go",
		"/home/exedev/e1/goroot/src/internal/poll/file_plan9.go",
		"/home/exedev/e1/goroot/src/internal/poll/hook_cloexec.go",
		"/home/exedev/e1/goroot/src/internal/poll/hook_windows.go",
		"/home/exedev/e1/goroot/src/internal/poll/iovec_solaris.go",
		"/home/exedev/e1/goroot/src/internal/poll/iovec_unix.go",
		"/home/exedev/e1/goroot/src/internal/poll/sendfile_solaris.go",
		"/home/exedev/e1/goroot/src/internal/poll/sendfile_unix.go",
		"/home/exedev/e1/goroot/src/internal/poll/sendfile_windows.go",
		"/home/exedev/e1/goroot/src/internal/poll/sock_cloexec.go",
		"/home/exedev/e1/goroot/src/internal/poll/sock_cloexec_solaris.go",
		"/home/exedev/e1/goroot/src/internal/poll/sockopt.go",
		"/home/exedev/e1/goroot/src/internal/poll/sockopt_linux.go",
		"/home/exedev/e1/goroot/src/internal/poll/sockopt_unix.go",
		"/home/exedev/e1/goroot/src/internal/poll/sockopt_windows.go",
		"/home/exedev/e1/goroot/src/internal/poll/sockoptip.go",
		"/home/exedev/e1/goroot/src/internal/poll/splice_linux.go",
		"/home/exedev/e1/goroot/src/internal/poll/splice_linux_test.go",
		"/home/exedev/e1/goroot/src/internal/poll/writev.go"
	],
	"Module": null,
	"ImportMap": {
		"errors": "errors",
		"internal/byteorder": "internal/byteorder",
		"internal/strconv": "internal/strconv",
		"internal/syscall/unix": "internal/syscall/unix",
		"io": "io",
		"sync": "sync",
		"sync/atomic": "sync/atomic",
		"syscall": "syscall",
		"time": "time",
		"unsafe": "unsafe"
	},
	"PackageFile": {
		"errors": "$WORK/b003/_pkg_.a",
		"internal/byteorder": "$WORK/b012/_pkg_.a",
		"internal/strconv": "$WORK/b030/_pkg_.a",
		"internal/syscall/unix": "$WORK/b051/_pkg_.a",
		"io": "$WORK/b038/_pkg_.a",
		"sync": "$WORK/b039/_pkg_.a",
		"sync/atomic": "$WORK/b041/_pkg_.a",
		"syscall": "$WORK/b049/_pkg_.a",
		"time": "$WORK/b048/_pkg_.a"
	},
	"Standard": {
		"errors": true,
		"internal/byteorder": true,
		"internal/strconv": true,
		"internal/syscall/unix": true,
		"io": true,
		"sync": true,
		"sync/atomic": true,
		"syscall": true,
		"time": true,
		"unsafe": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b050/vet.out",
	"Stdout": "$WORK/b050/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/internal/poll
cat >$WORK/b052/vet.cfg << 'EOF' # internal
{
	"ID": "internal/syscall/execenv",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/internal/syscall/execenv",
	"ImportPath": "internal/syscall/execenv",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/internal/syscall/execenv/execenv_default.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [
		"/home/exedev/e1/goroot/src/internal/syscall/execenv/execenv_windows.go"
	],
	"Module": null,
	"ImportMap": {
		"syscall": "syscall"
	},
	"PackageFile": {
		"syscall": "$WORK/b049/_pkg_.a"
	},
	"Standard": {
		"syscall": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b052/vet.out",
	"Stdout": "$WORK/b052/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/internal/syscall/execenv
cat >$WORK/b053/vet.cfg << 'EOF' # internal
{
	"ID": "internal/testlog",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/internal/testlog",
	"ImportPath": "internal/testlog",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/internal/testlog/exit.go",
		"/home/exedev/e1/goroot/src/internal/testlog/log.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [],
	"Module": null,
	"ImportMap": {
		"sync": "sync",
		"sync/atomic": "sync/atomic",
		"unsafe": "unsafe"
	},
	"PackageFile": {
		"sync": "$WORK/b039/_pkg_.a",
		"sync/atomic": "$WORK/b041/_pkg_.a"
	},
	"Standard": {
		"sync": true,
		"sync/atomic": true,
		"unsafe": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b053/vet.out",
	"Stdout": "$WORK/b053/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/internal/testlog
cat >$WORK/b002/vet.cfg << 'EOF' # internal
{
	"ID": "os",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/os",
	"ImportPath": "os",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/os/dir.go",
		"/home/exedev/e1/goroot/src/os/dir_unix.go",
		"/home/exedev/e1/goroot/src/os/dirent_wasip1.go",
		"/home/exedev/e1/goroot/src/os/eloop_other.go",
		"/home/exedev/e1/goroot/src/os/env.go",
		"/home/exedev/e1/goroot/src/os/error.go",
		"/home/exedev/e1/goroot/src/os/error_errno.go",
		"/home/exedev/e1/goroot/src/os/exec.go",
		"/home/exedev/e1/goroot/src/os/exec_nohandle.go",
		"/home/exedev/e1/goroot/src/os/exec_posix.go",
		"/home/exedev/e1/goroot/src/os/exec_unix.go",
		"/home/exedev/e1/goroot/src/os/executable.go",
		"/home/exedev/e1/goroot/src/os/executable_wasm.go",
		"/home/exedev/e1/goroot/src/os/file.go",
		"/home/exedev/e1/goroot/src/os/file_open_wasip1.go",
		"/home/exedev/e1/goroot/src/os/file_posix.go",
		"/home/exedev/e1/goroot/src/os/file_unix.go",
		"/home/exedev/e1/goroot/src/os/file_wasip1.go",
		"/home/exedev/e1/goroot/src/os/getwd.go",
		"/home/exedev/e1/goroot/src/os/path.go",
		"/home/exedev/e1/goroot/src/os/path_unix.go",
		"/home/exedev/e1/goroot/src/os/pidfd_other.go",
		"/home/exedev/e1/goroot/src/os/pipe_wasm.go",
		"/home/exedev/e1/goroot/src/os/proc.go",
		"/home/exedev/e1/goroot/src/os/rawconn.go",
		"/home/exedev/e1/goroot/src/os/removeall_at.go",
		"/home/exedev/e1/goroot/src/os/removeall_unix.go",
		"/home/exedev/e1/goroot/src/os/root.go",
		"/home/exedev/e1/goroot/src/os/root_nonwindows.go",
		"/home/exedev/e1/goroot/src/os/root_openat.go",
		"/home/exedev/e1/goroot/src/os/root_unix.go",
		"/home/exedev/e1/goroot/src/os/stat.go",
		"/home/exedev/e1/goroot/src/os/stat_unix.go",
		"/home/exedev/e1/goroot/src/os/stat_wasip1.go",
		"/home/exedev/e1/goroot/src/os/statat.go",
		"/home/exedev/e1/goroot/src/os/statat_unix.go",
		"/home/exedev/e1/goroot/src/os/sticky_bsd.go",
		"/home/exedev/e1/goroot/src/os/sys.go",
		"/home/exedev/e1/goroot/src/os/sys_bsd.go",
		"/home/exedev/e1/goroot/src/os/sys_wasip1.go",
		"/home/exedev/e1/goroot/src/os/tempfile.go",
		"/home/exedev/e1/goroot/src/os/types.go",
		"/home/exedev/e1/goroot/src/os/types_unix.go",
		"/home/exedev/e1/goroot/src/os/wait_unimp.go",
		"/home/exedev/e1/goroot/src/os/zero_copy_posix.go",
		"/home/exedev/e1/goroot/src/os/zero_copy_stub.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [
		"/home/exedev/e1/goroot/src/os/dir_darwin.go",
		"/home/exedev/e1/goroot/src/os/dir_plan9.go",
		"/home/exedev/e1/goroot/src/os/dir_windows.go",
		"/home/exedev/e1/goroot/src/os/dirent_aix.go",
		"/home/exedev/e1/goroot/src/os/dirent_dragonfly.go",
		"/home/exedev/e1/goroot/src/os/dirent_freebsd.go",
		"/home/exedev/e1/goroot/src/os/dirent_js.go",
		"/home/exedev/e1/goroot/src/os/dirent_linux.go",
		"/home/exedev/e1/goroot/src/os/dirent_netbsd.go",
		"/home/exedev/e1/goroot/src/os/dirent_openbsd.go",
		"/home/exedev/e1/goroot/src/os/dirent_solaris.go",
		"/home/exedev/e1/goroot/src/os/eloop_netbsd.go",
		"/home/exedev/e1/goroot/src/os/env_unix_test.go",
		"/home/exedev/e1/goroot/src/os/error_plan9.go",
		"/home/exedev/e1/goroot/src/os/error_windows_test.go",
		"/home/exedev/e1/goroot/src/os/example_windows_test.go",
		"/home/exedev/e1/goroot/src/os/exec_linux.go",
		"/home/exedev/e1/goroot/src/os/exec_plan9.go",
		"/home/exedev/e1/goroot/src/os/exec_unix_test.go",
		"/home/exedev/e1/goroot/src/os/exec_windows.go",
		"/home/exedev/e1/goroot/src/os/exec_windows_test.go",
		"/home/exedev/e1/goroot/src/os/executable_darwin.go",
		"/home/exedev/e1/goroot/src/os/executable_dragonfly.go",
		"/home/exedev/e1/goroot/src/os/executable_freebsd.go",
		"/home/exedev/e1/goroot/src/os/executable_netbsd.go",
		"/home/exedev/e1/goroot/src/os/executable_path.go",
		"/home/exedev/e1/goroot/src/os/executable_plan9.go",
		"/home/exedev/e1/goroot/src/os/executable_procfs.go",
		"/home/exedev/e1/goroot/src/os/executable_solaris.go",
		"/home/exedev/e1/goroot/src/os/executable_sysctl.go",
		"/home/exedev/e1/goroot/src/os/executable_windows.go",
		"/home/exedev/e1/goroot/src/os/export_freebsd_test.go",
		"/home/exedev/e1/goroot/src/os/export_linux_test.go",
		"/home/exedev/e1/goroot/src/os/export_windows_test.go",
		"/home/exedev/e1/goroot/src/os/fifo_test.go",
		"/home/exedev/e1/goroot/src/os/file_mutex_plan9.go",
		"/home/exedev/e1/goroot/src/os/file_open_unix.go",
		"/home/exedev/e1/goroot/src/os/file_plan9.go",
		"/home/exedev/e1/goroot/src/os/file_windows.go",
		"/home/exedev/e1/goroot/src/os/getwd_unix_test.go",
		"/home/exedev/e1/goroot/src/os/os_windows_test.go",
		"/home/exedev/e1/goroot/src/os/path_plan9.go",
		"/home/exedev/e1/goroot/src/os/path_windows.go",
		"/home/exedev/e1/goroot/src/os/path_windows_test.go",
		"/home/exedev/e1/goroot/src/os/pidfd_linux.go",
		"/home/exedev/e1/goroot/src/os/pidfd_linux_test.go",
		"/home/exedev/e1/goroot/src/os/pipe2_unix.go",
		"/home/exedev/e1/goroot/src/os/pipe_test.go",
		"/home/exedev/e1/goroot/src/os/pipe_unix.go",
		"/home/exedev/e1/goroot/src/os/rawconn_test.go",
		"/home/exedev/e1/goroot/src/os/readfrom_freebsd_test.go",
		"/home/exedev/e1/goroot/src/os/readfrom_linux_test.go",
		"/home/exedev/e1/goroot/src/os/readfrom_sendfile_test.go",
		"/home/exedev/e1/goroot/src/os/readfrom_solaris_test.go",
		"/home/exedev/e1/goroot/src/os/readfrom_unix_test.go",
		"/home/exedev/e1/goroot/src/os/removeall_noat.go",
		"/home/exedev/e1/goroot/src/os/removeall_windows.go",
		"/home/exedev/e1/goroot/src/os/root_js.go",
		"/home/exedev/e1/goroot/src/os/root_noopenat.go",
		"/home/exedev/e1/goroot/src/os/root_plan9.go",
		"/home/exedev/e1/goroot/src/os/root_windows.go",
		"/home/exedev/e1/goroot/src/os/root_windows_test.go",
		"/home/exedev/e1/goroot/src/os/stat_aix.go",
		"/home/exedev/e1/goroot/src/os/stat_darwin.go",
		"/home/exedev/e1/goroot/src/os/stat_dragonfly.go",
		"/home/exedev/e1/goroot/src/os/stat_freebsd.go",
		"/home/exedev/e1/goroot/src/os/stat_js.go",
		"/home/exedev/e1/goroot/src/os/stat_linux.go",
		"/home/exedev/e1/goroot/src/os/stat_netbsd.go",
		"/home/exedev/e1/goroot/src/os/stat_openbsd.go",
		"/home/exedev/e1/goroot/src/os/stat_plan9.go",
		"/home/exedev/e1/goroot/src/os/stat_solaris.go",
		"/home/exedev/e1/goroot/src/os/stat_windows.go",
		"/home/exedev/e1/goroot/src/os/statat_other.go",
		"/home/exedev/e1/goroot/src/os/sticky_notbsd.go",
		"/home/exedev/e1/goroot/src/os/sys_aix.go",
		"/home/exedev/e1/goroot/src/os/sys_js.go",
		"/home/exedev/e1/goroot/src/os/sys_linux.go",
		"/home/exedev/e1/goroot/src/os/sys_plan9.go",
		"/home/exedev/e1/goroot/src/os/sys_solaris.go",
		"/home/exedev/e1/goroot/src/os/sys_unix.go",
		"/home/exedev/e1/goroot/src/os/sys_windows.go",
		"/home/exedev/e1/goroot/src/os/timeout_test.go",
		"/home/exedev/e1/goroot/src/os/timeout_unix_test.go",
		"/home/exedev/e1/goroot/src/os/timeout_windows_test.go",
		"/home/exedev/e1/goroot/src/os/types_plan9.go",
		"/home/exedev/e1/goroot/src/os/types_windows.go",
		"/home/exedev/e1/goroot/src/os/wait6_dragonfly.go",
		"/home/exedev/e1/goroot/src/os/wait6_freebsd64.go",
		"/home/exedev/e1/goroot/src/os/wait6_freebsd_386.go",
		"/home/exedev/e1/goroot/src/os/wait6_freebsd_arm.go",
		"/home/exedev/e1/goroot/src/os/wait6_netbsd.go",
		"/home/exedev/e1/goroot/src/os/wait_wait6.go",
		"/home/exedev/e1/goroot/src/os/wait_waitid.go",
		"/home/exedev/e1/goroot/src/os/writeto_linux_test.go",
		"/home/exedev/e1/goroot/src/os/zero_copy_freebsd.go",
		"/home/exedev/e1/goroot/src/os/zero_copy_linux.go",
		"/home/exedev/e1/goroot/src/os/zero_copy_solaris.go"
	],
	"Module": null,
	"ImportMap": {
		"errors": "errors",
		"internal/bytealg": "internal/bytealg",
		"internal/byteorder": "internal/byteorder",
		"internal/filepathlite": "internal/filepathlite",
		"internal/goarch": "internal/goarch",
		"internal/poll": "internal/poll",
		"internal/strconv": "internal/strconv",
		"internal/stringslite": "internal/stringslite",
		"internal/syscall/execenv": "internal/syscall/execenv",
		"internal/syscall/unix": "internal/syscall/unix",
		"internal/testlog": "internal/testlog",
		"io": "io",
		"io/fs": "io/fs",
		"runtime": "runtime",
		"slices": "slices",
		"sync": "sync",
		"sync/atomic": "sync/atomic",
		"syscall": "syscall",
		"time": "time",
		"unsafe": "unsafe"
	},
	"PackageFile": {
		"errors": "$WORK/b003/_pkg_.a",
		"internal/bytealg": "$WORK/b010/_pkg_.a",
		"internal/byteorder": "$WORK/b012/_pkg_.a",
		"internal/filepathlite": "$WORK/b035/_pkg_.a",
		"internal/goarch": "$WORK/b006/_pkg_.a",
		"internal/poll": "$WORK/b050/_pkg_.a",
		"internal/strconv": "$WORK/b030/_pkg_.a",
		"internal/stringslite": "$WORK/b032/_pkg_.a",
		"internal/syscall/execenv": "$WORK/b052/_pkg_.a",
		"internal/syscall/unix": "$WORK/b051/_pkg_.a",
		"internal/testlog": "$WORK/b053/_pkg_.a",
		"io": "$WORK/b038/_pkg_.a",
		"io/fs": "$WORK/b036/_pkg_.a",
		"runtime": "$WORK/b009/_pkg_.a",
		"slices": "$WORK/b045/_pkg_.a",
		"sync": "$WORK/b039/_pkg_.a",
		"sync/atomic": "$WORK/b041/_pkg_.a",
		"syscall": "$WORK/b049/_pkg_.a",
		"time": "$WORK/b048/_pkg_.a"
	},
	"Standard": {
		"errors": true,
		"internal/bytealg": true,
		"internal/byteorder": true,
		"internal/filepathlite": true,
		"internal/goarch": true,
		"internal/poll": true,
		"internal/strconv": true,
		"internal/stringslite": true,
		"internal/syscall/execenv": true,
		"internal/syscall/unix": true,
		"internal/testlog": true,
		"io": true,
		"io/fs": true,
		"runtime": true,
		"slices": true,
		"sync": true,
		"sync/atomic": true,
		"syscall": true,
		"time": true,
		"unsafe": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b002/vet.out",
	"Stdout": "$WORK/b002/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/os
cat >$WORK/b063/vet.cfg << 'EOF' # internal
{
	"ID": "fmt",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/fmt",
	"ImportPath": "fmt",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/fmt/doc.go",
		"/home/exedev/e1/goroot/src/fmt/errors.go",
		"/home/exedev/e1/goroot/src/fmt/format.go",
		"/home/exedev/e1/goroot/src/fmt/print.go",
		"/home/exedev/e1/goroot/src/fmt/scan.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [],
	"Module": null,
	"ImportMap": {
		"errors": "errors",
		"internal/fmtsort": "internal/fmtsort",
		"internal/stringslite": "internal/stringslite",
		"io": "io",
		"math": "math",
		"os": "os",
		"reflect": "reflect",
		"slices": "slices",
		"strconv": "strconv",
		"sync": "sync",
		"unicode/utf8": "unicode/utf8"
	},
	"PackageFile": {
		"errors": "$WORK/b003/_pkg_.a",
		"internal/fmtsort": "$WORK/b064/_pkg_.a",
		"internal/stringslite": "$WORK/b032/_pkg_.a",
		"io": "$WORK/b038/_pkg_.a",
		"math": "$WORK/b055/_pkg_.a",
		"os": "$WORK/b002/_pkg_.a",
		"reflect": "$WORK/b054/_pkg_.a",
		"slices": "$WORK/b045/_pkg_.a",
		"strconv": "$WORK/b056/_pkg_.a",
		"sync": "$WORK/b039/_pkg_.a",
		"unicode/utf8": "$WORK/b044/_pkg_.a"
	},
	"Standard": {
		"errors": true,
		"internal/fmtsort": true,
		"internal/stringslite": true,
		"io": true,
		"math": true,
		"os": true,
		"reflect": true,
		"slices": true,
		"strconv": true,
		"sync": true,
		"unicode/utf8": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b063/vet.out",
	"Stdout": "$WORK/b063/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/fmt
cat >$WORK/b065/vet.cfg << 'EOF' # internal
{
	"ID": "strings",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/strings",
	"ImportPath": "strings",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/strings/builder.go",
		"/home/exedev/e1/goroot/src/strings/clone.go",
		"/home/exedev/e1/goroot/src/strings/compare.go",
		"/home/exedev/e1/goroot/src/strings/iter.go",
		"/home/exedev/e1/goroot/src/strings/reader.go",
		"/home/exedev/e1/goroot/src/strings/replace.go",
		"/home/exedev/e1/goroot/src/strings/search.go",
		"/home/exedev/e1/goroot/src/strings/strings.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [],
	"Module": null,
	"ImportMap": {
		"errors": "errors",
		"internal/abi": "internal/abi",
		"internal/bytealg": "internal/bytealg",
		"internal/stringslite": "internal/stringslite",
		"io": "io",
		"iter": "iter",
		"math/bits": "math/bits",
		"sync": "sync",
		"unicode": "unicode",
		"unicode/utf8": "unicode/utf8",
		"unsafe": "unsafe"
	},
	"PackageFile": {
		"errors": "$WORK/b003/_pkg_.a",
		"internal/abi": "$WORK/b005/_pkg_.a",
		"internal/bytealg": "$WORK/b010/_pkg_.a",
		"internal/stringslite": "$WORK/b032/_pkg_.a",
		"io": "$WORK/b038/_pkg_.a",
		"iter": "$WORK/b047/_pkg_.a",
		"math/bits": "$WORK/b031/_pkg_.a",
		"sync": "$WORK/b039/_pkg_.a",
		"unicode": "$WORK/b057/_pkg_.a",
		"unicode/utf8": "$WORK/b044/_pkg_.a"
	},
	"Standard": {
		"errors": true,
		"internal/abi": true,
		"internal/bytealg": true,
		"internal/stringslite": true,
		"io": true,
		"iter": true,
		"math/bits": true,
		"sync": true,
		"unicode": true,
		"unicode/utf8": true,
		"unsafe": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b065/vet.out",
	"Stdout": "$WORK/b065/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/strings
cat >$WORK/b061/vet.cfg << 'EOF' # internal
{
	"ID": "flag",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/flag",
	"ImportPath": "flag",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/flag/flag.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [],
	"Module": null,
	"ImportMap": {
		"encoding": "encoding",
		"errors": "errors",
		"fmt": "fmt",
		"io": "io",
		"os": "os",
		"reflect": "reflect",
		"runtime": "runtime",
		"slices": "slices",
		"strconv": "strconv",
		"strings": "strings",
		"time": "time"
	},
	"PackageFile": {
		"encoding": "$WORK/b062/_pkg_.a",
		"errors": "$WORK/b003/_pkg_.a",
		"fmt": "$WORK/b063/_pkg_.a",
		"io": "$WORK/b038/_pkg_.a",
		"os": "$WORK/b002/_pkg_.a",
		"reflect": "$WORK/b054/_pkg_.a",
		"runtime": "$WORK/b009/_pkg_.a",
		"slices": "$WORK/b045/_pkg_.a",
		"strconv": "$WORK/b056/_pkg_.a",
		"strings": "$WORK/b065/_pkg_.a",
		"time": "$WORK/b048/_pkg_.a"
	},
	"Standard": {
		"encoding": true,
		"errors": true,
		"fmt": true,
		"io": true,
		"os": true,
		"reflect": true,
		"runtime": true,
		"slices": true,
		"strconv": true,
		"strings": true,
		"time": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b061/vet.out",
	"Stdout": "$WORK/b061/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/flag
cat >$WORK/b066/vet.cfg << 'EOF' # internal
{
	"ID": "internal/sysinfo",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/internal/sysinfo",
	"ImportPath": "internal/sysinfo",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/internal/sysinfo/cpuinfo_stub.go",
		"/home/exedev/e1/goroot/src/internal/sysinfo/sysinfo.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [
		"/home/exedev/e1/goroot/src/internal/sysinfo/cpuinfo_bsd.go",
		"/home/exedev/e1/goroot/src/internal/sysinfo/cpuinfo_linux.go"
	],
	"Module": null,
	"ImportMap": {
		"internal/cpu": "internal/cpu",
		"sync": "sync"
	},
	"PackageFile": {
		"internal/cpu": "$WORK/b011/_pkg_.a",
		"sync": "$WORK/b039/_pkg_.a"
	},
	"Standard": {
		"internal/cpu": true,
		"sync": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b066/vet.out",
	"Stdout": "$WORK/b066/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/internal/sysinfo
cat >$WORK/b069/vet.cfg << 'EOF' # internal
{
	"ID": "internal/bisect",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/internal/bisect",
	"ImportPath": "internal/bisect",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/internal/bisect/bisect.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [],
	"Module": null,
	"ImportMap": {
		"runtime": "runtime",
		"sync": "sync",
		"sync/atomic": "sync/atomic"
	},
	"PackageFile": {
		"runtime": "$WORK/b009/_pkg_.a",
		"sync": "$WORK/b039/_pkg_.a",
		"sync/atomic": "$WORK/b041/_pkg_.a"
	},
	"Standard": {
		"runtime": true,
		"sync": true,
		"sync/atomic": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b069/vet.out",
	"Stdout": "$WORK/b069/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/internal/bisect
cat >$WORK/b068/vet.cfg << 'EOF' # internal
{
	"ID": "internal/godebug",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/internal/godebug",
	"ImportPath": "internal/godebug",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/internal/godebug/godebug.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [],
	"Module": null,
	"ImportMap": {
		"internal/bisect": "internal/bisect",
		"internal/godebugs": "internal/godebugs",
		"sync": "sync",
		"sync/atomic": "sync/atomic",
		"unsafe": "unsafe"
	},
	"PackageFile": {
		"internal/bisect": "$WORK/b069/_pkg_.a",
		"internal/godebugs": "$WORK/b015/_pkg_.a",
		"sync": "$WORK/b039/_pkg_.a",
		"sync/atomic": "$WORK/b041/_pkg_.a"
	},
	"Standard": {
		"internal/bisect": true,
		"internal/godebugs": true,
		"sync": true,
		"sync/atomic": true,
		"unsafe": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b068/vet.out",
	"Stdout": "$WORK/b068/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/internal/godebug
cat >$WORK/b067/vet.cfg << 'EOF' # internal
{
	"ID": "math/rand",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/math/rand",
	"ImportPath": "math/rand",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/math/rand/exp.go",
		"/home/exedev/e1/goroot/src/math/rand/normal.go",
		"/home/exedev/e1/goroot/src/math/rand/rand.go",
		"/home/exedev/e1/goroot/src/math/rand/rng.go",
		"/home/exedev/e1/goroot/src/math/rand/zipf.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [
		"/home/exedev/e1/goroot/src/math/rand/gen_cooked.go"
	],
	"Module": null,
	"ImportMap": {
		"internal/godebug": "internal/godebug",
		"math": "math",
		"sync": "sync",
		"sync/atomic": "sync/atomic",
		"unsafe": "unsafe"
	},
	"PackageFile": {
		"internal/godebug": "$WORK/b068/_pkg_.a",
		"math": "$WORK/b055/_pkg_.a",
		"sync": "$WORK/b039/_pkg_.a",
		"sync/atomic": "$WORK/b041/_pkg_.a"
	},
	"Standard": {
		"internal/godebug": true,
		"math": true,
		"sync": true,
		"sync/atomic": true,
		"unsafe": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b067/vet.out",
	"Stdout": "$WORK/b067/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/math/rand
cat >$WORK/b070/vet.cfg << 'EOF' # internal
{
	"ID": "path/filepath",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/path/filepath",
	"ImportPath": "path/filepath",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/path/filepath/match.go",
		"/home/exedev/e1/goroot/src/path/filepath/path.go",
		"/home/exedev/e1/goroot/src/path/filepath/path_unix.go",
		"/home/exedev/e1/goroot/src/path/filepath/symlink.go",
		"/home/exedev/e1/goroot/src/path/filepath/symlink_unix.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [
		"/home/exedev/e1/goroot/src/path/filepath/export_windows_test.go",
		"/home/exedev/e1/goroot/src/path/filepath/path_plan9.go",
		"/home/exedev/e1/goroot/src/path/filepath/path_windows.go",
		"/home/exedev/e1/goroot/src/path/filepath/path_windows_test.go",
		"/home/exedev/e1/goroot/src/path/filepath/symlink_plan9.go",
		"/home/exedev/e1/goroot/src/path/filepath/symlink_windows.go"
	],
	"Module": null,
	"ImportMap": {
		"errors": "errors",
		"internal/bytealg": "internal/bytealg",
		"internal/filepathlite": "internal/filepathlite",
		"io/fs": "io/fs",
		"os": "os",
		"runtime": "runtime",
		"slices": "slices",
		"strings": "strings",
		"syscall": "syscall",
		"unicode/utf8": "unicode/utf8"
	},
	"PackageFile": {
		"errors": "$WORK/b003/_pkg_.a",
		"internal/bytealg": "$WORK/b010/_pkg_.a",
		"internal/filepathlite": "$WORK/b035/_pkg_.a",
		"io/fs": "$WORK/b036/_pkg_.a",
		"os": "$WORK/b002/_pkg_.a",
		"runtime": "$WORK/b009/_pkg_.a",
		"slices": "$WORK/b045/_pkg_.a",
		"strings": "$WORK/b065/_pkg_.a",
		"syscall": "$WORK/b049/_pkg_.a",
		"unicode/utf8": "$WORK/b044/_pkg_.a"
	},
	"Standard": {
		"errors": true,
		"internal/bytealg": true,
		"internal/filepathlite": true,
		"io/fs": true,
		"os": true,
		"runtime": true,
		"slices": true,
		"strings": true,
		"syscall": true,
		"unicode/utf8": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b070/vet.out",
	"Stdout": "$WORK/b070/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/path/filepath
cat >$WORK/b071/vet.cfg << 'EOF' # internal
{
	"ID": "runtime/debug",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/runtime/debug",
	"ImportPath": "runtime/debug",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/runtime/debug/garbage.go",
		"/home/exedev/e1/goroot/src/runtime/debug/mod.go",
		"/home/exedev/e1/goroot/src/runtime/debug/stack.go",
		"/home/exedev/e1/goroot/src/runtime/debug/stubs.go"
	],
	"NonGoFiles": [
		"/home/exedev/e1/goroot/src/runtime/debug/debug.s"
	],
	"IgnoredFiles": [
		"/home/exedev/e1/goroot/src/runtime/debug/panic_test.go"
	],
	"Module": null,
	"ImportMap": {
		"fmt": "fmt",
		"internal/poll": "internal/poll",
		"os": "os",
		"runtime": "runtime",
		"slices": "slices",
		"strconv": "strconv",
		"strings": "strings",
		"time": "time",
		"unsafe": "unsafe"
	},
	"PackageFile": {
		"fmt": "$WORK/b063/_pkg_.a",
		"internal/poll": "$WORK/b050/_pkg_.a",
		"os": "$WORK/b002/_pkg_.a",
		"runtime": "$WORK/b009/_pkg_.a",
		"slices": "$WORK/b045/_pkg_.a",
		"strconv": "$WORK/b056/_pkg_.a",
		"strings": "$WORK/b065/_pkg_.a",
		"time": "$WORK/b048/_pkg_.a"
	},
	"Standard": {
		"fmt": true,
		"internal/poll": true,
		"os": true,
		"runtime": true,
		"slices": true,
		"strconv": true,
		"strings": true,
		"time": true,
		"unsafe": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b071/vet.out",
	"Stdout": "$WORK/b071/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/runtime/debug
cat >$WORK/b072/vet.cfg << 'EOF' # internal
{
	"ID": "runtime/trace",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/runtime/trace",
	"ImportPath": "runtime/trace",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/runtime/trace/annotation.go",
		"/home/exedev/e1/goroot/src/runtime/trace/batch.go",
		"/home/exedev/e1/goroot/src/runtime/trace/encoding.go",
		"/home/exedev/e1/goroot/src/runtime/trace/flightrecorder.go",
		"/home/exedev/e1/goroot/src/runtime/trace/recorder.go",
		"/home/exedev/e1/goroot/src/runtime/trace/subscribe.go",
		"/home/exedev/e1/goroot/src/runtime/trace/trace.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [],
	"Module": null,
	"ImportMap": {
		"context": "context",
		"errors": "errors",
		"fmt": "fmt",
		"internal/trace/tracev2": "internal/trace/tracev2",
		"io": "io",
		"runtime": "runtime",
		"slices": "slices",
		"sync": "sync",
		"sync/atomic": "sync/atomic",
		"time": "time",
		"unsafe": "unsafe"
	},
	"PackageFile": {
		"context": "$WORK/b060/_pkg_.a",
		"errors": "$WORK/b003/_pkg_.a",
		"fmt": "$WORK/b063/_pkg_.a",
		"internal/trace/tracev2": "$WORK/b033/_pkg_.a",
		"io": "$WORK/b038/_pkg_.a",
		"runtime": "$WORK/b009/_pkg_.a",
		"slices": "$WORK/b045/_pkg_.a",
		"sync": "$WORK/b039/_pkg_.a",
		"sync/atomic": "$WORK/b041/_pkg_.a",
		"time": "$WORK/b048/_pkg_.a"
	},
	"Standard": {
		"context": true,
		"errors": true,
		"fmt": true,
		"internal/trace/tracev2": true,
		"io": true,
		"runtime": true,
		"slices": true,
		"sync": true,
		"sync/atomic": true,
		"time": true,
		"unsafe": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b072/vet.out",
	"Stdout": "$WORK/b072/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/runtime/trace
cat >$WORK/b058/vet.cfg << 'EOF' # internal
{
	"ID": "testing",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/goroot/src/testing",
	"ImportPath": "testing",
	"GoFiles": [
		"/home/exedev/e1/goroot/src/testing/allocs.go",
		"/home/exedev/e1/goroot/src/testing/benchmark.go",
		"/home/exedev/e1/goroot/src/testing/cover.go",
		"/home/exedev/e1/goroot/src/testing/example.go",
		"/home/exedev/e1/goroot/src/testing/fuzz.go",
		"/home/exedev/e1/goroot/src/testing/match.go",
		"/home/exedev/e1/goroot/src/testing/newcover.go",
		"/home/exedev/e1/goroot/src/testing/run_example_wasm.go",
		"/home/exedev/e1/goroot/src/testing/testing.go",
		"/home/exedev/e1/goroot/src/testing/testing_other.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [
		"/home/exedev/e1/goroot/src/testing/run_example.go",
		"/home/exedev/e1/goroot/src/testing/testing_windows.go",
		"/home/exedev/e1/goroot/src/testing/testing_windows_test.go"
	],
	"Module": null,
	"ImportMap": {
		"bytes": "bytes",
		"context": "context",
		"errors": "errors",
		"flag": "flag",
		"fmt": "fmt",
		"internal/race": "internal/race",
		"internal/sysinfo": "internal/sysinfo",
		"io": "io",
		"math": "math",
		"math/rand": "math/rand",
		"os": "os",
		"path/filepath": "path/filepath",
		"reflect": "reflect",
		"runtime": "runtime",
		"runtime/debug": "runtime/debug",
		"runtime/trace": "runtime/trace",
		"slices": "slices",
		"strconv": "strconv",
		"strings": "strings",
		"sync": "sync",
		"sync/atomic": "sync/atomic",
		"time": "time",
		"unicode": "unicode",
		"unsafe": "unsafe"
	},
	"PackageFile": {
		"bytes": "$WORK/b059/_pkg_.a",
		"context": "$WORK/b060/_pkg_.a",
		"errors": "$WORK/b003/_pkg_.a",
		"flag": "$WORK/b061/_pkg_.a",
		"fmt": "$WORK/b063/_pkg_.a",
		"internal/race": "$WORK/b027/_pkg_.a",
		"internal/sysinfo": "$WORK/b066/_pkg_.a",
		"io": "$WORK/b038/_pkg_.a",
		"math": "$WORK/b055/_pkg_.a",
		"math/rand": "$WORK/b067/_pkg_.a",
		"os": "$WORK/b002/_pkg_.a",
		"path/filepath": "$WORK/b070/_pkg_.a",
		"reflect": "$WORK/b054/_pkg_.a",
		"runtime": "$WORK/b009/_pkg_.a",
		"runtime/debug": "$WORK/b071/_pkg_.a",
		"runtime/trace": "$WORK/b072/_pkg_.a",
		"slices": "$WORK/b045/_pkg_.a",
		"strconv": "$WORK/b056/_pkg_.a",
		"strings": "$WORK/b065/_pkg_.a",
		"sync": "$WORK/b039/_pkg_.a",
		"sync/atomic": "$WORK/b041/_pkg_.a",
		"time": "$WORK/b048/_pkg_.a",
		"unicode": "$WORK/b057/_pkg_.a"
	},
	"Standard": {
		"bytes": true,
		"context": true,
		"errors": true,
		"flag": true,
		"fmt": true,
		"internal/race": true,
		"internal/sysinfo": true,
		"io": true,
		"math": true,
		"math/rand": true,
		"os": true,
		"path/filepath": true,
		"reflect": true,
		"runtime": true,
		"runtime/debug": true,
		"runtime/trace": true,
		"slices": true,
		"strconv": true,
		"strings": true,
		"sync": true,
		"sync/atomic": true,
		"time": true,
		"unicode": true,
		"unsafe": true
	},
	"PackageVetx": {},
	"VetxOnly": true,
	"VetxOutput": "$WORK/b058/vet.out",
	"Stdout": "$WORK/b058/vet.stdout",
	"GoVersion": "go1.27.2",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/goroot/src/testing
cat >$WORK/b128/vet.cfg << 'EOF' # internal
{
	"ID": "tdemo",
	"Compiler": "gc",
	"Dir": "/home/exedev/e1/tdemo",
	"ImportPath": "tdemo",
	"GoFiles": [
		"/home/exedev/e1/tdemo/add.go",
		"/home/exedev/e1/tdemo/add_test.go"
	],
	"NonGoFiles": [],
	"IgnoredFiles": [],
	"Module": {
		"Path": "tdemo",
		"Version": "",
		"Replace": null,
		"Time": null,
		"Main": true,
		"Indirect": false,
		"Dir": "/home/exedev/e1/tdemo",
		"GoMod": "/home/exedev/e1/tdemo/go.mod",
		"GoVersion": "1.27",
		"Error": null
	},
	"ImportMap": {
		"testing": "testing"
	},
	"PackageFile": {
		"testing": "$WORK/b058/_pkg_.a"
	},
	"Standard": {
		"testing": true
	},
	"PackageVetx": {},
	"VetxOnly": false,
	"VetxOutput": "$WORK/b128/vet.out",
	"Stdout": "$WORK/b128/vet.stdout",
	"GoVersion": "go1.27",
	"FixArchive": "",
	"SucceedOnTypecheckFailure": false
}
EOF
cd /home/exedev/e1/tdemo
mkdir -p /home/exedev/e1/tdemo/
mv $WORK/b001/tdemo.test /home/exedev/e1/tdemo/tdemo.test.wasm
rm -rf $WORK/b001/
