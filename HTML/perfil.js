
/* ======================= FOTO DE PERFIL ======================= */

const modalFoto = document.querySelector(".mudar-foto");

function mudarFoto() {
    modalFoto.style.display = "flex";
}

function cancelar() {
    modalFoto.style.display = "none";
}

function salvarFoto() {
    const input = document.querySelector("#foto");
    const arquivo = input.files[0];

    if (!arquivo) {
        alert("Selecione uma imagem primeiro.");
        return;
    }

    const tiposPermitidos = [
        "image/png",
        "image/jpeg",
        "image/webp"
    ];

    if (!tiposPermitidos.includes(arquivo.type)) {
        alert("Selecione uma imagem PNG, JPG ou WEBP.");
        return;
    }

    const reader = new FileReader();

    reader.onload = function (e) {
        const fotoBase64 = e.target.result;

        document.querySelector("#foto-perfil").src = fotoBase64;

        localStorage.setItem("fotoPerfil", fotoBase64);
        modalFoto.style.display = "none";
    };

    reader.readAsDataURL(arquivo);
}

/* ======================= INFORMAÇÕES DO USUÁRIO ======================= */

const usuario = JSON.parse(
    localStorage.getItem("usuario") || "null"
);

if (usuario) {
    document.getElementById("nome").textContent = usuario.nome || "";
    document.getElementById("rm").textContent = usuario.rm || "";
    document.getElementById("email").textContent = usuario.email || "";
}

/* ======================= FOTO SALVA ======================= */

function carregarFoto() {
    const fotoSalva = localStorage.getItem("fotoPerfil");

    if (fotoSalva) {
        document.querySelector("#foto-perfil").src = fotoSalva;
    }
}

/* ======================= LIVROS FAVORITADOS ======================= */

function atualizarQuantidadeFavoritos() {
    const contador = document.getElementById("favoritos-count");

    if (!contador) {
        return;
    }

    if (!usuario || !usuario.id) {
        contador.textContent = "0";
        return;
    }

    const chaveFavoritos = `livrosFavoritados_${usuario.id}`;

    let favoritos = [];

    try {
        favoritos = JSON.parse(
            localStorage.getItem(chaveFavoritos) || "[]"
        );

        if (!Array.isArray(favoritos)) {
            favoritos = [];
        }
    } catch (error) {
        favoritos = [];
    }

    contador.textContent = new Set(
        favoritos.map(String)
    ).size;
}

/* ======================= INICIALIZAÇÃO ======================= */

document.addEventListener("DOMContentLoaded", function () {
    carregarFoto();
    atualizarQuantidadeFavoritos();
});

window.addEventListener("storage", function (evento) {
    if (
        usuario &&
        evento.key === `livrosFavoritados_${usuario.id}`
    ) {
        atualizarQuantidadeFavoritos();
    }
});

window.addEventListener("favoritosAtualizados", function () {
    atualizarQuantidadeFavoritos();
});
