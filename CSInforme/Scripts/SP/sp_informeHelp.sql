if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_informeHelp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_informeHelp]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO
/*

  sp_informehelp 'd',0,0,1
  sp_informeHelp '',-1,0,7
  sp_informeHelp '',0,0,7

*/

create procedure sp_informeHelp (
  @@us_id           int,
  @@bForAbm         tinyint        = 0,
  @@filter           varchar(255)  = '',
  @@check            smallint       = 0,
  @@inf_id          int,
  @@filter2          int = 0  -- Este sp no espera un filtro de tipo texto, 
                            -- sino un 1 o un 2 para determinar si debe 
                            -- mostrar informes o procesos
)
as
begin
  set nocount on

  create table #Informes (
                          per_id int,
                          pre_id int
                          )

  if @@check <> 0 begin
  
    declare @brslt  tinyint
    declare @pre_id int

    select @pre_id = pre_id from Informe where inf_id = @@inf_id
    exec SP_SecGetPermisoXUsuario @@us_id, @pre_id, @brslt out

    select   inf_id,
            inf_nombre        as [Nombre],
            inf_codigo         as [Codigo]

    from Informe

    where inf_id = @@inf_id
      and activo <> 0
      and @brslt <> 0
      and (inf_tipo = @@filter2 or @@filter2 = 0)

  end else begin

    if @@bForAbm <> 0 begin

        select inf_id,
               inf_nombre   as Nombre,
               inf_codigo   as Codigo,
               inf_modulo           as Modulo,
               inf_storedprocedure   as [Proceso],
               inf_reporte          as [Archivo CSR]

        from Informe
        where  (inf_tipo = @@filter2 or @@filter2 = 0)
          and (inf_codigo like '%'+@@filter+'%' or inf_nombre like '%'+@@filter+'%' 
                or inf_storedprocedure like '%'+@@filter+'%' 
                or inf_reporte like '%'+@@filter+'%' 
                or @@filter = '')
    end else begin

      if @@us_id <> 0 begin
  
        insert into #Informes exec SP_SecGetPermisosXUsuario @@us_id, 1
        select distinct inf_id,
               inf_nombre   as Nombre,
               inf_codigo   as Codigo,
               i.inf_modulo           as Modulo,
               i.inf_storedprocedure   as [Proceso],
               i.inf_reporte          as [Archivo CSR]

        from Informe i inner join #Informes i2 on i.pre_id = i2.pre_id
        where activo <> 0
          and (inf_tipo = @@filter2 or @@filter2 = 0)
          and (inf_codigo like '%'+@@filter+'%' or inf_nombre like '%'+@@filter+'%' 
                or inf_storedprocedure like '%'+@@filter+'%' 
                or inf_reporte like '%'+@@filter+'%' 
                or @@filter = '')
  
      end else begin
  
        select inf_id,
               inf_nombre           as Nombre,
               inf_codigo           as Codigo,
               inf_modulo           as Modulo,
               inf_storedprocedure   as [Proceso],
               inf_reporte          as [Archivo CSR]
        from Informe
        where  (inf_tipo = @@filter2 or @@filter2 = 0)
          and (inf_codigo like '%'+@@filter+'%' or inf_nombre like '%'+@@filter+'%' 
                or inf_storedprocedure like '%'+@@filter+'%' 
                or inf_reporte like '%'+@@filter+'%' 
                or @@filter = '')
  
      end
    end
  end    
end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

