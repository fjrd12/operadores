*&---------------------------------------------------------------------*
*& Include          ZTR_CAJA_OPER_CLS1
*&---------------------------------------------------------------------*

CLASS cls_alv_oo DEFINITION.

  PUBLIC SECTION.

    METHODS:
      get_data,
      show_alv,
      set_fieldcat.


  PRIVATE SECTION.

ENDCLASS.

CLASS cls_alv_oo IMPLEMENTATION.

  METHOD: get_data.
    IF p_lifnr IS NOT INITIAL.
      SELECT h~uuid, h~im_system, h~im_bldat, h~im_budat, h~im_bukrs,
       h~im_blart, h~im_waers, h~im_kursf, h~im_wwert, h~im_xblnr,
       h~im_bktxt, h~im_datum, h~im_user, h~im_uzeit, h~im_belnr,  h~im_gjahr, h~im_status
  INTO CORRESPONDING FIELDS OF TABLE @it_coper_header
  FROM ztr_coper_header AS h
  INNER JOIN ztr_coper_pos AS p ON h~uuid = p~uuid
  WHERE p~im_lifnr IN    @p_lifnr
      AND h~uuid      IN @p_uuid
      AND h~im_system IN @p_system
      AND h~im_bldat  IN @p_bldat
      AND h~im_budat  IN @p_budat
      AND h~im_bukrs  IN @p_bukrs
      AND h~im_blart  IN @p_blart
      AND h~im_wwert  IN @p_wwert
      AND h~im_bktxt  IN @p_bktxt
      AND h~im_datum  IN @p_datum
      AND h~im_user   IN @p_user
      AND h~im_belnr  IN @p_belnr
      AND h~im_status IN @p_status
      AND h~im_gjahr   IN @p_gjahr
    ORDER BY h~im_bukrs.

    ELSE.
      SELECT uuid im_system im_bldat im_budat im_bukrs im_blart im_waers
             im_kursf im_wwert im_xblnr im_bktxt im_datum
             im_user im_uzeit im_belnr im_gjahr im_status
        INTO CORRESPONDING FIELDS OF TABLE it_coper_header
        FROM ztr_coper_header
        WHERE uuid      IN p_uuid
        AND   im_system IN p_system
        AND im_bldat    IN p_bldat
        AND im_budat    IN p_budat
        AND im_bukrs    IN p_bukrs
        AND im_blart    IN p_blart
        AND im_wwert    IN p_wwert
        AND im_bktxt    IN p_bktxt
        AND im_datum    IN p_datum
        AND im_user     IN p_user
        AND im_belnr    IN p_belnr
        AND im_status   IN p_status
        AND im_gjahr   IN p_gjahr
        ORDER BY im_bukrs.


    ENDIF.

    PERFORM check_registration.
    PERFORM assign_parent_uuid.

  ENDMETHOD.


  METHOD: set_fieldcat.

    CLEAR it_fcat.
    it_fcat = VALUE #(
    BASE it_fcat
    ( fieldname   = 'UUID' scrtext_s   = TEXT-001 scrtext_m   = TEXT-001 scrtext_l   = TEXT-001 col_opt = abap_on key = abap_true emphasize = 'C510'  )
    ( fieldname   = 'IM_SYSTEM' scrtext_s   = TEXT-002 scrtext_m   = TEXT-003 scrtext_l   = TEXT-003 col_opt = abap_on emphasize = 'C110' )
    ( fieldname   = 'IM_BLDAT' scrtext_s = TEXT-004 scrtext_m   = TEXT-005 scrtext_l   = TEXT-005 )
    ( fieldname   = 'IM_BUDAT' scrtext_s   = TEXT-006 scrtext_m   = TEXT-007 scrtext_l   = TEXT-007 )
    ( fieldname   = 'IM_BUKRS' ref_table = 'ZES_COPER_HEADER' ref_field = 'IM_BUKRS' )
    ( fieldname   = 'IM_BLART' ref_table = 'ZES_COPER_HEADER' ref_field = 'IM_BLART' )
    ( fieldname   = 'SUM_IM_WRBTR' scrtext_s   = TEXT-024 scrtext_m   = TEXT-024 scrtext_l   = TEXT-024 )
    ( fieldname   = 'IM_WAERS' ref_table = 'ZES_COPER_HEADER' ref_field = 'IM_WAERS' )
    ( fieldname   = 'IM_KURSF' ref_table = 'ZES_COPER_HEADER' ref_field = 'IM_KURSF' )
    ( fieldname   = 'IM_WWERT' ref_table = 'ZES_COPER_HEADER' ref_field = 'IM_WWERT' )
    ( fieldname   = 'IM_XBLNR' ref_table = 'ZES_COPER_HEADER' ref_field = 'IM_XBLNR' )
    ( fieldname   = 'IM_BKTXT' ref_table = 'ZES_COPER_HEADER' ref_field = 'IM_BKTXT' )
    ( fieldname   = 'IM_DATUM' ref_table = 'ZES_COPER_HEADER' ref_field = 'IM_DATUM'  )
    ( fieldname   = 'IM_USER' ref_table = 'ZES_COPER_HEADER' ref_field = 'IM_USER'  )
    ( fieldname   = 'IM_UZEIT' ref_table = 'ZES_COPER_HEADER' ref_field = 'IM_UZEIT'  )
    ( fieldname   = 'IM_BELNR' ref_table = 'ZES_COPER_HEADER' ref_field = 'IM_BELNR' )
    ( fieldname   = 'IM_GJAHR' ref_table = 'ZES_COPER_HEADER' ref_field = 'IM_GJAHR' )
    ( fieldname   = 'STATUS_ICON' scrtext_s = TEXT-008 scrtext_m   = TEXT-008 scrtext_l   = TEXT-008 outputlen = 18 icon = 'X' )
    ( fieldname   = 'CON_POS_ICON' scrtext_s = TEXT-009 scrtext_m   = TEXT-010 scrtext_l   = TEXT-011 outputlen = 18 icon = 'X' )
    ( fieldname   = 'RETRY_ICON' scrtext_s = TEXT-013 scrtext_m   = TEXT-013 scrtext_l   = TEXT-013 outputlen = 18 icon = 'X' )
    ( fieldname   = 'LOG_ERR_ICON' scrtext_s = TEXT-017 scrtext_m   = TEXT-017 scrtext_l   = TEXT-017 outputlen = 18 icon = 'X' )
    ( fieldname   = 'PAY_PROP_ICON' scrtext_s = TEXT-019 scrtext_m   = TEXT-019 scrtext_l   = TEXT-019 outputlen = 18 icon = 'X' )
    ( fieldname   = 'BANCA_OPER_ICON' scrtext_s = TEXT-023 scrtext_m   = TEXT-023 scrtext_l   = TEXT-023 icon = 'X' )
    ( fieldname   = 'PARENT_UUID' scrtext_s = TEXT-018 scrtext_m   = TEXT-018 scrtext_l   = TEXT-018 outputlen = 18 )
    ).

  ENDMETHOD.

  METHOD: show_alv.
    DATA ls_layout2 TYPE lvc_s_layo.

    ls_layout2-sel_mode      = 'A'.
    ls_layout2-zebra         = 'X'.
    ls_layout2-cwidth_opt    = 'X'.

    IF vg_container IS NOT BOUND.

      CREATE OBJECT vg_container
        EXPORTING
          container_name              = 'CC_ALV'        " Name of the Screen CustCtrl Name to Link Container To
        EXCEPTIONS
          cntl_error                  = 1                " CNTL_ERROR
          cntl_system_error           = 2                " CNTL_SYSTEM_ERROR
          create_error                = 3                " CREATE_ERROR
          lifetime_error              = 4                " LIFETIME_ERROR
          lifetime_dynpro_dynpro_link = 5                " LIFETIME_DYNPRO_DYNPRO_LINK
          OTHERS                      = 6.               "#EC SUBRC_OK

*  CHECK vg_container IS BOUND.
*  CHECK obj_alv_grid IS INITIAL.

      CREATE OBJECT obj_alv_grid
        EXPORTING
          i_parent          = vg_container                 " Parent Container
        EXCEPTIONS
          error_cntl_create = 1                " Error when creating the control
          error_cntl_init   = 2                " Error While Initializing Control
          error_cntl_link   = 3                " Error While Linking Control
          error_dp_create   = 4                " Error While Creating DataProvider Control
          OTHERS            = 5.               "#EC SUBRC_OK

      CALL METHOD set_fieldcat.
      CREATE OBJECT obj_events.
      SET HANDLER obj_events->handle_double_click FOR obj_alv_grid.
      SET HANDLER obj_events->handle_user_command FOR obj_alv_grid.
      SET HANDLER obj_events->handle_toolbar FOR obj_alv_grid.

*  CHECK vg_container IS BOUND.

      CALL METHOD obj_alv_grid->set_table_for_first_display
        EXPORTING
          is_layout                     = ls_layout2      " Layout
          i_buffer_active               = 'X'
          i_bypassing_buffer            = 'X'
        CHANGING
          it_outtab                     = it_coper_header     " Output Table
          it_fieldcatalog               = it_fcat      " Field Catalog
        EXCEPTIONS
          invalid_parameter_combination = 1                " Wrong Parameter
          program_error                 = 2                " Program Errors
          too_many_lines                = 3                " Too many Rows in Ready for Input Grid
          OTHERS                        = 4.               "#EC SUBRC_OK
    ELSE.
      CALL METHOD obj_alv_grid->refresh_table_display.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
