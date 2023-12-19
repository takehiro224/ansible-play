#!/bin/bash

o osumi 36
m miyake 74
s1 suzuki 59
s2 sato 12
i ino 98
s3 sakurama 41

# 2列目3列目を表示する
awk '{print $2,$3}' score.txt
# 1列目がsから始まる行を表示する
awk '$1 ~ /^s/ {print NR,$0}' score.txt

# 特定のフィールドを抽出して表示するという列選択でよく利用される
# lsコマンド結果から、5列目と9列目を表示
ls -l /usr/bin | awk '{print $5,$9}'

# NFは最後のフィールドを指す
# 1番最後のフィールドと、その1つ前のフィールドを表示
ls -l /usr/bin | awk '{print $(NF-1), $NF}'

# パターンの指定
# awk '第9フィールド 正規表現の比較 正規表現 {print $5,$9}'
awk '$9 ~ /^cp/ {print $5,$9}'
# ファイル名がcpで始まる行のみを表示する
ls -l /usr/bin | awk '$9 ~ /^cp/ {print $5,$9}'

# 行の先頭がdで始まる行のみを表示する(レコード全体が対象になる)
ls -l /usr/bin | awk '/^d/ {print $5,$9}'