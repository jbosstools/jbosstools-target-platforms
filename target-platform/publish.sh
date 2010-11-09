#!/bin/bash
# Hudson creates a repo in ${repoPath}; copy it into other places for access by downstream jobs and users

# defaults for JBoss Tools
targetFile=e361-wtp322.target
repoPath=/home/hudson/static_build_env/jbds/tools/sources/REPO
destinationPath=/home/hudson/static_build_env/jbds/target-platform
DESTINATION=tools@filemgmt.jboss.org:/downloads_htdocs/tools/updates/target-platform

while [ "$#" -gt 0 ]; do
	case $1 in
		'-targetFile') targetFile="$2"; shift 2;;
		'-repoPath') repoPath="$2"; shift 2;;
		'-destinationPath') destinationPath="$2"; shift 2;;
		'-DESTINATION') DESTINATION="$2"; shift 2;;
		'-jbds') 
		# defaults for JBDS
		targetFile=jbds400-e361-wtp322.target
		repoPath=/home/hudson/static_build_env/jbds/tools/sources/JBDS-REPO
		destinationPath=/home/hudson/static_build_env/jbds/jbds-target-platform
		DESTINATION=/qa/services/http/binaries/RHDS/updates/jbds-target-platform
		shift 1;;
	esac
done

if [[ -d ${repoPath} ]]; then
	cd ${repoPath}

	du -sh ${repoPath} ${destinationPath}/${targetFile}

	# copy/update into central place for reuse by local downstream build jobs
	date; rsync -arzqc --delete-after --delete-excluded --rsh=ssh --exclude '.blobstore' * ${destinationPath}/${targetFile}/

	du -sh ${repoPath} ${destinationPath}/${targetFile}

	# upload to http://download.jboss.org/jbossotools/updates/target-platform/latest/ for public use
	date; rsync -arzqc --delete-after --delete-excluded --rsh=ssh --exclude '.blobstore' * ${DESTINATION}/latest/

	# create zip, then upload to http://download.jboss.org/jbossotools/updates/target-platform/${targetFile}.zip for public use
	zip -q -r9 /tmp/${targetFile}.zip *
	du -sh /tmp/${targetFile}.zip
	date; rsync -arzq --rsh=ssh /tmp/${targetFile}.zip ${DESTINATION}/ 
	rm -f /tmp/${targetFile}.zip
fi
