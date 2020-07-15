package main

import (
	"encoding/json"
	"fmt"
	"strconv"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	"github.com/imralpharvin/data-marketplace-prototype/chaincode/data-marketplace/resources"
)

type DataMarketplaceContract struct {
	contractapi.Contract
}

//Account Query Result
type AccountQueryResult struct {
	Key    string `json:"Key"`
	Record *Account
}
//Accoun Struct

/*
type DataHash struct {
	Hash  			string `json:"hash"`
	Description string `json:"description"`
	Keyword 		string `json:"keyword"`
	Account 		string `json:"account"`
	DataForSale bool `json:"dataforsale"`
	Price 			int `json:"price"`
}



//DataHash Struct


//DataHash Query Result
type DataHashQueryResult struct {
	Key    string `json:"Key"`
	Record *DataHash
}*/

func (s *DataMarketplaceContract) InitAccountLedger(ctx contractapi.TransactionContextInterface) error{
	accounts := []Account{
		Account{Name: "Ralph", Organization: "Org1", Balance: 1000},
		Account{Name: "John", Organization: "Org2", Balance: 10020},
		Account{Name: "Amy", Organization: "Org1", Balance: 10200},
		Account{Name: "Ben", Organization: "Org2", Balance: 100},
	}

	for i, account := range accounts {
		accountAsBytes, _ := json.Marshal(account)
		err := ctx.GetStub().PutState("ACCOUNT"+strconv.Itoa(i), accountAsBytes)

		if err != nil {
			return fmt.Errorf("Failed to put to world state. %s", err.Error())
		}
	}

	return nil
}

/*func (s *DataMarketplaceContract) register(ctx contractapi.TransactionContextInterface)*/

func (s *DataMarketplaceContract) QueryAllAccounts(ctx contractapi.TransactionContextInterface) ([]AccountQueryResult, error) {
	startKey := ""
	endKey := ""

	resultsIterator, err := ctx.GetStub().GetStateByRange(startKey, endKey)

	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	results := []AccountQueryResult{}

	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()

		if err != nil {
			return nil, err
		}

		account := new(Account)
		_ = json.Unmarshal(queryResponse.Value, account)

		queryResult := AccountQueryResult{Key: queryResponse.Key, Record: account}
		results = append(results, queryResult)
	}

	return results, nil
}

/*
func (s *DataHashContract) InitLedger(ctx dhc.TransactionContextInterface) error{
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

func (s *DataHashContract) CreateDataHash(ctx dhc.TransactionContextInterface, datahashNumber string, account string, hash string) error {
	datahash := DataHash{
		Account:   account,
		Hash:  hash,
	}

	datahashAsBytes, _ := json.Marshal(datahash)

	return ctx.GetStub().PutState(datahashNumber, datahashAsBytes)
}

func (s *DataHashContract) QueryDataHash(ctx dhc.TransactionContextInterface, datahashNumber string) (*DataHash, error) {
	datahashAsBytes, err := ctx.GetStub().GetState(datahashNumber)

	if err != nil {
		return nil, fmt.Errorf("Failed to read from world state. %s", err.Error())
	}

	if datahashAsBytes == nil {
		return nil, fmt.Errorf("%s does not exist", datahashNumber)
	}

	datahash := new(DataHash)
	_ = json.Unmarshal(datahashAsBytes, datahash)

	return datahash, nil
}*/
/*
func (s *DataHashContract) QueryAllDataHashes(ctx dhc.TransactionContextInterface) ([]DataHashQueryResult, error) {
	startKey := ""
	endKey := ""

	resultsIterator, err := ctx.GetStub().GetStateByRange(startKey, endKey)

	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	results := []DataHashQueryResult{}

	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()

		if err != nil {
			return nil, err
		}

		datahash := new(DataHash)
		_ = json.Unmarshal(queryResponse.Value, datahash)

		queryResult := DataHashQueryResult{Key: queryResponse.Key, Record: datahash}
		results = append(results, queryResult)
	}

	return results, nil
}*/

/*
func (s *DataHashContract) ChangeDataHashAccount(ctx dhc.TransactionContextInterface, datahashNumber string, newAccount string) error {
	datahash, err := s.QueryDataHash(ctx, datahashNumber)

	if err != nil {
		return err
	}

	datahash.Account = newAccount

	datahashAsBytes, _ := json.Marshal(datahash)

	return ctx.GetStub().PutState(datahashNumber, datahashAsBytes)
}*/


func main() {

	chaincode, err := contractapi.NewChaincode(new(DataMarketplaceContract))

	if err != nil {
		fmt.Printf("Error create data marketplace chaincode: %s", err.Error())
		return
	}

	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting data marketplace chaincode: %s", err.Error())
	}
}
