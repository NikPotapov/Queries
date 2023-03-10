USE [APG]
GO
/****** Object:  StoredProcedure [apg].[sp_dwh_apg_WanInterfaceCalculation_pipline]    Script Date: 15.12.2022 10:25:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [apg].[sp_dwh_apg_WanInterfaceCalculation_pipline] 
AS
BEGIN

	SET NOCOUNT ON
	declare
	@Load_Date varchar(10) = FORMAT(getdate(), 'dd-MM-yyyy');
	
	-- Clear table before inserting new values
	DELETE FROM [apg].[WanInterfaceCalculation];
	
	--Create the first temporary table with defined Mbps/Bps correct values
	With temp as (SELECT *,			
					Concat(Upper(Device), '-', Part) AS Device_Part,		
					CASE WHEN [VariableName] = 'Availability' THEN NULL ELSE [Value] * 0.000008 END AS Mpbs,		
					CASE WHEN [VariableName] = 'Availability' THEN NULL ELSE [Value] * 8 END AS Bps,		
					CASE WHEN [VariableName] = 'Availability' THEN [Value] / 100 ELSE NULL END AS Procento, 		
					CASE WHEN [VariableName] LIKE '%In%' THEN [Value] * 0.000008 ELSE NULL END AS IN_Mbps,		
					CASE WHEN [VariableName] LIKE '%Out%' THEN [Value] * 0.000008 ELSE NULL END AS OUT_Mbps,		
					CASE WHEN [VariableName] LIKE '%In%' THEN [Value] * 8 ELSE NULL END AS IN_Bps, 		
					CASE WHEN [VariableName] LIKE '%Out%' THEN [Value] * 8 ELSE NULL END AS OUT_Bps		
				FROM  services.APGRawValues AS ser LEFT JOIN			
							[APG].[apg].[WanInterface] AS
							wan ON ser.Device = wan.Switch AND
							ser.Part = wan.Interface),
		-- Create the second temporary table with 95% calculation
		procentoTable as (SELECT DISTINCT		
							Device_Part,
							round(percentile_cont(.95) within GROUP (ORDER BY [Mpbs]) OVER (PARTITION BY [Device_Part]), 4) AS Mbps_95,
							round(percentile_cont(.95) within GROUP (ORDER BY [IN_Mbps]) OVER (PARTITION BY [Device_Part]), 4) AS IN_Mbps_95, 
							round(percentile_cont(.95) within GROUP (ORDER BY [OUT_Mbps]) OVER (PARTITION BY [Device_Part]), 4) AS OUT_Mbps_95,
							round(percentile_cont(.95) within GROUP (ORDER BY [Bps]) OVER (PARTITION BY [Device_Part]), 4) AS Bps_95,
							round(percentile_cont(.95) within GROUP (ORDER BY [IN_Bps]) OVER (PARTITION BY [Device_Part]), 4) AS IN_Bps_95,
							round(percentile_cont(.95) within GROUP (ORDER BY [OUT_Bps]) OVER (PARTITION BY [Device_Part]), 4) AS OUT_Bps_95,
							[Port speed]
						FROM temp		
								Where [Port speed] Is not NULL)
   
   -- Insert data into table from the third data selecting
	Insert Into [apg].[WanInterfaceCalculation] (	Device_Part,
													Mbps_95,
													IN_Mbps_95,
													OUT_Mbps_95,
													Bps_95,
													IN_Bps_95,
													OUT_Bps_95,
													Port_speed,
													Bps_95_procento,
													IN_Bps_95_procento,
													OUT_Bps_95_procento,
													Mbps_95_procento, 
													IN_Mbps_95_procento,
													OUT_Mbps_95_procento,
													Load_Date
													)
	SELECT 											
				*,
				round(Bps_95 / [Port speed] * 0.0001, 3) AS Bps_95_procento,		
				round(IN_Bps_95 / [Port speed] * 0.0001, 3) AS IN_Bps_95_procento,		
				round(OUT_Bps_95 / [Port speed] * 0.0001, 3) AS OUT_Bps_95_procento,		
				round(Mbps_95 / [Port speed] * 100, 3) AS Mbps_95_procento, 		
				round(IN_Mbps_95 / [Port speed] * 100, 3) AS IN_Mbps_95_procento,				
				round(OUT_Mbps_95 / [Port speed] * 100, 3) AS OUT_Mbps_95_procento,
				@Load_Date
	FROM procentoTable
		Where Mbps_95 IS not Null 


	if (@@ERROR = 0)
		begin
		print ' Upload into WanInterfaceCalculation is failed! '
	end 

END