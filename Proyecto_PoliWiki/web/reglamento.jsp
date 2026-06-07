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
        <main class="container">

            <section class="header-reglamento">
                <h1>Reglamento General</h1>
                <p>Última actualización: 07/06/2026</p>
            </section>

            <section class="indice">
                <h2>Índice</h2>
                <ul>
                    <li><a href="#normas">Normas generales</a></li>
                    <li><a href="#material">Publicación de material</a></li>
                    <li><a href="#foros">Conducta en foros</a></li>
                    <li><a href="#marketplace">Uso del marketplace</a></li>
                    <li><a href="#eventos">Eventos</a></li>
                    <li><a href="#sanciones">Sanciones</a></li>
                </ul>
            </section>

            <section id="normas">
                <h2>Normas Generales</h2>
                <p>Contenido del reglamento...</p>
            </section>

            <section id="material">
                <h2>Publicación de Material</h2>
                <p>Contenido del reglamento...</p>
            </section>

            <section id="foros">
                <h2>Conducta en Foros</h2>
                <p>Contenido del reglamento...</p>
            </section>

            <section id="marketplace">
                <h2>Uso del Marketplace</h2>
                <p>Contenido del reglamento...</p>
            </section>

            <section id="eventos">
                <h2>Eventos</h2>
                <p>Contenido del reglamento...</p>
            </section>

            <section id="sanciones">
                <h2>Sanciones</h2>
                <p>Contenido del reglamento...</p>
            </section>

            <div class="aceptacion">
                <input type="checkbox" id="acepto">
                <label for="acepto">He leído y acepto el reglamento</label>
                <br><br>
                <button>Aceptar</button>
            </div>

        </main>
        <%@include file="/Plantillas/footer.jsp" %>
    </body>
</html>
