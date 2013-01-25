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
	
At any time, you can pull changes from the upstream and merge them onto your 4.3.0 branch:

    $ git checkout 4.3.0               # switches to the '4.3.0' branch
    $ git pull upstream 4.3.0          # fetches all 'upstream' changes and merges 'upstream/4.3.0' onto your '4.3.0' branch
    $ git push origin                  # pushes all the updates to your fork, which should be in-sync with 'upstream'

The general idea is to keep your '4.3.0' branch in-sync with the
'upstream/4.3.0'.

## Building JBoss Tools Target Platforms

To build _JBoss Tools Target Platforms_ requires specific versions of Java and
Maven. Also, there is some Maven setup. The [How to Build JBoss Tools with Maven 3](https://community.jboss.org/wiki/HowToBuildJBossToolsWithMaven3)
document will guide you through that setup.

This command will run the build:

    $ mvn clean verify

If you just want to check if things compiles/builds you can run:

    $ mvn clean verify -DskipTest=true

But *do not* push changes without having the new and existing unit tests pass!
 
## Contribute fixes and features

_JBoss Tools Target Platforms_ is open source, and we welcome anybody that wants to
participate and contribute!

If you want to fix a bug or make any changes, please log an issue in
the [JBoss Tools JIRA](https://issues.jboss.org/browse/JBDE)
describing the bug or new feature and give it a component type of
`build`. Then we highly recommend making the changes on a
topic branch named with the JIRA issue number. For example, this
command creates a branch for the JBIDE-1234 issue:

	$ git checkout -b jbide-1234

After you're happy with your changes and a full build (with unit
tests) runs successfully, commit your changes on your topic branch
(with good comments). Then it's time to check for any recent changes
that were made in the official repository:

	$ git checkout 4.3.0               # switches to the '4.3.0' branch
	$ git pull upstream 4.3.0          # fetches all 'upstream' changes and merges 'upstream/4.3.0' onto your '4.3.0' branch
	$ git checkout jbide-1234           # switches to your topic branch
	$ git rebase 4.3.0                 # reapplies your changes on top of the latest in 4.3.0
	                                      (i.e., the latest from 4.3.0 will be the new base for your changes)

If the pull grabbed a lot of changes, you should rerun your build with
tests enabled to make sure your changes are still good.

You can then push your topic branch and its changes into your public fork repository:

	$ git push origin jbide-1234         # pushes your topic branch into your public fork of JBoss Tools Target Platforms

And then [generate a pull-request](http://help.github.com/pull-requests/) where we can
review the proposed changes, comment on them, discuss them with you,
and if everything is good merge the changes right into the official
repository.
