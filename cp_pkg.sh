#!/bin/bash

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

# find current directory
CURRENTDIR=$(pwd)

#       CREATE LOG DIRECTORY
LOGDIR=""
LOGDIREXISTS="$(echo -e "Log directory exists: [ $CURRENTDIR/Logs ]")"
if [[ ! -d "$CURRENTDIR/Logs/" ]]; then
  mkdir "$CURRENTDIR/Logs"
  LOGDIR="$(echo -e "Log directory created: [ $CURRENTDIR/Logs/ ]")"
fi

#       CREATE LOG FILE
LOG="$CURRENTDIR/Logs/$0.log"
MINICONDAVERSION="Miniconda3-latest-Linux-x86_64.sh"
echo -e "" > "$LOG"
echo -e "\nCopying $MINICONDAVERSION to account(s). Please wait ...\n" | tee -a "$LOG"

# 	DATE STAMP
date | tee -a "$LOG"

#	DOWNLOAD MINICONDA
MINICONDALINK="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
if [[ ! -f "/root/Downloads/$MINICONDAVERSION" ]]; then
  wget -P /root/Downloads/ $MINICONDALINK
  echo -e "\n$MINICONDAVERSION downloaded !!!" | tee -a "$LOG"
fi

#	COPY MINICONDA TO USER
for user in $(cut -f 1 -d : /etc/passwd | grep -e ^"$USERNAME*"); do
  if [[ ! -f "/home/$user/$MINICONDAVERSION" ]]; then
    cp "/root/Downloads/$MINICONDAVERSION" "/home/$user/" & 
    echo -e "$MINICONDAVERSION copied to [ $user ]."
  fi;
done | tee -a "$LOG"

#	INSTALL MINICONDA
for user in $(cut -f 1 -d : /etc/passwd | grep -e ^"$USERNAME*"); do
  if [[ -f "/home/$user/$MINICONDAVERSION" ]]; then
    echo -e "Installing $MINICONDAVERSION to [ $user ]."
    runuser -l "$user" -c 'bash ~/Miniconda3-latest-Linux-x86_64.sh -b' > /dev/null 2>&1 &
    sleep 10
  fi;
done | tee -a "$LOG"

# 	UPDATE MINICONDA
for user in $(cut -f 1 -d : /etc/passwd | grep -e ^"$USERNAME*"); do
  if [[ -f "/home/$user/$MINICONDAVERSION" ]]; then
    echo -e "Updating $MINICONDAVERSION for [ $user ]."
    runuser -l "$user" -c 'echo "source ~/miniconda3/etc/profile.d/conda.sh" >> ~/.bashrc' > /dev/null 2>&1
    runuser -l "$user" -c 'echo y | conda update conda' > /dev/null 2>&1 &
  fi;
done | tee -a "$LOG"

