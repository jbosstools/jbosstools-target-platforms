#!/bin/bash
# Hudson creates a repo in ${sourceFolder} (in the job workspace); copy it into other places for access by downstream jobs and users

# must set -version if we can't deduce it from the JOB_NAME

# set defaults
include="*"
exclude="--exclude '.blobstore'" # exclude the .blobstore
INTERNALDESTROOT=/home/hudson/static_build_env/jbds/targetplatforms

# set jbosstools defaults
projectName='jbosstools'
DESTINATIONROOT=tools@filemgmt.jboss.org:/downloads_htdocs/tools/targetplatforms
# or, if the JOB_NAME contains devstudio, use devstudio defaults 
if [[ ${JOB_NAME} ]] && [[ ${JOB_NAME##*devstudio*} != ${JOB_NAME} ]]; then
	projectName='jbdevstudio'
	DESTINATIONROOT=/qa/services/http/binaries/RHDS/targetplatforms
fi

version="";
# must set -version if we can't deduce it from the JOB_NAME
if [[ ${JOB_NAME} ]] && [[ ${JOB_NAME##*-target-platform-*} != ${JOB_NAME} ]]; then
	version=${JOB_NAME##*-target-platform-}
fi
if [[ ${JOB_NAME} ]] && [[ ${JOB_NAME##*targetplatform-*} != ${JOB_NAME} ]]; then
	version=${JOB_NAME##*targetplatform-}
fi

while [ "$#" -gt 0 ]; do
	case $1 in
		'-version')
			version="$2"
			shift 2;;

		'-jbdevstudio')
			projectName='jbdevstudio'
			# to publish JBDS files to www.qa.jboss.com/binaries/RHDS/targetplatforms/, copy files here
			DESTINATIONROOT=/qa/services/http/binaries/RHDS/targetplatforms
			shift 1;;

		*)
			echo "Unknown parameter " $1
			exit 1;;
	esac
done

if [[ ! ${version} ]]; then
	echo "version not set. Must define version, eg., $0 -version 4.30.0.Final -jbdevstudio"
	exit 1
fi

# source target platform site from workspace
sourceFolder=${WORKSPACE}/${projectName}/multiple/target/${projectName}-multiple.target.repo

# eg., jbosstoolstarget-4.30.0.Final.zip
targetZipFile=${projectName}target-${version}.zip 

# publish to this location on download.jboss.org or www.qa.jboss.com, eg., tools@filemgmt.jboss.org:/downloads_htdocs/tools/targetplatforms/jbosstoolstarget/4.30.0.Final
DESTINATION=${DESTINATIONROOT}/${projectName}target/${version}

# keep a copy internally and ref that in downstream builds via hudson-settings.xml, eg., /home/hudson/static_build_env/jbds/targetplatforms/jbdevstudio/4.30.0.Final
INTERNALDEST=${INTERNALDESTROOT}/${projectName}target/${version}

if [[ -d ${sourceFolder} ]]; then
	cd ${sourceFolder}

	if [[ ! -d ${INTERNALDEST} ]]; then
		mkdir -p ${INTERNALDEST}
	fi
	du -sh ${sourceFolder} ${INTERNALDEST}

	# JBDS-2380 massage content.jar to remove all external 3rd party references: target platform site should be self contained
	wget --no-check-certificate https://raw.github.com/jbosstools/jbosstools-download.jboss.org/master/jbosstools/updates/requirements/remove.references.xml
	ant -f remove.references.xml -DworkDir=`pwd` 
	rm -f remove.references.xml

	# copy/update into central place for reuse by local downstream build jobs
	date; rsync -arzqc --protocol=28 --delete-after --delete-excluded --rsh=ssh ${exclude} ${include} ${INTERNALDEST}/REPO/

	du -sh ${sourceFolder} ${INTERNALDEST}

	# upload to http://download.jboss.org/jbossotools/targetplatforms/jbosstoolstarget/4.30.0.Final/REPO/ for public use
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
	date; rsync -arzqc --protocol=28 --delete-after --delete-excluded --rsh=ssh ${exclude} ${include} ${DESTINATION}/REPO/

	tempDir=`mktemp -d -t ${targetZipFile}.XXXXXXXX`; mkdir -p ${tempDir}
	# create zip, then upload to http://download.jboss.org/jbossotools/updates/target-platform_3.3.indigo/${targetZipFile} for public use
	targetZip=${tempDir}/${targetZipFile}
	zip -q -r9 ${targetZip} ${include}
	du -sh ${targetZip}
	# generate MD5 sum for zip (file contains only the hash, not the hash + filename)
	for m in $(md5sum ${targetZip}); do if [[ $m != ${targetZip} ]]; then echo $m > ${targetZip}.MD5; fi; done
	# generate compositeContent.xml and compositeArtifacts.xml to make this URL a link to /REPO with p2
	timestamp=$(date +%s0000)
	echo "<?compositeMetadataRepository version='1.0.0'?>
<repository name='JBoss Tools Target Platform Site' type='org.eclipse.equinox.internal.p2.metadata.repository.CompositeMetadataRepository' version='1.0.0'>
  <properties size='2'>
    <property name='p2.compressed' value='true'/>
    <property name='p2.timestamp' value=\"${timestamp}\"/>
  </properties>
  <children size='1'>
    <child location='REPO/'/>
  </children>
</repository>" > ${tempDir}/compositeContent.xml
	echo "<?compositeArtifactRepository version='1.0.0'?>
<repository name='JBoss Tools Target Platform Site' type='org.eclipse.equinox.internal.p2.artifact.repository.CompositeArtifactRepository' version='1.0.0'>
  <properties size='2'>
    <property name='p2.compressed' value='true'/>
    <property name='p2.timestamp' value=\"${timestamp}\"/>
  </properties>
  <children size='1'>
    <child location='REPO/'/>
  </children>
</repository>" > ${tempDir}/compositeArtifacts.xml

	date; rsync -arzq --protocol=28 --rsh=ssh ${tempDir}/* ${DESTINATION}/
	rm -fr ${tempDir}
else
	echo "sourceFolder ${sourceFolder} not found or not a directory! Must exit!"
	exit 1;
fi
