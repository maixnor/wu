{
  description = "A basic flake with a shell";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.default = pkgs.mkShell {
        nativeBuildInputs = [ pkgs.bashInteractive ];
        buildInputs = with pkgs; [ 
          R
					rPackages.xts
					rPackages.rmarkdown
          rPackages.tinytex
					rPackages.knitr
					rPackages.RDocumentation
					rPackages.IRkernel
					rPackages.emdbook
					rPackages.rgl
          rPackages.Hmisc
          rPackages.lubridate
          rPackages.corrplot
					rPackages.tidyverse
          rPackages.moments
				];
        shellHook = ''
          echo "It's time to R..."
        '';
       };
    });
}
