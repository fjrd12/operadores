*&---------------------------------------------------------------------*
*& Report ZFI_PROPAG                                                   *
*&---------------------------------------------------------------------*
*& v0002 20230704 SE MODIFICA EL PROGRAMA PARA QUE FUNCIONE POR JOB Y  *
*& TRAIGA TODAS LAS CUENTAS QUE SE INCLUYEN EN LA TABLA DE             *
*& MTTO:zsociedad_tmsnew  MOD: OTHÓN DANIEL LÓPEZ PALACIOS             *
*&---------------------------------------------------------------------*
report zfi_propag_new_v2.

INCLUDE ZFI_PROPAG_TOP_NEW_V2.
INCLUDE ZFI_PROPAG_SEL_NEW_V2.
INCLUDE ZFI_PROPAG_F01_NEW_V2.

at SELECTION-SCREEN OUTPUT.
  data: ttvarvc type STANDARD TABLE OF tvarvc,
        wtvarvc type tvarvc.

  select * from tvarvc
    into table ttvarvc where name = 'Z_VIAS'.

  if sy-subrc ne 0.
    refresh s_via.
    clear s_via.
    s_via-sign = 'I'.
    s_via-option  = 'EQ'.
    s_via-low  = '9'.
    append s_via.
    s_via-sign = 'I'.
    s_via-option  = 'EQ'.
    s_via-low  = '8'.
    append s_via.
  else.
    refresh s_via.
    loop at ttvarvc into wtvarvc.
      clear s_via.
      s_via-sign = 'I'.
      s_via-option  = 'EQ'.
      s_via-low  = wtvarvc-low.
      append s_via.
    endloop.
  endif.

start-of-selection.

  CALL FUNCTION 'Z_TR_CAJA_OPER_BLOCK_PROCESS'
* EXPORTING
*   THRESHOLD       = 30
    .

  perform get_data.
  perform set_data.

  CALL FUNCTION 'Z_TR_CAJA_OPER_UNBLOCK_PROCESS'.
