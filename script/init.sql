CREATE DATABASE cowrie;
CREATE USER 'cowrie'@'localhost' IDENTIFIED BY 'cowrie';
GRANT ALL ON cowrie.* TO 'cowrie'@'localhost';
