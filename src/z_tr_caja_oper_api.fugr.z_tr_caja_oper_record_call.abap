FUNCTION Z_TR_CAJA_OPER_RECORD_CALL.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(ZFIES_PAYLIQADV) TYPE  ZFIES_PAYLIQADV
*"  EXPORTING
*"     REFERENCE(UUID) TYPE  CHAR128
*"  TABLES
*"      ZFIES_IMITPOSITION STRUCTURE  ZFIES_IMITPOSITION
*"      ZFIES_EX_IT_RETURN STRUCTURE  ZFIES_EX_IT_RETURN
*"  EXCEPTIONS
*"      ERROR_SAVING_DATA
*"----------------------------------------------------------------------
  data: WZTR_COPER_HEADER   type ZTR_COPER_HEADER,
        TZTR_COPER_POS      type STANDARD TABLE OF ZTR_COPER_POS,
        WZTR_COPER_POS      type ZTR_COPER_POS,
        WZFIES_IMITPOSITION type ZFIES_IMITPOSITION,
        WZFIES_EX_IT_RETURN	type ZFIES_EX_IT_RETURN,
        wbkpf               type bkpf,
        concepto            type FCC_FDNAME,
        tipo                type FCC_FDNAME.

  move-CORRESPONDING ZFIES_PAYLIQADV to WZTR_COPER_HEADER.
  UUID = WZTR_COPER_HEADER-UUID = cl_system_uuid=>if_system_uuid_rfc4122_static~create_uuid_c36_by_version( version = 4 ).
  WZTR_COPER_HEADER-IM_DATUM = sy-datum.
  WZTR_COPER_HEADER-IM_USER = sy-uname.
  WZTR_COPER_HEADER-IM_UZEIT = sy-uzeit.
  WZTR_COPER_HEADER-IM_GJAHR = sy-datum(4).

  loop at ZFIES_EX_IT_RETURN into WZFIES_EX_IT_RETURN where EX_BELNR is NOT INITIAL.

    select single * from bkpf INTO wbkpf
      where BUKRS = WZTR_COPER_HEADER-IM_BUKRS and
            BELNR = WZFIES_EX_IT_RETURN-EX_BELNR and
            GJAHR = WZTR_COPER_HEADER-IM_BUDAT+6(4).

    if sy-subrc = 0.
      WZTR_COPER_HEADER-IM_STATUS = 'S'.
      WZTR_COPER_HEADER-IM_BELNR = WZFIES_EX_IT_RETURN-EX_BELNR.
    else.
      WZTR_COPER_HEADER-IM_STATUS = 'E'.
    endif.

  endloop.

  if WZTR_COPER_HEADER-IM_STATUS is INITIAL.
    WZTR_COPER_HEADER-IM_STATUS = 'E'.
  endif.

  loop at ZFIES_IMITPOSITION into WZFIES_IMITPOSITION.
    move-CORRESPONDING WZFIES_IMITPOSITION to WZTR_COPER_POS.
    WZTR_COPER_POS-IM_SYSTEM = WZTR_COPER_HEADER-IM_SYSTEM.
    WZTR_COPER_POS-UUID = WZTR_COPER_HEADER-UUID.

    CALL FUNCTION 'Z_TR_CAJA_OPER_DERIVE_KOSTL'
      EXPORTING
        KOSTL     = WZFIES_IMITPOSITION-im_kostl
      IMPORTING
        CONCEPTO  = concepto
        TIPO      = tipo
      EXCEPTIONS
        NOT_FOUND = 1
        OTHERS    = 2.

    if sy-subrc = 0.
      WZTR_COPER_POS-tipo_concepto = tipo.
*      WZTR_COPER_POS-concepto = concepto.
    else.
      clear: WZTR_COPER_POS-TIPO_CONCEPTO.
*             WZTR_COPER_POS-concepto.
    endif.
    append WZTR_COPER_POS to TZTR_COPER_POS.
  endloop.

  if TZTR_COPER_POS is NOT INITIAL.

    modify ZTR_COPER_HEADER from WZTR_COPER_HEADER.
    modify ZTR_COPER_POS    from table TZTR_COPER_POS.
    if sy-subrc = 0.
      commit WORK and WAIT.
    else.
      ROLLBACK WORK.
      raise ERROR_SAVING_DATA.
    endif.
  endif.

ENDFUNCTION.
