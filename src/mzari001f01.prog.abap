*&---------------------------------------------------------------------*
*&  Include           MZARI001F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SELECIONA_RESP
*&---------------------------------------------------------------------*
FORM seleciona_resp  CHANGING pt_rg_resp LIKE gt_rg_resp[].
  DATA:
        lt_resp TYPE tty_resp.

  SELECT categ_imposto
  INTO TABLE lt_resp
  FROM zari_responsavel
  WHERE codigo_usuario = sy-uname.

  pt_rg_resp[] = zcl_utils=>get_range_of_table( im_table = lt_resp
                                                im_field = 'CATEG_IMPOSTO' ).

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FILL_CATEG
*&---------------------------------------------------------------------*
FORM fill_categ  CHANGING pt_categ TYPE tty_categ.
  DATA:
    ls_categ LIKE LINE OF pt_categ,
    lt_dd07v TYPE STANDARD TABLE OF dd07v,
    ls_dd07v TYPE dd07v.

  CHECK gt_rg_resp[] IS NOT INITIAL.

  CALL FUNCTION 'GET_DOMAIN_VALUES'
    EXPORTING
      domname    = 'ZARI_CATEG_IMPOSTO'
    TABLES
      values_tab = lt_dd07v.


  LOOP AT lt_dd07v INTO ls_dd07v.
    CHECK ls_dd07v-domvalue_l IN gt_rg_resp.
    ls_categ-valor = ls_dd07v-domvalue_l.
    ls_categ-descricao = ls_dd07v-ddtext.

    APPEND ls_categ TO pt_categ.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_SALV11
*&---------------------------------------------------------------------*
FORM fieldcat_1100_1200_salv11  CHANGING pr_table TYPE REF TO cl_salv_table.

  DATA:
    lr_column             TYPE REF TO cl_salv_column_table,
    lo_event_handler_1100 TYPE REF TO lcl_1100_event_handler_11,
    lo_event_handler_1200 TYPE REF TO lcl_1200_event_handler_11,
    lo_event_handler_1400 TYPE REF TO lcl_1400_event_handler_11,
    lo_events             TYPE REF TO cl_salv_events_table.

  lr_column ?= pr_table->get_columns( )->get_column( 'CHECK' ).
  lr_column->set_icon( abap_true ).
  lr_column->set_cell_type( if_salv_c_cell_type=>checkbox_hotspot ).
  lr_column->set_output_length( 3 ).

*  pr_table->get_columns( )->set_column_position(  columnname = 'CHECK'
*                                                  position   = 1 ).

  lr_column ?= pr_table->get_columns( )->get_column( 'DESCRICAO' ).
  lr_column->set_long_text( 'Categoria' ).
  lr_column->set_output_length( 23 ).

  lr_column ?= pr_table->get_columns( )->get_column( 'VALOR' ).
  lr_column->set_visible( abap_false ).

  lo_events = pr_table->get_event( ).
  CASE sy-dynnr.
    WHEN '1100'.
      CREATE OBJECT lo_event_handler_1100.
      SET HANDLER lo_event_handler_1100->on_link_click FOR lo_events.
    WHEN '1200'.
      CREATE OBJECT lo_event_handler_1200.
      SET HANDLER lo_event_handler_1200->on_link_click FOR lo_events.
    WHEN '1400'.
      CREATE OBJECT lo_event_handler_1400.
      SET HANDLER lo_event_handler_1400->on_link_click FOR lo_events.
  ENDCASE.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FILL_TP_IMPOSTO
*&---------------------------------------------------------------------*
FORM fill_tp_imposto  USING    pt_categ TYPE tty_categ
                      CHANGING pt_tp_imposto TYPE tty_tp_imposto.

* Só prossegue se houver filtro
  CHECK NOT pt_categ[] IS INITIAL.

  SELECT tipo_imposto categ_imposto
  FROM zari_tp_imposto
  INTO TABLE pt_tp_imposto
  FOR ALL ENTRIES IN pt_categ
  WHERE categ_imposto = pt_categ-valor.

  SORT pt_tp_imposto BY categ_imposto ASCENDING.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_SALV12
*&---------------------------------------------------------------------*
FORM fieldcat_1100_1200_salv12  CHANGING pr_table TYPE REF TO cl_salv_table.
  DATA:
    lr_column             TYPE REF TO cl_salv_column_table,
    lo_event_handler_1100 TYPE REF TO lcl_1100_event_handler_12,
    lo_event_handler_1200 TYPE REF TO lcl_1200_event_handler_12,
    lo_event_handler_1400 TYPE REF TO lcl_1400_event_handler_12,
    lo_events             TYPE REF TO cl_salv_events_table.

  lr_column ?= pr_table->get_columns( )->get_column( 'CHECK' ).
  lr_column->set_cell_type( if_salv_c_cell_type=>checkbox_hotspot ).
  lr_column->set_output_length( 3 ).

  pr_table->get_columns( )->set_column_position(  columnname = 'CHECK'
                                                  position   = 1 ).

  lr_column ?= pr_table->get_columns( )->get_column( 'TIPO_IMPOSTO' ).
*  lr_column->set_short_text( 'Tipo de Imposto' ).
  lr_column->set_medium_text( 'Tipo de Imposto' ).
  lr_column->set_long_text( 'Tipo de Imposto' ).
  lr_column->set_output_length( 20 ).

  lr_column ?= pr_table->get_columns( )->get_column( 'CATEG_IMPOSTO' ).
  lr_column->set_visible( abap_false ).

  lo_events = pr_table->get_event( ).

  CASE sy-dynnr.
    WHEN '1100'.
      CREATE OBJECT lo_event_handler_1100.
      SET HANDLER lo_event_handler_1100->on_link_click FOR lo_events.
    WHEN '1200'.
      CREATE OBJECT lo_event_handler_1200.
      SET HANDLER lo_event_handler_1200->on_link_click FOR lo_events.
    WHEN '1400'.
      CREATE OBJECT lo_event_handler_1400.
      SET HANDLER lo_event_handler_1400->on_link_click FOR lo_events.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FILL_COD_IMPOSTO
*&---------------------------------------------------------------------*
FORM fill_cod_imposto  USING    pt_tp_imposto TYPE tty_tp_imposto
                       CHANGING pt_cod_imposto TYPE tty_cod_imposto.

* Só prossegue se houver filtro
  CHECK NOT pt_tp_imposto[] IS INITIAL.

  SELECT *
  FROM zari_cod_imposto
  INTO TABLE pt_cod_imposto
  FOR ALL ENTRIES IN pt_tp_imposto
  WHERE tipo_imposto = pt_tp_imposto-tipo_imposto.

  SORT pt_cod_imposto BY codigo_imposto ASCENDING.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_1100_SALV13
*&---------------------------------------------------------------------*
FORM fieldcat_1100_1200_salv13  CHANGING pr_table TYPE REF TO cl_salv_table.
  DATA:
    lr_column             TYPE REF TO cl_salv_column_table,
    lo_event_handler_1100 TYPE REF TO lcl_1100_event_handler_13,
    lo_event_handler_1200 TYPE REF TO lcl_1200_event_handler_13,
    lo_event_handler_1400 TYPE REF TO lcl_1400_event_handler_13,
    lo_events             TYPE REF TO cl_salv_events_table,
    lt_fields             TYPE lvc_t_fcat,
    lv_field              LIKE LINE OF lt_fields.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = 'ZARI_COCKPIT_COD_IMPOSTO_ALV'
    CHANGING
      ct_fieldcat            = lt_fields
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  CHECK sy-subrc = 0.

  LOOP AT lt_fields INTO lv_field.
    lr_column ?= pr_table->get_columns( )->get_column( lv_field-fieldname ).

*   Colunas-chave são exibidas antes das demais, mesmo redefinindo sua posição
    lr_column->set_key( space ).

    CASE lv_field-fieldname.

      WHEN 'CHECK'.
        lr_column->set_cell_type( if_salv_c_cell_type=>checkbox_hotspot ).
        lr_column->set_output_length( 3 ).
        pr_table->get_columns( )->set_column_position(  columnname = 'CHECK'
                                                        position   = 1 ).

      WHEN 'CODIGO_IMPOSTO'.
        lr_column->set_medium_text( 'Cód' ).
        lr_column->set_long_text( 'Cód' ).
        lr_column->set_output_length( 5 ).

      WHEN 'DESCRICAO_IMPOSTO'.
        lr_column->set_medium_text( 'Código do Imposto' ).
        lr_column->set_long_text( 'Código do Imposto' ).
        lr_column->set_output_length( 18 ).

      WHEN 'DIRECAO'.

      WHEN OTHERS.
        lr_column->set_visible( abap_false ).
    ENDCASE.
  ENDLOOP.

  lo_events = pr_table->get_event( ).

  CASE sy-dynnr.
    WHEN '1100'.
      CREATE OBJECT lo_event_handler_1100.
      SET HANDLER lo_event_handler_1100->on_link_click FOR lo_events.
    WHEN '1200'.
      CREATE OBJECT lo_event_handler_1200.
      SET HANDLER lo_event_handler_1200->on_link_click FOR lo_events.
    WHEN '1400'.
      CREATE OBJECT lo_event_handler_1400.
      SET HANDLER lo_event_handler_1400->on_link_click FOR lo_events.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FILL_EMPRESA
*&---------------------------------------------------------------------*
FORM fill_empresa  USING    pt_cod_imposto TYPE tty_cod_imposto
                   CHANGING pt_empresa TYPE tty_empresa
                            pt_emprdiv TYPE tty_emprdiv.
  FIELD-SYMBOLS:
                 <empresa> TYPE ty_empresa.

  DATA: l_emprdiv LIKE LINE OF pt_emprdiv.

* Só prossegue se houver filtro
  CHECK NOT pt_cod_imposto[] IS INITIAL.

  SELECT e~mandt e~empresa e~codigo_imposto t~tipo_imposto t~categ_imposto gsber
  FROM zari_empresa AS e
  INNER JOIN zari_cod_imposto AS c ON c~codigo_imposto = e~codigo_imposto
  INNER JOIN zari_tp_imposto  AS t ON t~tipo_imposto   = c~tipo_imposto
  LEFT JOIN zaneel ON bukrs = e~empresa
  INTO TABLE pt_empresa
  FOR ALL ENTRIES IN pt_cod_imposto
  WHERE e~codigo_imposto = pt_cod_imposto-codigo_imposto.

  LOOP AT pt_empresa ASSIGNING <empresa>.
    IF <empresa>-gsber IS INITIAL.
      <empresa>-empresa_div = <empresa>-empresa.
    ELSE.
      CONCATENATE <empresa>-empresa <empresa>-gsber INTO <empresa>-empresa_div SEPARATED BY ' - '.
    ENDIF.
    l_emprdiv-empresa_div = <empresa>-empresa_div.
    READ TABLE pt_emprdiv WITH KEY empresa_div = l_emprdiv-empresa_div
                          TRANSPORTING NO FIELDS
                          BINARY SEARCH.
    CHECK sy-subrc <> 0.
    INSERT l_emprdiv INTO pt_emprdiv INDEX sy-tabix. "já ordenado
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_1100_SALV14
*&---------------------------------------------------------------------*
FORM fieldcat_1100_1200_salv14  CHANGING pr_table TYPE REF TO cl_salv_table.

  DATA:
    lr_column             TYPE REF TO cl_salv_column_table,
    lo_event_handler_1100 TYPE REF TO lcl_1100_event_handler_14,
    lo_event_handler_1200 TYPE REF TO lcl_1200_event_handler_14,
    lo_event_handler_1400 TYPE REF TO lcl_1400_event_handler_14,
    lo_events             TYPE REF TO cl_salv_events_table.

  lr_column ?= pr_table->get_columns( )->get_column( 'CHECK' ).
  lr_column->set_cell_type( if_salv_c_cell_type=>checkbox_hotspot ).
  lr_column->set_output_length( 3 ).

  pr_table->get_columns( )->set_column_position(  columnname = 'CHECK'
                                                  position   = 1 ).

  lr_column ?= pr_table->get_columns( )->get_column( 'EMPRESA_DIV' ).
  lr_column->set_medium_text( 'Empresa-Divisão' ).
  lr_column->set_long_text( 'Empresa-Divisão' ).
  lr_column->set_output_length( 15 ).

  lo_events = pr_table->get_event( ).

  CASE sy-dynnr.
    WHEN '1100'.
      CREATE OBJECT lo_event_handler_1100.
      SET HANDLER lo_event_handler_1100->on_link_click FOR lo_events.
    WHEN '1200'.
      CREATE OBJECT lo_event_handler_1200.
      SET HANDLER lo_event_handler_1200->on_link_click FOR lo_events.
    WHEN '1400'.
      CREATE OBJECT lo_event_handler_1400.
      SET HANDLER lo_event_handler_1400->on_link_click FOR lo_events.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_1100_SALV22
*&---------------------------------------------------------------------*
FORM fieldcat_1100_1200_salv22  USING    p_icon_recolh TYPE xfeld
                                CHANGING pr_table TYPE REF TO cl_salv_table.

  DATA:
    lr_column             TYPE REF TO cl_salv_column_table,
    lo_event_handler_1100 TYPE REF TO lcl_1100_event_handler_22,
    lo_event_handler_1200 TYPE REF TO lcl_1200_event_handler_22,
    lo_events             TYPE REF TO cl_salv_events_table,
    lt_fields             TYPE lvc_t_fcat,  "rsz_t_string,
    lv_field              LIKE LINE OF lt_fields.

*  lt_fields = zcl_utils=>get_itab_fields( gt_1100_bkpf ).
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = 'ZARI_COCKPIT_BKPF_ALV'
    CHANGING
      ct_fieldcat            = lt_fields
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  CHECK sy-subrc = 0.

  LOOP AT lt_fields INTO lv_field.
    lr_column ?= pr_table->get_columns( )->get_column( lv_field-fieldname ).

*   Colunas-chave são exibidas antes das demais, mesmo redefinindo sua posição
    lr_column->set_key( space ).
    lr_column->set_optimized( 'X' ).        "largura otimizada

    CASE lv_field-fieldname.
      WHEN 'CHECK'.
        lr_column->set_cell_type( if_salv_c_cell_type=>checkbox_hotspot ).
        lr_column->set_output_length( 3 ).
        pr_table->get_columns( )->set_column_position(  columnname = 'CHECK'
                                                        position   = 1 ).

      WHEN 'NOME_PERIODO'.
        lr_column->set_medium_text( 'NomePer' ).
        lr_column->set_long_text( 'NomePer' ).
        pr_table->get_columns( )->set_column_position(  columnname = 'NOME_PERIODO'
                                                        position   = 2 ).

      WHEN 'EMPRESA'.
        lr_column->set_medium_text( 'Empresa' ).
        lr_column->set_long_text( 'Empresa' ).
        lr_column->set_output_length( 4 ).
        pr_table->get_columns( )->set_column_position(  columnname = 'EMPRESA'
                                                        position   = 3 ).

      WHEN 'DIVISAO'.
        lr_column->set_medium_text( 'Divisão' ).
        lr_column->set_long_text( 'Divisão' ).
        lr_column->set_output_length( 4 ).
        pr_table->get_columns( )->set_column_position(  columnname = 'DIVISAO'
                                                        position   = 4 ).

      WHEN 'FILIAL'.
        lr_column->set_medium_text( 'Filial' ).
        lr_column->set_long_text( 'Filial' ).
        lr_column->set_output_length( 4 ).
        pr_table->get_columns( )->set_column_position(  columnname = 'FILIAL'
                                                        position   = 5 ).

      WHEN 'COD_FORNECEDOR'.
        lr_column->set_medium_text( 'Prestador' ).
        lr_column->set_long_text( 'Prestador' ).
        lr_column->set_output_length( 10 ).
        pr_table->get_columns( )->set_column_position(  columnname = 'COD_FORNECEDOR'
                                                        position   = 6 ).

*      WHEN 'REFERENCIA'.
*        lr_column->set_medium_text( 'Refer' ).
*        lr_column->set_long_text( 'Refer' ).
*        pr_table->get_columns( )->set_column_position(  columnname = 'REFERENCIA'
*                                                        position   = 6 ).

      WHEN 'MONTANTE_APURADO'.
        lr_column->set_short_text( 'VlrApura' ).
        lr_column->set_medium_text( 'VlrApura' ).
        lr_column->set_long_text( 'Valor Apurado' ).
        lr_column->set_currency_column('MOEDA').
        pr_table->get_columns( )->set_column_position(  columnname = 'MONTANTE_APURADO'
                                                        position   = 7 ).

      WHEN 'MONTANTE_RECOLHIMENTO'.
        IF NOT p_icon_recolh IS INITIAL.
          lr_column->set_short_text( 'VlrTotRec' ).
          lr_column->set_medium_text( 'VlrTotRec' ).
          lr_column->set_long_text( 'VlrTotRec' ).
          lr_column->set_currency_column('MOEDA').
          pr_table->get_columns( )->set_column_position(  columnname = 'MONTANTE_RECOLHIMENTO'
                                                          position   = 8 ).
        ELSE.
          lr_column->set_visible( abap_false ).
        ENDIF.

      WHEN 'NUM_DOC_APURACAO'.
        lr_column->set_medium_text( 'NrDocApura' ).
        lr_column->set_long_text( 'NrDocApura' ).
        lr_column->set_output_length( 4 ).
        pr_table->get_columns( )->set_column_position(  columnname = 'NUM_DOC_APURACAO'
                                                        position   = 9 ).

      WHEN 'SITUACAO'.
        lr_column->set_medium_text( 'Situação' ).
        lr_column->set_long_text( 'Situação' ).

      WHEN 'TIPO_IMPOSTO'.

      WHEN 'CODIGO_IMPOSTO'.

      WHEN 'UF'.

      WHEN 'DESCR_DOMICILIO'.
        lr_column->set_medium_text( 'Domicílio Fiscal' ).
        lr_column->set_long_text( 'Domicílio Fiscal' ).
        lr_column->set_optimized( 'X' ).        "largura otimizada

      WHEN 'ICON_RECOLH'.

        lr_column->set_cell_type( if_salv_c_cell_type=>hotspot ).
        lr_column->set_icon( 'X' ).
        lr_column->set_medium_text( 'Recolh.' ).
        lr_column->set_long_text( 'Dds.Recolh.' ).

*       Se o icone de dds.recolh. não deve ser exibido
        IF p_icon_recolh IS INITIAL.
          lr_column->set_technical( 'X' ).
        ENDIF.

      WHEN OTHERS.
        lr_column->set_visible( abap_false ).
    ENDCASE.
  ENDLOOP.

  lo_events = pr_table->get_event( ).

  CASE sy-dynnr.
    WHEN '1100'.
      CREATE OBJECT lo_event_handler_1100.
      SET HANDLER lo_event_handler_1100->on_link_click FOR lo_events.
      SET HANDLER lo_event_handler_1100->on_double_click FOR lo_events.
    WHEN '1200'.
      CREATE OBJECT lo_event_handler_1200.
      SET HANDLER lo_event_handler_1200->on_link_click FOR lo_events.
      SET HANDLER lo_event_handler_1200->on_double_click FOR lo_events.
  ENDCASE.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_1100_1200_SALV31
*&---------------------------------------------------------------------*
FORM fieldcat_1100_1200_salv31  CHANGING pr_table TYPE REF TO cl_salv_table.

  DATA:
    lr_column TYPE REF TO cl_salv_column_table,
    lr_cols   TYPE REF TO cl_salv_columns,
    lt_fields TYPE lvc_t_fcat,  "rsz_t_string,
    lv_field  LIKE LINE OF lt_fields.

*  lt_fields = zcl_utils=>get_itab_fields( gt_1100_bseg ).
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = 'ZARI_COCKPIT_BSEG_ALV'
    CHANGING
      ct_fieldcat            = lt_fields
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  CHECK sy-subrc = 0.

  LOOP AT lt_fields INTO lv_field.
    lr_column ?= pr_table->get_columns( )->get_column( lv_field-fieldname ).

*   Colunas-chave são exibidas antes das demais, mesmo redefinindo sua posição
*    lr_column->set_optimized( 'X' ).        "largura otimizada

    CASE lv_field-fieldname.

      WHEN 'ITEM_APURACAO'.
        lr_column->set_medium_text( 'Item' ).
        lr_column->set_long_text( 'Item' ).
        pr_table->get_columns( )->set_column_position(  columnname = 'ITEM_APURACAO'
                                                        position   = 2 ).

      WHEN 'NUMERO_PEDIDO'.
        lr_column->set_short_text( 'Refer.' ).
        lr_column->set_medium_text( 'Referência' ).
        lr_column->set_long_text( 'Referência' ).
        lr_column->set_cell_type( if_salv_c_cell_type=>hotspot ).  "hotspot
        pr_table->get_columns( )->set_column_position(  columnname = 'NUMERO_PEDIDO'
                                                        position   = 3 ).

      WHEN 'NUM_DOC_CONTABIL'.
        lr_column->set_medium_text( 'Nr.Doc.SAP' ).
        lr_column->set_long_text( 'Nr.Doc.SAP' ).
        lr_column->set_cell_type( if_salv_c_cell_type=>hotspot ).  "hotspot
        pr_table->get_columns( )->set_column_position(  columnname = 'NUM_DOC_CONTABIL'
                                                        position   = 4 ).
*     WHEN 'ITEM_LANCAMENTO'.
*       lr_column->set_medium_text( 'Item' ).
*       lr_column->set_long_text( 'Item' ).
*       pr_table->get_columns( )->set_column_position(  columnname = 'ITEM_LANCAMENTO'
*       position   = 5 ).

      WHEN 'NOTA_FISCAL'.
        lr_column->set_short_text( 'Nr.NF' ).
        lr_column->set_medium_text( 'Nr.NF' ).
        lr_column->set_long_text( 'Nr.NF' ).
        pr_table->get_columns( )->set_column_position(  columnname = 'NOTA_FISCAL'
                                                        position   = 7 ).
      WHEN 'CONTA_CONTABIL'.
        lr_column->set_medium_text( 'Conta' ).
        lr_column->set_long_text( 'Conta' ).
        lr_column->set_output_length( 10 ).
        pr_table->get_columns( )->set_column_position(  columnname = 'CONTA_CONTABIL'
                                                        position   = 11 ).

      WHEN 'DATA_ENTRADA'.
        lr_column->set_short_text( 'Dt.Ent.' ).
        lr_column->set_medium_text( 'Dt.Ent.' ).
        lr_column->set_long_text( 'Dt.Ent.' ).
        lr_column->set_output_length( 10 ).
        pr_table->get_columns( )->set_column_position(  columnname = 'DATA_ENTRADA'
                                                        position   = 8 ).

      WHEN 'DATA_DOCUMENTO'.
        lr_column->set_short_text( 'Dt.Doc.' ).
        lr_column->set_medium_text( 'Dt.Doc.' ).
        lr_column->set_long_text( 'Dt.Doc.' ).
        lr_column->set_output_length( 10 ).
        pr_table->get_columns( )->set_column_position(  columnname = 'DATA_DOCUMENTO'
                                                        position   = 9 ).

      WHEN 'DATA_LANCAMENTO'.
        lr_column->set_short_text( 'Dt.Lçto.' ).
        lr_column->set_medium_text( 'Dt.Lçto.' ).
        lr_column->set_long_text( 'Dt.Lçto.' ).
        lr_column->set_output_length( 10 ).
        pr_table->get_columns( )->set_column_position(  columnname = 'DATA_LANCAMENTO'
                                                      position   = 10 ).

      WHEN 'LFA1_MCOD1'.
        lr_column->set_short_text( 'Prestador' ).
        lr_column->set_medium_text( 'Nome do prestador' ).
        lr_column->set_long_text( 'Nome do prestador' ).
        lr_column->set_output_length( 15 ).
        pr_table->get_columns( )->set_column_position(  columnname = 'LFA1_MCOD1'
                                                      position   = 9 ).

      WHEN 'MONTANTE'.
        lr_column->set_medium_text( 'Montante' ).
        lr_column->set_long_text( 'Montante' ).
        pr_table->get_columns( )->set_column_position(  columnname = 'MONTANTE'
                                                      position   = 10 ).

      WHEN 'ORDEM_ELEMPEP'.
        lr_column->set_medium_text( 'Ordem/Elem.PEP' ).
        lr_column->set_long_text( 'Ordem/Elem.PEP' ).
        pr_table->get_columns( )->set_column_position(  columnname = 'ORDEM_ELEMPEP'
                                                      position   = 15 ).
      WHEN OTHERS.
        lr_column->set_visible( abap_false ).
    ENDCASE.
  ENDLOOP.

  DATA: lo_events TYPE REF TO cl_salv_events_table.

  lo_events = pr_table->get_event( ).

  DATA: lo_event_handler_1100 TYPE REF TO lcl_1100_event_handler_31,
        lo_event_handler_1200 TYPE REF TO lcl_1200_event_handler_31.

  CASE sy-dynnr.
    WHEN '1100'.
      CREATE OBJECT lo_event_handler_1100.
      SET HANDLER lo_event_handler_1100->on_link_click FOR lo_events.
    WHEN '1200'.
      CREATE OBJECT lo_event_handler_1200.
      SET HANDLER lo_event_handler_1200->on_link_click FOR lo_events.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FILL_BKPF_1100_1200
*&---------------------------------------------------------------------*
FORM fill_bkpf_1100_1200  USING    p_tela     TYPE n
                                   p_mes      TYPE monat
                                   p_ano      TYPE gjahr
                                   pt_empresa TYPE tty_empresa
                                   pt_cod_imposto TYPE tty_cod_imposto
                          CHANGING pt_bkpf TYPE tty_bkpf.

  FIELD-SYMBOLS: <bkpf>     TYPE ty_bkpf,
                 <bkpf_aux> LIKE LINE OF gt_1100_bkpf_aux.

  PERFORM fill_bkpf USING    pt_empresa
                             pt_cod_imposto
                    CHANGING pt_bkpf.

* Descarta linha fora do exercício/período
  DELETE pt_bkpf WHERE NOT ( exercicio = p_ano
                         AND periodo   = p_mes ).

  LOOP AT pt_bkpf ASSIGNING <bkpf>.

    CASE p_tela.

      WHEN '1100'.
        READ TABLE gt_1100_bkpf_aux ASSIGNING <bkpf_aux>
                              WITH KEY empresa          = <bkpf>-empresa
                                       num_doc_apuracao = <bkpf>-num_doc_apuracao
                                       exercicio        = <bkpf>-exercicio.
        IF sy-subrc EQ 0.
*          MOVE <bkpf_aux> TO <bkpf>.
        ENDIF.

*       Preenche a situação do documento em APURAÇÃO
        PERFORM preenche_situacao_apu CHANGING <bkpf>.

      WHEN '1200'.
        IF <bkpf>-data_apuracao = '00000000' OR <bkpf>-data_liberacao = '00000000'.
          DELETE pt_bkpf INDEX sy-tabix.
          CONTINUE.
        ENDIF.

*       Preenche a situação do documento em RECOLHIMENTO
        PERFORM preenche_situacao_rec CHANGING <bkpf>.

*       Preenche ícone de dds.recolh.
        <bkpf>-icon_recolh = icon_document.

      WHEN OTHERS.
    ENDCASE.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FILL_BKPF_1400
*&---------------------------------------------------------------------*
FORM fill_bkpf_1400  USING    p_mes          TYPE monat
                              p_ano          TYPE gjahr
                              pt_empresa     TYPE tty_empresa
                              pt_cod_imposto TYPE tty_cod_imposto
                     CHANGING pt_bkpf        TYPE tty_bkpf.

  FIELD-SYMBOLS: <bkpf>     TYPE ty_bkpf.

  PERFORM fill_bkpf USING    pt_empresa
                             pt_cod_imposto
                    CHANGING pt_bkpf.

* Descarta linha fora do exercício/período
  DELETE pt_bkpf WHERE NOT ( exercicio = p_ano
                         AND periodo   = p_mes ).

  LOOP AT pt_bkpf ASSIGNING <bkpf>.

    IF <bkpf>-data_grava_rec IS INITIAL.
*     Preenche a situação do documento em APURAÇÃO
      PERFORM preenche_situacao_apu CHANGING <bkpf>.

    ELSE.
*     Preenche a situação do documento em RECOLHIMENTO
      PERFORM preenche_situacao_rec CHANGING <bkpf>.
    ENDIF.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FILL_BSEG
*&---------------------------------------------------------------------*
FORM fill_bseg  USING    pt_bkpf TYPE tty_bkpf
                CHANGING pt_bseg TYPE tty_bseg.

  DATA: lt_lfa1        TYPE tty_lfa1.

  FIELD-SYMBOLS: <bseg> LIKE LINE OF pt_bseg,
                 <lfa1> LIKE LINE OF lt_lfa1.

* Só prossegue se houver dados no filtro
  CHECK NOT pt_bkpf[] IS INITIAL.

  SELECT *
  INTO TABLE pt_bseg
  FROM zari_bseg
  FOR ALL ENTRIES IN pt_bkpf
  WHERE empresa = pt_bkpf-empresa  "via índice PRIMARY-KEY
    AND num_doc_apuracao = pt_bkpf-num_doc_apuracao
    AND exercicio_apuracao = pt_bkpf-exercicio.

  SORT pt_bseg BY item_apuracao numero_pedido num_doc_contabil
                  item_lancamento conta_contabil data_entrada.

* Seleciona dados da tabela de Fornecedores
  PERFORM fill_lfa1_2  USING    pt_bseg
                       CHANGING lt_lfa1.

  LOOP AT pt_bseg ASSIGNING <bseg>.

*   Preenche o campo Ordem/Elemento PEP
    IF NOT <bseg>-ordem_interna IS INITIAL.
      <bseg>-ordem_elempep = <bseg>-ordem_interna.
    ENDIF.
    IF NOT <bseg>-elemento_pep = 0.
      <bseg>-ordem_elempep = <bseg>-elemento_pep.
    ENDIF.

*   Preenche o nome do fornecedor
    READ TABLE lt_lfa1 WITH KEY lifnr = <bseg>-cod_fornecedor
                       ASSIGNING <lfa1>
                       BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      <bseg>-lfa1_mcod1 = <lfa1>-mcod1.
    ENDIF.
  ENDLOOP.

  FREE: lt_lfa1.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_SPLITTER_WITH_HEADER
*&---------------------------------------------------------------------*
FORM get_splitter_1300_with_header  USING    pr_parent TYPE REF TO cl_gui_custom_container
                                        pv_text  TYPE sdydo_text_element
                               CHANGING pr_result TYPE REF TO cl_gui_splitter_container.

  DATA:
    lr_splitter    TYPE REF TO cl_gui_splitter_container,
    lr_container   TYPE REF TO cl_gui_container,
    lr_header      TYPE REF TO cl_dd_document,
    lr_doctable    TYPE REF TO cl_dd_table_element,
    lr_column      TYPE REF TO cl_dd_area,
    lv_text        TYPE sdydo_text_element,
    lv_periodo_ant TYPE dats.

  PERFORM calcula_periodo_ant CHANGING lv_periodo_ant.

* Cria o divisor para a cabeçalho e o grid
  CREATE OBJECT lr_splitter
    EXPORTING
      rows    = 2
      columns = 1
      parent  = pr_parent.

  lr_splitter->set_row_height(
    id     = 1
    height = 18 ).

  lr_splitter->set_row_sash(
    id    = 1
    type  = 0
    value = 0 ).

  lr_container = lr_splitter->get_container(
    row     = 1
    column  = 1 ).

  CREATE OBJECT lr_header.

  lr_header->add_table(
     EXPORTING
       no_of_columns               = 2
       width                       = '100%'
       cell_background_transparent = abap_true
       border                      = '0'
     IMPORTING
       table                       = lr_doctable ).

* Título do relatório
  lr_doctable->add_column(
    EXPORTING width  = '10%'
    IMPORTING column = lr_column ).

  lr_column->add_text(
    text = 'Mês base:' ).

  lr_doctable->set_column_style(
      EXPORTING
        col_no = 1
        sap_align     = 'CENTER' ).

  DATA: form_inp TYPE REF TO cl_dd_form_area,
        opt_tab  TYPE sdydo_option_tab,
        lv_value TYPE sdydo_value,
        btn_exec TYPE REF TO cl_dd_button_element.

  lr_column->add_form(
      IMPORTING
        formarea = form_inp ).

  CALL METHOD form_inp->line_with_layout EXPORTING start = 'X'.
  CALL METHOD form_inp->add_gap EXPORTING width = 2.
  PERFORM fill_combo_form_inp CHANGING opt_tab.

  WRITE lv_periodo_ant+4(2) TO lv_value.
*** ADD_SELECT_ELEMENT -> ***
  CALL METHOD form_inp->add_select_element
    EXPORTING
      options        = opt_tab
      value          = lv_value
    IMPORTING
      select_element = sel_1300_monat.

  WRITE lv_periodo_ant(4) TO lv_value.
  CALL METHOD form_inp->add_input_element
    EXPORTING
      value         = lv_value
      name          = 'INP2'
      size          = 4
      maxlength     = 4
    IMPORTING
      input_element = inp_1300_gjahr.

  CALL METHOD form_inp->add_gap EXPORTING width = 2.


  CALL METHOD form_inp->add_button
    EXPORTING
      sap_icon = 'ICON_EXECUTE_OBJECT'
      tooltip  = 'Executar'
      name     = 'EXEC'
    IMPORTING
      button   = btn_exec.


  DATA lo_event_handler_1300 TYPE REF TO lcl_1300_event_handler_11.

  CREATE OBJECT lo_event_handler_1300.
  SET HANDLER lo_event_handler_1300->on_clicked FOR btn_exec.

  lr_header->merge_document( ).

  lr_header->display_document( parent = lr_container ).

  pr_result = lr_splitter.

ENDFORM.                    " GET_SPLITTER_WITH_HEADER

*&---------------------------------------------------------------------*
*&      Form  GET_SPLITTER_1100
*&---------------------------------------------------------------------*
FORM get_splitter_1100_1200  USING    pr_parent TYPE REF TO cl_gui_custom_container
                                      pv_button3_txt TYPE string
                                      pv_button5     TYPE xfeld
                        CHANGING pr_splitter_top TYPE REF TO cl_gui_splitter_container
                                 pr_splitter_middle TYPE REF TO cl_gui_splitter_container
                                 pr_splitter_bottom TYPE REF TO cl_gui_splitter_container
                                 pr_sel_monat TYPE REF TO cl_dd_select_element
                                 pr_inp_gjahr TYPE REF TO cl_dd_input_element.

  DATA:
    lr_splitter           TYPE REF TO cl_gui_splitter_container,
    lr_container          TYPE REF TO cl_gui_container,
    lo_event_handler_1100 TYPE REF TO lcl_1100_event_handler_21,
    lo_event_handler_1200 TYPE REF TO lcl_1200_event_handler_21,
*    button0               TYPE REF TO cl_dd_button_element,
    button0_1100          TYPE REF TO cl_dd_button_element.


  CREATE OBJECT lr_splitter
    EXPORTING
      parent  = pr_parent
      rows    = 3
      columns = 1.

  lr_splitter->set_row_height(
      id     = 1
      height = 22 ).

  lr_splitter->set_row_sash(
    id    = 1
    type  = 0
    value = 0 ).

  lr_container = lr_splitter->get_container(
                    row       = 1
                    column    = 1  ).

  CREATE OBJECT pr_splitter_top
    EXPORTING
      parent  = lr_container
      rows    = 1
      columns = 4.

  lr_container = lr_splitter->get_container(
                      row       = 2
                      column    = 1  ).

  CREATE OBJECT pr_splitter_middle
    EXPORTING
      parent  = lr_container
      rows    = 1
      columns = 2.

  pr_splitter_middle->set_column_width(
      id     = 1
      width = 20 ).

  pr_splitter_middle->set_column_sash(
    id    = 1
    type  = 0
    value = 0 ).

  lr_container = pr_splitter_middle->get_container(
                        row       = 1
                        column    = 1  ).

  CREATE OBJECT dd_doc_btn.

  DATA:
    lr_doctable TYPE REF TO cl_dd_table_element,
    lr_column   TYPE REF TO cl_dd_area.

  dd_doc_btn->add_table(
    EXPORTING
      no_of_columns               = 1
      width                       = '100%'
      cell_background_transparent = abap_true
      border                      = '0'
    IMPORTING
      table                       = lr_doctable ).

  lr_doctable->add_column(
      EXPORTING width  = '100%'
      IMPORTING column = lr_column ).

  lr_doctable->set_column_style(
          EXPORTING
            col_no = 1
            sap_align     = 'CENTER' ).

  DATA: form_inp       TYPE REF TO cl_dd_form_area,
        opt_tab        TYPE sdydo_option_tab,
        lv_periodo_ant TYPE dats,
        lv_value       TYPE sdydo_value.

  PERFORM calcula_periodo_ant CHANGING lv_periodo_ant.

  lr_column->add_form(
      IMPORTING
        formarea = form_inp ).

  CALL METHOD form_inp->line_with_layout EXPORTING start = 'X'.
  CALL METHOD form_inp->add_gap EXPORTING width = 2.
  PERFORM fill_combo_form_inp CHANGING opt_tab.

  WRITE lv_periodo_ant+4(2) TO lv_value.

*** ADD_SELECT_ELEMENT -> ***
  CALL METHOD form_inp->add_select_element
    EXPORTING
      options        = opt_tab
      value          = lv_value
    IMPORTING
      select_element = pr_sel_monat.

  CALL METHOD form_inp->add_text EXPORTING text = '/'.

  WRITE lv_periodo_ant(4) TO lv_value.
  CALL METHOD form_inp->add_input_element
    EXPORTING
      value         = lv_value
      name          = 'INP2'
      size          = 4
      maxlength     = 4
    IMPORTING
      input_element = pr_inp_gjahr.

  CALL METHOD form_inp->add_gap EXPORTING width = 2.

  CASE sy-dynnr.
    WHEN '1100'.
      CALL METHOD form_inp->add_button
        EXPORTING
          sap_icon = 'ICON_EXECUTE_OBJECT'
          tooltip  = 'Executar'
          name     = 'EXEC'
        IMPORTING
          button   = button0_1100.
    WHEN '1200'.
      CALL METHOD form_inp->add_button
        EXPORTING
          sap_icon = 'ICON_EXECUTE_OBJECT'
          tooltip  = 'Executar'
          name     = 'EXEC'
        IMPORTING
          button   = button0.
  ENDCASE.

  lr_column->add_form(
      IMPORTING
        formarea = form_btn ).

  CALL METHOD form_btn->add_button
    EXPORTING
      label  = 'Período Base'
      name   = 'BUT1'
    IMPORTING
      button = button1.

  CALL METHOD form_btn->add_button
    EXPORTING
      label  = 'Anteriores__'
      name   = 'BUT2'
    IMPORTING
      button = button2.

  CALL METHOD form_btn->add_button
    EXPORTING
      label  = pv_button3_txt  "'Gravar_____'
      name   = 'BUT3'
    IMPORTING
      button = button3.

  CALL METHOD form_btn->add_button
    EXPORTING
      label  = 'Liberar_____'
      name   = 'BUT4'
    IMPORTING
      button = button4.

  IF NOT pv_button5 IS INITIAL.
    CALL METHOD form_btn->add_button
      EXPORTING
        label  = 'Compensação'
        name   = 'BUT5'
      IMPORTING
        button = button5.
  ENDIF.

  CASE sy-dynnr.
    WHEN '1100'.
      IF gv_auth_apu02 = abap_false.
        CALL METHOD button3->disable_button.
      ENDIF.

      IF gv_auth_apu03 = abap_false.
        CALL METHOD button4->disable_button.
      ENDIF.

      CREATE OBJECT lo_event_handler_1100.
*      SET HANDLER lo_event_handler_1100->on_link_click FOR lo_events.
      SET HANDLER lo_event_handler_1100->on_clicked FOR button0_1100.
      SET HANDLER lo_event_handler_1100->on_clicked FOR button1.
      SET HANDLER lo_event_handler_1100->on_clicked FOR button2.
      SET HANDLER lo_event_handler_1100->on_clicked FOR button3.
      SET HANDLER lo_event_handler_1100->on_clicked FOR button4.

    WHEN '1200'.
      IF gv_auth_rec02 = abap_false.
        CALL METHOD button3->disable_button.
      ENDIF.

      IF gv_auth_rec03 = abap_false.
        CALL METHOD button4->disable_button.
      ENDIF.

      CREATE OBJECT lo_event_handler_1200.
*      SET HANDLER lo_event_handler_1200->on_link_click FOR lo_events.
      SET HANDLER lo_event_handler_1200->on_clicked FOR button0.
      SET HANDLER lo_event_handler_1200->on_clicked FOR button1.
      SET HANDLER lo_event_handler_1200->on_clicked FOR button2.
      SET HANDLER lo_event_handler_1200->on_clicked FOR button3.
      SET HANDLER lo_event_handler_1200->on_clicked FOR button4.
*----------------------------------------------------------------------*
* Início Alteração - 26.07.2016
*----------------------------------------------------------------------*
*     SET HANDLER lo_event_handler_1200->on_clicked FOR button5.
*----------------------------------------------------------------------*
* Fim Alteração - 26.07.2016
*----------------------------------------------------------------------*
  ENDCASE.

  CALL METHOD dd_doc_btn->merge_document.

  dd_doc_btn->display_document( parent = lr_container ).

  lr_container = lr_splitter->get_container(
                     row       = 3
                     column    = 1  ).

  CREATE OBJECT pr_splitter_bottom
    EXPORTING
      parent  = lr_container
      rows    = 1
      columns = 1.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CREATE_CONTROLS_1100
*&---------------------------------------------------------------------*
FORM create_controls_1100 .

  DATA:
    lr_splitter_top    TYPE REF TO cl_gui_splitter_container,
    lr_splitter_middle TYPE REF TO cl_gui_splitter_container,
    lr_splitter_bottom TYPE REF TO cl_gui_splitter_container,
    lr_container       TYPE REF TO cl_gui_container.

  CHECK go_1100_custom IS INITIAL.

  IF gt_1100_categ IS INITIAL.
    PERFORM fill_categ CHANGING gt_1100_categ.
  ENDIF.

  CREATE OBJECT go_1100_custom
    EXPORTING
      container_name = 'CONT_1100'.

  PERFORM get_splitter_1100_1200  USING go_1100_custom
                                        'Gravar_____'
                                        space    "sem botão Compensação
                             CHANGING lr_splitter_top lr_splitter_middle lr_splitter_bottom
                                      sel_1100_monat
                                      inp_1100_gjahr.

*&------------------------------------------------------------
*&- Linha 1 e Coluna 1
  go_1100_grid11 = lr_splitter_top->get_container(
            row       = 1
            column    = 1  ).

  TRY.
      CALL METHOD cl_salv_table=>factory
        EXPORTING
          r_container  = go_1100_grid11
        IMPORTING
          r_salv_table = go_1100_salv11
        CHANGING
          t_table      = gt_1100_categ.
    CATCH cx_salv_msg.

  ENDTRY.

  PERFORM fieldcat_1100_1200_salv11 CHANGING go_1100_salv11.

  go_1100_salv11->display( ).

*&------------------------------------------------------------
*&- Linha 1 e Coluna 2
  go_1100_grid12 = lr_splitter_top->get_container(
              row       = 1
              column    = 2  ).

  TRY.
      CALL METHOD cl_salv_table=>factory
        EXPORTING
          r_container  = go_1100_grid12
        IMPORTING
          r_salv_table = go_1100_salv12
        CHANGING
          t_table      = gt_1100_tp_imposto.
    CATCH cx_salv_msg.

  ENDTRY.

  PERFORM fieldcat_1100_1200_salv12 CHANGING go_1100_salv12.

  go_1100_salv12->display( ).

*&------------------------------------------------------------
*&- Linha 1 e Coluna 3
  go_1100_grid13 = lr_splitter_top->get_container(
              row       = 1
              column    = 3  ).

  TRY.
      CALL METHOD cl_salv_table=>factory
        EXPORTING
          r_container  = go_1100_grid13
        IMPORTING
          r_salv_table = go_1100_salv13
        CHANGING
          t_table      = gt_1100_cod_imposto.
    CATCH cx_salv_msg.

  ENDTRY.

  PERFORM fieldcat_1100_1200_salv13 CHANGING go_1100_salv13.

  go_1100_salv13->display( ).

*&------------------------------------------------------------
*&- Linha 1 e Coluna 4
  go_1100_grid14 = lr_splitter_top->get_container(
            row       = 1
            column    = 4  ).

  TRY.
      CALL METHOD cl_salv_table=>factory
        EXPORTING
          r_container  = go_1100_grid14
        IMPORTING
          r_salv_table = go_1100_salv14
        CHANGING
          t_table      = gt_1100_emprdiv.
    CATCH cx_salv_msg.

  ENDTRY.

  PERFORM fieldcat_1100_1200_salv14 CHANGING go_1100_salv14.

  go_1100_salv14->display( ).

*&------------------------------------------------------------
*&- Linha 2 e Coluna 2

  go_1100_grid22 = lr_splitter_middle->get_container(
                                    row       = 1
                                    column    = 2  ).

  TRY.
      CALL METHOD cl_salv_table=>factory
        EXPORTING
          r_container  = go_1100_grid22
        IMPORTING
          r_salv_table = go_1100_salv22
        CHANGING
          t_table      = gt_1100_bkpf.
    CATCH cx_salv_msg.

  ENDTRY.

  PERFORM fieldcat_1100_1200_salv22 USING    space  "sem ícone dds.recolh
                                    CHANGING go_1100_salv22.

  go_1100_salv22->display( ).

*&------------------------------------------------------------
*&- Linha 3 e Coluna 1

  go_1100_grid31 = lr_splitter_bottom->get_container(
            row       = 1
            column    = 1  ).

  TRY.
      CALL METHOD cl_salv_table=>factory
        EXPORTING
          r_container  = go_1100_grid31
        IMPORTING
          r_salv_table = go_1100_salv31
        CHANGING
          t_table      = gt_1100_bseg.
    CATCH cx_salv_msg.

  ENDTRY.

  PERFORM fieldcat_1100_1200_salv31 CHANGING go_1100_salv31.

  go_1100_salv31->display( ).
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CREATE_CONTROLS_1200
*&---------------------------------------------------------------------*
FORM create_controls_1200 .
  DATA:
    lr_splitter_top    TYPE REF TO cl_gui_splitter_container,
    lr_splitter_middle TYPE REF TO cl_gui_splitter_container,
    lr_splitter_bottom TYPE REF TO cl_gui_splitter_container,
    lr_container       TYPE REF TO cl_gui_container.

  CHECK go_1200_custom IS INITIAL.

  IF gt_1200_categ IS INITIAL.
    PERFORM fill_categ CHANGING gt_1200_categ.
  ENDIF.

  CREATE OBJECT go_1200_custom
    EXPORTING
      container_name = 'CONT_1200'.

  PERFORM get_splitter_1100_1200  USING go_1200_custom
                                        'Confirmar___'
*----------------------------------------------------------------------*
* Início Alteração - 26.07.2016
*----------------------------------------------------------------------*
*                                       'X'      " Com botão Compensação
                                        space    " Sem botão Compensação
*----------------------------------------------------------------------*
* Fim Alteração - 26.07.2016
*----------------------------------------------------------------------*
                             CHANGING lr_splitter_top lr_splitter_middle lr_splitter_bottom
                                      sel_1200_monat
                                      inp_1200_gjahr.

*&------------------------------------------------------------
*&- Linha 1 e Coluna 1
  go_1200_grid11 = lr_splitter_top->get_container(
            row       = 1
            column    = 1  ).

  TRY.
      CALL METHOD cl_salv_table=>factory
        EXPORTING
          r_container  = go_1200_grid11
        IMPORTING
          r_salv_table = go_1200_salv11
        CHANGING
          t_table      = gt_1200_categ.
    CATCH cx_salv_msg.

  ENDTRY.

  PERFORM fieldcat_1100_1200_salv11 CHANGING go_1200_salv11.

  go_1200_salv11->display( ).

*&------------------------------------------------------------
*&- Linha 1 e Coluna 2
  go_1200_grid12 = lr_splitter_top->get_container(
              row       = 1
              column    = 2  ).

  TRY.
      CALL METHOD cl_salv_table=>factory
        EXPORTING
          r_container  = go_1200_grid12
        IMPORTING
          r_salv_table = go_1200_salv12
        CHANGING
          t_table      = gt_1200_tp_imposto.
    CATCH cx_salv_msg.

  ENDTRY.

  PERFORM fieldcat_1100_1200_salv12 CHANGING go_1200_salv12.

  go_1200_salv12->display( ).

*&------------------------------------------------------------
*&- Linha 1 e Coluna 3
  go_1200_grid13 = lr_splitter_top->get_container(
              row       = 1
              column    = 3  ).

  TRY.
      CALL METHOD cl_salv_table=>factory
        EXPORTING
          r_container  = go_1200_grid13
        IMPORTING
          r_salv_table = go_1200_salv13
        CHANGING
          t_table      = gt_1200_cod_imposto.
    CATCH cx_salv_msg.

  ENDTRY.

  PERFORM fieldcat_1100_1200_salv13 CHANGING go_1200_salv13.

  go_1200_salv13->display( ).

*&------------------------------------------------------------
*&- Linha 1 e Coluna 4
  go_1200_grid14 = lr_splitter_top->get_container(
            row       = 1
            column    = 4  ).

  TRY.
      CALL METHOD cl_salv_table=>factory
        EXPORTING
          r_container  = go_1200_grid14
        IMPORTING
          r_salv_table = go_1200_salv14
        CHANGING
          t_table      = gt_1200_emprdiv.
    CATCH cx_salv_msg.

  ENDTRY.

  PERFORM fieldcat_1100_1200_salv14 CHANGING go_1200_salv14.

  go_1200_salv14->display( ).

*&------------------------------------------------------------
*&- Linha 2 e Coluna 2

  go_1200_grid22 = lr_splitter_middle->get_container(
                                    row       = 1
                                    column    = 2  ).

  TRY.
      CALL METHOD cl_salv_table=>factory
        EXPORTING
          r_container  = go_1200_grid22
        IMPORTING
          r_salv_table = go_1200_salv22
        CHANGING
          t_table      = gt_1200_bkpf.
    CATCH cx_salv_msg.

  ENDTRY.

  PERFORM fieldcat_1100_1200_salv22 USING    'X'   "com ícone dds.recolh
                                    CHANGING go_1200_salv22.

  go_1200_salv22->display( ).

*&------------------------------------------------------------
*&- Linha 3 e Coluna 1

  go_1200_grid31 = lr_splitter_bottom->get_container(
            row       = 1
            column    = 1  ).

  TRY.
      CALL METHOD cl_salv_table=>factory
        EXPORTING
          r_container  = go_1200_grid31
        IMPORTING
          r_salv_table = go_1200_salv31
        CHANGING
          t_table      = gt_1200_bseg.
    CATCH cx_salv_msg.

  ENDTRY.

  PERFORM fieldcat_1100_1200_salv31 CHANGING go_1200_salv31.

  go_1200_salv31->display( ).
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CREATE_CONTROLS_1400
*&---------------------------------------------------------------------*
FORM create_controls_1400 .

  DATA:
    lr_splitter_top    TYPE REF TO cl_gui_splitter_container,
    lr_splitter_middle TYPE REF TO cl_gui_splitter_container,
    lr_splitter_bottom TYPE REF TO cl_gui_splitter_container,
    lr_container       TYPE REF TO cl_gui_container,
    lv_periodo_ant     TYPE dats.

  CHECK go_1400_custom IS INITIAL.

* Preenche o período base com o período anterior ao corrente
  PERFORM calcula_periodo_ant CHANGING lv_periodo_ant.
  wa_1400_manut-gjahr = lv_periodo_ant(4).
  wa_1400_manut-monat = lv_periodo_ant+4(2).

  PERFORM dropdown_1400_monat.

  IF gt_1400_categ IS INITIAL.
    PERFORM fill_categ CHANGING gt_1400_categ.
  ENDIF.

  CREATE OBJECT go_1400_custom
    EXPORTING
      container_name = 'CONT_1400'.

  PERFORM get_splitter_1400  USING go_1400_custom
                             CHANGING lr_splitter_top.
*                                      lr_splitter_middle
*                                      lr_splitter_bottom
*                                      sel_1400_monat
*                                      inp_1400_gjahr.

*&------------------------------------------------------------
*&- Linha 1 e Coluna 1
  go_1400_grid11 = lr_splitter_top->get_container(
            row       = 1
            column    = 1  ).

  TRY.
      CALL METHOD cl_salv_table=>factory
        EXPORTING
          r_container  = go_1400_grid11
        IMPORTING
          r_salv_table = go_1400_salv11
        CHANGING
          t_table      = gt_1400_categ.
    CATCH cx_salv_msg.

  ENDTRY.

  PERFORM fieldcat_1100_1200_salv11 CHANGING go_1400_salv11.

  go_1400_salv11->display( ).

*&------------------------------------------------------------
*&- Linha 1 e Coluna 2
  go_1400_grid12 = lr_splitter_top->get_container(
              row       = 1
              column    = 2  ).

  TRY.
      CALL METHOD cl_salv_table=>factory
        EXPORTING
          r_container  = go_1400_grid12
        IMPORTING
          r_salv_table = go_1400_salv12
        CHANGING
          t_table      = gt_1400_tp_imposto.
    CATCH cx_salv_msg.

  ENDTRY.

  PERFORM fieldcat_1100_1200_salv12 CHANGING go_1400_salv12.

  go_1400_salv12->display( ).

*&------------------------------------------------------------
*&- Linha 1 e Coluna 3
  go_1400_grid13 = lr_splitter_top->get_container(
              row       = 1
              column    = 3  ).

  TRY.
      CALL METHOD cl_salv_table=>factory
        EXPORTING
          r_container  = go_1400_grid13
        IMPORTING
          r_salv_table = go_1400_salv13
        CHANGING
          t_table      = gt_1400_cod_imposto.
    CATCH cx_salv_msg.

  ENDTRY.

  PERFORM fieldcat_1100_1200_salv13 CHANGING go_1400_salv13.

  go_1400_salv13->display( ).

*&------------------------------------------------------------
*&- Linha 1 e Coluna 4
  go_1400_grid14 = lr_splitter_top->get_container(
            row       = 1
            column    = 4  ).

  TRY.
      CALL METHOD cl_salv_table=>factory
        EXPORTING
          r_container  = go_1400_grid14
        IMPORTING
          r_salv_table = go_1400_salv14
        CHANGING
          t_table      = gt_1400_emprdiv.
    CATCH cx_salv_msg.

  ENDTRY.

  PERFORM fieldcat_1100_1200_salv14 CHANGING go_1400_salv14.

  go_1400_salv14->display( ).

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_AUTORIZACOES
*&---------------------------------------------------------------------*
FORM set_autorizacoes.

  PERFORM authority_check USING 'APU01' CHANGING gv_auth_apu01.
  PERFORM authority_check USING 'APU02' CHANGING gv_auth_apu02.
  PERFORM authority_check USING 'APU03' CHANGING gv_auth_apu03.
  PERFORM authority_check USING 'REC01' CHANGING gv_auth_rec01.
  PERFORM authority_check USING 'REC02' CHANGING gv_auth_rec02.
  PERFORM authority_check USING 'REC03' CHANGING gv_auth_rec03.
  PERFORM authority_check USING 'CONSU' CHANGING gv_auth_consu.
  PERFORM authority_check USING 'MAN01' CHANGING gv_auth_man01.
  PERFORM authority_check USING 'MAN02' CHANGING gv_auth_man02.
  PERFORM authority_check USING 'MAN03' CHANGING gv_auth_man03.
  PERFORM authority_check USING 'MAN04' CHANGING gv_auth_man04.
  PERFORM authority_check USING 'MAN05' CHANGING gv_auth_man05.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  AUTHORITY_CHECK
*&---------------------------------------------------------------------*
FORM authority_check  USING    p_field TYPE char10
                      CHANGING pv_auth TYPE char1.

  AUTHORITY-CHECK OBJECT 'ZARI_AUTH' ID 'ZARI_ACTVT' FIELD p_field.  "Código da Atividade.

  IF sy-subrc = 0. "Usuário tem autorização
    pv_auth = abap_true.
  ELSE.
    pv_auth = abap_false.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FILL_COMBO_FORM_INP
*&---------------------------------------------------------------------*
FORM fill_combo_form_inp  CHANGING pt_option TYPE sdydo_option_tab.
  DATA opt TYPE sdydo_option.

  opt-text  = opt-value = '01'.
  APPEND opt TO pt_option .
  opt-text  = opt-value = '02'.
  APPEND opt TO pt_option .
  opt-text  = opt-value = '03'.
  APPEND opt TO pt_option .
  opt-text  = opt-value = '04'.
  APPEND opt TO pt_option .
  opt-text  = opt-value = '05'.
  APPEND opt TO pt_option .
  opt-text  = opt-value = '06'.
  APPEND opt TO pt_option .
  opt-text  = opt-value = '07'.
  APPEND opt TO pt_option .
  opt-text  = opt-value = '08'.
  APPEND opt TO pt_option .
  opt-text  = opt-value = '09'.
  APPEND opt TO pt_option .
  opt-text  = opt-value = '10'.
  APPEND opt TO pt_option .
  opt-text  = opt-value = '11'.
  APPEND opt TO pt_option .
  opt-text  = opt-value = '12'.
  APPEND opt TO pt_option .
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECIONA_BKPF_EXEC_1100
*&---------------------------------------------------------------------*
FORM fill_bkpf_exec_1100 USING    p_mes          TYPE monat
                                  p_ano          TYPE gjahr
                                  pt_categ       TYPE tty_categ
                                  pt_tp_imposto  TYPE tty_tp_imposto
                                  pt_cod_imposto TYPE tty_cod_imposto
                                  pt_empresa     TYPE tty_empresa
                                  pt_emprdiv     TYPE tty_emprdiv
                         CHANGING pt_bkpf        TYPE tty_bkpf.

  DATA: lt_tp_imposto  TYPE tty_tp_imposto,
        lt_cod_imposto TYPE tty_cod_imposto,
        lt_emprdiv     TYPE tty_emprdiv,
        lt_empresa     TYPE tty_empresa,
        lt_fields      TYPE rsz_t_string.

  FIELD-SYMBOLS
                 <bkpf> TYPE ty_bkpf.

* Se não foi definido o filtro de tipo de imposto,
  IF pt_tp_imposto[] IS INITIAL.
*   Seleciona dados da tabela de configuração
    PERFORM fill_tp_imposto USING pt_categ CHANGING lt_tp_imposto.
* Caso contrário,
  ELSE.
*   Considera as linhas marcadas
    lt_tp_imposto[] = pt_tp_imposto[].
    DELETE lt_tp_imposto[] WHERE check IS INITIAL.
  ENDIF.

* Se não foi definido o filtro de código de imposto,
  IF pt_cod_imposto[] IS INITIAL.
*   Seleciona dados da tabela de configuração
    PERFORM fill_cod_imposto USING pt_tp_imposto CHANGING lt_cod_imposto.
* Caso contrário,
  ELSE.
*   Considera as linhas marcadas
    lt_cod_imposto[] = pt_cod_imposto[].
    DELETE lt_cod_imposto[] WHERE check IS INITIAL.
  ENDIF.

* Se não foi definido o filtro de empresa/divisão,
  IF pt_cod_imposto[] IS INITIAL.
*   Seleciona dados da tabela de configuração
    PERFORM fill_empresa USING pt_cod_imposto CHANGING lt_empresa lt_emprdiv.
* Caso contrário,
  ELSE.
*   Considera as linhas marcadas
    lt_empresa[] = pt_empresa[].
    lt_emprdiv[] = pt_emprdiv[].
    DELETE lt_emprdiv[] WHERE check IS INITIAL.
  ENDIF.

* Filtra as configurações por empresa-divisão marcada
  PERFORM filter_empresa USING    lt_emprdiv
                         CHANGING lt_empresa.

  PERFORM fill_bkpf_1100_1200 USING    '1100'
                                       p_mes
                                       p_ano
                                       lt_empresa
                                       lt_cod_imposto
                              CHANGING pt_bkpf.

*  DELETE gt_1100_bkpf WHERE exercicio <> p_ano OR periodo <> p_mes.
  IF pt_bkpf IS INITIAL.
    MESSAGE s000 DISPLAY LIKE 'E' WITH 'Dados não encontrados.'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SELECIONA_BKPF_EXEC_1200
*&---------------------------------------------------------------------*
FORM fill_bkpf_exec_1200 USING    p_mes          TYPE monat
                                  p_ano          TYPE gjahr
                                  pt_categ       TYPE tty_categ
                                  pt_tp_imposto  TYPE tty_tp_imposto
                                  pt_cod_imposto TYPE tty_cod_imposto
                                  pt_empresa     TYPE tty_empresa
                                  pt_emprdiv     TYPE tty_emprdiv
                         CHANGING pt_bkpf        TYPE tty_bkpf.

  DATA: lt_tp_imposto  TYPE tty_tp_imposto,
        lt_cod_imposto TYPE tty_cod_imposto,
        lt_emprdiv     TYPE tty_emprdiv,
        lt_empresa     TYPE tty_empresa,
        lt_fields      TYPE rsz_t_string.

  FIELD-SYMBOLS
                 <bkpf> TYPE ty_bkpf.

* Se não foi definido o filtro de tipo de imposto,
  IF pt_tp_imposto[] IS INITIAL.
*   Seleciona dados da tabela de configuração
    PERFORM fill_tp_imposto USING pt_categ CHANGING lt_tp_imposto.
* Caso contrário,
  ELSE.
*   Considera as linhas marcadas
    lt_tp_imposto[] = pt_tp_imposto[].
    DELETE lt_tp_imposto[] WHERE check IS INITIAL.
  ENDIF.

* Se não foi definido o filtro de código de imposto,
  IF pt_cod_imposto[] IS INITIAL.
*   Seleciona dados da tabela de configuração
    PERFORM fill_cod_imposto USING pt_tp_imposto CHANGING lt_cod_imposto.
* Caso contrário,
  ELSE.
*   Considera as linhas marcadas
    lt_cod_imposto[] = pt_cod_imposto[].
    DELETE lt_cod_imposto[] WHERE check IS INITIAL.
  ENDIF.

* Se não foi definido o filtro de empresa/divisão,
  IF pt_cod_imposto[] IS INITIAL.
*   Seleciona dados da tabela de configuração
    PERFORM fill_empresa USING pt_cod_imposto CHANGING lt_empresa lt_emprdiv.
* Caso contrário,
  ELSE.
*   Considera as linhas marcadas
    lt_empresa[] = pt_empresa[].
    lt_emprdiv[] = pt_emprdiv[].
    DELETE lt_emprdiv[] WHERE check IS INITIAL.
  ENDIF.

* Filtra as configurações por empresa-divisão marcada
  PERFORM filter_empresa USING    lt_emprdiv
                         CHANGING lt_empresa.

  PERFORM fill_bkpf_1100_1200 USING    '1200'
                                       p_mes
                                       p_ano
                                       lt_empresa
                                       pt_cod_imposto
                              CHANGING pt_bkpf.

*  DELETE gt_1100_bkpf WHERE exercicio <> p_ano OR periodo <> p_mes.
  IF pt_bkpf IS INITIAL.
    MESSAGE s000 DISPLAY LIKE 'E' WITH 'Dados não encontrados.'.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UPDATE_BKP_1200
*&---------------------------------------------------------------------*
FORM update_bkp_1200_1  CHANGING p_bkpf TYPE ty_bkpf.

  p_bkpf-data_recolhimento         = sy-datum.
  p_bkpf-nome_usuario_recolhimento = sy-uname.
  p_bkpf-situacao                  = 'Gravado'.
  CLEAR: p_bkpf-data_grava_rec,
         p_bkpf-hora_grava_rec,
         p_bkpf-nome_grava_rec.

  UPDATE zari_bkpf FROM p_bkpf.
  COMMIT WORK.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UPDATE_BKP_1200
*&---------------------------------------------------------------------*
FORM update_bkp_1200_2  CHANGING pt_bkpf TYPE tty_bkpf.

  FIELD-SYMBOLS: <bkpf> LIKE LINE OF pt_bkpf.

  LOOP AT pt_bkpf ASSIGNING <bkpf> WHERE check <> space.

    <bkpf>-data_grava_rec = sy-datum.
    <bkpf>-hora_grava_rec = sy-uzeit.
    <bkpf>-nome_grava_rec = sy-uname.
    <bkpf>-situacao       = 'Confirmado'.

    UPDATE zari_bkpf FROM <bkpf>.
    COMMIT WORK.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CREATE_CONTROLS_1300
*&---------------------------------------------------------------------*
FORM create_controls_1300.

  DATA:
    lr_splitter  TYPE REF TO cl_gui_splitter_container,
    lr_container TYPE REF TO cl_gui_container.

  IF go_1300_salv21 IS BOUND.
    go_1300_salv21->refresh( ).
  ELSE.

    CREATE OBJECT go_1300_custom
      EXPORTING
        container_name = 'CONT_1300'.

    PERFORM get_splitter_1300_with_header  USING go_1300_custom 'Mês/Exercício'
                                      CHANGING lr_splitter .

    lr_container = lr_splitter->get_container(
             row       = 2
             column    = 1  ).

    TRY.
        cl_salv_table=>factory(
          EXPORTING
            r_container  = lr_container
          IMPORTING
            r_salv_table = go_1300_salv21
          CHANGING
            t_table      = gt_1300_saida ).

      CATCH cx_salv_msg.

    ENDTRY.

    PERFORM fieldcat_1300_salv21 CHANGING go_1300_salv21.
    go_1300_salv21->display( ).
  ENDIF.


ENDFORM.

FORM fill_bkpf  USING    pt_empresa TYPE tty_empresa
                         pt_cod_imposto TYPE tty_cod_imposto
*                         p_monat type monat
*                         p_gjahr type gjahr
                CHANGING pt_bkpf TYPE tty_bkpf.

  DATA:
    lt_j_1btxjurt TYPE tty_j_1btxjurt,
    lt_lfa1       TYPE tty_lfa1.

  FIELD-SYMBOLS: <bkpf>        LIKE LINE OF pt_bkpf,
                 <cod_imposto> LIKE LINE OF pt_cod_imposto,
                 <j_1btxjurt>  LIKE LINE OF lt_j_1btxjurt,
                 <lfa1>        LIKE LINE OF lt_lfa1.

* Só prossegue se houver filtro
  CHECK NOT pt_empresa[] IS INITIAL.

*MFS 08.04.2016 - ajuste de seleção para Empresa com divisão branco

  READ TABLE pt_empresa TRANSPORTING NO FIELDS WITH KEY gsber = ' '.

  IF sy-subrc IS NOT INITIAL.
    SELECT *
    INTO TABLE pt_bkpf
    FROM zari_bkpf
    FOR ALL ENTRIES IN pt_empresa
    WHERE empresa = pt_empresa-empresa
*      and exercicio = p_gjahr
*      and periodo   = p_monat
      AND categ_imposto = pt_empresa-categ_imposto
      AND tipo_imposto = pt_empresa-tipo_imposto
      AND codigo_imposto = pt_empresa-codigo_imposto
      AND divisao = pt_empresa-gsber.
  ELSE.
    SELECT *
    INTO TABLE pt_bkpf
    FROM zari_bkpf
    FOR ALL ENTRIES IN pt_empresa
    WHERE empresa = pt_empresa-empresa
*      and exercicio = p_gjahr
*      and periodo   = p_monat
      AND categ_imposto = pt_empresa-categ_imposto
      AND tipo_imposto = pt_empresa-tipo_imposto
      AND codigo_imposto = pt_empresa-codigo_imposto.
  ENDIF.
*MFS 08.04.2016

  SORT pt_bkpf BY empresa          ASCENDING
                  num_doc_apuracao ASCENDING
                  exercicio        ASCENDING.

  PERFORM fill_j_1btxjurt USING    pt_bkpf
                          CHANGING lt_j_1btxjurt.

  PERFORM fill_lfa1 USING    pt_cod_imposto
                    CHANGING lt_lfa1.

  LOOP AT pt_bkpf ASSIGNING <bkpf>.

*   Preenche o tipo da guia
    READ TABLE pt_cod_imposto WITH KEY codigo_imposto = <bkpf>-codigo_imposto
                              ASSIGNING <cod_imposto>
                              BINARY SEARCH.
    IF sy-subrc = 0.
      <bkpf>-tipo_guia = <cod_imposto>-tipo_guia.
      <bkpf>-dia_vencimento    = <cod_imposto>-dia_vencimento.
      <bkpf>-cod_imposto_guia  = <cod_imposto>-cod_imposto_guia.
      <bkpf>-descricao_imposto = <cod_imposto>-descricao_imposto.
      <bkpf>-lifnr_imposto     = <cod_imposto>-cod_fornecedor.

*     Preenche o nome do fornecedor
      READ TABLE lt_lfa1 WITH KEY lifnr = <bkpf>-lifnr_imposto
                         ASSIGNING <lfa1>
                         BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        <bkpf>-lfa1_name1 = <lfa1>-name1.
      ENDIF.
    ENDIF.

*   Preenche o domicílio fiscal
    READ TABLE lt_j_1btxjurt WITH KEY taxjurcode = <bkpf>-domicilio_fiscal
                             ASSIGNING <j_1btxjurt>
                             BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      <bkpf>-descr_domicilio = <j_1btxjurt>-text.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SELECIONA_BKPF_EXEC_1100
*&---------------------------------------------------------------------*
FORM fill_bkpf_exec_1300 USING    p_mes TYPE monat
                                  p_ano TYPE gjahr
                                  pt_categ TYPE tty_categ
                         CHANGING pt_saida TYPE tty_saida_1300.

  DATA:
    lt_fields      TYPE rsz_t_string,
    lt_tp_imposto  TYPE tty_tp_imposto,
    lt_cod_imposto TYPE tty_cod_imposto,
    lt_empresa     TYPE tty_empresa,
    lt_emprdiv     TYPE tty_emprdiv,
    lt_bkpf        TYPE tty_bkpf,
    ls_saida       TYPE ty_saida_1300,
    l_bsak         TYPE bsak.

  FIELD-SYMBOLS:
    <bkpf>        TYPE ty_bkpf,
    <cod_imposto> LIKE LINE OF gt_1100_cod_imposto.

  REFRESH pt_saida.

  PERFORM fill_tp_imposto  USING pt_categ       CHANGING lt_tp_imposto.
  PERFORM fill_cod_imposto USING lt_tp_imposto  CHANGING lt_cod_imposto.
  PERFORM fill_empresa     USING lt_cod_imposto CHANGING lt_empresa lt_emprdiv.
  PERFORM fill_bkpf        USING lt_empresa
                                 lt_cod_imposto CHANGING lt_bkpf.
  DELETE lt_bkpf WHERE exercicio <> p_ano OR periodo <> p_mes.

  IF lt_bkpf IS INITIAL.
    MESSAGE s000 DISPLAY LIKE 'E' WITH 'Dados não encontrados.'.
    RETURN.
  ENDIF.

  LOOP AT lt_bkpf ASSIGNING <bkpf>.
    MOVE-CORRESPONDING <bkpf> TO ls_saida.

*&- 1-  Pré-Apuração:

    IF <bkpf>-data_apuracao IS NOT INITIAL.
      ls_saida-pre_icon = icon_green_light.
    ELSE.
      ls_saida-pre_icon = icon_yellow_light.
    ENDIF.

*&- 2-  Apuração:

    IF <bkpf>-data_liberacao IS NOT INITIAL.
      ls_saida-apura_icon = icon_green_light.
    ELSEIF <bkpf>-data_apuracao IS NOT INITIAL.
      ls_saida-apura_icon = icon_yellow_light.
    ELSE.
      ls_saida-apura_icon = icon_red_light.
    ENDIF.

*&- 3-  Recolhimento :

    IF <bkpf>-doc_pre_editado IS NOT INITIAL
    OR <bkpf>-doc_referencia  IS NOT INITIAL.
      ls_saida-reco_icon = icon_green_light.
    ELSEIF <bkpf>-data_grava_rec IS NOT INITIAL.
      ls_saida-reco_icon = icon_yellow_light.
    ELSE.
      ls_saida-reco_icon = icon_red_light.
    ENDIF.

*&- 4-  Aprovação Pagamento


*Start  - Marcelo Alvares - MA004818 S4D MZARI001F01 ZCT0 - 24.10.2018 17:54
* Erro reportado pelo Bianor Neves, status do doc aprovado pelo worflow continuava como amarelo
*    IF <bkpf>-doc_referencia IS NOT INITIAL.
    IF lcl_fi_doc_reader=>is_doc_normal_status( <bkpf> ) EQ abap_true.
*END    - Marcelo Alvares - MA004818 S4D MZARI001F01 ZCT0 - 24.10.2018 17:54
      ls_saida-aprov_icon = icon_green_light.
    ELSEIF <bkpf>-doc_pre_editado IS NOT INITIAL.
      ls_saida-aprov_icon = icon_yellow_light.
    ELSE.
      ls_saida-aprov_icon = icon_red_light.
    ENDIF.

*&- 5-  Compensado

*----------------------------------------------------------------------*
* Início Alteração - 26.07.2016
*----------------------------------------------------------------------*
*   IF <bkpf>-doc_compensacao IS NOT INITIAL.
*     ls_saida-comp_icon = icon_green_light.
*   ELSE.
*     ls_saida-comp_icon = icon_red_light.
*   ENDIF.
*----------------------------------------------------------------------*
* Fim Alteração - 26.07.2016
*----------------------------------------------------------------------*

*&- 6-  Pagamento

    SELECT *
      INTO l_bsak
      FROM bsak UP TO 1 ROWS
     WHERE bukrs = <bkpf>-empresa
       AND belnr = <bkpf>-doc_referencia
       AND gjahr = <bkpf>-exercicio.
    ENDSELECT.

    IF sy-subrc IS INITIAL.
      ls_saida-pagto_icon = icon_green_light.
    ELSE.
      ls_saida-pagto_icon = icon_red_light.
    ENDIF.

    READ TABLE lt_cod_imposto WITH KEY codigo_imposto = <bkpf>-codigo_imposto
                              ASSIGNING <cod_imposto>
                              BINARY SEARCH.
    IF sy-subrc = 0.
      <bkpf>-descricao_imposto = <cod_imposto>-descricao_imposto.
    ENDIF.

    APPEND ls_saida TO pt_saida.

  ENDLOOP.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_SALV11
*&---------------------------------------------------------------------*
FORM fieldcat_1300_salv21  CHANGING pr_table TYPE REF TO cl_salv_table.

  DATA:
    lr_column TYPE REF TO cl_salv_column_table,
    lr_cols   TYPE REF TO cl_salv_columns,
    lt_fields TYPE lvc_t_fcat,  "rsz_t_string,
    lv_field  LIKE LINE OF lt_fields.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = 'ZARI_COCKPIT_BKPF_ALV3'
    CHANGING
      ct_fieldcat            = lt_fields
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  CHECK sy-subrc = 0.

  LOOP AT lt_fields INTO lv_field.

    lr_column ?= pr_table->get_columns( )->get_column( lv_field-fieldname ).

    CASE lv_field-fieldname.
      WHEN 'EMPRESA'.
      WHEN 'DIVISAO'.
      WHEN 'NUM_DOC_APURACAO'.
      WHEN 'TIPO_IMPOSTO'.
      WHEN 'CODIGO_IMPOSTO'.
      WHEN 'DESCRICAO_IMPOSTO'.
        lr_column->set_optimized( 'X' ).
      WHEN 'UF'.
      WHEN 'DOMICILIO_FISCAL'.
      WHEN 'PRE_ICON'.
        lr_column->set_short_text( 'Pré' ).
        lr_column->set_medium_text( 'Pré-Apuração' ).
        lr_column->set_long_text( 'Pré-Apuração' ).
        lr_column->set_output_length( 4 ).
      WHEN 'APURA_ICON'.
        lr_column->set_short_text( 'Apura' ).
        lr_column->set_medium_text( 'Apuração' ).
        lr_column->set_long_text( 'Apuração' ).
        lr_column->set_output_length( 4 ).
      WHEN 'RECO_ICON'.
        lr_column->set_short_text( 'Recolh' ).
        lr_column->set_medium_text( 'Recolhimento' ).
        lr_column->set_long_text( 'Recolhimento' ).
        lr_column->set_output_length( 4 ).
      WHEN 'APROV_ICON'.
        lr_column->set_short_text( 'Apr.Pgto' ).
        lr_column->set_medium_text( 'Aprovação Pgto' ).
        lr_column->set_long_text( 'Aprovação Pagamento' ).
        lr_column->set_output_length( 4 ).
*----------------------------------------------------------------------*
* Início Alteração - 26.07.2016
*----------------------------------------------------------------------*
*     WHEN 'COMP_ICON'.
*       lr_column->set_medium_text( 'Compens' ).
*       lr_column->set_long_text( 'Compensação' ).
*       lr_column->set_output_length( 4 ).
*----------------------------------------------------------------------*
* Fim Alteração - 26.07.2016
*----------------------------------------------------------------------*
      WHEN 'PAGTO_ICON'.
        lr_column->set_medium_text( 'Pagto' ).
        lr_column->set_long_text( 'Pagamento' ).
        lr_column->set_output_length( 4 ).
      WHEN OTHERS.
        lr_column->set_visible( abap_false ).
    ENDCASE.
  ENDLOOP.

  DATA:
        lo_event_handler TYPE REF TO lcl_1300_event_handler_21.

  DATA: lo_events TYPE REF TO cl_salv_events_table.

  lo_events = pr_table->get_event( ).

  CREATE OBJECT lo_event_handler.

  SET HANDLER: lo_event_handler->on_link_click   FOR lo_events,
               lo_event_handler->on_double_click FOR lo_events.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_SPLITTER_1400
*&---------------------------------------------------------------------*
FORM get_splitter_1400  USING    pr_parent TYPE REF TO cl_gui_custom_container
                        CHANGING pr_splitter TYPE REF TO cl_gui_splitter_container.

* Cria o divisor para a cabeçalho e o grid
  CREATE OBJECT pr_splitter
    EXPORTING
      rows    = 1
      columns = 4
      parent  = pr_parent.

  pr_splitter->set_row_height(
    id     = 1
    height = 4 ).

  pr_splitter->set_row_sash(
    id    = 1
    type  = 0
    value = 0 ).

ENDFORM.                    " GET_SPLITTER_1400

*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_1400_SALV11
*&---------------------------------------------------------------------*
FORM fieldcat_1400_salv11  CHANGING pr_table TYPE REF TO cl_salv_table.

  DATA:
    lr_column TYPE REF TO cl_salv_column_table,
    lr_cols   TYPE REF TO cl_salv_columns.

  lr_column ?= pr_table->get_columns( )->get_column( 'EMPRESA' ).
  lr_column->set_short_text( 'Empresa' ).
  lr_column->set_medium_text( 'Empresa' ).
  lr_column->set_long_text( 'Empresa' ).

  lr_column ?= pr_table->get_columns( )->get_column( 'PERIODO' ).
  lr_column->set_short_text( 'Per.Base' ).
  lr_column->set_medium_text( 'Período Base' ).
  lr_column->set_long_text( 'Período Base' ).

  lr_column ?= pr_table->get_columns( )->get_column( 'TIPO_IMPOSTO' ).
  lr_column->set_medium_text( 'Tipo' ).
  lr_column->set_long_text( 'Tipo' ).

  lr_column ?= pr_table->get_columns( )->get_column( 'CODIGO_IMPOSTO' ).
  lr_column->set_medium_text( 'Código' ).
  lr_column->set_long_text( 'Código' ).

  lr_column ?= pr_table->get_columns( )->get_column( 'BASE_ICON' ).
  lr_column->set_short_text( 'Base Pré' ).
  lr_column->set_medium_text( 'Base Pré' ).
  lr_column->set_long_text( 'BasePré' ).
  lr_column->set_icon( if_salv_c_bool_sap=>true ).
  lr_column->set_output_length( 3 ).

  lr_column ?= pr_table->get_columns( )->get_column( 'PRE_ICON' ).
  lr_column->set_short_text( 'Pré' ).
  lr_column->set_medium_text( 'Pré' ).
  lr_column->set_long_text( 'Pré' ).
  lr_column->set_icon( if_salv_c_bool_sap=>true ).
  lr_column->set_output_length( 3 ).

  lr_column ?= pr_table->get_columns( )->get_column( 'APURA_ICON' ).
  lr_column->set_short_text( 'Apura' ).
  lr_column->set_medium_text( 'Apura' ).
  lr_column->set_long_text( 'Apura' ).
  lr_column->set_icon( if_salv_c_bool_sap=>true ).
  lr_column->set_output_length( 3 ).

  lr_column ?= pr_table->get_columns( )->get_column( 'NUM_DOC_APURA' ).
  lr_column->set_medium_text( 'Nr.Doc.Apuração' ).
  lr_column->set_long_text( 'Nr.Doc.Apuração' ).

  lr_column ?= pr_table->get_columns( )->get_column( 'RECO_ICON' ).
  lr_column->set_medium_text( 'Reco' ).
  lr_column->set_long_text( 'Reco' ).
  lr_column->set_icon( if_salv_c_bool_sap=>true ).
  lr_column->set_output_length( 3 ).

  lr_column ?= pr_table->get_columns( )->get_column( 'NUM_DOC_RECO' ).
  lr_column->set_medium_text( 'Nr.Doc.Apuração' ).
  lr_column->set_long_text( 'Nr.Doc.Apuração' ).

*  DATA:
*        lo_event_handler TYPE REF TO lcl_1400_event_handler_11.
*
*  DATA: lo_events TYPE REF TO cl_salv_events_table.
*
*  lo_events = pr_table->get_event( ).
*
*  CREATE OBJECT lo_event_handler.
*
*  SET HANDLER: lo_event_handler->on_link_click   FOR lo_events,
*               lo_event_handler->on_double_click FOR lo_events.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  EXECUTA_ZPAG
*&---------------------------------------------------------------------*
FORM executa_zpag .

  DATA: lt_msg TYPE TABLE OF bdcmsgcoll.
  DATA: lt_bdc TYPE TABLE OF bdcdata.
  DATA: wa_options TYPE ctu_params,
        v_data     TYPE c LENGTH 10,
        v_valor    TYPE c LENGTH 17.

  FIELD-SYMBOLS: <fs_msg> LIKE LINE OF lt_msg.

  CLEAR wa_options.
  MOVE: 'S' TO wa_options-updmode,
        'E' TO wa_options-dismode,
        'X' TO wa_options-racommit.

* Gravar linha a linha
  LOOP AT gt_1200_bkpf INTO ws_1200_bkpf WHERE check IS NOT INITIAL.

    CLEAR: v_data, v_valor.

    FREE: lt_msg, lt_bdc.

*--> Início - Alteração  07.12.2018 11:48:14 - WR005118
*       Busca o nome do contribuinte pelo CNPJ
    PERFORM busca_contribuinte_cnpj USING    ws_1200_bkpf-cnpj
                                             ws_1200_bkpf-empresa
                                    CHANGING ws_1200_bkpf-bbranch_name.
*<-- Fim - 07.12.2018 11:48:14
*   Se o valor o montante apurado for zero,
    IF ws_1200_bkpf-montante_apurado = 0.

      PERFORM guarda_msg  USING    'ZARI'
                                   'I'
                                   '007'  "Documento &1 &2 &3 tem montante apurado 0.
                                   ws_1200_bkpf-empresa
                                   ws_1200_bkpf-num_doc_apuracao
                                   ws_1200_bkpf-exercicio
                                   space
                          CHANGING lt_msg.

      UPDATE zari_bkpf
      SET data_recolhimento         = sy-datum
          nome_usuario_recolhimento = sy-uname
          doc_pre_editado           = ws_1200_bkpf-num_doc_apuracao
*          doc_referencia            = ws_1200_bkpf-num_doc_apuracao "MFS 08.04.2016
       WHERE empresa                = ws_1200_bkpf-empresa
          AND num_doc_apuracao      = ws_1200_bkpf-num_doc_apuracao
          AND exercicio             = ws_1200_bkpf-exercicio.

      MESSAGE s000 WITH 'Documentos processados com sucesso.'
                        space space space.

*   Se houver montante apurado,
    ELSE.

*     Tela de entrada
      PERFORM f_montar_campo_tela TABLES lt_bdc
                                  USING:
              'X'  'SAPMZFI0001'           '1000',
              ' '  'BDC_OKCODE'            'SAVE',
              ' '  'T001-BUKRS'            ws_1200_bkpf-empresa,
              ' '  'ZPAGFOR-LIFNR'         ws_1200_bkpf-lifnr_imposto,
              ' '  'BKPF-XBLNR'            ws_1200_bkpf-referencia,
              ' '  'BSEG-GSBER'            ws_1200_bkpf-divisao.

      CLEAR v_data.
      WRITE ws_1200_bkpf-data_geracao TO v_data.
      PERFORM f_montar_campo_tela TABLES lt_bdc
                                  USING ' '  'BKPF-BLDAT'  v_data.

      CLEAR v_data.
      WRITE sy-datum TO v_data.
      PERFORM f_montar_campo_tela TABLES lt_bdc
                                  USING ' '  'BKPF-BUDAT'  v_data.

      CLEAR v_valor.
      WRITE ws_1200_bkpf-montante_apurado TO v_valor CURRENCY 'BRL'.
      PERFORM f_montar_campo_tela TABLES lt_bdc
                                  USING ' '  'BSEG-WRBTR'  v_valor.

      CLEAR v_valor.
      WRITE ws_1200_bkpf-montante_multa TO v_valor CURRENCY 'BRL'.
      PERFORM f_montar_campo_tela TABLES lt_bdc
                                  USING ' '  'G_MULTA'  v_valor.

      CLEAR v_valor.
      WRITE ws_1200_bkpf-montante_juros TO v_valor CURRENCY 'BRL'.
      PERFORM f_montar_campo_tela TABLES lt_bdc
                                  USING ' '  'G_JUROS'  v_valor.

      CLEAR v_valor.
      WRITE ws_1200_bkpf-montante_taxcorr TO v_valor CURRENCY 'BRL'.
      PERFORM f_montar_campo_tela TABLES lt_bdc
                                  USING ' '  'G_TAXA'  v_valor.

      CLEAR v_data.
      WRITE ws_1200_bkpf-data_vencimento TO v_data.
      PERFORM f_montar_campo_tela TABLES lt_bdc
                                  USING ' '  'BSEG-ZFBDT'  v_data.

      PERFORM f_montar_campo_tela TABLES lt_bdc
                                  USING:
              'X'  'SAPLZPCT_GUIAS'          '9000',
              ' '  'BDC_OKCODE'              '=OK'.
      if ws_1200_bkpf-TIPO_IMPOSTO ne 'ISS'.
        PERFORM f_montar_campo_tela TABLES lt_bdc
                                   USING:
               ' '  'ZPCT_PGTO_ITEM-NOMCON'   ws_1200_bkpf-bbranch_name,
               ' '  'ZPCT_PGTO_ITEM-CDPAGT'   ws_1200_bkpf-cod_imposto_guia,
               ' '  'WV_INSCRICAO'            ws_1200_bkpf-cnpj,
               ' '  'ZPCT_PGTO_ITEM-COMPET'   ws_1200_bkpf-referencia.
      endif.
*--> Início - Alteração  20.12.2018 11:47:55 - WR005118
*     ' '  'ZPCT_PGTO_ITEM-NRREFE'   ws_1200_bkpf-referencia.       "Referencia da Guia de Recolhimento
      if WV_CODBAR is NOT INITIAL.
        PERFORM f_montar_campo_tela TABLES lt_bdc
                                   USING:
               ' '  'WV_CODBAR'   WV_CODBAR.       "Referencia da Guia de Recolhimento
      endif.

      if ws_1200_bkpf-TIPO_IMPOSTO ne 'INSS' and ws_1200_bkpf-TIPO_IMPOSTO ne 'ISS'.
        PERFORM f_montar_campo_tela TABLES lt_bdc
                                   USING:
               ' '  'ZPCT_PGTO_ITEM-NRREFE'   ws_1200_bkpf-referencia.       "Referencia da Guia de Recolhimento
      endif.
*<-- Fim - 20.12.2018 11:47:55


*            ' '  'ZPCT_PGTO_ITEM-ENDRUA'   WS_1200_BKPF-,
*            ' '  'ZPCT_PGTO_ITEM-ENDNUM'   WS_1200_BKPF-,
*            ' '  'ZPCT_PGTO_ITEM-ENDCOM'   WS_1200_BKPF-,
*            ' '  'ZPCT_PGTO_ITEM-ENDBAI'   WS_1200_BKPF-,
*            ' '  'ZPCT_PGTO_ITEM-ENDCID'   WS_1200_BKPF-,
*            ' '  'ZPCT_PGTO_ITEM-ENDCEP'   WS_1200_BKPF-,
*            ' '  'ZPCT_PGTO_ITEM-ENDEST'   WS_1200_BKPF-.

*--> Início - Alteração  20.12.2018 11:47:29 - WR005118
      if ws_1200_bkpf-TIPO_IMPOSTO ne 'INSS' and ws_1200_bkpf-TIPO_IMPOSTO ne 'ISS'.
        CLEAR v_data.
        WRITE ws_1200_bkpf-data_recolhimento TO v_data.
        PERFORM f_montar_campo_tela TABLES lt_bdc
                                    USING ' '  'ZPCT_PGTO_ITEM-PRAPUR'  v_data.
      endif.
*<-- Fim - 20.12.2018 11:47:29

      CLEAR v_data.
*--> Início - Alteração  21.12.2018 10:25:24 - WR005118

      if ws_1200_bkpf-TIPO_IMPOSTO ne 'ISS'.
*WRITE ws_1200_bkpf-data_vencimento TO v_data.
        write GS_1210_BKPF_ALV-DATA_VENCIMENTO TO v_data.
*<-- Fim - 21.12.2018 10:25:24

        PERFORM f_montar_campo_tela TABLES lt_bdc
                                    USING ' '  'ZPCT_PGTO_ITEM-DATVEN'  v_data.
      endif.
      PERFORM f_montar_campo_tela TABLES lt_bdc
                                  USING:
              'X'  'SAPMSSY0'                 '0120',
              ' '  'BDC_OKCODE'               '=&ONT'.

      PERFORM f_montar_campo_tela TABLES lt_bdc
                                  USING:
              'X'  'SAPMZFI0001'              '1000',
              ' '  'BDC_OKCODE'               '/EBACK'.

      CALL TRANSACTION 'ZPAG'
        USING lt_bdc
              OPTIONS FROM wa_options
              MESSAGES INTO lt_msg.

*     Buscar Num.Documento pre-editado
      READ TABLE lt_msg WITH KEY msgtyp = 'S'
                                 msgid  = 'FP'
                                 msgnr  = '001'
                        ASSIGNING <fs_msg>.
      IF sy-subrc EQ 0.

        UPDATE zari_bkpf
        SET data_recolhimento         = sy-datum
            nome_usuario_recolhimento = sy-uname
            doc_pre_editado           = <fs_msg>-msgv1
         WHERE empresa                = ws_1200_bkpf-empresa
            AND num_doc_apuracao      = ws_1200_bkpf-num_doc_apuracao
            AND exercicio             = ws_1200_bkpf-exercicio.

        MESSAGE s000 WITH 'Documentos processados com sucesso.'
                          space space space.
      ELSE.
        MESSAGE s000 DISPLAY LIKE 'E' WITH 'Houve erros no processamento' 'dos documentos,'
                                           'verificar histórico de cada documento' space.
      ENDIF.
    ENDIF.

    PERFORM f_preparar_msg_saida USING    lt_msg
                                          'Transação ZPAG'.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_MONTAR_CAMPO_TELA
*&---------------------------------------------------------------------*
FORM f_montar_campo_tela TABLES pt_bdc STRUCTURE bdcdata
                         USING p_dynbegin
                               p_name
                               p_values.

  FIELD-SYMBOLS: <fs_bdc> TYPE bdcdata.

  APPEND INITIAL LINE TO pt_bdc ASSIGNING <fs_bdc>.

  IF NOT p_dynbegin IS INITIAL.

    MOVE: p_name   TO <fs_bdc>-program,
          p_values TO <fs_bdc>-dynpro,
          'X'      TO <fs_bdc>-dynbegin.

  ELSE.
    MOVE: p_name   TO <fs_bdc>-fnam,
          p_values TO <fs_bdc>-fval.

  ENDIF.
ENDFORM.                    "f_montar_campo_tela
*&---------------------------------------------------------------------*
*&      Form  f_preparar_msg_saida
*&---------------------------------------------------------------------*
FORM f_preparar_msg_saida USING pt_msg   TYPE tab_bdcmsgcoll
                                p_titulo TYPE c.

  FIELD-SYMBOLS: <fs_msg> TYPE bdcmsgcoll.

  CHECK NOT pt_msg[] IS INITIAL.

  CALL FUNCTION 'MESSAGES_INITIALIZE'
    EXCEPTIONS
      log_not_active       = 1
      wrong_identification = 2
      OTHERS               = 3.
  CHECK sy-subrc IS INITIAL.

  LOOP AT pt_msg ASSIGNING <fs_msg>.
    CALL FUNCTION 'MESSAGE_STORE'
      EXPORTING
        arbgb                  = <fs_msg>-msgid
        msgty                  = <fs_msg>-msgtyp
        msgv1                  = <fs_msg>-msgv1
        msgv2                  = <fs_msg>-msgv2
        msgv3                  = <fs_msg>-msgv3
        msgv4                  = <fs_msg>-msgv4
        txtnr                  = <fs_msg>-msgnr
      EXCEPTIONS
        message_type_not_valid = 1
        not_active             = 2
        OTHERS                 = 3.
    CHECK sy-subrc IS INITIAL.
  ENDLOOP.

  CALL FUNCTION 'MESSAGES_SHOW'
    EXPORTING
      object             = p_titulo
    EXCEPTIONS
      inconsistent_range = 1
      no_messages        = 2
      OTHERS             = 3.
  CHECK sy-subrc IS INITIAL.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILTER_EMPRESA
*&---------------------------------------------------------------------*
* Filtra as configurações por empresa-divisão marcada
*----------------------------------------------------------------------*
FORM filter_empresa  USING    pt_emprdiv TYPE tty_emprdiv
                     CHANGING pt_empresa TYPE tty_empresa.

  FIELD-SYMBOLS: <fs_empresa> LIKE LINE OF pt_empresa.

  LOOP AT pt_empresa ASSIGNING <fs_empresa>.
    READ TABLE pt_emprdiv WITH KEY empresa_div = <fs_empresa>-empresa_div
                          TRANSPORTING NO FIELDS
                          BINARY SEARCH.
    CHECK sy-subrc <> 0.
    DELETE pt_empresa.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_J_1BTXJURT
*&---------------------------------------------------------------------*
* Seleciona dados da tabela de textos para código brasileiro do domicílio fiscal
*----------------------------------------------------------------------*
FORM fill_j_1btxjurt  USING    pt_bkpf       TYPE tty_bkpf
                      CHANGING pt_j_1btxjurt TYPE tty_j_1btxjurt.

  DATA: BEGIN OF lt_filtro OCCURS 0,
          taxjurcode TYPE j_1btxjurt-taxjurcode,
        END OF lt_filtro.

  FIELD-SYMBOLS: <bkpf> LIKE LINE OF pt_bkpf.

* Monta filtro para seleção
  LOOP AT pt_bkpf ASSIGNING <bkpf> WHERE NOT domicilio_fiscal IS INITIAL.
    READ TABLE lt_filtro WITH KEY taxjurcode = <bkpf>-domicilio_fiscal
                         TRANSPORTING NO FIELDS
                         BINARY SEARCH.
    CHECK sy-subrc <> 0.
    INSERT <bkpf>-domicilio_fiscal INTO lt_filtro
                                   INDEX sy-tabix.  "~já ordenado
  ENDLOOP.

* Só prossegue se houver dados no filtro
  CHECK NOT lt_filtro[] IS INITIAL.

* Seleciona dados da tabela de textos para código brasileiro do domicílio fiscal
  SELECT *
    INTO TABLE pt_j_1btxjurt
    FROM j_1btxjurt FOR ALL ENTRIES IN lt_filtro
   WHERE spras   = 'P'
     AND country = 'BR'
     AND taxjurcode = lt_filtro-taxjurcode.

  SORT pt_j_1btxjurt BY taxjurcode ASCENDING.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_LFA1
*&---------------------------------------------------------------------*
* Seleciona dados da tabela de Fornecedores
*----------------------------------------------------------------------*
FORM fill_lfa1  USING    pt_cod_imposto TYPE tty_cod_imposto
                CHANGING pt_lfa1        TYPE tty_lfa1.

  DATA: BEGIN OF lt_filtro OCCURS 0,
          lifnr TYPE lfa1-lifnr,
        END OF lt_filtro.

  FIELD-SYMBOLS: <cod_imposto> LIKE LINE OF pt_cod_imposto.

* Monta filtro para seleção
  LOOP AT pt_cod_imposto ASSIGNING <cod_imposto> WHERE NOT cod_fornecedor IS INITIAL.
    READ TABLE lt_filtro WITH KEY lifnr = <cod_imposto>-cod_fornecedor
                         TRANSPORTING NO FIELDS
                         BINARY SEARCH.
    CHECK sy-subrc <> 0.
    INSERT <cod_imposto>-cod_fornecedor INTO lt_filtro
                                 INDEX sy-tabix.  "~já ordenado
  ENDLOOP.

* Só prossegue se houver dados no filtro
  CHECK NOT lt_filtro[] IS INITIAL.

* Seleciona dados da tabela de Fornecedores
  SELECT lifnr
         name1
         mcod1
    INTO TABLE pt_lfa1
    FROM lfa1 FOR ALL ENTRIES IN lt_filtro
   WHERE lifnr = lt_filtro-lifnr.

  SORT pt_lfa1 BY lifnr ASCENDING.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_LFA1_2
*&---------------------------------------------------------------------*
* Seleciona dados da tabela de Fornecedores
*----------------------------------------------------------------------*
FORM fill_lfa1_2  USING    pt_bseg TYPE tty_bseg
                  CHANGING pt_lfa1 TYPE tty_lfa1.

  DATA: BEGIN OF lt_filtro OCCURS 0,
          lifnr TYPE lfa1-lifnr,
        END OF lt_filtro.

  FIELD-SYMBOLS: <bseg> LIKE LINE OF pt_bseg.

* Monta filtro para seleção
  LOOP AT pt_bseg ASSIGNING <bseg> WHERE NOT cod_fornecedor IS INITIAL.
    READ TABLE lt_filtro WITH KEY lifnr = <bseg>-cod_fornecedor
                         TRANSPORTING NO FIELDS
                         BINARY SEARCH.
    CHECK sy-subrc <> 0.
    INSERT <bseg>-cod_fornecedor INTO lt_filtro
                                 INDEX sy-tabix.  "~já ordenado
  ENDLOOP.

* Só prossegue se houver dados no filtro
  CHECK NOT lt_filtro[] IS INITIAL.

* Seleciona dados da tabela de Fornecedores
  SELECT lifnr
         name1
         mcod1
    INTO TABLE pt_lfa1
    FROM lfa1 FOR ALL ENTRIES IN lt_filtro
   WHERE lifnr = lt_filtro-lifnr.

  SORT pt_lfa1 BY lifnr ASCENDING.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CALCULA_RECOLHIMENTO
*&---------------------------------------------------------------------*
* Calcula o valor total do recolhimento
*----------------------------------------------------------------------*
FORM calcula_recolhimento  CHANGING p_bkpf TYPE ty_bkpf.

  p_bkpf-montante_recolhimento = p_bkpf-montante_apurado
                               + p_bkpf-montante_taxcorr
                               + p_bkpf-montante_multa
                               + p_bkpf-montante_juros.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  VALIDA_DOC_MARCADO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM valida_doc_marcado  USING    pt_bkpf    TYPE tty_bkpf
                                  p_situacao TYPE c
                         CHANGING p_subrc    TYPE sysubrc.

  READ TABLE pt_bkpf WITH KEY check = 'X'
                              situacao = p_situacao
                          TRANSPORTING NO FIELDS.
*                          BINARY SEARCH.  "não está ordenado
  IF sy-subrc <> 0.
    MESSAGE 'Nenhum documento válido marcado.'
       TYPE 'I'.
    p_subrc = 4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  POPUP_CONFIRMACAO
*&---------------------------------------------------------------------*
* Gera uma mensagem popup de confirmação
*----------------------------------------------------------------------*
FORM popup_confirmacao  CHANGING p_subrc TYPE sysubrc.

  DATA: lv_answer TYPE c.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'Confirmação'
      text_question         = 'Os dados devem mesmo ser modificados?'
      display_cancel_button = space
    IMPORTING
      answer                = lv_answer
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.

  p_subrc = sy-subrc.
  CHECK sy-subrc IS INITIAL.

* Dependendo da resposta do usuário,
  CASE lv_answer.

*   Não
    WHEN '2'.
      p_subrc = 4.

    WHEN OTHERS.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  BUSCA_CONTRIBUINTE_CNPJ
*&---------------------------------------------------------------------*
* Busca o nome do contribuinte pelo CNPJ
*----------------------------------------------------------------------*
FORM busca_contribuinte_cnpj  USING    p_cnpj  TYPE j_1bcgc
                                       p_bukrs TYPE bukrs
                              CHANGING p_name  TYPE j_1bbranch-name.

*  data: lt_orgdata type J_1BNFE_ORGDATA_TAB.
*  FIELD-SYMBOLS: <orgdata> like line of lt_orgdata.
*  CALL FUNCTION 'J_1BNFE_GET_ORGDATA_FROM_CNPJ'
*    EXPORTING
*      I_CNPJ               = p_cnpj
*    IMPORTING
*      ET_ORGDATA           = lt_orgdata
*    EXCEPTIONS
*      NOT_FOUND            = 1
*      OTHERS               = 2.
*  check SY-SUBRC = 0.
*  read table lt_orgdata INDEX 1 ASSIGNING <orgdata>.
*  check SY-SUBRC = 0.


  DATA: lv_cgc_branch TYPE j_1bcgcbra,
        lv_branch     TYPE j_1bbranch-branch.     "CNPJ Business Place

* MFS 26/04/2016
  DATA : cgc_number  LIKE j_1bwfield-cgc_number,
         address1    LIKE addr1_val,
         branch_data LIKE j_1bbranch.

* MFS 26/04/2016

*  e_cnpj = cgc_company (c8) + cgc_branch (n4) + check_digits (c2)
  lv_cgc_branch = p_cnpj+8(4).

  SELECT SINGLE branch FROM j_1bbranch
    INTO lv_branch
    WHERE bukrs      EQ p_bukrs
      AND cgc_branch EQ lv_cgc_branch.
  CHECK sy-subrc = 0.
* MFS 26/04/2016
* Buscando os dados da Filial
  CALL FUNCTION 'J_1BREAD_BRANCH_DATA'
    EXPORTING
      branch      = lv_branch
      bukrs       = p_bukrs
    IMPORTING
      branch_data = branch_data
      cgc_number  = cgc_number
      address1    = address1
    EXCEPTIONS
      OTHERS      = 04.

  IF sy-subrc = 0.
    p_name = address1-name1.
  ELSE.
    MESSAGE w453 WITH p_bukrs lv_branch.
  ENDIF.
* MFS 26/04/2016
*  select single NAME
*    into p_name
*    from j_1bbranch
*   where bukrs =  p_bukrs
*     and branch = lv_branch.
*  check sy-subrc is initial.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  EXECUTA_COMPENSACAO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM executa_compensacao  USING    pt_bkpf TYPE tty_bkpf.

  DATA: s_empresa TYPE RANGE OF zari_bkpf-empresa,
        s_num_doc TYPE RANGE OF zari_bkpf-num_doc_apuracao,
        s_exercic TYPE RANGE OF zari_bkpf-exercicio,
        lt_bkpf   TYPE tty_bkpf,
        lt_bseg   TYPE tty_bseg,
        l_subrc   TYPE sysubrc,
        lt_msg    TYPE tab_bdcmsgcoll.

  FIELD-SYMBOLS: <bkpf>    LIKE LINE OF pt_bkpf,
                 <empresa> LIKE LINE OF s_empresa,
                 <num_doc> LIKE LINE OF s_num_doc,
                 <exercic> LIKE LINE OF s_exercic.

* Percorre os documentos marcados,
  LOOP AT pt_bkpf ASSIGNING <bkpf> WHERE check IS NOT INITIAL.

*   Se for apuracao 0,
    IF <bkpf>-doc_pre_editado = <bkpf>-num_doc_apuracao. "MFS 08.04.2016

      <bkpf>-doc_compensacao = <bkpf>-doc_referencia = <bkpf>-doc_pre_editado.
      APPEND <bkpf> TO lt_bkpf.

    ELSE.

*     Monta o range de empresa
      READ TABLE s_empresa WITH KEY low = <bkpf>-empresa
                           TRANSPORTING NO FIELDS
                           BINARY SEARCH.
      IF sy-subrc <> 0.
        INSERT INITIAL LINE INTO s_empresa
                       ASSIGNING <empresa>
                           INDEX sy-tabix.  "já ordenado
        <empresa>-sign = 'I'.
        <empresa>-option = 'EQ'.
        <empresa>-low = <bkpf>-empresa.
      ENDIF.

*     Monta o range de documento
      READ TABLE s_num_doc WITH KEY low = <bkpf>-num_doc_apuracao
                           TRANSPORTING NO FIELDS
                           BINARY SEARCH.
      IF sy-subrc <> 0.
        INSERT INITIAL LINE INTO s_num_doc
                       ASSIGNING <num_doc>
                           INDEX sy-tabix.  "já ordenado
        <num_doc>-sign = 'I'.
        <num_doc>-option = 'EQ'.
        <num_doc>-low = <bkpf>-num_doc_apuracao.
      ENDIF.

*     Monta o range de empresa
      READ TABLE s_exercic WITH KEY low = <bkpf>-exercicio
                           TRANSPORTING NO FIELDS
                           BINARY SEARCH.
      IF sy-subrc <> 0.
        INSERT INITIAL LINE INTO s_exercic
                       ASSIGNING <exercic>
                           INDEX sy-tabix.  "já ordenado
        <exercic>-sign = 'I'.
        <exercic>-option = 'EQ'.
        <exercic>-low = <bkpf>-exercicio.
      ENDIF.
    ENDIF.
  ENDLOOP.

* Se houver apuracao 0,
  IF NOT lt_bkpf[] IS INITIAL.

*   Seleciona dados da tabela de Item - Documento do SAP
    PERFORM fill_bseg  USING    lt_bkpf
                       CHANGING lt_bseg.

    LOOP AT lt_bkpf ASSIGNING <bkpf>.
      PERFORM modificacao_em_massa USING    <bkpf>
                                            lt_bseg
                                   CHANGING l_subrc
                                            lt_msg.
*     MFS 8.04.2016
      IF l_subrc IS INITIAL.
        MODIFY zari_bkpf FROM <bkpf>.
        COMMIT WORK AND WAIT.
      ENDIF.
*     MFS 8.04.2016

    ENDLOOP.
  ENDIF.

* Chama programa ZARI002
  IF s_num_doc[] IS NOT INITIAL.
    SUBMIT zari002
      WITH empresa IN s_empresa
      WITH num_doc IN s_num_doc
      WITH exercic IN s_exercic
       AND RETURN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CALCULA_PERIODO_ANT
*&---------------------------------------------------------------------*
* Calcula o período anterior ao corrente
*----------------------------------------------------------------------*
FORM calcula_periodo_ant  CHANGING pv_periodo_ant TYPE dats.

  CALL FUNCTION 'CALCULATE_DATE'
    EXPORTING
      months      = '-1'
    IMPORTING
      result_date = pv_periodo_ant.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MANUT_PRE_ATUALIZ
*&---------------------------------------------------------------------*
* Pré-Apuração: Atualizar
*----------------------------------------------------------------------*
FORM manut_pre_atualiz  USING    p_manut        TYPE ty_manut
                                 p_empresa     TYPE ty_empresa
                                 p_cod_imposto TYPE ty_cod_imposto.

* Executa o programa da transação ZARI_PRESEL
  PERFORM executa_zari_presel USING p_empresa-empresa
                                    p_manut-monat
                                    p_manut-gjahr
                                    p_cod_imposto-codigo_imposto.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MANUT_PRE_ESTORNO
*&---------------------------------------------------------------------*
* Pré-Apuração: Estornar
*----------------------------------------------------------------------*
FORM manut_pre_estorno  USING    pt_bkpf    TYPE tty_bkpf.

  DATA: lt_msg TYPE tab_bdcmsgcoll.

  FIELD-SYMBOLS: <bkpf> LIKE LINE OF pt_bkpf.

* Percorre os documentos,
  LOOP AT pt_bkpf ASSIGNING <bkpf>.

*   Se não houver data de apuração,
    IF <bkpf>-data_apuracao IS NOT INITIAL.
*     Guarda mensagem de log de processamento
      PERFORM guarda_msg USING    'ZARI'
                                  'E'
                                  '003' "Não é possível estornar pré-apuração. Doc.&1 com data apuração &2.
                                  <bkpf>-num_doc_apuracao
                                  <bkpf>-data_apuracao
                                  space
                                  space
                         CHANGING lt_msg.
      CONTINUE.
    ENDIF.

*   Guarda mensagem de log de processamento
    PERFORM guarda_msg USING    'ZARI'
                                'S'
                                '000'
                                'Registros BKPF/BSEG apagados'
                                <bkpf>-empresa
                                <bkpf>-num_doc_apuracao
                                <bkpf>-exercicio
                       CHANGING lt_msg.

*   Elimina a linha da tabela de Cabeçalho - Documento de controle do cockpit
    DELETE FROM zari_bkpf WHERE empresa            = <bkpf>-empresa     "via índice PRIMARY-KEY
                            AND num_doc_apuracao   = <bkpf>-num_doc_apuracao
                            AND exercicio          = <bkpf>-exercicio.

*   Elimina as linhas da tabela de Item - Documento do SAP
    DELETE FROM zari_bseg WHERE empresa            = <bkpf>-empresa     "via índice PRIMARY-KEY
                            AND num_doc_apuracao   = <bkpf>-num_doc_apuracao
                            AND exercicio_apuracao = <bkpf>-exercicio.
  ENDLOOP.

* Efetiva alterações no banco de dados.
  COMMIT WORK.

* Exibe mensagens de log de processamento
  PERFORM f_preparar_msg_saida USING lt_msg
                                     'Pré-Apuração: Estornar'.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MANUT_APU_ESTORNO
*&---------------------------------------------------------------------*
* Apuração: Estornar
*----------------------------------------------------------------------*
FORM manut_apu_estorno  USING    pt_bkpf TYPE tty_bkpf.

  DATA: lt_msg TYPE tab_bdcmsgcoll.

  FIELD-SYMBOLS: <bkpf> LIKE LINE OF pt_bkpf.

* Percorre os documentos,
  LOOP AT pt_bkpf ASSIGNING <bkpf>.

*   Se houver DATA DE RECOLHIMENTO,
    IF <bkpf>-data_recolhimento IS NOT INITIAL.
*     Guarda mensagem de log de processamento
      PERFORM guarda_msg USING    'ZARI'
                                  'E'
                                  '004'  "Não é possível estornar apuração. Doc.&1 com data recolhimento &2.
                                  <bkpf>-num_doc_apuracao
                                  <bkpf>-data_recolhimento
                                  space
                                  space
                         CHANGING lt_msg.

*   Atualiza a linha da tabela de Cabeçalho - Documento de controle do cockpit
    ELSEIF <bkpf>-data_liberacao IS NOT INITIAL.

      UPDATE zari_bkpf SET data_liberacao         = '00000000'
                           nome_usuario_liberacao = space
                     WHERE empresa            = <bkpf>-empresa     "via índice PRIMARY-KEY
                       AND num_doc_apuracao   = <bkpf>-num_doc_apuracao
                       AND exercicio          = <bkpf>-exercicio.

      IF sy-subrc = 0.
*       Guarda mensagem de log de processamento
        PERFORM guarda_msg USING    'ZARI'
                                    'S'
                                    '000'
                                    'Registro BKPF data_liberacao zerada'
                                    <bkpf>-empresa
                                    <bkpf>-num_doc_apuracao
                                    <bkpf>-exercicio
                           CHANGING lt_msg.
      ELSE.
*       Guarda mensagem de log de processamento
        PERFORM guarda_msg USING    'ZARI'
                                    'E'
                                    '000'
                                    'Erro atualizando ZARI_BKPF'
                                    <bkpf>-empresa
                                    <bkpf>-num_doc_apuracao
                                    <bkpf>-exercicio
                           CHANGING lt_msg.
      ENDIF.


    ELSEIF <bkpf>-data_apuracao IS NOT INITIAL.

      UPDATE zari_bkpf SET data_apuracao         = '00000000'
                           nome_usuario_apuracao = space
                     WHERE empresa            = <bkpf>-empresa     "via índice PRIMARY-KEY
                       AND num_doc_apuracao   = <bkpf>-num_doc_apuracao
                       AND exercicio          = <bkpf>-exercicio.

      IF sy-subrc IS INITIAL.
*       Guarda mensagem de log de processamento
        PERFORM guarda_msg USING    'ZARI'
                                    'S'
                                    '000'
                                    'Registro BKPF data_apuracao zerada'
                                    <bkpf>-empresa
                                    <bkpf>-num_doc_apuracao
                                    <bkpf>-exercicio
                           CHANGING lt_msg.
      ELSE.
*       Guarda mensagem de log de processamento
        PERFORM guarda_msg USING    'ZARI'
                                    'E'
                                    '000'
                                    'Erro atualizando ZARI_BKPF'
                                    <bkpf>-empresa
                                    <bkpf>-num_doc_apuracao
                                    <bkpf>-exercicio
                           CHANGING lt_msg.
      ENDIF.
    ENDIF.
  ENDLOOP.

* Efetiva alterações no banco de dados.
  COMMIT WORK.

* Exibe mensagens de log de processamento
  PERFORM f_preparar_msg_saida USING lt_msg
                                     'Apuração: Estornar'.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MANUT_REC_ESTORNO
*&---------------------------------------------------------------------*
* Recolhimento: Estornar
*----------------------------------------------------------------------*
FORM manut_rec_estorno  USING    pt_bkpf TYPE tty_bkpf.

  DATA: l_subrc     TYPE sysubrc,
        lt_msg      TYPE tab_bdcmsgcoll,
        lt_bsik     TYPE tty_bsik,
        lt_vbsegs   TYPE tty_vbsegs,
        lt_bkpf_std TYPE tty_bkpf_std,
        lt_vbkpf    TYPE tty_vbkpf,
        lt_bseg     TYPE tty_bseg.

  FIELD-SYMBOLS: <bkpf> LIKE LINE OF pt_bkpf.

* Seleciona dados da tabela de Contabilidade: índice secundário para fornecedores
  PERFORM fill_bsik USING    pt_bkpf
                    CHANGING lt_bsik.

* Seleciona dados da tabela de Segmento da pré-edição do doc. - banco dados p/contas Razão
  PERFORM fill_vbsegs USING    pt_bkpf
                      CHANGING lt_vbsegs.

* Seleciona dados da tabela de Cabeçalho do documento contábil standard
  PERFORM fill_bkpf_std USING    pt_bkpf
                        CHANGING lt_bkpf_std.

* Seleciona dados da documentos pré-editados
  PERFORM fill_vbkpf USING    pt_bkpf
                     CHANGING lt_vbkpf.

* Seleciona dados da tabela de Item - Documento do SAP
  PERFORM fill_bseg  USING    pt_bkpf
                     CHANGING lt_bseg.

* Percorre os documentos,
  LOOP AT pt_bkpf ASSIGNING <bkpf>.

*   COMPENSADO
    IF <bkpf>-doc_compensacao IS NOT INITIAL.

*     Recolhimento: Estornar: Compensado
      PERFORM manut_rec_estorno_compensado USING    <bkpf>
                                                    lt_bsik
                                                    lt_bseg
                                                    lt_vbsegs
                                                    lt_bkpf_std
                                           CHANGING l_subrc
                                                    lt_msg.

*     Se não houve erros,
      IF l_subrc IS INITIAL.
        UPDATE zari_bkpf SET doc_compensacao  = space
                             doc_referencia   = space
                             doc_pre_editado  = space
                       WHERE empresa          = <bkpf>-empresa     "via índice PRIMARY-KEY
                         AND num_doc_apuracao = <bkpf>-num_doc_apuracao
                         AND exercicio        = <bkpf>-exercicio.
        IF sy-subrc IS INITIAL.
*         Guarda mensagem de log de processamento
          PERFORM guarda_msg USING    'ZARI'
                                      'S'
                                      '000'
                                      'Registro BKPF doc_comp/ref/pre zerados'
                                      <bkpf>-empresa
                                      <bkpf>-num_doc_apuracao
                                      <bkpf>-exercicio
                             CHANGING lt_msg.
        ELSE.
*         Guarda mensagem de log de processamento
          PERFORM guarda_msg USING    'ZARI'
                                      'E'
                                      '000'
                                      'Erro atualizando ZARI_BKPF'
                                      <bkpf>-empresa
                                      <bkpf>-num_doc_apuracao
                                      <bkpf>-exercicio
                             CHANGING lt_msg.
        ENDIF.
      ENDIF.

**   APROVADO
    ELSEIF <bkpf>-doc_referencia IS NOT INITIAL.
* MFS 08.04.2016 -
*     Recolhimento: Estornar: Aprovado
*     Estornar apuração zerada.
      IF <bkpf>-num_doc_apuracao = <bkpf>-doc_referencia.
        l_subrc = '0'.
      ELSE.
        l_subrc = '4'.
      ENDIF.
*     Se não houve erros,
      IF l_subrc IS INITIAL.
        UPDATE zari_bkpf SET doc_compensacao  = space
                             doc_referencia   = space
                             doc_pre_editado  = space
                       WHERE empresa          = <bkpf>-empresa     "via índice PRIMARY-KEY
                         AND num_doc_apuracao = <bkpf>-num_doc_apuracao
                         AND exercicio        = <bkpf>-exercicio.
        IF sy-subrc IS INITIAL.
*         Guarda mensagem de log de processamento
          PERFORM guarda_msg USING    'ZARI'
                                      'S'
                                      '000'
                                      'Registro BKPF doc_comp/ref/pre zerados'
                                      <bkpf>-empresa
                                      <bkpf>-num_doc_apuracao
                                      <bkpf>-exercicio
                             CHANGING lt_msg.
        ELSE.
*         Guarda mensagem de log de processamento
          PERFORM guarda_msg USING    'ZARI'
                                      'E'
                                      '000'
                                      'Erro atualizando ZARI_BKPF'
                                      <bkpf>-empresa
                                      <bkpf>-num_doc_apuracao
                                      <bkpf>-exercicio
                             CHANGING lt_msg.
        ENDIF.
      ENDIF.
* MFS 08.04.2016
*   LANÇADO
    ELSEIF <bkpf>-doc_pre_editado IS NOT INITIAL.

*     Recolhimento: Estornar: Lançado
      PERFORM manut_rec_estorno_lancado  USING    <bkpf>
                                                  lt_bsik
                                                  lt_bseg
                                                  lt_vbsegs
                                                  lt_bkpf_std
                                                  lt_vbkpf
                                         CHANGING l_subrc
                                                  lt_msg.

*     Se não houve erros,
      IF l_subrc IS INITIAL.
        UPDATE zari_bkpf SET doc_pre_editado   = space
                       WHERE empresa          = <bkpf>-empresa     "via índice PRIMARY-KEY
                         AND num_doc_apuracao = <bkpf>-num_doc_apuracao
                         AND exercicio        = <bkpf>-exercicio.
        IF sy-subrc IS INITIAL.
*         Guarda mensagem de log de processamento
          PERFORM guarda_msg USING    'ZARI'
                                      'S'
                                      '000'
                                      'Registro BKPF doc_pre_editado zerado'
                                      <bkpf>-empresa
                                      <bkpf>-num_doc_apuracao
                                      <bkpf>-exercicio
                             CHANGING lt_msg.
        ELSE.
*         Guarda mensagem de log de processamento
          PERFORM guarda_msg USING    'ZARI'
                                      'E'
                                      '000'
                                      'Erro atualizando ZARI_BKPF'
                                      <bkpf>-empresa
                                      <bkpf>-num_doc_apuracao
                                      <bkpf>-exercicio
                             CHANGING lt_msg.
        ENDIF.
      ENDIF.

*   CONFIRMADO
    ELSEIF <bkpf>-data_grava_rec IS NOT INITIAL.

      UPDATE zari_bkpf SET data_grava_rec   = '00000000'
                           hora_grava_rec   = '000000'
                           nome_grava_rec   = space
                     WHERE empresa          = <bkpf>-empresa     "via índice PRIMARY-KEY
                       AND num_doc_apuracao = <bkpf>-num_doc_apuracao
                       AND exercicio        = <bkpf>-exercicio.
      IF sy-subrc IS INITIAL.
*       Guarda mensagem de log de processamento
        PERFORM guarda_msg USING    'ZARI'
                                    'S'
                                    '000'
                                    'Registro BKPF data_grava_rec zerada'
                                    <bkpf>-empresa
                                    <bkpf>-num_doc_apuracao
                                    <bkpf>-exercicio
                           CHANGING lt_msg.
      ELSE.
*       Guarda mensagem de log de processamento
        PERFORM guarda_msg USING    'ZARI'
                                    'E'
                                    '000'
                                    'Erro atualizando ZARI_BKPF'
                                    <bkpf>-empresa
                                    <bkpf>-num_doc_apuracao
                                    <bkpf>-exercicio
                           CHANGING lt_msg.
      ENDIF.

*   GRAVADO
    ELSEIF <bkpf>-data_recolhimento IS NOT INITIAL.

      UPDATE zari_bkpf SET data_recolhimento         = '00000000'
                           nome_usuario_recolhimento = space
                           montante_multa            = 0
                           montante_juros            = 0
                           montante_taxcorr          = 0
                           referencia                = space
                     WHERE empresa                   = <bkpf>-empresa     "via índice PRIMARY-KEY
                       AND num_doc_apuracao          = <bkpf>-num_doc_apuracao
                       AND exercicio                 = <bkpf>-exercicio.
      IF sy-subrc IS INITIAL.
*       Guarda mensagem de log de processamento
        PERFORM guarda_msg USING    'ZARI'
                                    'S'
                                    '000'
                                    'Registro BKPF data_recolhimento zerada'
                                    <bkpf>-empresa
                                    <bkpf>-num_doc_apuracao
                                    <bkpf>-exercicio
                           CHANGING lt_msg.
      ELSE.
*       Guarda mensagem de log de processamento
        PERFORM guarda_msg USING    'ZARI'
                                    'E'
                                    '000'
                                    'Erro atualizando ZARI_BKPF'
                                    <bkpf>-empresa
                                    <bkpf>-num_doc_apuracao
                                    <bkpf>-exercicio
                           CHANGING lt_msg.
      ENDIF.
    ENDIF.

  ENDLOOP.

* Efetiva alterações no banco de dados.
  COMMIT WORK.

* Exibe mensagens de log de processamento
  PERFORM f_preparar_msg_saida USING lt_msg
                                     'Recolhimento: Estornar'.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  EXECUTA_ZARI_PRESEL
*&---------------------------------------------------------------------*
* Executa transação ZARI_PRESEL
*----------------------------------------------------------------------*
FORM executa_zari_presel USING    p_bukrs        TYPE bukrs
                                  p_monat        TYPE monat
                                  p_gjahr        TYPE gjahr
                                  p_codigo_imposto TYPE zari_bkpf-codigo_imposto.

  RANGES: r_bukrs FOR zari_bkpf-empresa,
          r_hkont FOR zari_bseg-conta_contabil,
          r_gjahr FOR zari_bkpf-exercicio,
          r_monat FOR zari_bkpf-periodo.

* Monta range de empresa
  r_bukrs-sign   = 'I'.
  r_bukrs-option = 'EQ'.
  r_bukrs-low    = p_bukrs.
  APPEND r_bukrs.

* Monta range de conta contábil
  PERFORM monta_r_hkont TABLES     r_hkont
                        USING      p_codigo_imposto.

* Monta range de exercicio
  r_gjahr-sign   = 'I'.
  r_gjahr-option = 'EQ'.
  r_gjahr-low    = p_gjahr.
  APPEND r_gjahr.

* Monta range de período
  r_monat-sign   = 'I'.
  r_monat-option = 'EQ'.
  r_monat-low    = p_monat.
  APPEND r_monat.

* Chama programa da transação ZARI_PRESEL
  SUBMIT zari001
    WITH s_bukrs IN r_bukrs
    WITH s_hkont IN r_hkont
    WITH s_gjahr IN r_gjahr
    WITH s_monat IN r_monat
*    with s_cpudt in r_cpudt
*    via SELECTION-SCREEN
     AND RETURN.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MONTA_R_HKONT
*&---------------------------------------------------------------------*
* Monta range de conta contábil para categoria/tipo/código imposto
*----------------------------------------------------------------------*
FORM monta_r_hkont  TABLES   pt_rg_hkont
                    USING    p_codigo_imposto TYPE zari_bkpf-codigo_imposto.

  DATA: BEGIN OF lt_cod_imposto OCCURS 0,
          codigo_imposto TYPE zari_cod_imposto-codigo_imposto,
          conta_contabil TYPE zari_cod_imposto-conta_contabil,
        END OF lt_cod_imposto.

* Seleciona códigos de imposto
  SELECT codigo_imposto
         conta_contabil
    INTO TABLE lt_cod_imposto
    FROM zari_cod_imposto
   WHERE codigo_imposto = p_codigo_imposto.  "via índice PRIMARY-KEY

  CHECK sy-subrc IS INITIAL.

* Monta range a partir das linhas selecionadas
  pt_rg_hkont[] = zcl_utils=>get_range_of_table( im_table = lt_cod_imposto[]
                                                 im_field = 'CONTA_CONTABIL' ).

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND_1400_manut
*&---------------------------------------------------------------------*
* Executa a ação de manutenção selecionada
*----------------------------------------------------------------------*
FORM user_command_1400_manut USING    p_manut        TYPE ty_manut
                                      pt_empresa     TYPE tty_empresa
                                      pt_emprdiv     TYPE tty_emprdiv
                                      pt_cod_imposto TYPE tty_cod_imposto.

  DATA: lt_emprdiv     TYPE tty_emprdiv,
        lt_empresa     TYPE tty_empresa,
        lt_cod_imposto TYPE tty_cod_imposto,
        lt_bkpf        TYPE tty_bkpf,
        l_subrc        TYPE sysubrc.

  FIELD-SYMBOLS: <empresa>     LIKE LINE OF lt_empresa,
                 <cod_imposto> LIKE LINE OF lt_cod_imposto,
                 <bkpf>        LIKE LINE OF lt_bkpf.

* Busca a empresa-divisão marcada
  lt_empresa[] = pt_empresa[].
  lt_emprdiv[] = pt_emprdiv[].
  DELETE lt_emprdiv WHERE check IS INITIAL.     "deve haver apenas 1
  PERFORM filter_empresa  USING    lt_emprdiv
                          CHANGING lt_empresa.

* Busca o código imposto marcado
  lt_cod_imposto[] = pt_cod_imposto[].
  DELETE lt_cod_imposto WHERE check IS INITIAL. "deve haver apenas 1

* Preenche a lista de documentos
  PERFORM fill_bkpf USING    lt_empresa
                             lt_cod_imposto
                    CHANGING lt_bkpf.

* Descarta linha fora do exercício/período
  DELETE lt_bkpf WHERE NOT ( exercicio = p_manut-gjahr
                         AND periodo   = p_manut-monat ).

* Aplica filtro de documento, se houver,
  IF NOT p_manut-num_doc_apuracao IS INITIAL.
    DELETE lt_bkpf WHERE NOT num_doc_apuracao = p_manut-num_doc_apuracao.
  ENDIF.

* Busca o código de imposto marcado
  READ TABLE lt_cod_imposto ASSIGNING <cod_imposto>
                            INDEX 1.
  IF NOT sy-subrc IS INITIAL.
    MESSAGE 'Marcar um código de imposto.'
       TYPE 'I'.
    EXIT.
  ENDIF.

* Busca a empresa marcada
  READ TABLE lt_empresa ASSIGNING <empresa>
                        INDEX 1.
  IF NOT sy-subrc IS INITIAL.
    MESSAGE 'Marcar uma empresa.'
       TYPE 'I'.
    EXIT.
  ENDIF.

* Verifica se os parâmetros estão preenchidos
  IF p_manut-monat IS INITIAL
  OR p_manut-gjahr IS INITIAL.
    MESSAGE 'Preencher Período Base.'
       TYPE 'I'.
    EXIT.
  ENDIF.

* Gera uma mensagem popup de confirmação
  PERFORM popup_confirmacao  CHANGING l_subrc.
  CHECK l_subrc IS INITIAL.

* Dependendo da opção marcada,
  CASE 'X'.

*   Pré-Apuração: atualizar
    WHEN wa_1400_manut-pre_atualiz.
      PERFORM manut_pre_atualiz USING p_manut
                                      <empresa>
                                      <cod_imposto>.

*   Pré-Apuração: estornar
    WHEN wa_1400_manut-pre_estorno.
      PERFORM manut_pre_estorno USING lt_bkpf.

*   Apuração: estornar
    WHEN wa_1400_manut-apu_estorno.
      PERFORM manut_apu_estorno USING lt_bkpf.

*   Recolhimento: estornar
    WHEN wa_1400_manut-rec_estorno.
      PERFORM manut_rec_estorno USING lt_bkpf.

    WHEN OTHERS.
      MESSAGE 'Nenhuma ação selecionada'
         TYPE 'S'.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PREENCHE_SITUACAO_APU
*&---------------------------------------------------------------------*
* Preenche a situação do documento em APURAÇÃO
*----------------------------------------------------------------------*
FORM preenche_situacao_apu  CHANGING p_bkpf TYPE ty_bkpf.

  IF p_bkpf-data_liberacao IS NOT INITIAL.
    p_bkpf-situacao = 'Liberado'.
  ELSEIF p_bkpf-data_apuracao IS NOT INITIAL.
    p_bkpf-situacao = 'Gravado'.
  ELSE.
    p_bkpf-situacao = space.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PREENCHE_SITUACAO_REC
*&---------------------------------------------------------------------*
* Preenche a situação do documento em RECOLHIMENTO
*----------------------------------------------------------------------*
FORM preenche_situacao_rec  CHANGING p_bkpf TYPE ty_bkpf.

* Recolhimento
  IF p_bkpf-doc_compensacao IS NOT INITIAL.
    p_bkpf-situacao = 'Compensado'.
  ELSEIF p_bkpf-doc_referencia IS NOT INITIAL.
    p_bkpf-situacao = 'Aprovado'.
  ELSEIF p_bkpf-doc_pre_editado IS NOT INITIAL.
    p_bkpf-situacao = 'Lançado'.
  ELSEIF p_bkpf-data_grava_rec IS NOT INITIAL.
    p_bkpf-situacao = 'Confirmado'.
  ELSEIF p_bkpf-data_recolhimento IS NOT INITIAL.
    p_bkpf-situacao = 'Gravado'.
  ELSE.
    p_bkpf-situacao = space.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  DROPDOWN_1400_MONAT
*&---------------------------------------------------------------------*
* Preenche as opções do período.
*----------------------------------------------------------------------*
FORM dropdown_1400_monat .

  DATA : lt_values TYPE vrm_values,
         le_value  LIKE LINE OF lt_values,
         ln_monat  TYPE monat.

  REFRESH lt_values.
  DO 12 TIMES.
    ADD 1 TO ln_monat.
    le_value-key  = ln_monat.
    APPEND le_value TO lt_values.
  ENDDO.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = 'WA_1400_MANUT-MONAT'
      values          = lt_values
    EXCEPTIONS
      id_illegal_name = 1
      OTHERS          = 2.
  CHECK sy-subrc = 0.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  EXECUTA_FBV0
*&---------------------------------------------------------------------*
* Executa a transação FBV0 para estornar o documento pré-editado
*----------------------------------------------------------------------*
FORM executa_fbv0  USING    p_bkpf  TYPE ty_bkpf
                   CHANGING p_subrc TYPE sysubrc
                            pt_msg  TYPE tab_bdcmsgcoll.

  DATA: lt_bdc TYPE TABLE OF bdcdata.
  DATA: wa_options TYPE ctu_params,
        v_data     TYPE c LENGTH 10,
        v_valor    TYPE c LENGTH 17.

* Limpa variáveis de retorno
  CLEAR: p_subrc.
  REFRESH: pt_msg.

  CLEAR wa_options.
  MOVE: 'S' TO wa_options-updmode,
        'N' TO wa_options-dismode,
        'X' TO wa_options-racommit.

  PERFORM f_montar_campo_tela TABLES lt_bdc USING:
    'X' 'SAPMF05V'   '0100',
    ' ' 'BDC_OKCODE' '/00',
    ' ' 'RF05V-BUKRS' p_bkpf-empresa,
    ' ' 'RF05V-BELNR' p_bkpf-doc_pre_editado,
    ' ' 'RF05V-GJAHR' p_bkpf-data_vencimento(4).

  PERFORM f_montar_campo_tela TABLES lt_bdc USING:
    'X' 'SAPLF040'    '0700',
    ' ' 'BDC_OKCODE'  '=BL'.
*    ' ' 'BKPF-XBLNR'
*    ' ' 'BKPF-BKTXT'

  PERFORM f_montar_campo_tela TABLES lt_bdc USING:
    'X' 'SAPLSPO1'    '0200',
    ' ' 'BDC_OKCODE'  '=YES'.

  CALL TRANSACTION 'FBV0'
    USING lt_bdc
          OPTIONS FROM wa_options
          MESSAGES INTO pt_msg.

* Se houve erro,
  IF NOT p_subrc IS INITIAL.
*   Guarda mensagem de log de processamento
    PERFORM guarda_msg  USING    'ZARI'
                                 'E'
                                 '000'
                                 'Erro na transação FBV0'
                                 p_bkpf-empresa
                                 p_bkpf-doc_compensacao
                                 p_bkpf-data_vencimento(4)
                        CHANGING pt_msg.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_BSIK
*&---------------------------------------------------------------------*
* Seleciona dados da tabela de Contabilidade: índice secundário para fornecedores
*----------------------------------------------------------------------*
FORM fill_bsik  USING    pt_bkpf TYPE tty_bkpf
                CHANGING pt_bsik TYPE tty_bsik.

  FIELD-SYMBOLS: <bkpf> LIKE LINE OF pt_bkpf.

* Só prossegue se houver dados no filtro
  CHECK NOT pt_bkpf[] IS INITIAL.

* Seleciona dados da tabela de Contabilidade: índice secundário para fornecedores
  SELECT bukrs "Empresa
         lifnr "Nº conta do fornecedor
         umsks "Classe de operação de Razão Especial
         umskz "Código de Razão Especial
         augdt "Data de compensação
         augbl "Nº documento de compensação
         zuonr "Nº atribuição
         gjahr "Exercício
         belnr "Nº documento de um documento contábil
         buzei "Nº linha de lançamento no documento contábil
    INTO TABLE pt_bsik
    FROM bsik FOR ALL ENTRIES IN pt_bkpf
   WHERE bukrs = pt_bkpf-empresa  "via índice 5
     AND belnr = pt_bkpf-doc_referencia
     AND gjahr = pt_bkpf-data_vencimento(4).

  SORT pt_bsik BY bukrs ASCENDING
                  belnr ASCENDING
                  gjahr ASCENDING
                  buzei ASCENDING.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  EXECUTA_FB08
*&---------------------------------------------------------------------*
* Executa a transação FB08 para estornar o documento informado
*----------------------------------------------------------------------*
FORM executa_fb08  USING    p_bkpf  TYPE ty_bkpf
                            p_belnr TYPE bkpf-belnr
                   CHANGING p_subrc TYPE sysubrc
                            pt_msg  TYPE tab_bdcmsgcoll.

  DATA: lt_bdc TYPE TABLE OF bdcdata.
  DATA: wa_options TYPE ctu_params,
        v_data     TYPE c LENGTH 10,
        v_valor    TYPE c LENGTH 17.

* Limpa variáveis de retorno
  CLEAR: p_subrc.
  REFRESH: pt_msg.

  CLEAR wa_options.
  MOVE: 'S' TO wa_options-updmode,
        'N' TO wa_options-dismode,
        'X' TO wa_options-racommit.

  PERFORM f_montar_campo_tela TABLES lt_bdc
                              USING:
    'X'  'SAPMF05A'             '0105',
    ' '  'BDC_OKCODE'           '=BU',
    ' '  'RF05A-BELNS'          p_belnr,
    ' '  'RF05A-GJAHS'          p_bkpf-data_vencimento(4),
    ' '  'BKPF-BUKRS'           p_bkpf-empresa,
    ' '  'UF05A-STGRD'          '01'.

  CALL TRANSACTION 'FB08'
             USING lt_bdc
      OPTIONS FROM wa_options
     MESSAGES INTO pt_msg.

* Se houve erro,
  IF NOT p_subrc IS INITIAL.
*   Guarda mensagem de log de processamento
    PERFORM guarda_msg  USING    'ZARI'
                                 'E'
                                 '000'
                                 'Erro na transação FB08'
                                 p_bkpf-empresa
                                 p_bkpf-doc_compensacao
                                 p_bkpf-data_vencimento(4)
                        CHANGING pt_msg.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  EXECUTA_FBRA
*&---------------------------------------------------------------------*
* Executa a transação FBRA para anular a compensação do doc.compensação
*----------------------------------------------------------------------*
FORM executa_fbra  USING    p_bkpf  TYPE ty_bkpf
                   CHANGING p_subrc TYPE sysubrc
                            pt_msg  TYPE tab_bdcmsgcoll.

  DATA: lt_bdc TYPE TABLE OF bdcdata.
  DATA: wa_options TYPE ctu_params,
        v_data     TYPE c LENGTH 10,
        v_valor    TYPE c LENGTH 17.

* Limpa variáveis de retorno
  CLEAR: p_subrc.
  REFRESH: pt_msg.

  CLEAR wa_options.
  MOVE: 'S' TO wa_options-updmode,
        'N' TO wa_options-dismode,
        'X' TO wa_options-racommit.

  PERFORM f_montar_campo_tela TABLES lt_bdc
                              USING:
    'X'  'SAPMF05R'    '0100',
    ' '  'BDC_OKCODE'  '=RAGL',
    ' '  'RF05R-AUGBL' p_bkpf-doc_compensacao,
    ' '  'RF05R-BUKRS' p_bkpf-empresa,
    ' '  'RF05R-GJAHR' p_bkpf-data_vencimento(4).

  CALL TRANSACTION 'FBRA'
             USING lt_bdc
      OPTIONS FROM wa_options
     MESSAGES INTO pt_msg.

* Se houve erro,
  IF NOT p_subrc IS INITIAL.
*   Guarda mensagem de log de processamento
    PERFORM guarda_msg  USING    'ZARI'
                                 'E'
                                 '000'
                                 'Erro na transação FBRA'
                                 p_bkpf-empresa
                                 p_bkpf-doc_compensacao
                                 p_bkpf-data_vencimento(4)
                        CHANGING pt_msg.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MANUT_REC_ESTORNO_COMPENSADO
*&---------------------------------------------------------------------*
* Recolhimento: Estornar: Compensado
*----------------------------------------------------------------------*
FORM manut_rec_estorno_compensado  USING    p_bkpf  TYPE ty_bkpf
                                            pt_bsik TYPE tty_bsik
                                            pt_bseg TYPE tty_bseg
                                            pt_vbsegs TYPE tty_vbsegs
                                            pt_bkpf_std TYPE tty_bkpf_std
                                   CHANGING p_subrc TYPE sysubrc
                                            pt_msg  TYPE tab_bdcmsgcoll.

  FIELD-SYMBOLS: <bkpf_std> LIKE LINE OF pt_bkpf_std.

  IF p_bkpf-doc_referencia NE p_bkpf-num_doc_apuracao.
* Verifica se o documento está em aberto
    READ TABLE pt_bsik WITH KEY bukrs = p_bkpf-empresa
                                belnr = p_bkpf-doc_referencia
                                gjahr = p_bkpf-data_vencimento(4)
                       TRANSPORTING NO FIELDS
                       BINARY SEARCH.
    IF sy-subrc IS NOT INITIAL.
*   Verifica se o documento é pré-editado
      READ TABLE pt_vbsegs WITH KEY ausbk = p_bkpf-empresa
                                    belnr = p_bkpf-doc_referencia
                                    gjahr = p_bkpf-data_vencimento(4)
                           TRANSPORTING NO FIELDS
                           BINARY SEARCH.
    ENDIF.

* Se não encontrou o documento em nenhum dos dois,
    IF sy-subrc IS NOT INITIAL.
*   Guarda mensagem de log de processamento
      PERFORM guarda_msg  USING    'ZARI'
                                   'E'
                                   '005'  "Não é possível estornar recolhimento &1. Doc. &2 já liquidado.
                                   p_bkpf-num_doc_apuracao
                                   p_bkpf-doc_referencia
                                   space
                                   space
                          CHANGING pt_msg.

*   Retorna código de erro
      p_subrc = 4.
      EXIT.
    ENDIF.

* Verificar se <bkpf>-DOC_COMPENSACAO não está estornado
    READ TABLE pt_bkpf_std WITH KEY bukrs = p_bkpf-empresa
                                    belnr = p_bkpf-doc_compensacao
                                    gjahr = p_bkpf-data_vencimento(4)
                           ASSIGNING <bkpf_std>
                           BINARY SEARCH.

* Se estiver avisar que o doc.compensacao foi estornado manualmente
    IF  sy-subrc = 0
    AND <bkpf_std>-xstov = 'X'.
*   Guarda mensagem de log de processamento
      PERFORM guarda_msg  USING    'ZARI'
                                   'W'
                                   '006' "Documento &1 &2 &3 estornado manualmente.
                                   p_bkpf-empresa
                                   p_bkpf-doc_compensacao
                                   p_bkpf-data_vencimento(4)
                                   space
                          CHANGING pt_msg.
    ENDIF.
  ENDIF.
* Se o doc.compensação for o próprio doc.referência,
  IF p_bkpf-doc_compensacao = p_bkpf-doc_referencia.

*   Chama rotina de alteração em massa no programa ZARI002 para alteração da atribuição
    CLEAR p_bkpf-doc_referencia.  "vai para BSEG-ZUONR
    PERFORM modificacao_em_massa USING    p_bkpf
                                          pt_bseg
                                 CHANGING p_subrc
                                          pt_msg.
    CHECK p_subrc IS INITIAL.

* Se o doc.compensação não for o doc.referência,
  ELSE.
*   Executa a transação FBRA para anular a compensação do doc.compensação
    PERFORM executa_fbra USING    p_bkpf
                         CHANGING p_subrc
                                  pt_msg.
    CHECK p_subrc IS INITIAL.
  ENDIF.

* Executa a transação FB08 para estornar o documento referência
  PERFORM executa_fb08 USING    p_bkpf
                                p_bkpf-doc_compensacao
                       CHANGING p_subrc
                                pt_msg.
  CHECK p_subrc IS INITIAL.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MANUT_REC_ESTORNO_LANCADO
*&---------------------------------------------------------------------*
* Recolhimento: Estornar: Lançado
*----------------------------------------------------------------------*
FORM manut_rec_estorno_lancado USING    p_bkpf  TYPE ty_bkpf
                                        pt_bsik TYPE tty_bsik
                                        pt_bseg TYPE tty_bseg
                                        pt_vbsegs TYPE tty_vbsegs
                                        pt_bkpf_std TYPE tty_bkpf_std
                                        pt_vbkpf    TYPE tty_vbkpf
                               CHANGING p_subrc TYPE sysubrc
                                        pt_msg  TYPE tab_bdcmsgcoll.

  FIELD-SYMBOLS: <bkpf_std> LIKE LINE OF pt_bkpf_std.

* Busca o <bkpf>-DOC_PRE_EDITADO na tabela standard BKPF
  READ TABLE pt_bkpf_std WITH KEY bukrs = p_bkpf-empresa
                                  belnr = p_bkpf-doc_pre_editado
                                  gjahr = p_bkpf-data_vencimento(4)
                         ASSIGNING <bkpf_std>
                         BINARY SEARCH.

* Se encontrou o documento na BKPF standard,
  IF  sy-subrc = 0.

*   Se estiver avisar que o doc.compensacao foi estornado manualmente
    IF <bkpf_std>-xstov = 'X'.
*     Guarda mensagem de log de processamento
      PERFORM guarda_msg  USING    'ZARI'
                                   'W'
                                   '006' "Documento &1 &2 &3 estornado manualmente.
                                   p_bkpf-empresa
                                   p_bkpf-doc_pre_editado
                                   p_bkpf-data_vencimento(4)
                                   space
                          CHANGING pt_msg.

*   Caso contrário,
    ELSE.

*     Verifica se o documento está em aberto
      READ TABLE pt_bsik WITH KEY bukrs = p_bkpf-empresa
                                  belnr = p_bkpf-doc_pre_editado
                                  gjahr = p_bkpf-data_vencimento(4)
                         TRANSPORTING NO FIELDS
                         BINARY SEARCH.
      IF sy-subrc IS NOT INITIAL.
*       Verifica se o documento é pré-editado
        READ TABLE pt_vbsegs WITH KEY ausbk = p_bkpf-empresa
                                      belnr = p_bkpf-doc_pre_editado
                                      gjahr = p_bkpf-data_vencimento(4)
                             TRANSPORTING NO FIELDS
                             BINARY SEARCH.
      ENDIF.

*     Se não encontrou o documento em nenhum dos dois,
      IF sy-subrc IS NOT INITIAL.
*       Guarda mensagem de log de processamento
        PERFORM guarda_msg  USING    'ZARI'
                                     'E'
                                     '005'  "Não é possível estornar recolhimento &1. Doc. &2 já liquidado.
                                     p_bkpf-num_doc_apuracao
                                     p_bkpf-doc_pre_editado
                                     space
                                     space
                            CHANGING pt_msg.

*       Retorna código de erro
        p_subrc = 4.
        EXIT.
      ENDIF.

*     Executa a transação FB08 para estornar o documento pré-editado
      PERFORM executa_fb08 USING    p_bkpf
                                    p_bkpf-doc_pre_editado
                           CHANGING p_subrc
                                    pt_msg.
      CHECK p_subrc IS INITIAL.
    ENDIF.

* Se não encontrou o documento na BKPF standard,
  ELSE.

*   Busca o <bkpf>-DOC_PRE_EDITADO na tabela VBKPF
    READ TABLE pt_vbkpf WITH KEY ausbk = p_bkpf-empresa
                                 bukrs = p_bkpf-empresa
                                 belnr = p_bkpf-doc_pre_editado
                                 gjahr = p_bkpf-data_vencimento(4)
                        TRANSPORTING NO FIELDS
                        BINARY SEARCH.

*   Se não estiver, avisar que o doc.compensacao foi estornado manualmente
    IF sy-subrc <> 0.
*     Guarda mensagem de log de processamento
      PERFORM guarda_msg  USING    'ZARI'
                                   'W'
                                   '006' "Documento &1 &2 &3 estornado manualmente.
                                   p_bkpf-empresa
                                   p_bkpf-doc_pre_editado
                                   p_bkpf-data_vencimento(4)
                                   space
                          CHANGING pt_msg.

*   Caso contrário,
    ELSE.
*     Executa a transação FBV0 para estornar o documento pré-editado
      PERFORM executa_fbv0 USING    p_bkpf
                           CHANGING p_subrc
                                    pt_msg.
      CHECK p_subrc IS INITIAL.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_VBSEGS
*&---------------------------------------------------------------------*
* Seleciona dados da tabela de Segmento da pré-edição do doc. - banco dados p/contas Razão
*----------------------------------------------------------------------*
FORM fill_vbsegs  USING    pt_bkpf   TYPE tty_bkpf
                  CHANGING pt_vbsegs TYPE tty_vbsegs.

* Só prossegue se houver dados no filtro
  CHECK NOT pt_bkpf[] IS INITIAL.

* Seleciona dados da tabela de Segmento da pré-edição do doc. - banco dados p/contas Razão
  SELECT ausbk "Empresa inicial
         belnr "Nº documento de um documento contábil
         gjahr "Exercício
         bzkey "Nº linha de lançamento no documento contábil
    INTO TABLE pt_vbsegs
    FROM vbsegs FOR ALL ENTRIES IN pt_bkpf
   WHERE ausbk = pt_bkpf-empresa       "via índice PRIMARY-KEY
     AND belnr = pt_bkpf-doc_referencia
     AND gjahr = pt_bkpf-data_vencimento(4).

  SORT pt_vbsegs BY ausbk ASCENDING
                    belnr ASCENDING
                    gjahr ASCENDING.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MODIFICACAO_EM_MASSA
*&---------------------------------------------------------------------*
* Chama rotina de alteração em massa no programa ZARI002 para alteração da atribuição
*----------------------------------------------------------------------*
FORM modificacao_em_massa  USING    p_bkpf  TYPE ty_bkpf
                                    pt_bseg TYPE tty_bseg
                           CHANGING p_subrc TYPE sysubrc
                                    pt_msg  TYPE tab_bdcmsgcoll.

  DATA: ls_zari_bkpf      TYPE zari_bkpf,
        lt_zari_bseg      TYPE TABLE OF zari_bseg,
        lv_conta_contabil TYPE zari_bseg-conta_contabil.

  FIELD-SYMBOLS: <bseg>      LIKE LINE OF pt_bseg,
                 <zari_bseg> LIKE LINE OF lt_zari_bseg.

* Converte o formato da tabela interna em ZARI_BKPF
  MOVE-CORRESPONDING p_bkpf TO ls_zari_bkpf.

* Converte o formato da tabela interna em ZARI_BSEG
  LOOP AT pt_bseg ASSIGNING <bseg>
    WHERE empresa            = p_bkpf-empresa
      AND num_doc_apuracao   = p_bkpf-num_doc_apuracao
      AND exercicio_apuracao = p_bkpf-exercicio.

    APPEND INITIAL LINE TO lt_zari_bseg ASSIGNING <zari_bseg>.
    MOVE-CORRESPONDING <bseg> TO <zari_bseg>.

*   Guarda a conta contábil
    IF lv_conta_contabil IS INITIAL.
      lv_conta_contabil = <bseg>-conta_contabil.
    ENDIF.
  ENDLOOP.

* Chama função standard de alteração em massa para alteração da atribuição
  PERFORM modificacao_em_massa(zari002) USING    ls_zari_bkpf
                                                 lt_zari_bseg
                                                 lv_conta_contabil
                                        CHANGING p_subrc.

* Se houve erro,
  IF NOT p_subrc IS INITIAL.
*   Guarda mensagem de log de processamento
    PERFORM guarda_msg  USING    'ZARI'
                                 'E'
                                 '000'
                                 'Erro na atualização em massa da referência ZUONR'
                                 p_bkpf-empresa
                                 p_bkpf-num_doc_apuracao
                                 p_bkpf-exercicio
                        CHANGING pt_msg.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_BKPF_STD
*&---------------------------------------------------------------------*
* Seleciona dados da tabela de Cabeçalho do documento contábil standard
*----------------------------------------------------------------------*
FORM fill_bkpf_std  USING    pt_bkpf     TYPE tty_bkpf
                    CHANGING pt_bkpf_std TYPE tty_bkpf_std.

  DATA: BEGIN OF lt_filtro OCCURS 0,
          bukrs TYPE bkpf-bukrs,
          belnr TYPE bkpf-belnr,
          gjahr TYPE bkpf-gjahr,
        END OF lt_filtro.

  FIELD-SYMBOLS: <bkpf>     LIKE LINE OF pt_bkpf.

* Monta filtro para seleção
  LOOP AT pt_bkpf ASSIGNING <bkpf>.

    IF NOT <bkpf>-doc_compensacao IS INITIAL.
      READ TABLE lt_filtro WITH KEY bukrs = <bkpf>-empresa
                                    belnr = <bkpf>-doc_compensacao
                                    gjahr = <bkpf>-data_vencimento(4)
                           TRANSPORTING NO FIELDS
                           BINARY SEARCH.
      IF sy-subrc <> 0.
        INSERT INITIAL LINE INTO lt_filtro
                           INDEX sy-tabix.  "já ordenado
        lt_filtro-bukrs = <bkpf>-empresa.
        lt_filtro-belnr = <bkpf>-doc_compensacao.
        lt_filtro-gjahr = <bkpf>-data_vencimento(4).
      ENDIF.
    ENDIF.

    IF NOT <bkpf>-doc_pre_editado IS INITIAL.
      READ TABLE lt_filtro WITH KEY bukrs = <bkpf>-empresa
                                    belnr = <bkpf>-doc_pre_editado
                                    gjahr = <bkpf>-data_vencimento(4)
                           TRANSPORTING NO FIELDS
                           BINARY SEARCH.
      IF sy-subrc <> 0.
        INSERT INITIAL LINE INTO lt_filtro
                           INDEX sy-tabix.  "já ordenado
        lt_filtro-bukrs = <bkpf>-empresa.
        lt_filtro-belnr = <bkpf>-doc_pre_editado.
        lt_filtro-gjahr = <bkpf>-data_vencimento(4).
      ENDIF.
    ENDIF.
  ENDLOOP.

* Só prossegue se houver dados no filtro
  CHECK NOT lt_filtro[] IS INITIAL.

* Seleciona dados da tabela de Cabeçalho do documento contábil standard
  SELECT bukrs "Empresa
         belnr "Nº documento de um documento contábil
         gjahr "Exercício
         xstov "Código: documento marcado para estorno
    INTO TABLE pt_bkpf_std
    FROM bkpf FOR ALL ENTRIES IN lt_filtro
   WHERE bukrs = lt_filtro-bukrs  "via índice PRIMARY-KEY
     AND belnr = lt_filtro-belnr
     AND gjahr = lt_filtro-gjahr.

  SORT pt_bkpf_std BY bukrs ASCENDING
                      belnr ASCENDING
                      gjahr ASCENDING.

  FREE: lt_filtro.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_VBKPF
*&---------------------------------------------------------------------*
* Seleciona dados da tabela de documentos pré-editados
*----------------------------------------------------------------------*
FORM fill_vbkpf USING    pt_bkpf  TYPE tty_bkpf
                CHANGING pt_vbkpf TYPE tty_vbkpf.

  DATA: BEGIN OF lt_filtro OCCURS 0,
          bukrs TYPE bkpf-bukrs,
          belnr TYPE bkpf-belnr,
          gjahr TYPE bkpf-gjahr,
        END OF lt_filtro.

  FIELD-SYMBOLS: <bkpf>  LIKE LINE OF pt_bkpf.

* Monta filtro para seleção
  LOOP AT pt_bkpf ASSIGNING <bkpf>.

    IF NOT <bkpf>-doc_compensacao IS INITIAL.
      READ TABLE lt_filtro WITH KEY bukrs = <bkpf>-empresa
                                    belnr = <bkpf>-doc_compensacao
                                    gjahr = <bkpf>-data_vencimento(4)
                           TRANSPORTING NO FIELDS
                           BINARY SEARCH.
      IF sy-subrc <> 0.
        INSERT INITIAL LINE INTO lt_filtro
                           INDEX sy-tabix.  "já ordenado
        lt_filtro-bukrs = <bkpf>-empresa.
        lt_filtro-belnr = <bkpf>-doc_compensacao.
        lt_filtro-gjahr = <bkpf>-data_vencimento(4).
      ENDIF.
    ENDIF.

    IF NOT <bkpf>-doc_pre_editado IS INITIAL.
      READ TABLE lt_filtro WITH KEY bukrs = <bkpf>-empresa
                                    belnr = <bkpf>-doc_pre_editado
                                    gjahr = <bkpf>-data_vencimento(4)
                           TRANSPORTING NO FIELDS
                           BINARY SEARCH.
      IF sy-subrc <> 0.
        INSERT INITIAL LINE INTO lt_filtro
                           INDEX sy-tabix.  "já ordenado
        lt_filtro-bukrs = <bkpf>-empresa.
        lt_filtro-belnr = <bkpf>-doc_pre_editado.
        lt_filtro-gjahr = <bkpf>-data_vencimento(4).
      ENDIF.
    ENDIF.
  ENDLOOP.

* Só prossegue se houver dados no filtro
  CHECK NOT lt_filtro[] IS INITIAL.

* Seleciona dados da tabela de documentos pré-editados
  SELECT ausbk "Empresa inicial
         bukrs "Empresa
         belnr "Nº documento de um documento contábil
         gjahr "Exercício
    INTO TABLE pt_vbkpf
    FROM vbkpf FOR ALL ENTRIES IN lt_filtro
   WHERE ausbk = lt_filtro-bukrs  "via índice PRIMARY-KEY
     AND bukrs = lt_filtro-bukrs
     AND belnr = lt_filtro-belnr
     AND gjahr = lt_filtro-gjahr.

  SORT pt_vbkpf BY ausbk ASCENDING
                   bukrs ASCENDING
                   belnr ASCENDING
                   gjahr ASCENDING.

  FREE: lt_filtro.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PAI_MALL
*&---------------------------------------------------------------------*
* Marcar/desmarcar todas as linhas
*----------------------------------------------------------------------*
FORM pai_mall_uall  USING    p_check  TYPE xfeld
                    CHANGING pt_table TYPE ANY TABLE.

  FIELD-SYMBOLS: <row>   TYPE any,
                 <check> TYPE xfeld.

  LOOP AT pt_table ASSIGNING <row>.
    ASSIGN COMPONENT 'CHECK' OF STRUCTURE <row> TO <check>.
    CHECK sy-subrc IS INITIAL.
    <check> = p_check.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  REFRESH_SALV_11
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM refresh_salv_11  USING    po_salv11      TYPE REF TO cl_salv_table
                               po_salv12      TYPE REF TO cl_salv_table
                               po_salv13      TYPE REF TO cl_salv_table
                               po_salv14      TYPE REF TO cl_salv_table
                               pt_categ       TYPE tty_categ
                      CHANGING pt_tp_imposto  TYPE tty_tp_imposto
                               pt_cod_imposto TYPE tty_cod_imposto
                               pt_empresa     TYPE tty_empresa
                               pt_emprdiv     TYPE tty_emprdiv.

  DATA: lt_categ TYPE tty_categ.

  lt_categ[] = pt_categ[].
  DELETE lt_categ WHERE check = space.

  REFRESH: pt_tp_imposto,
           pt_cod_imposto,
           pt_empresa,
           pt_emprdiv.

  PERFORM fill_tp_imposto USING lt_categ CHANGING pt_tp_imposto.

  po_salv11->refresh( ).
  po_salv12->refresh( ).
  po_salv13->refresh( ).
  po_salv14->refresh( ).

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  REFRESH_SALV_12
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM refresh_salv_12  USING    po_salv12      TYPE REF TO cl_salv_table
                               po_salv13      TYPE REF TO cl_salv_table
                               po_salv14      TYPE REF TO cl_salv_table
                               pt_tp_imposto  TYPE tty_tp_imposto
                      CHANGING pt_cod_imposto TYPE tty_cod_imposto
                               pt_empresa     TYPE tty_empresa
                               pt_emprdiv     TYPE tty_emprdiv.

  DATA: lt_tp_imposto TYPE tty_tp_imposto.

  lt_tp_imposto[] = pt_tp_imposto[].
  DELETE lt_tp_imposto WHERE check = space.

  REFRESH: pt_cod_imposto,
           pt_empresa,
           pt_emprdiv.

  PERFORM fill_cod_imposto USING lt_tp_imposto CHANGING pt_cod_imposto.

  po_salv12->refresh( ).
  po_salv13->refresh( ).
  po_salv14->refresh( ).

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  REFRESH_SALV_13
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM refresh_salv_13  USING    po_salv13      TYPE REF TO cl_salv_table
                               po_salv14      TYPE REF TO cl_salv_table
                               pt_cod_imposto TYPE tty_cod_imposto
                      CHANGING pt_empresa     TYPE tty_empresa
                               pt_emprdiv     TYPE tty_emprdiv.

  DATA: lt_cod_imposto TYPE tty_cod_imposto.

  lt_cod_imposto[] = pt_cod_imposto[].
  DELETE lt_cod_imposto WHERE check = space.

  REFRESH: pt_empresa,
           pt_emprdiv.

  PERFORM fill_empresa USING    lt_cod_imposto
                       CHANGING pt_empresa pt_emprdiv.

  po_salv13->refresh( ).
  po_salv14->refresh( ).

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  REFRESH_SALV_14
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM refresh_salv_14  USING    p_tela         TYPE n
                               po_salv14      TYPE REF TO cl_salv_table
                               pt_cod_imposto TYPE tty_cod_imposto
                               pt_empresa     TYPE tty_empresa
                               pt_emprdiv     TYPE tty_emprdiv
                               pr_sel_monat       TYPE REF TO cl_dd_select_element
                               pr_inp_gjahr       TYPE REF TO cl_dd_input_element
                      CHANGING pt_bkpf        TYPE tty_bkpf
                               pt_bkpf_aux    TYPE tty_bkpf
                               pt_bseg        TYPE tty_bseg.

  DATA: lt_empresa TYPE tty_empresa,
        lt_emprdiv TYPE tty_emprdiv.
  DATA:
    lv_monat TYPE monat,
    lv_gjahr TYPE gjahr.
  WRITE pr_sel_monat->value TO lv_monat.
  WRITE pr_inp_gjahr->value TO lv_gjahr.

  lt_emprdiv[] = pt_emprdiv[].
  DELETE lt_emprdiv WHERE check = space.

  REFRESH: pt_bkpf,
           pt_bseg.

  IF lt_emprdiv IS NOT INITIAL.

*   Filtra as configurações por empresa-divisão marcada
    lt_empresa[] = pt_empresa[].
    PERFORM filter_empresa USING    lt_emprdiv
                           CHANGING lt_empresa.

    PERFORM fill_bkpf_1100_1200 USING    p_tela
                                         lv_monat
                                         lv_gjahr
                                         lt_empresa
                                         pt_cod_imposto
                                CHANGING pt_bkpf.
    pt_bkpf_aux = pt_bkpf.
  ENDIF.

  po_salv14->refresh( ).

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GUARDA_MSG
*&---------------------------------------------------------------------*
* Guarda mensagem no log de processamento
*----------------------------------------------------------------------*
FORM guarda_msg  USING    p_id     TYPE symsgid
                          p_type   TYPE symsgty
                          p_number TYPE symsgno
                          p_v1     TYPE any
                          p_v2     TYPE any
                          p_v3     TYPE any
                          p_v4     TYPE any
                 CHANGING pt_msg   TYPE tab_bdcmsgcoll.

  FIELD-SYMBOLS: <msg> LIKE LINE OF pt_msg.

  APPEND INITIAL LINE TO pt_msg ASSIGNING <msg>.
  <msg>-msgid  = p_id.
  <msg>-msgnr  = p_number.
  <msg>-msgtyp = p_type.
  WRITE p_v1 TO <msg>-msgv1.
  WRITE p_v2 TO <msg>-msgv2.
  WRITE p_v3 TO <msg>-msgv3.
  WRITE p_v4 TO <msg>-msgv4.

ENDFORM.
