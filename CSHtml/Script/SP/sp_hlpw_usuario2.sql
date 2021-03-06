if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_hlpw_usuario2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_hlpw_usuario2]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO
/*

        select us_id,
               us_nombre   as Nombre,
               us_codigo   as Codigo
        from Usuario 
  
        where (exists (select * from EmpresaUsuario where us_id = Usuario.us_id) or 1 = 1)

  select us_empresaex from usuario

 sp_hlpw_usuario2 1,1,'cca'

sp_hlpw_usuario2 572,1


*/

create procedure sp_hlpw_usuario2 (
  @@us_id           int,
  @@emp_id          int,
  @@filter           varchar(255)  = '',
  @@check            smallint       = 0
)
as
begin
  set nocount on

  if @@check <> 0 begin
  
    select   us_id,
            us_nombre        as [Nombre]

    from usuario

    where (us_nombre = @@filter)
      and activo <> 0
      and us_id <> -250
--      and (exists (select * from EmpresaUsuario where us_id = Usuario.us_id and emp_id = @@emp_id))

  end else begin

      select top 50
             us_id,
             us_nombre   as Nombre,
             IsNull(prs_apellido + ', ' + prs_nombre,'-') as Persona

      from usuario left join persona on usuario.prs_id = persona.prs_id

      where (us_nombre like '%'+@@filter+'%' 
             or prs_apellido like '%'+@@filter+'%' 
             or prs_nombre like '%'+@@filter+'%'
             or @@filter = ''
            )
        and us_id <> -250
        and usuario.activo <> 0
--        and (exists (select * from EmpresaUsuario where us_id = Usuario.us_id and emp_id = @@emp_id))
  end    

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

