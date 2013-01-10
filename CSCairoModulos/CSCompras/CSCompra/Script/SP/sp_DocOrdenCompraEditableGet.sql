if exists (select * from sysobjects where id = object_id(N'[dbo].[sp_DocOrdenCompraEditableGet]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_DocOrdenCompraEditableGet]

go
/*

sp_DocOrdenCompraEditableGet 57,7,0,'',1

*/

create procedure sp_DocOrdenCompraEditableGet (
  @@emp_id        int,
  @@oc_id         int,
  @@us_id         int,
  @@bEditable     tinyint        out,
  @@editMsg       varchar(255)   out,
  @@ShowMsg       tinyint = 0,
  @@bNoAnulado    tinyint = 0,
  @@bDelete        tinyint = 0 --TODO:delete
)
as

begin

  declare @doc_id         int
  declare @oc_fecha       datetime
  declare @estado          int
  declare @anulado        int set @anulado = 7
  declare @firmado        int
  declare @emp_id         int
  declare @emp_nombre     varchar(255)
  declare @impreso        tinyint

  declare @csPreCpraEditOrden   int set @csPreCpraEditOrden   = 17022
  declare @csPreCpraDeleteOrden  int set @csPreCpraDeleteOrden  = 17023

  if @@oc_id <> 0 begin


    select 
          @doc_id    = d.doc_id, 
          @emp_id    = c.emp_id,
          @oc_fecha  = oc_fecha,
          @estado    = est_id,
          @impreso   = c.impreso

    from OrdenCompra c inner join Documento d on c.doc_id = d.doc_id 
    where oc_id = @@oc_id

    if @@emp_id <> @emp_id begin

            select @emp_nombre = emp_nombre from Empresa where emp_id = @emp_id
            set @@bEditable = 0

--TODO:delete
            if @@bDelete = 0 begin

              set @@editMsg = 'El comprobante pertenece a la empresa ' 
                              +  @emp_nombre 
                              + ', para editarlo debe ingresar al sistema indicando dicha empresa.'
            end else begin

              set @@editMsg = 'El comprobante pertenece a la empresa ' 
                              +  @emp_nombre 
                              + ', para borrarlo debe ingresar al sistema indicando dicha empresa.'
            end
--TODO:delete

            if @@ShowMsg <> 0
              select [Editable]=@@bEditable, [EditMsg]= @@editMsg
            return
    end

    if @estado = @anulado and @@bNoAnulado = 0 begin
            set @@bEditable = 0
            set @@editMsg = 'El comprobante esta anulado'
            if @@ShowMsg <> 0
              select [Editable]=@@bEditable, [EditMsg]= @@editMsg
            return
    end

--TODO:delete
    declare @pre_id int
    if @@bDelete = 0  set @pre_id = @csPreCpraEditOrden
    else              set @pre_id = @csPreCpraDeleteOrden
--TODO:delete

    -- Tiene permiso para editar Ordenes de compra
    --
    if not exists (select per_id from permiso 
                     where pre_id = @pre_id --TODO:delete
                           and (
                                  (
                                  us_id = @@us_id
                                  )
                                  or
                                  exists(
                                      select us_id from usuarioRol
                                      where us_id  = @@us_id
                                        and rol_id = permiso.rol_id
                                  )
                                ) 
                   )begin
   
            set @@bEditable = 0

--TODO:delete
            if @@bDelete = 0  set @@editMsg = 'Usted no tiene permiso para editar ordenes de compra'
            else              set @@editMsg = 'Usted no tiene permiso para borrar ordenes de compra'
--TODO:delete

            if @@ShowMsg <> 0
              select [Editable]=@@bEditable, [EditMsg]= @@editMsg
            return
    end
      
    -- Tiene permiso para editar este documento
    --
--TODO:delete
    declare @doc_nombre  varchar(255)

    set @pre_id = null

    select @pre_id = case 
                        when @@bDelete = 0 then pre_id_edit
                        else                    pre_id_delete
                     end,
           @doc_nombre = doc_nombre 
    from documento 
    where doc_id = @doc_id
--TODO:delete

    if not exists (select per_id from permiso 
                     where pre_id = @pre_id --TODO:delete
                           and (
                                  (
                                  us_id = @@us_id
                                  )
                                  or
                                  exists(
                                      select us_id from usuarioRol
                                      where us_id  = @@us_id
                                        and rol_id = permiso.rol_id
                                  )
                                ) 
                   )begin
   
            set @@bEditable = 0

--TODO:delete
            if @@bDelete = 0  set @@editMsg = 'Usted no tiene permiso para editar ' + @doc_nombre
            else              set @@editMsg = 'Usted no tiene permiso para borrar ' + @doc_nombre
--TODO:delete

            if @@ShowMsg <> 0
              select [Editable]=@@bEditable, [EditMsg]= @@editMsg
            return
    end

    declare @fca_id int
  
    -- Fechas de control de Acceso
    select @fca_id = fca_id from Documento where doc_id = @doc_id 
  
    if not @fca_id is null begin

      if not exists(select fca_id from FechaControlAcceso 
                where fca_id = @fca_id and @oc_fecha between fca_fechaDesde and fca_fechaHasta) begin
  
              declare @fca_fechaDesde   datetime
              declare @fca_fechaHasta   datetime
    
              select @fca_fechaDesde=fca_fechaDesde,
                     @fca_fechaHasta=fca_fechaHasta
              from FechaControlAcceso 
                where fca_id = @fca_id

              set @@bEditable = 0
              set @@editMsg = 'La fecha del comprobante esta fuera del intervalo definido por las fechas de control de acceso (' 
                              + convert(varchar(20),isnull(@fca_fechaDesde,'')) +' - '+ convert(varchar(20),isnull(@fca_fechaHasta,'')) + ')'
              if @@ShowMsg <> 0
                select [Editable]=@@bEditable, [EditMsg]= @@editMsg
              return
      end
    end
  
    if exists(select oc_id from OrdenFacturaCompra f inner join Ordencompraitem oci on f.oci_id = oci.oci_id where oc_id = @@oc_id) begin
      set @@bEditable = 0
      set @@editMsg = 'El comprobante esta vinculado a una factura'
      if @@ShowMsg <> 0
        select [Editable]=@@bEditable, [EditMsg]= @@editMsg
      return
    end

    if exists(select oc_id from OrdenRemitoCompra r inner join Ordencompraitem oci on r.oci_id = oci.oci_id where oc_id = @@oc_id) begin
      set @@bEditable = 0
      set @@editMsg = 'El comprobante esta vinculado a un remito'
      if @@ShowMsg <> 0
        select [Editable]=@@bEditable, [EditMsg]= @@editMsg
      return
    end

    if exists(select * from OrdenDevolucionCompra p inner join Ordencompraitem oci on p.oci_id_Orden = oci.oci_id or p.oci_id_devolucion = oci.oci_id where oc_id = @@oc_id) begin
      set @@bEditable = 0
      set @@editMsg = 'El comprobante esta vinculado a una cancelación de orden de compra'
      if @@ShowMsg <> 0
        select [Editable]=@@bEditable, [EditMsg]= @@editMsg
      return
    end

    if exists(select * from PedidoOrdenCompra p inner join OrdenCompraItem oci on p.oci_id = oci.oci_id where oc_id = @@oc_id) begin
      set @@bEditable = 0
      set @@editMsg = 'El comprobante esta vinculado a un pedido'
      if @@ShowMsg <> 0
        select [Editable]=@@bEditable, [EditMsg]= @@editMsg
      return
    end

    if @impreso <> 0 and @@bNoAnulado = 0 begin

      declare @doc_editarimpresos tinyint
  
      select @doc_editarimpresos = doc_editarimpresos 
      from documento 
      where doc_id = @doc_id
  
      if @doc_editarimpresos = 0 begin
        set @@bEditable = 0

--TODO:delete
        if @@bDelete = 0  set @@editMsg = 'El comprobante esta impreso y la definición de su documento no permite la edición de comprobantes impresos.'
        else              set @@editMsg = 'El comprobante esta impreso y la definición de su documento no permite eliminar comprobantes impresos.'
--TODO:delete

        if @@ShowMsg <> 0
          select [Editable]=@@bEditable, [EditMsg]= @@editMsg
        return
      end
    end
  end
  
  set @@bEditable = 1
  set @@editMsg = ''

  if @@ShowMsg <> 0
    select @@bEditable as [Editable], @@editMsg as [EditMsg]
end