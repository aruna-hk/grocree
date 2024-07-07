const url = "http://localhost/login"

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
         usernameError.textContent = "Invalid user"
         document.querySelector("#logform").insertBefore(usernameError, document.querySelector("#logform").children[1])
         try {
          document.querySelector("#logform").removeChild(passwordError)
         } catch  (error) {
           //pass
         }
      } else {
         passwordError.textContent = "Wrong password"
         document.querySelector("#logform").insertBefore(passwordError, document.querySelector("#logform").children[1])
      }
      throw new Error(`Response status: ${response.status}`);
    }
    let _json = await response.json();
    document.querySelector("#USER img").src=_json.user.image
    document.querySelector("#USER img").id=_json.user.id
    document.querySelector("#USER >#username").textContent = _json.user.name
    let _counter = 0
    for (Entry of _json.items) {
      if (_counter >= document.querySelector("main").children) {
         let product = document.querySelector("figure").clone()
         product.id = Entry.id
         product.append(document.querySelector("figure > img").clone())
         product.append(document.querySelector("figure > figcaption").clone())
         product.lastElementChild.append(document.querySelector("figcaption > .description").clone())
         product.lastElementChild.firstElementChild.appendChild(document.querySelector("figcaption > .name"))
         product.lastElementChild.firstElementChild.appendChild(document.querySelector("figcaption > .category"))
         product.lastElementChild.firstElementChild.appendChild(document.querySelector("figcaption > .category"))
         product.lastElementChild.append(document.querySelector("figcaption > .PriceTag").clone())
         product.firstElementChild.src=Entry.img
         product.lastElementChild.firstElementChild.firstElementChild.textContent = Entry.name
         product.lastElementChild.firstElementChild.lastElementChild.textContent = Entry.category
         product.lastElementChild.firstElementChild.lastElementChild.textContent = Entry.description
         product.lastElementChild.lastElementChild.firstElementChild.textContent=Entry.price
         document.querySelector("main").insertBefore(product, document.querySelector("main").firstElementChild)

         } else {
          let product = document.querySelector("main").lastElementChild

          product.firstElementChild.src=Entry.img
          product.lastElementChild.firstElementChild.firstElementChild.textContent = Entry.name
          product.lastElementChild.firstElementChild.lastElementChild.textContent = Entry.category
          product.lastElementChild.firstElementChild.lastElementChild.textContent = Entry.description
          product.lastElementChild.lastElementChild.firstElementChild.textContent=Entry.price
          document.querySelector("main").removeChild(document.querySelector("main").lastElementChild)
          document.querySelector("main").insertBefore(product, document.querySelector("main").firstElementChild)
         }
        _counter = _counter + 1
       }
       document.querySelector("body > .login").style.visibility = "hidden";
  } catch (error) {
    console.error(error.message);
  }
}


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

reload()
