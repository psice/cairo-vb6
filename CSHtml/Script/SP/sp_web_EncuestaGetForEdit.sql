SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_web_EncuestaGetForEdit]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_web_EncuestaGetForEdit]
GO

/*

sp_web_EncuestaGetForEdit 7

*/

create Procedure sp_web_EncuestaGetForEdit
(
  @@ws_id               int,
  @@ec_fechaDesde        datetime,
  @@ec_fechaHasta        datetime,
  @@ec_nombre            varchar(255),
  @@ec_descrip          varchar(255),
  @@us_id               int
) 
as

  set @@ec_nombre   = IsNull(@@ec_nombre,'')
  set @@ec_descrip  = IsNull(@@ec_descrip,'')

  select ec_id, ec_fechaDesde, ec_nombre, ec_descrip
  from Encuesta ec
  where (    exists(select * from EncuestaWebSeccion 
                      where ec_id = ec.ec_id and ws_id = @@ws_id)
         or IsNull(@@ws_id,0) = 0)
   and (ec.ec_nombre like @@ec_nombre or @@ec_nombre='')
   and (ec.ec_descrip like @@ec_descrip or @@ec_descrip='')
   and (
        (ec_fechaDesde between @@ec_fechaDesde and @@ec_fechaHasta)
      or
        (ec_fechaHasta between @@ec_fechaDesde and @@ec_fechaHasta )
        )

  order by ec_fechaDesde

go
set quoted_identifier off 
go
set ansi_nulls on 
go

