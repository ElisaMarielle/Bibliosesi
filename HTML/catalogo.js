const usuario = JSON.parse(localStorage.getItem("usuario") || "null");

const url = "https://bibliosesi.vercel.app/livros/";
const urlEmprestimos = "https://bibliosesi.vercel.app/emprestimos/";
const urlFeedbacks = "https://bibliosesi.vercel.app/feedbacks/";


const colecoes = [
    {
        titulo: "Para se divertir depois de um longo dia",
        livros: [10, 12, 17, 27, 29, 36, 48]
    },
    {
        titulo: "Para baixinhos",
        livros: [10, 15, 31, 43]
    },
    {
        titulo: "O amor está no ar...",
        livros: [11, 9, 14, 16, 23, 25, 26]
    }
];


const btCadastrar = document.querySelector("#btCadastra");
const btExcluir = document.querySelector("#bt-excluir");
const btFavoritar = document.querySelector("#bt-fav");
const modal = document.querySelector(".modal-cadastro");
const form = document.querySelector("#formLivro");
const lista = document.querySelector(".catalogo-livros");
const filtro = document.querySelector("#filter");
const pesquisa = document.querySelector("#searchbook");

let livrosCarregados = [];
let livroSelecionado = null;

const chaveFavoritos = usuario && usuario.id
    ? `livrosFavoritados_${usuario.id}`
    : "livrosFavoritados_visitante";

function obterFavoritos() {
    try {
        const favoritos = JSON.parse(
            localStorage.getItem(chaveFavoritos) || "[]"
        );

        return Array.isArray(favoritos) ? favoritos.map(String) : [];
    } catch (error) {
        return [];
    }
}

function salvarFavoritos(favoritos) {
    localStorage.setItem(
        chaveFavoritos,
        JSON.stringify(favoritos)
    );

    atualizarCoracao();
    aplicarFiltros();

    window.dispatchEvent(new Event("favoritosAtualizados"));
}

function livroFavoritado(id) {
    return obterFavoritos().includes(String(id));
}

function cadastrar() {
    modal.style.display = "flex";
}

function cancelar() {
    modal.style.display = "none";

    const modalFoto = document.querySelector(".mudar-foto");

    if (modalFoto) {
        modalFoto.style.display = "none";
    }
}

if (usuario && usuario.funcao === "ADM") {
    btCadastrar.style.display = "flex";
} else {
    btCadastrar.style.display = "none";
    btExcluir.style.display = "none";
}

function estaEmprestado(livro) {
    if (!livro.emprestimos || !livro.emprestimos.length) {
        return false;
    }

    return livro.emprestimos.some(emprestimo => {
        return emprestimo.devolvido !== true;
    });
}



function renderizarColecoes() {
    lista.innerHTML = "";

    colecoes.forEach(colecao => {
        const secao = document.createElement("section");
        secao.className = "secao-catalogo";

        const titulo = document.createElement("h2");
        titulo.className = "titulo-colecao";
        titulo.textContent = colecao.titulo;

        const fileira = document.createElement("div");
        fileira.className = "fileira-livros";

        const livrosDaColecao = colecao.livros
            .map(id => livrosCarregados.find(
                livro => String(livro.id) === String(id)
            ))
            .filter(Boolean);

        livrosDaColecao.forEach(livro => {
            fileira.appendChild(criarCardLivro(livro));
        });

        if (livrosDaColecao.length > 0) {
            secao.append(titulo, fileira);
            lista.appendChild(secao);
        } else {
            console.warn(
                `Nenhum livro encontrado para a coleção: ${colecao.titulo}`,
                colecao.livros
            );
        }
    });
}


function criarCardLivro(item) {
    const livro = document.createElement("div");
    livro.className = "livro";
    livro.dataset.id = item.id;

    const detalhes = document.createElement("div");
    detalhes.className = "livros-detalhes";
    
    const sinopse = document.createElement("p");
    sinopse.className = "sinopse";
    sinopse.textContent = item.descricao || "";

    const status = document.createElement("p");
    status.className = "status";
    
    const titulo = document.createElement("h2");
    titulo.textContent = item.titulo;

    if (estaEmprestado(item)) {
        status.classList.add("emprestado");
        status.textContent = "Emprestado";
    } else {
        status.classList.add("livre");
        status.textContent = "Livre";
    }

    const imagemDiv = document.createElement("div");
    imagemDiv.className = "livros-imagem";

    const imagem = document.createElement("img");
    imagem.src = item.imagem;
    imagem.alt = "Capa de " + item.titulo;

    imagemDiv.appendChild(imagem);

    // detalhes.append(titulo, sinopse, status);

    livro.append(imagemDiv, titulo, status);

    livro.addEventListener("click", () => {
        abrirDetalhes(item);
    });

    return livro;
}


async function carregarLivros() {
    const token = localStorage.getItem("token");

    try {
        const response = await fetch(url + "listar", {
            headers: {
                Authorization: `Bearer ${token}`
            }
        });

        if (!response.ok) {
            throw new Error(
                `Erro HTTP ${response.status} ao buscar livros.`
            );
        }

        const data = await response.json();

        if (!Array.isArray(data)) {
            console.error("Resposta recebida da API:", data);
            throw new Error("A API não retornou uma lista de livros.");
        }

        livrosCarregados = data;

        console.log("Livros carregados:", livrosCarregados);
        console.log("Coleções configuradas:", colecoes);

        renderizarColecoes();
        aplicarFiltros();

    } catch (error) {
        console.error("Erro ao carregar os livros:", error);
        alert("Erro ao carregar os livros. Confira o console (F12).");
    }
}


function abrirDetalhes(livro) {
    livroSelecionado = livro;

    const modalDetalhes = document.querySelector(".livroDetalhes");
    const capa = document.querySelector("#capa");
    const titulo = document.querySelector("#tituloDetalhes");
    const descricao = document.querySelector("#descricaoDetalhes");
    const autor = document.querySelector("#autorDetalhes");
    const data = document.querySelector("#data_lancamento");
    const genero = document.querySelector("#generoDetalhes");
    const status = document.querySelector("#statusDetalhes");
    const botaoEmprestar = document.querySelector("#bt-emp");

    botaoEmprestar.dataset.idLivro = livro.id;
    btExcluir.dataset.idLivro = livro.id;

    capa.src = livro.imagem;
    capa.alt = "Capa de " + livro.titulo;
    titulo.textContent = livro.titulo;
    descricao.textContent = livro.descricao;
    autor.textContent = "Autor: " + livro.autor;
    data.textContent = "Publicação: " + livro.publicacao;

    genero.innerHTML = "";

    (livro.genero || "").split(",").forEach(g => {
        const texto = g.trim();

        if (!texto) return;

        const bloco = document.createElement("span");
        bloco.textContent = texto;
        genero.appendChild(bloco);
    });

    if (estaEmprestado(livro)) {
        status.textContent = "Emprestado";
        status.className = "emprestado";
        botaoEmprestar.disabled = true;
        botaoEmprestar.textContent = "Indisponível";
    } else {
        status.textContent = "Livre";
        status.className = "livre";
        botaoEmprestar.disabled = false;
        botaoEmprestar.textContent = "Emprestar";
    }

    btExcluir.style.display =
        usuario && usuario.funcao === "ADM" ? "flex" : "none";

    atualizarCoracao();

    modalDetalhes.style.display = "flex";
    carregarFeedbacks(livro.id);
}


async function carregarFeedbacks(livroId) {
    const listaFeedbacks = document.querySelector("#lista-feedbacks");
    const contagem = document.querySelector("#contagem-feedbacks");
    if (!listaFeedbacks || !contagem) return;

    listaFeedbacks.innerHTML = '<p class="feedbacks-vazio">Carregando comentários...</p>';
    contagem.textContent = "";

    try {
        const token = localStorage.getItem("token");

        const resposta = await fetch(
            `${urlFeedbacks}listar?livroId=${encodeURIComponent(livroId)}`,
            {
                headers: {
                    "Authorization": `Bearer ${token}`
                }
            }
        );
        const dados = await resposta.json();
        if (!resposta.ok) throw new Error(dados.mensagem || "Não foi possível carregar os feedbacks.");
        if (Number(livroSelecionado?.id) !== Number(livroId)) return;

        listaFeedbacks.innerHTML = "";
        contagem.textContent = `${dados.length} ${dados.length === 1 ? "comentário" : "comentários"}`;

        if (!Array.isArray(dados) || dados.length === 0) {
            listaFeedbacks.innerHTML = '<p class="feedbacks-vazio">Este livro ainda não recebeu comentários. Seja o primeiro a avaliar!</p>';
            return;
        }

        dados.forEach(feedback => {
            const card = document.createElement("article");
            card.className = "feedback-card";

            const avatar = document.createElement("img");
            avatar.className = "feedback-avatar";
            avatar.alt = "";
            avatar.src = feedback.usuario?.fotoPerfil || "../img/profile_placeholder.png";
            avatar.onerror = () => { avatar.onerror = null; avatar.src = "../img/profile_placeholder.png"; };

            const conteudo = document.createElement("div");
            conteudo.className = "feedback-conteudo";

            const topo = document.createElement("div");
            topo.className = "feedback-topo";

            const autor = document.createElement("span");
            autor.className = "feedback-autor";
            autor.textContent = feedback.usuario?.nome || "Usuário";

            const data = document.createElement("time");
            data.className = "feedback-data";
            if (feedback.data) {
                const dataObj = new Date(feedback.data);
                data.textContent = Number.isNaN(dataObj.getTime()) ? "" : dataObj.toLocaleDateString("pt-BR");
                if (!Number.isNaN(dataObj.getTime())) data.dateTime = dataObj.toISOString();
            }

            topo.append(autor, data);
            conteudo.appendChild(topo);

            if (feedback.nota) {
                const estrelas = document.createElement("div");
                estrelas.className = "feedback-estrelas";
                estrelas.setAttribute("aria-label", `Avaliação: ${feedback.nota} de 5 estrelas`);
                estrelas.textContent = "★".repeat(Math.max(0, Math.min(5, Number(feedback.nota)))) +
                    "☆".repeat(5 - Math.max(0, Math.min(5, Number(feedback.nota))));
                conteudo.appendChild(estrelas);
            }

            const texto = document.createElement("p");
            texto.className = "feedback-texto";
            texto.textContent = feedback.comentario || "";
            conteudo.appendChild(texto);

            card.append(avatar, conteudo);
            listaFeedbacks.appendChild(card);
        });
    } catch (erro) {
        console.error("Erro ao carregar feedbacks:", erro);
        listaFeedbacks.innerHTML = '<p class="feedbacks-vazio">Não foi possível carregar os comentários agora.</p>';
        contagem.textContent = "";
    }
}

function atualizarCoracao() {
    if (!btFavoritar || !livroSelecionado) return;

    const favoritado = livroFavoritado(livroSelecionado.id);
    const coracao = btFavoritar.querySelector("i");

    btFavoritar.classList.toggle("favoritado", favoritado);
    btFavoritar.setAttribute(
        "aria-pressed",
        String(favoritado)
    );

    btFavoritar.title = favoritado
        ? "Remover dos favoritos"
        : "Adicionar aos favoritos";

    if (coracao) {
        coracao.style.color = favoritado ? "#eb006e" : "#999999";
    }
}

btFavoritar.addEventListener("click", function () {
    if (!livroSelecionado) return;

    const id = String(livroSelecionado.id);
    const favoritos = obterFavoritos();
    const indice = favoritos.indexOf(id);

    if (indice !== -1) {
        favoritos.splice(indice, 1);
    } else {
        favoritos.push(id);
    }

    salvarFavoritos(favoritos);
});

document.querySelector(".livroDetalhes").addEventListener("click", function (e) {
    if (e.target === this) {
        this.style.display = "none";
        livroSelecionado = null;
    }
});

form.addEventListener("submit", function (e) {
    e.preventDefault();

    const novoLivro = {
        titulo: document.querySelector("#tituloCadastro").value,
        descricao: document.querySelector("#descricaoCadastro").value,
        autor: document.querySelector("#autorCadastro").value,
        publicacao: document.querySelector("#publicacaoCadastro").value,
        genero: document.querySelector("#generoCadastro").value,
        editora: document.querySelector("#editoraCadastro").value,
        imagem: document.querySelector("#imagemCadastro").value
    };

    fetch(url + "cadastrar", {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer " + localStorage.getItem("token")
        },
        body: JSON.stringify(novoLivro)
    })
        .then(response => {
            if (!response.ok) {
                throw new Error("Erro ao cadastrar livro.");
            }

            return response.json();
        })
        .then(() => {
            alert("Livro cadastrado com sucesso.");
            form.reset();
            cancelar();
            carregarLivros();
        })
        .catch(error => {
            console.error(error);
            alert("Erro ao cadastrar livro.");
        });
});

document.querySelector("#bt-emp").addEventListener("click", async function () {
    const idLivro = Number(this.dataset.idLivro);

    if (!idLivro) {
        alert("Livro não selecionado.");
        return;
    }

    if (!usuario || !usuario.id) {
        alert("Usuário não identificado. Faça login novamente.");
        return;
    }

    const idUsuario = Number(usuario.id);

    if (!idUsuario) {
        alert("ID do usuário inválido.");
        return;
    }

    this.disabled = true;
    this.textContent = "Emprestando...";

    try {
        const novoEmprestimo = {
            usuarioId: idUsuario,
            livroId: idLivro
        };

        const response = await fetch(urlEmprestimos + "cadastrar", {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer " + localStorage.getItem("token")
            },
            body: JSON.stringify(novoEmprestimo)
        });

        const resultado = await response.json();

        if (!response.ok) {
            throw new Error(
                resultado.mensagem || "Erro ao realizar empréstimo."
            );
        }

        document.querySelector(".livroDetalhes").style.display = "none";

        window.location.href = "emprestimos.htm?id=" + resultado.id;
    } catch (error) {
        console.error(error);

        alert(error.message || "Erro ao realizar empréstimo.");

        this.disabled = false;
        this.textContent = "Emprestar";
    }
});

btExcluir.addEventListener("click", function () {
    const idLivro = this.dataset.idLivro;

    if (!idLivro) {
        alert("Livro não selecionado.");
        return;
    }

    if (!confirm("Tem certeza que deseja excluir este livro?")) {
        return;
    }

    fetch(url + "excluir/" + idLivro, {
        method: "DELETE",
        headers: {
            "Authorization": "Bearer " + localStorage.getItem("token")
        }
    })
        .then(response => {
            if (!response.ok) {
                throw new Error("Erro ao excluir livro.");
            }

            return response.json();
        })
        .then(() => {
            const favoritos = obterFavoritos().filter(
                id => id !== String(idLivro)
            );

            localStorage.setItem(chaveFavoritos, JSON.stringify(favoritos));

            alert("Livro excluído com sucesso.");

            document.querySelector(".livroDetalhes").style.display = "none";
            livroSelecionado = null;

            carregarLivros();
        })
        .catch(error => {
            console.error(error);
            alert("Erro ao excluir livro.");
        });
});


function aplicarFiltros() {
    const termo = pesquisa.value
        .trim()
        .toLocaleLowerCase("pt-BR");

    const categoriaSelecionada = filtro.value
        .toLocaleLowerCase("pt-BR");

    const favoritos = obterFavoritos();

    document.querySelectorAll(".secao-catalogo").forEach(secao => {
        const generoSecao = secao.dataset.genero;

        const livros = secao.querySelectorAll(".livro");

        livros.forEach(elemento => {
            const id = String(elemento.dataset.id);

            const livro = livrosCarregados.find(
                item => String(item.id) === id
            );

            if (!livro) {
                elemento.style.display = "none";
                return;
            }

            const textoLivro = [
                livro.titulo,
                livro.descricao,
                livro.autor,
                livro.publicacao,
                livro.genero
            ]
                .join(" ")
                .toLocaleLowerCase("pt-BR");

            const correspondePesquisa =
                textoLivro.includes(termo);

            const generosLivro = (livro.genero || "")
                .split(",")
                .map(g => g.trim().toLocaleLowerCase("pt-BR"));

            const correspondeCategoria =
                categoriaSelecionada === "todos" ||
                (
                    categoriaSelecionada === "favoritados"
                        ? favoritos.includes(id)
                        : generoSecao === categoriaSelecionada &&
                          generosLivro.includes(categoriaSelecionada)
                );

            elemento.style.display =
                correspondePesquisa && correspondeCategoria
                    ? "flex"
                    : "none";
        });

        // Esconde as seções sem nenhum livro visível
        const temLivrosVisiveis = [...livros].some(
            livro => livro.style.display !== "none"
        );

        secao.style.display = temLivrosVisiveis ? "" : "none";
    });
}


pesquisa.addEventListener("input", aplicarFiltros);
filtro.addEventListener("change", aplicarFiltros);

carregarLivros();
