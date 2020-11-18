#!/bin/bash

# Victor Solaris
# November 18, 2020
# delete_user.sh

#	SUMMARY
# run as root
# take command line arguments 
# check if there are accounts to be deleted
# delete user accounts
# delete group
# delete encrypted user accounts/password file

#	RUN AS ROOT
if [[ $(whoami) != 'root' ]]; then
  echo "Run as root" && exit 1;
fi

#	TAKE COMMAND LINE ARGUMENTS
if [[ $1 == "-h" ]]; then
  echo -e "\nUsage: $0 <username> <group name> <number of accounts>\n"
  exit 1
fi

if [[ $# -ne 3 ]]; then
  echo -e "\nIllegal number of parameters"
  echo -e "\nUsage: $0 <username> <group name> <number of accounts>\n"
  exit 1
fi

USERNAME="$1"
GROUP="$2"
MAX="$3"

re1='^[a-z]+$'
if [[ ! $USERNAME =~ $re1 ]]; then
  echo -e "\nERROR: \"Username\" can only contain [a-z]."
  echo -e "\nUSAGE: $0 <username> <groupname> <number of accounts>\n"
  echo -e "Minimum passphrase length: 8 characters, [a-zA-Z0-9]"
  exit 1
fi

if [[ ! $GROUP =~ $re1 ]]; then
  echo -e "\nERROR: \"Groupname\" parameter can only contain [a-z]."
  echo -e "\nUSAGE: $0 <username> <groupname> <number of accounts>\n"
  echo -e "Minimum passphrase length: 8 characters, [a-zA-Z0-9]"
  exit 1
fi

re2='^[0-9]+$'
if ! [[ $MAX =~ $re2 ]]; then
  echo -e "\nERROR: \"Number of Accounts\" parameter not a number."
  echo -e "\nUSAGE: $0 <username> <groupname> <number of accounts>\n"
  echo -e "Minimum passphrase length: 8 characters, [a-zA-Z0-9]"
  exit 1
fi

# CHECK IF THERE ARE ACCOUNTS TO BE DELETED
totalaccounts="$(grep -wc "$USERNAME[0-9]*" "/etc/passwd")"
if [[ $totalaccounts -eq 0 ]];then
  echo -e "\nThere are $totalaccounts  account(s) to be deleted." 
  exit 1
else
  echo -e "\nDeleting $totalaccounts account(s). Please wait ...\n"
fi

# DELETE USER ACCOUNTS
for (( i=1; i <= MAX; i++  ));do
   if grep -wq "$USERNAME$i" /etc/passwd; then
     
     # delete user crontabs
     crontab -r -u "$USERNAME$i" > /dev/null 2&>1
     
     # log out users
     killall -u "$USERNAME$i"
      
     # delete user accounts
     /usr/sbin/userdel -r "$USERNAME$i"
     case $i in
	$((MAX/10)) ) echo Completed: 10% ;;
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
   else
     echo "User account does not exist. "

   fi;
done

# DELETE GROUP
echo -e "\n***** Remove Group **************************************\n"
if grep -wq -1 "$GROUP" "/etc/group";then
  groupdel $GROUP
  echo -e "Group deleted: $GROUP\n"
else
  echo -e "Group does not exist: $GROUP\n"
fi


# DELETE ENCRYPTED USER ACCOUNTS/PASSWORD FILE 
rm *.gpg 2>/dev/null
