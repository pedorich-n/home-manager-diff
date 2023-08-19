{ lib, pkgs, nvd }:
let
  poetryApp = pkgs.poetry2nix.mkPoetryApplication {
    projectDir = ./..;
    checkGroups = [ ]; # To omit dev dependencies
    meta.mainProgram = "hmd";
  };
in
pkgs.symlinkJoin {
  name = "hmd";
  paths = [ poetryApp ];
  buildInputs = [ pkgs.makeWrapper ];
  propagatedBuildInputs = [ pkgs.nvd ];
  postBuild = ''
    wrapProgram $out/bin/hmd \
      --prefix PATH : ${lib.makeBinPath [ nvd ]}
  '';
}
