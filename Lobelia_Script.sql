/* =====================================================
   PROYECTO LOBELIA - Base de datos (SQL Server)
   Curso: CC52 Ingenieria de Software - UPC
   Contenido: 1) Creacion de BD y tablas
              2) Datos de ejemplo
              3) Consultas de prueba
   ===================================================== */

IF DB_ID('Lobelia') IS NULL
    CREATE DATABASE Lobelia;
GO
USE Lobelia;
GO

/* ---------- 1. TABLAS ---------- */

CREATE TABLE Rol (
    idRol        INT IDENTITY(1,1) PRIMARY KEY,
    nombreRol    VARCHAR(50)  NOT NULL UNIQUE,
    descripcion  VARCHAR(100) NULL
);

CREATE TABLE Usuario (
    idUsuario            INT IDENTITY(1,1) PRIMARY KEY,
    nombre               VARCHAR(100) NOT NULL,
    email                VARCHAR(100) NOT NULL UNIQUE,
    telefono             VARCHAR(20)  NULL,
    canalNotifPreferido  VARCHAR(20)  NOT NULL DEFAULT 'APP'
        CHECK (canalNotifPreferido IN ('APP','SMS','EMAIL')),
    aceptaSms            BIT NOT NULL DEFAULT 0
);

CREATE TABLE UsuarioRol (
    idUsuario INT NOT NULL,
    idRol     INT NOT NULL,
    PRIMARY KEY (idUsuario, idRol),
    FOREIGN KEY (idUsuario) REFERENCES Usuario(idUsuario),
    FOREIGN KEY (idRol)     REFERENCES Rol(idRol)
);

CREATE TABLE DireccionUsuario (
    idDireccion INT IDENTITY(1,1) PRIMARY KEY,
    idUsuario   INT NOT NULL,
    direccion   VARCHAR(255) NOT NULL,
    distrito    VARCHAR(100) NULL,
    provincia   VARCHAR(100) NULL,
    FOREIGN KEY (idUsuario) REFERENCES Usuario(idUsuario)
);

CREATE TABLE Aficionado (
    idAficionado      INT IDENTITY(1,1) PRIMARY KEY,
    idUsuario         INT NOT NULL UNIQUE,
    nivelConocimiento VARCHAR(50)  NULL CHECK (nivelConocimiento IN ('BASICO','INTERMEDIO')),
    temaInteres       VARCHAR(100) NULL,
    FOREIGN KEY (idUsuario) REFERENCES Usuario(idUsuario)
);

CREATE TABLE Agricultor (
    idAgricultor     INT IDENTITY(1,1) PRIMARY KEY,
    idUsuario        INT NOT NULL UNIQUE,
    zonaAgricola     VARCHAR(100) NULL,
    nivelExperiencia VARCHAR(50)  NULL,
    FOREIGN KEY (idUsuario) REFERENCES Usuario(idUsuario)
);

CREATE TABLE Experto (
    idExperto               INT IDENTITY(1,1) PRIMARY KEY,
    idUsuario               INT NOT NULL UNIQUE,
    especialidad            VARCHAR(100) NULL,
    descripcionEspecialidad VARCHAR(255) NULL,
    FOREIGN KEY (idUsuario) REFERENCES Usuario(idUsuario)
);

CREATE TABLE Publicacion (
    idPublicacion INT IDENTITY(1,1) PRIMARY KEY,
    idUsuario     INT NOT NULL,
    titulo        VARCHAR(150) NOT NULL,
    tema          VARCHAR(100) NULL,
    descripcion   VARCHAR(255) NULL,
    creadoEn      DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    FOREIGN KEY (idUsuario) REFERENCES Usuario(idUsuario)
);

CREATE TABLE Comentario (
    idComentario     INT IDENTITY(1,1) PRIMARY KEY,
    idPublicacion    INT NOT NULL,
    idUsuario        INT NOT NULL,
    contenido        VARCHAR(500) NOT NULL,
    creadoEn         DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    moderacionEstado VARCHAR(50) NOT NULL DEFAULT 'APROBADO'
        CHECK (moderacionEstado IN ('APROBADO','REPORTADO','ELIMINADO')),
    FOREIGN KEY (idPublicacion) REFERENCES Publicacion(idPublicacion),
    FOREIGN KEY (idUsuario)     REFERENCES Usuario(idUsuario)
);

CREATE TABLE Reel (
    idReel        INT IDENTITY(1,1) PRIMARY KEY,
    idPublicacion INT NOT NULL UNIQUE,
    descripcion   VARCHAR(255) NULL,
    urlVideo      VARCHAR(255) NOT NULL,
    duracionSeg   INT NULL CHECK (duracionSeg > 0),
    creadoEn      DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    FOREIGN KEY (idPublicacion) REFERENCES Publicacion(idPublicacion)
);

CREATE TABLE Articulo (
    idArticulo    INT IDENTITY(1,1) PRIMARY KEY,
    idPublicacion INT NOT NULL UNIQUE,
    contenido     VARCHAR(MAX) NOT NULL,
    FOREIGN KEY (idPublicacion) REFERENCES Publicacion(idPublicacion)
);

CREATE TABLE EspecieCultivo (
    idEspecieCultivo INT IDENTITY(1,1) PRIMARY KEY,
    nombreComun      VARCHAR(100) NOT NULL,
    nombreCientifico VARCHAR(150) NULL
);

CREATE TABLE Parcela (
    idParcela        INT IDENTITY(1,1) PRIMARY KEY,
    idUsuario        INT NOT NULL,
    nombreParcela    VARCHAR(100) NOT NULL,
    tipoSuelo        VARCHAR(100) NULL,
    superficieHa     DECIMAL(10,2) NULL CHECK (superficieHa > 0),
    ubicacionCultivo VARCHAR(255) NULL,
    FOREIGN KEY (idUsuario) REFERENCES Usuario(idUsuario)
);

CREATE TABLE Cultivo (
    idCultivo        INT IDENTITY(1,1) PRIMARY KEY,
    idUsuario        INT NOT NULL,
    idParcela        INT NOT NULL,
    idEspecieCultivo INT NOT NULL,
    fechaSiembra     DATE NULL,
    estadoGeneral    VARCHAR(100) NULL,
    FOREIGN KEY (idUsuario)        REFERENCES Usuario(idUsuario),
    FOREIGN KEY (idParcela)        REFERENCES Parcela(idParcela),
    FOREIGN KEY (idEspecieCultivo) REFERENCES EspecieCultivo(idEspecieCultivo)
);

CREATE TABLE SensorIoT (
    idSensorIoT INT IDENTITY(1,1) PRIMARY KEY,
    idParcela   INT NOT NULL,
    tipo        VARCHAR(100) NOT NULL,
    estado      VARCHAR(50)  NULL,
    FOREIGN KEY (idParcela) REFERENCES Parcela(idParcela)
);

CREATE TABLE LecturaSensor (
    idLecturaSensor INT IDENTITY(1,1) PRIMARY KEY,
    idSensorIoT     INT NOT NULL,
    timeStamp       DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    valor           DECIMAL(10,2) NOT NULL,
    unidadMedida    VARCHAR(50) NULL,
    FOREIGN KEY (idSensorIoT) REFERENCES SensorIoT(idSensorIoT)
);

CREATE TABLE Enfermedad (
    idEnfermedad       INT IDENTITY(1,1) PRIMARY KEY,
    nombre             VARCHAR(100) NOT NULL,
    agenteCausal       VARCHAR(100) NULL,
    sintomas           VARCHAR(255) NULL,
    manejoRecomendado  VARCHAR(255) NULL,
    esPlaga            BIT NOT NULL DEFAULT 0
);

CREATE TABLE Diagnostico (
    idDiagnostico      INT IDENTITY(1,1) PRIMARY KEY,
    idCultivo          INT NOT NULL,
    idLecturaSensor    INT NULL,   -- NULL si el diagnostico fue por foto o experto
    idEnfermedad       INT NULL,   -- NULL si la necesidad no es una enfermedad (ej. riego)
    origen             VARCHAR(100) NOT NULL
        CHECK (origen IN ('VISION','SENSOR','EXPERTO')),
    necesidadDetectada VARCHAR(255) NULL,
    urlEvidencia       VARCHAR(255) NULL,
    generadoEn         DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    FOREIGN KEY (idCultivo)       REFERENCES Cultivo(idCultivo),
    FOREIGN KEY (idLecturaSensor) REFERENCES LecturaSensor(idLecturaSensor),
    FOREIGN KEY (idEnfermedad)    REFERENCES Enfermedad(idEnfermedad)
);

CREATE TABLE IncidenciaCultivo (
    idIncidenciaCultivo INT IDENTITY(1,1) PRIMARY KEY,
    idCultivo           INT NOT NULL,
    idEnfermedad        INT NULL,
    tipo                VARCHAR(100) NULL,
    severidad           VARCHAR(50)  NULL CHECK (severidad IN ('BAJO','MEDIO','ALTO')),
    descripcion         VARCHAR(255) NULL,
    fechaDetectada      DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    FOREIGN KEY (idCultivo)    REFERENCES Cultivo(idCultivo),
    FOREIGN KEY (idEnfermedad) REFERENCES Enfermedad(idEnfermedad)
);

CREATE TABLE CalendarioAgricola (
    idCalendarioAgricola INT IDENTITY(1,1) PRIMARY KEY,
    nombre               VARCHAR(100) NOT NULL,
    temporada            VARCHAR(100) NULL
);

CREATE TABLE TareaProgramada (
    idTareaProgramada    INT IDENTITY(1,1) PRIMARY KEY,
    idCalendarioAgricola INT NOT NULL,
    idCultivo            INT NOT NULL,
    tipo                 VARCHAR(100) NOT NULL,
    fechaProgramada      DATE NOT NULL,
    recurrente           BIT NOT NULL DEFAULT 0,
    estado               VARCHAR(100) NOT NULL DEFAULT 'PENDIENTE'
        CHECK (estado IN ('PENDIENTE','COMPLETADA','RETRASADA')),
    FOREIGN KEY (idCalendarioAgricola) REFERENCES CalendarioAgricola(idCalendarioAgricola),
    FOREIGN KEY (idCultivo)            REFERENCES Cultivo(idCultivo)
);

CREATE TABLE Clima (
    idClima         INT IDENTITY(1,1) PRIMARY KEY,
    idParcela       INT NOT NULL,
    fechaHora       DATETIME2 NOT NULL,
    temperaturaC    DECIMAL(5,2) NULL,
    humedadRelativa DECIMAL(5,2) NULL CHECK (humedadRelativa BETWEEN 0 AND 100),
    fuente          VARCHAR(100) NULL,
    FOREIGN KEY (idParcela) REFERENCES Parcela(idParcela)
);

CREATE TABLE Alerta (
    idAlerta          INT IDENTITY(1,1) PRIMARY KEY,
    idUsuario         INT NOT NULL,
    idTareaProgramada INT NULL,  -- NULL si la alerta es de clima
    idClima           INT NULL,  -- NULL si la alerta es de tarea
    tipo              VARCHAR(100) NOT NULL
        CHECK (tipo IN ('CLIMA','TAREA','DIAGNOSTICO')),
    prioridad         VARCHAR(50) NOT NULL DEFAULT 'MEDIA'
        CHECK (prioridad IN ('BAJA','MEDIA','ALTA')),
    mensaje           VARCHAR(255) NOT NULL,
    canal             VARCHAR(50)  NOT NULL
        CHECK (canal IN ('APP','SMS','EMAIL')),
    fechaEnviado      DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    leido             BIT NOT NULL DEFAULT 0,
    FOREIGN KEY (idUsuario)         REFERENCES Usuario(idUsuario),
    FOREIGN KEY (idTareaProgramada) REFERENCES TareaProgramada(idTareaProgramada),
    FOREIGN KEY (idClima)           REFERENCES Clima(idClima)
);
GO

/* ---------- 2. DATOS DE EJEMPLO ---------- */

INSERT INTO Rol (nombreRol, descripcion) VALUES
('Agricultor','Gestiona cultivos, tareas y diagnosticos'),
('Aficionado','Consume guias y publicaciones'),
('Experto','Asesora, publica contenido y valida diagnosticos');

INSERT INTO Usuario (nombre, email, telefono, canalNotifPreferido, aceptaSms) VALUES
('Favio Rios Sanchez','favio.rios@example.com','987654321','SMS',1),
('Milagros Garcia Flores','milagros.garcia@example.com','912345678','APP',0),
('Luis Quispe Huaman','luis.quispe@example.com','956781234','SMS',1);

INSERT INTO UsuarioRol (idUsuario, idRol) VALUES (1,1),(2,2),(3,3);

INSERT INTO DireccionUsuario (idUsuario, direccion, distrito, provincia) VALUES
(1,'Fundo Los Limoneros s/n','Tarapoto','San Martin'),
(2,'Av. Principal 123','Surco','Lima');

INSERT INTO Agricultor (idUsuario, zonaAgricola, nivelExperiencia) VALUES (1,'San Martin','10 anios');
INSERT INTO Aficionado (idUsuario, nivelConocimiento, temaInteres) VALUES (2,'INTERMEDIO','Papas nativas');
INSERT INTO Experto (idUsuario, especialidad, descripcionEspecialidad) VALUES (3,'Plagas','Ingeniero agronomo especialista en control de plagas');

INSERT INTO EspecieCultivo (nombreComun, nombreCientifico) VALUES
('Limon','Citrus x limon'),
('Papa','Solanum tuberosum');

INSERT INTO Parcela (idUsuario, nombreParcela, tipoSuelo, superficieHa, ubicacionCultivo) VALUES
(1,'Lote Sur','Arcilloso',2.50,'-6.4900,-76.3600'),
(2,'Huerto Azotea','Mixto',0.01,'Surco, Lima');

INSERT INTO Cultivo (idUsuario, idParcela, idEspecieCultivo, fechaSiembra, estadoGeneral) VALUES
(1,1,1,'2024-03-15','En crecimiento'),
(2,2,2,'2025-08-01','En crecimiento');

INSERT INTO SensorIoT (idParcela, tipo, estado) VALUES (1,'Humedad','ACTIVO'),(2,'Temperatura','ACTIVO');
INSERT INTO LecturaSensor (idSensorIoT, valor, unidadMedida) VALUES (1,32.50,'%'),(2,18.40,'C');

INSERT INTO Enfermedad (nombre, agenteCausal, sintomas, manejoRecomendado, esPlaga) VALUES
('Cochinilla','Insecto Coccoidea','Insectos oscuros en hojas y frutos','Poda y fumigacion con jabon potasico',1),
('Tizon tardio','Phytophthora infestans','Manchas oscuras en hojas','Fungicida y rotacion de cultivos',0);

INSERT INTO Diagnostico (idCultivo, idLecturaSensor, idEnfermedad, origen, necesidadDetectada, urlEvidencia) VALUES
(1,NULL,1,'VISION','Plaga detectada por foto','https://ejemplo.com/foto1.jpg'),
(2,2,NULL,'SENSOR','Riego recomendado',NULL);

INSERT INTO IncidenciaCultivo (idCultivo, idEnfermedad, tipo, severidad, descripcion) VALUES
(1,1,'Plaga','MEDIO','Frutos con manchas oscuras');

INSERT INTO CalendarioAgricola (nombre, temporada) VALUES ('Calendario Limon 2025','Verano');
INSERT INTO TareaProgramada (idCalendarioAgricola, idCultivo, tipo, fechaProgramada, recurrente, estado) VALUES
(1,1,'Fertilizacion','2025-11-20',1,'PENDIENTE'),
(1,1,'Control de plagas','2025-11-10',0,'COMPLETADA');

INSERT INTO Clima (idParcela, fechaHora, temperaturaC, humedadRelativa, fuente) VALUES
(1,'2025-11-04 08:00',27.5,82.0,'API'),
(2,'2025-11-04 08:00',19.0,70.0,'Sensor');

INSERT INTO Alerta (idUsuario, idTareaProgramada, idClima, tipo, prioridad, mensaje, canal) VALUES
(1,1,NULL,'TAREA','MEDIA','Recordatorio: fertilizacion programada para el 20/11','SMS'),
(1,NULL,1,'CLIMA','ALTA','Se esperan lluvias fuertes en su zona','SMS');

INSERT INTO Publicacion (idUsuario, titulo, tema, descripcion) VALUES
(3,'Como controlar la cochinilla','Control de plagas','Guia corta para agricultores'),
(2,'Mis papas nativas','Cultivo','Fotos y consejos');
INSERT INTO Articulo (idPublicacion, contenido) VALUES (1,'Texto completo del articulo sobre control de cochinilla...');
INSERT INTO Reel (idPublicacion, descripcion, urlVideo, duracionSeg) VALUES (2,'Video corto','https://ejemplo.com/video1.mp4',45);
INSERT INTO Comentario (idPublicacion, idUsuario, contenido) VALUES (1,1,'Muy util, gracias!');
GO

/* ---------- 3. CONSULTAS DE PRUEBA ---------- */

-- a) Usuarios con su rol
SELECT u.nombre, r.nombreRol
FROM Usuario u
JOIN UsuarioRol ur ON ur.idUsuario = u.idUsuario
JOIN Rol r ON r.idRol = ur.idRol;

-- b) Cultivos con parcela y especie
SELECT u.nombre AS propietario, p.nombreParcela, e.nombreComun AS especie, c.fechaSiembra, c.estadoGeneral
FROM Cultivo c
JOIN Usuario u ON u.idUsuario = c.idUsuario
JOIN Parcela p ON p.idParcela = c.idParcela
JOIN EspecieCultivo e ON e.idEspecieCultivo = c.idEspecieCultivo;

-- c) Diagnosticos con su enfermedad (si aplica)
SELECT d.idDiagnostico, e.nombreComun, d.origen, d.necesidadDetectada, en.nombre AS enfermedad
FROM Diagnostico d
JOIN Cultivo c ON c.idCultivo = d.idCultivo
JOIN EspecieCultivo e ON e.idEspecieCultivo = c.idEspecieCultivo
LEFT JOIN Enfermedad en ON en.idEnfermedad = d.idEnfermedad;

-- d) Tareas pendientes
SELECT t.tipo, t.fechaProgramada, cal.nombre AS calendario
FROM TareaProgramada t
JOIN CalendarioAgricola cal ON cal.idCalendarioAgricola = t.idCalendarioAgricola
WHERE t.estado = 'PENDIENTE'
ORDER BY t.fechaProgramada;

-- e) Alertas no leidas por usuario
SELECT u.nombre, a.tipo, a.prioridad, a.mensaje, a.canal
FROM Alerta a
JOIN Usuario u ON u.idUsuario = a.idUsuario
WHERE a.leido = 0;

-- f) Cantidad de comentarios por publicacion
SELECT p.titulo, COUNT(c.idComentario) AS total_comentarios
FROM Publicacion p
LEFT JOIN Comentario c ON c.idPublicacion = p.idPublicacion
GROUP BY p.titulo;
