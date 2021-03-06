SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_Web_UsuarioUpdatePwd]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_Web_UsuarioUpdatePwd]
GO

/*

select * from usuario where us_id = 1

sp_Web_UsuarioUpdatePwd 1,1,''

*/

create procedure sp_Web_UsuarioUpdatePwd
(
  @@rtn             int out,
  @@us_id           int,
  @@us_clave         varchar(50)
) 
As

  /* select tbl_id,tbl_nombrefisico from tabla where tbl_nombrefisico like '%%'*/
  exec sp_HistoriaUpdate 3, @@us_id, @@us_id, 1

  if @@us_id <> 0 begin

      update Usuario set us_clave  = @@us_clave  where us_id = @@us_id
      if @@error <> 0 set @@us_id=0
  end  

  set @@rtn = @@us_id

go
set quoted_identifier off 
go
set ansi_nulls on 
go

