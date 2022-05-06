---

# This is the main OpenSearch Security configuration file where authentication
# and authorization is defined.
#
# You need to configure at least one authentication domain in the authc of this file.
# An authentication domain is responsible for extracting the user credentials from
# the request and for validating them against an authentication backend like Active Directory for example.
#
# If more than one authentication domain is configured the first one which succeeds wins.
# If all authentication domains fail then the request is unauthenticated.
# In this case an exception is thrown and/or the HTTP status is set to 401.
#
# After authentication authorization (authz) will be applied. There can be zero or more authorizers which collect
# the roles from a given backend for the authenticated user.
#
# Both, authc and auth can be enabled/disabled separately for REST and TRANSPORT layer. Default is true for both.
http_enabled: true
transport_enabled: true
#
# For HTTP it is possible to allow anonymous authentication. If that is the case then the HTTP authenticators try to
# find user credentials in the HTTP request. If credentials are found then the user gets regularly authenticated.
# If none can be found the user will be authenticated as an "anonymous" user. This user has always the username "anonymous"
# and one role named "anonymous_backendrole".
# If you enable anonymous authentication all HTTP authenticators will not challenge.
#
#
# Note: If you define more than one HTTP authenticators make sure to put non-challenging authenticators like "proxy" or "clientcert"
# first and the challenging one last.
# Because it's not possible to challenge a client with two different authentication methods (for example
# Kerberos and Basic) only one can have the challenge flag set to true. You can cope with this situation
# by using pre-authentication, e.g. sending a HTTP Basic authentication header in the request.
#
# Default value of the challenge flag is true.
#
#
# HTTP
#   basic (challenging)
#   proxy (not challenging, needs xff)
#   kerberos (challenging)
#   clientcert (not challenging, needs https)
#   jwt (not challenging)
#   host (not challenging) #DEPRECATED, will be removed in a future version.
#                          host based authentication is configurable in roles_mapping

# Authc
#   internal
#   noop
#   ldap

# Authz
#   ldap
#   noop



_meta:
  type: "config"
  config_version: 2

config:
  dynamic:
    # Set filtered_alias_mode to 'disallow' to forbid more than 2 filtered aliases per index
    # Set filtered_alias_mode to 'warn' to allow more than 2 filtered aliases per index but warns about it (default)
    # Set filtered_alias_mode to 'nowarn' to allow more than 2 filtered aliases per index silently
    #filtered_alias_mode: warn
    #do_not_fail_on_forbidden: false
    #kibana:
    # Kibana multitenancy
    #multitenancy_enabled: true
    #server_username: kibanaserver
    #index: '.kibana'
    http:
      anonymous_auth_enabled: false
      xff:
        enabled: false
    authc:
      basic_internal_auth_domain:
        description: "Authenticate via HTTP Basic against internal users database"
        http_enabled: true
        transport_enabled: true
        order: 1
        http_authenticator:
          type: basic
          challenge: true
        authentication_backend:
          type: intern
      clientcert_auth_domain:
        description: "Authenticate via SSL client certificates"
        http_enabled: true
        transport_enabled: false
        order: 2
        http_authenticator:
          type: clientcert
          config:
            username_attribute: cn #optional, if omitted DN becomes username
          challenge: false
        authentication_backend:
          type: noop
      ldap:
        description: "Authenticate via LDAP or Active Directory"
        http_enabled: true
        transport_enabled: false
        order: 5
        http_authenticator:
          type: basic
          challenge: false
        authentication_backend:
          # LDAP authentication backend (authenticate users against a LDAP or Active Directory)
          type: ldap
          config:
            # enable ldaps
            enable_ssl: false
            # enable start tls, enable_ssl should be false
            enable_start_tls: false
            # send client certificate
            enable_ssl_client_auth: false
            # verify ldap hostname
            verify_hostnames: true
            hosts:
            - {{ .Values.global.ldap.host }}:{{ .Values.global.ldap.port }}
            bind_dn: {{ .Values.global.ldap.bind_dn }},{{ .Values.global.ldap.suffix }}
            password: {{ .Values.global.ldap.password }}
            userbase: '{{ .Values.global.ldap.userdomain }}'
            # Filter to search for users (currently in the whole subtree beneath userbase)
            # {0} is substituted with the username
            usersearch: '(sAMAccountName={0})'
            # Use this attribute from the user as username (if not set then DN is used)
            username_attribute: null
    authz:
      roles_ldap:
        description: "Authorize via LDAP or Active Directory"
        http_enabled: true
        transport_enabled: false
        authorization_backend:
          # LDAP authorization backend (gather roles from a LDAP or Active Directory, you have to configure the above LDAP authentication backend settings too)
          type: ldap
          config:
            # enable ldaps
            enable_ssl: true
            # enable start tls, enable_ssl should be false
            enable_start_tls: false
            # send client certificate
            enable_ssl_client_auth: true
            # verify ldap hostname
            verify_hostnames: false
            hosts:
            - {{ .Values.global.ldap.host }}:{{ .Values.global.ldap.port }}
            bind_dn: {{.Values.global.ldap.bind_dn}},{{ .Values.global.ldap.suffix }}
            password: {{ .Values.global.ldap.password }}
            rolebase: '{{ .Values.global.ldap.group_search_base_dns }},{{ .Values.global.ldap.suffix }}'
            # Filter to search for roles (currently in the whole subtree beneath rolebase)
            # {0} is substituted with the DN of the user
            # {1} is substituted with the username
            # {2} is substituted with an attribute value from user's directory entry, of the authenticated user. Use userroleattribute to specify the name of the attribute
            rolesearch: '(member={0})'
            # Specify the name of the attribute which value should be substituted with {2} above
            userroleattribute: null
            # Roles as an attribute of the user entry
            userrolename: disabled
            #userrolename: memberOf
            # The attribute in a role entry containing the name of that role, Default is "name".
            # Can also be "dn" to use the full DN as rolename.
            rolename: cn
            # Resolve nested roles transitive (roles which are members of other roles and so on ...)
            resolve_nested_roles: true
            userbase: 'ou=people,dc=example,dc=com'
            # Filter to search for users (currently in the whole subtree beneath userbase)
            # {0} is substituted with the username
            usersearch: '(uid={0})'
            # Skip users matching a user name, a wildcard or a regex pattern
            #skip_users:
            #  - 'cn=Michael Jackson,ou*people,o=TEST'
            #  - '/\S*/'
  #    auth_failure_listeners:
  #      ip_rate_limiting:
  #        type: ip
  #        allowed_tries: 10
  #        time_window_seconds: 3600
  #        block_expiry_seconds: 600
  #        max_blocked_clients: 100000
  #        max_tracked_clients: 100000
  #      internal_authentication_backend_limiting:
  #        type: username
  #        authentication_backend: intern
  #        allowed_tries: 10
  #        time_window_seconds: 3600
  #        block_expiry_seconds: 600
  #        max_blocked_clients: 100000
  #        max_tracked_clients: 100000
