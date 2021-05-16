--Por cada colaborador listar el apellido y nombre y la cantidad de proyectos
--distintos en los que haya trabajado
select c.Apellido, c.Nombre, count(distinct p.ID) as 'Cant Proyectos' from Colaboradores c
inner join Colaboraciones co on co.IDColaborador = c.ID
inner join Tareas t on t.ID = co.IDTarea
inner join Modulos m on m.ID = t.IDModulo
inner join Proyectos p on p.ID = m.IDProyecto
group by c.Apellido, c.Nombre

go

--Por cada cliente, listar la razón social y el costo estimado del módulo más
--costoso que haya solicitado.
select top 1 c.RazonSocial, max(m.CostoEstimado) as 'Modulo Mas costoso' from Clientes c
inner join Proyectos p on p.IDCliente = c.ID
inner join Modulos m on m.IDProyecto = p.ID
group by c.RazonSocial

go

--Los nombres de los tipos de tareas que hayan registrado más de diez
--colaboradores distintos en el año 2020.
select t.Nombre from TiposTarea t
inner join Tareas ta on ta.IDTipo = t.ID
inner join Colaboraciones c on c.IDTarea = ta.ID
inner join Colaboradores co on co.ID = c.IDColaborador
where year(ta.FechaInicio) = 2020 or year(ta.FechaFin) = 2020
group by t.Nombre
having count(distinct co.ID) > 10

go

--Por cada cliente listar la razón social y el promedio abonado en concepto de
--proyectos. Si no tiene proyectos asociados mostrar el cliente con promedio
--nulo.
select c.RazonSocial, isnull(AVG(isnull(p.CostoEstimado, 0)), 0) as 'Promedio' from Clientes c
inner join Proyectos p on p.IDCliente = c.ID
group by c.RazonSocial

--Los nombres de los tipos de tareas que hayan promediado más horas de
--colaboradores externos que internos.
select t.Nombre from TiposTarea t
where 
(
	(
		select avg(isnull(c.Tiempo, 0)) from Colaboraciones c
		inner join Colaboradores co on co.ID = c.IDColaborador
		inner join Tareas ta on ta.ID = c.IDTarea
		where ta.IDTipo = t.ID and co.Tipo = 'E'
	)
		>
	(
		select avg(isnull(c.Tiempo, 0)) from Colaboraciones c
		inner join Colaboradores co on co.ID = c.IDColaborador
		inner join Tareas ta on ta.ID = c.IDTarea
		where ta.IDTipo = t.ID and co.Tipo = 'I'
	)
)

--El nombre de proyecto que más colaboradores distintos haya empleado.
select top 1 tab.Nombre, tab.Col From
(
	select p.Nombre, 
	(
		select distinct count(*) from Colaboradores c
		inner join Colaboraciones co on co.IDColaborador = c.ID
		inner join Tareas t on t.ID = co.IDTarea
		inner join Modulos m on m.ID = t.IDModulo
		where p.ID = m.IDProyecto
	) as Col
	from Proyectos p
) as Tab
order by tab.Col desc

go

--Por cada colaborador, listar el apellido y nombres y la cantidad de horas
--trabajadas en el año 2018, la cantidad de horas trabajadas en 2019 y la
--cantidad de horas trabajadas en 2020.
select c.Apellido, c.Nombre, 
(
	select sum(co.Tiempo) from Colaboraciones co
	inner join Tareas t on t.ID = co.IDTarea
	where co.IDColaborador = c.ID and year(t.FechaInicio) = 2018
) as 'Cantidad HS 2018', 
(
	select sum(co.Tiempo) from Colaboraciones co
	inner join Tareas t on t.ID = co.IDTarea
	where co.IDColaborador = c.ID and year(t.FechaInicio) = 2019
) as 'Cantidad HS 2019', 
(
	select sum(co.Tiempo) from Colaboraciones co
	inner join Tareas t on t.ID = co.IDTarea
	where co.IDColaborador = c.ID and year(t.FechaInicio) = 2020
) as 'Cantidad HS 2020'
from Colaboradores c

go

--Los apellidos y nombres de los colaboradores que hayan trabajado más horas
--en 2018 que en 2019 y más horas en 2019 que en 2020.
select tab.Apellido, Tab.Nombre from
(
	select c.Apellido, c.Nombre, 
	(
		select sum(co.Tiempo) from Colaboraciones co
		inner join Tareas t on t.ID = co.IDTarea
		where co.IDColaborador = c.ID and year(t.FechaInicio) = 2018
	) as Cant2018, 
	(
		select sum(co.Tiempo) from Colaboraciones co
		inner join Tareas t on t.ID = co.IDTarea
		where co.IDColaborador = c.ID and year(t.FechaInicio) = 2019
	) as Cant2019, 
	(
		select sum(co.Tiempo) from Colaboraciones co
		inner join Tareas t on t.ID = co.IDTarea
		where co.IDColaborador = c.ID and year(t.FechaInicio) = 2020
	) as Cant2020
	from Colaboradores c
) as Tab
where tab.Cant2018 > Tab.Cant2019 and Tab.Cant2019 > Tab.Cant2020

go

--Los apellidos y nombres de los colaboradores que nunca hayan trabajado en
--un proyecto contratado por un cliente extranjero.
select c.Apellido, c.Nombre from Colaboradores c
where c.ID not in
(
	select distinct co.IDColaborador from Colaboraciones co
	inner join Tareas t on t.ID = co.IDTarea
	inner join Modulos m on m.ID = t.IDModulo
	inner join Proyectos p on p.ID = m.IDProyecto
	inner join Clientes cl on cl.ID = p.IDCliente
	inner join Ciudades ci on ci.ID = cl.IDCiudad
	inner join Paises pa on pa.ID = ci.IDPais
	where pa.Nombre != 'Argentina'
)

go

--Por cada tipo de tarea listar el nombre, el precio de hora base y el promedio de
--valor hora real (obtenido de las colaboraciones). También, una columna
--llamada Variación con las siguientes reglas:
--Poca → Si la diferencia entre el promedio y el precio de hora base es menor a $500.
--Mediana → Si la diferencia entre el promedio y el precio de hora base está
--entre $501 y $999.
--Alta → Si la diferencia entre el promedio y el precio de hora base es $1000 o más.
select t.Nombre, t.PrecioHoraBase, avg(isnull(c.PrecioHora, 0)) as Promedio,
case
	when (avg(isnull(c.PrecioHora, 0)) - t.PrecioHoraBase) < 500 then 'Poca'
	when (avg(isnull(c.PrecioHora, 0))- t.PrecioHoraBase) > 500 and (t.PrecioHoraBase - avg(isnull(c.PrecioHora, 0))) < 1000 then 'Mediana'
	else 'Alta'
end as Variación
from TiposTarea t
inner join Tareas ta on ta.IDTipo = t.ID
inner join Colaboraciones c on c.IDTarea = ta.ID
group by t.Nombre, t.PrecioHoraBase