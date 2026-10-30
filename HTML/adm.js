const API_ADMIN = "https://bibliosesi.vercel.app";
const adminUser = JSON.parse(localStorage.getItem("usuario") || "null");
const adminToken = localStorage.getItem("token") || "";
const authHeaders = { "Authorization": "Bearer " + adminToken };
let emprestimosAdmin = [], usuariosAdmin = [];

function dataBR(v) { return v ? new Date(v).toLocaleDateString("pt-BR") : "—"; }
function escapar(v) { return String(v ?? "").replace(/[&<>"']/g, c => ({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[c])); }
async function requisicao(url, op={}) {
    const r = await fetch(url, { ...op, headers: { ...authHeaders, ...(op.headers || {}) } });
    const data = await r.json().catch(() => ({}));
    if (!r.ok) throw new Error(data.mensagem || `Erro HTTP ${r.status}`);
    return data;
}
function exigirAdm() {
    if (!adminUser || adminUser.funcao !== "ADM" || !adminToken) {
        alert("Esta página é exclusiva para administradores.");
        location.href = "inicial.htm";
        return false;
    }
    return true;
}
async function carregarAdmin() {
    if (!exigirAdm()) return;
    try {
        [emprestimosAdmin, usuariosAdmin] = await Promise.all([
            requisicao(`${API_ADMIN}/emprestimos/listar`),
            requisicao(`${API_ADMIN}/usuarios/listar`)
        ]);
        renderEmprestimos(); renderUsuarios(); atualizarResumo();
    } catch(e) { alert(e.message); }
}
function atualizarResumo() {
    const ativos = emprestimosAdmin.filter(e => !e.devolvido);
    document.querySelector("#total-ativos").textContent = ativos.length;
    document.querySelector("#total-atrasados").textContent = ativos.filter(e => new Date(e.data_devolucao) < new Date()).length;
    document.querySelector("#total-usuarios").textContent = usuariosAdmin.length;
}
function renderEmprestimos() {
    const tbody = document.querySelector("#tabela-emprestimos");
    const termo = document.querySelector("#busca-emprestimo").value.toLocaleLowerCase("pt-BR");
    const lista = emprestimosAdmin.filter(e => `${e.livro?.titulo} ${e.usuario?.nome} ${e.usuario?.rm}`.toLocaleLowerCase("pt-BR").includes(termo));
    tbody.innerHTML = "";
    if (!lista.length) { tbody.innerHTML = '<tr><td colspan="6" class="vazio">Nenhum empréstimo encontrado.</td></tr>'; return; }
    lista.forEach(e => {
        const atrasado = !e.devolvido && new Date(e.data_devolucao) < new Date();
        const status = e.devolvido ? '<span class="status-pill devolvido">Devolvido</span>' : atrasado ? '<span class="status-pill atrasado">Em atraso</span>' : '<span class="status-pill">Em posse</span>';
        const tr = document.createElement("tr");
        tr.innerHTML = `<td>${escapar(e.livro?.titulo)}</td><td>${escapar(e.usuario?.nome)}<br><small>RM ${escapar(e.usuario?.rm)}</small></td><td>${dataBR(e.data_emprestimo)}</td><td>${dataBR(e.data_devolucao)}</td><td>${status}</td><td class="acoes">${e.devolvido ? '<button class="secundario" data-action="reabrir">Reabrir</button>' : '<button data-action="prazo">Alterar prazo</button><button class="secundario" data-action="devolver">Registrar devolução</button>'}</td>`;
        tr.querySelectorAll("button").forEach(b => b.addEventListener("click", () => acaoEmprestimo(e, b.dataset.action)));
        tbody.appendChild(tr);
    });
}
async function acaoEmprestimo(e, acao) {
    try {
        let body = {};
        if (acao === "devolver") {
            if (!confirm(`Confirmar a devolução de "${e.livro?.titulo}"?`)) return;
            body = { devolvido: true };
        } else if (acao === "reabrir") {
            if (!confirm("Reabrir este empréstimo? O prazo será reiniciado para 14 dias a partir de hoje.")) return;
            const hoje = new Date(), prazo = new Date(); prazo.setDate(prazo.getDate()+14);
            body = { devolvido: false, data_emprestimo: hoje.toISOString(), data_devolucao: prazo.toISOString() };
        } else {
            const atual = new Date(e.data_devolucao);
            const valor = prompt("Informe a nova data de devolução (DD/MM/AAAA):", atual.toLocaleDateString("pt-BR"));
            if (!valor) return;
            const m = valor.match(/^(\d{2})\/(\d{2})\/(\d{4})$/);
            if (!m) return alert("Data inválida. Use DD/MM/AAAA.");
            const nova = new Date(Number(m[3]), Number(m[2])-1, Number(m[1]));
            if (Number.isNaN(nova.getTime())) return alert("Data inválida.");
            body = { data_devolucao: nova.toISOString() };
        }
        await requisicao(`${API_ADMIN}/emprestimos/atualizar/${e.id}`, { method:"PUT", headers:{"Content-Type":"application/json"}, body:JSON.stringify(body) });
        await carregarAdmin();
    } catch(err) { alert(err.message); }
}
function renderUsuarios() {
    const tbody = document.querySelector("#tabela-usuarios");
    const termo = document.querySelector("#busca-usuario").value.toLocaleLowerCase("pt-BR");
    const lista = usuariosAdmin.filter(u => `${u.nome} ${u.email} ${u.rm}`.toLocaleLowerCase("pt-BR").includes(termo));
    tbody.innerHTML = "";
    if (!lista.length) { tbody.innerHTML = '<tr><td colspan="5" class="vazio">Nenhum usuário encontrado.</td></tr>'; return; }
    lista.forEach(u => {
        const tr = document.createElement("tr");
        tr.innerHTML = `<td>${escapar(u.nome)}</td><td>${escapar(u.email)}</td><td>${escapar(u.rm)}</td><td>${escapar(u.funcao)}</td><td class="acoes"><button data-action="perfil">Alterar perfil</button><button class="secundario" data-action="excluir">Excluir</button></td>`;
        tr.querySelector('[data-action="perfil"]').addEventListener("click", () => alterarPerfil(u));
        tr.querySelector('[data-action="excluir"]').addEventListener("click", () => excluirUsuario(u));
        tbody.appendChild(tr);
    });
}
async function alterarPerfil(u) {
    const novo = prompt(`Perfil de ${u.nome}: digite ALUNO ou ADM`, u.funcao);
    if (!novo) return;
    const funcao = novo.trim().toUpperCase();
    if (!["ALUNO","ADM"].includes(funcao)) return alert("Perfil inválido.");
    if (u.id === adminUser.id && funcao !== "ADM") return alert("Você não pode remover seu próprio acesso administrativo.");
    try {
        await requisicao(`${API_ADMIN}/usuarios/atualizar/${u.id}`, { method:"PUT", headers:{"Content-Type":"application/json"}, body:JSON.stringify({funcao}) });
        await carregarAdmin();
    } catch(e) { alert(e.message); }
}
async function excluirUsuario(u) {
    if (u.id === adminUser.id) return alert("Você não pode excluir sua própria conta.");
    if (!confirm(`Excluir o usuário ${u.nome}? A exclusão pode ser impedida se houver empréstimos ou feedbacks vinculados.`)) return;
    try {
        await requisicao(`${API_ADMIN}/usuarios/excluir/${u.id}`, { method:"DELETE" });
        await carregarAdmin();
    } catch(e) { alert(e.message); }
}
document.querySelector("#busca-emprestimo").addEventListener("input", renderEmprestimos);
document.querySelector("#busca-usuario").addEventListener("input", renderUsuarios);
document.querySelector("#atualizar").addEventListener("click", carregarAdmin);
document.addEventListener("DOMContentLoaded", carregarAdmin);
