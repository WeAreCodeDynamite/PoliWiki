
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.JspFragment;
import javax.servlet.jsp.tagext.SimpleTagSupport;

public class PaginaBase extends SimpleTagSupport {

    String basesita = """
                      <html lang="en">
                      
                      <head>
                          <meta charset="UTF-8">
                          <meta name="viewport" content="width=device-width, initial-scale=1.0">
                          <link href="CSS/index.css" rel="stylesheet">
                          <title>Bienvenido</title>
                      </head>
                      
                      <body>
                          <header>
                              <button id="boton_menu_lateral">&#9776</button>
                              <img class="logo" src="Imgs/logo_PoliWiki.jpeg" type="img">
                              <div class="eslogan">
                                  <h1>POLIWIKI</h1>
                                  <p>Comunidad Estudiantil del IPN</p>
                              </div>
                              <form>
                                  <input type="search" id="barraBusqueda" placeholder="Buscar en POLIWIKI">
                                  <button type="submit"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
                                          <path
                                              d="M15.5 14h-.79l-.28-.27A6.471 6.471 0 0 0 16 9.5 6.5 6.5 0 1 0 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z">
                      
                                          </path>
                                      </svg></button>
                              </form>
                      
                              <div class="auth">
                                  <a class="login" href="login.html">Iniciar Sesi\u00f3n</a>
                                  <a class="signup" href="signup.html">Crear cuenta</a>
                              </div>
                          </header>
                          <br>
                      
                          <div class="vistaPrincipal">
                              <aside id="menuLateral">
                                  <div class="paginas">
                                      <ul>
                                          <li>Inicio</li>
                                          <li>Explorar</li>
                                          <li>Materias</li>
                                          <li>Apuntes</li>
                                          <li>Profesores</li>
                                          <li><a href="foros.html">Foros</a></li>
                                          <li>Marketplace</li>
                                          <li>Eventos</li>
                                      </ul>
                                  </div>
                                  <div class="accesosRapidos">
                                      <p>ACCESOS R\u00c1PIDOS</p>
                                      <ul>
                                          <li>Subir apuntes</li>
                                          <li>Hacer publicaci\u00f3n</li>
                                          <li>Hacer pregunta</li>
                                          <li>Publicar e marketplace</li>
                                      </ul>
                                  </div>
                                  <div class="otros">
                                      <p>OTROS</p>
                                      <ul>
                                          <li>Ayuda y soporte</li>
                                      </ul>
                                  </div>
                                  <div class="cerrarSesion">
                                      <ul>
                                          <li>Cerrar sesi\u00f3n</li>
                                      </ul>
                                  </div>
                              </aside>
                              <main>
                                  <nav>
                                      <ul class="navLinks">
                                          <li><a id="info" href="informacion.html">Informaci\u00f3n</a></li>
                                          <li><a href="profesores.html">Profesores</a></li>
                                          <li><a href="explorarContenido.html">Tr\u00e1mites</a></li>
                                          <li><a href="eventos.html">Eventos</a></li>
                                          <li><a href="foros.html">Foros</a></li>
                                          <li><a href="marketplace.html">MarketPlace</a></li>
                                      </ul>
                                  </nav>
                      
                                  <section class="contenidoPrincipal">
                                   [CONTENIDO]
                                  </section>
                              </main>
                          </div>
                          <footer>
                              <div class=" redesSociales">
                      
                                          <div class="infoPoliWiki">
                                              <img src="Imgs/logo_PoliWiki.jpeg" class="logo">
                                              <div>
                                                  <p class="nombre">PoliWiki</p>
                                                  <p>Comunidad estudiantil del IPN</p>
                                                  <p>Conectando estudiantes, compartiendo conocimiento.</p>
                                              </div>
                                          </div>
                                          <img src="/Imgs/x.svg" type="img/svg">
                                          <img src="/Imgs/Facebook.svg" type="img/svg">
                                          <img src="/Imgs/Instagram.svg" type="img/svg">
                                      </div>
                      
                                      <div class="enlaces">
                                          <p class="nombre">Enlaces r\u00e1pidos</p>
                                          <ul>
                                              <li><a href="index.html">Inicio</a></li>
                                              <li><a href="explorar.html">Explorar</a></li>
                                              <li><a href="foros.html">Foros</a></li>
                                              <li><a href="marketplace.html">Marketplace</a></li>
                                              <li><a href="eventos.html">Eventos</a></li>
                      
                                          </ul>
                                      </div>
                      
                                      <div class="recursos">
                                          <p class="nombre">Recursos</p>
                                          <ul>
                                              <li><a href="ayuda.html">Ayuda</a></li>
                                              <li><a href="ayuda.html">Reglamento</a></li>
                                              <li><a href="ayuda.html">Gu\u00edas</a></li>
                                              <li><a href="ayuda.html">Preguntas frecuentes</a></li>
                                          </ul>
                                      </div>
                      
                                      <div class="about">
                                          <p class="nombre">Sobre PoliWiki</p>
                                          <p>PoliWIki es una plataforma creada por y para
                                              estudiantes del IPN, con el objetivo de impulsar
                                              la colaboraci\u00f3n y el aprendizaje.
                                          </p>
                                      </div>
                      
                                      <div class="contacto">
                                          <p class="nombre">Contacto</p>
                                          <a href="mailto:contactopoliwiki@gmail.com">
                                              contactopoliwiki@gmail.com
                                          </a>
                                      </div>
                      
                      
                                      </footer>
                      
                                      <script src="/JS/index.js"></script>
                      </body>
                      
                      </html>""";

    @Override
    public void doTag() throws JspException {
        JspWriter out = getJspContext().getOut();

        try {
            JspFragment f = getJspBody();
            if (f != null) {
                f.invoke(out);
                String salidaString = basesita.replace("[CONTENIDO]", f.toString());
                out.write(salidaString);
            }
        } catch (java.io.IOException ex) {
            throw new JspException("Error in PaginaBase tag", ex);
        }
    }

}
