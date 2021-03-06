#!/bin/bash

set -e

function extract() {
    for FILE in `egrep -v '(^#|^$)' $1`; do
        OLDIFS=$IFS IFS=":" PARSING_ARRAY=($FILE) IFS=$OLDIFS
        FILE=`echo ${PARSING_ARRAY[0]} | sed -e "s/^-//g"`
        DEST=${PARSING_ARRAY[1]}
        if [ -z $DEST ]; then
            DEST=$FILE
        fi
        DIR=`dirname $DEST`
        if [ ! -d $2/$DIR ]; then
            mkdir -p $2/$DIR
        fi
        echo "Extracting /system/$FILE ..."
        if [ "$SRC" = "adb" ]; then
            # Try CM target first
            adb pull /system/$DEST $2/$DEST
            # if file does not exist try OEM target
            if [ "$?" != "0" ]; then
                adb pull /system/$FILE $2/$DEST
            fi
        else
            if [ -r $SRC/system/$DEST ]; then
                cp $SRC/system/$DEST $2/$DEST
            else
                cp $SRC/system/$FILE $2/$DEST
            fi
        fi
    done
}

if [ $# -eq 0 ]; then
  SRC=adb
else
  if [ $# -eq 1 ]; then
    SRC=$1
  else
    echo "$0: bad number of arguments"
    echo ""
    echo "usage: $0 [PATH_TO_EXPANDED_ROM]"
    echo ""
    echo "If PATH_TO_EXPANDED_ROM is not specified, blobs will be extracted from"
    echo "the device using adb pull."
    exit 1
  fi
fi

BASE=../../../vendor/$VENDOR/e8-common/proprietary
rm -rf $BASE/*

DEVBASE=../../../vendor/$VENDOR/$DEVICE/proprietary
rm -rf $DEVBASE/*

extract ../../$VENDOR/mecul/common-proprietary-files.txt $BASE
extract ../../$VENDOR/mecul/proprietary-files.txt $DEVBASE
extract ../../$VENDOR/$DEVICE/device-proprietary-files.txt $DEVBASE

./setup-makefiles.sh
