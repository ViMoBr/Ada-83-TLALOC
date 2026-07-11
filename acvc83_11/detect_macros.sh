grep -h '\$[A-Z_]*' *.tst | grep -o '\$[A-Z_0-9]*' | sort -u
