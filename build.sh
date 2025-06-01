#!/usr/bin/bash

mv ../build_kernel.sh .

echo "[*] Install dependencies"
sudo apt-get update
sudo apt update
sudo apt upgrade -y
sudo apt install -y --fix-missing \
    build-essential \
    ccache \
    python3 \

pip install \
    bsdiff4 \
    rich

echo "[*] Download qcom LLVM toolchain"
gh release download -R RinOfficial0615/Melt-stuff -p LLVM.7z
mkdir LLVM
7z x LLVM.7z -o./LLVM/

echo "[*] Download AOSP clang r416183b"
git clone https://github.com/LineageOS/android_prebuilts_clang_kernel_linux-x86_clang-r416183b.git clang-r416183b

echo "[*] Clone Melt repositories"
git clone https://github.com/Pzqqt/AnyKernel3.git -b Marble-Melt out
git clone https://github.com/Pzqqt/android_kernel_xiaomi_marble.git

ls -A

cd android_kernel_xiaomi_marble
echo "[!] Build kernel image"
bash build_kernel.sh Image
echo "[!] Build kernel image with ksu"
bash build_kernel.sh --ksu Image
echo "[!] Build kernel modules"
bash build_kernel.sh
cd ..

echo "[!] Package kernel to flashable zip"
cd out
python3 make_package.py
