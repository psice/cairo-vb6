SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_web_EncuestaGet]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_web_EncuestaGet]
GO

/*

select * from Encuesta
select * from EncuestaWebSeccion
select * from EncuestaWebSeccion

sp_web_EncuestaGet 1,1

*/

create Procedure sp_web_EncuestaGet
(
  @@us_id     int,
  @@ws_id     int       = null,
  @@fecha      datetime   = null
) 
as

  set @@fecha = IsNull(@@fecha, getdate())

  select ecp_id, ecp_texto, ecp.ec_id, ecp_multiple
  from EncuestaPregunta ecp inner join EncuestaWebSeccion ecws      on ecp.ec_id   = ecws.ec_id
                            inner join Encuesta ec                  on ecws.ec_id = ec.ec_id
  where ecws.ws_id = @@ws_id
    and @@fecha between ec_fechadesde and ec_fechahasta
    and ec.activo <> 0

    and (
                  exists(select * 
                        from EncuestaDepartamento ecdpto 
                              inner join UsuarioDepartamento usdpto 
                                on   ecdpto.dpto_id  = usdpto.dpto_id 
                                and ecp.ec_id       = ecdpto.ec_id
                                and usdpto.us_id     = @@us_id
                        )
        )

  order by ecp_orden, ecp_texto


go
set quoted_identifier off 
go
set ansi_nulls on 
go

