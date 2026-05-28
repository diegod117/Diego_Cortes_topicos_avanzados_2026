--Parte 1 

--Pregunta 1 :
/* Explica la diferencia entre un
procedimiento almacenado y una función almacenada en 
PL/SQL. Da un ejemplo de cuándo usarías cada uno en el
 contexto de la base de datos de la prueba.
 
 Respuesta: Un procedimiento almacennado es un bloque de codigo que realiza una tarea especifica y no devuelve un valor,
    en cambio la funcion almacenada es un bloque de codigo que realiza una tarea especifica y devuelve un valor, en este contexto se podria usar un
    procedimiento almacenado para actualizar el estado de un incidente, mientras que una función almacenada podría usarse para calcular el total de horas
    asignadas a un incidente y devolver ese valor para su uso en consultas o reportes.
 */


--Pregunta 2 :
 /* Describe cómo usarías un parámetro IN 
 OUT en un procedimiento almacenado. Escribe un 
 ejemplo de un procedimiento que use un parámetro
  IN OUT para actualizar y devolver las horas de una 
  asignación después de un ajuste.

  Respuesta: Un parámetro IN OUT en un procedimiento 
  almacenado se utiliza para pasar un valor al procedimiento,
  permitir que el procedimiento lo modifique y luego devolver el valor modificado al llamador. 
  En el contexto de la base de datos de la prueba, podríamos usar un procedimiento con un parámetro IN OUT para 
  ajustar las horas asignadas a una tarea específica y devolver el nuevo total de horas después del ajuste.

CREATE OR REPLACE PROCEDURE ajustar_horas_asignacion(
    p_asignacion_id IN NUMBER,
    p_ajuste IN NUMBER,
    p_nuevo_total OUT NUMBER
) AS
BEGIN
    -- Obtener las horas actuales de la asignación
    SELECT Horas INTO p_nuevo_total
    FROM Asignaciones
    WHERE AsignacionID = p_asignacion_id;

    -- Ajustar las horas
    p_nuevo_total := p_nuevo_total + p_ajuste;

    -- Actualizar la tabla con el nuevo total de horas
    UPDATE Asignaciones
    SET Horas = p_nuevo_total
    WHERE AsignacionID = p_asignacion_id;

    DBMS_OUTPUT.PUT_LINE('Horas ajustadas para la asignación ' || p_asignacion_id ||
                         '. Nuevo total de horas: ' || p_nuevo_total);
    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Asignación con ID ' || p_asignacion_id || ' no encontrada.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
END;
/

  */



 --Pregunta 3 :
/* ¿Cómo se puede usar una función 
almacenada dentro de una consulta SQL? Escribe
 un ejemplo de una función que calcule el total de
  horas asignadas a un incidente y úsala en una 
  consulta para listar los incidentes con su total de horas.

  Respuesta: la funcion almacenada se puede usar dentro de una consulta SQL como cualquier otra funcion,
    siempre y cuando se le pasen los parametros necesarios.

  Por ejemplo:

  CREATE OR REPLACE FUNCTION calcular_horas_incidente(
    p_incidente_id IN NUMBER)
    RETURN NUMBER AS)
    v_total_horas NUMBER;
BEGIN
    SELECT SUM(Horas)
    INTO v_total_horas
    FROM Asignaciones
    WHERE IncidenteID = p_incidente_id;
    RETURN v_total_horas;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0; -- Si no hay asignaciones, retornar 0 horas
END;
/
-- Consulta SQL usando la función
SELECT i.IncidenteID, i.Descripcion, calcular_horas_incidente(i.IncidenteID) AS TotalHoras
FROM Incidentes i;

  */




--Pregunta 4 :
/* Explica qué es un trigger y menciona 
dos tipos de eventos que pueden dispararlo. 
Da un ejemplo de un trigger que se dispare después de 
insertar una asignación en la tabla Asignaciones y 
actualice el estado del incidente a 'En Proceso' si
 estaba en 'Abierto'.

 Respuesta: Un trigger es un bloque de código que se ejecuta
  automáticamente cuando ocurre un evento específico en la base de datos.
   Dos tipos de eventos que pueden disparar un trigger son INSERT y UPDATE. 
   Un ejemplo de trigger sería uno que se dispare después de insertar una asignación en la tabla Asignaciones y 
   actualice el estado del incidente a 'En Proceso' si estaba en 'Abierto'.
   
   EJEMPLO:
   CREATE OR REPLACE TRIGGER actualizar_estado_incidente
AFTER INSERT ON Asignaciones
FOR EACH ROW
BEGIN
    UPDATE Incidentes
    SET Estado = 'En Proceso'
    WHERE IncidenteID = :NEW.incidenteid
      AND Estado = 'Abierto';
      END;
/

 */

 
 
 
--Parte2



--Ejercicio 1 :   
/*Escribe un procedimiento registrar_asignacion que reciba
 un AgenteID, IncidenteID, Horas y Rol(parametros IN).
 El procedimiento debe:
 1 Incertar una nueva asignacion en la tabla Asignaciones(usa el proximo AsignacionID disponible). 
 2 Actualizar el estado del incidente a 'En Proceso' si estaba en 'Abierto'.
 3 Manejar excepciones si el agente o incidente no existen, o si el agente ya esta asignado a ese incidente.
*/
CREATE OR REPLACE PROCEDURE registrar_asignacion(
    P_AgenteID IN NUMBER,
    P_IncidenteID IN NUMBER,
    P_Horas IN NUMBER,
    P_Rol IN VARCHAR2
    )AS
    v_asignacion_id NUMBER;
    v_estado_incidente VARCHAR2(20);
    BEGIN  
    -- Verificar que el agente existe
    SELECT COUNT(*) INTO v_asignacion_id FROM Agentes WHERE AgenteID = P_AgenteID;
    IF v_asignacion_id = 0 THEN
        RAISE__APPLICATION_ERROR(-20002, 'Agente con ID ' // P_AgenteID // ' no encontrado.');
        END IF;
        -- Verificar que el incidente existe
        SELECT Estado INTO v_estado_incidente FROM Incidentes WHERE IncidenteID = P_IncidenteID;
        IF SQL%NOTFOUND THEN
            RAISE_APPLICATION_ERROR(-20003, 'Incidente con ID ' // P_IncidenteID // ' no encontrado.');
            END IF;
            -- Verificar que el agente no este ya asignado o no este asignado a ese incidente
            SELECT COUNT(*) INTO v_asignacion_id FROM Asignaciones WHERE AgenteID = P_AgenteID AND IncidenteID = P_IncidenteID;
            IF v_asignacion_id > 0 THEN
                RAISE_APPLICATION_ERROR(-20004, 'Agente con ID ' // P_AgenteID // ' ya esta asignado al incidente ' // P_IncidenteID);
                END IF;
                -- Obtener el proximo AsignacionID disponible
                SELECT NVL(MAX(AsignacionID), 0) + 1 INTO v_asignacion_id FROM Asignaciones;
                -- Insertar la nueva asignacion
                INSERT INTO Asignaciones (AsignacionID, AgenteID, IncidenteID, Horas, Rol)
                VALUES (v_asignacion_id, P_AgenteID, P_IncidenteID, P_Horas, P_Rol):
                -- Actualizar el estado del incidente a 'En Proceso' si estaba en 'Abierto'
                IF v_estado_incidente = 'Abierto' THEN
                    UPDATE Incidentes
                    SET Estado = 'En Proceso'
                    WHERE IncidenteID = P_IncidenteID;
                    END IF;
                    DBMS_OUTPUT.PUT_LINE('Asignacion registrada correctamente. AsignacionID: ' // v_asignacion_id);
                    COMMIT;
                    EXCEPTION
                    WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('Error: ' // SQLERRM);
                    ROLLBACK;
                    END; 
/
* Prueba del procedimiento
BEGIN
    registrar_asignacion(101, 202, 30, 'Apoyo');
    registrar_asignacion(102, 203, 20, 'Lider');
    registrar_asignacion(103, 204, 25, 'Apoyo');
    registrar_asignacion(104, 205, 15, 'Lider');
    registrar_asignacion(105, 201, 10, 'Apoyo');
END;    
/


-- Ejercicio 3 :
/* Implementa un sistema de auditoría manual usando un trigger. 
Para esto, primero crea una tabla llamada AuditoriaAsignaciones 
con las columnas necesarias. Luego, crea un trigger auditar_asignaciones 
que se dispare después de insertar o eliminar una asignación en la tabla Asignaciones. 
El trigger debe registrar en la tabla de auditoría el AsignacionID, AgenteID, IncidenteID, Horas, la 
acción realizada ('INSERT' o 'DELETE') y la fecha del registro.
*/

CREATE TABLE AuditoriaAsignaciones (
    AsignacionID NUMBER,
    AgenteID NUMBER,
    IncidenteID NUMBER,
    Horas NUMBER,
    Accion VARCHAR2(10),
    FechaRegistro DATE
);

CREATE OR REPLACE TRIGGER auditar_asignaciones
AFTER INSERT OR DELETE ON Asignaciones
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO AuditoriaAsignaciones (AsignacionID, AgenteID, IncidenteID, Horas, Accion, FechaRegistro)
        VALUES (:NEW.AsignacionID, :NEW.AgenteID, :NEW.IncidenteID, :NEW.Horas, 'INSERT', SYSDATE);
    ELSIF DELETING THEN
        INSERT INTO AuditoriaAsignaciones (AsignacionID, AgenteID, IncidenteID, Horas, Accion, FechaRegistro)
        VALUES (:OLD.AsignacionID, :OLD.AgenteID, :OLD.IncidenteID, :OLD.Horas, 'DELETE', SYSDATE);
    END IF;
END;
/




