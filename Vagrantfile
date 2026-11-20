# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# OSY 2026 - Zabbix 8.0 LTS auto-registrace agenta (Debian 13)
# Spusteni: vagrant up
# Opakovany provisioning: vagrant provision  /  vagrant reload --provision

Vagrant.configure("2") do |config|
  # Box over/prevezmi z Vagrant/Vagrantfile-debian ze sablony
  config.vm.box = "bento/debian-13"
  config.vm.hostname = "debian-zabbix"

  config.vm.provider "virtualbox" do |vb|
    vb.name   = "spos-debian-zabbix"
    vb.memory = 1024
    vb.cpus   = 1
  end

  # 1) instalace Zabbix Agent 2 z oficialniho repozitare Zabbix 8.0
  config.vm.provision "shell", name: "install-agent2",   path: "install-zabbix8-agent2.sh"
  # 2) konfigurace agenta + trvaly unikatni Hostname + start sluzby
  config.vm.provision "shell", name: "configure-agent2", path: "configure-zabbix8-agent2.sh"
end
