#!/bin/bash
exec 5> >(logger -t $0)
BASH_XTRACEFD="5"
PS4='$LINENO: '
set -x

# The kernel script
sudo apt install curl

read -p "Enter the Linux Kernel version you would like to install: " version
read -p "Are you sure? Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

# Step 1. Get the latest Linux kernel source code
# curl https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-"$version".tar.xz --output linux-"$version".tar.xz

# Step 2. Extract tar.xz file
# You really don’t have to extract the source code in /usr/src.
# You can extract the source code in your $HOME directory or any other directory using the following unzx command or xz command:
unxz -v linux-"$version".tar.xz

# Verify Linux kernel tartball with pgp - optional
gpg --recv-keys 647F28654894E3BD457199BE38DBBDC86092693E # recent key
# curl https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-"$version".tar.sign --output linux-"$version".tar.sign
gpg --verify linux-"$version".tar.sign
tar xvf linux-"$version".tar

# Step 3. Configure the Linux kernel features and modules
cd linux-"$version"
cp -v /boot/config-$(uname -r) .config

# Step 4. Install the required compilers and other tools
sudo apt-get install build-essential libncurses-dev bison flex libssl-dev libelf-dev

# Step 5. Configuring the kernel
make menuconfig

read -p "Setup is ready to complile and install the kernel. This will take time. Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

# Step 5. Compile a Linux Kernel
## get thread or cpu core count using nproc command ##
make -j $(nproc)

# Install the Linux kernel modules
sudo make modules_install

# Install the Linux kernel
sudo make install

# You have compiled a Linux kernel.
# The process takes some time, however now you have a custom Linux kernel for your system. Let us reboot the system.