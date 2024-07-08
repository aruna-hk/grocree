const orderApi = "http://localhost/users/customers/"
const headers = new Headers()
headers.append("Content-Type", "application/json")

const action = "orders"
async function order() {
 let userURL = orderApi + document.querySelector("#USER>a>img").id + "/" + action
 let orderResponse = await fetch(userURL, {"headers":headers, "body":JSON.stringify(cart), "method":"POST"})
 if (orderResponse.status == 201) {alert(await orderResponse.text())}
}
document.querySelector("#completePurchase").addEventListener("click", ()=>{
 if (document.querySelector("#totalcost").textContent == '0') {
   alert("Empty Cart continue shopping")
   document.querySelector(".Xcart").style.display = 'none';
 } else {
   document.querySelector('#pendingOrders').innerHTML = String(Number(document.querySelector('#pendingOrders').innerHTML) + 1);
   document.querySelector('#totalItems').innerHTML = String(0);
   document.querySelector(".Xcart").style.display = 'none';
   let __entries__ = document.querySelectorAll(".XitemEntry")
   for (__entry__ of __entries__) {
     document.querySelector(".Xitems").removeChild(__entry__);
   }
   order()
   //clear cart
   cart = {}
   document.querySelector(".Xitems").append(Empty)
   document.querySelector("#totalcost").textContent = '0';
   document.querySelector(".Xitems").display = 'none'
 }
});
