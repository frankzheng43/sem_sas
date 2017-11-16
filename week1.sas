/*建lib*/
libname sem_1 "F:\SASproject\week1";
/*导入收益数据*/
data sem_1.return_month;
infile "F:\SASproject\week1\TRD_Mnth.txt" delimiter = '09'x missover dsd lrecl=32767 firstobs=2;
format stock $6.;
format date $7.;
format returnw 10.6;
format returnn 10.6;
informat stock $6.;
informat date $7.;
informat returnw 10.6;
informat returnn 10.6;
input stock $ date returnw returnn ;
Run;
/*导入资产负债表数据*/
data sem_1.fin_statement;
infile "F:\SASproject\week1\FS_Combas.txt" delimiter = '09'x missover dsd lrecl=32767 firstobs=2;
format stock $6.;
format accper $10.;
format reptype $1.;
format asset 20.2;
format liability 20.2;
informat stock $6.;
informat accper $10.;
informat reptype $1.;
informat asset 20.2;
informat liability 20.2;
input stock $ accper $ reptype $ asset liability ;
Run;
data sem_1.fin_statement;
	set sem_1.fin_statement;
	if reptype = "A";
run;
/*日期*/
data sem_1.return_month;
	set sem_1.return_month;
	year = input(substr(date,1,4),4.);
	month = input(substr(date,6,2),2.);
	quarter = ceil(month/3);
run;
data sem_1.fin_statement;
	set sem_1.fin_statement;
	year = input(substr(accper,1,4),4.);
	quarter = ceil(input(substr(accper,6,2),2.)/3);
run;
/*排序*/
proc sort data = sem_1.fin_statement out = sem_1.fin_statement;
	by stock year quarter;
run;
proc sort data = sem_1.return_month out = sem_1.return_month;
	by stock year quarter;
run;
/*只保留12月的数据*/
data sem_1.fin_statement;
	set sem_1.fin_statement;
	by stock year;
	if last.year;
run;

/*合并*/
proc sql;
	create table sem_1.re_fin as
	select * from 
	(select * from sem_1.return_month) a
	left join
	(select * from sem_1.fin_statement) b
	on 
	a.stock = b.stock and  a.year = b.year
	order by stock, year, month
	;
quit;

/*合并2*/
proc sort data = sem_1.fin_statement out = sem_1.fin_statement;
	by stock year quarter;
run;
proc sort data = sem_1.return_month out = sem_1.return_month;
	by stock year quarter;
run;
data sem_1.re_fin1;
	merge sem_1.return_month sem_1.fin_statement;
	by stock year;
run;