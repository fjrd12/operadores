*&---------------------------------------------------------------------*
*& Include          ZFI_PROPAG_TOP
*&---------------------------------------------------------------------*
TABLES: zsociedad_tmsnew.

*INI DVBP 10.06.2022
TYPES: BEGIN OF ty_bkpf_dia,
         bukrs TYPE bkpf-bukrs,
         belnr TYPE bkpf-belnr,
         gjahr TYPE bkpf-gjahr,
         blart TYPE bkpf-blart,
         bldat TYPE bkpf-bldat,
         budat TYPE bkpf-budat,
         monat TYPE bkpf-monat,
         cpudt TYPE bkpf-cpudt,
         cputm TYPE bkpf-cputm,
       END OF ty_bkpf_dia.

DATA: gt_bkpf_pdte_dia TYPE STANDARD TABLE OF ty_bkpf_dia,
      wa_bkpf_pdte_dia TYPE ty_bkpf_dia.
*FIN DVBP 10.06.2022


TYPES: BEGIN OF ty_reguh,
         laufd TYPE laufd,
         laufi TYPE laufi,
         zbukr TYPE dzbukr,
       END OF   ty_reguh.

DATA: gt_soc       TYPE STANDARD TABLE OF zfitt_propag,
*      gt_socact    type standard table of zsociedad_tmsnew WITH HEADER LINE,
      GT_SOCACT    TYPE STANDARD TABLE OF zsociedad_tmsnew, "V0002
      gwa_socact   TYPE zsociedad_tmsnew,
      gt_reguh     TYPE STANDARD TABLE OF ty_reguh,
      gt_reguh_l   TYPE STANDARD TABLE OF ty_reguh,
      gt_reguh_o   TYPE STANDARD TABLE OF ty_reguh,
      gt_reguh_aux TYPE STANDARD TABLE OF ty_reguh.

DATA: gt_bkpf  TYPE STANDARD TABLE OF bkpf,
      wa_bkpf  TYPE bkpf,
      gt_bseg  TYPE STANDARD TABLE OF bseg,
      wa_bseg  TYPE bseg,
      wa_tbtco TYPE tbtco.

DATA: vg_date+        TYPE sy-datum,
      vg_date-        TYPE sy-datum,
      vg_laufi        TYPE laufi,
      vg_laufi_aux(4) TYPE c,
      vg_namejob      TYPE btcjob,
      vg_a            TYPE c.

RANGES: rg_vonkk  FOR lfa1-lifnr.

DEFINE load_sel.
* Clear header
  CLEAR: &1.
* Fields initialize
  &1-sign = &2.
  &1-option = &3.
  &1-low = &4.
  &1-high = &5.
* Append...
  APPEND &1 ."TO &1 SORTED BY low.
END-OF-DEFINITION. "load_sel.

RANGES: rg_blart FOR bsid-blart.

DEFINE load_rg.
* Clear header
  CLEAR: &1.
* Fields initialize
  &1-sign = &2.
  &1-option = &3.
  &1-low = &4.
  &1-high = &5.
* Append...
  APPEND &1 .
END-OF-DEFINITION. "load_rg.
