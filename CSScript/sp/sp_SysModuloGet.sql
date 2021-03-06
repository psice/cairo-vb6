if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_SysModuloGet]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_SysModuloGet]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO
/*

  select * from usuario

  sp_SysModuloGet 38

*/
create procedure sp_SysModuloGet (
  @@us_id            int
)
as
begin

  set nocount on

  select distinct 

      s.sysm_id,
      s.sysm_orden,
      s.sysm_objetoinicializacion,
      s.sysm_objetoedicion,
      s.pre_id

   from sysModulo s inner join sysModuloUser u on s.sysm_id = u.sysm_id and u.us_id = @@us_id

  order by s.sysm_orden

end


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

