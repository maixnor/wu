{
    description = "Monorepo for R projects";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system: let
        pkgs = import nixpkgs { inherit system; };
    in {
        packages = {
            default = pkgs.mkShell { # also works as dev shell
                buildInputs = with pkgs; [
                    R
                    rPackages.rmarkdown
                    rPackages.extraDistr
                    rPackages.dplyr
                    rPackages.ggplot2
                    rPackages.psych
                    rPackages.corrplot
                    rPackages.Hmisc
                    rPackages.apaTables
                    rPackages.nFactors
                    rPackages.qgraph
                    tectonic
                    pandoc
                    inotify-tools
                    bat
                ];
            };

            markdown = pkgs.stdenv.mkDerivation {
                name = "build-rmds";
                src = ./.;
                buildInputs = with pkgs; [ 
                    R 
                    rPackages.rmarkdown 
                    rPackages.extraDistr
                    rPackages.dplyr
                    rPackages.ggplot2
                    rPackages.psych
                    rPackages.corrplot
                    rPackages.Hmisc
                    rPackages.apaTables
                    tectonic 
                    pandoc 
                ];

                buildPhase = ''
                    for file in *.Rmd; do
                        Rscript -e "rmarkdown::render('$file')"
                    done
                '';

                installPhase = ''
                    mkdir -p $out
                    cp *.pdf $out
                '';
            };
        };
    });
}
