using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DataLabellingSupportSystem.Api.Migrations
{
    /// <inheritdoc />
    public partial class UseObjectIdStringsAndRoles : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(@"
    IF OBJECT_ID(N'[dbo].[Users]', N'U') IS NOT NULL
    BEGIN
        DROP TABLE [dbo].[Users];
    END;

    IF OBJECT_ID(N'[dbo].[Roles]', N'U') IS NOT NULL
    BEGIN
        DROP TABLE [dbo].[Roles];
    END;

    CREATE TABLE [dbo].[Roles]
    (
        [_id] varchar(24) NOT NULL,
        [name] nvarchar(100) NOT NULL,
        CONSTRAINT [PK_Roles] PRIMARY KEY ([_id])
    );

    CREATE UNIQUE INDEX [IX_Roles_name] ON [dbo].[Roles]([name]);

    CREATE TABLE [dbo].[Users]
    (
        [_id] varchar(24) NOT NULL,
        [fullName] nvarchar(150) NOT NULL,
        [email] nvarchar(320) NOT NULL,
        [phoneNumber] nvarchar(20) NULL,
        [identifyNumber] nvarchar(20) NULL,
        [gender] nvarchar(20) NULL,
        [address] nvarchar(300) NULL,
        [dateOfBirth] date NULL,
        [passwordHash] nvarchar(255) NOT NULL,
        [role] varchar(24) NOT NULL,
        [status] int NOT NULL CONSTRAINT [DF_Users_status] DEFAULT (0),
        [createdAt] datetime2 NOT NULL CONSTRAINT [DF_Users_createdAt] DEFAULT (SYSUTCDATETIME()),
        [updatedAt] datetime2 NOT NULL CONSTRAINT [DF_Users_updatedAt] DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT [PK_Users] PRIMARY KEY ([_id]),
        CONSTRAINT [FK_Users_Roles_role] FOREIGN KEY ([role]) REFERENCES [dbo].[Roles]([_id]) ON DELETE NO ACTION
    );

    CREATE UNIQUE INDEX [IX_Users_email] ON [dbo].[Users]([email]);
    CREATE INDEX [IX_Users_role] ON [dbo].[Users]([role]);
    ");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(@"
    IF OBJECT_ID(N'[dbo].[Users]', N'U') IS NOT NULL
    BEGIN
        DROP TABLE [dbo].[Users];
    END;

    IF OBJECT_ID(N'[dbo].[Roles]', N'U') IS NOT NULL
    BEGIN
        DROP TABLE [dbo].[Roles];
    END;

    CREATE TABLE [dbo].[Users]
    (
        [_id] uniqueidentifier NOT NULL CONSTRAINT [DF_Users__id] DEFAULT NEWSEQUENTIALID(),
        [fullName] nvarchar(150) NOT NULL,
        [email] nvarchar(320) NOT NULL,
        [phoneNumber] nvarchar(20) NULL,
        [identifyNumber] nvarchar(20) NULL,
        [gender] nvarchar(20) NULL,
        [address] nvarchar(300) NULL,
        [dateOfBirth] date NULL,
        [passwordHash] nvarchar(255) NOT NULL,
        [role] nvarchar(50) NOT NULL,
        [status] int NOT NULL CONSTRAINT [DF_Users_status] DEFAULT (0),
        [createdAt] datetime2 NOT NULL CONSTRAINT [DF_Users_createdAt] DEFAULT (SYSUTCDATETIME()),
        [updatedAt] datetime2 NOT NULL CONSTRAINT [DF_Users_updatedAt] DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT [PK_Users] PRIMARY KEY ([_id])
    );

    CREATE UNIQUE INDEX [IX_Users_email] ON [dbo].[Users]([email]);
    ");
        }
    }
}
