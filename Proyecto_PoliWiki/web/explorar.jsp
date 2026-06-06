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
        <section class="explorarOpciones">
            <h2>Explorar lo Mejor de PoliWiki</h2>
            <div>
                <ul class="listaMejor">
                    <li>Todo</li>
                    <li>Foros de Dudas</li>
                    <li>Eventos</li>
                </ul>
            </div>

            <h3>Apuntes Destacados</h3>
            <div class="apuntePDF">
                <div class="pdf-titulo">
                    <h2>
                        Cálculo Diferencial - Notas Completas
                    </h2>
                    <a href="PDFs/Calculo diferencial parcial 2.pdf" download>
                        Descargar PDF
                    </a>
                </div>

                <iframe src="PDFs/Calculo diferencial parcial 2.pdf" class="pdf-frame">
                </iframe>
            </div>

            <div class="apuntePDF">
                <div class="pdf-titulo">
                    <h2>
                        QUIMICA
                    </h2>
                    <a href="/PDFs/Quimica 2.pdf" download>
                        Descargar PDF
                    </a>
                </div>

                <iframe src="PDFs/Quimica 2.pdf" class="pdf-frame">
                </iframe>

            </div>
        </section>
        <%@include file="/Plantillas/footer.jsp" %>
    </body>
</html>
