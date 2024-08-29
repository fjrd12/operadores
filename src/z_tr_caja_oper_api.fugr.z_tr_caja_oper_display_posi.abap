FUNCTION Z_TR_CAJA_OPER_DISPLAY_POSI.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(UUID) TYPE  CHAR128
*"----------------------------------------------------------------------

DATA: it_coper_pos TYPE TABLE OF ztr_coper_pos.

  SELECT * INTO TABLE it_coper_pos
    FROM ztr_coper_pos
    WHERE uuid EQ uuid.

    LOOP AT it_coper_pos INTO DATA(ls_coper_pos).
  IF ls_coper_pos-im_kostl(1) EQ '@'.
    CLEAR ls_coper_pos-im_kostl.
    MODIFY it_coper_pos FROM ls_coper_pos.
  ENDIF.
ENDLOOP.

  CALL FUNCTION 'ZTR_CAJ_OPE_ALV_POP_UP_POS'
*         EXPORTING
*           I_START_COLUMN       = 25
*           I_START_LINE         = 6
*           I_END_COLUMN         = 100
*           I_END_LINE           = 10
*           I_TITLE              = 'ALV'
*           I_POPUP              = ''
    TABLES
      it_alv = it_coper_pos.







ENDFUNCTION.
