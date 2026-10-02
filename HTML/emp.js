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

async function carregarEmprestimo() {
    const parametros = new URLSearchParams(window.location.search);
    const id = parametros.get("id");
    try {
        let emprestimo;
        if (id) {
            const resposta = await fetch(`${urlEmprestimos}buscar/${id}`);
            const texto = await resposta.text();
            let resultado;
            try {
                resultado = JSON.parse(texto);
            } catch (erro) {
                throw new Error("O servidor não retornou um JSON válido.");
            }
            if (!resposta.ok) {
                throw new Error(resultado.mensagem || `Erro HTTP ${resposta.status}`);
            }
            emprestimo = resultado;
        } else {
            const usuario = pegarUsuario();
            if (!usuario || !usuario.id) {
                mostrarSemEmprestimo();
                return;
            }
            const resposta = await fetch(`${urlEmprestimos}listar/usuario/${usuario.id}`);
            const texto = await resposta.text();
            let emprestimos;
            try {
                emprestimos = JSON.parse(texto);
            } catch (erro) {
                throw new Error("O servidor não retornou um JSON válido.");
            }
            if (!resposta.ok) {
                throw new Error(emprestimos.mensagem || `Erro HTTP ${resposta.status}`);
            }
            if (!Array.isArray(emprestimos) || emprestimos.length === 0) {
                mostrarSemEmprestimo();
                return;
            }
            emprestimo = emprestimos[0];
        }
        console.log("Empréstimo recebido:", emprestimo);
        if (!emprestimo.livro) {
            throw new Error("Os dados do livro não foram encontrados.");
        }
        mostrarEmprestimo(emprestimo);
    } catch (erro) {
        console.error("Erro ao carregar empréstimo:", erro);
        alert(erro.message || "Não foi possível carregar o empréstimo.");
    }
}

function mostrarSemEmprestimo() {
    const empLivro = document.querySelector("#emp-livro");
    const detalhes = document.querySelector("#detalhes");
    const texto1 = document.querySelector("#texto1");
    const texto2 = document.querySelector("#texto2");
    esconderElemento(empLivro);
    esconderElemento(detalhes);
    if (texto1) mostrarElemento(texto1);
    if (texto2) mostrarElemento(texto2);
}

function mostrarEmprestimo(emprestimo) {
    const livro = emprestimo.livro;
    console.log("Livro recebido:", livro);
    const empLivro = document.querySelector("#emp-livro");
    if (empLivro) mostrarElemento(empLivro);

    const texto1 = document.querySelector("#texto1");
    if (texto1) esconderElemento(texto1);

    const texto2 = document.querySelector("#texto2");
    if (texto2) mostrarElemento(texto2);

    const imagemPrincipal = document.querySelector("#livro-img img");
    if (imagemPrincipal) {
        imagemPrincipal.src = livro.imagem;
        imagemPrincipal.alt = livro.titulo;
    }

    const tituloPrincipal = document.querySelector("#livro-info h5");
    if (tituloPrincipal) {
        tituloPrincipal.textContent = livro.titulo;
    }

    const autorPrincipal = document.querySelector("#livro-info p");
    if (autorPrincipal) {
        autorPrincipal.textContent = livro.autor;
    }

    const detalhes = document.querySelector("#detalhes");
    if (detalhes) esconderElemento(detalhes);

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

    const tags = document.querySelector(".livro-tags");
    if (tags) {
        tags.innerHTML = `
            <p>${livro.genero}</p>
            <p>${livro.publicacao}</p>
            <p>${livro.editora}</p>
        `;
    }

    if (empLivro) {
        empLivro.onclick = function () {
            const detalhes = document.querySelector("#detalhes");
            if (!detalhes) return;
            mostrarElemento(detalhes);
            if (texto2) esconderElemento(texto2);
            detalhes.scrollIntoView({
                behavior: "smooth",
                block: "nearest"
            });
        };
    }
}

async function marcarEntregue() {
    const parametros = new URLSearchParams(window.location.search);
    let id = parametros.get("id");

    if (!id) {
        const usuario = pegarUsuario();
        if (!usuario || !usuario.id) {
            alert("Usuário não encontrado.");
            return;
        }

        try {
            const resposta = await fetch(`${urlEmprestimos}listar/usuario/${usuario.id}`);
            const emprestimos = await resposta.json();

            if (!Array.isArray(emprestimos) || emprestimos.length === 0) {
                alert("Nenhum empréstimo encontrado.");
                return;
            }

            id = emprestimos[0].id;
        } catch (erro) {
            console.error(erro);
            alert("Não foi possível encontrar o empréstimo.");
            return;
        }
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
                resultado.mensagem || "Erro ao marcar como entregue."
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
    carregarEmprestimo();
});