//cart
var cart = {}
//add or minus menu
const entry = document.createElement('div')
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


plus.addEventListener('click', ()=>{
  let __key = plus.parentElement.parentElement.id + "$" + plus.parentElement.parentElement.attributes.getNamedItem('str').textContent
  if (__key in cart) {
   cart[__key] = cart[__key] + 1;
   count.innerHTML = String(cart[__key]);
  } else {
   cart[__key] = 1;
   count.innerHTML = String(cart[__key]);}
  document.querySelector('#totalItems').innerHTML = String(Number(document.querySelector('#totalItems').innerHTML) + 1);
});

minus.addEventListener('click', ()=>{
  let __key = plus.parentElement.parentElement.id + "$" + plus.parentElement.parentElement.attributes.getNamedItem('str').textContent
 if (__key in cart) {
   cart[__key] = cart[__key] - 1;
   count.innerHTML = String(cart[_key]);
   document.querySelector('#totalItems').innerHTML = String(Number(document.querySelector('#totalItems').innerHTML) - 1);
  }});

   
//bottom left entries

let container = document.querySelector(".Xitems");
let Empty = container.lastElementChild


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
         _entry_.children[2].textContent = String(Number(__price) * Number(cart[plus.parentElement.parentElement.id + "$" + plus.parentElement.parentElement.attributes.getNamedItem("str").textContent]));
        document.querySelector("#totalcost").textContent = String(Number(document.querySelector("#totalcost").textContent) + Number(__price));
        return;
      }
   }
 container.insertBefore(_entry, container.children[0]);
 document.querySelector("#totalcost").textContent = String(Number(document.querySelector("#totalcost").textContent) + Number(__price));
 if (container.lastElementChild.firstElementChild.textContent == '-') {
   container.removeChild(container.lastElementChild);
 }
}); 

const reload = ()=>{
//items
 let item = document.querySelectorAll('.groceryItem')
 //add event listener to items
 for (let i = 0; i < item.length; i++){
  item[i].addEventListener("click", ()=> {
   let _prevparent = item[i].id + "$" + item[i].attributes.getNamedItem('str').textContent
   if (entry.parentElement != null) {
     entry.parentElement.removeChild(entry)
     item[i].insertBefore(entry, item[i].children[1])
    } else {
    item[i].insertBefore(entry, item[i].children[1])
   }
   if (_prevparent in cart) {
    count.innerHTML = String(cart[_prevparent])
   } else {
    count.innerHTML = "0"
   }
 });
}
}

reload()
