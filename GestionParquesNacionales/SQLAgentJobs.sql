
SELECT name, SUSER_SNAME(owner_sid)
FROM sys.databases
WHERE name = 'GestionParquesNacionales'


SELECT name, type_desc
FROM sys.database_principals
WHERE name = 'WW930\a646241'


USE [GestionParquesNacionales]
GO

EXEC sp_changedbowner 'sa'
-- o mejor en versiones nuevas:
ALTER AUTHORIZATION ON DATABASE::[GestionParquesNacionales] TO sa;
