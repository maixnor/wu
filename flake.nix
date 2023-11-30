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
					rPackages.pagedown 
					rPackages.recommenderlab
					rPackages.ggplot2
					rPackages.dplyr
					rPackages.xts
					rPackages.purrr
					rPackages.rmarkdown
					rPackages.knitr
					rPackages.vioplot
					rPackages.RDocumentation
					rPackages.IRkernel
					rPackages.emdbook
					rPackages.rgl
					#vscode
					chromium 
					pandoc
					python311Packages.jupyter
					texlive.combined.scheme-full
					kile
					bat
					okular
					just
				];
       };
    });
}
