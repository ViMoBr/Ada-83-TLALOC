echo "COMPILE PREDEF"

./comp_predef_units.sh

echo "          -----------------"
echo "          COMPILE ENUM_TEST"
echo "          -----------------"

./a83.sh ./ ./enum_test.adb W
./a83.sh ./ ./enum_test.adb B
cd ./ADA__LIB
./fasmg ENUM_TEST.fas ENUM_TEST
chmod u+x ENUM_TEST
./ENUM_TEST rouge
cd ..

echo "          ----------------------"
echo "          COMPILE DIRECT_IO_TEST"
echo "          ----------------------"
./a83.sh ./ ./direct_io_test.adb W
./a83.sh ./ ./direct_io_test.adb B
cd ./ADA__LIB
./fasmg DIRECT_IO_TEST.fas DIRECT_IO_TEST
chmod u+x DIRECT_IO_TEST
./DIRECT_IO_TEST
cd ..

echo "          -------------------"
echo "          COMPILE SEQ_IO_TEST"
echo "          -------------------"
./a83.sh ./ ./seq_io_test.adb W
./a83.sh ./ ./seq_io_test.adb B
cd ./ADA__LIB
./fasmg SEQ_IO_TEST.fas SEQ_IO_TEST
chmod u+x SEQ_IO_TEST
./SEQ_IO_TEST
cd ..

echo "          ---------------------"
echo "          COMPILE TEST_CALENDAR"
echo "          ---------------------"
./a83.sh ./ ./test_calendar.adb W
./a83.sh ./ ./test_calendar.adb B
cd ./ADA__LIB
./fasmg TEST_CALENDAR.fas TEST_CALENDAR
chmod u+x TEST_CALENDAR
./TEST_CALENDAR
cd ..

echo "          ---------------------------"
echo "          COMPILE FLOAT_TEST"
echo "          ---------------------------"
./a83.sh ./ ./float_test.adb W
./a83.sh ./ ./float_test.adb B
cd ./ADA__LIB
./fasmg FLOAT_TEST.fas FLOAT_TEST
chmod u+x FLOAT_TEST
./FLOAT_TEST
cd ..

echo "          ---------------------------"
echo "          COMPILE FLOAT_FIXED_IO_TEST"
echo "          ---------------------------"
./a83.sh ./ ./float_fixed_io_test.adb W
./a83.sh ./ ./float_fixed_io_test.adb B
cd ./ADA__LIB
./fasmg FLOAT_FIXED_IO_TEST.fas FLOAT_FIXED_IO_TEST
chmod u+x FLOAT_FIXED_IO_TEST
./FLOAT_FIXED_IO_TEST
cd ..

echo "          -----------------"
echo "          COMPILE GOTO_TEST"
echo "          -----------------"
./a83.sh ./ ./goto_test.adb W
./a83.sh ./ ./goto_test.adb B
cd ./ADA__LIB
./fasmg GOTO_TEST.fas GOTO_TEST
chmod u+x GOTO_TEST
./GOTO_TEST
cd ..

echo "          -----------------"
echo "          COMPILE CONV_DER1"
echo "          -----------------"
./a83.sh ./ ./conv_der1.adb W
./a83.sh ./ ./conv_der1.adb B
cd ./ADA__LIB
./fasmg CONV_DER1.fas CONV_DER1
chmod u+x CONV_DER1
./CONV_DER1
cd ..

echo "          -----------------"
echo "          COMPILE CASE_ST1"
echo "          -----------------"
./a83.sh ./ ./case_st1.adb W
./a83.sh ./ ./case_st1.adb B
cd ./ADA__LIB
./fasmg CASE_ST1.fas CASE_ST1
chmod u+x CASE_ST1
./CASE_ST1
cd ..

echo "          ---------------"
echo "          COMPILE ARRINI1"
echo "          ---------------"
./a83.sh ./ ./arrini1.adb W
./a83.sh ./ ./arrini1.adb B
cd ./ADA__LIB
./fasmg ARRINI1.fas ARRINI1
chmod u+x ARRINI1
./ARRINI1
cd ..

echo "          --------------"
echo "          COMPILE SLICE1"
echo "          --------------"
./a83.sh ./ ./slice1.adb W
./a83.sh ./ ./slice1.adb B
cd ./ADA__LIB
./fasmg SLICE1.fas SLICE1
chmod u+x SLICE1
./SLICE1
cd ..

echo "          --------------"
echo "          COMPILE INSTF1"
echo "          --------------"
./a83.sh ./ ./inst1.adb W
./a83.sh ./ ./instf1.adb B
cd ./ADA__LIB
./fasmg INSTF1.fas INSTF1
chmod u+x INSTF1
./INSTF1
cd ..

echo "          ----------------"
echo "          COMPILE ADDR_OV1"
echo "          ----------------"
./a83.sh ./ ./addr_ov1.adb W
./a83.sh ./ ./addr_ov1.adb B
cd ./ADA__LIB
./fasmg ADDR_OV1.fas ADDR_OV1
chmod u+x ADDR_OV1
./ADDR_OV1
cd ..

echo "          --------------"
echo "          COMPILE TLALOC"
echo "          --------------"
./comp_ada_comp.sh A >out.txt


