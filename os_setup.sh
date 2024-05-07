#!/usr/bin/env bash
dnf groupinstall "Development Tools"
#dnf groupinstall "Virtualization Host" # RHEL - doesnt work with clab
dnf install python3-devel
dnf install libssh-devel
dnf groupinstall virtualization
dnf install podman podman-docker
dnf install ksmtuned
dnf install nano
dnf config-manager --add-repo=https://yum.fury.io/netdevops/
echo "gpgcheck=0" | sudo tee -a /etc/yum.repos.d/yum.fury.io_netdevops_.repo
dnf install containerlab
cd /root
git clone https://github.com/hellt/vrnetlab.git

echo "Place CSR QCOW2 file in /root/vrnetlab/csr."
echo "Then run 'make docker-image'."
echo "Place VMX-bundle TGZ file in /root/vrnetlab/vmx."
echo "Do not uncompress/untar the file."
echo "Then run 'make docker-image'."
echo "Run 'podman image list' and verify you have two images listed below available"
echo "- localhost/vrnetlab/vr-vmx"
echo "- localhost/vrnetlab/vr-csr"
 
echo "If you will be running a large number of similar VMs, KSM is helpful, run:"
echo "- systemctl start ksm"
echo "- systemctl start ksmtuned"`
echo "To enable KSM permanently run:"
echo "- systemctl enable ksm"
echo "- systemctl enable ksmtuned"
