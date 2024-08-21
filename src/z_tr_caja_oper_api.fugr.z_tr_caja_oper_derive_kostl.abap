FUNCTION Z_TR_CAJA_OPER_DERIVE_KOSTL.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(KOSTL) TYPE  KOSTL
*"  EXPORTING
*"     REFERENCE(CONCEPTO) TYPE  FCC_FDNAME
*"     REFERENCE(TIPO) TYPE  FCC_FDNAME
*"  EXCEPTIONS
*"      NOT_FOUND
*"----------------------------------------------------------------------
  DATA: DERIVAR type string.
  DERIVAR = kostl.
  CALL FUNCTION 'Z_TR_CAJA_OPER_DERIVE_CONCEPTO'
    EXPORTING
      DERIVAR_CONCEPTO = derivar
    IMPORTING
      CONCEPTO         = concepto
      TIPO             = tipo
    EXCEPTIONS
      NOT_FOUND        = 1
      OTHERS           = 2.
  IF SY-SUBRC <> 0.
    raise not_found.
  ENDIF.

ENDFUNCTION.
