FUNCTION Z_TR_CAJA_OPER_EXIT_PAYM.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  TABLES
*"      T_LINES STRUCTURE  FPM_FILE
*"      IT_BAPIRET2 STRUCTURE  BAPIRET2
*"  EXCEPTIONS
*"      ERROR_IN_IDOC_CONTROL
*"      ERROR_WRITING_IDOC_STATUS
*"      ERROR_IN_IDOC_DATA
*"      SENDING_LOGICAL_SYSTEM_UNKNOWN
*"      OTHERS
*"----------------------------------------------------------------------

  DATA: vl_body           TYPE z_body,
        vl_uri            TYPE string,
        vl_status         TYPE string,
        vl_result         TYPE z_body,
        vl_buffer         TYPE xstring,
        vl_body_send      TYPE z_body,
        vl_json           TYPE z_body,
        vl_body_principal TYPE z_body,
        vl_filename       TYPE string,
        ZTR_BODY          TYPE STRING,
        ZTR_NAME          TYPE STRING,
        c_sd_bil_d_05(20) TYPE c VALUE 'ZTR_PAGOS_SANTANDER',
        c_pbanorte(20)    TYPE c VALUE 'ZTR_PAGOS_BANORTE',
        lv_body           TYPE STRING,
        lv_contador(5),
        lv_contador2(5),
        lv_flag,
        lv_parform        type FORMI_FPM, "6@6o 09.09.2020 13:58:54
        lv_ext            type string, "6@6o 09.09.2020 14:02:05 '.in2'.
        lv_secinter       type char03, "6@6o 09.09.2020 15:48:25
        lv_reguh          type reguh, "6@6o 22.09.2020 00:42:32
        lv_laufi          type laufi, "6@6o 22.09.2020 00:13:36
        lv_laufd          type laufd, "6@6o 22.09.2020 00:13:56
        ORIG_LAUFI        type laufi,
        ORIG_LAUFD        type laufd,
        TZTRPAYH          type STANDARD TABLE OF ZTRPAYH,
        TZTRPAYP          type STANDARD TABLE OF ZTRPAYP,
        TZTRPAY_META      type STANDARD TABLE OF ZTRPAY_META,
        TZTRPAY_METAP     TYPE STANDARD TABLE OF ZTRPAY_METAP,
        EDIDC             type EDIDC,
        ZBNKHEADER        type ZBNKHEADER,
        lv_lifnr          TYPE lifnr,
        lv_laufitmp       type laufi, "6@6o 22.09.2020 00:13:36
        lv_laufdtmp       type laufd, "6@6o 22.09.2020 00:13:56
        l_cr(2)           type c value cl_abap_char_utilities=>cr_lf, "6@6o 06.10.2020 12:38:57
        lv_foot(2),
        lv_doc1r          TYPE doc1r_fpm,
        lv_ident          TYPE string,
        SCENARIO          TYPE CHAR10,
        PROCESS           TYPE CHAR10,
        ZLSCH             TYPE SCHZW_BSEG.

  DATA    p_numero(4) type c. "DVBP
  data: ls_data type zfi_valores. "quitar MMB 01042022

  data: l_obj_sec  type ref to zcl_tr004_secuencias,
        l_bnrt_sec type CHAR03.

  data: lv_bank1 type bnkn2, lv_bank2 type bnkn2.

  data: GS_ARCHIVO type ZFITT_ARCHIVO,
        NAME       TYPE STRING.

  data:   lv_doperammb  type zfitt_dopera.

  data: cls_folio_pay_file_write type ref to zclfi_h2h_folio. "EAHC R-011337

  FIELD-SYMBOLS: <FLAG>, <F_LAUFI>, <F_LAUFD>, <F_LIFNR>,
                 <F_folio_LAUFI> " EAHC R-011337
                 .

****INI DVBP 16.06.2022
**LOGICA PARA PODER RELIZAR DEBUG EN PORCESO DE FONDO Y VER LAS OPCIONES
*    DATA: GS_DOPERA_RES TYPE ZFITT_DOPERA_RES.
*DATA V_X TYPE C.
*DATA V_dEBUG TYPE C.
*
*SELECT SINGLE LOW
*  FROM TVARVC
*  INTO V_DEBUG
*  WHERE NAME = 'Z_DEBUG'.
*
*  IF SY-SUBRC EQ 0 AND V_DEBUG IS NOT INITIAL.
*DO.
*  IF V_X IS NOT INITIAL.
*    EXIT.
*    ENDIF.
*  ENDDO.
*ENDIF.
*
*****INI DVBP 16.06.2022


  assign ('(SAPFPAYM)PAR_XFIL') to <FLAG>.
  lv_flag = <FLAG>.

  IF lv_flag is not initial.

    assign ('(SAPFPAYM)PM_LAUFD') to <F_LAUFD>.
    lv_laufd = <F_LAUFD>.
    assign ('(SAPFPAYM)PM_LAUFI') to <F_LAUFI>.
    lv_laufi = <F_LAUFI>.

    CALL FUNCTION 'Z_TR_CAJA_OPER_SCENARIO'
      EXPORTING
        LAUFD      = lv_laufd
        LAUFI      = lv_laufi
      IMPORTING
        SCENARIO   = SCENARIO
        ORIG_LAUFD = ORIG_LAUFD
        ORIG_LAUFI = ORIG_LAUFI
        PROCESS    = PROCESS
        ZLSCH      = ZLSCH.


    case SCENARIO.
      when 'NO_CLASSIF'.

        if T_LINES[] is not INITIAL.
****INI DVBP 16.06.2022
*LOGICA PARA PODER RELIZAR DEBUG EN PORCESO DE FONDO Y VER LAS OPCIONES
          DATA: GS_DOPERA_RES TYPE ZFITT_DOPERA_RES.
          DATA V_X TYPE C.
          DATA V_dEBUG TYPE C.

          SELECT SINGLE LOW
            FROM TVARVC
            INTO V_DEBUG
            WHERE NAME = 'Z_DEBUG'.

          IF SY-SUBRC EQ 0.
            DO.
              IF V_DEBUG IS NOT INITIAL.
                EXIT.
              ENDIF.
            ENDDO.
          ENDIF.

****INI DVBP 16.06.2022
          "ADD INI CAPSYS 30072021
          PERFORM file_operadores(LFPAYM05F02) TABLES t_lines USING  ZTR_NAME.
          "ADD FIN CAPSYS 30072021

          l_obj_sec = new zcl_tr004_secuencias( ).
**********************************************************************
**********************************************************************

          clear : lv_parform, lv_secinter.
          assign ('(SAPFPAYM)PAR_FORM') to field-symbol(<f_par_form>).
          lv_parform = <f_par_form>.

          assign ('(SAPFPAYM)PM_LAUFI') to <F_folio_LAUFI>.
          data lv_folio_laufi type laufi.
          lv_folio_laufi = <F_folio_LAUFI>.

          CREATE OBJECT cls_folio_pay_file_write. "EAHC R-011337
          data(lv_folio) = cls_folio_pay_file_write->get_folio( lv_folio_laufi ). "EAHC R-011337

          if lv_parform = 'ZTR_CRSSBRDRINT'.
            select single uri
            into @vl_uri
            from zfitt_cpi_uris
            where proceso = @c_sd_bil_d_05.

            lv_secinter =  new zcl_tr004_secuencias( )->get_internacional( exporting im_fecha = sy-datum ) .
            "lv_secinter = '001'.
            lv_ext = '.inter'.
            "concatenate 'tran_' SY-DATUM SY-UZEIT+0(4) '_9134_TI_' lv_secinter into ZTR_NAME.  "EAHC R-011337
            concatenate 'tran_' SY-DATUM lv_folio '_9134_TI_' lv_secinter into ZTR_NAME.  "EAHC R-011337
            concatenate ZTR_NAME lv_ext into ZTR_NAME.
          elseif lv_parform = 'ZBANORTE'.
            clear l_bnrt_sec.
            lv_ext = '.TXT'.

            select single uri
            into @vl_uri
            from zfitt_cpi_uris
            where proceso = @c_pbanorte.

            assign ('(SAPFPAYM)PM_LAUFD') to <F_LAUFD>.
            lv_laufd = <F_LAUFD>.
            assign ('(SAPFPAYM)PM_LAUFI') to <F_LAUFI>.
            lv_laufi = <F_LAUFI>.


            select single *
            into lv_reguh
            from reguh
            where laufi = lv_laufi
              and laufd = lv_laufd.


            IF sy-subrc = 0.

              IF lv_reguh-zbnky NE lv_reguh-ubnky AND                                 "6@6o 22.09.2020 00:20:36 SPEI
                 lv_reguh-waers EQ 'MXN' AND
                 lv_reguh-zbnkn NE '999999999999999999'. "ADD FSW 19.01.2021 Se agrega validación de cuenta diferente de SERVICIOS

*              l_bnrt_sec = l_obj_sec->get_banorte( exporting im_fecha = sy-datum
*                im_nrobj = zcl_tr004_secuencias=>gc_nrobj_banorte_spei ).

                "INICIO FSW 30.11.2020 Corregir los prefijos para cada tipo de pago
                l_bnrt_sec = l_obj_sec->get_banorte( exporting im_fecha = sy-datum "Como SPEI y TERCEROS usan prefijo PP llamamos el mismo método
                  im_nrobj = zcl_tr004_secuencias=>GC_NROBJ_BANORTE_MX ).

                concatenate 'PP' '340966' SY-DATUM+2(2) SY-DATUM+4(2) SY-DATUM+6(2)  l_bnrt_sec into ZTR_NAME.
                concatenate ZTR_NAME lv_ext into ZTR_NAME.
                "FIN FSW 30.11.2020

                "ADD CAPSYS PARA GUARDAR NOMBRE DE ARCHIVO PARA REPORTE DE NOMINA
                PERFORM file_operadores(LFPAYM05F02) TABLES t_lines USING  ZTR_NAME .

              ELSEIF lv_reguh-zbnky NE lv_reguh-ubnky AND                             "6@6o 22.09.2020 00:21:25 SPID
                     lv_reguh-waers EQ 'USD' AND
                     lv_reguh-zbnkn NE '999999999999999999'. "ADD FSW 19.01.2021 Se agrega validación de cuenta diferente de SERVICIOS

                l_bnrt_sec = l_obj_sec->get_banorte( exporting im_fecha = sy-datum
                  im_nrobj = zcl_tr004_secuencias=>gc_nrobj_banorte_spid ).

                "INICIO FSW 30.11.2020 Corregir los prefijos para cada tipo de pago
                concatenate 'PS' '340966' SY-DATUM+2(2) SY-DATUM+4(2) SY-DATUM+6(2)  l_bnrt_sec into ZTR_NAME.
                concatenate ZTR_NAME lv_ext into ZTR_NAME.
                "FIN FSW 30.11.2020

              ELSEIF lv_reguh-zbnky EQ lv_reguh-ubnky AND                              "6@6o 22.09.2020 00:21:25 TERCEROS
                     lv_reguh-zbnkn NE '999999999999999999'. "ADD FSW 19.01.2021 Se agrega validación de cuenta diferente de SERVICIOS

                l_bnrt_sec = l_obj_sec->get_banorte( exporting im_fecha = sy-datum
                  im_nrobj = zcl_tr004_secuencias=>GC_NROBJ_BANORTE_MX ).

                "INICIO FSW 30.11.2020 Corregir los prefijos para cada tipo de pago
                concatenate 'PP' '340966' SY-DATUM+2(2) SY-DATUM+4(2) SY-DATUM+6(2)  l_bnrt_sec into ZTR_NAME.
                concatenate ZTR_NAME lv_ext into ZTR_NAME.
                "FIN FSW 30.11.2020

                "ADD CAPSYS PARA GUARDAR NOMBRE DE ARCHIVO PARA REPORTE DE NOMINA
                PERFORM file_operadores(LFPAYM05F02) TABLES t_lines USING  ZTR_NAME .

              ELSEIF lv_reguh-zbnks NE 'MX' AND                                         "6@6o 22.09.2020 00:21:25 OPI
                     lv_reguh-zbnkn NE '999999999999999999'. "ADD FSW 19.01.2021 Se agrega validación de cuenta diferente de SERVICIOS
                l_bnrt_sec = l_obj_sec->get_banorte( exporting im_fecha = sy-datum
                  im_nrobj = zcl_tr004_secuencias=>gc_nrobj_banorte_opi ).

                "INICIO FSW 30.11.2020 Corregir los prefijos para cada tipo de pago
                concatenate 'PI' '340966' SY-DATUM+2(2) SY-DATUM+4(2) SY-DATUM+6(2)  l_bnrt_sec into ZTR_NAME.
                concatenate ZTR_NAME lv_ext into ZTR_NAME.
                "FIN FSW 30.11.2020

              ELSEIF lv_reguh-zbnkn EQ '999999999999999999' .                          "6@6o 22.09.2020 00:21:25 SERVICIOS

                l_bnrt_sec = l_obj_sec->get_banorte( exporting im_fecha = sy-datum
                  im_nrobj = zcl_tr004_secuencias=>gc_nrobj_banorte_srv ).

                "INICIO FSW 30.11.2020 Corregir los prefijos para cada tipo de pago
                concatenate 'PC' '340966' SY-DATUM+2(2) SY-DATUM+4(2) SY-DATUM+6(2)  l_bnrt_sec into ZTR_NAME.
                concatenate ZTR_NAME lv_ext into ZTR_NAME.
                "FIN FSW 30.11.2020

              ELSE.

                select single bnkn2 from T012K into lv_bank1
                where bukrs = lv_reguh-ZBUKR
                and BANKN = lv_reguh-ZBNKN.
                if sy-subrc eq 0.
                  select single bnkn2 from T012K into lv_bank2
                  where bukrs = lv_reguh-ZBUKR
                  and BANKN = lv_reguh-UBKNT.
                  if sy-subrc eq 0.

                    l_bnrt_sec = l_obj_sec->get_banorte( exporting im_fecha = sy-datum
                      im_nrobj = zcl_tr004_secuencias=>GC_NROBJ_BANORTE_MX ).

                    "INICIO FSW 30.11.2020 Corregir los prefijos para cada tipo de pago
                    concatenate 'PP' '340966' SY-DATUM+2(2) SY-DATUM+4(2) SY-DATUM+6(2)  l_bnrt_sec into ZTR_NAME.
                    concatenate ZTR_NAME lv_ext into ZTR_NAME.
                    "FIN FSW 30.11.2020

                    "ADD CAPSYS PARA GUARDAR NOMBRE DE ARCHIVO PARA REPORTE DE NOMINA
                    PERFORM file_operadores(LFPAYM05F02) TABLES t_lines USING  ZTR_NAME .

                  endif.
                endif.
              endif.
            endif.

*          "INICIO FSW 30.11.2020 Corregir los prefijos para cada tipo de pago
*          concatenate 'PP' '340966' SY-DATUM+2(2) SY-DATUM+4(2) SY-DATUM+6(2)  l_bnrt_sec into ZTR_NAME.
*          concatenate ZTR_NAME lv_ext into ZTR_NAME.
*          "FIN FSW 30.11.2020

            "ADD CAPSYS PARA ENVIO DE ARCHIVO DE OPERADORES PARA BANORTE
          ELSEIF lv_parform EQ 'ZBNK_BAN_OPERADORES'.

            select single uri
               into @vl_uri
               from zfitt_cpi_uris
               where proceso = @c_pbanorte.

          else.

            select single uri
              into @vl_uri
              from zfitt_cpi_uris
              where proceso = @c_sd_bil_d_05.
*INI DVBP
            IF lv_parform EQ 'ZTR_CECOBAN'."ADD CAPSYS PARA QUE RESPETE EL NOMBRE DEL ARCHIVO DE OPERADORES
              lv_ext = '.in2'. wait up to 5 seconds.    "RSMQ 20210111  Se agrega un delay a la creación del nombre
**Obtener rango de numero para archivo Santander 26032022
*ini dvbp 28.06.2022
*      DATA P_NUMERO(4) TYPE C.
*      call function 'ZFI_CONSECUTIVO'
*        exporting
*          object            = 'ZTR_SAN'
*       IMPORTING
*         CONSECUTIVO       = P_NUMERO.

**

*IMPORT  P_NUMERO to P_NUMERO FROM memory ID 'CONS'.
*fin dvbp 28.06.2022
*            concatenate 'tran' SY-DATUM+6(2) SY-DATUM+4(2) SY-DATUM(4) p_numero '_36049134' into ZTR_NAME. "Santander 26032022

              "concatenate 'tran' SY-DATUM SY-UZEIT+0(4) '_36049134' into ZTR_NAME.  "EAHC R-011337
              concatenate 'tran' SY-DATUM lv_folio '_36049134' into ZTR_NAME. "EAHC R-011337
              concatenate ZTR_NAME lv_ext into ZTR_NAME.
            ENDIF.
*FIN DVBP
          endif.

**********************************************************************
**********************************************************************
          "ADD CAPSYS PARA ENVIO DE ARCHIVOS DE OPERADORES ZBNK_SAN_OPERADORES
*     if lv_parform = 'ZTR_CRSSBRDRINT' or lv_parform = 'ZTR_CECOBAN' .
          if lv_parform = 'ZTR_CRSSBRDRINT' or lv_parform = 'ZTR_CECOBAN' OR lv_parform = 'ZBNK_SAN_OPERADORES'.

            import lv_contador to lv_contador from memory ID 'H2H'.
            ADD 1 to lv_contador.

            "IF sy-subrc EQ 0. "6@6o 21.09.2020 11:00:40

*    PERFORM frm_mapea_lineas USING  p_countline
*                           CHANGING p_gv_body.
            import ZTR_BODY to ZTR_BODY from memory ID 'H2H1'.

            LOOP AT T_LINES.
              move T_LINES-LINE+0(2) to lv_foot.
              IF ZTR_BODY IS INITIAL.
                MOVE T_LINES-LINE TO ZTR_BODY.
              ELSE.
                CONCATENATE ZTR_BODY T_LINES-LINE INTO ZTR_BODY SEPARATED BY l_cr.
              ENDIF.
            ENDLOOP.

            export ZTR_BODY from ZTR_BODY to memory ID 'H2H1'.

*         IF lv_contador eq 2.
            IF lv_foot eq '09'.

              CONCATENATE ZTR_BODY l_cr INTO ZTR_BODY.

              CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
                EXPORTING
                  text   = ZTR_BODY
                IMPORTING
                  buffer = vl_buffer
                EXCEPTIONS
                  failed = 1
                  OTHERS = 2.

              CALL FUNCTION 'SCMS_BASE64_ENCODE_STR'
                EXPORTING
                  input  = vl_buffer
                IMPORTING
                  output = vl_body_send.

              "INICIO FSW 10.02.2021 Identificador único interfaces
              IMPORT lv_doc1r TO lv_doc1r FROM MEMORY ID 'ZMID_DOC1R'. "Se recibe de Z_DMEE_EXIT_HEADER2 (Santander) o Z_DMEE_EXIT_DETAIL3 (Banorte)
              "ADD CAPSYS SE RESCIBE DE ZFI_DMEE_EXIT_HDR_OPE_SAN (Santander) Y
              "                         ZFI_DMEE_EXIT_HDR_OPE_BAN (Banorte)
              write: lv_doc1r.

              lv_ident = lv_doc1r.

              CALL FUNCTION 'ZMFFI_ODATA_POST'
                EXPORTING
                  iv_uri        = vl_uri
                  iv_body       = vl_body_send
                  iv_filename   = ztr_name       "p_filename
                  iv_identifier = lv_ident
                IMPORTING
                  ev_status     = vl_status
                  ev_result     = vl_result.

* EAHC Reproceso pago folio
              if lv_folio is not initial.
                MODIFY zfitt_h2h_folio FROM @( VALUE #(
                  datum = sy-datum
                  folio = lv_folio
                  uzeit = sy-uzeit
                  tcode = sy-tcode
                  uname = sy-uname
                  laufi = lv_folio_laufi
                  sended = abap_true
                    ) ).
              endif.
* FIN EAHC Reproceso pago folio
              "FIN FSW 10.02.2021

**borrar
*             clear lv_doperammb.
*
*             lv_doperammb-bukrs = 'MM00'.
*             lv_doperammb-belnr = lv_ident.
*             lv_doperammb-gjahr = '2022'.
*             lv_doperammb-name_file = ztr_name.
*
*             insert zfitt_dopera from lv_doperammb.
*             commit work and wait.
*

*             INI DVBP 06.16.2022


              CLEAR    GS_DOPERA_RES.



              gs_dopera_RES-bukrs     = lv_reguh-ZBUKR.
              gs_dopera_RES-DOC1R_FPM    = lv_doc1r.
*  gs_dopera_RES-gjahr     = lv_reguh-gjahr.
              case lv_reguh-hbkid(3).
                when 'SNT'.
                  gs_dopera_RES-bankl = '014'.
                when 'BNT'.
                  gs_dopera_RES-bankl = '072'.
                when 'HSB'.
                  gs_dopera_RES-bankl = '021'.
              endcase.
              gs_dopera_RES-name_file   = ztr_name.
              gs_dopera_RES-fecha       = sy-datum.
              gs_dopera_RES-hora        = sy-uzeit.
              gs_dopera_RES-id_system   = sy-sysid.

              gs_dopera_RES-ESTATUS = vl_status.
              gs_dopera_RES-MSJ = vl_result.

              MODIFY ZFITT_DOPERA_RES FROM gs_dopera_RES.
              IF SY-SUBRC EQ 0.
                commit work and wait.


              ENDIF.
*             FIN DVBP 06.16.2022

              clear: lv_contador,
                     ztr_body.

              export ZTR_BODY from ZTR_BODY to memory ID 'H2H1'.
            endif.

          else.

            loop at T_LINES.
              if ZTR_BODY is initial.
                move T_LINES-line to ZTR_BODY.
              else.
                concatenate ZTR_BODY T_LINES-line into ZTR_BODY separated by l_cr.
              endif.
            endloop.

            concatenate ZTR_BODY l_cr into ZTR_BODY.

            call function 'SCMS_STRING_TO_XSTRING'
              exporting
                text   = ZTR_BODY
              importing
                buffer = vl_buffer
              exceptions
                failed = 1
                others = 2.

            call function 'SCMS_BASE64_ENCODE_STR'
              exporting
                input  = vl_buffer
              importing
                output = vl_body_send.

            "INICIO FSW 10.02.2021 Identificador único interfaces
            IMPORT lv_doc1r TO lv_doc1r FROM MEMORY ID 'ZMID_DOC1R'. "Se recibe de Z_DMEE_EXIT_HEADER2 (Santander) o Z_DMEE_EXIT_DETAIL3 (Banorte)
            "ADD CAPSYS SE RESCIBE DE ZFI_DMEE_EXIT_HDR_OPE_SAN (Santander) Y
            "                         ZFI_DMEE_EXIT_HDR_OPE_SAN (Banorte)

            lv_ident = lv_doc1r.

            call function 'ZMFFI_ODATA_POST'
              exporting
                iv_uri        = vl_uri
                iv_body       = vl_body_send
                iv_filename   = ZTR_NAME       "p_filename
                iv_identifier = lv_ident
              importing
                ev_status     = vl_status
                ev_result     = vl_result.
            "FIN FSW 10.02.2021

* EAHC Reproceso pago folio
            if lv_folio is not initial.
              MODIFY zfitt_h2h_folio FROM @( VALUE #(
                datum = sy-datum
                folio = lv_folio
                uzeit = sy-uzeit
                tcode = sy-tcode
                uname = sy-uname
                laufi = lv_folio_laufi
                sended = abap_true
                  ) ).
            endif.
* FIN EAHC Reproceso pago folio

            clear: ztr_body.

*borrar
*             clear lv_doperammb.
*
*             lv_doperammb-bukrs = 'MM00'.
*             lv_doperammb-belnr = lv_ident.
*             lv_doperammb-gjahr = '2022'.
*             lv_doperammb-name_file = ztr_name.
*
*             insert zfitt_dopera from lv_doperammb.
*             commit work and wait.



*             INI DVBP 06.16.2022


            CLEAR    GS_DOPERA_RES.
            gs_dopera_RES-bukrs     = lv_reguh-ZBUKR.
            gs_dopera_RES-DOC1R_FPM    = lv_doc1r.
*  gs_dopera_RES-gjahr     = lv_reguh-gjahr.
            case lv_reguh-hbkid(3).
              when 'SNT'.
                gs_dopera_RES-bankl = '014'.
              when 'BNT'.
                gs_dopera_RES-bankl = '072'.
              when 'HSB'.
                gs_dopera_RES-bankl = '021'.
            endcase.
            gs_dopera_RES-name_file   = ztr_name.
            gs_dopera_RES-fecha       = sy-datum.
            gs_dopera_RES-hora        = sy-uzeit.
            gs_dopera_RES-id_system   = sy-sysid.

            gs_dopera_RES-ESTATUS = vl_status.
            gs_dopera_RES-MSJ = vl_result.

            MODIFY ZFITT_DOPERA_RES FROM gs_dopera_RES.
            IF SY-SUBRC EQ 0.
              commit work and wait.
            ENDIF.
*             FIN DVBP 06.16.2022
          endif.
          "ENDIF."6@6o 21.09.2020 11:00:29
        ENDIF.

        export lv_contador from lv_contador to memory ID 'H2H'.
      when 'OPERADORES'.


        select single * from reguh
          into lv_reguh
          where laufd = lv_laufd and
                laufi = lv_laufi.

        case lv_reguh-hbkid(3).
          when 'SNT'.
            ZBNKHEADER-BANK = 'SANTANDER'.
          when 'BNT'.
            ZBNKHEADER-BANK = 'BANORTE'.
          when 'HSB'.
            ZBNKHEADER-BANK = 'HSBC'.
          when OTHERS.

            CALL FUNCTION 'Z_TR_CAJA_OPER_DERIVE_BANK'
              EXPORTING
                ZLSCH = ZLSCH
              IMPORTING
                BANK  = ZBNKHEADER-BANK.

        endcase.

        ZBNKHEADER-CORREL_ID = cl_system_uuid=>if_system_uuid_rfc4122_static~create_uuid_c36_by_version( version = 4 )..
        ZBNKHEADER-TRANS_IP = cl_system_uuid=>if_system_uuid_rfc4122_static~create_uuid_c36_by_version( version = 4 )..
        ZBNKHEADER-PROCESS = PROCESS.

        CALL FUNCTION 'ZTR_PAY_GENERATE_IDOC_FUNC_V2'
          EXPORTING
            ZBNKHEADER                     = ZBNKHEADER
            LAUFD                          = ORIG_LAUFD
            LAUFI                          = ORIG_LAUFI
          TABLES
            ZTRPAYH                        = TZTRPAYH
            ZTRPAYP                        = TZTRPAYP
            ZTRPAY_META                    = TZTRPAY_META
            ZTRPAY_METAP                   = TZTRPAY_METAP
            IT_BAPIRET2                    = it_bapiret2
          CHANGING
            MASTER_IDOC_CONTROL            = EDIDC
          EXCEPTIONS
            ERROR_IN_IDOC_CONTROL          = 1
            ERROR_WRITING_IDOC_STATUS      = 2
            ERROR_IN_IDOC_DATA             = 3
            SENDING_LOGICAL_SYSTEM_UNKNOWN = 4
            OTHERS                         = 5.

        CASE SY-SUBRC.
          WHEN 1.
            RAISE ERROR_IN_IDOC_CONTROL.
          WHEN 2.
            RAISE ERROR_WRITING_IDOC_STATUS.
          WHEN 3.
            RAISE ERROR_IN_IDOC_DATA.
          WHEN 4.
            raise SENDING_LOGICAL_SYSTEM_UNKNOWN.
          WHEN 5.
            RAISE OTHERS.
        endcase.
    ENDCASE.
  ENDIF.

  if SCENARIO is INITIAL or SCENARIO = 'NO_CLASSIFIED'.
*ini dvbp 16.06.2022
*Se agrega timepo de espera de 2 a 5 seg.
*WAIT UP TO 2 SECONDS. "ADD FSW 27.11.2020 Agregamos tiempo de espera
    WAIT UP TO 5 SECONDS.
*fin dvbp 16.06.2022
  endif.
ENDFUNCTION.
