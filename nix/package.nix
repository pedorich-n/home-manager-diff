{ pkgs }:
pkgs.poetry2nix.mkPoetryApplication {
  projectDir = ./..;
  checkGroups = [ ]; # To omit dev dependencies

  meta.mainProgram = "hmd";

  propagatedBuildInputs = [ pkgs.nvd ];
}
