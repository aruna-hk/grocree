document.querySelector("#completePurchase").addEventListener("click", ()=>{
 if (document.querySelector("#totalcost").textContent == '0') {
   alert("Empty Cart continue shopping")
   document.querySelector(".Xcart").style.display = 'none';
 } else {
   document.querySelector('#pendingOrders').innerHTML = String(Number(document.querySelector('#pendingOrders').innerHTML) + 1);
   document.querySelector('#totalItems').innerHTML = String(0);
   document.querySelector(".Xcart").style.display = 'none';
   cart = {}
   alert("order placed");
 }
});
