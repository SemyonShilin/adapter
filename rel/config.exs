use Mix.Releases.Config,
    # This sets the default release built by `mix release`
    default_release: :default,
    # This sets the default environment used by `mix release`
    default_environment: Mix.env

# For a full list of config options for both releases
# and environments, visit https://hexdocs.pm/distillery/configuration.html


# You may define one or more environments in this file,
# an environment's settings will override those of a release
# when building in that environment, this combination of release
# and environment configuration is called a profile

environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: :".d^jmTq>$nA2GeFj|x}us:?ru8{p4lMxYV/s!xq)o[=:,7xC!}omV25V$9a{,V*E"
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :",t,!)eEGmN`08$J5=NYr382;L{a)PTGL5R$^)7Ta02V=%;Di}C0w`h4VA.?60.X*"
  set vm_args: "rel/vm.args"
end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix release`, the first release in the file
# will be used by default

release :adapter do
  set version: current_version(:adapter)
  set applications: [
        :runtime_tools
      ]
end

