== HOWTO: Download the contents of a .target file to a local p2 repo on disk ==

1. Run target2p2mirror.xml at a target file, eg.

	ant -f target2p2mirror.xml -DtargetFile=e361-wtp322.target

2. Run the resulting *.p2mirror.xml, eg., e361-wtp322.target.p2mirror.xml

	/abs/path/to/eclipse -vm /opt/jdk1.6.0/bin/java -nosplash -data \
		/tmp/workspace -consolelog -application \
		org.eclipse.ant.core.antRunner -f e361-wtp322.target.p2mirror.xml \
		-Ddebug=true \
		-DfollowStrict=true \
		-Drepo.dir=/tmp/REPO/

3. Resulting repo can be added to Eclipse and from there, *uncategorized* features can be installed.


== HOWTO: Publish local p2 repo (generated from .target) to download.jboss.org ==

1. Zip the repo

	cd /tmp/REPO; zip -9r e361-wtp322.target.zip * &
	
2. Push to qa01

	rsync -aPrz e361-wtp322.target.zip nboldt@qa01:~/ &

3. Ssh to qa01; sudo to hudson; unpack and push contents + zip to download.jboss.org 

	sudo su - hudson
	unzip /home/nboldt/e361-wtp322.target.zip -d /tmp/e361-wtp322.target &
	rsync -aPrz --delete --rsh=ssh /tmp/e361-wtp322.target/* \ 
		tools@filemgmt.jboss.org:/downloads_htdocs/tools/updates/target-platform/latest/ &
	rsync -aPrz --rsh=ssh /home/nboldt/e361-wtp322.target.zip \
		tools@filemgmt.jboss.org:/downloads_htdocs/tools/updates/target-platform &

4. Alternatively, see publish.sh for when repo is built in JBoss Hudson.


== HOWTO: Publish local p2 repo (generated from .target) to shared location in Hudson for use in builds ==

1. You can reference http://download.jboss.org/jbosstools/updates/target-platform/latest/, 
   but a local path reference is faster.

2. So, continuing from previous HOWTO, copy from /tmp/e361-wtp322.target into 
   file://home/hudson/static_build_env/jbds/target-platform/e361-wtp322.target/

	rsync -aPrz --delete /tmp/e361-wtp322.target/* \
		/home/hudson/static_build_env/jbds/target-platform/e361-wtp322.target/ &

3. Alternatively, see publish.sh for when repo is built in JBoss Hudson.


== HOWTO: Update an existing .target file from newer versions of IUs in a repo ==

1. Run targetUpdateFromRepo.xml against a given repo folder on disk, eg.

	ant -v -f targetUpdateFromRepo.xml -DtargetFile=e361-wtp322.target -DrepoDir=./REPO_SR1

2. Resulting targetFile will be overwritten with updated version values from what was found in the 
   repo's content.xml file.


== HOWTO: Install the contents of a repo into Eclipse (via script) ==

1. See ../installation/README.txt

