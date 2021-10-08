use BluePrint
go

--Por cada cliente listar razón social, cuit y nombre del tipo de cliente.
select RazonSocial, CUIT, tc.Nombre from Clientes c
inner join TiposCliente tc on tc.ID = c.IDTipo

go

-- Por cada cliente listar razón social, cuit y nombre de la ciudad y nombre del
--país. Sólo de aquellos clientes que posean ciudad y país.
select RazonSocial, CUIT, ci.Nombre 'Ciudad', p.Nombre 'Pais' from Clientes c
inner join Ciudades ci on ci.ID = c.IDCiudad
inner join Paises p on p.ID = ci.IDPais

go

--Por cada cliente listar razón social, cuit y nombre de la ciudad y nombre del
--país. Listar también los datos de aquellos clientes que no tengan ciudad
--relacionada.
select RazonSocial, CUIT, ci.Nombre 'Ciudad', p.Nombre 'Pais' from Clientes c
left join Ciudades ci on ci.ID = c.IDCiudad
left join Paises p on p.ID = ci.IDPais

go

--Por cada cliente listar razón social, cuit y nombre de la ciudad y nombre del
--país. Listar también los datos de aquellas ciudades y países que no tengan
--clientes relacionados.
select RazonSocial, CUIT, ci.Nombre 'Ciudad', p.Nombre 'Pais' from Clientes c
right join Ciudades ci on ci.ID = c.IDCiudad
inner join Paises p on p.ID = ci.IDPais

go

-- Listar los nombres de las ciudades que no tengan clientes asociados. Listar
--también el nombre del país al que pertenece la ciudad.
select c.Nombre 'Ciudad', p.Nombre 'Pais' from Ciudades c
inner join Paises p on p.ID = c.IDPais
left join Clientes cl on cl.IDCiudad = c.ID
where cl.ID is null

go

--Listar para cada proyecto el nombre del proyecto, el costo, la razón social del
--cliente, el nombre del tipo de cliente y el nombre de la ciudad (si la tiene
--registrada) de aquellos clientes cuyo tipo de cliente sea 'Extranjero' o
--'Unicornio'.
select p.Nombre, p.CostoEstimado, c.RazonSocial, t.Nombre from Proyectos p
inner join Clientes c on c.ID = p.IDCliente
inner join TiposCliente t on t.ID = c.IDTipo
where t.Nombre in ('Extranjero', 'Unicornio')

go

--Listar los nombre de los proyectos de aquellos clientes que sean de los países
--'Argentina' o 'Italia'.
select p.Nombre, c.RazonSocial, ci.Nombre, pa.Nombre from Proyectos p
inner join Clientes c on c.ID = p.IDCliente
inner join Ciudades ci on ci.ID = c.IDCiudad
inner join Paises pa on pa.ID = ci.IDPais
where pa.Nombre in ('Argentina', 'Italia')

go

--Listar para cada módulo el nombre del módulo, el costo estimado del módulo,
--el nombre del proyecto, la descripción del proyecto y el costo estimado del
--proyecto de todos aquellos proyectos que hayan finalizado.
select m.Nombre, m.CostoEstimado, p.Nombre, p.Descripcion, p.CostoEstimado from Modulos m
inner join Proyectos p on p.ID = m.IDProyecto
where p.FechaFin is not null

go

--Listar los nombres de los módulos y el nombre del proyecto de aquellos
--módulos cuyo tiempo estimado de realización sea de más de 100 horas.
select m.Nombre, p.Nombre from Modulos m
inner join Proyectos p on p.ID = m.IDProyecto
where m.TiempoEstimado > 100

go

--Listar nombres de módulos, nombre del proyecto, descripción y tiempo
--estimado de aquellos módulos cuya fecha estimada de fin sea mayor a la
--fecha real de fin y el costo estimado del proyecto sea mayor a cien mil.
select m.Nombre, p.Nombre, p.Descripcion, m.TiempoEstimado from Modulos m
inner join Proyectos p on p.ID = m.IDProyecto
where p.CostoEstimado > 100000 and m.FechaEstimadaFin > m.FechaFin

go

--Listar nombre de proyectos, sin repetir, que registren módulos que hayan
--finalizado antes que el tiempo estimado.
select distinct p.Nombre from Proyectos p
inner join Modulos m on m.IDProyecto = p.ID
where m.FechaFin < m.FechaEstimadaFin

go

--Listar nombre de ciudades, sin repetir, que no registren clientes pero sí
--colaboradores.
select c.Nombre from Ciudades c
left join Clientes cl on cl.IDCiudad = c.ID
inner join Colaboradores co on co.IDCiudad = c.ID
where cl.IDCiudad is null

go

--Listar el nombre del proyecto y nombre de módulos de aquellos módulos que
--contengan la palabra 'login' en su nombre o descripción.
select p.Nombre, m.Nombre, m.Descripcion from Proyectos p
inner join Modulos m on m.IDProyecto = p.ID
where m.Nombre like '%login%' or m.Descripcion like '%login%'

go

--Listar el nombre del proyecto y el nombre y apellido de todos los
--colaboradores que hayan realizado algún tipo de tarea cuyo nombre contenga
--'Programación' o 'Testing'. Ordenarlo por nombre de proyecto de manera
--ascendente.
select p.Nombre, co.Nombre, co.Apellido from Proyectos p
inner join Modulos m on m.IDProyecto = p.ID
inner join Tareas t on t.IDModulo = m.ID
inner join TiposTarea tt on tt.ID = t.IDTipo
inner join Colaboraciones c on c.IDTarea = t.ID
inner join Colaboradores co on co.ID = c.IDColaborador
where tt.Nombre like '%Programación%' or tt.Nombre like '%Testing%'
order by p.Nombre asc

go

--Listar nombre y apellido del colaborador, nombre del módulo, nombre del tipo
--de tarea, precio hora de la colaboración y precio hora base de aquellos
--colaboradores que hayan cobrado su valor hora de colaboración más del 50%
--del valor hora base.
select c.Nombre, c.Apellido, m.Nombre, tt.Nombre, co.PrecioHora, tt.PrecioHoraBase from Colaboradores c
inner join Colaboraciones co on co.IDColaborador = c.ID
inner join Tareas t on t.ID = co.IDTarea
inner join TiposTarea tt on tt.ID = t.IDTipo
inner join Modulos m on m.ID = t.IDModulo
where co.PrecioHora > ((tt.PrecioHoraBase *150) / 100)

go

--Listar nombres y apellidos de las tres colaboraciones de colaboradores
--externos que más hayan demorado en realizar alguna tarea cuyo nombre de
--tipo de tarea contenga 'Testing'
select top(3) c.Nombre, c.Apellido, tt.Nombre from Colaboradores c
inner join Colaboraciones cc on cc.IDColaborador = c.ID
inner join Tareas t on t.ID = cc.IDTarea
inner join TiposTarea tt on tt.ID = t.IDTipo
inner join Modulos m on m.ID = t.IDModulo
where c.Tipo = 'E' and tt.Nombre like '%Testing%'

go

--Listar apellido, nombre y mail de los colaboradores argentinos que sean
--internos y cuyo mail no contenga '.com'.
select c.Nombre, c.Apellido, c.EMail, p.Nombre from Colaboradores c
inner join Ciudades ci on ci.ID = c.IDCiudad
inner join Paises p on p.ID = ci.IDPais
where p.Nombre = 'Argentina' and c.EMail not like '%.com%'


go

--Listar nombre del proyecto, nombre del módulo y tipo de tarea de aquellas
--tareas realizadas por colaboradores externos.
select p.Nombre, m.Nombre, tt.Nombre from Proyectos p
inner join Modulos m on m.IDProyecto = p.ID
inner join Tareas t on t.IDModulo = m.ID
inner join TiposTarea tt on tt.ID = t.IDTipo
inner join Colaboraciones c on c.IDTarea = t.ID
inner join Colaboradores co on co.ID = c.IDColaborador
where co.Tipo = 'E'

go

--Listar nombre de proyectos que no hayan registrado tareas.
select p.Nombre from Proyectos p
inner join Modulos m on m.IDProyecto = p.ID
left join Tareas t on t.IDModulo = M.ID
where t.ID is null

go

--Listar apellidos y nombres, sin repeticiones, de aquellos colaboradores que
--hayan trabajado en algún proyecto que aún no haya finalizado
select distinct c.Nombre, c.Apellido, p.FechaFin from Colaboradores c
inner join Colaboraciones co on co.IDColaborador = c.ID
inner join Tareas t on t.ID = co.IDTarea
inner join TiposTarea tt on tt.ID = t.IDTipo
inner join Modulos m on m.ID = t.IDModulo
inner join Proyectos p on p.ID = m.IDProyecto
where p.FechaFin is null
