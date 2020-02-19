#!/bin/bash

SCRIPT_DIR=`dirname $BASH_SOURCE{0}`
SCRIPT_HOME=`readlink -f $SCRIPT_DIR`

LIBC_DIR="$SCRIPT_HOME/sources/kora-libc"
KERN_DIR="$SCRIPT_HOME/sources/kora-kernel"
TOOL_DIR='/home/fabien/kora-tools-i386/usr/'


rm -rf "$TOOL_DIR/include"
# mkdir -p "$TOOL_DIR"


echo "-- Install Libc headers"
cp -vr "$LIBC_DIR/include" "$TOOL_DIR/"

# echo "Install Libc headers for i386"
# cp -vr "$LIBC_DIR/arch/i386/*" "$TOOL_HEADERS/"

echo "-- Install Kernel headers"
cp -vr "$KERN_DIR/include/kernel" "$TOOL_DIR/include"

echo "-- Install Kernel-arch headers"
cp -vr "$KERN_DIR/arch/i386/include/kernel/arch.h" "$TOOL_DIR/include/kernel"
cp -vr "$KERN_DIR/arch/i386/include/kernel/cpu.h" "$TOOL_DIR/include/kernel"
cp -vr "$KERN_DIR/arch/i386/include/kernel/mmu.h" "$TOOL_DIR/include/kernel"

