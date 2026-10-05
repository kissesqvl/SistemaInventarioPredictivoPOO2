-- =====================================================
-- Script para Railway: base + tablas + datos + usuario de la app
-- Ejecutar conectado como "sa" (en la base master)
-- =====================================================
IF DB_ID(N'SistemaInventarioPredictivo') IS NULL
    CREATE DATABASE [SistemaInventarioPredictivo]
GO
USE [SistemaInventarioPredictivo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Permiso](
	[idPermiso] [int] IDENTITY(1,1) NOT NULL,
	[nombrePermiso] [varchar](100) NOT NULL,
	[descripcion] [varchar](200) NULL,
	[estado] [bit] NOT NULL,
PRIMARY KEY CLUSTERED ([idPermiso] ASC)
)
GO
CREATE TABLE [dbo].[Rol](
	[idRol] [int] IDENTITY(1,1) NOT NULL,
	[nombreRol] [varchar](50) NOT NULL,
	[descripcion] [varchar](150) NULL,
	[estado] [bit] NOT NULL,
PRIMARY KEY CLUSTERED ([idRol] ASC)
)
GO
CREATE TABLE [dbo].[Usuario](
	[idUsuario] [int] IDENTITY(1,1) NOT NULL,
	[nombreUsuario] [varchar](100) NOT NULL,
	[correo] [varchar](150) NULL,
	[contrasenaHash] [varchar](255) NOT NULL,
	[idRol] [int] NOT NULL,
	[idPermiso] [int] NULL,
	[ultimoAcceso] [datetime] NULL,
	[intentosFallidos] [int] NOT NULL,
	[bloqueado] [bit] NOT NULL,
	[tokenRecuperacion] [varchar](255) NULL,
	[fechaCreacion] [datetime] NOT NULL,
	[fechaActualizacion] [datetime] NULL,
	[usuarioRegistro] [varchar](100) NULL,
	[estado] [bit] NOT NULL,
PRIMARY KEY CLUSTERED ([idUsuario] ASC)
)
GO
SET IDENTITY_INSERT [dbo].[Permiso] ON
INSERT [dbo].[Permiso] ([idPermiso], [nombrePermiso], [descripcion], [estado]) VALUES (1, N'AccesoSistema', N'Permite ingresar al sistema', 1)
INSERT [dbo].[Permiso] ([idPermiso], [nombrePermiso], [descripcion], [estado]) VALUES (2, N'AccesoSistema', N'Permite ingresar al sistema', 1)
SET IDENTITY_INSERT [dbo].[Permiso] OFF
GO
SET IDENTITY_INSERT [dbo].[Rol] ON
INSERT [dbo].[Rol] ([idRol], [nombreRol], [descripcion], [estado]) VALUES (1, N'Administrador', N'Acceso completo al sistema', 1)
INSERT [dbo].[Rol] ([idRol], [nombreRol], [descripcion], [estado]) VALUES (2, N'Administrador', N'Acceso completo al sistema', 1)
SET IDENTITY_INSERT [dbo].[Rol] OFF
GO
SET IDENTITY_INSERT [dbo].[Usuario] ON
INSERT [dbo].[Usuario] ([idUsuario], [nombreUsuario], [correo], [contrasenaHash], [idRol], [idPermiso], [ultimoAcceso], [intentosFallidos], [bloqueado], [tokenRecuperacion], [fechaCreacion], [fechaActualizacion], [usuarioRegistro], [estado]) VALUES (1, N'admin', N'admin@empresa.com', N'SkJMOpQuabG9Zma9JIdb8Q==:SsgltL9LWr6o5jbahe0nQN4HugZ7bDqZQghKVKSwhPM=', 1, 1, CAST(N'2026-09-26T13:03:52.140' AS DateTime), 0, 0, NULL, CAST(N'2026-09-25T12:28:15.490' AS DateTime), CAST(N'2026-09-26T13:03:52.140' AS DateTime), N'SYSTEM', 1)
SET IDENTITY_INSERT [dbo].[Usuario] OFF
GO
SET ANSI_PADDING ON
GO
ALTER TABLE [dbo].[Usuario] ADD UNIQUE NONCLUSTERED ([correo] ASC)
GO
ALTER TABLE [dbo].[Usuario] ADD UNIQUE NONCLUSTERED ([nombreUsuario] ASC)
GO
ALTER TABLE [dbo].[Permiso] ADD DEFAULT ((1)) FOR [estado]
GO
ALTER TABLE [dbo].[Rol] ADD DEFAULT ((1)) FOR [estado]
GO
ALTER TABLE [dbo].[Usuario] ADD DEFAULT ((0)) FOR [intentosFallidos]
GO
ALTER TABLE [dbo].[Usuario] ADD DEFAULT ((0)) FOR [bloqueado]
GO
ALTER TABLE [dbo].[Usuario] ADD DEFAULT (getdate()) FOR [fechaCreacion]
GO
ALTER TABLE [dbo].[Usuario] ADD DEFAULT ((1)) FOR [estado]
GO
ALTER TABLE [dbo].[Usuario] WITH CHECK ADD CONSTRAINT [FK_Usuario_Permiso] FOREIGN KEY([idPermiso]) REFERENCES [dbo].[Permiso] ([idPermiso])
GO
ALTER TABLE [dbo].[Usuario] CHECK CONSTRAINT [FK_Usuario_Permiso]
GO
ALTER TABLE [dbo].[Usuario] WITH CHECK ADD CONSTRAINT [FK_Usuario_Rol] FOREIGN KEY([idRol]) REFERENCES [dbo].[Rol] ([idRol])
GO
ALTER TABLE [dbo].[Usuario] CHECK CONSTRAINT [FK_Usuario_Rol]
GO

-- ===== Usuario que usa la aplicación =====
USE [master]
GO
IF NOT EXISTS (SELECT 1 FROM sys.sql_logins WHERE name = N'app_inventario')
    CREATE LOGIN [app_inventario] WITH PASSWORD = N'ApdQhpb0rS5tPKlcKdCu#9', CHECK_POLICY = OFF
GO
USE [SistemaInventarioPredictivo]
GO
CREATE USER [app_inventario] FOR LOGIN [app_inventario]
GO
ALTER ROLE db_datareader ADD MEMBER [app_inventario]
ALTER ROLE db_datawriter ADD MEMBER [app_inventario]
GO
