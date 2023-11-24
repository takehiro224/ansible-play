FROM rockylinux:9.2

# PIP関連
RUN dnf install -y python3-pip
RUN pip3 install --upgrade pip

# 必要なツール
## PSコマンド
RUN dnf install -y procps-ng

WORKDIR /root

# Pythonの仮想実行環境を作成
## python3.9 -m venv 環境名
RUN python3.9 -m venv venv
## シェルスクリプトや設定ファイルなどを読み込んで現在のシェル環境に反映させる
RUN source venv/bin/activate
## ansibleをインストール
RUN pip install ansible-core

# SSHキー作成
RUN dnf install -y openssh && ssh-keygen -q -t rsa -N "" -f $HOME/.ssh/id_rsa
## ssh-copy-idを利用するため
RUN dnf install -y openssh-clients
## sshサービス(sshd)のインストール /usr/sbin/sshdにインストールされる
RUN dnf install -y openssh-server

RUN echo 'root:root' | chpasswd
RUN sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/" /etc/ssh/sshd_config
EXPOSE 22
## SSHサービス(sshd)が利用するホストキーを作成する
RUN ssh-keygen -A
## SSHサービス(sshd)を起動
CMD ["/usr/sbin/sshd", "-D"]
## 公開鍵をターゲットノードに登録
# RUN ssh-copy-id -o StrictHostKeyChecking=no -i $HOME/.ssh/id_rsa.pub root@target1