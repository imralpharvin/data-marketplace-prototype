'use strict'

//Http
// Express App (Routes)
const express = require("express");
const app = express();
const bodyParser = require('body-parser');
const path = require("path");
const fileUpload = require('express-fileupload');
const crypto = require('crypto');

app.use(fileUpload());
app.use(bodyParser.json());

const fs = require('fs');
const JavaScriptObfuscator = require('javascript-obfuscator');
const CryptoJS = require('crypto-js');

const registerUser = require('./api/registerUser');
const enrollAdmin = require('./api/enrollAdmin');
const registerAccount = require('./api/registerAccount');
const queryAccount = require('./api/queryAccount');
const addDataHash = require('./api/addDataHash');
const buyDataHash = require('./api/buyDataHash');
const queryDataHashByOwner = require('./api/queryDataHashByOwner');
const queryDataHashByForSale = require('./api/queryDataHashByForSale');
const updateForSale = require('./api/updateForSale');
const queryTransactionsBySeller = require('./api/queryTransactionsBySeller');
const queryTransactionsByBuyer = require('./api/queryTransactionsByBuyer');

let currentUser;

app.get('/', function (req, res) {
  res.sendFile(path.join(__dirname + '/public/index.html'));
});

app.get('/datamarketplace', function (req, res) {
  res.sendFile(path.join(__dirname + '/public/datamarketplace.html'));
});

app.get('/profile', function (req, res) {
  res.sendFile(path.join(__dirname + '/public/profile.html'));
});

app.get('/datahash', function (req, res) {
  res.sendFile(path.join(__dirname + '/public/datahash.html'));
});

app.get('/transaction', function (req, res) {
  res.sendFile(path.join(__dirname + '/public/transaction.html'));
});

app.get('/admin', function (req, res) {
  res.sendFile(path.join(__dirname + '/public/admin.html'));
});

app.get('/style.css', function (req, res) {
  res.sendFile(path.join(__dirname + '/public/style.css'));
});

app.get('/index.js', function (req, res) {
  fs.readFile(path.join(__dirname + '/public/index.js'), 'utf8', function (err, contents) {
    const minimizedContents = JavaScriptObfuscator.obfuscate(contents, { compact: true, controlFlowFlattening: true });
    res.contentType('application/javascript');
    res.send(minimizedContents._obfuscatedCode);
  });
});

app.get('/admin.js', function (req, res) {
  fs.readFile(path.join(__dirname + '/public/admin.js'), 'utf8', function (err, contents) {
    const minimizedContents = JavaScriptObfuscator.obfuscate(contents, { compact: true, controlFlowFlattening: true });
    res.contentType('application/javascript');
    res.send(minimizedContents._obfuscatedCode);
  });
});

app.get('/datamarketplace.js', function (req, res) {
  fs.readFile(path.join(__dirname + '/public/datamarketplace.js'), 'utf8', function (err, contents) {
    const minimizedContents = JavaScriptObfuscator.obfuscate(contents, { compact: true, controlFlowFlattening: true });
    res.contentType('application/javascript');
    res.send(minimizedContents._obfuscatedCode);
  });
});

app.get('/profile.js', function (req, res) {
  fs.readFile(path.join(__dirname + '/public/profile.js'), 'utf8', function (err, contents) {
    const minimizedContents = JavaScriptObfuscator.obfuscate(contents, { compact: true, controlFlowFlattening: true });
    res.contentType('application/javascript');
    res.send(minimizedContents._obfuscatedCode);
  });
});

app.get('/datahash.js', function (req, res) {
  fs.readFile(path.join(__dirname + '/public/datahash.js'), 'utf8', function (err, contents) {
    const minimizedContents = JavaScriptObfuscator.obfuscate(contents, { compact: true, controlFlowFlattening: true });
    res.contentType('application/javascript');
    res.send(minimizedContents._obfuscatedCode);
  });
});

app.get('/transaction.js', function (req, res) {
  fs.readFile(path.join(__dirname + '/public/transaction.js'), 'utf8', function (err, contents) {
    const minimizedContents = JavaScriptObfuscator.obfuscate(contents, { compact: true, controlFlowFlattening: true });
    res.contentType('application/javascript');
    res.send(minimizedContents._obfuscatedCode);
  });
});

app.post('/enrollAdmin', function (req, res) {
  console.log("*****Enroll Admin POST request*****");
  enrollAdmin.enrollAdmin();
  res.redirect('/');
  res.end();

});

app.post('/registerUser', async function (req, res) {

  console.log("*****Register User POST request*****");
  let account = req.body;

  //Register and enroll application identity
  await registerUser.registerUser(account);
  //Register account in blockchain
  await registerAccount.registerAccount(account);

  //Create front end file
  let userFilePath = 'users/' + account["username"] + '.txt';
  //console.log(userFilePath);
  fs.writeFile(userFilePath, account["password"], (err) => {

      if (err) throw err;
  });
  res.end();

});

app.post('/logIn', async function (req, res, next) {
  console.log("*****Log In POST request*****");
  let credentials = req.body;
  currentUser = credentials["username"];
  let passwordAttempt = credentials["password"];
  console.log("*****Current User: " + currentUser + "*****");

  let filePath = 'users/' + currentUser + '.txt';
  let password = fs.readFileSync(filePath, {encoding:'utf8', flag:'r'});

  if(passwordAttempt != password){
      next("*****ERROR:Password is incorrect*****");
  }

  res.end();

});

app.post('/sendUsername', async function (req, res, next) {
  console.log("*****Log In POST request*****");
  let credentials = req.body;
  currentUser = credentials["username"];
  console.log("*****Current User: " + currentUser + "*****");
  res.end();

});

app.get('/loadAccount', async function (req, res) {
  console.log("*****Load Account GET request*****");
  console.log("*****Current User: " + currentUser + "*****");
  let account = await queryAccount.queryAccount(currentUser);
  account["username"] = currentUser;
  //console.log(account);
  res.send(account);

});

app.post('/uploadDataHash', async function (req, res, next) {
  console.log("*****Upload DataHash POST request*****");

  let datahash = req.body
  let err = await addDataHash.addDataHash(datahash);

  if(err != null){
      console.log(err);
      next("*****ERROR:Datahash already exists in the ledger.*****");
  }
  res.end();

});

app.post('/buyDataHash', async function (req, res, next) {
  console.log("*****Buy DataHash POST request*****");

  let transaction = req.body;
  console.log(transaction);
  let err = await buyDataHash.buyDataHash(transaction);


  if(err != null){
      console.log(err);
      next("*****ERROR:Transaction already exists in the ledger.*****");
  }
  res.end();

});

//Respond to POST requests that upload files to uploads/ directory
app.post('/upload', async function (req, res) {
  //console.log(req.files);
  if (!req.files) {
    return res.status(400).send('No files were uploaded.');
  }

  let uploadFile = req.files.uploadFile;

  // Use the mv() method to place the file somewhere on your server
  uploadFile.mv('uploads/' + uploadFile.name, function (err) {
    if (err) {
      return res.status(500).send(err);
    }

    var algorithm = 'sha256'
    , shasum = crypto.createHash(algorithm)

  // Updating shasum with file content
  var filename = __dirname + '/uploads/' + uploadFile.name
    , s = fs.ReadStream(filename)

  console.log(filename);
  s.on('data', function(data) {
    shasum.update(data)
  })

  let hash = {};

  // making digest
  s.on('end', function() {
    hash["sha256"] = shasum.digest('hex')
    console.log(hash["sha256"] + '  ' + filename)
    hash["md5"] = uploadFile.md5;
    res.send(hash);
  })


  });
});

//Respond to GET requests for files in the uploads/ directory
app.get('/uploads/:name', function (req, res) {
  fs.stat('uploads/' + req.params.name, function (err, stat) {
    console.log(err);
    if (err == null) {
      res.sendFile(path.join(__dirname + '/uploads/' + req.params.name));
    } else {
      res.send('');
    }
  });
});

app.get('/loadOwnerDataHashes', async function (req, res) {
  console.log("*****Load DataHashes GET request*****");
  console.log("*****Current User: " + currentUser + "*****");
  let datahashes = await queryDataHashByOwner.queryDataHashByOwner(currentUser);
  //console.log(account);
  res.send(datahashes);

});

app.get('/loadForSaleDataHashes', async function (req, res) {
  console.log("*****Load For Sale DataHashes GET request*****");
  console.log("*****Current User: " + currentUser + "*****");

  let datahashes = await queryDataHashByForSale.queryDataHashByForSale(currentUser);
  //console.log(account);
  res.send(datahashes);

});

app.get('/loadSellerTransactions', async function (req, res) {
  console.log("*****Load Seller Transactions GET request*****");
  console.log("*****Current User: " + currentUser + "*****");

  let transactions = await queryTransactionsBySeller.queryTransactionsBySeller(currentUser);
  console.log(transactions);
  res.send(transactions);

});

app.get('/loadBuyerTransactions', async function (req, res) {
  console.log("*****Load Buyer Transactions GET request*****");
  console.log("*****Current User: " + currentUser + "*****");

  let transactions = await queryTransactionsByBuyer.queryTransactionsByBuyer(currentUser);
  res.send(transactions);

});

app.post('/updateForSale', async function (req, res, next) {
  console.log("*****Update For Sale POST request*****");

  let datahash = req.body;
  await updateForSale.updateForSale(datahash);
  console.log(datahash);

  res.end();

});

app.listen(1234, function(){
  console.log('Listening on port 1234');
});
