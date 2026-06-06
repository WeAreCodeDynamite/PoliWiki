const botonMenuLateral = document.getElementById("boton_menu_lateral");
const menuLateral = document.getElementById("menuLateral");

botonMenuLateral.addEventListener("click",() => {
    menuLateral.classList.toggle("hidden");
});