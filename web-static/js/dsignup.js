const signupAPI = "http://localhost/users/delivery/"
let new_user = {}

document.querySelector("#ccancel").addEventListener('click', ()=>{
 document.querySelector("#signup").style.visibility = "hidden";
});

function removeError(elem) {
 if (elem.nextElementSibling != null) {
  if (elem.nextElementSibling.className == "signUpError") {
    elem.parentElement.removeChild(elem.nextElementSibling)
 }
}
}
document.querySelector("#rname").addEventListener('keydown', ()=> {
  removeError(document.querySelector("#rname"))
});
document.querySelector("#rphone").addEventListener('keydown', ()=> {
  removeError(document.querySelector("#rphone"))
});
document.querySelector("#rnationalId").addEventListener('keydown', ()=> {
  removeError(document.querySelector("#rnationalId"))
});


async function signUpRequest(user) {
 try {
  let _signupresponse = await fetch(signupAPI, {"headers":{"Content-Type":"application/json"}, "method":"POST", "body":JSON.stringify(user)})
  if (_signupresponse.ok == false) {
   let _errormsg = await _signupresponse.text()
   let _err = document.createElement('div')
   _err.className = "signUpError"
   _err.textContent = `${_errormsg} taken`
   document.querySelector("#r" + _errormsg).parentElement.insertBefore(_err, document.querySelector("#r" + _errormsg).nextElementSibling)
   document.querySelector("#signup").style.visibility = "visible"
  }else{
    alert("signup sucessful proceed to login")
    document.querySelector("#signup").visibility = "hidden";
    document.querySelector(".login").style.visibility = "visible"
   }
  } catch (error) {
    //pass
    alert(error)
  }
}
document.querySelector("#remail").addEventListener('keydown', ()=> {
  removeError(document.querySelector("#remail"))
});
document.querySelector("#rusername").addEventListener('keydown', ()=> {
  removeError(document.querySelector("#rusername"))
});
document.querySelector("#rpassword").addEventListener('keydown', ()=> {
  removeError(document.querySelector("#rpassword"))
});

document.querySelector("#register").addEventListener('click', ()=> {
 document.querySelector("#cancel > div").click();
 document.querySelector("#signup").style.visibility = "visible"
});

function fieldEmpty(name) {
  let signupError = document.createElement("div")
  signupError.style.color = "red"
  signupError.className = "signUpError"
  signupError.textContent = document.querySelector(name).attributes.getNamedItem('name').textContent
  let __nextElemSibling = document.querySelector(name).nextElementSibling
  if (__nextElemSibling == null) {
   document.querySelector("#createAc > #inptfields").appendChild(signupError)
  } else {
    document.querySelector("#createAc > #inptfields").insertBefore(signupError, __nextElemSibling)
  }
 }
function signUp(user) {
  const _options = {
   enableHighAccuracy: true,
   timeout: 5000,
   maximumAge: 0,
  };
  navigator.geolocation.getCurrentPosition(function(position){
   user['latitude'] = position.coords.latitude
   user['longitude'] = position.coords.longitude
   signUpRequest(new_user)}, function(error) {
   //pass
   }, _options);
}
document.querySelector("#cregister").addEventListener('click', ()=>{
 new_user['name'] = document.querySelector("#rname").value
 if (new_user['name']== '' && (document.querySelector("#rname").nextElementSibling.className != "signUpError")) {
  fieldEmpty("#rname")
 }
 new_user['phone'] = document.querySelector("#rphone").value
 if (new_user['phone'] == '' && (document.querySelector("#rphone").nextElementSibling.className != "signUpError")) {
  fieldEmpty("#rphone")
 }
 new_user['email'] = document.querySelector("#remail").value
 if (new_user['email'] == '' && (document.querySelector("#remail").nextElementSibling.className != "signUpError")) {
  fieldEmpty("#remail")
 }
 new_user['username'] = document.querySelector("#rusername").value
 if (new_user['username'] == '' && (document.querySelector("#rusername").nextElementSibling.className != "signUpError")) {
  fieldEmpty("#rusername")
 }
 new_user['nationalId'] = document.querySelector("#rnationalId").value
 if (new_user['nationalId'] == '' && (document.querySelector("#rnationalId").nextElementSibling.className != "signUpError")) {
  fieldEmpty("#rnationalId")
 }
 new_user['password'] = document.querySelector("#rpassword").value
 if (document.querySelector("#rpassword").nextElementSibling == null) {
  if (new_user['password'] == '') {
   fieldEmpty("#rpassword")
  }
 }
 if (document.querySelector(".signUpError") == null) {
   document.querySelector("#signup").style.visibility = "hidden";
   signUp(new_user)
   //Object.keys(new_user).forEach(key => {
   //  delete new_user[key];
  //});
}
});
