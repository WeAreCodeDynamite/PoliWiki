package poliwiki.servlet;

import java.io.File;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
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
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect("iniciarSesion.jsp");
            return;
        }
        
        Usuario usuarioLogueado = (Usuario) session.getAttribute("usuario");
        int idUsuario = usuarioLogueado.getId();

        String idProductoStr = request.getParameter("idProducto");
        String titulo = request.getParameter("titulo");
        String precioStr = request.getParameter("precio");
        String tema = request.getParameter("tema"); 
        String escuelaSeleccionada = request.getParameter("escuela");
        String contenidoGeneral = request.getParameter("descripcion"); 
        
        if (escuelaSeleccionada == null || escuelaSeleccionada.isEmpty()) {
            escuelaSeleccionada = "General";
        }
        
        double precio = (precioStr != null && !precioStr.isEmpty()) ? Double.parseDouble(precioStr) : 0.0;

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
            boolean esEdicion = (idProductoStr != null && !idProductoStr.trim().isEmpty());
            
            Part partFoto = request.getPart("foto");
            if (partFoto != null && partFoto.getSize() > 0) {
                String originalName = obtenerNombreArchivo(partFoto);
                String extension = obtenerExtension(originalName);
                
                if (!EXTENSIONES_IMAGENES.contains(extension.toLowerCase())) {
                    response.getWriter().println("Error: Tipo de archivo no permitido para imágenes.");
                    return;
                }
                
                String fileName = "prod_" + System.currentTimeMillis() + "." + extension;
                partFoto.write(uploadFilePath + File.separator + fileName);
                archivoUrl = UPLOAD_DIR + "/" + fileName;
            }
            
            String descripcionConTema = "[" + tema + "] " + contenidoGeneral;
            String textoConPrecio = "[Precio: $" + precio + "] " + descripcionConTema;
            
            if (esEdicion) {
                int idProducto = Integer.parseInt(idProductoStr);
                
                String fotoFinal = archivoUrl;
                if (fotoFinal == null) {
                    Map<String, Object> itemExistente = marketDao.obtenerItemPorId(idProducto); // Asegúrate de tener este método en tu DAO
                    if (itemExistente != null && itemExistente.get("foto_url") != null) {
                        fotoFinal = itemExistente.get("foto_url").toString();
                    } else {
                        fotoFinal = "IMG/default-item.png";
                    }
                }
                
                
                marketDao.actualizarItem(idProducto, titulo, descripcionConTema, precio, fotoFinal, escuelaSeleccionada);
                
                response.sendRedirect("marketplace.jsp?mensaje=Publicacion+actualizada+con+exito");
                
            } else {
                String fotoFinal = (archivoUrl != null) ? archivoUrl : "IMG/default-item.png";

                // FIX: antes se creaba el item en marketplace_items y la publicación en
                //      publicaciones_foro por separado, sin enlazarlos (id_publicacion quedaba NULL).
                //      Esto rompía la edición desde informacion.jsp, porque
                //      actualizarItemPorPublicacion busca por id_publicacion y nunca encontraba
                //      la fila, dejando el precio "congelado" en marketplace.jsp.
                //      Ahora se captura el id generado al insertar en publicaciones_foro y se
                //      pasa a crearItem para enlazar ambos registros desde el inicio.
                int nuevoIdPublicacion = infoDao.insertarPublicacionRetornandoId(
                        1, idUsuario, titulo, textoConPrecio, "Marketplace", archivoUrl, tema);

                marketDao.crearItem(idUsuario, titulo, descripcionConTema, precio, fotoFinal, escuelaSeleccionada, nuevoIdPublicacion);
                
                response.sendRedirect("marketplace.jsp?mensaje=Publicacion+creada+con+exito");
            }

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