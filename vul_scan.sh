#!/bin/bash

#defines the absolute path of the library
##SCRIPT_DIR=$(cd -- "$(dirname -- "fun_lib.sh")" &> /dev/null && pwd) // this line holds original filepath
SCRIPT_DIR=$(cd -- "$(dirname -- "fun_lib.sh")" &> /dev/null && pwd)

#accesses the library and makes its functions usable in this script
#source $SCRIPT_DIR/fun_lib.sh // this line holds original and functional library
source $SCRIPT_DIR/fun_lib.sh

#checks whether a single argument was entered into the script
if [ $# -ne 1 ]; then
  echo "Usage: $0 <target_ip_or_hostname>" >&2
  echo "ERROR: Please enter a single argument"
  exit 1
fi 


#text to ensure script began
echo "Starting report..."
echo 
#curly brackets to ensure only section within brackets is being stored in report.txt
{

#prints the header and either IP address or hostname based on argument 
create_header "$1"

#if no valid ip or domain was used, the following will not execute
if [ $? -eq 0 ]; then
  #prints the placeholder ports and services
  write_ports

  #prints the placeholder vulnerabilities 
  write_vulns

  #prints the placeholder recommendations
  write_recs

  write_footer

fi

} > report.txt 2>&1

#allows user to see the full report once it is done
cat report.txt
