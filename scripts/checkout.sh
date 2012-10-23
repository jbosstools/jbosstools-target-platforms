#!/bin/bash

if [[ $# -lt 1 ]]; then
	echo "Usage: $0 <moduleName> [-b branch (assumes master if omitted)] [-n|--no-upstream]"
	echo "Example: $0 openshift"
	echo "Example: $0 openshift -b jbosstools-4.0.x -n"
	exit 1;
fi

dbg=":" # debug off
#dbg="echo -e" # debug on
debug ()
{
	$dbg "${grey}${1}${norm}"
}

moduleName=""
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
		*) moduleName="$1";;
	esac
	shift 1
done

# TODO: make this actually delete or update; rather than just echoing
readOp ()
{
	echo -e "There is already a folder in this directory called ${blue}${module}${norm}. Would you like to ${red}DELETE${norm} (d), ${yellow}UPDATE${norm} (u), or ${green}SKIP${norm} (s)?"
	read op
	case $op in
		'd'|'DELETE')	echo "  >> rm -fr ./${module}; git clone git@github.com:jbosstools/jbosstools-${module}.git ${module}";;
		'u'|'UPDATE')	echo "  >> cd ${module}; git pull; git checkout ${branch}; cd -";;
		's'|'SKIP')		debug "Module ${module} skipped.";;
		*)			readOp;;
	esac
}

# TODO: make this actually fetch instead of just echoing
gitClone ()
{
	module=$1
	if [[ -d ${module} ]]; then
		readOp;
	else
		echo "  >> git clone git@github.com:jbosstools/jbosstools-${module}.git ${module}"
	fi
	
}

# parse 
gitCloneUpstream ()
{
	if [[ -f ${moduleName}/pom.xml ]]; then
		SEQ=/usr/bin/seq
		a=( $( cat ${moduleName}/pom.xml ) )
		for i in $($SEQ 0 $((${#a[@]} - 1))); do
			line="${a[$i]}"
			if [[ ${line//<id>bootstrap<\/id>} != $line ]]; then # begin processing actual content
				#debug "Found bootstrap entry on line $i: $line"
				i=$(( $i + 1 )); nextLine="${a[$i]}"; 
				while [[ ${nextLine//\/modules} == ${nextLine} ]]; do # collect upstream repos
					nextModule=$nextLine
					if [[ ${nextModule//module>} != ${nextModule} ]]; then # want this one
						nextModule=$(echo ${nextModule} | sed -e "s#<module>../\(.\+\)</module>#\1#")
						gitClone $nextModule
					fi
					i=$(( $i + 1 )); nextLine="${a[$i]}"
				done
			fi
		done
	else
		debug "File ${moduleName}/pom.xml not found in current directory. Did the previous step fail to git clone?"
	fi
}

if [[ ${noUpstreamClone} == "1" ]]; then
	debug "Fetching module ${moduleName} from branch ${branch} (no upstream modules will be fetched) ..."
	gitClone ${moduleName}
else
	debug "Fetching module ${moduleName} from branch ${branch} (and upstream modules) ..."
	gitClone ${moduleName}
	# next step will only do something useful if the previous step completed; without it there's no ${moduleName}/pom.xml to parse
	gitCloneUpstream ${moduleName}
fi
