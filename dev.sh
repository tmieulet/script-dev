#!/bin/bash

function FONCYES ()
{
[ "$1" = "y" ] || [ "$1" = "Y" ]
}

function ASK()
{
 if [ "$yesToAll" = "1" ]; then
	return 0
  fi
  echo "$1 ? [y/n]"
  read -r RESPONSE
  FONCYES "$RESPONSE"
}

function FUNC_INSTALL_DOCKER ()
{
curl -sSL https://get.docker.com/ | sh
# now install docker-compose
curl -L https://github.com/docker/compose/releases/download/1.7.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version
}



function FONC_INSTALL ()
{
RESULT=""
 apt-get update
   
	if ! hash curl 2>/dev/null; then
	   
	   if  ASK "Install curl"; then
	     apt-get install -y curl
	   fi
    fi
    
    if ! hash git 2>/dev/null; then
	   if ASK "Install git"; then
	      apt install -y  git
	   fi
	fi
	
	if ! hash docker 2>/dev/null; then
	   if ASK "Install docker"; then
	     FUNC_INSTALL_DOCKER
	   fi
	fi
  
  if ! hash java 2>/dev/null; then
	   if ASK "Install openjdk8 and maven"; then
	     apt install -y  maven default-jdk
	   fi
	fi
  
  if ! hash npm 2>/dev/null; then
	   if ASK "Install npm and node8"; then
	    apt install -y npm
	    # update npm
	    npm i -g npm
      npm install -g n
      n latest
	   fi
	fi
  
    if ! hash pip 2>/dev/null; then
	   if ASK "Install pip (required for aws-sam-cli, ..)"; then
	    apt install -y python-pip
	    # update to the last version (bad idea)
	    # keep 9.0.1-2 : https://github.com/pypa/pip/issues/5240
	    # pip install --upgrade pip
	    
	    RESULT="$RESULT\n export PATH=~/.local/bin:\$PATH"
	   fi
	fi
  
  if ! hash aws 2>/dev/null; then
	   if ASK "Install awscli"; then
	     # apt install -y   awscli
	     pip install awscli --upgrade --user
	     RESULT="$RESULT\n aws --version"
	   fi
	fi
  
  if ! hash sam 2>/dev/null; then
	  if ASK "Install aws-sam-local"; then
            pip install --user aws-sam-cli
	    sam --version
	    pip install --user --upgrade aws-sam-cli
          fi
  fi
  if ! hash localstack 2>/dev/null; then
	  if ASK "Install localstack"; then
            pip install --user localstack
	    RESULT="$RESULT\n localstack start --docker"
          fi
  fi
# echo \n doesn't print a newline
# printf has more consistent behavior than echo. The behavior of echo varies greatly between different versions.
printf  $RESULT
}

usage()
{
    echo "usage: dev.sh [[[-y] [-i] [-v]] | [-h]]"
}

interactive=
yesToAll=
validate=
while [ "$1" != "" ]; do
    case $1 in
        -y | --yesToAll )       yesToAll=1
                                ;;
        -i | --interactive )    interactive=1
                                ;;
        -v | --validate )       validate=1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    # Shift all the parameters down by one
    shift
done

FONC_INSTALL

if [ "$validate" = "1" ]; then
	curl -sSL https://raw.githubusercontent.com/tmieulet/script/master/validate-sam.sh | sh
fi
