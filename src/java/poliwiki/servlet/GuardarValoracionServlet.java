package poliwiki.servlet;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import poliwiki.dao.CatalogoDao;

@WebServlet("/GuardarValoracionServlet")
public class GuardarValoracionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/profesores.jsp");
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        
        int idProfesor = 0;
        
        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("usuario") == null) {
                response.sendRedirect(request.getContextPath() + "/iniciarSesion.jsp?error=SesionExpirada");
                return;
            }
            
            
            poliwiki.model.Usuario uLogueado = (poliwiki.model.Usuario) session.getAttribute("usuario");
            
            
            int idUsuarioLogueado = 1; 
            if (uLogueado != null) {
                idUsuarioLogueado = uLogueado.getId(); // <-- Ajusta al método de tu modelo si es necesario
            }

            String idParam = request.getParameter("idProfesor");
            String estrellasParam = request.getParameter("estrellas");

            if (idParam == null || idParam.trim().isEmpty() || estrellasParam == null || estrellasParam.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/profesores.jsp?error=ParametrosIncompletos");
                return;
            }

            idProfesor = Integer.parseInt(idParam.trim());
            int calificacion = Integer.parseInt(estrellasParam.trim()); 

            
            CatalogoDao dao = new CatalogoDao();
            
            if (dao.yaVotoUsuario(idProfesor, idUsuarioLogueado)) {
                response.sendRedirect(request.getContextPath() + "/perfilProfesor.jsp?id=" + idProfesor + "&error=YaValorado");
                return; // Corta la ejecución
            }
            

            List<String[]> listaAspectos = new ArrayList<>();

            // 1. Procesar "Forma de Enseñar"
            procesarTags(request.getParameterValues("tags_forma_ensenar_pos"), "positivo", "Forma de Enseñar", listaAspectos);
            procesarTags(request.getParameterValues("tags_forma_ensenar_neg"), "mejorar", "Forma de Enseñar", listaAspectos);

            // 2. Procesar "Trato con los Estudiantes"
            procesarTags(request.getParameterValues("tags_trato_pos"), "positivo", "Trato con los estudiantes", listaAspectos);
            procesarTags(request.getParameterValues("tags_trato_neg"), "mejorar", "Trato con los estudiantes", listaAspectos);

            // 3. Procesar "Evaluaciones y Tareas"
            procesarTags(request.getParameterValues("tags_evaluaciones_pos"), "positivo", "Evaluaciones y tareas", listaAspectos);
            procesarTags(request.getParameterValues("tags_evaluaciones_neg"), "mejorar", "Evaluaciones y tareas", listaAspectos);

            // 4. Procesar "Organización"
            procesarTags(request.getParameterValues("tags_organizacion_pos"), "positivo", "Organización", listaAspectos);
            procesarTags(request.getParameterValues("tags_organizacion_neg"), "mejorar", "Organización", listaAspectos);

            if (listaAspectos.isEmpty()) {
                listaAspectos.add(new String[]{"Sin comentarios", "neutro", "General"});
            }

            // Enviar los datos estructurados al método de inserción batch
            boolean exito = dao.guardarValoracion(idProfesor, idUsuarioLogueado, calificacion, listaAspectos);
            
            if (exito) {
                response.sendRedirect(request.getContextPath() + "/perfilProfesor.jsp?id=" + idProfesor + "&mensaje=ValoracionGuardada");
            } else {
                response.sendRedirect(request.getContextPath() + "/perfilProfesor.jsp?id=" + idProfesor + "&error=NoSeGuardo");
            }
            
        } catch (NumberFormatException nfe) {
            nfe.printStackTrace();
            if (idProfesor != 0) {
                response.sendRedirect(request.getContextPath() + "/perfilProfesor.jsp?id=" + idProfesor + "&error=FormatoNumeroInvalido");
            } else {
                response.sendRedirect(request.getContextPath() + "/profesores.jsp?error=IdProfesorInvalido");
            }
        } catch (Exception e) {
            e.printStackTrace();
            if (idProfesor != 0) {
                response.sendRedirect(request.getContextPath() + "/perfilProfesor.jsp?id=" + idProfesor + "&error=Exception");
            } else {
                response.sendRedirect(request.getContextPath() + "/profesores.jsp?error=ExceptionGeneral");
            }
        }
    }

    private void procesarTags(String[] tagsSeleccionados, String tipo, String categoria, List<String[]> listaAcumulada) {
        if (tagsSeleccionados != null) {
            for (String aspecto : tagsSeleccionados) {
                if (aspecto != null && !aspecto.trim().isEmpty()) {
                    listaAcumulada.add(new String[]{aspecto.trim(), tipo, categoria});
                }
            }
        }
    }
}