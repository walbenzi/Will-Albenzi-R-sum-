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

###Initial Tests and corrections
#If we are not running on Jenkins, then $BUILD_NUMBER will not be populated.  It is probably on a dev machine for some reason.
if [[ -z $BUILD_NUMBER ]]; then
   BUILD_NUMBER=1
fi

#Check for pandoc
pandoc_location=`which pandoc`
if [[ ! -e $pandoc_location ]]; then
   die "pandoc does not seem to exist"
fi

###Program
#change the filename because pandoc chokes on special characters.
mv Will_Albenzi*.md Albenzi.md

#Version the files
cat Albenzi.md | sed -e s/JENKINS_BUILD_NUMBER/$BUILD_NUMBER/ > Albenzi.md.new
mv Albenzi.md.new Albenzi.md

#TODO: Add link to where each of the files will be after the build

#Do the conversions.  This requires pandoc and a bunch of latex libraries.
pandoc Albenzi.md -o index.html
for filetype in $filetypelist; do
   echo "pandoc Albenzi.md -o Albenzi.$filetype"
   pandoc Albenzi.md -o Albenzi.$filetype || die "There were errors building Albenzi.$filetype"
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
