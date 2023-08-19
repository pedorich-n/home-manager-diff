#TODO: Drop once https://github.com/arrterian/nix-env-selector/issues/53 is merged
(builtins.getFlake (toString ./dev)).devShells.${builtins.currentSystem}.default
