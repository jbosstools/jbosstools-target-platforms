#!/bin/bash
# Hudson creates a repo in ${repoDir}; copy it into other places for access by downstream jobs and users

# defaults for JBoss Tools
# don't forget to increment these files when moving up a version:
# build.xml, *.target*, publish.sh, target2p2mirror.xml; also jbds/trunk/releng/org.jboss.ide.eclipse.releng/requirements/jbds-target-platform/build.properties;
# also all devstudio-6.0_*.updatesite jobs (4) need to be pointed at the new Target Platform URL
targetZipFile=e421RC2-wtp341M.target
repoDir=/home/hudson/static_build_env/jbds/tools/sources/REPO_4.0.juno.SR0a
destinationPath=/home/hudson/static_build_env/jbds/target-platform_4.0.juno.SR0a
DESTINATION=tools@filemgmt.jboss.org:/downloads_htdocs/tools/updates/target-platform_4.0.juno.SR0a
include="*"
exclude="--exclude '.blobstore'" # exclude the .blobstore

while [ "$#" -gt 0 ]; do
	case $1 in
		'-targetFile') targetZipFile="$2"; shift 2;; # old flag name (collision with build.xml's ${targetFile}, which points to a .target file)
		'-targetZipFile') targetZipFile="$2"; shift 2;;
		'-repoPath') repoDir="$2"; shift 2;; # old flag name (refactored to match build.xml's ${repoDir})
		'-repoDir') repoDir="$2"; shift 2;;
		'-destinationPath') destinationPath="$2"; shift 2;;
		'-DESTINATION') DESTINATION="$2"; shift 2;;
		'-include') include="$2"; shift 2;;
		'-exclude') exclude="$2"; shift 2;;

		'-jbt_4.0.juno.SR0a') 
		# defaults for JBT (trunk)
		targetZipFile=e421RC2-wtp341M.target
		repoDir=/home/hudson/static_build_env/jbds/tools/sources/REPO_4.0.juno.SR0a
		destinationPath=/home/hudson/static_build_env/jbds/target-platform_4.0.juno.SR0a
		DESTINATION=tools@filemgmt.jboss.org:/downloads_htdocs/tools/updates/target-platform_4.0.juno.SR0a
		include="*"
		exclude="--exclude '.blobstore'" # exclude the .blobstore
		shift 1;;

		'-jbds_4.0.juno.SR0a') 
		# defaults for JBDS (trunk)
		targetZipFile=jbds600-e421RC2-wtp341M.target
		repoDir=/home/hudson/static_build_env/jbds/tools/sources/JBDS-REPO_4.0.juno.SR0a
		destinationPath=/home/hudson/static_build_env/jbds/jbds-target-platform_4.0.juno.SR0a
		DESTINATION=/qa/services/http/binaries/RHDS/updates/jbds-target-platform_4.0.juno.SR0a
		include=".blobstore *" # include the .blobstore
		exclude="" 
		shift 1;;		
	esac
done

if [[ -d ${repoDir} ]]; then
	cd ${repoDir}

	if [[ ! -d ${destinationPath}/${targetZipFile} ]]; then 
		mkdir -p ${destinationPath}/${targetZipFile}
	fi
	du -sh ${repoDir} ${destinationPath}/${targetZipFile}

	# copy/update into central place for reuse by local downstream build jobs
	date; rsync -arzqc --protocol=28 --delete-after --delete-excluded --rsh=ssh ${exclude} ${include} ${destinationPath}/${targetZipFile}/

	du -sh ${repoDir} ${destinationPath}/${targetZipFile}

	# upload to http://download.jboss.org/jbossotools/updates/target-platform_3.3.indigo/latest/ for public use
	if [[ ${DESTINATION/:/} == ${DESTINATION} ]]; then # local path, no user@server:/path
		mkdir -p ${DESTINATION}/
	else
		DESTPARENT=${DESTINATION%/*}; NEWFOLDER=${DESTINATION##*/}
		if [[ $(echo "ls" | sftp ${DESTPARENT} 2>&1 | grep ${NEWFOLDER}) == "" ]]; then
			# DESTHOST=${DESTINATION%:*}; DESTFOLD=${DESTINATION#*:}; echo "mkdir ${DESTFOLD}" | sftp ${DESTHOST}; # alternate approach
			echo "mkdir ${NEWFOLDER}" | sftp ${DESTPARENT}
		fi
	fi
	# if the following line fails, make sure that ${DESTINATION} is already created on target server
	date; rsync -arzqc --protocol=28 --delete-after --delete-excluded --rsh=ssh ${exclude} ${include} ${DESTINATION}/latest/

	targetZip=/tmp/${targetZipFile}.zip

	# create zip, then upload to http://download.jboss.org/jbossotools/updates/target-platform_3.3.indigo/${targetZipFile}.zip for public use
	zip -q -r9 ${targetZip} ${include}
	du -sh ${targetZip}

	# generate MD5 sum for zip (file contains only the hash, not the hash + filename)
	for m in $(md5sum ${targetZip}); do if [[ $m != ${targetZip} ]]; then echo $m > ${targetZip}.MD5; fi; done

	date; rsync -arzq --protocol=28 --rsh=ssh ${targetZip} ${targetZip}.MD5 ${DESTINATION}/ 
	rm -f ${targetZip} ${targetZip}.MD5
fi
