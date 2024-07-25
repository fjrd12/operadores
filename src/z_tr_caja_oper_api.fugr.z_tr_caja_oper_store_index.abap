FUNCTION Z_TR_CAJA_OPER_STORE_INDEX.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(LAUFD) TYPE  LAUFD
*"     REFERENCE(LAUFI) TYPE  LAUFI
*"----------------------------------------------------------------------

  data: ZTR_COPER_PROP type ZTR_COPER_PROP.
  ZTR_COPER_PROP-LAUFD = LAUFD.
  ZTR_COPER_PROP-LAUFI = LAUFI.
  ZTR_COPER_PROP-DATUM = SY-DATUM.
  ZTR_COPER_PROP-UZEIT = SY-UZEIT.
  modify ZTR_COPER_PROP from ZTR_COPER_PROP.
  commit work AND WAIT.
ENDFUNCTION.
