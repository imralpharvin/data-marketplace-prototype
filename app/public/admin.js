
$(document).ready(function () {

  document.getElementById('enrollAdmin').onclick = function () {

      $.ajax(
        {
          type: "POST",
          url: "./enrollAdmin",
          dataType: 'text',
          contentType: "application/json",
          success: function (data, no, yes) {
            window.location.pathname = "/"
            console.log("Success: Enroll Admin");
          },
          fail: function (error) {
            // Non-200 return, do something with error
            console.log(error);
            console.log("Failure: Enroll Admin");
          }
        });
  };

});
