#!/bin/bash
. ./secret.txt

init()
{
	#setup the environment
	if [ ! -d ./ssh ]; then
		mkdir ./ssh 
		ssh-keygen -b 2048 -t rsa -f ./ssh/xld -q -N ""
		chmod 400 ./ssh/xld*
	else 
		rm -rf ./ssh
		mkdir ./ssh
		ssh-keygen -b 2048 -t rsa -f ./ssh/xld -q -N ""
		chmod 400 ./ssh/xld*
	fi


	# the Packer part
	PACKERBUILDLOG="./packer_build.log"
	TERRAFORMBUILDLOG="./terraform_build.log"
}

do_packer(){
		
	PACKERCMD="packer build  ""${PACKER_BUILD_ARGS}"" xldeploy.json"
	echo "running ${PACKERCMD}"
	${PACKERCMD} 2>&1 | tee ${PACKERBUILDLOG}
	AMI=`tail -2 ${PACKERBUILDLOG} | head -2 | awk 'match($0, /ami-.*/) { print substr($0, RSTART, RLENGTH) }'`
	# Terraform piece
}

do_terraform(){
	AMI=$1
	TERRAFORMCMD="terraform apply \
	 -no-color
	 -input=false\
	 -var ""aws_ami=${AMI}"" \
	 ${TERRAFORM_APPLY_ARGS}"
	 
	$TERRAFORMCMD 2>&1 | tee ${TERRAFORMBUILDLOG}
}

run_terraform_only(){
	do_terraform $1
	exit $?
}

run_packer_only(){
	do_packer
	exit $?
}
destroy_terraform(){

	TERRAFORMCMD="terraform destroy \
         -no-color \
         -input=false\
         ${TERRAFORM_APPLY_ARGS}"
 
    ${TERRAFORMCMD} 2>&1 | tee ${TERRAFORMBUILDLOG}
       
}
run(){
	do_packer
	do_terraform $AMI
}

#set -x

init

PACKER_BUILD_ARGS="-var ""aws_access_key=${AWS_ACCESS_KEY}"" -var ""aws_secret_key=${AWS_SECRET_KEY}"" -var ""download_password=${xld_download_password}"""
TERRAFORM_APPLY_ARGS=" -var ""aws_access_key=${AWS_ACCESS_KEY}"" -var ""aws_secret_key=${AWS_SECRET_KEY}"" "
RUNNER="run"

while getopts "Ddb:v:p:a:" opt; do
	echo "parse opts"
  case $opt in
    b)
      echo "packer builder is set to $OPTARG" >&2
      PACKER_BUILD_ARGS=" ""${PACKER_BUILD_ARGS}"" ""-only=${OPTARG}"""
      ;;
	v) 
	  echo "packer additional variables are set to ${OPTARG}" >&2
	  PACKER_BUILD_ARGS=" ""${PACKER_BUILD_ARGS}"" ""${OPTARG}"""
	  ;;
	a) 
	  echo "terraform ami is set to ${OPTARG}" >&2
	  RUNNER="run_terraform_only $OPTARG"
	  ;;
	d) 
      echo "destroy terraform setup"
	  RUNNER="destroy_terraform" 
	  ;;
	D) 
      export PACKER_LOG="debug"
      export PACKER_LOG_PATH="./packer_debug.log"
	  ;;
	p)
	  echo "running packer only"
	  RUNNER='run_packer_only'
	  ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

eval $RUNNER


