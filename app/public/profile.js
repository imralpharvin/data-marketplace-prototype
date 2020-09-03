
$(document).ready(function () {
  console.log("*****HOME.JS*****");

  loadAccount();

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
        let nameInfo = document.getElementById('nameInfo');
        let usernameInfo = document.getElementById('usernameInfo');
        let organizationInfo = document.getElementById('organizationInfo');
        let employeeIDInfo = document.getElementById('employeeIDInfo');
        let balanceInfo = document.getElementById('balanceInfo');

        nameInfo.innerHTML = account["name"];
        usernameInfo.innerHTML = account["username"];
        organizationInfo.innerHTML = account["organization"];
        employeeIDInfo.innerHTML = account["employeeID"];
        balanceInfo.innerHTML = account["balance"];

      },
      fail: function (error) {
        // Non-200 return, do something with error
        console.log(error);
      }
    });
  }
});
