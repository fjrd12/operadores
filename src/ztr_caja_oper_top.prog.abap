*&---------------------------------------------------------------------*
*& Include ZTR_CAJA_OPER_TOP                        - Modulpool        ZTR_CAJA_OPER
*&---------------------------------------------------------------------*
TABLES: ztr_coper_header, zes_coper_header, ztr_coper_retry, ztr_coper_pos.

*Constantes
CONSTANTS: error TYPE c LENGTH 132 VALUE '@0A@'.
CONSTANTS: succesfull TYPE c LENGTH 132 VALUE '@08@'.

* Field Symbols
FIELD-SYMBOLS <fs_coper_header> TYPE zes_coper_header.

*criterio de seleccion
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-000.
SELECT-OPTIONS: p_uuid      FOR ztr_coper_header-uuid MODIF ID g1.
SELECT-OPTIONS: p_system    FOR ztr_coper_header-im_system MODIF ID g1.
SELECT-OPTIONS: p_bldat     FOR ztr_coper_header-im_bldat MODIF ID g1.
SELECT-OPTIONS: p_budat     FOR ztr_coper_header-im_budat MODIF ID g1.
SELECT-OPTIONS: p_bukrs     FOR ztr_coper_header-im_bukrs MODIF ID g1.
SELECT-OPTIONS: p_blart     FOR ztr_coper_header-im_blart MODIF ID g1.
SELECT-OPTIONS: p_wwert     FOR ztr_coper_header-im_wwert MODIF ID g1.
SELECT-OPTIONS: p_bktxt     FOR ztr_coper_header-im_bktxt MODIF ID g1.
SELECT-OPTIONS: p_datum     FOR ztr_coper_header-im_datum MODIF ID g1 DEFAULT sy-datum.
SELECT-OPTIONS: p_user      FOR ztr_coper_header-im_user MODIF ID g1.
SELECT-OPTIONS: p_belnr     FOR ztr_coper_header-im_belnr MODIF ID g1.
SELECT-OPTIONS: p_status    FOR ztr_coper_header-im_status MODIF ID g1.
SELECT-OPTIONS: p_lifnr    FOR ztr_coper_pos-im_lifnr MODIF ID g1.
SELECTION-SCREEN END OF BLOCK b1.


*Variables
CLASS cls_alv_oo DEFINITION DEFERRED.
CLASS cls_events DEFINITION DEFERRED.

DATA: ok_code TYPE sy-ucomm.

* Variables globales
DATA: it_coper_header TYPE TABLE OF zes_coper_header,
      it_coper_retry  TYPE TABLE OF ztr_coper_retry,
      it_coper_pos    TYPE TABLE OF ztr_coper_pos,
      ls_coper_retry  TYPE ztr_coper_retry,
      it_bapiret2     TYPE TABLE OF bapiret2,
      ls_bapiret2     TYPE bapiret2,
      obj_alv_oo      TYPE REF TO cls_alv_oo,
      obj_events      TYPE REF TO cls_events,
      vg_container    TYPE REF TO cl_gui_custom_container,
      obj_alv_grid    TYPE REF TO  cl_gui_alv_grid,
      it_fcat         TYPE STANDARD TABLE OF lvc_s_fcat,
      g_repid         LIKE sy-repid.
