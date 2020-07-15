package resources

import (
	"encoding/json"
	"fmt"
	"strconv"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

//Account Struct
type Account struct {
	Name 					string 	`json:"name"`
	Organization 	string 	`json:"organization"`
	Balance			 	int 		`json:"balance"`
}

func CreateAccount(ctx contractapi.TransactionContextInterface, accountNumber string, name string, organization string, balance int) error {
	account := Account{
		Name:   name,
		Organization:  organization,
		Balance: balance,
	}

	accountAsBytes, _ := json.Marshal(account)

	return ctx.GetStub().PutState(accountNumber, accountAsBytes)
}
