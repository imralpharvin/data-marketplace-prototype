# Create artifacts for orderer
cryptogen generate --config=./config/crypto-config-orderer.yaml --output=./artifacts/
# Create artifacts for organizations
cryptogen generate --config=./config/crypto-config-orgs.yaml --output=./artifacts/
# Generate System Genesis block
configtxgen -profile OrdererGenesis -configPath ./config/ -channelID sys-channel -outputBlock ./artifacts/genesis.block
# Generate channel configuration block
configtxgen -profile BasicChannel -configPath ./config/ -outputCreateChannelTx ./artifacts/mychannel.tx -channelID mychannel

echo "#######    Generating anchor peer update for Org1MSP  ##########"
configtxgen -profile BasicChannel -configPath ./config/ -outputAnchorPeersUpdate ./artifacts/Org1MSPanchors.tx -channelID mychannel -asOrg Org1MSP
echo "#######    Generating anchor peer update for Org2MSP  ##########"
configtxgen -profile BasicChannel -configPath ./config/ -outputAnchorPeersUpdate ./artifacts/Org2MSPanchors.tx -channelID mychannel -asOrg Org2MSP
echo "#######    Generating anchor peer update for Org1MSP  ##########"
configtxgen -profile BasicChannel -configPath ./config/ -outputAnchorPeersUpdate ./artifacts/Org3MSPanchors.tx -channelID mychannel -asOrg Org3MSP
echo "#######    Generating anchor peer update for Org2MSP  ##########"
configtxgen -profile BasicChannel -configPath ./config/ -outputAnchorPeersUpdate ./artifacts/Org4MSPanchors.tx -channelID mychannel -asOrg Org4MSP
