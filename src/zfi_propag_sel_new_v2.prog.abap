*&---------------------------------------------------------------------*
*& Include          ZFI_PROPAG_SEL_NEW
*&---------------------------------------------------------------------*
selection-screen begin of block block with frame title text-001.
parameters: p_bukrs type bseg-bukrs obligatory.   " Sociedad
SELECT-OPTIONS: s_via for wa_bseg-ZLSCH OBLIGATORY.
selection-screen end of block block.
