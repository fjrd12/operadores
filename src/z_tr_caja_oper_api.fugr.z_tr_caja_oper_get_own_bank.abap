FUNCTION Z_TR_CAJA_OPER_GET_OWN_BANK.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(BANCO) TYPE  ZTR_PAY_BANCOS
*"     REFERENCE(BUKRS) TYPE  BUKRS
*"     REFERENCE(PROCESS) TYPE  CHAR10
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
          BUKRS = BUKRS and
          PROCESS = PROCESS.

  if sy-subrc NE 0.
    raise NOT_FOUND.
  else.
    hbkid = ZCOOPER_BANK-hbkid.
    hktid = ZCOOPER_BANK-hktid.
  endif.

ENDFUNCTION.
