{ lib, config, ... }:
with lib;
let
  cfg = config.programs.hmd;
in
{
  ###### interface
  options = {
    programs.hmd = {
      enable = mkEnableOption "Home-Manager Diff";

      package = mkOption {
        type = types.package;
        description = "HMD package to use";
      };

      runOnSwitch = mkEnableOption "Run HMD on home-manage switch" // { default = true; };
    };
  };


  ###### implementation
  config = mkIf cfg.enable {
    home = mkMerge [
      { packages = [ cfg.package ]; }
      (mkIf cfg.runOnSwitch {
        activation.hmd = hm.dag.entryAfter [ "linkGeneration" ] ''
          $VERBOSE_ECHO "Home Manager Generations Diff"
          $DRY_RUN_CMD ${getExe cfg.package} --auto
        '';
      })
    ];
  };
}
