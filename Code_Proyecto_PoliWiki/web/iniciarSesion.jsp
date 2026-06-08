<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Iniciar sesión - PoliWiki</title>
        <link href="CSS/estiloBase.css" rel="stylesheet" />
        <link href="CSS/iniciarSesion.css" rel="stylesheet" />
    </head>
    <body>
        <%@include file="/Plantillas/header.jsp" %>
        <%@include file="/Plantillas/navBar.jsp" %>

        <% if (request.getParameter("error") != null) { %>
            <div class="error"><%= request.getParameter("error") %></div>
        <% } %>

        <div class="contenido">
            <div class="formulario">
                <img src="Imgs/logo_PoliWiki.jpeg">
                <h1>Inicia sesión</h1>
                <p>Entra con tu boleta o correo institucional</p>
                <form action="login" method="post">
                    <label for="nombre">Boleta o correo: </label>
                    <br>
                    <input id="nombre" name="acceso" type="text" placeholder="Boleta o correo" required>
                    <br>
                    <label for="confirmacontra">Contraseña: </label>
                    <br>
                    <input type="password" name="password" id="confirmacontra" placeholder="Ingresa tu contraseña" required>
                    <br>
                    <input type="submit" value="Iniciar sesión" id="submit">
                </form>
            </div>
        </div>

        <%@include file="/Plantillas/footer.jsp" %>
    </body>
</html>
