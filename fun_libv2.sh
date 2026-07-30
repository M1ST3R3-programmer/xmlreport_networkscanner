#!/bin/bash
#
#This script is a library and will be used to call functions to the vul_scan script with
#proper formatting for simplicity and organization
#
#Author: Edwin Ramirez
#
#Date: 06-28-2026
#

is_valid_ip() {
  local ip="$1"

  #Check basic structure: 4 numbers separated by 3 dots
  if [[ ! $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    return 1
  fi
}

is_valid_domain() {
  local domain="$1"

  #Check basic  structure of domains
  if [[ ! $domain =~ ^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$ ]]; then
    return 1
  fi
}

create_header() {
  echo "---Network Security Scan Report---"

  #Checks whether the argument is an IP address or hostname
  if is_valid_ip "$1"; then
    TARGET="$1"
    echo "Target IP: $TARGET"
    echo
  elif is_valid_domain "$1"; then
    TARGET="$1"
    echo "Target Hostname: $TARGET"
    echo
  else
    echo "ERROR: Not a valid IP address or domain"
    echo
    return 1
  fi

}

write_ports() {
  echo "---Open Ports and Detected Services---"
  echo "Open Ports:"
  
  #This uses nmap to aggressively check all ports in a timely manner. This takes 10 min to complete
  sudo nmap -T4 $TARGET -oX scan_results.xml
  XML_FILE="scan_results.xml"

  # Check if xmlstarlet is installed
  if ! command -v xmlstarlet &> /dev/null; then
    echo "Error: xmlstarlet is not installed. Please install it to run this script." >&2
    exit 1
  fi

  # Check if the input file exists
  if [ ! -f "$XML_FILE" ]; then
    echo "Error: Scan file '$XML_FILE' not found." >&2
    exit 1
  fi

  #prints all ports and services found

  # Use a template to select and format the output for each open port.
  # -t: template
  # -m: match an element (like a for-each loop)
  # -v: select and print the value of an element/attribute
  # -n: print a newline

  xmlstarlet sel \
    -t \
    -m "//port[state/@state='open']" \
    -v "@portid" \
    -o "/" \
    -v "@protocol" \
    -o "   " \
    -v "service/@name" \
    -o " (" \
    -v "service/@product" \
    -o " " \
    -v "service/@version" \
    -o ")" \
    -n \
    "$XML_FILE"

  echo
}

write_vulns() {
  sudo nmap -sV --script vuln $TARGET -oX vulnerability.xml
  VXML_FILE=vulnerability.xml

  # Check if the input file exists
  if [ ! -f "$VXML_FILE" ]; then
    echo "Error: Scan file '$VXML_FILE' not found." >&2
    exit 1
  fi

  echo "---Potential Vulnerabilities Identified---"
  echo "Identified Vulnerabilities:"
  
  #prints all vulnerabilities found

  xmlstarlet sel \
    -t \
    -m "//port/script" \
    -v "concat('Port: ../@portid / ', ../service/@name, ' | Script: ', @id)" -n \
    -m "elem" \
    -v "concat(' - ', .)" -n \
    "$VXML_FILE"

  echo
}

write_recs() {
  sudo nmap --script ssl-enum-ciphers $TARGET -oX recommend.xml
  RXML_FILE=recommend.xml

  # Check if the input file exists
  if [ ! -f "$RXML_FILE" ]; then
    echo "Error: Scan file '$RXML_FILE' not found." >&2
    exit 1
  fi

  echo "-----Recommendations for Remediation-----"


  #prints all recommendations found
  xmlstarlet sel -t -m '//script[@id="ssl-enum-ciphers"]' \
    -v "../../address[@addrtype='ipv4']/@addr" \
    -o " Output: " -v "@output" -n "$RXML_FILE"
  
  
}

write_footer() {
  echo "Date created: $(date +'%Y-%m-%d %H:%M:%S')"
  echo "------------END OF REPORT------------"
  echo
}