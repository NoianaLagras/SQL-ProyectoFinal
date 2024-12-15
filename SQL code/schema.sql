-- ****************************************************************************
--                                  BASE DE DATOS
-- ****************************************************************************

-- Creación de la base de datos
DROP DATABASE IF EXISTS ProyectoFinal;
CREATE DATABASE ProyectoFinal;
USE ProyectoFinal;

-- ****************************************************************************
--                                  TABLAS
-- ****************************************************************************

-- Tabla de Clientes
CREATE TABLE Clientes (
  id_client INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  client_name VARCHAR(100) NOT NULL,
  dni VARCHAR(20) NOT NULL,
  birthdate DATE,
  client_mail VARCHAR(100) NOT NULL,
  client_address VARCHAR(150) NOT NULL
);

-- Tabla de Métodos de Pago
CREATE TABLE Metodos_de_Pago (
  id_pay INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  method VARCHAR(50) NOT NULL
);

-- Tabla de Categorías
CREATE TABLE Categorias (
  id_categ INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  categ_name VARCHAR(50) NOT NULL
);

-- Tabla de Productos
CREATE TABLE Productos (
  id_prod INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  prod_name VARCHAR(150) NOT NULL,
  list_price DECIMAL(10, 2) NOT NULL,
  wholesale_price DECIMAL(10, 2),
  retail_price DECIMAL(10, 2),
  prod_desc VARCHAR(255),
  id_categ INT,
  stock INT NOT NULL,
  thumbnails VARCHAR(500),
  FOREIGN KEY (id_categ) REFERENCES Categorias(id_categ)
);

-- Tabla de Pedidos
CREATE TABLE Pedidos (
  id_order INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  buy_date DATE NOT NULL,
  id_client INT NOT NULL,
  id_pay INT NOT NULL,
  total_order DECIMAL(10, 2) NOT NULL,
  FOREIGN KEY (id_client) REFERENCES Clientes(id_client),
  FOREIGN KEY (id_pay) REFERENCES Metodos_de_Pago(id_pay)
);

-- Tabla de Detalles del Pedido
CREATE TABLE Detalles_del_pedido (
  id_order INT,
  id_prod INT,
  prod_quantity INT NOT NULL,
  prod_price DECIMAL(10, 2) NOT NULL,
  PRIMARY KEY (id_order, id_prod),
  FOREIGN KEY (id_order) REFERENCES Pedidos(id_order),
  FOREIGN KEY (id_prod) REFERENCES Productos(id_prod)
);

-- Creacion de la tabla para registrar actualizaciones de stock
CREATE TABLE Updated_Stock (
    id_historial INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    id_prod INT NOT NULL,
    date_current TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    nuevo_stock INT NOT NULL,
    FOREIGN KEY (id_prod) REFERENCES Productos(id_prod)
);


-- *****************************************************************************
--             Inserción de datos realizados en Mockaroo de forma manual
-- *****************************************************************************
-- De la Carpeta /seed-data 
-- Importar archivos categorias.csv , clientes.csv, metodos.csv, productos.csv, pedidos.csv, detalles.csv 
-- en sus tablas respectivamente
-- 
-- *****************************************************************************
--             
-- *****************************************************************************