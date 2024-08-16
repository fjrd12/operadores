FUNCTION Z_TR_CAJA_OPER_SCENARIO.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(LAUFD) TYPE  LAUFD
*"     REFERENCE(LAUFI) TYPE  LAUFI
*"  EXPORTING
*"     REFERENCE(SCENARIO) TYPE  CHAR10
*"     REFERENCE(ORIG_LAUFD) TYPE  LAUFD
*"     REFERENCE(ORIG_LAUFI) TYPE  LAUFI
*"     REFERENCE(PROCESS) TYPE  CHAR10
*"----------------------------------------------------------------------

  data: reguhm         type reguhm,
        reguhm1        type reguhm,
        ZTR_COPER_PROP TYPE ZTR_COPER_PROP.

  select single * from reguhm
      into CORRESPONDING FIELDS OF REGUHM
      where LAUFD_M = LAUFD and
            LAUFI_M = LAUFI.

  if sy-subrc = 0.

    select single * from reguhm
        into CORRESPONDING FIELDS OF REGUHM1
        where LAUFD_M = REGUHM-LAUFD and
              LAUFI_M = REGUHM-LAUFI.

    if sy-subrc = 0.

      select single * from ZTR_COPER_PROP
        into ZTR_COPER_PROP
        where LAUFD = reguhm1-LAUFD and
              LAUFI = reguhm1-LAUFI.
      if sy-subrc = 0.
        SCENARIO = 'OPERADORES'.
        ORIG_LAUFD = reguhm1-LAUFD.
        ORIG_LAUFI = reguhm1-LAUFI.
        if reguhm1-LAUFI(1) = 'L'.
          PROCESS = 'OPERN'.
        endif.
        if reguhm1-LAUFI(1) = 'O'.
          PROCESS = 'OPERD'.
        endif.
      else.
        SCENARIO = 'NO_CLASSIFIED'.
      endif.
    else.
      SCENARIO = 'NO_CLASSIFIED'.
    endif.
  else.
    SCENARIO = 'NO_CLASSIFIED'.
  endif.


ENDFUNCTION.
