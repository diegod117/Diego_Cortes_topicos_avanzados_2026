--1 
SET SERVEROUTPUT ON;

DECLARE
    CURSOR producto_cantidad (p_productoid NUMBER) IS
        SELECT Productoid, Cantidad
        FROM DetallesPedidos
        WHERE Productoid = p_productoid;

    v_productoid  NUMBER;
    v_cantidad    NUMBER;

BEGIN
    OPEN producto_cantidad(2);

    LOOP
        FETCH producto_cantidad INTO v_productoid, v_cantidad;
        EXIT WHEN producto_cantidad%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('Productoid: ' || v_productoid || ', Cantidad: ' || v_cantidad);
    END LOOP;

    CLOSE producto_cantidad;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);

        IF producto_cantidad%ISOPEN THEN
            CLOSE producto_cantidad;
        END IF;
END;
/

--2
SET SERVEROUTPUT ON;

DECLARE
    CURSOR pedido_cursor (p_cliente_id NUMBER) IS
        SELECT PedidoID, Total
        FROM Pedidos
        WHERE ClienteID = p_cliente_id
        FOR UPDATE;

    v_pedido_id NUMBER;
    v_total     NUMBER;

BEGIN
    OPEN pedido_cursor(1);

    LOOP
        FETCH pedido_cursor INTO v_pedido_id, v_total;
        EXIT WHEN pedido_cursor%NOTFOUND;

        UPDATE Pedidos
        SET Total = v_total * 1.10
        WHERE CURRENT OF pedido_cursor;

        DBMS_OUTPUT.PUT_LINE('Pedido ' || v_pedido_id ||
                             ': Original ' || v_total ||
                             ', Nuevo ' || (v_total * 1.10));
    END LOOP;

    CLOSE pedido_cursor;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);

        IF pedido_cursor%ISOPEN THEN
            CLOSE pedido_cursor;
        END IF;
END;
/

