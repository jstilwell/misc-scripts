#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Check for sudo access
if sudo -n true 2>/dev/null; then 
    :
else
    echo -e "${RED}No sudo access. Trying 'sudo ls' to get access.${NC}"
    sudo ls >/dev/null 2>&1
    # Recheck sudo access
    if sudo -n true 2>/dev/null; then 
        :
    else
        echo -e "${RED}Still no sudo access. Exiting...${NC}"
        exit 1
    fi
fi

echo ""
echo -e "${GREEN}-------------------------------System Information----------------------------${NC}"
echo -e "${GREEN}Hostname:${NC}\t\t"`hostname`
echo -e "${GREEN}Operating System:${NC}\t"`hostnamectl | grep "Operating System" | cut -d ' ' -f5-`
echo -e "${GREEN}Uptime:${NC}\t\t\t"`uptime | awk '{print $3,$4}' | sed 's/,//'`
echo -e "${GREEN}LAN IPs:${NC}\t\t"`hostname -I`
public_ip=$(curl -s ifconfig.me)
echo -e "${GREEN}Public IP:${NC}\t\t"$public_ip
# Host Level
echo -e "${GREEN}Host Level:${NC}\t\t"`sed -n 's/deliverable_level = //p' /mnt/data/conf/global.ini`
echo -e "${GREEN}Host Stack:${NC}\t\t"`sed -n 's/platform_stack_version = //p' /etc/rl-release.ini`
echo ""
echo -e "${BLUE}-------------------------------CPU/Memory Usage------------------------------${NC}"
echo -e "${BLUE}CPU Usage:${NC}\t"`cat /proc/stat | awk '/cpu/{printf("%.2f%\n"), ($2+$4)*100/($2+$4+$5)}' |  awk '{print $0}' | head -1`
echo -e "${BLUE}Memory Usage:${NC}\t"`free | awk '/Mem/{printf("%.2f%"), $3/$2*100}'`
echo -e "${BLUE}Swap Usage:${NC}\t"`free | awk '/Swap/{printf("%.2f%"), $3/$2*100}'`
echo ""
echo -e "${CYAN}-------------------------------Disk Usage-----------------------------------${NC}"
echo -e "$(df -Ph | grep -E '/dev/xvda1|/dev/xvdb' | awk '{print $6": Used%: "$5," Size: "$2", Used: "$3}')"
echo ""
echo -e "${YELLOW}-------------------------------LMS Information------------------------------${NC}"
lms_version=$(grep '$release' /mnt/code/www/moodle_prod/version.php | awk -F\' '{ print $2 }')
cd /mnt/code/www/moodle_prod
git_branch=$(git branch -v | grep '*' | awk '{ print $2 }')
git_repo=$(git remote -v | grep 'origin' | awk '{print $2}' | head -1 | sed 's/.*\///')
echo -e "${YELLOW}LMS URL:${NC} $(/rlscripts/moodle/moodle_list -p wwwroot | grep 'https://' | awk -F'|' '{print $1}' | sed 's/ //g')"
echo -e "${YELLOW}LMS Version:${NC} $lms_version"
echo -e "${YELLOW}Git Branch:${NC} $git_branch"
echo -e "${YELLOW}Git Repo:${NC} $git_repo"
echo ""
cd ~
