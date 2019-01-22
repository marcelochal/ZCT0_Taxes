*&---------------------------------------------------------------------*
*&  Include           MZARI001I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_exit INPUT.
  LEAVE PROGRAM.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1000 INPUT.
  IF gv_okcode(3) = 'SUB'.
    tab_cockpit-activetab = gv_okcode.
  ENDIF.
  CLEAR gv_okcode.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1210  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1210 INPUT.

* Dependendo do botão clicado,
  CASE gv_okcode.
    WHEN 'CONF'.
      CLEAR gv_okcode.
      LEAVE TO SCREEN 0.
    WHEN 'CANC'.
      CLEAR gs_1210_bkpf_alv.
      CLEAR gv_okcode.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  PAI_1210_ATUALIZA_RECOLHIMENTO  INPUT
*&---------------------------------------------------------------------*
* Atualiza valor total de recolhimento
*----------------------------------------------------------------------*
MODULE pai_1210_atualiza_recolhimento INPUT.

* Calcula o valor total do recolhimento
  PERFORM calcula_recolhimento CHANGING gs_1210_bkpf_alv.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1400 INPUT.

* Dependendo do comando,
  CASE gv_okcode.

*   Marcar todos: categoria de imposto
    WHEN '1400_MALL_11'.
*      perform pai_mall_uall using    'X'  "marcar
*                            changing gt_1400_categ.
*
*      perform refresh_salv_11 using    go_1400_salv11
*                                       go_1400_salv12
*                                       go_1400_salv13
*                                       go_1400_salv14
*                                       gt_1400_categ
*                              changing gt_1400_tp_imposto
*                                       gt_1400_cod_imposto
*                                       gt_1400_empresa
*                                       gt_1400_emprdiv.
      CLEAR gv_okcode.

*   Marcar todos: tipo de imposto
    WHEN '1400_MALL_12'.
      PERFORM pai_mall_uall USING    'X'  "marcar
                            CHANGING gt_1400_tp_imposto.

      PERFORM refresh_salv_12 USING    go_1400_salv12
                                       go_1400_salv13
                                       go_1400_salv14
                                       gt_1400_tp_imposto
                              CHANGING gt_1400_cod_imposto
                                       gt_1400_empresa
                                       gt_1400_emprdiv.
      CLEAR gv_okcode.

*   Marcar todos: código de imposto
    WHEN '1400_MALL_13'.
      PERFORM pai_mall_uall USING    'X'  "marcar
                            CHANGING gt_1400_cod_imposto.

      PERFORM refresh_salv_13 USING    go_1400_salv13
                                       go_1400_salv14
                                       gt_1400_cod_imposto
                              CHANGING gt_1400_empresa
                                       gt_1400_emprdiv.
      CLEAR gv_okcode.

*   Marcar todos: empresa-divisão
    WHEN '1400_MALL_14'.
*      perform pai_mall_uall using    'X'  "marcar
*                            changing gt_1400_emprdiv.
*      go_1400_salv14->refresh( ).
      CLEAR gv_okcode.

*   Desmarcar todos: categoria de imposto
    WHEN '1400_UALL_11'.
      PERFORM pai_mall_uall USING    space  "desmarcar
                            CHANGING gt_1400_categ.

      PERFORM refresh_salv_11 USING    go_1400_salv11
                                       go_1400_salv12
                                       go_1400_salv13
                                       go_1400_salv14
                                       gt_1400_categ
                              CHANGING gt_1400_tp_imposto
                                       gt_1400_cod_imposto
                                       gt_1400_empresa
                                       gt_1400_emprdiv.
      CLEAR gv_okcode.

*   Desmarcar todos: tipo de imposto
    WHEN '1400_UALL_12'.
      PERFORM pai_mall_uall USING    space  "desmarcar
                            CHANGING gt_1400_tp_imposto.

      PERFORM refresh_salv_12 USING    go_1400_salv12
                                       go_1400_salv13
                                       go_1400_salv14
                                       gt_1400_tp_imposto
                              CHANGING gt_1400_cod_imposto
                                       gt_1400_empresa
                                       gt_1400_emprdiv.
      CLEAR gv_okcode.

*   Desmarcar todos: código de imposto
    WHEN '1400_UALL_13'.
      PERFORM pai_mall_uall USING    space  "desmarcar
                            CHANGING gt_1400_cod_imposto.

      PERFORM refresh_salv_13 USING    go_1400_salv13
                                       go_1400_salv14
                                       gt_1400_cod_imposto
                              CHANGING gt_1400_empresa
                                       gt_1400_emprdiv.
      CLEAR gv_okcode.

*   Desmarcar todos: empresa-divisão
    WHEN '1400_UALL_14'.
      PERFORM pai_mall_uall USING    space  "desmarcar
                            CHANGING gt_1400_emprdiv.

      go_1400_salv14->refresh( ).
      CLEAR gv_okcode.

*   Executar manutenção
    WHEN 'MANUT'.

*     Executa a ação de manutenção selecionada
      PERFORM user_command_1400_manut USING    wa_1400_manut
                                               gt_1400_empresa
                                               gt_1400_emprdiv
                                               gt_1400_cod_imposto.
      CLEAR gv_okcode.

    WHEN OTHERS.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1100 INPUT.

* Dependendo do comando,
  CASE gv_okcode.

*   Marcar todos: categoria de imposto
    WHEN '1100_MALL_11'.
      PERFORM pai_mall_uall USING    'X'  "marcar
                            CHANGING gt_1100_categ.

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
      CLEAR gv_okcode.

*   Marcar todos: tipo de imposto
    WHEN '1100_MALL_12'.
      PERFORM pai_mall_uall USING    'X'  "marcar
                            CHANGING gt_1100_tp_imposto.

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
      CLEAR gv_okcode.

*   Marcar todos: código de imposto
    WHEN '1100_MALL_13'.
      PERFORM pai_mall_uall USING    'X'  "marcar
                            CHANGING gt_1100_cod_imposto.

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
      CLEAR gv_okcode.

*   Marcar todos: empresa-divisão
    WHEN '1100_MALL_14'.
      PERFORM pai_mall_uall USING    'X'  "marcar
                            CHANGING gt_1100_emprdiv.

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
      REFRESH: gt_1100_bseg.
      go_1100_salv14->refresh( ).
      go_1100_salv22->refresh( refresh_mode = if_salv_c_refresh=>full ). "atualizar subtotais etc
      go_1100_salv31->refresh( refresh_mode = if_salv_c_refresh=>full ). "atualizar subtotais etc
      CLEAR gv_okcode.

*   Marcar todos: documentos
    WHEN '1100_MALL_22'.
      PERFORM pai_mall_uall USING    'X'  "marcar
                            CHANGING gt_1100_bkpf.
      go_1100_salv22->refresh( refresh_mode = if_salv_c_refresh=>full ). "atualizar subtotais etc

*   Desmarcar todos: categoria de imposto
    WHEN '1100_UALL_11'.
      PERFORM pai_mall_uall USING    space  "desmarcar
                            CHANGING gt_1100_categ.

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
      CLEAR gv_okcode.

*   Desmarcar todos: tipo de imposto
    WHEN '1100_UALL_12'.
      PERFORM pai_mall_uall USING    space  "desmarcar
                            CHANGING gt_1100_tp_imposto.

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
      CLEAR gv_okcode.

*   Desmarcar todos: código de imposto
    WHEN '1100_UALL_13'.
      PERFORM pai_mall_uall USING    space  "desmarcar
                            CHANGING gt_1100_cod_imposto.

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
      CLEAR gv_okcode.

*   Desmarcar todos: empresa-divisão
    WHEN '1100_UALL_14'.
      PERFORM pai_mall_uall USING    space  "desmarcar
                            CHANGING gt_1100_emprdiv.

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
      REFRESH: gt_1100_bseg.
      go_1100_salv14->refresh( ).
      go_1100_salv22->refresh( refresh_mode = if_salv_c_refresh=>full ). "atualizar subtotais etc
      go_1100_salv31->refresh( refresh_mode = if_salv_c_refresh=>full ). "atualizar subtotais etc
      CLEAR gv_okcode.

*   Desmarcar todos: documentos
    WHEN '1100_UALL_22'.
      PERFORM pai_mall_uall USING    space  "desmarcar
                            CHANGING gt_1100_bkpf.
      go_1100_salv22->refresh( refresh_mode = if_salv_c_refresh=>full ). "atualizar subtotais etc

    WHEN OTHERS.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1200 INPUT.

* Dependendo do comando,
  CASE gv_okcode.

*   Marcar todos: categoria de imposto
    WHEN '1200_MALL_11'.
      PERFORM pai_mall_uall USING    'X'  "marcar
                            CHANGING gt_1200_categ.

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
      CLEAR gv_okcode.

*   Marcar todos: tipo de imposto
    WHEN '1200_MALL_12'.
      PERFORM pai_mall_uall USING    'X'  "marcar
                            CHANGING gt_1200_tp_imposto.

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
      CLEAR gv_okcode.

*   Marcar todos: código de imposto
    WHEN '1200_MALL_13'.
      PERFORM pai_mall_uall USING    'X'  "marcar
                            CHANGING gt_1200_cod_imposto.

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
      CLEAR gv_okcode.

*   Marcar todos: empresa-divisão
    WHEN '1200_MALL_14'.
      PERFORM pai_mall_uall USING    'X'  "marcar
                            CHANGING gt_1200_emprdiv.

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
      REFRESH: gt_1200_bseg.
      go_1200_salv14->refresh( ).
      go_1200_salv22->refresh( refresh_mode = if_salv_c_refresh=>full ). "atualizar subtotais etc
      go_1200_salv31->refresh( refresh_mode = if_salv_c_refresh=>full ). "atualizar subtotais etc
      CLEAR gv_okcode.

*   Desmarcar todos: documentos
    WHEN '1200_MALL_22'.
      PERFORM pai_mall_uall USING    'X'  "marcar
                            CHANGING gt_1200_bkpf.
      go_1200_salv22->refresh( refresh_mode = if_salv_c_refresh=>full ). "atualizar subtotais etc

*   Desmarcar todos: categoria de imposto
    WHEN '1200_UALL_11'.
      PERFORM pai_mall_uall USING    space  "desmarcar
                            CHANGING gt_1200_categ.

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
      CLEAR gv_okcode.

*   Desmarcar todos: tipo de imposto
    WHEN '1200_UALL_12'.
      PERFORM pai_mall_uall USING    space  "desmarcar
                            CHANGING gt_1200_tp_imposto.

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
      CLEAR gv_okcode.

*   Desmarcar todos: código de imposto
    WHEN '1200_UALL_13'.
      PERFORM pai_mall_uall USING    space  "desmarcar
                            CHANGING gt_1200_cod_imposto.

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
      CLEAR gv_okcode.

*   Desmarcar todos: empresa-divisão
    WHEN '1200_UALL_14'.
      PERFORM pai_mall_uall USING    space  "desmarcar
                            CHANGING gt_1200_emprdiv.

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
      REFRESH: gt_1200_bseg.
      go_1200_salv14->refresh( ).
      go_1200_salv22->refresh( refresh_mode = if_salv_c_refresh=>full ). "atualizar subtotais etc
      go_1200_salv31->refresh( refresh_mode = if_salv_c_refresh=>full ). "atualizar subtotais etc
      CLEAR gv_okcode.

*   Desmarcar todos: documentos
    WHEN '1200_UALL_22'.
      PERFORM pai_mall_uall USING    space  "desmarcar
                            CHANGING gt_1200_bkpf.
      go_1200_salv22->refresh( refresh_mode = if_salv_c_refresh=>full ). "atualizar subtotais etc

    WHEN OTHERS.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  M_VALIDA_CODIGO_BARRAS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE M_VALIDA_CODIGO_BARRAS INPUT.
** Valida código de barras
*  PERFORM f_valida_codigo_barras.
ENDMODULE.
