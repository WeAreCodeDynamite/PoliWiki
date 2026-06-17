package poliwiki.servlet;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.LinkedHashSet;
import java.util.Set;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import poliwiki.dao.CatalogoDao;
import poliwiki.model.Usuario; 

@WebServlet(name = "GuardarProfesorServlet", urlPatterns = {"/GuardarProfesorServlet"})
@MultipartConfig 
public class GuardarProfesorServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        
        // SEGURIDAD: Verificar si el usuario tiene una sesión activa
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) { 
            String msgErrorSesion = "Debes iniciar sesión para agregar un profesor.";
            response.sendRedirect("profesores.jsp?error=" + java.net.URLEncoder.encode(msgErrorSesion, StandardCharsets.UTF_8.toString()));
            return; 
        }
        
        // --- CORREGIDO: Extraer el objeto Usuario usando .getId() ---
        Usuario usuarioLogueado = (Usuario) session.getAttribute("usuario");
        int idUsuarioCreador = 0;
        
        if (usuarioLogueado != null) {
            idUsuarioCreador = usuarioLogueado.getId(); // <-- Usando tu método exacto
        }
        
        // 1. Recuperar los datos del formulario
        String nombreCompleto = request.getParameter("nombreCompleto") != null ? request.getParameter("nombreCompleto").trim() : "";
        String materiaSeleccionada = request.getParameter("materia"); // El select desplegable
        String materiaEscrita = request.getParameter("materiaEscrita"); // El input de texto libre
        String idEscuelaStr = request.getParameter("escuela");
        String correo = request.getParameter("correo") != null ? request.getParameter("correo").trim() : "";
        String areaAcademica = request.getParameter("areaAcademica");

        // LÓGICA MULTI-MATERIA: LinkedHashSet evita materias duplicadas y mantiene el orden
        Set<String> conjuntoMaterias = new LinkedHashSet<>();

        // Agrega la materia seleccionada del dropdown si es válida
        if (materiaSeleccionada != null && !materiaSeleccionada.trim().isEmpty() 
                && !materiaSeleccionada.toLowerCase().contains("buscar o escribir")) {
            conjuntoMaterias.add(materiaSeleccionada.trim());
        }

        // Procesa y agrega las materias que el usuario escribió separadas por comas
        if (materiaEscrita != null && !materiaEscrita.trim().isEmpty()) {
            String[] tokens = materiaEscrita.split(",");
            for (String token : tokens) {
                String matLimpia = token.trim();
                if (!matLimpia.isEmpty()) {
                    conjuntoMaterias.add(matLimpia);
                }
            }
        }

        // Unifica los elementos usando solo ","
        String materiaFinal = String.join(",", conjuntoMaterias);

        // Si no se especificó ninguna materia, asignamos un valor por defecto seguro
        if (materiaFinal.isEmpty()) {
            materiaFinal = "General";
        }

        // 2. RECUPERAR Y GUARDAR EL ARCHIVO FÍSICAMENTE
        Part fotoPart = request.getPart("fotoPerfil");
        String nombreArchivo = null;
        
        if (fotoPart != null && fotoPart.getSize() > 0) {
            nombreArchivo = fotoPart.getSubmittedFileName();
            String uploadPath = "C:/poliwiki_uploads/profesores/";
            File uploadDir = new File(uploadPath);
            
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            
            fotoPart.write(uploadPath + File.separator + nombreArchivo);
        }

        // --- Algoritmo de fragmentación de nombre ---
        String nombres = "", apellidoPaterno = "", apellidoMaterno = "";
        String[] partesNombre = nombreCompleto.split("\\s+");
        
        if (partesNombre.length == 1 && !partesNombre[0].isEmpty()) {
            nombres = partesNombre[0];
            apellidoPaterno = "S/A";
        } else if (partesNombre.length == 2) {
            nombres = partesNombre[0];
            apellidoPaterno = partesNombre[1];
        } else if (partesNombre.length == 3) {
            nombres = partesNombre[0];
            apellidoPaterno = partesNombre[1];
            apellidoMaterno = partesNombre[2];
        } else if (partesNombre.length >= 4) {
            nombres = partesNombre[0] + " " + partesNombre[1];
            apellidoPaterno = partesNombre[2];
            apellidoMaterno = partesNombre[3];
        }

        // Conversión segura del ID de la escuela
        int idEscuela = (idEscuelaStr != null && !idEscuelaStr.isEmpty()) ? Integer.parseInt(idEscuelaStr) : 0;

        try {
            CatalogoDao catalogoDao = new CatalogoDao();
            
            // --- VALIDACIÓN DE DUPLICADOS ---
            boolean yaExiste = catalogoDao.existeProfesor(nombres, apellidoPaterno, apellidoMaterno);
            
            if (yaExiste) {
                String mensajeError = "El profesor '" + nombreCompleto + "' ya se encuentra registrado en el sistema.";
                response.sendRedirect("profesores.jsp?error=" + java.net.URLEncoder.encode(mensajeError, StandardCharsets.UTF_8.toString()));
                return; 
            }
            
            // Invoca al método pasándole la variable 'idUsuarioCreador' limpia
            boolean exito = catalogoDao.guardarProfesor(nombres, apellidoPaterno, apellidoMaterno, correo, idEscuela, materiaFinal, nombreArchivo, areaAcademica, idUsuarioCreador);
            
            if (exito) {
                String mensajeExito = "Profesor guardado con éxito.";
                response.sendRedirect("profesores.jsp?mensaje=" + java.net.URLEncoder.encode(mensajeExito, StandardCharsets.UTF_8.toString()));
            } else {
                String mensajeFallo = "No se pudo guardar el profesor en el catálogo.";
                response.sendRedirect("profesores.jsp?error=" + java.net.URLEncoder.encode(mensajeFallo, StandardCharsets.UTF_8.toString()));
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("profesores.jsp?error=" + java.net.URLEncoder.encode(e.getMessage(), StandardCharsets.UTF_8.toString()));
        }
    }
}