*&---------------------------------------------------------------------*
*& Include          ZTR_CAJA_OPER_F01
*&---------------------------------------------------------------------*

FORM check_registration.

  DATA: sum_importe TYPE ZFIED_WRBTR,
        tbseg       TYPE STANDARD TABLE OF bseg,
        wbseg       type bseg.

  LOOP AT it_coper_header ASSIGNING <fs_coper_header>.

    DATA: status TYPE c LENGTH 1.

    status = <fs_coper_header>-im_status.

    IF status EQ 'E'.
      <fs_coper_header>-status_icon = error.
    ELSEIF status EQ 'S'.
      <fs_coper_header>-status_icon = succesfull.
    ENDIF.

*   Definiendo iconos de los botones
    <fs_coper_header>-con_pos_icon = coper_pos_icon.
    <fs_coper_header>-retry_icon = coper_retry_icon.
    <fs_coper_header>-log_err_icon = log_icon.
    <fs_coper_header>-pay_prop_icon = ICON_VIEWER_OPTICAL_ARCHIVE.
    <fs_coper_header>-BANCA_OPER_ICON = v_doc_banca_oper.

    if <fs_coper_header>-IM_BELNR is INITIAL.
*   Definiendo sumatoria de las partidas
      SELECT * INTO TABLE it_coper_pos
        FROM ztr_coper_pos
        WHERE uuid EQ <fs_coper_header>-uuid.

      LOOP AT it_coper_pos INTO ls_coper_pos.
        IF ls_coper_pos-im_lifnr IS NOT INITIAL.
          sum_importe = sum_importe + ls_coper_pos-im_wrbtr.
        ENDIF.
      ENDLOOP.

      <fs_coper_header>-sum_im_wrbtr = sum_importe.
      CLEAR sum_importe.
    else.

      select * from bseg
        where bukrs = @<fs_coper_header>-im_bukrs and
              belnr = @<fs_coper_header>-im_belnr and
              GJAHR = @<fs_coper_header>-im_gjahr and
              lifnr is not INITIAL
        into TABLE @tbseg.

      loop at tbseg into wbseg.
        if wbseg-SHKZG = 'H'.
          sum_importe = sum_importe + wbseg-wrbtr.
        else.
          sum_importe = sum_importe - wbseg-wrbtr.
        endif.
      endloop.
      <fs_coper_header>-sum_im_wrbtr = sum_importe.
      CLEAR sum_importe.
    endif.

  ENDLOOP.

ENDFORM.

FORM assign_parent_uuid.

  DATA: ls_retry TYPE ztr_coper_retry.

  select * INTO TABLE it_coper_retry
    FROM ztr_coper_retry.

  LOOP AT it_coper_header ASSIGNING <fs_coper_header>.
    IF <fs_coper_header>-im_system EQ IM_SYSTEM.

      LOOP AT it_coper_retry INTO ls_retry.
        IF ls_retry-child_uuid EQ <fs_coper_header>-uuid.
          <fs_coper_header>-parent_uuid = ls_retry-parent_uuid.
        ENDIF.
      ENDLOOP.

    ENDIF.
  ENDLOOP.


endform.

FORM update_alv.
  IF obj_alv_grid IS BOUND.
    CLEAR it_coper_header.
    CREATE OBJECT obj_alv_oo.
    CALL METHOD obj_alv_oo->get_data.
    obj_alv_grid->refresh_table_display( ).
  ENDIF.
ENDFORM.
