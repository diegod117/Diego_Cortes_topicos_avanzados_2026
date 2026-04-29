-- practico 1

SET SERVEROUTPUT ON;

CREATE OR REPLACE FUNCTION calcular_edad_cliente(
    p_cliente_id IN NUMBER
) RETURN NUMBER AS
    v_fecha_nacimiento DATE;
    v_edad             NUMBER;
BEGIN
    SELECT FechaNaci
    INTO v_fecha_nacimiento
    FROM Clientes
    WHERE ClienteID = p_cliente_id;

    v_edad := FLOOR(MONTHS_BETWEEN(SYSDATE, v_fecha_nacimiento) / 12);

    RETURN v_edad;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'Cliente con ID ' ||
                                p_cliente_id || ' no encontrado.');
END;
/

-- Prueba
DECLARE
    v_edad NUMBER;
BEGIN
    v_edad := calcular_edad_cliente(1);
    DBMS_OUTPUT.PUT_LINE('Edad del cliente 1: ' || v_edad);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

-- practico 2 

SET SERVEROUTPUT ON;

CREATE OR REPLACE FUNCTION obtener_precio_promedio
RETURN NUMBER AS
    v_promedio NUMBER;
BEGIN
    SELECT AVG(Precio)
    INTO v_promedio
    FROM Productos;

    RETURN v_promedio;
END;
/

/*Consulta SQL usando la función
SELECT Nombre, Precio
FROM Productos
WHERE Precio > obtener_precio_promedio();*/