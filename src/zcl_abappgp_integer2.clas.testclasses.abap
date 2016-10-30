CLASS ltcl_and DEFINITION FOR TESTING
    DURATION SHORT
    RISK LEVEL HARMLESS
    FINAL.

  PRIVATE SECTION.
    METHODS:
      and1 FOR TESTING,
      and2 FOR TESTING,
      and3 FOR TESTING,
      and4 FOR TESTING.

    METHODS:
      test IMPORTING iv_op1           TYPE string
                     iv_op2           TYPE string
           RETURNING VALUE(rv_result) TYPE string.

ENDCLASS.       "ltcl_Get

CLASS ltcl_and IMPLEMENTATION.

  METHOD test.

    DATA: lo_binary1  TYPE REF TO zcl_abappgp_integer2,
          lo_binary2  TYPE REF TO zcl_abappgp_integer2.


    lo_binary1 = zcl_abappgp_integer2=>from_string( iv_op1 ).
    lo_binary2 = zcl_abappgp_integer2=>from_string( iv_op2 ).

    rv_result = lo_binary1->and( lo_binary2 )->to_string( ).

  ENDMETHOD.

  METHOD and1.

    DATA: lv_result TYPE string.

    lv_result = test( iv_op1 = '16'
                      iv_op2 = '16' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_result
      exp = '16' ).

  ENDMETHOD.

  METHOD and2.

    DATA: lv_result TYPE string.

    lv_result = test( iv_op1 = '32'
                      iv_op2 = '16' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_result
      exp = '0' ).

  ENDMETHOD.

  METHOD and3.

    DATA: lv_result TYPE string.

    lv_result = test( iv_op1 = '48'
                      iv_op2 = '16' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_result
      exp = '16' ).

  ENDMETHOD.

  METHOD and4.

    DATA: lv_result TYPE string.

    lv_result = test( iv_op1 = '8191'
                      iv_op2 = '8192' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_result
      exp = '0' ).

  ENDMETHOD.

ENDCLASS.

CLASS ltcl_binary_length DEFINITION FOR TESTING DURATION SHORT RISK LEVEL HARMLESS FINAL.

  PRIVATE SECTION.
    METHODS:
      length1 FOR TESTING,
      length2 FOR TESTING,
      length3 FOR TESTING.

    METHODS: test
      IMPORTING iv_string TYPE string
      iv_expected TYPE i.

ENDCLASS.

CLASS ltcl_binary_length IMPLEMENTATION.

  METHOD test.

    DATA: lo_var1   TYPE REF TO zcl_abappgp_integer2,
          lv_result TYPE i.


    lo_var1 = zcl_abappgp_integer2=>from_string( iv_string ).
    lv_result = lo_var1->get_binary_length( ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_result
      exp = iv_expected ).

  ENDMETHOD.

  METHOD length1.
    test( iv_string   = '8191'
          iv_expected = 13 ).
  ENDMETHOD.

  METHOD length2.
    test( iv_string   = '8192'
          iv_expected = 14 ).
  ENDMETHOD.

  METHOD length3.
    test( iv_string   = '1'
          iv_expected = 1 ).
  ENDMETHOD.

ENDCLASS.

CLASS ltcl_identity DEFINITION FOR TESTING DURATION SHORT RISK LEVEL HARMLESS FINAL.

  PRIVATE SECTION.
    METHODS:
      id1 FOR TESTING,
      id2 FOR TESTING,
      id3 FOR TESTING,
      id4 FOR TESTING,
      id5 FOR TESTING,
      id6 FOR TESTING,
      id7 FOR TESTING,
      id8 FOR TESTING.

    METHODS: test IMPORTING iv_string TYPE string.

ENDCLASS.

CLASS ltcl_identity IMPLEMENTATION.

  METHOD test.

    DATA: lo_var1   TYPE REF TO zcl_abappgp_integer2,
          lv_result TYPE string.


    lo_var1 = zcl_abappgp_integer2=>from_string( iv_string ).

    lv_result = lo_var1->to_string( ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_result
      exp = iv_string ).

  ENDMETHOD.

  METHOD id1.
    test( '1' ).
  ENDMETHOD.

  METHOD id2.
    test( '0' ).
  ENDMETHOD.

  METHOD id3.
    test( '8191' ).
  ENDMETHOD.

  METHOD id4.
    test( '8192' ).
  ENDMETHOD.

  METHOD id5.
    test( '123456789123456789' ).
  ENDMETHOD.

  METHOD id6.
    test( '1000000000000000000000000009' ).
  ENDMETHOD.

  METHOD id7.
    test( '10000000000000000000000000009' ).
  ENDMETHOD.

  METHOD id8.
    test( '12345678' ).
  ENDMETHOD.

ENDCLASS.