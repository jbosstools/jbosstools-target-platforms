# The JBoss Tools Target Platforms project


## Summary

JBoss Tools Target Platforms project provides the JBoss Tools Eclipse-based target platforrms used by JBoss Tools projects.

The 'master' branch only contains shared content - see the 4.x branches for the actual target platform definitions. To build them, simply run 'mvn verify' in a given target platform folder.


## Get the code

The easiest way to get started with the code is to [create your own fork](http://help.github.com/forking/), 
and then clone your fork:

    $ git clone git@github.com:<you>/jbosstools-target-platforms.git
    $ cd jbosstools-build
    $ git remote add upstream git://github.com/jbosstools/jbosstools-target-platforms.git
	
At any time, you can pull changes from the upstream and merge them onto your 4.40.x branch:

    $ git checkout 4.40.x               # switches to the '4.40.x' branch
    $ git pull upstream 4.40.x          # fetches all 'upstream' changes and merges 'upstream/4.40.x' onto your '4.40.x' branch
    $ git push origin                  # pushes all the updates to your fork, which should be in-sync with 'upstream'

The general idea is to keep your '4.40.x' branch in-sync with the
'upstream/4.40.x'.


## Building JBoss Tools Target Platforms

To build _JBoss Tools Target Platforms_ requires specific versions of Java and
Maven. Also, there is some Maven setup. The [How to Build JBoss Tools with Maven 3](https://community.jboss.org/wiki/HowToBuildJBossToolsWithMaven3)
document will guide you through that setup.

This command will run the build:

    $ mvn clean verify

If you want to run the build and fetch source bundles at the same time as other bundles are being resolved, do this:

    $ mvn clean verify -Dmirror-target-to-repo.includeSources=true

If you want to run the build and not fail if there's a problem w/ validation, do this:

    $ mvn clean verify -Dvalidate-target-platform.failOnError=false

If you just want to check if things compiles/builds you can run:

    $ mvn clean verify -DskipTest=true

But *do not* push changes without having the new and existing unit tests pass!
 

## Updating versions of IUs in .target files

When moving from one version of the target to another, the steps are:

0. Bump the target platform versions contained in all 5 pom.xml and 2 *.target files.

1. Update the URLs contained in jbosstools-multiple.target and jbdevstudio-multiple.target (by hand). Check in changes (but do not push to master).

2. Regenerate the IU versions, using <a href="https://github.com/jbosstools/jbosstools-maven-plugins/wiki">org.jboss.tools.tycho-plugins:target-platform-utils</a>, and validate results

<pre>

    # point BASEDIR to where you have these sources checked out
    BASEDIR=$HOME/jbosstools-target-platforms; # or, just do this:
    BASEDIR=`pwd`
    for PROJECT in jbosstools jbdevstudio; do 
      # Merge changes in new target file to actual target file
      pushd ${BASEDIR}/${PROJECT}/multiple && mvn -U org.jboss.tools.tycho-plugins:target-platform-utils:0.19.0-SNAPSHOT:fix-versions -DtargetFile=${PROJECT}-multiple.target && rm -f ${PROJECT}-multiple.target ${PROJECT}-multiple.target_update_hints.txt && mv -f ${PROJECT}-multiple.target_fixedVersion.target ${PROJECT}-multiple.target && popd
      # Resolve the new 'multiple' target platform and verify it is self-contained by building the 'unified' target platform too
      pushd ${BASEDIR}/${PROJECT} && mvn -U install -DtargetRepositoryUrl=file://${BASEDIR}/${PROJECT}/multiple/target/${PROJECT}-multiple.target.repo/ && popd
    done

</pre>

<ol><li value="4"> Check in updated target files & push to master.</li></ol>


## Contribute fixes and features

_JBoss Tools Target Platforms_ is open source, and we welcome anybody that wants to
participate and contribute!

If you want to fix a bug or make any changes, please log an issue in
the [JBoss Tools JIRA](https://issues.jboss.org/browse/JBIDE)
describing the bug or new feature and give it a component type of
`build`. Then we highly recommend making the changes on a
topic branch named with the JIRA issue number. For example, this
command creates a branch for the JBIDE-1234 issue:

	$ git checkout -b jbide-1234

After you're happy with your changes and a full build (with unit
tests) runs successfully, commit your changes on your topic branch
(with good comments). Then it's time to check for any recent changes
that were made in the official repository:

	$ git checkout 4.40.x               # switches to the '4.40.x' branch
	$ git pull upstream 4.40.x          # fetches all 'upstream' changes and merges 'upstream/4.40.x' onto your '4.40.x' branch
	$ git checkout jbide-1234           # switches to your topic branch
	$ git rebase 4.40.x                 # reapplies your changes on top of the latest in 4.40.x
	                                      (i.e., the latest from 4.40.x will be the new base for your changes)

If the pull grabbed a lot of changes, you should rerun your build with
tests enabled to make sure your changes are still good.

You can then push your topic branch and its changes into your public fork repository:

	$ git push origin jbide-1234         # pushes your topic branch into your public fork of JBoss Tools Target Platforms

And then [generate a pull-request](http://help.github.com/pull-requests/) where we can
review the proposed changes, comment on them, discuss them with you,
and if everything is good merge the changes right into the official
repository.
