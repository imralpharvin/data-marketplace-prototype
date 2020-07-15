pushd ./scripts

./clean_network.sh
sleep 3
./create_ca.sh
sleep 3
./create_network.sh
sleep 3
./create_channel.sh
sleep 3
./deploy_chaincode2.sh

popd
