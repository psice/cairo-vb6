if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_web_AvisoDelete]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_web_AvisoDelete]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO
/*

sp_web_AvisoDelete 572,1


*/

create procedure sp_web_AvisoDelete (
  @@us_id          int,
  @@ptd_id         int
)
as
begin
  set nocount on

  delete aviso where avt_id = 1 /* Partes diarios */ 
                  and us_id  = @@us_id
                  and id     = @@ptd_id

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

