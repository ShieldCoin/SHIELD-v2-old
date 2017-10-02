#!/bin/bash
# create multiresolution windows icon
ICON_DST=../../src/qt/res/icons/SHIELD.ico

convert ../../src/qt/res/icons/SHIELD-16.png ../../src/qt/res/icons/SHIELD-32.png ../../src/qt/res/icons/SHIELD-48.png ${ICON_DST}
