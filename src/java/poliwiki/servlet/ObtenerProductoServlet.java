package poliwiki.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import poliwiki.dao.MarketplaceDao;

@WebServlet("/ObtenerProductoServlet")
public class ObtenerProductoServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        
        try {
            MarketplaceDao dao = new MarketplaceDao();
            // Asegúrate de tener un método en tu DAO que busque un item por su ID
            // Supongamos que regresa un Map<String, Object> o tu modelo Producto
            Map<String, Object> producto = dao.obtenerItemPorId(Integer.parseInt(idStr)); 
            
            if (producto != null) {
                // Construimos un JSON simple manualmente para no obligarte a usar librerías externas
                PrintWriter out = response.getWriter();
                String titulo = (String) producto.get("titulo");
                double precio = ((Number) producto.get("precio")).doubleValue();
                String escuela = (String) producto.get("escuela");
                String descCompleta = (String) producto.get("descripcion"); 
                
                // Limpiar el [Tema] de la descripción si es necesario
                String tema = "";
                String descripcion = descCompleta;
                if (descCompleta != null && descCompleta.startsWith("[")) {
                    int finTema = descCompleta.indexOf("]");
                    if (finTema != -1) {
                        tema = descCompleta.substring(1, finTema);
                        descripcion = descCompleta.substring(finTema + 1).trim();
                    }
                }

                out.print("{");
                out.print("\"id\":\"" + idStr + "\",");
                out.print("\"titulo\":\"" + titulo.replace("\"", "\\\"") + "\",");
                out.print("\"precio\":" + precio + ",");
                out.print("\"tema\":\"" + tema.replace("\"", "\\\"") + "\",");
                out.print("\"escuela\":\"" + escuela + "\",");
                out.print("\"descripcion\":\"" + descripcion.replace("\"", "\\\"") + "\"");
                out.print("}");
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}