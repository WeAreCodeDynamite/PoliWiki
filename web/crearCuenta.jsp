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
        <link href="${pageContext.request.contextPath}/CSS/estiloBase.css" rel="stylesheet" type="text/css" />
        <link href="${pageContext.request.contextPath}/CSS/crearCuenta.css" rel="stylesheet" type="text/css" />
    </head>
    <body>
        <%@include file="/Plantillas/header.jsp" %>
        <%@include file="/Plantillas/navBar.jsp" %>

        <% if (request.getParameter("error") != null) {%>
        <div class="error"><%= request.getParameter("error")%></div>
        <% } %>
        <% if (errorCarga != null) {%>
        <div class="error"><%= errorCarga%></div>
        <% } %>

        <div class="registro-container">
           <div class="formulario">
                <img src="Imgs/logo_PoliWiki.jpeg" alt="PoliWiki Logo">
                <h1>Crear cuenta</h1>
                <p class="subtitulo">Completa tus datos para unirte a PoliWiki</p>
                
                <form action="registro" method="post">
                    <div class="grid-container">
                        <div class="input-group">
                            <label for="nombre">Nombre completo</label>
                            <input id="nombre" name="nombres" type="text" placeholder="Tu nombre completo" required>
                        </div>
                        
                        <div class="input-group">
                            <label for="apellidos">Apellido(s)</label>
                            <input id="apellidos" name="apellidos" type="text" placeholder="Tus apellidos" required>
                        </div>

                        <div class="input-group full-width">
                            <label for="email">Correo institucional del IPN</label>
                            <input type="email" name="correo" id="email" placeholder="ejemplo@alumno.ipn.mx" required>
                        </div>

                        <div class="input-group">
                            <label for="boleta">Número de boleta</label>
                            <input type="text" name="boleta" id="boleta" placeholder="Tu número de boleta" required>
                        </div>
                        
                        <div class="input-group">
                            <label for="carrera">Carrera</label>
                            <select id="carrera" name="idCarrera" class="select-field" required>
                                <option disabled selected value="">Selecciona tu carrera</option>
                                <% if (carreras != null) {
                                    for (Map<String, Object> carrera : carreras) {%>
                                <option value="<%= carrera.get("id_carrera")%>"><%= carrera.get("nombre")%></option>
                                <%  }
                                    }%>
                            </select>
                        </div>

                        <div class="input-group">
                            <label for="contra">Contraseña</label>
                            <input type="password" name="password" id="contra" placeholder="Crea una contraseña segura" required>
                            <small class="helper-text">Mínimo 8 caracteres, con mayúsculas, números y símbolos.</small>
                        </div>
                        
                        <div class="input-group">
                            <label for="confirmacontra">Confirmar contraseña</label>
                            <input type="password" name="confirmarPassword" id="confirmacontra" placeholder="Confirma tu contraseña" required>
                        </div>
                    </div>

                    <div class="terminos-container">
                        <input type="checkbox" id="terminos" name="terminos" required>
                        <label for="terminos">Acepto los <a href="#">Términos de servicio</a> y la <a href="#">Política de privacidad</a>.</label>
                    </div>

                    <input type="submit" value="Crear cuenta" id="submit">
                </form>
            </div>
        </div>
        <%@include file="/Plantillas/footer.jsp" %>
    </body>
</html>