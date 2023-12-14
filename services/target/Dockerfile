FROM rockylinux:9.2

# 必要なツール
RUN dnf install -y procps-ng
# sshサービス(sshd)のインストール /usr/sbin/sshdにインストールされる
RUN dnf install -y openssh-serve
# SSHホストキーを生成
RUN ssh-keygen -A

RUN echo 'root:root' | chpasswd
RUN sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/" /etc/ssh/sshd_config
EXPOSE 22
## SSHサービス(sshd)を起動
CMD ["/usr/sbin/sshd", "-D"]

WORKDIR /root