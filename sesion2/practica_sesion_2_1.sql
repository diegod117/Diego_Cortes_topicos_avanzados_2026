2 sentencias Select simples
 
select * from productos where precio < 100;

PRODUCTOID NOMBRE                                                 PRECIO
---------- -------------------------------------------------- ----------
         2 Mouse                                                      25

 select detalleid from detallespedidos;

 DETALLEID
----------
         1
         2
         5

2 sentencias Select utilizando funciones 

SQL> select count(*) as cantidad from detallespedidos;

  CANTIDAD
----------
         3


 select avg(precio) as precio_medio from productos;

PRECIO_MEDIO
------------
       612.5

2 sentencias select utilizando expresiones regulares

select ciudad from clientes where ciudad = 'Santiago';

CIUDAD
--------------------------------------------------
Santiago
Santiago


> select clienteid from pedidos where clienteid >0 and clienteid < 2;

 CLIENTEID
----------
         1
         1


crear 2 vistas

 create view vista_cliente_pedido as select t1.nombre, t1.clienteid as id_en_clientes, t2.clienteid as id_en_pedidos from clientes t1 inner join pedidos t2 on t1.clienteid = t2.clienteid;
 
select * from vista_cliente_pedido;

NOMBRE                                             ID_EN_CLIENTES ID_EN_PEDIDOS
-------------------------------------------------- -------------- -------------
Juan Perez                                                      1             1
Juan Perez                                                      1             1
Mar??a Gomez


 create or replace view  vista_pedido_nombre_prod as select t1.nombre as nombre_en_productos, t2.productoid as id_producto_en_detallesp from productos t1 inner join detallespedidos t2 on t1.productoid = t2.productoid;

 select * from vista_pedido_nombre_prod;

NOMBRE_EN_PRODUCTOS                                ID_PRODUCTO_EN_DETALLESP
-------------------------------------------------- ------------------------
Laptop                                                                    1
Mouse                                                                     2













