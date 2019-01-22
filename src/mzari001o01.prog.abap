*&---------------------------------------------------------------------*
*&  Include           MZARI001O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_1000  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_1000 OUTPUT.
  SET PF-STATUS sy-dynnr.
  SET TITLEBAR sy-dynnr.

  CHECK sy-uname(6) <> 'ABAPBR'.
  LOOP AT SCREEN.
    CASE screen-name.
      WHEN 'SUB1100'.
        IF gv_auth_apu01 = abap_true.
          screen-active = 1.
        ELSE.
          screen-active = 0.
        ENDIF.
      WHEN 'SUB1200'.
        IF gv_auth_rec01 = abap_true.
          screen-active = 1.
        ELSE.
          screen-active = 0.
        ENDIF.
      WHEN 'SUB1300'.
        IF gv_auth_consu = abap_true.
          screen-active = 1.
        ELSE.
          screen-active = 0.
        ENDIF.
      WHEN 'SUB1400'.
        IF gv_auth_man01 = abap_true.
          screen-active = 1.
        ELSE.
          screen-active = 0.
        ENDIF.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.
ENDMODULE.

MODULE status_1100 OUTPUT.
  PERFORM create_controls_1100.
ENDMODULE.

MODULE status_1200 OUTPUT.
  CHECK tab_cockpit-activetab = 'SUB1200'.
  PERFORM create_controls_1200.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  STATUS_1300  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_1300 OUTPUT.

  CHECK tab_cockpit-activetab = 'SUB1300'.

  PERFORM create_controls_1300.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  INITIALIZATION  OUTPUT
*&---------------------------------------------------------------------*
MODULE initialization OUTPUT.
  CHECK gt_rg_resp[] IS INITIAL.

  PERFORM seleciona_resp CHANGING gt_rg_resp.

  PERFORM set_autorizacoes.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  STATUS_1400  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_1400 OUTPUT.
  CHECK tab_cockpit-activetab = 'SUB1400'.

  PERFORM create_controls_1400.

  loop at screen.
    case screen-name.

      when 'WA_1400_MANUT-NUM_DOC_APURACAO'.
        if  wa_1400_manut-pre_estorno is initial
        and wa_1400_manut-apu_estorno is initial
        and wa_1400_manut-rec_estorno is initial.
          screen-input = 0.
          clear wa_1400_manut-num_doc_apuracao.
        endif.

      when 'WA_1400_MANUT-PRE_ATUALIZ'.
        if gv_auth_man02 = abap_false.
          screen-input = 0.
        endif.

      when 'WA_1400_MANUT-PRE_ESTORNO'.
        if gv_auth_man03 = abap_false.
          screen-input = 0.
        endif.

      when 'WA_1400_MANUT-APU_ESTORNO'.
        if gv_auth_man04 = abap_false.
          screen-input = 0.
        endif.

      when 'WA_1400_MANUT-REC_ESTORNO'.
        if gv_auth_man05 = abap_false.
          screen-input = 0.
        endif.

      when others.
        continue.
    endcase.
    modify screen.
  endloop.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_1210  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_1210 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
  SET TITLEBAR '1210'.

* Abre campos para INPUT quando possível
  loop at screen.
    case screen-group1.
      when 'INP'.
        if  gs_1210_bkpf_alv-doc_pre_editado is initial
        and gs_1210_bkpf_alv-doc_referencia  is INITIAL.
          screen-input = 1.
        else.
          screen-input = 0.
        endif.
        modify screen.
      when others.
    endcase.
  endloop.
ENDMODULE.
