# Home Manager Diff

Home Manager Diff (`hmd`) is a wrapper around [nvd](https://gitlab.com/khumba/nvd), that simplifies the process of comparing different Home-Manager generations.
It also provides an `activation` script that runs `hmd` during `home-manager switch`, showing the differences between the latest and current generations.

> **Warning**
> Only works with standalone Home-Manager installation at the moment.

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
            home-manager-diff.hmModules.default
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

## Demo

Here's an example what `hmd` prints out on a `home-manager switch`. In this generation `neovim` was added and `wslu` removed:

[![asciicast](https://asciinema.org/a/aWEeIIn6THrQCPsKSczd97ZXV.svg)](https://asciinema.org/a/aWEeIIn6THrQCPsKSczd97ZXV)

And here's ane example of comparing any two Home-Manager generations using `hmd`:

[![asciicast](https://asciinema.org/a/UyTKnK74mx1HWsua8GwVsj6b0.svg)](https://asciinema.org/a/UyTKnK74mx1HWsua8GwVsj6b0)
