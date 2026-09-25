const dados = JSON.parse(localStorage.getItem("dados"));
const url = "https://bibliosesi.vercel.app/livros/";
const btCadastrar = document.querySelector("#btCadastra");
const btExcluir = document.querySelector("#bt-excluir");
const modal = document.querySelector(".modal-cadastro");
const form = document.querySelector("#formLivro");
const lista = document.querySelector(".catalogo-livros");

function cadastrar() {
    modal.style.display = "flex";
}

function cancelar() {
    modal.style.display = "none";
}

if (dados && dados.funcao === "ADM") {
    btCadastrar.style.display = "flex";
    btExcluir.style.display = "flex";
} else {
    btCadastrar.style.display = "none";
    btExcluir.style.display = "none";
}

function carregarLivros() {
    fetch(url + "listar")
        .then(response => {
            if (!response.ok) {
                throw new Error("Erro ao buscar livros");
            }
            return response.json();
        })
        .then(data => {
            console.log("Livros recebidos:", data);
            lista.innerHTML = "";
            data.forEach(item => {
                const livro = document.createElement("div");
                livro.className = "livro";
                const detalhes = document.createElement("div");
                detalhes.className = "livros-detalhes";
                const titulo = document.createElement("h2");
                titulo.textContent = item.titulo;
                const sinopse = document.createElement("p");
                sinopse.className = "sinopse";
                sinopse.textContent = item.descricao;
                const status = document.createElement("p");
                status.className = "status";
                let emprestado = false;
                if (item.emprestimos) {
                    const agora = new Date();
                    emprestado = item.emprestimos.some(emprestimo => {
                        const dataDevolucao = new Date(emprestimo.data_devolucao);
                        return dataDevolucao > agora;
                    });
                }
                if (emprestado) {
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
                const categoria = document.createElement("p");
                categoria.className = "categoria";
                categoria.hidden = true;
                categoria.textContent = item.genero;
                detalhes.appendChild(titulo);
                detalhes.appendChild(sinopse);
                detalhes.appendChild(status);
                livro.appendChild(detalhes);
                livro.appendChild(imagemDiv);
                livro.appendChild(categoria);
                lista.appendChild(livro);
                livro.addEventListener("click", function() {
                    abrirDetalhes(item);
                });
            });
        })
        .catch(error => {
            console.log(error);
            alert("Erro ao carregar os livros.");
        });
}

function abrirDetalhes(livro) {
    const modalDetalhes = document.querySelector(".livroDetalhes");
    const capa = document.querySelector("#capa");
    const titulo = document.querySelector("#tituloDetalhes");
    const descricao = document.querySelector("#descricaoDetalhes");
    const autor = document.querySelector("#autorDetalhes");
    const data = document.querySelector("#data_lancamento");
    const genero = document.querySelector("#generoDetalhes");
    const status = document.querySelector("#statusDetalhes");
    const botaoEmprestar = document.querySelector("#bt-emp");
    const btExcluir = document.querySelector("#bt-excluir");
    botaoEmprestar.dataset.idLivro = livro.id;
    btExcluir.dataset.idLivro = livro.id;
    capa.src = livro.imagem;
    capa.alt = "Capa de " + livro.titulo;
    titulo.textContent = livro.titulo;
    descricao.textContent = livro.descricao;
    autor.textContent = "Autor: " + livro.autor;
    data.textContent = "Publicação: " + livro.publicacao;
    genero.textContent = "Gênero: " + livro.genero;
    let emprestado = false;
    if (livro.emprestimos) {
        const agora = new Date();
        emprestado = livro.emprestimos.some(emprestimo => {
            const dataDevolucao = new Date(emprestimo.data_devolucao);
            return dataDevolucao > agora;
        });
    }
    if (emprestado) {
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
    modalDetalhes.style.display = "flex";
}

document.querySelector(".livroDetalhes").addEventListener("click", function(e) {
    if (e.target.classList.contains("livroDetalhes")) {
        e.currentTarget.style.display = "none";
    }
});

form.addEventListener("submit", function(e) {
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
    console.log("Livro enviado:", novoLivro);
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
                throw new Error("Erro na API");
            }
            return response.json();
        })
        .then(data => {
            console.log(data);
            alert("Livro cadastrado com sucesso.");
            form.reset();
            cancelar();
            carregarLivros();
        })
        .catch(error => {
            console.log(error);
            alert("Erro ao cadastrar livro.");
        });
});

document.querySelector("#bt-emp").addEventListener("click", function() {
    const idLivro = this.dataset.idLivro;
    if (!idLivro) {
        alert("Livro não selecionado.");
        return;
    }
    console.log("ID do livro:", idLivro);
    alert("Livro selecionado: " + idLivro);
});

document.querySelector("#bt-excluir").addEventListener("click", function() {
    const idLivro = this.dataset.idLivro;
    if (!idLivro) {
        alert("Livro não selecionado.");
        return;
    }
    const confirmar = confirm("Tem certeza que deseja excluir este livro?");
    if (!confirmar) {
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
                throw new Error("Erro ao excluir livro");
            }
            return response.json();
        })
        .then(data => {
            console.log(data);
            alert("Livro excluído com sucesso.");
            document.querySelector(".livroDetalhes").style.display = "none";
            carregarLivros();
        })
        .catch(error => {
            console.log(error);
            alert("Erro ao excluir livro.");
        });
});

document.querySelector("#searchbook").addEventListener("input", function() {
    const pesquisa = this.value.toLowerCase();
    const livros = document.querySelectorAll(".livro");
    livros.forEach(livro => {
        const texto = livro.textContent.toLowerCase();
        if (texto.includes(pesquisa)) {
            livro.style.display = "flex";
        } else {
            livro.style.display = "none";
        }
    });
});

carregarLivros();