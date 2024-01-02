#!/bin/sh
source $stdenv/setup


# In case we are running "nix develop --command ./builder.sh", we
# can reuse the old source dir.
if [ ! -d libopencm3 ]; then
   # Needs to build in-place, so copy it from the readonly store.
   cp -a $libopencm3 libopencm3
   chmod -R a+rwX libopencm3
   # Change all #!/usr/bin/... to direct /nix/store paths
   for script in libopencm3/scripts/*; do
       if [ -f $script ]; then
           patchShebangs $script
       fi
   done
fi
cd libopencm3

# The subst expression that is supposed to quote spaces in SRCLIBDIR
# produces a stray backshlash at the end.  Patch was generated like this:
#   diff -Naur $libopencm3/Makefile libopencm3/Makefile >fix_SRCLIBDIR.patch
patch -p1 <$src/fix_SRCLIBDIR.patch
make PREFIX=arm-none-eabi- TARGETS=stm32/f1 V=1

# Copy only what uc_tools code needs.
mkdir -p $out/lib/dispatch ;
mkdir -p $out/lib/stm32/f1 ;
cp -a include $out/ ;
cp -a lib/libopencm3_stm32f1.a $out/lib/ ;
cp -a lib/dispatch/vector_chipset.c $out/lib/dispatch/ ;
cp -a lib/dispatch/vector_nvic.c    $out/lib/dispatch/ ;
cp -a lib/stm32/f1/vector_nvic.c    $out/lib/stm32/f1/ ;

