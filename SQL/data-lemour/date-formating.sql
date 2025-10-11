-- Problem Statement:
-- The Bloomberg terminal is the go-to resource for financial professionals, offering convenient access to a wide array of financial datasets. 
-- As a Data Analyst at Bloomberg, you have access to historical data on stock performance.

-- Currently, you're analyzing the highest and lowest open prices for each FAANG stock by month over the years.

-- For each FAANG stock, display the ticker symbol, the month and year ('Mon-YYYY') with the corresponding highest and lowest open prices 
-- (refer to the Example Output format). Ensure that the results are sorted by ticker symbol.

-- Table Schema:
-- stock_prices Table:
-- | Column Name | Type      | Description |
-- |-------------|-----------|-------------|
-- | date        | datetime  | The specified date (mm/dd/yyyy) of the stock data. |
-- | ticker      | varchar   | The stock ticker symbol (e.g., AAPL) for the corresponding company. |
-- | open        | decimal   | The opening price of the stock at the start of the trading day. |
-- | high        | decimal   | The highest price reached by the stock during the trading day. |
-- | low         | decimal   | The lowest price reached by the stock during the trading day. |
-- | close       | decimal   | The closing price of the stock at the end of the trading day. |

-- Example Input:
-- Note that the table below displays randomly selected AAPL data.
-- | date        | ticker | open   | high   | low    | close  |
-- |-------------|--------|--------|--------|--------|--------|
-- | 01/31/2023 00:00:00 | AAPL | 142.28 | 142.70 | 144.34 | 144.29 |
-- | 02/28/2023 00:00:00 | AAPL | 146.83 | 147.05 | 149.08 | 147.41 |
-- | 03/31/2023 00:00:00 | AAPL | 161.91 | 162.44 | 165.00 | 164.90 |
-- | 04/30/2023 00:00:00 | AAPL | 167.88 | 168.49 | 169.85 | 169.68 |
-- | 05/31/2023 00:00:00 | AAPL | 176.76 | 177.33 | 179.35 | 177.25 |

-- Example Output:
-- | ticker | highest_mth | highest_open | lowest_mth | lowest_open |
-- |--------|-------------|--------------|------------|-------------|
-- | AAPL   | May-2023    | 176.76       | Jan-2023   | 142.28      |

WITH CTE AS 
(
  SELECT *,
    DENSE_RANK() OVER(PARTITION BY ticker ORDER BY open DESC) AS highRnk,
    DENSE_RANK() OVER(PARTITION BY ticker ORDER BY open ASC) AS lowRnk
  FROM stock_prices
)
SELECT 
  ticker,
  TO_CHAR(MIN(CASE WHEN highRnk = 1 THEN date END), 'Mon-YYYY') AS highest_mth,
  ROUND(MIN(CASE WHEN highRnk = 1 THEN open END)::NUMERIC, 2) AS highest_open,
  TO_CHAR(MIN(CASE WHEN lowRnk = 1 THEN date END), 'Mon-YYYY') AS lowest_mth,
  ROUND(MIN(CASE WHEN lowRnk = 1 THEN open END)::NUMERIC, 2) AS lowest_open
FROM CTE 
GROUP BY ticker
ORDER BY ticker ASC;
