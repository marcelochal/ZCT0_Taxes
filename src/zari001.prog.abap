REPORT zari001 MESSAGE-ID zari LINE-SIZE 255 NO STANDARD PAGE HEADING LINE-COUNT 065(1).

INCLUDE zari001top.

DATA:
  gt_cod_imposto_rec TYPE tty_cod_imposto,
  ls_cod_imposto_rec TYPE ty_cod_imposto,
  ls_header          TYPE zari_bkpf,
  gt_header          TYPE tty_header,
  gt_item            TYPE tty_item,
  gt_resp            TYPE tty_responsavel,
  gt_data            TYPE tty_data.

SELECT-OPTIONS:
  s_bukrs FOR zari_empresa-empresa,
  s_hkont FOR zari_cod_imposto-conta_contabil,
  s_gjahr FOR bsis-gjahr NO INTERVALS,
  s_monat FOR bkpf-monat NO INTERVALS,
  s_cpudt FOR bkpf-cpudt.

START-OF-SELECTION.

  PERFORM preenche_s_cpudt USING    s_gjahr[]
                                    s_monat[]
                           CHANGING s_cpudt[].
  PERFORM seleciona_dados.
  PERFORM gera_base_dados.

  PERFORM processa_comp_imposto_rec.

  PERFORM insere_bd.
  PERFORM envia_email_responsaveis.

*&---------------------------------------------------------------------*
*&      Form  SELECIONA_DADOS
*&---------------------------------------------------------------------*
*&-  A seleção de dados deverá ser executada de acordo com a periodicidade
*&- dos impostos configurados, ou seja, a rotina será executada diariamente
*&- e automaticamente realizará as seleções de informações conforme período
*&- de apuração - semanal, mensal, trimestral, semestral e anual.
*&---------------------------------------------------------------------*
FORM seleciona_dados .
  REFRESH: gt_empresa, gt_cod_imposto, gt_data, gt_bkpf, gt_cod_imposto_rec,
  gt_tp_imposto, gt_bsis, gt_bsik, gt_bseg, gt_bseg, gt_cod_multajuros,
  gt_comp_rec, gt_header, gt_item, gt_resumo_imp, gt_doc.

  PERFORM seleciona_empresa CHANGING gt_empresa.
  CHECK gt_empresa IS NOT INITIAL.

*** Início - 30/09/2018 - Implementação de Authority-Check Projeto AGIR
  PERFORM f_authority_check TABLES gt_empresa
                            USING  '01'. "Criar
*** Fim    - 30/09/2018 - Implementação de Authority-Check Projeto AGIR

  PERFORM seleciona_cod_imposto USING gt_empresa CHANGING gt_cod_imposto.
  CHECK gt_cod_imposto IS NOT INITIAL.
  PERFORM seleciona_multajuros USING gt_cod_imposto CHANGING gt_cod_multajuros.
  PERFORM filtra_cod_imposto CHANGING gt_cod_imposto gt_data.
  CHECK gt_cod_imposto IS NOT INITIAL.
*  PERFORM seleciona_tipo_imposto USING gt_cod_imposto CHANGING gt_tipo_imposto.
  PERFORM filtra_empresas USING gt_cod_imposto CHANGING gt_empresa.
  PERFORM seleciona_bkpf USING gt_empresa gt_data CHANGING gt_bkpf.
  CHECK gt_bkpf IS NOT INITIAL.
  PERFORM seleciona_cod_imposto_rec USING gt_cod_imposto CHANGING gt_cod_imposto_rec.
  PERFORM seleciona_comp_rec   USING gt_cod_imposto_rec CHANGING gt_comp_rec.
  PERFORM seleciona_tp_imposto USING gt_cod_imposto gt_cod_imposto_rec CHANGING gt_tp_imposto.
  PERFORM seleciona_bsis USING gt_cod_imposto gt_cod_imposto_rec gt_data gt_empresa CHANGING gt_bsis gt_bkpf.
  CHECK gt_bsis IS NOT INITIAL.
  PERFORM seleciona_bseg USING gt_cod_imposto gt_cod_imposto_rec CHANGING gt_bsis gt_bseg gt_comp_manual.
  IF gt_cod_imposto_rec IS NOT INITIAL.              " calculo do saldo do imposto a recuperar
    PERFORM seleciona_glflext USING gt_cod_imposto_rec gt_comp_rec CHANGING gt_bsis gt_bkpf.
  ENDIF.
  PERFORM seleciona_bsik USING gt_bsis CHANGING gt_bsik.
  PERFORM seleciona_doc CHANGING gt_bsis gt_doc.
  IF gt_doc IS NOT INITIAL.
    PERFORM seleciona_stx USING gt_doc gt_cod_imposto CHANGING gt_stx.
    IF gt_stx IS NOT INITIAL.
      PERFORM seleciona_lin USING gt_stx CHANGING gt_lin.
      PERFORM seleciona_ekkn USING gt_lin CHANGING gt_ekkn gt_ekpo gt_stx.
      PERFORM seleciona_txjurt USING gt_stx CHANGING gt_txjurt.
    ELSE.
      PERFORM seleciona_lin_doc USING gt_doc CHANGING gt_lin.
      PERFORM seleciona_ekkn USING gt_lin CHANGING gt_ekkn gt_ekpo gt_stx.
      PERFORM seleciona_txjurt_ekpo USING gt_ekpo CHANGING gt_txjurt.
    ENDIF.
  ENDIF.
  PERFORM seleciona_with_item USING gt_bsis CHANGING gt_witem.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECIONA_EMPRESA
*&---------------------------------------------------------------------*
*& Empresas Válidas – selecionar todos os códigos de impostos atribuídos
*& a todas as empresas configuradas
*&---------------------------------------------------------------------*
FORM seleciona_empresa  CHANGING pt_empresa TYPE tty_empresa.
  DATA:
            lt_fields TYPE rsz_t_string.

  lt_fields = zcl_utils=>get_itab_fields( pt_empresa ).
  SELECT (lt_fields)
  INTO TABLE pt_empresa
  FROM zari_empresa
  WHERE empresa IN s_bukrs.

  IF sy-subrc <> 0.
    MESSAGE s001 DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECIONA_COD_IMPOSTO
*&---------------------------------------------------------------------*
*&-  Verificar se o código de imposto selecionado tem definido Código de
*&- Imposto a Recuperar
*&-  Se houver definição
*&-   Selecionar  na tabela de “Código de Impostos” a partir do Código
*&- de imposto a Recuperar
*&-
*&-  Considerar a conta contábil do Código de Imposto a Recuperar na
*&- seleção de dados
*&---------------------------------------------------------------------*
FORM seleciona_cod_imposto  USING    pt_empresa TYPE tty_empresa
                           CHANGING pt_cod_imposto TYPE tty_cod_imposto.

  DATA:
    lt_fields         TYPE rsz_t_string,
    gt_rg_cod_imposto TYPE RANGE OF zari_cod_imposto-codigo_imposto.

  gt_rg_cod_imposto[] = zcl_utils=>get_range_of_table( im_table = pt_empresa
                      im_field = 'CODIGO_IMPOSTO' ).

  lt_fields = zcl_utils=>get_itab_fields( pt_cod_imposto ).
*  SELECT (lt_fields)
  SELECT a~codigo_imposto
         a~tipo_imposto
         b~categ_imposto
         a~cod_imposto_rec
         a~periodo_apuracao
         a~uf
         a~domicilio_fiscal
         a~definicao_regra
         a~dias_apuracao
         a~tipo_apuracao
         a~conta_contabil
         a~regra_acumulo
         a~dia_vencimento
         a~cod_fornecedor     "codigo do fornecedor do imposto
         a~cod_compens_rec    "codigo compensação de imposto a rec
         a~cod_correcao_multa "codigo correção de multa
         a~cod_correcao_juros "codigo correção de juros
         a~categ_iva
         a~categ_irrf
         a~irrf
  INTO TABLE pt_cod_imposto
  FROM zari_cod_imposto AS a
    INNER JOIN zari_tp_imposto AS b
    ON a~tipo_imposto EQ b~tipo_imposto
  WHERE a~codigo_imposto IN gt_rg_cod_imposto
    AND conta_contabil IN s_hkont.

  IF sy-subrc <> 0.
    MESSAGE s002 DISPLAY LIKE 'E'.
  ENDIF.
*  lt_fields = zcl_utils=>get_itab_fields( pt_cod_imposto ).
*  SELECT (lt_fields)
*  INTO TABLE pt_cod_imposto
*  FROM zari_cod_imposto AS a
*  LEFT JOIN zari_cod_imposto AS b ON ( a~codigo_imposto = b~cod_imposto_rec )
*  WHERE a~codigo_imposto IN gt_rg_cod_imposto.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECIONA_COD_IMPOSTO_REC
*&---------------------------------------------------------------------*
FORM seleciona_cod_imposto_rec  USING    VALUE(pt_cod_imposto) TYPE tty_cod_imposto
CHANGING pt_cod_imposto_rec  TYPE tty_cod_imposto.

  DATA:
              lt_fields TYPE rsz_t_string.

  lt_fields = zcl_utils=>get_itab_fields( pt_cod_imposto_rec ).
*  SELECT (lt_fields)
  SELECT a~codigo_imposto
         a~tipo_imposto
         b~categ_imposto
         a~cod_imposto_rec
         a~periodo_apuracao
         a~uf
         a~domicilio_fiscal
         a~definicao_regra
         a~dias_apuracao
         a~tipo_apuracao
         a~conta_contabil
         a~regra_acumulo
         a~dia_vencimento
         a~cod_fornecedor
         a~cod_compens_rec    "codigo compensação de imposto a rec
         a~cod_correcao_multa "codigo correção de multa
         a~cod_correcao_juros "codigo correção de juros
         a~categ_iva
         a~categ_irrf
         a~irrf
  INTO TABLE pt_cod_imposto_rec
  FROM zari_cod_imposto AS a
    INNER JOIN zari_tp_imposto AS b
    ON a~tipo_imposto EQ b~tipo_imposto
  FOR ALL ENTRIES IN pt_cod_imposto
  WHERE codigo_imposto = pt_cod_imposto-cod_imposto_rec.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECIONA_BKPF
*&---------------------------------------------------------------------*
FORM seleciona_bkpf  USING    pt_empresa TYPE tty_empresa
                              pt_data TYPE tty_data
                     CHANGING pt_bkpf TYPE tty_bkpf.
  DATA:
    lt_fields     TYPE rsz_t_string,
    gt_rg_empresa TYPE RANGE OF zari_empresa-empresa.

  gt_rg_empresa[] = zcl_utils=>get_range_of_table( im_table = pt_empresa
                                                 im_field = 'EMPRESA' ).

  lt_fields = zcl_utils=>get_itab_fields( pt_bkpf ).

* MFS 06/04/2016 -
* Se a variavel c_l_CPUDT vazia a rotiana vai trabalhar com a data de lançamento - BUDAT se não CPUDT
  IF c_l_cpudt IS INITIAL.
    SELECT (lt_fields)
    INTO TABLE pt_bkpf
    FROM bkpf
    WHERE bukrs IN gt_rg_empresa
*    AND cpudt IN s_cpudt
* MFS - 06/04/2016
* Ajuste da data base do cockpit de data de entrada para data lançamento
*   AND cpudt IN pt_data
      AND budat IN pt_data
* MFS - 06/04/2016
      AND gjahr IN s_gjahr
*    AND cpudt >= pt_aux-dt_ini_apuracao
*    AND cpudt <= pt_aux-dt_fim_apuracao
      AND bstat = space.
  ELSE.
    SELECT (lt_fields)
    INTO TABLE pt_bkpf
    FROM bkpf
    WHERE bukrs IN gt_rg_empresa
     AND cpudt IN pt_data
      AND gjahr IN s_gjahr
*    AND cpudt >= pt_aux-dt_ini_apuracao
*    AND cpudt <= pt_aux-dt_fim_apuracao
      AND bstat = space.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECIONA_BSIS
*&---------------------------------------------------------------------*
FORM seleciona_bsis  USING
*                             VALUE(pt_bkpf) TYPE tty_bkpf
                              pt_cod_imposto TYPE tty_cod_imposto
                              pt_cod_imposto_rec TYPE tty_cod_imposto
                              pt_data TYPE tty_data
                              pt_empresa TYPE tty_empresa
                     CHANGING pt_bsis TYPE tty_bsis
                              pt_bkpf TYPE tty_bkpf.
  DATA:
    lt_fields       TYPE rsz_t_string,
    gt_rg_hkont     TYPE RANGE OF zari_cod_imposto-conta_contabil,
    gt_rg_hkont_aux TYPE RANGE OF zari_cod_imposto-conta_contabil,
    gt_rg_empresa   TYPE RANGE OF zari_empresa-empresa,
    gc_rg_hkont     LIKE LINE OF gt_rg_hkont,
    gt_bsis         TYPE tty_bsis,
    gc_bsis         TYPE ty_bsis,
    gt_bkpf         TYPE tty_bkpf,
    gc_bkpf         TYPE ty_bkpf,
    gc_cod_imposto  TYPE ty_cod_imposto,
    lv_dt_ini       TYPE datum,
    lv_dt_fim       TYPE datum,
    gc_data         TYPE ty_data,

    BEGIN OF ls_bseg,
      empresa            TYPE zari_bseg-empresa,
      exercicio_contabil TYPE zari_bseg-exercicio_contabil,
      periodo_apuracao   TYPE zari_bseg-periodo_apuracao,   "MFS 06/04/2016
      num_doc_contabil   TYPE zari_bseg-num_doc_contabil,
      item_lancamento    TYPE zari_bseg-item_lancamento,
      conta_contabil     TYPE zari_bseg-conta_contabil,
    END OF ls_bseg,
    gt_bseg         LIKE TABLE OF ls_bseg,
    gt_item         TYPE ty_bsis,
    ls_sum_bsis_rec TYPE tty_bsis,
    lv_idx          TYPE i.

  gt_rg_hkont[] = zcl_utils=>get_range_of_table( im_table = pt_cod_imposto
                                            im_field = 'CONTA_CONTABIL' ).

  gt_rg_hkont_aux[] = zcl_utils=>get_range_of_table( im_table = pt_cod_imposto_rec
  im_field = 'CONTA_CONTABIL' ).

  gt_rg_empresa[] = zcl_utils=>get_range_of_table( im_table = pt_empresa
                                                 im_field = 'EMPRESA' ).

*  APPEND LINES OF gt_rg_hkont_aux TO gt_rg_hkont.
  lt_fields = zcl_utils=>get_itab_fields( pt_bsis ).
  DELETE lt_fields WHERE table_line = 'TCODE' OR table_line = 'AWTYP'.

  SELECT (lt_fields)
  INTO TABLE pt_bsis
  FROM bsis
  FOR ALL ENTRIES IN pt_bkpf
  WHERE bukrs = pt_bkpf-bukrs
    AND hkont IN gt_rg_hkont
    AND gjahr = pt_bkpf-gjahr
    AND belnr = pt_bkpf-belnr.

  LOOP AT pt_data INTO gc_data.
    lv_dt_ini = gc_data-low.
    EXIT.
  ENDLOOP.

* Validação de seleção para atender a apuração de impostos provisionados manualmente.
  IF c_l_cpudt IS NOT INITIAL.

    lt_fields = zcl_utils=>get_itab_fields( gt_bsis ).
    DELETE lt_fields WHERE table_line = 'TCODE' OR table_line = 'AWTYP'.

    LOOP AT pt_cod_imposto ASSIGNING <cod_imposto>.
      IF <cod_imposto>-categ_irrf IS INITIAL.
        IF <cod_imposto>-categ_iva IS INITIAL.

*           criando range da conta de contas para o período
          CLEAR gt_rg_hkont.

          gc_rg_hkont-sign = 'I'.
          gc_rg_hkont-option = 'EQ'.
          gc_rg_hkont-low = <cod_imposto>-conta_contabil.
          APPEND gc_rg_hkont TO gt_rg_hkont.

          READ TABLE pt_cod_imposto_rec INTO gc_cod_imposto WITH KEY codigo_imposto = <cod_imposto>-cod_imposto_rec.
*           contas de a recuperar.
          IF sy-subrc IS INITIAL.
*              gc_rg_hkont-sign = 'I'.
*              gc_rg_hkont-option = 'EQ'.
*             gc_rg_hkont-low = gc_cod_imposto-conta_contabil.
*            APPEND gc_rg_hkont TO gt_rg_hkont.
          ENDIF.

          CASE <cod_imposto>-periodo_apuracao.
            WHEN '1'.	" Semanal
              _set_intervalo_semanal lv_dt_ini lv_dt_fim.
            WHEN '2'.	" Mensal
              _set_intervalo_mensal lv_dt_ini lv_dt_fim 1 .
            WHEN '3'.	" Trimestral
              _set_intervalo_trimestral lv_dt_ini lv_dt_fim 3.
            WHEN '4'. "	Semestral
              _set_intervalo_semestral lv_dt_ini lv_dt_fim 6.
            WHEN '5'. " Anual
              _set_intervalo_anual lv_dt_ini lv_dt_fim 12.
            WHEN OTHERS. " Fixo
          ENDCASE.

          DELETE pt_bsis WHERE hkont = <cod_imposto>-conta_contabil
                             AND bldat >= lv_dt_ini
                             AND bldat <= lv_dt_fim
                              OR shkzg = 'S'
                             AND bldat < lv_dt_ini .


          SELECT (lt_fields)
          INTO TABLE gt_bsis
          FROM bsis
          WHERE bukrs IN gt_rg_empresa
          AND hkont IN gt_rg_hkont
          AND gjahr IN s_gjahr
          AND bldat IN pt_data.
*          AND shkzg = 'H'.

          IF sy-subrc IS INITIAL.

            lt_fields = zcl_utils=>get_itab_fields( pt_bkpf ).

*           Atualizar a gt_BKPF com os registros de provisão manual.
            SELECT (lt_fields)
            INTO TABLE gt_bkpf
            FROM bkpf
            FOR ALL ENTRIES IN gt_bsis
            WHERE bukrs = gt_bsis-bukrs
            AND belnr = gt_bsis-belnr
            AND gjahr = gt_bsis-gjahr
            AND bstat = space.

            LOOP AT gt_bkpf INTO gc_bkpf.
              APPEND gc_bkpf TO pt_bkpf.
            ENDLOOP.

*          inserindo registros leitura da bsis apuração manual na pt_bsis.
            LOOP AT gt_bsis INTO gc_bsis.
              APPEND gc_bsis TO pt_bsis.
            ENDLOOP.

          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF pt_bsis IS NOT INITIAL.  "sy-subrc = 0. MFS 06/04/2016

    lt_fields = zcl_utils=>get_itab_fields( gt_bseg ).


*  Apagando na conta de a recuperar os registros a Crédito
*   IF gt_rg_hkont_aux is not initial.
*    DELETE pt_bsis WHERE shkzg = 'H'
*                     AND hkont in gt_rg_hkont_aux.

*    Sumarizando e montando o saldo a recuperar.
*     clear gt_bsis.

*      loop at pt_bsis into gc_bsis where hkont in gt_rg_hkont_aux.

*        gt_item-bukrs = gc_bsis-bukrs.
*        gt_item-hkont = gc_bsis-hkont.
*        gt_item-gjahr = gc_bsis-gjahr.
*        gt_item-gsber = gc_bsis-gsber.
*        gt_item-dmbtr = gc_bsis-dmbtr.

*        collect gt_item into ls_sum_bsis_rec.

*        DELETE pt_bsis INDEX sy-tabix.

*      endloop.

*   incluindo na pt_bsis saldo a recuperar disponível.
*      LOOP AT ls_sum_bsis_rec into gc_bsis.
*         gc_bsis-bukrs = gc_bsis-bukrs.
*         gc_bsis-hkont = gc_bsis-hkont.
*         gc_bsis-gjahr = gc_bsis-gjahr.
*         gc_bsis-belnr = '9999999999'.
*         gc_bsis-buzei = '001'.
*         gc_bsis-budat = lv_dt_fim.
*         gc_bsis-bldat = lv_dt_fim.
*         gc_bsis-waers = 'BRL'.
*         gc_bsis-monat = lv_dt_fim+4(02).
*         gc_bsis-bschl = ''.
*         gc_bsis-gsber = gc_bsis-gsber.
*         gc_bsis-shkzg = 'S'.
*         gc_bsis-dmbtr = gc_bsis-dmbtr.
*         gc_bsis-valut = lv_dt_fim.
*         APPEND gc_bsis to pt_bsis.
*      ENDLOOP.
*    ENDIF.
    SELECT (lt_fields)
    INTO TABLE gt_bseg
    FROM zari_bseg
    FOR ALL ENTRIES IN pt_bsis
    WHERE empresa = pt_bsis-bukrs
      AND conta_contabil = pt_bsis-hkont
      AND exercicio_contabil = pt_bsis-gjahr
      AND num_doc_contabil = pt_bsis-belnr.
*      AND item_lancamento = pt_bsis-buzei.

    SORT pt_bkpf BY bukrs belnr gjahr.
    SORT gt_bseg BY empresa conta_contabil exercicio_contabil num_doc_contabil item_lancamento.

    CLEAR gt_bsis.

    gt_bsis = pt_bsis.

    LOOP AT pt_bsis ASSIGNING <bsis>.

      lv_idx = sy-tabix.
* MFS - 06/04/2016 - comando anterior "Transporting no Fields", trocado por Assigning para possibiltiar comparar periodo.
* MFS 06/04/2016
*       Ajuste para atender imposto com apuração anual - IRPJ e CSLL Lucro real anual - movimento acumulado por período de apuração
      READ TABLE pt_cod_imposto ASSIGNING <cod_imposto> WITH KEY conta_contabil = <bsis>-hkont.

      IF sy-subrc IS INITIAL AND <cod_imposto>-periodo_apuracao = '5'.
        READ TABLE gt_bseg TRANSPORTING NO FIELDS WITH KEY empresa = <bsis>-bukrs
                                        conta_contabil = <bsis>-hkont
                                periodo_apuracao = gc_data-high+4(02)
                                exercicio_contabil = <bsis>-gjahr
                                num_doc_contabil = <bsis>-belnr
                                item_lancamento = <bsis>-buzei.

      ELSE.

        READ TABLE gt_bseg TRANSPORTING NO FIELDS WITH KEY empresa = <bsis>-bukrs
                                        conta_contabil = <bsis>-hkont
                                    exercicio_contabil = <bsis>-gjahr
                                    num_doc_contabil = <bsis>-belnr
                        item_lancamento = <bsis>-buzei BINARY SEARCH.
      ENDIF.

      IF sy-subrc = 0.
        DELETE pt_bsis INDEX lv_idx.
        CONTINUE.
      ENDIF.

      READ TABLE pt_bkpf ASSIGNING <bkpf> WITH KEY bukrs = <bsis>-bukrs
                                                   belnr = <bsis>-belnr
                                     gjahr = <bsis>-gjahr BINARY SEARCH.
      <bsis>-awtyp = <bkpf>-awtyp.
      <bsis>-tcode = <bkpf>-tcode.

* MFS - 23/03/2016
* Tratamento documento de estorno fora do período de apuração.
* os documentos de estorno das notas fiscais e documentos fiscais estornados fora do período de apuração
* não devem ser selecioandos pelo Cockpit, estas notas serão tratadas via processo externo ao COCKPIT.



      IF <bkpf>-stblg IS NOT INITIAL.
        READ TABLE gt_bsis TRANSPORTING NO FIELDS WITH KEY bukrs = <bkpf>-bukrs
                                                           belnr = <bkpf>-stblg
                                                          gjahr = <bkpf>-stjah.

        IF sy-subrc IS NOT INITIAL.
          DELETE pt_bsis INDEX lv_idx.
          CONTINUE.
        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECIONA_BSIK
*&---------------------------------------------------------------------*
FORM seleciona_bsik  USING    pt_bsis TYPE tty_bsis
                     CHANGING pt_bsik TYPE tty_bsik.

  DATA:
                lt_fields TYPE rsz_t_string.

  lt_fields = zcl_utils=>get_itab_fields( pt_bsik ).
  SELECT (lt_fields)
  INTO TABLE pt_bsik
  FROM bsik
  FOR ALL ENTRIES IN pt_bsis
    WHERE bukrs = pt_bsis-bukrs
*    AND augdt = pt_bsis-augdt
*    AND augbl = pt_bsis-augbl
*    AND zuonr = pt_bsis-zuonr
    AND gjahr = pt_bsis-gjahr
    AND belnr = pt_bsis-belnr
    AND buzei = pt_bsis-buzei.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_NEXT_NUM
*&---------------------------------------------------------------------*
*&- A configuração é realizada por Exercício, considerando:
*&-  Se desejar criar uma numeração única – definir no campo Exercício
*&- “9999”
*&-  Se desejar criar uma numeração por exercício – definir no campo
*&- exercício o ano que deseja cadastrar o intervalo de numeração.
*&-
*&-  Considerar a gravação do numero de documento sequencial, conforme
*&- for criando os registros de apuração – atingindo a numeração final,
*&- não deverá mais criar documentação apresentando erro na gravação.
*&-  Na ocorrência de estouro orientar o a criação do intervalo da
*&- numeração para a sequencia seguinte e devendo a primeira posição da
*&- Numeração Inicial e Final ser o caractere utilizado na sequencia.
*&---------------------------------------------------------------------*
FORM get_next_num CHANGING p_posicao TYPE zari_interv_num-posicao.

  DATA:
       ls_data TYPE zari_interv_num.

  SELECT SINGLE *
  INTO ls_data
  FROM zari_interv_num
  WHERE exercicio = sy-datum(4).

  CHECK sy-subrc <> 0.

  SELECT SINGLE *
  INTO ls_data
  FROM zari_interv_num
  WHERE exercicio = '9999'.

  CHECK sy-subrc = 0.

  p_posicao = ls_data-posicao = ls_data-posicao + 1.

  IF p_posicao > ls_data-num_final.
    p_posicao = '9999999999'.
    RETURN.
  ENDIF.

  MODIFY zari_interv_num FROM ls_data.

  UNPACK p_posicao TO p_posicao.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FILTRA_EMPRESAS
*&---------------------------------------------------------------------*
FORM filtra_empresas  USING    VALUE(pt_cod_imposto) TYPE tty_cod_imposto
          CHANGING pt_empresa TYPE tty_empresa.
  DATA:
    ls_empresa TYPE ty_empresa,
    lv_tabix   TYPE sytabix.

  SORT pt_cod_imposto BY codigo_imposto.

  LOOP AT pt_empresa INTO ls_empresa.
    lv_tabix = sy-tabix.
    READ TABLE pt_cod_imposto TRANSPORTING NO FIELDS WITH KEY codigo_imposto = ls_empresa-codigo_imposto BINARY SEARCH.
    CHECK sy-subrc <> 0.
    DELETE pt_empresa INDEX lv_tabix.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FILTRA_COD_IMPOSTO
*&---------------------------------------------------------------------*
FORM filtra_cod_imposto  CHANGING pt_cod_imposto TYPE tty_cod_imposto
                                  pt_data TYPE tty_data.
  DATA:
    ls_cod_imposto TYPE ty_cod_imposto,
    ls_data        TYPE ty_data,
    lv_dt_ini      TYPE datum,
    lv_dt_fim      TYPE datum,
    lv_str         TYPE char25,
    c_mes          TYPE num,
    c_ano          TYPE num4,
    c_data         TYPE sy-datum,
    l_sysubrc      TYPE sy-subrc.


  IF s_cpudt[] IS NOT INITIAL.
    pt_data[] = s_cpudt[].
*    EXIT.
  ENDIF.

  LOOP AT pt_cod_imposto INTO ls_cod_imposto.

    IF pt_data[] IS INITIAL.
      lv_dt_ini = sy-datum.
    ELSE.
      LOOP AT pt_data INTO ls_data.
        IF ls_data-high IS INITIAL.
          CONCATENATE ls_data-low(6) '01'  INTO c_data.
        ELSE.
          CONCATENATE ls_data-high(6) '01' INTO c_data.
        ENDIF.
        c_mes = c_data+4(2) + 1.
        c_ano = c_data(4).
        IF c_mes > '12'.
          c_ano = c_data(4) + 1.
          c_mes = 1.
        ENDIF.
        CONCATENATE c_ano c_mes c_data+6(02) INTO lv_dt_ini.
        CONTINUE.
      ENDLOOP.
    ENDIF.

    CASE ls_cod_imposto-periodo_apuracao.
      WHEN '1'.	" Semanal
        _set_intervalo_semanal lv_dt_ini lv_dt_fim.

        PERFORM inserir_cpudt USING    lv_dt_ini
                                       lv_dt_fim
                                       ls_cod_imposto
                              CHANGING pt_data[]
                                       s_gjahr[]
                                       l_sysubrc.
        IF l_sysubrc IS NOT INITIAL.
          DELETE pt_cod_imposto INDEX sy-tabix.
          CONTINUE.
        ENDIF.

      WHEN '2'.	" Mensal

        _set_intervalo_mensal lv_dt_ini lv_dt_fim 1.

        PERFORM inserir_cpudt USING    lv_dt_ini
                                       lv_dt_fim
                                       ls_cod_imposto
                              CHANGING pt_data[]
                                       s_gjahr[]
                                       l_sysubrc.
        IF l_sysubrc IS NOT INITIAL.
          DELETE pt_cod_imposto INDEX sy-tabix.
          CONTINUE.
        ENDIF.

      WHEN '3'.	" Trimestral
        IF lv_dt_ini+4(2) CN '10070401'.
          DELETE pt_cod_imposto INDEX sy-tabix.
          CONTINUE.
        ENDIF.
        _set_intervalo_trimestral lv_dt_ini lv_dt_fim 2.
        PERFORM inserir_cpudt USING    lv_dt_ini
                                       lv_dt_fim
                                       ls_cod_imposto
                              CHANGING pt_data[]
                                       s_gjahr[]
                                       l_sysubrc.
        IF l_sysubrc IS NOT INITIAL.
          DELETE pt_cod_imposto INDEX sy-tabix.
          CONTINUE.
        ENDIF.

      WHEN '4'. "	Semestral
        IF lv_dt_ini+4(2) CN '0701'.
          DELETE pt_cod_imposto INDEX sy-tabix.
          CONTINUE.
        ENDIF.
        _set_intervalo_semestral lv_dt_ini lv_dt_fim 5.

        PERFORM inserir_cpudt USING    lv_dt_ini
                                       lv_dt_fim
                                       ls_cod_imposto
                              CHANGING pt_data[]
                                       s_gjahr[]
                                       l_sysubrc.
        IF l_sysubrc IS NOT INITIAL.
          DELETE pt_cod_imposto INDEX sy-tabix.
          CONTINUE.
        ENDIF.

      WHEN '5'. " Anual
        IF lv_dt_ini+4(02) = 1.
          c_mes = 11.
        ELSE.
          c_mes = lv_dt_ini+4(02) - 2.
        ENDIF.
        _set_intervalo_acumulado lv_dt_ini lv_dt_fim c_mes.

        PERFORM inserir_cpudt USING    lv_dt_ini
                                       lv_dt_fim
                                       ls_cod_imposto
                              CHANGING pt_data[]
                                       s_gjahr[]
                                       l_sysubrc.
        IF l_sysubrc IS NOT INITIAL.
          DELETE pt_cod_imposto INDEX sy-tabix.
          CONTINUE.
        ENDIF.

      WHEN OTHERS. " Fixo
*        IF ls_cod_imposto-definicao_regra = '2'.
*          IF sy-datum+6(2) <> ls_cod_imposto-dias_apuracao.
*            DELETE pt_cod_imposto INDEX sy-tabix.
*            CONTINUE.
*          ENDIF.
*        ENDIF.
    ENDCASE.

*    ls_data-low = lv_dt_ini .
*    ls_data-high = lv_dt_fim.
*    ls_data-option = 'BT'.
*    ls_data-sign = 'I'.
*    COLLECT ls_data INTO pt_data.
  ENDLOOP.


ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECIONA_TP_IMPOSTO
*&---------------------------------------------------------------------*
FORM seleciona_tp_imposto  USING    pt_cod_imposto TYPE tty_cod_imposto
                                 pt_cod_imposto_rec TYPE tty_cod_imposto
                        CHANGING pt_tp_imposto TYPE tty_tipo_imposto.
  DATA:
    lt_fields          TYPE rsz_t_string,
    gt_aux             TYPE RANGE OF zari_cod_imposto-tipo_imposto,
    gt_rg_tipo_imposto TYPE RANGE OF zari_cod_imposto-tipo_imposto.

  gt_rg_tipo_imposto[] = zcl_utils=>get_range_of_table( im_table = pt_cod_imposto
  im_field = 'TIPO_IMPOSTO' ).

  gt_aux[] = zcl_utils=>get_range_of_table( im_table = pt_cod_imposto_rec
                                             im_field = 'TIPO_IMPOSTO' ).

  APPEND LINES OF gt_aux TO gt_rg_tipo_imposto.

  lt_fields = zcl_utils=>get_itab_fields( pt_tp_imposto ).
  SELECT (lt_fields)
  INTO TABLE pt_tp_imposto
  FROM zari_tp_imposto
  WHERE tipo_imposto IN gt_rg_tipo_imposto.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECIONA_RESPONSAVEL
*&---------------------------------------------------------------------*
FORM seleciona_responsavel  USING    pt_resumo_imp TYPE tty_resumo_impostos
CHANGING pt_resp TYPE tty_responsavel.
  DATA:
                  lt_fields TYPE rsz_t_string.

  lt_fields = zcl_utils=>get_itab_fields( pt_resp ).
  SELECT (lt_fields)
  INTO TABLE pt_resp
  FROM zari_responsavel
  FOR ALL ENTRIES IN pt_resumo_imp
  WHERE categ_imposto = pt_resumo_imp-categ_imposto.

  SORT pt_resp BY codigo_usuario categ_imposto.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ENVIA_EMAIL
*&---------------------------------------------------------------------*
FORM envia_email  USING pt_resp TYPE tty_responsavel
                  pt_resumo_imp TYPE tty_resumo_impostos.
  DATA:
    ls_resp       TYPE ty_responsavel,
    ls_resumo_imp TYPE ty_resumo_impostos,
    gt_content    TYPE soli_tab,
    lv_subject    TYPE so_obj_des VALUE 'Dados disponíveis para Apuração',
    ls_addr3      TYPE bapiaddr3,
    gt_return     TYPE STANDARD TABLE OF bapiret2,
    lv_uname      TYPE soud-usrnam,
    lv_mail       TYPE adr6-smtp_addr.

  CALL METHOD zcl_utils=>get_parameter
    EXPORTING
      i_par_id            = 'EMAIL_TESOURARIA'
    IMPORTING
      e_value             = lv_mail
    EXCEPTIONS
      parameter_not_found = 1
      OTHERS              = 2.

  APPEND 'Prezado Usuário,' TO gt_content.
  APPEND 'Encontra-se disponível para Apuração os seguintes códigos de Impostos :' TO gt_content.
  APPEND 'Categoria – Tipo      – Código  – Vencimento' TO gt_content.

  LOOP AT pt_resp INTO ls_resp.
    LOOP AT pt_resumo_imp INTO ls_resumo_imp WHERE categ_imposto =  ls_resp-categ_imposto.
      APPEND ls_resumo_imp TO gt_content.
    ENDLOOP.

    CALL FUNCTION 'BAPI_USER_GET_DETAIL'
      EXPORTING
        username = ls_resp-codigo_usuario
      IMPORTING
        address  = ls_addr3
      TABLES
        return   = gt_return.

    PERFORM send_mail USING lv_mail ls_addr3-e_mail gt_content lv_subject.
    REFRESH gt_content.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SEND_MAIL
*&---------------------------------------------------------------------*
FORM send_mail  USING    p_mail1 TYPE adr6-smtp_addr
                         p_mail2 TYPE adr6-smtp_addr
                         pt_soli TYPE soli_tab
                         p_subject TYPE so_obj_des.

  DATA:
    send_request  TYPE REF TO cl_bcs,
    document      TYPE REF TO cl_document_bcs,
    sender_id     TYPE REF TO if_sender_bcs,
    int_address   TYPE adr6-smtp_addr,
    recipient     TYPE REF TO if_recipient_bcs,
    sent_to_all   TYPE char1,
    bcs_message   TYPE char30,
    bcs_exception TYPE REF TO cx_bcs.

  TRY.
      send_request = cl_bcs=>create_persistent( ).

      document = cl_document_bcs=>create_document(
                      i_type = 'HTM'
                      i_subject = p_subject
                      i_text = pt_soli ).

      CALL METHOD send_request->set_document( document ).

*      sender_id = cl_sapuser_bcs=>create( 'JOB_USER' ).
*      CALL METHOD send_request->set_sender
*        EXPORTING
*          i_sender = sender_id.

      int_address = p_mail1.
      sender_id = cl_cam_address_bcs=>create_internet_address(
                                    i_address_string = int_address
                                    i_address_name = 'Tesouraria SAP' ).

      CALL METHOD send_request->set_sender
        EXPORTING
          i_sender = sender_id.

      PERFORM add_recipient USING p_mail1 space space CHANGING send_request.
      PERFORM add_recipient USING p_mail2 'X' space CHANGING send_request.

      CALL METHOD send_request->set_status_attributes
        EXPORTING
          i_requested_status = 'E'
          i_status_mail      = 'E'.

      CALL METHOD send_request->set_send_immediately( 'X' ).

* ---------- send document ---------------------------------------
      CALL METHOD send_request->send(
        EXPORTING
          i_with_error_screen = 'X'
        RECEIVING
          result              = sent_to_all ).

*      IF sent_to_all = 'X'.
*        "APPEND 'Mail sent successfully ' TO return .
*      ENDIF.
      COMMIT WORK.
    CATCH cx_bcs INTO bcs_exception.
      bcs_message = bcs_exception->get_text( ).
*      _add_msg 'W' 314 'D0' 'Erro durante envio do email' space space.
*      _add_msg 'W' 319 'D0' '4' space space.
*      _add_msg 'E' 326 'D0' bcs_message space space.
      EXIT.
  ENDTRY.

ENDFORM.                    " SEND_MAIL

*&---------------------------------------------------------------------*
*&      Form  add_recipient
*&---------------------------------------------------------------------*
FORM add_recipient  USING    VALUE(p_lista) TYPE adr6-smtp_addr
                             p_copy  TYPE char1
                             p_bcopy TYPE char1
                    CHANGING p_send TYPE REF TO cl_bcs.

  DATA l_email     TYPE adr6-smtp_addr.
  DATA recipient   TYPE REF TO if_recipient_bcs.
  DATA lr_send_exc TYPE REF TO cx_send_req_bcs.
  DATA lr_addr_exc TYPE REF TO cx_address_bcs.
  DATA lv_message  TYPE string.

  WHILE NOT p_lista IS INITIAL.
    SPLIT p_lista AT ',' INTO l_email p_lista.
    CHECK sy-subrc = 0.
    TRY.
        recipient = cl_cam_address_bcs=>create_internet_address( l_email ).

        CALL METHOD p_send->add_recipient
          EXPORTING
            i_recipient  = recipient
            i_copy       = p_copy
            i_blind_copy = p_bcopy
            i_express    = 'X'.

      CATCH cx_send_req_bcs INTO lr_send_exc.
        lv_message = lr_send_exc->get_text( ).
      CATCH cx_address_bcs INTO lr_addr_exc.
        lv_message = lr_addr_exc->get_text( ).
    ENDTRY.

  ENDWHILE.

ENDFORM.                    " ADD_RECIPIENT

*&---------------------------------------------------------------------*
*&      Form  LOOP_BSIS
*&---------------------------------------------------------------------*
FORM loop_bsis USING p_direcao TYPE zari_bseg-direcao
                     ps_cod_imposto TYPE ty_cod_imposto
                     ps_bkpf TYPE ty_bkpf
                     pt_bsis TYPE tty_bsis
                     pt_bsik TYPE tty_bsik
                     pt_bseg TYPE tty_bseg
                     pt_tp_imposto TYPE tty_tipo_imposto
                     pt_doc TYPE tty_doc
                     pt_stx TYPE tty_stx
                     pt_lin TYPE tty_lin
                     pt_ekkn TYPE tty_ekkn
      pt_ekpo TYPE tty_ekpo                 "domicilio no pedido compras
      pt_txjurt TYPE tty_txjurt
      pt_witem TYPE tty_witem
      pt_data  TYPE tty_data
 CHANGING pt_header TYPE tty_header
          pt_item TYPE tty_item
          pt_resumo_imp TYPE tty_resumo_impostos.

  DATA:
    ls_bsis       TYPE ty_bsis,
    ls_bsik       TYPE ty_bsik,
    ls_bseg       TYPE ty_bseg,
    ls_header     TYPE zari_bkpf,
    ls_item       TYPE zari_bseg,
    ls_tp_imposto TYPE ty_tipo_imposto,
    ls_resumo_imp TYPE ty_resumo_impostos,
    lv_week       TYPE scal-week,
    ls_t247       TYPE t247,
    lv_num        TYPE numc1,
    ls_cpudt      TYPE ty_data.

  ls_header-nome_usuario_geracao = sy-uname.
  ls_header-codigo_imposto = ps_cod_imposto-codigo_imposto.
  ls_header-empresa        = ps_bkpf-bukrs.

  LOOP AT pt_data INTO ls_cpudt.
    EXIT.
  ENDLOOP.

  READ TABLE pt_bsis TRANSPORTING NO FIELDS WITH KEY bukrs = ps_bkpf-bukrs
                                     hkont = ps_cod_imposto-conta_contabil
                                     gjahr = ps_bkpf-gjahr
                                     belnr = ps_bkpf-belnr.



  LOOP AT pt_bsis INTO ls_bsis FROM sy-tabix.
    IF ls_bsis-bukrs <> ps_bkpf-bukrs OR ls_bsis-hkont <> ps_cod_imposto-conta_contabil OR
    ls_bsis-gjahr <> ps_bkpf-gjahr OR ls_bsis-belnr <> ps_bkpf-belnr.
      EXIT.
    ENDIF.
* verficando qual o periodo de apuração.
    IF s_gjahr IS INITIAL.
      ls_header-exercicio = ls_cpudt-high(4).  "sy-datum(4).
    ELSE.
      ls_header-exercicio = s_gjahr-low.  "ls_bsis-gjahr.
    ENDIF.
    IF s_monat IS INITIAL.
      ls_header-periodo =  ls_cpudt-high+4(2). "sy-datum+4(2)
    ELSE.
      ls_header-periodo =  s_monat-low.   "ls_bsis-budat+4(2).
    ENDIF.

    CASE ps_cod_imposto-periodo_apuracao.


      WHEN '1'.	" Semanal

        CALL FUNCTION 'DATE_GET_WEEK'
          EXPORTING
            date = ls_bsis-bldat        "budat
          IMPORTING
            week = lv_week.

        CALL FUNCTION 'IDWT_READ_MONTH_TEXT'
          EXPORTING
            langu = sy-langu
            month = ls_bsis-bldat+4(2)  "budat
          IMPORTING
            t247  = ls_t247.

        CONCATENATE 'Sm' lv_week ls_t247-ktx(3) ls_bsis-bldat(4) INTO ls_header-nome_periodo.    "lv_week ls_t247-ktx(3) ls_bsis-budat(4)

      WHEN '2'.	" Mensal
        CALL FUNCTION 'IDWT_READ_MONTH_TEXT'
          EXPORTING
            langu = sy-langu
            month = ls_bsis-bldat+4(2) "budat
          IMPORTING
            t247  = ls_t247.

        CONCATENATE ls_t247-ktx(3) ls_bsis-bldat(4) INTO ls_header-nome_periodo.  "budat

      WHEN '3'.	" Trimestral
        lv_num = trunc( ls_bsis-budat+4(2) DIV 3 ).
        PERFORM valida_periodo CHANGING lv_num.
        CONCATENATE lv_num '°Trim' ls_bsis-bldat(4) INTO ls_header-nome_periodo.  "budat
      WHEN '4'. "	Semestral
        lv_num = trunc( ls_bsis-budat+4(2) DIV 6 ).
        PERFORM valida_periodo CHANGING lv_num.
        CONCATENATE lv_num '°Sem' ls_bsis-bldat(4) INTO ls_header-nome_periodo.   "budat
      WHEN '5'. " Anual
        ls_header-nome_periodo = ls_bsis-bldat(4).  "budat
      WHEN OTHERS. " Fixo
    ENDCASE.

*   tipo de apuração
*    READ TABLE gt_cod_imposto INTO ls_cod_imposto WITH KEY conta_contabil = ls_bsis-hkont.
    CLEAR: ls_header-divisao, ls_header-filial.
    CASE ps_cod_imposto-tipo_apuracao.
      WHEN '1'.	"cnpj filial
* MFS 06/04/2016
        IF ps_cod_imposto-periodo_apuracao NE '5'.  " Regra de apuração Empresa + Divisão. Se for 5 - anual será apurado por Empresa ( IRPJ e CSLL )
          ls_header-divisao = ls_bsis-gsber.
          ls_header-filial = ls_bsis-bupla.
        ENDIF.

        IF ls_bsis-bupla IS INITIAL OR ps_cod_imposto-categ_imposto = '1'.
          _company_read ps_bkpf-bukrs ls_header-cnpj.
        ELSE.
          _branch_read ps_bkpf-bukrs ls_bsis-bupla ls_header-cnpj.
        ENDIF.

      WHEN '2'. " cnpj divisão(concessão)
* MFS 06/04/2016
        IF ps_cod_imposto-periodo_apuracao NE '5'.  " Regra de apuração Empresa + Divisão. Se for 5 - anual será apurado por Empresa ( IRPJ e CSLL )
          ls_header-divisao = ls_bsis-gsber.
        ENDIF.

        IF ls_bsis-bupla IS INITIAL OR ps_cod_imposto-categ_imposto = '1'.
          _company_read ps_bkpf-bukrs ls_header-cnpj.
        ELSE.
          _branch_read ps_bkpf-bukrs ls_bsis-bupla ls_header-cnpj.
        ENDIF.

      WHEN '3'. " cnpj principal
        _company_read ps_bkpf-bukrs ls_header-cnpj.

    ENDCASE.

    ls_item-filial = ls_header-filial.
    ls_item-cod_fornecedor = ls_header-cod_fornecedor.

*< T.1
*    CASE ps_bkpf-awtyp.
*      WHEN 'RMRP'.
*> T.1
    READ TABLE pt_doc ASSIGNING <doc> WITH KEY belnr = ls_bsis-belnr
                                       gjahr = ls_bsis-gjahr
                                       bukrs = ls_bsis-bukrs.
    IF sy-subrc = 0.

*< T.1 - Inserido
      ls_item-doc_fiscal        = <doc>-docnum.
* MFS - 18.03.2016
      IF ps_cod_imposto-tipo_apuracao = '1'.  " Regra de apuração por Filial
        ls_header-filial          = <doc>-branch.
        ls_item-filial            = <doc>-branch.
      ENDIF.

      ls_item-dom_fiscal_forn   = <doc>-txjcd.
      ls_item-tipo_doc_fat      = <doc>-doctyp.
      ls_item-direcao_movimento = <doc>-direct.
      ls_item-nota_fiscal_srv   = <doc>-nfesrv.

      IF <doc>-parvw = 'LF' AND <doc>-partyp = 'V'.
* MFS - 18.03.2016
        IF ps_cod_imposto-regra_acumulo = '2'.
          ls_header-cod_fornecedor = ls_item-cod_fornecedor = <doc>-parid.
        ELSE.
*          ls_item-cod_fornecedor = <doc>-parid.
        ENDIF.
      ENDIF.

      IF <doc>-nfnum IS INITIAL.
        ls_item-nota_fiscal = <doc>-nfenum.
      ELSE.
        ls_item-nota_fiscal = <doc>-nfnum.
      ENDIF.

      READ TABLE pt_lin ASSIGNING <lin> WITH KEY docnum = <doc>-docnum.
      IF sy-subrc = 0.
        ls_item-numero_pedido   = <lin>-ebeln.
        ls_item-item_pedido     = <lin>-ebelp.
        ls_item-id_imposto      = <lin>-taxlw3.
        ls_item-item_doc_fiscal = <lin>-itmnum.

        READ TABLE pt_ekkn ASSIGNING <ekkn> WITH KEY ebeln = <lin>-ebeln
                                      ebelp = <lin>-ebelp BINARY SEARCH.
        IF sy-subrc = 0.
          ls_item-ordem_interna = <ekkn>-aufnr.
          ls_item-centro_custo  = <ekkn>-kostl.
          ls_item-centro_lucro  = <ekkn>-prctr.
          ls_item-elemento_pep  = <ekkn>-ps_psp_pnr.

        ENDIF.
      ENDIF.
*> T.1

      READ TABLE pt_stx ASSIGNING <stx> WITH KEY docnum = <doc>-docnum
                                      taxtyp = ps_cod_imposto-categ_iva.
      IF sy-subrc = 0.

*< T.1
*     Validar UF caso seja imposto estadual
        IF ps_cod_imposto-categ_imposto EQ '2'.
          IF ps_cod_imposto-uf NE <stx>-tax_loc(2).
            CONTINUE.
          ENDIF.
        ENDIF.
*> T.1

*< T.1
*     Validar Domicilio fiscal caso seja imposto municipal
        IF ps_cod_imposto-categ_imposto EQ '3'.
          IF ps_cod_imposto-domicilio_fiscal NE <stx>-tax_loc.
            CONTINUE.
          ENDIF.
        ENDIF.
*> T.1

        ls_item-categ_iva = <stx>-taxtyp.
        ls_item-montante_imposto = <stx>-taxval.
        ls_item-domicilio_fiscal = ls_item-dom_fiscal_srv = <stx>-tax_loc.
        ls_item-grupo_imposto = <stx>-taxgrp.

        READ TABLE pt_txjurt ASSIGNING <txjurt> WITH KEY taxjurcode = <stx>-tax_loc BINARY SEARCH.
        IF sy-subrc = 0.
          ls_item-cidade = <txjurt>-text.
        ENDIF.

*< T.1 - Comentado
*      READ TABLE pt_lin ASSIGNING <lin> WITH KEY docnum = <doc>-docnum.
*      ls_item-numero_pedido = <lin>-ebeln.
*      ls_item-item_pedido = <lin>-ebelp.
*      ls_item-id_imposto = <lin>-taxlw3.
*> T.1

*< T.1 - Comentado
*      READ TABLE pt_ekkn ASSIGNING <ekkn> WITH KEY ebeln = <lin>-ebeln
*                                                   ebelp = <lin>-ebelp BINARY SEARCH.
*      IF sy-subrc = 0.
*        ls_item-ordem_interna = <ekkn>-aufnr.
*        ls_item-centro_custo = <ekkn>-kostl.
*        ls_item-centro_lucro = <ekkn>-prctr.
*        ls_item-elemento_pep = <ekkn>-ps_psp_pnr.
*< T.1
**      ELSE.
**        MESSAGE e000 WITH 'Não há informações de impostos'.
**      ENDIF.
*      ENDIF.
*      ls_item-doc_fiscal = <doc>-docnum.
*      ls_item-item_doc_fiscal = <lin>-itmnum.
*      IF <doc>-nfnum IS INITIAL.
*        ls_item-nota_fiscal = <doc>-nfenum.
*      ELSE.
*        ls_item-nota_fiscal = <doc>-nfnum.
*      ENDIF.
*      ls_header-filial = ls_item-filial = <doc>-branch.
*      ls_item-dom_fiscal_forn = <doc>-txjcd.
*      ls_item-tipo_doc_fat = <doc>-doctyp.
*      ls_item-direcao_movimento = <doc>-direct.
*< T.1
*      ls_item-nota_fiscal_srv = <doc>-nfesrv.
*< T.1
*      IF <doc>-parvw = 'LF' AND <doc>-partyp = 'V'.
*        ls_header-cod_fornecedor =
*        ls_item-cod_fornecedor = <doc>-parid.
*      ENDIF.
*< T.1
*> T.1
      ELSE.                         "quando exite NF e não é IVA, sem categoria de Imposto na NF.
*        Continue.
        READ TABLE pt_ekpo ASSIGNING <ekpo> WITH KEY ebeln = <lin>-ebeln
                                      ebelp = <lin>-ebelp BINARY SEARCH.

        IF sy-subrc IS INITIAL.

*       Validar UF caso seja imposto estadual
          IF ps_cod_imposto-categ_imposto EQ '2'.
            IF ps_cod_imposto-uf NE <ekpo>-txjcd(2).
              CONTINUE.
            ENDIF.
          ENDIF.
*  > T.1

*  < T.1
*       Validar Domicilio fiscal caso seja imposto municipal
          IF ps_cod_imposto-categ_imposto EQ '3'.
            IF ps_cod_imposto-domicilio_fiscal NE <ekpo>-txjcd.
              CONTINUE.
            ENDIF.
          ENDIF.
*  > T.1

          ls_item-domicilio_fiscal = ls_item-dom_fiscal_srv = <ekpo>-txjcd.

          READ TABLE pt_txjurt ASSIGNING <txjurt> WITH KEY taxjurcode = <ekpo>-txjcd BINARY SEARCH.
          IF sy-subrc = 0.
            ls_item-cidade = <txjurt>-text.
          ENDIF.
        ENDIF.
      ENDIF.
    ELSE.
* continuar somente se não for Impostos Estaduais e Municipais - Necessidade de NF.
      CHECK ps_cod_imposto-categ_imposto <> '2' AND  "Estaduais
            ps_cod_imposto-categ_imposto <> '3'.     "Municipais
    ENDIF.

*      WHEN OTHERS.
* valida a pesquisa da WITH_ITEM somente par os itens com IR.
    IF ps_cod_imposto-irrf = 'X' OR
       ps_cod_imposto-categ_imposto = '3'.
*> T.1
      READ TABLE pt_witem ASSIGNING <witem> WITH KEY bukrs = ls_bsis-bukrs
                                                     belnr = ls_bsis-belnr
                                                     gjahr = ls_bsis-gjahr
                                        witht = ps_cod_imposto-categ_irrf.
*    IF sy-subrc = 0.
      CHECK sy-subrc IS INITIAL.

*     verificar duplicidade
      READ TABLE pt_item TRANSPORTING NO FIELDS WITH KEY empresa            = ls_bsis-bukrs
      num_doc_contabil   = ls_bsis-belnr
      exercicio_contabil = ls_bsis-gjahr
      item_lancamento    = ls_bsis-buzei.
*                                                         codigo_imposto     = ps_cod_imposto-codigo_imposto.
      CHECK sy-subrc IS NOT INITIAL.
      ls_item-categ_irrf = <witem>-witht.
      ls_item-montante_imposto = <witem>-wt_qbshh.
* MFS - 18.03.2016
      IF ps_cod_imposto-regra_acumulo = '2'.
        ls_header-cod_fornecedor = ls_item-cod_fornecedor = <witem>-wt_acco.  " deverá respeitar a regra de acumulo.
      ELSE.
*       ls_item-cod_fornecedor = <witem>-wt_acco.
      ENDIF.
*    ENDIF.
*< T.1
    ENDIF.
*    ENDCASE.
*> T.1

*   Regra de Acumulo - 1-Periodo ou 2-Período e Prestador
*    CLEAR ls_header-cod_fornecedor.
    IF ps_cod_imposto-regra_acumulo = '2'.  "Período Prestados
      READ TABLE pt_bseg INTO ls_bseg WITH KEY bukrs = ls_bsis-bukrs
                                             belnr = ls_bsis-belnr
                                    gjahr = ls_bsis-gjahr BINARY SEARCH.
      IF sy-subrc = 0 AND ls_header-cod_fornecedor IS INITIAL.
*      READ TABLE pt_bsik INTO ls_bsik WITH KEY bukrs = ls_bsis-bukrs
**                                               augdt = ls_bsis-augdt
**                                               augbl = ls_bsis-augbl
**                                               zuonr = ls_bsis-zuonr
*                                           gjahr = ls_bsis-gjahr
*                                           belnr = ls_bsis-belnr
*                                           buzei = ls_bsis-buzei.
        ls_item-cod_fornecedor = ls_header-cod_fornecedor = ls_bseg-lifnr.

      ENDIF.
    ENDIF.
* MFS - 18.03.2016
*    CONCATENATE 'Pré Apuração' ls_header-empresa ls_header-divisao ls_header-filial ls_header-nome_periodo INTO ls_header-texto.
    CONCATENATE 'Pré Apuração' ls_header-empresa ls_header-divisao ls_header-filial ls_header-nome_periodo ls_header-cod_fornecedor INTO ls_header-texto.

*   Ajustando o sinal do montante para reduzir da apuração do Débitos encontrados - Ajustes ou Compensações
    IF ls_bsis-shkzg = 'S'.
      ls_header-montante_apurado = ls_bsis-dmbtr * -1.

    ELSE.
      ls_header-montante_apurado = ls_bsis-dmbtr.
    ENDIF.
*    IF p_direcao = c_a_recuperar.
*      ls_header-montante_apurado = ls_header-montante_apurado * -1.
*    ENDIF.
*    COLLECT ls_header INTO pt_header.
*
    ls_item-empresa = ls_header-empresa.
    ls_item-exercicio_apuracao = ls_header-exercicio. "ls_bsis-budat(4).
    ls_item-periodo_apuracao =   ls_header-periodo.   "ls_bsis-budat+4(2).
    ls_item-nome_periodo = ls_header-nome_periodo.    "nome do período de apuração
    ls_item-num_doc_contabil = ls_bsis-belnr.
    ls_item-exercicio_contabil = ls_bsis-gjahr.
    ls_item-item_lancamento = ls_bsis-buzei.
    ls_item-conta_contabil = ls_bsis-hkont.
    ls_item-direcao = p_direcao. " A pagar
    ls_item-divisao = ls_header-divisao.

*   Ajustando o sinal do montante para reduzir da apuração do Débitos encontrados - Ajustes ou Compensações
    IF ls_bsis-shkzg = 'S'.
      ls_item-montante = ls_bsis-dmbtr * ( -1 ).
    ELSE.
      ls_item-montante = ls_bsis-dmbtr.
    ENDIF.

    ls_header-moeda = ls_item-moeda = ls_bsis-waers.
    ls_item-data_lancamento = ls_bsis-budat.
    ls_item-data_documento = ls_bsis-bldat.
    ls_item-data_efetiva = ls_bsis-valut.
    ls_item-data_entrada = ps_bkpf-cpudt.

    ls_header-categ_imposto       = ls_item-categ_imposto   = ls_tp_imposto-categ_imposto.
    ls_header-tipo_imposto        = ls_item-tipo_imposto    = ps_cod_imposto-tipo_imposto.
    ls_header-codigo_imposto      = ls_item-codigo_imposto  = ps_cod_imposto-codigo_imposto.


*    READ TABLE pt_tp_imposto INTO ls_tp_imposto WITH KEY tipo_imposto = ps_cod_imposto-tipo_imposto.
*    IF ls_tp_imposto-categ_imposto = '2'.
**LS_ITEM-UF
*    ELSEIF ls_tp_imposto-categ_imposto = '1'.
**LS_ITEM-DOMICILIO_FISCAL
*    ENDIF.

*< T.1
    ls_item-uf            = ps_cod_imposto-uf.
    ls_item-categ_imposto = ps_cod_imposto-categ_imposto.
    IF <lin>-nbm IS ASSIGNED.
      ls_item-nbm           = <lin>-nbm.
    ENDIF.

    ls_header-uf                = ps_cod_imposto-uf.
    ls_header-categ_imposto     = ps_cod_imposto-categ_imposto.
    ls_header-domicilio_fiscal  = ps_cod_imposto-domicilio_fiscal.
*> T.1

    ls_resumo_imp-tipo_imposto    = ps_cod_imposto-tipo_imposto.
    ls_resumo_imp-categ_imposto   = ls_tp_imposto-categ_imposto.
    ls_resumo_imp-dia_vencimento  = ps_cod_imposto-dia_vencimento.
    COLLECT ls_resumo_imp INTO pt_resumo_imp.

    IF ls_bsis-bldat IN pt_data.    "Budat
      ls_header-competencia       = ls_item-competencia     = 'S'.
    ELSE.
      ls_header-competencia       = ls_item-competencia     = 'N'.
* Preparação para apuração individual por fatura para entradas fora da competecia.
*      CONCATENATE 'Pré Apuração' ls_header-empresa ls_header-divisao ls_header-filial ls_header-nome_periodo ls_bsis-belnr ls_bsis-buzei INTO ls_header-texto.
    ENDIF.

    COLLECT ls_header INTO pt_header.

    APPEND ls_item TO pt_item.

    CLEAR: ls_resumo_imp, ls_item.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECIONA_BSEG
*&---------------------------------------------------------------------*
FORM seleciona_bseg  USING VALUE(pt_cod_imposto) TYPE tty_cod_imposto
                          VALUE(pt_cod_imposto_rec) TYPE tty_cod_imposto
                    CHANGING pt_bsis TYPE tty_bsis
                             pt_bseg TYPE tty_bseg
                             pt_comp_manual TYPE tty_comp_manual.

  DATA:           lv_idx          TYPE i,
                  lt_fields       TYPE rsz_t_string,
                  gt_bsis         TYPE tty_bsis,
                  gc_bsis         TYPE ty_bsis,
                  gt_rg_hkont_aux TYPE RANGE OF zari_cod_imposto-conta_contabil,
                  gc_cod_imposto  TYPE ty_cod_imposto,
                  gd_cod_imposto  TYPE ty_cod_imposto,
                  gc_comp_manual  TYPE ty_comp_manual.

  gt_rg_hkont_aux[] = zcl_utils=>get_range_of_table( im_table = pt_cod_imposto_rec
  im_field = 'CONTA_CONTABIL' ).


  lt_fields = zcl_utils=>get_itab_fields( pt_bseg ).
  SELECT (lt_fields)
  INTO TABLE pt_bseg
  FROM bseg
  FOR ALL ENTRIES IN pt_bsis
    WHERE bukrs = pt_bsis-bukrs
      AND belnr = pt_bsis-belnr
      AND gjahr = pt_bsis-gjahr.

* eliminação dos documentos de recolhimento e compensação  e considerando no calculo valores a débito e a crédito
  SORT pt_bseg BY bukrs belnr gjahr shkzg hkont.
  SORT pt_cod_imposto BY cod_fornecedor.

  LOOP AT pt_bsis ASSIGNING <bsis>.

    lv_idx = sy-tabix.

*   Testando os documentos de recolhimento

    IF <bsis>-shkzg = 'S'.

      LOOP AT pt_bseg ASSIGNING <bseg> WHERE bukrs  = <bsis>-bukrs
                                         AND belnr  = <bsis>-belnr
                                         AND gjahr = <bsis>-gjahr
                                         AND shkzg = 'H'
                                         AND hkont <> <bsis>-hkont.
*       verificando se a contrapartida é o fornecedor do imposto a recolher ou a conta da compensação.
        IF <bseg>-koart = 'K'.

          READ TABLE pt_cod_imposto TRANSPORTING NO FIELDS WITH KEY cod_fornecedor = <bseg>-lifnr.

          IF sy-subrc IS INITIAL.
            DELETE pt_bsis INDEX lv_idx.
            EXIT.
* MFS 26/04/2016
          ELSE.   " testar se o documento de devolução esta no período de apuração
*           verificando se o ano e mes são iguais entre a data de lançamento e data de documento
            IF <bsis>-budat(06) NE <bsis>-bldat(06).
              DELETE pt_bsis INDEX lv_idx.
              EXIT.
            ENDIF.
* MFS 26/04/2016
          ENDIF.
        ELSE.

*         localiza o código do imposto pela conta contabil - pt_bsis
          READ TABLE pt_cod_imposto INTO gc_cod_imposto WITH KEY conta_contabil = <bsis>-hkont.

          CHECK sy-subrc IS INITIAL.

*         localiza os dados imposto a recuperar atribuido ao impostos corrente.
          READ TABLE pt_cod_imposto_rec INTO gd_cod_imposto WITH KEY codigo_imposto = gc_cod_imposto-cod_imposto_rec.

          IF sy-subrc IS INITIAL.

            IF sy-subrc IS INITIAL AND gd_cod_imposto-conta_contabil = <bseg>-hkont.  " valida se a contrapartida é a conta de imp a recuperar.
* MFS 06/04/2016
              IF gc_cod_imposto-periodo_apuracao = '5'. " Apuração acumulado anual - IRPJ e CSLL
                DELETE pt_bsis INDEX lv_idx.
                EXIT.
              ENDIF.
* MFS 06/04/2016
*              marcar as divisões da empresa que já soferam compensações manuais.

              MOVE-CORRESPONDING <bsis> TO gc_comp_manual.

              gc_comp_manual-hkont = <bseg>-hkont.

              COLLECT gc_comp_manual INTO pt_comp_manual.
            ENDIF.

          ELSE.

* MFS - 04/04/2016
*           verificando se a conta de contrapartida é uma conta de compensação ( PER DCOMP e DCOMP ),
*           se for eliminar pois não deve entrar na posição, como pagamentos
            IF <bseg>-hkont CS '112412'.
              DELETE pt_bsis INDEX lv_idx.
              EXIT.
            ENDIF.

          ENDIF.

* MFS - 04/04/2016

        ENDIF.

      ENDLOOP.
    ELSE.
* MFS - 06/04/2016
*    localiza o código do imposto pela conta contabil - pt_bsis
      READ TABLE pt_cod_imposto INTO gc_cod_imposto WITH KEY conta_contabil = <bsis>-hkont.

*    testando se existe registro a crédito que seja compensação - fruição entre divisões.
      IF sy-subrc IS INITIAL AND gc_cod_imposto-periodo_apuracao = '5'.

        LOOP AT pt_bseg ASSIGNING <bseg> WHERE bukrs  = <bsis>-bukrs
                                           AND belnr  = <bsis>-belnr
                                           AND gjahr = <bsis>-gjahr
                                           AND shkzg = 'S'
                                           AND hkont <> <bsis>-hkont.

*         localiza os dados imposto a recuperar atribuido ao impostos corrente.
          READ TABLE pt_cod_imposto_rec INTO gd_cod_imposto WITH KEY codigo_imposto = gc_cod_imposto-cod_imposto_rec.

          IF sy-subrc IS INITIAL AND gd_cod_imposto-conta_contabil = <bseg>-hkont.  " valida se a contrapartida é a conta de imp a recuperar.
            IF <bseg>-koart = 'S' AND <bseg>-hkont CS '112412'.
              DELETE pt_bsis INDEX lv_idx.
              EXIT.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDIF.
* MFS - 06/04/2016
    ENDIF.

  ENDLOOP.

  DELETE pt_bseg WHERE koart <> 'K'.

  SORT pt_bseg BY bukrs belnr gjahr.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GERA_BASE_DADOS
*&---------------------------------------------------------------------*
FORM gera_base_dados .

  SORT gt_bsis BY bukrs hkont gjahr belnr.
  SORT gt_ekkn BY ebeln ebelp.
  SORT gt_ekpo BY ebeln ebelp.

  LOOP AT gt_cod_imposto ASSIGNING <cod_imposto>.

    READ TABLE gt_empresa ASSIGNING <empresa> WITH KEY codigo_imposto = <cod_imposto>-codigo_imposto.

* condição para evitar DUMP se o macro Empresa estiver vazia.
    IF sy-subrc <> 0.
      MESSAGE s000 WITH 'Não encontrado Código de Imposto'.
      CONTINUE.
    ENDIF.

    LOOP AT gt_bkpf ASSIGNING <bkpf> WHERE bukrs = <empresa>-empresa.

*&---------------------------- C O D I G O   I M P O S T O ----------------------------

*----------------------------------------------------------------------*
* Início Alteração - 26.07.2016
*----------------------------------------------------------------------*
      " Quando municipal
      CASE <cod_imposto>-categ_imposto.
        WHEN '3'.
          PERFORM loop_bsis_cod3 USING c_a_pagar
                                       <cod_imposto>
                                       <bkpf>
                                       gt_bsis
                                       gt_bsik
                                       gt_bseg
                                       gt_tp_imposto
                                       gt_doc
                                       gt_stx
                                       gt_lin
                                       gt_ekkn
                                       gt_ekpo
                                       gt_txjurt
                                       gt_witem gt_data
                              CHANGING gt_header
                                       gt_item
                                       gt_resumo_imp.
          " Quando outros
        WHEN OTHERS.
          PERFORM loop_bsis USING c_a_pagar
                                  <cod_imposto>
                                  <bkpf>
                                  gt_bsis
                                  gt_bsik
                                  gt_bseg
                                  gt_tp_imposto
                                  gt_doc
                                  gt_stx
                                  gt_lin
                                  gt_ekkn
                                  gt_ekpo
                                  gt_txjurt
                                  gt_witem gt_data
                         CHANGING gt_header
                                  gt_item
                                  gt_resumo_imp.
      ENDCASE.
*----------------------------------------------------------------------*
* Fim Alteração - 26.07.2016
*----------------------------------------------------------------------*

*&---------------------------- C O D I G O   I M P O S T O   R E C ----------------------------
      IF <cod_imposto>-cod_imposto_rec IS NOT INITIAL.
        READ TABLE gt_cod_imposto_rec INTO ls_cod_imposto_rec WITH KEY codigo_imposto = <cod_imposto>-cod_imposto_rec.
        PERFORM loop_bsis USING c_a_recuperar ls_cod_imposto_rec <bkpf>
gt_bsis gt_bsik gt_bseg gt_tp_imposto gt_doc gt_stx gt_lin gt_ekkn gt_ekpo gt_txjurt
gt_witem gt_data
CHANGING gt_header gt_item gt_resumo_imp.
      ENDIF.

    ENDLOOP.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  INSERE_BD
*&---------------------------------------------------------------------*
FORM insere_bd .
  DATA:
    lv_pos      TYPE zari_interv_num-posicao,
    lv_pos_item TYPE zari_bseg-item_apuracao,
    lv_data     TYPE sydatum,
    lv_hora     TYPE syuzeit,
    lv_tabix    TYPE sy-tabix.

  FIELD-SYMBOLS : <item_rec> TYPE zari_bseg.

  lv_data = sy-datum.
  lv_hora = sy-uzeit.

  SORT gt_item BY categ_imposto tipo_imposto codigo_imposto empresa divisao filial nome_periodo cod_fornecedor.

  LOOP AT gt_header ASSIGNING <header>.

    PERFORM get_next_num CHANGING lv_pos.
    IF lv_pos = '9999999999'.
      MESSAGE s100(zcmcarga) DISPLAY LIKE 'E' WITH 'Estouro do sequencial'.
      RETURN.
    ENDIF.

    <header>-num_doc_apuracao = lv_pos.
    <header>-data_geracao = lv_data.
    <header>-hora_geracao = lv_hora.

    lv_pos_item = 0.

* tratamento titulos fora da competencia, cosiderar apuração por fatura
*   IF <header>-competencia = 'N'.
*         LOOP AT gt_item ASSIGNING <item> WHERE categ_imposto = <header>-categ_imposto
*                                          AND tipo_imposto = <header>-tipo_imposto
*                                          AND codigo_imposto = <header>-codigo_imposto
*                                          AND divisao = <header>-divisao
*                                          AND filial = <header>-filial
*                                          AND cod_fornecedor = <header>-cod_fornecedor
*                                          AND NUM_DOC_CONTABIL = <header>-texto+30(10)
*                                          AND item_lancamento = <header>-texto+40(03).
*         lv_pos_item = <item>-item_apuracao = lv_pos_item + 1.
*         <item>-num_doc_apuracao = lv_pos.
*       ENDLOOP.
*   ELSE.
    LOOP AT gt_item ASSIGNING <item> WHERE categ_imposto = <header>-categ_imposto
                                       AND tipo_imposto = <header>-tipo_imposto
                                       AND codigo_imposto = <header>-codigo_imposto
                                       AND empresa = <header>-empresa
                                       AND divisao = <header>-divisao
                                       AND filial = <header>-filial
                                       AND nome_periodo = <header>-nome_periodo
                                       AND cod_fornecedor = <header>-cod_fornecedor.

*----------------------------------------------------------------------*
* Início Alteração - 26.07.2016
*----------------------------------------------------------------------*
      IF <header>-categ_imposto EQ '3'.
        IF <header>-domicilio_fiscal NE <item>-domicilio_fiscal.
          CONTINUE.
        ENDIF.
      ENDIF.
*----------------------------------------------------------------------*
* Fim Alteração - 26.07.2016
*----------------------------------------------------------------------*

      lv_pos_item = <item>-item_apuracao = lv_pos_item + 1.

* MFS 15/04/2016
*        informar o nr.documento de apuração do a recuperar no nr. documento contábil do item a ser subsituido na confirmação da contabilização.
      IF <item>-direcao = '+' AND <item>-numero_pedido CS 'COMP'.
        IF <item>-numero_pedido+5(05) = <item>-codigo_imposto.

          <item>-num_doc_contabil = lv_pos.
          <item>-item_lancamento  = '001'.

          lv_tabix = sy-tabix.

          READ TABLE gt_cod_imposto ASSIGNING <cod_imposto> WITH KEY categ_imposto   = <header>-categ_imposto
          tipo_imposto    = <header>-tipo_imposto
          cod_imposto_rec = <header>-codigo_imposto.

          IF sy-subrc IS INITIAL.

            READ TABLE gt_item ASSIGNING <item_rec> WITH KEY categ_imposto = <cod_imposto>-categ_imposto
            tipo_imposto = <cod_imposto>-tipo_imposto
            codigo_imposto = <cod_imposto>-codigo_imposto
            empresa = <header>-empresa
            divisao = <header>-divisao
            filial = <header>-filial
            nome_periodo = <header>-nome_periodo
            cod_fornecedor = <header>-cod_fornecedor
            direcao = '+'
            conta_contabil = <item>-ordem_interna(10).
            IF sy-subrc IS INITIAL.
              <item_rec>-num_doc_contabil = lv_pos.
              <item_rec>-item_lancamento  = '001'.
            ENDIF.
          ENDIF.

          sy-tabix = lv_tabix.

        ENDIF.
      ENDIF.
* MFS 15/04/2016
      <item>-num_doc_apuracao = lv_pos.
    ENDLOOP.
*    ENDIF.
  ENDLOOP.

  INSERT zari_bkpf FROM TABLE gt_header.
  INSERT zari_bseg FROM TABLE gt_item.

  IF sy-subrc = 0.
    MESSAGE s000 WITH 'Dados gerados com sucesso'.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ENVIA_EMAIL_RESPONSAVEIS
*&---------------------------------------------------------------------*
FORM envia_email_responsaveis .

  PERFORM seleciona_responsavel USING gt_resumo_imp CHANGING gt_resp.
  CHECK gt_resp IS NOT INITIAL.
  PERFORM envia_email USING gt_resp gt_resumo_imp.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECIONA_DOC
*&---------------------------------------------------------------------*
FORM seleciona_doc  CHANGING pt_bsis TYPE tty_bsis
                             pt_doc  TYPE tty_doc.
  DATA:
    lv_idx    TYPE i,
    lt_fields TYPE rsz_t_string,
    gt_bsis   TYPE tty_bsis,
    gt_doc    TYPE tty_doc,
    gc_doc    TYPE ty_doc.

  gt_bsis = pt_bsis.

  DELETE gt_bsis WHERE awtyp <> 'RMRP'.


  CHECK gt_bsis IS NOT INITIAL.

  lt_fields = zcl_utils=>get_itab_fields( pt_doc ).
  SELECT (lt_fields)
  INTO TABLE pt_doc
  FROM j_1bnfdoc
  FOR ALL ENTRIES IN gt_bsis
    WHERE belnr = gt_bsis-belnr
      AND gjahr = gt_bsis-gjahr
      AND bukrs = gt_bsis-bukrs.

*  DELETE pt_doc WHERE cancel = 'X'.

* MFS - 23/03/2016
* Tratamento documento de Cancelamento de NF fora do período de apuração.
* os documentos de cancelamento das notas fiscais fora do período de apuração
* não devem ser selecioandos pelo Cockpit, estas notas serão tratadas via processo externo ao COCKPIT.



  CHECK pt_doc IS NOT INITIAL.

  gt_doc = pt_doc.

  LOOP AT pt_doc INTO gc_doc.

    lv_idx = sy-tabix.

    IF gc_doc-doctyp = '5'.

      READ TABLE gt_doc TRANSPORTING NO FIELDS WITH KEY docnum = gc_doc-docref.

      CHECK sy-subrc IS NOT INITIAL.

      DELETE pt_bsis WHERE bukrs = gc_doc-bukrs
                       AND belnr = gc_doc-belnr
                       AND gjahr = gc_doc-gjahr.

      IF sy-subrc IS INITIAL.

        DELETE pt_doc INDEX lv_idx.
        CONTINUE.

      ENDIF.

    ENDIF.

  ENDLOOP.


ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECIONA_STX
*&---------------------------------------------------------------------*
FORM seleciona_stx  USING    pt_doc TYPE tty_doc
                             pt_cod_imposto TYPE tty_cod_imposto
                    CHANGING pt_stx TYPE tty_stx.
  DATA:
    lt_fields TYPE rsz_t_string,
    lt_rg_iva TYPE RANGE OF zari_cod_imposto-categ_iva.

  lt_rg_iva[] = zcl_utils=>get_range_of_table( im_table = pt_cod_imposto
                                               im_field = 'CATEG_IVA' ).

  lt_fields = zcl_utils=>get_itab_fields( pt_stx ).
  SELECT (lt_fields)
  INTO TABLE pt_stx
  FROM j_1bnfstx
  FOR ALL ENTRIES IN pt_doc
    WHERE docnum = pt_doc-docnum
      AND taxtyp IN lt_rg_iva.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECIONA_LIN
*&---------------------------------------------------------------------*
FORM seleciona_lin  USING    VALUE(pt_stx) TYPE tty_stx
                    CHANGING pt_lin TYPE tty_lin.
  DATA:
    lt_fields TYPE rsz_t_string,
    pt_rseg   TYPE ty_rseg.

  DELETE ADJACENT DUPLICATES FROM pt_stx COMPARING docnum itmnum.

  lt_fields = zcl_utils=>get_itab_fields( pt_lin ).
  DELETE lt_fields WHERE table_line = 'EBELN' OR table_line = 'EBELP'.
  SELECT (lt_fields)
  INTO TABLE pt_lin
  FROM j_1bnflin
  FOR ALL ENTRIES IN pt_stx
    WHERE docnum = pt_stx-docnum
      AND itmnum = pt_stx-itmnum.


  lt_fields = zcl_utils=>get_itab_fields( gt_rseg ).
  LOOP AT pt_lin ASSIGNING <lin>.

    SELECT SINGLE (lt_fields)
    INTO  pt_rseg
    FROM  rseg
    WHERE belnr = <lin>-refkey(10)
      AND gjahr = <lin>-refkey+10(08)
      AND buzei = <lin>-refitm.

    IF sy-subrc IS INITIAL.

      ASSIGN pt_rseg TO <rseg>.

      <lin>-ebeln = <rseg>-ebeln.
      <lin>-ebelp = <rseg>-ebelp.
    ELSE.
      <lin>-ebeln = <lin>-xped(10).
      <lin>-ebelp = <lin>-nitemped(5).
    ENDIF.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECIONA_EKKN
*&---------------------------------------------------------------------*
FORM seleciona_ekkn  USING    pt_lin TYPE tty_lin
                     CHANGING pt_ekkn TYPE tty_ekkn
                              pt_ekpo TYPE tty_ekpo
                              pt_stx  TYPE tty_stx.
  DATA:
        lt_fields TYPE rsz_t_string.

  lt_fields = zcl_utils=>get_itab_fields( pt_ekkn ).
  SELECT (lt_fields)
  INTO TABLE pt_ekkn
  FROM ekkn
  FOR ALL ENTRIES IN pt_lin
    WHERE ebeln = pt_lin-ebeln
      AND ebelp = pt_lin-ebelp. "nitemped(5).

  CHECK sy-subrc IS INITIAL.

  lt_fields = zcl_utils=>get_itab_fields( pt_ekpo ).
  SELECT (lt_fields)
  INTO TABLE pt_ekpo
  FROM ekpo
  FOR ALL ENTRIES IN pt_lin
    WHERE ebeln = pt_lin-ebeln
      AND ebelp = pt_lin-ebelp. "nitemped(5).

  SORT pt_ekpo BY ebeln ebelp.

  SORT pt_ekpo BY ebeln ebelp.

  LOOP AT pt_stx ASSIGNING <stx>.

    CHECK <stx>-tax_loc IS INITIAL.

    READ TABLE pt_lin ASSIGNING <lin> WITH KEY docnum = <stx>-docnum
                                               itmnum  = <stx>-itmnum.

    CHECK sy-subrc IS INITIAL.

    READ TABLE pt_ekpo ASSIGNING <ekpo> WITH KEY ebeln = <lin>-ebeln
                                                 ebelp = <lin>-ebelp.

    CHECK sy-subrc IS INITIAL.

    <stx>-tax_loc = <ekpo>-txjcd.

  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECIONA_WITH_ITEM
*&---------------------------------------------------------------------*
FORM seleciona_with_item  USING    VALUE(pt_bsis) TYPE tty_bsis
                          CHANGING pt_witem TYPE tty_witem.

  DATA:
                    lt_fields TYPE rsz_t_string.

*  DELETE pt_bsis WHERE awtyp = 'RMRP'.

  DATA lt_rg_irrf TYPE RANGE OF zari_cod_imposto-categ_iva.


  lt_rg_irrf[] = zcl_utils=>get_range_of_table( im_table = gt_cod_imposto
                                               im_field = 'CATEG_IRRF' ).

  CHECK pt_bsis IS NOT INITIAL.

  lt_fields = zcl_utils=>get_itab_fields( pt_witem ).
  SELECT (lt_fields)
  INTO TABLE pt_witem
  FROM with_item
  FOR ALL ENTRIES IN pt_bsis
    WHERE bukrs = pt_bsis-bukrs
      AND belnr = pt_bsis-belnr
      AND gjahr = pt_bsis-gjahr
      AND witht IN lt_rg_irrf.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECIONA_TXJURT
*&---------------------------------------------------------------------*
FORM seleciona_txjurt  USING    VALUE(pt_stx) TYPE tty_stx
                       CHANGING pt_txjurt TYPE tty_txjurt.
  DATA:
                    lt_fields TYPE rsz_t_string.

  SORT pt_stx BY tax_loc.
  DELETE ADJACENT DUPLICATES FROM pt_stx COMPARING tax_loc.

  lt_fields = zcl_utils=>get_itab_fields( pt_txjurt ).
  SELECT (lt_fields)
  INTO TABLE pt_txjurt
  FROM j_1btxjurt
  FOR ALL ENTRIES IN pt_stx
    WHERE spras = sy-langu
      AND country = 'BR'
      AND taxjurcode = pt_stx-tax_loc.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECIONA_TXJURT_EKPO
*&---------------------------------------------------------------------*
FORM seleciona_txjurt_ekpo  USING    VALUE(pt_ekpo) TYPE tty_ekpo
                       CHANGING pt_txjurt TYPE tty_txjurt.
  DATA:
                    lt_fields TYPE rsz_t_string.

  SORT pt_ekpo BY txjcd.
  DELETE ADJACENT DUPLICATES FROM pt_ekpo COMPARING txjcd.

  lt_fields = zcl_utils=>get_itab_fields( pt_txjurt ).
  SELECT (lt_fields)
  INTO TABLE pt_txjurt
  FROM j_1btxjurt
  FOR ALL ENTRIES IN pt_ekpo
    WHERE spras = sy-langu
      AND country = 'BR'
      AND taxjurcode = pt_ekpo-txjcd.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECIONA_LIN_doc
*&---------------------------------------------------------------------*
FORM seleciona_lin_doc  USING    VALUE(pt_doc) TYPE tty_doc
                        CHANGING pt_lin TYPE tty_lin.
  DATA:
    lt_fields TYPE rsz_t_string,
    pt_rseg   TYPE ty_rseg.

  lt_fields = zcl_utils=>get_itab_fields( pt_lin ).
  DELETE lt_fields WHERE table_line = 'EBELN' OR table_line = 'EBELP'.
  SELECT (lt_fields)
  INTO TABLE pt_lin
  FROM j_1bnflin
  FOR ALL ENTRIES IN pt_doc
    WHERE docnum = pt_doc-docnum.
*      AND itmnum = pt_stx-itmnum.

  lt_fields = zcl_utils=>get_itab_fields( gt_rseg ).
  LOOP AT pt_lin ASSIGNING <lin>.

    SELECT SINGLE (lt_fields)
    INTO  pt_rseg
    FROM  rseg
    WHERE belnr = <lin>-refkey(10)
      AND gjahr = <lin>-refkey+10(08)
      AND buzei = <lin>-refitm.

    IF sy-subrc IS INITIAL.

      ASSIGN pt_rseg TO <rseg>.

      <lin>-ebeln = <rseg>-ebeln.
      <lin>-ebelp = <rseg>-ebelp.
    ELSE.
      <lin>-ebeln = <lin>-xped(10).
      <lin>-ebelp = <lin>-nitemped(5).
    ENDIF.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  seleciona_glflext
*&---------------------------------------------------------------------*
FORM seleciona_glflext USING VALUE(pt_cod_imposto_rec) TYPE tty_cod_imposto
pt_compens_rec      TYPE tty_cod_multajuros
CHANGING pt_bsis TYPE tty_bsis
pt_bkpf TYPE tty_bkpf.


  DATA :
    gc_cod_imposto  TYPE ty_cod_imposto,
    gt_glt0         TYPE glt0,
    gt_glt0_sum     TYPE tty_glt0,
    gc_glt0_sum     TYPE ty_glt0,
    gc_bsis         TYPE ty_bsis,
    gc_bkpf         TYPE ty_bkpf,
    gc_data         TYPE ty_data,
    lv_dt_ini       TYPE datum,
    lv_dt_fim       TYPE datum,
    c_buzei         TYPE bseg-buzei,  "MFS 11/04
    saldo_acumulado TYPE zari_cod_imposto-irrf,
    lactive_comp    TYPE zari_cod_imposto-irrf.



  DATA: summe LIKE bapi1028_3-balance.

  CLEAR: summe,lactive_comp.
  DATA it_glt0 TYPE fagl_t_glt0.

  LOOP AT gt_data INTO gc_data.
    lv_dt_ini = gc_data-low.
    lv_dt_fim = gc_data-high.
    EXIT.
  ENDLOOP.

  LOOP AT pt_cod_imposto_rec INTO gc_cod_imposto.

    READ TABLE pt_compens_rec ASSIGNING <cod_multa> WITH KEY cod_correcao = gc_cod_imposto-cod_compens_rec.

    IF sy-subrc IS INITIAL.

      IF <cod_multa>-periodicidade = '4'.    " saldo acumulado de imposto a recuperar
        saldo_acumulado = 'X'.
      ELSEIF <cod_multa>-periodicidade = '2'." Saldo no mes de apuração.
        saldo_acumulado = 'M'.
      ELSE.                                  " saldo exercio de imposto a recuperar
        saldo_acumulado = 'A'.
      ENDIF.

      CALL FUNCTION 'FAGL_GET_GLT0'
        EXPORTING
          i_glt0_rldnr = '00'
          i_rrcty      = '0'
          i_rvers      = '001'
          i_bukrs      = s_bukrs-low
          i_ryear      = lv_dt_fim(4)
          i_racct      = gc_cod_imposto-conta_contabil
          i_rpmax      = '016'
        IMPORTING
          et_glt0      = it_glt0.

      SORT it_glt0 BY bukrs ryear racct rbusa.

      CLEAR :  c_buzei, summe.
      c_buzei = '001'.

      LOOP AT it_glt0 INTO gt_glt0.

        AT NEW rbusa.
          IF gc_cod_imposto-periodo_apuracao = '5' AND summe NE 0.
            c_buzei = c_buzei + 1.
          ENDIF.
          CLEAR : summe.
        ENDAT.

        PERFORM glt0_summ_hw USING gt_glt0
                                   saldo_acumulado
                                   lv_dt_ini
                          CHANGING summe.

        AT END OF rbusa.

*           _set_intervalo_mensal lv_dt_ini lv_dt_fim 0 .

*         verificando se já ocorreu a compensação manual para empresa+divisão+exercico+periodo+conta
          READ TABLE gt_comp_manual TRANSPORTING NO FIELDS WITH KEY bukrs = gt_glt0-bukrs
          gsber = gt_glt0-rbusa
          gjahr = gt_glt0-ryear
          monat = lv_dt_fim+4(02)
          hkont = gt_glt0-racct.

          IF sy-subrc IS NOT INITIAL.         " somente deverá seguir se não encontrar registro de compensação manual

            lactive_comp = 'X'.

            IF summe > 0.        " gravar somente registros com saldo >0

              gc_bsis-bukrs = gt_glt0-bukrs.
              gc_bsis-hkont = gt_glt0-racct.
              gc_bsis-gjahr = gt_glt0-ryear.
              gc_bsis-belnr = '9999999999'.
              gc_bsis-buzei = c_buzei.       "'001'.
              gc_bsis-budat = lv_dt_fim.
              gc_bsis-bldat = lv_dt_fim.
              gc_bsis-waers = 'BRL'.
              gc_bsis-monat = lv_dt_fim+4(02).
              gc_bsis-bschl = ''.
              gc_bsis-gsber = gt_glt0-rbusa.
              gc_bsis-shkzg = 'S'.
              gc_bsis-dmbtr = summe.
              gc_bsis-valut = lv_dt_fim.
              APPEND gc_bsis TO pt_bsis.

            ENDIF.

          ELSE.
            lactive_comp = ' '.
          ENDIF.

        ENDAT.

        AT END OF bukrs.
          IF lactive_comp IS NOT INITIAL.  " grava somente registro de a recuperar se não ocorreu comp. manual.
            gc_bkpf-bukrs = gt_glt0-bukrs.
            gc_bkpf-belnr = '9999999999'.
            gc_bkpf-gjahr = lv_dt_fim(04).
            gc_bkpf-cpudt = lv_dt_fim.
* MFS 06/04/2016
            gc_bkpf-budat = lv_dt_fim.
* MFS 06/04/2016
            gc_bkpf-tcode = 'FS10N'.
            gc_bkpf-awtyp = 'GLT0'.
            APPEND gc_bkpf TO pt_bkpf.
            c_buzei = '001'.
          ENDIF.

        ENDAT.

      ENDLOOP.

      IF sy-subrc NE 0.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM GLT0_SUMM_HW                                             *
*---------------------------------------------------------------------*
*       Die Verkehrszahlen der GLT0-Einträge werden                   *
*       in Hauswährung = Buchungskreiswährung kummuliert              *
*---------------------------------------------------------------------*
*  -->  GLT0   : aktueller GLT0 Satz                                  *
*  -->  SUMME                                                         *
*---------------------------------------------------------------------*
FORM glt0_summ_hw USING VALUE(glt0)        LIKE glt0
                        saldo_acum  LIKE zari_cod_imposto-irrf
                        plv_dt_fim  LIKE bsis-bldat
               CHANGING summe       LIKE bapi1028_3-balance.

  DATA: glt0vary LIKE glt0-hsl01,
        w_monat  LIKE bkpf-monat,
        w_field  TYPE name_komp.

  FIELD-SYMBOLS: <field> TYPE any.

  IF saldo_acum = 'X'.
    summe = summe + glt0-hslvt.
  ENDIF.

  IF saldo_acum = 'M'.
    w_monat = plv_dt_fim+4(2).
    CONCATENATE 'HSL' w_monat INTO w_field.
    ASSIGN COMPONENT w_field OF STRUCTURE glt0 TO <field>.
    IF sy-subrc <> 0.
      RAISE no_field.
    ENDIF.
    summe = <field>.
  ELSE.
    DO 16 TIMES VARYING glt0vary FROM glt0-hsl01 NEXT glt0-hsl02.
      summe = summe + glt0vary.
    ENDDO.
  ENDIF.
ENDFORM.                    "GLT0_SUMM_HW

*---------------------------------------------------------------------*
*       FORM seleciona_multajuros                                             *
*---------------------------------------------------------------------*
FORM seleciona_multajuros USING VALUE(pt_cod_imposto) TYPE  tty_cod_imposto
CHANGING pt_cod_multajuros TYPE tty_cod_multajuros.

  DATA:
    lt_fields TYPE rsz_t_string,
    gt_juros  TYPE tty_cod_multajuros,
    gc_juros  TYPE ty_cod_multajuros,
    gt_multa  TYPE tty_cod_multajuros,
    gc_multa  TYPE ty_cod_multajuros.

  lt_fields = zcl_utils=>get_itab_fields( gt_cod_multajuros ).

* seleciona código de juros
  SELECT (lt_fields)
  INTO TABLE gt_juros
  FROM zari_juros_multa
  FOR ALL ENTRIES IN pt_cod_imposto
  WHERE cod_correcao = pt_cod_imposto-cod_correcao_juros.

* seleciona código de multa
  SELECT (lt_fields)
  INTO TABLE gt_multa
  FROM zari_juros_multa
  FOR ALL ENTRIES IN pt_cod_imposto
  WHERE cod_correcao = pt_cod_imposto-cod_correcao_multa.

  APPEND LINES OF gt_juros TO pt_cod_multajuros.
  APPEND LINES OF gt_multa TO pt_cod_multajuros.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM seleciona_comp_rec                                             *
*---------------------------------------------------------------------*
FORM seleciona_comp_rec   USING VALUE(pt_cod_imposto) TYPE  tty_cod_imposto
CHANGING pt_cod_multajuros TYPE tty_cod_multajuros.

  DATA:
    lt_fields TYPE rsz_t_string,
    gt_juros  TYPE tty_cod_multajuros.

  lt_fields = zcl_utils=>get_itab_fields( gt_cod_multajuros ).

* seleciona código de compensação imposto a recuperar
  SELECT (lt_fields)
  INTO TABLE pt_cod_multajuros
  FROM zari_juros_multa
  FOR ALL ENTRIES IN pt_cod_imposto
  WHERE cod_correcao = pt_cod_imposto-cod_compens_rec.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM processa_compensacao_imposto_recuperar                   *
*---------------------------------------------------------------------*
FORM processa_comp_imposto_rec.

  DATA :
    gc_cod_imposto_rec TYPE ty_cod_imposto,
    ls_base_calculo    TYPE zari_bkpf-montante_apurado,
    ls_limite_comp     TYPE zari_bkpf-montante_apurado,
    gt_hd_rec          TYPE tty_header,
    gc_it_rec          TYPE zari_bseg,
    lv_index           TYPE sy-index. "MFS 11/04/2016


  FIELD-SYMBOLS:
    <hd_rec>    TYPE zari_bkpf,
    <hd_rec_ax> TYPE zari_bkpf, "MFS 11/04/2016
    <it_rec>    TYPE zari_bseg,
    <hd_pag>    TYPE zari_bkpf,
    <it_pag>    TYPE zari_bseg.


  LOOP AT gt_cod_imposto_rec INTO gc_cod_imposto_rec.

    MOVE-CORRESPONDING gt_header TO gt_hd_rec.

    LOOP AT gt_hd_rec ASSIGNING <hd_rec> WHERE categ_imposto  = gc_cod_imposto_rec-categ_imposto
    AND tipo_imposto   = gc_cod_imposto_rec-tipo_imposto
    AND codigo_imposto = gc_cod_imposto_rec-codigo_imposto.


      READ TABLE gt_item ASSIGNING <it_rec> WITH KEY categ_imposto  = <hd_rec>-categ_imposto
      tipo_imposto   = <hd_rec>-tipo_imposto
      codigo_imposto = <hd_rec>-codigo_imposto
      empresa        = <hd_rec>-empresa
      divisao        = <hd_rec>-divisao
      filial         = <hd_rec>-filial
      nome_periodo   = <hd_rec>-nome_periodo
      cod_fornecedor = <hd_rec>-cod_fornecedor.
      CHECK sy-subrc IS INITIAL.

*   localizando o valor calculado para o imposto a pagar.

      READ TABLE gt_cod_imposto ASSIGNING <cod_imposto> WITH KEY cod_imposto_rec = gc_cod_imposto_rec-codigo_imposto.

      CHECK sy-subrc IS INITIAL.

      READ TABLE gt_header ASSIGNING <hd_pag> WITH KEY categ_imposto  = <cod_imposto>-categ_imposto
      tipo_imposto   = <cod_imposto>-tipo_imposto
      codigo_imposto = <cod_imposto>-codigo_imposto
      empresa        = <hd_rec>-empresa
      divisao        = <hd_rec>-divisao
      filial         = <hd_rec>-filial
      nome_periodo   = <hd_rec>-nome_periodo.

      CHECK sy-subrc IS INITIAL.

*   localiza as regras de compensação

      READ TABLE gt_comp_rec ASSIGNING <cod_multa> WITH KEY cod_correcao = gc_cod_imposto_rec-cod_compens_rec.

      CHECK sy-subrc IS INITIAL AND <cod_multa>-tipo = '3'.

      IF <cod_multa>-base_calculo = '1' AND <cod_multa>-limite_correcao = '1'.      " valor do tributo a recuperar e  % do valor do tributo a pagar Limite
        ls_base_calculo = <hd_pag>-montante_apurado.
        ls_limite_comp  = ( <hd_rec>-montante_apurado * ( <cod_multa>-perc_limite_correcao * 100 ) ) * ( -1 ).
      ELSEIF <cod_multa>-base_calculo = '1' AND <cod_multa>-limite_correcao = '3'.  " valor do tributo a recuperar e valor do tributo a pagar são o limite
        ls_base_calculo = <hd_pag>-montante_apurado.
        ls_limite_comp  = <hd_rec>-montante_apurado * ( -1 ).
      ELSEIF <cod_multa>-base_calculo = '2' AND <cod_multa>-limite_correcao = '1'.  " % do valor tributo a recuperar e  % do valor do tributo a pagar Limite
        ls_base_calculo = <hd_pag>-montante_apurado * ( <cod_multa>-perc_fixo_correcao * 100 ).
        ls_limite_comp  = ( <hd_rec>-montante_apurado * ( <cod_multa>-perc_limite_correcao * 100 ) ) * ( -1 ).
      ELSEIF <cod_multa>-base_calculo = '2' AND <cod_multa>-limite_correcao = '3'.  " % do valor tributo a recuperar e valor do tributo a pagar é o limite
        ls_base_calculo = <hd_pag>-montante_apurado * ( <cod_multa>-perc_fixo_correcao * 100 ).
        ls_limite_comp  = <hd_rec>-montante_apurado * ( -1 ).
      ELSE.                                                                         " valor do tributo a recuperar e valor do tributo a pagar é o limite
        ls_base_calculo = <hd_pag>-montante_apurado.
        ls_limite_comp  = <hd_rec>-montante_apurado * ( -1 ).
      ENDIF.

      IF ls_base_calculo < ls_limite_comp.       " até o limite do imposto a pagar
        ls_limite_comp = ls_base_calculo.
      ENDIF.

*     criar registro de Item apuração para o valor do impostos a recuperar - ls_limite_comp
      MOVE-CORRESPONDING <it_rec> TO gc_it_rec.
      CONCATENATE 'COMP-' gc_cod_imposto_rec-codigo_imposto INTO gc_it_rec-numero_pedido.
      gc_it_rec-conta_contabil = <cod_imposto>-conta_contabil.
      gc_it_rec-codigo_imposto = <cod_imposto>-codigo_imposto.
      gc_it_rec-item_lancamento = '999'.
      gc_it_rec-montante       = ls_limite_comp * ( -1 ).
      gc_it_rec-ordem_interna  = gc_cod_imposto_rec-conta_contabil.
      APPEND gc_it_rec TO gt_item.

      MOVE-CORRESPONDING <it_rec> TO gc_it_rec.
      CONCATENATE 'COMP-' gc_cod_imposto_rec-codigo_imposto INTO gc_it_rec-numero_pedido.
      gc_it_rec-item_lancamento = '999'.
      gc_it_rec-montante       = ls_limite_comp * - 1.
      gc_it_rec-ordem_interna  = <cod_imposto>-conta_contabil.
      APPEND gc_it_rec TO gt_item.



*     Atualizar o registgro de apuração Header com novo saldo.
      <hd_pag>-montante_apurado = ls_base_calculo - ls_limite_comp.    " até o limite do imposto a pagar

*     Atualizar registros do Imposto a recuperar com os valores que participarão da compensação.

      READ TABLE gt_header ASSIGNING <hd_rec_ax> WITH KEY     categ_imposto  = <cod_imposto>-categ_imposto
      tipo_imposto   = <cod_imposto>-tipo_imposto
      codigo_imposto = <hd_rec>-codigo_imposto
      empresa        = <hd_rec>-empresa
      divisao        = <hd_rec>-divisao
      filial         = <hd_rec>-filial
      nome_periodo   = <hd_rec>-nome_periodo.

      IF sy-subrc IS INITIAL.
        <hd_rec_ax>-montante_apurado = ls_limite_comp * - 1.
      ENDIF.

*      <it_rec>-montante = ls_limite_comp.

      DELETE gt_item WHERE categ_imposto  = <hd_rec>-categ_imposto
                       AND tipo_imposto   = <hd_rec>-tipo_imposto
                       AND codigo_imposto = <hd_rec>-codigo_imposto
                       AND empresa        = <hd_rec>-empresa
                       AND divisao        = <hd_rec>-divisao
                       AND filial         = <hd_rec>-filial
                       AND nome_periodo   = <hd_rec>-nome_periodo
                       AND cod_fornecedor = <hd_rec>-cod_fornecedor
                       AND item_lancamento NE '999'.  ENDLOOP.
    ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PREENCHE_S_CPUDT
*&---------------------------------------------------------------------*
* Preenche o filtro de DATA, se necessário
*----------------------------------------------------------------------*
FORM preenche_s_cpudt  USING    pr_gjahr LIKE s_gjahr[]
                                pr_monat LIKE s_monat[]
                       CHANGING pr_cpudt LIKE s_cpudt[].

  FIELD-SYMBOLS: <gjahr> LIKE LINE OF pr_gjahr,
                 <monat> LIKE LINE OF pr_monat,
                 <cpudt> LIKE LINE OF pr_cpudt.

* Só prossegue se o filtro não foi informado
  CHECK pr_cpudt[] IS INITIAL.

  LOOP AT pr_gjahr ASSIGNING <gjahr>.
    LOOP AT pr_monat ASSIGNING <monat>.
      APPEND INITIAL LINE TO pr_cpudt ASSIGNING <cpudt>.
      <cpudt>-sign   = 'I'.
      <cpudt>-option = 'BT'.
      CONCATENATE <gjahr>-low
                  <monat>-low
                  '01'
             INTO <cpudt>-low.
      CALL FUNCTION 'LAST_DAY_OF_MONTHS'
        EXPORTING
          day_in            = <cpudt>-low
        IMPORTING
          last_day_of_month = <cpudt>-high.
*       EXCEPTIONS
*         DAY_IN_NO_DATE          = 1
*         OTHERS                  = 2.

    ENDLOOP.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  VALIDA_PERIODO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LV_NUM  text
*----------------------------------------------------------------------*
FORM valida_periodo  CHANGING p_lv_num.

  IF     p_lv_num <= '01'.
    p_lv_num = '01'.
  ELSEIF p_lv_num <= '02'.
    p_lv_num = '02'.
  ELSEIF p_lv_num <= '03'.
    p_lv_num = '03'.
  ELSEIF p_lv_num <= '04'.
    p_lv_num = '04'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  INSERIR_CPUDT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_PT_DATA    text
*      <--P_L_SYSUBRC  text
*----------------------------------------------------------------------*
FORM inserir_cpudt  USING    p_dtini        TYPE sy-datum
                             p_dtfim        TYPE sy-datum
                             pt_cod_imposto TYPE ty_cod_imposto
                    CHANGING p_pt_data      LIKE s_cpudt[]
                             p_pt_gjahr     LIKE s_gjahr[]
                             p_l_sysubrc    TYPE sy-subrc.

  DATA : c_dias_vecto TYPE zari_cod_imposto-dia_vencimento.

  FIELD-SYMBOLS: <cpudt> LIKE LINE OF p_pt_data,
                 <gjahr> LIKE LINE OF p_pt_gjahr.

* verificar se o processamento esta dentro do período de apuração ou será retroativo
  IF sy-datum(6) - p_dtfim(6) = 1.
* verifica se a data de execução esta enquadrada na data minima para execução.
    CASE pt_cod_imposto-definicao_regra.
      WHEN '1'. " dia Fixo
        IF pt_cod_imposto-dias_apuracao <= sy-datum+6(2).
          p_l_sysubrc = 0.
        ELSE.
          p_l_sysubrc = 4.
        ENDIF.

      WHEN '2'. "quantidade de dias antes do vencimento.
        c_dias_vecto = ( pt_cod_imposto-dia_vencimento - sy-datum+6(2) ).
        IF pt_cod_imposto-dias_apuracao <= c_dias_vecto.
          p_l_sysubrc = 0.
        ELSE.
          p_l_sysubrc = 4.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.

  ELSEIF sy-datum(6) - p_dtfim(6) < 1. .   " Tentativa execução fora período de apuração válido
    p_l_sysubrc = 4.
  ELSEIF sy-datum(6) - p_dtfim(6) > 1. .   " execução retroativa
    p_l_sysubrc = 0.
  ENDIF.

  CHECK p_l_sysubrc IS INITIAL.

  IF p_pt_data[] IS INITIAL.
    APPEND INITIAL LINE TO p_pt_data ASSIGNING <cpudt>.
    <cpudt>-sign   = 'I'.
    <cpudt>-option = 'BT'.
    <cpudt>-low    = p_dtini.
    <cpudt>-high   = p_dtfim.
  ELSE.
*   valida se a data entrada em s_cpudt esta correta
    LOOP AT p_pt_data ASSIGNING <cpudt>.
      IF p_dtini NE <cpudt>-low OR p_dtfim NE <cpudt>-high.
*       Gravar datas corretas do intervalo segundo a configuração da regra
        <cpudt>-low    = p_dtini.
        <cpudt>-high   = p_dtfim.
        MODIFY p_pt_data FROM <cpudt>.
      ENDIF.
    ENDLOOP.
  ENDIF.

  LOOP AT p_pt_data ASSIGNING <cpudt>.


    IF p_pt_gjahr IS NOT INITIAL.
      LOOP AT p_pt_gjahr ASSIGNING <gjahr>.
        <gjahr>-low    = <cpudt>-low(4).
        <gjahr>-high   = <cpudt>-high(4).
        MODIFY p_pt_gjahr FROM <gjahr>.
        CONTINUE.
      ENDLOOP.
    ELSE.
      CLEAR p_pt_gjahr.
      APPEND INITIAL LINE TO p_pt_gjahr ASSIGNING <gjahr>.
      <gjahr>-sign   = 'I'.
      <gjahr>-option = 'BT'.
      <gjahr>-low    = <cpudt>-low(4).
      <gjahr>-high   = <cpudt>-high(4).
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  LOOP_BSIS
*&---------------------------------------------------------------------*
FORM loop_bsis_cod3 USING p_direcao TYPE zari_bseg-direcao
                     ps_cod_imposto TYPE ty_cod_imposto
                     ps_bkpf TYPE ty_bkpf
                     pt_bsis TYPE tty_bsis
                     pt_bsik TYPE tty_bsik
                     pt_bseg TYPE tty_bseg
                     pt_tp_imposto TYPE tty_tipo_imposto
                     pt_doc TYPE tty_doc
                     pt_stx TYPE tty_stx
                     pt_lin TYPE tty_lin
                     pt_ekkn TYPE tty_ekkn
      pt_ekpo TYPE tty_ekpo                 "domicilio no pedido compras
      pt_txjurt TYPE tty_txjurt
      pt_witem TYPE tty_witem
      pt_data  TYPE tty_data
 CHANGING pt_header TYPE tty_header
          pt_item TYPE tty_item
          pt_resumo_imp TYPE tty_resumo_impostos.

  DATA:
    ls_bsis       TYPE ty_bsis,
    ls_bsik       TYPE ty_bsik,
    ls_bseg       TYPE ty_bseg,
    ls_header     TYPE zari_bkpf,
    ls_item       TYPE zari_bseg,
    ls_tp_imposto TYPE ty_tipo_imposto,
    ls_resumo_imp TYPE ty_resumo_impostos,
    lv_week       TYPE scal-week,
    ls_t247       TYPE t247,
    lv_num        TYPE numc1,
    ls_cpudt      TYPE ty_data.

  ls_header-nome_usuario_geracao = sy-uname.
  ls_header-codigo_imposto = ps_cod_imposto-codigo_imposto.
  ls_header-empresa        = ps_bkpf-bukrs.

  LOOP AT pt_data INTO ls_cpudt.
    EXIT.
  ENDLOOP.

  READ TABLE pt_bsis TRANSPORTING NO FIELDS WITH KEY bukrs = ps_bkpf-bukrs
                                     hkont = ps_cod_imposto-conta_contabil
                                     gjahr = ps_bkpf-gjahr
                                     belnr = ps_bkpf-belnr.



  LOOP AT pt_bsis INTO ls_bsis FROM sy-tabix.
    IF ls_bsis-bukrs <> ps_bkpf-bukrs OR ls_bsis-hkont <> ps_cod_imposto-conta_contabil OR
    ls_bsis-gjahr <> ps_bkpf-gjahr OR ls_bsis-belnr <> ps_bkpf-belnr.
      EXIT.
    ENDIF.
* verficando qual o periodo de apuração.
    IF s_gjahr IS INITIAL.
      ls_header-exercicio = ls_cpudt-high(4).  "sy-datum(4).
    ELSE.
      ls_header-exercicio = s_gjahr-low.  "ls_bsis-gjahr.
    ENDIF.
    IF s_monat IS INITIAL.
      ls_header-periodo =  ls_cpudt-high+4(2). "sy-datum+4(2)
    ELSE.
      ls_header-periodo =  s_monat-low.   "ls_bsis-budat+4(2).
    ENDIF.

    CASE ps_cod_imposto-periodo_apuracao.


      WHEN '1'.	" Semanal

        CALL FUNCTION 'DATE_GET_WEEK'
          EXPORTING
            date = ls_bsis-bldat        "budat
          IMPORTING
            week = lv_week.

        CALL FUNCTION 'IDWT_READ_MONTH_TEXT'
          EXPORTING
            langu = sy-langu
            month = ls_bsis-bldat+4(2)  "budat
          IMPORTING
            t247  = ls_t247.

        CONCATENATE 'Sm' lv_week ls_t247-ktx(3) ls_bsis-bldat(4) INTO ls_header-nome_periodo.    "lv_week ls_t247-ktx(3) ls_bsis-budat(4)

      WHEN '2'.	" Mensal
        CALL FUNCTION 'IDWT_READ_MONTH_TEXT'
          EXPORTING
            langu = sy-langu
            month = ls_bsis-bldat+4(2) "budat
          IMPORTING
            t247  = ls_t247.

        CONCATENATE ls_t247-ktx(3) ls_bsis-bldat(4) INTO ls_header-nome_periodo.  "budat

      WHEN '3'.	" Trimestral
        lv_num = trunc( ls_bsis-budat+4(2) DIV 3 ).
        PERFORM valida_periodo CHANGING lv_num.
        CONCATENATE lv_num '°Trim' ls_bsis-bldat(4) INTO ls_header-nome_periodo.  "budat
      WHEN '4'. "	Semestral
        lv_num = trunc( ls_bsis-budat+4(2) DIV 6 ).
        PERFORM valida_periodo CHANGING lv_num.
        CONCATENATE lv_num '°Sem' ls_bsis-bldat(4) INTO ls_header-nome_periodo.   "budat
      WHEN '5'. " Anual
        ls_header-nome_periodo = ls_bsis-bldat(4).  "budat
      WHEN OTHERS. " Fixo
    ENDCASE.

*   tipo de apuração
*    READ TABLE gt_cod_imposto INTO ls_cod_imposto WITH KEY conta_contabil = ls_bsis-hkont.
    CLEAR: ls_header-divisao, ls_header-filial.
    CASE ps_cod_imposto-tipo_apuracao.
      WHEN '1'.	"cnpj filial
* MFS 06/04/2016
        IF ps_cod_imposto-periodo_apuracao NE '5'.  " Regra de apuração Empresa + Divisão. Se for 5 - anual será apurado por Empresa ( IRPJ e CSLL )
          ls_header-divisao = ls_bsis-gsber.
          ls_header-filial = ls_bsis-bupla.
        ENDIF.

        IF ls_bsis-bupla IS INITIAL OR ps_cod_imposto-categ_imposto = '1'.
          _company_read ps_bkpf-bukrs ls_header-cnpj.
        ELSE.
          _branch_read ps_bkpf-bukrs ls_bsis-bupla ls_header-cnpj.
        ENDIF.

      WHEN '2'. " cnpj divisão(concessão)
* MFS 06/04/2016
        IF ps_cod_imposto-periodo_apuracao NE '5'.  " Regra de apuração Empresa + Divisão. Se for 5 - anual será apurado por Empresa ( IRPJ e CSLL )
          ls_header-divisao = ls_bsis-gsber.
        ENDIF.

        IF ls_bsis-bupla IS INITIAL OR ps_cod_imposto-categ_imposto = '1'.
          _company_read ps_bkpf-bukrs ls_header-cnpj.
        ELSE.
          _branch_read ps_bkpf-bukrs ls_bsis-bupla ls_header-cnpj.
        ENDIF.

      WHEN '3'. " cnpj principal
        _company_read ps_bkpf-bukrs ls_header-cnpj.

    ENDCASE.

    ls_item-filial = ls_header-filial.
    ls_item-cod_fornecedor = ls_header-cod_fornecedor.

*< T.1
*    CASE ps_bkpf-awtyp.
*      WHEN 'RMRP'.
*> T.1


*      WHEN OTHERS.
* valida a pesquisa da WITH_ITEM somente par os itens com IR.
    IF ps_cod_imposto-irrf = 'X' OR
       ps_cod_imposto-categ_imposto = '3'.
*> T.1
      READ TABLE pt_witem ASSIGNING <witem> WITH KEY bukrs = ls_bsis-bukrs
                                                     belnr = ls_bsis-belnr
                                                     gjahr = ls_bsis-gjahr
                                        witht = ps_cod_imposto-categ_irrf.
*    IF sy-subrc = 0.
      CHECK sy-subrc IS INITIAL.

*     verificar duplicidade
      READ TABLE pt_item TRANSPORTING NO FIELDS WITH KEY empresa            = ls_bsis-bukrs
      num_doc_contabil   = ls_bsis-belnr
      exercicio_contabil = ls_bsis-gjahr
      item_lancamento    = ls_bsis-buzei.
*                                                         codigo_imposto     = ps_cod_imposto-codigo_imposto.
      CHECK sy-subrc IS NOT INITIAL.
      ls_item-categ_irrf = <witem>-witht.
      ls_item-montante_imposto = <witem>-wt_qbshh.
* MFS - 18.03.2016
      IF ps_cod_imposto-regra_acumulo = '2'.
        ls_header-cod_fornecedor = ls_item-cod_fornecedor = <witem>-wt_acco.  " deverá respeitar a regra de acumulo.
      ELSE.
*       ls_item-cod_fornecedor = <witem>-wt_acco.
      ENDIF.
*    ENDIF.
*< T.1
    ENDIF.
*    ENDCASE.
*> T.1

*   Regra de Acumulo - 1-Periodo ou 2-Período e Prestador
*    CLEAR ls_header-cod_fornecedor.
    IF ps_cod_imposto-regra_acumulo = '2'.  "Período Prestados
      READ TABLE pt_bseg INTO ls_bseg WITH KEY bukrs = ls_bsis-bukrs
                                             belnr = ls_bsis-belnr
                                    gjahr = ls_bsis-gjahr BINARY SEARCH.
      IF sy-subrc = 0 AND ls_header-cod_fornecedor IS INITIAL.
*      READ TABLE pt_bsik INTO ls_bsik WITH KEY bukrs = ls_bsis-bukrs
**                                               augdt = ls_bsis-augdt
**                                               augbl = ls_bsis-augbl
**                                               zuonr = ls_bsis-zuonr
*                                           gjahr = ls_bsis-gjahr
*                                           belnr = ls_bsis-belnr
*                                           buzei = ls_bsis-buzei.
        ls_item-cod_fornecedor = ls_header-cod_fornecedor = ls_bseg-lifnr.

      ENDIF.
    ENDIF.
* MFS - 18.03.2016
*    CONCATENATE 'Pré Apuração' ls_header-empresa ls_header-divisao ls_header-filial ls_header-nome_periodo INTO ls_header-texto.
    CONCATENATE 'Pré Apuração' ls_header-empresa ls_header-divisao ls_header-filial ls_header-nome_periodo ls_header-cod_fornecedor INTO ls_header-texto.

*   Ajustando o sinal do montante para reduzir da apuração do Débitos encontrados - Ajustes ou Compensações
    IF ls_bsis-shkzg = 'S'.
      ls_header-montante_apurado = ls_bsis-dmbtr * -1.

    ELSE.
      ls_header-montante_apurado = ls_bsis-dmbtr.
    ENDIF.
*    IF p_direcao = c_a_recuperar.
*      ls_header-montante_apurado = ls_header-montante_apurado * -1.
*    ENDIF.
*    COLLECT ls_header INTO pt_header.
*
    ls_item-empresa = ls_header-empresa.
    ls_item-exercicio_apuracao = ls_header-exercicio. "ls_bsis-budat(4).
    ls_item-periodo_apuracao =   ls_header-periodo.   "ls_bsis-budat+4(2).
    ls_item-nome_periodo = ls_header-nome_periodo.    "nome do período de apuração
    ls_item-num_doc_contabil = ls_bsis-belnr.
    ls_item-exercicio_contabil = ls_bsis-gjahr.
    ls_item-item_lancamento = ls_bsis-buzei.
    ls_item-conta_contabil = ls_bsis-hkont.
    ls_item-direcao = p_direcao. " A pagar
    ls_item-divisao = ls_header-divisao.

*   Ajustando o sinal do montante para reduzir da apuração do Débitos encontrados - Ajustes ou Compensações
    IF ls_bsis-shkzg = 'S'.
      ls_item-montante = ls_bsis-dmbtr * ( -1 ).
    ELSE.
      ls_item-montante = ls_bsis-dmbtr.
    ENDIF.

    ls_header-moeda = ls_item-moeda = ls_bsis-waers.
    ls_item-data_lancamento = ls_bsis-budat.
    ls_item-data_documento = ls_bsis-bldat.
    ls_item-data_efetiva = ls_bsis-valut.
    ls_item-data_entrada = ps_bkpf-cpudt.

    ls_header-categ_imposto       = ls_item-categ_imposto   = ls_tp_imposto-categ_imposto.
    ls_header-tipo_imposto        = ls_item-tipo_imposto    = ps_cod_imposto-tipo_imposto.
    ls_header-codigo_imposto      = ls_item-codigo_imposto  = ps_cod_imposto-codigo_imposto.


*    READ TABLE pt_tp_imposto INTO ls_tp_imposto WITH KEY tipo_imposto = ps_cod_imposto-tipo_imposto.
*    IF ls_tp_imposto-categ_imposto = '2'.
**LS_ITEM-UF
*    ELSEIF ls_tp_imposto-categ_imposto = '1'.
**LS_ITEM-DOMICILIO_FISCAL
*    ENDIF.

*< T.1
    ls_item-uf            = ps_cod_imposto-uf.
    ls_item-categ_imposto = ps_cod_imposto-categ_imposto.
    IF <lin>-nbm IS ASSIGNED.
      ls_item-nbm           = <lin>-nbm.
    ENDIF.

    ls_header-uf                = ps_cod_imposto-uf.
    ls_header-categ_imposto     = ps_cod_imposto-categ_imposto.
    ls_header-domicilio_fiscal  = ps_cod_imposto-domicilio_fiscal.
*> T.1

    ls_resumo_imp-tipo_imposto    = ps_cod_imposto-tipo_imposto.
    ls_resumo_imp-categ_imposto   = ls_tp_imposto-categ_imposto.
    ls_resumo_imp-dia_vencimento  = ps_cod_imposto-dia_vencimento.
    COLLECT ls_resumo_imp INTO pt_resumo_imp.

    IF ls_bsis-bldat IN pt_data.    "Budat
      ls_header-competencia       = ls_item-competencia     = 'S'.
    ELSE.
      ls_header-competencia       = ls_item-competencia     = 'N'.
* Preparação para apuração individual por fatura para entradas fora da competecia.
*      CONCATENATE 'Pré Apuração' ls_header-empresa ls_header-divisao ls_header-filial ls_header-nome_periodo ls_bsis-belnr ls_bsis-buzei INTO ls_header-texto.
    ENDIF.



    READ TABLE pt_doc ASSIGNING <doc> WITH KEY belnr = ls_bsis-belnr
                                       gjahr = ls_bsis-gjahr
                                       bukrs = ls_bsis-bukrs.
    IF sy-subrc = 0.

*< T.1 - Inserido
      ls_item-doc_fiscal        = <doc>-docnum.
* MFS - 18.03.2016
      IF ps_cod_imposto-tipo_apuracao = '1'.  " Regra de apuração por Filial
        ls_header-filial          = <doc>-branch.
        ls_item-filial            = <doc>-branch.
      ENDIF.

      ls_item-dom_fiscal_forn   = <doc>-txjcd.
      ls_item-tipo_doc_fat      = <doc>-doctyp.
      ls_item-direcao_movimento = <doc>-direct.
      ls_item-nota_fiscal_srv   = <doc>-nfesrv.

      IF <doc>-parvw = 'LF' AND <doc>-partyp = 'V'.
* MFS - 18.03.2016
        IF ps_cod_imposto-regra_acumulo = '2'.
          ls_header-cod_fornecedor = ls_item-cod_fornecedor = <doc>-parid.
        ELSE.
*          ls_item-cod_fornecedor = <doc>-parid.
        ENDIF.
      ENDIF.

      IF <doc>-nfnum IS INITIAL.
        ls_item-nota_fiscal = <doc>-nfenum.
      ELSE.
        ls_item-nota_fiscal = <doc>-nfnum.
      ENDIF.

      READ TABLE pt_lin ASSIGNING <lin> WITH KEY docnum = <doc>-docnum.
      IF sy-subrc = 0.
        ls_item-numero_pedido   = <lin>-ebeln.
        ls_item-item_pedido     = <lin>-ebelp.
        ls_item-id_imposto      = <lin>-taxlw3.
        ls_item-item_doc_fiscal = <lin>-itmnum.

        READ TABLE pt_ekkn ASSIGNING <ekkn> WITH KEY ebeln = <lin>-ebeln
                                      ebelp = <lin>-ebelp BINARY SEARCH.
        IF sy-subrc = 0.
          ls_item-ordem_interna = <ekkn>-aufnr.
          ls_item-centro_custo  = <ekkn>-kostl.
          ls_item-centro_lucro  = <ekkn>-prctr.
          ls_item-elemento_pep  = <ekkn>-ps_psp_pnr.

        ENDIF.
      ENDIF.
*> T.1

      READ TABLE pt_stx ASSIGNING <stx> WITH KEY docnum = <doc>-docnum
                                      taxtyp = ps_cod_imposto-categ_iva.
      IF sy-subrc = 0.

*< T.1
*     Validar UF caso seja imposto estadual
        IF ps_cod_imposto-categ_imposto EQ '2'.
          IF ps_cod_imposto-uf NE <stx>-tax_loc(2).
            CONTINUE.
          ENDIF.
        ENDIF.
*> T.1

*< T.1
*     Validar Domicilio fiscal caso seja imposto municipal
        IF ps_cod_imposto-categ_imposto EQ '3'.
          IF ps_cod_imposto-domicilio_fiscal NE <stx>-tax_loc.
            CONTINUE.
          ENDIF.
        ENDIF.
*> T.1

        ls_item-categ_iva = <stx>-taxtyp.
        ls_item-montante_imposto = <stx>-taxval.
        ls_item-domicilio_fiscal = ls_item-dom_fiscal_srv = <stx>-tax_loc.
        ls_item-grupo_imposto = <stx>-taxgrp.

        READ TABLE pt_txjurt ASSIGNING <txjurt> WITH KEY taxjurcode = <stx>-tax_loc BINARY SEARCH.
        IF sy-subrc = 0.
          ls_item-cidade = <txjurt>-text.
        ENDIF.

      ELSE.                         "quando exite NF e não é IVA, sem categoria de Imposto na NF.
*        Continue.
        READ TABLE pt_ekpo ASSIGNING <ekpo> WITH KEY ebeln = <lin>-ebeln
                                      ebelp = <lin>-ebelp BINARY SEARCH.

        IF sy-subrc IS INITIAL.

*       Validar UF caso seja imposto estadual
          IF ps_cod_imposto-categ_imposto EQ '2'.
            IF ps_cod_imposto-uf NE <ekpo>-txjcd(2).
              CONTINUE.
            ENDIF.
          ENDIF.
*  > T.1

*  < T.1
*       Validar Domicilio fiscal caso seja imposto municipal
          IF ps_cod_imposto-categ_imposto EQ '3'.
            IF ps_cod_imposto-domicilio_fiscal NE <ekpo>-txjcd.
              CONTINUE.
            ENDIF.
          ENDIF.
*  > T.1

          ls_item-domicilio_fiscal = ls_item-dom_fiscal_srv = <ekpo>-txjcd.

          READ TABLE pt_txjurt ASSIGNING <txjurt> WITH KEY taxjurcode = <ekpo>-txjcd BINARY SEARCH.
          IF sy-subrc = 0.
            ls_item-cidade = <txjurt>-text.
          ENDIF.
        ENDIF.
      ENDIF. " J_1BNFSTX

      READ TABLE pt_doc ASSIGNING <doc> WITH KEY belnr = ls_bsis-belnr
                                                 gjahr = ls_bsis-gjahr
                                                 bukrs = ls_bsis-bukrs.
      IF sy-subrc = 0.
        LOOP AT pt_stx ASSIGNING <stx>
          WHERE docnum = <doc>-docnum.

          MOVE <stx>-taxval  TO ls_item-montante.
          MOVE <stx>-tax_loc TO ls_item-domicilio_fiscal.

          MOVE <stx>-taxval  TO ls_header-montante_apurado.
          MOVE <stx>-tax_loc TO ls_header-domicilio_fiscal.

          COLLECT ls_header INTO pt_header.
          APPEND ls_item TO pt_item.
        ENDLOOP.
      ENDIF.
    ENDIF. " J_1BNFDOC

    CLEAR: ls_resumo_imp, ls_item.
  ENDLOOP.

ENDFORM.

*** Início - 30/09/2018 - Implementação de Authority-Check Projeto AGIR
*---------------------------------------------------------------------*
*      Form  f_authority_check
*---------------------------------------------------------------------*
FORM f_authority_check TABLES pt_dados    TYPE tty_empresa
                       USING  p_atividade TYPE zag_campo.

*** Constantes
  CONSTANTS:
    lc_f_bkpf_buk TYPE xuobject  VALUE 'F_BKPF_BUK',
    lc_x          TYPE char1     VALUE 'X'.

*** Variáveis
  DATA:
    lv_erro     TYPE char1,
    lv_objeto   TYPE xuobject,
    lv_campo1   TYPE zag_campo,
    lv_campo2   TYPE zag_campo,
    lv_mensagem TYPE string.

*** Estruturas
  DATA ls_dados  TYPE ty_empresa.

*** Tabelas internas
  DATA lt_dados TYPE tty_empresa.

  CLEAR lv_erro.
  lt_dados[] = pt_dados[].
  SORT lt_dados BY empresa.
  DELETE ADJACENT DUPLICATES FROM lt_dados COMPARING empresa.

*** Verifica autorização para cada empresa
  LOOP AT lt_dados INTO ls_dados.

*** Preenche variáveis
    lv_objeto = lc_f_bkpf_buk.
    lv_campo1 = ls_dados-empresa.
    lv_campo2 = p_atividade.

*** Executa função padrão para verificação de autorizações
    CALL FUNCTION 'ZAG_F_AUTHORITY'
      EXPORTING
        i_tcode    = sy-tcode
        i_xuobject = lv_objeto
        i_campo1   = lv_campo1
        i_campo2   = lv_campo2
      IMPORTING
        e_mensagem = lv_mensagem.

*** Caso o usuário não tenha autorização, exibe mensagem e interrompe o processamento
    IF lv_mensagem IS NOT INITIAL.
      MESSAGE i000(zfi0) WITH lv_mensagem.
      lv_erro = lc_x.
      EXIT.
    ENDIF.

  ENDLOOP.

  IF lv_erro IS NOT INITIAL.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.
*** Fim    - 30/09/2018 - Implementação de Authority-Check Projeto AGIR
