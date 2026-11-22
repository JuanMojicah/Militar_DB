-- PROYECTO: MILITAR_DB - RESTRICCIONES DECLARATIVAS Y PROCEDIMENTALES
-- Cubre: Personal, Sanidad, Infraestructura, Logística y Operaciones
-- 9 restricciones configuradas (que en siendo todas aplican 12 reglas de negocio sobre la DB) 

-- 1. LIMPIEZA PREVIA DE DATOS (Para evitar conflictos con los 12k registros)

-- Toca limpiar armas dañadas que tengan soldado asignado
UPDATE armamento SET id_soldado = NULL WHERE estado_arma LIKE 'Da%ada';

-- 2. TUPLAS (Restricciones CHECK de múltiples atributos / dominio)
-- A. Oficial Logístico: Un arma dañada no puede estar asignada a ningún soldado
ALTER TABLE armamento 
DROP CONSTRAINT IF EXISTS chk_arma_danada_sin_soldado;

ALTER TABLE armamento 
ADD CONSTRAINT chk_arma_danada_sin_soldado 
CHECK (NOT (estado_arma = 'Dañada' AND id_soldado IS NOT NULL));

-- 3. ACCIONES DE REFERENCIA (Comportamiento de Llaves Foráneas)
-- A. Comandante de Operaciones: Si se elimina una misión, se borran en cascada 
-- todas las asignaciones de soldados vinculadas a ella (ON DELETE CASCADE)
ALTER TABLE asignacion_mision 
DROP CONSTRAINT IF EXISTS asignacion_mision_id_mision_fkey;

ALTER TABLE asignacion_mision 
ADD CONSTRAINT asignacion_mision_id_mision_fkey 
FOREIGN KEY (id_mision) REFERENCES mision(id_mision) ON DELETE CASCADE;

-- B. Oficial de Personal / Operaciones: Si un soldado es eliminado de la base de datos,
-- se borran en cascada sus asignaciones a misiones (ON DELETE CASCADE)
ALTER TABLE asignacion_mision 
DROP CONSTRAINT IF EXISTS asignacion_mision_id_soldado_fkey;

ALTER TABLE asignacion_mision 
ADD CONSTRAINT asignacion_mision_id_soldado_fkey 
FOREIGN KEY (id_soldado) REFERENCES soldado(id_soldado) ON DELETE CASCADE;

-- C. Oficial Logístico / Personal: Si se elimina el registro de un soldado, 
-- su arma vuelve al inventario quedando sin asignar (ON DELETE SET NULL)
ALTER TABLE armamento 
DROP CONSTRAINT IF EXISTS armamento_id_soldado_fkey;

ALTER TABLE armamento 
ADD CONSTRAINT armamento_id_soldado_fkey 
FOREIGN KEY (id_soldado) REFERENCES soldado(id_soldado) ON DELETE SET NULL;

-- D. Administrador de Infraestructura: Prohibir eliminar un batallón si todavía 
-- tiene soldados activos asignados a él (ON DELETE RESTRICT)
ALTER TABLE soldado 
DROP CONSTRAINT IF EXISTS soldado_id_batallon_fkey;

ALTER TABLE soldado 
ADD CONSTRAINT soldado_id_batallon_fkey 
FOREIGN KEY (id_batallon) REFERENCES batallon(id_batallon) ON DELETE RESTRICT;

-- E. Administrador de Infraestructura: Prohibir eliminar un batallón si todavía 
-- tiene vehículos militares asignados (ON DELETE RESTRICT)
ALTER TABLE vehiculo 
DROP CONSTRAINT IF EXISTS vehiculo_id_batallon_fkey;

ALTER TABLE vehiculo 
ADD CONSTRAINT vehiculo_id_batallon_fkey 
FOREIGN KEY (id_batallon) REFERENCES batallon(id_batallon) ON DELETE RESTRICT;

-- 4. DISPARADORES (Automatización Procedimental - Triggers)
-- DISPARADOR 1: Comandante de Operaciones ("Registrar asignación de misión")
-- Regla: Impedir asignar soldados en 'Baja Medica' o 'Fallecido' a misiones.

CREATE OR REPLACE FUNCTION verificar_salud_soldado()
RETURNS TRIGGER AS $$
DECLARE
    estado_actual VARCHAR;
BEGIN
    SELECT hm.estado_salud INTO estado_actual
    FROM soldado s
    JOIN historial_medico hm ON s.id_historial = hm.id_historial
    WHERE s.id_soldado = NEW.id_soldado;

    IF estado_actual IN ('Baja Medica', 'Fallecido') THEN
        RAISE EXCEPTION 'Automatización (Operaciones): El soldado % tiene estado médico [%] y no puede ir a misiones.', NEW.id_soldado, estado_actual;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_evitar_asignacion_baja_medica ON asignacion_mision;

CREATE TRIGGER trg_evitar_asignacion_baja_medica
BEFORE INSERT OR UPDATE ON asignacion_mision
FOR EACH ROW
EXECUTE FUNCTION verificar_salud_soldado();

-- DISPARADOR 2: Oficial de Sanidad ("Mantener historial médico")
-- Regla 1: Un soldado 'Fallecido' no puede volver a cambiar de estado médico.
-- Regla 2: Si el soldado muere en batalla ('Fallecido'), su arma queda libre 
-- (id_soldado = NULL), pero NO cambia a 'Dañada', y se retira de misiones.

CREATE OR REPLACE FUNCTION liberar_arma_por_fallecimiento()
RETURNS TRIGGER AS $$
DECLARE
    v_id_soldado INT;
BEGIN
    -- Regla 1: Inmutabilidad del fallecimiento
    IF OLD.estado_salud = 'Fallecido' AND NEW.estado_salud <> 'Fallecido' THEN
        RAISE EXCEPTION 'Automatización (Sanidad): El historial % pertenece a un soldado fallecido; su estado es irreversible.', OLD.id_historial;
    END IF;

    -- Regla 2: Liberación de armamento al caer en combate
    IF NEW.estado_salud = 'Fallecido' AND OLD.estado_salud <> 'Fallecido' THEN
        
        -- Buscamos el ID del soldado dueño de este historial
        SELECT id_soldado INTO v_id_soldado 
        FROM soldado 
        WHERE id_historial = NEW.id_historial;
        
        IF v_id_soldado IS NOT NULL THEN
            -- Le quitamos el arma (queda disponible en NULL) sin alterar su estado físico
            UPDATE armamento 
            SET id_soldado = NULL 
            WHERE id_soldado = v_id_soldado;

            -- Lo retiramos de las asignaciones operativas activas
            DELETE FROM asignacion_mision
            WHERE id_soldado = v_id_soldado;
        END IF;
        
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_liberar_arma_fallecido ON historial_medico;

CREATE TRIGGER trg_liberar_arma_fallecido
BEFORE UPDATE ON historial_medico
FOR EACH ROW
EXECUTE FUNCTION liberar_arma_por_fallecimiento();


-- DISPARADOR 3: Oficial Logístico ("Registrar asignación de armamento")
-- Regla 1: No entregar armas a soldados en 'Baja Medica' o 'Fallecido'.
-- Regla 2: Un soldado no puede acaparar más de 2 armas al mismo tiempo.
CREATE OR REPLACE FUNCTION validar_entrega_armamento()
RETURNS TRIGGER AS $$
DECLARE
    v_estado_salud VARCHAR;
    v_armas_actuales INT;
BEGIN
    -- Solo validamos cuando se está asignando el arma a un soldado
    IF NEW.id_soldado IS NOT NULL THEN
        
        -- 1. Revisar su estado en el historial médico
        SELECT hm.estado_salud INTO v_estado_salud
        FROM soldado s
        JOIN historial_medico hm ON s.id_historial = hm.id_historial
        WHERE s.id_soldado = NEW.id_soldado;

        IF v_estado_salud IN ('Baja Medica', 'Fallecido') THEN
            RAISE EXCEPTION 'Automatización (Logística): No se puede asignar el arma % al soldado % porque su estado es [%].', 
                NEW.id_arma, NEW.id_soldado, v_estado_salud;
        END IF;

        -- 2. Contar cuántas armas tiene ya asignadas ese soldado
        SELECT COUNT(*) INTO v_armas_actuales
        FROM armamento
        WHERE id_soldado = NEW.id_soldado AND id_arma <> NEW.id_arma;

        IF v_armas_actuales >= 2 THEN
            RAISE EXCEPTION 'Automatización (Logística): El soldado % ya alcanzó el límite máximo de 2 armas asignadas.', NEW.id_soldado;
        END IF;

    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_validar_entrega_armamento ON armamento;

CREATE TRIGGER trg_validar_entrega_armamento
BEFORE INSERT OR UPDATE ON armamento
FOR EACH ROW
EXECUTE FUNCTION validar_entrega_armamento();

-- 5. XDISPARADORES (Código de limpieza para desinstalar la automatización)

-- DROP TRIGGER IF EXISTS trg_evitar_asignacion_baja_medica ON asignacion_mision;
-- DROP FUNCTION IF EXISTS verificar_salud_soldado();

-- DROP TRIGGER IF EXISTS trg_liberar_arma_fallecido ON historial_medico;
-- DROP FUNCTION IF EXISTS liberar_arma_por_fallecimiento();

-- DROP TRIGGER IF EXISTS trg_validar_entrega_armamento ON armamento;
-- DROP FUNCTION IF EXISTS validar_entrega_armamento();