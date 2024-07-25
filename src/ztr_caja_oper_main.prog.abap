*&---------------------------------------------------------------------*
*& Include          ZTR_CAJA_OPER_MAIN
*&---------------------------------------------------------------------*


START-OF-SELECTION.

CREATE OBJECT obj_alv_oo.
  CALL METHOD obj_alv_oo->GET_DATA.
  CALL METHOD obj_alv_oo->SHOW_ALV.
  CALL SCREEN 0100.
