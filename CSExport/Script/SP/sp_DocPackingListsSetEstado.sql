if exists (select * from sysobjects where id = object_id(N'[dbo].[sp_DocPackingListsSetEstado]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_DocPackingListsSetEstado]

/*

 sp_DocPackingListsSetEstado 

*/

go
create procedure sp_DocPackingListsSetEstado (
  @@desde       datetime = '19900101',
  @@hasta       datetime = '21000101'
)
as

begin

  declare @pklst_id int

  declare c_Ventas insensitive cursor for 
    select pklst_id from PackingList where pklst_fecha between @@desde and @@hasta

  open c_Ventas

  fetch next from c_Ventas into @pklst_id
  while @@fetch_status = 0 begin

    exec sp_DocPackingListSetEstado @pklst_id

    fetch next from c_Ventas into @pklst_id
  end

  close c_Ventas
  deallocate c_Ventas
end