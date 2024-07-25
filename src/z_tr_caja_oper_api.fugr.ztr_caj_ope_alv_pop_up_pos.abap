FUNCTION ZTR_CAJ_OPE_ALV_POP_UP_POS.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(I_START_COLUMN) TYPE  I DEFAULT 25
*"     REFERENCE(I_START_LINE) TYPE  I DEFAULT 6
*"     REFERENCE(I_END_COLUMN) TYPE  I DEFAULT 100
*"     REFERENCE(I_END_LINE) TYPE  I DEFAULT 10
*"     REFERENCE(I_TITLE) TYPE  STRING DEFAULT 'ALV'
*"     REFERENCE(I_POPUP) TYPE  FLAG DEFAULT ''
*"  TABLES
*"      IT_ALV STRUCTURE  ZTR_COPER_POS
*"----------------------------------------------------------------------
  DATA go_alv TYPE REF TO cl_salv_table.
  DATA: lr_functions TYPE REF TO cl_salv_functions_list.
  DATA: lo_cols      TYPE REF TO cl_salv_columns.
* modify individual properties
  DATA: lo_column    TYPE REF TO cl_salv_column.

  if it_alv[] is NOT INITIAL.

    YTZTR_MESS_EVENT_REPORT = it_alv[].

    TRY.
        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = go_alv
          CHANGING
            t_table      = it_alv[] ).

      CATCH cx_salv_msg.
    ENDTRY.
  endif.

  lo_cols = go_alv->get_columns( ).

    TRY.
      lo_column = lo_cols->get_column( 'MANDT' ).
      lo_column->set_long_text( 'MANDT' ).                   "#EC NOTEXT
      lo_column->set_medium_text( 'MANDT' ).                 "#EC NOTEXT
      lo_column->set_short_text( 'MANDT' ).                  "#EC NOTEXT
      lo_column->set_output_length( 10 ).
      lo_column->SET_VISIBLE( '' ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lo_column = lo_cols->get_column( 'UUID' ).
      lo_column->set_long_text( 'UUID' ).                   "#EC NOTEXT
      lo_column->set_medium_text( 'UUID' ).                 "#EC NOTEXT
      lo_column->set_short_text( 'UUID' ).                  "#EC NOTEXT
      lo_column->set_output_length( 10 ).
*      lo_column->SET_VISIBLE( '' ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lo_column = lo_cols->get_column( 'IM_CONS' ).
      lo_column->set_long_text( 'Posición' ).                  "#EC NOTEXT
      lo_column->set_medium_text( 'Posición' ).                "#EC NOTEXT
      lo_column->set_short_text( 'Pos.' ).                 "#EC NOTEXT
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lo_column = lo_cols->get_column( 'IM_LIFNR' ).
      lo_column->set_long_text( 'Proveedor' ).                  "#EC NOTEXT
      lo_column->set_medium_text( 'Proveedor' ).                "#EC NOTEXT
      lo_column->set_short_text( 'Proveedor' ).                 "#EC NOTEXT
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.


  TRY.
      lo_column = lo_cols->get_column( 'IM_UMSKZ' ).
      lo_column->set_long_text( 'Ind.CME' ).              "#EC NOTEXT
      lo_column->set_medium_text( 'Ind.CME' ).            "#EC NOTEXT
      lo_column->set_short_text( 'Ind.CME' ).            "#EC NOTEXT}
*      lo_column->SET_VISIBLE( '' ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lo_column = lo_cols->get_column( 'IM_HKONT' ).
      lo_column->set_long_text( 'Cuenta de mayor' ).                  "#EC NOTEXT
      lo_column->set_medium_text( 'Libro mayor' ).                "#EC NOTEXT
      lo_column->set_short_text( 'LibrMay' ).                 "#EC NOTEXT
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lo_column = lo_cols->get_column( 'IM_WRBTR' ).
      lo_column->set_long_text( 'Importe en la moneda del documento' ).                   "#EC NOTEXT
      lo_column->set_medium_text( 'Imp. moneda docu' ).                 "#EC NOTEXT
      lo_column->set_short_text( 'I. Mon. D.' ).                "#EC NOTEXT
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.
  TRY.
      lo_column = lo_cols->get_column( 'IM_MWSKZ' ).
      lo_column->set_long_text( 'Indicador impuestos' ).                 "#EC NOTEXT
      lo_column->set_medium_text( 'Ind.impuestos' ).               "#EC NOTEXT
      lo_column->set_short_text( 'Ind.imp.' ).                "#EC NOTEXT
      lo_column->set_output_length( 10 ).
*      lo_column->SET_VISIBLE( '' ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lo_column = lo_cols->get_column( 'IM_WT_WITHCD' ).
      lo_column->set_long_text( 'Indicador de retención' ).                   "#EC NOTEXT
      lo_column->set_medium_text( 'Indicador ret.' ).                 "#EC NOTEXT
      lo_column->set_short_text( 'Ind.ret.' ).                  "#EC NOTEXT
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lo_column = lo_cols->get_column( 'IM_ZTERM' ).
      lo_column->set_long_text( 'Cond.pago' ).                "#EC NOTEXT
      lo_column->set_medium_text( 'Cond.pago' ).              "#EC NOTEXT
      lo_column->set_short_text( 'Cond.pago' ).               "#EC NOTEXT
      lo_column->set_output_length( 10 ).
*      lo_column->SET_VISIBLE( '' ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lo_column = lo_cols->get_column( 'IM_KOSTL' ).
      lo_column->set_long_text( 'Centro de coste' ).                    "#EC NOTEXT
      lo_column->set_medium_text( 'Centro coste' ).                  "#EC NOTEXT
      lo_column->set_short_text( 'Ce.coste' ).                   "#EC NOTEXT
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.
  TRY.
      lo_column = lo_cols->get_column( 'IM_ZLSCH' ).
      lo_column->set_long_text( 'Vía de pago' ).                   "#EC NOTEXT
      lo_column->set_medium_text( 'Vía pago' ).                 "#EC NOTEXT
      lo_column->set_short_text( 'Vía pago' ).                  "#EC NOTEXT
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lo_column = lo_cols->get_column( 'IM_ZUONR' ).
      lo_column->set_long_text( 'Asignación' ).                   "#EC NOTEXT
      lo_column->set_medium_text( 'Asignación' ).                 "#EC NOTEXT
      lo_column->set_short_text( 'Asign.' ).                  "#EC NOTEXT
*      lo_column->SET_VISIBLE( '' ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lo_column = lo_cols->get_column( 'IM_SGTXT' ).
      lo_column->set_long_text( 'Texto' ).                "#EC NOTEXT
      lo_column->set_medium_text( 'Texto' ).              "#EC NOTEXT
      lo_column->set_short_text( 'Texto' ).               "#EC NOTEXT
      lo_column->set_output_length( 400 ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lo_column = lo_cols->get_column( 'IM_PRCTR' ).
      lo_column->set_long_text( 'Centro de beneficio' ).                 "#EC NOTEXT
      lo_column->set_medium_text( 'CeBe' ).               "#EC NOTEXT
      lo_column->set_short_text( 'CeBe' ).                "#EC NOTEXT
      lo_column->set_output_length( 18 ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  lo_cols->set_optimize( 'X' ).
  lr_functions = go_alv->get_functions( ).
  lr_functions->set_all( 'X' ).
  go_alv->get_aggregations( )->add_aggregation( columnname = 'IM_WRBTR' ).
*  create OBJECT event_handler.
*  set handler event_handler->on_double_click for go_alv->get_event( ).

  IF go_alv IS BOUND.
    IF i_popup = 'X'.
      go_alv->set_screen_popup(
        start_column = i_start_column
        end_column  = i_end_column
        start_line  = i_start_line
        end_line    = i_end_line ).
    ENDIF.

    go_alv->display( ).

  ENDIF.

ENDFUNCTION.
