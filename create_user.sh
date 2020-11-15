#!/bin/bash

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


# find current directory
CURRENTDIR=$(pwd)

# 	CREATE LOG DIRECTORY
LOGDIR=""
LOGDIREXISTS="$(echo -e "Log directory exists: [ $CURRENTDIR/Logs ]")"
if [[ ! -d "$CURRENTDIR/Logs/" ]]; then
  mkdir "$CURRENTDIR/Logs" 
  LOGDIR="$(echo -e "Log directory created: [ $CURRENTDIR/Logs/ ]")"
fi

#	CREATE LOG FILE
LOG="$CURRENTDIR/Logs/$0.log"
echo -e "\nCreating $MAX user account(s). Please wait ...\n" | tee -a "$LOG"

#	CREATE GROUP
CREATEGROUP=""
GROUPEXISTS="$(echo -e "\nGroup exists: [ $GROUP ]")"
if ! grep -wq "$GROUP" "/etc/group";then
  groupadd "$GROUP"
  CREATEGROUP="$(echo -e "\nGroup created: [ $GROUP ]")"
fi

# 	CREATE USERS
touch "$(date +useraccounts_%Y-%m-%d_%H-%M-%S.csv)"
# USERACCOUNTSFILE="$(ls | grep -e ^"useraccounts_.*_.*\.""csv"$)"
USERACCOUNTSFILE="$(ls $CURRENTDIR/useraccounts_*-*-*_*-*-*.csv)"

for (( i=1; i<=MAX; i++ ));do
  case $i in
        $((MAX/10 * 1)) ) echo Completed: $((MAX/10 * 1))% ;;
        $((MAX/10 * 2)) ) echo Completed: 20% ;;
        $((MAX/10 * 3)) ) echo Completed: 30% ;;
        $((MAX/10 * 4)) ) echo Completed: 40% ;;
        $((MAX/10 * 5)) ) echo Completed: 50% ;;
        $((MAX/10 * 6)) ) echo Completed: 60% ;;
        $((MAX/10 * 7)) ) echo Completed: 70% ;;
        $((MAX/10 * 8)) ) echo Completed: 80% ;;
        $((MAX/10 * 9)) ) echo Completed: 90% ;;
        $((MAX/10 *10)) ) echo Completed: 100% ;;
  esac

  banner="\n***** $USERNAME$i ********************************************\n"
  
  if  ! grep -q "$USERNAME$i" "/etc/passwd"; 
    then
      /usr/sbin/useradd -e "$(date -d "$EXPIRE days" +"%Y-%m-%d")" -m "$USERNAME$i"
      /usr/sbin/usermod -aG "$GROUP" "$USERNAME$i"
      
      password="$(openssl rand -base64 8 | cut -b -10)" 
      echo "$USERNAME$i:$password" | chpasswd

      echo "$USERNAME$i,$password" >> "$USERACCOUNTSFILE"
      
    else
      echo -e "$banner" | tee -a "$LOG" &
      echo -e "User account already exists" | tee -a "$LOG" &
  fi; 
done

# 	ENCRYPT FILE
gpg -c --batch --passphrase "$MYPASS" "$USERACCOUNTSFILE"
shred -uz "$USERACCOUNTSFILE"

# 	SUMMARY
i=0
while [ $i -le 0 ] 
do
	echo -e "***** SUMMARY ******************************\n"
	date
	echo -e "\nUsername: $USERNAME"
	echo -e "Groupname: $GROUP"
	echo -e "Number of Accounts: $MAX"
	echo -e "Expiration date: $(date -d "$EXPIRE days" +"%Y-%m-%d")"

	if [[ ! -z "$CREATEGROUP" ]]; then echo -e "$CREATEGROUP"; else echo "$GROUPEXISTS"; fi

	echo -e "User accounts file created: [ $USERACCOUNTSFILE.gpg ]"
	if [[ ! -z "$LOGDIR" ]]; then echo -e "$LOGDIR"; else echo "$LOGDIREXISTS"; fi
	((i++))
done | tee -a "$LOG"
