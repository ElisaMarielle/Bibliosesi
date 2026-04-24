const menuBtn = document.querySelector('.bt-menu');
const nav = document.querySelector('.navegar nav');

menuBtn.addEventListener('click', () => {
  nav.classList.toggle('active');
  if (nav.classList.contains('active')) {
    document.querySelector('main').style.filter = "grayscale(100%) blur(3px)";
  } else {
    document.querySelector('main').style.filter = "grayscale(0) blur(0)";
  }

});

function salvarLocal() {
  localStorage.setItem("comentario", JSON.stringify(comentario));
  window.location.reload();

}

//modalCli > modalComent
function abrirModal() {
  modalComent.style.display = "block";
  limparCampos();
}

function fecharModal() {
  modalComent.style.display = "none";
}

//formCli > comentario
const formComent = document.getElementById("comentario");
formComent.addEventListener("submit", e => {
  e.preventDefault();
  limparCampos();
})

function limparCampos() {
  document.getElementById("coment").value = " ";
}

//-----------------FILTRAR LIVROS NO CATÁLOGO


/*function listarCatalogo() {
  fetch("https://viacep.com.br/ws/01001000/json/")
  .then(data => {
    return data.json();
  })
  .then(resp => {
    resp.forEach(livro => {
      
    });
  });
}

listarCatalogo();*/

//-----------------SEARCH INPUT
function buscarLivros() {
  let livros = document.getElementsByClassName("livro");
  let pesquisa = document.getElementById('searcbook');

  for (let i = 0; i < livros.length; i++) {
    if (livros[i].innerHTML != pesquisa) {
      livros[i].parentNode.style.display = "none";
    }else{
      livros[i].parentNode.style.display = "block";
    }
  }
}




