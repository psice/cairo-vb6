if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_web_UsuarioGetAgenda]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_web_UsuarioGetAgenda]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO
/*

  sp_web_UsuarioGetAgenda 1
  
*/

create procedure sp_web_UsuarioGetAgenda (
  @@us_id           int
)
as
begin
  set nocount on

  /* select tbl_id,tbl_nombrefisico from tabla where tbl_nombrefisico like '%agenda%'*/
  exec sp_HistoriaUpdate 2010, 0, @@us_id, 1

  if not exists (select * from usuario where us_id = @@us_id) begin

    select agn_id,agn_nombre from agenda where 1=2

  end else begin

    if not exists(select *
                  from Agenda 
                  where 
                   (exists (select per_id from Permiso
                            where  pre_id = pre_id_propietario
                               and (Permiso.us_id = @@us_id
                                    or (exists(select rol_id from UsuarioRol where rol_id = Permiso.rol_id and us_id = @@us_id))
                                    )
                           )
                      )
                   ) begin
  
      if not exists  (select * from Agenda where modifico=@@us_id) begin 
  
        declare @agn_codigo varchar(255), @agn_nombre varchar(255), @agn_id int      
  
        if exists(select * from usuario where us_id = @@us_id and prs_id is null) begin
  
          select  @agn_codigo = 'AG-'+ us_nombre, 
                  @agn_nombre = 'Agenda de '+ us_nombre 
          from Usuario where us_id = @@us_id
  
        end else begin
  
          select  @agn_codigo = 'AG-'+ us_nombre, 
                  @agn_nombre = 'Agenda de '+ prs_apellido+', '+ prs_nombre 
          from Usuario inner join Persona on Usuario.prs_id = Persona.prs_id
          where us_id = @@us_id
        end
  
        exec sp_dbGetNewId 'Agenda', 'agn_id', @agn_id out, 0
   
        insert into Agenda (agn_id, agn_nombre, agn_codigo, modifico)
                    values (@agn_id, @agn_nombre, @agn_codigo, @@us_id)
  
        exec sp_AgendaSavePrestacion @agn_id
      end
    end
  
    select top 1 agn_id, agn_nombre
  
    from Agenda 
    where 
     (exists (select per_id from Permiso
              where  pre_id = pre_id_propietario
                 and (Permiso.us_id = @@us_id
                      or (exists(select rol_id from UsuarioRol where rol_id = Permiso.rol_id and us_id = @@us_id))
                      )
             )
        )
  end  
end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

