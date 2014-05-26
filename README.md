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


## Building Target Platforms

To build, you require specific versions of Java and Maven. Also, there is some Maven setup. 
The [How to Build JBoss Tools with Maven 3](https://community.jboss.org/wiki/HowToBuildJBossToolsWithMaven3)
document will guide you through that setup.

This command will run the build, but will NOT download the contents of the target platform to disk:

    $ mvn clean verify

If you want to download the contents of the target platform to disk, do this:

    $ mvn clean verify -Pmultiple2repo

If you want to run the build and fetch source bundles at the same time as other bundles are being resolved, do this:

    $ mvn clean verify -Pmultiple2repo -Dmirror-target-to-repo.includeSources=true

If you want to run the build and not fail if there's a problem w/ validation, do this:

    $ mvn clean verify -Pmultiple2repo -Dvalidate-target-platform.failOnError=false

If you just want to check if things compiles/builds you can run:

    $ mvn clean verify -Pmultiple2repo -DskipTest=true

But *do not* push changes without having the new and existing unit tests pass!
 

## Updating versions of IUs in .target files

When moving from one version of the target to another, the steps are:

0. Bump the target platform versions contained in all 5 pom.xml and 2 *.target files.

1. Update the URLs contained in jbosstools-multiple.target and jbdevstudio-multiple.target (by hand). Check in changes (but do not push to master).

2. Regenerate the IU versions, using <a href="https://github.com/jbosstools/jbosstools-maven-plugins/wiki">org.jboss.tools.tycho-plugins:target-platform-utils</a>, and validate results

<pre>

    # keep these in sync + up to date:
    # https://github.com/jbosstools/jbosstools-discovery/tree/master/jbtcentraltarget#updating-versions-of-ius-in-target-files
    # https://github.com/jbosstools/jbosstools-target-platforms/tree/master/#updating-versions-of-ius-in-target-files
    # https://github.com/jbosstools/jbosstools-target-platforms/tree/4.40.x/#updating-versions-of-ius-in-target-files

    # point BASEDIR to where you have these sources checked out
    BASEDIR=$HOME/jbosstools-target-platforms; # or, just do this:
    BASEDIR=`pwd`

    # set path to where you have the latest compatible Eclipse bundle stored locally
    ECLIPSEZIP=${HOME}/tmp/Eclipse_Bundles/eclipse-jee-luna-M7-linux-gtk-x86_64.tar.gz

    # set path to where you have the latest p2diff executable installed
    P2DIFF=${HOME}/tmp/p2diff/p2diff

    NOW=`date +%F_%H-%M`

    for PROJECT in jbosstools jbdevstudio; do
      if [[ -d ${BASEDIR}/${PROJECT} ]]; then WORKSPACE=${BASEDIR}/${PROJECT}; else WORKSPACE=${BASEDIR}; fi

      # Step 0: move the existing target platform folder to a new path, so that it can be p2diff'd against the one you're about to build
      # TODO: remember to clean these out
      if [[ -d ${WORKSPACE}/multiple/target/${PROJECT}-multiple.target.repo/ ]]; then
        mv ${WORKSPACE}/multiple/target/${PROJECT}-multiple.target.repo/ /tmp/${PROJECT}-multiple.target.repo_${NOW}
      fi

      # Step 1: Merge changes in new target file to actual target file
      pushd ${WORKSPACE}/multiple && mvn -U org.jboss.tools.tycho-plugins:target-platform-utils:0.19.0-SNAPSHOT:fix-versions -DtargetFile=${PROJECT}-multiple.target && rm -f ${PROJECT}-multiple.target ${PROJECT}-multiple.target_update_hints.txt && mv -f ${PROJECT}-multiple.target_fixedVersion.target ${PROJECT}-multiple.target && popd
    
      # Step 2: Resolve the new 'multiple' target platform and verify it is self-contained by building the 'unified' target platform too
      # TODO: if you removed IUs, be sure to do a `mvn clean install`, rather than just a `mvn install`; process will be much longer but will guarantee metadata is correct 
      pushd ${WORKSPACE} && mvn install -Pmultiple2repo -DtargetRepositoryUrl=file://${WORKSPACE}/multiple/target/${PROJECT}-multiple.target.repo/ -Dmirror-target-to-repo.includeSources=true && popd
    
      # Step 3: Install the new target platform into a clean Eclipse JEE bundle to verify if everything can be installed
      INSTALLDIR=/tmp/${PROJECT}target-install-test
      INSTALLSCRIPT=/tmp/installFromTarget.sh
      rm -fr ${INSTALLDIR} && mkdir -p ${INSTALLDIR}
      pushd ${INSTALLDIR}
        echo "Unpack ${ECLIPSEZIP} into ${INSTALLDIR} ..." && tar xzf ${ECLIPSEZIP}
        echo "Fetch install script to ${INSTALLSCRIPT} ..." && wget -q --no-check-certificate -N https://raw.githubusercontent.com/jbosstools/jbosstools-build-ci/master/util/installFromTarget.sh -O ${INSTALLSCRIPT} && chmod +x ${INSTALLSCRIPT} 
        echo "Install..."
        if [[ ${UPSTREAM_SITE} ]]; then
          ${INSTALLSCRIPT} -ECLIPSE ${INSTALLDIR}/eclipse -INSTALL_PLAN ${UPSTREAM_SITE},file://${WORKSPACE}/multiple/target/${PROJECT}-multiple.target.repo/ | tee ${INSTALLSCRIPT}_log_${PROJECT}_${NOW}.txt; 
        else
          ${INSTALLSCRIPT} -ECLIPSE ${INSTALLDIR}/eclipse -INSTALL_PLAN file://${WORKSPACE}/multiple/target/${PROJECT}-multiple.target.repo/ | tee ${INSTALLSCRIPT}_log_${PROJECT}_${NOW}.txt; 
        fi
        cat ${INSTALLSCRIPT}_log_${PROJECT}_${NOW}.txt | egrep -i -A2 "IllegalArgumentException|Could not resolve|error|Unresolved requirement|could not be found|FAILED|Missing|Only one of the following|being installed|Cannot satisfy dependency"; if [[ "$?" == "0" ]]; then break; fi
      popd

      # Step 4: produce p2diff report
      ${P2DIFF} /tmp/${PROJECT}-multiple.target.repo_${NOW} file://${WORKSPACE}/multiple/target/${PROJECT}-multiple.target.repo/ | tee /tmp/p2diff_log_${PROJECT}_${NOW}.txt

    done

</pre>

<ol>
  <li value="4"> Follow the <a href="https://github.com/jbosstools/jbosstools-devdoc/blob/master/building/target_platforms/target_platforms_updates.adoc">release guidelines</a> for how to announce target platform changes.</li>
  <li>Check in updated target files &amp; push to the branch.</li>
</ol>

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
