LDC97T19=/export/corpora/LDC/LDC97T19
LDC2002T38=/export/corpora/LDC/LDC2002T38
LDC2002T39=/export/corpora/LDC/LDC2002T39

all:
	@./bin/callhome_data_prep.sh ${LDC97T19} ${LDC2002T38} ${LDC2002T39}

clean:
	@rm corpus/*.ar
	@rm -rf links tmp
