<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="poliwiki.model.Usuario"%>
<%
    Usuario usuarioHeader = (Usuario) session.getAttribute("usuario");
%>
<header>
    <link href="CSS/header.css" rel="stylesheet" />
    <button id="boton_menu_lateral">&#9776</button>
    <a href="index.jsp" class="linkInicio">
        <img class="logo" src="Imgs/logo_PoliWiki.jpeg" type="img">
        <div class="eslogan">
            <h1>POLIWIKI</h1>
            <p>Comunidad Estudiantil del IPN</p>
        </div>
    </a>
    <form action="explorar.jsp" method="get">
        <input type="search" id="barraBusqueda" name="q" placeholder="Buscar en POLIWIKI">
        <button type="submit">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
                <path d="M15.5 14h-.79l-.28-.27A6.471 6.471 0 0 0 16 9.5 6.5 6.5 0 1 0 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"></path>
            </svg>
        </button>
    </form>

    <div class="auth">
        <% if (usuarioHeader == null) { %>
            <a class="login" href="iniciarSesion.jsp">Iniciar Sesión</a>
            <a class="signup" href="crearCuenta.jsp">Crear cuenta</a>
        <% } else { %>
            <div>Hola, <%= usuarioHeader.getNombres() %></div>
            <a class="signup" href="logout">Cerrar sesión</a>
        <% } %>
    </div>
</header>
