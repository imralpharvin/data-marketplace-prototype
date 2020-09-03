package main

import (
	"encoding/json"
	"fmt"
	"strconv"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
//	"github.com/hyperledger/fabric-chaincode-go/shim"
//	pb "github.com/hyperledger/fabric-protos-go/peer"
)

type DataMarketplaceContract struct {
	contractapi.Contract
}
//Account Query Result
type AccountQueryResult struct {
	Key    string `json:"Key"`
	Record *Account
}

//DataHash Struct

//DataHash Query Result
type DataHashQueryResult struct {
	Key    string `json:"Key"`
	Record *DataHash
}

func (s * DataMarketplaceContract) RegisterAccount(ctx contractapi.TransactionContextInterface, username string, name string, organization string, employeeID string) error {

	employeeIDint, err := strconv.Atoi(employeeID)
	if err == nil {
		fmt.Println(employeeIDint)
	}

	return PutAccount(ctx, username, name, organization, employeeIDint, 1000)
}

func (s * DataMarketplaceContract) AddDataHash(ctx contractapi.TransactionContextInterface,  title string, hash string, description string, owner string, price string) error {

	priceInt, err := strconv.Atoi(price)
	if err == nil {
		fmt.Println(priceInt)
	}

	return PutDataHash(ctx, title, hash, description, owner, priceInt, false)
}

func (s * DataMarketplaceContract) QueryAccount(ctx contractapi.TransactionContextInterface, username string) (*Account, error) {

	return GetAccount(ctx, username)

}

func (s * DataMarketplaceContract) QueryDataHashByOwner(ctx contractapi.TransactionContextInterface, username string) (*Account, error) {

	return GetAccount(ctx, username)

}

/*func (s *DataMarketplaceContract) queryDataHashByOwner(ctx contractapi.TransactionContextInterface, owner string) pb.Response {

	queryString := fmt.Sprintf("{\"selector\":{\"docType\":\"datahash\",\"owner\":\"%s\"}}", owner)

	queryResults, err := getQueryResultForQueryString(ctx.GetStub(), queryString)
	if err != nil {
		return shim.Error(err.Error())
	}
	return shim.Success(queryResults)
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
