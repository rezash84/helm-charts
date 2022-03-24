#!/bin/bash
set -e

lunaclient () {
    /safenet/lunaclient/bin/64/configurator setValue -s "VirtualToken" -e VirtualToken00Label -v {{ .Values.lunaclient.VirtualToken.VirtualToken00Label }}
    /safenet/lunaclient/bin/64/configurator setValue -s "VirtualToken" -e VirtualToken00SN -v {{ .Values.lunaclient.VirtualToken.VirtualToken00SN }}
    /safenet/lunaclient/bin/64/configurator setValue -s "VirtualToken" -e VirtualToken00Members -v {{ .Values.lunaclient.VirtualToken.VirtualToken00Members }}
    /safenet/lunaclient/bin/64/configurator setValue -s "VirtualToken" -e VirtualTokenActiveRecovery -v {{ .Values.lunaclient.VirtualToken.VirtualTokenActiveRecovery }}
    /safenet/lunaclient/bin/64/configurator setValue -s "HASynchronize" -e {{ .Values.lunaclient.VirtualToken.VirtualToken00Label }} -v {{ .Values.lunaclient.HASynchronize.sync }}
    /safenet/lunaclient/bin/64/configurator setValue -s "HAConfiguration" -e haLogStatus -v {{ .Values.lunaclient.HAConfiguration.haLogStatus }}
    /safenet/lunaclient/bin/64/configurator setValue -s "HAConfiguration" -e reconnAtt -v {{ .Values.lunaclient.HAConfiguration.reconnAtt }}
    /safenet/lunaclient/bin/64/configurator setValue -s "HAConfiguration" -e HAOnly -v {{ .Values.lunaclient.HAConfiguration.HAOnly }}
    /safenet/lunaclient/bin/64/configurator setValue -s "HAConfiguration" -e haLogPath -v {{ .Values.lunaclient.HAConfiguration.haLogPath }}
    /safenet/lunaclient/bin/64/configurator setValue -s "HAConfiguration" -e logLen -v {{ .Values.lunaclient.HAConfiguration.logLen }}
    ln /safenet/lunaclient/libs/64/libCryptoki2.so /usr/lib/libcrystoki2.so
    rm /tmp/610-000401-004_SW_Linux_Luna_Minimal_Client_V10.4.0_RevA.tar
    /safenet/lunaclient/bin/64/vtl createCert -n $HOSTNAME
    /safenet/lunaclient/bin/64/pscp -pw {{ .Values.lunaclient.conn.pwd }} /safenet/lunaclient/config/certs/$HOSTNAME.pem {{ .Values.lunaclient.conn.user }}@{{ .Values.lunaclient.conn.ip }}:.
    /safenet/lunaclient/bin/64/pscp -pw {{ .Values.lunaclient.conn.pwd }} {{ .Values.lunaclient.conn.user }}@{{ .Values.lunaclient.conn.ip }}:server.pem /safenet/lunaclient/config/certs/
    /safenet/lunaclient/bin/64/vtl addserver -n {{ .Values.lunaclient.conn.ip }} -c  /safenet/lunaclient/config/certs/server.pem
    echo "client register -c $HOSTNAME" -h $HOSTNAME > /safenet/lunaclient/config/$HOSTNAME.txt
    echo "client assignPartition -c $HOSTNAME -p {{ .Values.lunaclient.conn.par }}" >> /safenet/lunaclient/config/$HOSTNAME.txt
    echo "exit" >> /safenet/lunaclient/config/$HOSTNAME.txt
    /safenet/lunaclient/bin/64/plink {{ .Values.lunaclient.conn.ip }} -ssh -l {{ .Values.lunaclient.conn.user }} -pw {{ .Values.lunaclient.conn.pwd }} -v < /safenet/lunaclient/config/$HOSTNAME.txt
    cp /safenet/lunaclient/config/Chrystoki.conf /etc/Chrystoki.conf
    }

{{- if eq .Values.hsm.enabled true }}
lunaclient
{{- end }}
