if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_SysDomainDeleteEmpresa]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_SysDomainDeleteEmpresa]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO
/*


*/
create procedure sp_SysDomainDeleteEmpresa (
  @@bd_id         int,
  @@emp_id        int
)
as
begin

  delete Empresa where bd_id = @@bd_id and emp_id = @@emp_id

end


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

