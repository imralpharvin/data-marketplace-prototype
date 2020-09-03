package main

import (
	"encoding/json"
	"fmt"
  "strings"
	"time"

	"github.com/hyperledger/fabric-chaincode-go/shim"
	sc "github.com/hyperledger/fabric-protos-go/peer"
)

//Transaction Struct
type Transaction struct {
	ObjectType		string  `json:"docType"`
	Hash 					string 	`json:"hash"`
	Seller 				string  `json:"seller"`
	Buyer 			 	string 	`json:"buyer"`
	DateTime 		  string  `json:"dateTime"`
}

func PutTransaction(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	transactionKey := args[0] + "_" + args[1] + "_" + args[2]

	transactionAsBytes, err := APIstub.GetState(transactionKey)
	if err != nil {
		return shim.Error("Failed to get transaction: " + err.Error())
	} else if transactionAsBytes != nil {
		fmt.Println("This transaction already exists: " + transactionKey)
		return shim.Error("This transaction already exists: " + transactionKey)
	}

	t := time.Now()

	transaction := Transaction{
		ObjectType: "transaction",
		Hash: args[0],
		Seller: args[1],
		Buyer: args[2],
		DateTime: t.Format("2006-01-02 15:04:05"),
	}

	transactionJSONAsBytes, _ := json.Marshal(transaction)

  APIstub.PutState(transactionKey, transactionJSONAsBytes)

	return shim.Success(transactionJSONAsBytes)
}

func GetTransactionsByHash(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
	if len(args) < 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	hash := strings.ToLower(args[0])

	queryString := fmt.Sprintf("{\"selector\":{\"docType\":\"transaction\",\"hash\":\"%s\"}}", hash)

	queryResults, err := getQueryResultForQueryString(APIstub, queryString)
	if err != nil {
		return shim.Error(err.Error())
	}
	return shim.Success(queryResults)
}

func GetTransactionsBySeller(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
	if len(args) < 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	seller := strings.ToLower(args[0])

	queryString := fmt.Sprintf("{\"selector\":{\"docType\":\"transaction\",\"seller\":\"%s\"}}", seller)

	queryResults, err := getQueryResultForQueryString(APIstub, queryString)
	if err != nil {
		return shim.Error(err.Error())
	}
	return shim.Success(queryResults)
}

func GetTransactionsByBuyer(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
	if len(args) < 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	buyer := strings.ToLower(args[0])

	queryString := fmt.Sprintf("{\"selector\":{\"docType\":\"transaction\",\"buyer\":\"%s\"}}", buyer)

	queryResults, err := getQueryResultForQueryString(APIstub, queryString)
	if err != nil {
		return shim.Error(err.Error())
	}
	return shim.Success(queryResults)
}
