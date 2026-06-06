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
        <section>
            <h1>Profesores</h1>
            <p>Conoce a los profesores de tu institución, materias y forma ed contacto.</p>
            <h3>Profesores destacados</h3>
            <div class="profesor">
                <h4>Armando Suarez</h4>
                <h5>Ingles y biologia</h5>
                <p>Centro de estudios cientificos y tecnológicos 9</p>
                <h6>Materias que imparte</h6>
                <ul>
                    <li>Biologia básica</li>
                    <li>Ingles</li>
                </ul>
            </div>

            <div class="profesor">
                <h4>Sonia Barrios</h4>
                <h5>Biologia y comunicación cientifica</h5>
                <p>Centro de estudios cientificos y tecnológicos 9</p>
                <h6>Materias que imparte</h6>
                <ul>
                    <li>Biologia básica</li>
                    <li>Comunicación cientifica</li>
                </ul>
            </div>
        </section>
        <%@include file="/Plantillas/footer.jsp" %>
    </body>
</html>
