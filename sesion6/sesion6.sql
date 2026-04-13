1-- 
SET SERVEROUTPUT ON;

DECLARE
    CURSOR detalle_cursor IS
        SELECT DetalleID, PedidoID, ProductoID, Cantidad
        FROM DetallesPedidos
        ORDER BY DetalleID DESC;

    v_detalleid   NUMBER;
    v_pedidoid    NUMBER;
    v_productoid  NUMBER;
    v_cantidad    NUMBER;
BEGIN
    OPEN detalle_cursor;

    LOOP
        FETCH detalle_cursor INTO v_detalleid, v_pedidoid, v_productoid, v_cantidad;
        EXIT WHEN detalle_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('DetalleID: ' || v_detalleid ||
                             ', PedidoID: ' || v_pedidoid ||
                             ', ProductoID: ' || v_productoid ||
                             ', Cantidad: ' || v_cantidad);
    END LOOP;

    CLOSE detalle_cursor;
END;
/

2--
SET SERVEROUTPUT ON;

DECLARE
    CURSOR pedido_cursor (p_cliente_id NUMBER) IS
        SELECT VALUE(p)
        FROM pedidos_obj p
        WHERE p.cliente_id = p_cliente_id
        FOR UPDATE;

    v_pedido       pedido_obj;
    v_nuevo_total  NUMBER;
BEGIN
    OPEN pedido_cursor(1);

    LOOP
        FETCH pedido_cursor INTO v_pedido;
        EXIT WHEN pedido_cursor%NOTFOUND;

        v_nuevo_total := v_pedido.total * 1.10;

        UPDATE pedidos_obj p
        SET VALUE(p) = pedido_obj(
            v_pedido.pedido_id,
            v_pedido.cliente_id,
            v_nuevo_total,
            v_pedido.fecha_pedido
        )
        WHERE CURRENT OF pedido_cursor;

        DBMS_OUTPUT.PUT_LINE('Pedido ' || v_pedido.pedido_id ||
                             ': Original ' || v_pedido.total ||
                             ', Nuevo ' || v_nuevo_total);
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



