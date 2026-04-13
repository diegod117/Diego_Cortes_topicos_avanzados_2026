1-- 
SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE aumentar_precio_producto(
    p_producto_id IN NUMBER,
    p_porcentaje  IN NUMBER
) AS
BEGIN
    UPDATE Productos
    SET Precio = Precio * (1 + p_porcentaje / 100)
    WHERE ProductoID = p_producto_id;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Producto con ID ' || p_producto_id || ' no encontrado.');
    END IF;

    DBMS_OUTPUT.PUT_LINE('Precio del producto ' || p_producto_id ||
                         ' aumentado en ' || p_porcentaje || '%.');
    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
/*prueba
EXEC aumentar_precio_producto(2, 10);
*/ 

2--
SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE contar_pedidos_cliente(
    p_cliente_id IN NUMBER,
    p_cantidad   OUT NUMBER
) AS
BEGIN
    SELECT COUNT(*)
    INTO p_cantidad
    FROM Pedidos
    WHERE ClienteID = p_cliente_id;
END;
/

/*prueba 
DECLARE
    v_cantidad NUMBER;
BEGIN
    contar_pedidos_cliente(1, v_cantidad);
    DBMS_OUTPUT.PUT_LINE('Cliente 1 tiene ' || v_cantidad || ' pedidos.');
END;
/
*/ 
