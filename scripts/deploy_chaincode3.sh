pushd ..
export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/network/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export PEER0_ORG1_CA=${PWD}/network/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export PEER0_ORG2_CA=${PWD}/network/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/network/config
export CHANNEL_NAME=mychannel


setOrdererGlobals() {
  export CORE_PEER_LOCALMSPID="OrdererMSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/network/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
  export CORE_PEER_MSPCONFIGPATH=${PWD}/network/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp
}

setGlobalsForPeer0Org1(){
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/network/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

setGlobalsForPeer0Org2(){
    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/network/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051
}

presetup() {
    pushd ./chaincode/data-marketplace
    GO111MODULE=on go mod vendor
    popd
    echo "===================== Finished vendoring Go dependencies ===================== "
}
#presetup

CHANNEL_NAME="mychannel"
CC_RUNTIME_LANGUAGE="golang"
VERSION="1"
CC_SRC_PATH="./chaincode/data-marketplace"
CC_NAME="data-marketplace"

packageChaincode() {
    rm -rf chaincode/data-marketplace/${CC_NAME}.tar.gz
    setGlobalsForPeer0Org1
    peer lifecycle chaincode package chaincode/data-marketplace/${CC_NAME}.tar.gz \
        --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} \
        --label ${CC_NAME}_${VERSION}
    echo "===================== Chaincode is packaged ===================== "
}
#packageChaincode

installChaincode() {
    setGlobalsForPeer0Org1
    peer lifecycle chaincode install chaincode/data-marketplace/${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.org1 ===================== "

    setGlobalsForPeer0Org2
    peer lifecycle chaincode install chaincode/data-marketplace/${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.org2 ===================== "

}
# installChaincode

queryInstalled() {
    setGlobalsForPeer0Org1
    peer lifecycle chaincode queryinstalled
    echo "===================== Query installed successful on peer0.org1 on channel ===================== "

    setGlobalsForPeer0Org2
    peer lifecycle chaincode queryinstalled >&chaincode/data-marketplace/log.txt
    cat chaincode/data-marketplace/log.txt
    PACKAGE_ID=$(sed -n "/${CC_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" chaincode/data-marketplace/log.txt)
    echo PackageID is ${PACKAGE_ID}
    echo "===================== Query installed successful on peer0.org2 on channel ===================== "
}
#queryInstalled


approveForMyOrg1() {
    setGlobalsForPeer0Org1
    # set -x
    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com --tls \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --init-required --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}
    # set +x

    echo "===================== chaincode approved from org 1 ===================== "

}

#approveForMyOrg1

# --signature-policy "OR ('Org1MSP.member')"
# --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG2_CA
# --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles $PEER0_ORG1_CA --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles $PEER0_ORG2_CA
#--channel-config-policy Channel/Application/Admins
# --signature-policy "OR ('Org1MSP.peer','Org2MSP.peer')"

checkCommitReadyness() {
    setGlobalsForPeer0Org1
    peer lifecycle chaincode checkcommitreadiness \
        --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from org 1 ===================== "
}

 #checkCommitReadyness

# --collections-config ./artifacts/private-data/collections_config.json \
# --signature-policy "OR('Org1MSP.member','Org2MSP.member')" \
approveForMyOrg2() {
    setGlobalsForPeer0Org2

    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --version ${VERSION} --init-required --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}

    echo "===================== chaincode approved from org 2 ===================== "
}

# approveForMyOrg2

checkCommitReadyness() {

    setGlobalsForPeer0Org1
    peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
        --name ${CC_NAME} --version ${VERSION} --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from org 1 ===================== "
}
#approveOrgs

commitChaincodeDefinition() {
    setGlobalsForPeer0Org1
    peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com \
        --tls --cafile $ORDERER_CA \
        --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG2_CA \
        --version ${VERSION} --sequence ${VERSION} --init-required
    echo "===================== Chaincode definition committed ===================== "

#    peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com \
#    --channelID mychannel --name fabcar \
#    --version 1.0 --sequence 1 --tls \
#     --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \
#      --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
#      --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

}

queryCommitted() {
    setGlobalsForPeer0Org1
    peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME}

}

chaincodeInvokeInit() {
  setGlobalsForPeer0Org1
  peer chaincode invoke -o localhost:7050 \
      --ordererTLSHostnameOverride orderer.example.com \
      --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
      -C $CHANNEL_NAME -n ${CC_NAME} \
      --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
      --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG2_CA \
      --isInit -c '{"function":"initLedger","Args":[]}'

}

chaincodeInvoke() {
    # setGlobalsForPeer0Org1
    # peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com \
    # --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n ${CC_NAME} \
    # --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
    # --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG2_CA  \
    # -c '{"function":"initLedger","Args":[]}'

    setGlobalsForPeer0Org1

    ## Create Car
    # peer chaincode invoke -o localhost:7050 \
    #     --ordererTLSHostnameOverride orderer.example.com \
    #     --tls $CORE_PEER_TLS_ENABLED \
    #     --cafile $ORDERER_CA \
    #     -C $CHANNEL_NAME -n ${CC_NAME}  \
    #     --peerAddresses localhost:7051 \
    #     --tlsRootCertFiles $PEER0_ORG1_CA \
    #     --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG2_CA   \
    #     -c '{"function": "createCar","Args":["Car-ABCDEEE", "Audi", "R8", "Red", "Pavan"]}'

    ## Init ledger
    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com \
        --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG2_CA \
        -c '{"function": "initLedger","Args":[]}'

}

# chaincodeInvoke

chaincodeQuery() {
    setGlobalsForPeer0Org2

    # Query all cars
    # peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"Args":["queryAllCars"]}'

    # Query Car by Id
    peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"Args":["QueryAllDataHashes"]}'
    #'{"Args":["GetSampleData","Key1"]}'

    # Query Private Car by Id
    # peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"function": "readPrivateCar","Args":["1111"]}'
    # peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"function": "readCarPrivateDetails","Args":["1111"]}'
}

deployCC(){
  presetup
  packageChaincode
  installChaincode
  queryInstalled
  approveForMyOrg1
  checkCommitReadyness
  approveForMyOrg2
  checkCommitReadyness
  commitChaincodeDefinition
  queryCommitted
  chaincodeInvokeInit
  sleep 5
  chaincodeInvoke
  sleep 3
  chaincodeQuery
}

deployCC
#presetup
#packageChaincode
#installChaincode
#queryInstalled
#approveOrgs
#checkCommitReadyness
#commitChaincodeDefinition
#queryCommitted
#chaincodeInvokeInit
#sleep 5
#chaincodeInvoke
#sleep 3
#chaincodeQuery
popd
