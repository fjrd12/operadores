*&---------------------------------------------------------------------*
*& Include          ZFI_PROPAG_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
FORM get_data .

  DATA: lv_reguh_l LIKE LINE OF gt_reguh_l,
        lv_reguh_o LIKE LINE OF gt_reguh_o,
        SY_SUBRC   LIKE SY-SUBRC.

  CLEAR: lv_reguh_l, lv_reguh_o.

  "obtenemos la sociedad para crear propuesta de pago
*  INI DVBP 10.06.2022
*  CLEAR gt_socact.
*  SELECT  *
*    INTO TABLE gt_socact
*    FROM zsociedad_tmsnew
*     WHERE bukrs EQ p_bukrs
*       AND dispsap EQ 'X'.

* Se buscan todas las sociedades activadas en zsociedad_tmsnew
* para el caso de correr por Job
* 20230704 OPALACIOS V0002

  IF SY-BATCH EQ 'X'."V0002
    CLEAR gwa_socact.
    SELECT *
      INTO TABLE gt_socact
      FROM zsociedad_tmsnew
      WHERE dispsap EQ 'X'.
    SY_SUBRC = SY-SUBRC. "GUARDANDO SY-SUBRC V0002

  ELSE.  "CASO QUE SE EJECUTE EN DIALOGO V0002
    CLEAR gwa_socact.
    SELECT  SINGLE *
      INTO gwa_socact
      FROM zsociedad_tmsnew
       WHERE bukrs EQ p_bukrs
         AND dispsap EQ 'X'.
    SY_SUBRC = SY-SUBRC. "GUARDANDO SY-SUBRC V0002
  ENDIF.
  SY-SUBRC = SY_SUBRC.
  "FIN V0002

*FIN DVBP 10.06.2022
  IF sy-subrc EQ 0.
    CLEAR gt_soc.
    SELECT *
      INTO TABLE gt_soc
      FROM zfitt_propag
      WHERE bukrs EQ p_bukrs.

    IF sy-subrc = 0.
      " se recuepera indicadores de propuesta del dia
      CLEAR: gt_reguh_l.
*      SELECT laufd laufi zbukr
*        INTO TABLE gt_reguh_l
*        FROM reguh
*        WHERE laufd EQ sy-datum
*
*          AND laufi LIKE 'L%'
**        INI DVBP 10.06.2022
*        AND zbukr EQ  p_bukrs.
      SELECT laufd laufi bukrs
      INTO TABLE gt_reguh_l
      FROM ZTR_COPER_PROP
      WHERE laufd EQ sy-datum
        AND laufi LIKE 'L%'
        AND bukrs EQ  p_bukrs.

*        FIN DVBP 10.06.2022
      "Indica que es la primera propuesta de pago de liquidación operadores
      IF sy-subrc NE 0.
        lv_reguh_l-laufd = sy-datum.
*        INI  DVBP 10.06.2022
*        lv_reguh_l-laufi = 'L0000'.

        CONCATENATE 'L'
        gwa_socact-rango
        INTO  lv_reguh_l-laufi.
*        FIN DVBP 10.06.2022
        INSERT lv_reguh_l INTO TABLE gt_reguh_l.
      ENDIF.

*      if sy-subrc = 0.
*        clear: gt_reguh_o.
*        select laufd laufi zbukr
*          into table gt_reguh_o
*          from reguh
*          where laufd eq sy-datum
*            and laufi like 'O%'.
*
*        "Indica que es la primera propuesta de pago de anticipos operadores
*        if sy-subrc ne 0.
*          lv_reguh_o-laufd = sy-datum.
*          lv_reguh_o-laufi = 'O0000'.
**          lv_reguh_o-zbukr = p_bukrs.
*          insert lv_reguh_o into table gt_reguh_o.
*        endif.
*      else.
*        write / 'No se encontraron datos en tabla ZFIITT_PROPAG'  .
*      endif.
    ELSE.
      WRITE / 'No se encontraron datos en tabla ZFIITT_PROPAG'  .
    ENDIF.
  ELSE.
    WRITE / 'No se encontraron datos en tabla ZFIITT_PROPAG'  .
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form SET_DATA
*&---------------------------------------------------------------------*
FORM set_data .
  DATA: lv_reguh_l LIKE LINE OF gt_reguh_l,
        lv_reguh_o LIKE LINE OF gt_reguh_o.
  DATA: vl_zwe TYPE zweln.

  DATA: ZLSCH             TYPE  SCHZW_BSEG,
        LAUFI             TYPE  LAUFI,
        BUKRS             TYPE  BUKRS,
        TVIAS_DE_PAGO     TYPE STANDARD TABLE OF  RSPARAMS,
        WVIAS_DE_PAGO	    TYPE RSPARAMS,
        TTIPOS_DOCUMENTOS TYPE STANDARD TABLE OF  RSPARAMS,
        WTIPOS_DOCUMENTOS	TYPE RSPARAMS,
        TPROVEEDORES      TYPE STANDARD TABLE OF  RSPARAMS,
        WPROVEEDORES      TYPE RSPARAMS.

  RANGES: r_lfd FOR reguh-laufd,
   r_lfi FOR reguh-laufi.
  "si la tabla de sociedades a tratar es initial no procesa nada
  CHECK gt_soc IS NOT INITIAL.
  "recorremos la rabla de sociedades para generar propuestas.
  LOOP AT gt_soc ASSIGNING FIELD-SYMBOL(<fs_soc>).
    PERFORM rango_acreedor USING <fs_soc>-bukrs.

    DO 2 TIMES.
      CLEAR: gt_reguh_aux, vg_laufi.
      IF sy-index EQ 1.
        gt_reguh_aux[] = gt_reguh_l[].
        vl_zwe = <fs_soc>-zweln.
      ELSE.
        CLEAR: gt_reguh_o.
*        SELECT laufd laufi zbukr
*          INTO TABLE gt_reguh_o
*          FROM reguh
*          WHERE laufd EQ sy-datum
*            AND laufi LIKE 'O%'
**          *        INI DVBP 10.06.2022
*        AND zbukr EQ  p_bukrs.


        SELECT laufd laufi bukrs
          INTO TABLE gt_reguh_o
          FROM ZTR_COPER_PROP
          WHERE laufd EQ sy-datum
            AND laufi LIKE 'O%'
            AND bukrs EQ  p_bukrs.

*        FIN DVBP 10.06.2022

        "Indica que es la primera propuesta de pago de liquidación operadores
        IF sy-subrc NE 0.
          lv_reguh_o-laufd = sy-datum.

*          *        INI  DVBP 10.06.2022
*          lv_reguh_o-laufi = 'O0000'.
          CONCATENATE 'O'
          gwa_socact-rango
          INTO  lv_reguh_o-laufi.
*        FIN DVBP 10.06.2022
          INSERT lv_reguh_o INTO TABLE gt_reguh_o.
        ENDIF.
        gt_reguh_aux[] = gt_reguh_o[].
        vl_zwe = <fs_soc>-zwelo.
      ENDIF.
      "Nos quedamos con el valor de propuesta mas alto
      SORT gt_reguh_aux BY  laufd laufi DESCENDING.
      READ TABLE gt_reguh_aux ASSIGNING FIELD-SYMBOL(<fs_reguh>) INDEX 1.
      IF sy-subrc EQ 0.

        IF rg_vonkk IS NOT INITIAL.

          loop at s_via.
            if vg_laufi is NOT initial.
              <fs_reguh>-laufi = vg_laufi.
            endif.
            PERFORM id USING  <fs_reguh>-laufi vg_laufi.
            LAUFI = vg_laufi.
            clear: TVIAS_DE_PAGO, TTIPOS_DOCUMENTOS, TPROVEEDORES.
            ZLSCH = s_via-low.
            WVIAS_DE_PAGO-SELNAME = 'VIAS_DE_PAGO'.
            WVIAS_DE_PAGO-KIND = 'S'.
            WVIAS_DE_PAGO-SIGN = 'I'.
            WVIAS_DE_PAGO-OPTION = 'EQ'.
            WVIAS_DE_PAGO-LOW = s_via-low.
            APPEND WVIAS_DE_PAGO TO TVIAS_DE_PAGO.

            IF LAUFI(1) = 'L'.
              WTIPOS_DOCUMENTOS-SELNAME = 'TDOCUMENTO'.
              WTIPOS_DOCUMENTOS-KIND = 'S'.
              WTIPOS_DOCUMENTOS-SIGN = 'I'.
              WTIPOS_DOCUMENTOS-OPTION = 'EQ'.
              WTIPOS_DOCUMENTOS-LOW = 'KL'.
              APPEND WTIPOS_DOCUMENTOS TO TTIPOS_DOCUMENTOS.
              WTIPOS_DOCUMENTOS-LOW = 'LP'.
              APPEND WTIPOS_DOCUMENTOS TO TTIPOS_DOCUMENTOS.
              WTIPOS_DOCUMENTOS-LOW = 'LT'.
              APPEND WTIPOS_DOCUMENTOS TO TTIPOS_DOCUMENTOS.
              WTIPOS_DOCUMENTOS-LOW = 'LQ'.
              APPEND WTIPOS_DOCUMENTOS TO TTIPOS_DOCUMENTOS.
            ENDIF.

            IF LAUFI(1) = 'O'.
              WTIPOS_DOCUMENTOS-SELNAME = 'TDOCUMENTO'.
              WTIPOS_DOCUMENTOS-KIND = 'S'.
              WTIPOS_DOCUMENTOS-SIGN = 'I'.
              WTIPOS_DOCUMENTOS-OPTION = 'EQ'.
              WTIPOS_DOCUMENTOS-LOW = 'KT'.
              APPEND WTIPOS_DOCUMENTOS TO TTIPOS_DOCUMENTOS.
              WTIPOS_DOCUMENTOS-LOW = 'KV'.
              APPEND WTIPOS_DOCUMENTOS TO TTIPOS_DOCUMENTOS.
            ENDIF.

            LOOP AT rg_vonkk.
              WPROVEEDORES-SELNAME = 'PROVEEDORES'.
              WPROVEEDORES-KIND = 'S'.
              WPROVEEDORES-SIGN = 'I'.
              WPROVEEDORES-OPTION = 'EQ'.
              WPROVEEDORES-LOW = rg_vonkk-low.
              APPEND WPROVEEDORES TO TPROVEEDORES.
            ENDLOOP.

            BUKRS = <fs_soc>-bukrs.

            CALL FUNCTION 'Z_TR_CAJA_OPER_PROPOSAL'
              EXPORTING
                ZLSCH            = ZLSCH
                LAUFI            = LAUFI
                BUKRS            = BUKRS
              IMPORTING
                LAUFI_EX         = vg_laufi
              TABLES
                VIAS_DE_PAGO     = TVIAS_DE_PAGO
                TIPOS_DOCUMENTOS = TTIPOS_DOCUMENTOS
                PROVEEDORES      = TPROVEEDORES
              EXCEPTIONS
                NOT_PROVEEDORES  = 1
                OTHERS           = 2.
            IF SY-SUBRC <> 0.
* Implement suitable error handling here
            else.
              WRITE:/ bukrs , 'Propuestas creadas', vg_laufi.
            ENDIF.

          endloop.

        ENDIF.
*        IF rg_vonkk IS NOT INITIAL.
*          "se suma 1 al inidcador de propuesta
*          PERFORM id USING  <fs_reguh>-laufi vg_laufi.
*
*          SUBMIT rff110s
*          WITH par_lfd      EQ sy-datum
*          WITH par_lfid     EQ vg_laufi       "identificador
*          WITH par_xvl      EQ 'X'            "Ej propuesta
*          WITH par_buda     EQ sy-datum       "fe.contabilización
*          WITH par_grda     EQ sy-datum       "Doc.creados hasta
*          WITH sel_bukr-low EQ <fs_soc>-bukrs "sociedad
*          WITH par_zwe      EQ vl_zwe         "via de pago
*          WITH sel_kred-low IN rg_vonkk       "acreedor
*          WITH par_xfa      EQ 'X'            "verificar vencimiento
*          WITH par_xzw      EQ 'X'            "seleccionar via pago
*          WITH par_xbl      EQ 'X'            "Indicador¿Requiere
*          WITH par_prp1     EQ 'RFFOEDI1'     "Programa1  "Toma los programas que están ligados a la vía de pago
**        WITH par_prp2     EQ 'RFFOEDI1'     "Programa2  "Toma los programas que están ligados a la vía de pago
**        WITH par_prp3     EQ 'ZRFFOM100'    "Programa3  "Toma los programas que están ligados a la vía de pago
*          AND RETURN.
*
*          IF sy-subrc EQ 0.
*            CLEAR vg_namejob.
*            CONCATENATE 'F110-' sy-datum '-' vg_laufi ' -X' INTO vg_namejob.
*
*            CLEAR vg_a.
*            WHILE vg_a IS INITIAL.
*              SELECT SINGLE *
*                       FROM tbtco
*                       INTO  wa_tbtco
*                      WHERE jobname EQ vg_namejob
*                        AND ( status EQ 'A' OR status EQ 'F' ).
*
*              IF sy-subrc EQ 0.
*                vg_a = 'X'.
*              ENDIF.
*            ENDWHILE.
*
*            SUBMIT rff110s
*            WITH par_lfd      EQ sy-datum
*            WITH par_lfid     EQ vg_laufi       "identificador
*            WITH par_xvl      EQ ''            "Ej propuesta
*            WITH par_buda     EQ sy-datum       "fe.contabilización
*            WITH par_grda     EQ sy-datum       "Doc.creados hasta
*            WITH sel_bukr-low EQ <fs_soc>-bukrs "sociedad
*            WITH par_zwe      EQ vl_zwe         "via de pago
*            WITH sel_kred-low IN rg_vonkk       "acreedor
*            WITH par_xfa      EQ 'X'            "verificar vencimiento
*            WITH par_xzw      EQ 'X'            "seleccionar via pago
*            WITH par_xbl      EQ 'X'            "Indicador¿Requiere
**          WITH par_prp1     EQ 'RFFOAVIS'     "Programa1  "Toma los programas que están ligados a la vía de pago
*            WITH par_prp2     EQ 'RFFOEDI1'     "Programa2  "Toma los programas que están ligados a la vía de pago
**          WITH par_prp3     EQ 'ZRFFOM100'    "Programa3  "Toma los programas que están ligados a la vía de pago
*           AND RETURN.
*
*            IF sy-subrc EQ 0.
*              CONCATENATE 'F110-' sy-datum '-' vg_laufi INTO vg_namejob.
*              CLEAR vg_a.
*              WHILE vg_a IS INITIAL.
*                SELECT SINGLE *
*                         FROM tbtco
*                         INTO  wa_tbtco
*                        WHERE jobname EQ vg_namejob
*                          AND ( status EQ 'A' OR status EQ 'F' ).
*
*                IF sy-subrc EQ 0.
*                  vg_a = 'X'.
*                ENDIF.
*              ENDWHILE.
*
*              WRITE:/ <fs_soc>-bukrs , 'Propuestas creadas', vg_laufi.
*              data: laufd type laufd.
*
*              laufd = sy-datum.
*              CALL FUNCTION 'Z_TR_CAJA_OPER_STORE_INDEX'
*                EXPORTING
*                  LAUFD         = laufd
*                  LAUFI         = vg_laufi.
*
**              ini dvbp
**              SUBMIT sapfpaym_merge USING SELECTION-SET 'Z_CAJAOP'
**                    AND RETURN.
*
*
*              REFRESH: r_lfd,r_lfi.
*
*
*              load_rg r_lfd 'I' 'EQ' sy-datum sy-datum .
*              load_rg r_lfi 'I' 'EQ' vg_laufi ' ' .
*
*              SUBMIT sapfpaym_merge
*              WITH so_lfd   IN r_lfd
*              WITH so_lfi  IN r_lfi      "identificador
*               WITH so_rzawe-low      EQ vl_zwe         "via de pago
*                AND RETURN.
**              fin dvbp
*            ENDIF.
*          ENDIF.
*        ENDIF.
      ENDIF.
    ENDDO.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form ID
*&---------------------------------------------------------------------*
FORM id  USING    p_laufi TYPE laufi
                  p_vg_laufi TYPE laufi.

  vg_laufi_aux = p_laufi+1(4) + 1.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = vg_laufi_aux
    IMPORTING
      output = vg_laufi_aux.
  CONCATENATE p_laufi(1) vg_laufi_aux INTO p_vg_laufi.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form RANGO_ACREEDOR
*&---------------------------------------------------------------------*
FORM rango_acreedor  USING p_bukrs.
  DATA: gt_ac TYPE STANDARD TABLE OF zfitt_reppag_ac.
  DATA: vl_cont(1) TYPE c.
  DATA: vl_operador2(10) TYPE c,
        vl_operador3(10) TYPE c.
  DATA: lt_ctrlpoliza TYPE STANDARD TABLE OF zctrlpoliza,
        wa_ctrlpoliza TYPE zctrlpoliza,
        vl_cpudt      TYPE bkpf-cpudt,
        vl_cputm      TYPE bkpf-cputm,
        vl_enddate    TYPE sy-datum,
        vl_endhour    TYPE sy-uzeit,
        vl_minutos    TYPE tvarvc-low.

  load_rg rg_blart 'I' 'EQ' 'KL' ' ' .
  load_rg rg_blart 'I' 'EQ' 'KT' ' ' .
  load_rg rg_blart 'I' 'EQ' 'KV' ' ' .
  load_rg rg_blart 'I' 'EQ' 'ZA' ' ' .
  load_rg rg_blart 'I' 'EQ' 'LQ' ' ' .

  SELECT *
     INTO TABLE lt_ctrlpoliza
     FROM zctrlpoliza
     WHERE bukrs EQ p_bukrs.

  CLEAR: wa_ctrlpoliza, vl_cpudt, vl_cputm.
  READ TABLE lt_ctrlpoliza INTO wa_ctrlpoliza INDEX 1.

  vl_cpudt = sy-datum.
  vl_cputm = sy-uzeit.

  UPDATE zctrlpoliza SET cpudt = vl_cpudt cputm = vl_cputm WHERE bukrs = p_bukrs.

  CLEAR vl_minutos.
  SELECT SINGLE low
    INTO vl_minutos
    FROM tvarvc
    WHERE name = 'ZDELAY'.

  CALL FUNCTION 'END_TIME_DETERMINE'
    EXPORTING
      duration                   = vl_minutos
      unit                       = 'MIN'
    IMPORTING
      end_date                   = vl_enddate
      end_time                   = vl_endhour
    CHANGING
      start_date                 = wa_ctrlpoliza-cpudt "sy-datum
      start_time                 = wa_ctrlpoliza-cputm "sy-uzeit
    EXCEPTIONS
      factory_calendar_not_found = 1
      date_out_of_calendar_range = 2
      date_not_valid             = 3
      unit_conversion_error      = 4
      si_unit_missing            = 5
      parameters_no_valid        = 6
      OTHERS                     = 7.
  IF sy-subrc <> 0.
*    implement suitable error handling here
  ENDIF.

  IF sy-datum EQ vl_enddate.
    vl_cont = '0'.
    REFRESH gt_bkpf.
    SELECT *
      INTO TABLE gt_bkpf
      FROM bkpf
      WHERE bukrs = p_bukrs
        AND gjahr = vl_cpudt+0(4)
        AND blart IN rg_blart
*        and budat = vl_cpudt
        AND cpudt BETWEEN wa_ctrlpoliza-cpudt AND vl_cpudt
*        and cputm between wa_ctrlpoliza-cputm and vl_cputm. "MMB 16.05.2022 debe realizar el ajuste con respecto al más reciente corte
        AND cputm BETWEEN vl_endhour AND vl_cputm.
    IF sy-subrc = 0.
      vl_cont = '1'.
    ENDIF.

*    *    INI DVBP 10.06.2022
*SE AGREGAN POLIZA QUE NO SE HAN PORCESADOS DURANTE EL DIA Y PARA ESO BUSCAMOS EN LA BPKF Y EN LA BSEG CON AUGBEL = SPACE

    SELECT    a~bukrs
         a~belnr
         a~gjahr
         a~blart
         a~bldat
         a~budat
         a~monat
         a~cpudt
         a~cputm
         APPENDING TABLE gt_bkpf_pdte_dia
          FROM bkpf AS a
      INNER JOIN bseg  AS b ON b~bukrs = a~bukrs AND
    b~belnr  = a~belnr AND
    b~gjahr = a~gjahr
          WHERE a~bukrs = p_bukrs
            AND a~gjahr = vl_cpudt+0(4)
            AND a~blart IN rg_blart
*        and budat = vl_cpudt
            AND a~cpudt BETWEEN wa_ctrlpoliza-cpudt AND vl_cpudt
        AND b~lifnr NE space
        AND b~augbl EQ space.
    IF sy-subrc = 0.

      SELECT *
           APPENDING TABLE gt_bkpf
           FROM bkpf
        FOR ALL ENTRIES IN gt_bkpf_pdte_dia
           WHERE bukrs = gt_bkpf_pdte_dia-bukrs
             AND belnr = gt_bkpf_pdte_dia-belnr
             AND gjahr = gt_bkpf_pdte_dia-gjahr.
      IF sy-subrc = 0.
        vl_cont = '1'.
      ENDIF.

    ENDIF.
*    FIN DVBP 10.06.2022
  ELSE.
    vl_cont = '0'.
    REFRESH gt_bkpf.
    SELECT *
      INTO TABLE gt_bkpf
      FROM bkpf
      WHERE bukrs = p_bukrs
        AND gjahr = vl_cpudt+0(4)
        AND blart IN rg_blart
*        and budat = vl_cpudt
        AND cpudt = vl_enddate
        AND cputm BETWEEN vl_endhour AND '23:59:59'.
    IF sy-subrc = 0.
      vl_cont = '1'.
    ENDIF.

    SELECT *
         APPENDING TABLE gt_bkpf
         FROM bkpf
         WHERE bukrs = p_bukrs
           AND gjahr = vl_cpudt+0(4)
           AND blart IN rg_blart
*           and budat = vl_cpudt
           AND cpudt > vl_enddate.
    IF sy-subrc = 0.
      vl_cont = '1'.
    ENDIF.


*    INI DVBP 10.06.2022
*SE AGREGAN POLIZA QUE NO SE HAN PORCESADOS DURANTE EL DIA Y PARA ESO BUSCAMOS EN LA BPKF Y EN LA BSEG CON AUGBEL = SPACE

    SELECT    a~bukrs
         a~belnr
         a~gjahr
         a~blart
         a~bldat
         a~budat
         a~monat
         a~cpudt
         a~cputm
         APPENDING TABLE gt_bkpf_pdte_dia
          FROM bkpf AS a
      INNER JOIN bseg  AS b ON b~bukrs = a~bukrs AND
    b~belnr  = a~belnr AND
    b~gjahr = a~gjahr
          WHERE a~bukrs = p_bukrs
            AND a~gjahr = vl_cpudt+0(4)
            AND a~blart IN rg_blart
*        and budat = vl_cpudt
            AND a~cpudt BETWEEN wa_ctrlpoliza-cpudt AND vl_cpudt
        AND b~lifnr NE space
        AND b~augbl EQ space.
    IF sy-subrc = 0.

      SELECT *
           APPENDING TABLE gt_bkpf
           FROM bkpf
        FOR ALL ENTRIES IN gt_bkpf_pdte_dia
           WHERE bukrs = gt_bkpf_pdte_dia-bukrs
             AND belnr = gt_bkpf_pdte_dia-belnr
             AND gjahr = gt_bkpf_pdte_dia-gjahr.
      IF sy-subrc = 0.
        vl_cont = '1'.
      ENDIF.

    ENDIF.
*    FIN DVBP 10.06.2022
  ENDIF.

  IF vl_cont = '1'.
    SELECT *
      INTO TABLE gt_bseg
      FROM bseg
      FOR ALL ENTRIES IN gt_bkpf
      WHERE bukrs = gt_bkpf-bukrs
        AND belnr = gt_bkpf-belnr
        AND gjahr = gt_bkpf-gjahr
        AND lifnr NE space.
    SORT gt_bseg BY lifnr.
    DELETE ADJACENT DUPLICATES FROM gt_bseg COMPARING lifnr.
    IF  gt_bseg IS NOT INITIAL.
      LOOP AT gt_bseg INTO wa_bseg.
        rg_vonkk-sign = 'I'.
        rg_vonkk-option = 'EQ'.
        rg_vonkk-low = wa_bseg-lifnr.
        rg_vonkk-high =  ' '.
*** Se revisa que lifnr sea operador.
        CLEAR vl_operador2.
        CLEAR vl_operador3.
        vl_operador2 = wa_bseg-lifnr.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = vl_operador2
          IMPORTING
            output = vl_operador2.
        SELECT SINGLE lifnr
          INTO vl_operador3
          FROM lfb1
          WHERE lifnr = vl_operador2
          AND   bukrs = wa_bseg-bukrs
          AND   akont IN ( '1143010000','1143020000', '1144010000' ).
        IF sy-subrc = 0.
          APPEND rg_vonkk.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.
