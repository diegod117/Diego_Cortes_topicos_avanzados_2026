declare 
cursor detalle_cursor is 
	select * from detallespedidos
	group by detalleid;
	order by detalleid desc;
	d_detalle detallespedidos;
begin 
	open detalle_cursor;
	loop
		fetch detalle_cursor into d_detalle;
		exit when detalle_cursor%NOTFOUND;
		DBMS_OUTPUT.PUT_LINE(d_detalle.get_info());
	end loop;
	close detalle_cursor
end;
/
