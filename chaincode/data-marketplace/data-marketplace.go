package main

import (
	"encoding/json"
	"fmt"

	"github.com/hyperledger/fabric-chaincode-go/shim"
	sc "github.com/hyperledger/fabric-protos-go/peer"

)

type DataMarketplaceContract struct {
}

func (s *DataMarketplaceContract) Init(APIstub shim.ChaincodeStubInterface) sc.Response {
	return shim.Success(nil)
}

func (s *DataMarketplaceContract) Invoke(APIstub shim.ChaincodeStubInterface) sc.Response {
	function, args := APIstub.GetFunctionAndParameters()

	switch function {
	case "CreateAccount":
		return s.CreateAccount(APIstub, args)
	case "QueryAccount":
		return s.QueryAccount(APIstub, args)
	case "CreateDataHash":
		return s.CreateDataHash(APIstub, args)
	case "QueryDataHashesByOwner":
		return s.QueryDataHashesByOwner(APIstub, args)
	case "QueryDataHashesByForSale":
		return s.QueryDataHashesByForSale(APIstub, args)
	case "UpdateDataHashForSale":
		return s.UpdateDataHashForSale(APIstub, args)
	case "QueryTransactionsByHash":
		return s.QueryTransactionsByHash(APIstub, args)
	case "QueryTransactionsBySeller":
		return s.QueryTransactionsBySeller(APIstub, args)
	case "QueryTransactionsByBuyer":
		return s.QueryTransactionsByBuyer(APIstub, args)
	case "BuyDataHash":
		return s.BuyDataHash(APIstub, args)
	default:
		return shim.Error("Invalid Smart Contract function name.")
	}
}

func (s *DataMarketplaceContract) CreateAccount(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
	return PutAccount(APIstub, args)
}

func (s *DataMarketplaceContract) QueryAccount(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
	return GetAccount(APIstub, args)
}

func (s *DataMarketplaceContract) CreateDataHash(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
	return PutDataHash(APIstub ,args)
}

func (s *DataMarketplaceContract) QueryDataHashesByOwner(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
	return GetDataHashesByOwner(APIstub, args)
}

func (s *DataMarketplaceContract) QueryDataHashesByForSale(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
	return GetDataHashesByForSale(APIstub, args)
}

func (s *DataMarketplaceContract) UpdateDataHashForSale(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
	return ChangeDataHashForSale(APIstub, args)
}

func (s *DataMarketplaceContract) QueryTransactionsByHash(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
	return GetTransactionsByHash(APIstub, args)
}

func (s *DataMarketplaceContract) QueryTransactionsBySeller(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
	return GetTransactionsBySeller(APIstub, args)
}

func (s *DataMarketplaceContract) QueryTransactionsByBuyer(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
	return GetTransactionsByBuyer(APIstub, args)
}

func (s *DataMarketplaceContract) BuyDataHash(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
	hashAsBytes, err := APIstub.GetState(args[0])
	if err != nil {
		return shim.Error("Failed to get hash:" + err.Error())
	} else if hashAsBytes == nil {
		return shim.Error("Hash does not exist")
	}

	hash := DataHash{}
	err = json.Unmarshal(hashAsBytes, &hash)
	if err != nil {
		return shim.Error(err.Error())
	}

	sellerAsBytes, err := APIstub.GetState(args[1])
	if err != nil {
		return shim.Error("Failed to get seller:" + err.Error())
	} else if sellerAsBytes == nil {
		return shim.Error("Seller does not exist")
	}

	seller := Account{}
	err = json.Unmarshal(sellerAsBytes, &seller)
	if err != nil {
		return shim.Error(err.Error())
	}

	buyerAsBytes, err := APIstub.GetState(args[2])
	if err != nil {
		return shim.Error("Failed to get buyer:" + err.Error())
	} else if buyerAsBytes == nil {
		return shim.Error("Buyer does not exist")
	}

	buyer := Account{}
	err = json.Unmarshal(buyerAsBytes, &buyer)
	if err != nil {
		return shim.Error(err.Error())
	}

	if(buyer.Balance < hash.Price){
		return shim.Error("Buyer does not have sufficient balance.")
	}

	newBuyerBalance := buyer.Balance - hash.Price
	newSellerBalance := seller.Balance + hash.Price

	ChangeAccountBalance(APIstub, args[1], newSellerBalance)
	ChangeAccountBalance(APIstub, args[2], newBuyerBalance)

	ChangeDataHashOwner(APIstub, args)
	return PutTransaction(APIstub, args)
}

func main() {

	// Create a new Smart Contract
	err := shim.Start(new(DataMarketplaceContract))
	if err != nil {
		fmt.Printf("Error creating new Smart Contract: %s", err)
	}
}
