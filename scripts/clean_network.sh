pushd ..
# Delete existing artifacts
#rm -rf ./artifacts
rm -rf network/channel/crypto-config
rm network/channel/genesis.block
rm network/channel/mychannel.tx
rm network/channel/Org1MSPanchors.tx
rm network/channel/Org2MSPanchors.tx
rm -rf channel-artifacts/*
rm fabcar.tar.gz
rm -rf ./chaincode/fabcar/vendor
rm log.txt

removeUnwantedImages() {
  DOCKER_IMAGE_IDS=$(docker images | awk '($1 ~ /dev-peer.*/) {print $3}')
  if [ -z "$DOCKER_IMAGE_IDS" -o "$DOCKER_IMAGE_IDS" == " " ]; then
    echo "---- No images available for deletion ----"
  else
    docker rmi -f $DOCKER_IMAGE_IDS
  fi
}

#remove all containers and images
docker-compose -f network/docker-compose.yaml down --volumes --remove-orphans
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
removeUnwantedImages
popd
