package main

import (
	"encoding/json"
	"fmt"
	"strconv"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

type SmartContract struct {
	contractapi.Contract
}

type DataHash struct {
	Account string `json:"account"`
	Hash  string `json:"hash"`
}

type QueryResult struct {
	Key    string `json:"Key"`
	Record *DataHash
}


func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error{
	datahashes := []DataHash{
		DataHash{Account: "Ralph", Hash: "file.txt"},
		DataHash{Account: "John", Hash: "money.dollar"},
		DataHash{Account: "Mary", Hash: "song.mp3"},
		DataHash{Account: "Emily", Hash: "google.doc"},
	}

	for i, datahash := range datahashes {
		datahashAsBytes, _ := json.Marshal(datahash)
		err := ctx.GetStub().PutState("DATAHASH"+strconv.Itoa(i), datahashAsBytes)

		if err != nil {
			return fmt.Errorf("Failed to put to world state. %s", err.Error())
		}
	}

	return nil
}

func (s *SmartContract) QueryAllDataHashes(ctx contractapi.TransactionContextInterface) ([]QueryResult, error) {
	startKey := ""
	endKey := ""

	resultsIterator, err := ctx.GetStub().GetStateByRange(startKey, endKey)

	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	results := []QueryResult{}

	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()

		if err != nil {
			return nil, err
		}

		datahash := new(DataHash)
		_ = json.Unmarshal(queryResponse.Value, datahash)

		queryResult := QueryResult{Key: queryResponse.Key, Record: datahash}
		results = append(results, queryResult)
	}

	return results, nil
}

func main() {

	chaincode, err := contractapi.NewChaincode(new(SmartContract))

	if err != nil {
		fmt.Printf("Error create fabcar chaincode: %s", err.Error())
		return
	}

	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting fabcar chaincode: %s", err.Error())
	}
}
