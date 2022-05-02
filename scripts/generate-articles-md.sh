if which jq >/dev/null; then
  find . -type f -name "*.json" ! -name "all.json" -print0 |
    while IFS= read -r -d '' file; do 
      echo "Processing $file..."
      mdfile="${file%.*}.md"
      rm -rf $mdfile
      touch $mdfile
      echo "##" >> $mdfile
      jq -r ".title" $file >> $mdfile
      jq -r ".description" $file >> $mdfile
    done
else
  echo "brew install jq OR apt-get install jq OR pacman -S jq --needed" 
  exit 1
fi

