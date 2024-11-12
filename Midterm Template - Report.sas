

*_________________________________________________*
*												  *
*		        MIDTERM TEMPLATE			      *
*		COLUMBIA DEPT. OF BIOSTATISTICS			  *
*         										  *
*												  *
*	   P6110: Statistical Computing with SAS	  *
*				 March 08, 2024				      *
*_________________________________________________* 
*												  *
* Name: Zhuodiao Kuang							  *
* UNI:  zk2275									  *
*_________________________________________________* 



/** DEFINE MACRO VARIABLES **/ ;

%let username = u63668108 ; * edit this! Enter your SAS OnDemand username;
%let name	  = Zhuodiao Kuang ;
%let uni 	  = zk2275 ;
%let date  	  = 4/19/2024 ;
%let title 	  = Hw9 Output; 

/** Specify file paths **/
%let sharedrive = /home/&username/my_shared_file_links/u63093975/Midterm;
%let localpath  = /home/&username/midtermzhuodiaokuang; * where your output should be sent;

/** Import report template for midterm **/
%include "&sharedrive/proctemplate.sas";

* ODS RTF OUTPUT;
options nodate nonumber leftmargin=1in rightmargin=1in colorprinting=yes;
* == START == ; ods rtf 
				file = "/home/u63668108/SAShomework/zk2275_FinalProject.rtf" 
				author="&name"
				startpage=never nogtitle nogfootnote image_dpi=300
				style=midterm;
* ==       == ; ods noproctitle; * supress procedure title;

%DocTitle(&title); ** START OF DOCUMENT;
%include "/home/u63668108/SAShomework/zk2275_FinalProject.sas";

* == STOP == ; ods rtf close;
