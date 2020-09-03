
$(document).ready(function () {
  console.log("*****HOME.JS*****");

  loadAccount();
  loadForSaleDataHashes();

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


  $(document).on("click", ".button2", function(){
      console.log("*****Buy Button Clicked*****");// Outputs the answer

      let row = $(this).closest("tr");
      let $tds = row.find("td:nth-child(3)");
      let seller;

      $.each($tds, function() {
        seller = $(this).text();
      });

      let hash = row.attr('id');
      let usernameInfo = document.getElementById('usernameInfo');

      let transaction = {};
      transaction["hash"] = hash;
      transaction["buyer"] = usernameInfo.innerHTML;
      transaction["seller"] = seller;
      console.log(transaction);


      $.ajax({
          type: "POST",
          url: "./buyDataHash",
          data: JSON.stringify(transaction),
          dataType: 'text',
          contentType: "application/json",
          async: false,
          success: function (data, no, yes) {
            console.log("*****SUCCESS: Buy Datahash POST request*****");
            loadForSaleDataHashes();
          },
          fail: function (error) {
            console.log("*****FAILURE: Buy Datahash POST request*****");
            console.log(error);
          }
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
        console.log("*****SUCCESS: Send Username POST request*****");
        console.log(JSON.stringify(data));

      },
      error: function (error) {
        console.log("*****FAILURE: Send Username POST request*****");
        //let logInError = document.getElementById('logInError');
        //logInError.innerHTML = 'Incorrect Log In. Please try again';
        console.log(error);

      }
    });
  }

  //Load Account Detaisl
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
  function loadForSaleDataHashes(){

    $.ajax({
      type: 'GET',
      dataType: 'json',
      url: '/loadForSaleDataHashes',
      async: 'false',
      success: function (data) {
        console.log(data);

        let datahashes = data;

        let noDatahashes = document.getElementById('noDatahashes');
        let tableContainer = document.getElementById('tableContainer');
        let datahashesTable = document.getElementById('datahashesTable');
        datahashesTable.innerHTML = "";

        if(datahashes.length == 0)  {
          noDatahashes.innerHTML = "There are no available datahashes.";
          tableContainer.style.display="none";
        } else{
          noDatahashes.innerHTML = "";
          tableContainer.style.display="block";
          let row = datahashesTable.insertRow(-1);
          for (let i = 0; i < 5; i++) {
            let headerCell = document.createElement("TH");
            row.appendChild(headerCell);
          }

          row.cells[0].innerHTML = "Title";
          row.cells[1].innerHTML = "Description";
          row.cells[2].innerHTML = "Owner";
          row.cells[3].innerHTML = "Price";
          row.cells[4].innerHTML = "Action";

          for (let i = 1; i <= datahashes.length; i++) {
            row = datahashesTable.insertRow(-1);
            $(row).attr('id', datahashes[i - 1]["Key"]);
            for (let j = 0; j < 5; j++) {
              let cell = row.insertCell(-1);
            }
            console.log(datahashes[i - 1]["Key"]);
            let datahash = datahashes[i - 1]["Record"];
            datahashesTable.rows[i].cells[0].innerHTML = datahash["title"];
            datahashesTable.rows[i].cells[1].innerHTML = datahash["description"];
            datahashesTable.rows[i].cells[2].innerHTML = datahash["owner"];
            datahashesTable.rows[i].cells[3].innerHTML = datahash["price"];

            let usernameInfo = document.getElementById('usernameInfo');
            if(usernameInfo.innerHTML == datahash["owner"]){
              datahashesTable.rows[i].cells[4].innerHTML = "N/A";

            } else{
              datahashesTable.rows[i].cells[4].innerHTML = '<button type="button" class="button2">Buy</button>';
            }
            /*if(datahash["forsale"] == false){
              datahashesTable.rows[i].cells[4].innerHTML = "No";
              datahashesTable.rows[i].cells[5].innerHTML = '<button type="button" class="button1">Sell</button>';
            } else if(datahash["forsale"] ==true) {
              datahashesTable.rows[i].cells[4].innerHTML = "Yes";
              datahashesTable.rows[i].cells[5].innerHTML = '<button type="button" class="button1">Remove from Data Marketplace</button>';
            }*/
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
