﻿/*
Deployment script for MtelligentDB

This code was generated by a tool.
Changes to this file may cause incorrect behavior and will be lost if
the code is regenerated.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar DatabaseName "MtelligentDB"
:setvar DefaultFilePrefix "MtelligentDB"
:setvar DefaultDataPath "C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\"
:setvar DefaultLogPath "C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\"

GO
:on error exit
GO
/*
Detect SQLCMD mode and disable script execution if SQLCMD mode is not supported.
To re-enable the script after enabling SQLCMD mode, execute the following:
SET NOEXEC OFF; 
*/
:setvar __IsSqlCmdEnabled "True"
GO
IF N'$(__IsSqlCmdEnabled)' NOT LIKE N'True'
    BEGIN
        PRINT N'SQLCMD mode must be enabled to successfully execute this script.';
        SET NOEXEC ON;
    END


GO
USE [$(DatabaseName)];


GO
PRINT N'Dropping [dbo].[Visitors].[idx_Visitors_UID]...';


GO
DROP INDEX [idx_Visitors_UID]
    ON [dbo].[Visitors];


GO
PRINT N'Dropping DF__Goals__Active__108B795B...';


GO
ALTER TABLE [dbo].[Goals] DROP CONSTRAINT [DF__Goals__Active__108B795B];


GO
PRINT N'Dropping FK_VisitorCohorts_ToGoals...';


GO
ALTER TABLE [dbo].[VisitorConversions] DROP CONSTRAINT [FK_VisitorCohorts_ToGoals];


GO
PRINT N'Starting rebuilding table [dbo].[Goals]...';


GO
BEGIN TRANSACTION;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SET XACT_ABORT ON;

CREATE TABLE [dbo].[tmp_ms_xx_Goals] (
    [Id]         INT            IDENTITY (1, 1) NOT NULL,
    [Name]       NVARCHAR (100) NOT NULL,
    [SystemName] NVARCHAR (100) NOT NULL,
    [Active]     INT            DEFAULT 1 NOT NULL,
    [Value]      FLOAT (53)     DEFAULT 0 NOT NULL,
    [GACode]     NVARCHAR (20)  NULL,
    [CustomJS]   NVARCHAR (MAX) NULL,
    [CreatedBy]  NVARCHAR (50)  NOT NULL,
    [Created]    DATETIME       NOT NULL,
    [UpdatedBy]  NVARCHAR (50)  NULL,
    [Updated]    DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [tmp_ms_xx_constraint_CK_Goals_SystemName_unique] UNIQUE NONCLUSTERED ([SystemName] ASC)
);

IF EXISTS (SELECT TOP 1 1 
           FROM   [dbo].[Goals])
    BEGIN
        SET IDENTITY_INSERT [dbo].[tmp_ms_xx_Goals] ON;
        INSERT INTO [dbo].[tmp_ms_xx_Goals] ([Id], [Name], [SystemName], [Active], [GACode], [CustomJS], [CreatedBy], [Created], [UpdatedBy], [Updated])
        SELECT   [Id],
                 [Name],
                 [SystemName],
                 [Active],
                 [GACode],
                 [CustomJS],
                 [CreatedBy],
                 [Created],
                 [UpdatedBy],
                 [Updated]
        FROM     [dbo].[Goals]
        ORDER BY [Id] ASC;
        SET IDENTITY_INSERT [dbo].[tmp_ms_xx_Goals] OFF;
    END

DROP TABLE [dbo].[Goals];

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_Goals]', N'Goals';

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_constraint_CK_Goals_SystemName_unique]', N'CK_Goals_SystemName_unique', N'OBJECT';

COMMIT TRANSACTION;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;


GO
PRINT N'Creating FK_VisitorCohorts_ToGoals...';


GO
ALTER TABLE [dbo].[VisitorConversions] WITH NOCHECK
    ADD CONSTRAINT [FK_VisitorCohorts_ToGoals] FOREIGN KEY ([GoalId]) REFERENCES [dbo].[Goals] ([Id]);


GO
Select * from Cohorts where Type = 'Mtelligent.Entities.Cohorts.AllUsersCohort, Mtelligent.Entities';

if (@@ROWCOUNT = 0)
begin

Insert into Cohorts (Name, SystemName, Type, Created, CreatedBy) Values ('All Users', 'All users', 'Mtelligent.Entities.Cohorts.AllUsersCohort, Mtelligent.Entities', getDate(), 'System')

end

Select * from Cohorts where Type = 'Mtelligent.Entities.Cohorts.AuthenticatedUsersCohort, Mtelligent.Entities';

if (@@ROWCOUNT = 0)
begin

Insert into Cohorts (Name, SystemName, Type, Created, CreatedBy) Values ('Authenticated Users', 'Authenticated users', 'Mtelligent.Entities.Cohorts.AuthenticatedUsersCohort, Mtelligent.Entities', getDate(), 'System')

end

GO

GO
PRINT N'Checking existing data against newly created constraints';


GO
USE [$(DatabaseName)];


GO
ALTER TABLE [dbo].[VisitorConversions] WITH CHECK CHECK CONSTRAINT [FK_VisitorCohorts_ToGoals];


GO
PRINT N'Update complete.';


GO