<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="poliwiki.dao.CatalogoDao"%>
<%
    CatalogoDao catalogoDao = new CatalogoDao();
    List<Map<String, Object>> carreras = null;
    String errorCarga = null;
    try {
        carreras = catalogoDao.listarCarreras();
    } catch (Exception ex) {
        errorCarga = "No se pudieron cargar las carreras. Revisa la conexión a MySQL.";
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Crear cuenta - PoliWiki</title>
        <link href="CSS/estiloBase.css" rel="stylesheet" />
        <link rel="stylesheet" href="CSS/crearCuenta.css"/>
    </head>
    <body>
        <%@include file="/Plantillas/header.jsp" %>
        <%@include file="/Plantillas/navBar.jsp" %>

        <% if (request.getParameter("error") != null) { %>
            <div class="error"><%= request.getParameter("error") %></div>
        <% } %>
        <% if (errorCarga != null) { %>
            <div class="error"><%= errorCarga %></div>
        <% } %>

        <div class="contenido">
            <div class="formulario">
                <img src="Imgs/logo_PoliWiki.jpeg">
                <h1>Crear cuenta</h1>
                <p>Completa tus datos para unirte a PoliWiki</p>
                <form action="registro" method="post">
                    <div>
                        <label for="nombre">Nombre(s): </label>
                        <br>
                        <input id="nombre" name="nombres" type="text" placeholder="Tu nombre(s)" required>
                    </div>
                    <div>
                        <label for="apellidoPaterno">Apellido Paterno:</label>
                        <input id="apellidoPaterno" name="apellidoPaterno" type="text" placeholder="Tu apellido paterno" required>
                    </div>
                    <br>
                    <div>
                        <label for="apellidoMaterno">Apellido Materno:</label>
                        <input id="apellidoMaterno" name="apellidoMaterno" type="text" placeholder="Tu apellido materno">
                    </div>
                    <br>
                    <div>
                        <label for="email">Correo institucional: </label>
                        <input type="email" name="correo" id="email" placeholder="ejemplo@alumno.ipn.mx" required>
                    </div>
                    <div>
                        <label for="boleta">Número de boleta: </label>
                        <input type="text" name="boleta" id="boleta" placeholder="Boleta" required>
                    </div>
                    <div>
                        <label for="carrera">Carrera</label>
                        <select id="carrera" name="idCarrera" required>
                            <option disabled selected value="">Selecciona tu carrera</option>
                            <% if (carreras != null) {
                                for (Map<String, Object> carrera : carreras) { %>
                                    <option value="<%= carrera.get("id_carrera") %>"><%= carrera.get("nombre") %></option>
                            <%  }
                            } %>
                        </select>
                    </div>
                    <br>
                    <label for="contra">Contraseña: </label>
                    <input type="password" name="password" id="contra" required>
                    <br>
                    <label for="confirmacontra">Confirmar contraseña: </label>
                    <input type="password" name="confirmarPassword" id="confirmacontra" required>

                    <input type="submit" value="Crear cuenta" id="submit">
                </form>
            </div>
        </div>
        <%@include file="/Plantillas/footer.jsp" %>
    </body>
</html>
