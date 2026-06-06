<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
        <link href="CSS/estiloBase.css" rel="stylesheet" />
    </head>
    <body>
        <%@include file="/Plantillas/header.jsp" %>
        <%@include file="/Plantillas/navBar.jsp" %>
        <link href="CSS/iniciarSesion.css" rel="stylesheet" />
        <div class="contenido">
            <div class="formulario">
                <img src="Imgs/logo_PoliWiki.jpeg">
                <h1>Inicia sesión</h1>
                <p>Completa tus datos para unirte a PoliWiki</p>
                <form>
                    <label for="nombre">Boleta o correo: </label>
                    <br>
                    <input id="nombre" type="text" placeholder="Boleta o correo: ">
                    <br>
                    <label for="confirmacontra">Contraseña: </label>
                    <br>
                    <input type="password" name="contra" id="confirmacontra" placeholder="Ingresa tu contraseña">
                    <br>
                    <input type="submit" value="Iniciar sesión" id="submit">
                </form>
            </div>
        </div>
        
        <%@include file="/Plantillas/footer.jsp" %>
    </body>
</html>
