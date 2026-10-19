-- ========================================================================
-- ESTRUCTURA Y RESTRICCIONES DECLARATIVAS: PROYECTO MILITAR_DB
-- ========================================================================

-- ------------------------------------------------------------------------
-- XTablas: Limpieza previa
-- (Se ejecuta en orden inverso a las dependencias para evitar errores)
-- ------------------------------------------------------------------------
DROP TABLE IF EXISTS Asignacion_Mision CASCADE;
DROP TABLE IF EXISTS Mision CASCADE;
DROP TABLE IF EXISTS Municion CASCADE;
DROP TABLE IF EXISTS Explosivo CASCADE;
DROP TABLE IF EXISTS Arma_Fuego CASCADE;
DROP TABLE IF EXISTS Calibre CASCADE;
DROP TABLE IF EXISTS Armamento CASCADE;
DROP TABLE IF EXISTS Categoria_Arma CASCADE;
DROP TABLE IF EXISTS Soldado CASCADE;
DROP TABLE IF EXISTS Historial_Medico CASCADE;
DROP TABLE IF EXISTS Especialidad CASCADE;
DROP TABLE IF EXISTS Rango CASCADE;
DROP TABLE IF EXISTS Vehiculo CASCADE;
DROP TABLE IF EXISTS Batallon CASCADE;
DROP TABLE IF EXISTS Base_Militar CASCADE;

-- ------------------------------------------------------------------------
-- Tablas (Estructura y Dominios base con restricciones de Nulidad)
-- ------------------------------------------------------------------------

CREATE TABLE Base_Militar (
    id_base         INTEGER       NOT NULL,
    nombre_base     VARCHAR(100)  NOT NULL,
    ubicacion       VARCHAR(150)  NOT NULL
);

CREATE TABLE Batallon (
    id_batallon     INTEGER       NOT NULL,
    nombre_batallon VARCHAR(100)  NOT NULL,
    id_base         INTEGER       NOT NULL
);

CREATE TABLE Vehiculo (
    id_vehiculo          INTEGER      NOT NULL,
    placa_identificacion VARCHAR(20)  NOT NULL,
    tipo_vehiculo        VARCHAR(50)  NOT NULL,
    id_base              INTEGER      NOT NULL
);

CREATE TABLE Rango (
    id_rango         INTEGER       NOT NULL,
    nombre_rango     VARCHAR(50)   NOT NULL,
    nivel_jerarquico INTEGER       NOT NULL,
    sueldo_base      NUMERIC(12,2) NOT NULL
);

CREATE TABLE Especialidad (
    id_especialidad     INTEGER       NOT NULL,
    nombre_especialidad VARCHAR(50)   NOT NULL,
    descripcion_rol     VARCHAR(255)  NOT NULL,
    nivel_riesgo        VARCHAR(20)   NOT NULL,
    bono_salarial       NUMERIC(10,2) NOT NULL
);

CREATE TABLE Historial_Medico (
    id_historial INTEGER      NOT NULL,
    tipo_sangre  VARCHAR(5)   NOT NULL,
    alergias     VARCHAR(255),               -- Permite nulos
    estado_salud VARCHAR(255) NOT NULL
);

CREATE TABLE Soldado (
    id_soldado        INTEGER      NOT NULL,
    nombres_apellidos VARCHAR(150) NOT NULL,
    id_rango          INTEGER      NOT NULL,
    id_especialidad   INTEGER      NOT NULL,
    id_batallon       INTEGER      NOT NULL,
    id_historial      INTEGER      NOT NULL
);

CREATE TABLE Categoria_Arma (
    id_categoria      INTEGER     NOT NULL,
    nombre_categoria  VARCHAR(50) NOT NULL,
    nivel_restriccion VARCHAR(20) NOT NULL
);

CREATE TABLE Armamento (
    id_arma         INTEGER     NOT NULL,
    numero_serie    VARCHAR(50) NOT NULL,
    estado_arma     VARCHAR(50) NOT NULL,
    id_categoria    INTEGER     NOT NULL,
    id_soldado      INTEGER                  -- Permite nulos
);

CREATE TABLE Calibre (
    id_calibre       INTEGER     NOT NULL,
    nombre_calibre   VARCHAR(20) NOT NULL,
    tipo_penetracion VARCHAR(50) NOT NULL
);

CREATE TABLE Arma_Fuego (
    id_arma            INTEGER       NOT NULL,
    capacidad_cargador INTEGER       NOT NULL,
    peso_vacia_kg      NUMERIC(6,2)  NOT NULL,
    modo_disparo       VARCHAR(50)   NOT NULL,
    id_calibre         INTEGER       NOT NULL
);

CREATE TABLE Explosivo (
    id_arma         INTEGER       NOT NULL,
    fecha_caducidad DATE          NOT NULL,
    peso_kg         NUMERIC(6,2)  NOT NULL
);

CREATE TABLE Municion (
    id_municion         INTEGER     NOT NULL,
    cantidad_disponible INTEGER     NOT NULL,
    fecha_vencimiento   DATE        NOT NULL,
    lote                VARCHAR(50) NOT NULL,
    id_calibre          INTEGER     NOT NULL,
    id_base             INTEGER     NOT NULL
);

CREATE TABLE Mision (
    id_mision     INTEGER      NOT NULL,
    nombre_mision VARCHAR(100) NOT NULL,
    fecha_inicio  DATE         NOT NULL,
    estado_mision VARCHAR(50)  NOT NULL
);

CREATE TABLE Asignacion_Mision (
    id_asignacion INTEGER      NOT NULL,
    rol_asignado  VARCHAR(100) NOT NULL,
    id_mision     INTEGER      NOT NULL,
    id_soldado    INTEGER      NOT NULL
);

-- ------------------------------------------------------------------------
-- Atributos (Restricciones Declarativas de Dominio y Lógica)
-- ------------------------------------------------------------------------

-- Validaciones de longitud mínima para cadenas obligatorias
ALTER TABLE Base_Militar ADD CONSTRAINT CK_BaseMilitar_nombre CHECK (LENGTH(TRIM(nombre_base)) > 0);
ALTER TABLE Batallon ADD CONSTRAINT CK_Batallon_nombre CHECK (LENGTH(TRIM(nombre_batallon)) > 0);
ALTER TABLE Soldado ADD CONSTRAINT CK_Soldado_nombres CHECK (LENGTH(TRIM(nombres_apellidos)) > 0);
ALTER TABLE Mision ADD CONSTRAINT CK_Mision_nombre CHECK (LENGTH(TRIM(nombre_mision)) > 0);

-- Validaciones numéricas (Positivos)
ALTER TABLE Rango ADD CONSTRAINT CK_Rango_sueldo CHECK (sueldo_base >= 0);
ALTER TABLE Especialidad ADD CONSTRAINT CK_Especialidad_bono CHECK (bono_salarial >= 0);
ALTER TABLE Arma_Fuego ADD CONSTRAINT CK_ArmaFuego_capacidad CHECK (capacidad_cargador > 0);
ALTER TABLE Arma_Fuego ADD CONSTRAINT CK_ArmaFuego_peso CHECK (peso_vacia_kg > 0);
ALTER TABLE Explosivo ADD CONSTRAINT CK_Explosivo_peso CHECK (peso_kg > 0);
ALTER TABLE Municion ADD CONSTRAINT CK_Municion_cantidad CHECK (cantidad_disponible >= 0);

-- ------------------------------------------------------------------------
-- Primarias
-- ------------------------------------------------------------------------
ALTER TABLE Base_Militar      ADD CONSTRAINT PK_Base_Militar      PRIMARY KEY (id_base);
ALTER TABLE Batallon          ADD CONSTRAINT PK_Batallon          PRIMARY KEY (id_batallon);
ALTER TABLE Vehiculo          ADD CONSTRAINT PK_Vehiculo          PRIMARY KEY (id_vehiculo);
ALTER TABLE Rango             ADD CONSTRAINT PK_Rango             PRIMARY KEY (id_rango);
ALTER TABLE Especialidad      ADD CONSTRAINT PK_Especialidad      PRIMARY KEY (id_especialidad);
ALTER TABLE Historial_Medico  ADD CONSTRAINT PK_Historial_Medico  PRIMARY KEY (id_historial);
ALTER TABLE Soldado           ADD CONSTRAINT PK_Soldado           PRIMARY KEY (id_soldado);
ALTER TABLE Categoria_Arma    ADD CONSTRAINT PK_Categoria_Arma    PRIMARY KEY (id_categoria);
ALTER TABLE Armamento         ADD CONSTRAINT PK_Armamento         PRIMARY KEY (id_arma);
ALTER TABLE Calibre           ADD CONSTRAINT PK_Calibre           PRIMARY KEY (id_calibre);
ALTER TABLE Arma_Fuego        ADD CONSTRAINT PK_Arma_Fuego        PRIMARY KEY (id_arma);
ALTER TABLE Explosivo         ADD CONSTRAINT PK_Explosivo         PRIMARY KEY (id_arma);
ALTER TABLE Municion          ADD CONSTRAINT PK_Municion          PRIMARY KEY (id_municion);
ALTER TABLE Mision            ADD CONSTRAINT PK_Mision            PRIMARY KEY (id_mision);
ALTER TABLE Asignacion_Mision ADD CONSTRAINT PK_Asignacion_Mision PRIMARY KEY (id_asignacion);

-- ------------------------------------------------------------------------
-- Unicas
-- ------------------------------------------------------------------------
ALTER TABLE Vehiculo          ADD CONSTRAINT UK_Vehiculo_placa    UNIQUE (placa_identificacion);
ALTER TABLE Armamento         ADD CONSTRAINT UK_Armamento_serie   UNIQUE (numero_serie);

-- ------------------------------------------------------------------------
-- Foraneas
-- ------------------------------------------------------------------------
ALTER TABLE Batallon
    ADD CONSTRAINT FK_Batallon_Base
    FOREIGN KEY (id_base) REFERENCES Base_Militar (id_base);

ALTER TABLE Vehiculo
    ADD CONSTRAINT FK_Vehiculo_Base
    FOREIGN KEY (id_base) REFERENCES Base_Militar (id_base);

ALTER TABLE Soldado
    ADD CONSTRAINT FK_Soldado_Rango
    FOREIGN KEY (id_rango) REFERENCES Rango (id_rango);

ALTER TABLE Soldado
    ADD CONSTRAINT FK_Soldado_Especialidad
    FOREIGN KEY (id_especialidad) REFERENCES Especialidad (id_especialidad);

ALTER TABLE Soldado
    ADD CONSTRAINT FK_Soldado_Batallon
    FOREIGN KEY (id_batallon) REFERENCES Batallon (id_batallon);

ALTER TABLE Soldado
    ADD CONSTRAINT FK_Soldado_Historial
    FOREIGN KEY (id_historial) REFERENCES Historial_Medico (id_historial);

ALTER TABLE Armamento
    ADD CONSTRAINT FK_Armamento_Categoria
    FOREIGN KEY (id_categoria) REFERENCES Categoria_Arma (id_categoria);

ALTER TABLE Armamento
    ADD CONSTRAINT FK_Armamento_Soldado
    FOREIGN KEY (id_soldado) REFERENCES Soldado (id_soldado);

ALTER TABLE Arma_Fuego
    ADD CONSTRAINT FK_ArmaFuego_Armamento
    FOREIGN KEY (id_arma) REFERENCES Armamento (id_arma);

ALTER TABLE Arma_Fuego
    ADD CONSTRAINT FK_ArmaFuego_Calibre
    FOREIGN KEY (id_calibre) REFERENCES Calibre (id_calibre);

ALTER TABLE Explosivo
    ADD CONSTRAINT FK_Explosivo_Armamento
    FOREIGN KEY (id_arma) REFERENCES Armamento (id_arma);

ALTER TABLE Municion
    ADD CONSTRAINT FK_Municion_Calibre
    FOREIGN KEY (id_calibre) REFERENCES Calibre (id_calibre);

ALTER TABLE Municion
    ADD CONSTRAINT FK_Municion_Base
    FOREIGN KEY (id_base) REFERENCES Base_Militar (id_base);

ALTER TABLE Asignacion_Mision
    ADD CONSTRAINT FK_Asignacion_Mision
    FOREIGN KEY (id_mision) REFERENCES Mision (id_mision);

ALTER TABLE Asignacion_Mision
    ADD CONSTRAINT FK_Asignacion_Soldado
    FOREIGN KEY (id_soldado) REFERENCES Soldado (id_soldado);