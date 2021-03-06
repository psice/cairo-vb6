SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_web_EncuestaSeccionSave]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_web_EncuestaSeccionSave]
GO

/*

sp_web_EncuestaSeccionSave 

*/

create procedure sp_web_EncuestaSeccionSave (

  @@ec_id             int,
  @@strIds             varchar(5000)
)
as

begin

  declare @ws_id    int
  declare @ecws_id  int
  declare @timeCode datetime

  set @timeCode = getdate()
  exec sp_strStringToTable @timeCode, @@strIds, ','

  declare c_seccion insensitive cursor for 

        select convert(int,tmpstr2tbl_campo)
        from TmpStringToTable
        where tmpstr2tbl_id = @timeCode

  open c_seccion

  begin transaction

  delete EncuestaWebSeccion where ec_id = @@ec_id

  fetch next from c_seccion into @ws_id
  while @@fetch_status = 0
  begin
    
    exec sp_dbgetnewid 'EncuestaWebSeccion', 'ecws_id', @ecws_id out, 0

    insert into EncuestaWebSeccion (ec_id, ws_id, ecws_id) values(@@ec_id, @ws_id, @ecws_id)
    if @@error <> 0 goto ControlError

    fetch next from c_seccion into @ws_id
  end

  close c_seccion
  deallocate c_seccion

  commit transaction

  return
ControlError:

  raiserror ('Ha ocurrido un error al grabar la encuesta. sp_web_EncuestaSeccionSave.', 16, 1)

  if @@trancount > 0 begin
    rollback transaction  
  end

end
go
set quoted_identifier off 
go
set ansi_nulls on 
go

