const menuBtn = document.querySelector('.bt-menu');
const nav = document.querySelector('.navegar nav');

menuBtn.addEventListener('click', () => {
  nav.classList.toggle('active');
});

function salvarLocal(){
  localStorage.setItem("comentario", JSON.stringify(comentario));
  window.location.reload();
   
}

//modalCli > modalComent
function abrirModal(){
  modalComent.style.display = "block";
  limparCampos();
}

function fecharModal(){
    modalComent.style.display = "none";
}

//formCli > comentario
const formComent = document.getElementById("comentario");
formComent.addEventListener("submit", e => {
    e.preventDefault();
    limparCampos();
})

function limparCampos(){
  document.getElementById("coment").value = " ";
}