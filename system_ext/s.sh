find . -type f -size +50M | while read -r file; do git lfs track "$file"
done
