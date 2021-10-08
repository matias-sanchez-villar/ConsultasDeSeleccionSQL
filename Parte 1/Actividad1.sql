use BluePrint
go

--Listado de todos los clientes.
select * from Clientes

go

--Listado de todos los proyectos.
select * from Proyectos

go

--Listado con nombre, descripción, costo, fecha de inicio y de fin de todos los proyectos.
select Nombre, Descripcion, CostoEstimado, FechaInicio, FechaFin from Proyectos

go

--Listado con nombre, descripción, costo y fecha de inicio de todos los
--proyectos con costo mayor a cien mil pesos.
select Nombre, Descripcion, CostoEstimado, FechaInicio from Proyectos
where CostoEstimado > 100000

go

--Listado con nombre, descripción, costo y fecha de inicio de todos los
--proyectos con costo menor a cincuenta mil pesos
select Nombre, Descripcion, CostoEstimado, FechaInicio from Proyectos
where CostoEstimado < 5000

go

--Listado con todos los datos de todos los proyectos que comiencen en el año 2020.
select * from Proyectos
where year(FechaInicio) = 2020

go

--Listado con nombre, descripción y costo de los proyectos que comiencen en
--el año 2020 y cuesten más de cien mil pesos
select Nombre, Descripcion, CostoEstimado from Proyectos
where year(FechaInicio) = 2020 and CostoEstimado > 100000

go

-- Listado con nombre del proyecto, costo y año de inicio del proyecto.
select Nombre, CostoEstimado, year(FechaInicio) from Proyectos


go


--Listado con nombre del proyecto, costo, fecha de inicio, fecha de fin y días de
--duración de los proyectos
select Nombre, CostoEstimado, FechaInicio, FechaFin, datediff(DAY ,FechaInicio, FechaFin) from Proyectos

go

--Listado con razón social, cuit y teléfono de todos los clientes cuyo IDTipo sea
--1, 3, 5 o 6
select RazonSocial, CUIT, Telefono from Clientes
where IDTipo in(1,3,5,6)

go

--Listado con nombre del proyecto, costo, fecha de inicio y fin de todos los
--proyectos que no pertenezcan a los clientes 1, 5 ni 10.
select Nombre, CostoEstimado, FechaInicio, FechaFin from Proyectos
where IDCliente in(1,5,10)

go

--Listado con nombre del proyecto, costo y descripción de aquellos proyectos
--que hayan comenzado entre el 1/1/2018 y el 24/6/2018.
select Nombre, CostoEstimado, Descripcion from Proyectos
where FechaInicio between '2018-01-01' and '2018-06-24'

go

--Listado con nombre del proyecto, costo y descripción de aquellos proyectos
--que hayan finalizado entre el 1/1/2019 y el 12/12/2019.
select Nombre, CostoEstimado, Descripcion from Proyectos
where FechaFin between '2019-01-01' and '2019-12-12'

go

--Listado con nombre de proyecto y descripción de aquellos proyectos que aún
--no hayan finalizado.
select Nombre, Descripcion from Proyectos
where FechaFin is null

go

--Listado con nombre de proyecto y descripción de aquellos proyectos que aún
--no hayan comenzado.
select Nombre, Descripcion from Proyectos
where FechaInicio is null

go

--Listado de clientes cuya razón social comience con letra vocal.
select * from clientes
where RazonSocial like '[aeiuo]%'

go

--Listado de clientes cuya razón social finalice con vocal.
select * from clientes
where RazonSocial like '%[aeiuo]'

go

--Listado de clientes cuya razón social finalice con la palabra 'Inc'
select * from clientes
where RazonSocial like '%inc'

go

-- Listado de clientes cuya razón social no finalice con vocal.
select * from clientes
where RazonSocial like '%[^aeiuo]'

go

--Listado de clientes cuya razón social no contenga espacios.
select * from clientes
where RazonSocial like '%[^ ]%'

go

--Listado de clientes cuya razón social contenga más de un espacio.
select * from clientes
where RazonSocial like '%[  ]%'

go

--Listado de razón social, cuit, email y celular de aquellos clientes que tengan
--mail pero no teléfono.
select RazonSocial, CUIT, EMail, Celular from Clientes
where EMail is not null and Telefono is null

go

--Listado de razón social, cuit, email y celular de aquellos clientes que no
--tengan mail pero sí teléfono
select RazonSocial, CUIT, EMail, Celular from Clientes
where EMail is null and Telefono is not null

go

--Listado de razón social, cuit, email, teléfono o celular de aquellos clientes que
--tengan mail o teléfono o celular
select RazonSocial, CUIT, EMail, Telefono, Celular from Clientes
where EMail is not null or Telefono is not null or Celular is not null

go

--Listado de razón social, cuit y mail. Si no dispone de mail debe aparecer el
--texto "Sin mail".
select RazonSocial, CUIT,
case 
	when EMail is not null then EMail
	else 'sin email'
end
from Clientes

go

--Listado de razón social, cuit y una columna llamada Contacto con el mail, si
--no posee mail, con el número de celular y si no posee número de celular con
--un texto que diga "Incontactable"
select RazonSocial, CUIT,
case 
	when EMail is not null then EMail
	when Celular is not null then Celular
	else 'Incontactable'
end as 'Contacto'
from Clientes
