*&---------------------------------------------------------------------*
*&  Include           MZARI001IMP01
*&---------------------------------------------------------------------*

CLASS lcl_1100_event_handler_11 IMPLEMENTATION.

  METHOD on_link_click.

    FIELD-SYMBOLS: <categ> LIKE LINE OF gt_1100_categ.

    READ TABLE gt_1100_categ ASSIGNING <categ> INDEX row.

    CHECK sy-subrc IS INITIAL.

    IF <categ>-check IS INITIAL.
      <categ>-check = 'X'.
    ELSE.
      CLEAR <categ>-check.
    ENDIF.

    PERFORM refresh_salv_11 USING    go_1100_salv11
                                     go_1100_salv12
                                     go_1100_salv13
                                     go_1100_salv14
                                     gt_1100_categ
                            CHANGING gt_1100_tp_imposto
                                     gt_1100_cod_imposto
                                     gt_1100_empresa
                                     gt_1100_emprdiv.

    REFRESH: gt_1100_bkpf,
             gt_1100_bkpf_aux,
             gt_1100_bseg.
    go_1100_salv22->refresh( refresh_mode = if_salv_c_refresh=>full ). "atualizar subtotais etc
    go_1100_salv31->refresh( refresh_mode = if_salv_c_refresh=>full ). "atualizar subtotais etc

  ENDMETHOD.                    "on_link_click
ENDCLASS.

CLASS lcl_1100_event_handler_12 IMPLEMENTATION.

  METHOD on_link_click.

    FIELD-SYMBOLS: <tp_imposto> LIKE LINE OF gt_1100_tp_imposto.

    READ TABLE  gt_1100_tp_imposto ASSIGNING <tp_imposto> INDEX row.

    CHECK sy-subrc IS INITIAL.

    IF <tp_imposto>-check IS INITIAL.
      <tp_imposto>-check = 'X'.
    ELSE.
      CLEAR <tp_imposto>-check.
    ENDIF.

    PERFORM refresh_salv_12 USING    go_1100_salv12
                                     go_1100_salv13
                                     go_1100_salv14
                                     gt_1100_tp_imposto
                            CHANGING gt_1100_cod_imposto
                                     gt_1100_empresa
                                     gt_1100_emprdiv.

    REFRESH: gt_1100_bkpf,
             gt_1100_bkpf_aux,
             gt_1100_bseg.
    go_1100_salv22->refresh( refresh_mode = if_salv_c_refresh=>full ). "atualizar subtotais etc
    go_1100_salv31->refresh( refresh_mode = if_salv_c_refresh=>full ). "atualizar subtotais etc

  ENDMETHOD.                    "on_link_click
ENDCLASS.

CLASS lcl_1100_event_handler_13 IMPLEMENTATION.

  METHOD on_link_click.

    FIELD-SYMBOLS: <cod_imposto> LIKE LINE OF gt_1100_cod_imposto.

    READ TABLE  gt_1100_cod_imposto ASSIGNING <cod_imposto> INDEX row.

    CHECK sy-subrc IS INITIAL.

    IF <cod_imposto>-check IS INITIAL.
      <cod_imposto>-check = 'X'.
    ELSE.
      CLEAR <cod_imposto>-check.
    ENDIF.

    PERFORM refresh_salv_13 USING    go_1100_salv13
                                     go_1100_salv14
                                     gt_1100_cod_imposto
                            CHANGING gt_1100_empresa
                                     gt_1100_emprdiv.

    REFRESH: gt_1100_bkpf,
             gt_1100_bkpf_aux,
             gt_1100_bseg.
    go_1100_salv22->refresh( refresh_mode = if_salv_c_refresh=>full ). "atualizar subtotais etc
    go_1100_salv31->refresh( refresh_mode = if_salv_c_refresh=>full ). "atualizar subtotais etc

  ENDMETHOD.                    "on_link_click
ENDCLASS.

CLASS lcl_1100_event_handler_14 IMPLEMENTATION.

  METHOD on_link_click.

    FIELD-SYMBOLS: <emprdiv> LIKE LINE OF gt_1100_emprdiv.

    READ TABLE  gt_1100_emprdiv ASSIGNING <emprdiv> INDEX row.

    CHECK sy-subrc IS INITIAL.

    IF <emprdiv>-check IS INITIAL.
      <emprdiv>-check = 'X'.
    ELSE.
      CLEAR <emprdiv>-check.
    ENDIF.

    DATA:
      lv_monat TYPE monat,
      lv_gjahr TYPE gjahr.
    WRITE sel_1100_monat->value TO lv_monat.
    WRITE inp_1100_gjahr->value TO lv_gjahr.

    PERFORM refresh_salv_14 USING    '1100'
                                     go_1100_salv14
                                     gt_1100_cod_imposto
                                     gt_1100_empresa
                                     gt_1100_emprdiv
                                     sel_1100_monat
                                     inp_1100_gjahr
                            CHANGING gt_1100_bkpf
                                     gt_1100_bkpf_aux
                                     gt_1100_bseg.
    go_1100_salv22->refresh( refresh_mode = if_salv_c_refresh=>full ). "atualizar subtotais etc
    go_1100_salv31->refresh( refresh_mode = if_salv_c_refresh=>full ). "atualizar subtotais etc

  ENDMETHOD.                    "on_link_click
ENDCLASS.

CLASS lcl_1100_event_handler_21 IMPLEMENTATION.

  METHOD on_clicked.
    DATA:
      lv_monat TYPE monat,
      lv_gjahr TYPE gjahr,
      lv_subrc TYPE sysubrc.

    FIELD-SYMBOLS <bkpf> LIKE LINE OF gt_1100_bkpf.

    WRITE sel_1100_monat->value TO lv_monat.
    WRITE inp_1100_gjahr->value TO lv_gjahr.

    CASE sender->name.

      WHEN 'EXEC'.
        PERFORM fill_bkpf_exec_1100 USING     lv_monat
                                              lv_gjahr
                                              gt_1100_categ
                                              gt_1100_tp_imposto
                                              gt_1100_cod_imposto
                                              gt_1100_empresa
                                              gt_1100_emprdiv
                                     CHANGING gt_1100_bkpf.

      WHEN 'BUT1'.
        PERFORM fill_bkpf_exec_1100 USING     lv_monat
                                              lv_gjahr
                                              gt_1100_categ
                                              gt_1100_tp_imposto
                                              gt_1100_cod_imposto
                                              gt_1100_empresa
                                              gt_1100_emprdiv
                                     CHANGING gt_1100_bkpf.
*        gt_1100_bkpf = gt_1100_bkpf_aux.
        DELETE gt_1100_bkpf WHERE competencia <> 'S'.

      WHEN 'BUT2'.
        PERFORM fill_bkpf_exec_1100 USING     lv_monat
                                              lv_gjahr
                                              gt_1100_categ
                                              gt_1100_tp_imposto
                                              gt_1100_cod_imposto
                                              gt_1100_empresa
                                              gt_1100_emprdiv
                                     CHANGING gt_1100_bkpf.
*        gt_1100_bkpf = gt_1100_bkpf_aux.
        DELETE gt_1100_bkpf WHERE competencia <> 'N'.

      WHEN 'BUT3'. "Gravar PAG.51

        PERFORM valida_doc_marcado USING    gt_1100_bkpf
                                            space  "situação
                                   CHANGING lv_subrc.
        CHECK lv_subrc IS INITIAL.

        PERFORM popup_confirmacao CHANGING lv_subrc.
        CHECK lv_subrc IS INITIAL.

        LOOP AT gt_1100_bkpf ASSIGNING <bkpf> WHERE check = 'X' AND situacao = space.
          UPDATE zari_bkpf
          SET data_apuracao = sy-datum
              nome_usuario_apuracao = sy-uname
          WHERE empresa = <bkpf>-empresa
          AND num_doc_apuracao = <bkpf>-num_doc_apuracao
          AND exercicio = <bkpf>-exercicio.
          <bkpf>-situacao = 'Gravado'.
        ENDLOOP.
        COMMIT WORK.

      WHEN 'BUT4'. "Liberar

        PERFORM valida_doc_marcado USING    gt_1100_bkpf
                                            'Gravado'
                                   CHANGING lv_subrc.
        CHECK lv_subrc IS INITIAL.

        PERFORM popup_confirmacao CHANGING lv_subrc.
        CHECK lv_subrc IS INITIAL.

        LOOP AT gt_1100_bkpf ASSIGNING <bkpf> WHERE check = 'X' AND situacao = 'Gravado'.
          UPDATE zari_bkpf
          SET data_liberacao = sy-datum
              nome_usuario_liberacao = sy-uname
          WHERE empresa = <bkpf>-empresa
          AND num_doc_apuracao = <bkpf>-num_doc_apuracao
          AND exercicio = <bkpf>-exercicio.
          <bkpf>-situacao = 'Liberado'.
        ENDLOOP.
        COMMIT WORK.

    ENDCASE.
    go_1100_salv22->refresh( refresh_mode = if_salv_c_refresh=>full ). "atualizar subtotais etc
    REFRESH: gt_1100_bseg.
    go_1100_salv31->refresh( refresh_mode = if_salv_c_refresh=>full ). "atualizar subtotais etc
  ENDMETHOD.                    "handle_submit_buttons
ENDCLASS.

CLASS lcl_1100_event_handler_22 IMPLEMENTATION.

  METHOD on_link_click.

    FIELD-SYMBOLS: <bkpf> LIKE LINE OF gt_1100_bkpf.

    READ TABLE  gt_1100_bkpf ASSIGNING <bkpf> INDEX row.
    CHECK sy-subrc IS INITIAL.

    IF <bkpf>-check IS INITIAL.
      <bkpf>-check = 'X'.
    ELSE.
      CLEAR <bkpf>-check.
    ENDIF.

    go_1100_salv22->refresh( refresh_mode = if_salv_c_refresh=>full ). "atualizar subtotais etc
  ENDMETHOD.                    "on_link_click
  METHOD on_double_click.
    DATA:
              lt_bkpf TYPE tty_bkpf.
    FIELD-SYMBOLS: <bkpf> LIKE LINE OF gt_1100_bkpf.

*   Busca a linha clicada
    READ TABLE  gt_1100_bkpf ASSIGNING <bkpf> INDEX row.
    CHECK sy-subrc IS INITIAL.

*   Exibe os detalhes apenas da linha clicada
    APPEND <bkpf> TO lt_bkpf.

    REFRESH gt_1100_bseg.
    IF lt_bkpf IS NOT INITIAL.
      PERFORM fill_bseg USING lt_bkpf CHANGING gt_1100_bseg.
    ENDIF.
    go_1100_salv31->refresh( refresh_mode = if_salv_c_refresh=>full ). "atualizar subtotais etc
  ENDMETHOD.                    "on_double_click
ENDCLASS.

CLASS lcl_1100_event_handler_31 IMPLEMENTATION.

  METHOD on_link_click.
    DATA:          lt_bseg TYPE tty_bseg.
    FIELD-SYMBOLS: <bseg> LIKE LINE OF gt_1100_bseg.

    READ TABLE  gt_1100_bseg ASSIGNING <bseg> INDEX row.
    CHECK sy-subrc IS INITIAL.

    CASE column.

      WHEN 'NUM_DOC_CONTABIL'.
*       Faz drill-down para exibir doc.contábil
        CHECK NOT <bseg>-num_doc_contabil IS INITIAL.

*----------------------------------------------------------------------*
* Início Alteração - 26.07.2016
*----------------------------------------------------------------------*
*        if <bseg>-NUMERO_PEDIDO is NOT INITIAL.
*          SET PARAMETER ID 'RBN' FIELD <bseg>-num_doc_contabil.
*          SET PARAMETER ID 'GJR' FIELD <bseg>-exercicio_apuracao.
*          CALL TRANSACTION 'MIR4' AND SKIP FIRST SCREEN.
*        else.
          SET PARAMETER ID 'BLN' FIELD <bseg>-num_doc_contabil.
          SET PARAMETER ID 'BUK' FIELD <bseg>-EMPRESA.
          SET PARAMETER ID 'GJR' FIELD <bseg>-exercicio_apuracao.
          CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
*        endif.
*----------------------------------------------------------------------*
* Fim Alteração - 26.07.2016
*----------------------------------------------------------------------*

      WHEN 'NUMERO_PEDIDO'.
*       Faz drill-down para exibir pedido
        CHECK NOT <bseg>-numero_pedido IS INITIAL.
        SET PARAMETER ID 'BES' FIELD <bseg>-numero_pedido.
        CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.                    "on_link_click
ENDCLASS.

CLASS lcl_1200_event_handler_11 IMPLEMENTATION.

  METHOD on_link_click.

    FIELD-SYMBOLS: <categ> LIKE LINE OF gt_1200_categ.

    READ TABLE gt_1200_categ ASSIGNING <categ> INDEX row.

    CHECK sy-subrc IS INITIAL.

    IF <categ>-check IS INITIAL.
      <categ>-check = 'X'.
    ELSE.
      CLEAR <categ>-check.
    ENDIF.

    PERFORM refresh_salv_11 USING    go_1200_salv11
                                     go_1200_salv12
                                     go_1200_salv13
                                     go_1200_salv14
                                     gt_1200_categ
                            CHANGING gt_1200_tp_imposto
                                     gt_1200_cod_imposto
                                     gt_1200_empresa
                                     gt_1200_emprdiv.

    REFRESH: gt_1200_bkpf,
             gt_1200_bkpf_aux,
             gt_1200_bseg.
    go_1200_salv22->refresh( refresh_mode = if_salv_c_refresh=>full ). "atualizar subtotais etc
    go_1200_salv31->refresh( refresh_mode = if_salv_c_refresh=>full ). "atualizar subtotais etc

  ENDMETHOD.                    "on_link_click
ENDCLASS.

CLASS lcl_1200_event_handler_12 IMPLEMENTATION.

  METHOD on_link_click.

    FIELD-SYMBOLS: <tp_imposto> LIKE LINE OF gt_1200_tp_imposto.

    READ TABLE  gt_1200_tp_imposto ASSIGNING <tp_imposto> INDEX row.

    CHECK sy-subrc IS INITIAL.

    IF <tp_imposto>-check IS INITIAL.
      <tp_imposto>-check = 'X'.
    ELSE.
      CLEAR <tp_imposto>-check.
    ENDIF.

    PERFORM refresh_salv_12 USING    go_1200_salv12
                                     go_1200_salv13
                                     go_1200_salv14
                                     gt_1200_tp_imposto
                            CHANGING gt_1200_cod_imposto
                                     gt_1200_empresa
                                     gt_1200_emprdiv.

    REFRESH: gt_1200_bkpf,
             gt_1200_bkpf_aux,
             gt_1200_bseg.
    go_1200_salv22->refresh( refresh_mode = if_salv_c_refresh=>full ). "atualizar subtotais etc
    go_1200_salv31->refresh( refresh_mode = if_salv_c_refresh=>full ). "atualizar subtotais etc

  ENDMETHOD.                    "on_link_click
ENDCLASS.

CLASS lcl_1200_event_handler_13 IMPLEMENTATION.

  METHOD on_link_click.

    FIELD-SYMBOLS: <cod_imposto> LIKE LINE OF gt_1200_cod_imposto.

    READ TABLE  gt_1200_cod_imposto ASSIGNING <cod_imposto> INDEX row.

    CHECK sy-subrc IS INITIAL.

    IF <cod_imposto>-check IS INITIAL.
      <cod_imposto>-check = 'X'.
    ELSE.
      CLEAR <cod_imposto>-check.
    ENDIF.

    PERFORM refresh_salv_13 USING    go_1200_salv13
                                     go_1200_salv14
                                     gt_1200_cod_imposto
                            CHANGING gt_1200_empresa
                                     gt_1200_emprdiv.

    REFRESH: gt_1200_bkpf,
             gt_1200_bkpf_aux,
             gt_1200_bseg.
    go_1200_salv22->refresh( refresh_mode = if_salv_c_refresh=>full ). "atualizar subtotais etc
    go_1200_salv31->refresh( refresh_mode = if_salv_c_refresh=>full ). "atualizar subtotais etc

  ENDMETHOD.                    "on_link_click
ENDCLASS.

CLASS lcl_1200_event_handler_14 IMPLEMENTATION.

  METHOD on_link_click.

    FIELD-SYMBOLS: <emprdiv> LIKE LINE OF gt_1200_emprdiv.

    READ TABLE  gt_1200_emprdiv ASSIGNING <emprdiv> INDEX row.

    CHECK sy-subrc IS INITIAL.

    IF <emprdiv>-check IS INITIAL.
      <emprdiv>-check = 'X'.
    ELSE.
      CLEAR <emprdiv>-check.
    ENDIF.

    PERFORM refresh_salv_14 USING    '1200'
                                     go_1200_salv14
                                     gt_1200_cod_imposto
                                     gt_1200_empresa
                                     gt_1200_emprdiv
                                     sel_1200_monat
                                     inp_1200_gjahr
                            CHANGING gt_1200_bkpf
                                     gt_1200_bkpf_aux
                                     gt_1200_bseg.
    go_1200_salv22->refresh( refresh_mode = if_salv_c_refresh=>full ). "atualizar subtotais etc
    go_1200_salv31->refresh( refresh_mode = if_salv_c_refresh=>full ). "atualizar subtotais etc

  ENDMETHOD.                    "on_link_click
ENDCLASS.

CLASS lcl_1200_event_handler_21 IMPLEMENTATION.

  METHOD on_clicked.
    DATA:
      lv_monat TYPE monat,
      lv_gjahr TYPE gjahr,
      lv_subrc TYPE sysubrc.
    WRITE sel_1200_monat->value TO lv_monat.
    WRITE inp_1200_gjahr->value TO lv_gjahr.

    CASE sender->name.

      WHEN 'EXEC'.
        PERFORM fill_bkpf_exec_1200 USING     lv_monat lv_gjahr
                                              gt_1200_categ
                                              gt_1200_tp_imposto
                                              gt_1200_cod_imposto
                                              gt_1200_empresa
                                              gt_1200_emprdiv
                                     CHANGING gt_1200_bkpf.

      WHEN 'BUT1'.
        PERFORM fill_bkpf_exec_1200 USING     lv_monat lv_gjahr
                                              gt_1200_categ
                                              gt_1200_tp_imposto
                                              gt_1200_cod_imposto
                                              gt_1200_empresa
                                              gt_1200_emprdiv
                                     CHANGING gt_1200_bkpf.
*        gt_1200_bkpf = gt_1100_bkpf_aux.
        DELETE gt_1200_bkpf WHERE competencia <> 'S'.

      WHEN 'BUT2'.
        PERFORM fill_bkpf_exec_1200 USING     lv_monat lv_gjahr
                                              gt_1200_categ
                                              gt_1200_tp_imposto
                                              gt_1200_cod_imposto
                                              gt_1200_empresa
                                              gt_1200_emprdiv
                                     CHANGING gt_1200_bkpf.
*        gt_1200_bkpf = gt_1100_bkpf_aux.
        DELETE gt_1200_bkpf WHERE competencia <> 'N'.

      WHEN 'BUT3'. "Confirmar

        PERFORM valida_doc_marcado USING    gt_1200_bkpf
                                            'Gravado'
                                   CHANGING lv_subrc.
        CHECK lv_subrc IS INITIAL.

        PERFORM popup_confirmacao CHANGING lv_subrc.
        CHECK lv_subrc IS INITIAL.

        PERFORM update_bkp_1200_2 CHANGING gt_1200_bkpf.

      WHEN 'BUT4'. "Liberar

        PERFORM valida_doc_marcado USING    gt_1200_bkpf
                                            'Confirmado'
                                   CHANGING lv_subrc.
        CHECK lv_subrc IS INITIAL.

        PERFORM popup_confirmacao CHANGING lv_subrc.
        CHECK lv_subrc IS INITIAL.

*       Inclusão solicitada pelo Forti - 01.12.2015
        PERFORM executa_zpag.

      WHEN 'BUT5'.  "Compensação

        PERFORM valida_doc_marcado USING    gt_1200_bkpf
                                            'Lançado'
                                   CHANGING lv_subrc.
        CHECK lv_subrc IS INITIAL.

        PERFORM popup_confirmacao CHANGING lv_subrc.
        CHECK lv_subrc IS INITIAL.

        PERFORM executa_compensacao USING    gt_1200_bkpf.

    ENDCASE.

    go_1200_salv22->refresh( refresh_mode = if_salv_c_refresh=>full ). "atualizar subtotais etc
    REFRESH gt_1200_bseg.
    go_1200_salv31->refresh( refresh_mode = if_salv_c_refresh=>full ). "atualizar subtotais etc
  ENDMETHOD.                    "handle_submit_buttons

ENDCLASS.

CLASS lcl_1200_event_handler_22 IMPLEMENTATION.

  METHOD on_link_click.

    DATA: lv_subrc TYPE sysubrc.

    FIELD-SYMBOLS: <bkpf> LIKE LINE OF gt_1200_bkpf.

    READ TABLE  gt_1200_bkpf ASSIGNING <bkpf> INDEX row.
    CHECK sy-subrc IS INITIAL.

    CASE column.

      WHEN 'CHECK'.

        IF <bkpf>-check IS INITIAL.
          <bkpf>-check = 'X'.
        ELSE.
          CLEAR <bkpf>-check.
        ENDIF.
        go_1200_salv22->refresh( refresh_mode = if_salv_c_refresh=>full ). "atualizar subtotais etc

      WHEN 'ICON_RECOLH'.

*       Monta a data de vencimento, se necessário
        IF <bkpf>-data_vencimento IS INITIAL.
          CONCATENATE sy-datum(6)
                      <bkpf>-dia_vencimento
                 INTO <bkpf>-data_vencimento.
        ENDIF.

*       Calcula o valor total do recolhimento
        PERFORM calcula_recolhimento  CHANGING <bkpf>.

*       Busca o nome do contribuinte pelo CNPJ
        PERFORM busca_contribuinte_cnpj USING    <bkpf>-cnpj
                                                 <bkpf>-empresa
                                        CHANGING <bkpf>-bbranch_name.

*--> Início - Alteração  06.12.2018 18:33:03 - WR005118
* Preenche o campo referência
        concatenate <bkpf>-PERIODO <bkpf>-EXERCICIO INTO <bkpf>-REFERENCIA.
*<-- Fim - 06.12.2018 18:33:03

*       Exibe popup de dados de recolhimento
        gs_1210_bkpf_alv = <bkpf>.
        CALL SCREEN 1210 STARTING AT 5 5.

*       Se o usuário confirmou as alterações,
        IF NOT gs_1210_bkpf_alv IS INITIAL.

*         Popup de confirmacao
          PERFORM popup_confirmacao CHANGING lv_subrc.
          CHECK lv_subrc IS INITIAL.

*         Atualiza tabela
          PERFORM update_bkp_1200_1 CHANGING gs_1210_bkpf_alv.

*         Atualiza tabela interna
          <bkpf> = gs_1210_bkpf_alv.
          go_1200_salv22->refresh( refresh_mode = if_salv_c_refresh=>full ). "atualizar subtotais etc
        ENDIF.

      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.                    "on_link_click
  METHOD on_double_click.

    DATA: lt_bkpf TYPE tty_bkpf.

    FIELD-SYMBOLS: <bkpf> LIKE LINE OF gt_1200_bkpf.

*   Busca a linha clicada
    READ TABLE  gt_1200_bkpf ASSIGNING <bkpf> INDEX row.
    CHECK sy-subrc IS INITIAL.

*   Exibe os detalhes apenas da linha clicada
    APPEND <bkpf> TO lt_bkpf.

    REFRESH gt_1200_bseg.
    IF lt_bkpf IS NOT INITIAL.
      PERFORM fill_bseg USING lt_bkpf CHANGING gt_1200_bseg.
    ENDIF.
    go_1200_salv31->refresh( refresh_mode = if_salv_c_refresh=>full ). "atualizar subtotais etc
  ENDMETHOD.                    "on_double_click
ENDCLASS.

CLASS lcl_1200_event_handler_31 IMPLEMENTATION.

  METHOD on_link_click.
    DATA:          lt_bseg TYPE tty_bseg.
    FIELD-SYMBOLS: <bseg> LIKE LINE OF gt_1200_bseg.

    READ TABLE  gt_1200_bseg ASSIGNING <bseg> INDEX row.
    CHECK sy-subrc IS INITIAL.

    CASE column.

      WHEN 'NUM_DOC_CONTABIL'.
*       Faz drill-down para exibir doc.contábil
        CHECK NOT <bseg>-num_doc_contabil IS INITIAL.
        SET PARAMETER ID 'BLN' FIELD <bseg>-num_doc_contabil.
        SET PARAMETER ID 'BUK' FIELD <bseg>-empresa.
        SET PARAMETER ID 'GJR' FIELD <bseg>-exercicio_apuracao.
        CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.

      WHEN 'NUMERO_PEDIDO'.
*       Faz drill-down para exibir pedido
        CHECK NOT <bseg>-numero_pedido IS INITIAL.
        SET PARAMETER ID 'BES' FIELD <bseg>-numero_pedido.
        CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.                    "on_link_click
ENDCLASS.

CLASS lcl_1300_event_handler_11 IMPLEMENTATION.
  METHOD on_clicked.
    DATA:
      lv_monat TYPE monat,
      lv_gjahr TYPE gjahr.

    CASE sender->name.

      WHEN 'EXEC'.
        WRITE sel_1300_monat->value TO lv_monat.
        WRITE inp_1300_gjahr->value TO lv_gjahr.
        PERFORM fill_bkpf_exec_1300 USING lv_monat lv_gjahr
                                             gt_1100_categ
                                    CHANGING gt_1300_saida.

    ENDCASE.
*    go_1300_salv21->refresh( ).
  ENDMETHOD.                    "on_link_click
ENDCLASS.

CLASS lcl_1300_event_handler_21 IMPLEMENTATION.

  METHOD on_link_click.

  ENDMETHOD.                    "on_link_click

  METHOD on_double_click.
    FIELD-SYMBOLS:
                   <saida> LIKE LINE OF gt_1300_saida.

    READ TABLE gt_1300_saida ASSIGNING <saida> INDEX row.

    CHECK sy-subrc = 0.

    CASE column.
      WHEN 'DOC_REFERENCIA'.

      WHEN 'DOC_COMPENSACAO'.

      WHEN 'NUM_DOC_APURACAO'.

    ENDCASE.


  ENDMETHOD.

ENDCLASS.

CLASS lcl_1400_event_handler_11 IMPLEMENTATION.

  METHOD on_link_click.

    FIELD-SYMBOLS: <categ> LIKE LINE OF gt_1400_categ.

    LOOP AT gt_1400_categ ASSIGNING <categ>.
      CHECK NOT sy-tabix EQ row.
      CLEAR <categ>-check.
    ENDLOOP.

    READ TABLE gt_1400_categ ASSIGNING <categ> INDEX row.

    CHECK sy-subrc IS INITIAL.

    IF <categ>-check IS INITIAL.
      <categ>-check = 'X'.
    ELSE.
      CLEAR <categ>-check.
    ENDIF.

    PERFORM refresh_salv_11 USING    go_1400_salv11
                                     go_1400_salv12
                                     go_1400_salv13
                                     go_1400_salv14
                                     gt_1400_categ
                            CHANGING gt_1400_tp_imposto
                                     gt_1400_cod_imposto
                                     gt_1400_empresa
                                     gt_1400_emprdiv.

  ENDMETHOD.                    "on_link_click
ENDCLASS.

CLASS lcl_1400_event_handler_12 IMPLEMENTATION.

  METHOD on_link_click.

    FIELD-SYMBOLS: <tp_imposto> LIKE LINE OF gt_1400_tp_imposto.

    READ TABLE  gt_1400_tp_imposto ASSIGNING <tp_imposto> INDEX row.

    CHECK sy-subrc IS INITIAL.

    IF <tp_imposto>-check IS INITIAL.
      <tp_imposto>-check = 'X'.
    ELSE.
      CLEAR <tp_imposto>-check.
    ENDIF.

    PERFORM refresh_salv_12 USING    go_1400_salv12
                                     go_1400_salv13
                                     go_1400_salv14
                                     gt_1400_tp_imposto
                            CHANGING gt_1400_cod_imposto
                                     gt_1400_empresa
                                     gt_1400_emprdiv.

  ENDMETHOD.                    "on_link_click
ENDCLASS.

CLASS lcl_1400_event_handler_13 IMPLEMENTATION.

  METHOD on_link_click.

    FIELD-SYMBOLS: <cod_imposto> LIKE LINE OF gt_1400_cod_imposto.

    READ TABLE  gt_1400_cod_imposto ASSIGNING <cod_imposto> INDEX row.

    CHECK sy-subrc IS INITIAL.

    IF <cod_imposto>-check IS INITIAL.
      <cod_imposto>-check = 'X'.
    ELSE.
      CLEAR <cod_imposto>-check.
    ENDIF.

    PERFORM refresh_salv_13 USING    go_1400_salv13
                                     go_1400_salv14
                                     gt_1400_cod_imposto
                            CHANGING gt_1400_empresa
                                     gt_1400_emprdiv.

  ENDMETHOD.                    "on_link_click
ENDCLASS.

CLASS lcl_1400_event_handler_14 IMPLEMENTATION.

  METHOD on_link_click.

    FIELD-SYMBOLS: <emprdiv> LIKE LINE OF gt_1400_emprdiv.

    LOOP AT gt_1400_emprdiv ASSIGNING <emprdiv>.
      CHECK NOT sy-tabix EQ row.
      CLEAR <emprdiv>-check.
    ENDLOOP.

    READ TABLE  gt_1400_emprdiv ASSIGNING <emprdiv> INDEX row.

    CHECK sy-subrc IS INITIAL.

    IF <emprdiv>-check IS INITIAL.
      <emprdiv>-check = 'X'.
    ELSE.
      CLEAR <emprdiv>-check.
    ENDIF.

    go_1400_salv14->refresh( ).

  ENDMETHOD.                    "on_link_click
ENDCLASS.

"Start    - Marcelo Alvares - MA004818 S4D MZARI001IMP01 ZCT0 - 24.10.2018 17:51
CLASS lcl_fi_doc_reader IMPLEMENTATION.

  METHOD read_bkpf.

    CALL FUNCTION 'READ_BKPF'
      EXPORTING
        xbelnr         = im_v_belnr   " Document number
        xbukrs         = im_v_bukrs   " Company code
        xgjahr         = im_v_gjahr   " Fiscal year
        no_auth_check  = space
      IMPORTING
        xbkpf          = ex_s_bkpf                 " Document header
      EXCEPTIONS
        key_incomplete = 1                " Key is incomplete
        not_authorized = 2                " No authorization
        not_found      = 3                " Data record not found
        OTHERS         = 4.

    CASE sy-subrc.
      WHEN 1.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING key_incomplete.
      WHEN 2.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_authorized.
      WHEN 3.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_found.
    ENDCASE.

  ENDMETHOD.

  METHOD get_doc_status.

    DATA ls_bkpf TYPE bkpf.

    CALL METHOD lcl_fi_doc_reader=>read_bkpf
      EXPORTING
        im_v_bukrs     = im_v_bukrs
        im_v_belnr     = im_v_belnr
        im_v_gjahr     = im_v_gjahr
      IMPORTING
        ex_s_bkpf      = ls_bkpf
      EXCEPTIONS
        key_incomplete = 1
        not_authorized = 2
        not_found      = 3
        OTHERS         = 4.

    CASE sy-subrc.
      WHEN 1.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING key_incomplete.
      WHEN 2.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_authorized.
      WHEN 3.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_found.
    ENDCASE.

    r_bstat = ls_bkpf-bstat.

  ENDMETHOD.

  METHOD is_doc_normal_status.

    DATA:
      lv_bstat TYPE bstat_d.

    " Se caso já estiver aprovado o campo "doc_pre_editado" fica vazio, informando status errado.
    " O porque fica vazio não consegui descobrir
    IF im_s_bkpf-doc_pre_editado IS INITIAL.
      im_s_bkpf-doc_pre_editado = im_s_bkpf-doc_referencia.
    ENDIF.

    CALL METHOD lcl_fi_doc_reader=>get_doc_status
      EXPORTING
        im_v_bukrs     = im_s_bkpf-empresa
        im_v_belnr     = im_s_bkpf-doc_pre_editado
        im_v_gjahr     = im_s_bkpf-data_vencimento(4)
      RECEIVING
        r_bstat        = lv_bstat
      EXCEPTIONS
        key_incomplete = 1
        not_authorized = 2
        not_found      = 3
        OTHERS         = 4.

    " Verifica se o status está vazio indicando documento normal
    " e se o documento foi encontrado
    IF lv_bstat IS INITIAL AND sy-subrc IS INITIAL.
      r_bool = abap_true.
    ELSE.
      r_bool = abap_false.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
"END    - Marcelo Alvares - MA004818 S4D MZARI001IMP01 ZCT0 - 24.10.2018 17:51
