#!/bin/bash

if [ $# -lt 4 ]
then
cat << HELP

This tool will pull, tag, push and update the deployment file.
Use with caution (if you have more than 1 images with similar image ids, it'll replace all of them!!)

usage: ./deployer.sh [deployment-file] [docker-org] [docker-repo] [build-docker-Image] [output-version] [gradual (optional)]
i.e. ./deployer.sh staging.json orbsnetworkstaging vm-twap v1.0.0-a14ff39d v1.0.10 true

HELP

else

deploymentFile="$1"
dockerOrg="$2"
dockerRepo="$3"
buildDockerImage="$4"
version="$5"

# Optional argument
gradual=''
immediate=''

if [ $# -gt 5 ]; then
    gradual=$6

    if [ "$gradual" != "true" ]; then
       immediate='-immediate'
    fi

fi

echo "pulling buildDockerImage ${buildDockerImage} from ${dockerRepo}"
docker pull ${dockerOrg}/${dockerRepo}:${buildDockerImage}
echo "tagging buildDockerImage ${buildDockerImage} ==> ${version}${immediate}"
docker tag ${dockerOrg}/${dockerRepo}:${buildDockerImage} ${dockerOrg}/${dockerRepo}:${version}${immediate}
echo "pushing buildDockerImage ${dockerOrg}/${dockerRepo}:${version}${immediate}"
docker push ${dockerOrg}/${dockerRepo}:${version}${immediate}

echo "modifying ${deploymentFile} to include the new image version"
sed "s/${dockerOrg}\/${dockerRepo}:.*\"/${dockerOrg}\/${dockerRepo}:${version}${immediate}\"/g" ${deploymentFile} > ${deploymentFile}_temp && mv ${deploymentFile}_temp ${deploymentFile}

echo "done! in order to deploy, commit and push the changes to github..."

fi
