== HOWTO: Download the contents of a .target file to a local p2 repo on disk ==

1. If not available in JBoss Nexus, build the multiple.target locally:

	cd jbosstools-JunoSR0b/multiple; mvn install 
	
2. Fetch the contents of multiple.target to a local folder on your disk. repoDir default value is local/target/REPO, but you can set a different path if you prefer:

	cd jbosstools-JunoSR0b/local;    mvn install -P get.local.target -DrepoDir=/path/to/where/you/want/your/repo

This will get you a copy of contents of multiple.target (retrieved thanks to target2p2mirror script) and will generate
a local.target (thanks to multiple2local.xsl) which is the same target platform but pointed at your local disk. 

Remember that if the .target file changes you need to rebuild to fetch new content.

----

For convenience you can use profiles from the root pom.xml.

To build JBT/JBDS target platforms with Juno SR0 (should not change unless we need to add a new GWT requirement (?)):

	mvn install -P jbdevstudio-stable 
	mvn install -P jbosstools-stable

To build JBT/JBDS target platforms with Juno SRx (moves forward when there's a new release):

	mvn install -P jbdevstudio-latest
	mvn install -P jbosstools-latest

