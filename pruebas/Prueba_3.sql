/*
Parte 1: Teórica (40 puntos)

PREGUNTA 1 (10 puntos)
Explica qué es una transacción en una base de datos y describe las propiedades
ACID. Luego, muestra a través de un ejemplo cómo usarías múltiples savepoints
para manejar errores parciales en un procedimiento que asigna un agente a un
incidente y actualiza simultáneamente el estado del incidente. ¿Qué ocurre si
falla solo la actualización del estado?

Respuesta 1: Una transacción en una base de datos es una unidad de trabajo que se ejecuta de manera completa o no se ejecuta en absoluto. 
Las propiedades ACID son: Atomicidad en la cual la transacción es indivisible, Consistencia donde la base de datos pasa de un estado válido a otro, 
Aislamiento en esta propiedad las transacciones concurrentes no interfieren entre sí y por ultimo la Durabilidad, aqui los cambios realizados por una transacción confirmada
son permanentes.


PREGUNTA 2 (10 puntos)
¿Qué es un Data Warehouse y cómo se diferencia de una base de datos
transaccional? Describe cómo diseñarías un modelo dimensional (tabla de hechos
y al menos dos dimensiones) para analizar las horas trabajadas por agente y
por severidad de incidente. ¿Qué ventajas tiene este modelo para consultas
analíticas versus consultar directamente las tablas transaccionales?

Respuesta 2: Un Data Warehouse es un sistema de almacenamiento de datos diseñado para consultas y análisis, mientras que una base de datos transaccional está optimizada para operaciones de lectura y escritura frecuentes.
Para diseñar un modelo dimensional para analizar las horas trabajadas por agente y por severidad de incidente, se podría crear una tabla de hechos llamada Fact_Asignaciones que contenga las métricas de horas trabajadas y referencias a las dimensiones Agente y Incidente.
La tabla de hechos incluiría columnas como AgenteID, IncidenteID, Horas, y FechaAsignacion. Las dimensiones serían Dim_Agente (con atributos como Nombre, Especialidad) y Dim_Incidente (con atributos como Severidad, Estado).
Las ventajas de este modelo para consultas analíticas incluyen un rendimiento mejorado en consultas agregadas, ya que las tablas de hechos y dimensiones están diseñadas para facilitar la agregación y el filtrado, mientras que consultar directamente las tablas transaccionales puede ser más lento y menos eficiente debido a la estructura normalizada y
la cantidad de datos.  


PREGUNTA 3 (10 puntos)
Explica cómo se implementa la herencia en Oracle usando tipos de objetos.
Da un ejemplo de una jerarquía de dos niveles: Agente → AgenteEspecialista →
AgentePentester, donde cada nivel agrega atributos y sobreescribe un método
calcular_costo(). ¿Qué implicancias tiene declarar un tipo como NOT
INSTANTIABLE?

Respuesta 3: En Oracle, la herencia se implementa mediante tipos de objetos. Un tipo de objeto puede heredar atributos y metodos de otro tipo de objeto, permitiendo la creación de jerarquías.
Por ejemplo, se puede definir un tipo base Agente con atributos como AgenteID y Nombre, y un método calcular_costo(). Luego, se puede crear un tipo derivado AgenteEspecialista que herede de Agente y agregue un atributo Especialidad y sobreescriba
el método calcular_costo() para reflejar costos específicos de especialistas. Finalmente, se puede crear otro tipo derivado AgentePentester que herede de AgenteEspecialista, agregando atributos adicionales y sobreescribiendo nuevamente el método calcular_costo().
Declarar un tipo como NOT INSTANTIABLE significa que no se pueden crear instancias directas de ese tipo; solo se pueden crear instancias de sus subtipos. Esto es útil para definir una clase base abstracta que proporciona una interfaz común y comportamiento compartido,
mientras que las implementaciones concretas se realizan en los subtipos. 

PREGUNTA 4 (10 puntos)
Describe las ventajas y desventajas de usar índices y particiones en una base
de datos. ¿Cómo usarías un índice compuesto y una partición por rango para
mejorar el rendimiento de consultas en la tabla Incidentes filtradas por
Severidad y FechaDeteccion? Explica qué es el partition pruning y cómo
impacta en el plan de ejecución.

Respuesta 4: Los índices mejoran el rendimiento de las consultas al permitir un acceso más rápido a los datos,
pero pueden ralentizar las operaciones de inserción, actualización y eliminación debido a la necesidad de mantener el índice.
Las particiones permiten dividir una tabla grande en partes más pequeñas, lo que facilita la gestión y mejora el rendimiento de las consultas al permitir que solo se acceda a las particiones relevantes.
Para mejorar el rendimiento de consultas en la tabla Incidentes filtradas por Severidad y FechaDeteccion,
se podría crear un índice compuesto en las columnas Severidad y FechaDeteccion.
Además, se podría particionar la tabla Incidentes por rango de FechaDeteccion, por ejemplo, creando particiones trimestrales para el año 2026.
El partition pruning es una técnica que permite al optimizador de consultas identificar y acceder solo a las particiones relevantes de una tabla durante la ejecución de una consulta,
en lugar de escanear toda la tabla.
Esto reduce significativamente el tiempo de ejecución y mejora el rendimiento de las consultas, ya que se evita el procesamiento innecesario de datos en particiones que no cumplen con los criterios de filtrado.

*/

/*
Parte 2: Ejercicios prácticos (60 puntos)


EJERCICIO 1 (20 puntos)
Escribe un procedimiento registrar_asignacion que reciba un AgenteID,
IncidenteID, Horas y Rol (parámetros IN). El procedimiento debe:
  a) Insertar una nueva asignación en Asignaciones (usa el próximo
     AsignacionID disponible).
  b) Validar que el agente no supere 100 horas totales asignadas en
     incidentes con Estado 'Abierto'.
  c) Validar que el incidente no tenga ya 3 o más agentes asignados.
  d) Usar savepoints independientes para cada validación, de modo que un
     fallo en una no deshaga operaciones previas válidas.
  e) Manejar todas las excepciones con mensajes descriptivos.
*/
-- Respuesta Ejercicio 1:El procedimiento registrar_asignacion se implementa de la siguiente manera:
CREATE OR REPLACE PROCEDURE registrar_asignacion (
    p_AgenteID   IN NUMBER,
    p_IncidenteID IN NUMBER,
    p_Horas      IN NUMBER,
    p_Rol        IN VARCHAR2
) AS
    v_total_horas   NUMBER;
    v_total_agentes NUMBER;
    v_next_asignacion_id NUMBER;
BEGIN
    -- Obtener el siguiente AsignacionID disponible
    SELECT NVL(MAX(AsignacionID), 0) + 1
      INTO v_next_asignacion_id
      FROM Asignaciones;

    -- Validación 1: horas totales del agente en incidentes Abiertos
    SAVEPOINT sp_horas;
    SELECT NVL(SUM(a.Horas), 0)
      INTO v_total_horas
      FROM Asignaciones a
      JOIN Incidentes i ON a.IncidenteID = i.IncidenteID
     WHERE a.AgenteID = p_AgenteID
       AND i.Estado = 'Abierto';

    v_total_horas := v_total_horas + p_Horas;
    IF v_total_horas > 100 THEN
        ROLLBACK TO sp_horas;
        RAISE_APPLICATION_ERROR(
            -20001,
            'Validación fallida: el agente ' || p_AgenteID ||
            ' excede 100 horas en incidentes Abiertos (total=' ||
            v_total_horas || ').'
        );
    END IF;

    -- Validación 2: máximo de 3 agentes por incidente
    SAVEPOINT sp_agentes;
    SELECT COUNT(*)
      INTO v_total_agentes
      FROM Asignaciones
     WHERE IncidenteID = p_IncidenteID;

    IF v_total_agentes >= 3 THEN
        ROLLBACK TO sp_agentes;
        RAISE_APPLICATION_ERROR(
            -20002,
            'Validación fallida: el incidente ' || p_IncidenteID ||
            ' ya tiene ' || v_total_agentes || ' agentes asignados.'
        );
    END IF;

    INSERT INTO Asignaciones (
        AsignacionID,
        AgenteID,
        IncidenteID,
        Horas,
        Rol
    ) VALUES (
        v_next_asignacion_id,
        p_AgenteID,
        p_IncidenteID,
        p_Horas,
        p_Rol
    );

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(
            -20099,
            'Error al registrar asignación: ' || SQLERRM
        );
END registrar_asignacion;
/


/*
EJERCICIO 2 (20 puntos)
Diseña las tablas Fact_Asignaciones, Dim_Agente y Dim_Incidente para un
Data Warehouse basado en la base de datos de la prueba. Luego, escribe una
consulta analítica sobre las tablas transaccionales que muestre, para cada
agente, el total de horas trabajadas y el número de incidentes atendidos,
ordenado de mayor a menor por total de horas.
*/    

--Respuesta Ejercicio 2: Para diseñar las tablas de un Data Warehouse, se pueden crear las siguientes estructuras
-- Dimensión: Agente
CREATE TABLE Dim_Agente (
  AgenteSK     NUMBER PRIMARY KEY,
  AgenteID     NUMBER,
  Nombre       VARCHAR2(50),
  Especialidad VARCHAR2(50),
  FechaIngreso DATE
);

-- Dimensión: Incidente
CREATE TABLE Dim_Incidente (
  IncidenteSK    NUMBER PRIMARY KEY,
  IncidenteID    NUMBER,
  Descripcion    VARCHAR2(100),
  Severidad      VARCHAR2(20),
  Estado         VARCHAR2(20),
  FechaDeteccion DATE
);

-- Tabla de hechos: Asignaciones (hechos de horas trabajadas)
CREATE TABLE Fact_Asignaciones (
  FactID      NUMBER PRIMARY KEY,
  AgenteSK    NUMBER,
  IncidenteSK NUMBER,
  Horas       NUMBER,
  FechaAsignacion DATE,
  CONSTRAINT fk_fact_agente FOREIGN KEY (AgenteSK) REFERENCES Dim_Agente(AgenteSK),
  CONSTRAINT fk_fact_incidente FOREIGN KEY (IncidenteSK) REFERENCES Dim_Incidente(IncidenteSK)
);

-- Opcional: ejemplo simple para poblar dimensiones desde las tablas transaccionales
-- (en un entorno real se usarían surrogates y procesos ETL más robustos)
INSERT INTO Dim_Agente (AgenteSK, AgenteID, Nombre, Especialidad, FechaIngreso)
SELECT AgenteID, AgenteID, Nombre, Especialidad, FechaIngreso FROM Agentes;

INSERT INTO Dim_Incidente (IncidenteSK, IncidenteID, Descripcion, Severidad, Estado, FechaDeteccion)
SELECT IncidenteID, IncidenteID, Descripcion, Severidad, Estado, FechaDeteccion FROM Incidentes;

COMMIT;

-- Consulta analítica sobre las tablas transaccionales (requerido)
SELECT a.AgenteID,
     ag.Nombre,
     SUM(a.Horas) AS TotalHoras,
     COUNT(DISTINCT a.IncidenteID) AS TotalIncidentes
FROM Asignaciones a
JOIN Agentes ag ON a.AgenteID = ag.AgenteID
GROUP BY a.AgenteID, ag.Nombre
ORDER BY TotalHoras DESC

/*
EJERCICIO 3 (20 puntos)
Crea un índice compuesto en Incidentes para las columnas Severidad y
FechaDeteccion. Luego, crea la tabla Incidentes particionada por rango de
FechaDeteccion (trimestral para 2026). Escribe una consulta que muestre el
total de horas asignadas por incidente para incidentes 'Critical' detectados
en el primer trimestre de 2026. Finalmente, muestra el plan de ejecución
con EXPLAIN PLAN e indica qué ventaja aporta la partición para esta consulta.
*/
--Respuesta Ejercicio 3: Para crear un índice compuesto en la tabla Incidentes para las columnas Severidad y FechaDeteccion, se puede usar la siguiente instruccion SQL:
CREATE INDEX idx_severidad_fecha ON Incidentes (Severidad, FechaDeteccion);
CREATE TABLE Incidentes_Partitioned (
    IncidenteID    NUMBER PRIMARY KEY,
    Descripcion    VARCHAR2(100),
    Severidad      VARCHAR2(20),
    Estado         VARCHAR2(20),
    FechaDeteccion DATE
) PARTITION BY RANGE (FechaDeteccion)
(
    PARTITION p_2026_q1 VALUES LESS THAN (TO_DATE('2026-04-01','YYYY-MM-DD')),
    PARTITION p_2026_q2 VALUES LESS THAN (TO_DATE('2026-07-01','YYYY-MM-DD')),
    PARTITION p_2026_q3 VALUES LESS THAN (TO_DATE('2026-10-01','YYYY-MM-DD')),
    PARTITION p_2026_q4 VALUES LESS THAN (TO_DATE('2027-01-01','YYYY-MM-DD')),
    PARTITION p_future  VALUES LESS THAN (MAXVALUE)
);

-- Volcar datos desde la tabla original
INSERT INTO Incidentes_Partitioned (IncidenteID, Descripcion, Severidad, Estado, FechaDeteccion)
SELECT IncidenteID, Descripcion, Severidad, Estado, FechaDeteccion FROM Incidentes;

COMMIT;
CREATE INDEX idx_severidad_fecha_part ON Incidentes_Partitioned (Severidad, FechaDeteccion);

SELECT i.IncidenteID,
       i.Descripcion,
       SUM(a.Horas) AS TotalHoras
FROM Incidentes_Partitioned i
JOIN Asignaciones a ON i.IncidenteID = a.IncidenteID
WHERE i.Severidad = 'Critical'
  AND i.FechaDeteccion BETWEEN TO_DATE('2026-01-01','YYYY-MM-DD') AND TO_DATE('2026-03-31','YYYY-MM-DD')
GROUP BY i.IncidenteID, i.Descripcion
ORDER BY TotalHoras DESC;

EXPLAIN PLAN FOR
SELECT i.IncidenteID,
       i.Descripcion,
       SUM(a.Horas) AS TotalHoras
FROM Incidentes_Partitioned i
JOIN Asignaciones a ON i.IncidenteID = a.IncidenteID
WHERE i.Severidad = 'Critical'
  AND i.FechaDeteccion BETWEEN TO_DATE('2026-01-01','YYYY-MM-DD') AND TO_DATE('2026-03-31','YYYY-MM-DD')
GROUP BY i.IncidenteID, i.Descripcion;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY());