FUNCTION-POOL Z_TR_CAJA_OPER_API.           "MESSAGE-ID ..

DATA: YTZTR_MESS_EVENT_REPORT type TABLE of ZTR_coper_pos,
      TZTR_COPER_PROP_LIST    type STANDARD TABLE OF ZTR_COPER_PROP_LIST.

FORM id  USING    p_laufi TYPE laufi
                  p_vg_laufi TYPE laufi.

  data: vg_laufi_aux(4) TYPE c.

  vg_laufi_aux = p_laufi+1(4) + 1.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = vg_laufi_aux
    IMPORTING
      output = vg_laufi_aux.
  CONCATENATE p_laufi(1) vg_laufi_aux INTO p_vg_laufi.

ENDFORM.
