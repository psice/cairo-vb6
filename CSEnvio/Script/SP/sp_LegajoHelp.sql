if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_LegajoHelp ]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_LegajoHelp ]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO
/*

 sp_LegajoHelp  1,1,1,'',0,0

*/
create procedure sp_LegajoHelp  (
  @@emp_id          int,
  @@us_id           int,
  @@bForAbm         tinyint,
  @@filter           varchar(255)  = '',
  @@check            smallint       = 0,
  @@lgj_id          int=0,
  @@filter2          varchar(5000)  = ''
)
as
begin

  set nocount on


  if @@check <> 0 begin
  
    select   lgj_id,
           case 
              when lgj_titulo <> '' then lgj_titulo 
              else lgj_codigo 
           end               as Nombre,
           lgj_codigo       as Codigo

    from Legajo

    where (lgj_titulo = @@filter or lgj_codigo = @@filter)
      and (activo <> 0 or @@bForAbm <> 0)
      and (lgj_id = @@lgj_id or @@lgj_id=0)

  end else begin

    select top 50
           lgj_id,
           case 
              when lgj_titulo <> '' then lgj_titulo 
              else lgj_codigo 
           end                as Nombre,
           lgj_codigo        as Codigo
    from Legajo 

    where (lgj_codigo like '%'+@@filter+'%' or lgj_titulo like '%'+@@filter+'%' 
            or @@filter = '')
      and (activo <> 0 or @@bForAbm <> 0)

  end    

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

