Componentes
-- 1. MANTENER_HISTORIAL_MEDICO, Tabla: Historial_Medico (id_historial, tipo_sangre, alergias, estado_salud)

CREATE SCHEMA IF NOT EXISTS mantener_historial_medico;

CREATE OR REPLACE PROCEDURE mantener_historial_medico.adicionar_historial_medico(
    p_id_historial integer,
    p_tipo_sangre varchar,
    p_alergias varchar,
    p_estado_salud varchar
)
LANGUAGE plpgsql AS $$
BEGIN
    BEGIN
        INSERT INTO historial_medico (id_historial, tipo_sangre, alergias, estado_salud)
        VALUES (p_id_historial, p_tipo_sangre, p_alergias, p_estado_salud);
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'mantener_historial_medico.adicionar_historial_medico: %', SQLERRM;
    END;
    COMMIT;
END;
$$;

CREATE OR REPLACE PROCEDURE mantener_historial_medico.modificar_historial_medico(
    p_id_historial integer,
    p_estado_salud varchar,
    p_alergias varchar
)
LANGUAGE plpgsql AS $$
BEGIN
    BEGIN
        UPDATE historial_medico
        SET estado_salud = COALESCE(p_estado_salud, estado_salud),
            alergias = COALESCE(p_alergias, alergias)
        WHERE id_historial = p_id_historial;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'El historial medico % no existe', p_id_historial;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'mantener_historial_medico.modificar_historial_medico: %', SQLERRM;
    END;
    COMMIT;
END;
$$;

CREATE OR REPLACE FUNCTION mantener_historial_medico.consultar_historial_medico(
    p_id_historial integer DEFAULT NULL
)
RETURNS refcursor LANGUAGE plpgsql AS $$
DECLARE
    cur refcursor := 'cur_historial_medico';
BEGIN
    OPEN cur FOR
        SELECT id_historial, tipo_sangre, alergias, estado_salud
        FROM historial_medico
        WHERE p_id_historial IS NULL OR id_historial = p_id_historial
        ORDER BY id_historial;
    RETURN cur;
END;
$$;


-- 2. MANTENER_BASE_MILITAR
-- Tabla: Base_Militar (id_base, nombre_base, ubicacion)

CREATE SCHEMA IF NOT EXISTS mantener_base_militar;

CREATE OR REPLACE PROCEDURE mantener_base_militar.adicionar_base_militar(
    p_id_base integer,
    p_nombre_base varchar,
    p_ubicacion varchar
)
LANGUAGE plpgsql AS $$
BEGIN
    BEGIN
        INSERT INTO base_militar (id_base, nombre_base, ubicacion)
        VALUES (p_id_base, p_nombre_base, p_ubicacion);
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'mantener_base_militar.adicionar_base_militar: %', SQLERRM;
    END;
    COMMIT;
END;
$$;

CREATE OR REPLACE PROCEDURE mantener_base_militar.modificar_base_militar(
    p_id_base integer,
    p_nombre_base varchar,
    p_ubicacion varchar
)
LANGUAGE plpgsql AS $$
BEGIN
    BEGIN
        UPDATE base_militar
        SET nombre_base = COALESCE(p_nombre_base, nombre_base),
            ubicacion = COALESCE(p_ubicacion, ubicacion)
        WHERE id_base = p_id_base;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'La base militar % no existe', p_id_base;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'mantener_base_militar.modificar_base_militar: %', SQLERRM;
    END;
    COMMIT;
END;
$$;

CREATE OR REPLACE PROCEDURE mantener_base_militar.eliminar_base_militar(
    p_id_base integer
)
LANGUAGE plpgsql AS $$
BEGIN
    BEGIN
        DELETE FROM base_militar WHERE id_base = p_id_base;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'La base militar % no existe', p_id_base;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'mantener_base_militar.eliminar_base_militar: %', SQLERRM;
    END;
    COMMIT;
END;
$$;

CREATE OR REPLACE FUNCTION mantener_base_militar.consultar_base_militar(
    p_id_base integer DEFAULT NULL
)
RETURNS refcursor LANGUAGE plpgsql AS $$
DECLARE
    cur refcursor := 'cur_base_militar';
BEGIN
    OPEN cur FOR
        SELECT id_base, nombre_base, ubicacion
        FROM base_militar
        WHERE p_id_base IS NULL OR id_base = p_id_base
        ORDER BY id_base;
    RETURN cur;
END;
$$;


-- 3. MANTENER_SOLDADO, Tabla: Soldado (id_soldado, nombres_apellidos, id_rango, id_especialidad, id_batallon, id_historial)

CREATE SCHEMA IF NOT EXISTS mantener_soldado;

CREATE OR REPLACE PROCEDURE mantener_soldado.adicionar_soldado(
    p_id_soldado integer,
    p_nombres_apellidos varchar,
    p_id_rango integer,
    p_id_especialidad integer,
    p_id_batallon integer,
    p_id_historial integer
)
LANGUAGE plpgsql AS $$
BEGIN
    BEGIN
        INSERT INTO soldado (
            id_soldado, nombres_apellidos, id_rango,
            id_especialidad, id_batallon, id_historial
        )
        VALUES (
            p_id_soldado, p_nombres_apellidos, p_id_rango,
            p_id_especialidad, p_id_batallon, p_id_historial
        );
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'mantener_soldado.adicionar_soldado: %', SQLERRM;
    END;
    COMMIT;
END;
$$;

CREATE OR REPLACE PROCEDURE mantener_soldado.modificar_soldado(
    p_id_soldado integer,
    p_id_rango integer,
    p_id_especialidad integer,
    p_id_batallon integer
)
LANGUAGE plpgsql AS $$
BEGIN
    BEGIN
        UPDATE soldado
        SET id_rango = COALESCE(p_id_rango, id_rango),
            id_especialidad = COALESCE(p_id_especialidad, id_especialidad),
            id_batallon = COALESCE(p_id_batallon, id_batallon)
        WHERE id_soldado = p_id_soldado;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'El soldado % no existe', p_id_soldado;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'mantener_soldado.modificar_soldado: %', SQLERRM;
    END;
    COMMIT;
END;
$$;

CREATE OR REPLACE PROCEDURE mantener_soldado.eliminar_soldado(
    p_id_soldado integer
)
LANGUAGE plpgsql AS $$
BEGIN
    BEGIN
        DELETE FROM soldado WHERE id_soldado = p_id_soldado;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'El soldado % no existe', p_id_soldado;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'mantener_soldado.eliminar_soldado: %', SQLERRM;
    END;
    COMMIT;
END;
$$;

CREATE OR REPLACE FUNCTION mantener_soldado.consultar_soldado(
    p_id_soldado integer DEFAULT NULL
)
RETURNS refcursor LANGUAGE plpgsql AS $$
DECLARE
    cur refcursor := 'cur_soldado';
BEGIN
    OPEN cur FOR
        SELECT s.id_soldado, s.nombres_apellidos,
               r.nombre_rango, e.nombre_especialidad,
               b.nombre_batallon, hm.estado_salud
        FROM soldado s
        JOIN rango r ON r.id_rango = s.id_rango
        JOIN especialidad e ON e.id_especialidad = s.id_especialidad
        JOIN batallon b ON b.id_batallon = s.id_batallon
        JOIN historial_medico hm ON hm.id_historial = s.id_historial
        WHERE p_id_soldado IS NULL OR s.id_soldado = p_id_soldado
        ORDER BY s.id_soldado;
    RETURN cur;
END;
$$;


-- 4. MANTENER_ARMAMENTO,Tabla: Armamento (id_arma, numero_serie, estado_arma, id_categoria, id_soldado)
CREATE SCHEMA IF NOT EXISTS mantener_armamento;

CREATE OR REPLACE PROCEDURE mantener_armamento.adicionar_armamento(
    p_id_arma integer,
    p_numero_serie varchar,
    p_estado_arma varchar,
    p_id_categoria integer,
    p_id_soldado integer DEFAULT NULL
)
LANGUAGE plpgsql AS $$
BEGIN
    BEGIN
        INSERT INTO armamento (id_arma, numero_serie, estado_arma, id_categoria, id_soldado)
        VALUES (p_id_arma, p_numero_serie, p_estado_arma, p_id_categoria, p_id_soldado);
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'mantener_armamento.adicionar_armamento: %', SQLERRM;
    END;
    COMMIT;
END;
$$;

CREATE OR REPLACE PROCEDURE mantener_armamento.modificar_armamento(
    p_id_arma integer,
    p_estado_arma varchar,
    p_id_soldado integer
)
LANGUAGE plpgsql AS $$
BEGIN
    BEGIN
        UPDATE armamento
        SET estado_arma = COALESCE(p_estado_arma, estado_arma),
            id_soldado = p_id_soldado
        WHERE id_arma = p_id_arma;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'El arma % no existe', p_id_arma;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'mantener_armamento.modificar_armamento: %', SQLERRM;
    END;
    COMMIT;
END;
$$;

CREATE OR REPLACE PROCEDURE mantener_armamento.eliminar_armamento(
    p_id_arma integer
)
LANGUAGE plpgsql AS $$
BEGIN
    BEGIN
        DELETE FROM armamento WHERE id_arma = p_id_arma;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'El arma % no existe', p_id_arma;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'mantener_armamento.eliminar_armamento: %', SQLERRM;
    END;
    COMMIT;
END;
$$;

CREATE OR REPLACE FUNCTION mantener_armamento.consultar_armamento(
    p_id_arma integer DEFAULT NULL
)
RETURNS refcursor LANGUAGE plpgsql AS $$
DECLARE
    cur refcursor := 'cur_armamento';
BEGIN
    OPEN cur FOR
        SELECT a.id_arma, a.numero_serie, a.estado_arma,
               c.nombre_categoria, a.id_soldado
        FROM armamento a
        JOIN categoria_arma c ON c.id_categoria = a.id_categoria
        WHERE p_id_arma IS NULL OR a.id_arma = p_id_arma
        ORDER BY a.id_arma;
    RETURN cur;
END;
$$;


-- 5. MANTENER_MISION, Tabla: Mision (id_mision, nombre_mision, fecha_inicio, estado_mision)

CREATE SCHEMA IF NOT EXISTS mantener_mision;

CREATE OR REPLACE PROCEDURE mantener_mision.adicionar_mision(
    p_id_mision integer,
    p_nombre_mision varchar,
    p_fecha_inicio date,
    p_estado_mision varchar
)
LANGUAGE plpgsql AS $$
BEGIN
    BEGIN
        INSERT INTO mision (id_mision, nombre_mision, fecha_inicio, estado_mision)
        VALUES (p_id_mision, p_nombre_mision, p_fecha_inicio, p_estado_mision);
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'mantener_mision.adicionar_mision: %', SQLERRM;
    END;
    COMMIT;
END;
$$;

CREATE OR REPLACE PROCEDURE mantener_mision.modificar_mision(
    p_id_mision integer,
    p_estado_mision varchar,
    p_fecha_inicio date
)
LANGUAGE plpgsql AS $$
BEGIN
    BEGIN
        UPDATE mision
        SET estado_mision = COALESCE(p_estado_mision, estado_mision),
            fecha_inicio = COALESCE(p_fecha_inicio, fecha_inicio)
        WHERE id_mision = p_id_mision;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'La mision % no existe', p_id_mision;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'mantener_mision.modificar_mision: %', SQLERRM;
    END;
    COMMIT;
END;
$$;

CREATE OR REPLACE PROCEDURE mantener_mision.eliminar_mision(
    p_id_mision integer
)
LANGUAGE plpgsql AS $$
BEGIN
    BEGIN
        DELETE FROM mision WHERE id_mision = p_id_mision;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'La mision % no existe', p_id_mision;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'mantener_mision.eliminar_mision: %', SQLERRM;
    END;
    COMMIT;
END;
$$;

CREATE OR REPLACE FUNCTION mantener_mision.consultar_mision(
    p_id_mision integer DEFAULT NULL
)
RETURNS refcursor LANGUAGE plpgsql AS $$
DECLARE
    cur refcursor := 'cur_mision';
BEGIN
    OPEN cur FOR
        SELECT id_mision, nombre_mision, fecha_inicio, estado_mision
        FROM mision
        WHERE p_id_mision IS NULL OR id_mision = p_id_mision
        ORDER BY fecha_inicio DESC, id_mision;
    RETURN cur;
END;
$$;


-- XCOMPONENTES (Limpieza)
-- DROP SCHEMA IF EXISTS mantener_mision CASCADE;
-- DROP SCHEMA IF EXISTS mantener_armamento CASCADE;
-- DROP SCHEMA IF EXISTS mantener_soldado CASCADE;
-- DROP SCHEMA IF EXISTS mantener_base_militar CASCADE;
-- DROP SCHEMA IF EXISTS mantener_historial_medico CASCADE;



-- COMPONENTESOK

-- 1. Base Militar 
CALL mantener_base_militar.adicionar_base_militar(9001, 'Base Fuerte Norte', 'Tunja');
CALL mantener_base_militar.modificar_base_militar(9001, 'Base Fuerte Norte Actualizada', 'Boyaca');

BEGIN;
SELECT mantener_base_militar.consultar_base_militar(9001);
FETCH ALL IN cur_base_militar;
COMMIT;

-- 2. Historial Medico 
CALL mantener_historial_medico.adicionar_historial_medico(9001, 'O+', NULL, 'Optimo');
CALL mantener_historial_medico.modificar_historial_medico(9001, 'Optimo', 'Penicilina');

BEGIN;
SELECT mantener_historial_medico.consultar_historial_medico(9001);
FETCH ALL IN cur_historial_medico;
COMMIT;

-- 3. Soldado
CALL mantener_soldado.adicionar_soldado(9001, 'Carlos Ramirez', 1, 1, 1, 9001);
CALL mantener_soldado.modificar_soldado(9001, 2, NULL, NULL);

BEGIN;
SELECT mantener_soldado.consultar_soldado(9001);
FETCH ALL IN cur_soldado;
COMMIT;

-- 4. Armamento 
CALL mantener_armamento.adicionar_armamento(9001, 'WPN-99990001', 'Operativa', 1, 9001);
CALL mantener_armamento.modificar_armamento(9001, 'En Mantenimiento', NULL);

BEGIN;
SELECT mantener_armamento.consultar_armamento(9001);
FETCH ALL IN cur_armamento;
COMMIT;

-- 5. Mision 
CALL mantener_mision.adicionar_mision(9001, 'Operacion Alfa', '2026-11-22', 'Planificacion');
CALL mantener_mision.modificar_mision(9001, 'En Progreso', NULL);

BEGIN;
SELECT mantener_mision.consultar_mision(9001);
FETCH ALL IN cur_mision;
COMMIT;

-- Limpieza de datos de prueba OK
CALL mantener_mision.eliminar_mision(9001);
CALL mantener_armamento.eliminar_armamento(9001);
CALL mantener_soldado.eliminar_soldado(9001);
CALL mantener_base_militar.eliminar_base_militar(9001);


-- COMPONENTESNOOK (Pruebas de error controlado)

-- 1. Registros inexistentes
CALL mantener_soldado.modificar_soldado(99999, 1, 1, 1);
CALL mantener_soldado.eliminar_soldado(99999);
CALL mantener_base_militar.eliminar_base_militar(99999);
CALL mantener_armamento.eliminar_armamento(99999);
CALL mantener_mision.eliminar_mision(99999);

-- 2. Nombre vacio (viola CK_BaseMilitar_nombre / CK_Soldado_nombres / CK_Mision_nombre)
CALL mantener_base_militar.adicionar_base_militar(9002, '   ', 'Bogota');
CALL mantener_mision.adicionar_mision(9002, '   ', '2026-11-22', 'Planificacion');

-- 3. Arma dañada asignada a un soldado (viola chk_arma_danada_sin_soldado)
CALL mantener_armamento.adicionar_armamento(9002, 'WPN-99990002', 'Dañada', 1, 1);

-- 4. Numero de serie duplicado (viola UK_Armamento_serie)
CALL mantener_armamento.adicionar_armamento(9003, 'WPN-99990003', 'Operativa', 1, NULL);
CALL mantener_armamento.adicionar_armamento(9004, 'WPN-99990003', 'Operativa', 1, NULL);

-- 5. Historial medico con llave duplicada (id_historial 1 ya existe en inserts_masivos.sql)
CALL mantener_historial_medico.adicionar_historial_medico(1, 'A+', NULL, 'Optimo');
