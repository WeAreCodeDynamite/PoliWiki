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
        <link rel="stylesheet" href="CSS/crearCuenta.css"/>
        <div class="contenido">
            <div class="formulario">
                <img src="Imgs/logo_PoliWiki.jpeg">
                <h1>Crear cuenta</h1>
                <p>Completa tus datos para unirte a PoliWiki</p>
                <form action="Controlador/crearCuenta.jsp" method="post">
                    <div>
                        <label for="nombre">Nombre(s): </label>
                        <br>
                        <input name="nombre" id="nombre" type="text" placeholder="Tu nombre(s)">
                    </div>
                    <div>
                        <label for="apellidoPaterno">Apellido materno:</label>
                        <input name="apellidoPaterno" id="apellidoPaterno" type="text" placeholder="Tu apellido paterno">
                    </div>
                    <div>
                        <label for="apellidoMaterno">
                            Apellido materno:
                        </label>
                        <input name="apellidoMaterno" id="apellidoMaterno" type="text" placeholder="Tu apellido materno">
                    </div>
                    <div>
                        <label for="email">Correo institucional: </label>
                        <input type="email" name="correo" id="email" placeholder="ejemplo@alumno.ipn.mx">
                    </div>
                    <div>
                        <label for="boleta">Número de boleta: </label>
                        <input name="boleta" type="text" id="boleta" placeholder="Boleta">
                    </div>
                    <div>
                        <label for="carrera">Carrera</label>
                        <select name="carrera" id="carrera">
                            <option disabled selected>Selecciona tu carrera</option>
                        </select>
                    </div>
                    <div>
                        <label for="contrasena">Contraseña: </label>
                        <input type="password" name="contrasena" id="contra">
                    </div>
                    <div>
                        <label for="confirmacontrasena">Confirmar contraseña: </label>
                        <input type="password" name="confirmarcontrasena" id="confirmacontra">
                    </div>
                    <br>
                    
                    <input type="submit" value="Crear cuenta" id="submit">
                </form>
            </div>
        </div>
        <%@include file="/Plantillas/footer.jsp" %>
    </body>
</html>
