FUNCTION Z_TR_CAJA_OPER_SCENARIO_ORIG.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(LAUFD) TYPE  LAUFD
*"     REFERENCE(LAUFI) TYPE  LAUFI
*"  EXPORTING
*"     REFERENCE(SCENARIO) TYPE  CHAR10
*"  EXCEPTIONS
*"      NOT_FOUND
*"----------------------------------------------------------------------

  data: reguhm         type reguhm,
        reguhm1        type reguhm,
        ZTR_COPER_PROP TYPE ZTR_COPER_PROP.

  select single * from ZTR_COPER_PROP
    into ZTR_COPER_PROP
    where LAUFD = LAUFD and
          LAUFI = LAUFI.

  if sy-subrc = 0.
    SCENARIO = 'OPERADORES'.
  else.
    SCENARIO = 'NO_CLASSIFIED'.
  endif.


ENDFUNCTION.
