#!/bin/bash

# Victor Solaris
# November 18, 2020
# main.sh

# 	RUN AS ROOT
if [[ $(whoami) != 'root' ]]; then 
  echo "Run as root" && exit 1;
fi

# 	TAKE COMMAND LINE ARGUMENTS
if [ "$1" == "-h" ]; then
  echo -e "\nUsage: $0 <username> <groupname> <number of accounts> <number of days until expiration> <passphrase>\n"
  echo -e "Minimum passphrase length: 8 characters, [a-zA-Z0-9]"
  exit 1
fi

if [ $# -ne 5 ]; then
  echo -e "\nERROR: Illegal number of parameters"
  echo -e "\nUSAGE: $0 <username> <groupname> <number of accounts> <number of days until expiration> <passphrase>\n"
  echo -e "Minimum passphrase length: 8 characters, [a-zA-Z0-9]"
  exit 1
fi

USERNAME="$1"
GROUP="$2"
MAX="$3"
EXPIRE="$4"
MYPASS="$5"

re1='^[a-z]+$'
if [[ ! $USERNAME =~ $re1 ]]; then 
  echo -e "\nERROR: \"Username\" can only contain [a-z]."
  echo -e "\nUSAGE: $0 <username> <groupname> <number of accounts> <number of days until expiration> <passphrase>\n"
  echo -e "Minimum passphrase length: 8 characters, [a-zA-Z0-9]"
  exit 1
fi

if [[ ! $GROUP =~ $re1 ]]; then 
  echo -e "\nERROR: \"Groupname\" parameter can only contain [a-z]."
  echo -e "\nUSAGE: $0 <username> <groupname> <number of accounts> <number of days until expiration> <passphrase>\n"
  echo -e "Minimum passphrase length: 8 characters, [a-zA-Z0-9]"
  exit 1
fi

re2='^[0-9]+$'
if ! [[ $MAX =~ $re2 ]]; then
  echo -e "\nERROR: \"Number of Accounts\" parameter not a number."
  echo -e "\nUSAGE: $0 <username> <groupname> <number of accounts> <number of days until expiration> <passphrase>\n"
  echo -e "Minimum passphrase length: 8 characters, [a-zA-Z0-9]"
  exit 1
fi

if ! [[ $EXPIRE =~ $re2 ]]; then
  echo -e "\nERROR: \"Number of Days Until Expiration\" parameter not a number."
  echo -e "\nUSAGE: $0 <username> <groupname> <number of accounts> <number of days until expiration> <passphrase>\n"
  echo -e "Minimum passphrase length: 8 characters, [a-zA-Z0-9]"
  exit 1
fi

if [[ ${#MYPASS} -lt 8 ]]; then echo "Passphrase must be at least 8 characters, [a-zA-Z0-9]"; exit 1; fi

re3='^[[:alnum:]]+$'
if [[ ! $MYPASS =~ $re3 ]]; then 
  echo -e "\nERROR: \"Passphrase\" parameter can only contain [a-zA-Z0-9]."
  echo -e "\nUSAGE: $0 <username> <groupname> <number of accounts> <number of days until expiration> <passphrase>\n"
  echo -e "Minimum passphrase length: 8 characters, [a-zA-Z0-9]"
  exit 1
fi

./create_user.sh $USERNAME $GROUP $MAX $EXPIRE $MYPASS
./install_conda.sh $USERNAME


