#!/usr/bin/env bash
set -euxo pipefail

nova_manage="nova-manage --config-file /etc/nova/nova.conf"
available_commands_text=$(nova-manage --help | awk '/Command categories/ {getline; print $0}')

{{- if (.Values.imageVersion | hasPrefix "rocky" | not) }}

$nova_manage db online_data_migrations
{{- end }}

if echo "${available_commands_text}" | grep -q -E '[{,]placement[},]'; then
  $nova_manage placement sync_aggregates
fi

{{ include "utils.proxysql.proxysql_signal_stop_script" . }}
