#!/bin/bash

if [[ $# -lt 1 ]]; then
	echo "Usage: $0 <moduleName1> <moduleName2> <...> [-b branch (assumes master if omitted)] [-u username-for-github-fork] [-n|--no-upstream]"
	echo "Example: $0 openshift"
	echo "Example: $0 openshift webservices -b jbosstools-4.0.x"
	echo "Example: $0 base server gwt -u nickboldt -n"
	exit 1;
fi

dbg=":" # debug off
#dbg="echo -e" # debug on
debug ()
{
	$dbg "${grey}${1}${norm}"
}

username=""
moduleNames=""
branch="master"
noUpstreamClone=0

# colours!
norm="\033[0;39m";
grey="\033[1;30m";
green="\033[1;32m";
brown="\033[0;33m";
yellow="\033[1;33m";
blue="\033[1;34m";
cyan="\033[1;36m";
red="\033[1;31m";

# read commandline args
while [[ "$#" -gt 0 ]]; do
	case $1 in
		'-n'|'--no-upstream') noUpstreamClone=1;;
		'-b') branch="$2"; shift 1;;
		'-u') username="$2"; shift 1;;
		*) moduleNames="$moduleNames $1";;
	esac
	shift 1
done

showStatus()
{
	module=$1
	pushd ${module} >/dev/null
	echo '=============================================================';
	echo "git status:"
	git status
	echo '-------------------------------------------------------------';
	echo "git remote -v"
	git remote -v
	echo '-------------------------------------------------------------';
	echo "git branch -v"
	git branch -v
	echo '-------------------------------------------------------------';
	echo "For recent commits, use git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative -10"
	echo '=============================================================';
	popd >/dev/null
}

switchToFork ()
{
	module=$1
	username=$2
	branch=$3
	pushd ${module} >/dev/null
	git remote add ${username} git://github.com/${username}/jbosstools-${module}.git
	git checkout -b ${username}/${branch}
	git pull ${username} ${branch}
	popd >/dev/null
}

readOp ()
{
	echo -e "There is already a folder in this directory called ${blue}${module}${norm}. Would you like to ${red}DELETE${norm} (d), ${yellow}UPDATE${norm} (u), ${green}FORK${norm} (f), or hit enter to ${grey}SKIP${norm}?"
	read op
	case $op in
		'f'|'F'|'fork'|'FORK') 		
			if [[ ! $username ]]; then
				echo "Error: no username specified with '-u USERNAME' on commandline. Must exit!"; exit 1;
			else
				switchToFork ${module} ${username} ${branch}
				showStatus ${module}
			fi
			;;
		'd'|'D'|'delete'|'DELETE')
			rm -fr ./${module}; gitClone ${module}
			;;
		'u'|'U'|'update'|'UPDATE')	
			pushd ${module} >/dev/null
			if [[ ! $username ]]; then
				git checkout ${branch} 
				git pull ${branch}
			else
				git checkout -b ${username}/${branch}
				git checkout ${username}/${branch}
				git pull ${username} ${branch}
			fi
			showStatus ${module}
			popd >/dev/null
			;;
		*) 
			debug "Module ${module} skipped."
			;;
	esac
}

# store list of modules so we don't do them twice
doneModules=""
gitClone ()
{
	module=$1
	doneModules="${doneModules} ${module}"
	if [[ -d ./${module} ]]; then
		readOp;
	else
		git clone git@github.com:jbosstools/jbosstools-${module}.git ${module}
		if [[ $username ]]; then
			switchToFork ${module} ${username} ${branch}
		fi
		showStatus ${module}
	fi
}

# parse 
gitCloneUpstream ()
{
	if [[ -f ${moduleName}/pom.xml ]]; then
		debug "Read ${moduleName}/pom.xml ..."
		SEQ=/usr/bin/seq
		a=( $( cat ${moduleName}/pom.xml ) )
		nextModules=""
		for i in $($SEQ 0 $((${#a[@]} - 1))); do
			line="${a[$i]}"
			if [[ ${line//<id>bootstrap<\/id>} != $line ]]; then # begin processing actual content
				#debug "Found bootstrap entry on line $i: $line"
				i=$(( $i + 1 )); nextLine="${a[$i]}"; 
				while [[ ${nextLine//\/modules} == ${nextLine} ]]; do # collect upstream repos
					nextModule=$nextLine
					if [[ ${nextModule//module>} != ${nextModule} ]]; then # want this one
						nextModule=$(echo ${nextModule} | sed -e "s#<module>../\(.\+\)</module>#\1#")
						nextModules="${nextModules} ${nextModule}"
						debug "nextModule = $nextModule"
					fi
					i=$(( $i + 1 )); nextLine="${a[$i]}"
				done
				for nextModule in ${nextModules}; do gitCloneAll ${nextModule}; done
			fi
		done
		debug "Done reading pom.xml."
	else
		debug "File ${moduleName}/pom.xml not found in current directory. Did the previous step fail to git clone?"
	fi
}

gitCloneAll ()
{
	moduleName=$1
	if [[ $moduleName ]]; then
		#echo $doneModules
		if [[ ${doneModules/ ${moduleName}/} == $doneModules ]]; then
			if [[ ${noUpstreamClone} == "1" ]]; then
				debug "Fetching module ${moduleName} from branch ${branch} (no upstream modules will be fetched) ..."
				gitClone ${moduleName}
			else
				debug "Fetching module ${moduleName} from branch ${branch} (and upstream modules) ..."
				gitClone ${moduleName}
				# next step will only do something useful if the previous step completed; without it there's no ${moduleName}/pom.xml to parse
				gitCloneUpstream ${moduleName}
			fi
		#else
			#debug "Already processed ${moduleName}: skip."
		fi
	fi
}

for moduleName in $moduleNames; do
	gitCloneAll ${moduleName}
done