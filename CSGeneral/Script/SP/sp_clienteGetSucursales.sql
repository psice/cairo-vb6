SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_clienteGetSucursales]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_clienteGetSucursales]
GO

/*

sp_clienteGetSucursales 7

*/

create procedure sp_clienteGetSucursales
(
  @@cli_id              int
)
as
begin

  select 
    clis.*,
    zon_nombre,
    pro_nombre,
    pa_nombre


  from ClienteSucursal clis left join zona      zon on clis.zon_id = zon.zon_id
                            left join provincia pro on clis.pro_id = pro.pro_id
                            left join pais      pa  on clis.pa_id  = pa.pa_id

  where cli_id= @@cli_id

end

go
set quoted_identifier off 
go
set ansi_nulls on 
go

