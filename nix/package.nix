{ lib, pkgs }:
pkgs.poetry2nix.mkPoetryApplication {
  projectDir = ./..;
  checkGroups = [ ]; # To omit dev dependencies

  meta.mainProgram = "hmd";

  nativeBuildInputs = [ pkgs.makeWrapper ];
  propagatedBuildInputs = [ pkgs.nvd ];

  preFixup = ''
    wrapProgram $out/bin/hmd \
      --prefix PATH : ${lib.makeBinPath [ pkgs.nvd ]}
  '';
}
