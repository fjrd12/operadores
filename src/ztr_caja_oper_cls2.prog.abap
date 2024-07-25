*&---------------------------------------------------------------------*
*& Include          ZTR_CAJA_OPER_CLS2
*&---------------------------------------------------------------------*

CLASS cls_events DEFINITION.
  PUBLIC SECTION.
    METHODS:
      handle_toolbar
                  FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object e_interactive,
      handle_user_command
                  FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm,
      handle_double_click
                  FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING e_row
                  e_column
                  es_row_no.
ENDCLASS.

CLASS cls_events IMPLEMENTATION.

  METHOD handle_toolbar.
    DATA: ls_toolbar  TYPE stb_button.

* append a separator to normal toolbar
    CLEAR ls_toolbar.
    MOVE 3 TO ls_toolbar-butn_type.
    APPEND ls_toolbar TO e_object->mt_toolbar.


    CLEAR ls_toolbar.
    MOVE 'ACTUALIZAR' TO ls_toolbar-function.
    MOVE icon_report TO ls_toolbar-icon.
*    MOVE 'Show Bookings'(111) TO ls_toolbar-quickinfo.
    MOVE TEXT-020 TO ls_toolbar-text.
    MOVE '' TO ls_toolbar-disabled.
    APPEND ls_toolbar TO e_object->mt_toolbar.

  ENDMETHOD.

  METHOD handle_user_command.
    IF sy-subrc NE 0.
      CALL FUNCTION 'POPUP_TO_INFORM'
        EXPORTING
          titel = g_repid
          txt2  = sy-subrc
          txt1  = 'Error in Flush'(500).
    ELSE.
      CASE e_ucomm.
        WHEN 'ACTUALIZAR'.
          PERFORM update_alv.
      ENDCASE.
    ENDIF.
  ENDMETHOD.                           "handle_user_command

  METHOD handle_double_click.
    READ TABLE it_coper_header ASSIGNING <fs_coper_header> INDEX e_row-index.
    CASE e_column-fieldname.
      WHEN 'IM_BELNR'.
        DATA: v_gjahr TYPE gjahr.
        v_gjahr = <fs_coper_header>-im_budat+6(4).
        CALL FUNCTION 'Z_TR_CAJA_OPER_CALL_TRAN'
          EXPORTING
            belnr = <fs_coper_header>-im_belnr
            bukrs = <fs_coper_header>-im_bukrs
            gjahr = v_gjahr.

      WHEN 'CON_POS_ICON'.
        CALL FUNCTION 'Z_TR_CAJA_OPER_DISPLAY_POSI'
          EXPORTING
            uuid = <fs_coper_header>-uuid.

      WHEN 'RETRY_ICON'.

        CALL FUNCTION 'Z_TR_CAJA_OPER_CREATE_RETRY'
          EXPORTING
            ts_coper_header = <fs_coper_header>
          TABLES
            ext_return      = it_bapiret2.


        PERFORM update_alv.
        cl_rmsl_message=>display( it_bapiret2 ).

      WHEN 'LOG_ERR_ICON'.
        CALL FUNCTION 'Z_TR_CAJA_OPER_DISPLAY_LOG'
          EXPORTING
            uuid          = <fs_coper_header>-uuid
          EXCEPTIONS
            log_not_found = 1
            OTHERS        = 2.
        IF sy-subrc <> 0.
*         Implement suitable error handling here
        ENDIF.

      WHEN 'PAY_PROP_ICON'.
        MESSAGE: 'Propuesta de pago' TYPE 'I'.
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.

ENDCLASS.
