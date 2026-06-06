<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
        <link href="CSS/estiloBase.css" rel="stylesheet" />
    </head>
    <body>
        <%@include file="/Plantillas/header.jsp" %>
        <%@include file="/Plantillas/navBar.jsp" %>

        <section class="eventosMain">
            <div class="container">

                <main class="main-content">

                    <div class="page-title">
                        <i class="fa-solid fa-magnifying-glass"></i>
                        <h1>Explorar</h1>
                    </div>

                    <p class="description">
                        Encuentra información académica, trámites, tutorías,
                        becas y recursos.
                    </p>

                    <div class="tabs">
                        <button class="tab active">Trámites</button>
                        <button class="tab">Titulación</button>
                        <button class="tab">Becas</button>
                    </div>

                    <div class="search-box">
                        <i class="fa-solid fa-magnifying-glass"></i>
                        <input type="text" placeholder="Buscar trámites">
                    </div>

                    <h2 class="section-title">Trámites</h2>

                    <div class="tramite-card">

                        <div class="card-left">

                            <div class="icon-box red">
                                <i class="fa-regular fa-file-lines"></i>
                            </div>

                            <div class="card-info">
                                <h3>Reinscripción semestral</h3>
                                <div class="department">Servicios escolares</div>
                                <p>Consulta fechas, requisitos y pasos para realizar tu reinscripción en línea.</p>
                            </div>

                        </div>

                        <div class="card-right">
                            <div><i class="fa-regular fa-message"></i> 18 comentarios</div>
                            <div><i class="fa-regular fa-clock"></i> Actualizado hace 2 días</div>
                        </div>

                    </div>

                    <div class="tramite-card">

                        <div class="card-left">

                            <div class="icon-box purple">
                                <i class="fa-solid fa-graduation-cap"></i>
                            </div>

                            <div class="card-info">
                                <h3>Proceso de titulación</h3>
                                <div class="department">Coordinación académica</div>
                                <p>Información sobre modalidades de titulación, documentación y fechas importantes.</p>
                            </div>

                        </div>

                        <div class="card-right">
                            <div><i class="fa-regular fa-message"></i> 25 comentarios</div>
                            <div><i class="fa-regular fa-clock"></i> Hace 5 horas</div>
                        </div>

                    </div>

                    <div class="tramite-card">

                        <div class="card-left">

                            <div class="icon-box green">
                                <i class="fa-solid fa-award"></i>
                            </div>

                            <div class="card-info">
                                <h3>Solicitud de beca institucional</h3>
                                <div class="department">Becas IPN</div>
                                <p>Guía para registrarte y subir documentos para la beca del semestre actual.</p>
                            </div>

                        </div>

                        <div class="card-right">
                            <div><i class="fa-regular fa-message"></i> 10 comentarios</div>
                            <div><i class="fa-regular fa-clock"></i> Hace 1 día</div>
                        </div>

                    </div>

                    <div class="tramite-card">

                        <div class="card-left">

                            <div class="icon-box orange">
                                <i class="fa-solid fa-right-left"></i>
                            </div>

                            <div class="card-info">
                                <h3>Cambio de carrera o plantel</h3>
                                <div class="department">Gestión escolar</div>
                                <p>Requisitos, promedio mínimo y fechas disponibles para realizar cambios.</p>
                            </div>

                        </div>

                        <div class="card-right">
                            <div><i class="fa-regular fa-message"></i> 7 comentarios</div>
                            <div><i class="fa-regular fa-clock"></i> Hace 3 días</div>
                        </div>

                    </div>

                    <div class="tramite-card">

                        <div class="card-left">

                            <div class="icon-box teal">
                                <i class="fa-regular fa-heart"></i>
                            </div>

                            <div class="card-info">
                                <h3>Liberación de servicio social</h3>
                                <div class="department">Departamento de servicio social</div>
                                <p>Pasos para entregar reportes y obtener tu carta de liberación.</p>
                            </div>

                        </div>

                        <div class="card-right">
                            <div><i class="fa-regular fa-message"></i> 14 comentarios</div>
                            <div><i class="fa-regular fa-clock"></i> Hace 6 horas</div>
                        </div>

                    </div>

                    <div class="tramite-card">

                        <div class="card-left">

                            <div class="icon-box blue">
                                <i class="fa-regular fa-id-card"></i>
                            </div>

                            <div class="card-info">
                                <h3>Trámite de credencial</h3>
                                <div class="department">Control escolar</div>
                                <p>Reposición, renovación y activación de credencial estudiantil.</p>
                            </div>

                        </div>

                        <div class="card-right">
                            <div><i class="fa-regular fa-message"></i> 4 comentarios</div>
                            <div><i class="fa-regular fa-clock"></i> Hace 1 semana</div>
                        </div>

                    </div>

                </main>

                <aside class="events">

                    <div class="events-header">
                        <h3>Próximos eventos</h3>
                        <a href="#">Ver todos</a>
                    </div>

                    <div class="event">
                        <div class="date">
                            <span>24</span>
                            <small>MAY</small>
                        </div>
                        <div class="event-info">
                            <h4>Nombre del evento</h4>
                            <p>10:00 AM • Lugar</p>
                        </div>
                    </div>

                    <div class="event">
                        <div class="date">
                            <span>27</span>
                            <small>MAY</small>
                        </div>
                        <div class="event-info">
                            <h4>Nombre del evento</h4>
                            <p>11:00 AM • Lugar</p>
                        </div>
                    </div>

                    <div class="event">
                        <div class="date">
                            <span>31</span>
                            <small>MAY</small>
                        </div>
                        <div class="event-info">
                            <h4>Nombre del evento</h4>
                            <p>08:00 AM • Lugar</p>
                        </div>
                    </div>

                    <button class="calendar-btn">
                        Ver calendario completo
                    </button>

                </aside>

            </div>
        </section>

        <%@include file="/Plantillas/footer.jsp" %>
    </body>
</html>
