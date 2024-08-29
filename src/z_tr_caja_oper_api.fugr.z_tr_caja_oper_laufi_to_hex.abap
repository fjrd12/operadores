FUNCTION Z_TR_CAJA_OPER_LAUFI_TO_HEX.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(INCREMENT) TYPE  XFELD
*"  EXPORTING
*"     REFERENCE(HEXA) TYPE  STRING
*"  CHANGING
*"     REFERENCE(RANGO) TYPE  STRING
*"----------------------------------------------------------------------

  data: v_hexa(2) type x,
        longi     type sy-tabix,
        iter      type sy-tabix.

  longi = strlen( rango ).

  if longi < 4.
    iter = 4 - longi.
    do iter times.
      concatenate '0' rango into rango.
    enddo.
  endif.

  v_hexa = RANGO.

  if increment = 'X'.
    V_HEXA = V_HEXA + 1.
  endif.

  HEXA = V_HEXA.
  HEXA = HEXA+1(3).

ENDFUNCTION.
