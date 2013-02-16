#!/usr/bin/env bash
###Functions
die () {
   #Reedirect stdout to stderr
   echo "$@" 1>&2
   #exit in an error state, which will cause Jenkins to report the error
   exit 1
   }

copy_to_target () {
   echo "cp $WORKSPACE/$1 $webdirectory/$1"
   cp $WORKSPACE/$1 $webdirectory/$1
   }

###Variables
#a list containing the output formats
filetypelist="pdf docx epub"
#web-directory
webdirectory="/var/www/html/"


###Program
#change the filename because pandoc chokes on special characters.
mv Will_Albenzi*.md Albenzi.md

#Version the files
cat Will_Albenzi_Résumé.md | sed -e s/JENKINS_BUILD_NUMBER/$BUILD_NUMBER/ > Will_Albenzi_Résumé.md.new
mv Will_Albenzi_Résumé.md.new Will_Albenzi_Résumé.md

#TODO: Add link to where each of the files will be after the build

#Do the conversions.  This requires pandoc and a bunch of latex libraries.
pandoc Albenzi.md -o index.html
for filetype in $filetypelist; do
   echo "pandoc Albenzi.md -o Albenzi.$filetype"
   pandoc Albenzi.md -o Albenzi.$filetype
done

#Testing.
#If the Linux Systems Architect position is not listed, do not copy to live website.
if ! grep "<p><strong>Linux Systems Architect" index.html; then
   die "We are missing an element that is required in index.html  The whole thing is suspect.  Do nothing more."
fi

if grep "JENKINS_BUILD_NUMBER" index.html; then
   die "We failed to substitute the build number properly in the file.  No copying"
fi

#Copy the files to a location they can be used.
copy_to_target "index.html"
for filetype in $filetypelist; do
   copy_to_target "Albenzi.$filetype"
done
