
 
if [ -z "$(which inotifywait)" ]; then
    echo "inotifywait not installed."
    exit 1
fi
 
inotifywait --recursive --monitor --format "%e %w%f" \
--event modify,move ./*.Rmd \
| while read -r changed; do
    echo "$changed"
    "$@"
done
