
/* ======================= FOTO DE PERFIL ======================= */

const modalFoto = document.querySelector(".mudar-foto");

function mudarFoto() {
    modalFoto.style.display = "flex";
}

function cancelar() {
    modalFoto.style.display = "none";
}

async function salvarFoto() {
    const input = document.querySelector("#foto");
    const arquivo = input.files[0];

    if (!arquivo) {
        alert("Selecione uma imagem primeiro.");
        return;
    }

    const tiposPermitidos = ["image/png", "image/jpeg", "image/webp"];
    if (!tiposPermitidos.includes(arquivo.type)) {
        alert("Selecione uma imagem PNG, JPG ou WEBP.");
        return;
    }

    const usuarioAtual = JSON.parse(localStorage.getItem("usuario") || "null");
    if (!usuarioAtual || !usuarioAtual.id) {
        alert("Faça login novamente para salvar sua foto.");
        return;
    }

    try {
        // Redimensiona a foto para reduzir o tamanho armazenado no banco.
        const fotoBase64 = await new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onerror = () => reject(new Error("Não foi possível ler a imagem."));
            reader.onload = () => {
                const imagem = new Image();
                imagem.onerror = () => reject(new Error("Arquivo de imagem inválido."));
                imagem.onload = () => {
                    const maxLado = 500;
                    const escala = Math.min(1, maxLado / Math.max(imagem.width, imagem.height));
                    const canvas = document.createElement("canvas");
                    canvas.width = Math.max(1, Math.round(imagem.width * escala));
                    canvas.height = Math.max(1, Math.round(imagem.height * escala));
                    const contexto = canvas.getContext("2d");
                    contexto.drawImage(imagem, 0, 0, canvas.width, canvas.height);
                    resolve(canvas.toDataURL("image/jpeg", 0.78));
                };
                imagem.src = reader.result;
            };
            reader.readAsDataURL(arquivo);
        });

        const resposta = await fetch(`https://bibliosesi.vercel.app/usuarios/atualizar/${usuarioAtual.id}`, {
            method: "PUT",
            headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer " + (localStorage.getItem("token") || "")
            },
            body: JSON.stringify({ fotoPerfil: fotoBase64 })
        });
        const resultado = await resposta.json().catch(() => ({}));
        if (!resposta.ok) {
            throw new Error(resultado.mensagem || "Não foi possível salvar a foto no servidor.");
        }

        const usuarioAtualizado = { ...usuarioAtual, ...resultado, fotoPerfil: fotoBase64 };
        localStorage.setItem("usuario", JSON.stringify(usuarioAtualizado));
        localStorage.setItem("fotoPerfil", fotoBase64);
        document.querySelector("#foto-perfil").src = fotoBase64;
        modalFoto.style.display = "none";
        alert("Foto de perfil salva. Ela aparecerá nos seus feedbacks para todos os usuários.");
    } catch (erro) {
        console.error("Erro ao salvar foto:", erro);
        alert(erro.message || "Não foi possível salvar a foto.");
    }
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
    const fotoSalva = (usuario && usuario.fotoPerfil) || localStorage.getItem("fotoPerfil");

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
