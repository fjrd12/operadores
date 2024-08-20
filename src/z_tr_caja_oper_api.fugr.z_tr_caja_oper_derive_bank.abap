FUNCTION Z_TR_CAJA_OPER_DERIVE_BANK.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(ZLSCH) TYPE  SCHZW_BSEG
*"  EXPORTING
*"     REFERENCE(BANK) TYPE  CHAR10
*"----------------------------------------------------------------------

  case zlsch.
    when '8'.
      BANK = 'SANTANDER'.
    when '9'.
      BANK = 'BANORTE'.
  endcase.

ENDFUNCTION.
