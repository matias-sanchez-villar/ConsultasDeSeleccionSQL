use BluePrint

go

--Por cada cliente listar razón social, cuit y nombre del tipo de cliente.
select C.RazonSocial, C.Cuit, T.Nombre from Clientes C 
inner join TiposCliente t on C.IDTipo = T.ID

--Por cada cliente listar razón social, cuit y nombre de la ciudad y nombre del
--país. Sólo de aquellos clientes que posean ciudad y país.
select Cl.RazonSocial, Cl.Cuit, C.Nombre as Ciudad, P.Nombre as Pais
from Clientes CL
inner join Ciudades C on CL.IDCiudad = C.ID
inner join Paises p on C.IDPais = P.ID

--Por cada cliente listar razón social, cuit y nombre de la ciudad y nombre del
--país. Listar también los datos de aquellos clientes que no tengan ciudad relacionada.
select CL.RazonSocial, CL.Cuit, C.Nombre as Ciudad, P.Nombre as Pais
from Clientes CL
left join Ciudades C on CL.IDCiudad = C.ID
left join Paises P on C.IDPais = P.ID

--Por cada cliente listar razón social, cuit y nombre de la ciudad y nombre del
--país. Listar también los datos de aquellas ciudades y países que no tengan
--clientes relacionados.
select c.RazonSocial, c.CUIT, ci.Nombre, p.Nombre from Clientes c
full join Ciudades ci on ci.ID = c.IDCiudad
full join Paises p on p.ID = ci.ID

--Listar los nombres de las ciudades que no tengan clientes asociados. Listar
--también el nombre del país al que pertenece la ciudad.
select ci.Nombre, p.Nombre from Clientes c
right join Ciudades ci on ci.ID = c.IDCiudad
full join Paises p on p.ID = ci.ID
where c.IDCiudad is null

--Listar para cada proyecto el nombre del proyecto, el costo, la razón social del
--cliente, el nombre del tipo de cliente y el nombre de la ciudad (si la tiene
--registrada) de aquellos clientes cuyo tipo de cliente sea 'Extranjero' o
--'Unicornio'.
select p.Nombre, p.CostoEstimado, c.RazonSocial, tc.Nombre, ci.Nombre from Proyectos p
inner join Clientes C on c.ID = p.IDCliente
inner join TiposCliente tc on tc.ID = c.IDTipo
inner join Ciudades ci on ci.ID = c.IDCiudad
where tc.Nombre = 'Extranjero' or tc.Nombre = 'Unicornio'

--Listar los nombre de los proyectos de aquellos clientes que sean de los países
--'Argentina' o 'Italia'.
select PR.Nombre from Proyectos PR
inner join Clientes CL on PR.IDCliente = CL.ID
inner join Ciudades C on C.ID = CL.IDCiudad
inner join Paises P on P.ID = C.IDPais
where P.Nombre = 'Argentina' or P.Nombre = 'Italia'

--Listar para cada módulo el nombre del módulo, el costo estimado del módulo,
--el nombre del proyecto, la descripción del proyecto y el costo estimado del
--proyecto de todos aquellos proyectos que hayan finalizado.
select m.Nombre, m.CostoEstimado, p.Nombre, p.Descripcion, p.CostoEstimado from Modulos m
inner join Proyectos p on p.ID = m.IDProyecto
where p.FechaFin < getdate()

--Listar los nombres de los módulos y el nombre del proyecto de aquellos
--módulos cuyo tiempo estimado de realización sea de más de 100 horas.
select M.Nombre, P.Nombre from Modulos M
inner join Proyectos P on P.ID = M.IDProyecto
where M.TiempoEstimado > 100

--Listar nombres de módulos, nombre del proyecto, descripción y tiempo
--estimado de aquellos módulos cuya fecha estimada de fin sea mayor a la
--fecha real de fin y el costo estimado del proyecto sea mayor a cien mil.
select m.Nombre, p.Nombre, m.Descripcion, m.TiempoEstimado, m.FechaEstimadaFin, m.FechaFin from Modulos m
inner join Proyectos p on p.ID = m.IDProyecto
where m.TiempoEstimado > 100000 and m.FechaEstimadaFin > m.FechaFin

--Listar nombre de proyectos, sin repetir, que registren módulos que hayan
--finalizado antes que el tiempo estimado.
select distinct P.Nombre from Proyectos p
Inner join Modulos M on M.IDProyecto = P.ID
where M.FechaEstimadaFin < M.FechaFin

--Listar nombre de ciudades, sin repetir, que no registren clientes pero sí
--colaboradores.
select distinct C.Nombre from Ciudades c
inner join Colaboradores co on co.IDCiudad = c.ID
left join Clientes cl on c.ID =cl.ID
where cl.IDCiudad is null

-- Listar el nombre del proyecto y nombre de módulos de aquellos módulos que
-- contengan la palabra 'login' en su nombre o descripción.
select P.Nombre, M.Nombre from Proyectos P
inner join Modulos M on M.IDProyecto = P.ID
where M.Nombre like '%login%' and M.Descripcion like '%Login%'

--Listar el nombre del proyecto y el nombre y apellido de todos los
--colaboradores que hayan realizado algún tipo de tarea cuyo nombre contenga
--'Programación' o 'Testing'. Ordenarlo por nombre de proyecto de manera
--ascendente.
select P.Nombre, C.Nombre, C.Apellido from Proyectos P
inner join Modulos M on M.IDProyecto = P.ID
inner join Tareas T on T.IDModulo = M.ID
inner join Colaboraciones CO on CO.IDTarea = T.ID
inner join Colaboradores C on C.ID = CO.IDColaborador
inner join TiposTarea TI on T.IDTipo = TI.ID
where TI.Nombre like '%Programacion%' or TI.Nombre like '%Testing%'
order by P.Nombre asc

--Listar nombre y apellido del colaborador, nombre del módulo, nombre del tipo
--de tarea, precio hora de la colaboración y precio hora base de aquellos
--colaboradores que hayan cobrado su valor hora de colaboración más del 50%
--del valor hora base.
select c.Nombre, c.Apellido, m.Nombre as 'Nombre Modulo', ti.Nombre as 'Tipo Tarea', co.PrecioHora, ti.PrecioHoraBase from Colaboradores c
inner join Colaboraciones co on co.IDColaborador = c.ID
inner join Tareas t on t.ID = co.IDTarea
inner join TiposTarea ti on ti.ID = t.IDTipo
inner join Modulos m on m.ID = t.IDModulo
where co.PrecioHora > (ti.PrecioHoraBase*1.50)

--Listar nombres y apellidos de las tres colaboraciones de colaboradores
--externos que más hayan demorado en realizar alguna tarea cuyo nombre de
--tipo de tarea contenga 'Testing'.
select top 3 c.Nombre, c.Apellido from colaboradores c
inner join Colaboraciones co on co.IDColaborador = c.ID
inner join Tareas t on t.ID = co.IDTarea
inner join TiposTarea ti on ti.ID = t.IDTipo
where c.Tipo = 'E' and ti.Nombre like '%Testing%'
order by co.Tiempo

--Listar apellido, nombre y mail de los colaboradores argentinos que sean
--internos y cuyo mail no contenga '.com'.
select C.Nombre, C.Apellido, C.EMail from Colaboradores C
inner join Ciudades CI on CI.ID = C.IDCiudad
inner join Paises P on P.ID = CI.IDPais
where C.Tipo = 'I' and C.EMail not like '%.com%' and P.Nombre = 'Argentina'

--Listar nombre del proyecto, nombre del módulo y tipo de tarea de aquellas
--tareas realizadas por colaboradores externos.
select Distinct p.Nombre, m.Nombre, ti.Nombre from Proyectos p
inner join Modulos m on m.IDProyecto = p.ID
inner join Tareas t on t.IDModulo = m.ID
inner join TiposTarea ti on ti.ID = t.IDTipo
inner join Colaboraciones c on c.IDTarea = t.ID
inner join Colaboradores co on co.ID = c.IDColaborador
where co.Tipo = 'E'

--Listar nombre de proyectos que no hayan registrado tareas.
select P.Nombre from Proyectos P
inner join Modulos M on M.IDProyecto = P.ID
left join Tareas T on T.IDModulo = M.ID
where T.ID is null

--Listar apellidos y nombres, sin repeticiones, de aquellos colaboradores que
--hayan trabajado en algún proyecto que aún no haya finalizado.
select distinct C.Apellido + ' ' + C.Nombre as 'Nombre y Apellido' from Colaboradores C
inner join Colaboraciones CO on CO.IDColaborador = C.ID
inner join Tareas T on T.ID = CO.IDTarea
inner join Modulos M on M.ID = T.IDModulo
inner join Proyectos P on p.ID = M.IDProyecto
where P.FechaFin is null or p.FechaFin < getdate()
