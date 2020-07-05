pushd ./scripts

./clean_network.sh
sleep 3
./create_artifacts.sh
sleep 3
./create_network.sh
sleep 3
./create_channel.sh
sleep 3
./deploy_chaincode3.sh

popd
