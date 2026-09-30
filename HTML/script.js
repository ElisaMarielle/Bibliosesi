const menuBtn = document.querySelector('.bt-menu');
const nav = document.querySelector('.navegar nav');
const overlay = document.querySelector("#overlay");

menuBtn.addEventListener('click', () => {
  nav.classList.toggle('active');
  overlay.classList.add("ativo");
  if (nav.classList.contains('active')) {
    document.querySelector('main').style.filter = "grayscale(100%) blur(3px)";
    document.body.style.overflow = "hidden";
  } else {
    document.querySelector('main').style.filter = "grayscale(0) blur(0)";
    overlay.classList.remove("ativo");
    document.body.style.overflow = "";
  }
});



function logoff(){
  localStorage.removeItem('dados')
  localStorage.removeItem('token')
  window.location.href = 'login.htm';
}
