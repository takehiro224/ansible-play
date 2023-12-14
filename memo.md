## 実行手順
docker compose --file docker-compose.yml up -d
docker exec -it control_n bash
docker exec -it target1_n bash
### コントロールノード起動後に実行
ssh-copy-id -o StrictHostKeyChecking=no -i $HOME/.ssh/id_rsa.pub root@target1

## PIPを利用する手順
dnf install python3-pip
pip3 install --upgrade pip

## ansibleインストール
### Pythonパッケージマネージャからのインストール
(推奨) pipを利用する場合はvenvを利用してpythonの仮想実行環境内にAnsibleをインストールする
#### venv
- 同一のPythonバージョンで異なる仮想環境を構築できる
- 用途に応じてPython環境を切り替えるツール
- 複数バージョンを切り替えるものではなく、同一バージョンでの切り替えるためのツール

##### venvの利用(仮想環境の構築)
python -m venv [環境名]

- pipを利用したAnsibleのインストール
python3.9 -m venv venv
source venv/bin/activate シェルスクリプトや設定ファイルなどを読み込んで現在のシェル環境に反映させる
[Dockerfile]pip install --upgrade pip
pip install ansible-core
ansible --version

## Ansibleの動作確認

### 事前準備
- Ansible運用ユーザーの作成
- SSH公開鍵認証の設定
- 作業ディレクトリ作成
- ansible.cfgの設定

#### Ansible運用ユーザーの作成
「パッケージのインストール」や「OSの設定変更」などは特権ユーザー権限が必要
全ての作業を特権ユーザーで行わない
Ansible実行専用ユーザー(一般ユーザー)を作成
＊サンプルとして「ansible」というユーザーを作成する

#### SSH公開鍵認証の設定
ssh-copy-id: SSHキーをリモートホストにコピーするための便利なユーティリティ
-o StrictHostKeyChecking=no: SSH接続時にホストキーの検証を無効にするオプションです。通常、SSH接続時にはリモートホストのホストキーを検証しますが、このオプションを指定することで検証を無効にしています。ただし、セキュリティ上のリスクが伴うため、実際の運用環境では検証を行うことが推奨されます。
-i $HOME/.ssh/id_rsa.pub: コピーする公開鍵のパスを指定しています。
localhost: コピー先のホスト名またはIPアドレスです。この例ではローカルホストに対してSSHキーをコピーしています。

ssh-keygen -q -t rsa -N "" -f パス

ssh-copy-id -o StrictHostKeyChecking=no -i $HOME/.ssh/id_rsa.pub localhost

ssh-copy-id -o StrictHostKeyChecking=no -i $HOME/.ssh/id_rsa.pub ターゲットノード
ssh-copy-id -o StrictHostKeyChecking=no -i $HOME/.ssh/id_rsa.pub ユーザー名@ホスト
ssh-copy-id -o StrictHostKeyChecking=no -i $HOME/.ssh/id_rsa.pub root@target1

#### 作業ディレクトリの作成
コントロールノードにディレクトリを作成
mkdir -vp ./effective_ansible/sec2/

#### ansible.cfg作成
ansibleの設定ファイルは$HOMEに配置する場合は.ansible.cfgだが他の場合はansible.cfgとなる

#### ansibleコマンドの実行
dockerコンテナのIPアドレスを調べる方法は「docker inspect コンテナ名 | grep IP」
ansibleコマンドはプレイブックを用意せずに直接モジュールを指定するコマンド
- ./sec2/inventory.iniを作成(以下内容)＊test_serversに記載のIPアドレスはターゲットノードのコンテナのIPアドレス
localhost

[test_servers]
192.168.224.3

- コマンド実行(ターゲットノード関係なし)
ansible -i inventory.ini localhost -m ansible.builtin.ping
-> 出力結果
localhost | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}

ansible -i inventory.ini localhost -m ansible.builtin.file -a 'path=$HOME/test.txt state=touch mode=0644'
-> 出力結果
localhost | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": true,
    "dest": "/root/test.txt",
    "gid": 0,
    "group": "root",
    "mode": "0644",
    "owner": "root",
    "size": 0,
    "state": "file",
    "uid": 0
}

##### root権限の必要な(OSのユーザー管理)
ansibleコマンドではroot権限が必要なオペレーションも実行可能

#### ansible-playbookコマンドの実行
- test_playbook.ymlの作成
---
- hosts: test_servers
  tasks:
    - name: Create directory
      ansible.builtin.file:
        path: /home/ansible/tmp
        state: directory
        owner: root
        mode: "0755"
    
    - name: Copy file
      ansible.builtin.copy:
        src: /etc/hosts
        dest: /home/ansible/tmp/hosts
        owner: root
        mode: "0644"

- コマンド実行
ansible-playbook -i inventory.ini test_playbook.yml
-> 出力結果
PLAY [test_servers] *******************************************************************************************************************************************************************************

TASK [Gathering Facts] ****************************************************************************************************************************************************************************ok: [172.21.0.2]

TASK [Create directory] ***************************************************************************************************************************************************************************changed: [172.21.0.2]

TASK [Copy file] **********************************************************************************************************************************************************************************changed: [172.21.0.2]

PLAY RECAP ****************************************************************************************************************************************************************************************172.21.0.2                 : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0


## 問題
- ssh-copy-idコマンドがない
openssh-clientsをインストールする
dnf install -y openssh-clients

-公開鍵をターゲットノードに登録しようとしたところエラーが発生
ssh-copy-id -o StrictHostKeyChecking=no -i $HOME/.ssh/id_rsa.pub localhost
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/root/.ssh/id_rsa.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: ERROR: ssh: connect to host localhost port 22: Cannot assign requested address
- SSHサービスが起動していない
/usr/sbin/sshd -D
上記を実行したいがsshdがないためにインストールする(openssh-server)
dnf install -y openssh-server
再度sshサービス起動「/usr/sbin/sshd -D」
エラー
sshd: no hostkeys available -- exiting.
-> SSHサービスがホストキーを見つけられないために発生
ホストキーを生成してSSHサービスを起動する手順
ssh-keygen -A
再度sshサービス起動「/usr/sbin/sshd -D」
=> 成功

- パスワードを求められる
ssh-copy-id -o StrictHostKeyChecking=no -i $HOME/.ssh/id_rsa.pub localhost
上記を実行するとパスワードを求められるが設定していない
-> Dockerfileで以下の記載
RUN echo 'root:root' | chpasswd
RUN sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/" /etc/ssh/sshd_config
EXPOSE 22


## その他
### ssh-keygen -Aを実行すると
SSHホストキーを生成する
SSHプロトコルの各バージョンに対するホストキーが生成されて標準の場所に保存される
/etc/ssh
"SSHサーバーを初期設定する際に使用されます"
moduli
ssh_config
ssh_config.d
sshd_config
sshd_config.d
↓↓↓実行後↓↓↓
moduli
ssh_config
ssh_config.d
- ssh_host_dsa_key
- ssh_host_dsa_key.pub
- ssh_host_ecdsa_key
- ssh_host_ecdsa_key.pub
- ssh_host_ed25519_key
- ssh_host_ed25519_key.pub
- ssh_host_rsa_key
- ssh_host_rsa_key.pub
sshd_config
sshd_config.d


### PSコマンドインストール方法
dnf install -y procps-ng

### sshdインストール
dnf install -y openssh-server

### ssh-copy-idで公開鍵を指定のホストに登録する
ssh-copy-id
~/.ssh/authorized_keys
上記に保存される

### Dockerコンテナにssh接続する
Dockerfileで以下を記載
RUN echo 'root:root' | chpasswd
RUN sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/" /etc/ssh/sshd_config
EXPOSE 22