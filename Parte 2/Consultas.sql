use BluePrint
go

--Por cada cliente listar raz�n social, cuit y nombre del tipo de cliente.
select C.RazonSocial, C.Cuit, T.Nombre from Clientes as C inner join TiposCliente t on C.IDTipo = T.ID

go

--Por cada cliente listar raz�n social, cuit y nombre de la ciudad y nombre del
--pa�s. S�lo de aquellos clientes que posean ciudad y pa�s.
select Cl.RazonSocial, Cl.Cuit, C.Nombre as Ciudad, P.Nombre as Pais
from Clientes CL
inner join Ciudades C on CL.IDCiudad = C.ID
inner join Paises p on C.IDPais = P.ID

go

--Por cada cliente listar raz�n social, cuit y nombre de la ciudad y nombre del
--pa�s. Listar tambi�n los datos de aquellos clientes que no tengan ciudad relacionada.
select CL.RazonSocial, CL.Cuit, C.Nombre as Ciudad, P.Nombre as Pais
from Clientes CL
left join Ciudades C on CL.IDCiudad = C.ID
left join Paises P on C.IDPais = P.ID

go

--Por cada cliente listar raz�n social, cuit y nombre de la ciudad y nombre del
--pa�s. Listar tambi�n los datos de aquellas ciudades y pa�ses que no tengan
--clientes relacionados.
select CL.RazonSocial, CL.Cuit, C.Nombre as Ciudad, P.Nombre Pais
from Clientes CL
right join Ciudades C on CL.IDCiudad = C.ID
right join Paises P on P.ID = C.IDPais

--Listar los nombres de las ciudades que no tengan clientes asociados. Listar
--tambi�n el nombre del pa�s al que pertenece la ciudad.
select CL.RazonSocial, CL.Cuit, C.Nombre as Ciudad, P.Nombre Pais
from Clientes CL
full join Ciudades C on CL.IDCiudad = C.ID
full join Paises P on P.ID = C.IDPais

go

--Listar para cada proyecto el nombre del proyecto, el costo, la raz�n social del
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

--Listar los nombre de los proyectos de aquellos clientes que sean de los pa�ses
--'Argentina' o 'Italia'.
select PR.Nombre from Proyectos PR
inner join Clientes CL on PR.IDCliente = CL.ID
inner join Ciudades C on C.ID = CL.IDCiudad
inner join Paises P on P.ID = C.IDPais
where P.Nombre = 'Argentina' or P.Nombre = 'Italia'

go

--Listar para cada m�dulo el nombre del m�dulo, el costo estimado del m�dulo,
--el nombre del proyecto, la descripci�n del proyecto y el costo estimado del
--proyecto de todos aquellos proyectos que hayan finalizado.
select M.Nombre, M.CostoEstimado, P.Nombre, P.Descripcion, P.CostoEstimado
from Modulos M
full join Proyectos P on P.ID = M.IDProyecto