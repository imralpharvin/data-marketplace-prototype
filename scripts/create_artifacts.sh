# Create artifacts for orderer
echo "#######    Creating artifacts for orderer node  ##########"
cryptogen generate --config=../config/crypto-config-orderer.yaml --output=../artifacts/
echo "===================== Created artifacts for orderer node ====================="
# Create artifacts for organizations
echo "#######    Creating artifacts for organizations and peer nodes ##########"
cryptogen generate --config=../config/crypto-config-orgs.yaml --output=../artifacts/
echo "================== Created artifacts for organizations and peer nodes =================="

# Generate System Genesis block
echo "#######    Generating system genesis block  ##########"
configtxgen -profile OrdererGenesis -configPath ../config/ -channelID sys-channel -outputBlock ../artifacts/genesis.block
echo "===================== Generated system genesis block ===================== "
# Generate channel configuration block
echo "#######    Generating channel configuration block  ##########"
configtxgen -profile BasicChannel -configPath ../config/ -outputCreateChannelTx ../artifacts/mychannel.tx -channelID mychannel
echo "===================== Generated channel configuration block ===================== "


echo "#######    Generating anchor peer update for Org1MSP  ##########"
configtxgen -profile BasicChannel -configPath ../config/ -outputAnchorPeersUpdate ../artifacts/Org1MSPanchors.tx -channelID mychannel -asOrg Org1MSP
echo "===================== Generated anchor peer update for Org1MSP ===================== "
echo "#######    Generating anchor peer update for Org2MSP  ##########"
configtxgen -profile BasicChannel -configPath ../config/ -outputAnchorPeersUpdate ../artifacts/Org2MSPanchors.tx -channelID mychannel -asOrg Org2MSP
echo "===================== Generated anchor peer update for Org2MSP ===================== "
