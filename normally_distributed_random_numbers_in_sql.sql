DECLARE @NumSamples bigint;
SET @NumSamples = 100000;

-- Generate random numbers based on Sorenzo-Epure approximation: https://dmi.units.it/~soranzo/epureAMS85-88-2014%202.pdf
WITH NORMAL_RNG AS (
    SELECT 
    (10.0 / LOG(41.0)) * 
    LOG(
        1 - 
        (LOG(
            (-LOG(0.003+RAND(CHECKSUM(NEWID()))*0.994)) / LOG(2)
        ) / LOG(22))) AS RandomSample,
	   0.003+RAND(CHECKSUM(NEWID()))*0.994 AS Src
    FROM (
        SELECT TOP (@NumSamples) 
            ROW_NUMBER() OVER (ORDER BY t1.number) AS N
        FROM master..spt_values t1
        CROSS JOIN master..spt_values t2
    ) AS NumberSource
)
SELECT * FROM NORMAL_RNG

-- Generate random numbers based on the Box-Muller algorithm: https://en.wikipedia.org/wiki/Box%E2%80%93Muller_transform
WITH NORMAL_RNG AS (
    SELECT
SQRT(-2.0 * LOG(RAND(CHECKSUM(NEWID())))) * COS(2.0 * (22 / 7) * RAND(CHECKSUM(NEWID()))) AS RandomSample
    FROM (
        SELECT TOP (@NumSamples) 
            ROW_NUMBER() OVER (ORDER BY t1.number) AS N
        FROM master..spt_values t1
        CROSS JOIN master..spt_values t2
    ) AS NumberSource
)
SELECT * FROM NORMAL_RNG;

-- Generate random numbers based on the Irwin-Hall approximation: https://en.wikipedia.org/wiki/Irwin%E2%80%93Hall_distribution
WITH NORMAL_RNG AS (
    SELECT 
        @mu + @sigma * (
            RAND(CHECKSUM(NEWID())) + RAND(CHECKSUM(NEWID())) + RAND(CHECKSUM(NEWID())) + RAND(CHECKSUM(NEWID())) +
            RAND(CHECKSUM(NEWID())) + RAND(CHECKSUM(NEWID())) + RAND(CHECKSUM(NEWID())) + RAND(CHECKSUM(NEWID())) +
            RAND(CHECKSUM(NEWID())) + RAND(CHECKSUM(NEWID())) + RAND(CHECKSUM(NEWID())) + RAND(CHECKSUM(NEWID()))
         - 6) AS RandomSample
    FROM (
        SELECT TOP (@Max - @Min + 1) 
            @Min - 1 + ROW_NUMBER() OVER (ORDER BY t1.number) AS N
        FROM master..spt_values t1
        CROSS JOIN master..spt_values t2
    ) AS NumberSource
)
-- Select the result from the CTE
SELECT * FROM NORMAL_RNG;