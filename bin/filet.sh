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

./acvc_a2.sh
./acvc_a3.sh
./acvc_a5.sh
./acvc_a6.sh
./acvc_a7.sh
./acvc_a8.sh

echo "          --------------"
echo "          COMPILE TLALOC"
echo "          --------------"
./comp_ada_comp.sh A


