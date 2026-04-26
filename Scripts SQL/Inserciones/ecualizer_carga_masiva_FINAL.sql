-- ============================================================
--   ECUALIZER – CARGA MASIVA DE DATOS (VERSIÓN CORREGIDA)
--   Base de Datos II  |  ITIZ-2201  |  202620
--   Equipo 6: Freire Adrián, Guevara Josselyn, Anthony Llanos
--   Fecha: 23 de Abril de 2026

-- ============================================================

USE Ecualizer;
GO

SET NOCOUNT ON;



-- ============================================================
-- 1. CATALOGO.TIPOALBUM
-- ============================================================
PRINT '>>> Insertando TipoAlbum...';

SET IDENTITY_INSERT Catalogo.TipoAlbum ON;
INSERT INTO Catalogo.TipoAlbum (idTipoAlbum, nombreTipo) VALUES
(1, 'LP'),
(2, 'EP'),
(3, 'Sencillo'),
(4, 'Álbum en vivo'),
(5, 'Compilación');
SET IDENTITY_INSERT Catalogo.TipoAlbum OFF;

-- ============================================================
-- 2. PAGOS.TIPOPLAN

-- ============================================================
PRINT '>>> Insertando TipoPlan...';

-- TipoPlan también es IDENTITY
SET IDENTITY_INSERT Pagos.TipoPlan ON;
INSERT INTO Pagos.TipoPlan (idTipoPlan, nombrePlan, precio, descripcionPlan, duracion) VALUES
(1, 'Free',        0.00,  'Plan gratuito con anuncios y calidad estándar',          'Mensual'),
(2, 'Individual',  9.99,  'Plan individual sin anuncios, alta calidad',              'Mensual'),
(3, 'Duo',        13.99,  'Plan para dos personas',                                  'Mensual'),
(4, 'Familiar',   17.99,  'Plan para hasta 6 cuentas familiares',                   'Mensual'),
(5, 'Estudiante',  4.99,  'Plan con descuento para estudiantes verificados',         'Mensual');
SET IDENTITY_INSERT Pagos.TipoPlan OFF;

-- ============================================================
-- 3. CATALOGO.GENEROMUSICAL
-- ============================================================
PRINT '>>> Insertando GeneroMusical...';

INSERT INTO Catalogo.GeneroMusical (idGeneroMusical, nombreGenero) VALUES
(1,  'Trap Latino'),
(2,  'Pop'),
(3,  'Rock Alternativo'),
(4,  'Reggaeton'),
(5,  'Flamenco Urbano'),
(6,  'Hip Hop'),
(7,  'Electrónica'),
(8,  'R&B'),
(9,  'Indie Pop'),
(10, 'Latin Pop');

-- ============================================================
-- 4. INDUSTRIA.DISCOGRAFICA
-- ============================================================
PRINT '>>> Insertando Discografica...';

-- Discografica es IDENTITY
SET IDENTITY_INSERT Industria.Discografica ON;
INSERT INTO Industria.Discografica
    (idDiscografica, nombreDiscografica, paisOrigen, correoContacto, telefonoContacto)
VALUES
(1, 'Sony Music Entertainment',   'Estados Unidos', 'contacto@sonymusic.com',     '2125550100'),
(2, 'Universal Music Group',      'Estados Unidos', 'info@universalmusic.com',    '3105550200'),
(3, 'Warner Music Group',         'Estados Unidos', 'contacto@warnermusic.com',   '2125550300'),
(4, 'BMG Rights Management',      'Alemania',       'rights@bmg.com',             '4930550400'),
(5, 'Interscope Records',         'Estados Unidos', 'interscope@interscope.com',  '3105550500');
SET IDENTITY_INSERT Industria.Discografica OFF;

-- ============================================================
-- 5. USUARIO.PERSONA  (20 registros: 5 artistas + 13 oyentes + 2 admins)
-- ============================================================
PRINT '>>> Insertando Persona...';

INSERT INTO Usuario.Persona
    (idUsuario, alias, paisUsuario, fechaNacimiento, genero, idTipoPlan)
VALUES
-- Artistas (idUsuario 1-5): se les asigna plan Free (1) como base
(1,  'duki_arg',       'Argentina',      '1996-08-29', 'M', 1),
(2,  'rosalia_oficial','España',         '1992-09-25', 'F', 1),
(3,  'arcticmonkeys',  'Reino Unido',    '1985-10-09', 'M', 1),
(4,  'bad_bunny',      'Puerto Rico',    '1994-03-10', 'M', 1),
(5,  'karol_g',        'Colombia',       '1990-02-14', 'F', 1),
-- Oyentes (idUsuario 6-18)
(6,  'mario.lp',       'Ecuador',        '2001-03-15', 'M', 2),
(7,  'sofia.qs',       'Ecuador',        '1999-07-22', 'F', 3),
(8,  'carlos.rm',      'Colombia',       '2000-11-05', 'M', 2),
(9,  'lucia.va',       'México',         '1998-04-30', 'F', 4),
(10, 'andres.tp',      'Perú',           '2003-09-12', 'M', 2),
(11, 'valeria.gm',     'Chile',          '1997-06-18', 'F', 2),
(12, 'daniel.fc',      'Venezuela',      '2002-01-25', 'M', 1),
(13, 'isabella.sr',    'Argentina',      '2000-12-08', 'F', 5),
(14, 'miguel.hn',      'España',         '1995-05-14', 'M', 1),
(15, 'camila.or',      'Ecuador',        '2001-08-27', 'F', 3),
(16, 'sebastian.vz',   'Bolivia',        '1999-02-03', 'M', 2),
(17, 'natalia.cb',     'Uruguay',        '2004-10-19', 'F', 2),
(18, 'josue.pm',       'Paraguay',       '1996-07-31', 'M', 2),
-- Administradores (idUsuario 19-20)
(19, 'admin.general',  'Ecuador',        '1985-03-10', 'M', 1),
(20, 'admin.content',  'Ecuador',        '1990-06-25', 'F', 1);

-- ============================================================
-- 6. USUARIO.ARTISTA
-- ============================================================
PRINT '>>> Insertando Artista...';

INSERT INTO Usuario.Artista (idUsuario, nombreArtistico, biografia)
VALUES
(1, 'Duki',
   'Mauro Ezequiel Lombardo, conocido como Duki, es un rapero y cantante argentino pionero del trap latino en Latinoamérica. Inició su carrera en 2016 y rápidamente se convirtió en referente del género.'),
(2, 'Rosalía',
   'Rosalía Vila Tobella es una cantante y compositora española que fusiona el flamenco tradicional con géneros urbanos contemporáneos. Ganadora de múltiples Grammy Latinos.'),
(3, 'Arctic Monkeys',
   'Banda de rock alternativo originaria de Sheffield, Inglaterra, formada en 2002. Conocidos por álbumes icónicos como AM y Whatever People Say I Am, That s What I m Not.'),
(4, 'Bad Bunny',
   'Benito Antonio Martínez Ocasio, conocido como Bad Bunny, es un cantante y compositor puertorriqueño. Es uno de los artistas de reggaeton y trap latino más influyentes del mundo.'),
(5, 'Karol G',
   'Carolina Giraldo Navarro, conocida como Karol G, es una cantante colombiana de música urbana y reggaeton. Ha sido reconocida como una de las artistas femeninas más importantes del género.');

-- ============================================================
-- 7. USUARIO.USUARIO (oyentes)
-- ============================================================
PRINT '>>> Insertando Usuario (oyentes)...';

-- Usuario es IDENTITY; insertar con IDENTITY_INSERT
SET IDENTITY_INSERT Usuario.Usuario ON;
INSERT INTO Usuario.Usuario (idUsuario, correo, contrasena, estado, fechaRegistro,
                              cedulaUsuario, primerNombre, primerApellido)
VALUES
(6,  'mario.lp@gmail.com',     '$2a$10$aK9Lm1XqZ8vN3pR7sT2uOeY4bW5cD6fG',  'activo',    '2023-01-15', '1700000006', 'Mario',     'López'),
(7,  'sofia.qs@hotmail.com',   '$2a$10$bL0Mn2YrA9wO4qS8tU3vPfZ5cX6dE7gH',  'activo',    '2023-02-20', '1700000007', 'Sofia',     'Quiroz'),
(8,  'carlos.rm@gmail.com',    '$2a$10$cM1No3ZsB0xP5rT9uV4wQgA6dY7eF8hI',  'activo',    '2023-03-10', '1700000008', 'Carlos',    'Ramírez'),
(9,  'lucia.va@outlook.com',   '$2a$10$dN2Op4AtC1yQ6sU0vW5xRhB7eZ8fG9iJ',  'activo',    '2023-04-05', '1700000009', 'Lucía',     'Vargas'),
(10, 'andres.tp@gmail.com',    '$2a$10$eO3Pq5BuD2zA7tV1wX6ySiC8fA0gH0jK',  'activo',    '2023-05-18', '1700000010', 'Andrés',    'Torres'),
(11, 'valeria.gm@gmail.com',   '$2a$10$fP4Qr6CvE3AB8uW2xY7zTjD9gB1hI1kL',  'activo',    '2023-06-22', '1700000011', 'Valeria',   'García'),
(12, 'daniel.fc@yahoo.com',    '$2a$10$gQ5Rs7DwF4BC9vX3yZ8AUkE0hC2iJ2lM',  'activo',    '2023-07-30', '1700000012', 'Daniel',    'Flores'),
(13, 'isabella.sr@gmail.com',  '$2a$10$hR6St8ExG5CD0wY4zA9BVlF1iD3jK3mN',  'activo',    '2023-08-14', '1700000013', 'Isabella',  'Soto'),
(14, 'miguel.hn@gmail.com',    '$2a$10$iS7Tu9FyH6DE1xZ5AB0CWmG2jE4kL4nO',  'inactivo',  '2023-09-01', '1700000014', 'Miguel',    'Hernández'),
(15, 'camila.or@hotmail.com',  '$2a$10$jT8Uv0GzI7EF2yA6BC1DXnH3kF5lM5oP',  'activo',    '2023-10-07', '1700000015', 'Camila',    'Ortega'),
(16, 'sebastian.vz@gmail.com', '$2a$10$kU9Vw1HaJ8FG3zB7CD2EYoI4lG6mN6pQ',  'activo',    '2023-11-19', '1700000016', 'Sebastián', 'Vásquez'),
(17, 'natalia.cb@gmail.com',   '$2a$10$lV0Wx2IbK9GH4AC8DE3FZpJ5mH7nO7qR',  'activo',    '2024-01-08', '1700000017', 'Natalia',   'Castro'),
(18, 'josue.pm@outlook.com',   '$2a$10$mW1Xy3JcL0HI5BD9EF4GAqK6nI8oP8rS',  'activo',    '2024-02-14', '1700000018', 'Josué',     'Paredes');
SET IDENTITY_INSERT Usuario.Usuario OFF;

-- ============================================================
-- 8. USUARIO.ADMINISTRADOR
-- ============================================================
PRINT '>>> Insertando Administrador...';

INSERT INTO Usuario.Administrador (idUsuario, rolAdmin, departamento)
VALUES
(19, 'Administrador general',  'Tecnología'),
(20, 'Moderador de contenido', 'Contenido');

-- ============================================================
-- 9. CATALOGO.ALBUM

-- ============================================================
PRINT '>>> Insertando Album...';

SET IDENTITY_INSERT Catalogo.Album ON;
INSERT INTO Catalogo.Album
    (idAlbum, tituloAlbum, fechaLanzamientoAlbum, descripcionAlbum, estadoAlbum, TipoAlbum_idTipoAlbum)
VALUES
(1,  'Super Sangre Joven',      '2018-09-21', 'Álbum debut de Duki que consolidó el trap latino en Argentina.',                       'activo', 1),
(2,  'Desde el Fin del Mundo',  '2021-11-05', 'Segundo álbum de Duki con colaboraciones internacionales de alto perfil.',             'activo', 1),
(3,  'El Mal Querer',           '2018-11-02', 'Álbum conceptual de Rosalía que reimagina el flamenco en clave moderna.',             'activo', 1),
(4,  'MOTOMAMI',                '2022-03-18', 'Tercer álbum de Rosalía, ganador del Grammy al Mejor Álbum de Música Urbana.',         'activo', 1),
(5,  'AM',                      '2013-09-09', 'Quinto álbum de Arctic Monkeys, uno de los más influyentes del rock moderno.',         'activo', 1),
(6,  'The Car',                 '2022-10-21', 'Séptimo álbum de Arctic Monkeys con sonido orquestal y sofisticado.',                  'activo', 1),
(7,  'Un Verano Sin Ti',        '2022-05-06', 'Álbum de Bad Bunny que batió récords en plataformas de streaming globales.',           'activo', 1),
(8,  'nadie sabe lo que va a pasar mañana', '2023-10-13', 'Álbum introspectivo de Bad Bunny con influencias de trap y perreo.',      'activo', 1),
(9,  'MAÑANA SERÁ BONITO',      '2023-02-24', 'Álbum de Karol G que debutó en el número 1 del Billboard 200.',                       'activo', 1),
(10, 'Bichota Season',          '2021-12-03', 'EP navideño de Karol G que incluye colaboraciones con grandes del reggaeton.',         'activo', 2);
SET IDENTITY_INSERT Catalogo.Album OFF;

-- ============================================================
-- 10. CATALOGO.ARTISTAALBUM
-- ============================================================
PRINT '>>> Insertando ArtistaAlbum...';

INSERT INTO Catalogo.ArtistaAlbum (Artista_idUsuario, Album_idAlbum, fechaPublicacion)
VALUES
(1, 1, '2018-09-21'),   -- Duki -> Super Sangre Joven
(1, 2, '2021-11-05'),   -- Duki -> Desde el Fin del Mundo
(2, 3, '2018-11-02'),   -- Rosalía -> El Mal Querer
(2, 4, '2022-03-18'),   -- Rosalía -> MOTOMAMI
(3, 5, '2013-09-09'),   -- Arctic Monkeys -> AM
(3, 6, '2022-10-21'),   -- Arctic Monkeys -> The Car
(4, 7, '2022-05-06'),   -- Bad Bunny -> Un Verano Sin Ti
(4, 8, '2023-10-13'),   -- Bad Bunny -> nadie sabe...
(5, 9, '2023-02-24'),   -- Karol G -> MAÑANA SERÁ BONITO
(5,10, '2021-12-03');   -- Karol G -> Bichota Season

-- ============================================================
-- 11. CATALOGO.CANCION  (50 canciones, ~5 por álbum)
-- ============================================================
PRINT '>>> Insertando Cancion...';

SET IDENTITY_INSERT Catalogo.Cancion ON;
INSERT INTO Catalogo.Cancion
    (idCancion, nombreCancion, duracion, calidadKbps, numeroPista,
     totalReproducciones, estadoCancion, Album_idAlbum, fechaLanzamiento)
VALUES
-- Album 1: Super Sangre Joven (Duki) — lanzamiento: 2018-09-21
(1,  'Rockstar',                 198, 320, 1, 85000000,  'activa', 1, '2018-09-21'),
(2,  'Loca',                     204, 320, 2, 72000000,  'activa', 1, '2018-09-21'),
(3,  'Set',                      186, 320, 3, 68000000,  'activa', 1, '2018-09-21'),
(4,  'No Salgas',                192, 256, 4, 54000000,  'activa', 1, '2018-09-21'),
(5,  'Mucho Más',                210, 320, 5, 61000000,  'activa', 1, '2018-09-21'),
-- Album 2: Desde el Fin del Mundo (Duki) — lanzamiento: 2021-11-05
(6,  'She Don''t Give a Fo',    223, 320, 1, 120000000, 'activa', 2, '2021-11-05'),
(7,  'Goteo',                    195, 320, 2, 95000000,  'activa', 2, '2021-11-05'),
(8,  'Primer Tiempo',            241, 256, 3, 78000000,  'activa', 2, '2021-11-05'),
(9,  'Luna Llena',               205, 320, 4, 83000000,  'activa', 2, '2021-11-05'),
(10, 'Desde el Fin del Mundo',   268, 320, 5, 67000000,  'activa', 2, '2021-11-05'),
-- Album 3: El Mal Querer (Rosalía) — lanzamiento: 2018-11-02
(11, 'Malamente',                183, 320, 1, 95000000,  'activa', 3, '2018-11-02'),
(12, 'Que No Salga la Luna',     214, 320, 2, 77000000,  'activa', 3, '2018-11-02'),
(13, 'Pienso en Tu Mirá',        226, 256, 3, 110000000, 'activa', 3, '2018-11-02'),
(14, 'De Aquí No Sales',         198, 320, 4, 68000000,  'activa', 3, '2018-11-02'),
(15, 'Bagdad',                   391, 320, 5, 82000000,  'activa', 3, '2018-11-02'),
-- Album 4: MOTOMAMI (Rosalía) — lanzamiento: 2022-03-18
(16, 'Saoko',                    156, 320, 1, 145000000, 'activa', 4, '2022-03-18'),
(17, 'Candy',                    178, 320, 2, 132000000, 'activa', 4, '2022-03-18'),
(18, 'Bizcochito',               136, 320, 3, 118000000, 'activa', 4, '2022-03-18'),
(19, 'Chicken Teriyaki',         131, 256, 4, 98000000,  'activa', 4, '2022-03-18'),
(20, 'Despechá',                 148, 320, 5, 178000000, 'activa', 4, '2022-03-18'),
-- Album 5: AM (Arctic Monkeys) — lanzamiento: 2013-09-09
(21, 'Do I Wanna Know?',         341, 320, 1, 420000000, 'activa', 5, '2013-09-09'),
(22, 'R U Mine?',                203, 320, 2, 310000000, 'activa', 5, '2013-09-09'),
(23, 'One for the Road',         237, 320, 3, 185000000, 'activa', 5, '2013-09-09'),
(24, 'Arabella',                 212, 256, 4, 172000000, 'activa', 5, '2013-09-09'),
(25, 'Why''d You Only Call Me When You''re High?', 163, 320, 5, 290000000, 'activa', 5, '2013-09-09'),
-- Album 6: The Car (Arctic Monkeys) — lanzamiento: 2022-10-21
(26, 'There''d Better Be a Mirrorball', 303, 320, 1, 88000000, 'activa', 6, '2022-10-21'),
(27, 'I Ain''t Quite Where I Think I Am', 254, 320, 2, 71000000, 'activa', 6, '2022-10-21'),
(28, 'Sculptures of Anything Goes', 237, 256, 3, 59000000, 'activa', 6, '2022-10-21'),
(29, 'Body Paint',              340, 320, 4, 95000000,  'activa', 6, '2022-10-21'),
(30, 'The Car',                  271, 320, 5, 67000000,  'activa', 6, '2022-10-21'),
-- Album 7: Un Verano Sin Ti (Bad Bunny) — lanzamiento: 2022-05-06
(31, 'Moscow Mule',              355, 320, 1, 320000000, 'activa', 7, '2022-05-06'),
(32, 'Tití Me Preguntó',         248, 320, 2, 390000000, 'activa', 7, '2022-05-06'),
(33, 'Me Porto Bonito',          178, 320, 3, 430000000, 'activa', 7, '2022-05-06'),
(34, 'Ojitos Lindos',            314, 256, 4, 280000000, 'activa', 7, '2022-05-06'),
(35, 'Un Verano Sin Ti',         326, 320, 5, 215000000, 'activa', 7, '2022-05-06'),
-- Album 8: nadie sabe... (Bad Bunny) — lanzamiento: 2023-10-13
(36, 'EL APAGÓN',                476, 320, 1, 195000000, 'activa', 8, '2023-10-13'),
(37, 'WHERE SHE GOES',           175, 320, 2, 340000000, 'activa', 8, '2023-10-13'),
(38, 'COCO CHANEL',              217, 256, 3, 145000000, 'activa', 8, '2023-10-13'),
(39, 'HIBIKI',                   254, 320, 4, 98000000,  'activa', 8, '2023-10-13'),
(40, 'THUNDER Y LIGHTNING',      196, 320, 5, 112000000, 'activa', 8, '2023-10-13'),
-- Album 9: MAÑANA SERÁ BONITO (Karol G) — lanzamiento: 2023-02-24
(41, 'PROVENZA',                 207, 320, 1, 285000000, 'activa', 9, '2023-02-24'),
(42, 'TQG',                      186, 320, 2, 410000000, 'activa', 9, '2023-02-24'),
(43, 'Cairo',                    210, 256, 3, 198000000, 'activa', 9, '2023-02-24'),
(44, 'QLONA',                    185, 320, 4, 165000000, 'activa', 9, '2023-02-24'),
(45, 'AMARGURA',                 228, 320, 5, 142000000, 'activa', 9, '2023-02-24'),
-- Album 10: Bichota Season (Karol G) — lanzamiento: 2021-12-03
(46, 'Bichota',                  194, 320, 1, 320000000, 'activa', 10, '2021-12-03'),
(47, 'El Makinon',               218, 320, 2, 195000000, 'activa', 10, '2021-12-03'),
(48, 'Ay Dios Mío',              185, 256, 3, 143000000, 'activa', 10, '2021-12-03'),
(49, 'Mi Cama',                  232, 320, 4, 178000000, 'activa', 10, '2021-12-03'),
(50, 'Pineapple',                197, 320, 5, 98000000,  'activa', 10, '2021-12-03');
SET IDENTITY_INSERT Catalogo.Cancion OFF;

-- ============================================================
-- 12. CATALOGO.CANCIONGENEROMUSICAL
-- ============================================================
PRINT '>>> Insertando CancionGeneroMusical...';

INSERT INTO Catalogo.CancionGeneroMusical (Cancion_idCancion, GeneroMusical_idGeneroMusical)
VALUES
-- Duki (Trap Latino + Hip Hop)
(1,1),(1,6), (2,1),(2,6), (3,1), (4,1), (5,1),
(6,1),(6,6), (7,1), (8,1), (9,1), (10,1),
-- Rosalía (Flamenco Urbano + Pop)
(11,5),(11,2), (12,5), (13,5),(13,2), (14,5), (15,5),
(16,5),(16,4), (17,2), (18,4), (19,4), (20,4),(20,2),
-- Arctic Monkeys (Rock Alternativo + Indie Pop)
(21,3),(21,9), (22,3), (23,3), (24,3),(24,9), (25,3),
(26,3),(26,9), (27,3), (28,3), (29,3), (30,3),
-- Bad Bunny (Reggaeton + Trap Latino + Latin Pop)
(31,4),(31,1), (32,4), (33,4),(33,10), (34,4), (35,4),
(36,1),(36,6), (37,1),(37,4), (38,4), (39,7), (40,4),
-- Karol G (Reggaeton + Latin Pop)
(41,4),(41,10), (42,4),(42,10), (43,4), (44,4), (45,4),
(46,4),(46,10), (47,4), (48,4), (49,4), (50,4);

-- ============================================================
-- 13. INDUSTRIA.CONTRATODISCOGRAFICA
-- ============================================================
PRINT '>>> Insertando ContratoDiscografica...';

SET IDENTITY_INSERT Industria.ContratoDiscografica ON;
INSERT INTO Industria.ContratoDiscografica
    (Artista_idUsuario, Discografica_idDiscografica, idContrato,
     porcentajeArtista, porcentajeDiscografica,
     fechaInicio, fechaFin, estadoContrato)
VALUES
(1, 1, 1, 18.00, 82.00, '2017-06-01', '2025-05-31', 'Activo'),
(1, 1, 2, 22.00, 78.00, '2025-06-01', '2030-05-31', 'Activo'),
(2, 2, 1, 25.00, 75.00, '2017-01-15', '2023-01-14', 'Finalizado'),
(2, 2, 2, 30.00, 70.00, '2023-01-15', '2028-01-14', 'Activo'),
(3, 3, 1, 20.00, 80.00, '2006-07-01', '2016-06-30', 'Finalizado'),
(3, 3, 2, 25.00, 75.00, '2016-07-01', '2026-06-30', 'Activo'),
(4, 1, 1, 35.00, 65.00, '2016-05-01', '2022-04-30', 'Finalizado'),
(4, 4, 1, 40.00, 60.00, '2022-05-01', '2027-04-30', 'Activo'),
(5, 2, 1, 28.00, 72.00, '2015-03-01', '2021-02-28', 'Finalizado'),
(5, 5, 1, 35.00, 65.00, '2021-03-01', '2026-02-28', 'Activo');
SET IDENTITY_INSERT Industria.ContratoDiscografica OFF;

-- ============================================================
-- 14. BIBLIOTECA.PLAYLIST  (8 playlists)
-- ============================================================
PRINT '>>> Insertando Playlist...';

SET IDENTITY_INSERT Biblioteca.Playlist ON;
INSERT INTO Biblioteca.Playlist
    (idPlaylist, nombrePlaylist, descripcionPlaylist, tipoVisibilidad, tipoPlaylist)
VALUES
(1, 'Mis Favoritas',              'Canciones favoritas de todos los tiempos',          'Publica',  'Personal'),
(2, 'Workout Mix 2024',           'Playlist energética para el gimnasio',              'Publica',  'Personal'),
(3, 'Tarde de Lluvia',            'Canciones tranquilas para días lluviosos',          'Privada',  'Personal'),
(4, 'Fiesta Latina',              'Los mejores reggaetoneros para la fiesta',          'Publica',  'Colaborativa'),
(5, 'Indie Vibes',                'Lo mejor del indie y rock alternativo',             'Publica',  'Personal'),
(6, 'Top Hits Globales',          'Las canciones más escuchadas del mundo',            'Publica',  'Colaborativa'),
(7, 'Estudio Profundo',           'Música instrumental y ambiental para estudiar',     'Privada',  'Personal'),
(8, 'Trap en Español',            'Lo mejor del trap y rap en castellano',             'Publica',  'Personal');
SET IDENTITY_INSERT Biblioteca.Playlist OFF;

-- ============================================================
-- 15. BIBLIOTECA.CANCIONPLAYLIST
-- ============================================================
PRINT '>>> Insertando CancionPlaylist...';

INSERT INTO Biblioteca.CancionPlaylist
    (Playlist_idPlaylist, Cancion_idCancion, posicionPlaylist, fechaAgregada)
VALUES
-- Playlist 1: Mis Favoritas
(1, 21, 1, '2024-01-10'), (1, 33, 2, '2024-01-10'), (1, 42, 3, '2024-01-11'),
(1, 20, 4, '2024-01-12'), (1,  6, 5, '2024-01-15'),
-- Playlist 2: Workout Mix
(2, 16, 1, '2024-02-01'), (2, 32, 2, '2024-02-01'), (2, 46, 3, '2024-02-02'),
(2, 22, 4, '2024-02-03'), (2,  1, 5, '2024-02-05'),
-- Playlist 3: Tarde de Lluvia
(3, 15, 1, '2024-03-05'), (3, 29, 2, '2024-03-05'), (3, 13, 3, '2024-03-06'),
-- Playlist 4: Fiesta Latina
(4, 31, 1, '2024-03-15'), (4, 41, 2, '2024-03-15'), (4, 49, 3, '2024-03-16'),
(4, 33, 4, '2024-03-17'), (4, 42, 5, '2024-03-18'),
-- Playlist 5: Indie Vibes
(5, 21, 1, '2024-04-01'), (5, 26, 2, '2024-04-01'), (5, 25, 3, '2024-04-02'),
-- Playlist 6: Top Hits
(6, 37, 1, '2024-04-10'), (6, 33, 2, '2024-04-10'), (6, 42, 3, '2024-04-11'),
(6, 20, 4, '2024-04-12'), (6, 21, 5, '2024-04-13'),
-- Playlist 7: Estudio
(7, 30, 1, '2024-05-01'), (7, 15, 2, '2024-05-01'),
-- Playlist 8: Trap en Español
(8,  1, 1, '2024-05-10'), (8,  6, 2, '2024-05-10'), (8,  7, 3, '2024-05-11'),
(8,  9, 4, '2024-05-12'), (8, 36, 5, '2024-05-13');

-- ============================================================
-- 16. BIBLIOTECA.USUARIOPLAYLIST
-- ============================================================
PRINT '>>> Insertando UsuarioPlaylist...';

INSERT INTO Biblioteca.UsuarioPlaylist
    (Usuario_idUsuario, Playlist_idPlaylist, rolPlaylist)
VALUES
(6,  1, 'Creador'),    (7,  1, 'Colaborador'),
(6,  2, 'Creador'),
(7,  3, 'Creador'),
(8,  4, 'Creador'),    (9,  4, 'Colaborador'), (10, 4, 'Colaborador'),
(11, 5, 'Creador'),
(12, 6, 'Creador'),    (13, 6, 'Colaborador'),
(15, 7, 'Creador'),
(16, 8, 'Creador'),    (18, 8, 'Colaborador');

-- ============================================================
-- 17. BIBLIOTECA.USUARIOALBUM
-- ============================================================
PRINT '>>> Insertando UsuarioAlbum...';

INSERT INTO Biblioteca.UsuarioAlbum
    (Usuario_idUsuario, Album_idAlbum, fechaGuardado)
VALUES
(6,  7, '2024-01-05'),  (6,  9, '2024-01-20'),
(7,  3, '2024-02-10'),  (7,  4, '2024-02-11'),
(8,  7, '2024-02-15'),  (8,  8, '2024-03-01'),
(9,  9, '2024-03-05'),  (9, 10, '2024-03-06'),
(10, 5, '2024-03-10'),  (10, 6, '2024-03-11'),
(11, 5, '2024-04-01'),
(12, 1, '2024-04-05'),  (12, 2, '2024-04-06'),
(13, 9, '2024-04-10'),
(15, 4, '2024-05-01'),  (15, 3, '2024-05-02'),
(16, 1, '2024-05-10'),  (16, 2, '2024-05-11'),
(17, 9, '2024-05-20'),
(18, 7, '2024-06-01');

-- ============================================================
-- 18. BIBLIOTECA.USUARIOCANCIONLIKE
-- ============================================================
PRINT '>>> Insertando UsuarioCancionLike...';

INSERT INTO Biblioteca.UsuarioCancionLike
    (Usuario_idUsuario, Cancion_idCancion, fechaLike)
VALUES
(6,  21, '2024-01-10 20:15:00'), (6,  33, '2024-01-11 18:30:00'),
(6,  42, '2024-01-15 21:00:00'), (6,  20, '2024-02-01 10:00:00'),
(7,  13, '2024-02-10 19:45:00'), (7,  16, '2024-02-11 20:00:00'),
(7,  20, '2024-03-01 22:30:00'),
(8,  31, '2024-02-15 17:00:00'), (8,  33, '2024-03-01 21:15:00'),
(9,  41, '2024-03-05 16:30:00'), (9,  42, '2024-03-06 20:00:00'),
(10, 21, '2024-03-10 14:00:00'), (10, 22, '2024-03-11 15:30:00'),
(11, 25, '2024-04-01 11:00:00'), (11, 26, '2024-04-02 12:00:00'),
(12,  1, '2024-04-05 20:00:00'), (12,  6, '2024-04-06 21:00:00'),
(13, 42, '2024-04-10 19:00:00'), (13, 44, '2024-04-11 20:30:00'),
(15,  3, '2024-05-01 18:00:00'), (15, 17, '2024-05-02 19:00:00'),
(16,  7, '2024-05-10 20:00:00'), (16,  9, '2024-05-12 21:00:00'),
(17, 41, '2024-05-20 17:30:00'), (17, 43, '2024-05-21 18:00:00'),
(18, 32, '2024-06-01 22:00:00');

-- ============================================================
-- 19. BIBLIOTECA.USUARIOSIGUEARTISTA
-- ============================================================
PRINT '>>> Insertando UsuarioSigueArtista...';

INSERT INTO Biblioteca.UsuarioSigueArtista
    (Usuario_idUsuario, Artista_idUsuario, notificacionesActivas)
VALUES
(6,  1, 'A'), (6,  4, 'A'), (6,  5, 'D'),
(7,  2, 'A'), (7,  5, 'A'),
(8,  4, 'A'), (8,  1, 'D'),
(9,  5, 'A'), (9,  2, 'A'),
(10, 3, 'A'), (10, 1, 'D'),
(11, 3, 'A'), (11, 2, 'A'),
(12, 1, 'A'), (12, 4, 'D'),
(13, 5, 'A'), (13, 2, 'A'),
(15, 2, 'A'), (15, 4, 'A'),
(16, 1, 'A'),
(17, 5, 'A'), (17, 4, 'A'),
(18, 4, 'A');

-- ============================================================
-- 20. PAGOS.SUSCRIPCION
-- ============================================================
PRINT '>>> Insertando Suscripcion...';

SET IDENTITY_INSERT Pagos.Suscripcion ON;
INSERT INTO Pagos.Suscripcion
    (idSuscripcion, Usuario_idUsuario, TipoPlan_idTipoPlan,
     fechaInicio, fechaFin, estadoSuscripcion)
VALUES
(1,   6, 2, '2023-01-15', '2024-01-15', 'inactiva'),
(2,   6, 2, '2024-01-16', '2025-01-16', 'activa'),
(3,   7, 3, '2023-02-20', '2024-02-20', 'inactiva'),
(4,   7, 2, '2024-02-21', '2025-02-21', 'activa'),
(5,   8, 5, '2023-03-10', '2024-03-10', 'inactiva'),
(6,   8, 2, '2024-03-11', '2025-03-11', 'activa'),
(7,   9, 4, '2023-04-05', '2024-04-05', 'inactiva'),
(8,   9, 4, '2024-04-06', '2025-04-06', 'activa'),
(9,  10, 5, '2023-05-18', '2024-05-18', 'inactiva'),
(10, 10, 2, '2024-05-19', '2025-05-19', 'activa'),
(11, 11, 2, '2023-06-22', '2025-06-22', 'activa'),
(12, 12, 1, '2023-07-30', '2024-07-30', 'inactiva'),
(13, 12, 2, '2024-07-31', '2025-07-31', 'activa'),
(14, 13, 5, '2023-08-14', '2025-08-14', 'activa'),
(15, 15, 3, '2023-10-07', '2025-10-07', 'activa'),
(16, 16, 2, '2023-11-19', '2025-11-19', 'activa'),
(17, 17, 5, '2024-01-08', '2025-01-08', 'inactiva'),
(18, 17, 2, '2025-01-09', '2026-01-09', 'activa'),
(19, 18, 2, '2024-02-14', '2026-02-14', 'activa');
SET IDENTITY_INSERT Pagos.Suscripcion OFF;

-- ============================================================
-- 21. PAGOS.PAGO
-- ============================================================
PRINT '>>> Insertando Pago...';

SET IDENTITY_INSERT Pagos.Pago ON;
INSERT INTO Pagos.Pago
    (idPago, Suscripcion_idSuscripcion, monto, metodoPago, fechaPago, resultadoPago)
VALUES
(1,  1,  9.99, 'Tarjeta de credito', '2023-01-15', 'Completado'),
(2,  2,  9.99, 'Tarjeta de credito', '2024-01-16', 'Completado'),
(3,  3, 13.99, 'Paypal',             '2023-02-20', 'Completado'),
(4,  4,  9.99, 'Paypal',             '2024-02-21', 'Completado'),
(5,  5,  4.99, 'Tarjeta de debito',  '2023-03-10', 'Completado'),
(6,  6,  9.99, 'Tarjeta de debito',  '2024-03-11', 'Completado'),
(7,  7, 17.99, 'Tarjeta de credito', '2023-04-05', 'Completado'),
(8,  8, 17.99, 'Tarjeta de credito', '2024-04-06', 'Completado'),
(9,  9,  4.99, 'Paypal',             '2023-05-18', 'Completado'),
(10, 9,  4.99, 'Paypal',             '2023-06-18', 'Fallido'),   -- intento fallido
(11,10,  9.99, 'Paypal',             '2024-05-19', 'Completado'),
(12,11,  9.99, 'Tarjeta de credito', '2023-06-22', 'Completado'),
(13,12,  0.01, 'Tarjeta de debito',  '2023-07-30', 'Completado'), -- plan free (monto > 0 requerido)
(14,13,  9.99, 'Tarjeta de debito',  '2024-07-31', 'Completado'),
(15,14,  4.99, 'Paypal',             '2023-08-14', 'Completado'),
(16,15, 13.99, 'Tarjeta de credito', '2023-10-07', 'Completado'),
(17,16,  9.99, 'Paypal',             '2023-11-19', 'Completado'),
(18,17,  4.99, 'Tarjeta de debito',  '2024-01-08', 'Completado'),
(19,18,  9.99, 'Tarjeta de credito', '2025-01-09', 'Completado'),
(20,19,  9.99, 'Tarjeta de credito', '2024-02-14', 'Completado'),
(21,19,  9.99, 'Tarjeta de credito', '2025-02-14', 'Pendiente');
SET IDENTITY_INSERT Pagos.Pago OFF;

-- ============================================================
-- 22. ANALITICA.REPRODUCCION  (100 registros)
-- ============================================================
PRINT '>>> Insertando Reproduccion...';

SET IDENTITY_INSERT Analitica.Reproduccion ON;
INSERT INTO Analitica.Reproduccion
    (Usuario_idUsuario, Cancion_idCancion, idReproduccion,
     fechaHora, pais, duracionEscuchada, fueSaltada)
VALUES
-- Usuario 6 (30 reproducciones)
(6, 21, 1,  '2024-03-01 08:00:00', 'Ecuador',       341, 'N'),
(6, 22, 2,  '2024-03-01 08:06:00', 'Ecuador',       203, 'N'),
(6, 33, 3,  '2024-03-01 18:30:00', 'Ecuador',       178, 'N'),
(6, 42, 4,  '2024-03-02 07:45:00', 'Ecuador',       186, 'N'),
(6,  1, 5,  '2024-03-02 20:00:00', 'Ecuador',       198, 'N'),
(6, 31, 6,  '2024-03-03 09:00:00', 'Ecuador',       355, 'N'),
(6, 16, 7,  '2024-03-03 17:30:00', 'Ecuador',        80, 'S'),
(6, 41, 8,  '2024-03-04 12:00:00', 'Ecuador',       207, 'N'),
(6, 20, 9,  '2024-03-04 21:00:00', 'Ecuador',       148, 'N'),
(6, 25, 10, '2024-03-05 08:15:00', 'Ecuador',       163, 'N'),
(6, 37, 11, '2024-03-06 19:00:00', 'Ecuador',       175, 'N'),
(6, 46, 12, '2024-03-07 10:00:00', 'Ecuador',       194, 'N'),
(6,  6, 13, '2024-03-08 22:00:00', 'Ecuador',       223, 'N'),
(6, 13, 14, '2024-03-09 15:00:00', 'Ecuador',       226, 'N'),
(6, 32, 15, '2024-03-10 11:00:00', 'Ecuador',       248, 'N'),
-- Usuario 7 (20 reproducciones)
(7, 13, 16, '2024-03-01 20:00:00', 'Ecuador',       226, 'N'),
(7, 11, 17, '2024-03-02 09:30:00', 'Ecuador',       183, 'N'),
(7, 16, 18, '2024-03-03 18:00:00', 'Ecuador',       156, 'N'),
(7, 20, 19, '2024-03-04 22:00:00', 'Ecuador',       148, 'N'),
(7, 42, 20, '2024-03-05 07:00:00', 'Ecuador',       186, 'N'),
(7, 17, 21, '2024-03-06 20:30:00', 'España',        178, 'N'),
(7, 18, 22, '2024-03-07 12:00:00', 'España',        136, 'N'),
(7, 19, 23, '2024-03-08 11:00:00', 'España',         60, 'S'),
(7, 41, 24, '2024-03-09 10:00:00', 'Ecuador',       207, 'N'),
(7, 44, 25, '2024-03-10 19:00:00', 'Ecuador',       185, 'N'),
-- Usuario 8 (15 reproducciones)
(8, 31, 26, '2024-03-01 21:00:00', 'Colombia',      355, 'N'),
(8, 32, 27, '2024-03-02 08:00:00', 'Colombia',      248, 'N'),
(8, 33, 28, '2024-03-03 19:30:00', 'Colombia',      178, 'N'),
(8, 36, 29, '2024-03-04 20:00:00', 'Colombia',      476, 'N'),
(8, 37, 30, '2024-03-05 17:00:00', 'Colombia',      175, 'N'),
(8,  1, 31, '2024-03-06 10:00:00', 'Colombia',      198, 'N'),
(8,  7, 32, '2024-03-07 22:00:00', 'Colombia',      195, 'N'),
(8, 46, 33, '2024-03-08 12:00:00', 'Colombia',      194, 'N'),
(8, 47, 34, '2024-03-09 11:00:00', 'Colombia',      218, 'N'),
(8, 21, 35, '2024-03-10 18:00:00', 'Colombia',      341, 'N'),
-- Usuario 9 (15 reproducciones)
(9, 41, 36, '2024-03-01 09:00:00', 'México',        207, 'N'),
(9, 42, 37, '2024-03-02 10:00:00', 'México',        186, 'N'),
(9, 43, 38, '2024-03-03 11:00:00', 'México',        210, 'N'),
(9, 44, 39, '2024-03-04 18:00:00', 'México',        185, 'N'),
(9, 45, 40, '2024-03-05 20:00:00', 'México',        228, 'N'),
(9, 33, 41, '2024-03-06 07:30:00', 'México',        178, 'N'),
(9, 16, 42, '2024-03-07 22:00:00', 'México',         70, 'S'),
(9, 31, 43, '2024-03-08 15:00:00', 'México',        355, 'N'),
-- Usuario 10 (10 reproducciones - Rock)
(10, 21, 44, '2024-03-01 14:00:00', 'Perú',         341, 'N'),
(10, 22, 45, '2024-03-02 15:00:00', 'Perú',         203, 'N'),
(10, 23, 46, '2024-03-03 16:00:00', 'Perú',         237, 'N'),
(10, 24, 47, '2024-03-04 17:00:00', 'Perú',         212, 'N'),
(10, 25, 48, '2024-03-05 18:00:00', 'Perú',         163, 'N'),
(10, 26, 49, '2024-03-06 19:00:00', 'Perú',         303, 'N'),
(10, 27, 50, '2024-03-07 20:00:00', 'Perú',         254, 'N'),
-- Usuario 11 (10 reproducciones)
(11, 21, 51, '2024-03-01 11:00:00', 'Chile',        341, 'N'),
(11, 25, 52, '2024-03-02 12:00:00', 'Chile',        163, 'N'),
(11, 26, 53, '2024-03-03 13:00:00', 'Chile',        303, 'N'),
(11, 13, 54, '2024-03-04 14:00:00', 'Chile',        226, 'N'),
(11, 15, 55, '2024-03-05 15:00:00', 'Chile',        391, 'N'),
(11, 11, 56, '2024-03-06 16:00:00', 'Chile',        183, 'N'),
-- Reproducciones adicionales para cubrir más países y canciones
(12,  1, 57, '2024-03-01 09:00:00', 'Venezuela',    198, 'N'),
(12,  6, 58, '2024-03-02 10:00:00', 'Venezuela',    223, 'N'),
(12,  7, 59, '2024-03-03 11:00:00', 'Venezuela',    195, 'N'),
(12,  9, 60, '2024-03-04 12:00:00', 'Venezuela',    205, 'N'),
(13, 42, 61, '2024-03-01 20:00:00', 'Argentina',    186, 'N'),
(13, 43, 62, '2024-03-02 21:00:00', 'Argentina',    210, 'N'),
(13, 44, 63, '2024-03-03 22:00:00', 'Argentina',    185, 'N'),
(13,  1, 64, '2024-03-04 09:00:00', 'Argentina',    198, 'N'),
(15, 16, 65, '2024-03-05 18:00:00', 'Ecuador',      156, 'N'),
(15, 17, 66, '2024-03-06 19:00:00', 'Ecuador',      178, 'N'),
(15, 20, 67, '2024-03-07 20:00:00', 'Ecuador',      148, 'N'),
(16,  1, 68, '2024-03-01 10:00:00', 'Bolivia',      198, 'N'),
(16,  2, 69, '2024-03-02 11:00:00', 'Bolivia',      204, 'N'),
(16,  6, 70, '2024-03-03 12:00:00', 'Bolivia',      223, 'N'),
(17, 41, 71, '2024-03-01 08:00:00', 'Uruguay',      207, 'N'),
(17, 45, 72, '2024-03-02 09:00:00', 'Uruguay',      228, 'N'),
(17, 46, 73, '2024-03-03 10:00:00', 'Uruguay',      194, 'N'),
(18, 33, 74, '2024-03-01 22:00:00', 'Paraguay',     178, 'N'),
(18, 34, 75, '2024-03-02 23:00:00', 'Paraguay',     314, 'N'),
-- Segunda ronda de reproducciones para probar historial y tendencias
(6,  33, 76, '2024-04-01 08:00:00', 'Ecuador',      178, 'N'),
(6,  42, 77, '2024-04-02 09:00:00', 'Ecuador',      186, 'N'),
(6,  21, 78, '2024-04-03 10:00:00', 'Ecuador',      341, 'N'),
(7,  20, 79, '2024-04-01 20:00:00', 'Ecuador',      148, 'N'),
(7,  42, 80, '2024-04-02 21:00:00', 'Ecuador',      186, 'N'),
(8,  33, 81, '2024-04-01 19:00:00', 'Colombia',     178, 'N'),
(8,  37, 82, '2024-04-02 20:00:00', 'Colombia',     175, 'N'),
(9,  42, 83, '2024-04-01 07:00:00', 'México',       186, 'N'),
(9,  41, 84, '2024-04-02 08:00:00', 'México',       207, 'N'),
(10, 21, 85, '2024-04-01 14:00:00', 'Perú',         341, 'N'),
(11, 25, 86, '2024-04-01 11:00:00', 'Chile',        163, 'N'),
(12,  7, 87, '2024-04-01 09:00:00', 'Venezuela',    195, 'N'),
(13, 42, 88, '2024-04-01 20:00:00', 'Argentina',    186, 'N'),
-- Mes mayo para probar reportes mensuales
(6,  21, 89, '2024-05-05 08:00:00', 'Ecuador',      341, 'N'),
(6,  33, 90, '2024-05-06 09:00:00', 'Ecuador',      178, 'N'),
(7,  13, 91, '2024-05-05 20:00:00', 'Ecuador',      226, 'N'),
(8,  31, 92, '2024-05-05 21:00:00', 'Colombia',     355, 'N'),
(9,  42, 93, '2024-05-05 07:00:00', 'México',       186, 'N'),
(10, 22, 94, '2024-05-05 14:00:00', 'Perú',         203, 'N'),
(11, 21, 95, '2024-05-05 11:00:00', 'Chile',        341, 'N'),
(12,  6, 96, '2024-05-05 09:00:00', 'Venezuela',    223, 'N'),
(13, 44, 97, '2024-05-05 20:00:00', 'Argentina',    185, 'N'),
(15, 16, 98, '2024-05-05 18:00:00', 'Ecuador',      156, 'N'),
(16,  2, 99, '2024-05-05 11:00:00', 'Bolivia',      204, 'N'),
(17, 41,100, '2024-05-05 08:00:00', 'Uruguay',      207, 'N');
SET IDENTITY_INSERT Analitica.Reproduccion OFF;

-- ============================================================
-- 23. ANALITICA.REGALIA  (registros mensuales por canción y país)
-- ============================================================
PRINT '>>> Insertando Regalia...';

SET IDENTITY_INSERT Analitica.Regalia ON;
INSERT INTO Analitica.Regalia
    (idRegalia, Cancion_idCancion, anioPeriodo, mesPeriodo,
     paisReproduccion, cantidadReproducciones,
     montoTotalGenerado, montoArtista, montoDiscografica)
VALUES
-- Marzo 2024 - Canciones más escuchadas
(1,  21, 2024, 3, 'Ecuador',   4, 0.016, 0.006, 0.010),
(2,  33, 2024, 3, 'Ecuador',   3, 0.012, 0.005, 0.007),
(3,  42, 2024, 3, 'Ecuador',   3, 0.012, 0.004, 0.008),
(4,  41, 2024, 3, 'México',    4, 0.016, 0.005, 0.011),
(5,  31, 2024, 3, 'Colombia',  3, 0.012, 0.004, 0.008),
(6,  13, 2024, 3, 'Ecuador',   2, 0.008, 0.003, 0.005),
(7,  16, 2024, 3, 'Ecuador',   2, 0.008, 0.002, 0.006),
(8,  46, 2024, 3, 'Colombia',  2, 0.008, 0.003, 0.005),
(9,  21, 2024, 3, 'Perú',      3, 0.012, 0.004, 0.008),
(10, 25, 2024, 3, 'Chile',     2, 0.008, 0.003, 0.005),
(11,  1, 2024, 3, 'Venezuela', 2, 0.008, 0.001, 0.007),
(12, 37, 2024, 3, 'Colombia',  2, 0.008, 0.003, 0.005),
-- Abril 2024
(13, 33, 2024, 4, 'Ecuador',   2, 0.008, 0.003, 0.005),
(14, 42, 2024, 4, 'Ecuador',   2, 0.008, 0.003, 0.005),
(15, 21, 2024, 4, 'Ecuador',   2, 0.008, 0.003, 0.005),
(16, 33, 2024, 4, 'Colombia',  2, 0.008, 0.003, 0.005),
(17, 42, 2024, 4, 'México',    2, 0.008, 0.003, 0.005),
(18, 21, 2024, 4, 'Perú',      1, 0.004, 0.001, 0.003),
(19, 25, 2024, 4, 'Chile',     1, 0.004, 0.001, 0.003),
-- Mayo 2024
(20, 21, 2024, 5, 'Ecuador',   2, 0.008, 0.003, 0.005),
(21, 33, 2024, 5, 'Ecuador',   1, 0.004, 0.001, 0.003),
(22, 13, 2024, 5, 'Ecuador',   1, 0.004, 0.001, 0.003),
(23, 31, 2024, 5, 'Colombia',  1, 0.004, 0.001, 0.003),
(24, 42, 2024, 5, 'México',    1, 0.004, 0.001, 0.003),
(25, 22, 2024, 5, 'Perú',      1, 0.004, 0.001, 0.003);
SET IDENTITY_INSERT Analitica.Regalia OFF;

-- ============================================================

PRINT '';
PRINT '====================================================';
PRINT '  CARGA MASIVA COMPLETADA EXITOSAMENTE';
PRINT '  Resumen:';
PRINT '  - 5  Tipos de Album';
PRINT '  - 5  Planes de suscripcion';
PRINT '  - 10 Generos musicales';
PRINT '  - 5  Discograficas';
PRINT '  - 20 Personas (5 artistas, 13 oyentes, 2 admins)';
PRINT '  - 10 Albums';
PRINT '  - 50 Canciones';
PRINT '  - 10 Contratos discograficos';
PRINT '  - 8  Playlists';
PRINT '  - 19 Suscripciones';
PRINT '  - 21 Pagos';
PRINT '  - 100 Reproducciones';
PRINT '  - 25 Registros de regalias';
PRINT '====================================================';
GO
