## mix humo.new

Provides `humo.new` installer as an archive.

To install from Hex, run:

    $ mix archive.install hex humo_new

To build and install it locally,
ensure any previous archive versions are removed:

    $ mix archive.uninstall humo_new

Then run:

    $ cd installer
    $ MIX_ENV=prod mix do archive.build, archive.install
