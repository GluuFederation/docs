#! /bin/bash
git pull origin alpha
echo -n "Enter task Performed >"
read text
echo "Entered Task: $text"
git add -A
git commit -m "updated site & - $text"
git push origin alpha
