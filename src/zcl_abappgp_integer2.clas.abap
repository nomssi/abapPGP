class ZCL_ABAPPGP_INTEGER2 definition
  public
  create public .

public section.

  type-pools ABAP .
  methods IS_GT
    importing
      !IO_INTEGER type ref to ZCL_ABAPPGP_INTEGER2
    returning
      value(RV_BOOL) type ABAP_BOOL .
  class-methods CLASS_CONSTRUCTOR .
  class-methods FROM_INTEGER
    importing
      !IO_INTEGER type ref to ZCL_ABAPPGP_INTEGER
    returning
      value(RO_INTEGER) type ref to ZCL_ABAPPGP_INTEGER2 .
  class-methods FROM_STRING
    importing
      !IV_INTEGER type STRING
    returning
      value(RO_INTEGER) type ref to ZCL_ABAPPGP_INTEGER2 .
  methods ADD
    importing
      !IO_INTEGER type ref to ZCL_ABAPPGP_INTEGER2
    returning
      value(RO_RESULT) type ref to ZCL_ABAPPGP_INTEGER2 .
  methods AND
    importing
      !IO_INTEGER type ref to ZCL_ABAPPGP_INTEGER2
    returning
      value(RO_RESULT) type ref to ZCL_ABAPPGP_INTEGER2 .
  methods CLONE
    returning
      value(RO_INTEGER) type ref to ZCL_ABAPPGP_INTEGER2 .
  methods CONSTRUCTOR
    importing
      !IV_INTEGER type I default 1 .
  methods DIVIDE_BY_2
    returning
      value(RO_RESULT) type ref to ZCL_ABAPPGP_INTEGER2 .
  methods GET_BINARY_LENGTH
    returning
      value(RV_LENGTH) type I .
  methods IS_EQ
    importing
      !IO_INTEGER type ref to ZCL_ABAPPGP_INTEGER2
    returning
      value(RV_BOOL) type ABAP_BOOL .
  methods IS_ONE
    returning
      value(RV_BOOL) type ABAP_BOOL .
  methods IS_ZERO
    returning
      value(RV_BOOL) type ABAP_BOOL .
  methods MULTIPLY
    importing
      !IO_INTEGER type ref to ZCL_ABAPPGP_INTEGER2
    returning
      value(RO_RESULT) type ref to ZCL_ABAPPGP_INTEGER2 .
  methods SHIFT_RIGHT
    importing
      !IV_TIMES type I
    returning
      value(RO_RESULT) type ref to ZCL_ABAPPGP_INTEGER2 .
  methods SUBTRACT
    importing
      !IO_INTEGER type ref to ZCL_ABAPPGP_INTEGER2
    returning
      value(RO_RESULT) type ref to ZCL_ABAPPGP_INTEGER2 .
  methods TO_INTEGER
    returning
      value(RO_INTEGER) type ref to ZCL_ABAPPGP_INTEGER .
  methods TO_STRING
    returning
      value(RV_INTEGER) type STRING .
protected section.

  types TY_SPLIT type I .
  types:
    ty_split_tt TYPE STANDARD TABLE OF ty_split WITH DEFAULT KEY .

  data MT_SPLIT type TY_SPLIT_TT .
  class-data GV_MAX type I value 8192. "#EC NOTEXT .
  class-data GV_BITS type I value 13. "#EC NOTEXT .
  class-data GO_MAX type ref to ZCL_ABAPPGP_INTEGER .
  class-data:
    gt_powers TYPE STANDARD TABLE OF REF TO zcl_abappgp_integer WITH DEFAULT KEY .

  methods REMOVE_LEADING_ZEROS .
private section.
ENDCLASS.



CLASS ZCL_ABAPPGP_INTEGER2 IMPLEMENTATION.


  METHOD add.

    DATA: lv_max   TYPE i,
          lv_carry TYPE ty_split,
          lv_op1   TYPE ty_split,
          lv_op2   TYPE ty_split,
          lv_index TYPE i.


    ro_result = me.

    lv_max = nmax( val1 = lines( io_integer->mt_split )
                   val2 = lines( mt_split ) ).

    DO lv_max TIMES.
      lv_index = sy-index.

      CLEAR: lv_op1,
             lv_op2.

      READ TABLE mt_split INDEX lv_index INTO lv_op1.     "#EC CI_SUBRC
      READ TABLE io_integer->mt_split INDEX lv_index INTO lv_op2. "#EC CI_SUBRC

      lv_op1 = lv_op1 + lv_op2 + lv_carry.

      lv_carry = lv_op1 DIV gv_max.
      lv_op1 = lv_op1 - lv_carry * gv_max.

      MODIFY mt_split INDEX lv_index FROM lv_op1.
      IF sy-subrc <> 0.
        APPEND lv_op1 TO mt_split.
      ENDIF.
    ENDDO.

    IF lv_carry <> 0.
      lv_index = lv_max + 1.
      MODIFY mt_split INDEX lv_index FROM lv_carry.
      IF sy-subrc <> 0.
        APPEND lv_carry TO mt_split.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD and.

    DATA: lv_hres   TYPE x LENGTH 2,
          lv_hex1   TYPE x LENGTH 2,
          lv_hex2   TYPE x LENGTH 2,
          lv_lines  TYPE i,
          lt_result LIKE mt_split,
          lv_split  LIKE LINE OF mt_split.


    lv_lines = nmin( val1 = lines( io_integer->mt_split )
                     val2 = lines( mt_split ) ).

    DO lv_lines TIMES.
      READ TABLE io_integer->mt_split INTO lv_hex1 INDEX sy-index.
      READ TABLE mt_split INTO lv_hex2 INDEX sy-index.

      lv_hres = lv_hex1 BIT-AND lv_hex2.
      APPEND lv_hres TO lt_result.
    ENDDO.

    mt_split = lt_result.

    WHILE lines( mt_split ) > 0.
      READ TABLE mt_split INDEX lines( mt_split ) INTO lv_split.
      IF lv_split = 0.
        DELETE mt_split INDEX lines( mt_split ).
      ELSE.
        EXIT. " current loop
      ENDIF.
    ENDWHILE.

    ro_result = me.

  ENDMETHOD.


  METHOD class_constructor.

    CREATE OBJECT go_max
      EXPORTING
        iv_integer = 1.

    APPEND go_max TO gt_powers.

    CREATE OBJECT go_max
      EXPORTING
        iv_integer = gv_max.

    APPEND go_max TO gt_powers.

  ENDMETHOD.


  METHOD clone.

    CREATE OBJECT ro_integer.
    ro_integer->mt_split = mt_split.

  ENDMETHOD.


  METHOD constructor.

    ASSERT iv_integer >= 0.
    ASSERT iv_integer < gv_max.

    APPEND iv_integer TO mt_split.

  ENDMETHOD.


  METHOD divide_by_2.

    DATA: lv_index TYPE i,
          lv_value TYPE ty_split,
          lv_carry TYPE ty_split.


    lv_index = lines( mt_split ) + 1.

    DO lines( mt_split ) TIMES.
      lv_index = lv_index - 1.

      READ TABLE mt_split INDEX lv_index INTO lv_value.

      lv_value = lv_value + lv_carry * gv_max.
      lv_carry = lv_value MOD 2.
      lv_value = lv_value DIV 2.

      MODIFY mt_split INDEX lv_index FROM lv_value.
    ENDDO.

* remove leading zero, note: there can only be one when dividing with 2
    READ TABLE mt_split INTO lv_value INDEX lines( mt_split ).
    IF lv_value = 0 AND lines( mt_split ) > 1.
      DELETE mt_split INDEX lines( mt_split ).
    ENDIF.

    ro_result = me.

  ENDMETHOD.


  METHOD from_integer.

    DATA: lv_hex   TYPE x LENGTH 2, " 16 bits
          lv_count TYPE i VALUE 16,
          lv_int   TYPE i,
          lo_int   TYPE REF TO zcl_abappgp_integer.


    ASSERT io_integer->is_positive( ) = abap_true.

    CREATE OBJECT ro_integer.
    CLEAR ro_integer->mt_split.

    lo_int = io_integer->clone( ).

    WHILE lo_int->is_zero( ) = abap_false.
      IF lo_int->mod_2( ) = 1.
        SET BIT lv_count OF lv_hex.
      ENDIF.

      IF lv_count = 4.
        lv_count = 16.

        lv_int = lv_hex.
        APPEND lv_int TO ro_integer->mt_split.
        CLEAR lv_hex.
      ELSE.
        lv_count = lv_count - 1.
      ENDIF.

      lo_int->divide_by_2( ).
    ENDWHILE.

    IF NOT lv_hex IS INITIAL.
      lv_int = lv_hex.
      APPEND lv_int TO ro_integer->mt_split.
    ENDIF.

  ENDMETHOD.


  METHOD from_string.
* input = base 10

    ASSERT iv_integer CO '0123456789'.

    IF iv_integer = '0'.
      CREATE OBJECT ro_integer
        EXPORTING
          iv_integer = 0.
    ELSE.
      ro_integer = from_integer( zcl_abappgp_integer=>from_string( iv_integer ) ).
    ENDIF.

  ENDMETHOD.


  METHOD get_binary_length.

    DATA: lv_split LIKE LINE OF mt_split,
          lv_bit   TYPE c LENGTH 1,
          lv_hex   TYPE x LENGTH 2.


    IF is_zero( ) = abap_true.
      rv_length = 1.
    ENDIF.

    IF lines( mt_split ) > 1.
      rv_length = ( lines( mt_split ) - 1 ) * gv_bits.
    ENDIF.

    READ TABLE mt_split INDEX lines( mt_split ) INTO lv_split.
    lv_hex = lv_split.
    DO 16 TIMES.
      GET BIT sy-index OF lv_hex INTO lv_bit.
      IF lv_bit = '1'.
        rv_length = rv_length + 17 - sy-index.
        RETURN.
      ENDIF.
    ENDDO.

  ENDMETHOD.


  METHOD is_eq.

    FIELD-SYMBOLS: <lv_op1> LIKE LINE OF mt_split,
                   <lv_op2> LIKE LINE OF mt_split.


    IF lines( mt_split ) <> lines( io_integer->mt_split ).
      rv_bool = abap_false.
      RETURN.
    ENDIF.

    DO lines( mt_split ) TIMES.
      READ TABLE mt_split INDEX 1 ASSIGNING <lv_op1>.
      ASSERT sy-subrc = 0.
      READ TABLE io_integer->mt_split INDEX 1 ASSIGNING <lv_op2>.
      ASSERT sy-subrc = 0.

      IF <lv_op1> <> <lv_op2>.
        rv_bool = abap_false.
        RETURN.
      ENDIF.
    ENDDO.

    rv_bool = abap_true.

  ENDMETHOD.


  METHOD is_gt.

    DATA: lv_index   TYPE i,
          lv_op1     TYPE ty_split,
          lv_op2     TYPE ty_split,
          lv_length1 TYPE i,
          lv_length2 TYPE i.


    lv_length1 = lines( mt_split ).
    lv_length2 = lines( io_integer->mt_split ).

    IF lv_length1 > lv_length2.
      rv_bool = abap_true.
      RETURN.
    ELSEIF lv_length1 < lv_length2.
      rv_bool = abap_false.
      RETURN.
    ENDIF.

    rv_bool = abap_false.

    DO lines( mt_split ) TIMES.
      lv_index = lines( mt_split ) - sy-index + 1.

      READ TABLE mt_split INDEX lv_index INTO lv_op1.
      ASSERT sy-subrc = 0.
      READ TABLE io_integer->mt_split INDEX lv_index INTO lv_op2.
      ASSERT sy-subrc = 0.

      IF lv_op1 > lv_op2.
        rv_bool = abap_true.
        EXIT.
      ELSEIF lv_op1 < lv_op2.
        rv_bool = abap_false.
        EXIT.
      ENDIF.
    ENDDO.

  ENDMETHOD.


  METHOD is_one.

    DATA: lv_split LIKE LINE OF mt_split.


    rv_bool = abap_false.

    IF lines( mt_split ) = 1.
      READ TABLE mt_split INDEX 1 INTO lv_split.
      rv_bool = boolc( lv_split = 1 ).
    ENDIF.

  ENDMETHOD.


  METHOD is_zero.

    DATA: lv_split LIKE LINE OF mt_split.


    rv_bool = abap_false.

    IF lines( mt_split ) = 1.
      READ TABLE mt_split INDEX 1 INTO lv_split.
      rv_bool = boolc( lv_split = 0 ).
    ENDIF.

  ENDMETHOD.


  METHOD multiply.

    DATA: lv_index  TYPE i,
          lv_index1 TYPE i,
          lv_op     TYPE ty_split,
          lv_add    TYPE ty_split,
          lv_carry  TYPE ty_split,
          lt_result LIKE mt_split.

    FIELD-SYMBOLS: <lv_result> TYPE ty_split,
                   <lv_op1>    TYPE ty_split,
                   <lv_op2>    TYPE ty_split.


    ro_result = me.

    IF is_zero( ) = abap_true OR io_integer->is_zero( ) = abap_true.
      CLEAR mt_split.
      APPEND 0 TO mt_split.
      RETURN.
    ENDIF.

    LOOP AT mt_split ASSIGNING <lv_op1>.
      lv_index1 = sy-tabix.
      LOOP AT io_integer->mt_split ASSIGNING <lv_op2>.
        lv_index = lv_index1 + sy-tabix - 1.

        READ TABLE lt_result INDEX lv_index ASSIGNING <lv_result>.
        IF sy-subrc <> 0.
          APPEND INITIAL LINE TO lt_result ASSIGNING <lv_result>.
        ENDIF.

        lv_op = <lv_op1> * <lv_op2>.
        lv_add = lv_op MOD gv_max.
        <lv_result> = <lv_result> + lv_add.

        lv_carry = <lv_result> DIV gv_max + lv_op DIV gv_max.
        <lv_result> = <lv_result> MOD gv_max.

        WHILE lv_carry <> 0.
          lv_index = lv_index + 1.
          READ TABLE lt_result INDEX lv_index ASSIGNING <lv_result>.
          IF sy-subrc <> 0.
            APPEND INITIAL LINE TO lt_result ASSIGNING <lv_result>.
          ENDIF.
* carry might trigger the next carry
          <lv_result> = <lv_result> + lv_carry.
          lv_carry    = <lv_result> DIV gv_max.
          <lv_result> = <lv_result> MOD gv_max.
        ENDWHILE.

      ENDLOOP.
    ENDLOOP.

    mt_split = lt_result.

  ENDMETHOD.


  METHOD remove_leading_zeros.

    DATA: lv_lines TYPE i,
          lv_value TYPE ty_split.


    lv_lines = lines( mt_split ) + 1.

    DO.
      lv_lines = lv_lines - 1.

      READ TABLE mt_split INTO lv_value INDEX lv_lines.

      IF lv_value = 0 AND lv_lines <> 1.
        DELETE mt_split INDEX lv_lines.
        ASSERT sy-subrc = 0.
      ELSE.
        EXIT.
      ENDIF.
    ENDDO.

  ENDMETHOD.


  METHOD shift_right.

    DO iv_times TIMES.
      ro_result = divide_by_2( ).
    ENDDO.

  ENDMETHOD.


  METHOD subtract.

    DATA: lv_max   TYPE i,
          lv_carry TYPE ty_split,
          lv_op1   TYPE ty_split,
          lv_op2   TYPE ty_split,
          lv_index TYPE i.


    ro_result = me.

    ASSERT is_gt( io_integer ) = abap_true
      OR is_eq( io_integer ) = abap_true.

    lv_max = nmax( val1 = lines( io_integer->mt_split )
                   val2 = lines( mt_split ) ).

    DO lv_max TIMES.
      lv_index = sy-index.

      CLEAR: lv_op1,
             lv_op2.

      READ TABLE mt_split INDEX lv_index INTO lv_op1.     "#EC CI_SUBRC
      READ TABLE io_integer->mt_split INDEX lv_index INTO lv_op2. "#EC CI_SUBRC

      lv_op1 = lv_op1 - lv_op2 - lv_carry.
      lv_carry = 0.

      IF lv_op1 < 0.
        lv_op1 = lv_op1 + gv_max.
        lv_carry = 1.
      ENDIF.

      MODIFY mt_split INDEX lv_index FROM lv_op1.
      ASSERT sy-subrc = 0.
    ENDDO.

    ASSERT lv_carry = 0.

    remove_leading_zeros( ).

  ENDMETHOD.


  METHOD to_integer.

    DATA: lv_split LIKE LINE OF mt_split,
          lo_split TYPE REF TO zcl_abappgp_integer,
          lo_int   TYPE REF TO zcl_abappgp_integer.


    CREATE OBJECT ro_integer
      EXPORTING
        iv_integer = 0.

    LOOP AT mt_split INTO lv_split.
      READ TABLE gt_powers INTO lo_int INDEX sy-tabix.
      IF sy-subrc <> 0.
        ASSERT lo_int IS BOUND.
        lo_int = lo_int->clone( )->multiply( go_max ).
        APPEND lo_int TO gt_powers.
      ENDIF.

      CREATE OBJECT lo_split
        EXPORTING
          iv_integer = lv_split.
      ro_integer = ro_integer->add( lo_split->multiply( lo_int ) ).
    ENDLOOP.

  ENDMETHOD.


  METHOD to_string.
* output integer base 10

    rv_integer = to_integer( )->to_string( ).

  ENDMETHOD.
ENDCLASS.