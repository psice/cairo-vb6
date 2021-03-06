SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_AlumnoSaveCliente]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_AlumnoSaveCliente]
GO

/*

sp_AlumnoSaveCliente 12404,1

*/

create procedure sp_AlumnoSaveCliente
(
  @@alum_id   int,
  @@emp_id    int,
  @@bSilent   tinyint = 0
)
as
begin

  declare @cli_id           int
  declare @cli_nombre       varchar(1000)
  declare @cli_razonsocial   varchar(1000)
  declare @modifico         int
  declare @prs_id           int

  select  @cli_id = cli_id, 
          @prs_id = alum.prs_id,
          @modifico = alum.modifico, 
          @cli_nombre = prs_apellido + ', ' + prs_nombre
  from Alumno alum inner join Persona prs on alum.prs_id = prs.prs_id
  where alum_id = @@alum_id

  set @cli_razonsocial = @cli_nombre

  if @cli_id is null begin

    declare @cfg_valor       varchar(5000) 
    
    -- Obtengo condicion de pago y lista de precios
    --
    declare @cpg_id int
    declare @lp_id  int

    exec sp_Cfg_GetValor  'Ventas-General',
                          'ClientesPVcpg_id',
                          @cfg_valor out,
                          0
    
    if isnumeric(@cfg_valor)=0 set @cpg_id = null
    else                        set @cpg_id = convert(int,@cfg_valor)

    exec sp_Cfg_GetValor  'Ventas-General',
                          'ClientesPVlp_id',
                          @cfg_valor out,
                          0
    
    if isnumeric(@cfg_valor)=0 set @lp_id = null
    else                        set @lp_id = convert(int,@cfg_valor)


    exec sp_dbgetnewid 'Cliente','cli_id',@cli_id out,0

    insert into Cliente (cli_id, cli_nombre, cli_codigo, cli_razonsocial, cli_catfiscal, modifico, cpg_id, lp_id)
                  values(@cli_id, @cli_nombre, right('00000'+convert(varchar,@cli_id),5),
                                                         @cli_razonsocial, 4 /*CF*/, @modifico, @cpg_id, @lp_id)

    declare @empcli_id int

    exec sp_dbgetnewid 'EmpresaCliente','empcli_id',@empcli_id out,0

    insert into EmpresaCliente (empcli_id,emp_id,cli_id,modifico) 
                        values (@empcli_id, @@emp_id, @cli_id, @modifico)

    update Persona set cli_id = @cli_id where prs_id = @prs_id

  end else begin

    -- Si el cliente tiene asociado otros alumnos no hacemos nada
    -- (es el caso donde los alumnos son de una empresa que paga por sus cursos)
    --
    if not exists(select * 
                  from Alumno alum 
                    inner join Persona prs 
                      on alum.prs_id = prs.prs_id 
                  where cli_id = @cli_id 
                    and alum_id <> @@alum_id
                  )
    begin

      update Cliente set   cli_nombre       = @cli_nombre, 
                          cli_razonsocial = @cli_razonsocial, 
                          modifico         = @modifico
      where cli_id = @cli_id

    end
  end

  if @@bSilent = 0

    select cli_id, cli_nombre from Cliente where cli_id = @cli_id

end

go
set quoted_identifier off 
go
set ansi_nulls on 
go

