<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>PoliWIki - Bienvenido</title>
        <link href="CSS/estiloBase.css" rel="stylesheet" />
    </head>
    <body>
        <%@include file="/Plantillas/header.jsp" %>
        <%@include file="/Plantillas/navBar.jsp" %>
        <!-- Aqui va el contenido principal -->
        <section class="contenidoPrincipal">
                <link href="CSS/portada.css" rel="stylesheet">
                <div class="contenido">
                    <h2>
                        Bienvenidos a
                        <span>PoliWiki</span>
                    </h2>

                    <p class="subtitulo">
                        "Conectando estudiantes, compartiendo conocimiento."
                    </p>

                    <p>
                        PoliWiki es la comunidad donde estudiantes del IPN se apoyan,
                        comparten recursos y crecen juntos.
                    </p>

                    <div class="botones">

                        <button class="explorar">
                            Explorar contenido
                        </button>

                        <button class="conocer">
                            Conoce más
                        </button>
                    </div>
                </div>
                <div class="imagen">
                    <img src="Imgs/portada.png"">

                </div>
            </section>
        <!--<!-- Aqui termina el contenido principal -->
        <%@include file="/Plantillas/footer.jsp" %>
    </body>
</html>
