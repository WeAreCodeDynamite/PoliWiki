<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
        <link href="CSS/estiloBase.css" rel="stylesheet" />
        <link href="CSS/reglamento.css" rel="stylesheet" />
    </head>
    <body>
        <%@include file="/Plantillas/header.jsp" %>
        <%@include file="/Plantillas/navBar.jsp" %>
        <div class="reglas">
            <h2>1. Normas de participación</h2>
            <p>
                1. Todos los usuarios deberán mantener una actitud respetuosa hacia los demás miembros.<br>
                2. La información publicada debe estar relacionada con temas académicos o actividades escolares.<br>
                3. Se prohíbe el uso de lenguaje ofensivo, discriminatorio o que promueva la violencia.<br>
                4. Los usuarios deben verificar que la información compartida sea correcta y confiable.<br>
            </p>
            <h2>
                2. Publicación y edición de contenido
            </h2>
            <p>
                1. Las contribuciones deberán redactarse con claridad, buena ortografía y lenguaje apropiado.<br>
                2. Está permitido editar artículos existentes para corregir errores o mejorar la calidad de la información.<br>
                3. No se deben eliminar contenidos útiles sin una justificación válida.<br>
                4. Toda información tomada de otras fuentes deberá incluir la referencia correspondiente para respetar los derechos de autor.<br>
            </p>
            <h2>
                3. Uso responsable
            </h2>
            <p>
                1. Queda prohibido publicar información personal propia o de terceros sin autorización.<br>
                2. No se permite el uso de la wiki para publicidad, propaganda o fines comerciales.<br>
                3. Los usuarios son responsables del contenido que publiquen o modifiquen.<br>
            </p>
            <h2>
                4. Medidas disciplinarias
            </h2>
            <p>
                1. El incumplimiento de este reglamento podrá ocasionar la edición o eliminación del contenido inapropiado.<br>
                2. En casos de faltas reiteradas, se podrá suspender temporalmente el acceso del usuario a la wiki.<br>
                3. Las faltas graves podrán ser reportadas.<br>
            </p>
        </div>
        <%@include file="/Plantillas/footer.jsp" %>
    </body>
</html>
