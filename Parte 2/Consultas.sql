use BluePrint
go

--Por cada cliente listar razón social, cuit y nombre del tipo de cliente.
select C.RazonSocial, C.Cuit, T.Nombre from Clientes as C inner join TiposCliente t on C.IDTipo = T.ID

go

--Por cada cliente listar razón social, cuit y nombre de la ciudad y nombre del
--país. Sólo de aquellos clientes que posean ciudad y país.
select Cl.RazonSocial, Cl.Cuit, C.Nombre as Ciudad, P.Nombre as Pais
from Clientes CL
inner join Ciudades C on CL.IDCiudad = C.ID
inner join Paises p on C.IDPais = P.ID

go

--Por cada cliente listar razón social, cuit y nombre de la ciudad y nombre del
--país. Listar también los datos de aquellos clientes que no tengan ciudad relacionada.
select CL.RazonSocial, CL.Cuit, C.Nombre as Ciudad, P.Nombre as Pais
from Clientes CL
left join Ciudades C on CL.IDCiudad = C.ID
left join Paises P on C.IDPais = P.ID

go

--Por cada cliente listar razón social, cuit y nombre de la ciudad y nombre del
--país. Listar también los datos de aquellas ciudades y países que no tengan
--clientes relacionados.
select CL.RazonSocial, CL.Cuit, C.Nombre as Ciudad, P.Nombre Pais
from Clientes CL
right join Ciudades C on CL.IDCiudad = C.ID
right join Paises P on P.ID = C.IDPais

--Listar los nombres de las ciudades que no tengan clientes asociados. Listar
--también el nombre del país al que pertenece la ciudad.
select CL.RazonSocial, CL.Cuit, C.Nombre as Ciudad, P.Nombre Pais
from Clientes CL
full join Ciudades C on CL.IDCiudad = C.ID
full join Paises P on P.ID = C.IDPais

go

--Listar para cada proyecto el nombre del proyecto, el costo, la razón social del
--cliente, el nombre del tipo de cliente y el nombre de la ciudad (si la tiene
--registrada) de aquellos clientes cuyo tipo de cliente sea 'Extranjero' o
--'Unicornio'.
select P.Nombre, P.CostoEstimado, CL.RazonSocial, TC.Nombre as TipoCliente, C.Nombre as Ciudad
from Proyectos P
inner join Clientes CL on P.IDCliente = CL.ID
inner join Ciudades C on CL.IDCiudad = C.ID
inner join TiposCliente TC on CL.IDTipo = TC.ID
where TC.Nombre = 'Extranjero' or TC.Nombre = 'Unicornio'

go

--Listar los nombre de los proyectos de aquellos clientes que sean de los países
--'Argentina' o 'Italia'.
select PR.Nombre from Proyectos PR
inner join Clientes CL on PR.IDCliente = CL.ID
inner join Ciudades C on C.ID = CL.IDCiudad
inner join Paises P on P.ID = C.IDPais
where P.Nombre = 'Argentina' or P.Nombre = 'Italia'

go

--Listar para cada módulo el nombre del módulo, el costo estimado del módulo,
--el nombre del proyecto, la descripción del proyecto y el costo estimado del
--proyecto de todos aquellos proyectos que hayan finalizado.
select M.Nombre, M.CostoEstimado, P.Nombre, P.Descripcion, P.CostoEstimado
from Modulos as M
full join Proyectos P on P.ID = M.IDProyecto
where M.FechaFin is not null

go

--Listar los nombres de los módulos y el nombre del proyecto de aquellos
--módulos cuyo tiempo estimado de realización sea de más de 100 horas.
select M.Nombre, P.Nombre from Modulos M
inner join Proyectos P on P.ID = M.IDProyecto
where M.TiempoEstimado>100

go

--Listar nombres de módulos, nombre del proyecto, descripción y tiempo
--estimado de aquellos módulos cuya fecha estimada de fin sea mayor a la
--fecha real de fin y el costo estimado del proyecto sea mayor a cien mil.
select M.Nombre, P.Nombre, P.Descripcion, M.TiempoEstimado
from Modulos M
inner join Proyectos p on p.ID = M.IDProyecto
where M.FechaEstimadaFin > M.FechaFin and P.CostoEstimado > 100000

go

--Listar nombre de proyectos, sin repetir, que registren módulos que hayan
--finalizado antes que el tiempo estimado.
select distinct P.Nombre from Proyectos p
Inner join Modulos M on M.IDProyecto = P.ID
where M.FechaEstimadaFin < M.FechaFin

go

--Listar nombre de ciudades, sin repetir, que no registren clientes pero sí
--colaboradores.
select distinct C.Nombre from Ciudades C
left join Colaboradores CO on CO.IDCiudad = C.ID
left join Clientes CL on CL.IDCiudad = C.ID 
where CL.IDCiudad is null and CO.IDCiudad is not null

go

-- Listar el nombre del proyecto y nombre de módulos de aquellos módulos que
-- contengan la palabra 'login' en su nombre o descripción.
select P.Nombre, M.Nombre from Proyectos P
inner join Modulos M on M.IDProyecto = P.ID
where M.Nombre like '%login%' and M.Descripcion like '%Login%'

go

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
order by P.ID asc

--Listar nombres y apellidos de las tres colaboraciones de colaboradores
--externos que más hayan demorado en realizar alguna tarea cuyo nombre de
--tipo de tarea contenga 'Testing'.
select top 3 C.Nombre + ' ' + C.Apellido as 'Nombre y Apellido' from Colaboraciones CO
inner join Colaboradores C on CO.IDColaborador = C.ID
inner join Tareas T on T.ID = CO.IDTarea
inner join TiposTarea TT on T.IDTipo = TT.ID
where C.Tipo = 'E' and TT.Nombre like '%Testing%'

--Listar apellido, nombre y mail de los colaboradores argentinos que sean
--internos y cuyo mail no contenga '.com'.
select C.Nombre, C.Apellido, C.EMail from Colaboradores C
inner join Ciudades CI on CI.ID = C.IDCiudad
inner join Paises P on P.ID = CI.IDPais
where C.Tipo = 'I' and C.EMail not like '%.com%' and P.Nombre = 'Argentina'

--Listar nombre del proyecto, nombre del módulo y tipo de tarea de aquellas
--tareas realizadas por colaboradores externos.
select P.Nombre, M.Nombre, TT.Nombre from Proyectos p
inner join Modulos M on M.IDProyecto = P.ID
inner join Tareas T on T.IDModulo = M.ID
inner join TiposTarea TT on TT.ID = T.IDTipo
inner join Colaboraciones CO on CO.IDTarea = T.ID
inner join Colaboradores C on C.ID = CO.IDColaborador
where C.Tipo = 'e'

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
where P.FechaFin is null
