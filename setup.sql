-- setup database user

CREATE DATABASE IF NOT EXISTS grocree;
CREATE USER IF NOT EXISTS 'grocree'@'localhost';
GRANT ALL PRIVILEGES ON grocree.* TO 'grocree'@'localhost'
