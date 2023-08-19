# Home Manager Diff

Home Manager Diff (`hmd`) is a wrapper around [nvd](https://gitlab.com/khumba/nvd), that simplifies the process of comparing different Home-Manager generations.
It also provides an `activation` script that runs `hmd` during `home-manager switch`, showing the differences between the latest and current generations.

## Installation

In your `flake.nix`:

```nix

{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager-diff.url = "github:pedorich-n/home-manager-diff";
  };

  outputs = { self, nixpkgs, home-manager, home-manager-diff }: {
    homeConfigurations.example = home-manager.lib.homeManagerConfiguration {
        ...
        modules = [
            home-manager-diff.hmModule
            ./configuration.nix
        ];
    };
  };
}

```

`configuration.nix`:

```nix

{...}: {
    programs.hmd = {
      enable = true;
      runOnSwitch = true; # enabled by default
    };
}

```

## Usage

After the installation, simply run `home-manager switch` as usual. HMD will automatically show the differences between the latest and current generations.

You can also run `hmd` from CLI to compare any two Home-Manager generations.
