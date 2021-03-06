if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_SysDomainUpdateDom2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_SysDomainUpdateDom2]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO
/*

  select * from basedatos

  sp_SysDomainUpdateDom2 7

*/
create procedure sp_SysDomainUpdateDom2 (
  @@connstr varchar(255)
)
as
begin
  set nocount on

  if exists(select * from sistema where si_clave = 'strconnect_dom') begin

    update sistema set si_valor = @@connstr where si_clave = 'strconnect_dom'

  end else begin

    insert sistema (si_clave,si_valor) values ('strconnect_dom',@@connstr)

  end

end


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

