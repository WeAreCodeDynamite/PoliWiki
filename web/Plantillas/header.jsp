<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="poliwiki.model.Usuario"%>
<%
    Usuario usuarioHeader = (Usuario) session.getAttribute("usuario");
%>
<link href="CSS/header.css" rel="stylesheet" />

<header class="main-header">
    <a href="index.jsp" class="brand-container">
        <img class="logo" src="Imgs/logo_PoliWiki.jpeg" alt="Logo PoliWiki">
        <div class="eslogan">
            <h1>POLIWIKI</h1>
            <p>Comunidad Estudiantil del IPN</p>
        </div>
    </a>

    <div class="auth-container">
        <% if (usuarioHeader == null) { %>
            <a class="btn-auth login" href="iniciarSesion.jsp">Iniciar Sesión</a>
            <a class="btn-auth signup" href="crearCuenta.jsp">Crear cuenta</a>
        <% } else { %>
            <div class="user-logged-container">
                <div class="user-info">
                    <span class="user-welcome">Hola, <%= usuarioHeader.getNombreCompleto() %></span>
                    <span class="user-career"><%= usuarioHeader.getCarrera() %></span>
                </div>
                <a class="btn-logout" href="logout">Cerrar sesión</a>
            </div>
        <% } %>
    </div>
</header>