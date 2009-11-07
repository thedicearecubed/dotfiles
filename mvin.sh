#!/bin/sh
#
# TODO
# should be prompting user for each dotfile
#	see how see tahoe installer handled default values
#	see how other people are handling default values in their user promts
# rename string: replace all WORK with WORKING
#			^^tmp?  cause... it's really a temp directory...
# give a thought to renaming all __foreach__ functions like...
#	fforeachDotfile_COPY
#
#
#


#
# ARGUMENT PARSING AND SANITY CHECKING
#===================================================================
#

if [ $USER = 'root' ] ; then
	echo "no root user"
	f_usage
	exit 1;
fi


f_usage(){
	local _USAGE=$(cat <<__HEREDOC__
${0}: designed to assist in keeping your dotfiles portable and
synchronized. Default behavior is to pull dotfiles from remote
server and put under home directory.

usage: ${0} [--mvout] [--downloadonly]
	--mvout
		Move out.
		Reverses default "move in" behavior. Pushes or uploads
		dotfiles (from home directory) to remote server

	--downloadonly
**DISABLED**
		Same as default behavior except dotfiles are not
		put under home directory, but are left under the
		"tmp.mvin" folder that this script uses as its
		working directory.

misc/notes:
	lynx
	wget
	curl
__HEREDOC__
)

	echo "$_USAGE"
	exit 1;
}

# ensure at least 1 argument is given
[ $# = 0 ] && f_usage

ACTION=
while [[ "$1" = -* ]] ; do
  case "$1" in
    --download) # no-value arg
			ACTION=download
			shift
			;;

    --mvout) # no-value arg
			ACTION=upload
			isMvIn="NO"
			shift
			;;
    --downloadonly) # no-value arg
			isDownloadOnly="YES"
			shift
			;;

    *)
		echo "ERROR case matched wildcard"
		f_usage
		;;
  esac
done


#
# source conf file, which should be sibling to curr script
source "$(dirname $0)/mvin.conf"



#
# VARIABLE PARAMS/INITIALIZATION
#===================================================================
#
# like cfparam=* required=yes
#: ${TEMPDIR2:?ERROR: not specified}
: ${HOME:?ERROR: HOME variable must be set}
: ${REMOTE_HOST_MVIN_ADDRESS:?ERROR: REMOTE_HOST_MVIN_ADDRESS variable must be set (see mvin.conf)}
if [ ${#ACTION} = 0 ] ; then
	echo "don't know what to do"
	f_usage
fi


#
# like cfparam=* required=no
: ${isMvIn:="YES"}
: ${isDownloadonly:="NO"}

#
# the mvin program home directory
: ${mvinHOME:="${HOME}/.mvin"}
#
# mvin's temp directory.  between when files are up/downloaded and
# copied to the home directory, each one is copied here first.
: ${mvinTMP:="${mvinHOME}/tmp"}

#
# remote server address
REMOTE_DOWNLOAD_DIRECTORY="${REMOTE_HOST_MVIN_ADDRESS}/dotfiles"
REMOTE_UPLOAD_DIRECTORY="${REMOTE_HOST_MVIN_ADDRESS}/upload/"


#
# the set of all dot files to work with
#: ${dot_files:="myaliases myvariables myfunctions"}
: ${dot_files:=".inputrc .mvinrc .zshrc"}






#
# FUNCTIONS
#===================================================================
#
fCreateWorkingDirectory(){
	if [ ! -d $mvinHOME ] ; then
		echo "creating $mvinTMP directory"
		mkdir -p "${mvinTMP}"
#DEVEL	else
#DEVEL		echo "ERROR: $mvinHOME already exists! ...I want to be the one to create it"
#DEVEL		exit 2
	fi
}


fForeachDotfileDoDownload(){
	remoteSourceDirectory="$1"
	localDestinationDirectory="$2"

	for dotfile in $dot_files ; do
		fDownload "$remoteSourceDirectory/${dotfile}" "$localDestinationDirectory/${dotfile}"
	done
}

fDownload(){
	remoteSource="$1"
	localDestination="$2"
	wget --no-verbose --output-document="$localDestination" "$remoteSource"
}

fForeachDotfileDoUpload(){
	localSourceDirectory="$1"
	remoteDestinationDirectory="$2"

	for dotfile in $dot_files ; do
		fUpload "$localSourceDirectory/${dotfile}" "$remoteDestinationDirectory"
	done
}

fUpload(){
	localSource="$1"
	remoteDestination="$2"
	curl -F "upload_file[]=@${localSource}" -F "request=HANDLE_UPLOAD" "${remoteDestination}"
}


fForeachDotfileDoCopy(){
	sourceDirectory="$1"
	destinationDirectory="$2"

	for dotfile in $dot_files ; do
		fCopy "$sourceDirectory/${dotfile}" "$destinationDirectory/${dotfile}"
	done
}

fCopy(){
	# simply a wrapper for cp
	cp -v "$1" "$2"
}




#
# MAIN
#===================================================================
#
SLEEPTIME=1

if [ "$ACTION" = "download" ] ; then
	fCreateWorkingDirectory

	echo "Retrieve dotfiles from remote host?... in $SLEEPTIME seconds..."
	sleep $SLEEPTIME
	fForeachDotfileDoDownload "$REMOTE_DOWNLOAD_DIRECTORY" "$mvinTMP"


	echo "Copy dotfiles from $mvinTMP to HOME (files are overwritten"
	echo "if they exist)? ...in $SLEEPTIME seconds..."
	sleep $SLEEPTIME
	fForeachDotfileDoCopy "$mvinTMP" "$HOME"


else if [ "$ACTION" = "upload" ] ; then
	echo "Copy dotfiles from HOME to $mvinTMP (files are overwritten"
	echo "if they exist)? ...in $SLEEPTIME seconds..."
	sleep $SLEEPTIME
	fForeachDotfileDoCopy "$HOME" "$mvinTMP"


	echo "Upload dotfiles to remote host?... in $SLEEPTIME seconds..."
	sleep $SLEEPTIME
	fForeachDotfileDoUpload "$mvinTMP" "$REMOTE_UPLOAD_DIRECTORY"
fi



exit $?

########### MAYBE LATER............

#
# PROFILE SOURCING
#
# the calling parent profile (i.e. .bashrc should source .mvinrc)
PARENT_PROFILE=~/.bashrc
MVIN_PROFILE_MVINRC='~/.mvinrc'

#
# check if calling parent profile needs to be "patched" (really updated) so that
# it'll source .mvinrc (which in turn will source custom profiles)
grep -n ". $MVIN_PROFILE_MVINRC" "$PARENT_PROFILE"

if [ $? = 0 ] ; then
	echo "$PARENT_PROFILE is patched; nothing to do"

else
	echo "Updating $PARENT_PROFILE to source custom profiles"

	tmpSourcingProfile="[[ -f $MVIN_PROFILE_MVINRC ]] && . $MVIN_PROFILE_MVINRC"

	echo "" >> $PARENT_PROFILE
	echo "# mvin.sh adds sourcing code" >> $PARENT_PROFILE
	echo "$tmpSourcingProfile" >> $PARENT_PROFILE
fi

