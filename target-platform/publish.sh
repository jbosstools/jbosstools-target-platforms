#!/bin/bash
# Hudson creates a repo in ${repoPath}
# So, copy it into other places for access by downstream jobs and others

repoPath=/home/hudson/static_build_env/jbds/tools/sources/REPO
targetFile=e361-wtp322.target
DESTINATION=tools@filemgmt.jboss.org:/downloads_htdocs/tools/updates/target-platform
LOCALDESTNN=/home/hudson/static_build_env/jbds/target-platform

if [[ -d ${repoPath} ]]; then
	# copy/update into central place for reuse by local downstream build jobs
	rsync -aPrz --delete ${repoPath}/* ${LOCALDESTNN}/${targetFile}/

	# upload to http://download.jboss.org/jbossotools/updates/target-platform/latest/ for public use
	rsync -aPrz --delete --rsh=ssh ${repoPath}/* ${DESTINATION}/latest/ &

	# create zip, then upload to http://download.jboss.org/jbossotools/updates/target-platform/${targetFile}.zip for public use
	cd ${repoPath} && \
	zip -q -r9 ../${targetFile}.zip * && \
	rsync -aPrz --delete --rsh=ssh ${repoPath}/../${targetFile}.zip ${DESTINATION}/ && \
	rm -f ${repoPath}/../${targetFile}.zip
fi
