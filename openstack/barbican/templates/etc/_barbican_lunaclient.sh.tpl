#!/bin/bash
set -e

lunaclient () {
    curl https://repo.eu-de-1.cloud.sap/hw-firmware/hsm/minimal-client/610-000401-004_SW_Linux_Luna_Minimal_Client_V10.4.0_RevA.tar --output 610-000401-004_SW_Linux_Luna_Minimal_Client_V10.4.0_RevA.tar
    mkdir -p /thales
    mkdir -p /thales/LunaClient-Minimal-10.4.0-417.x86_64/config/
    mkdir -p /thales/LunaClient-Minimal-10.4.0-417.x86_64/config/certs
    mv 610-000401-004_SW_Linux_Luna_Minimal_Client_V10.4.0_RevA.tar /thales
    tar -xf /thales/610-000401-004_SW_Linux_Luna_Minimal_Client_V10.4.0_RevA.tar -C /thales
    mkdir -p /root/.putty/
    curl https://repo.eu-de-1.cloud.sap/hw-firmware/hsm/minimal-client/known_hosts --output sshhostkeys
    mv sshhostkeys /root/.putty/
    NOW="$(date +%Y%m%d)"
    cp /thales/LunaClient-Minimal-10.4.0-417.x86_64/Chrystoki-template.conf /thales/LunaClient-Minimal-10.4.0-417.x86_64/config/Chrystoki.conf
    ln -s /thales/LunaClient-Minimal-10.4.0-417.x86_64/libs/64/libCryptoki2.so /usr/lib/libcrystoki2.so
    /thales/LunaClient-Minimal-10.4.0-417.x86_64/bin/64/configurator setValue -s Chrystoki2 -e LibUNIX -v /thales/LunaClient-Minimal-10.4.0-417.x86_64/libs/64/libCryptoki2.so
    /thales/LunaClient-Minimal-10.4.0-417.x86_64/bin/64/configurator setValue -s Chrystoki2 -e LibUNIX64 -v /thales/LunaClient-Minimal-10.4.0-417.x86_64/libs/64/libCryptoki2_64.so
    /thales/LunaClient-Minimal-10.4.0-417.x86_64/bin/64/configurator setValue -s Misc -e ToolsDir -v /thales/LunaClient-Minimal-10.4.0-417.x86_64/bin/64/
    /thales/LunaClient-Minimal-10.4.0-417.x86_64/bin/64/configurator setValue -s "LunaSA Client" -e SSLConfigFile -v /thales/LunaClient-Minimal-10.4.0-417.x86_64/openssl.cnf
    /thales/LunaClient-Minimal-10.4.0-417.x86_64/bin/64/configurator setValue -s "LunaSA Client" -e ServerCAFile -v /thales/LunaClient-Minimal-10.4.0-417.x86_64/config/certs/CAFile.pem
    /thales/LunaClient-Minimal-10.4.0-417.x86_64/bin/64/configurator setValue -s "LunaSA Client" -e "ClientCertFile" -v /thales/LunaClient-Minimal-10.4.0-417.x86_64/config/certs/
    /thales/LunaClient-Minimal-10.4.0-417.x86_64/bin/64/configurator setValue -s "LunaSA Client" -e "ClientPrivKeyFile" -v /thales/LunaClient-Minimal-10.4.0-417.x86_64/config/certs/
    /thales/LunaClient-Minimal-10.4.0-417.x86_64/bin/64/configurator setValue -s "Secure Trusted Channel" -e ClientTokenLib -v /thales/LunaClient-Minimal-10.4.0-417.x86_64/libs/64/libSoftToken.so
    /thales/LunaClient-Minimal-10.4.0-417.x86_64/bin/64/configurator setValue -s "Secure Trusted Channel" -e SoftTokenDir -v /thales/LunaClient-Minimal-10.4.0-417.x86_64/config/stc/token
    /thales/LunaClient-Minimal-10.4.0-417.x86_64/bin/64/configurator setValue -s "Secure Trusted Channel" -e ClientIdentitiesDir -v /thales/LunaClient-Minimal-10.4.0-417.x86_64/config/stc/client_identities
    /thales/LunaClient-Minimal-10.4.0-417.x86_64/bin/64/configurator setValue -s "Secure Trusted Channel" -e PartitionIdentitiesDir -v /thales/LunaClient-Minimal-10.4.0-417.x86_64/config/stc/partition_identities
    /thales/LunaClient-Minimal-10.4.0-417.x86_64/bin/64/configurator setValue -s "VirtualToken" -e VirtualToken00Label -v {{ .Values.lunaclient.VirtualToken.VirtualToken00Label }}
    /thales/LunaClient-Minimal-10.4.0-417.x86_64/bin/64/configurator setValue -s "VirtualToken" -e VirtualToken00SN -v {{ .Values.lunaclient.VirtualToken.VirtualToken00SN }}
    /thales/LunaClient-Minimal-10.4.0-417.x86_64/bin/64/configurator setValue -s "VirtualToken" -e VirtualToken00Members -v {{ .Values.lunaclient.VirtualToken.VirtualToken00Members }}
    /thales/LunaClient-Minimal-10.4.0-417.x86_64/bin/64/configurator setValue -s "VirtualToken" -e VirtualTokenActiveRecovery -v {{ .Values.lunaclient.VirtualToken.VirtualTokenActiveRecovery }}
    /thales/LunaClient-Minimal-10.4.0-417.x86_64/bin/64/configurator setValue -s "HASynchronize" -e {{ .Values.lunaclient.VirtualToken.VirtualToken00Label }} -v {{ .Values.lunaclient.HASynchronize.sync }}
    /thales/LunaClient-Minimal-10.4.0-417.x86_64/bin/64/configurator setValue -s "HAConfiguration" -e haLogStatus -v {{ .Values.lunaclient.HAConfiguration.haLogStatus }}
    /thales/LunaClient-Minimal-10.4.0-417.x86_64/bin/64/configurator setValue -s "HAConfiguration" -e reconnAtt -v {{ .Values.lunaclient.HAConfiguration.reconnAtt }}
    /thales/LunaClient-Minimal-10.4.0-417.x86_64/bin/64/configurator setValue -s "HAConfiguration" -e HAOnly -v {{ .Values.lunaclient.HAConfiguration.HAOnly }}
    /thales/LunaClient-Minimal-10.4.0-417.x86_64/bin/64/configurator setValue -s "HAConfiguration" -e haLogPath -v {{ .Values.lunaclient.HAConfiguration.haLogPath }}
    /thales/LunaClient-Minimal-10.4.0-417.x86_64/bin/64/configurator setValue -s "HAConfiguration" -e logLen -v {{ .Values.lunaclient.HAConfiguration.logLen }}
    /thales/LunaClient-Minimal-10.4.0-417.x86_64/bin/64/vtl createCert -n $HOSTNAME-$NOW
    /thales/LunaClient-Minimal-10.4.0-417.x86_64/bin/64/pscp -pw {{ .Values.lunaclient.conn.pwd }} /thales/LunaClient-Minimal-10.4.0-417.x86_64/config/certs/$HOSTNAME-$NOW.pem {{ .Values.lunaclient.conn.user }}@{{ .Values.lunaclient.conn.ip }}:.
    /thales/LunaClient-Minimal-10.4.0-417.x86_64/bin/64/pscp -pw {{ .Values.lunaclient.conn.pwd }} {{ .Values.lunaclient.conn.user }}@{{ .Values.lunaclient.conn.ip }}:server.pem /thales/LunaClient-Minimal-10.4.0-417.x86_64/config/certs/
    /thales/LunaClient-Minimal-10.4.0-417.x86_64/bin/64/vtl addserver -n {{ .Values.lunaclient.conn.ip }} -c  /thales/LunaClient-Minimal-10.4.0-417.x86_64/config/certs/server.pem
    echo "client register -c $HOSTNAME-$NOW" -h $HOSTNAME-$NOW > /thales/LunaClient-Minimal-10.4.0-417.x86_64/config/$HOSTNAME-$NOW.txt
    echo "client assignPartition -c $HOSTNAME-$NOW -p {{ .Values.lunaclient.conn.par }}" >> /thales/LunaClient-Minimal-10.4.0-417.x86_64/config/$HOSTNAME-$NOW.txt
    echo "exit" >> /thales/LunaClient-Minimal-10.4.0-417.x86_64/config/$HOSTNAME-$NOW.txt
    /thales/LunaClient-Minimal-10.4.0-417.x86_64/bin/64/plink {{ .Values.lunaclient.conn.ip }} -ssh -l {{ .Values.lunaclient.conn.user }} -pw {{ .Values.lunaclient.conn.pwd }} -v < /thales/LunaClient-Minimal-10.4.0-417.x86_64/config/$HOSTNAME-$NOW.txt
    cp /thales/LunaClient-Minimal-10.4.0-417.x86_64/config/Chrystoki.conf /etc/Chrystoki.conf
    }
{{- if eq .Values.hsm.enabled true }}
lunaclient
{{- end }}