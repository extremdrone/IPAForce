#!/bin/sh

#  checkMyAss.sh
#  IPAForce
#
#  Created by Lakr Sakura on 2018/10/1.
#  Copyright © 2018 Lakr Sakura. All rights reserved.

# 获取当前目录
BASEDIR=$(dirname "$0")

# 检查 py 工具是否存在
if [ -e $BASEDIR/SMJobBlessUtil.py ]
then
echo "[*] SMJobBlessUtil.py found! Ready to check your ass."
else
echo "[Panic] SMJobBlessUtil.py is not here my friend."
fi

# 开始修正
./SMJobBlessUtil.py setreq   ./../Build/Products/Debug/IPAForce.app   ./../IPAForce/Info.plist   ./rootHandler-Info.plist

# 检查一下
# ./SMJobBlessUtil.py check   ./../Build/Products/Debug/IPAForce.app

exit 0
