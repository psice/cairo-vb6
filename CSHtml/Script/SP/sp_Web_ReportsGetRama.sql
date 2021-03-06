SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_Web_ReportsGetRama]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_Web_ReportsGetRama]
GO

/*

select * from reporte

sp_Web_ReportsGetRama 5

*/

create procedure sp_Web_ReportsGetRama
(
  @@ram_id           int,
  @@tbl_id           int
) 
as
begin

  select 
          ram_nombre 
  
  from rama inner join arbol on rama.arb_id = arbol.arb_id 
  
  where ram_id = Ram_ID
    and tbl_id = Tbl_id
  
end
go
set quoted_identifier off 
go
set ansi_nulls on 
go

