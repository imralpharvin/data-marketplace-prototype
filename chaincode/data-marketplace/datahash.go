package main

import (
	"encoding/json"
	"fmt"
	"strconv"
  "strings"

	"github.com/hyperledger/fabric-chaincode-go/shim"
	sc "github.com/hyperledger/fabric-protos-go/peer"
)

//DataHash Struct
type DataHash struct {
	ObjectType		string  `json:"docType"`
	Title 				string  `json:"title"`
	Hash 					string 	`json:"hash"`
	Description 	string 	`json:"description"`
	Owner				  string 	`json:"owner"`
	Price				 	int 		`json:"price"`
	ForSale       bool		`json:"forsale"`
}

func PutDataHash(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	datahashAsBytes, err := APIstub.GetState(args[1])
	if err != nil {
		return shim.Error("Failed to get datahash: " + err.Error())
	} else if datahashAsBytes != nil {
		fmt.Println("This datahash already exists: " + args[1])
		return shim.Error("This datahash already exists: " + args[1])
	}

  priceInt, err := strconv.Atoi(args[4])
  if err == nil {
    fmt.Println(priceInt)
  }

	datahash := DataHash{
		ObjectType: "datahash",
		Title: args[0],
		Hash: args[1],
		Description: args[2],
		Owner: args[3],
		Price: priceInt,
		ForSale: false,
	}

	datahashJSONAsBytes, _ := json.Marshal(datahash)

	datahashKey := args[1]
  APIstub.PutState(datahashKey, datahashJSONAsBytes)

	return shim.Success(datahashAsBytes)
}

func GetDataHashesByOwner(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
	if len(args) < 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	owner := strings.ToLower(args[0])

	queryString := fmt.Sprintf("{\"selector\":{\"docType\":\"datahash\",\"owner\":\"%s\"}}", owner)

	queryResults, err := getQueryResultForQueryString(APIstub, queryString)
	if err != nil {
		return shim.Error(err.Error())
	}
	return shim.Success(queryResults)
}

func GetDataHashesByForSale(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
	if len(args) < 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	forsale := strings.ToLower(args[0])

	queryString := fmt.Sprintf("{\"selector\":{\"docType\":\"datahash\",\"forsale\":%s}}", forsale)

	queryResults, err := getQueryResultForQueryString(APIstub, queryString)
	if err != nil {
		return shim.Error(err.Error())
	}
	return shim.Success(queryResults)
}

func ChangeDataHashForSale(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
	if len(args) < 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	datahashKey := args[0]

	datahashAsBytes, err := APIstub.GetState(datahashKey)
	if err != nil {
		return shim.Error("Failed to get datahash:" + err.Error())
	} else if datahashAsBytes == nil {
		return shim.Error("Datahash does not exist")
	}

	datahashToChange := DataHash{}
	err = json.Unmarshal(datahashAsBytes, &datahashToChange) //unmarshal it aka JSON.parse()
	if err != nil {
		return shim.Error(err.Error())
	}

	tof := datahashToChange.ForSale
	if tof == true {
		datahashToChange.ForSale = false
	} else if tof == false{
		datahashToChange.ForSale = true //change the owner
	}

	datahashJSONasBytes, _ := json.Marshal(datahashToChange)
	err = APIstub.PutState(datahashKey,datahashJSONasBytes) //rewrite the marble
	if err != nil {
		return shim.Error(err.Error())
	}

//	fmt.Println("- end transferMarble (success)")
	return shim.Success(nil)

}

func ChangeDataHashOwner(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
	if len(args) < 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2")
	}

	datahashKey := args[0]

	datahashAsBytes, err := APIstub.GetState(datahashKey)
	if err != nil {
		return shim.Error("Failed to get datahash:" + err.Error())
	} else if datahashAsBytes == nil {
		return shim.Error("Datahash does not exist")
	}

	datahashToChange := DataHash{}
	err = json.Unmarshal(datahashAsBytes, &datahashToChange) //unmarshal it aka JSON.parse()
	if err != nil {
		return shim.Error(err.Error())
	}

	datahashToChange.Owner = args[2]
	datahashJSONasBytes, _ := json.Marshal(datahashToChange)
	err = APIstub.PutState(datahashKey,datahashJSONasBytes) //rewrite the marble
	if err != nil {
		return shim.Error(err.Error())
	}

//	fmt.Println("- end transferMarble (success)")
	return shim.Success(nil)

}
