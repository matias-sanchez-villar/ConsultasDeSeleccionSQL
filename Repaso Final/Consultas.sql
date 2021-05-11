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
select c.RazonSocial, max(m.CostoEstimado) as 'Modulo Mas costoso' from Clientes c
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
select p.Nombre from Proyectos p
inner join Modulos m on m.IDProyecto = p.ID
inner join Tareas t on t.IDModulo = m.ID
inner join Colaboraciones c on c.IDTarea = t.ID
inner join Colaboradores co on co.ID = c.IDColaborador
group by p.Nombre
having max(co.ID) > 
(
	select max(co.ID) from Proyectos p
	inner join Modulos m on m.IDProyecto = p.ID
	inner join Tareas t on t.IDModulo = m.ID
	inner join Colaboraciones c on c.IDTarea = t.ID
	inner join Colaboradores co on co.ID = c.IDColaborador
)