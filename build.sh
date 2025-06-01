#!/usr/bin/bash

RELEASE_VERSION=${LOCALVERSION}

info() {
    echo -e "[\033[32mINFO\033[0m] $1"
}

error() {
    echo -e "[\033[31mERROR\033[0m] $1"
}

info "*Install dependencies"
sudo apt-get update
sudo apt update
sudo apt install -y --fix-missing \
    build-essential \
    ccache \
    python3 \

pip install \
    bsdiff4 \
    rich \
    lxml

info "*Download qcom LLVM toolchain"
gh release download Compilers -R RinOfficial0615/Melt-stuff -p LLVM.7z
if [ $? -ne 0 ]; then
    error "Failed to download qcom LLVM toolchain!"
    exit 1
fi
mkdir LLVM
7z x LLVM.7z -o./LLVM/

info "*Download AOSP clang r416183b"
git clone https://github.com/LineageOS/android_prebuilts_clang_kernel_linux-x86_clang-r416183b.git clang-r416183b

info "*Clone Melt repositories"
git clone https://github.com/Pzqqt/AnyKernel3.git -b Marble-Melt --depth 1 out
git clone https://github.com/Pzqqt/android_kernel_xiaomi_marble.git --depth 1
mv ../build_kernel.sh .

echo -e "\n==="
ls -A
echo -e "===\n"

cd android_kernel_xiaomi_marble
info "!Build kernel image"
bash build_kernel.sh --no-kmi-strict -- Image
if [ $? -ne 0 ]; then
    error "Failed to build kernel image!"
    exit 1
fi
info "!Build kernel image with ksu"
bash build_kernel.sh --no-kmi-strict --ksu -- Image
if [ $? -ne 0 ]; then
    error "Failed to build kernel image with ksu!"
    exit 1
fi
info "!Build kernel modules"
bash build_kernel.sh --no-kmi-strict -- modules
if [ $? -ne 0 ]; then
    error "Failed to build kernel modules!"
    exit 1
fi
cd ..

info "!Package kernel to flashable zip"
cd out
python3 make_package.py ${RELEASE_VERSION}
cd ..

info "OK!"
