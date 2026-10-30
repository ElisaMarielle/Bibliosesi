document.addEventListener("DOMContentLoaded", () => {
  const menuBtn = document.querySelector(".bt-menu");
  const nav = document.querySelector(".navegar nav");
  const overlay = document.querySelector("#overlay");
  const adminLink = document.querySelector("#link-administracao");
  const usuario = JSON.parse(localStorage.getItem("usuario") || "null");

  if (adminLink && usuario?.funcao === "ADM") adminLink.style.display = "flex";

  function fecharMenu() {
    if (nav) nav.classList.remove("active");
    if (overlay) overlay.classList.remove("ativo");
    const main = document.querySelector("main");
    if (main) main.style.filter = "grayscale(0) blur(0)";
    document.body.style.overflow = "";
  }
  if (menuBtn && nav) {
    menuBtn.addEventListener("click", () => {
      nav.classList.toggle("active");
      const aberto = nav.classList.contains("active");
      if (overlay) overlay.classList.toggle("ativo", aberto);
      const main = document.querySelector("main");
      if (main) main.style.filter = aberto ? "grayscale(100%) blur(3px)" : "grayscale(0) blur(0)";
      document.body.style.overflow = aberto ? "hidden" : "";
    });
  }
  if (overlay) overlay.addEventListener("click", fecharMenu);
});

function logoff() {
  localStorage.removeItem("dados");
  localStorage.removeItem("token");
  localStorage.removeItem("usuario");
  window.location.href = "login.htm";
}
