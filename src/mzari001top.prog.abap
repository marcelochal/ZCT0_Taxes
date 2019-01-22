*&---------------------------------------------------------------------*
*& Include MZARI001TOP                                       PoolMóds.        SAPMZARI001
*&
*&---------------------------------------------------------------------*
PROGRAM sapmzari001 MESSAGE-ID zari.

CONTROLS:
          tab_cockpit TYPE TABSTRIP.

TYPES:
  BEGIN OF ty_categ,
    check     TYPE sap_bool,
    valor     TYPE char1,
    descricao TYPE char15,
  END OF ty_categ,
  tty_categ TYPE STANDARD TABLE OF ty_categ,

  BEGIN OF ty_tp_imposto,
    tipo_imposto  TYPE zari_tp_imposto-tipo_imposto,
    categ_imposto TYPE zari_tp_imposto-categ_imposto,
    check         TYPE sap_bool,
  END OF ty_tp_imposto,
  tty_tp_imposto TYPE STANDARD TABLE OF ty_tp_imposto,

  ty_cod_imposto type ZARI_COCKPIT_COD_IMPOSTO_ALV,
  tty_cod_imposto TYPE STANDARD TABLE OF ty_cod_imposto,

  ty_J_1BTXJURT type J_1BTXJURT,
  tty_J_1BTXJURT type standard table of ty_J_1BTXJURT,

  begin of ty_lfa1,
    lifnr type lfa1-lifnr,
    name1 type lfa1-name1,
    mcod1 type lfa1-mcod1,
  end of ty_lfa1,
  tty_lfa1 type STANDARD TABLE OF ty_lfa1,

  ty_empresa type ZARI_COCKPIT_EMPRESA_ALV,
  tty_empresa TYPE STANDARD TABLE OF ty_empresa,

  BEGIN OF ty_emprdiv,
    empresa_div(11) TYPE c,
    check           TYPE sap_bool,
  END OF ty_emprdiv,
  tty_emprdiv TYPE STANDARD TABLE OF ty_emprdiv,

  ty_bkpf type ZARI_COCKPIT_BKPF_ALV,
  tty_bkpf TYPE STANDARD TABLE OF ty_bkpf,

  ty_bseg type zari_cockpit_bseg_alv,
  tty_bseg TYPE STANDARD TABLE OF ty_bseg,

  ty_saida_1300 type ZARI_COCKPIT_BKPF_ALV3,
  tty_saida_1300 TYPE STANDARD TABLE OF ty_saida_1300,

  begin of ty_bkpf_std,
    bukrs type bkpf-bukrs, "Empresa
    belnr type bkpf-belnr, "Nº documento de um documento contábil
    gjahr type bkpf-gjahr, "Exercício
    xstov type bkpf-xstov, "Código: documento marcado para estorno
  end of ty_bkpf_std,
  tty_bkpf_std type table of ty_bkpf_std,

  begin of ty_vbkpf,
    ausbk type vbkpf-ausbk, "Empresa inicial
    bukrs type vbkpf-bukrs, "Empresa
    belnr type vbkpf-belnr, "Nº documento de um documento contábil
    gjahr type vbkpf-gjahr, "Exercício
  end of ty_vbkpf,
  tty_vbkpf type table of ty_vbkpf,

  begin of ty_bsik,
    BUKRS type bsik-BUKRS, "Empresa
    LIFNR type bsik-LIFNR, "Nº conta do fornecedor
    UMSKS type bsik-UMSKS, "Classe de operação de Razão Especial
    UMSKZ type bsik-UMSKZ, "Código de Razão Especial
    AUGDT type bsik-AUGDT, "Data de compensação
    AUGBL type bsik-AUGBL, "Nº documento de compensação
    ZUONR type bsik-ZUONR, "Nº atribuição
    GJAHR type bsik-GJAHR, "Exercício
    BELNR type bsik-BELNR, "Nº documento de um documento contábil
    BUZEI type bsik-BUZEI, "Nº linha de lançamento no documento contábil
  end of ty_bsik,
  tty_bsik type table of ty_bsik,

  begin of ty_vbsegs,
    AUSBK type vbsegs-AUSBK, "Empresa inicial
    BELNR type vbsegs-BELNR, "Nº documento de um documento contábil
    GJAHR type vbsegs-GJAHR, "Exercício
    BZKEY type vbsegs-bzkey, "Nº linha de lançamento no documento contábil
  end of ty_vbsegs,
  tty_vbsegs type table of ty_vbsegs,

  BEGIN OF ty_resp,
    categ_imposto TYPE zari_responsavel-categ_imposto,
  END OF ty_resp,
  tty_resp TYPE STANDARD TABLE OF ty_resp,

  BEGIN OF ty_manut,
    monat       type monat,
    gjahr       type gjahr,
    NUM_DOC_APURACAO type zari_bkpf-NUM_DOC_APURACAO,
    pre_atualiz type xfeld,
    pre_estorno type xfeld,
    apu_estorno type xfeld,
    rec_estorno type xfeld,
  END OF ty_manut.

DATA:

  gv_okcode           TYPE syucomm,

*&- Autorizações
  gv_auth_apu01       TYPE char1, "Apuração - Visualizar
  gv_auth_apu02       TYPE char1, "Apuração - Gravar
  gv_auth_apu03       TYPE char1, "Apuração - Liberar
  gv_auth_rec01       TYPE char1, "Recolhimento - Visualizar
  gv_auth_rec02       TYPE char1, "Recolhimento - Gravar
  gv_auth_rec03       TYPE char1, "Recolhimento - Liberar
  gv_auth_consu       TYPE char1, "Consulta
  gv_auth_man01       TYPE char1, "Manutenção - Visualizar
  gv_auth_man02       TYPE char1, "Manutenção - Nova Seleção
  gv_auth_man03       TYPE char1, "Manutenção - Estornar Pré-Apuração
  gv_auth_man04       TYPE char1, "Manutenção - Estornar Apuração
  gv_auth_man05       TYPE char1, "Manutenção - Estornar Recolhimento

  gt_rg_resp          TYPE RANGE OF zari_responsavel-categ_imposto,

  gt_1100_categ       TYPE tty_categ,
  gt_1100_tp_imposto  TYPE tty_tp_imposto,
  gt_1100_cod_imposto TYPE tty_cod_imposto,
  gt_1100_empresa     TYPE tty_empresa,
  gt_1100_emprdiv     TYPE tty_emprdiv,
  gt_1100_bkpf        TYPE tty_bkpf,
  gt_1100_bkpf_aux    TYPE tty_bkpf,
  gt_1100_bseg        TYPE tty_bseg,

  go_1100_salv11      TYPE REF TO cl_salv_table,
  go_1100_salv12      TYPE REF TO cl_salv_table,
  go_1100_salv13      TYPE REF TO cl_salv_table,
  go_1100_salv14      TYPE REF TO cl_salv_table,
  go_1100_salv22      TYPE REF TO cl_salv_table,
  go_1100_salv31      TYPE REF TO cl_salv_table,

  gt_1200_categ       TYPE tty_categ,
  gt_1200_tp_imposto  TYPE tty_tp_imposto,
  gt_1200_cod_imposto TYPE tty_cod_imposto,
  gt_1200_empresa     TYPE tty_empresa,
  gt_1200_emprdiv     TYPE tty_emprdiv,
  gt_1200_bkpf        TYPE tty_bkpf,
  gt_1200_bkpf_aux    TYPE tty_bkpf,
  gt_1200_bseg        TYPE tty_bseg,

  go_1200_salv11      TYPE REF TO cl_salv_table,
  go_1200_salv12      TYPE REF TO cl_salv_table,
  go_1200_salv13      TYPE REF TO cl_salv_table,
  go_1200_salv14      TYPE REF TO cl_salv_table,
  go_1200_salv22      TYPE REF TO cl_salv_table,
  go_1200_salv31      TYPE REF TO cl_salv_table,

  go_1300_salv21      TYPE REF TO cl_salv_table,
  gt_1300_saida       TYPE tty_saida_1300,

  gt_1400_categ       TYPE tty_categ,
  gt_1400_tp_imposto  TYPE tty_tp_imposto,
  gt_1400_cod_imposto TYPE tty_cod_imposto,
  gt_1400_empresa     TYPE tty_empresa,
  gt_1400_emprdiv     TYPE tty_emprdiv,

  go_1400_salv11      TYPE REF TO cl_salv_table,
  go_1400_salv12      TYPE REF TO cl_salv_table,
  go_1400_salv13      TYPE REF TO cl_salv_table,
  go_1400_salv14      TYPE REF TO cl_salv_table,

  go_1100_custom      TYPE REF TO cl_gui_custom_container,
  go_1200_custom      TYPE REF TO cl_gui_custom_container,
  go_1300_custom      TYPE REF TO cl_gui_custom_container,
  go_1400_custom      TYPE REF TO cl_gui_custom_container,

  go_1300_splitter    TYPE REF TO cl_gui_splitter_container,
  go_1300_grid        TYPE REF TO cl_gui_container,

  o_splitter          TYPE REF TO cl_gui_splitter_container,
  o_splitter_top      TYPE REF TO cl_gui_splitter_container,
  o_splitter_mid      TYPE REF TO cl_gui_splitter_container,
  o_splitter_bot      TYPE REF TO cl_gui_splitter_container,
  o_top               TYPE REF TO cl_gui_container,
  o_mid               TYPE REF TO cl_gui_container,
  o_bot               TYPE REF TO cl_gui_container,

  go_1100_grid11      TYPE REF TO cl_gui_container,
  go_1100_grid12      TYPE REF TO cl_gui_container,
  go_1100_grid13      TYPE REF TO cl_gui_container,
  go_1100_grid14      TYPE REF TO cl_gui_container,
  go_1100_screen21    TYPE REF TO cl_gui_container,
  go_1100_grid22      TYPE REF TO cl_gui_container,
  go_1100_grid31      TYPE REF TO cl_gui_container,
  go_1200_grid11      TYPE REF TO cl_gui_container,
  go_1200_grid12      TYPE REF TO cl_gui_container,
  go_1200_grid13      TYPE REF TO cl_gui_container,
  go_1200_grid14      TYPE REF TO cl_gui_container,
  go_1200_grid22      TYPE REF TO cl_gui_container,
  go_1200_grid31      TYPE REF TO cl_gui_container,

  go_1400_grid11      TYPE REF TO cl_gui_container,
  go_1400_grid12      TYPE REF TO cl_gui_container,
  go_1400_grid13      TYPE REF TO cl_gui_container,
  go_1400_grid14      TYPE REF TO cl_gui_container,

  sel_1100_monat TYPE REF TO cl_dd_select_element,
  sel_1200_monat TYPE REF TO cl_dd_select_element,
  sel_1300_monat TYPE REF TO cl_dd_select_element,
  inp_1100_gjahr TYPE REF TO cl_dd_input_element,
  inp_1200_gjahr TYPE REF TO cl_dd_input_element,
  inp_1300_gjahr TYPE REF TO cl_dd_input_element,
*  input_1200_barcode  TYPE REF TO cl_dd_input_element,
  input_1200_ref      TYPE REF TO cl_dd_input_element,
  input_1200_valor    TYPE REF TO cl_dd_input_element,
  input_1200_multa    TYPE REF TO cl_dd_input_element,
  input_1200_juros    TYPE REF TO cl_dd_input_element,

  gs_1210_bkpf_alv type zari_cockpit_bkpf_alv.

*  go_1200_event_handler_21 TYPE REF TO lcl_1200_event_handler_21.
DATA: button0    TYPE REF TO cl_dd_button_element,
      button1    TYPE REF TO cl_dd_button_element,
      button2    TYPE REF TO cl_dd_button_element,
      button3    TYPE REF TO cl_dd_button_element,
      button4    TYPE REF TO cl_dd_button_element,
      button5    TYPE REF TO cl_dd_button_element,
      dd_doc_btn TYPE REF TO cl_dd_document,
      form_btn   TYPE REF TO cl_dd_form_area.

*&---------------------------------------------------------------------*
*& Declarações para carga na ZPAG
*&---------------------------------------------------------------------*
DATA: ws_1200_bkpf  LIKE LINE OF gt_1200_bkpf,
      wa_1400_manut type ty_manut.

*--> Início - Alteração  21.12.2018 10:07:45 - WR005118
data WV_CODBAR(56) type c.
*<-- Fim - 21.12.2018 10:07:45
