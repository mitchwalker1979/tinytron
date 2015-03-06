.PHONY: all clean test loader

PART = xc3s250e-cp132

all: top.bit test

top.prj: *.v
	### Write project file.
	:> top.prj
	for f in *.v; do echo "verilog work $$f" >> top.prj; done

top.syr top.ngc: top.prj
	### SYNTHESIZING
	mkdir -p xst/projnav.tmp/
	xst -ifn top.xst -ofn top.syr
	rm -r xst/projnav.tmp/

top.ngd: top.ucf top.ngc
	### PROCESS CONSTRAINTS
	mkdir -p _ngo
	ngdbuild -dd _ngo -nt timestamp -uc top.ucf -p $(PART) top.ngc top.ngd
	rm -r _ngo

top_map.ncd: top.ngd
	### MAPPING
	map -p $(PART) -cm area -ir off -pr off -c 100 -o top_map.ncd top.ngd top.pcf

top.ncd: top_map.ncd
	### PLANNING AND ROUTING
	par -w -ol high -t 1 top_map.ncd top.ncd top.pcf

# This seems unecessary-- at least, trivial projects seem to build properly without it.
#top.twr: top.ncd
#	### TRACING
#	trce -v 3 -s 4 -n 3 -fastpaths -xml top.twx top.ncd -o top.twr top.pcf -ucf top.ucf

top.bit: top.ncd
	### GENERATING IMAGE
	bitgen -f top.ut top.ncd

test: top.bit
	### LOADING ON BOARD (VOLATILE)
	echo "Y" | djtgcfg prog -d Basys2 -i 0 -f top.bit

loader: top.bit
	### LOADING ON PROM
	djtgcfg prog -d Basys2 -i 1 -f top.bit

clean:
	rm -f top.prj top.bld top.lso top_map.map top_map.mrp top_map.ncd top_map.ngm top_map.xrpt top.ngc top.ngd top_ngdbuild.xrpt top.ngr top.pcf top_summary.xml top.syr top_usage.xml top_xst.xrpt
	rm -f top.ncd top.pad top_pad.csv top_pad.txt top.par top_par.xrpt top.ptwx top.twr top.twx top.unroutes top.xpi top.bgn top_bitgen.xwbt top.drc usage_statistics_webtalk.html webtalk.log
	rm -rf xlnx_auto_0_xdb _xmsgs xst _ngo


