const usuario = JSON.parse(localStorage.getItem("usuario") || "null");

const url = "https://bibliosesi.vercel.app/livros/";
const urlEmprestimos = "https://bibliosesi.vercel.app/emprestimos/";
const urlFeedbacks = "https://bibliosesi.vercel.app/feedbacks/";


const colecoes = [
    {
        titulo: "Para se divertir depois de um longo dia",
        generos: ["comédia", "aventura"]
    },
    {
        titulo: "Do Brasil aos brasileiros",
        generos: ["literatura brasileira"]
    },
    {
        titulo: "Para baixinhos",
        generos: ["literatura infantil"]
    },
    {
        titulo: "Para os dramáticos",
        generos: ["drama"]
    },
    {
        titulo: "Para se arrepiar",
        generos: ["terror", "horror", "suspense", "thriller psicológico"]
    },
    {
        titulo: "Histórias curtas",
        generos: ["contos", "conto"]
    },
    {
        titulo: "Do dia a dia para a história",
        generos: ["crônica"]
    },
];

function normalizarTexto(texto) {
    return (texto || "")
        .toLocaleLowerCase("pt-BR")
        .normalize("NFD")
        .replace(/[\u0300-\u036f]/g, "")
        .trim();
}

function obterGeneros(livro) {
    return (livro.genero || "")
        .split(",")
        .map(g => normalizarTexto(g));
}

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

        // Área que envolve a fileira e os botões
        const wrapper = document.createElement("div");
        wrapper.className = "wrapper-fileira";

        const fileira = document.createElement("div");
        fileira.className = "fileira-livros";

        const livrosDaColecao = livrosCarregados.filter(livro => {
            const generosLivro = obterGeneros(livro);

            return colecao.generos.some(genero =>
                generosLivro.includes(normalizarTexto(genero))
            );
        });

        livrosDaColecao.forEach(livro => {
            fileira.appendChild(criarCardLivro(livro));
        });

        if (livrosDaColecao.length > 0) {
            // Botão para voltar
            const voltar = document.createElement("button");
            voltar.className = "controle-fileira voltar";
            voltar.innerHTML = `<img class="seta seta-esquerda" src="../img/angulo-esquerdo.png" alt="seta esquerda">`;
            voltar.setAttribute("aria-label", "Rolar para a esquerda");

            // Botão para avançar
            const avancar = document.createElement("button");
            avancar.className = "controle-fileira avancar";
            avancar.innerHTML = `<img class="seta seta-direita" src="../img/angulo-direito.png" alt="seta direita">`;
            avancar.setAttribute("aria-label", "Rolar para a direita");

            wrapper.append(fileira, voltar, avancar);
            secao.append(titulo, wrapper);
            lista.appendChild(secao);

            configurarRolagem(fileira, voltar, avancar);
        }
    });
}


function configurarRolagem(fileira, voltar, avancar) {

    function atualizarBotoes() {
        const temRolagem =
            fileira.scrollWidth > fileira.clientWidth + 1;

        if (!temRolagem) {
            voltar.style.display = "none";
            avancar.style.display = "none";
            return;
        }

        voltar.style.display =
            fileira.scrollLeft > 1 ? "flex" : "none";

        const chegouAoFinal =
            fileira.scrollLeft + fileira.clientWidth >=
            fileira.scrollWidth - 1;

        avancar.style.display =
            chegouAoFinal ? "none" : "flex";
    }

    voltar.addEventListener("click", () => {
        fileira.scrollBy({
            left: -fileira.clientWidth * 0.8,
            behavior: "smooth"
        });
    });

    avancar.addEventListener("click", () => {
        fileira.scrollBy({
            left: fileira.clientWidth * 0.8,
            behavior: "smooth"
        });
    });

    fileira.addEventListener("scroll", atualizarBotoes);

    // Verifica novamente quando a tela muda de tamanho
    if ("ResizeObserver" in window) {
        const observador = new ResizeObserver(atualizarBotoes);
        observador.observe(fileira);
    } else {
        window.addEventListener("resize", atualizarBotoes);
    }

    atualizarBotoes();
}


function renderizarResultadosPesquisa(livros, tituloSecao = "Resultados") {
    lista.innerHTML = "";

    const secao = document.createElement("section");
    secao.className = "secao-catalogo";

    const titulo = document.createElement("h2");
    titulo.className = "titulo-colecao";
    titulo.textContent = tituloSecao;

    const grade = document.createElement("div");
    grade.className = "grade-resultados";

    livros.forEach(livro => {
        grade.appendChild(criarCardLivro(livro));
    });

    if (livros.length > 0) {
        secao.append(titulo, grade);
        lista.appendChild(secao);
    } else {
        const mensagem = document.createElement("p");
        mensagem.className = "resultado-pesquisa";
        mensagem.textContent = "Nenhum livro encontrado.";
        lista.appendChild(mensagem);
    }
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
    const botao = this;
    const idLivro = Number(botao.dataset.idLivro);

    if (!idLivro) {
        alert("Livro não selecionado.");
        return;
    }

    if (!usuario || !usuario.id) {
        alert("Faça login para realizar um empréstimo.");
        return;
    }

    const idUsuario = Number(usuario.id);

    if (!idUsuario) {
        alert("ID do usuário inválido.");
        return;
    }

    botao.disabled = true;
    botao.textContent = "Emprestando...";

    try {
        const token = localStorage.getItem("token");

        const response = await fetch(urlEmprestimos + "cadastrar", {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${token}`
            },
            body: JSON.stringify({
                usuarioId: idUsuario,
                livroId: idLivro
            })
        });

        const texto = await response.text();
        let resultado;

        try {
            resultado = JSON.parse(texto);
        } catch {
            throw new Error("O servidor retornou uma resposta inválida.");
        }

        if (!response.ok) {
            throw new Error(
                resultado.erro ||
                resultado.mensagem ||
                "Erro ao realizar empréstimo."
            );
        }

        // Fecha os detalhes do livro
        document.querySelector(".livroDetalhes").style.display = "none";
        livroSelecionado = null;

        // Atualiza o catálogo sem sair da página
        await carregarLivros();

        alert("Empréstimo realizado com sucesso!");

    } catch (error) {
        console.error("Erro no empréstimo:", error);
        alert(error.message || "Erro ao realizar empréstimo.");

        botao.disabled = false;
        botao.textContent = "Emprestar";
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
    const termo = normalizarTexto(pesquisa.value);
    const categoriaSelecionada = normalizarTexto(filtro.value);
    const favoritos = obterFavoritos();

    // Se não houver pesquisa nem filtro, mostra as coleções
    if (termo === "" && categoriaSelecionada === "todos") {
        renderizarColecoes();
        return;
    }

    // Pesquisa em TODOS os livros, não apenas nos que estão nas coleções
    const resultados = livrosCarregados.filter(livro => {
        const textoLivro = [
            livro.titulo,
            livro.descricao,
            livro.autor,
            livro.publicacao,
            livro.genero
        ].join(" ");

        const correspondePesquisa =
            normalizarTexto(textoLivro).includes(termo);

        const generosLivro = obterGeneros(livro);

        const correspondeCategoria =
            categoriaSelecionada === "todos" ||
            (
                categoriaSelecionada === "favoritados"
                    ? favoritos.includes(String(livro.id))
                    : generosLivro.includes(categoriaSelecionada)
            );

        return correspondePesquisa && correspondeCategoria;
    });

    let titulo = "Resultados";

    if (categoriaSelecionada === "favoritados") {
        titulo = "Meus favoritos";
    } else if (categoriaSelecionada !== "todos") {
        titulo = filtro.options[filtro.selectedIndex].textContent;
    } else if (termo !== "") {
        titulo = "Resultados da pesquisa";
    }

    renderizarResultadosPesquisa(resultados, titulo);
}


pesquisa.addEventListener("input", aplicarFiltros);
filtro.addEventListener("change", aplicarFiltros);

carregarLivros();