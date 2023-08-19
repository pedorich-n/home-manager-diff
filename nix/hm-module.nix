{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.programs.hmd;

  package = pkgs.callPackage ./package.nix { };
in
{
  ###### interface
  options = {
    programs.hmd = {
      enable = mkEnableOption "Home-Manager Diff";

      runOnSwitch = mkEnableOption "Run HMD on home-manage switch" // { default = true; };
    };
  };


  ###### implementation
  config = mkIf cfg.enable {
    home = mkMerge [
      { packages = [ package ]; }
      (mkIf cfg.runOnSwitch {
        activation.hmd = hm.dag.entryAfter [ "linkGeneration" ] ''
          $VERBOSE_ECHO "Home Manager Generations Diff"
          $DRY_RUN_CMD ${getExe package} --auto
        '';
      })
    ];
  };
}
