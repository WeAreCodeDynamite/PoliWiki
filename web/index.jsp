<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>PoliWIki - Bienvenido</title>
        <link href="${pageContext.request.contextPath}/CSS/estiloBase.css" rel="stylesheet" />
    </head>
    <body>
        <%@include file="/Plantillas/header.jsp" %>
        <%@include file="/Plantillas/navBar.jsp" %>
        
        <section class="contenidoPrincipal">

    <div class="contenido">
        <h2>
            Bienvenidos a
            <span class="logoTexto">PoliWiki</span>
        </h2>

        <p class="subtitulo">
            "Conectando estudiantes, compartiendo conocimiento."
        </p>

        <p>
            PoliWiki es la comunidad donde estudiantes del IPN se apoyan,
            comparten recursos y crecen juntos.
        </p>

        <div class="botones">

            <button class="explorar"
                    onclick="window.location.href='informacion.jsp'">
                Explorar contenido
            </button>

            <button class="conocer"
                    onclick="window.location.href='conocer.jsp'">
                Conoce más
            </button>

        </div>
    </div>

    <div class="imagen">
        <img src="Imgs/portada.png" alt="Portada PoliWiki">
    </div>

</section>


<!-- SECCION DE TARJETAS -->

<section class="funciones">

    <h2>
        ¿Qué puedes hacer en
        <span>PoliWiki</span>?
    </h2>

    <div class="cards">

        <div class="card">
            <img src="Imgs/LogoMaterias.jpg" alt="">
            <div>
                <h3>Consultar apuntes</h3>
                <p>Encuentra y comparte apuntes de tus materias.</p>
            </div>
        </div>

        <div class="card">
            <img src="Imgs/LogoProfes.jpg" alt="">
            <div>
                <h3>Ver profesores</h3>
                <p>Consulta información y experiencias sobre profesores.</p>
            </div>
        </div>

        <div class="card">
            <img src="Imgs/LogoMarketplace.jpg" alt="">
            <div>
                <h3>Marketplace</h3>
                <p>Compra, vende o intercambia materiales y más.</p>
            </div>
        </div>

        <div class="card">
            <img src="Imgs/LogoForos.jpg" alt="">
            <div>
                <h3>Foros estudiantiles</h3>
                <p>Participa en discusiones y resuelve tus dudas.</p>
            </div>
        </div>

        <div class="card">
            <img src="Imgs/LogoEventos.jpg" alt="">
            <div>
                <h3>Eventos académicos</h3>
                <p>Entérate de talleres, cursos y eventos del IPN.</p>
            </div>
        </div>

    </div>

</section>
        <!--<!-- Aqui termina el contenido principal -->
        <%@include file="/Plantillas/footer.jsp" %>
    </body>
</html>
