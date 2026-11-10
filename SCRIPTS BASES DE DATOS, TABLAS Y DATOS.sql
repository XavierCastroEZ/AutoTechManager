-- SCRIPTS ZUKAS DE SQL PARA PP ZUKA

CREATE TABLE Diagnosticos(
 id INT IDENTITY PRIMARY KEY,
 orden_id INT NOT NULL REFERENCES OrdenesTrabajo(id),
 evaluacion NVARCHAR(1000) NOT NULL,
 evidencias NVARCHAR(500),
 fecha DATETIME2 NOT NULL DEFAULT SYSDATETIME());

CREATE TABLE Presupuestos(
 id INT IDENTITY PRIMARY KEY,
 orden_id INT NOT NULL REFERENCES OrdenesTrabajo(id),
 subtotal_mano_obra DECIMAL(12,2) NOT NULL,
 subtotal_repuestos DECIMAL(12,2) NOT NULL,
 descuento DECIMAL(12,2) NOT NULL DEFAULT 0 ,
 impuesto_pct DECIMAL(5,2) NOT NULL ,
 impuesto DECIMAL(12,2) NOT NULL,
 total DECIMAL(12,2) NOT NULL,
 estado NVARCHAR(15) NOT NULL DEFAULT 'Pendiente' ,
 fecha DATETIME2 NOT NULL DEFAULT SYSDATETIME());

CREATE TABLE ConsumoRepuestos(            
 id INT IDENTITY PRIMARY KEY,
 orden_id INT NOT NULL REFERENCES OrdenesTrabajo(id),
 repuesto_id INT NOT NULL REFERENCES Repuestos(id),
 cantidad INT NOT NULL ,
 precio_unit DECIMAL(12,2) NOT NULL ,
 consumido BIT NOT NULL DEFAULT 0,
 UNIQUE(orden_id,repuesto_id));

CREATE TABLE MovimientosInventario(
 id INT IDENTITY PRIMARY KEY,
 repuesto_id INT NOT NULL REFERENCES Repuestos(id),
 tipo CHAR(1) NOT NULL ,
 cantidad INT NOT NULL ,
 fecha DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
 orden_id INT NULL REFERENCES OrdenesTrabajo(id),
 referencia NVARCHAR(100));

CREATE TABLE ActividadesTrabajo(
 id INT IDENTITY PRIMARY KEY,
 orden_id INT NOT NULL REFERENCES OrdenesTrabajo(id),
 mecanico_id INT NOT NULL REFERENCES Mecanicos(id),
 descripcion NVARCHAR(250) NOT NULL,
 estado NVARCHAR(15) NOT NULL DEFAULT 'Pendiente' ,
 fecha DATETIME2 NOT NULL DEFAULT SYSDATETIME());

CREATE TABLE ControlesCalidad(
 id INT IDENTITY PRIMARY KEY,
 orden_id INT NOT NULL REFERENCES OrdenesTrabajo(id),
 descripcion NVARCHAR(250) NOT NULL,
 obligatorio BIT NOT NULL DEFAULT 1,
 aprobado BIT NULL);

CREATE TABLE Pagos(
 id INT IDENTITY PRIMARY KEY,
 orden_id INT NOT NULL REFERENCES OrdenesTrabajo(id),
 monto DECIMAL(12,2) NOT NULL ,
 fecha DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
 metodo NVARCHAR(30) NOT NULL);

CREATE TABLE Motores(
 id INT IDENTITY PRIMARY KEY,
 serie NVARCHAR(40) NOT NULL UNIQUE,
 marca_compat NVARCHAR(40) NOT NULL,
 modelo_compat NVARCHAR(40) NOT NULL,
 anio_desde INT NOT NULL, anio_hasta INT NOT NULL,
 cilindrada NVARCHAR(20),
 repuesto_id INT NOT NULL REFERENCES Repuestos(id),
 estado NVARCHAR(15) NOT NULL DEFAULT 'Disponible' ,
 vehiculo_id INT NULL REFERENCES Vehiculos(id)
);

CREATE TABLE CambiosMotor(
 id INT IDENTITY PRIMARY KEY,
 orden_id INT NOT NULL UNIQUE REFERENCES OrdenesTrabajo(id),
 serie_anterior NVARCHAR(40) NOT NULL,
 motor_nuevo_id INT NOT NULL REFERENCES Motores(id),
 destino_retirado NVARCHAR(100) NOT NULL,
 resultado_pruebas NVARCHAR(500) NOT NULL,
 evidencias NVARCHAR(500),
 garantia_meses INT NOT NULL ,
 garantia_hasta DATE NULL,               
 fecha DATETIME2 NOT NULL DEFAULT SYSDATETIME());

--TABLA DE AUDITORIA

CREATE TABLE Auditoria(
 id INT IDENTITY PRIMARY KEY,
 tabla NVARCHAR(40), operacion NVARCHAR(10), detalle NVARCHAR(300),
 usuario NVARCHAR(100) DEFAULT SUSER_SNAME(),
 fecha DATETIME2 DEFAULT SYSDATETIME());
GO

GO

-- DATOS PRECARGADOS PARA PRUEBAS

INSERT INTO Proveedores(nombre,telefono) VALUES(N'AutoPartes Centroamericana','2222-1111'),(N'Motores del Norte','2233-4455');
INSERT INTO Clientes(nombre,dni,telefono,correo) VALUES(N'Carlos Mejía','0801-1990-00123','9999-0001','carlos@mail.com'),(N'Ana López','0801-1985-00456','9999-0002','ana@mail.com');
INSERT INTO Vehiculos(cliente_id,placa,vin,marca,modelo,anio,color,kilometraje,combustible) VALUES
 (1,'HAB-1234','MR0FZ29G700000001','Toyota','Hilux',2015,'Blanco',185000,'Diesel'),
 (1,'HBC-5678','JHMFA16586S000002','Honda','Civic',2018,'Gris',92000,'Gasolina'),
 (2,'HCD-9012','3N1AB7AP5HY000003','Nissan','Sentra',2017,'Rojo',70000,'Gasolina');
INSERT INTO Mecanicos(nombre,especialidad) VALUES(N'Luis Fernández',N'Motores'),(N'Marta Reyes',N'Eléctrico'),(N'José Castillo',N'Frenos y suspensión');
INSERT INTO Servicios(codigo,nombre,descripcion,nivel,costo_mano_obra,horas_estimadas) VALUES
 ('SRV-101',N'Cambio de aceite y filtro',N'Mantenimiento básico',1,350,0.5),
 ('SRV-201',N'Cambio de frenos',N'Mantenimiento preventivo',2,900,2),
 ('SRV-301',N'Cambio de radiador',N'Reparación intermedia',3,2500,5),
 ('SRV-401',N'Reparación de transmisión',N'Reparación avanzada',4,8000,16),
 ('SRV-501',N'Sustitución de motor',N'Reparación mayor',5,25000,40);
INSERT INTO Repuestos(codigo,nombre,categoria,stock,stock_minimo,costo,precio,proveedor_id) VALUES
 ('REP-ACE',N'Aceite 10W-30 (litro)',N'Aceite',50,10,90,150,1),
 ('REP-FIL',N'Filtro de aceite',N'Filtro',30,8,60,110,1),
 ('REP-FRE',N'Pastillas de freno',N'Frenos',12,4,400,650,1),
 ('REP-RAD',N'Radiador universal',N'Radiador',3,2,1800,2600,1),
 ('MOT-1KD',N'Motor Toyota 1KD-FTV 3.0L',N'Motor',1,1,45000,62000,2),
 ('MOT-R18',N'Motor Honda R18 1.8L',N'Motor',1,1,30000,42000,2);
INSERT INTO ServicioRepuesto SELECT s.id,r.id,4 FROM Servicios s,Repuestos r WHERE s.codigo='SRV-101' AND r.codigo='REP-ACE';
INSERT INTO ServicioRepuesto SELECT s.id,r.id,1 FROM Servicios s,Repuestos r WHERE s.codigo='SRV-101' AND r.codigo='REP-FIL';
INSERT INTO ServicioRepuesto SELECT s.id,r.id,1 FROM Servicios s,Repuestos r WHERE s.codigo='SRV-201' AND r.codigo='REP-FRE';
INSERT INTO ServicioRepuesto SELECT s.id,r.id,1 FROM Servicios s,Repuestos r WHERE s.codigo='SRV-301' AND r.codigo='REP-RAD';
INSERT INTO Motores(serie,marca_compat,modelo_compat,anio_desde,anio_hasta,cilindrada,repuesto_id)
 SELECT 'SN-1KD-77001','Toyota','Hilux',2012,2016,'3.0L',id FROM Repuestos WHERE codigo='MOT-1KD';
INSERT INTO Motores(serie,marca_compat,modelo_compat,anio_desde,anio_hasta,cilindrada,repuesto_id)
 SELECT 'SN-R18-55002','Honda','Civic',2012,2018,'1.8L',id FROM Repuestos WHERE codigo='MOT-R18';

GO
