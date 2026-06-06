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
        <section class="foros">
                <h2>Foros</h2>
                <p>Participa en discusiones, resuelve dudas y comparte
                    conocimiento con la comunidad.
                </p>
                <div>
                    <ul>
                        <li>Todos los foros</li>
                        <li>Preguntas</li>
                        <li>Discusiones</li>
                        <li>Avisos</li>
                    </ul>
                </div>
                <p>Publicaciones recientes</p>
                <div class="publicacion">
                    <p class="titulo">¿Alguien entendio cálculo?</p>
                    <p class="autor">Mariana Tejados</p>
                    <p>Tengo duda con el ejemplo 3, en aplicar
                        la regla de la cadena
                    </p>
                    <p class="informacion">12:33      12 respuestas</p>
                </div>
                <div class="publicacion">
                    <p class="titulo">Inscripcion a ETS</p>
                    <p class="autor">Administrador</p>
                    <p>
                        Las inscripciones inicia este viernes.
                    </p>
                    <p class="informacion">12:33      12 respuestas</p>
                </div>
            </section>
        <%@include file="/Plantillas/footer.jsp" %>
    </body>
</html>
