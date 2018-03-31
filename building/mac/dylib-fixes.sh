#!/bin/bash

# helper to get path of a library installed by brew
function get-brew-lib-path {
  THELIBDIR=`dirname $(brew --prefix $1)`
  ACTUAL_PATH=`readlink $THELIBDIR/$1`
  ABS_PATH=$(python -c "import os,sys; print os.path.realpath(sys.argv[1])" $THELIBDIR/$ACTUAL_PATH)
  echo $ABS_PATH
}

# TODO fix macdeployqtplus recursive strategy
# specifically, libboost_system-mt.dylib is the culprit!
# the actual issue is that the python script ends up recursively looking at the libraries that are required by the dylibs, however, when it sees @loader_path on a module already copied over to package contents, those referenced modules are assumed to already be copied because they "are in" the package contents--  basically a false short circuit. For now, this script will remove any @loader_path and replace it with the absolute path so macdeployqtplus behaves correctly.

function fix-boost-dylib-for-qtdeploy {
  BOOST_PATH=$(get-brew-lib-path boost@1.57)
  for dylib in $(ls $BOOST_PATH/lib)
  do
    for localref in $(otool -L $BOOST_PATH/lib/$dylib | grep loader_path | awk '{print $1}')
    do
      newref=$(echo $localref | sed 's#@loader_path#'$BOOST_PATH/lib'#g')
      sudo install_name_tool -change $localref $newref $BOOST_PATH/lib/$dylib
    done
  done
}

# brew install mysql
# cd /usr/local/qt5/5.4/clang_64/plugins/sqldrivers
# otool -L libqsqlmysql.dylib

function fix-mysql-dylib-for-qtdeploy {
  QTSQLDRIVERS_PATH=/usr/local/qt5/5.4/clang_64/plugins/sqldrivers/
  CURRENT_MYSQLCLIENT_PATH=$(otool -L $QTSQLDRIVERS_PATH/libqsqlmysql.dylib | grep mysqlclient | awk '{print $1}')

  MYSQL_DIR=`dirname $(brew --prefix mysql)`
  ACTUAL_PATH=`readlink $MYSQL_DIR/mysql`
  ABS_PATH=$(python -c "import os,sys; print os.path.realpath(sys.argv[1])" $MYSQL_DIR/$ACTUAL_PATH)

  install_name_tool -change $CURRENT_MYSQLCLIENT_PATH $ABS_PATH/lib/libmysqlclient.20.dylib $QTSQLDRIVERS_PATH/libqsqlmysql.dylib
}
