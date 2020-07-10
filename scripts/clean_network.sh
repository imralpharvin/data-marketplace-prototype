pushd ..
# Delete existing network
#rm -rf ./network
#rm network/channel/genesis.block
#rm network/channel/mychannel.tx
#rm network/channel/Org1MSPanchors.tx
#rm network/channel/Org2MSPanchors.tx
#rm -rf channel-network/*
#rm fabcar.tar.gz
#rm -rf ./chaincode/fabcar/vendor
#rm log.txt

rm -rf network/organizations/*
rm network/artifacts/genesis.block network/channel/mychannel.tx network/channel/mychannel.block
rm network/channel/Org1MSPanchors.tx network/channel/Org2MSPanchors.tx
#Remove fabcar 1 components
rm chaincode/fabcar/fabcar.tar.gz
rm chaincode/fabcar/log.txt
rm -rf ./chaincode/fabcar/vendor

#Remove fabcar 2 components
rm chaincode/fabcar2/fabcar2.tar.gz
rm chaincode/fabcar2/log.txt
rm -rf ./chaincode/fabcar2/vendor

#Remove data-marketplace components
rm chaincode/data-marketplace/data-marketplace.tar.gz
rm chaincode/data-marketplace/log.txt
rm -rf ./chaincode/data-marketplace/vendor

removeUnwantedImages() {
  DOCKER_IMAGE_IDS=$(docker images | awk '($1 ~ /dev-peer.*/) {print $3}')
  if [ -z "$DOCKER_IMAGE_IDS" -o "$DOCKER_IMAGE_IDS" == " " ]; then
    echo "---- No images available for deletion ----"
  else
    docker rmi -f $DOCKER_IMAGE_IDS
  fi
}

#remove all containers and images
docker-compose -f network/config/docker-compose.yaml down --volumes --remove-orphans
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
removeUnwantedImages
popd
