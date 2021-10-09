use BluePrint
go

--La cantidad de colaboradores
select count(*) from Colaboradores

go

-- La cantidad de colaboradores nacidos entre 1990 y 2000.
select count(*) from Colaboradores
where year(FechaNacimiento) > 1990 and year(FechaNacimiento) < 2000

go

--El promedio de precio hora base de los tipos de tareas
select sum(PrecioHoraBase)/COUNT(PrecioHoraBase) from TiposTarea

go

--El promedio de costo de los proyectos iniciados en el año 2019.
select avg(CostoEstimado) from Proyectos
where year(FechaInicio) = 2019

go

--El costo más alto entre los proyectos de clientes de tipo 'Unicornio'
select max(CostoEstimado) from Proyectos p
inner join Clientes c on c.ID = p.IDCliente
inner join TiposCliente tc on tc.ID = c.IDTipo
where tc.Nombre = 'Unicornio'

go

--El costo más bajo entre los proyectos de clientes del país 'Argentina'
select max(CostoEstimado) from Proyectos p
inner join Clientes c on c.ID = p.IDCliente
inner join Ciudades ci on ci.ID = c.IDCiudad
inner join Paises pa on pa.ID = ci.IDPais
where pa.Nombre = 'Argentina'

go

--La suma total de los costos estimados entre todos los proyectos.
select sum(CostoEstimado) from Proyectos

go

--Por cada ciudad, listar el nombre de la ciudad y la cantidad de clientes.
select c.Nombre, count(cl.IDCiudad) from Ciudades c
inner join Clientes cl on cl.IDCiudad = c.ID
group by c.Nombre

go

--Por cada país, listar el nombre del país y la cantidad de clientes.
select p.Nombre, count(cl.IDCiudad) from Paises p
inner join Ciudades c on c.IDPais = p.ID
inner join Clientes cl on cl.IDCiudad = c.ID
group by p.Nombre

go

-- Por cada tipo de tarea, la cantidad de colaboraciones registradas. Indicar el
--tipo de tarea y la cantidad calculada.
select tt.Nombre, count(c.IDTarea) from TiposTarea tt
inner join Tareas t on t.IDTipo = tt.ID
inner join Colaboraciones c on c.IDTarea = t.ID
group by tt.Nombre

go

--Por cada tipo de tarea, la cantidad de colaboradores distintos que la hayan
--realizado. Indicar el tipo de tarea y la cantidad calculada.
select tt.Nombre, count(distinct c.IDTarea) from TiposTarea tt
inner join Tareas t on t.IDTipo = tt.ID
inner join Colaboraciones c on c.IDTarea = t.ID
group by tt.Nombre

go

--Por cada módulo, la cantidad total de horas trabajadas. Indicar el ID, nombre
--del módulo y la cantidad totalizada. Mostrar los módulos sin horas registradas
--con 0.
select m.ID, m.Nombre, sum(c.Tiempo) from Modulos m
inner join Tareas t on t.IDModulo = m.ID
inner join Colaboraciones c on c.IDTarea = t.ID
group by m.ID, m.Nombre

go

--Por cada módulo y tipo de tarea, el promedio de horas trabajadas. Indicar el ID
--y nombre del módulo, el nombre del tipo de tarea y el total calculado.
select m.ID, m.Nombre, tt.Nombre, avg(c.Tiempo) from Modulos m
inner join Tareas t on t.IDModulo = m.ID
inner join TiposTarea tt on tt.ID = t.IDTipo
inner join Colaboraciones c on c.IDTarea = t.ID
group by m.ID, m.Nombre, tt.ID, tt.Nombre

go

--Por cada módulo, indicar su ID, apellido y nombre del colaborador y total que
--se le debe abonar en concepto de colaboraciones realizadas en dicho módulo.
select co.ID, co.Apellido, co.Nombre, sum(c.Tiempo) + SUM(c.PrecioHora) from Modulos m
inner join Tareas t on t.IDModulo = m.ID
inner join TiposTarea tt on tt.ID = t.IDTipo
inner join Colaboraciones c on c.IDTarea = t.ID
inner join Colaboradores co on co.ID = c.IDColaborador
group by m.ID, co.ID, co.Apellido, co.Nombre

go

--Por cada proyecto indicar el nombre del proyecto y la cantidad de horas
--registradas en concepto de colaboraciones y el total que debe abonar en
--concepto de colaboraciones.
select p.Nombre, sum(c.Tiempo), sum(c.PrecioHora * c.Tiempo) from Proyectos p
inner join Modulos m on m.IDProyecto = p.ID
inner join Tareas t on t.IDModulo = m.ID
inner join Colaboraciones c on c.IDTarea = t.ID
group by p.Nombre

go

--Listar los nombres de los proyectos que hayan registrado menos de cinco
--colaboradores distintos y más de 100 horas total de trabajo
select distinct p.Nombre from Proyectos p
inner join Modulos m on m.IDProyecto = p.ID
inner join Tareas t on t.IDModulo = m.ID
inner join Colaboraciones c on c.IDTarea = t.ID
inner join Colaboradores co on co.ID = c.IDColaborador
group by p.Nombre, co.ID
having sum(c.Tiempo) > 100 and count(distinct co.ID) < 5 

go

--Listar los nombres de los proyectos que hayan comenzado en el año 2020 que
--hayan registrado más de tres módulos.
select distinct p.Nombre from Proyectos p
inner join Modulos m on m.IDProyecto = p.ID
where year(m.FechaFin) = 2020
group by p.Nombre
having count(m.ID) > 3

go

--Listar para cada colaborador externo, el apellido y nombres y el tiempo
--máximo de horas que ha trabajo en una colaboración.
select c.Apellido, c.Nombre, max(cc.Tiempo) from Colaboradores c
inner join Colaboraciones cc on cc.IDColaborador = c.ID
where c.Tipo = 'E'
group by c.ID, c.Apellido, c.Nombre

go

--Listar para cada colaborador interno, el apellido y nombres y el promedio
--percibido en concepto de colaboraciones.
select c.Apellido, c.Nombre, avg(cc.Tiempo * cc.PrecioHora) from Colaboradores c
inner join Colaboraciones cc on cc.IDColaborador = c.ID
where c.Tipo = 'I'
group by c.ID, c.Apellido, c.Nombre

go

--Listar el promedio percibido en concepto de colaboraciones para
--colaboradores internos y el promedio percibido en concepto de
--colaboraciones para colaboradores externos.
select c.Tipo, avg(cc.Tiempo * cc.PrecioHora) from Colaboraciones cc
inner join Colaboradores c on c.ID = cc.IDColaborador
group by c.Tipo

go

--Listar el nombre del proyecto y el total neto estimado. Este último valor surge
--del costo estimado menos los pagos que requiera hacer en concepto de
--colaboraciones.
select p.Nombre, p.CostoEstimado - sum(cc.PrecioHora * cc.Tiempo) from Proyectos p
inner join Modulos m on m.IDProyecto = p.ID
inner join Tareas t on t.IDModulo = m.ID
inner join Colaboraciones cc on cc.IDTarea = t.ID
group by p.Nombre, p.CostoEstimado

go

--Listar la cantidad de colaboradores distintos que hayan colaborado en alguna
--tarea que correspondan a proyectos de clientes de tipo 'Unicornio'.
select count(distinct c.ID) from Colaboradores c
inner join Colaboraciones cc on cc.IDColaborador = c.ID
inner join Tareas t on t.ID = cc.IDTarea
inner join Modulos m on m.ID = t.IDModulo
inner join Proyectos p on p.ID = m.IDProyecto
inner join Clientes cl on cl.ID = p.IDCliente
inner join TiposCliente tc on tc.ID = cl.IDTipo
where tc.Nombre = 'Unicornio'

go

--La cantidad de tareas realizadas por colaboradores del país 'Argentina'.
select count(t.ID) from Tareas t
inner join Colaboraciones cc on cc.IDTarea = t.ID
inner join Colaboradores c on c.ID = cc.IDColaborador
inner join Ciudades ci on ci.ID = c.IDCiudad
inner join Paises p on p.ID = ci.IDPais
where p.Nombre = 'Argentina'

go

--Por cada proyecto, la cantidad de módulos que se haya estimado mal la fecha
--de fin. Es decir, que se haya finalizado antes o después que la fecha estimada.
--Indicar el nombre del proyecto y la cantidad calculada
select p.Nombre, count(m.ID) from Proyectos p
inner join Modulos m on m.IDProyecto = p.ID
where m.FechaFin != m.FechaEstimadaFin
group by p.ID, p.Nombre
