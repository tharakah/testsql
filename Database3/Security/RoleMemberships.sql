EXECUTE sp_addrolemember @rolename = N'db_owner', @membername = N'datawriter';


GO
EXECUTE sp_addrolemember @rolename = N'db_datawriter', @membername = N'datawriter';


GO
EXECUTE sp_addrolemember @rolename = N'db_datawriter', @membername = N'planstage_editor';


GO
EXECUTE sp_addrolemember @rolename = N'db_datareader', @membername = N'datawriter';


GO
EXECUTE sp_addrolemember @rolename = N'db_datareader', @membername = N'planstage_editor';


GO
EXECUTE sp_addrolemember @rolename = N'db_datareader', @membername = N'datareader';

