check:
    nix flake check ./dev

fmt:
    cd ./dev; nix fmt ../

develop:
    nix develop ./dev

generate-pre-commit:
    nix develop ./dev#pre-commit