consul {
  # This block specifies the basic authentication information to pass with the
  # request. For more information on authentication, please see the Consul
  # documentation.
  auth {
    enabled  = true
    username = "test"
    password = "test"
  }

  # This is the address of the Consul agent. 
  address = "127.0.0.1:8500"

  # This is the ACL token to use when connecting to Consul.
  # This option is also available via the environment variable CONSUL_TOKEN.
  # token = "abcd1234"

  # This controls the retry behavior when an error is returned from Consul.
  # Consul Template is highly fault tolerant, meaning it does not exit in the
  # face of failure. Instead, it uses exponential back-off and retry functions
  # to wait for the cluster to become available, as is customary in distributed
  # systems.
  retry {
    enabled = true
    attempts = 5
    backoff = "250ms"
  }
}

# This is the signal to listen for to trigger a reload event. 
reload_signal = "SIGHUP"

# This is the signal to listen for to trigger a graceful stop. 
kill_signal = "SIGTERM"

# This is the maximum interval to allow "stale" data. By default, only the
# Consul leader will respond to queries; any requests to a follower will
# forward to the leader. In large clusters with many requests, this is not as
# scalable, so this option allows any follower to respond to a query, so long
# as the last-replicated data is within these bounds. Higher values result in
# less cluster load, but are more likely to have outdated data.
max_stale = "10m"

# This is the log level. 
log_level = "warn"

# This is the path to store a PID file which will contain the process ID of the
# Consul Template process.
pid_file = "/app/consul-template.pid"

# This is the quiescence timers; it defines the minimum and maximum amount of
# time to wait for the cluster to reach a consistent state before rendering a
# template. This is useful to enable in systems that have a lot of flapping,
# because it will reduce the the number of times a template is rendered.
wait {
  min = "5s"
  max = "10s"
}

vault {
  # This is the address of the Vault leader. The protocol (http(s)) portion
  # of the address is required.
  #address = "http://vault:8200"

  # This value is specified via the environment variable VAULT_TOKEN.
  #token = "test_token"

  # This tells Consul Template that the provided token is actually a wrapped
  # token that should be unwrapped using Vault's cubbyhole response wrapping
  # before being used. Please see Vault's cubbyhole response wrapping
  # documentation for more information.
  unwrap_token = false

  # This option tells Consul Template to automatically renew the Vault token
  # given.
  renew_token = true

  retry {
    enabled = true
    attempts = 5
    backoff = "250ms"
  }
}

# This block defines the configuration for connecting to a syslog server for
# logging.
syslog {
  # This enables syslog logging. Specifying any other option also enables
  # syslog logging.
  enabled = false
}

deduplicate {
  # This enables de-duplication mode. Specifying any other options also enables
  # de-duplication mode.
  enabled = false
}

# This block defines the configuration for exec mode. Please see the exec mode
# documentation at the bottom of this README for more information on how exec
# mode operates and the caveats of this mode.
exec {
  # This is the command to exec as a child process. There can be only one
  # command per Consul Template process.
  command = "/app/run.sh"

  # This is a random splay to wait before killing the command. The default
  # value is 0 (no wait), but large clusters should consider setting a splay
  # value to prevent all child processes from reloading at the same time when
  # data changes occur. When this value is set to non-zero, Consul Template
  # will wait a random period of time up to the splay value before reloading
  # or killing the child process. This can be used to prevent the thundering
  # herd problem on applications that do not gracefully reload.
  splay = "5s"

  env {
    # This specifies if the child process should not inherit the parent
    # process's environment.
    pristine = false

    # This specifies a list of environment variables to exclusively prohibit in
    # the list of environment variables exposed to the child process. If
    # specified, any environment variables matching the given patterns will not
    # be exposed to the child process, even if they are whitelisted. The values
    # in this option take precedence over the values in the whitelist.
    # These strings are matched using Go's glob function, so wildcards are
    # permitted.
    blacklist = ["VAULT_*"]
  }

  # This defines the signal that will be sent to the child process when a
  # change occurs in a watched template. The signal will only be sent after the
  # process is started, and the process will only be started after all
  # dependent templates have been rendered at least once. The default value is
  # nil, which tells Consul Template to stop the child process and spawn a new
  # one instead of sending it a signal. This is useful for legacy applications
  # or applications that cannot properly reload their configuration without a
  # full reload.
  reload_signal = ""

  # This defines the signal sent to the child process when Consul Template is
  # gracefully shutting down. The application should begin a graceful cleanup.
  # If the application does not terminate before the `kill_timeout`, it will
  # be terminated (effectively "kill -9"). The default value is "SIGTERM".
  kill_signal = "SIGTERM"

  # This defines the amount of time to wait for the child process to gracefully
  # terminate when Consul Template exits. After this specified time, the child
  # process will be force-killed (effectively "kill -9"). The default value is
  # "30s".
  kill_timeout = "10s"
}

# This block defines the configuration for a template. Unlike other blocks,
# this block may be specified multiple times to configure multiple templates.
# It is also possible to configure templates via the CLI directly.
template {
  # This is the source file on disk to use as the input template. This is often
  # called the "Consul Template template". This option is required if not using
  # the `contents` option.
  source = "/app/run.sh.ctmpl"

  # This is the destination path on disk where the source template will render.
  # If the parent directories do not exist, Consul Template will attempt to
  # create them.
  destination = "/app/run.sh"

  # This is the maximum amount of time to wait for the optional command to
  # return. Default is 30s.
  command_timeout = "60s"

  # This is the permission to render the file. If this option is left
  # unspecified, Consul Template will attempt to match the permissions of the
  # file that already exists at the destination path. If no file exists at that
  # path, the permissions are 0644.
  perms = 0755

  # This option backs up the previously rendered template at the destination
  # path before writing a new one.
  backup = false

  # These are the delimiters to use in the template. The default is "{{" and
  # "}}", but for some templates, it may be easier to use a different delimiter
  # that does not conflict with the output file itself.
  left_delimiter  = "{{"
  right_delimiter = "}}"

  # This is the `minimum(:maximum)` to wait before rendering a new template to
  # disk and triggering a command, separated by a colon (`:`). 
  # The wait value for a template takes precedence over any globally-configured
  # wait.
  wait {
    min = "2s"
    max = "10s"
  }
}
