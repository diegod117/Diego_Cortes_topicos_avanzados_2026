--PARTE 1
-- pregunta 1
/*Una relacion muchos a muchos es cuando 2 tablas se relacionan como por ejemplo tabla de agentes y de incidentes aqui existe esa relacion, ya que hay muchos incidentes asignados para muchos agentes y viceversa, por lo que se debe de crear una tabla intermediaria que permita la interaccion de estas.*/

SQL> create table asignacionesI_A

	AsignacionID PRIMARY KEY
	AgenteID NUMBER,
	InsidenteID NUMBER,
	CONSTRAINT FK_asignacion_agente FOREING KEY (AGENTEID) References Agentes(AgentesID)
	CONSTRAINT FK_asignacion_incidente FOREING KEY (INCIDENTEID) References Incidentes(INCIDENTESID)
	

--pregunta 2
/*Una vista es una especie de funcion que ocupamos para habitualmente hacer interactuar 2 tablas o 1 muy grande para mostrar lo que se nos pida o queramos que se vea.*/

SQL> crate view incidentes_sev_des as select  IncidenteID as inc, Descripcion as desc, Severidad as sev from tabla Incidentes;




-- pregunta 3
/* Una excepcion predfinida en PL/SQL es una excepcion que ya viene integrada en este lenguaje como por ejemplo la excepciones TimesTen que serian las TT8000, TT8001, etc.
Como se maneja una excepcion NO_DATA_FOUND en un bloque de PL/SQL, es basicamente con:
WHEN NO_DATA_FOUND THEN 
DBMS_OUTPUT.PUT_LINE('Error: No se encontro el dato') */


-- pregunta 4 
/*Un cursor explicito es una especie de procedimiento que se selecciona una variable de una tabla y esta es actualizada; por ejemplo con las tablas se hace un cursor para actualizar fechas de los insidentes, o para actualizar, su severidad o incluso su estado.
Y el proposito del cursor %NOTFOUND es cuando por ejemplo se cree el cursor y el dato no exista en la tabla que se quiere buscar esto hace que salga cuando no se encuentre, y sus atributos son que se ocupa con el FETCH que es buscar.*/


--PARTE 2

-- ejercicio 1



-- ejercicio 2


-- ejercicio 3 




