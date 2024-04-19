#!/bin/bash

NEXUS_URL=http://35.85.147.67:8081
MAVEN_REPO=mongo-releases
GROUP_ID=com.mt
ARTIFACT_ID=spring-boot-mongo
VERSION=1.0
FILE_EXTENSION=jar

# Function to extract the timestamp from the download URL
extract_timestamp() {
    url="$1"
    timestamp=$(echo "$url" | grep -oE '[0-9]{8}\.[0-9]{6}-[0-9]+')
    echo "$timestamp"
}

# Get the download URLs
urls=$(curl -s --user admin:admin -X GET "${NEXUS_URL}/service/rest/v1/search/assets?repository=${MAVEN_REPO}&maven.groupId=${GROUP_ID}&maven.artifactId=${ARTIFACT_ID}&maven.baseVersion=${VERSION}&maven.extension=${FILE_EXTENSION}" -H  "accept: application/json"  | jq -rc '.items | .[].downloadUrl')

# Initialize variables to hold the latest timestamp and URL
latest_timestamp=""
latest_url=""

# Loop through each URL
while IFS= read -r url; do
    timestamp=$(extract_timestamp "$url")
    # Compare timestamps
    if [[ -z $latest_timestamp || $timestamp > $latest_timestamp ]]; then
        latest_timestamp=$timestamp
        latest_url=$url
    fi
done <<< "$urls"

echo "Latest URL: $latest_url"

final_url=$latest_url' --http-user=admin --http-password=admin'

wget $final_url
