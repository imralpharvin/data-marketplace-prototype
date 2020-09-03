/*package main

import (
	"encoding/json"
	"fmt"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)



//Account Struct
type Account struct {
	ObjectType		string  `json:"docType"`
	Name 					string 	`json:"name"`
	Organization 	string 	`json:"organization"`
	EmployeeID	  int 		`json:"employeeID"`
	Balance			 	int 		`json:"balance"`
}

func PutAccount(ctx contractapi.TransactionContextInterface, username string, name string, organization string, employeeID int, balance int) error {

	account := Account{
		ObjectType: "account",
		Name:   name,
		Organization:  organization,
		EmployeeID: employeeID,
		Balance: balance,

	}

	accountAsBytes, _ := json.Marshal(account)

	return ctx.GetStub().PutState(username, accountAsBytes)
}

func GetAccount(ctx contractapi.TransactionContextInterface, username string) (*Account, error) {
	accountAsBytes, err := ctx.GetStub().GetState(username)

	if err != nil {
		return nil, fmt.Errorf("Failed to read from world state. %s", err.Error())
	}

	if accountAsBytes == nil {
		return nil, fmt.Errorf("%s does not exist", username)
	}

	account := new(Account)
	_ = json.Unmarshal(accountAsBytes, account)

	return account, nil
}*/
