# Create artifacts for orderer
echo "#######    Creating artifacts for orderer and peer nodes  ##########"
cryptogen generate --config=../config/crypto-config.yaml --output=../artifacts/
echo "===================== Created artifacts for orderer and peer nodes ====================="

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
