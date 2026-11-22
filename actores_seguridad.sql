-- Actores
-- PA_OFICIAL_PERSONAL

CREATE SCHEMA IF NOT EXISTS pa_oficial_personal;

CREATE OR REPLACE PROCEDURE pa_oficial_personal.adicionar_soldado(
    p_id_soldado integer,
    p_nombres_apellidos varchar,
    p_id_rango integer,
    p_id_especialidad integer,
    p_id_batallon integer,
    p_id_historial integer)
LANGUAGE plpgsql AS $$
BEGIN
    CALL mantener_soldado.adicionar_soldado(
        p_id_soldado, p_nombres_apellidos, p_id_rango,
        p_id_especialidad, p_id_batallon, p_id_historial
    );
END;
$$;

CREATE OR REPLACE PROCEDURE pa_oficial_personal.modificar_soldado(
    p_id_soldado integer,
    p_id_rango integer,
    p_id_especialidad integer,
    p_id_batallon integer)
LANGUAGE plpgsql AS $$
BEGIN
    CALL mantener_soldado.modificar_soldado(
        p_id_soldado, p_id_rango, p_id_especialidad, p_id_batallon
    );
END;
$$;

CREATE OR REPLACE PROCEDURE pa_oficial_personal.eliminar_soldado(
    p_id_soldado integer)
LANGUAGE plpgsql AS $$
BEGIN
    CALL mantener_soldado.eliminar_soldado(p_id_soldado);
END;
$$;

CREATE OR REPLACE FUNCTION pa_oficial_personal.consultar_soldado(
    p_id_soldado integer DEFAULT NULL)
RETURNS refcursor LANGUAGE plpgsql AS $$
BEGIN
    RETURN mantener_soldado.consultar_soldado(p_id_soldado);
END;
$$;


-- PA_OFICIAL_SANIDAD

CREATE SCHEMA IF NOT EXISTS pa_oficial_sanidad;

CREATE OR REPLACE PROCEDURE pa_oficial_sanidad.adicionar_historial_medico(
    p_id_historial integer,
    p_tipo_sangre varchar,
    p_alergias varchar,
    p_estado_salud varchar)
LANGUAGE plpgsql AS $$
BEGIN
    CALL mantener_historial_medico.adicionar_historial_medico(
        p_id_historial, p_tipo_sangre, p_alergias, p_estado_salud
    );
END;
$$;

CREATE OR REPLACE PROCEDURE pa_oficial_sanidad.modificar_historial_medico(
    p_id_historial integer,
    p_estado_salud varchar,
    p_alergias varchar)
LANGUAGE plpgsql AS $$
BEGIN
    CALL mantener_historial_medico.modificar_historial_medico(
        p_id_historial, p_estado_salud, p_alergias
    );
END;
$$;

CREATE OR REPLACE FUNCTION pa_oficial_sanidad.consultar_historial_medico(
    p_id_historial integer DEFAULT NULL)
RETURNS refcursor LANGUAGE plpgsql AS $$
BEGIN
    RETURN mantener_historial_medico.consultar_historial_medico(p_id_historial);
END;
$$;


-- PA_ADMIN_INFRAESTRUCTURA

CREATE SCHEMA IF NOT EXISTS pa_admin_infraestructura;

CREATE OR REPLACE PROCEDURE pa_admin_infraestructura.adicionar_base_militar(
    p_id_base integer,
    p_nombre_base varchar,
    p_ubicacion varchar)
LANGUAGE plpgsql AS $$
BEGIN
    CALL mantener_base_militar.adicionar_base_militar(
        p_id_base, p_nombre_base, p_ubicacion
    );
END;
$$;

CREATE OR REPLACE PROCEDURE pa_admin_infraestructura.modificar_base_militar(
    p_id_base integer,
    p_nombre_base varchar,
    p_ubicacion varchar)
LANGUAGE plpgsql AS $$
BEGIN
    CALL mantener_base_militar.modificar_base_militar(
        p_id_base, p_nombre_base, p_ubicacion
    );
END;
$$;

CREATE OR REPLACE PROCEDURE pa_admin_infraestructura.eliminar_base_militar(
    p_id_base integer)
LANGUAGE plpgsql AS $$
BEGIN
    CALL mantener_base_militar.eliminar_base_militar(p_id_base);
END;
$$;

CREATE OR REPLACE FUNCTION pa_admin_infraestructura.consultar_base_militar(
    p_id_base integer DEFAULT NULL)
RETURNS refcursor LANGUAGE plpgsql AS $$
BEGIN
    RETURN mantener_base_militar.consultar_base_militar(p_id_base);
END;
$$;


-- PA_OFICIAL_LOGISTICO

CREATE SCHEMA IF NOT EXISTS pa_oficial_logistico;

CREATE OR REPLACE PROCEDURE pa_oficial_logistico.adicionar_armamento(
    p_id_arma integer,
    p_numero_serie varchar,
    p_estado_arma varchar,
    p_id_categoria integer,
    p_id_soldado integer DEFAULT NULL)
LANGUAGE plpgsql AS $$
BEGIN
    CALL mantener_armamento.adicionar_armamento(
        p_id_arma, p_numero_serie, p_estado_arma, p_id_categoria, p_id_soldado
    );
END;
$$;

CREATE OR REPLACE PROCEDURE pa_oficial_logistico.modificar_armamento(
    p_id_arma integer,
    p_estado_arma varchar,
    p_id_soldado integer)
LANGUAGE plpgsql AS $$
BEGIN
    CALL mantener_armamento.modificar_armamento(
        p_id_arma, p_estado_arma, p_id_soldado
    );
END;
$$;

CREATE OR REPLACE PROCEDURE pa_oficial_logistico.eliminar_armamento(
    p_id_arma integer)
LANGUAGE plpgsql AS $$
BEGIN
    CALL mantener_armamento.eliminar_armamento(p_id_arma);
END;
$$;

CREATE OR REPLACE FUNCTION pa_oficial_logistico.consultar_armamento(
    p_id_arma integer DEFAULT NULL)
RETURNS refcursor LANGUAGE plpgsql AS $$
BEGIN
    RETURN mantener_armamento.consultar_armamento(p_id_arma);
END;
$$;


-- PA_COMANDANTE_OPERACIONES

CREATE SCHEMA IF NOT EXISTS pa_comandante_operaciones;

CREATE OR REPLACE PROCEDURE pa_comandante_operaciones.adicionar_mision(
    p_id_mision integer,
    p_nombre_mision varchar,
    p_fecha_inicio date,
    p_estado_mision varchar)
LANGUAGE plpgsql AS $$
BEGIN
    CALL mantener_mision.adicionar_mision(
        p_id_mision, p_nombre_mision, p_fecha_inicio, p_estado_mision
    );
END;
$$;

CREATE OR REPLACE PROCEDURE pa_comandante_operaciones.modificar_mision(
    p_id_mision integer,
    p_estado_mision varchar,
    p_fecha_inicio date)
LANGUAGE plpgsql AS $$
BEGIN
    CALL mantener_mision.modificar_mision(
        p_id_mision, p_estado_mision, p_fecha_inicio
    );
END;
$$;

CREATE OR REPLACE PROCEDURE pa_comandante_operaciones.eliminar_mision(
    p_id_mision integer)
LANGUAGE plpgsql AS $$
BEGIN
    CALL mantener_mision.eliminar_mision(p_id_mision);
END;
$$;

CREATE OR REPLACE FUNCTION pa_comandante_operaciones.consultar_mision(
    p_id_mision integer DEFAULT NULL)
RETURNS refcursor LANGUAGE plpgsql AS $$
BEGIN
    RETURN mantener_mision.consultar_mision(p_id_mision);
END;
$$;


-- SEGURIDAD

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'rol_oficial_personal') THEN
        CREATE ROLE rol_oficial_personal NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'rol_oficial_sanidad') THEN
        CREATE ROLE rol_oficial_sanidad NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'rol_admin_infraestructura') THEN
        CREATE ROLE rol_admin_infraestructura NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'rol_oficial_logistico') THEN
        CREATE ROLE rol_oficial_logistico NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'rol_comandante_operaciones') THEN
        CREATE ROLE rol_comandante_operaciones NOLOGIN;
    END IF;
END;
$$;

REVOKE ALL ON ALL ROUTINES IN SCHEMA
    mantener_soldado, mantener_historial_medico, mantener_base_militar,
    mantener_armamento, mantener_mision,
    pa_oficial_personal, pa_oficial_sanidad, pa_admin_infraestructura,
    pa_oficial_logistico, pa_comandante_operaciones
FROM PUBLIC;

-- Oficial de Personal
GRANT USAGE ON SCHEMA pa_oficial_personal, mantener_soldado TO rol_oficial_personal;
GRANT EXECUTE ON ALL ROUTINES IN SCHEMA pa_oficial_personal, mantener_soldado TO rol_oficial_personal;
GRANT SELECT, INSERT, UPDATE, DELETE ON soldado TO rol_oficial_personal;
GRANT SELECT ON rango, especialidad, batallon, historial_medico, info_soldados_activos TO rol_oficial_personal;

-- Oficial de Sanidad
GRANT USAGE ON SCHEMA pa_oficial_sanidad, mantener_historial_medico TO rol_oficial_sanidad;
GRANT EXECUTE ON ALL ROUTINES IN SCHEMA pa_oficial_sanidad, mantener_historial_medico TO rol_oficial_sanidad;
GRANT SELECT, INSERT, UPDATE ON historial_medico TO rol_oficial_sanidad;
GRANT SELECT ON soldado TO rol_oficial_sanidad;
GRANT SELECT, UPDATE ON armamento TO rol_oficial_sanidad;
GRANT SELECT, DELETE ON asignacion_mision TO rol_oficial_sanidad;

-- Administrador de Infraestructura
GRANT USAGE ON SCHEMA pa_admin_infraestructura, mantener_base_militar TO rol_admin_infraestructura;
GRANT EXECUTE ON ALL ROUTINES IN SCHEMA pa_admin_infraestructura, mantener_base_militar TO rol_admin_infraestructura;
GRANT SELECT, INSERT, UPDATE, DELETE ON base_militar TO rol_admin_infraestructura;

-- Oficial Logistico
GRANT USAGE ON SCHEMA pa_oficial_logistico, mantener_armamento TO rol_oficial_logistico;
GRANT EXECUTE ON ALL ROUTINES IN SCHEMA pa_oficial_logistico, mantener_armamento TO rol_oficial_logistico;
GRANT SELECT, INSERT, UPDATE, DELETE ON armamento TO rol_oficial_logistico;
GRANT SELECT ON categoria_arma, soldado, historial_medico, info_armamento_activo TO rol_oficial_logistico;

-- Comandante de Operaciones
GRANT USAGE ON SCHEMA pa_comandante_operaciones, mantener_mision TO rol_comandante_operaciones;
GRANT EXECUTE ON ALL ROUTINES IN SCHEMA pa_comandante_operaciones, mantener_mision TO rol_comandante_operaciones;
GRANT SELECT, INSERT, UPDATE, DELETE ON mision TO rol_comandante_operaciones;
GRANT SELECT ON info_misiones_activas TO rol_comandante_operaciones;


-- XSEGURIDAD

-- DROP SCHEMA IF EXISTS pa_comandante_operaciones CASCADE;
-- DROP SCHEMA IF EXISTS pa_oficial_logistico CASCADE;
-- DROP SCHEMA IF EXISTS pa_admin_infraestructura CASCADE;
-- DROP SCHEMA IF EXISTS pa_oficial_sanidad CASCADE;
-- DROP SCHEMA IF EXISTS pa_oficial_personal CASCADE;
-- DROP OWNED BY rol_comandante_operaciones;
-- DROP OWNED BY rol_oficial_logistico;
-- DROP OWNED BY rol_admin_infraestructura;
-- DROP OWNED BY rol_oficial_sanidad;
-- DROP OWNED BY rol_oficial_personal;
-- DROP ROLE IF EXISTS rol_comandante_operaciones;
-- DROP ROLE IF EXISTS rol_oficial_logistico;
-- DROP ROLE IF EXISTS rol_admin_infraestructura;
-- DROP ROLE IF EXISTS rol_oficial_sanidad;
-- DROP ROLE IF EXISTS rol_oficial_personal;


-- SEGURIDADOK
-- 1. Oficial de Sanidad
SET ROLE rol_oficial_sanidad;
CALL pa_oficial_sanidad.adicionar_historial_medico(9501, 'O+', NULL, 'Optimo');
CALL pa_oficial_sanidad.modificar_historial_medico(9501, 'Optimo', 'Sin alergias');
RESET ROLE;

BEGIN;
SET LOCAL ROLE rol_oficial_sanidad;
SELECT pa_oficial_sanidad.consultar_historial_medico(9501);
FETCH ALL IN cur_historial_medico;
COMMIT;

-- 2. Administrador de Infraestructura
SET ROLE rol_admin_infraestructura;
CALL pa_admin_infraestructura.adicionar_base_militar(9501, 'Base Seguridad Norte', 'Tunja');
CALL pa_admin_infraestructura.modificar_base_militar(9501, 'Base Seguridad Central', 'Boyaca');
RESET ROLE;

BEGIN;
SET LOCAL ROLE rol_admin_infraestructura;
SELECT pa_admin_infraestructura.consultar_base_militar(9501);
FETCH ALL IN cur_base_militar;
COMMIT;

-- 3. Oficial de Personal
SET ROLE rol_oficial_personal;
CALL pa_oficial_personal.adicionar_soldado(9501, 'Laura Mendoza', 1, 1, 1, 9501);
CALL pa_oficial_personal.modificar_soldado(9501, 2, NULL, NULL);
RESET ROLE;

BEGIN;
SET LOCAL ROLE rol_oficial_personal;
SELECT pa_oficial_personal.consultar_soldado(9501);
FETCH ALL IN cur_soldado;
COMMIT;

-- 4. Oficial Logistico
SET ROLE rol_oficial_logistico;
CALL pa_oficial_logistico.adicionar_armamento(9501, 'WPN-99995001', 'Operativa', 1, 9501);
CALL pa_oficial_logistico.modificar_armamento(9501, 'En Mantenimiento', NULL);
RESET ROLE;

BEGIN;
SET LOCAL ROLE rol_oficial_logistico;
SELECT pa_oficial_logistico.consultar_armamento(9501);
FETCH ALL IN cur_armamento;
COMMIT;

-- 5. Comandante de Operaciones
SET ROLE rol_comandante_operaciones;
CALL pa_comandante_operaciones.adicionar_mision(9501, 'Operacion Escudo', '2026-11-25', 'Planificacion');
CALL pa_comandante_operaciones.modificar_mision(9501, 'En Progreso', NULL);
RESET ROLE;

BEGIN;
SET LOCAL ROLE rol_comandante_operaciones;
SELECT pa_comandante_operaciones.consultar_mision(9501);
FETCH ALL IN cur_mision;
COMMIT;

-- Limpieza de datos de prueba OK
SET ROLE rol_comandante_operaciones;
CALL pa_comandante_operaciones.eliminar_mision(9501);
RESET ROLE;

SET ROLE rol_oficial_logistico;
CALL pa_oficial_logistico.eliminar_armamento(9501);
RESET ROLE;

SET ROLE rol_oficial_personal;
CALL pa_oficial_personal.eliminar_soldado(9501);
RESET ROLE;

SET ROLE rol_admin_infraestructura;
CALL pa_admin_infraestructura.eliminar_base_militar(9501);
RESET ROLE;

-- debe devolver 0 filas
SELECT 1 FROM mision WHERE id_mision = 9501
UNION ALL
SELECT 1 FROM armamento WHERE id_arma = 9501
UNION ALL
SELECT 1 FROM soldado WHERE id_soldado = 9501
UNION ALL
SELECT 1 FROM base_militar WHERE id_base = 9501;


-- SEGURIDADNOOK
-- El Oficial de Sanidad no puede usar servicios de Personal
BEGIN;
SET LOCAL ROLE rol_oficial_sanidad;
CALL pa_oficial_personal.eliminar_soldado(1);
ROLLBACK;

BEGIN;
SET LOCAL ROLE rol_oficial_sanidad;
SELECT pa_oficial_personal.consultar_soldado();
ROLLBACK;

-- El Oficial Logistico no puede crear misiones ni leer la tabla mision
BEGIN;
SET LOCAL ROLE rol_oficial_logistico;
CALL pa_comandante_operaciones.adicionar_mision(9600, 'Mision Ilegal', '2026-11-25', 'Planificacion');
ROLLBACK;

BEGIN;
SET LOCAL ROLE rol_oficial_logistico;
SELECT * FROM mision;
ROLLBACK;

-- El Comandante de Operaciones no puede eliminar armamento ni borrar directo de la tabla
BEGIN;
SET LOCAL ROLE rol_comandante_operaciones;
CALL pa_oficial_logistico.eliminar_armamento(1);
ROLLBACK;

BEGIN;
SET LOCAL ROLE rol_comandante_operaciones;
DELETE FROM armamento WHERE id_arma = 1;
ROLLBACK;

-- El Administrador de Infraestructura no puede leer historiales medicos ni crear soldados
BEGIN;
SET LOCAL ROLE rol_admin_infraestructura;
SELECT * FROM historial_medico;
ROLLBACK;

BEGIN;
SET LOCAL ROLE rol_admin_infraestructura;
CALL pa_oficial_personal.adicionar_soldado(9600, 'Intruso', 1, 1, 1, 1);
ROLLBACK;

-- debe devolver 0 filas
SELECT * FROM mision WHERE id_mision = 9600;
SELECT * FROM soldado WHERE id_soldado = 9600;