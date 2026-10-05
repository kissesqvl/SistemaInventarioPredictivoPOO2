-- =====================================================
-- SistemaInventarioPredictivo
-- Script MySQL para Railway
-- =====================================================

-- =====================================================
-- TABLA: Permiso
-- =====================================================

CREATE TABLE IF NOT EXISTS Permiso (
    idPermiso INT NOT NULL AUTO_INCREMENT,
    nombrePermiso VARCHAR(100) NOT NULL,
    descripcion VARCHAR(200),
    estado BOOLEAN NOT NULL DEFAULT TRUE,

    PRIMARY KEY (idPermiso)
);


-- =====================================================
-- TABLA: Rol
-- =====================================================

CREATE TABLE IF NOT EXISTS Rol (
    idRol INT NOT NULL AUTO_INCREMENT,
    nombreRol VARCHAR(50) NOT NULL,
    descripcion VARCHAR(150),
    estado BOOLEAN NOT NULL DEFAULT TRUE,

    PRIMARY KEY (idRol)
);


-- =====================================================
-- TABLA: Usuario
-- =====================================================

CREATE TABLE IF NOT EXISTS Usuario (
    idUsuario INT NOT NULL AUTO_INCREMENT,

    nombreUsuario VARCHAR(100) NOT NULL,
    correo VARCHAR(150),

    contrasenaHash VARCHAR(255) NOT NULL,

    idRol INT NOT NULL,
    idPermiso INT,

    ultimoAcceso DATETIME,

    intentosFallidos INT NOT NULL DEFAULT 0,
    bloqueado BOOLEAN NOT NULL DEFAULT FALSE,

    tokenRecuperacion VARCHAR(255),

    fechaCreacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fechaActualizacion DATETIME,

    usuarioRegistro VARCHAR(100),

    estado BOOLEAN NOT NULL DEFAULT TRUE,

    PRIMARY KEY (idUsuario),

    UNIQUE KEY UK_Usuario_nombreUsuario (nombreUsuario),
    UNIQUE KEY UK_Usuario_correo (correo),

    CONSTRAINT FK_Usuario_Rol
        FOREIGN KEY (idRol)
        REFERENCES Rol(idRol),

    CONSTRAINT FK_Usuario_Permiso
        FOREIGN KEY (idPermiso)
        REFERENCES Permiso(idPermiso)
);


-- =====================================================
-- DATOS: Permisos
-- =====================================================

INSERT INTO Permiso
    (idPermiso, nombrePermiso, descripcion, estado)
VALUES
    (1, 'AccesoSistema', 'Permite ingresar al sistema', TRUE),
    (2, 'AccesoSistema', 'Permite ingresar al sistema', TRUE)
ON DUPLICATE KEY UPDATE
    nombrePermiso = VALUES(nombrePermiso);


-- =====================================================
-- DATOS: Roles
-- =====================================================

INSERT INTO Rol
    (idRol, nombreRol, descripcion, estado)
VALUES
    (1, 'Administrador', 'Acceso completo al sistema', TRUE),
    (2, 'Administrador', 'Acceso completo al sistema', TRUE)
ON DUPLICATE KEY UPDATE
    nombreRol = VALUES(nombreRol);


-- =====================================================
-- USUARIO ADMINISTRADOR
-- =====================================================

INSERT INTO Usuario (
    idUsuario,
    nombreUsuario,
    correo,
    contrasenaHash,
    idRol,
    idPermiso,
    ultimoAcceso,
    intentosFallidos,
    bloqueado,
    tokenRecuperacion,
    fechaCreacion,
    fechaActualizacion,
    usuarioRegistro,
    estado
)
VALUES (
    1,
    'admin',
    'admin@empresa.com',
    'SkJMOpQuabG9Zma9JIdb8Q==:SsgltL9LWr6o5jbahe0nQN4HugZ7bDqZQghKVKSwhPM=',
    1,
    1,
    '2026-09-26 13:03:52',
    0,
    FALSE,
    NULL,
    '2026-09-25 12:28:15',
    '2026-09-26 13:03:52',
    'SYSTEM',
    TRUE
)
ON DUPLICATE KEY UPDATE
    correo = VALUES(correo),
    contrasenaHash = VALUES(contrasenaHash),
    idRol = VALUES(idRol),
    idPermiso = VALUES(idPermiso),
    estado = VALUES(estado);
