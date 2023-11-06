{
  description = "Application packaged using poetry2nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    systems.url = "github:nix-systems/default";
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
    };

    flake = {
      hmModules.default = moduleWithSystem (perSystem@{ config }: { ... }: {
        imports = [ ./nix/hm-module.nix ];
        programs.hmd.package = perSystem.config.packages.hmd;
      });
    };
  });
}
