#!/bin/bash
DEVROOT="/mnt/d/github/"
ROOT="/mnt/d/github/REpo-all-in-one"
DIRS=("KRYPTON_LEIA" "MATRIX" "REPOSITORIES")
ZIP="$(command -v zip)"

if [ "$ZIP" = "" ]
then
    echo "zip missing. eg: apt-get install zip"
    exit 0
fi

generate_repo() {
    echo ""
        echo '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' >addons.xml
        echo '<addons>' >> addons.xml

        for name in $(find . -maxdepth 1 -type d | grep -v \.git | grep -v addons | egrep -v "^\.$" | cut -d \/ -f 2); do
                if [ -f "$name/addon.xml" ]; then
                    VERSION=$(cat $name/addon.xml | sed '/?xml/d' | sed '/<import/d' | grep version= | sed -n 1p | sed 's/.*version="\([^"]*\)"*.*/\1/g')
                    if [ ! -f "$name/$name-$VERSION.zip" ]; then
                            rm *.zip >/dev/null 2>&1
                            echo "Create: $kodibuild/$name-$VERSION.zip"
                            zip -r "$name/$name-$VERSION.zip" "$name" -x -x \*.git -x \*.psd -x \*.pyo -x \*.pyc -x \*.mo -x \*.gitignore >/dev/null 2>&1
                            echo ""
                    fi
                    find "$name" ! \( -name "addon.xml" -o -name "*.zip" -o -name "fanart.jpg" -o -name "icon.png" -o -name "screenshot*.*" \) -delete >/dev/null 2>&1
                    echo "Add: $name $VERSION"
            echo ""
            cat "$name"/addon.xml|grep -v "<?xml " >> addons.xml
                    echo "" >> addons.xml
            fi
        done

        echo "</addons>" >> addons.xml
        md5sum addons.xml > addons.xml.md5
}

echo ""
echo "░█▀▄░█▀▀░█▀█░█▀█░░░█░█░█▀█░█▀▄░█▀█░▀█▀░█▀▀░█▀▄"
echo "░█▀▄░█▀▀░█▀▀░█░█░░░█░█░█▀▀░█░█░█▀█░░█░░█▀▀░█▀▄"
echo "░▀░▀░▀▀▀░▀░░░▀▀▀░░░▀▀▀░▀░░░▀▀░░▀░▀░░▀░░▀▀▀░▀░▀"
echo ""
echo ""

if [ ! "$1" = "" ] && [ ! "$2" == "" ]
then
    read -p "Are you sure you want to copy and replace '$1'?"
    mkdir "$ROOT/$2" >/dev/null 2>&1
    rm -rf "$ROOT/$2/$1"
    rsync -av --exclude ".git" --exclude ".git*" --exclude "*.psd" "$DEVROOT/$1" "$ROOT/$2"
fi

for kodibuild in "${DIRS[@]}"; do
    echo $kodibuild
    if [ -d "$ROOT/$kodibuild" ]; then
        echo ""
        cd "$ROOT/$kodibuild"
        generate_repo
        echo "-------------------"
        echo ""
    fi
done

read -p "Press enter to push to GitHub"
cd "$ROOT"
git add .
git checkout --orphan new-master master
git commit -m "update"
git branch -M new-master master
git gc --aggressive --prune=now
git push -f
echo ""
read -p "Done. Press enter to quit"
pause
