#!/bin/bash
# Hudson creates a repo in ${repoPath}; copy it into other places for access by downstream jobs and users

# defaults for JBoss Tools
targetFile=e361-wtp322.target
repoPath=/home/hudson/static_build_env/jbds/tools/sources/REPO
destinationPath=/home/hudson/static_build_env/jbds/target-platform
DESTINATION=tools@filemgmt.jboss.org:/downloads_htdocs/tools/updates/target-platform
include="*"
exclude="--exclude '.blobstore'" # exclude the .blobstore

while [ "$#" -gt 0 ]; do
	case $1 in
		'-targetFile') targetFile="$2"; shift 2;;
		'-repoPath') repoPath="$2"; shift 2;;
		'-destinationPath') destinationPath="$2"; shift 2;;
		'-DESTINATION') DESTINATION="$2"; shift 2;;
		'-include') include="$2"; shift 2;;
		'-exclude') exclude="$2"; shift 2;;
		'-jbds') 
		# defaults for JBDS
		targetFile=jbds400-e361-wtp322.target
		repoPath=/home/hudson/static_build_env/jbds/tools/sources/JBDS-REPO
		destinationPath=/home/hudson/static_build_env/jbds/jbds-target-platform
		DESTINATION=/qa/services/http/binaries/RHDS/updates/jbds-target-platform
		include=".blobstore *" # include the .blobstore
		exclude="" 
		shift 1;;
	esac
done

if [[ -d ${repoPath} ]]; then
	cd ${repoPath}

	if [[ ! -d ${destinationPath}/${targetFile} ]]; then 
		mkdir -p ${destinationPath}/${targetFile}
	fi
	du -sh ${repoPath} ${destinationPath}/${targetFile}

	# copy/update into central place for reuse by local downstream build jobs
	date; rsync -arzqc --delete-after --delete-excluded --rsh=ssh ${exclude} ${include} ${destinationPath}/${targetFile}/

	du -sh ${repoPath} ${destinationPath}/${targetFile}

	# upload to http://download.jboss.org/jbossotools/updates/target-platform/latest/ for public use
	if [[ ${DESTINATION/@/} == ${DESTINATION} ]]; then # local path, no user@server
		mkdir -p ${DESTINATION}/
	fi
	# if the following line fails, make sure that ${DESTINATION} is already created on target server
	date; rsync -arzqc --delete-after --delete-excluded --rsh=ssh ${exclude} ${include} ${DESTINATION}/latest/

	targetZip=/tmp/${targetFile}.zip

	# create zip, then upload to http://download.jboss.org/jbossotools/updates/target-platform/${targetFile}.zip for public use
	zip -q -r9 ${targetZip} *
	du -sh ${targetZip}

	# generate MD5 sum for zip (file contains only the hash, not the hash + filename)
	for m in $(md5sum ${targetZip}); do if [[ $m != ${targetZip} ]]; then echo $m > ${targetZip}.MD5; fi; done

	date; rsync -arzq --rsh=ssh ${targetZip} ${targetZip}.MD5 ${DESTINATION}/ 
	rm -f ${targetZip} ${targetZip}.MD5
fi
