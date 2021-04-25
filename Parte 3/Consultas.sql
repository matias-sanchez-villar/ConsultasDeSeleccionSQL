use BluePrint
GO

--La cantidad de colaboradores
select count(*) from Colaboradores

go

--La cantidad de colaboradores nacidos entre 1990 y 2000.
select COUNT(*) from Colaboradores where year(FechaNacimiento)>=1990 and year(FechaNacimiento)<=2000

go

--El promedio de precio hora base de los tipos de tareas
select avg(PrecioHoraBase) from TiposTarea

go

--El promedio de costo de los proyectos iniciados en el año 2019.
select avg(CostoEstimado) from Proyectos where year(FechaInicio) = 2019

go

--El costo más alto entre los proyectos de clientes de tipo 'Unicornio
select max(CostoEstimado) from Proyectos
inner join Clientes on Proyectos.IDCliente = Clientes.ID
inner join TiposCliente ON TiposCliente.ID = Clientes.IDTipo
where TiposCliente.Nombre = 'Unicornio'

go

--El costo más bajo entre los proyectos de clientes del país 'Argentina'
select min(CostoEstimado) from Proyectos
inner join Clientes on Proyectos.IDCliente = Clientes.ID
inner join Ciudades ON Ciudades.ID = Clientes.IDCiudad
inner join Paises on Paises.ID = Ciudades.IDPais
where Paises.Nombre = 'Argentina'

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
select Paises.Nombre, COUNT(Clientes.ID) from Clientes
inner join Ciudades on Ciudades.ID = Clientes.IDCiudad
inner join Paises ON Paises.ID = Ciudades.IDPais
group by Paises.Nombre

--Por cada tipo de tarea, la cantidad de colaboraciones registradas. Indicar el
--tipo de tarea y la cantidad calculada.
select T.Nombre, COUNT(C.ID) as CantColaboraciones from TiposTarea t
inner join Tareas ta ON T.ID = Ta.IDTipo
inner join Colaboraciones Col on col.IDTarea = Ta.ID
inner join Colaboradores C on Col.IDColaborador = c.ID
group by T.Nombre

go

--Por cada tipo de tarea, la cantidad de colaboradores distintos que la hayan
--realizado. Indicar el tipo de tarea y la cantidad calculada.

