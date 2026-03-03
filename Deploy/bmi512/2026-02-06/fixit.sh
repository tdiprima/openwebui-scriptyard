#!/bin/bash

#sudo iptables -P FORWARD ACCEPT
#sudo iptables -A FORWARD -i docker0 -o eth0 -j ACCEPT
#sudo iptables -A FORWARD -i eth0 -o docker0 -m state --state RELATED,ESTABLISHED -j ACCEPT

sudo apt install iptables-persistent -y
sudo netfilter-persistent save

