-- Base de datos para PoliWiki
-- MySQL 8.x

CREATE DATABASE IF NOT EXISTS poliwiki
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE poliwiki;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS marketplace_items;
DROP TABLE IF EXISTS eventos;
DROP TABLE IF EXISTS comentarios_tramite;
DROP TABLE IF EXISTS tramites;
DROP TABLE IF EXISTS respuestas_foro;
DROP TABLE IF EXISTS publicaciones_foro;
DROP TABLE IF EXISTS categorias_foro;
DROP TABLE IF EXISTS apuntes;
DROP TABLE IF EXISTS profesor_materia;
DROP TABLE IF EXISTS profesores;
DROP TABLE IF EXISTS materias;
DROP TABLE IF EXISTS usuarios;
DROP TABLE IF EXISTS carreras;
DROP TABLE IF EXISTS escuelas;
DROP TABLE IF EXISTS roles;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE roles (
  id_rol INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(30) NOT NULL UNIQUE,
  descripcion VARCHAR(150) NULL
) ENGINE=InnoDB;

CREATE TABLE escuelas (
  id_escuela INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(150) NOT NULL,
  siglas VARCHAR(20) NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE carreras (
  id_carrera INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_escuela INT UNSIGNED NOT NULL,
  nombre VARCHAR(150) NOT NULL,
  nivel ENUM('medio_superior', 'superior', 'posgrado') NOT NULL DEFAULT 'medio_superior',
  CONSTRAINT fk_carreras_escuelas
    FOREIGN KEY (id_escuela) REFERENCES escuelas(id_escuela)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  UNIQUE KEY uq_carrera_escuela (id_escuela, nombre)
) ENGINE=InnoDB;

CREATE TABLE usuarios (
  id_usuario INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_rol INT UNSIGNED NOT NULL DEFAULT 2,
  id_carrera INT UNSIGNED NULL,
  nombres VARCHAR(80) NOT NULL,
  apellido_paterno VARCHAR(80) NOT NULL,
  apellido_materno VARCHAR(80) NULL,
  correo_institucional VARCHAR(120) NOT NULL UNIQUE,
  boleta VARCHAR(20) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  activo TINYINT(1) NOT NULL DEFAULT 1,
  creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_usuarios_roles
    FOREIGN KEY (id_rol) REFERENCES roles(id_rol)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_usuarios_carreras
    FOREIGN KEY (id_carrera) REFERENCES carreras(id_carrera)
    ON UPDATE CASCADE
    ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE materias (
  id_materia INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_carrera INT UNSIGNED NULL,
  nombre VARCHAR(120) NOT NULL,
  semestre TINYINT UNSIGNED NULL,
  descripcion TEXT NULL,
  CONSTRAINT fk_materias_carreras
    FOREIGN KEY (id_carrera) REFERENCES carreras(id_carrera)
    ON UPDATE CASCADE
    ON DELETE SET NULL,
  UNIQUE KEY uq_materia_carrera (id_carrera, nombre)
) ENGINE=InnoDB;

CREATE TABLE profesores (
  id_profesor INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_escuela INT UNSIGNED NULL,
  nombres VARCHAR(80) NOT NULL,
  apellido_paterno VARCHAR(80) NOT NULL,
  apellido_materno VARCHAR(80) NULL,
  correo VARCHAR(120) NULL,
  telefono VARCHAR(25) NULL,
  biografia TEXT NULL,
  creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_profesores_escuelas
    FOREIGN KEY (id_escuela) REFERENCES escuelas(id_escuela)
    ON UPDATE CASCADE
    ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE profesor_materia (
  id_profesor INT UNSIGNED NOT NULL,
  id_materia INT UNSIGNED NOT NULL,
  PRIMARY KEY (id_profesor, id_materia),
  CONSTRAINT fk_profesor_materia_profesor
    FOREIGN KEY (id_profesor) REFERENCES profesores(id_profesor)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT fk_profesor_materia_materia
    FOREIGN KEY (id_materia) REFERENCES materias(id_materia)
    ON UPDATE CASCADE
    ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE apuntes (
  id_apunte INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_usuario INT UNSIGNED NULL,
  id_materia INT UNSIGNED NULL,
  titulo VARCHAR(180) NOT NULL,
  descripcion TEXT NULL,
  archivo_url VARCHAR(255) NOT NULL,
  tipo_archivo VARCHAR(30) NOT NULL DEFAULT 'pdf',
  descargas INT UNSIGNED NOT NULL DEFAULT 0,
  destacado TINYINT(1) NOT NULL DEFAULT 0,
  creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_apuntes_usuarios
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
    ON UPDATE CASCADE
    ON DELETE SET NULL,
  CONSTRAINT fk_apuntes_materias
    FOREIGN KEY (id_materia) REFERENCES materias(id_materia)
    ON UPDATE CASCADE
    ON DELETE SET NULL,
  INDEX idx_apuntes_destacado (destacado),
  FULLTEXT KEY ft_apuntes_busqueda (titulo, descripcion)
) ENGINE=InnoDB;

CREATE TABLE categorias_foro (
  id_categoria INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(60) NOT NULL UNIQUE,
  descripcion VARCHAR(180) NULL
) ENGINE=InnoDB;

CREATE TABLE publicaciones_foro (
  id_publicacion INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_categoria INT UNSIGNED NOT NULL,
  id_usuario INT UNSIGNED NULL,
  titulo VARCHAR(180) NOT NULL,
  contenido TEXT NOT NULL,
  estado ENUM('abierta', 'cerrada', 'oculta') NOT NULL DEFAULT 'abierta',
  creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_publicaciones_categoria
    FOREIGN KEY (id_categoria) REFERENCES categorias_foro(id_categoria)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_publicaciones_usuario
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
    ON UPDATE CASCADE
    ON DELETE SET NULL,
  FULLTEXT KEY ft_publicaciones_busqueda (titulo, contenido)
) ENGINE=InnoDB;

CREATE TABLE respuestas_foro (
  id_respuesta INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_publicacion INT UNSIGNED NOT NULL,
  id_usuario INT UNSIGNED NULL,
  contenido TEXT NOT NULL,
  creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_respuestas_publicacion
    FOREIGN KEY (id_publicacion) REFERENCES publicaciones_foro(id_publicacion)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT fk_respuestas_usuario
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
    ON UPDATE CASCADE
    ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE tramites (
  id_tramite INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  titulo VARCHAR(160) NOT NULL,
  departamento VARCHAR(120) NOT NULL,
  categoria ENUM('tramites', 'titulacion', 'becas', 'servicio_social', 'control_escolar') NOT NULL DEFAULT 'tramites',
  descripcion TEXT NOT NULL,
  url_oficial VARCHAR(255) NULL,
  actualizado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FULLTEXT KEY ft_tramites_busqueda (titulo, departamento, descripcion)
) ENGINE=InnoDB;

CREATE TABLE comentarios_tramite (
  id_comentario INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_tramite INT UNSIGNED NOT NULL,
  id_usuario INT UNSIGNED NULL,
  comentario TEXT NOT NULL,
  creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_comentarios_tramite
    FOREIGN KEY (id_tramite) REFERENCES tramites(id_tramite)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT fk_comentarios_usuario
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
    ON UPDATE CASCADE
    ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE eventos (
  id_evento INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  titulo VARCHAR(160) NOT NULL,
  descripcion TEXT NULL,
  lugar VARCHAR(160) NULL,
  inicia_en DATETIME NOT NULL,
  termina_en DATETIME NULL,
  creado_por INT UNSIGNED NULL,
  creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_eventos_usuario
    FOREIGN KEY (creado_por) REFERENCES usuarios(id_usuario)
    ON UPDATE CASCADE
    ON DELETE SET NULL,
  INDEX idx_eventos_fecha (inicia_en)
) ENGINE=InnoDB;

CREATE TABLE marketplace_items (
  id_item INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_usuario INT UNSIGNED NULL,
  titulo VARCHAR(160) NOT NULL,
  descripcion TEXT NOT NULL,
  precio DECIMAL(10,2) NULL,
  estado ENUM('disponible', 'vendido', 'pausado') NOT NULL DEFAULT 'disponible',
  creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_marketplace_usuario
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
    ON UPDATE CASCADE
    ON DELETE SET NULL,
  FULLTEXT KEY ft_marketplace_busqueda (titulo, descripcion)
) ENGINE=InnoDB;

INSERT INTO roles (nombre, descripcion) VALUES
  ('administrador', 'Gestiona contenido, usuarios y avisos.'),
  ('estudiante', 'Usuario estudiante de PoliWiki.'),
  ('profesor', 'Usuario docente asociado a materias.');

INSERT INTO escuelas (nombre, siglas) VALUES
  ('Centro de Estudios Cientificos y Tecnologicos 9', 'CECyT 9');

INSERT INTO carreras (id_escuela, nombre, nivel) VALUES
  (1, 'Tecnico en Programacion', 'medio_superior'),
  (1, 'Tecnico en Maquinas con Sistemas Automatizados', 'medio_superior'),
  (1, 'Tecnico en Sistemas Digitales', 'medio_superior');

INSERT INTO usuarios
  (id_rol, id_carrera, nombres, apellido_paterno, apellido_materno, correo_institucional, boleta, password_hash)
VALUES
  (1, NULL, 'Administrador', 'PoliWiki', NULL, 'admin@alumno.ipn.mx', '0000000000', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9'),
  (2, 1, 'Mariana', 'Tejados', NULL, 'mariana.tejados@alumno.ipn.mx', '2026000001', 'daf6669f00f3e4a88c264cf0de5928f81b42bcd292e3ca6737757ed32d996f98');

INSERT INTO materias (id_carrera, nombre, semestre, descripcion) VALUES
  (1, 'Calculo Diferencial', 2, 'Material y dudas de calculo diferencial.'),
  (1, 'Quimica', 2, 'Material de quimica del segundo semestre.'),
  (1, 'Biologia Basica', 1, 'Fundamentos de biologia.'),
  (1, 'Ingles', 1, 'Idioma ingles.'),
  (1, 'Comunicacion Cientifica', 2, 'Comunicacion aplicada a ciencia y tecnologia.');

INSERT INTO profesores
  (id_escuela, nombres, apellido_paterno, apellido_materno, biografia)
VALUES
  (1, 'Armando', 'Suarez', NULL, 'Profesor destacado de Ingles y Biologia.'),
  (1, 'Sonia', 'Barrios', NULL, 'Profesora destacada de Biologia y Comunicacion Cientifica.');

INSERT INTO profesor_materia (id_profesor, id_materia) VALUES
  (1, 3),
  (1, 4),
  (2, 3),
  (2, 5);

INSERT INTO apuntes
  (id_usuario, id_materia, titulo, descripcion, archivo_url, tipo_archivo, destacado)
VALUES
  (2, 1, 'Calculo Diferencial - Notas Completas', 'Apunte destacado incluido en el proyecto.', 'PDFs/Calculo diferencial parcial 2.pdf', 'pdf', 1),
  (2, 2, 'Quimica', 'Apunte destacado incluido en el proyecto.', 'PDFs/Quimica 2.pdf', 'pdf', 1);

INSERT INTO categorias_foro (nombre, descripcion) VALUES
  ('Preguntas', 'Dudas academicas de la comunidad.'),
  ('Discusiones', 'Conversaciones generales sobre vida escolar.'),
  ('Avisos', 'Comunicados importantes.');

INSERT INTO publicaciones_foro
  (id_categoria, id_usuario, titulo, contenido)
VALUES
  (1, 2, 'Alguien entendio calculo?', 'Tengo duda con el ejemplo 3, en aplicar la regla de la cadena.'),
  (3, 1, 'Inscripcion a ETS', 'Las inscripciones inician este viernes.');

INSERT INTO respuestas_foro (id_publicacion, id_usuario, contenido) VALUES
  (1, 1, 'Revisa primero la derivada exterior y despues multiplica por la derivada interior.');

INSERT INTO tramites
  (titulo, departamento, categoria, descripcion)
VALUES
  ('Reinscripcion semestral', 'Servicios escolares', 'tramites', 'Consulta fechas, requisitos y pasos para realizar tu reinscripcion en linea.'),
  ('Proceso de titulacion', 'Coordinacion academica', 'titulacion', 'Informacion sobre modalidades de titulacion, documentacion y fechas importantes.'),
  ('Solicitud de beca institucional', 'Becas IPN', 'becas', 'Guia para registrarte y subir documentos para la beca del semestre actual.'),
  ('Cambio de carrera o plantel', 'Gestion escolar', 'tramites', 'Requisitos, promedio minimo y fechas disponibles para realizar cambios.'),
  ('Liberacion de servicio social', 'Departamento de servicio social', 'servicio_social', 'Pasos para entregar reportes y obtener tu carta de liberacion.'),
  ('Tramite de credencial', 'Control escolar', 'control_escolar', 'Reposicion, renovacion y activacion de credencial estudiantil.');

INSERT INTO eventos
  (titulo, descripcion, lugar, inicia_en)
VALUES
  ('Nombre del evento', 'Evento mostrado como ejemplo en la interfaz.', 'Lugar', '2026-05-24 10:00:00'),
  ('Nombre del evento', 'Evento mostrado como ejemplo en la interfaz.', 'Lugar', '2026-05-27 11:00:00'),
  ('Nombre del evento', 'Evento mostrado como ejemplo en la interfaz.', 'Lugar', '2026-05-31 08:00:00');

INSERT INTO marketplace_items
  (id_usuario, titulo, descripcion, precio)
VALUES
  (2, 'Libro o material de ejemplo', 'Publicacion inicial para la seccion Marketplace.', 0.00);
