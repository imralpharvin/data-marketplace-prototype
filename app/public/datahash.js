
$(document).ready(function () {
  console.log("*****HOME.JS*****");

  loadAccount();
  loadDataHashes();

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

  //Upload DataHash Event
  $('#uploadDataHash').submit(function (event) {
    event.preventDefault();

    console.log("*****Upload DataHash Event Clicked*****");

    let usernameInfo = document.getElementById('usernameInfo');

    let title = document.getElementById('addTitle').value;
    let hash = document.getElementById('addHash').value;
    let description = document.getElementById('addDescription').value;
    let owner = usernameInfo.innerHTML;
    let price = document.getElementById('addPrice').value;

    console.log("*****DataHash Details*****")
    console.log("Title: " + title);
    console.log("Hash: " + hash);
    console.log("Description: " + description);
    console.log("Owner: " + owner);
    console.log("Price: " + price);

    let datahash = {};
    datahash["title"] = title;
    datahash["hash"] = hash;
    datahash["description"] = description;
    datahash["owner"] = owner;
    datahash["price"] = price;

    $.ajax( {
        type: "POST",
        url: "./uploadDataHash",
        data: JSON.stringify(datahash),
        dataType: 'text',
        contentType: "application/json",
        async: false,
        success: function (data, no, yes) {
          console.log("*****SUCCESS: Upload Data Hash POST request*****");
          let uploadDataHashMessage = document.getElementById('uploadDataHashMessage');
          uploadDataHashMessage.innerHTML = "Succesfully added datahash.";
          loadDataHashes();
        },
        error: function (error) {
          console.log("*****FAILURE: Upload Data Hash POST request*****");
          let uploadDataHashMessage = document.getElementById('uploadDataHashMessage');
          uploadDataHashMessage.innerHTML = "Error: Datahash already exists.";
          console.log(error);
        }
      });
  });

  //Log Out
  document.getElementById('logOut').onclick = function () {
    console.log("*****Log Out Button Clicked*****");
    window.location.href = '/';
  };

  //Update For Sale
  $(document).on("click", ".button1", function(){
      console.log("Button Clicked");// Outputs the answer

      let row = $(this).closest("tr");
      let id = row.attr('id');
      let usernameInfo = document.getElementById('usernameInfo');

      let datahash = {};
      datahash["key"] = id;
      datahash["username"] = usernameInfo.innerHTML;
      console.log("ID: " + id);

      $.ajax({
          type: "POST",
          url: "./updateForSale",
          data: JSON.stringify(datahash),
          dataType: 'text',
          contentType: "application/json",
          async: false,
          success: function (data, no, yes) {
            console.log("*****SUCCESS: Update For Sale POST request*****");
            loadDataHashes();
          },
          fail: function (error) {
            console.log("*****FAILURE: Update For Sale POST request*****");
            console.log(error);
          }
        });
  });

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
  function loadDataHashes() {
    $.ajax({
      type: 'GET',
      dataType: 'json',
      url: '/loadOwnerDataHashes',
      async: 'false',
      success: function (data) {
        console.log(data);

        let datahashes = data;

        let noDatahashes = document.getElementById('noDatahashes');
        let tableContainer = document.getElementById('tableContainer');
        let datahashesTable = document.getElementById('datahashesTable');
        datahashesTable.innerHTML = "";

        if(datahashes.length == 0)  {
          noDatahashes.innerHTML = "You have no datahashes uploaded.";
          tableContainer.style.display="none";
        } else{
          noDatahashes.innerHTML = "";
          tableContainer.style.display="block";
          let row = datahashesTable.insertRow(-1);
          for (let i = 0; i < 6; i++) {
            let headerCell = document.createElement("TH");
            row.appendChild(headerCell);
          }

          row.cells[0].innerHTML = "Title";
          row.cells[1].innerHTML = "Description";
          row.cells[2].innerHTML = "Hash";
          row.cells[3].innerHTML = "Price";
          row.cells[4].innerHTML = "For Sale";
          row.cells[5].innerHTML = "Action";

          for (let i = 1; i <= datahashes.length; i++) {
            row = datahashesTable.insertRow(-1);
            $(row).attr('id', datahashes[i - 1]["Key"]);
            for (let j = 0; j < 6; j++) {
              let cell = row.insertCell(-1);
            }
            console.log(datahashes[i - 1]["Key"]);
            let datahash = datahashes[i - 1]["Record"];
            datahashesTable.rows[i].cells[0].innerHTML = datahash["title"];
            datahashesTable.rows[i].cells[1].innerHTML = datahash["description"];
            datahashesTable.rows[i].cells[2].innerHTML = datahash["hash"];
            datahashesTable.rows[i].cells[3].innerHTML = datahash["price"];
            if(datahash["forsale"] == false){
              datahashesTable.rows[i].cells[4].innerHTML = "No";
              datahashesTable.rows[i].cells[5].innerHTML = '<button type="button" class="button1">Sell</button>';
            } else if(datahash["forsale"] ==true) {
              datahashesTable.rows[i].cells[4].innerHTML = "Yes";
              datahashesTable.rows[i].cells[5].innerHTML = '<button type="button" class="button1">Remove from Data Marketplace</button>';
            }
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
