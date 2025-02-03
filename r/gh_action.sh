
if [ -d result ]; then
  rm -r result
fi

mkdir -p result

n=${1:-10}

echo "scanning $n last commits for Rmd files"

for file in $(git log -n $n --pretty=format:"%H" --name-only | grep 'Rmd' | sed "s/r\///"); do
  echo $file
  Rscript -e "rmarkdown::render('$file')"
  PDF=$(echo $file | sed "s/\.Rmd/.pdf/")
  echo $PDF
  cp $PDF result
done

