#!/bin/bash
# todo: add pacamn and other setups

# generating entropy make it harder to guess the randomness!.
echo "Initializing random number generator..."
random_seed=/var/run/random-seed
# Carry a random seed from start-up to start-up
# Load and then save the whole entropy pool
if [ -f $random_seed ]; then
    sudo cat $random_seed >/dev/urandom
else
    sudo touch $random_seed
fi
sudo chmod 600 $random_seed
poolfile=/proc/sys/kernel/random/poolsize
[ -r $poolfile ] && bytes=`sudo cat $poolfile` || bytes=512
sudo dd if=/dev/urandom of=$random_seed count=1 bs=$bytes

#Also, add the following lines in an appropriate script which is run during the$

# Carry a random seed from shut-down to start-up
# Save the whole entropy pool
echo "Saving random seed..."
random_seed=/var/run/random-seed
sudo touch $random_seed
sudo chmod 600 $random_seed
poolfile=/proc/sys/kernel/random/poolsize
[ -r $poolfile ] && bytes=`sudo cat $poolfile` || bytes=512
sudo dd if=/dev/urandom of=$random_seed count=1 bs=$bytes

# Create a swap file

cd ~
if [ -e /swapfile1 ]; then
echo "Swapfile already present"
else
sudo dd if=/dev/zero of=/swapfile1 bs=1024 count=524288
sudo mkswap /swapfile1
sudo chown root:root /swapfile1
sudo chmod 0600 /swapfile1
sudo swapon /swapfile1
fi


sudo pacman -Sy openssl-1.0 base-devel boost boost-libs db4.8 base-devel qrencode qt5 automoc4 protobuf

mkdir ~/.SHIELD
echo "rpcuser="$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 26 ; echo '') '\n'"rpcpassword="$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 26 ; echo '') '\n'"rpcport=20103" '\n'"port=21103" '\n'"daemon=1" '\n'"listen=1" > ~/.SHIELD/SHIELD.conf

cd ~/
git clone https://github.com/ShieldCoin/ShieldCoin
cd ~/ShieldCoin
./autogen.sh
./configure CPPFLAGS="-I/usr/include/openssl-1.0 -O2" LDFLAGS="-L/usr/lib/openssl-1.0" CFLAGS="-I/usr/include/openssl-1.0" --with-gui=qt5
make