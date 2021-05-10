use BluePrint

go

--Listar los nombres de proyecto y costo estimado de aquellos proyectos cuyo
--costo estimado sea mayor al promedio de costos.
select p.Nombre, p.CostoEstimado from Proyectos p
where (select avg(p.CostoEstimado) from Proyectos p) > p.CostoEstimado

go

--Listar razón social, cuit y contacto (email, celular o teléfono) de aquellos
--clientes que no tengan proyectos que comiencen en el año 2020.
select distinct c.RazonSocial, c.CUIT, COALESCE(c.EMail, c.Celular, c.Telefono, 'Sin Contacto') as Contacto from Clientes c
inner join Proyectos p on p.IDCliente = c.ID 
where p.FechaInicio not in
(
	select p.FechaInicio from Proyectos p
	where year(p.FechaInicio) = 2020
)

go

--Listado de países que no tengan clientes relacionados.
select * from Paises p
where p.ID not in 
(
	select distinct p.ID from Paises p
	inner join Ciudades c on c.IDPais = p.ID
	inner join Clientes cl on cl.IDCiudad = c.ID
)

go

--Listado de proyectos que no tengan tareas registradas.
select * from Proyectos p
where p.ID not in
(
	select distinct p.ID from Proyectos p
	inner join Modulos m on m.IDProyecto = p.ID
	inner join Tareas t on t.IDModulo = m.ID
)

go

--Listado de tipos de tareas que no registren tareas pendientes.
select * from TiposTarea t
where t.ID not in
(
	select distinct t.ID from TiposTarea T
	inner join Tareas ta on ta.IDTipo = t.ID
	where ta.FechaInicio is null or ta.Estado = 0 or ta.FechaFin> GETDATE()
)

go

--Listado con ID, nombre y costo estimado de proyectos cuyo costo estimado
--sea menor al costo estimado de cualquier proyecto de clientes extranjeros
--(clientes que sean de Argentina o no tengan asociado un país).
select p.ID, p.Nombre, p.CostoEstimado from Proyectos p
where p.CostoEstimado < 
(
	select min(p.CostoEstimado) from Proyectos p
	inner join Clientes c on c.ID = p.IDCliente
	left join Ciudades ci on ci.ID = c.IDCiudad
	left join Paises pa on pa.ID = ci.IDPais
	where pa.Nombre = 'Argentina' or c.IDCiudad is null
)

go

--Listado de apellido y nombres de colaboradores, que hayan demorado más en
--una tarea, que el colaborador de la ciudad de 'Buenos Aires' que más haya
--demorado.

select c.Nombre, c.Apellido from Colaboradores c
inner join Colaboraciones co on co.IDColaborador = c.ID
where co.Tiempo > 
(
	select max(c.Tiempo) from Colaboraciones c
	inner join Colaboradores co on co.ID = c.IDColaborador
	inner join Ciudades ci on ci.ID = co.IDCiudad
	where ci.Nombre = 'Buenos Aires'
)

go

--Listado de clientes indicando razón social, nombre del país (si tiene) y
--cantidad de proyectos comenzados y cantidad de proyectos por comenzar.
select c.RazonSocial, isnull(p.Nombre, 'Sin Pais'), 
(
	select count(*) from Proyectos po
	where po.IDCliente = c.ID and po.FechaInicio<=GETDATE()
) as 'Proyectos comenzados',
(
	select count(*) from Proyectos po
	where po.IDCliente = c.ID and po.FechaInicio>GETDATE()
) as 'Proyectos comenzar'
from Clientes c
left join Ciudades ci on ci.ID = c.IDCiudad
left join Paises p on p.ID = ci.IDPais

go

--Listado de tareas indicando nombre del módulo, nombre del tipo de tarea,
--cantidad de colaboradores externos que la realizaron y cantidad de
--colaboradores internos que la realizaron.
select m.Nombre, ti.Nombre, 
(
	select count(*) from Colaboradores c
	inner join Colaboraciones co on co.IDColaborador = c.ID
	where co.IDTarea = t.ID and c.Tipo = 'E'
) as 'Colaboradores Externos',
(
	select count(*) from Colaboradores c
	inner join Colaboraciones co on co.IDColaborador = c.ID
	where co.IDTarea = t.ID and c.Tipo = 'I'
) as 'Colaboradores Internos'
from Modulos m
inner join Tareas t on t.IDModulo = m.ID
inner join TiposTarea ti on ti.ID = t.IDTipo

go

--Listado de proyectos indicando nombre del proyecto, costo estimado,
--cantidad de módulos cuya estimación de fin haya sido exacta, cantidad de
--módulos con estimación adelantada y cantidad de módulos con estimación
--demorada.
--Adelantada → estimación de fin haya sido inferior a la real.
--Demorada → estimación de fin haya sido superior a la real.
select p.Nombre, p.CostoEstimado,
(
	select count(*) from Modulos m
	where m.FechaEstimadaFin = m.FechaFin and m.IDProyecto = p.ID
) as 'Estimacion Exacta',
(
	select count(*) from Modulos m
	where m.FechaEstimadaFin < m.FechaFin and m.IDProyecto = p.ID
) as 'Estimación Adelantada',
(
	select count(*) from Modulos m
	where m.FechaEstimadaFin > m.FechaFin and m.IDProyecto = p.ID
) as 'Estimación Demorada'
from Proyectos p

go

--Listado con nombre del tipo de tarea y total abonado en concepto de
--honorarios para colaboradores internos y total abonado en concepto de
--honorarios para colaboradores externos.
select t.Nombre, 
(
	select sum(c.PrecioHora * c.Tiempo) from Colaboraciones c
	inner join Colaboradores co on co.ID = c.IDColaborador
	inner join Tareas ta on ta.IDTipo = t.ID
	where co.Tipo = 'I' 
) as 'Total Abonado "I"',
(
	select sum(c.PrecioHora * c.Tiempo) from Colaboraciones c
	inner join Colaboradores co on co.ID = c.IDColaborador
	inner join Tareas ta on ta.IDTipo = t.ID
	where co.Tipo = 'E' 
) as 'Total Abonado "E"'
from TiposTarea t

go

--Listado con nombre del proyecto, razón social del cliente y saldo final del
--proyecto. El saldo final surge de la siguiente fórmula:
--Costo estimado - Σ(HCE) - Σ(HCI) * 0.1
--Siendo HCE → Honorarios de colaboradores externos y HCI → Honorarios de
--colaboradores internos.
select p.Nombre, c.RazonSocial,
(
	(
		select Coalesce(sum(co.PrecioHora), 0) from Colaboraciones co
		inner join Colaboradores col on col.ID = co.IDColaborador
		inner join Tareas t on  t.ID = co.IDTarea
		inner join Modulos m on m.ID = t.IDModulo
		where col.Tipo = 'E' and m.IDProyecto = p.ID
	) 
	-
	(
		select Coalesce(sum(co.PrecioHora), 0) from Colaboraciones co
		inner join Colaboradores col on col.ID = co.IDColaborador
		inner join Tareas t on  t.ID = co.IDTarea
		inner join Modulos m on m.ID = t.IDModulo
		where col.Tipo = 'I' and m.IDProyecto = p.ID
	)
	* 0.1
) as 'Saldo Final'
from Proyectos p
inner join Clientes c on c.ID = p.IDCliente

go

--Para cada módulo listar el nombre del proyecto, el nombre del módulo, el total
--en tiempo que demoraron las tareas de ese módulo y qué porcentaje de
--tiempo representaron las tareas de ese módulo en relación al tiempo total de
--tareas del proyecto.
select p.Nombre, m.Nombre, 
(
	select sum(c.Tiempo) from Colaboraciones c
	inner join Tareas t on t.ID = c.IDTarea
	where t.IDModulo = m.ID
) as TotalDemorado,
(
	(
		select isnull(sum(mo.TiempoEstimado), 0) from modulos mo
		where mo.IDProyecto = p.ID
	)
	*
	(
		select isnull(sum(c.Tiempo), 0) from Colaboraciones c
		inner join Tareas t on t.ID = c.IDTarea
		where t.IDModulo = m.ID
	) / 100
) as 'Porcentaje'
from Modulos m
inner join Proyectos p on p.ID = m.IDProyecto

go

--Por cada colaborador indicar el apellido, el nombre, 'Interno' o 'Externo' según
--su tipo y la cantidad de tareas de tipo 'Testing' que haya realizado y la
--cantidad de tareas de tipo 'Programación' que haya realizado.
--NOTA: Se consideran tareas de tipo 'Testing' a las tareas que contengan la
--palabra 'Testing' en su nombre. Ídem para Programación.
select c.Apellido, c.Nombre,
	case 
		when c.tipo
			like 'I' then 'Interno'
		else 'Externo'
	end as 'Tipo',
	(
		select count(*) from Colaboraciones co
		inner join Tareas t on t.ID = co.IDTarea
		inner join TiposTarea ti on ti.ID = t.IDTipo
		where co.IDColaborador = c.ID and ti.Nombre like '%Testing%'
	) as 'Tareas Testing',
	(
		select count(*) from Colaboraciones co
		inner join Tareas t on t.ID = co.IDTarea
		inner join TiposTarea ti on ti.ID = t.IDTipo
		where co.IDColaborador = c.ID and ti.Nombre like '%Programación%'
	) as 'Tareas Programador'
from Colaboradores c

go

--Listado apellido y nombres de los colaboradores que no hayan realizado
--tareas de 'Diseño de base de datos'.
select c.Apellido, c.Nombre from Colaboradores c
where c.ID not in
	(
		select distinct co.IDColaborador from Colaboraciones co
		inner join Tareas t on t.ID = co.IDTarea
		inner join TiposTarea ti on ti.ID = t.IDTipo
		where ti.Nombre like '%Diseño de base de datos%' and co.IDColaborador = c.ID
	)

--Por cada país listar el nombre, la cantidad de clientes y la cantidad de
--colaboradores.
select p.Nombre, 
(
	select count(*) from Colaboradores c
	inner join Ciudades ci on ci.ID = c.IDCiudad
	where ci.IDPais = p.ID
) as 'Cant Colaboradores',
(
	select count(*) from Clientes c
	inner join Ciudades ci on ci.ID = c.IDCiudad
	where ci.IDPais = p.ID
) as 'Cant Clientes'
from Paises p

--Listar por cada país el nombre, la cantidad de clientes y la cantidad de
--colaboradores de aquellos países que no tengan clientes pero sí
--colaboradores.
select Tabla.Nombre from
(
	select p.Nombre, 
		(
			select count(*) from Colaboradores c
			inner join Ciudades ci on ci.ID = c.IDCiudad
			where ci.IDPais = p.ID
		) as CantColaboradores,
		(
			select count(*) from Clientes c
			inner join Ciudades ci on ci.ID = c.IDCiudad
			where ci.IDPais = p.ID
		) as CantClientes
	from Paises p
) as Tabla
where Tabla.CantClientes = 0 and Tabla.CantColaboradores > 0

go

--Listar apellidos y nombres de los colaboradores internos que hayan realizado
--más tareas de tipo 'Testing' que tareas de tipo 'Programación'.
select tab.Apellido, tab.Nombre from 
(
	select c.Apellido, c.Nombre,
		(
			select count(*) from Tareas t
			inner join TiposTarea ti on ti.ID = t.IDTipo
			inner join Colaboraciones co on co.IDTarea = t.ID
			where co.IDColaborador = c.ID and ti.Nombre like '%Testing%'
		) as TareasTesting,
		(
			select count(*) from Tareas t
			inner join TiposTarea ti on ti.ID = t.IDTipo
			inner join Colaboraciones co on co.IDTarea = t.ID
			where co.IDColaborador = c.ID and ti.Nombre like '%Programación%'
		) as TareasProgramacion
	from Colaboradores c
	where c.Tipo = 'I'
) as Tab
where tab.TareasTesting > tab.TareasProgramacion

go

--Listar los nombres de los tipos de tareas que hayan abonado más del
--cuádruple (*4) en colaboradores internos que externos
select tab.Nombre from
(
	select t.Nombre,
	(
		select sum(c.PrecioHora * c.Tiempo) from Colaboraciones c
		inner join Colaboradores co on co.ID = c.IDColaborador
		inner join Tareas ta on ta.ID = c.IDTarea
		where ta.IDTipo = t.ID and co.Tipo = 'I'
	) as CantInternos,
	(
		select sum(c.PrecioHora * c.Tiempo) from Colaboraciones c
		inner join Colaboradores co on co.ID = c.IDColaborador
		inner join Tareas ta on ta.ID = c.IDTarea
		where ta.IDTipo = t.ID and co.Tipo = 'E'
	) as CantExternos
	from TiposTarea t
) as tab
where tab.CantInternos > tab.CantExternos *4

--Listar los proyectos que hayan registrado 
--igual cantidad de estimaciones demoradas que adelantadas
--y que al menos hayan registrado alguna estimación adelantada
--y que no hayan registrado ninguna estimación exacta.
select * from Proyectos p
where
(
	(
		select count(distinct m.ID) from Modulos m
		where m.IDProyecto = p.ID and m.FechaEstimadaFin > m.FechaFin
	) 
		=
	(
		select count(distinct m.ID) from Modulos m
		where m.IDProyecto = p.ID and m.FechaEstimadaFin < m.FechaFin 
	)
		and
	(
		select count(distinct m.ID) from Modulos m
		where m.IDProyecto = p.ID and m.FechaEstimadaFin < m.FechaFin 
	) 
		>0 and
	(
		select count(distinct m.ID) from Modulos m
		where m.IDProyecto = p.ID and m.FechaEstimadaFin = m.FechaFin 
	) 
		= 0
)