SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_Web_UsuarioUpdate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_Web_UsuarioUpdate]
GO

/*

select * from usuario

sp_Web_UsuarioUpdate 0,'Neron14','catalina','',0

*/

create procedure sp_Web_UsuarioUpdate
(
  @@us_id           int,
  @@us_nombre       varchar(50),
  @@us_clave         varchar(16),
  @@rtn             int out
) 
As

  if @@us_id = 0 begin

    exec SP_DBGetNewId 'Usuario','us_id',@@us_id out,0

    insert into Usuario (
                            us_id,
                            us_nombre, 
                            us_clave, 
                            us_externo
                        )
                values (
                            @@us_id,
                            @@us_nombre,
                            @@us_clave,
                            1
                        )
  end else begin

      update Usuario set
                          us_nombre = @@us_nombre,
                          us_clave  = @@us_clave

      where us_id = @@us_id

  end  

  select @@rtn = @@us_id

go
set quoted_identifier off 
go
set ansi_nulls on 
go

