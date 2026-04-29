-- practico 1

SET SERVEROUTPUT ON;

-- Función
CREATE OR REPLACE FUNCTION calcular_total_con_descuento(
    p_pedido_id IN NUMBER
) RETURN NUMBER AS
    v_total NUMBER;
BEGIN
    SELECT Total
    INTO v_total
    FROM Pedidos
    WHERE PedidoID = p_pedido_id;

    IF v_total > 1000 THEN
        v_total := v_total * 0.9; -- 10% de descuento
    END IF;

    RETURN v_total;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20004, 'Pedido con ID ' ||
                                p_pedido_id || ' no encontrado.');
END;
/

--Procedimiento
CREATE OR REPLACE PROCEDURE aplicar_descuento_pedido(
    p_pedido_id IN NUMBER
) AS
    v_nuevo_total NUMBER;
BEGIN
    v_nuevo_total := calcular_total_con_descuento(p_pedido_id);

    UPDATE Pedidos
    SET Total = v_nuevo_total
    WHERE PedidoID = p_pedido_id;

    DBMS_OUTPUT.PUT_LINE('Total del pedido ' || p_pedido_id ||
                         ' actualizado a: ' || v_nuevo_total);
    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
END;
/


/*Prueba
EXEC aplicar_descuento_pedido(101);
EXEC aplicar_descuento_pedido(103);*/

-- practico 2

SET SERVEROUTPUT ON;

CREATE OR REPLACE TRIGGER validar_cantidad_detalle
BEFORE INSERT OR UPDATE ON DetallesPedidos
FOR EACH ROW
BEGIN
    IF :NEW.Cantidad <= 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'La cantidad debe ser mayor a 0.');
    END IF;
END;
/

/*Prueba: esto falla por cantidad negativa
INSERT INTO DetallesPedidos (DetalleID, PedidoID, ProductoID, Cantidad)
VALUES (3, 101, 2, -1);

Prueba: esto sí se inserta correctamente
INSERT INTO DetallesPedidos (DetalleID, PedidoID, ProductoID, Cantidad)
VALUES (3, 101, 2, 3);
*/

