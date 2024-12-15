
-- *****************************************************************************
--                                 Consultas 
-- *****************************************************************************

SELECT client_name, client_address
FROM Clientes
WHERE client_address = '12890 Richardson Road, Rochester, New York, United States, 14609';

SELECT prod_name, list_price
FROM Productos
ORDER BY list_price ASC;

-- Simplificar pedidos usando alias p para Pedidos y c para Clientes
SELECT p.id_order, c.client_name, p.buy_date
FROM Pedidos AS p
JOIN Clientes AS c ON p.id_client = c.id_client;

-- Consulta de precios en caso de que no tenga precio mayorista 
SELECT prod_name, wholesale_price AS price
FROM Productos
WHERE wholesale_price IS NOT NULL
UNION
SELECT prod_name, retail_price AS price
FROM Productos
WHERE retail_price IS NOT NULL;

-- Consulta por productos con el mayor precio
SELECT prod_name, list_price
FROM Productos
WHERE list_price = (SELECT MAX(list_price) FROM Productos);

-- Consulta para identificar el mes con más compras
SELECT MONTHNAME(buy_date) AS mes, COUNT(*) AS total_pedidos
FROM Pedidos
GROUP BY mes
ORDER BY total_pedidos DESC;

-- Promedio de ventas por cliente para segmentarlos 
SELECT c.client_name, AVG(p.total_order) AS promedio_ventas
FROM Pedidos p
JOIN Clientes c ON p.id_client = c.id_client
GROUP BY c.id_client
HAVING AVG(p.total_order) > 0  -- Excluye clientes sin compras
ORDER BY promedio_ventas DESC;


-- Consulta para identificar la categoría más vendida
SELECT cat.categ_name, SUM(d.prod_quantity) AS total_cantidad
FROM Detalles_del_pedido d
JOIN Productos p ON d.id_prod = p.id_prod
JOIN Categorias cat ON p.id_categ = cat.id_categ
GROUP BY cat.categ_name
ORDER BY total_cantidad DESC;


-- Consulta para encontrar los 5 productos más vendidos
SELECT p.prod_name, SUM(d.prod_quantity) AS total_cantidad
FROM Detalles_del_pedido d
JOIN Productos p ON d.id_prod = p.id_prod
GROUP BY p.prod_name
ORDER BY total_cantidad DESC
LIMIT 5;

-- Consulta sobre que se usa mas en metodos de pago 
SELECT m.method, COUNT(p.id_order) AS total_usos
FROM Pedidos p
JOIN Metodos_de_Pago m ON p.id_pay = m.id_pay
GROUP BY m.method
ORDER BY total_usos DESC
LIMIT 4;



-- *****************************************************************************
--                              Fin de Consultas 
-- *****************************************************************************

-- *****************************************************************************
--                                 VISTAS
-- *****************************************************************************

-- Vista para ver los pedidos junto con el cliente y el total de la orden
DROP VIEW IF EXISTS Vista_Pedido;
CREATE VIEW Vista_Pedido AS
SELECT p.id_order, c.client_name, p.buy_date, p.total_order
FROM Pedidos p
JOIN Clientes c ON p.id_client = c.id_client;

-- Vista para ver el stock por categoría
DROP VIEW IF EXISTS Vista_Stock;
CREATE VIEW Vista_Stock AS
SELECT p.prod_name, c.categ_name, p.stock
FROM Productos p
JOIN Categorias c ON p.id_categ = c.id_categ;

-- Vista para ver los detalles del pedido por cliente
DROP VIEW IF EXISTS Vista_PedidosCliente;
CREATE VIEW Vista_PedidosCliente AS
SELECT c.client_name, p.id_order, p.buy_date, p.total_order
FROM Pedidos p
JOIN Clientes c ON p.id_client = c.id_client;

-- Vista para ver los detalles del producto pedido
DROP VIEW IF EXISTS Vista_DetallesPedidos;
CREATE VIEW Vista_DetallesPedidos AS
SELECT p.id_order, c.client_name, prod.prod_name, d.prod_quantity, d.prod_price
FROM Detalles_del_pedido d
JOIN Pedidos p ON d.id_order = p.id_order
JOIN Clientes c ON p.id_client = c.id_client
JOIN Productos prod ON d.id_prod = prod.id_prod;

-- Vista para ver el total de ventas y cantidades por categoría
DROP VIEW IF EXISTS Vista_VentasCategoria;
CREATE VIEW Vista_VentasCategoria AS
SELECT cat.categ_name, SUM(d.prod_quantity) AS total_quantity, 
       SUM(d.prod_quantity * d.prod_price) AS total_sales
FROM Detalles_del_pedido d
JOIN Productos prod ON d.id_prod = prod.id_prod
JOIN Categorias cat ON prod.id_categ = cat.id_categ
GROUP BY cat.categ_name;

-- *****************************************************************************
--                                FUNCIONES 
-- *****************************************************************************

-- Función para ver total gastado por el cliente según su ID
DROP FUNCTION IF EXISTS TotalGastadoPorCliente;
DELIMITER //

CREATE FUNCTION TotalGastadoPorCliente(client_id INT)
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
  DECLARE total DECIMAL(10, 2);

  SELECT SUM(total_order) INTO total
  FROM Pedidos
  WHERE id_client = client_id;

  RETURN total;
END //

DELIMITER ;

-- cliente con id 1 
SELECT TotalGastadoPorCliente(3);

-- Función para ver los pedidos que tiene el cliente según su ID
DROP FUNCTION IF EXISTS CantidadPedidosPorCliente;
DELIMITER //
CREATE FUNCTION CantidadPedidosPorCliente(client_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE total INT;

  SELECT COUNT(*) INTO total
  FROM Pedidos
  WHERE id_client = client_id;

  RETURN total;
END //
DELIMITER ;

-- cliente con id 1
SELECT CantidadPedidosPorCliente(2);

-- *****************************************************************************
--                                 STORED PROCEDURES
-- *****************************************************************************
DROP PROCEDURE IF EXISTS AgregarNuevoCliente;

DELIMITER //
CREATE PROCEDURE AgregarNuevoCliente(
  IN nombre VARCHAR(100),
  IN dni VARCHAR(20),
  IN nacimiento DATE,
  IN email VARCHAR(100),
  IN direccion VARCHAR(150)
)
BEGIN
  INSERT INTO Clientes (client_name, dni, birthdate, client_mail, client_address)
  VALUES (nombre, dni, nacimiento, email, direccion);
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS ActualizarStockProducto;
DELIMITER //
CREATE PROCEDURE ActualizarStockProducto(
  IN producto_id INT,
  IN nuevo_stock INT
)
BEGIN
  UPDATE Productos
  SET stock = nuevo_stock
  WHERE id_prod = producto_id;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS EliminarCliente;
DELIMITER //

CREATE PROCEDURE EliminarCliente(
  IN client_id INT
)
BEGIN
  DELETE FROM Clientes
  WHERE id_client = client_id;
END //
DELIMITER ;
-- *****************************************************************************
--                                TRIGGERS 
-- *****************************************************************************

DELIMITER //
CREATE TRIGGER ActualizarStockEnPedido
AFTER INSERT ON Detalles_del_pedido
FOR EACH ROW
BEGIN
  UPDATE Productos
  SET stock = stock - NEW.prod_quantity
  WHERE id_prod = NEW.id_prod;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER RegistrarFechaActualizacionStock
AFTER UPDATE ON Productos
FOR EACH ROW
BEGIN
    IF NEW.stock != OLD.stock THEN
        INSERT INTO Updated_Stock (id_prod, nuevo_stock)
        VALUES (NEW.id_prod, NEW.stock);
    END IF;
END //
DELIMITER ;
