FUNCTION z_tr_caja_oper_create_retry.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(TS_COPER_HEADER) TYPE  ZES_COPER_HEADER
*"  TABLES
*"      EXT_RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------

  CONSTANTS IM_SYSTEM_DEFAULT TYPE c LENGTH 10 VALUE '9999999999'.

  DATA: it_header          TYPE TABLE OF zes_coper_header,
        ls_header          TYPE ztr_coper_header,
        lt_header_fallido  TYPE TABLE OF ztr_coper_header,
        ls_header_fallido  TYPE ztr_coper_header,
        ls_coper_retry     TYPE ztr_coper_retry,
        ls_bapiret2        TYPE bapiret2,
        belnr_exit         TYPE belnr_d,
        bukrs_exit         TYPE bukrs,
        ex_status          TYPE char1,
        zfies_payliqadv    TYPE zfies_payliqadv,
        zfies_imitposition TYPE TABLE OF zfies_imitposition,
        zfies_ex_it_return TYPE TABLE OF zfies_ex_it_return.

  IF ts_coper_header-im_status EQ 'S'.
    CLEAR ls_bapiret2.
    ls_bapiret2-type = 'E'.
    ls_bapiret2-id = 'ZTR_CAJA_OPER'.
    ls_bapiret2-number = 000.
    APPEND ls_bapiret2 TO ext_return.

  ELSEIF ts_coper_header-im_system EQ IM_SYSTEM_DEFAULT.
    CLEAR ls_bapiret2.
    ls_bapiret2-type = 'E'.
    ls_bapiret2-id = 'ZTR_CAJA_OPER'.
    ls_bapiret2-number = 001.
    APPEND ls_bapiret2 TO ext_return.
  ELSE.

*   Asigno mi cabecera a la cabecera de la funcion
    zfies_payliqadv-im_system = ts_coper_header-im_system.
    zfies_payliqadv-im_bldat = ts_coper_header-im_bldat.
    zfies_payliqadv-im_budat = ts_coper_header-im_budat.
    zfies_payliqadv-im_bukrs = ts_coper_header-im_bukrs.
    zfies_payliqadv-im_blart = ts_coper_header-im_blart.
    zfies_payliqadv-im_waers = ts_coper_header-im_waers.
    zfies_payliqadv-im_kursf = ts_coper_header-im_kursf.
    zfies_payliqadv-im_wwert = ts_coper_header-im_wwert.
    zfies_payliqadv-im_xblnr = ts_coper_header-im_xblnr.
    zfies_payliqadv-im_bktxt = ts_coper_header-im_bktxt.

*         Busco las posiciones de este uuid
    SELECT *
    INTO CORRESPONDING FIELDS OF TABLE zfies_imitposition
    FROM ztr_coper_pos
    WHERE uuid EQ ts_coper_header-uuid.


    CALL FUNCTION 'ZMFFI_POLIZA_CONTABLE'
      EXPORTING
        zfies_payliqadv    = zfies_payliqadv
      IMPORTING
        ex_status          = ex_status "S/E
      TABLES
        zfies_imitposition = zfies_imitposition
        zfies_ex_it_return = zfies_ex_it_return.


    LOOP AT zfies_ex_it_return INTO DATA(ex_it).
      belnr_exit = ex_it-ex_belnr.
      bukrs_exit = ex_it-ex_bukrs.
    ENDLOOP.


    IF ex_status EQ 'S'.
*   Filtrar tambien por ejercicio, zfies_ex_it_return no la devuelve
      SELECT SINGLE *
        INTO CORRESPONDING FIELDS OF ls_header
        FROM ztr_coper_header
        WHERE im_bukrs EQ bukrs_exit
        AND im_belnr  EQ belnr_exit.

*     Actualizo el header (im_system)del hijo
      UPDATE ztr_coper_header
      SET im_system = IM_SYSTEM_DEFAULT
      WHERE im_bukrs EQ bukrs_exit
      AND im_belnr  EQ belnr_exit.


*    Actualizo el header del padre
      UPDATE ztr_coper_header
      SET im_status = 'S'
          im_belnr =  belnr_exit
      WHERE uuid = ts_coper_header-uuid.

*   Relleno la tabla RETRY
      ls_coper_retry-parent_uuid = ts_coper_header-uuid.
      ls_coper_retry-child_uuid = ls_header-uuid.
      ls_coper_retry-datum = sy-datum.
      ls_coper_retry-uname = sy-uname.
      ls_coper_retry-uzeit = sy-uzeit.

      INSERT ztr_coper_retry FROM ls_coper_retry.

      CLEAR ls_bapiret2.
      ls_bapiret2-type = 'S'.
      ls_bapiret2-id = 'ZTR_CAJA_OPER'.
      ls_bapiret2-number = 002.
      APPEND ls_bapiret2 TO ext_return.

    ELSEIF ex_status EQ 'E'.
*   BUSCO EL ULTIMO UUID HIJO FALLIDO POR LA HORA
      SELECT * FROM ztr_coper_header
        INTO TABLE lt_header_fallido
        WHERE im_bukrs = bukrs_exit
        AND im_bldat = ts_coper_header-im_bldat
        AND im_datum = sy-datum
        AND im_user =  sy-uname
        ORDER BY im_uzeit DESCENDING.

      IF lt_header_fallido[] IS NOT INITIAL.
        ls_header_fallido = lt_header_fallido[ 1 ].

*       Actualizo el header (im_system)del hijo
        UPDATE ztr_coper_header
          SET im_system = IM_SYSTEM_DEFAULT
          WHERE uuid EQ ls_header_fallido-uuid.

*       Mapeo
        ls_coper_retry-parent_uuid = ts_coper_header-uuid.
        ls_coper_retry-child_uuid = ls_header_fallido-uuid.
        ls_coper_retry-datum = sy-datum.
        ls_coper_retry-uname = sy-uname.
        ls_coper_retry-uzeit = sy-uzeit.

        INSERT ztr_coper_retry FROM ls_coper_retry.

        CLEAR ls_bapiret2.
        ls_bapiret2-type = 'E'.
        ls_bapiret2-id = 'ZTR_CAJA_OPER'.
        ls_bapiret2-number = 003.
        APPEND ls_bapiret2 TO ext_return.
      ENDIF.
    ENDIF.
  ENDIF.



ENDFUNCTION.
