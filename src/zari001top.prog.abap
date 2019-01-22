*&---------------------------------------------------------------------*
*&  Include           ZARI001TOP
*&---------------------------------------------------------------------*
TABLES: bkpf, bsis, zari_empresa, zari_cod_imposto.

TYPES:
  BEGIN OF ty_empresa,
    empresa        TYPE zari_empresa-empresa,
*    tipo_imposto   TYPE zari_empresa-tipo_imposto,
*    categ_imposto  TYPE zari_empresa-categ_imposto,
    codigo_imposto TYPE zari_empresa-codigo_imposto,
  END OF ty_empresa,
  tty_empresa TYPE STANDARD TABLE OF ty_empresa,

  BEGIN OF ty_cod_imposto,
    codigo_imposto   TYPE zari_cod_imposto-codigo_imposto,
    tipo_imposto     TYPE zari_cod_imposto-tipo_imposto,

*< T.1 - Descomentado
    categ_imposto    TYPE zari_tp_imposto-categ_imposto,
*> T.1

    cod_imposto_rec  TYPE zari_cod_imposto-cod_imposto_rec,
    periodo_apuracao TYPE zari_cod_imposto-periodo_apuracao,

*< T.1 - Novos campos
    uf               TYPE zari_cod_imposto-uf,
    domicilio_fiscal TYPE zari_cod_imposto-domicilio_fiscal,
*> T.1

    definicao_regra  TYPE zari_cod_imposto-definicao_regra,
    dias_apuracao    TYPE zari_cod_imposto-dias_apuracao,
    tipo_apuracao    TYPE zari_cod_imposto-tipo_apuracao,
    conta_contabil   TYPE zari_cod_imposto-conta_contabil,
    regra_acumulo    TYPE zari_cod_imposto-regra_acumulo,
    dia_vencimento   TYPE zari_cod_imposto-dia_vencimento,
    cod_fornecedor   TYPE zari_cod_imposto-cod_fornecedor,
    cod_compens_rec  TYPE zari_cod_imposto-cod_compens_rec,
    cod_correcao_juros TYPE zari_cod_imposto-cod_correcao_juros,
    cod_correcao_multa TYPE zari_cod_imposto-cod_correcao_multa,
    categ_iva        TYPE zari_cod_imposto-categ_iva,
    categ_irrf       TYPE zari_cod_imposto-categ_irrf,
    irrf             TYPE zari_cod_imposto-irrf,
  END OF ty_cod_imposto,
  tty_cod_imposto TYPE STANDARD TABLE OF ty_cod_imposto,

  BEGIN OF ty_cod_multajuros,
    COD_CORRECAO           TYPE zari_juros_multa-cod_correcao,
    TIPO                   TYPE zari_juros_multa-tipo,
    BASE_CALCULO           TYPE zari_juros_multa-base_calculo,
    PERC_FIXO_CORRECAO     TYPE zari_juros_multa-perc_fixo_correcao,
    TAXA_VAR_MERCADO       TYPE zari_juros_multa-taxa_var_mercado,
    PERC_TAXA_VAR_MERC     TYPE zari_juros_multa-perc_taxa_var_merc,
    PERIODICIDADE          TYPE zari_juros_multa-periodicidade,
    LIMITE_CORRECAO        TYPE zari_juros_multa-limite_correcao,
    PERC_LIMITE_CORRECAO   TYPE zari_juros_multa-perc_limite_correcao,
  END OF ty_cod_multajuros,
  tty_cod_multajuros TYPE STANDARD TABLE OF ty_cod_multajuros,

  BEGIN OF ty_tipo_imposto,
    tipo_imposto  TYPE zari_tp_imposto-tipo_imposto,
    categ_imposto TYPE zari_tp_imposto-categ_imposto,
  END OF ty_tipo_imposto,
  tty_tipo_imposto TYPE STANDARD TABLE OF ty_tipo_imposto,

  BEGIN OF ty_resumo_impostos,
    codigo_imposto TYPE zari_cod_imposto-codigo_imposto,
    tipo_imposto   TYPE zari_tp_imposto-tipo_imposto,
    categ_imposto  TYPE zari_tp_imposto-categ_imposto,
    dia_vencimento TYPE zari_cod_imposto-dia_vencimento,
  END OF ty_resumo_impostos,
  tty_resumo_impostos TYPE STANDARD TABLE OF ty_resumo_impostos,

  BEGIN OF ty_bkpf,
    bukrs TYPE bkpf-bukrs,
    belnr TYPE bkpf-belnr,
    gjahr TYPE bkpf-gjahr,
    cpudt TYPE bkpf-cpudt,
* MFS 06/04/2016 -
    budat TYPE bkpf-budat,
* MFS 06/04/2016 -
    tcode TYPE bkpf-tcode,
    awtyp TYPE bkpf-awtyp,
    stblg TYPE bkpf-stblg,
    stjah TYPE bkpf-stjah,
  END OF ty_bkpf,
  tty_bkpf        TYPE STANDARD TABLE OF ty_bkpf,

  tty_range_hkont TYPE RANGE OF bsis-hkont,
  ty_range_hkont  TYPE LINE OF tty_range_hkont,

  BEGIN OF ty_bsis,
    bukrs TYPE bsis-bukrs,
    hkont TYPE bsis-hkont,
*    augdt TYPE bsik-augdt,
*    augbl TYPE bsik-augbl,
*    zuonr TYPE bsik-zuonr,
    gjahr TYPE bsis-gjahr,
    belnr TYPE bsis-belnr,
    buzei TYPE bsis-buzei,
    budat TYPE budat,
    bldat TYPE bldat,
    waers TYPE waers,
    monat TYPE monat,
    bschl TYPE bsis-bschl,
    gsber TYPE gsber,
    shkzg TYPE bsis-shkzg,
    dmbtr TYPE bsis-dmbtr,
    valut TYPE valut,
    "ebeln
    bupla TYPE bsis-bupla,
    tcode TYPE bkpf-tcode,
    awtyp TYPE bkpf-awtyp,
  END OF ty_bsis,
  tty_bsis TYPE STANDARD TABLE OF ty_bsis,

  BEGIN OF ty_bsik,
    bukrs TYPE bsik-bukrs,
    lifnr TYPE bsik-lifnr,
    umsks TYPE bsik-umsks,
    umskz TYPE bsik-umskz,
*    augdt TYPE bsik-augdt,
*    augbl TYPE bsik-augbl,
*    zuonr TYPE bsik-zuonr,
    gjahr TYPE bsik-gjahr,
    belnr TYPE bsik-belnr,
    buzei TYPE bsik-buzei,
  END OF ty_bsik,
  tty_bsik TYPE STANDARD TABLE OF ty_bsik,

  BEGIN OF ty_bseg,
    bukrs TYPE bseg-bukrs,
    gjahr TYPE bseg-gjahr,
    belnr TYPE bseg-belnr,
    buzei TYPE bseg-buzei,
    shkzg TYPE bseg-shkzg,
    hkont TYPE bseg-hkont,
    koart TYPE bseg-koart,
    lifnr TYPE bseg-lifnr,
  END OF ty_bseg,
  tty_bseg TYPE STANDARD TABLE OF ty_bseg,

  BEGIN OF ty_doc,
    docnum TYPE j_1bnfdoc-docnum,
    doctyp TYPE j_1bnfdoc-doctyp,
    direct TYPE j_1bnfdoc-direct,
    nfnum  TYPE j_1bnfdoc-nfnum,
    belnr  TYPE j_1bnfdoc-belnr,
    gjahr  TYPE j_1bnfdoc-gjahr,
    bukrs  TYPE j_1bnfdoc-bukrs,
    branch TYPE j_1bnfdoc-branch,
    docref TYPE j_1bnfdoc-docref,     "incluido documento de referencia para notas canceladas
    parvw  TYPE j_1bnfdoc-parvw,
    parid  TYPE j_1bnfdoc-parid,
    partyp TYPE j_1bnfdoc-partyp,
    cancel TYPE j_1bnfdoc-cancel,
    nfenum TYPE j_1bnfdoc-nfenum,
    nfesrv TYPE j_1bnfdoc-nfesrv,
    cgc    TYPE j_1bnfdoc-cgc,
    txjcd  TYPE j_1bnfdoc-txjcd,
  END OF ty_doc,
  tty_doc TYPE STANDARD TABLE OF ty_doc,

  BEGIN OF ty_stx,
    docnum  TYPE j_1bnfstx-docnum,
    itmnum  TYPE j_1bnfstx-itmnum,
    taxtyp  TYPE j_1bnfstx-taxtyp,
    taxval  TYPE j_1bnfstx-taxval,
    tax_loc TYPE j_1bnfstx-tax_loc,
    taxgrp  TYPE j_1bnfstx-taxgrp,
  END OF ty_stx,
  tty_stx TYPE STANDARD TABLE OF ty_stx,

  BEGIN OF ty_lin,
    docnum   TYPE j_1bnflin-docnum,
    itmnum   TYPE j_1bnflin-itmnum,
    refkey   TYPE j_1bnflin-refkey,   " chave de referencia
    refitm   TYPE j_1bnflin-refitm,   " Item da Chave de Referencia
    xped     TYPE j_1bnflin-xped,
    nitemped TYPE j_1bnflin-nitemped,
    taxlw3   TYPE j_1bnflin-taxlw3,
    nbm      TYPE j_1bnflin-nbm,
    ebeln    TYPE ekkn-ebeln,
    ebelp    TYPE ekkn-ebelp,
  END OF ty_lin,
  tty_lin TYPE STANDARD TABLE OF ty_lin,

 BEGIN OF ty_rseg,
    belnr   TYPE rseg-belnr,
    gjahr   TYPE rseg-gjahr,
    buzei   TYPE rseg-buzei,
    ebeln   TYPE rseg-ebeln,
    ebelp   TYPE rseg-ebelp,
    zekkn   TYPE rseg-zekkn,
    bwkey   TYPE rseg-bwkey,
    bukrs   TYPE rseg-bukrs,
    werks   TYPE rseg-werks,
    txjcd   TYPE rseg-txjcd,
  END OF ty_rseg,
  tty_rseg TYPE STANDARD TABLE OF ty_rseg,

  BEGIN OF ty_txjurt,
    taxjurcode TYPE j_1btxjurt-taxjurcode,
    text       TYPE j_1btxjurt-text,
  END OF ty_txjurt,
  tty_txjurt TYPE STANDARD TABLE OF ty_txjurt,

  BEGIN OF ty_ekpo,
    ebeln      TYPE ekpo-ebeln,
    ebelp      TYPE ekpo-ebelp,
    txjcd      TYPE ekpo-txjcd,
  END OF ty_ekpo,
  tty_ekpo TYPE STANDARD TABLE OF ty_ekpo,

BEGIN OF ty_ekkn,
    ebeln      TYPE ekkn-ebeln,
    ebelp      TYPE ekkn-ebelp,
    zekkn      TYPE ekkn-zekkn,
    kostl      TYPE ekkn-kostl,
    projn      TYPE ekkn-projn,
    aufnr      TYPE ekkn-aufnr,
    prctr      TYPE ekkn-prctr,
    ps_psp_pnr TYPE ekkn-ps_psp_pnr,
  END OF ty_ekkn,
  tty_ekkn TYPE STANDARD TABLE OF ty_ekkn,
  BEGIN OF ty_witem,
    bukrs    TYPE with_item-bukrs,
    belnr    TYPE with_item-belnr,
    gjahr    TYPE with_item-gjahr,
    buzei    TYPE with_item-buzei,
    witht    TYPE with_item-witht,
*    WERKS    TYPE with_item-WERKS,
    wt_qbshh TYPE with_item-wt_qbshh,
    wt_acco  TYPE with_item-wt_acco,
  END OF ty_witem,
  BEGIN OF ty_glt0,
    RLDNR TYPE glt0-rldnr,
    RRCTY TYPE glt0-rrcty,
    RVERS TYPE glt0-rvers,
    BUKRS TYPE glt0-bukrs,
    RYEAR TYPE glt0-ryear,
    RACCT TYPE glt0-racct,
    RBUSA TYPE glt0-rbusa,
    RTCUR TYPE glt0-rtcur,
    DRCRK TYPE glt0-drcrk,
    RPMAX TYPE glt0-rpmax,
    HSLVT TYPE glt0-hslvt,
  END OF ty_glt0,
  tty_glt0   TYPE STANDARD TABLE OF ty_glt0,

  BEGIN OF ty_comp_manual,
    BUKRS TYPE BSEG-BUKRS,
    GSBER TYPE BSEG-GSBER,
    GJAHR TYPE BSIS-GJAHR,
    MONAT TYPE BSIS-MONAT,
    HKONT TYPE BSEG-HKONT,
  END OF ty_comp_manual,
  tty_comp_manual   TYPE STANDARD TABLE OF ty_comp_manual,

  tty_witem  TYPE STANDARD TABLE OF ty_witem,

  tty_header TYPE STANDARD TABLE OF zari_bkpf,

  tty_item   TYPE STANDARD TABLE OF zari_bseg,

  BEGIN OF ty_responsavel,
    codigo_usuario TYPE zari_responsavel-codigo_usuario,
    categ_imposto  TYPE zari_responsavel-categ_imposto,
  END OF ty_responsavel,
  tty_responsavel TYPE STANDARD TABLE OF ty_responsavel,

  tty_data        TYPE RANGE OF sy-datum,
  ty_data         TYPE LINE OF tty_data.

CONSTANTS:

* MFS 06/04/2016 -
* variaevl constante com valor ' ' - trabalhar com Data de Lançamento e com valor 'X' - trabalhar com data de entrada
  c_l_cpudt     TYPE CHAR1 VALUE ' ',
* MFS 06/04/2016 -
  c_a_pagar     TYPE char1 VALUE '-',
  c_a_recuperar TYPE char1 VALUE '+'.

DATA:
  l_cpudt        TYPE CHAR1,
  gt_empresa     TYPE tty_empresa,
  gt_cod_imposto TYPE tty_cod_imposto,
  gt_tp_imposto  TYPE tty_tipo_imposto,
  gt_resumo_imp  TYPE tty_resumo_impostos,
  gt_bkpf        TYPE tty_bkpf,
  gt_bsis        TYPE tty_bsis,
  gt_bsik        TYPE tty_bsik,
  gt_bseg        TYPE tty_bseg,
  gt_doc         TYPE tty_doc,
  gt_stx         TYPE tty_stx,
  gt_lin         TYPE tty_lin,
  gt_rseg        TYPE tty_rseg,   " item de documeno revisão de fatura
  gt_ekkn        TYPE tty_ekkn,
  gt_ekpo        TYPE tty_ekpo,
  gt_txjurt      TYPE tty_txjurt,
  gt_witem       TYPE tty_witem.

DATA :
  gt_comp_manual    TYPE tty_comp_manual,
  gt_cod_multajuros TYPE tty_cod_multajuros,
  gt_comp_rec       TYPE tty_cod_multajuros.

FIELD-SYMBOLS:
  <empresa>     TYPE ty_empresa,
  <cod_imposto> TYPE ty_cod_imposto,
  <bkpf>        TYPE ty_bkpf,
  <bseg>        TYPE ty_bseg,
  <bsis>        TYPE ty_bsis,
  <doc>         TYPE ty_doc,
  <stx>         TYPE ty_stx,
  <lin>         TYPE ty_lin,
  <rseg>        TYPE ty_rseg,
  <ekkn>        TYPE ty_ekkn,
  <ekpo>        TYPE ty_ekpo,
  <txjurt>      TYPE ty_txjurt,
  <witem>       TYPE ty_witem,
  <header>      TYPE zari_bkpf,
  <item>        TYPE zari_bseg,
  <cod_multa>   TYPE ty_cod_multajuros,
  <cod_compe>   TYPE ty_cod_multajuros.

DEFINE _set_intervalo_semanal.
  CALL FUNCTION 'GET_WEEK_INFO_BASED_ON_DATE'
          EXPORTING
            date   = sy-datum
          IMPORTING
            monday = &1.

        &1 = &1 - 7.
        &2 = &1 + 5.
END-OF-DEFINITION.

DEFINE _set_intervalo_mensal.
  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
  EXPORTING
    date      = &1  "sy-datum
    days      = 0
    months    = &3
    signum    = '-'
    years     = 0
  IMPORTING
    calc_date = &1.
&1+6 = '01'.
CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
  EXPORTING
    day_in            = &1
  IMPORTING
    last_day_of_month = &2.
END-OF-DEFINITION.

DEFINE _set_intervalo_trimestral.

  _set_intervalo_mensal &1 &2 1.

  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
  EXPORTING
    date      = &1
    days      = 0
    months    = &3
    signum    = '-'
    years     = 0
  IMPORTING
    calc_date = &1.

END-OF-DEFINITION.

DEFINE _set_intervalo_semestral.

  _set_intervalo_mensal &1 &2 1.

  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
  EXPORTING
    date      = &1
    days      = 0
    months    = &3
    signum    = '-'
    years     = 0
  IMPORTING
    calc_date = &1.

END-OF-DEFINITION.

DEFINE _set_intervalo_anual.
  _set_intervalo_mensal &1 &2 &3.

  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
  EXPORTING
    date      = &1
    days      = 0
    months    = &3
    signum    = '-'
    years     = 0
  IMPORTING
    calc_date = &1.

END-OF-DEFINITION.

DEFINE _set_intervalo_acumulado.
  _set_intervalo_mensal &1 &2 1.

*  &1+6 = '01'.

  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
  EXPORTING
    date      = &1
    days      = 0
    months    = &3
    signum    = '-'
    years     = 0
  IMPORTING
    calc_date = &1.

END-OF-DEFINITION.
DEFINE _branch_read.
  CALL FUNCTION 'J_1B_BRANCH_READ'
    EXPORTING
      branch     = &2
      company    = &1
    IMPORTING
      cgc_number = &3.
END-OF-DEFINITION.

DEFINE _company_read.
  CALL FUNCTION 'J_1BREAD_CGC_COMPANY'
    EXPORTING
      bukrs      = &1
    IMPORTING
      cgc_number = &2.
END-OF-DEFINITION.
