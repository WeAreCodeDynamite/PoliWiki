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
    fileSizeThreshold = 1024 * 1024 * 2,
    maxFileSize = 1024 * 1024 * 10,
    maxRequestSize = 1024 * 1024 * 50
)
public class GuardarPublicacionServlet extends HttpServlet {

    private static final String UPLOAD_DIR = "Archivos";

    private static final List<String> EXTENSIONES_DOCUMENTOS = Arrays.asList("pdf", "docx", "doc", "txt", "pptx", "xlsx");
    private static final List<String> EXTENSIONES_IMAGENES   = Arrays.asList("png", "jpg", "jpeg", "webp");

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

        String idPublicacionStr  = request.getParameter("id_publicacion");
        String tipoPublicacion   = request.getParameter("tipo_publicacion");
        String titulo            = request.getParameter("titulo");
        String idCategoriaStr    = request.getParameter("id_materia");
        String temas             = request.getParameter("temas");
        String contenidoGeneral  = request.getParameter("contenido_general");
        String redirectToParam   = request.getParameter("redirect_to");

        int idCategoria = (idCategoriaStr != null && !idCategoriaStr.isEmpty())
                          ? Integer.parseInt(idCategoriaStr) : 1;

        String applicationPath = request.getServletContext().getRealPath("");
        String uploadFilePath  = applicationPath + File.separator + UPLOAD_DIR;
        File uploadFolder = new File(uploadFilePath);
        if (!uploadFolder.exists()) {
            uploadFolder.mkdirs();
        }

        String archivoUrl = null;
        InformacionDao infoDao   = new InformacionDao();
        MarketplaceDao marketDao = new MarketplaceDao();

        String redireccionBase = "informacion.jsp";
        String mensajeStatus   = "Publicacion realizada con exito";

        try {
            boolean esEdicion = (idPublicacionStr != null && !idPublicacionStr.trim().isEmpty());
            mensajeStatus = esEdicion ? "Publicacion editada con exito" : "Publicacion creada con exito";

            if ("Material".equals(tipoPublicacion)) {
                Part part = request.getPart("archivo_adjunto");
                if (part != null && part.getSize() > 0) {
                    String originalName = obtenerNombreArchivo(part);
                    // FIX: obtenerExtension ya retorna en minúsculas, no se necesita toLowerCase()
                    String extension = obtenerExtension(originalName);
                    boolean esDocumento = EXTENSIONES_DOCUMENTOS.contains(extension);
boolean esImagen    = EXTENSIONES_IMAGENES.contains(extension);

if (!esDocumento && !esImagen) {
    response.setContentType("text/html;charset=UTF-8");
    response.getWriter().println(
        "Error: Formato no permitido. Formatos aceptados: PDF, DOCX, DOC, TXT, PPTX, XLSX, PNG, JPG, JPEG y WEBP."
    );
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
                    // FIX: obtenerExtension ya retorna en minúsculas, no se necesita toLowerCase()
                    String extension = obtenerExtension(originalName);
                    boolean esDocumento = EXTENSIONES_DOCUMENTOS.contains(extension);
boolean esImagen    = EXTENSIONES_IMAGENES.contains(extension);

if (!esDocumento && !esImagen) {
    response.setContentType("text/html;charset=UTF-8");
    response.getWriter().println(
        "Error: Formato no permitido. Formatos aceptados: PDF, DOCX, DOC, TXT, PPTX, XLSX, PNG, JPG, JPEG y WEBP."
    );
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

                Part partFoto = request.getPart("foto_producto");
                if (partFoto != null && partFoto.getSize() > 0) {
                    String originalName = obtenerNombreArchivo(partFoto);
                    // FIX: obtenerExtension ya retorna en minúsculas, no se necesita toLowerCase()
                    String extension = obtenerExtension(originalName);
                    if (!EXTENSIONES_IMAGENES.contains(extension)) {
                        response.setContentType("text/html;charset=UTF-8");
                        response.getWriter().println("Error: Tipo de archivo no permitido para imágenes. Formatos aceptados: PNG, JPG, JPEG, WEBP.");
                        return;
                    }
                    String fileName = "prod_" + System.currentTimeMillis() + "." + extension;
                    partFoto.write(uploadFilePath + File.separator + fileName);
                    archivoUrl = UPLOAD_DIR + "/" + fileName;
                }

                String textoConPrecio = "[Precio: $" + precio + "] " + contenidoGeneral;

                if (esEdicion) {
                    int idPublicacion = Integer.parseInt(idPublicacionStr);

                    String fotoFinal = archivoUrl;
                    if (fotoFinal == null) {
                        fotoFinal = marketDao.obtenerFotoPorIdPublicacion(idPublicacion);
                        if (fotoFinal == null) {
                            fotoFinal = "IMG/default-item.png";
                        }
                    }

                    marketDao.actualizarItemPorPublicacion(idPublicacion, titulo, contenidoGeneral, precio, fotoFinal);
                    infoDao.actualizarPublicacion(idPublicacion, idCategoria, titulo, textoConPrecio, fotoFinal, temas);

                } else {
                    String escuela   = marketDao.obtenerEscuelaPorUsuario(idUsuario);
                    String fotoFinal = (archivoUrl != null) ? archivoUrl : "IMG/default-item.png";

                    int nuevoIdPublicacion = infoDao.insertarPublicacionRetornandoId(
                            idCategoria, idUsuario, titulo, textoConPrecio, "Marketplace", archivoUrl, temas);

                    marketDao.crearItem(idUsuario, titulo, contenidoGeneral, precio, fotoFinal, escuela, nuevoIdPublicacion);
                }

                redireccionBase = "informacion.jsp";
                mensajeStatus   = esEdicion ? "Producto editado con exito" : "Producto publicado con exito";
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
        String[] tokens    = contentDisp.split(";");
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
        return nombreArchivo.substring(nombreArchivo.lastIndexOf(".") + 1).toLowerCase();
    }
}