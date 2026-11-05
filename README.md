# Lobelia - Base de datos

Proyecto del curso **CC52 Ingeniería de Software (UPC)**.
Lobelia es una plataforma híbrida (offline + online) para apoyar a agricultores rurales y aficionados urbanos: diagnóstico de plantas por foto, alertas climáticas por SMS, calendario agrícola y comunidad.

## Contenido

| Archivo | Descripción |
|---|---|
| `Lobelia_Script.sql` | Creación de la BD, 23 tablas, datos de ejemplo y consultas de prueba |
| `docs/` | Diagramas entidad-relación (lógico y físico) |

## Motor de base de datos

SQL Server (elegido por su entorno gráfico, seguridad e integración con herramientas Microsoft).

## Cómo ejecutarlo

1. Abre SQL Server Management Studio (o Azure Data Studio).
2. Abre `Lobelia_Script.sql`.
3. Ejecútalo completo (F5). Crea la base `Lobelia`, las tablas, inserta datos de ejemplo y corre las consultas.

## Entidades principales

Usuario, Rol, UsuarioRol, DireccionUsuario, Aficionado, Agricultor, Experto, Publicación, Comentario, Reel, Artículo, Parcela, EspecieCultivo, Cultivo, SensorIoT, LecturaSensor, Diagnóstico, Enfermedad, IncidenciaCultivo, CalendarioAgrícola, TareaProgramada, Alerta y Clima.

## Equipo

Integrantes del proyecto Lobelia, UPC - Ciclo 2025-20.
