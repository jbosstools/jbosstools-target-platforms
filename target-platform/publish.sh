#!/bin/bash
# Hudson creates a repo in ${repoPath}; copy it into other places for access by downstream jobs and users

targetFile=e361-wtp322.target

repoPath=/home/hudson/static_build_env/jbds/tools/sources/REPO
destinationPath=/home/hudson/static_build_env/jbds/target-platform
DESTINATION=tools@filemgmt.jboss.org:/downloads_htdocs/tools/updates/target-platform

if [[ -d ${repoPath} ]]; then
	du -sh ${repoPath} ${destinationPath}/${targetFile}

	# copy/update into central place for reuse by local downstream build jobs
	date; rsync -arzq --delete ${repoPath}/* ${destinationPath}/${targetFile}/

	du -sh ${repoPath} ${destinationPath}/${targetFile}

	# upload to http://download.jboss.org/jbossotools/updates/target-platform/latest/ for public use
	date; rsync -arzq --delete --rsh=ssh ${repoPath}/* ${DESTINATION}/latest/

	# create zip, then upload to http://download.jboss.org/jbossotools/updates/target-platform/${targetFile}.zip for public use
	cd ${repoPath}
	zip -q -r9 /tmp/${targetFile}.zip *
	du -sh /tmp/${targetFile}.zip
	date; rsync -arzq --delete --rsh=ssh /tmp/${targetFile}.zip ${DESTINATION}/ 
	rm -f /tmp/${targetFile}.zip
fi
