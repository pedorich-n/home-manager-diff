#TODO: Drop once https://github.com/arrterian/nix-env-selector/issues/53 is merged
(builtins.getFlake ("git+file://" + toString ./.)).devShells.${builtins.currentSystem}.default
