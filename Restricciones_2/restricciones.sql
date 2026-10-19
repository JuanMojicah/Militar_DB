
--me habia salido un error al hacer la restriccion ya que al haber creado los casi 12k 
--de datos algunos fueron llenados con dañada, por lo que aca estamos haciendo un update 
--para corregir eso
UPDATE armamento SET id_soldado = NULL WHERE estado_arma = 'Dañada';


--Tuplas
ALTER TABLE armamento 
ADD CONSTRAINT chk_arma_danada_sin_soldado 
CHECK (NOT (estado_arma = 'Dañada' AND id_soldado IS NOT NULL));


--Acciones (ON DELETE CASCADE)

-- Eliminar la restricción anterior (usando IF EXISTS para evitar errores si ya se borró)
ALTER TABLE asignacion_mision 
DROP CONSTRAINT IF EXISTS asignacion_mision_id_mision_fkey;

-- Aplicar la acción de referencia en cascada
ALTER TABLE asignacion_mision 
ADD CONSTRAINT asignacion_mision_id_mision_fkey 
FOREIGN KEY (id_mision) REFERENCES mision(id_mision) ON DELETE CASCADE;

--Disparadores (Automatización de Historial Médico)

-- 1. Crear la función del disparador
CREATE OR REPLACE FUNCTION verificar_salud_soldado()
RETURNS TRIGGER AS $$
DECLARE
    estado_actual VARCHAR;
BEGIN
    SELECT hm.estado_salud INTO estado_actual
    FROM soldado s
    JOIN historial_medico hm ON s.id_historial = hm.id_historial
    WHERE s.id_soldado = NEW.id_soldado;

    IF estado_actual = 'Baja Medica' THEN
        RAISE EXCEPTION 'Automatización: El soldado % está de Baja Médica y no puede ir a misiones', NEW.id_soldado;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Crear el disparador en la tabla
DROP TRIGGER IF EXISTS trg_evitar_asignacion_baja_medica ON asignacion_mision;

CREATE TRIGGER trg_evitar_asignacion_baja_medica
BEFORE INSERT ON asignacion_mision
FOR EACH ROW
EXECUTE FUNCTION verificar_salud_soldado();



--Disparador (Soldado caído en batalla)
-- 1. Creamos la función
CREATE OR REPLACE FUNCTION liberar_arma_por_fallecimiento()
RETURNS TRIGGER AS $$
DECLARE
    v_id_soldado INT;
BEGIN
    -- Si el estado de salud se actualiza a 'Fallecido'
    IF NEW.estado_salud = 'Fallecido' THEN
        
        -- Buscamos cuál es el ID del soldado dueño de este historial
        SELECT id_soldado INTO v_id_soldado 
        FROM soldado 
        WHERE id_historial = NEW.id_historial;
        
        -- Le quitamos el arma (queda en NULL) pero NO cambiamos el estado del arma
        UPDATE armamento 
        SET id_soldado = NULL 
        WHERE id_soldado = v_id_soldado;
        
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Creamos el disparador que reacciona al UPDATE en historial_medico
DROP TRIGGER IF EXISTS trg_liberar_arma_fallecido ON historial_medico;

CREATE TRIGGER trg_liberar_arma_fallecido
AFTER UPDATE ON historial_medico
FOR EACH ROW
EXECUTE FUNCTION liberar_arma_por_fallecimiento();



-- XDisparadores: Código para eliminar la automatización
-- DROP TRIGGER IF EXISTS trg_evitar_asignacion_baja_medica ON asignacion_mision;
-- DROP FUNCTION IF EXISTS verificar_salud_soldado();