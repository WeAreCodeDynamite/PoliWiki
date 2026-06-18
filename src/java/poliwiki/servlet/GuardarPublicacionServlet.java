package poliwiki.servlet;

import java.io.File;
import java.io.IOException;
import java.net.URLEncoder;
import java.util.Arrays;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

import poliwiki.dao.InformacionDao;
import poliwiki.dao.MarketplaceDao;
import poliwiki.model.Usuario;

@WebServlet("/GuardarPublicacionServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 10,       // 10MB
    maxRequestSize = 1024 * 1024 * 50     // 50MB
)
public class GuardarPublicacionServlet extends HttpServlet {

    private static final String UPLOAD_DIR = "Archivos";
    
    private static final List<String> EXTENSIONES_DOCUMENTOS = Arrays.asList("pdf", "docx", "doc", "txt");
    private static final List<String> EXTENSIONES_IMAGENES = Arrays.asList("png", "jpg", "jpeg");

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        Usuario usuarioLogueado = (Usuario) session.getAttribute("usuario");
        int idUsuario = usuarioLogueado.getId();

        String idPublicacionStr = request.getParameter("id_publicacion"); // Captura el ID dinámico enviado por JS
        String tipoPublicacion = request.getParameter("tipo_publicacion"); 
        String titulo = request.getParameter("titulo");
        String idCategoriaStr = request.getParameter("id_categoria"); 
        String temas = request.getParameter("temas"); 
        String contenidoGeneral = request.getParameter("contenido_general");
        
        String redirectToParam = request.getParameter("redirect_to");
        
        int idCategoria = (idCategoriaStr != null && !idCategoriaStr.isEmpty()) ? Integer.parseInt(idCategoriaStr) : 1;

        String applicationPath = request.getServletContext().getRealPath("");
        String uploadFilePath = applicationPath + File.separator + UPLOAD_DIR;
        File uploadFolder = new File(uploadFilePath);
        if (!uploadFolder.exists()) {
            uploadFolder.mkdirs();
        }

        String archivoUrl = null;
        InformacionDao infoDao = new InformacionDao();
        MarketplaceDao marketDao = new MarketplaceDao();

        String redireccionBase = "informacion.jsp";
        String mensajeStatus = "Publicacion realizada con exito";

        try {
            boolean esEdicion = (idPublicacionStr != null && !idPublicacionStr.trim().isEmpty());
            if (esEdicion) {
                mensajeStatus = "Publicacion editada con exito";
            } else {
                mensajeStatus = "Publicacion creada con exito";
            }

            if ("Material".equals(tipoPublicacion)) {
                Part part = request.getPart("archivo_adjunto");
                if (part != null && part.getSize() > 0) {
                    String originalName = obtenerNombreArchivo(part);
                    String extension = obtenerExtension(originalName);
                    
                    if (!EXTENSIONES_DOCUMENTOS.contains(extension.toLowerCase())) {
                        response.setContentType("text/html;charset=UTF-8");
                        response.getWriter().println("Error: Tipo de archivo no permitido para documentos.");
                        return;
                    }
                    
                    String fileName = "doc_" + System.currentTimeMillis() + "." + extension;
                    part.write(uploadFilePath + File.separator + fileName);
                    archivoUrl = UPLOAD_DIR + "/" + fileName;
                }
                
                if (esEdicion) {
                    int idPublicacion = Integer.parseInt(idPublicacionStr);
                    infoDao.actualizarPublicacion(idPublicacion, idCategoria, titulo, contenidoGeneral, archivoUrl, temas);
                } else {
                    infoDao.insertarPublicacion(idCategoria, idUsuario, titulo, contenidoGeneral, "Material", archivoUrl, temas);
                }
                redireccionBase = "material.jsp"; 

            } else if ("Apuntes".equals(tipoPublicacion)) {
                Part part = request.getPart("archivo_adjunto");
                if (part != null && part.getSize() > 0) {
                    String originalName = obtenerNombreArchivo(part);
                    String extension = obtenerExtension(originalName);
                    
                    if (!EXTENSIONES_DOCUMENTOS.contains(extension.toLowerCase())) {
                        response.setContentType("text/html;charset=UTF-8");
                        response.getWriter().println("Error: Tipo de archivo no permitido para documentos.");
                        return;
                    }
                    
                    String fileName = "doc_" + System.currentTimeMillis() + "." + extension;
                    part.write(uploadFilePath + File.separator + fileName);
                    archivoUrl = UPLOAD_DIR + "/" + fileName;
                }
                
                if (esEdicion) {
                    int idPublicacion = Integer.parseInt(idPublicacionStr);
                    infoDao.actualizarPublicacion(idPublicacion, idCategoria, titulo, contenidoGeneral, archivoUrl, temas);
                } else {
                    infoDao.insertarPublicacion(idCategoria, idUsuario, titulo, contenidoGeneral, "Apuntes", archivoUrl, temas);
                }
                redireccionBase = "apuntes.jsp"; 

            } else if ("Pregunta".equals(tipoPublicacion)) {
                String contenidoPregunta = request.getParameter("contenido_pregunta");
                if (contenidoPregunta != null && !contenidoPregunta.isEmpty()) {
                    contenidoGeneral = contenidoPregunta;
                }
                
                if (esEdicion) {
                    int idPublicacion = Integer.parseInt(idPublicacionStr);
                    infoDao.actualizarPublicacion(idPublicacion, idCategoria, titulo, contenidoGeneral, null, temas);
                } else {
                    infoDao.insertarPublicacion(idCategoria, idUsuario, titulo, contenidoGeneral, "Pregunta", null, temas);
                }
                redireccionBase = "foritos.jsp";

            } else if ("Marketplace".equals(tipoPublicacion)) {
                String precioStr = request.getParameter("precio");
                double precio = (precioStr != null && !precioStr.isEmpty()) ? Double.parseDouble(precioStr) : 0.0;
                
                if (contenidoGeneral == null || contenidoGeneral.trim().isEmpty()) {
                    contenidoGeneral = "Sin descripción adicional proporcionada.";
                }

                String escuela = marketDao.obtenerEscuelaPorUsuario(idUsuario);
                
                Part partFoto = request.getPart("foto_producto");
                if (partFoto != null && partFoto.getSize() > 0) {
                    String originalName = obtenerNombreArchivo(partFoto);
                    String extension = obtenerExtension(originalName);
                    
                    if (!EXTENSIONES_IMAGENES.contains(extension.toLowerCase())) {
                        response.setContentType("text/html;charset=UTF-8");
                        response.getWriter().println("Error: Tipo de archivo no permitido para imágenes del producto.");
                        return;
                    }
                    
                    String fileName = "prod_" + System.currentTimeMillis() + "." + extension;
                    partFoto.write(uploadFilePath + File.separator + fileName);
                    archivoUrl = UPLOAD_DIR + "/" + fileName;
                }
                
                String fotoFinal = (archivoUrl != null) ? archivoUrl : "IMG/default-item.png";
                
                marketDao.crearItem(idUsuario, titulo, contenidoGeneral, precio, fotoFinal, escuela);
                
                String textConPrecio = "[Precio: $" + precio + "] " + contenidoGeneral;
                infoDao.insertarPublicacion(idCategoria, idUsuario, titulo, textConPrecio, "Marketplace", archivoUrl, temas);
                redireccionBase = "informacion.jsp";
                mensajeStatus = "Producto publicado con exito";
            }

            if (redirectToParam != null && !redirectToParam.trim().isEmpty()) {
                redireccionBase = redirectToParam;
            }

            String mensajeCodificado = URLEncoder.encode(mensajeStatus, "UTF-8");
            response.sendRedirect(redireccionBase + "?exito=true&msg=" + mensajeCodificado);

        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/html;charset=UTF-8");
            response.getWriter().println("Error al procesar la publicación: " + e.getMessage());
        }
    }

   
    private String obtenerNombreArchivo(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] tokens = contentDisp.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                String name = token.substring(token.indexOf("=") + 1).trim().replace("\"", "");
                return new File(name).getName(); 
            }
        }
        return "archivo_anonimo";
    }

    
    private String obtenerExtension(String nombreArchivo) {
        if (nombreArchivo == null || !nombreArchivo.contains(".")) {
            return "";
        }
        return nombreArchivo.substring(nombreArchivo.lastIndexOf(".") + 1);
    }
}