const API = "https://bibliosesi.vercel.app";
const usuario = JSON.parse(localStorage.getItem("usuario") || "null");
const token = localStorage.getItem("token") || "";
const headersAuth = { "Authorization": "Bearer " + token };

function mudarFoto() { document.querySelector(".mudar-foto").style.display = "flex"; }
function cancelar() { document.querySelector(".mudar-foto").style.display = "none"; }

function salvarFoto() {
    const arquivo = document.querySelector("#foto").files[0];

    if (!arquivo) return alert("Selecione uma imagem primeiro.");

    if (!arquivo.type.startsWith("image/")) {
        return alert("Selecione uma imagem válida.");
    }

    if (!usuario?.id) return alert("Faça login novamente.");

    const reader = new FileReader();

    reader.onload = function () {
        localStorage.setItem(`fotoPerfil_${usuario.id}`, reader.result);

        document.querySelector("#foto-perfil").src = reader.result;
        document.querySelector(".mudar-foto").style.display = "none";

        alert("Foto de perfil atualizada!");
    };

    reader.readAsDataURL(arquivo);
}

const fotoSalva = localStorage.getItem(`fotoPerfil_${usuario.id}`);

if (fotoSalva) {
    document.querySelector("#foto-perfil").src = fotoSalva;
}

function formatarData(valor) {
    if (!valor) return "—";
    return new Date(valor).toLocaleDateString("pt-BR");
}
function criarLinha(texto, classe = "") {
    const li = document.createElement("li");
    li.textContent = texto;
    if (classe) li.className = classe;
    return li;
}

async function carregarPerfil() {
    if (!usuario?.id || !token) {
        alert("Faça login novamente.");
        location.href = "login.htm";
        return;
    }
    document.querySelector("#nome").textContent = usuario.nome || "";
    document.querySelector("#rm").textContent = usuario.rm ? `RM: ${usuario.rm}` : "";
    document.querySelector("#email").textContent = usuario.email || "";
    if (usuario.fotoPerfil) document.querySelector("#foto-perfil").src = usuario.fotoPerfil;
    if (usuario.funcao === "ADM") document.querySelector("#link-administracao").style.display = "flex";

    let favoritos = [];
    try {
        const salvos = JSON.parse(localStorage.getItem(`livrosFavoritados_${usuario.id}`) || "[]");
        favoritos = Array.isArray(salvos) ? salvos : [];
    } catch (_) { favoritos = []; }
    document.querySelector("#favoritos-count").textContent = new Set(favoritos.map(String)).size;

    const historico = document.querySelector("#historico-emprestimos");
    const posse = document.querySelector("#livros-em-posse");
    const favoritosLista = document.querySelector("#livros-favoritos");
    const avisos = document.querySelector("#lista-avisos");
    try {
        const r = await fetch(`${API}/emprestimos/listar/usuario/${usuario.id}`, { headers: headersAuth });
        const dados = await r.json();
        if (!r.ok) throw new Error(dados.mensagem || "Não foi possível carregar seus empréstimos.");
        const emprestimos = Array.isArray(dados) ? dados : [];
        const ativos = emprestimos.filter(e => !e.devolvido);
        document.querySelector("#emprestados-count").textContent = emprestimos.length;
        document.querySelector("#posse-count").textContent = ativos.length;

        historico.innerHTML = "";
        if (!emprestimos.length) historico.appendChild(criarLinha("Você ainda não realizou empréstimos."));
        posse.innerHTML = "";
        if (!ativos.length) posse.appendChild(criarLinha("Você não tem livros em posse no momento."));
        ativos.forEach(e => {
            const p = document.createElement("p");
            p.textContent = `${e.livro?.titulo || "Livro"} — Devolver até ${formatarData(e.data_devolucao)}`;
            posse.appendChild(p);
        });

        emprestimos.forEach(e => {
            const livro = e.livro?.titulo || "Livro";
            const status = e.devolvido ? "Devolvido" : (new Date(e.data_devolucao) < new Date() ? "Atrasado" : "Em posse");
            const p = document.createElement("p");
            p.textContent = `${livro} — Retirada: ${formatarData(e.data_emprestimo)} — Prazo: ${formatarData(e.data_devolucao)} — ${status}`;
            historico.appendChild(p);
        });

        favoritosLista.innerHTML = "";
        const idsFavoritos = [...new Set(favoritos.map(String))];
        if (!idsFavoritos.length) favoritosLista.appendChild(criarLinha("Você ainda não favoritou livros."));
        else {
            const livrosResposta = await fetch(`${API}/livros/listar`);
            const livros = await livrosResposta.json();
            if (!livrosResposta.ok) throw new Error("Não foi possível carregar seus favoritos.");
            idsFavoritos.forEach(id => {
                const livro = livros.find(l => String(l.id) === id);
                if (livro) favoritosLista.appendChild(criarLinha(livro.titulo));
            });
        }

        avisos.innerHTML = "";
        const hoje = new Date(); hoje.setHours(0,0,0,0);
        const pendentes = ativos.map(e => {
            const prazo = new Date(e.data_devolucao); prazo.setHours(0,0,0,0);
            return { e, dias: Math.ceil((prazo - hoje) / 86400000) };
        }).filter(x => x.dias <= 3);
        if (!pendentes.length) avisos.appendChild(criarLinha("Você não tem empréstimos próximos do vencimento."));
        pendentes.forEach(({e,dias}) => {
            const titulo = e.livro?.titulo || "Livro";
            avisos.appendChild(criarLinha(dias < 0
                ? `⚠ "${titulo}" está atrasado há ${Math.abs(dias)} dia(s).`
                : dias === 0 ? `⚠ "${titulo}" vence hoje.`
                : ` "${titulo}" vence em ${dias} dia(s).`));
        });
    } catch (e) {
        historico.textContent = e.message;
        avisos.textContent = "Não foi possível carregar os avisos.";
    }
}

document.addEventListener("DOMContentLoaded", carregarPerfil);
