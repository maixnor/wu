#!/bin/bash

select_file() {
    local file=$(find . -type f \( -name "*.R" -o -name "*.Rmd" \) | fzf)
    echo "$file"
}

compile() {
    local file=$1
    R CMD BATCH "$file"
    bat "${file}out"
}

compile_pdf() {
    local file=$1
    R CMD BATCH "$file"
    okular Rplots.pdf &
    bat "${file}out"
}

render() {
    local file=$1
    Rscript -e "rmarkdown::render('$file')"
}

watch() {
    local file=$1
    while inotifywait --event modify "$file"; do
        compile "$file"
    done
}

watch_rmd() {
    local file=$1
    while inotifywait --event modify "$file"; do
        render "$file"
    done
}

if [ -z "$1" ]; then
    file=$(select_file)
    if [[ $file == *.R ]]; then
        options=("compile" "compile-pdf" "watch")
    elif [[ $file == *.Rmd ]]; then
        options=("render" "watch-rmd")
    else
        echo "Unsupported file type."
        exit 1
    fi
    action=$(printf "%s\n" "${options[@]}" | fzf)
    set -- "$action" "$file"
fi

case $1 in
    compile)
        compile "$2"
        ;;
    compile-pdf)
        compile_pdf "$2"
        ;;
    render)
        render "$2"
        ;;
    watch)
        watch "$2"
        ;;
    watch-rmd)
        watch_rmd "$2"
        ;;
    *)
        echo "Usage: $0 {compile|compile-pdf|render|watch|watch-rmd} file"
        exit 1
        ;;
esac