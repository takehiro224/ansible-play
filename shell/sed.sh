#!/bin/bash

# 1行目を削除
sed 1d drink2.txt
# 2~5行目を削除
sed 2,5d drink2.txt
# 3行目から最後まで削除
sed '3,$d' drink2.txt
# Bから始まる行を削除
sed /^B/d drink2.txt
# 1行目を表示(だけで全部の行が表示される)
sed 1p drink2.txt
# 1行目だけを表示(-nはパターンスペースを表示しない)
sed -n 1p drink2.txt
# 行の最初に一致するBeerをWhiskyに変更する
sed 's/Beer/Whisky/' drink2.txt
# 全てのBeerをWhiskyに変更する
sed 's/Beer/Whisky/g' drink2.txt
# Br, Bxxrなどの正規表現に一致したものをWhiskyに変更する
sed 's/B.*r/whisky/g' drink2.txt
# !を削除する
sed 's/!//g' drink2.tx
# !に一致する行を表示する(-nでパターンスペースを非表示にしてpで置換が発生した行だけを表示)
sed -n 's/!//gp' drink2.tx
# -rで拡張正規表現
sed -r 's/Be+r/Whisky/' drink2.txt
# My xxxのxxxに一致している箇所が\1に該当して変更する
sed 's/My \(.*\)/--\1--/' drink2.txt
# 1から3行目までのBeerをWhiskyに変更する
sed '1,3s/Beer/Whisky/g' drink2.txt
# /を!に変更して/を文字列として利用する
sed 's!Beer!/Beer/!g' drink2.txt
