#!/usr/bin/env bash

module load python/2.7.3-epd-7.3.2

echo $(date +%s%03N)

UPP_HOME=$HOME/.local/bin

g=$(echo $*|grep -e "-d")
if [ -n "$g" ]
then
	output=`echo $*|sed -e 's/.*-d //g' -e 's/ .*//g'`
	if [ -d $output ] 
	then
	    back=`mktemp -d ${output}_back_XXXXXX`
	    mv $output/* $back
	    rm -r $output
	  fi
fi

python $UPP_HOME/run_upp.py $*
ret=$?

echo $(date +%s%03N)

exit $ret
