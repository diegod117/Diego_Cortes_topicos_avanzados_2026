/*Crea un procedimiento actualizar_precios_por_categoria que reciba un porcentaje de au
mento (parámetro IN) y aplique el aumento solo a productos 
cuyo precio promedio por pedido (calculado con una función) sea mayor a 500. 
Usa un cursor para iterar sobre los productos.*/

CREATE OR REPLACE FUNCTION precio_promedio_por_pedido(p_ProductoID INT) RETURN NUMBER IS
    v_precio_promedio NUMBER;
BEGIN
    SELECT AVG(P.Total / D.Cantidad) INTO v_precio_promedio
    FROM DetallesPedidos D
    JOIN Pedidos P ON D.PedidoID = P.PedidoID
    WHERE D.ProductoID = p_ProductoID;
    RETURN v_precio_promedio;   
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0; -- Si no hay pedidos para el producto, el precio promedio es 0
END;
/
DELIMITER //
CREATE PROCEDURE actualizar_precios_por_categoria(IN p_aumento_porcentaje NUMBER)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_ProductoID INT;
    DECLARE v_PrecioPromedio NUMBER;
    DECLARE cur CURSOR FOR SELECT ProductoID FROM Productos;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_ProductoID;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Calcular el precio promedio por pedido para el producto
        v_PrecioPromedio := precio_promedio_por_pedido(v_ProductoID);

        -- Si el precio promedio es mayor a 500, aplicar el aumento
        IF v_PrecioPromedio > 500 THEN
            UPDATE Productos
            SET Precio = Precio * (1 + p_aumento_porcentaje / 100)
            WHERE ProductoID = v_ProductoID;
        END IF;
    END LOOP;

    CLOSE cur;
END //  
DELIMITER ;


/*Crea un trigger auditar_eliminacion_pedido que se dispare después de eliminar un pedido
 y registre el PedidoID, ClienteID, Total y la fecha de eliminación en una
  tabla de auditoría AuditoriaPedidos.*/
  
CREATE TABLE AuditoriaPedidos (
    AuditoriaID NUMBER PRIMARY KEY,
    PedidoID NUMBER,
    ClienteID NUMBER,
    Total NUMBER,
    FechaEliminacion DATE
);
DELIMITER //
CREATE TRIGGER auditar_eliminacion_pedido
AFTER DELETE ON Pedidos
FOR EACH ROW
BEGIN
    INSERT INTO AuditoriaPedidos (AuditoriaID, PedidoID, ClienteID, Total, FechaEliminacion)
    VALUES (AuditoriaPedidos_SEQ.NEXTVAL, OLD.PedidoID, OLD.ClienteID, OLD.Total, SYSDATE);
END //
DELIMITER ;
