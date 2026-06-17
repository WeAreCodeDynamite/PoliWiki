package poliwiki.servlet;

import java.io.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet(name = "ImagenServlet", urlPatterns = {"/verImagen"})
public class ImagenServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Obtenemos el nombre del archivo desde la URL (ej: verImagen?nombre=foto.jpg)
        String nombreImagen = request.getParameter("nombre");
        String rutaBase = "C:/poliwiki_uploads/profesores/";
        
        File file = new File(rutaBase + nombreImagen);
        
        // Verificamos que el archivo exista
        if (file.exists()) {
            // Determinamos el tipo de contenido (jpg, png, etc.)
            response.setContentType(getServletContext().getMimeType(file.getName()));
            response.setContentLength((int) file.length());
            
            // Leemos y escribimos la imagen en la respuesta
            try (FileInputStream in = new FileInputStream(file);
                 OutputStream out = response.getOutputStream()) {
                byte[] buffer = new byte[1024];
                int bytesRead;
                while ((bytesRead = in.read(buffer)) != -1) {
                    out.write(buffer, 0, bytesRead);
                }
            }
        }
    }
}