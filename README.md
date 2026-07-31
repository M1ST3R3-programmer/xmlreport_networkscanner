# xmlreport_networkscanner
This is network scanner that is created using bash script. It will scan for open ports, vulnerabilities in the network, and make recommendations. Once it is done, it will provide a report using XML to format it.

## Features

* Accepts a target IP address or hostname from the command line.
* Performs an Nmap scan to detect services and versions.
* (Coming soon) Uses NSE scripts to check for specific vulnerabilities.
* (Coming soon) Generates a formatted report summarizing open ports and potential risks.
* Includes input validation and prerequisite checks.

## Prerequisites

To run this script, you will need the following installed:
* Bash (v4+)
* Nmap (v7.60+)

## Usage

1.  Clone the repository: `git clone git@github.com:YourUsername/my_scanner.git`
2.  Navigate to the directory: `cd my_scanner`
3.  Make the script executable: `chmod +x network_scanner.sh`
4.  Run the script with a target:
./network_scanner.sh <target_ip_or_hostname>

Example:
./network_scanner.sh scanme.nmap.org

## Ethical Considerations
This tool is for educational purposes only. Only run scans against hosts and networks for which you have explicit, written permission. Unauthorized network scanning is illegal.
