--1
-- Crear índice compuesto​

CREATE INDEX idx_detalles_pedido_producto ON DetallesPedidos(PedidoID, ProductoID);​

​

-- Consulta que usa el índice​

EXPLAIN PLAN FOR​

SELECT * FROM DetallesPedidos​

WHERE PedidoID = 108 AND ProductoID = 1;​

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);​

​

-- Ejecutar la consulta​

SELECT * FROM DetallesPedidos​

WHERE PedidoID = 108 AND ProductoID = 1;​ 

--2
-- Crear tabla Ventas particionada por hash​

CREATE TABLE Ventas (​

	VentaID NUMBER PRIMARY KEY,​

	ClienteID NUMBER,​

	Total NUMBER,​

	FechaVenta DATE​

)​

PARTITION BY HASH (ClienteID)​

PARTITIONS 4;​

​

-- Insertar datos desde Pedidos​

INSERT INTO Ventas (VentaID, ClienteID, Total, FechaVenta)​

SELECT PedidoID, ClienteID, Total, FechaPedido​

FROM Pedidos;​

​

-- Consulta que usa las particiones​

EXPLAIN PLAN FOR​

SELECT ClienteID, SUM(Total) AS TotalVentas​

FROM Ventas​

GROUP BY ClienteID;​

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);​

​

-- Ejecutar la consulta​

SELECT ClienteID, SUM(Total) AS TotalVentas​

FROM Ventas​

GROUP BY ClienteID;​