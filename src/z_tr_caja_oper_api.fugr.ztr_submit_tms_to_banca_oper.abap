FUNCTION ztr_submit_tms_to_banca_oper.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(BUKRS) TYPE  BUKRS
*"     REFERENCE(GJAHR) TYPE  GJAHR
*"  TABLES
*"      TMS_TO_PAY STRUCTURE  ZESTMS_TO_PAY
*"----------------------------------------------------------------------

  DATA: it_sels     TYPE TABLE OF rsparams,
        ls_sels     TYPE rsparams,
        lstms_pay   TYPE zestms_to_pay,
        ls_pay_ctrl TYPE ztrpay_ctrl,
        xvblnr      TYPE vblnr.

  LOOP AT tms_to_pay INTO lstms_pay.

    SELECT SINGLE belnr FROM bkpf
      INTO xvblnr
      WHERE bukrs EQ bukrs
      AND   belnr EQ lstms_pay-vblnr
      AND   gjahr EQ gjahr
      AND   stblg EQ ''.

    IF xvblnr IS NOT INITIAL.
      SELECT SINGLE * FROM ztrpay_ctrl
     INTO ls_pay_ctrl
     WHERE laufd EQ lstms_pay-laufd
     AND laufi EQ lstms_pay-laufi.

      IF ls_pay_ctrl IS NOT INITIAL.
        CLEAR ls_sels.
        ls_sels-selname = 'S_LAUFD'.
        ls_sels-kind = 'S'.
        ls_sels-sign = 'I'.
        ls_sels-option = 'EQ'.
        ls_sels-low = lstms_pay-laufd.
        APPEND ls_sels TO it_sels.

        CLEAR ls_sels.
        ls_sels-selname = 'S_LAUFI'.
        ls_sels-kind = 'S'.
        ls_sels-sign = 'I'.
        ls_sels-option = 'EQ'.
        ls_sels-low = lstms_pay-laufi.
        APPEND ls_sels TO it_sels.
      ENDIF.
    ENDIF.

  ENDLOOP.

  CLEAR ls_sels.
  ls_sels-selname = 'S_BUKRS'.
  ls_sels-kind = 'P'.
  ls_sels-sign = 'I'.
  ls_sels-option = 'EQ'.
  ls_sels-low = bukrs.
  APPEND ls_sels TO it_sels.

  CLEAR ls_sels.
  ls_sels-selname = 'S_BANKN'.
  ls_sels-kind = 'S'.
  ls_sels-sign = 'I'.
  ls_sels-option = 'EQ'.
  ls_sels-low = '4062199542'.
  APPEND ls_sels TO it_sels.


  CLEAR ls_sels.
  READ TABLE it_sels INTO ls_sels WITH KEY selname = 'S_LAUFD'.
  IF sy-subrc = 0.
    SUBMIT z_tr_moni_banca
    WITH SELECTION-TABLE it_sels
    AND RETURN.
  ELSE.
    MESSAGE s398(00) WITH TEXT-001 DISPLAY LIKE 'E'.
  ENDIF.

ENDFUNCTION.
