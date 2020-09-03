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

    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com --tls \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}

    echo "===================== chaincode approved from org 1 ===================== "

}

#approveForMyOrg1

checkCommitReadyness() {
    setGlobalsForPeer0Org1
    peer lifecycle chaincode checkcommitreadiness \
        --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --sequence ${VERSION} --output json
    echo "===================== checking commit readyness from org 1 ===================== "
}

 #checkCommitReadyness

approveForMyOrg2() {
    setGlobalsForPeer0Org2

    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --version ${VERSION} --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}

    echo "===================== chaincode approved from org 2 ===================== "
}

# approveForMyOrg2

checkCommitReadyness() {

    setGlobalsForPeer0Org1
    peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
        --name ${CC_NAME} --version ${VERSION} --sequence ${VERSION} --output json
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
        --version ${VERSION} --sequence ${VERSION}
    echo "===================== Chaincode definition committed ===================== "
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
      -c '{"Args":["CreateAccount","ralph", "Ralph Arvin", "Banana","989898"]}'

  sleep 2

  setGlobalsForPeer0Org1
  peer chaincode invoke -o localhost:7050 \
      --ordererTLSHostnameOverride orderer.example.com \
      --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
      -C $CHANNEL_NAME -n ${CC_NAME} \
      --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
      --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG2_CA \
      -c '{"Args":["CreateAccount","john", "John Doe", "Carrot","9898966"]}'

  sleep 2

  setGlobalsForPeer0Org1
  peer chaincode invoke -o localhost:7050 \
      --ordererTLSHostnameOverride orderer.example.com \
      --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
      -C $CHANNEL_NAME -n ${CC_NAME} \
      --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
      --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG2_CA \
      -c '{"Args":["CreateAccount","karen", "Karen Milton", "Don","19898966"]}'

  sleep 2

  setGlobalsForPeer0Org1
  peer chaincode invoke -o localhost:7050 \
      --ordererTLSHostnameOverride orderer.example.com \
      --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
      -C $CHANNEL_NAME -n ${CC_NAME} \
      --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
      --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG2_CA \
      -c '{"Args":["CreateAccount","emily", "Emily Rogers", "Apple","93898966"]}'

  sleep 2

  setGlobalsForPeer0Org1
  peer chaincode invoke -o localhost:7050 \
      --ordererTLSHostnameOverride orderer.example.com \
      --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
      -C $CHANNEL_NAME -n ${CC_NAME} \
      --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
      --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG2_CA \
      -c '{"Args":["CreateDataHash","Movie", "123", "Comedy","emily", "12"]}'

  sleep 2

  setGlobalsForPeer0Org1
  peer chaincode invoke -o localhost:7050 \
      --ordererTLSHostnameOverride orderer.example.com \
      --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
      -C $CHANNEL_NAME -n ${CC_NAME} \
      --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
      --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG2_CA \
      -c '{"Args":["UpdateDataHashForSale", "123"]}'


  sleep 2

  setGlobalsForPeer0Org1
  peer chaincode invoke -o localhost:7050 \
      --ordererTLSHostnameOverride orderer.example.com \
      --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
      -C $CHANNEL_NAME -n ${CC_NAME} \
      --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
      --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG2_CA \
      -c '{"Args":["CreateDataHash","Document", "abc", "Microsoft Word","ralph", "100"]}'

  sleep 2

  setGlobalsForPeer0Org1
  peer chaincode invoke -o localhost:7050 \
      --ordererTLSHostnameOverride orderer.example.com \
      --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
      -C $CHANNEL_NAME -n ${CC_NAME} \
      --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
      --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG2_CA \
      -c '{"Args":["UpdateDataHashForSale", "abc"]}'
  echo "===================== Ledger Initiated ===================== "

}

chaincodeInvokeCreate() {
    setGlobalsForPeer0Org1
    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com \
        --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG2_CA \
        -c '{"function": "CreateDataHash","Args":["DATAHASH5", "Amy", "excel.sheet"]}'

    echo "===================== Added new datahash ===================== "

}

chaincodeInvokeChangeAccount() {
    setGlobalsForPeer0Org1
    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com \
        --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG2_CA \
        -c '{"function": "ChangeDataHashAccount","Args":["DATAHASH5", "Aaron"]}'

    echo "===================== Added new datahash ===================== "

}

# chaincodeInvoke

chaincodeQueryAllAccounts() {
    setGlobalsForPeer0Org2
    peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"Args":["QueryAllAccounts"]}'
    echo "===================== Queried All Datahashes ===================== "

}

chaincodeQueryDataHash() {
    setGlobalsForPeer0Org2
    peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"Args":["QueryDataHash","DATAHASH5"]}'
    echo "===================== Query a car ===================== "


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
  #chaincodeQueryAllDataHashes
  #sleep 3
  #chaincodeInvokeCreate
  #sleep 3
  #chaincodeQueryAllAccounts
  #sleep 3
  #chaincodeInvokeChangeAccount
  #sleep 3
#  chaincodeQueryDataHash
  #sleep 3
#  chaincodeQueryAllDataHashes
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
##chaincodeQueryAllDataHashes
#sleep 3
#chaincodeInvokeCreate
#sleep 3
#chaincodeQueryAllDataHashes
#sleep 3
#chaincodeInvokeChangeAccount
#sleep 3
#chaincodeQueryDataHash
#sleep 3
#chaincodeQueryAllDataHashes

popd
