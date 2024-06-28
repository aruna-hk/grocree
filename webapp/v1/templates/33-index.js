document.querySelector("#shoppingCart").onclick = ()=> {
  document.querySelector(".Xcart").style.display = "block";
  document.querySelector("#ordertrack").style.display = "none";
};
document.querySelector("main").onclick = ()=> {
  document.querySelector(".Xcart").style.display = "none";
  document.querySelector("#ordertrack").style.display = "";
  document.querySelector("#contacts").style.display = "";
  document.querySelector(".fm").style.display = "none";
}
