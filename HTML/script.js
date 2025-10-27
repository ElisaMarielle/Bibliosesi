const menuBtn = document.querySelector('.bt-menu');
const nav = document.querySelector('.navegar nav');

menuBtn.addEventListener('click', () => {
  nav.classList.toggle('active');
});