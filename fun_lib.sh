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
  
  #ports and services variable placeholders
  
  echo "Open Ports:"
  sudo nmap -sV -T4 -oX scan_results.xml $TARGET
  local XML_FILE="scan_results.xml"

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
  echo "---Potential Vulnerabilities Identified---"
  
  #vulnerabilities array placeholder
  declare -A vuln
  vuln["1"]="CVE-2023-XXXX - Outdated Web Server"
  vuln["2"]="Default Credentials - FTPServer"

  echo "Identified Vulnerabilities:"

  #prints all vulnerabilities found
  for i in "${!vuln[@]}"; do
  echo "  ${vuln[$i]}"
  done
  echo
}

write_recs() {
  echo "-----Recommendations for Remediation-----"

  #recommendations arrays
  declare -A recommend
  recommend["1"]="Update all software to the latest version"
  recommend["2"]="Change default credentials immediately"
  recommend["3"]="Implement Firewall"

  #prints all recommendations found
  for r in "${!recommend[@]}"; do
  echo "  ${recommend[$r]}"
  done
  echo
}

write_footer() {
  echo "Date created: $(date +'%Y-%m-%d %H:%M:%S')"
  echo "------------END OF REPORT------------"
  echo
}