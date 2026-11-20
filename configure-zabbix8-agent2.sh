#!/usr/bin/env bash
# Konfigurace Zabbix Agent 2 pro auto-registraci na enceladus.pfsense.cz
set -euo pipefail

ZBX_SERVER="enceladus.pfsense.cz"
METADATA="SPOS"
PREFIX="rozensky-debian"              # klidne zmen na svuj prefix

CONF="/etc/zabbix/zabbix_agent2.conf"
STATE_DIR="/var/lib/spos-zabbix"
HN_FILE="${STATE_DIR}/hostname"

# 1) Trvaly unikatni Hostname - vygeneruje se jen poprve, pak se jen cte
mkdir -p "${STATE_DIR}"
if [[ ! -s "${HN_FILE}" ]]; then
    RAND="$(od -An -N6 -tx1 /dev/urandom | tr -d ' \n')"   # 12 hex znaku
    echo "${PREFIX}-${RAND}" > "${HN_FILE}"
    echo ">>> Vygenerovan novy hostname"
fi
HN="$(cat "${HN_FILE}")"

if ! [[ "${HN}" =~ ^${PREFIX}-[0-9a-f]{12}$ ]]; then
    echo "CHYBA: hostname '${HN}' nema ocekavany format" >&2
    exit 1
fi
echo ">>> Hostname agenta: ${HN}"

# 2) Zaloha puvodni konfigurace (jen jednou)
[[ -f "${CONF}.orig" ]] || cp "${CONF}" "${CONF}.orig"

# 3) Smazat stare hodnoty (aby se pri opakovanem provisioningu neduplikovaly)
sed -i -E '/^(Server|ServerActive|Hostname|HostnameItem|HostMetadata|HostMetadataItem|Timeout)=/d' "${CONF}"

# 4) Pripsat nove hodnoty
cat >> "${CONF}" <<EOF
Server=${ZBX_SERVER}
ServerActive=${ZBX_SERVER}
Hostname=${HN}
HostMetadata=${METADATA}
Timeout=30
EOF

# 5) Spustit sluzbu a zapnout po startu
systemctl enable zabbix-agent2
systemctl restart zabbix-agent2
sleep 3

echo ">>> Stav sluzby: $(systemctl is-active zabbix-agent2)"
echo ">>> Aktivni parametry:"
grep -E '^(Server|ServerActive|Hostname|HostMetadata|Timeout)=' "${CONF}"
echo ">>> Posledni radky logu:"
tail -n 5 /var/log/zabbix/zabbix_agent2.log || true