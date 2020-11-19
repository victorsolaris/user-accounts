#!/bin/bash

# Victor Solaris
# November 18, 2020
# update_conda.sh

#	SUMMARY
# run as root
# take command line arguments
# create log directory
# create log file
# download miniconda
# update miniconda

#       RUN AS ROOT
if [[ $(whoami) != 'root' ]]; then
  echo "Run as root" && exit 1;
fi

#       TAKE COMMAND LINE ARGUMENTS
if [ "$1" == "-h" ]; then
  echo -e "\nUsage: $0 <username>"
  echo -e "\nMinimum passphrase length: 8 characters, [a-zA-Z0-9]"
  exit 1
fi

if [ $# -ne 1 ]; then
  echo -e "\nERROR: Illegal number of parameters"
  echo -e "\nUSAGE: $0 <username>"
  echo -e "\nMinimum passphrase length: 8 characters, [a-zA-Z0-9]"
  exit 1
fi

USERNAME="$1"
LOG="0.log"

re1='^[a-z]+$'
if [[ ! $USERNAME =~ $re1 ]]; then
  echo -e "\nERROR: \"Username\" can only contain [a-z]."
  echo -e "\nUSAGE: $0 <username>"
  echo -e "\nMinimum passphrase length: 8 characters, [a-zA-Z0-9]"
  exit 1
fi

#       CREATE LOG DIRECTORY
CURRENTDIR=$(pwd)
LOGDIR=""
LOGDIREXISTS="$(echo -e "Log directory exists: [ $CURRENTDIR/Logs ]")"
if [[ ! -d "$CURRENTDIR/Logs/" ]]; then
  mkdir "$CURRENTDIR/Logs"
  LOGDIR="$(echo -e "Log directory created: [ $CURRENTDIR/Logs/ ]")"
fi

#       CREATE LOG FILE
LOG="$CURRENTDIR/Logs/$0.log"
MINICONDAVERSION="Miniconda3-latest-Linux-x86_64.sh"
echo -e "\n*************************************************************\n" | tee -a "$LOG"
date | tee -a "$LOG"
echo -e "\nUpdating $MINICONDAVERSION for account(s). Please wait ...\n" | tee -a "$LOG"


# 	UPDATE MINICONDA
for user in $(cut -f 1 -d : /etc/passwd | grep -w "$USERNAME[0-9]\+$"); do
  if [[ -f "/home/$user/$MINICONDAVERSION" ]]; then
    echo -e "Updating $MINICONDAVERSION for [ $user ]."
    runuser -l "$user" -c 'echo "source ~/miniconda3/etc/profile.d/conda.sh" >> ~/.bashrc'
    runuser -l "$user" -c 'conda config --add channels bioconda'
    runuser -l "$user" -c 'conda config --add channels conda-forge'
    runuser -l "$user" -c 'echo y | conda update conda' > /dev/null 2>&1 &
  fi;
done | tee -a "$LOG"
