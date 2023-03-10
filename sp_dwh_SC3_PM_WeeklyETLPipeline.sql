USE [ServerFarmStaging]
GO
/****** Object:  StoredProcedure [MAN].[sp_dwh_SC3_PM_WeeklyETLPipeline]    Script Date: 15.12.2022 10:34:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


/*|*************************
** @Name: [MAN].[sp_dwh_SC3_PM_WeeklyETLPipeline]
*************************
** @Desc: SP for SC3 PM load into DWH
*************************
** @Parameters:
	 @etl_batch_id varchar(42) = NULL
	,@etl_process_id int
	,@current_date date
*************************
** @Use Case: load pipeline into dwh
*************************|*/



ALTER PROCEDURE [MAN].[sp_dwh_SC3_PM_WeeklyETLPipeline]
(
	 @etl_batch_id varchar(42) = NULL
	,@etl_process_id int
	,@current_date date
)
AS
BEGIN

	set ansi_warnings off;
	declare 
	 @expected int = 0
	,@input int = 0
	,@error_message varchar(4000)
	,@row_count int = 0;



	declare @SC3_PM_Weekly TABLE
	(
		[No.] [int] NULL,
		[Problem ID] [char](10) NOT NULL,
		[Phase] [varchar](max) NULL,
		[Status] [varchar](max) NULL,
		[Title] [varchar](max) NULL,
		[Related Incident Count] [int] NULL,
		[Reported CI] [varchar](max) NULL,
		[Reported CI Company/Plant] [varchar](max) NULL,
		[Reported CI - CI Maintainer - OE] [varchar](max) NULL,
		[Reported CI Riskclass] [tinyint] NULL,
		[Reported CI Type] [varchar](max) NULL,
		[Reported CI Subtype] [varchar](max) NULL,
		[Reported CI Environment] [varchar](max) NULL,
		[Reported CI Status] [varchar](max) NULL,
		[Layer 1] [varchar](max) NULL,
		[Layer 2] [varchar](max) NULL,
		[Layer 3] [varchar](max) NULL,
		[Root Cause CI] [varchar](max) NULL,
		[Root Cause CI Company/Plant] [varchar](max) NULL,
		[Root Cause CI - CI Maintainer - OE] [varchar](max) NULL,
		[Root Cause CI Riskclass] [float] NULL,
		[Root Cause CI Type] [varchar](max) NULL,
		[Root Cause CI Subtype] [varchar](max) NULL,
		[Root Cause CI Environment] [varchar](max) NULL,
		[Root Cause CI Status] [varchar](max) NULL,
		[Root Cause CI Layer 1] [varchar](max) NULL,
		[Root Cause CI Layer 2] [varchar](max) NULL,
		[Root Cause CI Layer 3] [varchar](max) NULL,
		[Problem Manager Group] [varchar](max) NULL,
		[Problem Manager Group - Company/Plant] [varchar](max) NULL,
		[Problem Manager Group - OE] [varchar](max) NULL,
		[External] [varchar](max) NULL,
		[Reference ID] [varchar](max) NULL,
		[Description] [varchar](max) NULL,
		[Detection] [varchar](max) NULL,
		[Root Cause Description] [varchar](max) NULL,
		[Workaround available] [varchar](max) NULL,
		[Workaround proofed] [varchar](max) NULL,
		[Workaround] [varchar](max) NULL,
		[Avoidance] [varchar](max) NULL,
		[Solution] [varchar](max) NULL,
		[Impact] [tinyint] NULL,
		[Priority] [tinyint] NULL,
		[Impact Description] [varchar](max) NULL,
		[Root Cause Date Estimated] [varchar](max) NULL,
		[Solution Date Estimated] [varchar](max) NULL,
		[Resolution Date Estimated] [datetime] NULL,
		[Root Cause Date Completed] [datetime] NULL,
		[Solution Date Completed] [datetime] NULL,
		[Resolution Date Completed] [datetime] NULL,
		[Closure Code] [varchar](max) NULL,
		[Cause Area] [varchar](max) NULL,
		[Cause Code] [varchar](max) NULL,
		[Review Process] [varchar](max) NULL,
		[Closure Comment] [varchar](max) NULL,
		[Problem Candidate marked] [datetime] NULL,
		[Problem Opened] [datetime] NULL,
		[Problem Updated] [datetime] NULL,
		[Problem Closed] [datetime] NULL,
		[TPM Status] [float] NULL,
		[Top Problem] [float] NULL,
		[EndOfWeek] [char](19) NOT NULL,
		[Closure Reason] [varchar](max) NULL
	);


	PRINT('Procedure logic...')
	if( @etl_batch_id is not null)
	begin

		-- 2. checks - batch is not complete
		if((select 
			count(*)
			from [dbo].[DS_ETL_PROCESS_RUNS] 
			where etl_process_id = @etl_process_id
			and etl_batch_dataset in 
			(
				'SC3_PM_Weekly'
			)
			and etl_run_end is not null
			and etl_batch_id  = @etl_batch_id 
			and cast(etl_run_start as date) = @current_date
			) < 1
		) 
		begin
			print 'last batch is not complete';
			throw 50001, N'last batch is not complete', 2;
		end
		

		insert into @SC3_PM_Weekly
		(
			 [No.]
			,[Problem ID]
			,[Phase]
			,[Status]
			,[Title]
			,[Related Incident Count]
			,[Reported CI]
			,[Reported CI Company/Plant]
			,[Reported CI - CI Maintainer - OE]
			,[Reported CI Riskclass]
			,[Reported CI Type]
			,[Reported CI Subtype]
			,[Reported CI Environment]
			,[Reported CI Status]
			,[Layer 1]
			,[Layer 2]
			,[Layer 3]
			,[Root Cause CI]
			,[Root Cause CI Company/Plant]
			,[Root Cause CI - CI Maintainer - OE]
			,[Root Cause CI Riskclass]
			,[Root Cause CI Type]
			,[Root Cause CI Subtype]
			,[Root Cause CI Environment]
			,[Root Cause CI Status]
			,[Root Cause CI Layer 1]
			,[Root Cause CI Layer 2]
			,[Root Cause CI Layer 3]
			,[Problem Manager Group]
			,[Problem Manager Group - Company/Plant]
			,[Problem Manager Group - OE]
			,[External]
			,[Reference ID]
			,[Description]
			,[Detection]
			,[Root Cause Description]
			,[Workaround available]
			,[Workaround proofed]
			,[Workaround]
			,[Avoidance]
			,[Solution]
			,[Impact]
			,[Priority]
			,[Impact Description]
			,[Root Cause Date Estimated]
			,[Solution Date Estimated]
			,[Resolution Date Estimated]
			,[Root Cause Date Completed]
			,[Solution Date Completed]
			,[Resolution Date Completed]
			,[Closure Code]
			,[Cause Area]
			,[Cause Code]
			,[Review Process]
			,[Closure Comment]
			,[Problem Candidate marked]
			,[Problem Opened]
			,[Problem Updated]
			,[Problem Closed]
			,[TPM Status]
			,[Top Problem]
			,[EndOfWeek]
			,[Closure Reason]
		)
		select 
			   [no] as [no.]
		      ,[problem_id] as [problem id]
		      ,[phase]
		      ,[status]
		      ,[title]
		      ,[related_incidents_count] as [related incident count]
		      ,[reported_ci_-_id] as [reported ci]
		      ,[reported_ci_-_company] as [reported ci company/plant]
		      ,[reported_ci_-_responsible_department] as [reported ci - ci maintainer - oe]
		      ,[reported_ci_-_risk_class] as [reported ci riskclass]
		      ,[reported_ci_-_type] as [reported ci type]
		      ,[reported_ci_-_subtype] as [reported ci subtype]
		      ,[reported_ci_-_environment] as [reported ci environment]
		      ,[reported_ci_-_status] as [reported ci status]
		      ,null as [layer 1]
		      ,null as [layer 2]
		      ,null as [layer 3]
		      ,[rootcause_ci_-_id] as [root cause ci]
		      ,[rootcause_ci_-_company] as [root cause ci company/plant]
		      ,[rootcause_ci_-_responsible_department] as [root cause ci - ci maintainer - oe]
		      ,[rootcause_ci_-_risk_class] as [root cause ci riskclass]
		      ,[rootcause_ci_-_type] as [root cause ci type]
		      ,[rootcause_ci_-_subtype] as [root cause ci subtype]
		      ,[rootcause_ci_-_environment] as [root cause ci environment]
		      ,[rootcause_ci_-_status] as [root cause ci status]
		      ,null as [root cause ci layer 1]
		      ,null as [root cause ci layer 2]
		      ,null as [root cause ci layer 3]
		      ,[problem_manager_group] as [problem manager group]
		      ,[problem_manager_group_-_company] as [problem manager group - company/plant]
		      ,[problem_manager_group_-_responsible_department] as [problem manager group - oe]
		      ,[external]
		      ,[reference_id] as [reference id]
		      ,[description]
		      ,null as [detection]
		      ,[root_cause_description] as [root cause description]
		      ,[workaround_available] as [workaround available]
		      ,null as [workaround proofed]
		      ,[workaround]
		      ,null as [avoidance]
		      ,[solution]
		      ,[impact]
		      ,[priority]
		      ,[impact_description] as [impact description]
		      ,[estimated_rootcause_time] as [root cause date estimated]
		      ,[estimated_solution_time] as [solution date estimated]
		      ,[estimated_resolution_time] as [resolution date estimated]
		      ,[completed_rootcause_time] as [root cause date completed]
		      ,[completed_solution_time] as [solution date completed]
		      ,[completed_resolution_time] as [resolution date completed]
		      ,[closure_code] as [closure code]
		      ,null as [cause area]
		      ,null as [cause code]
		      ,null as [review process]
		      ,[closure_description] as [closure comment]
		      ,null as [problem candidate marked]
		      ,[open_time] as [problem opened]
		      ,[update_time] as [problem updated]
		      ,[close_time] as [problem closed]
		      ,null as [tpm status]
		      ,[major_problem] as [top problem]
		      ,[endofweek]
		      ,null as [closure reason]
		from [serverfarmstaging].[dbo].[sc3_pm_weekly]
		where Load_Date = @current_date
		and batch_id = @etl_batch_id;




		-- 4. load
		if (@@ERROR = 0)
		begin
			--select * from @SC3_IM_Weekly;

			insert into [dbo].[MAN_SC2_problems_weekly]
			select
			 [No.]
			,[Problem ID]
			,[Phase]
			,[Status]
			,[Title]
			,[Related Incident Count]
			,[Reported CI]
			,[Reported CI Company/Plant]
			,[Reported CI - CI Maintainer - OE]
			,[Reported CI Riskclass]
			,[Reported CI Type]
			,[Reported CI Subtype]
			,[Reported CI Environment]
			,[Reported CI Status]
			,[Layer 1]
			,[Layer 2]
			,[Layer 3]
			,[Root Cause CI]
			,[Root Cause CI Company/Plant]
			,[Root Cause CI - CI Maintainer - OE]
			,[Root Cause CI Riskclass]
			,[Root Cause CI Type]
			,[Root Cause CI Subtype]
			,[Root Cause CI Environment]
			,[Root Cause CI Status]
			,[Root Cause CI Layer 1]
			,[Root Cause CI Layer 2]
			,[Root Cause CI Layer 3]
			,[Problem Manager Group]
			,[Problem Manager Group - Company/Plant]
			,[Problem Manager Group - OE]
			,[External]
			,[Reference ID]
			,[Description]
			,[Detection]
			,[Root Cause Description]
			,[Workaround available]
			,[Workaround proofed]
			,[Workaround]
			,[Avoidance]
			,[Solution]
			,[Impact]
			,[Priority]
			,[Impact Description]
			,[Root Cause Date Estimated]
			,[Solution Date Estimated]
			,[Resolution Date Estimated]
			,[Root Cause Date Completed]
			,[Solution Date Completed]
			,[Resolution Date Completed]
			,[Closure Code]
			,[Cause Area]
			,[Cause Code]
			,[Review Process]
			,[Closure Comment]
			,[Problem Candidate marked]
			,[Problem Opened]
			,[Problem Updated]
			,[Problem Closed]
			,[TPM Status]
			,[Top Problem]
			,[EndOfWeek]
			,[Closure Reason]
			,@etl_batch_id
			from @SC3_PM_Weekly;

			select @row_count = count(*) from @SC3_PM_Weekly;

			print 'Loaded rows into [dbo].[MAN_SC2_problems_weekly]: ' + cast(@row_count as varchar);
			set @error_message = 'Loaded rows into [dbo].[MAN_SC2_problems_weekly]: ' + cast(@row_count as varchar);
			exec [dbo].[sp_ds_LogETLProcessError] 
				 @etl_batch_id = @etl_batch_id
				,@etl_process_error_category = 'Information'
				,@etl_process_error_severity = 0
				,@etl_process_error_message	= @error_message;



		end
		else
		begin
			print 'Batch loading failed for batch_id: ' + @etl_batch_id + '; Date: ' + cast( @current_date as varchar(10)); 
			set @error_message = N'Batch loading failed for batch_id: ' + @etl_batch_id + '; Date: ' + cast( @current_date as varchar(10)); 
			throw 50004, @error_message, 2;
		end;

	end
	--else
	--begin
	--	print 'successful load for ' + cast( @current_date as varchar(10)) + ' is not found'; 
	--	set @error_message = N'successful load for ' + cast( @current_date as varchar(10)) + ' is not found'; 
	--	throw 50004, @error_message, 2;
	--end;

END
