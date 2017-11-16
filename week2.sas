/*建lib*/
libname sem_2 "F:\SASproject\week2";
/*导入数据*/
DATA sem_2.return_week (Label="周个股回报率文件");
Infile "F:\SASproject\week2\TRD_Week.txt" delimiter = '09'x Missover Dsd lrecl=32767 firstobs=2;
Format Stkcd $6.;
Format Trdwnt $7.;
Format Opndt $10.;
Format Wopnprc 8.3;
Format Clsdt $10.;
Format Wclsprc 8.3;
Format Wnshrtrd 14.;
Format Wnvaltrd 14.2;
Format Wsmvosd 16.2;
Format Wsmvttl 16.2;
Format Ndaytrd 2.;
Format Wretwd 10.6;
Format Wretnd 10.6;
Format Markettype 10.;
Format Capchgdt $10.;
Informat Stkcd $6.;
Informat Trdwnt $7.;
Informat Opndt $10.;
Informat Wopnprc 8.3;
Informat Clsdt $10.;
Informat Wclsprc 8.3;
Informat Wnshrtrd 14.;
Informat Wnvaltrd 14.2;
Informat Wsmvosd 16.2;
Informat Wsmvttl 16.2;
Informat Ndaytrd 2.;
Informat Wretwd 10.6;
Informat Wretnd 10.6;
Informat Markettype 10.;
Informat Capchgdt $10.;
Input Stkcd $ Trdwnt $ Opndt $ Wopnprc Clsdt $ Wclsprc Wnshrtrd Wnvaltrd Wsmvosd Wsmvttl Ndaytrd Wretwd Wretnd Markettype Capchgdt $ ;
Run;
data sem_2.return_week;
	set sem_2.return_week;
	if Markettype in (1,4);
run;
proc sort data = sem_2.return_week;
	by Trdwnt;
run;
proc means data = sem_2.return_week noprint;
	var Wretwd;
	freq Wsmvosd;/*or weight*/
	by Trdwnt;
	output out = temp1 mean = return_market;
run;
proc sql;
	create table sem_2.mkr as 
	select * from 
	(select * from sem_2.return_week) a
	left join 
	(select Trdwnt, return_market from temp1) b
	on
	a.Trdwnt = b.Trdwnt
	order by Stkcd, Trdwnt
	;
quit;
data sem_2.mkr;
	set sem_2.mkr;
	year = input(substr(Opndt,1,4),4.);
	month = input(substr(Opndt,6,2),2.);
run;
data sem_2.mkr;
	set sem_2.mkr;
	return_free = 0.01;
run;
data sem_2.mkr;
	set sem_2.mkr;
	prm_mk = return_market - return_free;
	prm_stk = Wretwd - return_free;
run;
proc sort data = sem_2.mkr;
	by Stkcd;
run;
proc reg data = sem_2.mkr outest = sem_2.para noprint;
	model prm_stk = prm_mk;
	by Stkcd;
run;