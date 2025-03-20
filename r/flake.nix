{
    description = "Monorepo for R projects";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system: let
        pkgs = import nixpkgs { inherit system; };
    in {
        devShells.default = pkgs.stdenv.mkDerivation {
            name = "build-rmds";
            src = ./.;
            buildInputs = with pkgs; [ 
                rPackages.rmarkdown 
                rPackages.extraDistr
                rPackages.dplyr
                rPackages.ggplot2
                rPackages.ggthemes
                rPackages.psych
                rPackages.corrplot
                rPackages.Hmisc
                rPackages.apaTables
                rPackages.nFactors
                rPackages.qgraph
                rPackages.xts
                rPackages.lubridate
                rPackages.tidyverse
                rPackages.viridisLite
                rPackages.Benchmarking
            ];
        };
    });
}
