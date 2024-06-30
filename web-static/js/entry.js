const cart = {}

let entry = document.createElement('div')

entry.innerHTML = '<div class=minus>-</div><div class=count>0</div><div class=plus>+</div>'
entry.className = "add_minus_cart"
let items = document.querySelectorAll('.groceryItem')

for (let i = 0; i < items.length; i++){
  let item = items[i];
  let children = item.children
  item.addEventListener("click", ()=> {
    item.insertBefore(entry, children[1])});
}
  
