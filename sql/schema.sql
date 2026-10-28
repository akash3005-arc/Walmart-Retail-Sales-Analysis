/*=============================================================================
                  WALMART RETAIL SALES ANALYTICS - DDL SCHEMA
=============================================================================*/
-- Database creation (MySQL / PostgreSQL compatible)
CREATE DATABASE IF NOT EXISTS walmart;
USE walmart;

-- Sales Table Creation
DROP TABLE IF EXISTS sales;
CREATE TABLE sales (
    invoice_id        INT PRIMARY KEY,
    branch            VARCHAR(50) NOT NULL,
    city              VARCHAR(50) NOT NULL,
    category          VARCHAR(50) NOT NULL,
    unit_price        DECIMAL(10, 2) NOT NULL,
    quantity          INT NOT NULL,
    sale_date         DATE NOT NULL,
    sale_time         TIME NOT NULL,
    payment_method    VARCHAR(50) NOT NULL,
    rating            DECIMAL(3, 1) NOT NULL,
    profit_margin     DECIMAL(5, 2) NOT NULL,
    total             DECIMAL(10, 2) GENERATED ALWAYS AS (unit_price * quantity) STORED
);

-- Recommended Performance Indexes for Analytical Queries
CREATE INDEX idx_sales_branch ON sales (branch);
CREATE INDEX idx_sales_city ON sales (city);
CREATE INDEX idx_sales_category ON sales (category);
CREATE INDEX idx_sales_date ON sales (sale_date);
CREATE INDEX idx_sales_payment ON sales (payment_method);
CREATE INDEX idx_sales_rating ON sales (rating);
