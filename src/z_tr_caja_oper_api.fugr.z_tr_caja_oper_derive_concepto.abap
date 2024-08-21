FUNCTION Z_TR_CAJA_OPER_DERIVE_CONCEPTO.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(DERIVAR_CONCEPTO) TYPE  STRING
*"  EXPORTING
*"     REFERENCE(CONCEPTO) TYPE  FCC_FDNAME
*"     REFERENCE(TIPO) TYPE  FCC_FDNAME
*"  EXCEPTIONS
*"      NOT_FOUND
*"----------------------------------------------------------------------

  data: patron type string.

  FIND all OCCURRENCES OF REGEX '@[gn]@' in DERIVAR_CONCEPTO IGNORING CASE
  RESULTS DATA(result_tab).
  if sy-subrc = 0.
    LOOP AT result_tab ASSIGNING FIELD-SYMBOL(<result>).
      patron = substring( val = DERIVAR_CONCEPTO off = <result>-offset len = <result>-length ).
      TIPO = patron+1(1).
*      TIPO = patron+6(1).
    endloop.
  else.
    raise not_found.
  endif.

ENDFUNCTION.
