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


== Updating an existing .target file from newer versions of IUs in a repo ==

1. Run targetUpdateFromRepo.xml against a given repo folder on disk, eg.

ant -v -f targetUpdateFromRepo.xml -DtargetFile=e361-wtp322.target -DrepoDir=./REPO_SR1

2. Resulting targetFile will be overwritten with updated version values from what was found in the 
   repo's content.xml file.


== Installing the contents of a repo into Eclipse (via script) ==

1. See ../installation/README.txt

