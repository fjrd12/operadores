*&---------------------------------------------------------------------*
*& Include          ZTR_CAJA_OPER_F01
*&---------------------------------------------------------------------*

FORM check_registration.

  LOOP AT it_coper_header ASSIGNING <fs_coper_header>.

    DATA: status TYPE c LENGTH 1.

    status = <fs_coper_header>-im_status.

    IF status EQ 'E'.
      <fs_coper_header>-status_icon = error.
    ELSEIF status EQ 'S'.
      <fs_coper_header>-status_icon = succesfull.
    ENDIF.

    <fs_coper_header>-con_pos_icon = '@3J@'.
    <fs_coper_header>-retry_icon = '@2W@'.
    <fs_coper_header>-log_err_icon = '@RN@'.
    <fs_coper_header>-pay_prop_icon = '@Y5@'.
  ENDLOOP.

ENDFORM.

FORM assign_parent_uuid.

  CONSTANTS: IM_SYSTEM TYPE c LENGTH 10 VALUE '9999999999'.
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
