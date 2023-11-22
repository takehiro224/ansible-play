FROM rockylinux:9.2

# 必要なツール
RUN dnf install -y procps-ng

RUN dnf install -y openssh-server
RUN ssh-keygen -A

RUN echo 'root:root' | chpasswd
RUN sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/" /etc/ssh/sshd_config
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]

WORKDIR /root