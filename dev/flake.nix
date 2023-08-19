{
  # Inspired by https://github.com/nix-community/ethereum.nix/issues/258 & https://github.com/NixOS/nix/issues/6124

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs = inputs@{ flake-parts, systems, ... }: flake-parts.lib.mkFlake { inherit inputs; } {
    systems = import systems;
    imports = [
      inputs.treefmt-nix.flakeModule
      inputs.pre-commit-hooks.flakeModule
    ];

    perSystem = { inputs', config, pkgs, lib, ... }: {
      devShells = {
        default = pkgs.mkShell {
          name = "home-manager-diff";
          buildInputs = [ pkgs.bashInteractive ];
          packages = [
            inputs'.poetry2nix.packages.poetry
            pkgs.just
          ];
        };

        pre-commit = config.pre-commit.devShell;
      };

      treefmt.config = {
        projectRootFile = "pyproject.toml";
        flakeCheck = false;

        programs = {
          # Nix
          nixpkgs-fmt.enable = true;

          # Python
          black.enable = true;
          isort = {
            enable = true;
            profile = "black";
          };

          # Other
          prettier.enable = true;
        };
        settings.formatter = {
          black.options = [ "--line-length=120" ];
        };
      };

      pre-commit.settings = {
        rootSrc = lib.mkForce ../.;
        settings.treefmt.package = config.treefmt.build.wrapper;

        hooks = {
          deadnix.enable = true;
          statix.enable = true;

          treefmt.enable = true;
        };
      };
    };
  };
}
