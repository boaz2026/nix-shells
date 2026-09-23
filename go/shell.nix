{
  pkgs ? import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/refs/heads/nixos-26.05.tar.gz";
  }) { },
}:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    go
    gopls
    gotools
    pkg-config
    gpgme
    libseccomp
  ];

  shellHook = ''
    # Anchor GOPATH to the project's git root rather than $PWD, so entering
    # the shell from a subdirectory doesn't create a second, separate cache.
    PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")"

    # NOTE: with Go modules (default since Go 1.16), GOPATH no longer
    # controls dependency resolution. It's used here only to localize the
    # build cache and any `go install`-ed binaries to this project.
    export GOPATH="$PROJECT_ROOT/.gopath"
    export GOCACHE="$GOPATH/cache"
    export PATH="$GOPATH/bin:$PATH"

    # Pin module/proxy behavior explicitly rather than inheriting whatever
    # is set in the user's ambient environment, for reproducibility.
    export GOFLAGS="-mod=mod"
    export GOPROXY="https://proxy.golang.org,direct"
    export GOSUMDB="sum.golang.org"

    mkdir -p "$GOPATH/bin" "$GOCACHE"
  '';
}
