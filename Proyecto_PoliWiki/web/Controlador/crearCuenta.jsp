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
            String nombre = request.getParameter("nombre");
            String apellidoPaterno = request.getParameter("apellidoPaterno");
            String apellidoMaterno = request.getParameter("apellidoMaterno");
            String correo = request.getParameter("correo");
            String boleta = request.getParameter("boleta");
            String carrera = request.getParameter("carrera");
            String contrasena = request.getParameter("contrasena");
            ConexionBaseDeDatos conexion = new ConexionBaseDeDatos();
            String query = String.format("insert into "
                    + "usuario(boleta, correoInstitucional, password, nombre, apellidoPaterno, "
                    + "apellidoMaterno, idEstado)"
                    + " values('%s','%s','%s','%s','%s','%s','%s')"
            ,boleta, correo,contrasena, nombre, apellidoPaterno, apellidoMaterno, "3");
            int resultado = conexion.normalStatement.executeUpdate(query);
            if(resultado > 0){
                session.setAttribute("nombre", nombre);
                session.setAttribute("apellidoPaterno", apellidoPaterno);
                session.setAttribute("apellidoMaterno", apellidoMaterno);
                session.setAttribute("correo", correo);
                response.sendRedirect("../index.jsp");
            }
        %>
    </body>
</html>
