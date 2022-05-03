if which jq >/dev/null; then
  find . -type f -name "*.json" ! -name "all.json" -print0 |
    while IFS= read -r -d '' file; do 
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
    done
else
  echo "brew install jq OR apt-get install jq OR pacman -S jq --needed" 
  exit 1
fi

