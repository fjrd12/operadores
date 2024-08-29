FUNCTION Z_TR_CAJA_OPER_DERIVE_DATA.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(BLART) TYPE  BLART
*"     REFERENCE(BUKRS) TYPE  BUKRS
*"  EXPORTING
*"     REFERENCE(PYMT_METH) TYPE  ACPI_ZLSCH
*"     REFERENCE(REF_KEY_3) TYPE  XREF3
*"     REFERENCE(HBKID) TYPE  HBKID
*"     REFERENCE(HKTID) TYPE  HKTID
*"  TABLES
*"      TRETURN STRUCTURE  BAPIRET2
*"  CHANGING
*"     REFERENCE(ZFIES_IMITPOSITION) TYPE  ZFIES_IMITPOSITION
*"----------------------------------------------------------------------
  data: wreturn          type BAPIRET2,
        concepto         type FCC_FDNAME,
        tipo             type FCC_FDNAME,
        flag_lifnr       type xfeld,
        kostl_aux        type kostl,
        BANCO	           TYPE ZTR_PAY_BANCOS,
        ZTR_PAY_PROC     TYPE ZTR_PAY_PROC,
        ZTR_COPER_DOC_LY TYPE ZTR_COPER_DOC_LY,
        PROCESS          TYPE CHAR10.

  call FUNCTION 'Z_TR_CAJA_OPER_DERIVE_VIA'
    EXPORTING
      LIFNR             = ZFIES_IMITPOSITION-im_lifnr                 " Número de cuenta de proveedor o acreedor
    IMPORTING
      PYMT_METH         = PYMT_METH                " Vía de pago
    TABLES
      RETURN            = TRETURN                 " Parámetro de retorno
    EXCEPTIONS
      ACCOUNT_NOT_FOUND = 1                " account_not_found
      OTHERS            = 2.

  select single * from ZTR_COPER_DOC_LY
    into ZTR_COPER_DOC_LY
    where blart = blart.

  if ZTR_COPER_DOC_LY-xfeld = 'X'.
    CALL FUNCTION 'Z_TR_CAJA_OPER_DERIVE_KOSTL'
      EXPORTING
        KOSTL     = ZFIES_IMITPOSITION-im_kostl
      IMPORTING
        CONCEPTO  = concepto
        TIPO      = tipo
      EXCEPTIONS
        NOT_FOUND = 1
        OTHERS    = 2.

    if sy-subrc = 0.
      REF_KEY_3 = tipo.
    else.
*      clear REF_KEY_3.
*      clear wreturn.
*      wreturn-TYPE = 'E'.
*      wreturn-ID = 'ZTR_CAJA_OPER'.
*      wreturn-NUMBER = '011'.
*      wreturn-MESSAGE_V1 = ZFIES_IMITPOSITION-IM_CONS.
*      append wreturn to treturn.
      ZFIES_IMITPOSITION-im_kostl = '@g@'.
      REF_KEY_3 = 'g'.
      PROCESS = 'OPERN'.
    endif.


  else.

    case ZTR_COPER_DOC_LY-PROCESS.
      when 'OPERD'.
        tipo = 'g'.
        ZFIES_IMITPOSITION-im_kostl = '@g@'.
        PROCESS = ZTR_COPER_DOC_LY-PROCESS.
      when 'OPERN'.
        tipo = 'n'.
        ZFIES_IMITPOSITION-im_kostl = '@n@'.
        PROCESS = ZTR_COPER_DOC_LY-PROCESS.
      when OTHERS.
        tipo = 'g'.
        ZFIES_IMITPOSITION-im_kostl = '@g@'.
        PROCESS = ZTR_COPER_DOC_LY-PROCESS.
    endcase.
    REF_KEY_3 = tipo.

  endif.


  if tipo = 'g'.
    PROCESS = 'OPERD'.
    select single * from ZTR_PAY_PROC
      into ZTR_PAY_PROC
      where ZLSCH = PYMT_METH and
            PROCESS = 'OPERD'.
  endif.

  if tipo = 'n'.
    PROCESS = 'OPERN'.
    select SINGLE * from ZTR_PAY_PROC
      into ZTR_PAY_PROC
      where ZLSCH = PYMT_METH and
            PROCESS = 'OPERN'.
  endif.

  BANCO = ZTR_PAY_PROC-BANCO.

  CALL FUNCTION 'Z_TR_CAJA_OPER_GET_OWN_BANK'
    EXPORTING
      BANCO     = BANCO
      BUKRS     = bukrs
      PROCESS   = PROCESS
    IMPORTING
      HBKID     = hbkid
      HKTID     = hktid
    EXCEPTIONS
      NOT_FOUND = 1
      OTHERS    = 2.
  IF SY-SUBRC <> 0.
    clear wreturn.
    wreturn-TYPE = 'E'.
    wreturn-ID = 'ZTR_CAJA_OPER'.
    wreturn-NUMBER = '010'.
    wreturn-MESSAGE_V1 = BANCO.
    wreturn-MESSAGE_V2 = bukrs.
    append wreturn to treturn.
  ENDIF.


ENDFUNCTION.
