IF EXISTS(SELECT 1 FROM SysDataBases WHERE name='AgenciaViajes')
BEGIN
	DROP DATABASE AgenciaViajes
END
GO

CREATE DATABASE AgenciaViajes
GO

USE AgenciaViajes
GO

----TABLAS-----------------------------------------------------------------------------------------------------

CREATE TABLE Empleado(
    UsuLog VARCHAR(15) PRIMARY KEY,
    NombreUsu VARCHAR(40) NOT NULL,
    UsuPass VARCHAR(8) NOT NULL,
    Cargo VARCHAR(40) NOT NULL check (Cargo IN ('gerente', 'admin', 'vendedor'))
	)
GO

CREATE TABLE Ciudad 
(
	CodigoCiudad VARCHAR(6) PRIMARY KEY check (CodigoCiudad like '[a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z]'),
	NomCiudad VARCHAR(40) NOT NULL,
	Pais VARCHAR(40) NOT NULL,
	Activo BIT DEFAULT (1) NOT NULL -- 1 Significa que se encuentra activo
	)
GO


CREATE TABLE Cliente(
NumPasaporte VARCHAR (10) PRIMARY KEY NOT NULL,
NombreCliente VARCHAR (20) NOT NULL,
ClientPass VARCHAR (8) NOT NULL,
NumTarjeta BIGINT NOT NULL,
Activo BIT DEFAULT (1) NOT NULL -- 1 Significa que se encuentra activo
)
GO


CREATE TABLE AEROPUERTO(
CodigoAP VARCHAR (3) CHECK (CodigoAP like'[a-zA-Z][a-zA-Z][a-zA-Z]') PRIMARY KEY NOT NULL,
ImpLlegada INT NOT NULL check (ImpLlegada>0),
ImpPartida INT NOT NULL check (ImpPartida>0),
NombreAP VARCHAR (30) NOT NULL,
Direccion VARCHAR (30) NOT NULL,
CodigoCiudad VARCHAR (6) NOT NULL FOREIGN KEY REFERENCES ciudad(CodigoCiudad),
Activo BIT DEFAULT (1) NOT NULL -- 1 Significa que se encuentra activo
)
GO


Create table Vuelos
(
	CodigoVuelo varchar(15) primary key check (CodigoVuelo like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][a-zA-Z][a-zA-Z][a-zA-Z]'),
	FechaPartida datetime not null check (FechaPartida >= getdate()), --No pueden salir 2 vuelos al mismo tiempo (min5 min diferencia) para el mismo aeropuerto
	FechaLlegada DATETIME NOT NULL,
	CantAsientos INT NOT NULL CHECK(CantAsientos BETWEEN 100 AND 300),
	PrecioPasaje int NOT NULL CHECK(PrecioPasaje>0),
	CodigoAeropOrigen varchar(3) not null foreign key references Aeropuerto (CodigoAP),
	CodigoAeropDestino varchar(3) not null foreign key references Aeropuerto (CodigoAP),
	check(FechaPartida<FechaLlegada), 
	check (CodigoAeropOrigen != CodigoAeropDestino )
)
go

create table Ventas
(
NroVenta int identity (1,1) primary key,
FechaCompra datetime not null default (getdate()),
Monto int not null check (Monto>0), ---lo calculamos durante el ALTA
Usulog varchar (15) not null foreign key references Empleado (Usulog),
CodigoVuelo varchar(15) not null foreign key references Vuelos(CodigoVuelo),
NumPasaporte varchar (10) not null foreign key references Cliente (NumPasaporte)
)
go

create table Pasajeros
(
  NroVenta int not null foreign key references Ventas(NroVenta),
  NumPasaporte varchar (10) not null foreign key references Cliente(NumPasaporte),
  NroAsiento int not null check(NroAsiento between 1 and 300),
  primary key (NroVenta,NumPasaporte,NroAsiento)
)
go

----------------------------------------------------------------------------------------------
--//////////////CREACION DE USUARIOS COMUNES PARA EJECUTAR SPs (EMPLEADOS)
----------------------------------------------------------------------------------------------
CREATE PROCEDURE CreoUsuarioComun @usuLog varchar(20), @usuPass varchar(10) AS
Begin
	Declare @VarSentencia varchar(200)
	
  
	-- Multiples acciones - TRN
	Begin TRAN
	
		--creo el usuario de logueo
		Set @VarSentencia = 'CREATE LOGIN [' +  @usuLog + '] WITH PASSWORD = ' + QUOTENAME(@usuPass, '''')
		Exec (@VarSentencia)
		
		if (@@ERROR <> 0)
		Begin
			Rollback TRAN
			return -2
		end
		
		--creo usuario bd
		Set @VarSentencia = 'Create User [' +  @usuLog + '] From Login [' + @usuLog + ']'
		Exec (@VarSentencia)
		
		if (@@ERROR <> 0)
		Begin
			Rollback TRAN
			return -3
		end
		--Permiso para ejecutar SPs
	
		Set @VarSentencia = 'GRANT EXECUTE TO [' +  @usuLog + ']'
		Exec (@VarSentencia)
		
		if (@@ERROR <> 0)
		Begin
			Rollback TRAN
			return -3
		end

	Commit TRAN		

End
go

EXEC CreoUsuarioComun 'MatiEgue', 'Egu123';
EXEC CreoUsuarioComun 'SebaAmes', 'Seb123';
EXEC CreoUsuarioComun 'CesarEtc', 'Ces123';
EXEC CreoUsuarioComun 'SantRovi', 'San123';
EXEC CreoUsuarioComun 'NicoMaya', 'Nic123';
EXEC CreoUsuarioComun 'AlejAlba', 'Ale123';
EXEC CreoUsuarioComun 'JoseFern', 'Jos123';
EXEC CreoUsuarioComun 'MatiCast', 'Cas123';
EXEC CreoUsuarioComun 'MatiEspi', 'Esp123';
EXEC CreoUsuarioComun 'JosPerez', 'Jos123';

 USE master
go
 
CREATE LOGIN [IIS APPPOOL\DefaultAppPool] FROM WINDOWS 
go
 
USE AgenciaViajes
go
 
CREATE USER [IIS APPPOOL\DefaultAppPool] FOR LOGIN [IIS APPPOOL\DefaultAppPool]
go
 
 exec sys.sp_addrolemember 'db_owner', [IIS APPPOOL\DefaultAppPool]
go

--------------STORED PROCEDURES VUELOS---------------------------------------------------------------

create proc AltaVuelo
	@codigoVuelo varchar(15),
	@fechaPartida datetime,
	@fechaLlegada DATETIME,
	@cantAsientos INT,
	@precioPasaje int,
	@codigoAeropOrigen varchar(3),
	@codigoAeropDestino varchar(3)
	as begin
	--Valido PK no repetida
	if exists(select 1 from Vuelos where @codigoVuelo=CodigoVuelo)
		return -1
	--valido aeropuertos destino
	if not exists(select 1 from Aeropuerto where @codigoAeropDestino=CodigoAP)
		return -2
	--valido aeropuertos origen
	if not exists(select 1 from Aeropuerto  where @codigoAeropOrigen=CodigoAP)
		return -3

	insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino)
		values (@codigoVuelo,@fechaPartida,@fechaLlegada,@cantAsientos,@precioPasaje,@codigoAeropOrigen,@codigoAeropDestino)
		
		if @@Error <> 0
		return -4
	end
go



create proc ListadoVuelos
as begin
select * from Vuelos
end
go


--------------STORED PROCEDURES VENTAS----------------------------------------------------------------------------------------

create proc AltaVenta
@monto int, 
@usulog varchar (20),
@codigoVuelo varchar(15),
@numPasaporte varchar (10)
as begin

--Valido Empleado
if not exists (select 1 from Empleado where @usulog=Usulog)
	return -1
--Valido Vuelo
if not exists(select 1 from Vuelos where @codigoVuelo=CodigoVuelo)
	return -2
--Valido Cliente
if not exists(select 1 from Cliente where @numPasaporte=NumPasaporte and Activo=1)
	return -3
insert into Ventas (Monto, Usulog, CodigoVuelo, NumPasaporte)
    values (@monto, @usulog, @codigoVuelo, @numPasaporte);

	if @@Error <> 0
		return -4
end
go

create proc ListarVentasVuelo
@codigoVuelo varchar(15)
as 
begin
select * from Ventas where CodigoVuelo=@codigoVuelo
end
go

-------------------------STORED PROCEDURES PASAJEROS-----------------------------------------

create proc AltaPasajero
 @nroVenta int,
 @numPasaporte varchar (10),
 @nroAsiento int
 as begin

 	--Validar asiento libre
If exists (select 1 from Pasajeros inner join Ventas on Pasajeros.NroVenta = Ventas.NroVenta inner join Vuelos on Vuelos.CodigoVuelo=Ventas.CodigoVuelo where @nroAsiento=NroAsiento)
	return -1

 ---Valido PK no repetida
 if exists (select 1 from Pasajeros where @nroVenta=NroVenta and @numPasaporte=NumPasaporte and @nroAsiento=NroAsiento)
	return -2

--Valido Venta
if not exists (select 1 from Ventas where @nroVenta=NroVenta)
	return -3

--Valido Cliente
if not exists (select 1 from Cliente where @numPasaporte=NumPasaporte and Activo=1)
	return -4

    insert Pasajeros (NroVenta, NumPasaporte, NroAsiento)
    values (@nroVenta, @numPasaporte, @nroAsiento);

    IF @@ERROR <> 0
        return -5
end
go

create proc ListarPasajeros
@nroVenta int
as
begin
select * from Pasajeros
where NroVenta=@nroVenta
end
go

-------------------------------------------------- SP's CLIENTE -----------------------------------------------------------




CREATE PROC sp_BuscarClienteActivo
@NumPasaporte varchar(10)
AS
	SELECT cli.NumPasaporte, cli.NombreCliente, cli.ClientPass, cli.NumTarjeta
	FROM CLIENTE AS cli 
	WHERE cli.NumPasaporte = @NumPasaporte AND cli.Activo = 1
GO

CREATE PROC sp_BuscarClienteTodos
@NumPasaporte varchar(10)
AS
	SELECT cli.NumPasaporte, cli.NombreCliente, cli.ClientPass, cli.NumTarjeta
	FROM CLIENTE AS cli 
	WHERE cli.NumPasaporte = @NumPasaporte
GO

CREATE PROC sp_AgregarCliente
@NumPasaporte varchar(10), @NombreCliente varchar(20), @ClientePass varchar(8), @NumTarjeta int
AS

	IF EXISTS (SELECT * FROM CLIENTE cli WHERE cli.NumPasaporte = @NumPasaporte AND cli.Activo = 1)
		RETURN -1

		IF EXISTS (SELECT * FROM CLIENTE cli WHERE cli.NumPasaporte = @NumPasaporte AND cli.Activo = 0)
			BEGIN
				UPDATE CLIENTE SET ClientPass = @ClientePass, NumTarjeta = @NumTarjeta, ACTIVO = 1
				WHERE NumPasaporte = @NumPasaporte
			END

		ELSE
			BEGIN
				INSERT CLIENTE VALUES(@NumPasaporte, @NombreCliente, @ClientePass, @NumTarjeta, 1)	
			END
		
	 IF @@ERROR <> 0
        return -2

			RETURN 1	
			GO

CREATE PROC sp_ModificarCliente
@NumPasaporte varchar(10), @NombreCliente varchar(20), @ClientePass varchar(8), @NumTarjeta int
AS
  
       IF NOT EXISTS (SELECT * FROM CLIENTE cli WHERE cli.NumPasaporte = @NumPasaporte AND cli.Activo = 1)
           RETURN -1
			
				UPDATE CLIENTE SET ClientPass = @ClientePass, NumTarjeta = @NumTarjeta WHERE NumPasaporte = @NumPasaporte 		
		
	 IF @@ERROR <> 0
        return -2	

		RETURN 1
GO

CREATE PROC sp_EliminarCliente
@NumPasaporte varchar(10)
AS

	IF NOT EXISTS (SELECT * FROM CLIENTE cli WHERE cli.NumPasaporte = @NumPasaporte AND cli.Activo = 1)
		RETURN -1

		IF EXISTS (SELECT * FROM VENTAS WHERE NumPasaporte = @NumPasaporte) --Si tiene Venta asociada dejo Inactivo
		BEGIN 
			UPDATE CLIENTE
			SET ACTIVO = 0
			WHERE NumPasaporte = @NumPasaporte
		END

		IF EXISTS (SELECT * FROM Pasajeros WHERE NumPasaporte = @NumPasaporte) --Si es pasajero de un vuelo dejo Inactivo
		BEGIN 
			UPDATE CLIENTE
			SET ACTIVO = 0
			WHERE NumPasaporte = @NumPasaporte
		END

		ELSE
			BEGIN
				DELETE CLIENTE
				WHERE NumPasaporte = @NumPasaporte
			END	

	 IF @@ERROR <> 0
        return -1

			RETURN 1
GO

create proc listarClientes
as
begin
select * from Cliente
end
go


-------------------------------------------------- SP's AEROPUERTO -----------------------------------------------------------
CREATE PROC sp_BuscarAeropuertoActivo
@CodigoAP varchar(3)
AS
	SELECT ae.CodigoAP, ae.ImpLlegada, ae.ImpPartida, ae.NombreAP, ae.Direccion, ae.CodigoCiudad
	FROM AEROPUERTO AS ae 
	WHERE ae.CodigoAP = @CodigoAP AND ae.Activo = 1
GO

CREATE PROC sp_BuscarAeropuertoTodos
@CodigoAP varchar(3)
AS
	SELECT ae.CodigoAP, ae.ImpLlegada, ae.ImpPartida, ae.NombreAP, ae.Direccion, ae.CodigoCiudad
	FROM AEROPUERTO AS ae 
	WHERE ae.CodigoAP = @CodigoAP
GO

CREATE PROC sp_AgregarAeropuerto
@CodigoCiudad varchar(6), @CodigoAP VARCHAR(3), @ImpLlegada INT, @ImpPartida INT, @NombreAP VARCHAR(15), @Direccion VARCHAR(30)
AS

	IF EXISTS (SELECT * FROM AEROPUERTO AS ae WHERE CodigoAP = @CodigoAP AND ae.Activo = 1) --ojo decia @CodigoAP = @CodigoAP
		RETURN -1  --valido pk

	
	IF NOT EXISTS (SELECT * FROM CIUDAD AS ciu where ciu.CodigoCiudad = @CodigoCiudad AND Activo = 1)
		RETURN -2 ---valido Ciudad
	

		IF EXISTS (SELECT * FROM AEROPUERTO AS ae WHERE CodigoAP = @CodigoAP AND ae.Activo = 0)
			BEGIN
				UPDATE AEROPUERTO SET ImpLlegada = @ImpLlegada, @ImpPartida = @ImpPartida, NombreAP = @NombreAP, Direccion = @Direccion, ACTIVO = 1
				WHERE CodigoAP = @CodigoAP
			END
		ELSE
			BEGIN
				INSERT AEROPUERTO VALUES(@CodigoAP, @ImpLlegada, @ImpPartida, @NombreAP, @Direccion, @CodigoCiudad, 1)	
			END
		
	IF @@ERROR <> 0
        return -3   
				RETURN 1
GO


 
CREATE PROC sp_ModificarAeropuerto
@CodigoCiudad varchar(6), --fk
@CodigoAP VARCHAR (3), 
@ImpLlegada INT, 
@ImpPartida INT, 
@NombreAP VARCHAR (15), 
@Direccion VARCHAR (30)
AS    
       IF NOT EXISTS (SELECT * FROM AEROPUERTO AS ae WHERE CodigoAP = @CodigoAP AND ae.Activo = 1) 
           RETURN -1 --valido aeropuerto

		IF NOT EXISTS (SELECT 1 FROM Ciudad WHERE CodigoCiudad = @CodigoCiudad AND Activo = 1) 
           RETURN -2 --valido ciudad
		   
				UPDATE AEROPUERTO 
				SET ImpLlegada = @ImpLlegada, 
				ImpPartida = @ImpPartida, 
				NombreAP = @NombreAP, 
				Direccion = @Direccion,
				CodigoCiudad=@CodigoCiudad,
				ACTIVO = 1
				WHERE CodigoAP = @CodigoAP 	
		
	IF @@ERROR <> 0
        return -3

		RETURN 1
GO

CREATE PROC sp_EliminarAeropuerto
@CodigoAP varchar(3)
AS

	IF NOT EXISTS (SELECT * FROM AEROPUERTO AS ae WHERE CodigoAP = @CodigoAP AND ae.Activo = 1)
		RETURN -1
	
		IF EXISTS (SELECT * FROM VUELOs AS v WHERE v.CodigoAeropOrigen = @CodigoAP or v.CodigoAeroPDestino = @CodigoAP)
		BEGIN 
			UPDATE AEROPUERTO
			SET ACTIVO = 0
			WHERE CodigoAP = @CodigoAP
		END

		ELSE
			BEGIN
				DELETE AEROPUERTO
				WHERE CodigoAP = @CodigoAP
			END	

	IF @@ERROR <> 0
        return -1

			RETURN 1
GO

create proc listarAeropuerto
as
begin
select * from AEROPUERTO
end
go


--/////////////////////SP EMPLEADO///////////////////////////////

create procedure BuscarEmpleado
 @usuLog VARCHAR(15)
as
begin
	select * 
	from Empleado
	where UsuLog=@usuLog
end
go

CREATE PROC LogueoEmpleado
@usuLog varchar(15), 
@usuPass varchar(8)
AS
	SELECT 1
	FROM Empleado
	WHERE UsuLog=@usuLog and UsuPass=@usuPass
GO





--//////////////////////// SP CIUDADES  /////////////////////////////////////--

-------------Agregar------------- 
create proc AgregarCiudad
@codigoCiudad VARCHAR(6),
@nomCiudad VARCHAR(40),
@pais VARCHAR(6)
as 

if exists (select 1 from Ciudad where @codigoCiudad = Ciudad.CodigoCiudad and Ciudad.Activo = 1)
return -1

IF EXISTS (select 1 from Ciudad where @codigoCiudad = Ciudad.CodigoCiudad and Ciudad.Activo = 0)
			BEGIN
				UPDATE Ciudad SET 
				@nomCiudad = Ciudad.NomCiudad,
				@pais = Ciudad.Pais where @codigoCiudad = Ciudad.CodigoCiudad
			END

else
insert Ciudad values(@codigoCiudad,@nomCiudad,@pais,1) 

if(@@ERROR != 0)
return -2

return 1

go

--------------Buscar--------------------
create proc BuscarCiudadActiva ---Buscar solo activos
@codigoCiudad VARCHAR(6)
as 

select * from Ciudad where Ciudad.CodigoCiudad = @codigoCiudad and Ciudad.Activo = 1

go

create proc BuscarCiudad ---Buscar todas las ciudades
@codigoCiudad VARCHAR(6)
as 
select * from Ciudad where Ciudad.CodigoCiudad = @codigoCiudad
go

--------------Modificar-------------
create proc ModificarCiudad
@codigoCiudad VARCHAR(6),  
@nomCiudad VARCHAR(40),
@pais VARCHAR(6)
as 

if not exists (select 1 from Ciudad where  Ciudad.CodigoCiudad = @codigoCiudad  and Ciudad.Activo = 1)
	return -1

update Ciudad set 

@nomCiudad = Ciudad.NomCiudad,
@pais = Ciudad.Pais where @codigoCiudad = Ciudad.CodigoCiudad

if(@@ERROR != 0)
return -2
go

--------------Eliminar-------------
create proc EliminarCiudad
@codigoCiudad VARCHAR(6)
as 

if not exists (select 1 from Ciudad where  Ciudad.CodigoCiudad = @codigoCiudad )
	return -1

if exists(select 1 from Aeropuerto where Aeropuerto.CodigoCiudad =@codigoCiudad )
		begin	
			update Ciudad
			SET Activo=0  
			WHERE CodigoCiudad = @codigoCiudad
		end

DELETE Ciudad
	WHERE Ciudad.CodigoCiudad = @codigoCiudad

if(@@ERROR != 0)
	return -2
go

create proc ListadoCiudades
as begin
select * from Ciudad
end
go


----------------------------------------------------------------------------------
---//////////////////////////// INSERTS ////////////////////////////////////////
----------------------------------------------------------------------------------



INSERT Empleado (UsuLog,UsuPass,NombreUsu,Cargo) VALUES 
					   ('MatiEgue','Egu123','Matias Eguez','Vendedor'),
					   ('SebaAmes','Seb123','Sebastian Amestoy','Admin'),
					   ('CesarEtc','Ces123','Cesar Etchechury','Gerente'),
					   ('SantRovi','San123','Santiago Rovitto','Vendedor'),
					   ('NicoMaya','Nic123','Nicolas Maya','Vendedor'),
					   ('AlejAlba','Ale123','Alejandro Alba','Gerente'),
					   ('JoseFern','Jos123','Jose Fernandez','Admin'),
					   ('MatiCast','Cas123','Matias Castellinni','Admin'),
					   ('MatiEspi','Esp123','Matias Espinosa','Vendedor'),
					   ('JosPerez','Jos123','Jose Perez','Vendedor')
go

INSERT Ciudad VALUES ('NYCUSA','New York','Estados Unidos',1),
					('USHARG','Ushuaia','Argentina',1),
					('SASDOR','San Salvador','El Salvador',1),
					('RECIFE','Recife','Brasil',1),
					('SFAUSA','San Francisco','Estados Unidos',1),
					('MVDURU','Montevideo','Uruguay',1),
					('MDNCOL','Medellin','Colombia',1),
				    ('RIOBRA','Rio de Janeiro','Brasil',1),
					('TDOCRA','Tamarindo','Costa Rica',1),
					('CAYENA','Cayena','Guayana Francesa',1),
					('TJOPRU','Trujillo','Peru',1),
					('SFECHI','San Felipe','Chile',1),
					('CASVNZ','Caracas','Venezuela',1),
					('CUNMEX','Cancun','Mexico',1),
					('PDEURU','Punta Del Este','Uruguay',1),
					('LPZBOL','La Paz','Bolivia',1),
					('MDZARG','Mendoza','Argentina',1),
					('GYLECU','Guayaquil','Ecuador',1),
					('ACACHI','Arica','Chile',1),
					('CJACOL','Cartajena','Colombia',1)		
go


------------------------INSERT CLIENTE-------------------------------------------------------------------------------------------------------

insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('AB85866510', 'Justen Brandsma', 'ZSBI969', '1908962002');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('NR74771350', 'Margarethe Dunlea', 'PGLH673', '3642153088');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('CF23998196', 'Tarra Sottell', 'JUQN170', '5321199440');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('PL03576691', 'Sherie Giacomazzo', 'JODC960', '7549746052');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('DG33264553', 'Althea Floodgate', 'XFUG086', '8708279336');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('FB05759988', 'Milty Runnalls', 'OUZA192', '5250880263');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('VW47914137', 'Alexia De Santos', 'ODLD784', '0898031325');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('MY30759157', 'Tybie Pittet', 'QUDN973', '6355944950');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('UG09709778', 'Dicky Lyddiatt', 'KTRQ596', '1340210898');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('QA02282274', 'Thaine Rewan', 'HXSN674', '5444692208');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('ZR21504081', 'Fancie Buck', 'IYIX730', '7488720893');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('IJ51055987', 'Cherice Lotherington', 'EZTO867', '7770589206');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('CJ81231879', 'Hadlee Lamperd', 'MBYH229', '9280613282');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('ND96727324', 'Claudian Ferraro', 'XERG783', '0134177078');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('RP58505822', 'Ashia Dangerfield', 'ITEN889', '2754269306');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('AK07175184', 'Vinita Leghorn', 'WIID627', '2533148637');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('UY23964955', 'Charmain Lehemann', 'JBFT872', '2595386193');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('HJ20702534', 'Ron Oki', 'RRPJ811', '2591082872');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('PV96859986', 'Hurley Reavell', 'KQJZ445', '4301891618');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('PJ62247982', 'Thurstan Eshelby', 'YVDD594', '0637505083');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('GW89382121', 'Humbert Boothe', 'CKWW118', '8379447462');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('EO92681037', 'Yolane Masterman', 'HQSJ971', '0928040952');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('JK29009594', 'Andros Pepperell', 'PWPU408', '5094585433');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('TX11737945', 'Nicoli Rosevear', 'BABC988', '0572068015');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('UY63147470', 'Lauretta Gange', 'HOAY127', '1548238405');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('PQ07655849', 'Chase Brooks', 'LOJE337', '8820922703');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('LP88169491', 'Pebrook Johl', 'TYTI521', '9115265820');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('AP18565604', 'Devon Agott', 'RXXV566', '9487798516');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('NQ60826584', 'Arnold Tunstall', 'NSUE864', '2795087173');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('TZ25392380', 'Rorke Bathowe', 'YXLD565', '6637929115');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('HB22675590', 'Sheffie Burrows', 'LQKC586', '0368463835');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('DR05542313', 'Bernetta Negal', 'UVNC083', '6437188157');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('LL02443548', 'Kerrin Chittie', 'WAZC063', '8003588157');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('FM23615606', 'Andi McQuode', 'VFBZ570', '4787598912');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('SB39861378', 'Heidie Rossbrook', 'TERT816', '5841688906');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('CE33594454', 'Klement Peetermann', 'AAKM398', '8038436786');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('FJ85743328', 'Ardyce Lukins', 'MOWB158', '3331485715');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('CE53410758', 'Abie Leeson', 'OOER407', '7866170880');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('UC18967631', 'Kayne MacKinnon', 'FVGZ407', '6490513376');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('MW30717458', 'Mirabelle Whimpenny', 'SIOL820', '4560254978');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('MS70765004', 'Amalie Harback', 'SZUN535', '1449800639');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('KG86052975', 'Cletus Gallego', 'SQRG067', '1572954074');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('GW86883558', 'Rosalinde Nannoni', 'FEKC573', '3060597589');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('KP63740809', 'Amber Blogg', 'AXCH208', '3814179682');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('AX88003741', 'Barnabe Mulbery', 'LUNX815', '6019153754');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('IV54745407', 'Alexandros Stopper', 'WDYC890', '1270606722');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('KE84410920', 'Leslie Darnbrough', 'STHA813', '1465153590');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('MK45619730', 'Gill Woodcraft', 'KXQK017', '6076118246');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('YP18946351', 'Inger Bourges', 'OPYO965', '3900862136');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('KZ12681313', 'Hilda Jeaffreson', 'OUFW245', '2961329909');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('WB07865856', 'Randal Bartosiak', 'YOQN925', '8522516535');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('RK25321787', 'Jonathan Twinbrow', 'CCYR109', '9992468879');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('HR80714200', 'Sylvan Rottcher', 'VOSH919', '5917823455');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('ZV78510193', 'Corey Mazzia', 'KJSL713', '8419584871');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('OP02640072', 'Heloise McKee', 'IIRZ591', '1860767038');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('FI22222787', 'Livvy Morant', 'XHSH238', '8978211181');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('TX53059770', 'Jordon Baggally', 'YDXN968', '0222211034');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('NE75929540', 'Elroy Pearcy', 'UTSS461', '1711031130');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('AJ46943504', 'Basilio O'' Concannon', 'BUFJ073', '2532252526');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('GK42513995', 'Meir Collabine', 'SYQX676', '1883670445');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('QV80252945', 'Silvana Rean', 'GKCD322', '1147270900');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('KD86273760', 'Loralee Gamlyn', 'LKGW070', '4512814911');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('EE75850096', 'Frederich Brotherick', 'CITU139', '2393398990');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('MM18572940', 'Sioux Guerrazzi', 'BQMW433', '2696574486');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('NI80822334', 'Gillian Hernik', 'XUAC465', '4906215723');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('PR59911981', 'Alysa Boas', 'CSXG799', '6213910574');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('IR64836210', 'Emmanuel Peris', 'EYPH764', '3020239442');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('NJ08254291', 'Celinda Stuttard', 'BFST261', '3672690689');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('HW43630930', 'Silvana Pattrick', 'OJSF901', '8642799916');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('NI17219071', 'Lucien Wagner', 'EOFS963', '0024004771');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('ST04634061', 'Sherri Belderson', 'GCFG955', '9663646059');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('PY95843698', 'Kirsteni Catlette', 'HMBK792', '6783150492');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('QO71199521', 'Halley Davenell', 'LDVM193', '6188057065');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('ST03374520', 'Bunnie Potten', 'HHPV077', '8397440221');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('UG26000208', 'Charlena Slack', 'EFLX384', '5696815483');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('VL35883189', 'Dorise Penhaleurack', 'QJST846', '0146122789');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('IP89820113', 'Andra Downes', 'SEJT531', '6953897827');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('MS53823665', 'Webster Scobie', 'NPRD273', '3155184086');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('UN86116317', 'Theresina Sonschein', 'FAIY852', '8706228186');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('ZC07772022', 'Leann Goscomb', 'EFPF699', '0614914074');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('CK85479872', 'Coralie Brimblecombe', 'JWGR816', '3910188972');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('NF52124119', 'Ellis Jenyns', 'HSJB448', '7525534781');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('QI31968830', 'Courtenay Delamaine', 'IDEC785', '5912265760');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('LR33691099', 'Verne Liddel', 'SLWA872', '0585189022');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('VL69536104', 'Aluin Wakeham', 'NVOC777', '7694357069');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('TU77980556', 'Dody Leeves', 'NTDR590', '0839860774');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('IB77937638', 'Marjy Dawidowitz', 'WGVX418', '8933030673');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('ZE00660225', 'Harrietta Keelan', 'VDKC273', '1947604363');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('VI24852201', 'Orv Kempston', 'BQPL444', '7164197984');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('ZP97999324', 'Dalt Pallant', 'SDSY986', '1655943975');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('GT89135138', 'Karlis Paternoster', 'NWIQ832', '2210032228');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('LY10925749', 'Beverlie Barnham', 'GOYC515', '8717157308');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('GB09775395', 'Allis Snozzwell', 'QOKR190', '5841254310');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('LW66697283', 'Thorpe Allmann', 'MQQZ046', '3871288532');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('WK28555978', 'Maryanne McKeever', 'EGMD023', '1651698975');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('NQ30508825', 'Dita Pashler', 'DTUU956', '6069216415');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('HP30649390', 'Emmanuel Oganesian', 'NNCJ829', '8968450085');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('YK39483783', 'Cullan Farquhar', 'TNFP450', '4782102060');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('BN54895211', 'Carter Durand', 'ORBR084', '0453693961');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('AI86150008', 'Ella Crookall', 'MVCW949', '5801506316');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('CW35148778', 'Charmaine Lovemore', 'ESIK644', '7540887179');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('MZ02248210', 'Dion Gronauer', 'DVIH252', '1449198168');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('NR60004099', 'Renard Wilcock', 'CGQI597', '9489737549');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('NO07470557', 'Nora Doddemeede', 'AOET686', '4732448209');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('EE55996788', 'Donielle Severns', 'ZQPA378', '8166017131');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('BC86152414', 'Redford Durbyn', 'XOQL389', '2769634032');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('EC01510034', 'Frannie Girdler', 'QETO710', '1947467733');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('WM08405319', 'Jada Curtain', 'RAJX407', '6250793711');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('VN01288692', 'Ellyn Medford', 'UXID401', '3532653698');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('JO19237254', 'Kyrstin Axup', 'BULV975', '5288411853');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('QX41675215', 'Elwira Kaasmann', 'EEBZ743', '1630116886');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('QF76203268', 'Alvinia Ruston', 'KWHR841', '2284659626');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('OI28106564', 'Jaquenetta Horbart', 'IMSJ045', '7474338871');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('ZL73085567', 'Julee Diemer', 'ZDOH065', '9814850552');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('OK50235050', 'Brand Feilden', 'GTHW205', '0716634810');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('ZN77897030', 'Matthus Broggio', 'ZSND409', '4841770310');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('LA09041809', 'Shir Brinsden', 'KBKG772', '4941618149');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('UN91375369', 'Fredric Netting', 'HXKD117', '8122144383');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('XB98677028', 'Lorne Ducarne', 'OBFW309', '4451162085');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('GY66251082', 'Nobie Newstead', 'MYJS909', '4982369766');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('AA71515410', 'Milt Jammet', 'NXDY208', '2248218285');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('PU44155899', 'Virgie Hedau', 'TXGH397', '3353748620');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('CV78331634', 'Cullin Cutford', 'EHKW113', '4472847411');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('FF40104564', 'Hedvige Sigars', 'PNGI462', '2832427746');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('BB76703983', 'Maryjane Calleja', 'FCBJ280', '0507410856');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('GV22731197', 'Jeremias Scholfield', 'HAFQ344', '7650731665');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('RJ01680400', 'Missy Riseam', 'KVSE053', '6827980609');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('PQ14262560', 'Westbrooke Simic', 'PQRS700', '4971280918');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('YE57346457', 'Kristopher Ainscow', 'EQBB148', '0736596487');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('IK08256756', 'Sergio Durrans', 'GGZU409', '7625159819');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('PA88346050', 'Chryste MacCauley', 'NWTX854', '2963462003');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('TH02086864', 'Jacquelyn Duesberry', 'QOFA675', '9385130428');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('ON13667717', 'Arnoldo Alek', 'SGNT664', '5941259346');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('QQ64177386', 'Kimberli Crathern', 'KUEV559', '6305439775');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('BA86594853', 'Roxana Trussler', 'GNWY688', '2441938682');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('AD91806575', 'Nicola Garrit', 'LAKC669', '6624595414');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('FU83876707', 'Dorena Born', 'UXVI931', '4941648487');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('NK75537444', 'Emmery Ruffy', 'YAQS933', '4441753920');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('PH51508052', 'Turner Alfonsetto', 'ZRER885', '2423129735');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('UE41504269', 'Hollis Richin', 'AZZN882', '5141761661');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('HG96592466', 'Loralee Theodoris', 'RZQH441', '4098661921');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('NN25553434', 'Lynnea Shirlaw', 'TMHW599', '1718970229');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('AY50884490', 'Earvin Pablo', 'WNKF391', '9840597403');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('VC19767690', 'Salome Seifenmacher', 'TWCB697', '7390577970');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('BT69274693', 'Clark Mannock', 'NSQR030', '9706013483');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('EG11553099', 'Gwenni Prettyjohn', 'DLVR153', '7568439233');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('ZZ18406855', 'Fina Lemin', 'MUTO556', '4758640759');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('ZW12698680', 'Nessa Nortunen', 'WAVP849', '7372950742');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('UL62989504', 'Olin Nibloe', 'VERX972', '4503031753');
insert into Cliente (NumPasaporte, NombreCliente, ClientPass, NumTarjeta) values ('EJ18433218', 'Brandea Maggill', 'LMZH463', '3411262469')
go

--------------------------INSERT AEROPUERTO------------------------------------------------------------------------------------------------------


insert into AEROPUERTO (CodigoAP, ImpLlegada, ImpPartida, NombreAP, Direccion, CodigoCiudad, Activo) values ('NYA', 20, 1973, 'New York Airport', '0596 Petterle Way', 'NYCUSA', 1);
insert into AEROPUERTO (CodigoAP, ImpLlegada, ImpPartida, NombreAP, Direccion, CodigoCiudad, Activo) values ('UHA', 200, 4627, 'Ushuaia Airport', '78 Fulton Circle', 'USHARG', 1);
insert into AEROPUERTO (CodigoAP, ImpLlegada, ImpPartida, NombreAP, Direccion, CodigoCiudad, Activo) values ('MVA', 166, 4423, 'Montevideo Airport', '8 Summer Ridge Center', 'MVDURU', 1);
insert into AEROPUERTO (CodigoAP, ImpLlegada, ImpPartida, NombreAP, Direccion, CodigoCiudad, Activo) values ('CYA', 100, 3101, 'Cayena Airport', '49064 Northwestern Lane', 'CAYENA', 1);
insert into AEROPUERTO (CodigoAP, ImpLlegada, ImpPartida, NombreAP, Direccion, CodigoCiudad, Activo) values ('PUA', 23, 2000, 'Punta Airport', '769 3rd Road', 'PDEURU', 1);
insert into AEROPUERTO (CodigoAP, ImpLlegada, ImpPartida, NombreAP, Direccion, CodigoCiudad, Activo) values ('LPA', 500, 752, 'La Paz Airport', '1297 Mosinee Road', 'LPZBOL', 1);
insert into AEROPUERTO (CodigoAP, ImpLlegada, ImpPartida, NombreAP, Direccion, CodigoCiudad, Activo) values ('MZA', 252, 1600, 'Mendoza Airport', '414 Carpenter Road', 'MDZARG', 1);
insert into AEROPUERTO (CodigoAP, ImpLlegada, ImpPartida, NombreAP, Direccion, CodigoCiudad, Activo) values ('ACA', 23, 1750, 'Arica Airport', '39789 Scofield Junction', 'ACACHI', 1);
insert into AEROPUERTO (CodigoAP, ImpLlegada, ImpPartida, NombreAP, Direccion, CodigoCiudad, Activo) values ('CJA', 225, 2354, 'Cartajena Airport', '2855 Heath Park', 'CJACOL', 1);
insert into AEROPUERTO (CodigoAP, ImpLlegada, ImpPartida, NombreAP, Direccion, CodigoCiudad, Activo) values ('SFA', 600, 4432, 'San Francisco Airport', '21 Moulton Hill', 'SFAUSA', 1);
insert into AEROPUERTO (CodigoAP, ImpLlegada, ImpPartida, NombreAP, Direccion, CodigoCiudad, Activo) values ('MLA', 700, 2751, 'Medellin Airport', '991 Messerschmidt Court', 'MDNCOL', 1);
insert into AEROPUERTO (CodigoAP, ImpLlegada, ImpPartida, NombreAP, Direccion, CodigoCiudad, Activo) values ('RJA', 650, 2700, 'Rio Airport', '372 Eagle Crest Terrace', 'RIOBRA', 1);
insert into AEROPUERTO (CodigoAP, ImpLlegada, ImpPartida, NombreAP, Direccion, CodigoCiudad, Activo) values ('TMA', 23, 1500, 'Tamarindo Airport', '3008 Tomscot Parkway', 'TDOCRA', 1);
insert into AEROPUERTO (CodigoAP, ImpLlegada, ImpPartida, NombreAP, Direccion, CodigoCiudad, Activo) values ('GYA', 250, 2170, 'Guayaquil Airport', '0 Hovde Terrace', 'GYLECU', 1);
insert into AEROPUERTO (CodigoAP, ImpLlegada, ImpPartida, NombreAP, Direccion, CodigoCiudad, Activo) values ('REA', 189, 1140, 'Recife Airport', '13571 Chive Terrace', 'RECIFE', 1);
insert into AEROPUERTO (CodigoAP, ImpLlegada, ImpPartida, NombreAP, Direccion, CodigoCiudad, Activo) values ('ATL', 500, 2372, 'Hartsfield', '5551 Hill Road', 'TJOPRU', 1);
insert into AEROPUERTO (CodigoAP, ImpLlegada, ImpPartida, NombreAP, Direccion, CodigoCiudad, Activo) values ('LAX', 500, 2372, 'Los Angeles', '372 East Terrace', 'NYCUSA', 1);
insert into AEROPUERTO (CodigoAP, ImpLlegada, ImpPartida, NombreAP, Direccion, CodigoCiudad, Activo) values ('ORD', 500, 2372, 'O-Hare', '1297 Hot Road', 'SFAUSA', 1);
insert into AEROPUERTO (CodigoAP, ImpLlegada, ImpPartida, NombreAP, Direccion, CodigoCiudad, Activo) values ('DFW', 500, 2372, 'Dallas Fort Worth', '991 Smith Court', 'NYCUSA', 1);
insert into AEROPUERTO (CodigoAP, ImpLlegada, ImpPartida, NombreAP, Direccion, CodigoCiudad, Activo) values ('DEN', 500, 2372, 'Denver', '414 BlackSmith Road', 'SFAUSA', 1);
GO




----------------------INSERT VUELOS---------------------------------------------------------------------------



insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202469821090CRT', '20240426 11:07', '20240428 11:07', 218, 771, 'NYA', 'DEN');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202461978103ZPE', '20240608 09:27', '20240613 09:27', 187, 524, 'UHA', 'DFW');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202401518926VJD', '20240508 11:07', '20240509 11:07', 264, 862, 'MVA', 'ORD');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202431853556OXK', '20240416 12:37', '20240421 12:37', 245, 980, 'CYA', 'LAX');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202403982348KZW', '20240613 17:58', '20240614 17:58', 223, 689, 'PUA', 'ATL');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202493964163QSC', '20240608 09:37', '20240611 09:37', 210, 877, 'LPA', 'REA');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202431657744TEH', '20240501 00:00', '20240506 00:00', 132, 817, 'MZA', 'GYA');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202455458819DNI', '20240309 19:52', '20240312 19:52', 165, 718, 'ACA', 'TMA');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202444674715OOH', '20240328 03:00', '20240401 03:00', 236, 511, 'CJA', 'RJA');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202481080603BIM', '20240227 04:09', '20240229 04:09', 102, 809, 'SFA', 'MLA');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202414329065EPC', '20240531 08:25', '20240602 08:25', 132, 808, 'MLA', 'SFA');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202460313090CWH', '20240228 09:16', '20240301 09:16', 222, 799, 'RJA', 'CJA');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202492203922CGG', '20240611 12:20', '20240612 12:20', 222, 741, 'TMA', 'ACA');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202447341125TVU', '20240601 09:03', '20240605 09:03', 157, 890, 'GYA', 'MZA');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202407748780FJE', '20240217 04:29', '20240219 04:29', 183, 788, 'REA', 'LPA');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202459078217JUW', '20240512 20:13', '20240514 20:13', 166, 801, 'ATL', 'PUA');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202434130247ATY', '20240313 10:56', '20240318 10:56', 205, 565, 'NYA', 'CYA');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202443558384BCS', '20240309 18:06', '20240313 18:06', 239, 530, 'UHA', 'MVA');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202434067039SZT', '20240315 23:30', '20240318 23:30', 204, 755, 'MVA', 'UHA');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202493877991SYW', '20240418 14:20', '20240422 14:20', 299, 714, 'CYA', 'NYA');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202413661480KEH', '20240329 12:04', '20240331 12:04', 300, 743, 'PUA', 'DEN');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202499939322YGT', '20240416 15:25', '20240419 15:25', 255, 878, 'LPA', 'DFW');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202463578166BHP', '20240225 00:54', '20240228 00:54', 247, 959, 'MZA', 'ORD');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202465415169EVY', '20240419 13:29', '20240423 13:29', 284, 742, 'ACA', 'LAX');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202413583574JAW', '20240424 00:20', '20240425 00:20', 170, 894, 'CJA', 'ATL');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202495337924QGS', '20240527 05:23', '20240601 05:23', 167, 525, 'SFA', 'REA');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202419572084NOV', '20240601 23:58', '20240602 23:58', 168, 672, 'MLA', 'ATL');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202426014512ENF', '20240318 17:52', '20240322 17:52', 288, 904, 'RJA', 'LAX');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202429298382KWI', '20240508 19:17', '20240512 19:17', 225, 565, 'TMA', 'REA');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202481897311GPY', '20240407 20:23', '20240412 20:23', 259, 729, 'GYA', 'REA');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202480789439LXE', '20240330 20:19', '20240401 20:19', 280, 908, 'REA', 'TMA');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202427091665TBC', '20240403 16:12', '20240407 16:12', 221, 771, 'MLA', 'RJA');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202482505863RAW', '20240327 12:00', '20240330 12:00', 288, 628, 'NYA', 'MLA');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202463108576NMZ', '20240525 21:35', '20240530 21:35', 297, 637, 'UHA', 'SFA');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202450425933UFI', '20240319 23:09', '20240324 23:09', 288, 742, 'MVA', 'CJA');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202488784541KLO', '20240501 10:06', '20240504 10:06', 177, 919, 'CYA', 'ACA');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202494144769KTR', '20240410 13:58', '20240415 13:58', 242, 939, 'PUA', 'MZA');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202495587074IOW', '20240428 04:06', '20240430 04:06', 202, 729, 'PUA', 'LPA');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202482883439NFG', '20240508 10:30', '20240509 10:30', 272, 557, 'MZA', 'PUA');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202470115468TFY', '20240327 17:56', '20240329 17:56', 289, 867, 'ACA', 'CYA');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202471532110BTY', '20240516 18:59', '20240518 18:59', 123, 645, 'CJA', 'MVA');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202453269276IGE', '20240405 23:36', '20240407 23:36', 223, 692, 'CJA', 'UHA');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202460446470LLH', '20240507 16:55', '20240509 16:55', 186, 671, 'MLA', 'NYA');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202416679362JNO', '20240517 09:03', '20240521 09:03', 178, 752, 'RJA', 'DEN');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202456020994YMY', '20240419 00:32', '20240422 00:32', 142, 934, 'TMA', 'DFW');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202473163827OKG', '20240331 22:28', '20240403 22:28', 141, 833, 'GYA', 'ORD');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202410730295AWI', '20240509 12:58', '20240512 12:58', 204, 516, 'REA', 'LAX');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202410825981YNU', '20240524 01:38', '20240529 01:38', 151, 728, 'TMA', 'ATL');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202407864934SHB', '20240410 21:38', '20240413 21:38', 190, 580, 'NYA', 'REA');
insert into Vuelos (CodigoVuelo, FechaPartida, FechaLlegada, CantAsientos, PrecioPasaje, CodigoAeropOrigen, CodigoAeropDestino) values ('202469947114OYK', '20240228 18:36', '20240301 18:36', 257, 527, 'UHA', 'GYA');
GO

----------------------------------INSERT VENTAS---------------------------------------------

insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ('20240229 06:51', 626, 'MatiEgue', '202469821090CRT', 'AB85866510');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ('20240117 17:39', 1418, 'MatiEgue', '202469821090CRT', 'AB85866510');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240130 20:55', 1248, 'MatiEgue', '202469821090CRT', 'AB85866510');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240131 19:25', 1230, 'MatiEgue', '202469821090CRT', 'AB85866510');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240124 09:12', 695, 'MatiEgue', '202469821090CRT', 'NR74771350');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240225 07:19', 979, 'SantRovi', '202461978103ZPE', 'NR74771350');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240215 20:55', 1406, 'SantRovi', '202461978103ZPE', 'CF23998196');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240205 03:41', 680, 'SantRovi', '202461978103ZPE', 'CF23998196');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240310 10:38', 1386, 'SantRovi', '202461978103ZPE', 'PL03576691');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240227 04:30', 873, 'SantRovi', '202461978103ZPE', 'PL03576691');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240311 18:45', 1492, 'SantRovi', '202401518926VJD', 'DG33264553');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240208 17:35', 511, 'SantRovi', '202401518926VJD', 'DG33264553');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240215 01:25', 1340, 'SantRovi', '202401518926VJD', 'FB05759988');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240301 04:07', 714, 'NicoMaya', '202401518926VJD', 'FB05759988');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240121 02:41', 974, 'NicoMaya', '202401518926VJD', 'VW47914137');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240221 19:14', 508, 'NicoMaya', '202431853556OXK', 'VW47914137');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240220 10:00', 1050, 'SebaAmes', '202431853556OXK', 'MY30759157');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240121 11:40', 1118, 'SebaAmes', '202431853556OXK', 'MY30759157');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240211 12:47', 703, 'SebaAmes', '202431853556OXK', 'UG09709778');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240211 14:49', 708, 'SebaAmes', '202431853556OXK', 'UG09709778');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240127 13:53', 1148, 'SebaAmes', '202431853556OXK', 'QA02282274');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240125 14:41', 917, 'SebaAmes', '202403982348KZW', 'QA02282274');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240311 17:45', 670, 'SebaAmes', '202403982348KZW', 'ZR21504081');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240206 08:31', 596, 'SebaAmes', '202403982348KZW', 'ZR21504081');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240202 23:48', 1414, 'SebaAmes', '202403982348KZW', 'IJ51055987');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240202 10:48', 565, 'SebaAmes', '202403982348KZW', 'IJ51055987');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240228 18:45', 1041, 'CesarEtc', '202403982348KZW', 'CJ81231879');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240201 14:52', 997, 'CesarEtc', '202493964163QSC', 'CJ81231879');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240228 13:12', 840, 'CesarEtc', '202493964163QSC', 'ND96727324');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240117 11:40', 560, 'CesarEtc', '202493964163QSC', 'ND96727324');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240309 19:42', 778, 'CesarEtc', '202493964163QSC', 'RP58505822');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240125 11:47', 1481, 'CesarEtc', '202493964163QSC', 'RP58505822');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240213 19:29', 1038, 'CesarEtc', '202493964163QSC', 'AK07175184');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240131 02:47', 998, 'CesarEtc', '202431657744TEH', 'AK07175184');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240129 13:13', 550, 'CesarEtc', '202431657744TEH', 'UY23964955');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240221 17:09', 896, 'JosPerez', '202431657744TEH', 'UY23964955');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240117 01:13', 575, 'JosPerez', '202431657744TEH', 'HJ20702534');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240210 05:42', 1410, 'JosPerez', '202431657744TEH', 'HJ20702534');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240229 10:35', 1184, 'JosPerez', '202455458819DNI', 'PV96859986');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240202 00:25', 1113, 'JosPerez', '202455458819DNI', 'PV96859986');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240212 22:16', 633, 'JosPerez', '202455458819DNI', 'PJ62247982');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240310 20:12', 1326, 'JosPerez', '202455458819DNI', 'PJ62247982');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240202 09:45', 1129, 'JosPerez', '202455458819DNI', 'GW89382121');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240224 14:55', 662, 'JosPerez', '202455458819DNI', 'GW89382121');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240124 03:31', 1211, 'JosPerez', '202444674715OOH', 'EO92681037');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240308 17:05', 1013, 'JosPerez', '202444674715OOH', 'EO92681037');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240304 18:02', 966, 'JosPerez', '202444674715OOH', 'JK29009594');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240204 09:09', 733, 'JosPerez', '202444674715OOH', 'JK29009594');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240307 17:56', 886, 'JosPerez', '202444674715OOH', 'TX11737945');
insert into Ventas ( FechaCompra, Monto, Usulog, CodigoVuelo, NumPasaporte) values ( '20240207 23:17', 598, 'JosPerez', '202444674715OOH', 'TX11737945');
GO

----------------------------INSERT PASAJEROS-------------------------------------------------------------------------------------------------------------------------

insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (50, 'OK50235050', 218);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (49, 'ZR21504081', 67);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (3, 'WB07865856', 282);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (17, 'AJ46943504', 8);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (4, 'DG33264553', 6);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (22, 'UY23964955', 175);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (5, 'CW35148778', 35);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (39, 'NO07470557', 100);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (8, 'AK07175184', 64);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (45, 'UG26000208', 139);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (44, 'CW35148778', 202);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (36, 'MY30759157', 147);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (15, 'QV80252945', 259);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (20, 'GK42513995', 158);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (5, 'NI80822334', 210);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (14, 'QO71199521', 44);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (39, 'ND96727324', 199);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (15, 'GY66251082', 45);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (4, 'IP89820113', 222);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (15, 'JK29009594', 183);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (38, 'BT69274693', 285);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (16, 'KG86052975', 250);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (21, 'OP02640072', 61);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (14, 'UG26000208', 205);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (37, 'MY30759157', 30);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (29, 'AK07175184', 109);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (4, 'NR74771350', 1);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (44, 'QF76203268', 228);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (4, 'PR59911981', 97);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (47, 'IB77937638', 126);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (8, 'VI24852201', 209);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (46, 'MZ02248210', 103);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (6, 'AI86150008', 45);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (12, 'NQ30508825', 253);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (13, 'VI24852201', 29);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (11, 'TX11737945', 57);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (10, 'HJ20702534', 105);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (29, 'ON13667717', 264);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (16, 'EE55996788', 149);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (11, 'RK25321787', 17);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (26, 'YE57346457', 122);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (5, 'LP88169491', 283);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (32, 'PY95843698', 42);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (43, 'ZW12698680', 9);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (19, 'TH02086864', 174);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (34, 'ND96727324', 200);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (35, 'NE75929540', 252);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (24, 'AD91806575', 74);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (35, 'CJ81231879', 36);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (15, 'JO19237254', 275);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (23, 'ZP97999324', 18);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (24, 'VL35883189', 34);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (29, 'BB76703983', 176);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (4, 'EO92681037', 260);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (26, 'TX11737945', 132);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (43, 'ZW12698680', 262);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (14, 'ND96727324', 94);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (30, 'CV78331634', 190);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (4, 'YE57346457', 217);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (45, 'CF23998196', 234);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (5, 'VW47914137', 211);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (22, 'QQ64177386', 253);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (17, 'IR64836210', 105);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (31, 'YP18946351', 263);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (10, 'CV78331634', 105);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (10, 'LR33691099', 76);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (4, 'UL62989504', 229);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (38, 'ND96727324', 27);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (15, 'NK75537444', 126);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (39, 'LR33691099', 91);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (46, 'VL69536104', 189);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (32, 'PR59911981', 14);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (41, 'QI31968830', 155);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (5, 'PH51508052', 118);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (4, 'PR59911981', 37);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (6, 'AK07175184', 139);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (43, 'SB39861378', 44);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (10, 'NQ60826584', 157);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (14, 'NN25553434', 173);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (27, 'EG11553099', 252);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (49, 'TX11737945', 79);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (47, 'UG26000208', 250);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (47, 'RP58505822', 196);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (34, 'PV96859986', 130);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (21, 'RJ01680400', 144);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (48, 'UE41504269', 267);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (32, 'ZW12698680', 190);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (32, 'CW35148778', 91);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (26, 'CK85479872', 246);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (16, 'YP18946351', 57);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (27, 'GB09775395', 69);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (24, 'VW47914137', 4);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (40, 'GW86883558', 141);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (43, 'JK29009594', 175);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (37, 'MZ02248210', 216);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (17, 'NO07470557', 139);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (22, 'UY63147470', 245);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (8, 'IR64836210', 112);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (29, 'BN54895211', 174);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (1, 'EC01510034', 67);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (31, 'DR05542313', 155);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (33, 'OP02640072', 150);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (10, 'UG26000208', 90);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (10, 'PQ14262560', 117);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (38, 'YP18946351', 224);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (25, 'IK08256756', 102);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (46, 'ZW12698680', 154);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (16, 'PL03576691', 15);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (22, 'ZC07772022', 128);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (12, 'AK07175184', 169);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (32, 'QX41675215', 172);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (37, 'ZP97999324', 14);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (30, 'UC18967631', 50);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (44, 'HW43630930', 139);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (47, 'NQ60826584', 163);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (15, 'BT69274693', 48);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (49, 'ZV78510193', 37);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (27, 'GW89382121', 222);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (44, 'HB22675590', 178);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (50, 'TU77980556', 269);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (12, 'VC19767690', 241);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (21, 'IJ51055987', 55);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (42, 'RP58505822', 281);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (3, 'NQ60826584', 135);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (43, 'MS70765004', 264);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (15, 'PY95843698', 35);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (7, 'PY95843698', 289);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (21, 'ZN77897030', 114);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (24, 'QX41675215', 153);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (25, 'ZZ18406855', 65);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (25, 'NR74771350', 294);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (15, 'ZN77897030', 34);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (24, 'RK25321787', 31);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (17, 'TX53059770', 9);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (41, 'KE84410920', 147);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (48, 'ON13667717', 156);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (37, 'WM08405319', 156);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (14, 'UY63147470', 158);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (38, 'ZN77897030', 163);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (36, 'CF23998196', 42);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (10, 'PL03576691', 12);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (18, 'BA86594853', 65);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (32, 'HG96592466', 256);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (44, 'EE55996788', 117);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (40, 'DG33264553', 274);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (20, 'ZW12698680', 153);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (16, 'BA86594853', 153);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (40, 'IJ51055987', 36);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (34, 'ST03374520', 269);
insert into Pasajeros (NroVenta, NumPasaporte, NroAsiento) values (38, 'LY10925749', 42);
go