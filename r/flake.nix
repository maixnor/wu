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
            default = pkgs.stdenv.mkDerivation {
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
                    rPackages.nFactors
                    rPackages.qgraph
                    rPackages.xts
                    rPackages.lubridate
                    rPackages.tidyverse
                    tectonic
                    pandoc 
                    inotify-tools
                    bat
                    git
                ];

                buildPhase = ''
                    for file in $(git diff --name-only @{20} | grep -E '\.R$|\.Rmd$'); do
                        Rscript -e "rmarkdown::render('$file')"
                    done
                '';

                installPhase = ''
                    mkdir -p $out
                    for file in $(find -name '*.pdf'); do
                        cp $file $out
                    done
                    echo "Done"
                '';
            };
        };
    });
}
