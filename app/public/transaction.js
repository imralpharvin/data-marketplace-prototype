
$(document).ready(function () {
  console.log("*****HOME.JS*****");

  loadAccount();
  loadSellerTransactions();
  loadBuyerTransactions();

  document.getElementById('datamarketplacePage').onclick = function () {
    console.log("***** Data Marketplace Page Clicked*****");

    let usernameInfo = document.getElementById('usernameInfo');
    let credentials = {};
    credentials["username"] = usernameInfo.innerHTML;

    sendUsername(credentials);
    window.location.href = '/datamarketplace';
  };

  document.getElementById('profilePage').onclick = function () {
    console.log("***** Profile Page Clicked*****");

    let usernameInfo = document.getElementById('usernameInfo');
    let credentials = {};
    credentials["username"] = usernameInfo.innerHTML;

    sendUsername(credentials);
    window.location.href = '/profile';
  };

  document.getElementById('datahashesPage').onclick = function () {
    console.log("***** DataHash Page Clicked*****");

    let usernameInfo = document.getElementById('usernameInfo');
    let credentials = {};
    credentials["username"] = usernameInfo.innerHTML;

    sendUsername(credentials);
    window.location.href = '/datahash';
  };

  document.getElementById('transactionsPage').onclick = function () {
    console.log("***** Transactions Page Clicked*****");

    let usernameInfo = document.getElementById('usernameInfo');
    let credentials = {};
    credentials["username"] = usernameInfo.innerHTML;

    sendUsername(credentials);
    window.location.href = '/transaction';
  };

  //Log Out
  document.getElementById('logOut').onclick = function () {
    console.log("*****Log Out Button Clicked*****");
    window.location.href = '/';
  };

  let realButton = document.getElementById('realButton');

  document.getElementById('uploadButton').onclick = function () {

    realButton.click();
    console.log("***** Upload Button Clicked*****");

  };

  realButton.addEventListener("change", function () {
    var uploadFile = realButton.value;

    if (uploadFile != "invalid") {
      console.log("IF");
      var path = realButton.value
      var filename = path.replace(/^.*\\/, "");
      customText.innerHTML = filename;


    }
    else {
      console.log("else");
      customText.innerHTML = "No file chosen";
    }
  });

  $('#uploadForm').submit(function (event) {
    event.preventDefault();

    let fd = new FormData(document.getElementById('uploadForm'));
    //fd.append("CustomField", "This is some extra data");
    $.ajax({
        url: '/upload',
        type: 'POST',
        data: fd,
        success:function(data){
            console.log("*****SUCCESS: Upload Successful*****");
            console.log("HASH: " + JSON.stringify(data));

            let hashText = document.getElementById('hashText');

            hashText.innerHTML = data["sha256"];

            let hashValue = document.getElementById('hashValue');
            let hashVerification = document.getElementById('hashVerification');
            if(hashText.innerHTML == hashValue.value){
              hashVerification.innerHTML = "Correct Hash Value."
            } else{
              hashVerification.innerHTML = "Incorrect Hash Value."
            }
        },
        cache: false,
        contentType: false,
        processData: false
    });


  });

  function sendUsername(credentials){
    $.ajax({
      type: "POST",
      url: "./sendUsername",
      data: JSON.stringify(credentials),
      dataType: 'text',
      contentType: "application/json",
      async: false,
      success: function (data) {
        console.log("*****SUCCESS: Log In User GET request*****");
        console.log(JSON.stringify(data));
        window.location.href = '/profile';

      },
      error: function (error) {
        console.log("*****FAILURE: Log In User GET request*****");
        //let logInError = document.getElementById('logInError');
        //logInError.innerHTML = 'Incorrect Log In. Please try again';
        console.log(error);

      }
    });
  }

  function loadAccount(){
    $.ajax({
      type: 'GET',
      dataType: 'json',
      url: '/loadAccount',
      async: 'false',
      success: function (data) {
        console.log(data);

        let account = data;
        console.log(account);
        let usernameInfo = document.getElementById('usernameInfo');

        usernameInfo.innerHTML = account["username"];

      },
      fail: function (error) {
        // Non-200 return, do something with error
        console.log(error);
      }
    });
  }
  //LoadDataHash on Table
  function loadSellerTransactions() {
    $.ajax({
      type: 'GET',
      dataType: 'json',
      url: '/loadSellerTransactions',
      async: 'false',
      success: function (data) {
        console.log(data);

        let transactions = data;

        let noSellerTransactions = document.getElementById('noSellerTransactions');
        let tableContainer1 = document.getElementById('tableContainer1');
        let transactionsSellerTable = document.getElementById('transactionsSellerTable');
        transactionsSellerTable.innerHTML = "";

        if(transactions.length == 0)  {
          noSellerTransactions.innerHTML = "You have no transactions as a seller.";
          tableContainer1.style.display="none";
        } else{
          noSellerTransactions.innerHTML = "";
          tableContainer1.style.display="block";
          let row = transactionsSellerTable.insertRow(-1);
          for (let i = 0; i < 3; i++) {
            let headerCell = document.createElement("TH");
            row.appendChild(headerCell);
          }

          row.cells[0].innerHTML = "Date";
          row.cells[1].innerHTML = "Hash";
          row.cells[2].innerHTML = "Buyer";

          for (let i = 1; i <= transactions.length; i++) {
            row = transactionsSellerTable.insertRow(-1);
            $(row).attr('id', transactions[i - 1]["Key"]);
            for (let j = 0; j < 3; j++) {
              let cell = row.insertCell(-1);
            }
            console.log(transactions[i - 1]["Key"]);
            let transaction = transactions[i - 1]["Record"];
            transactionsSellerTable.rows[i].cells[0].innerHTML = transaction["dateTime"];
            transactionsSellerTable.rows[i].cells[1].innerHTML = transaction["hash"];
            transactionsSellerTable.rows[i].cells[2].innerHTML = transaction["buyer"];

          }
        }
      },
      fail: function (error) {
        // Non-200 return, do something with error
        console.log(error);
      }
    });
  }


  function loadBuyerTransactions() {
    $.ajax({
      type: 'GET',
      dataType: 'json',
      url: '/loadBuyerTransactions',
      async: 'false',
      success: function (data) {
        console.log(data);

        let transactions = data;

        let noBuyerTransactions = document.getElementById('noBuyerTransactions');
        let tableContainer2 = document.getElementById('tableContainer2');
        let transactionsBuyerTable = document.getElementById('transactionsBuyerTable');
        transactionsBuyerTable.innerHTML = "";

        if(transactions.length == 0)  {
          noBuyerTransactions.innerHTML = "You have no transactions as a buyer.";
          tableContainer2.style.display="none";
        } else{
          noBuyerTransactions.innerHTML = "";
          tableContainer2.style.display="block";
          let row = transactionsBuyerTable.insertRow(-1);
          for (let i = 0; i < 3; i++) {
            let headerCell = document.createElement("TH");
            row.appendChild(headerCell);
          }
          row.cells[0].innerHTML = "Date";
          row.cells[1].innerHTML = "Hash";
          row.cells[2].innerHTML = "Seller";

          for (let i = 1; i <= transactions.length; i++) {
            row = transactionsBuyerTable.insertRow(-1);
            $(row).attr('id', transactions[i - 1]["Key"]);
            for (let j = 0; j < 3; j++) {
              let cell = row.insertCell(-1);
            }
            console.log(transactions[i - 1]["Key"]);
            let transaction = transactions[i - 1]["Record"];
            transactionsBuyerTable.rows[i].cells[0].innerHTML = transaction["dateTime"];
            transactionsBuyerTable.rows[i].cells[1].innerHTML = transaction["hash"];
            transactionsBuyerTable.rows[i].cells[2].innerHTML = transaction["seller"];
          }
        }
      },
      fail: function (error) {
        // Non-200 return, do something with error
        console.log(error);
      }
    });
  }
});
