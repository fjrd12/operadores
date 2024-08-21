FUNCTION Z_TR_CAJA_OPER_GET_OWN_BANK.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(BANCO) TYPE  ZTR_PAY_BANCOS
*"     REFERENCE(BUKRS) TYPE  BUKRS
*"  EXPORTING
*"     REFERENCE(HBKID) TYPE  HBKID
*"     REFERENCE(HKTID) TYPE  HKTID
*"  EXCEPTIONS
*"      NOT_FOUND
*"----------------------------------------------------------------------
  data: ZCOOPER_BANK type ZCOOPER_BANK.

  select single * from ZCOOPER_BANK
    into ZCOOPER_BANK
    where BANCO = BANCO and
          BUKRS = BUKRS.

  if sy-subrc NE 0.
    raise NOT_FOUND.
  endif.

ENDFUNCTION.
