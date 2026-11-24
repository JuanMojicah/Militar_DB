-- pruebas
--Historia 1: El primer amanecer en Arauca
​--historia: En noviembre de 2026, la tensión en la frontera de Arauca obliga
-- a abrir un nuevo punto de control. Andrés Felipe Torres, un joven soldado recién salido de 
--instrucción, se prepara para su primer despliegue real: pasa su revisión médica, recibe su fusil de 
--dotación y parte con su pelotón al caer la tarde.

--​Qué hacemos en la DB: Alta de infraestructura (Base Avanzada Sierra), creación del historial 
--médico e ingreso del nuevo soldado (Andrés Felipe Torres), dotación de armamento operativ o (WPN-99997001)
-- y lanzamiento de la misión (Operación Centinela).

-- Paso 1: El Administrador de Infraestructura habilita una nueva base operativa
SET ROLE rol_admin_infraestructura;
CALL pa_admin_infraestructura.adicionar_base_militar(9701, 'Base Avanzada Sierra', 'Arauca');
RESET ROLE;

-- Paso 2: El Oficial de Sanidad realiza el examen de ingreso y crea el historial médico
SET ROLE rol_oficial_sanidad;
CALL pa_oficial_sanidad.adicionar_historial_medico(9701, 'O+', 'Ninguna', 'Optimo');
RESET ROLE;

-- Paso 3: El Oficial de Personal da de alta al soldado con su historial médico
SET ROLE rol_oficial_personal;
CALL pa_oficial_personal.adicionar_soldado(9701, 'Andres Felipe Torres', 1, 1, 1, 9701);

-- Verificación 1: El soldado debe aparecer en la vista de soldados activos
SELECT * FROM info_soldados_activos WHERE id_soldado = 9701;
RESET ROLE;

-- Paso 4: El Oficial Logístico le asigna un fusil operativo al soldado
SET ROLE rol_oficial_logistico;
CALL pa_oficial_logistico.adicionar_armamento(9701, 'WPN-99997001', 'Operativa', 1, 9701);

-- Verificación 2: El arma debe aparecer asignada a Andres Felipe Torres en la vista activa
SELECT * FROM info_armamento_activo WHERE numero_serie = 'WPN-99997001';
RESET ROLE;

-- Paso 5: El Comandante de Operaciones inicia la misión de despliegue
SET ROLE rol_comandante_operaciones;
CALL pa_comandante_operaciones.adicionar_mision(9701, 'Operacion Centinela', '2026-11-22', 'En Progreso');

-- Verificación 3: Consultar la misión recién creada mediante el servicio del actor
BEGIN;
SELECT pa_comandante_operaciones.consultar_mision(9701);
FETCH ALL IN cur_mision;
COMMIT;
RESET ROLE;

--​Historia 2 : El regreso silencioso de Centinela (complementaria a la h1)
--historia: Tres días después, la patrulla sufre una emboscada durante el repliegue nocturno. 
--El pelotón logra asegurar la zona, pero Andrés cae en combate. De regreso en la base, sanidad 
--reporta su fallecimiento, sus compañeros devuelven su fusil a la armería para revisión y el mando 
--cierra la operación.

​--Qué hacemos en la DB: Reporte de fallecimiento del mismo soldado, 
--liberación automática del arma por trigger (trg_liberar_arma_fallecido), envío del fusil a 
--mantenimiento logístico y cierre de la misión (Completada).

-- Flujo: Infraestructura -> Sanidad -> Personal -> Logística -> Operaciones

-- Paso 1: El Oficial de Sanidad reporta el fallecimiento del soldado 9701
-- (Dispara automáticamente trg_liberar_arma_fallecido: libera el arma sin dañarla)
SET ROLE rol_oficial_sanidad;
CALL pa_oficial_sanidad.modificar_historial_medico(9701, 'Fallecido', 'Ninguna');
RESET ROLE;

-- Paso 2: El Oficial de Personal verifica que el soldado ya NO figura como activo
-- (Debe devolver 0 filas)
SET ROLE rol_oficial_personal;
SELECT * FROM info_soldados_activos WHERE id_soldado = 9701;
RESET ROLE;

-- Paso 3: El Oficial Logístico audita el arma 9701 y confirma que volvió al inventario (id_soldado = NULL)
SET ROLE rol_oficial_logistico;
BEGIN;
SELECT pa_oficial_logistico.consultar_armamento(9701);
FETCH ALL IN cur_armamento;
COMMIT;

-- El Oficial Logístico envía el arma recuperada a mantenimiento preventivo
CALL pa_oficial_logistico.modificar_armamento(9701, 'En Mantenimiento', NULL);
RESET ROLE;

-- Paso 4: El Comandante de Operaciones da por finalizada la misión
SET ROLE rol_comandante_operaciones;
CALL pa_comandante_operaciones.modificar_mision(9701, 'Completada', NULL);

-- Verificación final: Confirmar estado 'Completada' de la misión
BEGIN;
SELECT pa_comandante_operaciones.consultar_mision(9701);
FETCH ALL IN cur_mision;
COMMIT;
RESET ROLE;



-- LIMPIEZA DE DATOS DE LAS HISTORIAS (por si acaso para pruebas)

-- SET ROLE rol_comandante_operaciones;
-- CALL pa_comandante_operaciones.eliminar_mision(9701);
-- RESET ROLE;
--
-- SET ROLE rol_oficial_logistico;
-- CALL pa_oficial_logistico.eliminar_armamento(9701);
-- RESET ROLE;
--
-- SET ROLE rol_oficial_personal;
-- CALL pa_oficial_personal.eliminar_soldado(9701);
-- RESET ROLE;
--
-- SET ROLE rol_admin_infraestructura;
-- CALL pa_admin_infraestructura.eliminar_base_militar(9701);
-- RESET ROLE;
