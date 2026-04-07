
--1
SET SERVEROUTPUT ON;

DECLARE
    v_pedido_id       NUMBER := 102;
    v_total           NUMBER;
    pedido_invalido   EXCEPTION;
BEGIN
    SELECT Total
    INTO v_total
    FROM Pedidos
    WHERE PedidoID = v_pedido_id;

    IF v_total < 500 THEN
        RAISE pedido_invalido;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Pedido ID: ' || v_pedido_id);
    DBMS_OUTPUT.PUT_LINE('Total del pedido: ' || v_total);

EXCEPTION
    WHEN pedido_invalido THEN
        DBMS_OUTPUT.PUT_LINE('Error: el total del pedido es menor al bias permitido.');
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: ID de pedido no fue encontrado.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
END;
/


--2


SET SERVEROUTPUT ON;

DECLARE
BEGIN
    INSERT INTO Clientes (ClienteID, Nombre, Ciudad, FechaNaci)
    VALUES (1, 'Carlos Ruiz', 'Concepcion', DATE '1998-06-10');

    DBMS_OUTPUT.PUT_LINE('Cliente insertado correctamente.');

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Error: no se puede insertar el cliente porque el ID ya existe.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
END;
/
