SET SERVEROUTPUT ON;

DECLARE
    v_cliente_id       NUMBER := 1;
    v_total_pedidos    NUMBER;
    v_clasificacion    VARCHAR2(20);
BEGIN
    SELECT NVL(SUM(Total), 0)
    INTO v_total_pedidos
    FROM Pedidos
    WHERE ClienteID = v_cliente_id;

    /*
      Criterios propuestos:
      - Alto  : total >= 800
      - Medio : total >= 400 y < 800
      - Bajo  : total < 400
    */

    IF v_total_pedidos >= 800 THEN
        v_clasificacion := 'Alto';
    ELSIF v_total_pedidos >= 400 THEN
        v_clasificacion := 'Medio';
    ELSE
        v_clasificacion := 'Bajo';
    END IF;

    DBMS_OUTPUT.PUT_LINE('Cliente ID: ' || v_cliente_id);
    DBMS_OUTPUT.PUT_LINE('Total acumulado: ' || v_total_pedidos);
    DBMS_OUTPUT.PUT_LINE('Clasificación: ' || v_clasificacion);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No se encontraron pedidos para el cliente ' || v_cliente_id);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
END;
/
