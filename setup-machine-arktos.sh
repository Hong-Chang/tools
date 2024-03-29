#!/bin/bash

####################

# echo Setup: Enable password login

# sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
# ### Set password: sudo passwd ubuntu
# sudo service sshd restart

####################

# echo Setup: Install remote desktop

# sudo apt update
# sudo apt install -y ubuntu-desktop xrdp

# sudo service xrdp restart
# sudo apt install -y xfce4 xfce4-goodies
# echo xfce4-session >~/.xsession

####################

echo Setup: Install go \(currently limited to version 1.13.9\)

sudo apt-get update -y -q

cd /tmp
wget https://dl.google.com/go/go1.13.9.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.13.9.linux-amd64.tar.gz
rm -rf go1.13.9.linux-amd64.tar.gz

####################

echo Setup: Install bazel

sudo apt install g++ unzip zip -y -q
sudo apt-get install openjdk-8-jdk -y -q
cd /tmp
wget https://github.com/bazelbuild/bazel/releases/download/0.26.1/bazel-0.26.1-installer-linux-x86_64.sh
chmod +x bazel-0.26.1-installer-linux-x86_64.sh
./bazel-0.26.1-installer-linux-x86_64.sh --user

####################

# echo Setup: Install goland

# cd /tmp
# wget https://download.jetbrains.com/go/goland-2019.3.4.tar.gz
# tar -xzf goland-2019.3.4.tar.gz
# mv GoLand-2019.3.4 ~/GoLand-2019.3.4

echo fs.inotify.max_user_watches=524288 > ./max_user_watches.conf
sudo mv ./max_user_watches.conf /etc/sysctl.d/
sudo sysctl -p --system

####################

echo Setup: Enlist arktos

cd ~
git clone https://github.com/CentaurusInfra/arktos.git ~/go/src/k8s.io/arktos
cd ~/go/src/k8s.io
ln -s ./arktos kubernetes

git config --global credential.helper 'cache --timeout=3600000'

####################

echo Setup: Install etcd

cd ~/go/src/k8s.io/arktos/
git tag v1.15.0
./hack/install-etcd.sh

####################

echo Setup: Install Docker

sudo apt -y install docker.io
sudo gpasswd -a $USER docker

####################

echo Setup: Install crictl

cd /tmp
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.17.0/crictl-v1.17.0-linux-amd64.tar.gz
sudo tar zxvf crictl-v1.17.0-linux-amd64.tar.gz -C /usr/local/bin 
rm -f crictl-v1.17.0-linux-amd64.tar.gz 

touch /tmp/crictl.yaml
echo runtime-endpoint: unix:///run/containerd/containerd.sock >> /tmp/crictl.yaml
echo image-endpoint: unix:///run/containerd/containerd.sock >> /tmp/crictl.yaml
echo timeout: 10 >> /tmp/crictl.yaml
echo debug: true >> /tmp/crictl.yaml
sudo mv /tmp/crictl.yaml /etc/crictl.yaml

mkdir -p /etc/containerd
sudo rm -rf /etc/containerd/config.toml
sudo containerd config default > /tmp/config.toml
sudo mv /tmp/config.toml /etc/containerd/config.toml
sudo systemctl restart containerd

####################

echo Setup: Install miscellaneous

sudo apt-get install -y -q libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev
wget -O /home/ubuntu/Python-3.8.8.tgz https://www.python.org/ftp/python/3.8.8/Python-3.8.8.tgz
tar -C /home/ubuntu -xzf /home/ubuntu/Python-3.8.8.tgz
cd /home/ubuntu/Python-3.8.8
sudo ./configure
sudo make
sudo make install
sudo ln -sfn /usr/local/bin/python3.8 /usr/bin/python3
sudo apt remove -fy python3-apt
sudo apt install -fy python3-apt
sudo apt update
sudo apt install -fy python3-pip
sudo sed -i '1c\#!/usr/bin/python3.8 -Es' /usr/bin/lsb_release
sudo usr/local/bin/python3.8 -m pip install --upgrade pip -y -q

sudo apt install awscli -y -q
sudo apt install jq -y -q

####################

echo Setup: Install Kind

cd ~/go/src/
GO111MODULE="on" go get sigs.k8s.io/kind@v0.7.0

####################

echo Setup: Enlist Mizar

cd ~
git clone https://github.com/CentaurusInfra/mizar

####################

echo Setup: Mizar Related

cd ~/mizar
sudo apt-get update
sudo apt-get install -y \
    build-essential clang-7 llvm-7 \
    libelf-dev \
    python3 \
    python3-pip \
    libcmocka-dev \
    lcov \
    protobuf-compiler \
    libprotobuf-dev

GO111MODULE="on" go get google.golang.org/protobuf/cmd/protoc-gen-go@v1.26
GO111MODULE="on" go get google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.1

sudo apt install docker.io
sudo pip3 install netaddr docker scapy
sudo systemctl unmask docker.service
sudo systemctl unmask docker.socket
sudo systemctl start docker
sudo systemctl enable docker

sudo docker build -f ./test/Dockerfile -t buildbox:v2 ./test

git submodule update --init --recursive

ver=$(curl -s https://api.github.com/repos/kubernetes-sigs/kind/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
curl -Lo kind https://github.com/kubernetes-sigs/kind/releases/download/$ver/kind-$(uname)-amd64
chmod +x kind
sudo mv kind /usr/local/bin

curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

sudo pip3 install fs
sudo pip3 install protobuf
sudo pip3 install grpcio
sudo pip3 install grpcio-tools
sudo pip3 install luigi==2.8.12
sudo pip3 install kubernetes==11.0.0
sudo pip3 install rpyc
sudo pip3 install pyroute2
sudo pip3 install ipaddress
sudo pip3 install netaddr
sudo pip3 install kopf
sudo pip3 install PyYAML

####################

# echo Setup: Change Containerd

# wget -qO- https://github.com/futurewei-cloud/containerd/releases/download/tenant-cni-args/containerd.zip | zcat > /tmp/containerd
# chmod +x /tmp/containerd
# sudo systemctl stop containerd
# sudo mv /usr/bin/containerd /usr/bin/containerd.bak
# sudo mv /tmp/containerd /usr/bin/
# sudo systemctl restart containerd
# sudo systemctl start docker

####################

echo Setup: Setup profile

echo PATH=\"\$HOME/go/src/k8s.io/arktos/third_party/etcd:/usr/local/go/bin:\$HOME/go/bin:\$HOME/go/src/k8s.io/arktos/_output/bin:\$HOME/go/src/k8s.io/arktos/_output/dockerized/bin/linux/amd64:\$PATH\" >> ~/.profile
echo GOPATH=\"\$HOME/go\" >> ~/.profile
echo GOROOT=\"/usr/local/go\" >> ~/.profile
echo >> ~/.profile
echo alias arktos=\"cd \$HOME/go/src/k8s.io/arktos\" >> ~/.profile
echo alias k8s=\"cd \$HOME/go/src/k8s.io/kubernetes\" >> ~/.profile
echo alias mizar=\"cd \$HOME/mizar\" >> ~/.profile
echo alias up=\"\$HOME/go/src/k8s.io/arktos/hack/arktos-up.sh\" >> ~/.profile
echo alias status=\"git status\" >> ~/.profile
echo alias pods=\"kubectl get pods -A -o wide\" >> ~/.profile
echo alias nodes=\"kubectl get nodes -o wide\" >> ~/.profile
echo alias nets=\"echo 'kubectl get subnets'\; kubectl get subnets\; echo\; echo 'kubectl get droplets'\; kubectl get droplets\; echo\; echo 'kubectl get bouncers'\; kubectl get bouncers\; echo\; echo 'kubectl get dividers'\; kubectl get dividers\; echo\; echo 'kubectl get vpcs'\; kubectl get vpcs\; echo\; echo 'kubectl get eps'\; kubectl get eps\; echo\; echo 'kubectl get networks'\; kubectl get networks\" >> ~/.profile

echo export PYTHONPATH=\"\$HOME/mizar/\" >> ~/.profile
echo export GPG_TTY=\$\(tty\) >> ~/.profile

echo cd \$HOME/go/src/k8s.io/arktos >> ~/.profile

source "$HOME/.profile"

####################

echo Setup: Install kubetest

cd ~/go/src/k8s.io
git clone https://github.com/kubernetes/test-infra.git
cd ~/go/src/k8s.io/test-infra/
GO111MODULE=on go install ./kubetest
GO111MODULE=on go mod vendor

####################

echo Setup: Machine setup completed!

sudo reboot
