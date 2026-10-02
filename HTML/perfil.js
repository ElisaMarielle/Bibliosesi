//======================= FOTO DE PERFIL ==========================//
const modalFoto = document.querySelector('.mudar-foto')
function mudarFoto(){
  modalFoto.style.display = "flex"
}
function cancelar(){
  modalFoto.style.display = "none"
}

function salvarFoto() {
    const input = document.querySelector('#foto');
    const arquivo = input.files[0];

    if (!arquivo) return;

    const reader = new FileReader();

    reader.onload = function(e) {
        const fotoBase64 = e.target.result;

        document.querySelector('#foto-perfil').src = fotoBase64;

        localStorage.setItem('fotoPerfil', fotoBase64);
    };

    reader.readAsDataURL(arquivo);
    modalFoto.style.display = "none";
}

window.onload = function() {
    const fotoSalva = localStorage.getItem('fotoPerfil');

    if (fotoSalva) {
        document.querySelector('#foto-perfil').src = fotoSalva;
    }
};
//==============================================================//



//======================= INFORMAÇÕES DO USUÁRIO ==========================//

const usuario = JSON.parse(localStorage.getItem("usuario"));

document.getElementById("nome").textContent = usuario.nome;
document.getElementById("rm").textContent = usuario.rm;
document.getElementById("email").textContent = usuario.email;