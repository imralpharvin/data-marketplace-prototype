pushd ..
# Delete existing network

#Remove fabric-ca artifactss
sudo rm -rf network/organizations/fabric-ca/org1/msp network/organizations/fabric-ca/org1/tls-cert.pem network/organizations/fabric-ca/org1/ca-cert.pem network/organizations/fabric-ca/org1/IssuerPublicKey network/organizations/fabric-ca/org1/IssuerRevocationPublicKey network/organizations/fabric-ca/org1/fabric-ca-server.db
sudo rm -rf network/organizations/fabric-ca/org2/msp network/organizations/fabric-ca/org2/tls-cert.pem network/organizations/fabric-ca/org2/ca-cert.pem network/organizations/fabric-ca/org2/IssuerPublicKey network/organizations/fabric-ca/org2/IssuerRevocationPublicKey network/organizations/fabric-ca/org2/fabric-ca-server.db
sudo rm -rf network/organizations/fabric-ca/ordererOrg/msp network/organizations/fabric-ca/ordererOrg/tls-cert.pem network/organizations/fabric-ca/ordererOrg/ca-cert.pem network/organizations/fabric-ca/ordererOrg/IssuerPublicKey network/organizations/fabric-ca/ordererOrg/IssuerRevocationPublicKey network/organizations/fabric-ca/ordererOrg/fabric-ca-server.db

rm -rf network/organizations/peerOrganizations
rm -rf network/organizations/ordererOrganizations
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

#delete api modules
rm -rf app/users/*
rm -rf app/wallet/*

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
docker-compose -f network/config/docker-compose-ca.yaml down --volumes --remove-orphans
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
removeUnwantedImages
popd
