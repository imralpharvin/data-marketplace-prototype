# Delete existing artifacts
rm -rf ./artifacts
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
docker-compose -f ./config/docker-compose.yaml down --volumes --remove-orphans
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
removeUnwantedImages
