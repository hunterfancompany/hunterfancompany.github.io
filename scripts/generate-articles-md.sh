# findfile filename option (fallback||related)
function findfile {
  local name=$1
  local option=$2
  targetfile=$(find . -type f -path "*$name/$language.json" | head -1)
  if [ -z $targetfile ]; then
    echo "Couldn't find $option option for target language."
    targetfile=$(find . -type f -path "*$name/en.json" | head -1)
  fi
  if [ -z $targetfile ]; then
    echo "Couldn't find $option option for $mdfile. Exiting..."
    exit 1
  fi
  title=$(jq -r ".title" $targetfile)
  echo -e "\n[$title](${targetfile:1})" >> $mdfile
  #    return 0
}

if which jq >/dev/null; then
  find . -type f -name "*.json" ! -name "all.json" ! -path "./.config/*" -print0 | while IFS= read -r -d '' file; do
    echo "Processing $file..."

    mdfolder="${file%.*}"
    mdfile="${mdfolder}/index.md"
    mkdir -p $mdfolder
    rm -rf $mdfile
    touch $mdfile

    echo -e "# $(jq -r ".title" $file)\n" >> $mdfile

    image=$(jq -r ".image" $file)
    if [ $image != "null" ]; then
      echo -e "![title]($image)\n" >> $mdfile
    fi

    jq -r ".description" $file >> $mdfile

    language=${mdfolder##*/}

    fallback=$(jq -r ".fallback" $file)
    if [ $fallback != "null" ]; then
      echo -e "\n$(cat articles/blocks/fallback/$language.md)" >> $mdfile
      findfile $fallback "fallback"
    fi

    related=$(jq -r ".related[]" $file | tr "\n" " ")
    if [[ $related != "" ]]; then
      echo -e "\n$(cat articles/blocks/related/$language.md)" >> $mdfile
      for article in $related; do
        findfile $related "related"
      done
    fi
  done
else
  echo "brew install jq OR apt-get install jq OR pacman -S jq --needed"
  exit 1
fi

