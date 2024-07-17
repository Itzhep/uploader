#!/bin/bash

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to upload to Dropbox
upload_to_dropbox() {
    ACCESS_TOKEN="$1"
    FILE="$2"

    response=$(curl -s -X POST https://content.dropboxapi.com/2/files/upload \
        --header "Authorization: Bearer $ACCESS_TOKEN" \
        --header "Dropbox-API-Arg: {\"path\": \"/$(basename "$FILE")\",\"mode\": \"add\",\"autorename\": true,\"mute\": false}" \
        --header "Content-Type: application/octet-stream" \
        --data-binary @"$FILE")

    echo "$response"
}


# Function to upload to Google Drive (requires OAuth2 setup)
upload_to_google_drive() {
    FILE="$1"
    ACCESS_TOKEN="$2"

    response=$(curl -s -X POST -L \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -F "metadata={name: '$(basename "$FILE")'};type=application/json;charset=UTF-8" \
        -F "file=@${FILE};type=application/octet-stream" \
        "https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart")

    echo "$response"
}

# Function to upload to Imgur (anonymous upload)
upload_to_imgur() {
    FILE="$1"

    response=$(curl -s -X POST --data-binary "@$FILE" \
        -H "Authorization: Client-ID YOUR_IMGUR_CLIENT_ID" \
        https://api.imgur.com/3/image)
    
    echo "$response"
}

# Check for curl
if ! command -v curl &> /dev/null; then
    echo -e "${RED}curl is not installed. Please install it first.${NC}"
    exit 1
fi

echo -e "${RED} By Danial Github : https://github.com/Itzhep/ "
echo -e "${CYAN}Select the upload API:${NC}"
echo -e "${GREEN}1. Dropbox (requires access token)${NC}"
echo -e "${GREEN}2. Google Drive (requires access token)${NC}"
echo -e "${GREEN}3. Imgur (requires Client ID)${NC}"
read -p "Enter your choice (1-3): " choice

# Handle user choice
case $choice in
    1)
        read -p "Enter your Dropbox access token: " ACCESS_TOKEN
        ;;

    2)
        read -p "Enter your Google Drive access token: " ACCESS_TOKEN
        ;;
    3)
        read -p "Enter your Imgur Client ID: " CLIENT_ID
        ;;
    *)
        echo -e "${RED}Invalid choice. Exiting.${NC}"
        exit 1
        ;;
esac

# Get the file to upload
read -p "Enter the path of the file to upload: " FILE

# Check if the file exists
if [ ! -f "$FILE" ]; then
    echo -e "${RED}File '$FILE' does not exist.${NC}"
    exit 1
fi

# Perform the upload based on the selected API
if [ "$choice" -eq 1 ]; then
    echo -e "${BLUE}Uploading '$FILE' to Dropbox...${NC}"
    response=$(upload_to_dropbox "$ACCESS_TOKEN" "$FILE")
elif [ "$choice" -eq 2 ]; then
    echo -e "${BLUE}Uploading '$FILE' to Google Drive...${NC}"
    response=$(upload_to_google_drive "$FILE" "$ACCESS_TOKEN")
elif [ "$choice" -eq 3 ]; then
    echo -e "${BLUE}Uploading '$FILE' to Imgur...${NC}"
    response=$(upload_to_imgur "$FILE" "$CLIENT_ID")
fi

# Notify user of completion
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Upload successful! Response: $response${NC}"
else
    echo -e "${RED}Upload failed!${NC}"
    exit 1
fi
