use BluePrint
GO

--La cantidad de colaboradores
select count(*) as 'Cantidad de colaboradores' from Colaboradores

go

--La cantidad de colaboradores nacidos entre 1990 y 2000.
select COUNT(*) as 'Colaboradores nacidos 1990/2000' from Colaboradores
where year(FechaNacimiento)>=1990 and year(FechaNacimiento)<=2000

go

--El promedio de precio hora base de los tipos de tareas
select avg(PrecioHoraBase) from TiposTarea

go

--El promedio de costo de los proyectos iniciados en el año 2019.
select avg(CostoEstimado) as 'Promedio Costo' from Proyectos
where year(FechaInicio) = 2019

go

--El costo más alto entre los proyectos de clientes de tipo 'Unicornio
select top 1 p.Nombre, max(p.CostoEstimado) as 'Costo' from Proyectos p
inner join Clientes c on c.ID = p.IDCliente
inner join TiposCliente tc on tc.ID = c.IDTipo
where tc.Nombre = 'Unicornio'
group by p.Nombre

go

--El costo más bajo entre los proyectos de clientes del país 'Argentina'
select top 1 p.Nombre, min(p.CostoEstimado) as 'Costo' from Proyectos p
inner join Clientes c on c.ID = p.IDCliente
inner join Ciudades ci on ci.ID = c.IDCiudad
inner join Paises pa on pa.ID = ci.IDPais
where pa.Nombre = 'Argentina'
group by p.Nombre

go

--La suma total de los costos estimados entre todos los proyectos.
select sum(CostoEstimado) as total from Proyectos

go

--Por cada ciudad, listar el nombre de la ciudad y la cantidad de clientes.
select Ciudades.Nombre, COUNT(Clientes.ID) Cantidad from Clientes
inner join Ciudades on Ciudades.ID = Clientes.IDCiudad
group by Ciudades.Nombre

GO

--Por cada país, listar el nombre del país y la cantidad de clientes.
select Paises.Nombre, COUNT(Clientes.ID) as 'Cantidad Clientes' from Clientes
inner join Ciudades on Ciudades.ID = Clientes.IDCiudad
inner join Paises ON Paises.ID = Ciudades.IDPais
group by Paises.Nombre

--Por cada tipo de tarea, la cantidad de colaboraciones registradas. Indicar el
--tipo de tarea y la cantidad calculada.
select t.Nombre, count(c.IDTarea) as Colaboraciones from TiposTarea t
inner join Tareas ta on ta.ID = t.ID
inner join Colaboraciones c on c.IDTarea = t.ID
group by T.Nombre

go

--Por cada tipo de tarea, la cantidad de colaboradores distintos que la hayan
--realizado. Indicar el tipo de tarea y la cantidad calculada.
select t.Nombre, count(distinct co.ID) as Cantidad from TiposTarea t
inner join Tareas ta on ta.ID = t.ID
inner join Colaboraciones c on c.IDTarea = t.ID
inner join Colaboradores co on co.ID = c.IDColaborador
group by T.Nombre

go

--Por cada módulo, la cantidad total de horas trabajadas. Indicar el ID, nombre
--del módulo y la cantidad totalizada. Mostrar los módulos sin horas registradas
--con 0.
select m.ID, m.Nombre, isnull(count(c.Tiempo), 0) as 'Cantidad Horas' from Modulos m
left join Tareas t on t.IDModulo = m.ID
left join Colaboraciones c on c.IDTarea = t.ID
group by m.ID, m.Nombre

go

--Por cada módulo y tipo de tarea, el promedio de horas trabajadas. Indicar el ID
--y nombre del módulo, el nombre del tipo de tarea y el total calculado.
select m.ID, m.Nombre, ti.Nombre, avg(c.Tiempo) as 'Promedio' from Modulos m
inner join Tareas t on t.IDModulo = m.ID
inner join TiposTarea ti on ti.ID = t.IDTipo
inner join Colaboraciones c on c.IDTarea = t.ID
group by m.ID, m.Nombre, ti.Nombre

go

--Por cada módulo, indicar su ID, apellido y nombre del colaborador y total que
--se le debe abonar en concepto de colaboraciones realizadas en dicho módulo.
select m.ID, co.Nombre, co.Apellido, sum(c.PrecioHora * c.Tiempo) as Precio from Modulos m
inner join Tareas t on t.IDModulo = m.ID
inner join Colaboraciones c on c.IDTarea = t.ID
inner join Colaboradores co on co.ID = c.IDColaborador
group by m.ID, co.Nombre, co.Apellido

go

--Por cada proyecto indicar el nombre del proyecto y la cantidad de horas
--registradas en concepto de colaboraciones y el total que debe abonar en
--concepto de colaboraciones.
select p.Nombre, sum(c.Tiempo) Horas, sum(c.PrecioHora * c.Tiempo) Precio from Proyectos p
inner join Modulos m on m.IDProyecto = p.ID
inner join Tareas t on t.IDModulo = m.ID
inner join Colaboraciones c on c.IDTarea = t.ID
group by p.Nombre

go

--Listar los nombres de los proyectos que hayan registrado menos de cinco
--colaboradores distintos y más de 100 horas total de trabajo.
select distinct p.Nombre from Proyectos p
inner join Modulos m on m.IDProyecto = p.ID
inner join Tareas t on t.IDModulo = m.ID
inner join Colaboraciones c on c.IDTarea = t.ID
inner join Colaboradores co on co.ID = c.IDColaborador
group by p.Nombre, co.Nombre
having count(distinct co.Nombre) < 5 and sum(c.Tiempo) > 100

go

--Listar los nombres de los proyectos que hayan comenzado en el año 2020 que
--hayan registrado más de tres módulos.
select distinct p.Nombre from Proyectos p
inner join Modulos m on m.IDProyecto = p.ID
where year(p.FechaInicio) = 2020
group by p.Nombre
having count(m.IDProyecto) > 3

go

--Listar para cada colaborador externo, el apellido y nombres y el tiempo
--máximo de horas que ha trabajo en una colaboración
select c.Nombre, c.Apellido, max(co.Tiempo) as tiempo from Colaboradores c
inner join Colaboraciones co on co.IDColaborador = c.ID
where c.Tipo = 'E'
group by c.Nombre, c.Apellido

go

--Listar para cada colaborador interno, el apellido y nombres y el promedio
--percibido en concepto de colaboraciones.
select c.Nombre, c.Apellido, avg(co.Tiempo * co.PrecioHora) promedio from Colaboradores c
inner join Colaboraciones co on co.IDColaborador = c.ID
where c.Tipo = 'I'
group by c.Nombre, c.Apellido

go

--Listar el promedio percibido en concepto de colaboraciones para
--colaboradores internos y el promedio percibido en concepto de
--colaboraciones para colaboradores externos.
select co.Tipo, avg(c.Tiempo * c.PrecioHora) from Colaboraciones c
inner join Colaboradores co on co.ID = c.IDColaborador
group by co.Tipo

go

--Listar el nombre del proyecto y el total neto estimado. Este último valor surge
--del costo estimado menos los pagos que requiera hacer en concepto de
--colaboraciones.
select p.Nombre, p.CostoEstimado- isnull(sum(c.PrecioHora * c.Tiempo), 0) as 'Total estimado' from Proyectos p
inner join Modulos m on m.IDProyecto = p.ID
inner join Tareas t on t.IDModulo = m.ID
inner join Colaboraciones c on c.IDTarea = t.ID
group by p.Nombre, p.CostoEstimado

go

--Listar la cantidad de colaboradores distintos que hayan colaborado en alguna
--tarea que correspondan a proyectos de clientes de tipo 'Unicornio'.
select count(distinct c.ID) as 'Colaboradores' from Colaboradores c
inner join Colaboraciones co on co.IDColaborador = c.ID
inner join Tareas t on t.ID = co.IDTarea
inner join Modulos m on m.ID = t.IDModulo
inner join Proyectos p on p.ID = m.IDProyecto
inner join Clientes cl on cl.ID = p.IDCliente
inner join TiposCliente tc on tc.ID = cl.IDTipo
where tc.Nombre = 'Unicornio'

go

--La cantidad de tareas realizadas por colaboradores del país 'Argentina'.
select count(*) from Tareas t
inner join Colaboraciones c on c.IDTarea = t.ID
inner join Colaboradores co on co.ID = c.IDColaborador
inner join Ciudades ci on ci.ID = co.IDCiudad
inner join Paises p on p.ID = ci.IDPais
where p.Nombre = 'Argentina'

go

--Por cada proyecto, la cantidad de módulos que se haya estimado mal la fecha
--de fin. Es decir, que se haya finalizado antes o después que la fecha estimada.
--Indicar el nombre del proyecto y la cantidad calculada.
select p.Nombre, count(m.ID) as 'Cantidad' from Proyectos p 
inner join Modulos m on m.IDProyecto = p.ID
where m.FechaEstimadaFin != m.FechaFin
group by p.Nombre




