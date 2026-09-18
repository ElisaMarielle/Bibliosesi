const url = 'https://bibliosesi.vercel.app/usuarios/'


//=====================================================================//


document.getElementById("bt-cadastrar").addEventListener("click", (event) => {
    event.preventDefault();

    const emailValue = email.value.trim().toLowerCase();

    if (!emailValue.endsWith('@portalsesisp.org.br')) {
        alert('O e-mail deve ser institucional (@portalsesisp.org.br)');
        return;
    }

    const rmValue = rm.value.trim();
    if (!/^\d{4}$/.test(rmValue)) {
        alert('O RM deve conter exatamente 4 números.');
        return;
    }

    const novoUsuario = {
        nome: nome.value,
        email: emailValue,
        senha: senha.value,
        rm: Number(rmValue),
        funcao: funcao.value
    };

    console.log(novoUsuario);

    fetch(url + 'cadastrar', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(novoUsuario)
    })
        .then(res => {
            if (!res.ok) {
                throw new Error('Erro na API');
            }
        })
        .then(() => {
            alert("Cadastro realizado.");
            window.location.href = "login.htm";
        })
        .catch(() => alert("Erro ao cadastrar"));
});



function decodeJWT(token) {
    const payload = token.split('.')[1];

    const decodedPayload = atob(payload);

    return JSON.parse(decodedPayload);
}


function login() {
    const email = document.querySelector("#email").value;
    const senha = document.querySelector("#senha").value;

    fetch("https://bibliosesi.vercel.app/auth/login", {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({
            email: email,
            senha: senha
        })
    })
    .then(resp => {
        if (!resp.ok) {
            throw new Error("Email ou senha inválidos");
        }

        return resp.json();
    })
    .then(data => {
        const dados = decodeJWT(data.token);

        localStorage.setItem("token", data.token);
        localStorage.setItem("dados", JSON.stringify(dados));
        window.location.href = "inicial.htm";
    })
    .catch(err => {
        console.log(err);
        alert(err.message);
    });
}
