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
PRINT N'Dropping CK_Goals_Name_unique...';


GO
ALTER TABLE [dbo].[Goals] DROP CONSTRAINT [CK_Goals_Name_unique];


GO
PRINT N'Creating [dbo].[CohortProperties]...';


GO
CREATE TABLE [dbo].[CohortProperties] (
    [Id]       INT            IDENTITY (1, 1) NOT NULL,
    [CohortId] INT            NOT NULL,
    [Name]     NVARCHAR (255) NOT NULL,
    [Value]    NVARCHAR (MAX) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
PRINT N'Creating [dbo].[Cohorts]...';


GO
CREATE TABLE [dbo].[Cohorts] (
    [Id]         INT              IDENTITY (1, 1) NOT NULL,
    [Name]       NVARCHAR (100)   NOT NULL,
    [SystemName] NVARCHAR (100)   NOT NULL,
    [UID]        UNIQUEIDENTIFIER NOT NULL,
    [Active]     INT              NOT NULL,
    [Type]       NVARCHAR (255)   NOT NULL,
    [CreatedBy]  NVARCHAR (50)    NOT NULL,
    [Created]    DATETIME         NOT NULL,
    [UpdatedBy]  NVARCHAR (50)    NULL,
    [Updated]    DATETIME         NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [CK_Cohorts_SystemName] UNIQUE NONCLUSTERED ([SystemName] ASC)
);


GO
PRINT N'Creating CK_Goals_SystemName_unique...';


GO
ALTER TABLE [dbo].[Goals]
    ADD CONSTRAINT [CK_Goals_SystemName_unique] UNIQUE NONCLUSTERED ([SystemName] ASC);


GO
PRINT N'Creating Default Constraint on [dbo].[Cohorts]....';


GO
ALTER TABLE [dbo].[Cohorts]
    ADD DEFAULT newID() FOR [UID];


GO
PRINT N'Creating Default Constraint on [dbo].[Cohorts]....';


GO
ALTER TABLE [dbo].[Cohorts]
    ADD DEFAULT 1 FOR [Active];


GO
PRINT N'Creating FK_CohortProperties_ToCohort...';


GO
ALTER TABLE [dbo].[CohortProperties] WITH NOCHECK
    ADD CONSTRAINT [FK_CohortProperties_ToCohort] FOREIGN KEY ([CohortId]) REFERENCES [dbo].[Cohorts] ([Id]);


GO
PRINT N'Checking existing data against newly created constraints';


GO
USE [$(DatabaseName)];


GO
ALTER TABLE [dbo].[CohortProperties] WITH CHECK CHECK CONSTRAINT [FK_CohortProperties_ToCohort];


GO
PRINT N'Update complete.';


GO
