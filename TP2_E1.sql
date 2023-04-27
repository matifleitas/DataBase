-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2023-04-10 10:34:36.261

-- tables
-- Table: Cliente
CREATE TABLE Cliente (
    id_cliente decimal(4,0)  NOT NULL,
    nombre varchar(100)  NOT NULL,
    apellido varchar(100)  NOT NULL,
    n_telefono varchar(200)  NOT NULL,
    fecha_nacimiento date  NOT NULL,
    direccion varchar(80)  NOT NULL,
    CONSTRAINT Cliente_pk PRIMARY KEY (id_cliente)
);

-- Table: Factura
CREATE TABLE Factura (
    numero int  NOT NULL,
    tipo varchar(80)  NOT NULL,
    fecha date  NOT NULL,
    importe_total int  NOT NULL,
    Cliente_id_cliente decimal(4,0)  NOT NULL,
    CONSTRAINT Factura_pk PRIMARY KEY (numero)
);

-- Table: Producto
CREATE TABLE Producto (
    codigo int  NOT NULL,
    descripcion varchar(100)  NOT NULL,
    precio_costo int  NOT NULL,
    precio_venta int  NOT NULL,
    Factura_numero int  NOT NULL,
    CONSTRAINT Producto_pk PRIMARY KEY (codigo)
);

-- foreign keys
-- Reference: Factura_Cliente (table: Factura)
ALTER TABLE Factura ADD CONSTRAINT Factura_Cliente
    FOREIGN KEY (Cliente_id_cliente)
    REFERENCES Cliente (id_cliente)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: Producto_Factura (table: Producto)
ALTER TABLE Producto ADD CONSTRAINT Producto_Factura
    FOREIGN KEY (Factura_numero)
    REFERENCES Factura (numero)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- End of file.

