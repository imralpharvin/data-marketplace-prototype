package main

import (
	"encoding/json"
	"fmt"
	"strconv"

	"github.com/hyperledger/fabric-chaincode-go/shim"
	sc "github.com/hyperledger/fabric-protos-go/peer"
)



//Account Struct
type Account struct {
	ObjectType		string  `json:"docType"`
	Name 					string 	`json:"name"`
	Organization 	string 	`json:"organization"`
	EmployeeID	  int 		`json:"employeeID"`
	Balance			 	int 		`json:"balance"`
}

func PutAccount(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 4 {
		return shim.Error("Incorrect number of arguments. Expecting 4")
	}
	employeeIDint, err := strconv.Atoi(args[3])
	if err == nil {
		fmt.Println(employeeIDint)
	}

	account := Account{
		ObjectType: "account",
		Name:   args[1],
		Organization:  args[2],
		EmployeeID: employeeIDint,
		Balance: 1000,

	}

	accountAsBytes, _ := json.Marshal(account)
	APIstub.PutState(args[0], accountAsBytes)

	return shim.Success(accountAsBytes)
}

func GetAccount(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	accountAsBytes, _ := APIstub.GetState(args[0])
	return shim.Success(accountAsBytes)
}

func ChangeAccountBalance(APIstub shim.ChaincodeStubInterface, username string, balance int) sc.Response {

	accountKey := username

	accountAsBytes, err := APIstub.GetState(accountKey)
	if err != nil {
		return shim.Error("Failed to get account:" + err.Error())
	} else if accountAsBytes == nil {
		return shim.Error("Account does not exist")
	}

	accountToChange := Account{}
	err = json.Unmarshal(accountAsBytes, &accountToChange) //unmarshal it aka JSON.parse()
	if err != nil {
		return shim.Error(err.Error())
	}

	accountToChange.Balance = balance
	accountJSONasBytes, _ := json.Marshal(accountToChange)
	err = APIstub.PutState(accountKey,accountJSONasBytes) //rewrite the marble
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success(nil)

}
