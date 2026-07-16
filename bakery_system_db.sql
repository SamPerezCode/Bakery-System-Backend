CREATE DATABASE bakery_system;
USE bakery_system;

/*
| Módulo                  | Tablas posibles                            |
| ----------------------- | ------------------------------------------ |
| Autenticación           | `roles`, `users`                           |
| Productos               | `categories`, `products`                   |
| Clientes                | `customers`                                |
| Ventas                  | `sales`, `sale_details`                    |
| Pedidos                 | `orders`, `order_details`                  |
| Inventario              | `inventory_movements`                      |
| Producción              | `production_batches`, `production_details` |
| Insumos / materia prima | `supplies`, `product_recipes`              |


Orden recomendado

Empezamos por autenticación porque casi todo el sistema dependerá de usuarios:
1. roles
2. users
3. categories
4. products
5. customers
6. sales
7. sale_details
8. orders
9. order_details
10. Inventario y producción
*/

-- Tabla 1. roles
-- Relación : Un rol puede tener muchos usuarios. roles 1 ─── N users

CREATE TABLE roles(
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP
);

-- Tabla 2. users 
-- Relación : 1:N (uno a muchos).
-- Sintaxis foreing 
-- FOREIGN KEY (columna_local) REFERENCES tabla(columna)
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role_id INT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	FOREIGN KEY (role_id)
	REFERENCES roles(id)
	ON DELETE RESTRICT
	ON UPDATE CASCADE
);

-- Tabla 3. categories 
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255),
    image_url VARCHAR(255),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP
);

INSERT INTO categories (name, description, image_url)
VALUES
('Panes', 'Productos de panadería tradicional', '/uploads/categories/panes.jpg'),
('Hojaldres', 'Productos elaborados con masa de hojaldre', '/uploads/categories/hojaldres.jpg'),
('Pasteles', 'Tortas y pasteles para venta', '/uploads/categories/pasteles.jpg'),
('Cafés', 'Bebidas calientes a base de café', '/uploads/categories/cafes.jpg'),
('Bebidas', 'Bebidas frías y productos embotellados', '/uploads/categories/bebidas.jpg'),
('Postres', 'Postres dulces individuales o familiares', '/uploads/categories/postres.jpg');

-- Tabla 4: products --> Relation Cada producto pertenece a una categoría: categories 1 ─── N products
-- sku significa Stock Keeping Unit. Es un código interno del negocio.
-- ON DELETE RESTRICT--> "No puedes borrar este registro porque hay otros registros que dependen de él."
/*
| Columna       | Para qué sirve            |
| ------------- | ------------------------- |
| `id`          | Identificador único       |
| `category_id` | Relación con `categories` |
| `name`        | Nombre del producto       |
| `description` | Descripción opcional      |
| `sku`         | Código interno único      |
| `barcode`     | Código de barras opcional |
| `sale_price`  | Precio de venta           |
| `cost_price`  | Costo estimado            |
| `image_url`   | Imagen del producto       |
| `is_active`   | Si se vende o no          |
| `created_at`  | Fecha de creación         |
| `updated_at`  | Fecha de actualización    |
*/
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255),
    sku VARCHAR(50) NOT NULL UNIQUE,
    barcode VARCHAR(50) UNIQUE,
    sale_price DECIMAL(10,2) NOT NULL,
    cost_price DECIMAL(10,2),
    image_url VARCHAR(255),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (category_id)
        REFERENCES categories(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

SELECT id, name FROM categories;

INSERT INTO products (
    category_id, name, description, sku, barcode, sale_price, cost_price, image_url
)
VALUES
(1, 'Pan Francés', 'Pan tradicional recién horneado', 'PAN-0001', NULL, 800.00, 350.00, '/uploads/products/pan-frances.jpg'),
(5, 'Coca-Cola 400ml', 'Gaseosa Coca-Cola 400ml', 'BEB-0001', '7702535010101', 3500.00, 2500.00, '/uploads/products/coca-cola-400.jpg'),
(4, 'Café Americano', 'Café americano preparado al momento', 'CAF-0001', NULL, 4500.00, 1200.00, '/uploads/products/cafe-americano.jpg');

SELECT * FROM products;

--  5. tabla customers -> Relación 1 = customer --- N = Sales  y despues 1 = sales --- N = Sales_details  --> Products
/*
| Columna           | Tipo recomendado | Regla                           |
| ----------------- | ---------------: | ------------------------------- |
| `id`              |            `INT` | PK, auto incremental            |
| `name`            |   `VARCHAR(120)` | obligatorio                     |
| `document_number` |    `VARCHAR(50)` | opcional, único                 |
| `phone`           |    `VARCHAR(30)` | opcional                        |
| `email`           |   `VARCHAR(120)` | opcional, único                 |
| `address`         |   `VARCHAR(255)` | opcional                        |
| `is_active`       |        `BOOLEAN` | obligatorio, por defecto `TRUE` |
| `created_at`      |      `TIMESTAMP` | fecha automática                |
| `updated_at`      |      `TIMESTAMP` | se actualiza automáticamente    |
*/
CREATE TABLE customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    document_number VARCHAR(50) UNIQUE,
    phone VARCHAR(30),
    email VARCHAR(120) UNIQUE,
    address VARCHAR(255),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP
);

INSERT INTO customers (
    name, document_number, phone, email, address
)
VALUES
(    'Juan Pérez', '1065123456', '3001234567', 'juan@gmail.com','Cra 10 #12-34'),
(    'María Gómez',  NULL, '3019876543', NULL, 'Calle 20 #15-40'),
(    'Empresa ABC SAS', '900123456','6051234567','compras@abc.com','Zona Industrial');

/*
📌 Así va nuestro modelo de datos
roles
   │
   └────────────── users

categories
   │
   └────────────── products

En la próxima tabla (sales) empezaremos a conectar todo:

customers
      │
      └────────── sales
                      │
                      └────────── sale_details
                                      │
                                      └────────── products
                                      Tabla 1
sales

Guarda la información general.

Ejemplo:

id	customer	fecha	total
1	Juan	hoy	18500

Solo existe una venta.

Tabla 2
sale_details

Guarda cada producto vendido.

Ejemplo:

sale_id	product	cantidad	precio
1	Pan francés	2	800
1	Coca-Cola	1	3500
1	Croissant	3	4500

Observa que una venta tiene muchos productos.

sales

Factura 1
      │
      │
      ▼
sale_details

Pan
Coca-Cola
Croissant
Primera decisión importante
¿Qué debería guardar la tabla sales?

Yo propondría:

| Campo          | Explicación                 |
| -------------- | --------------------------- |
| id             | PK                          |
| customer_id    | Cliente                     |
| user_id        | Cajero que hizo la venta    |
| sale_date      | Fecha de la venta           |
| total          | Total de la venta           |
| payment_method | Efectivo, tarjeta, Nequi... |
| status         | Completada, anulada...      |
| created_at     | Auditoría                   |
| updated_at     | Auditoría                   |

¿Por qué guardar user_id?

Imagina que tienes tres cajeros.

Quieres saber quién realizó esta venta.

Factura 1050

Cliente:
Juan Pérez

Cajero:
Sam

Entonces la relación será:

users

1
│
└────────────── sales
Diseño de sales
| Campo            | Regla       |
| ---------------- | ----------- |
| `id`             | PK          |
| `customer_id`    | Opcional    |
| `user_id`        | Obligatorio |
| `sale_date`      | Automático  |
| `total`          | Obligatorio |
| `payment_method` | Obligatorio |
| `status`         | Obligatorio |
| `created_at`     | Automático  |
| `updated_at`     | Automático  |

*/
-- 5. tabla sales
-- para customer_id ON DELETE SET NULL -> Porque si eliminan/desactivan un cliente, no queremos borrar la venta.
-- para user_id usamos usamos ON DELETE RESTRICT   Porque no queremos eliminar un usuario si tiene ventas históricas asociadas.
CREATE TABLE sales (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NULL,
    user_id INT NOT NULL,
    sale_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(10,2) NOT NULL,
    payment_method ENUM('cash', 'card', 'transfer', 'nequi', 'daviplata') NOT NULL,
    status ENUM('completed', 'cancelled') NOT NULL DEFAULT 'completed',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (customer_id)
        REFERENCES customers(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- 7. Tabla sale_details
-- Guarda cada producto incluido en una venta.
-- Tabla 7: sale_details
-- Relación:
-- sales 1 ---- N sale_details
-- products 1 - N sale_details
--
-- ON DELETE CASCADE:
-- Si se elimina una venta, se eliminan automáticamente sus detalles.
--
-- ON DELETE RESTRICT:
-- No se permite eliminar un producto utilizado en una venta histórica.

CREATE TABLE sale_details (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sale_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (sale_id)
        REFERENCES sales(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    FOREIGN KEY (product_id)
        REFERENCES products(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CHECK (quantity > 0),
    CHECK (unit_price >= 0),
    CHECK (subtotal >= 0)
);

-- 8. Tabla orders
-- Representa pedidos anticipados, encargos, domicilios o productos para recoger posteriormente.
-- Tabla 8: orders
-- Un cliente puede tener muchos pedidos.
-- Un usuario registra muchos pedidos.
-- Un pedido puede convertirse posteriormente en una venta.

CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NULL,
    user_id INT NOT NULL,
    sale_id INT NULL UNIQUE,

    contact_name VARCHAR(120) NOT NULL,
    contact_phone VARCHAR(30),
    delivery_type ENUM('pickup', 'delivery')
        NOT NULL DEFAULT 'pickup',
    delivery_address VARCHAR(255),

    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    required_date DATETIME NULL,

    subtotal DECIMAL(10,2) NOT NULL DEFAULT 0,
    discount DECIMAL(10,2) NOT NULL DEFAULT 0,
    total DECIMAL(10,2) NOT NULL DEFAULT 0,

    payment_status ENUM(
        'pending',
        'partial',
        'paid',
        'refunded'
    ) NOT NULL DEFAULT 'pending',

    status ENUM(
        'pending',
        'confirmed',
        'in_production',
        'ready',
        'delivered',
        'cancelled'
    ) NOT NULL DEFAULT 'pending',

    notes VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (customer_id)
        REFERENCES customers(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    FOREIGN KEY (sale_id)
        REFERENCES sales(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    CHECK (subtotal >= 0),
    CHECK (discount >= 0),
    CHECK (total >= 0)
);

-- 9. Tabla order_details
-- Guarda los productos incluidos en cada pedido.
-- Tabla 9: order_details
-- orders 1 ---- N order_details
-- products 1 -- N order_details
CREATE TABLE order_details (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    notes VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (order_id)
        REFERENCES orders(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    FOREIGN KEY (product_id)
        REFERENCES products(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CHECK (quantity > 0),
    CHECK (unit_price >= 0),
    CHECK (subtotal >= 0)
);

-- Tabla 10: suppliers
-- Un proveedor puede suministrar muchos insumos.
-- Guarda los proveedores de harina, azúcar, empaques, bebidas y demás insumos.
CREATE TABLE suppliers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(120) NOT NULL UNIQUE,
    document_number VARCHAR(50) UNIQUE,
    contact_name VARCHAR(120),
    phone VARCHAR(30),
    email VARCHAR(120),
    address VARCHAR(255),
    notes VARCHAR(500),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP
);

-- Tabla 11: supplies
-- Guarda materias primas e insumos.
-- Representa las materias primas e insumos utilizados por la panadería.
-- Ejemplos:
-- Harina
-- Azúcar
-- Levadura
-- Huevos
-- Leche
-- Chocolate
-- Cajas para torta
-- Se utilizarán unidades base:
-- g    = gramos
-- ml   = mililitros
-- unit = unidades

CREATE TABLE supplies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(120) NOT NULL UNIQUE,
    sku VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255),

    unit_of_measure ENUM('g', 'ml', 'unit') NOT NULL,

    current_stock DECIMAL(12,3) NOT NULL DEFAULT 0,
    minimum_stock DECIMAL(12,3) NOT NULL DEFAULT 0,
    last_cost DECIMAL(12,2) NULL,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CHECK (current_stock >= 0),
    CHECK (minimum_stock >= 0),
    CHECK (last_cost IS NULL OR last_cost >= 0)
);

-- Tabla 12: supplier_supplies
-- Relación muchos a muchos:
-- suppliers N ---- M supplies
-- Un insumo puede ser vendido por varios proveedores y un proveedor 
-- puede vender varios insumos. Es una relación N:M.
CREATE TABLE supplier_supplies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_id INT NOT NULL,
    supply_id INT NOT NULL,
    supplier_product_code VARCHAR(50),
    last_purchase_cost DECIMAL(12,2),
    is_preferred BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (supplier_id)
        REFERENCES suppliers(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    FOREIGN KEY (supply_id)
        REFERENCES supplies(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    UNIQUE (supplier_id, supply_id),

    CHECK (
        last_purchase_cost IS NULL
        OR last_purchase_cost >= 0
    )
);


-- Tabla 13: product_recipes
-- Un producto producido tendrá una receta.
-- product_id es UNIQUE porque inicialmente manejaremos
-- una sola receta activa por producto.

CREATE TABLE product_recipes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL UNIQUE,
    name VARCHAR(120) NOT NULL,
    yield_quantity DECIMAL(12,3) NOT NULL,
    instructions TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (product_id)
        REFERENCES products(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CHECK (yield_quantity > 0)
);

-- Tabla 14: recipe_details
-- product_recipes 1 ---- N recipe_details
-- supplies 1 ----------- N recipe_details
--  Guarda los insumos y cantidades necesarias para cada receta.
CREATE TABLE recipe_details (
    id INT AUTO_INCREMENT PRIMARY KEY,
    recipe_id INT NOT NULL,
    supply_id INT NOT NULL,
    quantity DECIMAL(12,3) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (recipe_id)
        REFERENCES product_recipes(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    FOREIGN KEY (supply_id)
        REFERENCES supplies(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    UNIQUE (recipe_id, supply_id),

    CHECK (quantity > 0)
);

-- Tabla 15: production_batches
-- Una receta puede utilizarse en muchos lotes.
-- Un usuario puede registrar muchos lotes de producción.

CREATE TABLE production_batches (
    id INT AUTO_INCREMENT PRIMARY KEY,
    recipe_id INT NOT NULL,
    user_id INT NOT NULL,

    batch_code VARCHAR(50) NOT NULL UNIQUE,
    planned_quantity DECIMAL(12,3) NOT NULL,
    produced_quantity DECIMAL(12,3) NOT NULL DEFAULT 0,

    status ENUM(
        'planned',
        'in_progress',
        'completed',
        'cancelled'
    ) NOT NULL DEFAULT 'planned',

    planned_start_at DATETIME NULL,
    started_at DATETIME NULL,
    completed_at DATETIME NULL,

    notes VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (recipe_id)
        REFERENCES product_recipes(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CHECK (planned_quantity > 0),
    CHECK (produced_quantity >= 0)
);

-- Tabla 16: production_details
-- Registra cuánto insumo se planeaba usar y cuánto se utilizó realmente en un lote. 
-- production_batches 1 ---- N production_details
-- supplies 1 -------------- N production_details

CREATE TABLE production_details (
    id INT AUTO_INCREMENT PRIMARY KEY,
    production_batch_id INT NOT NULL,
    supply_id INT NOT NULL,

    planned_quantity DECIMAL(12,3) NOT NULL,
    actual_quantity DECIMAL(12,3) NOT NULL DEFAULT 0,
    waste_quantity DECIMAL(12,3) NOT NULL DEFAULT 0,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (production_batch_id)
        REFERENCES production_batches(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    FOREIGN KEY (supply_id)
        REFERENCES supplies(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    UNIQUE (production_batch_id, supply_id),

    CHECK (planned_quantity >= 0),
    CHECK (actual_quantity >= 0),
    CHECK (waste_quantity >= 0)
);
-- Tabla 17: supply_inventory_movements
-- Historial de movimientos de materias primas.
-- Registra entradas y salidas de materias primas.
-- La cantidad siempre será positiva.
-- El tipo de movimiento determina si suma o resta inventario.

CREATE TABLE supply_inventory_movements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    supply_id INT NOT NULL,
    user_id INT NOT NULL,
    production_batch_id INT NULL,

    movement_type ENUM(
        'purchase_in',
        'production_out',
        'adjustment_in',
        'adjustment_out',
        'waste_out',
        'return_in'
    ) NOT NULL,

    quantity DECIMAL(12,3) NOT NULL,
    unit_cost DECIMAL(12,2) NULL,

    reference_type VARCHAR(50),
    reference_id INT NULL,
    notes VARCHAR(500),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (supply_id)
        REFERENCES supplies(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    FOREIGN KEY (production_batch_id)
        REFERENCES production_batches(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    CHECK (quantity > 0),
    CHECK (unit_cost IS NULL OR unit_cost >= 0)
);

-- Tabla 18: product_inventory_movements
-- Historial de entradas y salidas de productos terminados.

CREATE TABLE product_inventory_movements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    user_id INT NOT NULL,
    sale_id INT NULL,
    production_batch_id INT NULL,

    movement_type ENUM(
        'production_in',
        'purchase_in',
        'sale_out',
        'adjustment_in',
        'adjustment_out',
        'waste_out',
        'return_in'
    ) NOT NULL,

    quantity DECIMAL(12,3) NOT NULL,
    notes VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (product_id)
        REFERENCES products(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    FOREIGN KEY (sale_id)
        REFERENCES sales(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    FOREIGN KEY (production_batch_id)
        REFERENCES production_batches(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    CHECK (quantity > 0)
);

/*
1.  roles
2.  users
3.  categories
4.  products
5.  customers
6.  sales
7.  sale_details
8.  orders
9.  order_details
10. suppliers
11. supplies
12. supplier_supplies
13. product_recipes
14. recipe_details
15. production_batches
16. production_details
17. supply_inventory_movements
18. product_inventory_movements

roles
  └── users
       ├── sales
       ├── orders
       ├── production_batches
       └── inventory_movements

categories
  └── products
       ├── sale_details
       ├── order_details
       ├── product_recipes
       └── product_inventory_movements

customers
  ├── sales
  └── orders

sales
  └── sale_details

orders
  └── order_details

suppliers
  └── supplier_supplies
            └── supplies

product_recipes
  └── recipe_details
            └── supplies

production_batches
  └── production_details


Regla importante para el backend

Cuando hagamos Node.js, operaciones como registrar una venta deberán ejecutarse
 dentro de una transacción MySQL:
1. Crear la venta
2. Crear los detalles
3. Registrar salidas de inventario
4. Confirmar todos los cambios con COMMIT
*/