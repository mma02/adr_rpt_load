BEGIN TRY
	DROP TABLE [dbo].[DimDate]
END TRY

BEGIN CATCH
	/*No Action*/
END CATCH

/**********************************************************************************/

CREATE TABLE	[dbo].[DimDate]
	(	[DateKey] INT, 
		[Date] DATETIME null,
		[FullDate] CHAR(10) null, -- Date in dd-MM-yyyy format
		[DayOfMonth] VARCHAR(2) null, -- Field will hold day number of Month
		[DaySuffix] VARCHAR(4) null, -- Apply suffix as 1st, 2nd ,3rd etc
		[DayName] VARCHAR(9) null, -- Contains name of the day, Sunday, Monday 
		[DayOfWeek] CHAR(1) null,-- First Day Sunday=1 and Saturday=7
		[DayOfWeekInMonth] VARCHAR(2) null, --1st Monday or 2nd Monday in Month
		[DayOfWeekInYear] VARCHAR(2) null,
		[DayOfQuarter] VARCHAR(3) null,
		[DayOfYear] VARCHAR(3) null,
		[WeekOfMonth] VARCHAR(1) null,-- Week Number of Month 
		[WeekOfQuarter] VARCHAR(2) null, --Week Number of the Quarter
		[WeekOfYear] VARCHAR(2) null,--Week Number of the Year
		[Month] VARCHAR(2) null, --Number of the Month 1 to 12
		[MonthName] VARCHAR(9) null,--January, February etc
		[MonthOfQuarter] VARCHAR(2) null,-- Month Number belongs to Quarter
		[Quarter] CHAR(1) null,
		[QuarterName] VARCHAR(9) null,--First,Second..
		[Year] CHAR(4) null,-- Year value of Date stored in Row
		[YearName] CHAR(7) null, --CY 2012,CY 2013
		[MonthYear] CHAR(10) null, --Jan-2013,Feb-2013
		[MMYYYY] CHAR(6) null,
		[FirstDayOfMonth] DATE null,
		[LastDayOfMonth] DATE null,
		[FirstDayOfQuarter] DATE null,
		[LastDayOfQuarter] DATE null,
		[FirstDayOfYear] DATE null,
		[LastDayOfYear] DATE null,
		[IsWeekday] BIT null,-- 0=Week End ,1=Week Day
		[Period] int null, --YYYYMM
		[IsHoliday] BIT Null,
		[year0] int null,
		[yearM1] int null,
		[day0] int null,
		[dayM1] int null,
		[month0] int null,
		[monthM1] int  null

	)
GO

--Specify Start Date and End date here
--Value of Start Date Must be Less than Your End Date 

DECLARE @StartDate DATETIME = '01/01/1800' --Starting value of Date Range
DECLARE @EndDate DATETIME = '1/1/2100' --End Value of Date Range
DECLARE @asofdate datetime = dateadd(dd, -1,dateadd(dd,0,datediff(dd,0,getdate())))

--Temporary Variables To Hold the Values During Processing of Each Date of Year
DECLARE
	@DayOfWeekInMonth INT,
	@DayOfWeekInYear INT,
	@DayOfQuarter INT,
	@WeekOfMonth INT,
	@CurrentYear INT,
	@CurrentMonth INT,
	@CurrentQuarter INT

/*Table Data type to store the day of week count for the month and year*/
DECLARE @DayOfWeek TABLE (DOW INT, MonthCount INT, QuarterCount INT, YearCount INT)

INSERT INTO @DayOfWeek VALUES (1, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (2, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (3, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (4, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (5, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (6, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (7, 0, 0, 0)

--Extract and assign various parts of Values from Current Date to Variable

DECLARE @CurrentDate AS DATETIME = @StartDate
SET @CurrentMonth = DATEPART(MM, @CurrentDate)
SET @CurrentYear = DATEPART(YY, @CurrentDate)
SET @CurrentQuarter = DATEPART(QQ, @CurrentDate)

/********************************************************************************************/
--Proceed only if Start Date(Current date ) is less than End date you specified above

WHILE @CurrentDate <= @EndDate
BEGIN
 
/*Begin day of week logic*/

       /*Check for Change in Month of the Current date if Month changed then 
          Change variable value*/
	IF @CurrentMonth != DATEPART(MM, @CurrentDate) 
	BEGIN
		UPDATE @DayOfWeek
		SET MonthCount = 0
		SET @CurrentMonth = DATEPART(MM, @CurrentDate)
	END

        /* Check for Change in Quarter of the Current date if Quarter changed then change 
         Variable value*/

	IF @CurrentQuarter != DATEPART(QQ, @CurrentDate)
	BEGIN
		UPDATE @DayOfWeek
		SET QuarterCount = 0
		SET @CurrentQuarter = DATEPART(QQ, @CurrentDate)
	END
       
        /* Check for Change in Year of the Current date if Year changed then change 
         Variable value*/
	

	IF @CurrentYear != DATEPART(YY, @CurrentDate)
	BEGIN
		UPDATE @DayOfWeek
		SET YearCount = 0
		SET @CurrentYear = DATEPART(YY, @CurrentDate)
	END
	
        -- Set values in table data type created above from variables 

	UPDATE @DayOfWeek
	SET 
		MonthCount = MonthCount + 1,
		QuarterCount = QuarterCount + 1,
		YearCount = YearCount + 1
	WHERE DOW = DATEPART(DW, @CurrentDate)

	SELECT
		@DayOfWeekInMonth = MonthCount,
		@DayOfQuarter = QuarterCount,
		@DayOfWeekInYear = YearCount
	FROM @DayOfWeek
	WHERE DOW = DATEPART(DW, @CurrentDate)
	
/*End day of week logic*/


/* Populate Your Dimension Table with values*/

	INSERT INTO [dbo].[DimDate]
	SELECT
		
		CONVERT (char(8),@CurrentDate,112) as DateKey,
		@CurrentDate AS Date,
		CONVERT (char(10),@CurrentDate,101) as FullDate,
		DATEPART(DD, @CurrentDate) AS DayOfMonth,
		--Apply Suffix values like 1st, 2nd 3rd etc..
		CASE 
			WHEN DATEPART(DD,@CurrentDate) IN (11,12,13) THEN CAST(DATEPART(DD,@CurrentDate) AS VARCHAR) + 'th'
			WHEN RIGHT(DATEPART(DD,@CurrentDate),1) = 1 THEN CAST(DATEPART(DD,@CurrentDate) AS VARCHAR) + 'st'
			WHEN RIGHT(DATEPART(DD,@CurrentDate),1) = 2 THEN CAST(DATEPART(DD,@CurrentDate) AS VARCHAR) + 'nd'
			WHEN RIGHT(DATEPART(DD,@CurrentDate),1) = 3 THEN CAST(DATEPART(DD,@CurrentDate) AS VARCHAR) + 'rd'
			ELSE CAST(DATEPART(DD,@CurrentDate) AS VARCHAR) + 'th' 
			END AS DaySuffix,
		
		DATENAME(DW, @CurrentDate) AS DayName,
		DATEPART(DW, @CurrentDate) AS DayOfWeek,

		-- check for day of week as Per US and change it as per UK format 

		
		@DayOfWeekInMonth AS DayOfWeekInMonth,
		@DayOfWeekInYear AS DayOfWeekInYear,
		@DayOfQuarter AS DayOfQuarter,
		DATEPART(DY, @CurrentDate) AS DayOfYear,
		DATEPART(WW, @CurrentDate) + 1 - DATEPART(WW, CONVERT(VARCHAR, DATEPART(MM, @CurrentDate)) + '/1/' + CONVERT(VARCHAR, DATEPART(YY, @CurrentDate))) AS WeekOfMonth,
		(DATEDIFF(DD, DATEADD(QQ, DATEDIFF(QQ, 0, @CurrentDate), 0), @CurrentDate) / 7) + 1 AS WeekOfQuarter,
		DATEPART(WW, @CurrentDate) AS WeekOfYear,
		DATEPART(MM, @CurrentDate) AS Month,
		DATENAME(MM, @CurrentDate) AS MonthName,
		CASE
			WHEN DATEPART(MM, @CurrentDate) IN (1, 4, 7, 10) THEN 1
			WHEN DATEPART(MM, @CurrentDate) IN (2, 5, 8, 11) THEN 2
			WHEN DATEPART(MM, @CurrentDate) IN (3, 6, 9, 12) THEN 3
			END AS MonthOfQuarter,
		DATEPART(QQ, @CurrentDate) AS Quarter,
		CASE DATEPART(QQ, @CurrentDate)
			WHEN 1 THEN 'First'
			WHEN 2 THEN 'Second'
			WHEN 3 THEN 'Third'
			WHEN 4 THEN 'Fourth'
			END AS QuarterName,
		DATEPART(YEAR, @CurrentDate) AS Year,
		'CY ' + CONVERT(VARCHAR, DATEPART(YEAR, @CurrentDate)) AS YearName,
		LEFT(DATENAME(MM, @CurrentDate), 3) + '-' + CONVERT(VARCHAR, DATEPART(YY, @CurrentDate)) AS MonthYear,
		RIGHT('0' + CONVERT(VARCHAR, DATEPART(MM, @CurrentDate)),2) + CONVERT(VARCHAR, DATEPART(YY, @CurrentDate)) AS MMYYYY,
		CONVERT(DATETIME, CONVERT(DATE, DATEADD(DD, - (DATEPART(DD, @CurrentDate) - 1), @CurrentDate))) AS FirstDayOfMonth,
		CONVERT(DATETIME, CONVERT(DATE, DATEADD(DD, - (DATEPART(DD, (DATEADD(MM, 1, @CurrentDate)))), DATEADD(MM, 1, @CurrentDate)))) AS LastDayOfMonth,
		DATEADD(QQ, DATEDIFF(QQ, 0, @CurrentDate), 0) AS FirstDayOfQuarter,
		DATEADD(QQ, DATEDIFF(QQ, -1, @CurrentDate), -1) AS LastDayOfQuarter,
		CONVERT(DATETIME, '01/01/' + CONVERT(VARCHAR, DATEPART(YY, @CurrentDate))) AS FirstDayOfYear,
		CONVERT(DATETIME, '12/31/' + CONVERT(VARCHAR, DATEPART(YY, @CurrentDate))) AS LastDayOfYear,
		case when DATEPART(DW, @CurrentDate) in (2,3,4,5,6) then 1 else 0 end as IsWeekday,
		cast(cast(year(@CurrentDate) as varchar(4)) + RIGHT('00' + CONVERT(NVARCHAR(2), DATEPART(month, @CurrentDate)), 2) as int),
		null, 0,0,0,0,0,0

	SET @CurrentDate = DATEADD(DD, 1, @CurrentDate)
END



/*Update HOLIDAY Field of USA In dimension*/

--these three holidays need to be updated every year
	/*CHRISTMAS*/
	UPDATE [dbo].[DimDate]
		SET [IsHoliday] = 1
		
	WHERE [Month] = 12 AND [DayOfMonth]  = 26 and [Year] = 2016

	UPDATE [dbo].[DimDate]
		SET [IsHoliday] = 1
		
	WHERE [Month] = 12 AND [DayOfMonth]  = 23 and [Year] = 2016

	/*4th of July*/
	UPDATE [dbo].[DimDate]
		SET [IsHoliday] = 1
	WHERE [Month] = 7 AND [DayOfMonth] = 4 and [Year] = 2016

	/*New Years Day*/
	UPDATE [dbo].[DimDate]
		SET [IsHoliday] = 1
	WHERE [Month] = 1 AND [DayOfMonth] = 1 and [Year] = 2016
	
--these holidays are always the same
 	/*THANKSGIVING - Fourth THURSDAY in November*/
	UPDATE [dbo].[DimDate]
		SET [IsHoliday] = 1
	WHERE
		[Month] = 11 
		AND [DayOfWeek] = 'Thursday' 
		AND DayOfWeekInMonth = 4

	UPDATE [dbo].[DimDate]
		SET [IsHoliday] = 1
	WHERE
		[Month] = 11 
		AND [DayOfWeek] = 'Friday' 
		AND DayOfWeekInMonth = 5

	/*Memorial Day - Last Monday in May*/
	UPDATE [dbo].[DimDate]
		SET [IsHoliday] = 1
	FROM [dbo].[DimDate]
	WHERE DateKey IN 
		(
		SELECT
			MAX(DateKey)
		FROM [dbo].[DimDate]
		WHERE
			[MonthName] = 'May'
			AND [DayOfWeek]  = 'Monday'
		GROUP BY
			[Year],
			[Month]
		)

	/*Labor Day - First Monday in September*/
	UPDATE [dbo].[DimDate]
		SET [IsHoliday] = 1
	FROM [dbo].[DimDate]
	WHERE DateKey IN 
		(
		SELECT
			MIN(DateKey)
		FROM [dbo].[DimDate]
		WHERE
			[MonthName] = 'September'
			AND [DayOfWeek] = 'Monday'
		GROUP BY
			[Year],
			[Month]
		)	

	/*Martin Luthor King Day - Third Monday in January starting in 1983*/
	UPDATE [dbo].[DimDate]
		SET [IsHoliday] = 1
	WHERE
		[Month] = 1
		AND [DayOfWeek]  = 'Monday'
		AND [Year] >= 1983
		AND DayOfWeekInMonth = 3

	/*President's Day - Third Monday in February*/
	UPDATE [dbo].[DimDate]
		SET [IsHoliday] = 1
	WHERE
		[Month] = 2
		AND [DayOfWeek] = 'Monday'
		AND DayOfWeekInMonth = 3


/*Update date indicator fields*/
	--update current year
	update [dbo].[DimDate]
		set [year0] = 1
	where 
		datepart(year, @asofdate) = [Year]
		and [year0] = 0

	update [dbo].[DimDate]
		set [year0] = 0
	where 
		datepart(year, @asofdate) != [Year]
		and [year0] = 1

	--update last year
	update [dbo].[DimDate]
		set [yearM1] = 1
	where 
		datepart(year, @asofdate) = [Year]-1
		and [yearM1] = 0

	update [dbo].[DimDate]
		set [yearM1] = 0
	where 
		datepart(year, @asofdate) != [Year]-1
		and [yearM1] = 1

	--update today
	update [dbo].[DimDate]
		set [day0] = 1
	where 
		@asofdate = [Date]
		and [day0] = 0

	update [dbo].[DimDate]
		set [day0] = 0
	where 
		@asofdate != [Date]
		and [day0] = 1


	--update yesterday
	update [dbo].[DimDate]
		set [dayM1] = 1
	where 
		@asofdate = dateadd(dd, -1, [Date])
		and [dayM1] = 0

	update [dbo].[DimDate]
		set [dayM1] = 0
	where 
		@asofdate != dateadd(dd, -1, [Date])
		and [dayM1] = 1

	--update current month
	update [dbo].[DimDate]
		set [month0] = 1
	where 
		DATEADD(month, DATEDIFF(month, 0, @asofdate), 0) = [FirstDayOfMonth]
		and [month0] = 0

	update [dbo].[DimDate]
		set [month0] = 0
	where 
		DATEADD(month, DATEDIFF(month, 0, @asofdate), 0) != [FirstDayOfMonth]
		and [month0] = 1
		
	--update last month
	update [dbo].[DimDate]
		set [monthM1] = 1
	where 
		dateadd(month, -1, DATEADD(month, DATEDIFF(month, 0, @asofdate), 0)) = dateadd(month, -1, [FirstDayOfMonth])
		and [monthM1] = 0

	update [dbo].[DimDate]
		set [monthM1] = 0
	where 
		dateadd(month, -1, DATEADD(month, DATEDIFF(month, 0, @asofdate), 0)) != dateadd(month, -1, [FirstDayOfMonth])
		and [monthM1] = 1
/*****************************************************************************************/

insert into [dbo].[DimDate] ([DateKey]) values (1)

SELECT * FROM [dbo].[DimDate]

select @@config 










	