FUNCTION Z_TR_CAJA_OPER_PROPOSAL_V2.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(ZLSCH) TYPE  SCHZW_BSEG
*"     REFERENCE(LAUFI) TYPE  LAUFI
*"     REFERENCE(BUKRS) TYPE  BUKRS
*"  EXPORTING
*"     REFERENCE(LAUFI_EX) TYPE  LAUFI
*"  TABLES
*"      VIAS_DE_PAGO STRUCTURE  RSPARAMS
*"      TIPO_CONCEPTO STRUCTURE  RSPARAMS
*"      PROVEEDORES STRUCTURE  RSPARAMS
*"  EXCEPTIONS
*"      NOT_PROVEEDORES
*"----------------------------------------------------------------------
  RANGES: rg_vonkk  FOR lfa1-lifnr,
          r_lfd     FOR reguh-laufd,
          r_lfi     FOR reguh-laufi.

  data: vg_laufi        type laufi,
        wrsparams       type rsparams,
        vg_namejob      TYPE btcjob,
        vg_a            TYPE c,
        wa_tbtco        type tbtco,
        laufd           type laufd,
        PAR_TEX1        TYPE F110V-TEXT1 VALUE 'BSEG-XREF3',
        PAR_LIS1        TYPE F110V-LIST1,
        PARAMETRO_COMMA TYPE STRING,
        time            type sy-tabix VALUE 1.

  CALL FUNCTION 'Z_TR_CAJA_OPER_MERGE_PARAMETER'
    IMPORTING
      PARAMETRO_COMMA = PARAMETRO_COMMA
    TABLES
      PARAMETROS      = TIPO_CONCEPTO
    EXCEPTIONS
      NO_CONTENT      = 1
      OTHERS          = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  else.
    par_lis1 = parametro_comma.
  ENDIF.


*Llena el rango de proveedores.
  if PROVEEDORES[] is INITIAL.
    raise NOT_PROVEEDORES.
  endif.
  clear rg_vonkk.
  loop at proveedores into wrsparams.
    rg_vonkk-sign = 'I'.
    rg_vonkk-option = 'EQ'.
    rg_vonkk-low = wrsparams-low.
    rg_vonkk-high =  ' '.
    append rg_vonkk.
  endloop.
*
*  "se suma 1 al inidcador de propuesta
*  PERFORM id USING  laufi vg_laufi.
  vg_laufi = laufi.

  SUBMIT rff110s
  WITH par_lfd      EQ sy-datum
  WITH par_lfid     EQ vg_laufi       "identificador
  WITH par_xvl      EQ 'X'            "Ej propuesta
  WITH par_buda     EQ sy-datum       "fe.contabilización
  WITH par_grda     EQ sy-datum       "Doc.creados hasta
  WITH sel_bukr-low EQ bukrs "sociedad
  WITH par_zwe      EQ ZLSCH         "via de pago
  WITH sel_kred-low IN rg_vonkk       "acreedor
  WITH par_xfa      EQ 'X'            "verificar vencimiento
  WITH par_xzw      EQ 'X'            "seleccionar via pago
  WITH par_xbl      EQ 'X'            "Indicador¿Requiere
  WITH par_prp1     EQ 'RFFOEDI1'     "Programa1  "Toma los programas que están ligados a la vía de pago
  WITH PAR_TEX1     EQ PAR_TEX1
  WITH PAR_LIS1     EQ PAR_LIS1
*        WITH par_prp2     EQ 'RFFOEDI1'     "Programa2  "Toma los programas que están ligados a la vía de pago
*        WITH par_prp3     EQ 'ZRFFOM100'    "Programa3  "Toma los programas que están ligados a la vía de pago
  AND RETURN.

  wait up to time seconds.

  IF sy-subrc EQ 0.
    CLEAR vg_namejob.
    CONCATENATE 'F110-' sy-datum '-' vg_laufi ' -X' INTO vg_namejob.

    CLEAR vg_a.
    WHILE vg_a IS INITIAL.
      SELECT SINGLE *
               FROM tbtco
               INTO  wa_tbtco
              WHERE jobname EQ vg_namejob
                AND ( status EQ 'A' OR status EQ 'F' ).

      IF sy-subrc EQ 0.
        vg_a = 'X'.
      ENDIF.
    ENDWHILE.

    SUBMIT rff110s
    WITH par_lfd      EQ sy-datum
    WITH par_lfid     EQ vg_laufi       "identificador
    WITH par_xvl      EQ ''            "Ej propuesta
    WITH par_buda     EQ sy-datum       "fe.contabilización
    WITH par_grda     EQ sy-datum       "Doc.creados hasta
    WITH sel_bukr-low EQ bukrs "sociedad
    WITH par_zwe      EQ ZLSCH         "via de pago
    WITH sel_kred-low IN rg_vonkk       "acreedor
    WITH par_xfa      EQ 'X'            "verificar vencimiento
    WITH par_xzw      EQ 'X'            "seleccionar via pago
    WITH par_xbl      EQ 'X'            "Indicador¿Requiere
*          WITH par_prp1     EQ 'RFFOAVIS'     "Programa1  "Toma los programas que están ligados a la vía de pago
    WITH par_prp2     EQ 'RFFOEDI1'     "Programa2  "Toma los programas que están ligados a la vía de pago
*          WITH par_prp3     EQ 'ZRFFOM100'    "Programa3  "Toma los programas que están ligados a la vía de pago
   WITH PAR_TEX1     EQ PAR_TEX1
   WITH PAR_LIS1     EQ PAR_LIS1
   AND RETURN.

    wait up to time seconds.

    IF sy-subrc EQ 0.
      CONCATENATE 'F110-' sy-datum '-' vg_laufi INTO vg_namejob.
      CLEAR vg_a.
      WHILE vg_a IS INITIAL.
        SELECT SINGLE *
                 FROM tbtco
                 INTO  wa_tbtco
                WHERE jobname EQ vg_namejob
                  AND ( status EQ 'A' OR status EQ 'F' ).

        IF sy-subrc EQ 0.
          vg_a = 'X'.
        ENDIF.
      ENDWHILE.

*      WRITE:/ bukrs , 'Propuestas creadas', vg_laufi.
      LAUFI_EX = vg_laufi.
      laufd = sy-datum.

      CALL FUNCTION 'Z_TR_CAJA_OPER_STORE_INDEX'
        EXPORTING
          LAUFD = laufd
          LAUFI = laufi_ex
          ZLSCH = ZLSCH
          BUKRS = bukrs.

      REFRESH: r_lfd,r_lfi.
      clear r_lfd.
      r_lfd-sign = 'I'.
      r_lfd-option = 'EQ'.
      r_lfd-low = sy-datum.
*      r_lfd-high =  sy-datum.
      append r_lfd.

      clear r_lfi.
      r_lfi-sign = 'I'.
      r_lfi-option = 'EQ'.
      r_lfi-low = laufi_ex.
      append r_lfi.

      wait up to time seconds.

      SUBMIT sapfpaym_merge
      WITH so_lfd   IN r_lfd
      WITH so_lfi   IN r_lfi      "identificador
      WITH so_rzawe-low      EQ ZLSCH         "via de pago
      AND RETURN.
    ENDIF.
  ENDIF.

ENDFUNCTION.
