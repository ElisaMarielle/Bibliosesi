const urlEmprestimos = "https://bibliosesi.vercel.app/emprestimos/";

function pegarUsuario() {
    const dados = localStorage.getItem("dados");

    if (!dados) return null;

    try {
        return JSON.parse(dados);
    } catch (erro) {
        console.error("Erro ao ler dados do usuário:", erro);
        return null;
    }
}

function mostrarElemento(elemento) {
    if (!elemento) return;

    if (elemento.id === "detalhes") {
        elemento.style.display = "flex";
    } else {
        elemento.style.removeProperty("display");
    }
}

function esconderElemento(elemento) {
    if (!elemento) return;

    elemento.style.display = "none";
}

let emprestimosAtuais = [];
let emprestimoSelecionado = null;
let avaliacaoSelecionada = 0;

async function carregarEmprestimo() {
    const parametros = new URLSearchParams(window.location.search);
    const id = parametros.get("id");

    try {
        if (id) {
            const resposta = await fetch(`${urlEmprestimos}buscar/${id}`);
            const texto = await resposta.text();

            let emprestimo;

            try {
                emprestimo = JSON.parse(texto);
            } catch (erro) {
                throw new Error("O servidor não retornou um JSON válido.");
            }

            if (!resposta.ok) {
                throw new Error(
                    emprestimo.mensagem || `Erro HTTP ${resposta.status}`
                );
            }

            if (!emprestimo.livro) {
                throw new Error("Os dados do livro não foram encontrados.");
            }

            emprestimosAtuais = [emprestimo];

            mostrarListaEmprestimos(emprestimosAtuais);
            selecionarEmprestimo(emprestimo);

            return;
        }

        const usuario = pegarUsuario();

        if (!usuario || !usuario.id) {
            mostrarSemEmprestimo();
            return;
        }

        const resposta = await fetch(
            `${urlEmprestimos}listar/usuario/${usuario.id}`
        );

        const texto = await resposta.text();

        let emprestimos;

        try {
            emprestimos = JSON.parse(texto);
        } catch (erro) {
            throw new Error("O servidor não retornou um JSON válido.");
        }

        if (!resposta.ok) {
            throw new Error(
                emprestimos.mensagem || `Erro HTTP ${resposta.status}`
            );
        }

        if (!Array.isArray(emprestimos) || emprestimos.length === 0) {
            mostrarSemEmprestimo();
            return;
        }

        emprestimosAtuais = emprestimos;

        console.log("Empréstimos recebidos:", emprestimos);

        mostrarListaEmprestimos(emprestimos);

        selecionarEmprestimo(emprestimos[0]);

    } catch (erro) {
        console.error("Erro ao carregar empréstimos:", erro);

        alert(
            erro.message ||
            "Não foi possível carregar os empréstimos."
        );
    }
}

function mostrarSemEmprestimo() {
    const lista = document.querySelector(".emp-lista-grid");
    const detalhes = document.querySelector("#detalhes");
    const texto1 = document.querySelector("#texto1");
    const texto2 = document.querySelector("#texto2");

    if (lista) {
        lista.innerHTML = "";
    }

    esconderElemento(detalhes);

    if (texto1) {
        mostrarElemento(texto1);
    }

    if (texto2) {
        mostrarElemento(texto2);
    }
}

function mostrarListaEmprestimos(emprestimos) {
    const lista = document.querySelector(".emp-lista-grid");

    if (!lista) return;

    lista.innerHTML = "";

    const texto1 = document.querySelector("#texto1");
    const texto2 = document.querySelector("#texto2");

    if (texto1) {
        esconderElemento(texto1);
    }

    if (texto2) {
        mostrarElemento(texto2);
    }

    emprestimos.forEach((emprestimo) => {

        if (!emprestimo.livro) return;

        const livro = emprestimo.livro;

        const empLivro = document.createElement("div");

        empLivro.className = "emp-livro";
        empLivro.dataset.id = emprestimo.id;

        empLivro.innerHTML = `
            <div class="emp-livro-img">
                <img src="${livro.imagem}" alt="${livro.titulo}">
            </div>

            <div class="emp-livro-info">
                <h5>${livro.titulo}</h5>
                <p>${livro.autor}</p>
                <span>Em posse</span>
            </div>
        `;

        empLivro.addEventListener("click", function () {
            selecionarEmprestimo(emprestimo);
        });

        lista.appendChild(empLivro);
    });
}

function selecionarEmprestimo(emprestimo) {
    if (!emprestimo || !emprestimo.livro) return;

    emprestimoSelecionado = emprestimo;

    const livro = emprestimo.livro;

    console.log("Livro selecionado:", livro);
    console.log("Empréstimo selecionado:", emprestimo);

    const texto2 = document.querySelector("#texto2");

    if (texto2) {
        esconderElemento(texto2);
    }

    const detalhes = document.querySelector("#detalhes");

    if (detalhes) {
        mostrarElemento(detalhes);
    }

    const imagemDetalhes = document.querySelector(".det-img img");

    if (imagemDetalhes) {
        imagemDetalhes.src = livro.imagem;
        imagemDetalhes.alt = livro.titulo;
    }

    const tituloDetalhes = document.querySelector(".det-desc h3");

    if (tituloDetalhes) {
        tituloDetalhes.textContent = livro.titulo;
    }

    const descricao = document.querySelector(".det-desc p");

    if (descricao) {
        descricao.textContent = livro.descricao;
    }

    criarGeneros(livro.genero);

    const publicacao = document.querySelector(".livro-publicacao");
    const editora = document.querySelector(".livro-editora");

    if (publicacao) {
        publicacao.textContent = livro.publicacao
            ? livro.publicacao
            : "";
    }

    if (editora) {
        editora.textContent = livro.editora
            ? livro.editora
            : "";
    }

    limparAvaliacao();

    const cards = document.querySelectorAll(".emp-livro");

    cards.forEach((card) => {

        card.classList.remove("selecionado");

        if (Number(card.dataset.id) === Number(emprestimo.id)) {
            card.classList.add("selecionado");
        }

    });

    detalhes.scrollIntoView({
        behavior: "smooth",
        block: "nearest"
    });
}

function criarGeneros(generos) {
    const tags = document.querySelector(".livro-tags");

    if (!tags) return;

    tags.innerHTML = "";

    if (!generos) return;

    const listaGeneros = generos
        .split(",")
        .map((genero) => genero.trim())
        .filter((genero) => genero !== "");

    listaGeneros.forEach((genero) => {

        const tag = document.createElement("p");

        tag.textContent = genero;

        tags.appendChild(tag);

    });
}

function configurarEstrelas() {
    const estrelas = document.querySelectorAll(".stars i");

    estrelas.forEach((estrela) => {

        estrela.addEventListener("click", function () {

            const valor = Number(this.dataset.star);

            avaliacaoSelecionada = valor;

            estrelas.forEach((item) => {

                const numero = Number(item.dataset.star);

                if (numero <= valor) {

                    item.classList.remove("fa-regular");
                    item.classList.add("fa-solid");

                } else {

                    item.classList.remove("fa-solid");
                    item.classList.add("fa-regular");

                }

            });

        });

        estrela.addEventListener("mouseenter", function () {

            const valor = Number(this.dataset.star);

            estrelas.forEach((item) => {

                const numero = Number(item.dataset.star);

                if (numero <= valor) {

                    item.classList.add("hover");

                } else {

                    item.classList.remove("hover");

                }

            });

        });

    });

    const areaEstrelas = document.querySelector(".stars");

    if (areaEstrelas) {

        areaEstrelas.addEventListener("mouseleave", function () {

            estrelas.forEach((item) => {
                item.classList.remove("hover");
            });

        });

    }
}

function limparAvaliacao() {
    avaliacaoSelecionada = 0;

    const estrelas = document.querySelectorAll(".stars i");

    estrelas.forEach((estrela) => {

        estrela.classList.remove("fa-solid");
        estrela.classList.add("fa-regular");
        estrela.classList.remove("hover");

    });
}

async function marcarEntregue() {
    if (!emprestimoSelecionado) {
        alert("Selecione um livro primeiro.");
        return;
    }

    const id = emprestimoSelecionado.id;

    if (!id) {
        alert("ID do empréstimo não encontrado.");
        return;
    }

    try {

        const resposta = await fetch(
            `${urlEmprestimos}atualizar/${id}`,
            {
                method: "PUT",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({
                    data_devolucao: new Date().toISOString()
                })
            }
        );

        const resultado = await resposta.json();

        if (!resposta.ok) {
            throw new Error(
                resultado.mensagem ||
                "Erro ao marcar como entregue."
            );
        }

        alert("Livro marcado como entregue!");

        window.location.href = "emprestimos.htm";

    } catch (erro) {

        console.error("Erro ao marcar como entregue:", erro);

        alert(
            erro.message ||
            "Não foi possível marcar o livro como entregue."
        );
    }
}

function comentario() {
    const campo = document.querySelector("#comentario");

    if (!campo) return;

    const texto = campo.value.trim();

    if (!texto) {
        alert("Digite um comentário.");
        return;
    }

    alert("Comentário enviado!");

    campo.value = "";
}

function comentar() {
    comentario();
}

document.addEventListener("DOMContentLoaded", function () {

    configurarEstrelas();
    carregarEmprestimo();

});