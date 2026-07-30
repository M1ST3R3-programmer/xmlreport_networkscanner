#!/bin/bash


TARGET=scanme.nmap.org

echo "Running vulnerability scan on $TARGET..."
sudo nmap --script vuln -sV "$TARGET" | grep -E "CVE-|VULNERABLE"

echo "Scan complete."



echo "---Potential Vulnerabilities Identified---"
echo "Identified Vulnerabilities:"
  

#prints all vulnerabilities found

echo
echo "done"
