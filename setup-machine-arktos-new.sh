#!/bin/bash

####################

echo Setup: From arktos/master/hack/setup-dev-node.sh

GOLANG_VERSION=${GOLANG_VERSION:-"1.13.9"}

echo "Update apt."
sudo apt -y update

echo "Install docker."
sudo apt -y install docker.io
sudo gpasswd -a $USER docker

echo "Install make & gcc."
sudo apt -y install make
sudo apt -y install gcc
sudo apt -y install jq

echo "Install golang."
wget https://dl.google.com/go/go${GOLANG_VERSION}.linux-amd64.tar.gz -P /tmp
sudo tar -C /usr/local -xzf /tmp/go${GOLANG_VERSION}.linux-amd64.tar.gz

####################

echo Setup: Enlist arktos

cd ~
git clone https://github.com/CentaurusInfra/arktos.git ~/go/src/k8s.io/arktos
cd ~/go/src/k8s.io
ln -s ./arktos kubernetes

git config --global credential.helper 'cache --timeout=3600000'

####################

echo Setup: Install miscellaneous

sudo apt install awscli -y -q
sudo apt install python-pip -y -q
sudo apt install jq -y -q

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
    lcov


sudo docker build -f ./test/Dockerfile -t buildbox:v2 ./test

ver=$(curl -s https://api.github.com/repos/kubernetes-sigs/kind/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
curl -Lo kind https://github.com/kubernetes-sigs/kind/releases/download/$ver/kind-$(uname)-amd64
chmod +x kind
sudo mv kind /usr/local/bin

curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

pip3 install fs
pip3 install protobuf
pip3 install grpcio
pip3 install grpcio-tools
pip3 install luigi==2.8.12
pip3 install kubernetes==11.0.0
pip3 install rpyc
pip3 install pyroute2
pip3 install ipaddress
pip3 install netaddr
pip3 install kopf
pip3 install PyYAML

####################

echo Setup: Change Containerd

wget -qO- https://github.com/futurewei-cloud/containerd/releases/download/tenant-cni-args/containerd.zip | zcat > /tmp/containerd
chmod +x /tmp/containerd
sudo systemctl stop containerd
sudo mv /usr/bin/containerd /usr/bin/containerd.bak
sudo mv /tmp/containerd /usr/bin/
sudo systemctl restart containerd
sudo systemctl start docker

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
