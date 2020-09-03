/*package main

import (
	"encoding/json"
	//"fmt"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

//DataHash Struct
type DataHash struct {
	ObjectType		string  `json:"docType"`
	Title 				string  `json:"hash"`
	Hash 					string 	`json:"hash"`
	Description 	string 	`json:"description"`
	Owner				  string 	`json:"owner"`
	Price				 	int 		`json:"price"`
	OnMarketPlace	bool		`json:"onmarketplace"`
}

func PutDataHash(ctx contractapi.TransactionContextInterface, title string, hash string, description string, owner string, price int, onmarketplace bool) error {

	datahash := DataHash{
		ObjectType: "datahash",
		Title: title,
		Hash: hash,
		Description: description,
		Owner: owner,
		Price: price,
		OnMarketPlace: onmarketplace,
	}

	datahashAsBytes, _ := json.Marshal(datahash)

	datahashKey := "DH_" + owner + "_" + title

	return ctx.GetStub().PutState(datahashKey, datahashAsBytes)
}*/
