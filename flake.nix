{
  description = "Application packaged using poetry2nix";

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

    perSystem = { config, inputs', pkgs, system, ... }: {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ inputs.poetry2nix.overlay ];
      };

      packages = {
        default = pkgs.callPackage ./nix/package.nix { };
      };

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
        projectRootFile = "flake.nix";
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

          prettier.includes = [
            "*.md"
          ];
        };
      };

      pre-commit.settings = {
        settings.treefmt.package = config.treefmt.build.wrapper;

        hooks = {
          deadnix.enable = true;
          statix.enable = true;

          treefmt.enable = true;
        };
      };
    };

    flake = {
      hmModule.default = import ./nix/hm-module.nix;
    };
  };
}
