{
  description = "Home Manager Diff";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        flake-utils.follows = "flake-utils";
        nix-github-actions.follows = "";
        treefmt-nix.follows = "";
      };
    };
  };

  outputs = inputs@{ flake-parts, systems, ... }: flake-parts.lib.mkFlake { inherit inputs; } ({ moduleWithSystem, ... }: {
    systems = import systems;

    perSystem = { pkgs, system, config, ... }: {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ inputs.poetry2nix.overlays.default ];
      };

      packages = {
        hmd = pkgs.callPackage ./nix/package.nix { };
        default = config.packages.hmd;
      };

      devShells = {
        default = pkgs.mkShell {
          name = "home-manager-diff";
          buildInputs = [ pkgs.bashInteractive ];
          packages = with pkgs; [
            poetry
            just
          ];
        };
      };
    };

    flake = {
      hmModules.default = moduleWithSystem (perSystem@{ config }: { ... }: {
        imports = [ ./nix/hm-module.nix ];
        programs.hmd.package = perSystem.config.packages.hmd;
      });
    };
  });
}
