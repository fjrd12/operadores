*&---------------------------------------------------------------------*
*& Report ZTR_CAJA_OPER_DATA
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZTR_CAJA_OPER_DATA.
tables: zes_coper_header.
DATA: it_coper_header TYPE TABLE OF zes_coper_header,
      it_coper_pos    TYPE TABLE OF ztr_coper_pos,
      iw_coper_pos    TYPE ztr_coper_pos,
      tabix           type sy-tabix.

select-OPTIONS: s_uuid for zes_coper_header-UUID.

start-OF-SELECTION.

  select * from ztr_coper_pos
    where
          uuid in @s_uuid and
          im_lifnr is not INITIAL
        into table @it_coper_pos.

  if sy-subrc = 0.

    loop at it_coper_pos into iw_coper_pos.
      tabix = sy-tabix.
      if tabix mod 2 = 0.
        iw_coper_pos-TIPO_CONCEPTO = 'g'.
        iw_coper_pos-im_kostl = '@g@'.
      else.
        iw_coper_pos-TIPO_CONCEPTO = 'n'.
        iw_coper_pos-im_kostl = '@n@'.
      endif.
      modify it_coper_pos from iw_coper_pos index tabix.
    endloop.

    modify ztr_coper_pos from TABLE it_coper_pos.
    commit WORK AND WAIT.

  endif.
