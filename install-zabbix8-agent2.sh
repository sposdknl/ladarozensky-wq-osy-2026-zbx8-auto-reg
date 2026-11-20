#!/usr/bin/env bash
# Instalace Zabbix Agent 2 (8.0 LTS) z oficialniho repozitare Zabbix pro Debian 13
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

ZBX_VER="8.0"
REL_DEB="zabbix-release_latest+debian13_all.deb"
REL_URL="https://repo.zabbix.com/zabbix/${ZBX_VER}/release/debian/pool/main/z/zabbix-release/${REL_DEB}"

echo ">>> Pridavam oficialni repozitar Zabbix ${ZBX_VER}"
if ! dpkg -s zabbix-release >/dev/null 2>&1; then
    apt-get update -q
    apt-get install -y -q wget ca-certificates
    wget -q "${REL_URL}" -O "/tmp/${REL_DEB}"
    dpkg -i "/tmp/${REL_DEB}"
    rm -f "/tmp/${REL_DEB}"
else
    echo "    zabbix-release uz je nainstalovany, preskakuji"
fi

echo ">>> Instaluji zabbix-agent2"
apt-get update -q
apt-get install -y -q zabbix-agent2

# Kontrola, ze je opravdu verze 8.0 (ne starsi balicek z repozitare Debianu)
# awk cte cely vystup (head -n1 by zavrel rouru -> SIGPIPE -> pipefail ukonci skript)
VER="$(/usr/sbin/zabbix_agent2 -V 2>&1 | awk 'NR==1')"
echo "    ${VER}"
if ! echo "${VER}" | grep -q " 8\.0\."; then
    echo "CHYBA: nainstalovana verze neni 8.0!" >&2
    apt-cache policy zabbix-agent2 >&2
    exit 1
fi