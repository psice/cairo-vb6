if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FEGetTipoCbte]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[FEGetTipoCbte]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


create function FEGetTipoCbte (

@@doct_id int,
@@fv_id   int

)

returns smallint

as
begin

/* Tabla AFIP

C�digo  Denominaci�n
001  FACTURAS A
002  NOTAS DE DEBITO A
003  NOTAS DE CREDITO A
004  RECIBOS A
005  NOTAS DE VENTA AL CONTADO A
006  FACTURAS B
007  NOTAS DE DEBITO B
008  NOTAS DE CREDITO B
009  RECIBOS B
010  NOTAS DE VENTA AL CONTADO B
011  FACTURAS C
012  NOTAS DE DEBITO C
013  NOTAS DE CREDITO C
014  DOCUMENTO ADUANERO
015  RECIBOS C
016  NOTAS DE VENTA AL CONTADO C
019  FACTURAS DE EXPORTACION
020  NOTAS DE DEBITO POR OPERACIONES CON EL EXTERIOR
021  NOTAS DE CREDITO POR OPERACIONES CON EL EXTERIOR
022  FACTURAS - PERMISO EXPORTACION SIMPLIFICADO - DTO. 855/97
030  COMPROBANTES DE COMPRA DE BIENES USADOS
031  MANDATO - CONSIGNACION
032  COMPROBANTES PARA RECICLAR MATERIALES
034  COMPROBANTES A DEL APARTADO A  INCISO F  R G  N  1415
035  COMPROBANTES B DEL ANEXO I, APARTADO A, INC. F), RG N� 1415
036  COMPROBANTES C DEL Anexo I, Apartado A, INC.F), R.G. N� 1415
037  NOTAS DE DEBITO O DOCUMENTO EQUIVALENTE QUE CUMPLAN CON LA R.G. N� 1415
038  NOTAS DE CREDITO O DOCMENTO EQUIVALENTE QUE CUMPLAN CON LA R.G. N� 1415
039  OTROS COMPROBANTES A QUE CUMPLEN CON LA R G  1415
040  OTROS COMPROBANTES B QUE CUMPLAN CON LA R.G. N� 1415
041  OTROS COMPROBANTES C QUE CUMPLAN CON LA R.G. N� 1415
050  RECIBO FACTURA A  REGIMEN DE FACTURA DE CREDITO 
051  FACTURAS M
052  NOTAS DE DEBITO M
053  NOTAS DE CREDITO M
054  RECIBOS M
055  NOTAS DE VENTA AL CONTADO M
056  COMPROBANTES M DEL ANEXO I  APARTADO A  INC F   R G  N  1415
057  OTROS COMPROBANTES M QUE CUMPLAN CON LA R G  N  1415
058  CUENTAS DE VENTA Y LIQUIDO PRODUCTO M
059  LIQUIDACIONES M
060  CUENTAS DE VENTA Y LIQUIDO PRODUCTO A
061  CUENTAS DE VENTA Y LIQUIDO PRODUCTO B
063  LIQUIDACIONES A
064  LIQUIDACIONES B
065  NOTAS DE CREDITO DE COMPROBANTES CON COD. 34, 39, 58, 59, 60, 63, 96, 97 
066  DESPACHO DE IMPORTACION
067  IMPORTACION DE SERVICIOS
068  LIQUIDACION C
070  RECIBOS FACTURA DE CREDITO
071  CREDITO FISCAL POR CONTRIBUCIONES PATRONALES
073  FORMULARIO 1116 RT
074  CARTA DE PORTE PARA EL TRANSPORTE AUTOMOTOR PARA GRANOS
075  CARTA DE PORTE PARA EL TRANSPORTE FERROVIARIO PARA GRANOS
077  
078  
079  
080  COMPROBANTE DIARIO DE CIERRE (ZETA)
081  TIQUE FACTURA A   CONTROLADORES FISCALES
082  TIQUE - FACTURA B
083  TIQUE
084  COMPROBANTE   FACTURA DE SERVICIOS PUBLICOS   INTERESES FINANCIEROS
085  NOTA DE CREDITO   SERVICIOS PUBLICOS   NOTA DE CREDITO CONTROLADORES FISCALES
086  NOTA DE DEBITO   SERVICIOS PUBLICOS
087  OTROS COMPROBANTES - SERVICIOS DEL EXTERIOR
088  OTROS COMPROBANTES - DOCUMENTOS EXCEPTUADOS / REMITO ELECTRONICO 
089  OTROS COMPROBANTES - DOCUMENTOS EXCEPTUADOS - NOTAS DE DEBITO / RESUMEN DE DATOS
090  OTROS COMPROBANTES - DOCUMENTOS EXCEPTUADOS - NOTAS DE CREDITO
091  REMITOS R
092  AJUSTES CONTABLES QUE INCREMENTAN EL DEBITO FISCAL
093  AJUSTES CONTABLES QUE DISMINUYEN EL DEBITO FISCAL
094  AJUSTES CONTABLES QUE INCREMENTAN EL CREDITO FISCAL
095  AJUSTES CONTABLES QUE DISMINUYEN EL CREDITO FISCAL
096  FORMULARIO 1116 B
097  FORMULARIO 1116 C
099  OTROS COMP  QUE NO CUMPLEN CON LA R G  3419 Y SUS MODIF 
101  AJUSTE ANUAL PROVENIENTE DE LA  D J  DEL IVA  POSITIVO 
102  AJUSTE ANUAL PROVENIENTE DE LA  D J  DEL IVA  NEGATIVO 
103  NOTA DE ASIGNACION
104  NOTA DE CREDITO DE ASIGNACION

*/

  declare @letra varchar(1)
  select @letra = substring(fv_nrodoc,1,1) from FacturaVenta where fv_id = @@fv_id

  return case   --fv
                when @@doct_id = 1 and @letra = 'A'  then 1 
                when @@doct_id = 1 and @letra = 'B'  then 6 
                when @@doct_id = 1 and @letra = 'C'  then 11 
                --nc
                when @@doct_id = 7 and @letra = 'A'  then 3 
                when @@doct_id = 7 and @letra = 'B'  then 8 
                when @@doct_id = 7 and @letra = 'C'  then 13 
                --nd
                when @@doct_id = 9 and @letra = 'A'  then 2 
                when @@doct_id = 9 and @letra = 'B'  then 7 
                when @@doct_id = 9 and @letra = 'C'  then 12 
         end  

end


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

