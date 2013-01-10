-- Script de Chequeo de Integridad de:

-- 1 - Control de documentos que mueven stock

if exists (select * from sysobjects where id = object_id(N'[dbo].[sp_AuditoriaStockValidateDocFV]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_AuditoriaStockValidateDocFV]

go

create procedure sp_AuditoriaStockValidateDocFV (

  @@fv_id       int,
  @@aud_id       int

)
as

begin

  set nocount on

  declare @st_id         int
  declare @audi_id       int
  declare @doct_id      int
  declare @fv_nrodoc     varchar(50) 
  declare @fv_numero     varchar(50) 
  declare @est_id       int

  create table #KitItems      (
                                pr_id int not null, 
                                nivel int not null
                              )

  create table #KitItemsSerie(
                                pr_id_kit       int null,
                                cantidad         decimal(18,6) not null,
                                pr_id           int not null, 
                                prk_id           int not null,
                                nivel           smallint not null default(0)
                              )

  select 
            @doct_id     = doct_id,
            @st_id       = st_id, 
            @fv_nrodoc  = fv_nrodoc,
            @fv_numero  = convert(varchar,fv_numero),
            @est_id     = est_id

  from FacturaVenta where fv_id = @@fv_id

  -- 1 Si esta anulado no tiene que tener stock
  --
  if @est_id = 7 begin

    if @st_id is not null begin
          
      if exists (select * from Stock where st_id = @st_id) begin
              
        exec sp_dbgetnewid 'AuditoriaItem', 'audi_id', @audi_id out,0
        if @@error <> 0 goto ControlError  
                    
        insert into AuditoriaItem (aud_id, audi_id, audi_descrip,audn_id,audg_id,doct_id,comp_id)
                           values (@@aud_id, 
                                   @audi_id,
                                   'La factura esta anulada y posee un movimiento de stock '
                                   + '(comp.:' + @fv_nrodoc + ' nro.: '+ @fv_numero + ')',
                                   3,
                                   1,
                                   @doct_id,
                                   @@fv_id
                                  )
      end else begin
                
        exec sp_dbgetnewid 'AuditoriaItem', 'audi_id', @audi_id out,0
        if @@error <> 0 goto ControlError  
              
        insert into AuditoriaItem (aud_id, audi_id, audi_descrip,audn_id,audg_id,doct_id,comp_id)
                           values (@@aud_id, 
                                   @audi_id,
                                   'La factura esta anulada y posee st_id distinto de null pero este st_id no existe en la tabla stock '
                                   + '(comp.:' + @fv_nrodoc + ' nro.: '+ @fv_numero + ')',
                                   2,
                                   1,
                                   @doct_id,
                                   @@fv_id
                                  )
        
      end
    end

  -- 2 Si no esta anulado tiene que tener stock
  -- 
  end else begin

    declare @fvi_id                    int
    declare @fvi_cantidad              decimal(18,6)
    declare @pr_id                    int
    declare @pr_nombreventa            varchar(255)
    declare @pr_llevastock            smallint
    declare @pr_eskit                  smallint
    declare @pr_kitItems              decimal(18,6)
    declare @pr_llevanroserie          smallint
    declare @pr_lotefifo              tinyint
    declare @stl_id                   int  
    declare @sti_cantidad             decimal(18,6)
    declare @cant_kits                decimal(18,6)

    declare @pr_ventastock            decimal(18,6)

    declare @pr_item                  varchar(255)
    declare @prns_cantidad            int
    declare @pr_id_item               int

    --//////////////////////////////
    --
    -- Sin numero de serie
    --
      declare c_fv_item insensitive cursor for
    
        select 
                sum(fvi_cantidadaremitir),
                fvi.pr_id,
                pr_nombreventa,
                pr_llevastock,
                pr_eskit,
                pr_kitItems,
                pr_llevanroserie,
                pr_lotefifo,
                pr_ventastock,
                stl_id
        from
              FacturaVentaItem fvi inner join Producto pr on fvi.pr_id = pr.pr_id
    
        where fv_id = @@fv_id and (pr_llevanroserie = 0 or pr_eskit <> 0)

        group by
                fvi.pr_id,
                pr_nombreventa,
                pr_llevastock,
                pr_eskit,
                pr_kitItems,
                pr_llevanroserie,
                pr_lotefifo,
                pr_ventastock,
                stl_id
    
      open c_fv_item
    
      fetch next from c_fv_item into 
                                      @fvi_cantidad,
                                      @pr_id,
                                      @pr_nombreventa,
                                      @pr_llevastock,
                                      @pr_eskit,
                                      @pr_kitItems,
                                      @pr_llevanroserie,
                                      @pr_lotefifo,
                                      @pr_ventastock,
                                      @stl_id
    
      while @@fetch_status = 0
      begin

        set @sti_cantidad = 0
  
        if @pr_llevastock <> 0 begin
  
          if @pr_eskit <> 0 begin
            set @cant_kits     = @fvi_cantidad
            set @fvi_cantidad  = @fvi_cantidad * @pr_kitItems

            select @sti_cantidad = sum(sti_ingreso) 
            from 
                  StockItem 
            where 
                  st_id            = @st_id
              and pr_id_kit         = @pr_id
              and IsNull(stl_id,0) = IsNull(@stl_id,0)

          end else begin

            set @fvi_cantidad = @fvi_cantidad * @pr_ventastock

            select @sti_cantidad = sum(sti_ingreso) 
            from 
                  StockItem 
            where 
                  st_id             = @st_id
              and pr_id             = @pr_id
              and (IsNull(stl_id,0) = IsNull(@stl_id,0) or @pr_lotefifo <> 0)
              and pr_id_kit is null

          end

          set @sti_cantidad = IsNull(@sti_cantidad,0)

          if abs(@sti_cantidad - @fvi_cantidad) > 0.01 begin

            exec sp_dbgetnewid 'AuditoriaItem', 'audi_id', @audi_id out,0
            if @@error <> 0 goto ControlError  

            if @pr_eskit <> 0 begin

              insert into AuditoriaItem (aud_id, audi_id, audi_descrip,audn_id,audg_id,doct_id,comp_id)
                                 values (@@aud_id, 
                                         @audi_id,
                                         'La factura indica ' + convert(varchar,convert(decimal(18,2),@cant_kits)) 
                                         + ' Kit "' + @pr_nombreventa + '" compuesto(s) en total por '
                                         + convert(varchar,convert(decimal(18,2),@fvi_cantidad)) + ' items'
                                         + ' y el movimiento de stock indica ' + convert(varchar,convert(decimal(18,2),@sti_cantidad))
                                         + ' (comp.:' + @fv_nrodoc + ' nro.: '+ @fv_numero + ')',
                                         3,
                                         1,
                                         @doct_id,
                                         @@fv_id
                                        )

            end else begin

              insert into AuditoriaItem (aud_id, audi_id, audi_descrip,audn_id,audg_id,doct_id,comp_id)
                                 values (@@aud_id, 
                                         @audi_id,
                                         'La factura indica ' + convert(varchar,convert(decimal(18,2),@fvi_cantidad))
                                         + ' "' + @pr_nombreventa + '" y el movimiento de stock indica '
                                         + convert(varchar,convert(decimal(18,2),@sti_cantidad))
                                         + ' (comp.:' + @fv_nrodoc + ' nro.: '+ @fv_numero + ')',
                                         3,
                                         1,
                                         @doct_id,
                                         @@fv_id
                                        )
            end
          end

          -- Ahora los numeros de serie de los que son kit
          --
          if @pr_llevanroserie <> 0 and @pr_eskit <> 0 begin

            delete #KitItems
            delete #KitItemsSerie

            exec sp_StockProductoGetKitInfo @pr_id, 0

            declare c_fv_itemKit insensitive cursor for

              select 
                      k.pr_id,
                      pr_nombrecompra,
                      cantidad 
              from 
                      #KitItemsSerie k inner join Producto p on k.pr_id = p.pr_id

              where pr_llevanroserie <> 0

            open c_fv_itemKit

            fetch next from c_fv_itemKit into @pr_id_item, @pr_item, @prns_cantidad

            while @@fetch_status=0
            begin

              set @prns_cantidad = @prns_cantidad * @cant_kits
              set @sti_cantidad  = 0

              select @sti_cantidad = sum(sti_ingreso) 
              from 
                    StockItem 
              where 
                    st_id            = @st_id
                and pr_id            = @pr_id_item
                and IsNull(stl_id,0) = IsNull(@stl_id,0)
                and pr_id_kit        = @pr_id

              set @sti_cantidad = IsNull(@sti_cantidad,0)
    
              if @sti_cantidad <> @prns_cantidad begin
    
                exec sp_dbgetnewid 'AuditoriaItem', 'audi_id', @audi_id out,0
                if @@error <> 0 goto ControlError  
    
                insert into AuditoriaItem (aud_id, audi_id, audi_descrip,audn_id,audg_id,doct_id,comp_id)
                                   values (@@aud_id, 
                                           @audi_id,
                                           'La factura indica que el Kit "' + @pr_nombreventa +
                                           + '" lleva ' + convert(varchar,convert(decimal(18,2),@prns_cantidad))
                                           + ' "' + @pr_item
                                           + '" y el movimiento de stock indica ' + convert(varchar,convert(decimal(18,2),@sti_cantidad))
                                           + ' (comp.:' + @fv_nrodoc + ' nro.: '+ @fv_numero + ')',
                                           3,
                                           1,
                                           @doct_id,
                                           @@fv_id
                                          )
              end

              fetch next from c_fv_itemKit into @pr_id_item, @pr_item, @prns_cantidad
            end

            close c_fv_itemKit

            deallocate c_fv_itemKit                  

          end
  
        end else begin
  
          if exists(select * from StockItem where st_id = @st_id and pr_id = @pr_id) begin
  
            exec sp_dbgetnewid 'AuditoriaItem', 'audi_id', @audi_id out,0
            if @@error <> 0 goto ControlError  

            insert into AuditoriaItem (aud_id, audi_id, audi_descrip,audn_id,audg_id,doct_id,comp_id)
                               values (@@aud_id, 
                                       @audi_id,
                                       'La factura indica el producto "' + @pr_nombreventa 
                                       + '" que no mueve stock pero esta incluido en el movimiento '
                                       + 'de stock asociado a esta factura '
                                       + '(comp.:' + @fv_nrodoc + ' nro.: '+ @fv_numero + ')',
                                       3,
                                       1,
                                       @doct_id,
                                       @@fv_id
                                      )
          end
  
        end
    
        fetch next from c_fv_item into 
                                        @fvi_cantidad,
                                        @pr_id,
                                        @pr_nombreventa,
                                        @pr_llevastock,
                                        @pr_eskit,
                                        @pr_kitItems,
                                        @pr_llevanroserie,
                                        @pr_lotefifo,
                                        @pr_ventastock,
                                        @stl_id
      end
    
      close c_fv_item
    
      deallocate c_fv_item


    --//////////////////////////////
    --
    -- Con numero de serie
    --
      declare c_fv_item insensitive cursor for
    
        select 
                fvi_id,
                fvi_cantidadaremitir,
                fvi.pr_id,
                pr_nombreventa,
                pr_eskit,
                pr_kitItems,
                pr_ventastock,
                stl_id
        from
              FacturaVentaItem fvi inner join Producto pr on fvi.pr_id = pr.pr_id
    
        where fv_id = @@fv_id and pr_llevanroserie <> 0 and pr_eskit = 0
    
      open c_fv_item
    
      fetch next from c_fv_item into 
                                      @fvi_id,
                                      @fvi_cantidad,
                                      @pr_id,
                                      @pr_nombreventa,
                                      @pr_eskit,
                                      @pr_kitItems,
                                      @pr_ventastock,
                                      @stl_id
    
      while @@fetch_status = 0
      begin

        set @sti_cantidad = 0
  
        select @sti_cantidad = sum(sti_ingreso) 
        from 
              StockItem 
        where 
              st_id            = @st_id
          and pr_id            = @pr_id
          and IsNull(stl_id,0) = IsNull(@stl_id,0)
          and sti_grupo        = @fvi_id
          and pr_id_kit is null

        set @sti_cantidad = IsNull(@sti_cantidad,0)

        if abs(@sti_cantidad - (@fvi_cantidad * @pr_ventastock)) > 0.01 begin

          exec sp_dbgetnewid 'AuditoriaItem', 'audi_id', @audi_id out,0
          if @@error <> 0 goto ControlError  

          insert into AuditoriaItem (aud_id, audi_id, audi_descrip,audn_id,audg_id,doct_id,comp_id)
                             values (@@aud_id, 
                                     @audi_id,
                                     'La factura indica ' + convert(varchar,convert(decimal(18,2),@fvi_cantidad))
                                     + ' "' + @pr_nombreventa + '" y el movimiento de stock indica '
                                     + convert(varchar,convert(decimal(18,2),@sti_cantidad))
                                     + ' (comp.:' + @fv_nrodoc + ' nro.: '+ @fv_numero + ')',
                                     3,
                                     1,
                                     @doct_id,
                                     @@fv_id
                                    )
        end

        fetch next from c_fv_item into 
                                        @fvi_id,
                                        @fvi_cantidad,
                                        @pr_id,
                                        @pr_nombreventa,
                                        @pr_eskit,
                                        @pr_kitItems,
                                        @pr_ventastock,
                                        @stl_id
      end
    
      close c_fv_item
    
      deallocate c_fv_item

  end

ControlError:

  drop table #KitItems
  drop table #KitItemsSerie

end
GO