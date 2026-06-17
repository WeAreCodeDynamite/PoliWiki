<%@page contentType="text/html" pageEncoding="UTF-8"%>
<link href="CSS/navBar.css" rel="stylesheet">
<script>
    document.addEventListener("DOMContentLoaded", function() {
        var path = window.location.pathname;
        var links = document.querySelectorAll(".navLinks a");

        links.forEach(function(link) {
            var href = link.getAttribute("href");
            // Usamos .includes para que funcione aunque la URL sea larga
            if (path.includes(href)) {
                link.classList.add("nav-active");
            }
        });
    });
</script>

<nav>
    <ul class="navLinks">
        <li><a href="index.jsp">Inicio</a></li>
        <li><a href="informacion.jsp">Explorar</a></li>
        <li><a href="profesores.jsp">Profesores</a></li>
        <li><a href="tramites.jsp">Trámites</a></li>
        <li><a href="EventosServlet" class="nav-link">Eventos</a></li>
        <li><a href="foritos.jsp">Foros</a></li>
        <li><a href="marketplace.jsp">MarketPlace</a></li>
        <li><a href="apuntes.jsp">Apuntes</a></li>
        <li><a href="conocer.jsp">Conoce más</a></li>
        <li><a href="material.jsp">Material de Estudio</a></li>
        <li><a href="perfil.jsp">Perfil</a></li>
    </ul>
</nav>