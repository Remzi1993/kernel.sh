#!/bin/bash
exec 5> >(logger -t $0)
BASH_XTRACEFD="5"
PS4='$LINENO: '
set -x

# The kernel.sh script
# Step 1. Install the required compilers and other tools
sudo apt install curl build-essential libncurses-dev bison flex libssl-dev libelf-dev

read -p "Enter the Linux Kernel version you would like to install: " version
read -p "Are you sure? Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

# Step 2. Get the latest Linux kernel source code
curl -O https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-"$version".tar.xz

# Step 3a. Extract tar.xz file
# You really don’t have to extract the source code in /usr/src.
# You can extract the source code in your $HOME directory or any other directory using the following unzx command or xz command:
unxz -v linux-"$version".tar.xz

# Step 3b. Verify Linux kernel tartball with pgp - optional
gpg --recv-keys 647F28654894E3BD457199BE38DBBDC86092693E # recent key
curl -O https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-"$version".tar.sign
gpg --verify linux-"$version".tar.sign
tar xvf linux-"$version".tar

# Step 4. Configure the Linux kernel features and modules
cd linux-"$version"
cp -v /boot/config-$(uname -r) .config

# Step 5. Configuring the kernel
make menuconfig

# You have configured everything. The process takes some time, afterwards you will have a custom Linux kernel for your system.
read -p "Setup is ready to complile and install the kernel. This will take time. Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

# Step 6. Compile the Linux Kernel and install Linux kernel modules and the kernel
## get thread or cpu core count using nproc command ##
make -j $(nproc)

# Install the Linux kernel modules
sudo make modules_install

# Install the Linux kernel
sudo make install

# You have compiled a Linux kernel and installed it.
# For the changes to have effect, you should reboot your system to use the new kernel.