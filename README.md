SHIELD [XSH] Source Code
================================

Specifications:
--------------

* Symbol: XSH
* PoW (proof of work)
* Algorithms: scrypt, x17, Lyra2rev2, myr-groestl, & blake2s
* Blocktime: 15 seconds -
* RPC port: 20103 -
* P2P port: 21103 -
* Blockreward: 
  * Block 0 to 14,000 : 8,000 coins
  * 14,000 to 28,000 : 4,000 coins
  * 28,000 to 42,000: 2,000 coins
  * 42,000 to 210,000: 1,000 coins
  * 210,000 to 378,000: 500 coins
  * 378,000 to 546,000: 250 coins
  * 546,000 to 714,000: 125 coins
  * 714,000 to 2,124,000: 62 coins
  * 2,124,000 to 4,248,000: 32 coins

Total Supply
------------

Approximately total reward cap: ~660 Million -

Binary (pre-compiled) wallets are available on all platforms at [https://ShieldCoin.github.io](https://ShieldCoin.github.io/#wallets)

Compiling Linux Wallet on Ubuntu/Debian (faster) 
----------------------

sudo rm -Rf ~/SHIELD  #(if you already have it) 

sudo apt-get -y install git && cd ~ && git clone https://github.com/ShieldCoin/SHIELD && cd SHIELD && sh go.sh


Compiling Linux Wallet on Ubuntu/Debian
----------------------

Step 1. Install the dependencies. 

```sudo apt-get update```

```sudo apt-get install libdb-dev libdb++-dev build-essential libtool autotools-dev automake pkg-config libssl1.0-dev libevent-dev bsdmainutils git libboost-all-dev libminiupnpc-dev libqt5gui5 libqt5core5a libqt5webkit5-dev libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler libqrencode-dev```

**Note**: If you are on debian, you will also need to `apt-get install libcanberra-gtk-module`.

Step 2. Clone the git repository and compile the daemon and gui wallet:

```git clone https://github.com/ShieldCoin/SHIELD && cd SHIELD && ./autogen.sh && ./configure --with-incompatible-bdb && make```

if you are using source-build libdb4.8(++)-dev you may need to use

```./configure  CPPFLAGS="-I/usr/local/BerkeleyDB.4.8/include -O2" LDFLAGS="-L/usr/local/BerkeleyDB.4.8/lib"```

**Note**: If you get a "memory exhausted" error, make a swap file. (https://www.digitalocean.com/community/tutorials/how-to-add-swap-space-on-ubuntu-16-04)

Using the wallet:
----
The gui wallet is in ./SHIELD/src/qt and the daemon in ./SHIELD/src directories.

**Note**: If you see something like 'Killed (program cc1plus)' run ```dmesg``` to see the error(s)/problems(s). This is most likely caused by running out of resources. You may need to add some RAM or add some swap space.

**Optional**:
If you want to copy the binaries for use by all users, run the following commands:

```sudo cp src/SHIELDd /usr/bin/```

```sudo cp src/qt/SHIELD-qt /usr/bin/```

Step 3. Creating a configuration file. Type ```cd ~``` to get back to the home folder and type:

```SHIELDd.exe```  (or ```./SHIELDd``` if on mac or linux)

the output from this command will tell you that you need to make a Shield.conf and will suggest some good starting values.

For Linux users, type:
 
```nano ~/.SHIELD/SHIELD.conf```
(For Windows users, see below. For mac users, the command is ```nano ~/Library/Application\ Support\SHIELD\SHIELD.conf```)
    
Paste the output from the `SHIELDd` command into the Shield.conf like this: (It is recommended to change the password to something unique.)

    rpcuser=Shieldrpcusername
    rpcpassword=85CpSuCNvDcYsdQU8w621mkQqJAimSQwCSJL5dPT9wQX
    
    
**Optional**: Add `rpcport=20103`, `port=21103`, or `algo=groestl` to the configuration file.

Add `daemon=1`. 

Your config may look something like this:

    rpcuser=Shieldrpcusername
    rpcpassword=85CpSuCNvDcYsdQU8w621mkQqJAimSQwCSJL5dPT9wQX
    rpcport=20103
    port=21103
    daemon=1
    algo=groestl

Exit the Shield.conf by pressing `ctrl + x` on your keyboard then pressing `y` and hitting enter. This should have created a Shield.conf file with what you just added. 

Type ```SHIELDd.exe``` (or ```./SHIELDd``` if on mac or linux) and your Shield daemon should start.

To check the status of how much of the blockchain has been downloaded (aka synced) type `SHIELDd.exe getinfo` (or `./SHIELDd getinfo` if on mac or linux).



To compile on Mac (OSX El Capitan, but test compiled on Mountain Lion v10.8):
------------
1. Ensure you do not have qt5 nor qt installed.

    `brew uninstall qt qt5 qt55 qt52`   
   
2. Download [qt5.4.2](https://download.qt.io/archive/qt/5.4/5.4.2/qt-opensource-mac-x64-clang-5.4.2.dmg)
     
3. Install qt5 into /usr/local/qt5
   
   Note: Change the installation folder from "xxx/Qt5.4.2" to "/usr/local/qt5"
   
4. Run these commands:

    `export PKG_CONFIG_PATH=/usr/local/qt5/5.4/clang_64/lib/pkgconfig`
    
    `export PATH=/usr/local/qt5/5.4/clang_64/bin:$PATH`
    
    `export QT_CFLAGS="-I/usr/local/qt5/5.4/clang_64/lib/QtWebKitWidgets.framework/Versions/5/Headers -I/usr/local/qt5/5.4/clang_64/lib/QtWebView.framework/Versions/5/Headers -I/usr/local/qt5/5.4/clang_64/lib/QtDBus.framework/Versions/5/Headers -I/usr/local/qt5/5.4/clang_64/lib/QtWidgets.framework/Versions/5/Headers -I/usr/local/qt5/5.4/clang_64/lib/QtWebKit.framework/Versions/5/Headers -I/usr/local/qt5/5.4/clang_64/lib/QtNetwork.framework/Versions/5/Headers -I/usr/local/qt5/5.4/clang_64/lib/QtGui.framework/Versions/5/Headers -I/usr/local/qt5/5.4/clang_64/lib/QtCore.framework/Versions/5/Headers -I. -I/usr/local/qt5/5.4/clang_64/mkspecs/macx-clang -F/usr/local/qt5/5.4/clang_64/lib"`
    
    `export QT_LIBS="-F/usr/local/qt5/5.4/clang_64/lib -framework QtWidgets -framework QtGui -framework QtCore -framework DiskArbitration -framework IOKit -framework OpenGL -framework AGL -framework QtNetwork -framework QtWebKit -framework QtWebKitWidgets -framework QtDBus -framework QtWebView"`
    
    
5. Install the other required items:

    `brew install protobuf boost@1.57 miniupnpc openssl qrencode berkeley-db4 automake`
    
    `brew link boost@1.57 --force`
    
6. Download the wallet source and build:

    `git clone https://github.com/ShieldCoin/SHIELD`

    `cd SHIELD`
    
    `./autogen.sh`
    
    `./configure --with-gui=qt5`
    
    `make -j4`
    

Building the Mac installer (.dmg) file
-----
Run `make deploy`

If you are building the .dmg (by running 'mac deploy') you may need to run these commands if you get an error regarding mysql:

    brew install mysql
    
    cd /usr/local/qt5/5.4/clang_64/plugins/sqldrivers
    
    otool -L libqsqlmysql.dylib

Note: This may be pointing to an version of mysql that you do not have installed (like mysql55) - Alternatively, you may be able to remove the library from the sqldrivers folder.

    install_name_tool -change /opt/local/lib/mysql55/mysql/libmysqlclient.18.dylib /usr/local/Cellar/mysql/5.7.12/lib/libmysqlclient.20.dylib libqsqlmysql.dylib
    
Trying to build .dmg on 10.8? You will need to run this:
    
    export CFLAGS=-Qunused-arguments
    
    export CPPFLAGS=-Qunused-arguments
    
    sudo -E easy_install appscript
    

Want to use Docker?
------------

Check out the [readme](https://github.com/ShieldCoin/Shield/tree/master/contrib/docker) for more information.


Want to 'solo-mine' from the wallet?
----------
You can use the wallet to mine. You need to specify the algorithm (see below) and set the "gen" flag. For instance, in the configuration specify ```gen=1```. 


Using different algorithms (for mining)
----------

To use a specific mining algorithm use the `algo` switch in your configuration file (.conf file) or from the command line (like this `--algo=x17`) Here are the possible values:

    algo=x17
    algo=scrypt
    algo=groestl
    algo=lyra
    algo=blake

Using SHIELD on Windows
-------------

1. Download the pre-compiled software. (only from official SHIELD site)
2. Install
3. In windows file explorer, open c:\Users\XXX\AppData\Roaming\SHIELD (be sure to change XXX to your windows user)
4. Right click and create a new file SHIELD.txt
5. Edit the file to have contents above (see instructions above for options)
6. Save and close the file
7. Reame the file to SHIELD.conf
8. Start the SHIELD-qt program.
9. Open up SHIELD-qt console and run ```getinfo``` (or ```getmininginfo```) to verify settings.

(Optional)<br>
Add tor nodes using: https://github.com/ShieldCoin/SHIELD/wiki/Using-Tor-qt-nodes

**Note:** You must re-start the wallet after making changes to ShieldCoin.conf.
[How To build on Windows](https://bitcointalk.org/index.php?topic=149479.0)


Thanks
----
Special Thanks to: 
* VERGE Devs
* Tor Devs
* i2p Devs
* Bitcoin Devs



Linux Wallet Video Tutorial
-------
https://www.youtube.com/watch?v=WYe75b6RWes


