package poliwiki.servlet;

import java.io.IOException;
import java.util.LinkedHashSet;
import java.util.Set;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import poliwiki.dao.CatalogoDao;

@WebServlet(name = "ActualizarProfesorServlet", urlPatterns = {"/ActualizarProfesorServlet"})
public class ActualizarProfesorServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        
        // SEGURIDAD: Verificar sesión activa
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) { 
            response.sendRedirect("profesores.jsp?error=Debes%20iniciar%20sesion");
            return; 
        }
        
        // 1. Recuperar los parámetros de texto de forma segura
        String idProfesorStr = request.getParameter("idProfesor"); 
        String nombreInput = request.getParameter("nombreCompleto") != null ? request.getParameter("nombreCompleto").trim() : "";
        String materiaEscrita = request.getParameter("materiaEscrita"); 
        String correo = request.getParameter("correo") != null ? request.getParameter("correo").trim() : "";
        String areaAcademica = request.getParameter("areaAcademica");
        String escuelaStr = request.getParameter("escuela"); 

        // SOLUCIÓN AL APELLIDO DUPLICADO: Separar inteligentemente el nombre de los apellidos
        String nombres = nombreInput;
        String apellidoPaterno = "";
        String apellidoMaterno = "";

        if (!nombreInput.isEmpty()) {
            String[] partesNombre = nombreInput.split("\\s+"); // Dividir por cualquier cantidad de espacios
            if (partesNombre.length == 2) {
                nombres = partesNombre[0];
                apellidoPaterno = partesNombre[1];
            } else if (partesNombre.length == 3) {
                nombres = partesNombre[0];
                apellidoPaterno = partesNombre[1];
                apellidoMaterno = partesNombre[2];
            } else if (partesNombre.length >= 4) {
                // Caso común: Dos nombres (Juan Carlos) y dos apellidos (Pérez Gómez)
                nombres = partesNombre[0] + " " + partesNombre[1];
                apellidoPaterno = partesNombre[2];
                StringBuilder am = new StringBuilder();
                for (int i = 3; i < partesNombre.length; i++) {
                    am.append(partesNombre[i]).append(" ");
                }
                apellidoMaterno = am.toString().trim();
            }
        }

        // SOLUCIÓN A LA COMA POR DEFAULT / ESPACIOS VACÍOS
        Set<String> conjuntoMaterias = new LinkedHashSet<>();
        if (materiaEscrita != null && !materiaEscrita.trim().isEmpty()) {
            String[] tokens = materiaEscrita.split(",");
            for (String token : tokens) {
                if (token != null) {
                    String matLimpia = token.trim().replaceAll("\\s+", " "); // Limpia espacios extraños
                    // Evita agregar textos vacíos, comas sueltas o la palabra "General" por error
                    if (!matLimpia.isEmpty() && !matLimpia.equalsIgnoreCase("General")) { 
                        conjuntoMaterias.add(matLimpia);
                    }
                }
            }
        }
        String materiaFinal = conjuntoMaterias.isEmpty() ? "General" : String.join(", ", conjuntoMaterias);

        try {
            // Validaciones anti-nulos / Parseo Seguro
            int idProfesor = 0;
            if (idProfesorStr != null && !idProfesorStr.trim().isEmpty()) {
                idProfesor = Integer.parseInt(idProfesorStr.trim());
            } else {
                throw new IllegalArgumentException("El ID del profesor no fue recibido en la petición.");
            }

            int idEscuela = 0;
            if (escuelaStr != null && !escuelaStr.trim().isEmpty()) {
                idEscuela = Integer.parseInt(escuelaStr.trim());
            }

            CatalogoDao catalogoDao = new CatalogoDao();
            
            // 2. Modificar el método del DAO para enviar por separado los apellidos
            // NOTA: Asegúrate de ajustar las variables en tu método 'actualizarProfesor' del DAO
            boolean exito = catalogoDao.actualizarProfesor(idProfesor, nombres, apellidoPaterno, apellidoMaterno, correo, materiaFinal, areaAcademica, idEscuela);
            
            if (exito) {
                response.sendRedirect("profesores.jsp?mensaje=Profesor%20actualizado%20con%20exito");
            } else {
                response.sendRedirect("profesores.jsp?error=No%20se%20pudo%20actualizar");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("profesores.jsp?error=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
        }
    }
}