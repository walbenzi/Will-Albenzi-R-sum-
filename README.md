#William Albenzi's Resume Builder
##Required Systems
github.com, web server, jenkins server, and development stations

##How it works
The jenkins server will monitor the specified github project.  When a change is detected, the jenkins server pulls a copy of the code.  The jenkins server executes "build.sh", which modifies the markdown file by versioning it.  Then build.sh runs pandoc to conver the markdown into html, pdf, docx, epub.  After these conversions build.sh runs a few tests.  The positive test requires the presence of a specific string, and the negative test is to ensure that the version string is replaced by the build process.

It the tests pass, then the files are sent to locations where they can be downloaded.  
