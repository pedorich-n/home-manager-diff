{ lib, pkgs }:
let
  poetryApp = pkgs.poetry2nix.mkPoetryApplication {
    projectDir = ./..;
    checkGroups = [ ]; # To omit dev dependencies
  };
in
pkgs.symlinkJoin {
  name = "${poetryApp.name}-wrapped";
  inherit (poetryApp) version;
  meta.mainProgram = "hmd";

  paths = [ poetryApp ];
  buildInputs = [ pkgs.makeWrapper ];
  propagatedBuildInputs = [ pkgs.nvd ];
  postBuild = ''
    wrapProgram $out/bin/hmd \
      --prefix PATH : ${lib.makeBinPath [ pkgs.nvd ]}
  '';
}
