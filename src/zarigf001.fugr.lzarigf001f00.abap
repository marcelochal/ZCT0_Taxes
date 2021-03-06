*---------------------------------------------------------------------*
*    view related FORM routines
*   generation date: 30.08.2018 at 13:50:22
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZARIV_COD_IMP...................................*
FORM GET_DATA_ZARIV_COD_IMP.
  PERFORM VIM_FILL_WHERETAB.
*.read data from database.............................................*
  REFRESH TOTAL.
  CLEAR   TOTAL.
  SELECT * FROM ZARI_COD_IMPOSTO WHERE
(VIM_WHERETAB) .
    CLEAR ZARIV_COD_IMP .
ZARIV_COD_IMP-MANDT =
ZARI_COD_IMPOSTO-MANDT .
ZARIV_COD_IMP-CODIGO_IMPOSTO =
ZARI_COD_IMPOSTO-CODIGO_IMPOSTO .
ZARIV_COD_IMP-TIPO_IMPOSTO =
ZARI_COD_IMPOSTO-TIPO_IMPOSTO .
ZARIV_COD_IMP-DESCRICAO_IMPOSTO =
ZARI_COD_IMPOSTO-DESCRICAO_IMPOSTO .
ZARIV_COD_IMP-COD_IMPOSTO_GUIA =
ZARI_COD_IMPOSTO-COD_IMPOSTO_GUIA .
ZARIV_COD_IMP-CONTA_CONTABIL =
ZARI_COD_IMPOSTO-CONTA_CONTABIL .
ZARIV_COD_IMP-DIRECAO =
ZARI_COD_IMPOSTO-DIRECAO .
ZARIV_COD_IMP-PERIODO_APURACAO =
ZARI_COD_IMPOSTO-PERIODO_APURACAO .
ZARIV_COD_IMP-UF =
ZARI_COD_IMPOSTO-UF .
ZARIV_COD_IMP-DOMICILIO_FISCAL =
ZARI_COD_IMPOSTO-DOMICILIO_FISCAL .
ZARIV_COD_IMP-TIPO_GUIA =
ZARI_COD_IMPOSTO-TIPO_GUIA .
ZARIV_COD_IMP-DIA_VENCIMENTO =
ZARI_COD_IMPOSTO-DIA_VENCIMENTO .
ZARIV_COD_IMP-DEFINICAO_REGRA =
ZARI_COD_IMPOSTO-DEFINICAO_REGRA .
ZARIV_COD_IMP-DIAS_APURACAO =
ZARI_COD_IMPOSTO-DIAS_APURACAO .
ZARIV_COD_IMP-TIPO_APURACAO =
ZARI_COD_IMPOSTO-TIPO_APURACAO .
ZARIV_COD_IMP-REGRA_ACUMULO =
ZARI_COD_IMPOSTO-REGRA_ACUMULO .
ZARIV_COD_IMP-COD_FORNECEDOR =
ZARI_COD_IMPOSTO-COD_FORNECEDOR .
ZARIV_COD_IMP-COD_IMPOSTO_REC =
ZARI_COD_IMPOSTO-COD_IMPOSTO_REC .
ZARIV_COD_IMP-COD_COMPENS_REC =
ZARI_COD_IMPOSTO-COD_COMPENS_REC .
ZARIV_COD_IMP-COD_CORRECAO_MULTA =
ZARI_COD_IMPOSTO-COD_CORRECAO_MULTA .
ZARIV_COD_IMP-COD_CORRECAO_JUROS =
ZARI_COD_IMPOSTO-COD_CORRECAO_JUROS .
ZARIV_COD_IMP-IRRF =
ZARI_COD_IMPOSTO-IRRF .
ZARIV_COD_IMP-CATEG_IRRF =
ZARI_COD_IMPOSTO-CATEG_IRRF .
ZARIV_COD_IMP-CATEG_IVA =
ZARI_COD_IMPOSTO-CATEG_IVA .
    SELECT SINGLE * FROM ZARI_TP_IMPOSTO WHERE
TIPO_IMPOSTO = ZARI_COD_IMPOSTO-TIPO_IMPOSTO .
    IF SY-SUBRC EQ 0.
ZARIV_COD_IMP-CATEG_IMPOSTO =
ZARI_TP_IMPOSTO-CATEG_IMPOSTO .
    ENDIF.
<VIM_TOTAL_STRUC> = ZARIV_COD_IMP.
    APPEND TOTAL.
  ENDSELECT.
  SORT TOTAL BY <VIM_XTOTAL_KEY>.
  <STATUS>-ALR_SORTED = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF X_HEADER-SELECTION NE SPACE.
    PERFORM CHECK_DYNAMIC_SELECT_OPTIONS.
  ELSEIF X_HEADER-DELMDTFLAG NE SPACE.
    PERFORM BUILD_MAINKEY_TAB.
  ENDIF.
  REFRESH EXTRACT.
ENDFORM.
*---------------------------------------------------------------------*
FORM DB_UPD_ZARIV_COD_IMP .
*.process data base updates/inserts/deletes.........................*
LOOP AT TOTAL.
  CHECK <ACTION> NE ORIGINAL.
MOVE <VIM_TOTAL_STRUC> TO ZARIV_COD_IMP.
  IF <ACTION> = UPDATE_GELOESCHT.
    <ACTION> = GELOESCHT.
  ENDIF.
  CASE <ACTION>.
   WHEN NEUER_GELOESCHT.
IF STATUS_ZARIV_COD_IMP-ST_DELETE EQ GELOESCHT.
     READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
     IF SY-SUBRC EQ 0.
       DELETE EXTRACT INDEX SY-TABIX.
     ENDIF.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN GELOESCHT.
  SELECT SINGLE FOR UPDATE * FROM ZARI_COD_IMPOSTO WHERE
  CODIGO_IMPOSTO = ZARIV_COD_IMP-CODIGO_IMPOSTO .
    IF SY-SUBRC = 0.
    DELETE ZARI_COD_IMPOSTO .
    ENDIF.
    IF STATUS-DELETE EQ GELOESCHT.
      READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY> BINARY SEARCH.
      DELETE EXTRACT INDEX SY-TABIX.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN OTHERS.
  SELECT SINGLE FOR UPDATE * FROM ZARI_COD_IMPOSTO WHERE
  CODIGO_IMPOSTO = ZARIV_COD_IMP-CODIGO_IMPOSTO .
    IF SY-SUBRC <> 0.   "insert preprocessing: init WA
      CLEAR ZARI_COD_IMPOSTO.
    ENDIF.
ZARI_COD_IMPOSTO-MANDT =
ZARIV_COD_IMP-MANDT .
ZARI_COD_IMPOSTO-CODIGO_IMPOSTO =
ZARIV_COD_IMP-CODIGO_IMPOSTO .
ZARI_COD_IMPOSTO-TIPO_IMPOSTO =
ZARIV_COD_IMP-TIPO_IMPOSTO .
ZARI_COD_IMPOSTO-DESCRICAO_IMPOSTO =
ZARIV_COD_IMP-DESCRICAO_IMPOSTO .
ZARI_COD_IMPOSTO-COD_IMPOSTO_GUIA =
ZARIV_COD_IMP-COD_IMPOSTO_GUIA .
ZARI_COD_IMPOSTO-CONTA_CONTABIL =
ZARIV_COD_IMP-CONTA_CONTABIL .
ZARI_COD_IMPOSTO-DIRECAO =
ZARIV_COD_IMP-DIRECAO .
ZARI_COD_IMPOSTO-PERIODO_APURACAO =
ZARIV_COD_IMP-PERIODO_APURACAO .
ZARI_COD_IMPOSTO-UF =
ZARIV_COD_IMP-UF .
ZARI_COD_IMPOSTO-DOMICILIO_FISCAL =
ZARIV_COD_IMP-DOMICILIO_FISCAL .
ZARI_COD_IMPOSTO-TIPO_GUIA =
ZARIV_COD_IMP-TIPO_GUIA .
ZARI_COD_IMPOSTO-DIA_VENCIMENTO =
ZARIV_COD_IMP-DIA_VENCIMENTO .
ZARI_COD_IMPOSTO-DEFINICAO_REGRA =
ZARIV_COD_IMP-DEFINICAO_REGRA .
ZARI_COD_IMPOSTO-DIAS_APURACAO =
ZARIV_COD_IMP-DIAS_APURACAO .
ZARI_COD_IMPOSTO-TIPO_APURACAO =
ZARIV_COD_IMP-TIPO_APURACAO .
ZARI_COD_IMPOSTO-REGRA_ACUMULO =
ZARIV_COD_IMP-REGRA_ACUMULO .
ZARI_COD_IMPOSTO-COD_FORNECEDOR =
ZARIV_COD_IMP-COD_FORNECEDOR .
ZARI_COD_IMPOSTO-COD_IMPOSTO_REC =
ZARIV_COD_IMP-COD_IMPOSTO_REC .
ZARI_COD_IMPOSTO-COD_COMPENS_REC =
ZARIV_COD_IMP-COD_COMPENS_REC .
ZARI_COD_IMPOSTO-COD_CORRECAO_MULTA =
ZARIV_COD_IMP-COD_CORRECAO_MULTA .
ZARI_COD_IMPOSTO-COD_CORRECAO_JUROS =
ZARIV_COD_IMP-COD_CORRECAO_JUROS .
ZARI_COD_IMPOSTO-IRRF =
ZARIV_COD_IMP-IRRF .
ZARI_COD_IMPOSTO-CATEG_IRRF =
ZARIV_COD_IMP-CATEG_IRRF .
ZARI_COD_IMPOSTO-CATEG_IVA =
ZARIV_COD_IMP-CATEG_IVA .
    IF SY-SUBRC = 0.
    UPDATE ZARI_COD_IMPOSTO ##WARN_OK.
    ELSE.
    INSERT ZARI_COD_IMPOSTO .
    ENDIF.
    READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
    IF SY-SUBRC EQ 0.
      <XACT> = ORIGINAL.
      MODIFY EXTRACT INDEX SY-TABIX.
    ENDIF.
    <ACTION> = ORIGINAL.
    MODIFY TOTAL.
  ENDCASE.
ENDLOOP.
CLEAR: STATUS_ZARIV_COD_IMP-UPD_FLAG,
STATUS_ZARIV_COD_IMP-UPD_CHECKD.
MESSAGE S018(SV).
ENDFORM.
*---------------------------------------------------------------------*
FORM READ_SINGLE_ZARIV_COD_IMP.
  SELECT SINGLE * FROM ZARI_COD_IMPOSTO WHERE
CODIGO_IMPOSTO = ZARIV_COD_IMP-CODIGO_IMPOSTO .
ZARIV_COD_IMP-MANDT =
ZARI_COD_IMPOSTO-MANDT .
ZARIV_COD_IMP-CODIGO_IMPOSTO =
ZARI_COD_IMPOSTO-CODIGO_IMPOSTO .
ZARIV_COD_IMP-TIPO_IMPOSTO =
ZARI_COD_IMPOSTO-TIPO_IMPOSTO .
ZARIV_COD_IMP-DESCRICAO_IMPOSTO =
ZARI_COD_IMPOSTO-DESCRICAO_IMPOSTO .
ZARIV_COD_IMP-COD_IMPOSTO_GUIA =
ZARI_COD_IMPOSTO-COD_IMPOSTO_GUIA .
ZARIV_COD_IMP-CONTA_CONTABIL =
ZARI_COD_IMPOSTO-CONTA_CONTABIL .
ZARIV_COD_IMP-DIRECAO =
ZARI_COD_IMPOSTO-DIRECAO .
ZARIV_COD_IMP-PERIODO_APURACAO =
ZARI_COD_IMPOSTO-PERIODO_APURACAO .
ZARIV_COD_IMP-UF =
ZARI_COD_IMPOSTO-UF .
ZARIV_COD_IMP-DOMICILIO_FISCAL =
ZARI_COD_IMPOSTO-DOMICILIO_FISCAL .
ZARIV_COD_IMP-TIPO_GUIA =
ZARI_COD_IMPOSTO-TIPO_GUIA .
ZARIV_COD_IMP-DIA_VENCIMENTO =
ZARI_COD_IMPOSTO-DIA_VENCIMENTO .
ZARIV_COD_IMP-DEFINICAO_REGRA =
ZARI_COD_IMPOSTO-DEFINICAO_REGRA .
ZARIV_COD_IMP-DIAS_APURACAO =
ZARI_COD_IMPOSTO-DIAS_APURACAO .
ZARIV_COD_IMP-TIPO_APURACAO =
ZARI_COD_IMPOSTO-TIPO_APURACAO .
ZARIV_COD_IMP-REGRA_ACUMULO =
ZARI_COD_IMPOSTO-REGRA_ACUMULO .
ZARIV_COD_IMP-COD_FORNECEDOR =
ZARI_COD_IMPOSTO-COD_FORNECEDOR .
ZARIV_COD_IMP-COD_IMPOSTO_REC =
ZARI_COD_IMPOSTO-COD_IMPOSTO_REC .
ZARIV_COD_IMP-COD_COMPENS_REC =
ZARI_COD_IMPOSTO-COD_COMPENS_REC .
ZARIV_COD_IMP-COD_CORRECAO_MULTA =
ZARI_COD_IMPOSTO-COD_CORRECAO_MULTA .
ZARIV_COD_IMP-COD_CORRECAO_JUROS =
ZARI_COD_IMPOSTO-COD_CORRECAO_JUROS .
ZARIV_COD_IMP-IRRF =
ZARI_COD_IMPOSTO-IRRF .
ZARIV_COD_IMP-CATEG_IRRF =
ZARI_COD_IMPOSTO-CATEG_IRRF .
ZARIV_COD_IMP-CATEG_IVA =
ZARI_COD_IMPOSTO-CATEG_IVA .
    SELECT SINGLE * FROM ZARI_TP_IMPOSTO WHERE
TIPO_IMPOSTO = ZARI_COD_IMPOSTO-TIPO_IMPOSTO .
    IF SY-SUBRC EQ 0.
ZARIV_COD_IMP-CATEG_IMPOSTO =
ZARI_TP_IMPOSTO-CATEG_IMPOSTO .
    ELSE.
      CLEAR SY-SUBRC.
      CLEAR ZARIV_COD_IMP-CATEG_IMPOSTO .
    ENDIF.
ENDFORM.
*---------------------------------------------------------------------*
FORM CORR_MAINT_ZARIV_COD_IMP USING VALUE(CM_ACTION) RC.
  DATA: RETCODE LIKE SY-SUBRC, COUNT TYPE I, TRSP_KEYLEN TYPE SYFLENG.
  FIELD-SYMBOLS: <TAB_KEY_X> TYPE X.
  CLEAR RC.
MOVE ZARIV_COD_IMP-CODIGO_IMPOSTO TO
ZARI_COD_IMPOSTO-CODIGO_IMPOSTO .
MOVE ZARIV_COD_IMP-MANDT TO
ZARI_COD_IMPOSTO-MANDT .
  CORR_KEYTAB             =  E071K.
  CORR_KEYTAB-OBJNAME     = 'ZARI_COD_IMPOSTO'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN CORR_KEYTAB-TABKEY TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN ZARI_COD_IMPOSTO TO <TAB_KEY_X> CASTING.
  PERFORM VIM_GET_TRSPKEYLEN
    USING 'ZARI_COD_IMPOSTO'
    CHANGING TRSP_KEYLEN.
  <VIM_CORR_KEYX>(TRSP_KEYLEN) = <TAB_KEY_X>(TRSP_KEYLEN).
  PERFORM UPDATE_CORR_KEYTAB USING CM_ACTION RETCODE.
  ADD: RETCODE TO RC, 1 TO COUNT.
  IF RC LT COUNT AND CM_ACTION NE PRUEFEN.
    CLEAR RC.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
FORM COMPL_ZARIV_COD_IMP USING WORKAREA.
*      provides (read-only) fields from secondary tables related
*      to primary tables by foreignkey relationships
ZARI_COD_IMPOSTO-MANDT =
ZARIV_COD_IMP-MANDT .
ZARI_COD_IMPOSTO-CODIGO_IMPOSTO =
ZARIV_COD_IMP-CODIGO_IMPOSTO .
ZARI_COD_IMPOSTO-TIPO_IMPOSTO =
ZARIV_COD_IMP-TIPO_IMPOSTO .
ZARI_COD_IMPOSTO-DESCRICAO_IMPOSTO =
ZARIV_COD_IMP-DESCRICAO_IMPOSTO .
ZARI_COD_IMPOSTO-COD_IMPOSTO_GUIA =
ZARIV_COD_IMP-COD_IMPOSTO_GUIA .
ZARI_COD_IMPOSTO-CONTA_CONTABIL =
ZARIV_COD_IMP-CONTA_CONTABIL .
ZARI_COD_IMPOSTO-DIRECAO =
ZARIV_COD_IMP-DIRECAO .
ZARI_COD_IMPOSTO-PERIODO_APURACAO =
ZARIV_COD_IMP-PERIODO_APURACAO .
ZARI_COD_IMPOSTO-UF =
ZARIV_COD_IMP-UF .
ZARI_COD_IMPOSTO-DOMICILIO_FISCAL =
ZARIV_COD_IMP-DOMICILIO_FISCAL .
ZARI_COD_IMPOSTO-TIPO_GUIA =
ZARIV_COD_IMP-TIPO_GUIA .
ZARI_COD_IMPOSTO-DIA_VENCIMENTO =
ZARIV_COD_IMP-DIA_VENCIMENTO .
ZARI_COD_IMPOSTO-DEFINICAO_REGRA =
ZARIV_COD_IMP-DEFINICAO_REGRA .
ZARI_COD_IMPOSTO-DIAS_APURACAO =
ZARIV_COD_IMP-DIAS_APURACAO .
ZARI_COD_IMPOSTO-TIPO_APURACAO =
ZARIV_COD_IMP-TIPO_APURACAO .
ZARI_COD_IMPOSTO-REGRA_ACUMULO =
ZARIV_COD_IMP-REGRA_ACUMULO .
ZARI_COD_IMPOSTO-COD_FORNECEDOR =
ZARIV_COD_IMP-COD_FORNECEDOR .
ZARI_COD_IMPOSTO-COD_IMPOSTO_REC =
ZARIV_COD_IMP-COD_IMPOSTO_REC .
ZARI_COD_IMPOSTO-COD_COMPENS_REC =
ZARIV_COD_IMP-COD_COMPENS_REC .
ZARI_COD_IMPOSTO-COD_CORRECAO_MULTA =
ZARIV_COD_IMP-COD_CORRECAO_MULTA .
ZARI_COD_IMPOSTO-COD_CORRECAO_JUROS =
ZARIV_COD_IMP-COD_CORRECAO_JUROS .
ZARI_COD_IMPOSTO-IRRF =
ZARIV_COD_IMP-IRRF .
ZARI_COD_IMPOSTO-CATEG_IRRF =
ZARIV_COD_IMP-CATEG_IRRF .
ZARI_COD_IMPOSTO-CATEG_IVA =
ZARIV_COD_IMP-CATEG_IVA .
    SELECT SINGLE * FROM ZARI_TP_IMPOSTO WHERE
TIPO_IMPOSTO = ZARI_COD_IMPOSTO-TIPO_IMPOSTO .
    IF SY-SUBRC EQ 0.
ZARIV_COD_IMP-CATEG_IMPOSTO =
ZARI_TP_IMPOSTO-CATEG_IMPOSTO .
    ELSE.
      CLEAR SY-SUBRC.
      CLEAR ZARIV_COD_IMP-CATEG_IMPOSTO .
    ENDIF.
ENDFORM.
*...processing: ZARIV_EMPRESA...................................*
FORM GET_DATA_ZARIV_EMPRESA.
  PERFORM VIM_FILL_WHERETAB.
*.read data from database.............................................*
  REFRESH TOTAL.
  CLEAR   TOTAL.
  SELECT * FROM ZARI_EMPRESA WHERE
(VIM_WHERETAB) .
    CLEAR ZARIV_EMPRESA .
ZARIV_EMPRESA-MANDT =
ZARI_EMPRESA-MANDT .
ZARIV_EMPRESA-EMPRESA =
ZARI_EMPRESA-EMPRESA .
ZARIV_EMPRESA-CODIGO_IMPOSTO =
ZARI_EMPRESA-CODIGO_IMPOSTO .
    SELECT SINGLE * FROM ZARI_COD_IMPOSTO WHERE
CODIGO_IMPOSTO = ZARI_EMPRESA-CODIGO_IMPOSTO .
    IF SY-SUBRC EQ 0.
      SELECT SINGLE * FROM ZARI_TP_IMPOSTO WHERE
TIPO_IMPOSTO = ZARI_COD_IMPOSTO-TIPO_IMPOSTO .
      IF SY-SUBRC EQ 0.
ZARIV_EMPRESA-TIPO_IMPOSTO =
ZARI_TP_IMPOSTO-TIPO_IMPOSTO .
ZARIV_EMPRESA-CATEG_IMPOSTO =
ZARI_TP_IMPOSTO-CATEG_IMPOSTO .
      ENDIF.
    ENDIF.
<VIM_TOTAL_STRUC> = ZARIV_EMPRESA.
    APPEND TOTAL.
  ENDSELECT.
  SORT TOTAL BY <VIM_XTOTAL_KEY>.
  <STATUS>-ALR_SORTED = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF X_HEADER-SELECTION NE SPACE.
    PERFORM CHECK_DYNAMIC_SELECT_OPTIONS.
  ELSEIF X_HEADER-DELMDTFLAG NE SPACE.
    PERFORM BUILD_MAINKEY_TAB.
  ENDIF.
  REFRESH EXTRACT.
ENDFORM.
*---------------------------------------------------------------------*
FORM DB_UPD_ZARIV_EMPRESA .
*.process data base updates/inserts/deletes.........................*
LOOP AT TOTAL.
  CHECK <ACTION> NE ORIGINAL.
MOVE <VIM_TOTAL_STRUC> TO ZARIV_EMPRESA.
  IF <ACTION> = UPDATE_GELOESCHT.
    <ACTION> = GELOESCHT.
  ENDIF.
  CASE <ACTION>.
   WHEN NEUER_GELOESCHT.
IF STATUS_ZARIV_EMPRESA-ST_DELETE EQ GELOESCHT.
     READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
     IF SY-SUBRC EQ 0.
       DELETE EXTRACT INDEX SY-TABIX.
     ENDIF.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN GELOESCHT.
  SELECT SINGLE FOR UPDATE * FROM ZARI_EMPRESA WHERE
  EMPRESA = ZARIV_EMPRESA-EMPRESA AND
  CODIGO_IMPOSTO = ZARIV_EMPRESA-CODIGO_IMPOSTO .
    IF SY-SUBRC = 0.
    DELETE ZARI_EMPRESA .
    ENDIF.
    IF STATUS-DELETE EQ GELOESCHT.
      READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY> BINARY SEARCH.
      DELETE EXTRACT INDEX SY-TABIX.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN OTHERS.
  SELECT SINGLE FOR UPDATE * FROM ZARI_EMPRESA WHERE
  EMPRESA = ZARIV_EMPRESA-EMPRESA AND
  CODIGO_IMPOSTO = ZARIV_EMPRESA-CODIGO_IMPOSTO .
    IF SY-SUBRC <> 0.   "insert preprocessing: init WA
      CLEAR ZARI_EMPRESA.
    ENDIF.
ZARI_EMPRESA-MANDT =
ZARIV_EMPRESA-MANDT .
ZARI_EMPRESA-EMPRESA =
ZARIV_EMPRESA-EMPRESA .
ZARI_EMPRESA-CODIGO_IMPOSTO =
ZARIV_EMPRESA-CODIGO_IMPOSTO .
    IF SY-SUBRC = 0.
    UPDATE ZARI_EMPRESA ##WARN_OK.
    ELSE.
    INSERT ZARI_EMPRESA .
    ENDIF.
    READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
    IF SY-SUBRC EQ 0.
      <XACT> = ORIGINAL.
      MODIFY EXTRACT INDEX SY-TABIX.
    ENDIF.
    <ACTION> = ORIGINAL.
    MODIFY TOTAL.
  ENDCASE.
ENDLOOP.
CLEAR: STATUS_ZARIV_EMPRESA-UPD_FLAG,
STATUS_ZARIV_EMPRESA-UPD_CHECKD.
MESSAGE S018(SV).
ENDFORM.
*---------------------------------------------------------------------*
FORM READ_SINGLE_ZARIV_EMPRESA.
  SELECT SINGLE * FROM ZARI_EMPRESA WHERE
EMPRESA = ZARIV_EMPRESA-EMPRESA AND
CODIGO_IMPOSTO = ZARIV_EMPRESA-CODIGO_IMPOSTO .
ZARIV_EMPRESA-MANDT =
ZARI_EMPRESA-MANDT .
ZARIV_EMPRESA-EMPRESA =
ZARI_EMPRESA-EMPRESA .
ZARIV_EMPRESA-CODIGO_IMPOSTO =
ZARI_EMPRESA-CODIGO_IMPOSTO .
    SELECT SINGLE * FROM ZARI_COD_IMPOSTO WHERE
CODIGO_IMPOSTO = ZARI_EMPRESA-CODIGO_IMPOSTO .
    IF SY-SUBRC EQ 0.
      SELECT SINGLE * FROM ZARI_TP_IMPOSTO WHERE
TIPO_IMPOSTO = ZARI_COD_IMPOSTO-TIPO_IMPOSTO .
      IF SY-SUBRC EQ 0.
ZARIV_EMPRESA-TIPO_IMPOSTO =
ZARI_TP_IMPOSTO-TIPO_IMPOSTO .
ZARIV_EMPRESA-CATEG_IMPOSTO =
ZARI_TP_IMPOSTO-CATEG_IMPOSTO .
      ELSE.
        CLEAR SY-SUBRC.
        CLEAR ZARIV_EMPRESA-TIPO_IMPOSTO .
        CLEAR ZARIV_EMPRESA-CATEG_IMPOSTO .
      ENDIF.
    ELSE.
      CLEAR SY-SUBRC.
      CLEAR ZARIV_EMPRESA-TIPO_IMPOSTO .
      CLEAR ZARIV_EMPRESA-CATEG_IMPOSTO .
    ENDIF.
ENDFORM.
*---------------------------------------------------------------------*
FORM CORR_MAINT_ZARIV_EMPRESA USING VALUE(CM_ACTION) RC.
  DATA: RETCODE LIKE SY-SUBRC, COUNT TYPE I, TRSP_KEYLEN TYPE SYFLENG.
  FIELD-SYMBOLS: <TAB_KEY_X> TYPE X.
  CLEAR RC.
MOVE ZARIV_EMPRESA-EMPRESA TO
ZARI_EMPRESA-EMPRESA .
MOVE ZARIV_EMPRESA-CODIGO_IMPOSTO TO
ZARI_EMPRESA-CODIGO_IMPOSTO .
MOVE ZARIV_EMPRESA-MANDT TO
ZARI_EMPRESA-MANDT .
  CORR_KEYTAB             =  E071K.
  CORR_KEYTAB-OBJNAME     = 'ZARI_EMPRESA'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN CORR_KEYTAB-TABKEY TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN ZARI_EMPRESA TO <TAB_KEY_X> CASTING.
  PERFORM VIM_GET_TRSPKEYLEN
    USING 'ZARI_EMPRESA'
    CHANGING TRSP_KEYLEN.
  <VIM_CORR_KEYX>(TRSP_KEYLEN) = <TAB_KEY_X>(TRSP_KEYLEN).
  PERFORM UPDATE_CORR_KEYTAB USING CM_ACTION RETCODE.
  ADD: RETCODE TO RC, 1 TO COUNT.
  IF RC LT COUNT AND CM_ACTION NE PRUEFEN.
    CLEAR RC.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
FORM COMPL_ZARIV_EMPRESA USING WORKAREA.
*      provides (read-only) fields from secondary tables related
*      to primary tables by foreignkey relationships
ZARI_EMPRESA-MANDT =
ZARIV_EMPRESA-MANDT .
ZARI_EMPRESA-EMPRESA =
ZARIV_EMPRESA-EMPRESA .
ZARI_EMPRESA-CODIGO_IMPOSTO =
ZARIV_EMPRESA-CODIGO_IMPOSTO .
    SELECT SINGLE * FROM ZARI_COD_IMPOSTO WHERE
CODIGO_IMPOSTO = ZARI_EMPRESA-CODIGO_IMPOSTO .
    IF SY-SUBRC EQ 0.
      SELECT SINGLE * FROM ZARI_TP_IMPOSTO WHERE
TIPO_IMPOSTO = ZARI_COD_IMPOSTO-TIPO_IMPOSTO .
      IF SY-SUBRC EQ 0.
ZARIV_EMPRESA-TIPO_IMPOSTO =
ZARI_TP_IMPOSTO-TIPO_IMPOSTO .
ZARIV_EMPRESA-CATEG_IMPOSTO =
ZARI_TP_IMPOSTO-CATEG_IMPOSTO .
      ELSE.
        CLEAR SY-SUBRC.
        CLEAR ZARIV_EMPRESA-TIPO_IMPOSTO .
        CLEAR ZARIV_EMPRESA-CATEG_IMPOSTO .
      ENDIF.
    ELSE.
      CLEAR SY-SUBRC.
      CLEAR ZARIV_EMPRESA-TIPO_IMPOSTO .
      CLEAR ZARIV_EMPRESA-CATEG_IMPOSTO .
    ENDIF.
ENDFORM.
*...processing: ZARIV_INTERVALO.................................*
FORM GET_DATA_ZARIV_INTERVALO.
  PERFORM VIM_FILL_WHERETAB.
*.read data from database.............................................*
  REFRESH TOTAL.
  CLEAR   TOTAL.
  SELECT * FROM ZARI_INTERV_NUM WHERE
(VIM_WHERETAB) .
    CLEAR ZARIV_INTERVALO .
ZARIV_INTERVALO-MANDT =
ZARI_INTERV_NUM-MANDT .
ZARIV_INTERVALO-SEQUENCIAL =
ZARI_INTERV_NUM-SEQUENCIAL .
ZARIV_INTERVALO-EXERCICIO =
ZARI_INTERV_NUM-EXERCICIO .
ZARIV_INTERVALO-NUM_INICIAL =
ZARI_INTERV_NUM-NUM_INICIAL .
ZARIV_INTERVALO-NUM_FINAL =
ZARI_INTERV_NUM-NUM_FINAL .
ZARIV_INTERVALO-POSICAO =
ZARI_INTERV_NUM-POSICAO .
<VIM_TOTAL_STRUC> = ZARIV_INTERVALO.
    APPEND TOTAL.
  ENDSELECT.
  SORT TOTAL BY <VIM_XTOTAL_KEY>.
  <STATUS>-ALR_SORTED = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF X_HEADER-SELECTION NE SPACE.
    PERFORM CHECK_DYNAMIC_SELECT_OPTIONS.
  ELSEIF X_HEADER-DELMDTFLAG NE SPACE.
    PERFORM BUILD_MAINKEY_TAB.
  ENDIF.
  REFRESH EXTRACT.
ENDFORM.
*---------------------------------------------------------------------*
FORM DB_UPD_ZARIV_INTERVALO .
*.process data base updates/inserts/deletes.........................*
LOOP AT TOTAL.
  CHECK <ACTION> NE ORIGINAL.
MOVE <VIM_TOTAL_STRUC> TO ZARIV_INTERVALO.
  IF <ACTION> = UPDATE_GELOESCHT.
    <ACTION> = GELOESCHT.
  ENDIF.
  CASE <ACTION>.
   WHEN NEUER_GELOESCHT.
IF STATUS_ZARIV_INTERVALO-ST_DELETE EQ GELOESCHT.
     READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
     IF SY-SUBRC EQ 0.
       DELETE EXTRACT INDEX SY-TABIX.
     ENDIF.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN GELOESCHT.
  SELECT SINGLE FOR UPDATE * FROM ZARI_INTERV_NUM WHERE
  SEQUENCIAL = ZARIV_INTERVALO-SEQUENCIAL AND
  EXERCICIO = ZARIV_INTERVALO-EXERCICIO .
    IF SY-SUBRC = 0.
    DELETE ZARI_INTERV_NUM .
    ENDIF.
    IF STATUS-DELETE EQ GELOESCHT.
      READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY> BINARY SEARCH.
      DELETE EXTRACT INDEX SY-TABIX.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN OTHERS.
  SELECT SINGLE FOR UPDATE * FROM ZARI_INTERV_NUM WHERE
  SEQUENCIAL = ZARIV_INTERVALO-SEQUENCIAL AND
  EXERCICIO = ZARIV_INTERVALO-EXERCICIO .
    IF SY-SUBRC <> 0.   "insert preprocessing: init WA
      CLEAR ZARI_INTERV_NUM.
    ENDIF.
ZARI_INTERV_NUM-MANDT =
ZARIV_INTERVALO-MANDT .
ZARI_INTERV_NUM-SEQUENCIAL =
ZARIV_INTERVALO-SEQUENCIAL .
ZARI_INTERV_NUM-EXERCICIO =
ZARIV_INTERVALO-EXERCICIO .
ZARI_INTERV_NUM-NUM_INICIAL =
ZARIV_INTERVALO-NUM_INICIAL .
ZARI_INTERV_NUM-NUM_FINAL =
ZARIV_INTERVALO-NUM_FINAL .
ZARI_INTERV_NUM-POSICAO =
ZARIV_INTERVALO-POSICAO .
    IF SY-SUBRC = 0.
    UPDATE ZARI_INTERV_NUM ##WARN_OK.
    ELSE.
    INSERT ZARI_INTERV_NUM .
    ENDIF.
    READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
    IF SY-SUBRC EQ 0.
      <XACT> = ORIGINAL.
      MODIFY EXTRACT INDEX SY-TABIX.
    ENDIF.
    <ACTION> = ORIGINAL.
    MODIFY TOTAL.
  ENDCASE.
ENDLOOP.
CLEAR: STATUS_ZARIV_INTERVALO-UPD_FLAG,
STATUS_ZARIV_INTERVALO-UPD_CHECKD.
MESSAGE S018(SV).
ENDFORM.
*---------------------------------------------------------------------*
FORM READ_SINGLE_ZARIV_INTERVALO.
  SELECT SINGLE * FROM ZARI_INTERV_NUM WHERE
SEQUENCIAL = ZARIV_INTERVALO-SEQUENCIAL AND
EXERCICIO = ZARIV_INTERVALO-EXERCICIO .
ZARIV_INTERVALO-MANDT =
ZARI_INTERV_NUM-MANDT .
ZARIV_INTERVALO-SEQUENCIAL =
ZARI_INTERV_NUM-SEQUENCIAL .
ZARIV_INTERVALO-EXERCICIO =
ZARI_INTERV_NUM-EXERCICIO .
ZARIV_INTERVALO-NUM_INICIAL =
ZARI_INTERV_NUM-NUM_INICIAL .
ZARIV_INTERVALO-NUM_FINAL =
ZARI_INTERV_NUM-NUM_FINAL .
ZARIV_INTERVALO-POSICAO =
ZARI_INTERV_NUM-POSICAO .
ENDFORM.
*---------------------------------------------------------------------*
FORM CORR_MAINT_ZARIV_INTERVALO USING VALUE(CM_ACTION) RC.
  DATA: RETCODE LIKE SY-SUBRC, COUNT TYPE I, TRSP_KEYLEN TYPE SYFLENG.
  FIELD-SYMBOLS: <TAB_KEY_X> TYPE X.
  CLEAR RC.
MOVE ZARIV_INTERVALO-SEQUENCIAL TO
ZARI_INTERV_NUM-SEQUENCIAL .
MOVE ZARIV_INTERVALO-EXERCICIO TO
ZARI_INTERV_NUM-EXERCICIO .
MOVE ZARIV_INTERVALO-MANDT TO
ZARI_INTERV_NUM-MANDT .
  CORR_KEYTAB             =  E071K.
  CORR_KEYTAB-OBJNAME     = 'ZARI_INTERV_NUM'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN CORR_KEYTAB-TABKEY TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN ZARI_INTERV_NUM TO <TAB_KEY_X> CASTING.
  PERFORM VIM_GET_TRSPKEYLEN
    USING 'ZARI_INTERV_NUM'
    CHANGING TRSP_KEYLEN.
  <VIM_CORR_KEYX>(TRSP_KEYLEN) = <TAB_KEY_X>(TRSP_KEYLEN).
  PERFORM UPDATE_CORR_KEYTAB USING CM_ACTION RETCODE.
  ADD: RETCODE TO RC, 1 TO COUNT.
  IF RC LT COUNT AND CM_ACTION NE PRUEFEN.
    CLEAR RC.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
*...processing: ZARIV_JUROS_MULT................................*
FORM GET_DATA_ZARIV_JUROS_MULT.
  PERFORM VIM_FILL_WHERETAB.
*.read data from database.............................................*
  REFRESH TOTAL.
  CLEAR   TOTAL.
  SELECT * FROM ZARI_JUROS_MULTA WHERE
(VIM_WHERETAB) .
    CLEAR ZARIV_JUROS_MULT .
ZARIV_JUROS_MULT-MANDT =
ZARI_JUROS_MULTA-MANDT .
ZARIV_JUROS_MULT-COD_CORRECAO =
ZARI_JUROS_MULTA-COD_CORRECAO .
ZARIV_JUROS_MULT-TIPO =
ZARI_JUROS_MULTA-TIPO .
ZARIV_JUROS_MULT-TIPO_IMPOSTO =
ZARI_JUROS_MULTA-TIPO_IMPOSTO .
ZARIV_JUROS_MULT-BASE_CALCULO =
ZARI_JUROS_MULTA-BASE_CALCULO .
ZARIV_JUROS_MULT-PERC_FIXO_CORRECAO =
ZARI_JUROS_MULTA-PERC_FIXO_CORRECAO .
ZARIV_JUROS_MULT-TAXA_VAR_MERCADO =
ZARI_JUROS_MULTA-TAXA_VAR_MERCADO .
ZARIV_JUROS_MULT-PERC_TAXA_VAR_MERC =
ZARI_JUROS_MULTA-PERC_TAXA_VAR_MERC .
ZARIV_JUROS_MULT-PERIODICIDADE =
ZARI_JUROS_MULTA-PERIODICIDADE .
ZARIV_JUROS_MULT-LIMITE_CORRECAO =
ZARI_JUROS_MULTA-LIMITE_CORRECAO .
ZARIV_JUROS_MULT-PERC_LIMITE_CORRECAO =
ZARI_JUROS_MULTA-PERC_LIMITE_CORRECAO .
    SELECT SINGLE * FROM ZARI_TP_IMPOSTO WHERE
TIPO_IMPOSTO = ZARI_JUROS_MULTA-TIPO_IMPOSTO .
    IF SY-SUBRC EQ 0.
ZARIV_JUROS_MULT-CATEG_IMPOSTO =
ZARI_TP_IMPOSTO-CATEG_IMPOSTO .
    ENDIF.
<VIM_TOTAL_STRUC> = ZARIV_JUROS_MULT.
    APPEND TOTAL.
  ENDSELECT.
  SORT TOTAL BY <VIM_XTOTAL_KEY>.
  <STATUS>-ALR_SORTED = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF X_HEADER-SELECTION NE SPACE.
    PERFORM CHECK_DYNAMIC_SELECT_OPTIONS.
  ELSEIF X_HEADER-DELMDTFLAG NE SPACE.
    PERFORM BUILD_MAINKEY_TAB.
  ENDIF.
  REFRESH EXTRACT.
ENDFORM.
*---------------------------------------------------------------------*
FORM DB_UPD_ZARIV_JUROS_MULT .
*.process data base updates/inserts/deletes.........................*
LOOP AT TOTAL.
  CHECK <ACTION> NE ORIGINAL.
MOVE <VIM_TOTAL_STRUC> TO ZARIV_JUROS_MULT.
  IF <ACTION> = UPDATE_GELOESCHT.
    <ACTION> = GELOESCHT.
  ENDIF.
  CASE <ACTION>.
   WHEN NEUER_GELOESCHT.
IF STATUS_ZARIV_JUROS_MULT-ST_DELETE EQ GELOESCHT.
     READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
     IF SY-SUBRC EQ 0.
       DELETE EXTRACT INDEX SY-TABIX.
     ENDIF.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN GELOESCHT.
  SELECT SINGLE FOR UPDATE * FROM ZARI_JUROS_MULTA WHERE
  COD_CORRECAO = ZARIV_JUROS_MULT-COD_CORRECAO AND
  TIPO = ZARIV_JUROS_MULT-TIPO .
    IF SY-SUBRC = 0.
    DELETE ZARI_JUROS_MULTA .
    ENDIF.
    IF STATUS-DELETE EQ GELOESCHT.
      READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY> BINARY SEARCH.
      DELETE EXTRACT INDEX SY-TABIX.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN OTHERS.
  SELECT SINGLE FOR UPDATE * FROM ZARI_JUROS_MULTA WHERE
  COD_CORRECAO = ZARIV_JUROS_MULT-COD_CORRECAO AND
  TIPO = ZARIV_JUROS_MULT-TIPO .
    IF SY-SUBRC <> 0.   "insert preprocessing: init WA
      CLEAR ZARI_JUROS_MULTA.
    ENDIF.
ZARI_JUROS_MULTA-MANDT =
ZARIV_JUROS_MULT-MANDT .
ZARI_JUROS_MULTA-COD_CORRECAO =
ZARIV_JUROS_MULT-COD_CORRECAO .
ZARI_JUROS_MULTA-TIPO =
ZARIV_JUROS_MULT-TIPO .
ZARI_JUROS_MULTA-TIPO_IMPOSTO =
ZARIV_JUROS_MULT-TIPO_IMPOSTO .
ZARI_JUROS_MULTA-BASE_CALCULO =
ZARIV_JUROS_MULT-BASE_CALCULO .
ZARI_JUROS_MULTA-PERC_FIXO_CORRECAO =
ZARIV_JUROS_MULT-PERC_FIXO_CORRECAO .
ZARI_JUROS_MULTA-TAXA_VAR_MERCADO =
ZARIV_JUROS_MULT-TAXA_VAR_MERCADO .
ZARI_JUROS_MULTA-PERC_TAXA_VAR_MERC =
ZARIV_JUROS_MULT-PERC_TAXA_VAR_MERC .
ZARI_JUROS_MULTA-PERIODICIDADE =
ZARIV_JUROS_MULT-PERIODICIDADE .
ZARI_JUROS_MULTA-LIMITE_CORRECAO =
ZARIV_JUROS_MULT-LIMITE_CORRECAO .
ZARI_JUROS_MULTA-PERC_LIMITE_CORRECAO =
ZARIV_JUROS_MULT-PERC_LIMITE_CORRECAO .
    IF SY-SUBRC = 0.
    UPDATE ZARI_JUROS_MULTA ##WARN_OK.
    ELSE.
    INSERT ZARI_JUROS_MULTA .
    ENDIF.
    READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
    IF SY-SUBRC EQ 0.
      <XACT> = ORIGINAL.
      MODIFY EXTRACT INDEX SY-TABIX.
    ENDIF.
    <ACTION> = ORIGINAL.
    MODIFY TOTAL.
  ENDCASE.
ENDLOOP.
CLEAR: STATUS_ZARIV_JUROS_MULT-UPD_FLAG,
STATUS_ZARIV_JUROS_MULT-UPD_CHECKD.
MESSAGE S018(SV).
ENDFORM.
*---------------------------------------------------------------------*
FORM READ_SINGLE_ZARIV_JUROS_MULT.
  SELECT SINGLE * FROM ZARI_JUROS_MULTA WHERE
COD_CORRECAO = ZARIV_JUROS_MULT-COD_CORRECAO AND
TIPO = ZARIV_JUROS_MULT-TIPO .
ZARIV_JUROS_MULT-MANDT =
ZARI_JUROS_MULTA-MANDT .
ZARIV_JUROS_MULT-COD_CORRECAO =
ZARI_JUROS_MULTA-COD_CORRECAO .
ZARIV_JUROS_MULT-TIPO =
ZARI_JUROS_MULTA-TIPO .
ZARIV_JUROS_MULT-TIPO_IMPOSTO =
ZARI_JUROS_MULTA-TIPO_IMPOSTO .
ZARIV_JUROS_MULT-BASE_CALCULO =
ZARI_JUROS_MULTA-BASE_CALCULO .
ZARIV_JUROS_MULT-PERC_FIXO_CORRECAO =
ZARI_JUROS_MULTA-PERC_FIXO_CORRECAO .
ZARIV_JUROS_MULT-TAXA_VAR_MERCADO =
ZARI_JUROS_MULTA-TAXA_VAR_MERCADO .
ZARIV_JUROS_MULT-PERC_TAXA_VAR_MERC =
ZARI_JUROS_MULTA-PERC_TAXA_VAR_MERC .
ZARIV_JUROS_MULT-PERIODICIDADE =
ZARI_JUROS_MULTA-PERIODICIDADE .
ZARIV_JUROS_MULT-LIMITE_CORRECAO =
ZARI_JUROS_MULTA-LIMITE_CORRECAO .
ZARIV_JUROS_MULT-PERC_LIMITE_CORRECAO =
ZARI_JUROS_MULTA-PERC_LIMITE_CORRECAO .
    SELECT SINGLE * FROM ZARI_TP_IMPOSTO WHERE
TIPO_IMPOSTO = ZARI_JUROS_MULTA-TIPO_IMPOSTO .
    IF SY-SUBRC EQ 0.
ZARIV_JUROS_MULT-CATEG_IMPOSTO =
ZARI_TP_IMPOSTO-CATEG_IMPOSTO .
    ELSE.
      CLEAR SY-SUBRC.
      CLEAR ZARIV_JUROS_MULT-CATEG_IMPOSTO .
    ENDIF.
ENDFORM.
*---------------------------------------------------------------------*
FORM CORR_MAINT_ZARIV_JUROS_MULT USING VALUE(CM_ACTION) RC.
  DATA: RETCODE LIKE SY-SUBRC, COUNT TYPE I, TRSP_KEYLEN TYPE SYFLENG.
  FIELD-SYMBOLS: <TAB_KEY_X> TYPE X.
  CLEAR RC.
MOVE ZARIV_JUROS_MULT-COD_CORRECAO TO
ZARI_JUROS_MULTA-COD_CORRECAO .
MOVE ZARIV_JUROS_MULT-TIPO TO
ZARI_JUROS_MULTA-TIPO .
MOVE ZARIV_JUROS_MULT-MANDT TO
ZARI_JUROS_MULTA-MANDT .
  CORR_KEYTAB             =  E071K.
  CORR_KEYTAB-OBJNAME     = 'ZARI_JUROS_MULTA'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN CORR_KEYTAB-TABKEY TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN ZARI_JUROS_MULTA TO <TAB_KEY_X> CASTING.
  PERFORM VIM_GET_TRSPKEYLEN
    USING 'ZARI_JUROS_MULTA'
    CHANGING TRSP_KEYLEN.
  <VIM_CORR_KEYX>(TRSP_KEYLEN) = <TAB_KEY_X>(TRSP_KEYLEN).
  PERFORM UPDATE_CORR_KEYTAB USING CM_ACTION RETCODE.
  ADD: RETCODE TO RC, 1 TO COUNT.
  IF RC LT COUNT AND CM_ACTION NE PRUEFEN.
    CLEAR RC.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
FORM COMPL_ZARIV_JUROS_MULT USING WORKAREA.
*      provides (read-only) fields from secondary tables related
*      to primary tables by foreignkey relationships
ZARI_JUROS_MULTA-MANDT =
ZARIV_JUROS_MULT-MANDT .
ZARI_JUROS_MULTA-COD_CORRECAO =
ZARIV_JUROS_MULT-COD_CORRECAO .
ZARI_JUROS_MULTA-TIPO =
ZARIV_JUROS_MULT-TIPO .
ZARI_JUROS_MULTA-TIPO_IMPOSTO =
ZARIV_JUROS_MULT-TIPO_IMPOSTO .
ZARI_JUROS_MULTA-BASE_CALCULO =
ZARIV_JUROS_MULT-BASE_CALCULO .
ZARI_JUROS_MULTA-PERC_FIXO_CORRECAO =
ZARIV_JUROS_MULT-PERC_FIXO_CORRECAO .
ZARI_JUROS_MULTA-TAXA_VAR_MERCADO =
ZARIV_JUROS_MULT-TAXA_VAR_MERCADO .
ZARI_JUROS_MULTA-PERC_TAXA_VAR_MERC =
ZARIV_JUROS_MULT-PERC_TAXA_VAR_MERC .
ZARI_JUROS_MULTA-PERIODICIDADE =
ZARIV_JUROS_MULT-PERIODICIDADE .
ZARI_JUROS_MULTA-LIMITE_CORRECAO =
ZARIV_JUROS_MULT-LIMITE_CORRECAO .
ZARI_JUROS_MULTA-PERC_LIMITE_CORRECAO =
ZARIV_JUROS_MULT-PERC_LIMITE_CORRECAO .
    SELECT SINGLE * FROM ZARI_TP_IMPOSTO WHERE
TIPO_IMPOSTO = ZARI_JUROS_MULTA-TIPO_IMPOSTO .
    IF SY-SUBRC EQ 0.
ZARIV_JUROS_MULT-CATEG_IMPOSTO =
ZARI_TP_IMPOSTO-CATEG_IMPOSTO .
    ELSE.
      CLEAR SY-SUBRC.
      CLEAR ZARIV_JUROS_MULT-CATEG_IMPOSTO .
    ENDIF.
ENDFORM.
*...processing: ZARIV_RESP......................................*
FORM GET_DATA_ZARIV_RESP.
  PERFORM VIM_FILL_WHERETAB.
*.read data from database.............................................*
  REFRESH TOTAL.
  CLEAR   TOTAL.
  SELECT * FROM ZARI_RESPONSAVEL WHERE
(VIM_WHERETAB) .
    CLEAR ZARIV_RESP .
ZARIV_RESP-MANDT =
ZARI_RESPONSAVEL-MANDT .
ZARIV_RESP-CODIGO_USUARIO =
ZARI_RESPONSAVEL-CODIGO_USUARIO .
ZARIV_RESP-POSICAO =
ZARI_RESPONSAVEL-POSICAO .
ZARIV_RESP-CATEG_IMPOSTO =
ZARI_RESPONSAVEL-CATEG_IMPOSTO .
<VIM_TOTAL_STRUC> = ZARIV_RESP.
    APPEND TOTAL.
  ENDSELECT.
  SORT TOTAL BY <VIM_XTOTAL_KEY>.
  <STATUS>-ALR_SORTED = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF X_HEADER-SELECTION NE SPACE.
    PERFORM CHECK_DYNAMIC_SELECT_OPTIONS.
  ELSEIF X_HEADER-DELMDTFLAG NE SPACE.
    PERFORM BUILD_MAINKEY_TAB.
  ENDIF.
  REFRESH EXTRACT.
ENDFORM.
*---------------------------------------------------------------------*
FORM DB_UPD_ZARIV_RESP .
*.process data base updates/inserts/deletes.........................*
LOOP AT TOTAL.
  CHECK <ACTION> NE ORIGINAL.
MOVE <VIM_TOTAL_STRUC> TO ZARIV_RESP.
  IF <ACTION> = UPDATE_GELOESCHT.
    <ACTION> = GELOESCHT.
  ENDIF.
  CASE <ACTION>.
   WHEN NEUER_GELOESCHT.
IF STATUS_ZARIV_RESP-ST_DELETE EQ GELOESCHT.
     READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
     IF SY-SUBRC EQ 0.
       DELETE EXTRACT INDEX SY-TABIX.
     ENDIF.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN GELOESCHT.
  SELECT SINGLE FOR UPDATE * FROM ZARI_RESPONSAVEL WHERE
  CODIGO_USUARIO = ZARIV_RESP-CODIGO_USUARIO AND
  POSICAO = ZARIV_RESP-POSICAO AND
  CATEG_IMPOSTO = ZARIV_RESP-CATEG_IMPOSTO .
    IF SY-SUBRC = 0.
    DELETE ZARI_RESPONSAVEL .
    ENDIF.
    IF STATUS-DELETE EQ GELOESCHT.
      READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY> BINARY SEARCH.
      DELETE EXTRACT INDEX SY-TABIX.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN OTHERS.
  SELECT SINGLE FOR UPDATE * FROM ZARI_RESPONSAVEL WHERE
  CODIGO_USUARIO = ZARIV_RESP-CODIGO_USUARIO AND
  POSICAO = ZARIV_RESP-POSICAO AND
  CATEG_IMPOSTO = ZARIV_RESP-CATEG_IMPOSTO .
    IF SY-SUBRC <> 0.   "insert preprocessing: init WA
      CLEAR ZARI_RESPONSAVEL.
    ENDIF.
ZARI_RESPONSAVEL-MANDT =
ZARIV_RESP-MANDT .
ZARI_RESPONSAVEL-CODIGO_USUARIO =
ZARIV_RESP-CODIGO_USUARIO .
ZARI_RESPONSAVEL-POSICAO =
ZARIV_RESP-POSICAO .
ZARI_RESPONSAVEL-CATEG_IMPOSTO =
ZARIV_RESP-CATEG_IMPOSTO .
    IF SY-SUBRC = 0.
    UPDATE ZARI_RESPONSAVEL ##WARN_OK.
    ELSE.
    INSERT ZARI_RESPONSAVEL .
    ENDIF.
    READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
    IF SY-SUBRC EQ 0.
      <XACT> = ORIGINAL.
      MODIFY EXTRACT INDEX SY-TABIX.
    ENDIF.
    <ACTION> = ORIGINAL.
    MODIFY TOTAL.
  ENDCASE.
ENDLOOP.
CLEAR: STATUS_ZARIV_RESP-UPD_FLAG,
STATUS_ZARIV_RESP-UPD_CHECKD.
MESSAGE S018(SV).
ENDFORM.
*---------------------------------------------------------------------*
FORM READ_SINGLE_ENTRY_ZARIV_RESP.
  SELECT SINGLE * FROM ZARI_RESPONSAVEL WHERE
CODIGO_USUARIO = ZARIV_RESP-CODIGO_USUARIO AND
POSICAO = ZARIV_RESP-POSICAO AND
CATEG_IMPOSTO = ZARIV_RESP-CATEG_IMPOSTO .
ZARIV_RESP-MANDT =
ZARI_RESPONSAVEL-MANDT .
ZARIV_RESP-CODIGO_USUARIO =
ZARI_RESPONSAVEL-CODIGO_USUARIO .
ZARIV_RESP-POSICAO =
ZARI_RESPONSAVEL-POSICAO .
ZARIV_RESP-CATEG_IMPOSTO =
ZARI_RESPONSAVEL-CATEG_IMPOSTO .
ENDFORM.
*---------------------------------------------------------------------*
FORM CORR_MAINT_ZARIV_RESP USING VALUE(CM_ACTION) RC.
  DATA: RETCODE LIKE SY-SUBRC, COUNT TYPE I, TRSP_KEYLEN TYPE SYFLENG.
  FIELD-SYMBOLS: <TAB_KEY_X> TYPE X.
  CLEAR RC.
MOVE ZARIV_RESP-CODIGO_USUARIO TO
ZARI_RESPONSAVEL-CODIGO_USUARIO .
MOVE ZARIV_RESP-POSICAO TO
ZARI_RESPONSAVEL-POSICAO .
MOVE ZARIV_RESP-CATEG_IMPOSTO TO
ZARI_RESPONSAVEL-CATEG_IMPOSTO .
MOVE ZARIV_RESP-MANDT TO
ZARI_RESPONSAVEL-MANDT .
  CORR_KEYTAB             =  E071K.
  CORR_KEYTAB-OBJNAME     = 'ZARI_RESPONSAVEL'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN CORR_KEYTAB-TABKEY TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN ZARI_RESPONSAVEL TO <TAB_KEY_X> CASTING.
  PERFORM VIM_GET_TRSPKEYLEN
    USING 'ZARI_RESPONSAVEL'
    CHANGING TRSP_KEYLEN.
  <VIM_CORR_KEYX>(TRSP_KEYLEN) = <TAB_KEY_X>(TRSP_KEYLEN).
  PERFORM UPDATE_CORR_KEYTAB USING CM_ACTION RETCODE.
  ADD: RETCODE TO RC, 1 TO COUNT.
  IF RC LT COUNT AND CM_ACTION NE PRUEFEN.
    CLEAR RC.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
*...processing: ZARIV_TP_IMPOSTO................................*
FORM GET_DATA_ZARIV_TP_IMPOSTO.
  PERFORM VIM_FILL_WHERETAB.
*.read data from database.............................................*
  REFRESH TOTAL.
  CLEAR   TOTAL.
  SELECT * FROM ZARI_TP_IMPOSTO WHERE
(VIM_WHERETAB) .
    CLEAR ZARIV_TP_IMPOSTO .
ZARIV_TP_IMPOSTO-MANDT =
ZARI_TP_IMPOSTO-MANDT .
ZARIV_TP_IMPOSTO-TIPO_IMPOSTO =
ZARI_TP_IMPOSTO-TIPO_IMPOSTO .
ZARIV_TP_IMPOSTO-CATEG_IMPOSTO =
ZARI_TP_IMPOSTO-CATEG_IMPOSTO .
ZARIV_TP_IMPOSTO-ORGAO =
ZARI_TP_IMPOSTO-ORGAO .
<VIM_TOTAL_STRUC> = ZARIV_TP_IMPOSTO.
    APPEND TOTAL.
  ENDSELECT.
  SORT TOTAL BY <VIM_XTOTAL_KEY>.
  <STATUS>-ALR_SORTED = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF X_HEADER-SELECTION NE SPACE.
    PERFORM CHECK_DYNAMIC_SELECT_OPTIONS.
  ELSEIF X_HEADER-DELMDTFLAG NE SPACE.
    PERFORM BUILD_MAINKEY_TAB.
  ENDIF.
  REFRESH EXTRACT.
ENDFORM.
*---------------------------------------------------------------------*
FORM DB_UPD_ZARIV_TP_IMPOSTO .
*.process data base updates/inserts/deletes.........................*
LOOP AT TOTAL.
  CHECK <ACTION> NE ORIGINAL.
MOVE <VIM_TOTAL_STRUC> TO ZARIV_TP_IMPOSTO.
  IF <ACTION> = UPDATE_GELOESCHT.
    <ACTION> = GELOESCHT.
  ENDIF.
  CASE <ACTION>.
   WHEN NEUER_GELOESCHT.
IF STATUS_ZARIV_TP_IMPOSTO-ST_DELETE EQ GELOESCHT.
     READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
     IF SY-SUBRC EQ 0.
       DELETE EXTRACT INDEX SY-TABIX.
     ENDIF.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN GELOESCHT.
  SELECT SINGLE FOR UPDATE * FROM ZARI_TP_IMPOSTO WHERE
  TIPO_IMPOSTO = ZARIV_TP_IMPOSTO-TIPO_IMPOSTO .
    IF SY-SUBRC = 0.
    DELETE ZARI_TP_IMPOSTO .
    ENDIF.
    IF STATUS-DELETE EQ GELOESCHT.
      READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY> BINARY SEARCH.
      DELETE EXTRACT INDEX SY-TABIX.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN OTHERS.
  SELECT SINGLE FOR UPDATE * FROM ZARI_TP_IMPOSTO WHERE
  TIPO_IMPOSTO = ZARIV_TP_IMPOSTO-TIPO_IMPOSTO .
    IF SY-SUBRC <> 0.   "insert preprocessing: init WA
      CLEAR ZARI_TP_IMPOSTO.
    ENDIF.
ZARI_TP_IMPOSTO-MANDT =
ZARIV_TP_IMPOSTO-MANDT .
ZARI_TP_IMPOSTO-TIPO_IMPOSTO =
ZARIV_TP_IMPOSTO-TIPO_IMPOSTO .
ZARI_TP_IMPOSTO-CATEG_IMPOSTO =
ZARIV_TP_IMPOSTO-CATEG_IMPOSTO .
ZARI_TP_IMPOSTO-ORGAO =
ZARIV_TP_IMPOSTO-ORGAO .
    IF SY-SUBRC = 0.
    UPDATE ZARI_TP_IMPOSTO ##WARN_OK.
    ELSE.
    INSERT ZARI_TP_IMPOSTO .
    ENDIF.
    READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
    IF SY-SUBRC EQ 0.
      <XACT> = ORIGINAL.
      MODIFY EXTRACT INDEX SY-TABIX.
    ENDIF.
    <ACTION> = ORIGINAL.
    MODIFY TOTAL.
  ENDCASE.
ENDLOOP.
CLEAR: STATUS_ZARIV_TP_IMPOSTO-UPD_FLAG,
STATUS_ZARIV_TP_IMPOSTO-UPD_CHECKD.
MESSAGE S018(SV).
ENDFORM.
*---------------------------------------------------------------------*
FORM READ_SINGLE_ZARIV_TP_IMPOSTO.
  SELECT SINGLE * FROM ZARI_TP_IMPOSTO WHERE
TIPO_IMPOSTO = ZARIV_TP_IMPOSTO-TIPO_IMPOSTO .
ZARIV_TP_IMPOSTO-MANDT =
ZARI_TP_IMPOSTO-MANDT .
ZARIV_TP_IMPOSTO-TIPO_IMPOSTO =
ZARI_TP_IMPOSTO-TIPO_IMPOSTO .
ZARIV_TP_IMPOSTO-CATEG_IMPOSTO =
ZARI_TP_IMPOSTO-CATEG_IMPOSTO .
ZARIV_TP_IMPOSTO-ORGAO =
ZARI_TP_IMPOSTO-ORGAO .
ENDFORM.
*---------------------------------------------------------------------*
FORM CORR_MAINT_ZARIV_TP_IMPOSTO USING VALUE(CM_ACTION) RC.
  DATA: RETCODE LIKE SY-SUBRC, COUNT TYPE I, TRSP_KEYLEN TYPE SYFLENG.
  FIELD-SYMBOLS: <TAB_KEY_X> TYPE X.
  CLEAR RC.
MOVE ZARIV_TP_IMPOSTO-TIPO_IMPOSTO TO
ZARI_TP_IMPOSTO-TIPO_IMPOSTO .
MOVE ZARIV_TP_IMPOSTO-MANDT TO
ZARI_TP_IMPOSTO-MANDT .
  CORR_KEYTAB             =  E071K.
  CORR_KEYTAB-OBJNAME     = 'ZARI_TP_IMPOSTO'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN CORR_KEYTAB-TABKEY TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN ZARI_TP_IMPOSTO TO <TAB_KEY_X> CASTING.
  PERFORM VIM_GET_TRSPKEYLEN
    USING 'ZARI_TP_IMPOSTO'
    CHANGING TRSP_KEYLEN.
  <VIM_CORR_KEYX>(TRSP_KEYLEN) = <TAB_KEY_X>(TRSP_KEYLEN).
  PERFORM UPDATE_CORR_KEYTAB USING CM_ACTION RETCODE.
  ADD: RETCODE TO RC, 1 TO COUNT.
  IF RC LT COUNT AND CM_ACTION NE PRUEFEN.
    CLEAR RC.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
