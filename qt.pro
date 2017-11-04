TEMPLATE = app
TARGET = novacoin-qt
VERSION = 0.7.5
INCLUDEPATH += src src/json src/qt
QT += core gui network
greaterThan(QT_MAJOR_VERSION, 4): QT += widgets
DEFINES += QT_GUI BOOST_THREAD_USE_LIB BOOST_SPIRIT_THREADSAFE __STDC_FORMAT_MACROS __STDC_LIMIT_MACROS
CONFIG += no_include_pwd
CONFIG += thread
CONFIG += static
USE_LEVELDB = 1
#DEBUG = 1
#USE_IPV6 = 0
#BITCOIN_NEED_QT_PLUGIN = 1
USE_SSE2 = 1
USE_O3 = 1
TEST_UINT256 = 1
# QMAKE_CC=clang
# QMAKE_CXX=clang++
# QMAKE_LINK=clang++
QMAKE_CXXFLAGS *= -Wno-unused-variable -Wno-deprecated-declarations

freebsd-g++: QMAKE_TARGET.arch = $$QMAKE_HOST.arch
linux-g++: QMAKE_TARGET.arch = $$QMAKE_HOST.arch
linux-g++-32: QMAKE_TARGET.arch = i686
linux-g++-64: QMAKE_TARGET.arch = x86_64
win32-g++-cross: QMAKE_TARGET.arch = $$TARGET_PLATFORM

# for boost 1.37, add -mt to the boost libraries
# use: qmake BOOST_LIB_SUFFIX=-mt
# for boost thread win32 with _win32 sufix
# use: BOOST_THREAD_LIB_SUFFIX=_win32-...
# or when linking against a specific BerkelyDB version: BDB_LIB_SUFFIX=-6.1

# Dependency library locations can be customized with:
#    BOOST_INCLUDE_PATH, BOOST_LIB_PATH, BDB_INCLUDE_PATH,
#    BDB_LIB_PATH, OPENSSL_INCLUDE_PATH and OPENSSL_LIB_PATH respectively
#BOOST_LIB_SUFFIX=-mgw63-mt-s-1_64
#BOOST_LIB_SUFFIX=-mgw63-mt-sd-1_64
#BOOST_INCLUDE_PATH=C:\TEMP\boost_1_64_0
#BOOST_LIB_PATH=C:\TEMP\boost_1_64_0\stage\lib
#BDB_INCLUDE_PATH=C:\TEMP\db-4.8.30.NC/build_unix
#BDB_LIB_PATH=C:/TEMP/db-4.8.30.NC/build_unix
#OPENSSL_INCLUDE_PATH=C:/TEMP/openssl-1.0.1l/include
#OPENSSL_LIB_PATH=C:/TEMP/openssl-1.0.1l
#QRENCODE_INCLUDE_PATH=C:/TEMP/qrencode-3.4.4
#QRENCODE_LIB_PATH=C:/TEMP/qrencode-3.4.4/.libs

OBJECTS_DIR = build
MOC_DIR = build
UI_DIR = build

# use: qmake "RELEASE=1"
contains(RELEASE, 1) {
    macx:QMAKE_CXXFLAGS += -isysroot /Applications/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk -mmacosx-version-min=10.7
    macx:QMAKE_CFLAGS += -isysroot /Applications/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk -mmacosx-version-min=10.7
    macx:QMAKE_OBJECTIVE_CFLAGS += -isysroot /Applications/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk -mmacosx-version-min=10.7

    !windows:!macx {
        # Linux: static link
        LIBS += -Wl,-Bstatic
    }
}

contains(DEBUG, 1) {
    QMAKE_CXXFLAGS -= -O2
    QMAKE_CFLAGS -= -O2

    QMAKE_CFLAGS += -g -O0
    QMAKE_CXXCFLAGS += -g -O0
}

!win32 {
# for extra security against potential buffer overflows: enable GCCs Stack Smashing Protection
QMAKE_CXXFLAGS *= -fstack-protector-all --param ssp-buffer-size=1
QMAKE_LFLAGS *= -fstack-protector-all --param ssp-buffer-size=1
# We need to exclude this for Windows cross compile with MinGW 4.2.x, as it will result in a non-working executable!
# This can be enabled for Windows, when we switch to MinGW >= 4.4.x.
}
# for extra security on Windows: enable ASLR and DEP via GCC linker flags

win32:QMAKE_LFLAGS *= -Wl,--dynamicbase -Wl,--nxcompat
win32:QMAKE_LFLAGS += -static-libgcc -static-libstdc++

# use: qmake "USE_QRCODE=1"
# libqrencode (http://fukuchi.org/works/qrencode/index.en.html) must be installed for support
contains(USE_QRCODE, 1) {
    message(Building with QRCode support)
    DEFINES += USE_QRCODE
    LIBS += -lqrencode
}

# use: qmake "USE_DBUS=1"
contains(USE_DBUS, 1) {
    message(Building with DBUS (Freedesktop notifications) support)
    DEFINES += USE_DBUS
    QT += dbus
}

# use: qmake "USE_IPV6=1" ( enabled by default; default)
#  or: qmake "USE_IPV6=0" (disabled by default)
#  or: qmake "USE_IPV6=-" (not supported)
contains(USE_IPV6, -) {
    message(Building without IPv6 support)
} else {
    count(USE_IPV6, 0) {
        USE_IPV6=1
    }
    DEFINES += USE_IPV6=$$USE_IPV6
}

contains(BITCOIN_NEED_QT_PLUGINS, 1) {
    DEFINES += BITCOIN_NEED_QT_PLUGINS
    QTPLUGIN += qcncodecs qjpcodecs qtwcodecs qkrcodecs qtaccessiblewidgets
}

contains(USE_LEVELDB, 1) {
    message(Building with LevelDB transaction index)
    DEFINES += USE_LEVELDB

    INCLUDEPATH += src/leveldb/include src/leveldb/helpers
    LIBS += $$PWD/src/leveldb/libleveldb.a $$PWD/src/leveldb/libmemenv.a
    SOURCES += src/txdb-leveldb.cpp
    !win32 {
        # we use QMAKE_CXXFLAGS_RELEASE even without RELEASE=1 because we use RELEASE to indicate linking preferences not -O preferences
        genleveldb.commands = cd $$PWD/src/leveldb && CC=$$QMAKE_CC CXX=$$QMAKE_CXX $(MAKE) OPT=\"$$QMAKE_CXXFLAGS $$QMAKE_CXXFLAGS_RELEASE\" libleveldb.a libmemenv.a
    } else {
        # make an educated guess about what the ranlib command is called
        isEmpty(QMAKE_RANLIB) {
            QMAKE_RANLIB = $$replace(QMAKE_STRIP, strip, ranlib)
        }
        LIBS += -lshlwapi
        genleveldb.commands = cd $$PWD/src/leveldb && CC=$$QMAKE_CC CXX=$$QMAKE_CXX TARGET_OS=OS_WINDOWS_CROSSCOMPILE $(MAKE) OPT=\"$$QMAKE_CXXFLAGS $$QMAKE_CXXFLAGS_RELEASE\" libleveldb.a libmemenv.a && $$QMAKE_RANLIB $$PWD/src/leveldb/libleveldb.a && $$QMAKE_RANLIB $$PWD/src/leveldb/libmemenv.a
    }
    genleveldb.target = $$PWD/src/leveldb/libleveldb.a
    genleveldb.depends = FORCE
    PRE_TARGETDEPS += $$PWD/src/leveldb/libleveldb.a
    QMAKE_EXTRA_TARGETS += genleveldb
    # Gross ugly hack that depends on qmake internals, unfortunately there is no other way to do it.
    QMAKE_CLEAN += $$PWD/src/leveldb/libleveldb.a; cd $$PWD/src/leveldb ; $(MAKE) clean
} else {
    message(Building with Berkeley DB transaction index)
    SOURCES += src/txdb-bdb.cpp
}


# use: qmake "USE_ASM=1"
contains(USE_ASM, 1) {
    message(Using assembler scrypt implementations)
    DEFINES += USE_ASM

     contains(QMAKE_TARGET.arch, i386) | contains(QMAKE_TARGET.arch, i586) | contains(QMAKE_TARGET.arch, i686) {
        message("x86 platform, setting -msse2 flag")

        QMAKE_CXXFLAGS += -msse2
        QMAKE_CFLAGS += -msse2
    }

    SOURCES += src/crypto/scrypt/asm/scrypt-arm.S src/crypto/scrypt/asm/scrypt-x86.S src/crypto/scrypt/asm/scrypt-x86_64.S src/crypto/scrypt/asm/asm-wrapper.cpp
} else {
    # use: qmake "USE_SSE2=1"
    contains(USE_SSE2, 1) {
        message(Using SSE2 intrinsic scrypt implementation & generic sha256 implementation)
        SOURCES +=
        DEFINES += USE_SSE2
        QMAKE_CXXFLAGS += -msse2
        QMAKE_CFLAGS += -msse2
    } else {
        message(Using generic scrypt implementations)
        SOURCES += src/scrypt.cpp
    }
}

# regenerate src/build.h
!windows|contains(USE_BUILD_INFO, 1) {
    genbuild.depends = FORCE
    genbuild.commands = cd $$PWD; /bin/sh share/genbuild.sh $$OUT_PWD/build/build.h
    genbuild.target = $$OUT_PWD/build/build.h
    PRE_TARGETDEPS += $$OUT_PWD/build/build.h
    QMAKE_EXTRA_TARGETS += genbuild
    DEFINES += HAVE_BUILD_INFO
}

contains(USE_O3, 1) {
    message(Building O3 optimization flag)
    QMAKE_CXXFLAGS_RELEASE -= -O2
    QMAKE_CFLAGS_RELEASE -= -O2
    QMAKE_CXXFLAGS += -O3
    QMAKE_CFLAGS += -O3
}


QMAKE_CXXFLAGS_WARN_ON = -fdiagnostics-show-option -Wall -Wextra -Wno-ignored-qualifiers -Wformat -Wformat-security -Wno-unused-parameter -Wstack-protector

# Input
DEPENDPATH += src src/json src/qt

RESOURCES += \
    src/qt/bitcoin.qrc \
    src/qt/res/qdarkstyle/style.qrc

contains(USE_QRCODE, 1) {
    HEADERS += src/qt/qrcodedialog.h
    SOURCES += src/qt/qrcodedialog.cpp
    FORMS += src/qt/forms/qrcodedialog.ui
}

CODECFORTR = UTF-8

# for lrelease/lupdate
# also add new translations to src/qt/bitcoin.qrc under translations/
TRANSLATIONS = $$files(src/qt/locale/bitcoin_*.ts)

isEmpty(QMAKE_LRELEASE) {
    win32:QMAKE_LRELEASE = $$[QT_INSTALL_BINS]\\lrelease.exe
    else:QMAKE_LRELEASE = $$[QT_INSTALL_BINS]/lrelease
}
isEmpty(QM_DIR):QM_DIR = $$PWD/src/qt/locale
# automatically build translations, so they can be included in resource file
TSQM.name = lrelease ${QMAKE_FILE_IN}
TSQM.input = TRANSLATIONS
TSQM.output = $$QM_DIR/${QMAKE_FILE_BASE}.qm
TSQM.commands = $$QMAKE_LRELEASE ${QMAKE_FILE_IN} -qm ${QMAKE_FILE_OUT}
TSQM.CONFIG = no_link
QMAKE_EXTRA_COMPILERS += TSQM

# "Other files" to show in Qt Creator
OTHER_FILES += \
    doc/*.rst doc/*.txt doc/README README.md res/bitcoin-qt-res.rc

# platform specific defaults, if not overridden on command line
isEmpty(BOOST_LIB_SUFFIX) {
    windows:BOOST_LIB_SUFFIX = -mgw44-mt-1_53
    macx:BOOST_LIB_SUFFIX = -mt
}

isEmpty(BOOST_THREAD_LIB_SUFFIX) {
    BOOST_THREAD_LIB_SUFFIX = $$BOOST_LIB_SUFFIX
}

isEmpty(BDB_LIB_PATH) {
    macx:BDB_LIB_PATH = /usr/local/BerkeleyDB.6.1/lib
}

isEmpty(OPENSSL_LIB_PATH) {
    macx:OPENSSL_LIB_PATH = /opt/local/lib
}

isEmpty(BDB_LIB_SUFFIX) {
    macx:BDB_LIB_SUFFIX = -6.0
}

isEmpty(BDB_INCLUDE_PATH) {
    macx:BDB_INCLUDE_PATH = /opt/local/include/db60
}

isEmpty(OPENSSL_INCLUDE_PATH) {
    macx:OPENSSL_INCLUDE_PATH = /opt/local/include
}

isEmpty(BOOST_LIB_PATH) {
    macx:BOOST_LIB_PATH = /opt/local/lib
}

isEmpty(BOOST_INCLUDE_PATH) {
    macx:BOOST_INCLUDE_PATH = /opt/local/include
}

windows:DEFINES += WIN32
windows:RC_FILE = src/qt/res/bitcoin-qt-res.rc

windows:!contains(MINGW_THREAD_BUGFIX, 0) {
    # At least qmake's win32-g++-cross profile is missing the -lmingwthrd
    # thread-safety flag. GCC has -mthreads to enable this, but it doesn't
    # work with static linking. -lmingwthrd must come BEFORE -lmingw, so
    # it is prepended to QMAKE_LIBS_QT_ENTRY.
    # It can be turned off with MINGW_THREAD_BUGFIX=0, just in case it causes
    # any problems on some untested qmake profile now or in the future.
    DEFINES += _MT BOOST_THREAD_PROVIDES_GENERIC_SHARED_MUTEX_ON_WIN
    QMAKE_LIBS_QT_ENTRY = -lmingwthrd $$QMAKE_LIBS_QT_ENTRY
}

!windows:!macx {
    DEFINES += LINUX
    LIBS += -lrt
}

macx:HEADERS += src/qt/macdockiconhandler.h \
                src/qt/macnotificationhandler.h
macx:OBJECTIVE_SOURCES += src/qt/macdockiconhandler.mm \
                          src/qt/macnotificationhandler.mm
macx:LIBS += -framework Foundation -framework ApplicationServices -framework AppKit
macx:DEFINES += MAC_OSX MSG_NOSIGNAL=0
macx:ICON = src/qt/res/icons/bitcoin.icns
macx:TARGET = "NovaCoin-Qt"
macx:QMAKE_CFLAGS_THREAD += -pthread
macx:QMAKE_LFLAGS_THREAD += -pthread
macx:QMAKE_CXXFLAGS_THREAD += -pthread

# Set libraries and includes at end, to use platform-defined defaults if not overridden
INCLUDEPATH += $$BOOST_INCLUDE_PATH $$BDB_INCLUDE_PATH $$OPENSSL_INCLUDE_PATH $$QRENCODE_INCLUDE_PATH
LIBS += $$join(BOOST_LIB_PATH,,-L,) $$join(BDB_LIB_PATH,,-L,) $$join(OPENSSL_LIB_PATH,,-L,) $$join(QRENCODE_LIB_PATH,,-L,)
LIBS += -lssl -lcrypto -ldb_cxx$$BDB_LIB_SUFFIX
# -lgdi32 has to happen after -lcrypto (see  #681)
windows:LIBS += -lws2_32 -lshlwapi -lmswsock -lole32 -loleaut32 -luuid -lgdi32
LIBS += -lboost_system$$BOOST_LIB_SUFFIX -lboost_filesystem$$BOOST_LIB_SUFFIX -lboost_program_options$$BOOST_LIB_SUFFIX -lboost_thread$$BOOST_THREAD_LIB_SUFFIX
windows:LIBS += -lboost_chrono$$BOOST_LIB_SUFFIX -Wl,-Bstatic -lpthread -Wl,-Bdynamic

contains(RELEASE, 1) {
    !windows:!macx {
        # Linux: turn dynamic linking back on for c/c++ runtime libraries
        LIBS += -Wl,-Bdynamic
    }
}

linux-* {
    # We may need some linuxism here
    LIBS += -ldl
}

netbsd-*|freebsd-*|openbsd-* {
    # libexecinfo is required for back trace
    LIBS += -lexecinfo
}

system($$QMAKE_LRELEASE -silent $$PWD/src/qt/locale/translations.pro)

HEADERS += \
    src/addrman.h \
    src/alert.h \
    src/allocators.h \
    src/base58.h \
    src/bignum.h \
    src/bitcoinrpc.h \
    src/blake2.h \
    src/blake2-impl.h \
    src/bloom.h \
    src/chainparamsbase.h \
    src/checkpoints.h \
    src/clientversion.h \
    src/coincontrol.h \
    src/compat.h \
    src/crypter.h \
    src/db.h \
    src/hash.h \
    src/hashblake.h \
    src/hashgroestl.h \
    src/hashquark.h \
    src/hashqubit.h \
    src/hashskein.h \
    src/hashx11.h \
    src/hashx13.h \
    src/hashx15.h \
    src/hashx17.h \
    src/i2p.h \
    src/i2psam.h \
    src/init.h \
    src/kernel.h \
    src/key.h \
    src/keystore.h \
    src/Lyra2.h \
    src/Lyra2RE.h \
    src/main.h \
    src/mruset.h \
    src/net.h \
    src/netbase.h \
    src/protocol.h \
    src/script.h \
    src/scrypt.h \
    src/serialize.h \
    src/serveur.h \
    src/showi2paddresses.h \
    src/sph_blake.h \
    src/sph_bmw.h \
    src/sph_cubehash.h \
    src/sph_echo.h \
    src/sph_fugue.h \
    src/sph_groestl.h \
    src/sph_hamsi.h \
    src/sph_haval.h \
    src/sph_jh.h \
    src/sph_keccak.h \
    src/sph_luffa.h \
    src/sph_sha2.h \
    src/sph_shabal.h \
    src/sph_shavite.h \
    src/sph_simd.h \
    src/sph_skein.h \
    src/sph_types.h \
    src/sph_whirlpool.h \
    src/Sponge.h \
    src/strlcpy.h \
    src/sync.h \
    src/txdb.h \
    src/txdb-leveldb.h \
    src/ui_interface.h \
    src/uint256.h \
    src/util.h \
    src/version.h \
    src/wallet.h \
    src/walletdb.h \
    src/json/json_spirit.h \
    src/json/json_spirit_error_position.h \
    src/json/json_spirit_reader.h \
    src/json/json_spirit_reader_template.h \
    src/json/json_spirit_stream_reader.h \
    src/json/json_spirit_utils.h \
    src/json/json_spirit_value.h \
    src/json/json_spirit_writer.h \
    src/json/json_spirit_writer_template.h \
    src/qt/res/bitcoin-qt-res.rc \
    src/qt/aboutdialog.h \
    src/qt/addressbookpage.h \
    src/qt/addresstablemodel.h \
    src/qt/askpassphrasedialog.h \
    src/qt/bitcoinaddressvalidator.h \
    src/qt/bitcoinamountfield.h \
    src/qt/bitcoingui.h \
    src/qt/bitcoinunits.h \
    src/qt/blockbrowser.h \
    src/qt/chatwindow.h \
    src/qt/clientmodel.h \
    src/qt/csvmodelwriter.h \
    src/qt/editaddressdialog.h \
    src/qt/guiconstants.h \
    src/qt/guiutil.h \
    src/qt/monitoreddatamapper.h \
    src/qt/notificator.h \
    src/qt/optionsdialog.h \
    src/qt/optionsmodel.h \
    src/qt/overviewpage.h \
    src/qt/qtipcserver.h \
    src/qt/qvalidatedlineedit.h \
    src/qt/qvaluecombobox.h \
    src/qt/rpcconsole.h \
    src/qt/sendcoinsdialog.h \
    src/qt/sendcoinsentry.h \
    src/qt/serveur.h \
    src/qt/signverifymessagedialog.h \
    src/qt/transactiondesc.h \
    src/qt/transactiondescdialog.h \
    src/qt/transactionfilterproxy.h \
    src/qt/transactionrecord.h \
    src/qt/transactiontablemodel.h \
    src/qt/transactionview.h \
    src/qt/walletmodel.h \
    src/qt/showi2paddresses.h

SOURCES += \
    src/addrman.cpp \
    src/alert.cpp \
    src/bitcoinrpc.cpp \
    src/bloom.cpp \
    src/chainparamsbase.cpp \
    src/checkpoints.cpp \
    src/crypter.cpp \
    src/daemon.cpp \
    src/db.cpp \
    src/hash.cpp \
    src/i2p.cpp \
    src/i2psam.cpp \
    src/init.cpp \
    src/kernel.cpp \
    src/key.cpp \
    src/keystore.cpp \
    src/main.cpp \
    src/net.cpp \
    src/netbase.cpp \
    src/noui.cpp \
    src/protocol.cpp \
    src/rpcblockchain.cpp \
    src/rpcdump.cpp \
    src/rpcmining.cpp \
    src/rpcnet.cpp \
    src/rpcrawtransaction.cpp \
    src/rpcwallet.cpp \
    src/script.cpp \
    src/scrypt.cpp \
    src/sync.cpp \
    src/util.cpp \
    src/version.cpp \
    src/wallet.cpp \
    src/walletdb.cpp \
    src/aes_helper.c \
    src/blake.c \
    src/blake2s-ref.c \
    src/bmw.c \
    src/cubehash.c \
    src/echo.c \
    src/fugue.c \
    src/groestl.c \
    src/hamsi.c \
    src/hamsi_helper.c \
    src/haval.c \
    src/haval_helper.c \
    src/jh.c \
    src/keccak.c \
    src/luffa.c \
    src/Lyra2.c \
    src/Lyra2RE.c \
    src/md_helper.c \
    src/shabal.c \
    src/shavite.c \
    src/simd.c \
    src/skein.c \
    src/sph_md_helper.c \
    src/sph_sha2big.c \
    src/Sponge.c \
    src/whirlpool.c \
    src/json/json_spirit_reader.cpp \
    src/json/json_spirit_value.cpp \
    src/json/json_spirit_writer.cpp \
    src/qt/aboutdialog.cpp \
    src/qt/addressbookpage.cpp \
    src/qt/addresstablemodel.cpp \
    src/qt/askpassphrasedialog.cpp \
    src/qt/bitcoin.cpp \
    src/qt/bitcoinaddressvalidator.cpp \
    src/qt/bitcoinamountfield.cpp \
    src/qt/bitcoingui.cpp \
    src/qt/bitcoinstrings.cpp \
    src/qt/bitcoinunits.cpp \
    src/qt/blockbrowser.cpp \
    src/qt/chatwindow.cpp \
    src/qt/clientmodel.cpp \
    src/qt/csvmodelwriter.cpp \
    src/qt/editaddressdialog.cpp \
    src/qt/guiutil.cpp \
    src/qt/monitoreddatamapper.cpp \
    src/qt/notificator.cpp \
    src/qt/optionsdialog.cpp \
    src/qt/optionsmodel.cpp \
    src/qt/overviewpage.cpp \
    src/qt/qtipcserver.cpp \
    src/qt/qvalidatedlineedit.cpp \
    src/qt/qvaluecombobox.cpp \
    src/qt/rpcconsole.cpp \
    src/qt/sendcoinsdialog.cpp \
    src/qt/sendcoinsentry.cpp \
    src/qt/serveur.cpp \
    src/qt/signverifymessagedialog.cpp \
    src/qt/transactiondesc.cpp \
    src/qt/transactiondescdialog.cpp \
    src/qt/transactionfilterproxy.cpp \
    src/qt/transactionrecord.cpp \
    src/qt/transactiontablemodel.cpp \
    src/qt/transactionview.cpp \
    src/qt/walletmodel.cpp \
    src/qt/showi2paddresses.cpp \
    src/scrypt-sse2.cpp

DISTFILES += \
    src/Makefile.am \
    src/Makefile.qt.include \
    src/m4/ax_boost_base.m4 \
    src/m4/ax_boost_chrono.m4 \
    src/m4/ax_boost_date_time.m4 \
    src/m4/ax_boost_filesystem.m4 \
    src/m4/ax_boost_iostreams.m4 \
    src/m4/ax_boost_program_options.m4 \
    src/m4/ax_boost_regex.m4 \
    src/m4/ax_boost_system.m4 \
    src/m4/ax_boost_thread.m4 \
    src/m4/ax_boost_unit_test_framework.m4 \
    src/m4/ax_check_compile_flag.m4 \
    src/m4/ax_check_link_flag.m4 \
    src/m4/ax_check_preproc_flag.m4 \
    src/m4/ax_pthread.m4 \
    src/m4/bitcoin_find_bdb48.m4 \
    src/m4/bitcoin_qt.m4 \
    src/m4/bitcoin_subdir_to_include.m4 \
    src/qt/res/icons/bitcoin.png \
    src/qt/res/icons/bitcoin_testnet.png \
    src/qt/res/icons/notsynced.png \
    src/qt/res/icons/social.png \
    src/qt/res/icons/toolbar.png \
    src/qt/res/icons/toolbar_testnet.png \
    src/qt/res/icons/transaction_conflicted.png \
    src/qt/res/src/bitcoin.svg \
    src/qt/res/src/clock1.svg \
    src/qt/res/src/clock2.svg \
    src/qt/res/src/clock3.svg \
    src/qt/res/src/clock4.svg \
    src/qt/res/src/clock5.svg \
    src/qt/res/src/clock_green.svg \
    src/qt/res/src/inout.svg \
    src/qt/res/src/questionmark.svg \
    src/qt/res/icons/bitcoin.ico \
    src/qt/res/icons/bitcoin_testnet.ico \
    src/qt/res/icons/SHIELD.ico \
    src/qt/res/icons/SHIELD_testnet.ico \
    src/qt/res/icons/microcash.icns \
    src/qt/res/icons/SHIELD.icns \
    src/json/LICENSE.txt

FORMS += \
    src/qt/forms/aboutdialog.ui \
    src/qt/forms/addressbookpage.ui \
    src/qt/forms/askpassphrasedialog.ui \
    src/qt/forms/blockbrowser.ui \
    src/qt/forms/chatwindow.ui \
    src/qt/forms/editaddressdialog.ui \
    src/qt/forms/optionsdialog.ui \
    src/qt/forms/overviewpage.ui \
    src/qt/forms/rpcconsole.ui \
    src/qt/forms/sendcoinsdialog.ui \
    src/qt/forms/sendcoinsentry.ui \
    src/qt/forms/signverifymessagedialog.ui \
    src/qt/forms/transactiondescdialog.ui \
    src/qt/forms/showi2paddresses.ui

