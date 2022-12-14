# This Fluentd configuration file enables the collection of log files
# that can be specified at the time of its creation in an environment
# variable, assuming that the config_generator.sh script runs to generate
# a configuration file for each log file to collect.
# Logs collected will be sent to the cluster's Elasticsearch service.
#
# Currently the collector uses a text format rather than allowing the user
# to specify how to parse each file.

# Pick up all the auto-generated input config files, one for each file
# specified in the FILES_TO_COLLECT environment variable.
@include files/*

<system>
  @log_level warn
</system>

# All the auto-generated files should use the tag "file.<filename>".
<source>
  @type tail
  @id in_tail_container_logs
  path /var/log/containers/*.log
  exclude_path /var/log/containers/fluent*
  pos_file /var/log/opensearch-containers.log.pos
  <parse>
    @type multi_format
     <pattern>
       format regexp
       expression /^(?<time>.+)\s(?<stream>stdout|stderr)\s(?<logtag>F|P)\s(?<log>.*)$/
       time_key time
       time_format '%Y-%m-%dT%H:%M:%S.%NZ'
       keep_time_key true
     </pattern>
     <pattern>
       format json
       time_format '%Y-%m-%dT%H:%M:%S.%N%:z'
       time_key time
       keep_time_key true
     </pattern>
  </parse>
  read_from_head
  @log_level warn
  tag kubernetes.*
</source>


<label @FLUENT_LOG>
  <match fluent.*>
    @type null
  </match>
</label>

# prometheus monitoring config

@include /fluentd/etc/prometheus.conf

<filter kubernetes.**>
  @type kubernetes_metadata
  bearer_token_file /var/run/secrets/kubernetes.io/serviceaccount/token
  ca_file /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
</filter>

{{ if eq .Values.global.clusterType  "scaleout" -}}
  @include /fluentd/etc/scaleout.conf
{{ else }}
  @include /fluentd/etc/controlplane.conf
{{ end }}