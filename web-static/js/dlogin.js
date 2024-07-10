const url = "http://localhost/dlogin"

let usernameError = document.createElement('div')
usernameError.id = 'usernameError'
usernameError.textContent='Enter Username'
usernameError.className = 'logerror'

let passwordError = document.createElement('div')
passwordError.id = 'passwordError'
passwordError.textContent = "Enter Password"
passwordError.className = 'logerror'

async function loginRequest(username, password) {
 let Url = url + "?" + "username=" + username +"&" + "password=" + password;
  console.log(Url)
  try {
    const response = await fetch(Url);
    if (!response.ok) {
      if (response.status == 404) {
         usernameError.textContent = "Not found, Invalid username"
         document.querySelector("#logform").insertBefore(usernameError, document.querySelector("#logform").children[1])
         try {
          document.querySelector("#logform").removeChild(passwordError)
         } catch  (error) {
           //pass
         }
      } else {
         passwordError.textContent = "Unauthorized, password Error"
         document.querySelector("#logform").insertBefore(passwordError, document.querySelector("#logform").children[1])
      }
      throw new Error(`Response status: ${response.status}`);
    }
    let _json = await response.json();
    document.querySelector("#USER img").src=_json.imgURL
    document.querySelector("#USER img").id=_json.id
    document.querySelector("#USER >#username").textContent = _json.username
    document.querySelector("#cancel > div").click()
  } catch (error) {
    console.error(error.message);
  }
}
document.querySelector("#USER img").addEventListener("click", ()=> {
 if (document.querySelector("#username").textContent == 'login/register') {
    document.querySelector(".login").style.visibility = 'visible';
 } else {
   alert("return account info page")
  }});
document.querySelector("#username").addEventListener("click", ()=> {
  if (document.querySelector("#username").textContent == 'login/register') {
    document.querySelector(".login").style.visibility = 'visible';
  } else {
    alert("return account info page")
  }});


document.querySelector('#login').addEventListener('click', ()=> {
 if (document.querySelector('#usernme').value == "") {
    document.querySelector("#logform").insertBefore(usernameError, document.querySelector("#logform").children[1]);
 } else {
   if (document.querySelector('#password').value == '') {
     document.querySelector("#logform").insertBefore(passwordError, document.querySelector("#logform").children[1]);
   } else {
      username = document.querySelector("#usernme").value.trim();
      password = document.querySelector("#password").value
      try {
          document.querySelector('.login').removeChild(passwordError);
      } catch (e) {
        //pass
      } finally {
         loginRequest(username, password)
      }
    }
   }
  }
);
document.querySelector('#usernme').addEventListener('keydown', ()=> {
  try {
    document.querySelector('#logform').removeChild(usernameError)
  } catch (e) {
   //pass
  }
});
document.querySelector('#password').addEventListener('keydown', ()=> {
  try {
    document.querySelector('#logform').removeChild(passwordError)
  } catch (e) {
   //pass
  }
});

//reload()
