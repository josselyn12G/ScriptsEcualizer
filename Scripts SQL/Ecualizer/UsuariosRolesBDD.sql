-- ====================================================
--              Creación de Login
-- ====================================================
USE master;
GO

-- Login para el Administrador de Base de Datos.
-- Este login será utilizado por el perfil técnico encargado de administrar
-- la base de datos a nivel estructural y de seguridad.
CREATE LOGIN login_AdminDB
    WITH PASSWORD = 'Admin@Ecualizer2026!',
    CHECK_POLICY = ON,
    CHECK_EXPIRATION = ON;
GO

-- Login para el sistema / aplicación web.
-- Este login será utilizado por la aplicación para conectarse a la base de datos
-- y ejecutar los procesos generales del sistema.
CREATE LOGIN login_Sistema
    WITH PASSWORD = 'Sistema@Ecualizer2026!',
    CHECK_POLICY = ON,
    CHECK_EXPIRATION = OFF;
GO

-- Login para el perfil Oyente.
-- Representa el acceso funcional para usuarios con perfil de oyente.
CREATE LOGIN login_Oyente
    WITH PASSWORD = 'Oyente@Ecualizer2026!',
    CHECK_POLICY = ON,
    CHECK_EXPIRATION = OFF;
GO

-- Login para el perfil Artista.
-- Representa el acceso funcional para usuarios con perfil de artista.
CREATE LOGIN login_Artista
    WITH PASSWORD = 'Artista@Ecualizer2026!',
    CHECK_POLICY = ON,
    CHECK_EXPIRATION = OFF;
GO

-- Login para el Administrador de la aplicación.
-- Este login representa al usuario funcional que administra procesos
-- dentro del sistema Ecualizer, no la base de datos como tal.
CREATE LOGIN login_Administrador
    WITH PASSWORD = 'Admin@Sistema2025!',
    CHECK_POLICY = ON,
    CHECK_EXPIRATION = ON;
GO

-- Login para el perfil de Reportes.
-- Este login será utilizado por usuarios que necesitan consultar información
-- para análisis, reportes administrativos y seguimiento del sistema.
CREATE LOGIN login_Reportes
    WITH PASSWORD = 'Reportes@Ecualizer2026!',
    CHECK_POLICY = ON,
    CHECK_EXPIRATION = OFF;
GO

-- ====================================================
--              Creación de Usuarios
-- ====================================================
USE Ecualizer;
GO

-- Usuario administrador de base de datos.
-- Se asocia al login_AdminDB y tendrá permisos elevados mediante db_owner.
CREATE USER user_AdminDB
    FOR LOGIN login_AdminDB
    WITH DEFAULT_SCHEMA = dbo;
GO

-- Usuario técnico usado por el sistema / aplicación web.
-- Se asocia al login_Sistema y será utilizado por la aplicación para operar
-- sobre la base de datos.
CREATE USER user_Sistema
    FOR LOGIN login_Sistema
    WITH DEFAULT_SCHEMA = dbo;
GO

-- Usuario asociado al perfil funcional Oyente.
-- Se asocia al login_Oyente y su esquema predeterminado es Biblioteca,
-- porque el oyente interactúa principalmente con playlists, favoritos y biblioteca.
CREATE USER user_Oyente
    FOR LOGIN login_Oyente
    WITH DEFAULT_SCHEMA = Biblioteca;
GO

-- Usuario asociado al perfil funcional Artista.
-- Se asocia al login_Artista y su esquema predeterminado es Catalogo,
-- porque el artista gestiona principalmente canciones, álbumes y contenido musical.
CREATE USER user_Artista
    FOR LOGIN login_Artista
    WITH DEFAULT_SCHEMA = Catalogo;
GO

-- Usuario asociado al perfil funcional Administrador de la aplicación.
-- Se asocia al login_Administrador y su esquema predeterminado es Usuario,
-- porque administra cuentas, perfiles y procesos funcionales del sistema.
CREATE USER user_Administrador
    FOR LOGIN login_Administrador
    WITH DEFAULT_SCHEMA = Usuario;
GO

-- Usuario asociado al perfil de Reportes.
-- Se asocia al login_Reportes y su esquema predeterminado es Analitica,
-- porque su función principal es consultar información para reportes.
CREATE USER user_Reportes
    FOR LOGIN login_Reportes
    WITH DEFAULT_SCHEMA = Analitica;
GO

-- ====================================================
--              Creación de Roles
-- ====================================================

-- Rol técnico utilizado por la aplicación web para ejecutar procesos generales.
CREATE ROLE RolSistema;
GO

-- Rol funcional para usuarios con perfil Oyente.
CREATE ROLE RolOyente;
GO

-- Rol funcional para usuarios con perfil Artista.
CREATE ROLE RolArtista;
GO

-- Rol funcional para administradores de la aplicación Ecualizer.
CREATE ROLE RolAdministrador;
GO

-- Rol funcional para usuarios de consulta y generación de reportes.
CREATE ROLE RolReportes;
GO


-- ====================================================
--             Otorgar permisos a cada rol
-- ====================================================

------------------------------------------------------------
-- PERMISOS PARA EL ROL: RolReportes
------------------------------------------------------------

-- Lectura del catálogo musical.
GRANT SELECT ON SCHEMA::Catalogo TO RolReportes;
GO

-- Lectura de información analítica: reproducciones, regalías y tendencias.
GRANT SELECT ON SCHEMA::Analitica TO RolReportes;
GO

-- Lectura de información de biblioteca para reportes de playlists, likes y álbumes guardados.
GRANT SELECT ON SCHEMA::Biblioteca TO RolReportes;
GO

-- Lectura de pagos y suscripciones para reportes administrativos.
GRANT SELECT ON SCHEMA::Pagos TO RolReportes;
GO

-- Lectura de contratos y discográficas para reportes de industria.
GRANT SELECT ON SCHEMA::Industria TO RolReportes;
GO

-- Lectura de usuarios para reportes administrativos.
GRANT SELECT ON SCHEMA::Usuario TO RolReportes;
GO

------------------------------------------------------------
-- PERMISOS PARA EL ROL: RolOyente
------------------------------------------------------------


-- El oyente puede explorar todo el catálogo musical:
-- álbumes, canciones, géneros, artistas y tipos de álbum.
GRANT SELECT ON SCHEMA::Catalogo TO RolOyente;
GO

-- El oyente puede consultar los planes disponibles
-- antes de elegir o renovar su suscripción.
GRANT SELECT ON Pagos.TipoPlan TO RolOyente;
GO

-- El oyente puede consultar el historial de sus suscripciones.
-- La aplicación debe filtrar la información por el usuario autenticado.
GRANT SELECT ON Pagos.Suscripcion TO RolOyente;
GO

-- El oyente puede consultar el historial de sus pagos.
-- La aplicación debe filtrar la información por el usuario autenticado.
GRANT SELECT ON Pagos.Pago TO RolOyente;
GO

-- El oyente puede consultar, crear, editar y eliminar sus playlists.
GRANT SELECT, INSERT, UPDATE, DELETE
    ON Biblioteca.Playlist TO RolOyente;
GO

-- El oyente puede asociarse a playlists como creador o colaborador.
-- La actualización se usa para cambios controlados en la relación,
-- según las reglas de playlists colaborativas.
GRANT SELECT, INSERT, UPDATE, DELETE
    ON Biblioteca.UsuarioPlaylist TO RolOyente;
GO

-- El oyente puede agregar, quitar y reorganizar canciones
-- dentro de sus playlists, actualizando posicionPlaylist.
GRANT SELECT, INSERT, UPDATE, DELETE
    ON Biblioteca.CancionPlaylist TO RolOyente;
GO

-- El oyente puede dar like y quitar like a canciones.
-- No se permite UPDATE porque un like no se edita, solo se crea o elimina.
GRANT SELECT, INSERT, DELETE
    ON Biblioteca.UsuarioCancionLike TO RolOyente;
GO

-- El oyente puede guardar y eliminar álbumes de su biblioteca personal.
-- No se permite UPDATE porque la relación no tiene atributos editables.
GRANT SELECT, INSERT, DELETE
    ON Biblioteca.UsuarioAlbum TO RolOyente;
GO

-- El oyente puede seguir artistas, dejar de seguirlos
-- y modificar el flag de notificaciones.
GRANT SELECT, INSERT, UPDATE, DELETE
    ON Biblioteca.UsuarioSigueArtista TO RolOyente;
GO

-- El oyente puede registrar cada evento de reproducción
-- y consultar su propio historial de escucha.
-- La aplicación debe filtrar el historial por el usuario autenticado.
GRANT SELECT, INSERT
    ON Analitica.Reproduccion TO RolOyente;
GO

------------------------------------------------------------
-- PERMISOS PARA EL ROL: RolArtista
------------------------------------------------------------
-- El artista puede consultar el catálogo musical.
GRANT SELECT ON SCHEMA::Catalogo TO RolArtista;
GO
-- El artista puede publicar y actualizar álbumes.
GRANT INSERT, UPDATE 
ON Catalogo.Album TO RolArtista;
GO
-- El artista puede publicar y actualizar canciones.
GRANT INSERT, UPDATE 
ON Catalogo.Cancion TO RolArtista;
GO
-- El artista puede asociar sus álbumes.
GRANT SELECT, INSERT 
ON Catalogo.ArtistaAlbum TO RolArtista;
GO
-- El artista puede asociar y corregir géneros musicales de sus canciones.
GRANT SELECT, INSERT, DELETE
ON Catalogo.CancionGeneroMusical TO RolArtista;
GO
-- El artista puede consultar reproducciones y regalías.
GRANT SELECT ON SCHEMA::Analitica TO RolArtista;
GO
-- El artista puede consultar sus contratos con discográficas.
GRANT SELECT 
ON Industria.ContratoDiscografica TO RolArtista;
GO
-- El artista puede actualizar su propio perfil artístico:
-- nombre artístico y biografía.
GRANT SELECT, UPDATE ON Usuario.Artista TO RolArtista;
GO

------------------------------------------------------------
-- PERMISOS PARA EL ROL: RolAdministrador
------------------------------------------------------------

-- Gestión de usuarios y perfiles.
GRANT SELECT, INSERT, UPDATE, DELETE 
ON SCHEMA::Usuario TO RolAdministrador;
GO

-- Gestión del catálogo musical.
GRANT SELECT, INSERT, UPDATE, DELETE 
ON SCHEMA::Catalogo TO RolAdministrador;
GO

-- Gestión de biblioteca, playlists, likes y artistas seguidos.
GRANT SELECT, INSERT, UPDATE, DELETE 
ON SCHEMA::Biblioteca TO RolAdministrador;
GO

-- Gestión de suscripciones y pagos.
GRANT SELECT, INSERT, UPDATE, DELETE 
ON SCHEMA::Pagos TO RolAdministrador;
GO

-- Gestión de información analítica.
GRANT SELECT, INSERT, UPDATE, DELETE 
ON SCHEMA::Analitica TO RolAdministrador;
GO

-- Gestión de discográficas y contratos.
GRANT SELECT, INSERT, UPDATE, DELETE 
ON SCHEMA::Industria TO RolAdministrador;
GO

------------------------------------------------------------
-- PERMISOS PARA EL ROL: RolSistema
------------------------------------------------------------

-- El sistema puede consultar el catálogo musical:
-- álbumes, canciones, géneros, artistas y tipos de álbum.
GRANT SELECT ON SCHEMA::Catalogo TO RolSistema;
GO

-- El sistema puede registrar y actualizar usuarios,
-- perfiles de persona, artistas y administradores.
-- No se otorga DELETE para evitar eliminación física de cuentas.
GRANT SELECT, INSERT, UPDATE
ON SCHEMA::Usuario TO RolSistema;
GO

-- El sistema puede gestionar la biblioteca del usuario:
-- playlists, canciones dentro de playlists, likes,
-- álbumes guardados y artistas seguidos.
GRANT SELECT, INSERT, UPDATE, DELETE
ON SCHEMA::Biblioteca TO RolSistema;
GO

-- El sistema puede consultar planes, crear y actualizar suscripciones,
-- y registrar pagos asociados.
-- No se otorga DELETE para mantener trazabilidad financiera.
GRANT SELECT, INSERT, UPDATE
ON SCHEMA::Pagos TO RolSistema;
GO

-- El sistema puede registrar reproducciones y consultar información analítica.
-- También puede actualizar datos analíticos si se recalculan indicadores.
-- No se otorga DELETE para mantener historial.
GRANT SELECT, INSERT, UPDATE
ON SCHEMA::Analitica TO RolSistema;
GO

-- El sistema puede consultar información de discográficas y contratos.
-- Esto permite validar contratos vigentes para cálculo de regalías.
GRANT SELECT
ON SCHEMA::Industria TO RolSistema;
GO

-- ====================================================
--              Asignación de Usuarios a Roles
-- ====================================================

-- El usuario técnico de la aplicación se asigna al rol del sistema.
ALTER ROLE RolSistema ADD MEMBER user_Sistema;
GO

-- El usuario oyente se asigna al rol funcional Oyente.
ALTER ROLE RolOyente ADD MEMBER user_Oyente;
GO

-- El usuario artista se asigna al rol funcional Artista.
ALTER ROLE RolArtista ADD MEMBER user_Artista;
GO

-- El usuario administrador de la aplicación se asigna al rol Administrador.
ALTER ROLE RolAdministrador ADD MEMBER user_Administrador;
GO

-- El usuario de reportes se asigna al rol funcional de Reportes.
ALTER ROLE RolReportes ADD MEMBER user_Reportes;
GO

-- El administrador de base de datos tiene control total sobre la base.
-- Este permiso solo debe otorgarse al administrador técnico de la base de datos.
ALTER ROLE db_owner ADD MEMBER user_AdminDB;
GO

-- ====================================================
--       Verificación de Usuarios, Roles y Permisos
-- ====================================================
-- Verificar logins creados en el servidor
SELECT name, type_desc, is_disabled
FROM sys.server_principals
WHERE name LIKE 'login_%';
GO

-- Verificar usuarios en la base de datos Ecualizer
SELECT name, type_desc, default_schema_name
FROM sys.database_principals
WHERE type IN ('S','U')
  AND name LIKE 'user_%';
GO

-- Verificar membresía de usuarios en roles
SELECT
    r.name  AS Rol,
    m.name  AS Usuario
FROM sys.database_role_members  rm
JOIN sys.database_principals    r ON rm.role_principal_id   = r.principal_id
JOIN sys.database_principals    m ON rm.member_principal_id = m.principal_id
WHERE r.name IN ('RolOyente','RolArtista','RolAdministrador','RolReportes')
ORDER BY r.name;
GO

-- Verificar permisos otorgados por esquema
SELECT
    pr.name         AS Rol,
    pe.state_desc   AS Accion,
    pe.permission_name,
    sch.name        AS Esquema
FROM sys.database_permissions pe
JOIN sys.database_principals  pr  ON pe.grantee_principal_id = pr.principal_id
JOIN sys.schemas              sch ON pe.major_id             = sch.schema_id
WHERE pe.class = 3
ORDER BY pr.name, sch.name;
GO