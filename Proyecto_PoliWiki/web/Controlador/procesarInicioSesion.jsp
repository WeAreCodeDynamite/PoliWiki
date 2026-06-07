<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <body>
        <%@page import="baseDeDatos.ConexionBaseDeDatos" %>
        <%@page import="java.sql.*" %>
        <%
            String correo = request.getParameter("correo");
            ConexionBaseDeDatos conexion = new ConexionBaseDeDatos();
            ResultSet datos = conexion.ejecutarStatement("select * from usuario where correoInstitucional ="
            + "'" + correo + "'"
            );
            if(datos == null){
                out.println("<script>alert('Error en tus datos');</script>");
                out.println("<h1>Redirigiendo...</h1>");
                try{Thread.sleep(5000);}catch(Exception e){}
                response.sendRedirect("../index.jsp");
            }else{
                session.setAttribute("idUsuario", datos.getString("idUsuario"));
                session.setAttribute("nombre", datos.getString("nombre"));
                session.setAttribute("apellidoPaterno", datos.getString("apellidoPaterno"));
                session.setAttribute("apellidoMaterno", datos.getString("apellidoMaterno"));
                session.setAttribute("correo", datos.getString("correoInstitucional"));
            }
        %>
    </body>
</html>
