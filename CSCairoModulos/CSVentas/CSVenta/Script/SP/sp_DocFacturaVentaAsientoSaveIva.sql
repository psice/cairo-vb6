if exists (select * from sysobjects where id = object_id(N'[dbo].[sp_DocFacturaVentaAsientoSaveIva]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_DocFacturaVentaAsientoSaveIva]

/*

 select * from FacturaVenta
 select * from FacturaVentaItem

 sp_DocFacturaVentaAsientoSaveIva 93

*/

go
create procedure sp_DocFacturaVentaAsientoSaveIva (
  @@fv_id             int,
  @@as_id             int,
  @@bIva_ri            tinyint,
  @@mon_id            int,
  @@doct_id_factura    int,
  @@ccos_id            int,
  @@desc1             decimal(18,6),
  @@desc2             decimal(18,6),
  @@bError            tinyint out
)
as

begin

  set nocount on

  declare  @iva                     decimal(18, 6)
  declare @fvi_importe             decimal(18, 6)
  declare @fvi_importeorigen      decimal(18, 6)
  declare @cue_id                 int
  declare  @asi_debe               decimal(18, 6) 
  declare  @asi_haber               decimal(18, 6)
  declare  @asi_origen             decimal(18, 6)
  declare  @fvi_neto               decimal(18, 6) 
  declare  @asi_orden               smallint 

  declare @asi_id          int
  declare @IsNew          smallint

  select @asi_orden = max(asi_orden) from AsientoItem where as_id = @@as_id

  if @@bIva_ri <> 0 begin
    declare c_FacturaItemAsientoIva cursor for 
  
      select sum(fvi_ivari), sum(fvi_importe), sum(fvi_importeorigen), ti.cue_id
      from FacturaVentaItem fvi inner join Producto p         on fvi.pr_id           = p.pr_id
                                inner join TasaImpositiva ti  on p.ti_id_ivariventa  = ti.ti_id

      where fv_id = @@fv_id
      group by    
              ti.cue_id having sum(fvi_ivari) <> 0

  end else begin

    declare c_FacturaItemAsientoIva cursor for 
  
      select sum(fvi_ivarni), sum(fvi_importe), sum(fvi_importeorigen), ti.cue_id
      from FacturaVentaItem fvi inner join Producto p         on fvi.pr_id           = p.pr_id
                                inner join TasaImpositiva ti  on p.ti_id_ivarniventa = ti.ti_id
                                
      where fv_id = @@fv_id
      group by    
              ti.cue_id having sum(fvi_ivarni) <> 0
  end

  open c_FacturaItemAsientoIva

  fetch next from c_FacturaItemAsientoIva into
        @iva, @fvi_importe, @fvi_importeorigen, @cue_id

  while @@fetch_status = 0
  begin

    set @asi_id = null

    if @@doct_id_factura = 1 /* Factura */ or @@doct_id_factura = 9 /* Nota de Debito*/ begin
        set @asi_debe  = 0
        set @asi_haber = @iva
        set @asi_haber = @asi_haber - (@asi_haber * @@desc1 /100)
        set @asi_haber = @asi_haber - (@asi_haber * @@desc2 /100)

          select @asi_id = asi_id from AsientoItem 
          where as_id = @@as_id and cue_id = @cue_id and asi_debe = 0
                and IsNull(ccos_id,0) = IsNull(@@ccos_id,0)

    end else begin
      if @@doct_id_factura = 7 /* Nota de Credito */ begin
          set @asi_debe  = @iva
          set @asi_debe  = @asi_debe - (@asi_debe * @@desc1 /100)
          set @asi_debe  = @asi_debe - (@asi_debe * @@desc2 /100)
          set @asi_haber = 0

          select @asi_id = asi_id from AsientoItem 
          where as_id = @@as_id and cue_id = @cue_id and asi_haber = 0
                and IsNull(ccos_id,0) = IsNull(@@ccos_id,0)
      end
    end

    if @fvi_importeorigen <> 0 begin
          set @fvi_importeorigen = @fvi_importeorigen - (@fvi_importeorigen * @@desc1 /100)
          set @fvi_importeorigen = @fvi_importeorigen - (@fvi_importeorigen * @@desc2 /100)
          set @asi_origen = @iva /(@fvi_importe / @fvi_importeorigen)
    end
    else  set @asi_origen = 0

    set @asi_id = isnull(@asi_id,0)

    if @asi_id = 0 begin

      exec SP_DBGetNewId 'AsientoItem','asi_id',@asi_id out, 0
  
      set @asi_orden = @asi_orden + 1
  
      insert into AsientoItem (
                                    as_id,
                                    asi_id,
                                    asi_orden,
                                    asi_descrip,
                                    asi_debe,
                                    asi_haber,
                                    asi_origen,
                                    cue_id,
                                    ccos_id,
                                    mon_id
                              )
                          Values(
                                    @@as_id,
                                    @asi_id,
                                    @asi_orden,
                                    '',
                                    @asi_debe,
                                    @asi_haber,
                                    @asi_origen,
                                    @cue_id,
                                    @@ccos_id,
                                    @@mon_id
                              )
  
      if @@error <> 0 goto ControlError
    end else begin 

      update AsientoItem set 
                            asi_debe     = asi_debe   + @asi_debe,
                            asi_haber    = asi_haber  + @asi_haber,
                            asi_origen  = asi_origen + @asi_origen
      where asi_id = @asi_id

    end

    fetch next from c_FacturaItemAsientoIva into
          @iva, @fvi_importe, @fvi_importeorigen, @cue_id
  end

  close c_FacturaItemAsientoIva
  deallocate c_FacturaItemAsientoIva

  set @@bError = 0

  return
ControlError:

  set @@bError = 1

end

go