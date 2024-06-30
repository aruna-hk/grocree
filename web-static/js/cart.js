document.querySelector("#shoppingCart").addEventListener('click', ()=>{
    document.querySelector('.Xcart').style.display = 'block';
  });

document.querySelector("main").addEventListener('click', ()=>{
  if (document.querySelector('.Xcart').style.display != 'none') {
    document.querySelector('.Xcart').style.display = 'none'}});
