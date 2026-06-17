package poliwiki.servlet;

import java.io.File;
import java.io.IOException;
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

// 1. Cambiamos la ruta de acceso exclusiva para el Marketplace
@WebServlet("/GuardarMarketplaceServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 10,       // 10MB
    maxRequestSize = 1024 * 1024 * 50     // 50MB
)
public class GuardarMarketplaceServlet extends HttpServlet {

    private static final String UPLOAD_DIR = "Archivos";
    private static final List<String> EXTENSIONES_IMAGENES = Arrays.asList("png", "jpg", "jpeg");

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        
        // ==================== CONTROL DE SESIÓN ESTRICTO ====================
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect("iniciarSesion.jsp"); // <--- Tu archivo real de login
            return;
        }
        
        Usuario usuarioLogueado = (Usuario) session.getAttribute("usuario");
        int idUsuario = usuarioLogueado.getId();

        // 1. Obtener parámetros desde el formulario del Modal
        String titulo = request.getParameter("titulo");
        String precioStr = request.getParameter("precio");
        String tema = request.getParameter("tema"); 
        String escuelaSeleccionada = request.getParameter("escuela");
        String contenidoGeneral = request.getParameter("descripcion"); // El textarea del modal
        
        if (escuelaSeleccionada == null || escuelaSeleccionada.isEmpty()) {
            escuelaSeleccionada = "General";
        }
        
        double precio = (precioStr != null && !precioStr.isEmpty()) ? Double.parseDouble(precioStr) : 0.0;

        // Directorio de subida absoluto para la imagen
        String applicationPath = request.getServletContext().getRealPath("");
        String uploadFilePath = applicationPath + File.separator + UPLOAD_DIR;
        File uploadFolder = new File(uploadFilePath);
        if (!uploadFolder.exists()) {
            uploadFolder.mkdirs();
        }

        String archivoUrl = null;
        InformacionDao infoDao = new InformacionDao();
        MarketplaceDao marketDao = new MarketplaceDao();

        try {
            // Procesar la imagen del producto
            Part partFoto = request.getPart("foto");
            if (partFoto != null && partFoto.getSize() > 0) {
                String originalName = obtenerNombreArchivo(partFoto);
                String extension = obtenerExtension(originalName);
                
                // Validar extensión de imagen
                if (!EXTENSIONES_IMAGENES.contains(extension.toLowerCase())) {
                    response.getWriter().println("Error: Tipo de archivo no permitido para imagenes.");
                    return;
                }
                
                String fileName = "prod_" + System.currentTimeMillis() + "." + extension;
                partFoto.write(uploadFilePath + File.separator + fileName);
                archivoUrl = UPLOAD_DIR + "/" + fileName;
            }
            
            String fotoFinal = (archivoUrl != null) ? archivoUrl : "IMG/default-item.png";
            String descripcionConTema = "[" + tema + "] " + contenidoGeneral;
            
            // 1. Guardar en la tabla de Marketplace
            marketDao.crearItem(idUsuario, titulo, descripcionConTema, precio, fotoFinal, escuelaSeleccionada);
            
            // 2. Registrar el testigo en el muro general de informacion.jsp (id_categoria 1 por defecto)
            String textoConPrecio = "[Precio: $" + precio + "] " + descripcionConTema;
            infoDao.insertarPublicacion(1, idUsuario, titulo, textoConPrecio, "Marketplace", archivoUrl, tema);
            
            // Redireccionar al marketplace con éxito
            response.sendRedirect("marketplace.jsp?mensaje=Publicacion+creada+con+exito");

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error al procesar la publicacion: " + e.getMessage());
        }
    }

    private String obtenerNombreArchivo(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] tokens = contentDisp.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                String name = token.substring(token.indexOf("=") + 2, token.length() - 1);
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