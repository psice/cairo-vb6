if exists (select * from sysobjects where id = object_id(N'[dbo].[sp_DocOrdenPagosSetEstado]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_DocOrdenPagosSetEstado]

/*

 sp_DocOrdenPagosSetEstado 

*/

go
create procedure sp_DocOrdenPagosSetEstado (
  @@desde       datetime = '19900101',
  @@hasta       datetime = '21000101'
)
as

begin

  declare @opg_id int

  declare c_OrdenPagos insensitive cursor for 
    select opg_id from OrdenPago where opg_fecha between @@desde and @@hasta

  open c_OrdenPagos

  fetch next from c_OrdenPagos into @opg_id
  while @@fetch_status = 0 begin

    exec  sp_DocOrdenPagoSetEstado @opg_id

    fetch next from c_OrdenPagos into @opg_id
  end

  close c_OrdenPagos
  deallocate c_OrdenPagos
end