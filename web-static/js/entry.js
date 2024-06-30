//cart
var cart = {}
//add or minus menu
let entry = document.createElement('div')
entry.className = "add_minus_cart"
let minus = document.createElement('div')
minus.className= 'minus'
minus.innerHTML = '-'
let count = document.createElement('div')
count.className = 'count'
count.innerHTML = '0'
let plus = document.createElement('div')
plus.className = 'plus'
plus.innerHTML = '+'
entry.appendChild(minus)
entry.appendChild(count)
entry.appendChild(plus)

//items
let items = document.querySelectorAll('.groceryItem')
//add event listener to items

for (let i = 0; i < items.length; i++){
  items[i].addEventListener("click", ()=> {
  if (items[i].children.length == 2) {
      items[i].insertBefore(entry, items[i].children[1]);
      count.innerHTML = '0';
  }
  if (items[i].id in cart) {
      count.innerHTML = String(cart[items[i].id]);}
  });
}

plus.addEventListener('click', ()=>{
  if (plus.parentElement.parentElement.id in cart) {
   cart[plus.parentElement.parentElement.id] = cart[plus.parentElement.parentElement.id] + 1;
   count.innerHTML = String(cart[plus.parentElement.parentElement.id]);
  } else {
   cart[plus.parentElement.parentElement.id] = 1;
   count.innerHTML = String(cart[plus.parentElement.parentElement.id]);}
  document.querySelector('#totalItems').innerHTML = String(Number(document.querySelector('#totalItems').innerHTML) + 1);
});

    
minus.addEventListener('click', ()=>{
 if (minus.parentElement.parentElement.id in cart) {
   cart[minus.parentElement.parentElement.id] = cart[minus.parentElement.parentElement.id] - 1;
   count.innerHTML = String(cart[minus.parentElement.parentElement.id]);
   document.querySelector('#totalItems').innerHTML = String(Number(document.querySelector('#totalItems').innerHTML) - 1);
  }});
//bottom left entries

let container = document.querySelector(".Xitems");


plus.addEventListener('click', ()=> {
  let __name = plus.parentElement.nextElementSibling.firstElementChild.firstElementChild.textContent;
  let __price = plus.parentElement.nextElementSibling.lastElementChild.firstChild.textContent;
  let _entry = document.querySelector(".XitemEntry").cloneNode();
  _entry.appendChild(document.querySelector(".Xname").cloneNode());
  _entry.appendChild(document.querySelector(".Xquantity").cloneNode());
  _entry.appendChild(document.querySelector(".Xamount").cloneNode());
  _entry.appendChild(document.querySelector(".Xremove").cloneNode());
  _entry.children[0].textContent = __name;
  _entry.children[1].textContent = __price;
  _entry.children[2].textContent = Number(__price);
  _entry.children[3].textContent = "X";
  let _entries_ = document.querySelectorAll(".XitemEntry");
  for (_entry_ of _entries_) {
        if (_entry_.firstElementChild.textContent == __name) {
         _entry_.children[2].textContent = String(Number(__price) * Number(cart[plus.parentElement.parentElement.id]));
        document.querySelector("#totalcost").textContent = String(Number(document.querySelector("#totalcost").textContent) + Number(__price));
        return;
      }
   }
 container.insertBefore(_entry, container.children[0]);
 document.querySelector("#totalcost").textContent = String(Number(document.querySelector("#totalcost").textContent) + Number(__price));
}); 
