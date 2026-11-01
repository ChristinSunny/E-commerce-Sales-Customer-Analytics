E-commerce Sales & Customer Analytics

End-to-end analysis of a multi-table e-commerce dataset using Excel Power Query, SQL Server (SSMS) and Power BI. The project covers data cleaning, 31 SQL queries, and a 2-page interactive dashboard tracking sales, customers, products, payments and refunds.

Dataset

Six related tables, all amounts in USD:

Table	Rows	Description
orders	100,000	Order status, dates, subtotal, tax, shipping, total
order_items	237,537	Products, quantity, unit price, discount, line total
customers	20,000	Country, acquisition channel, customer segment
products	1,200	Category, product name, unit cost
payments	105,388	Payment method and status
refunds	7,910	Refund reason, amount, date
Tools
Excel Power Query: cleaning duplicates, inconsistent text values and data-quality issues
SQL Server (SSMS): KPI and analysis queries (CTEs, window functions, multi-table joins)
Power BI: data model, DAX measures, interactive dashboard
Repository structure
Ecommerce/
├── raw/          # Raw sample files
├── Clean/        # Cleaned tables (CSV + Cleaned.xlsx)
├── SS.sql        # 31 SQL Server queries
└── dasss.pbix    # Power BI dashboard
KPI definitions
Sales Revenue: sum of line_total for completed orders
Net Sales: sum of line_total for non-cancelled orders minus refunds
Average Order Value: total order_total of completed orders divided by number of completed orders
Refund Rate: orders with a refund divided by all orders
Repeat Customer Rate: customers with more than one order divided by customers who ordered
SQL analysis (SS.sql)
Order metrics: total, cancelled and completed orders, cancellation and completion rates
Revenue: total revenue, net sales after refunds, AOV, monthly revenue, month-over-month growth (using LAG)
Customers: repeat customer rate, average orders per customer, revenue by segment and acquisition channel, top 10 customers
Products: units sold, top 10 products, revenue by category, gross profit and margin, products never ordered
Payments and refunds: payment success rate, collected amount by payment method, refund amount, refund reasons, failed payments, refund rate
Data quality: orders without a matching customer
Dashboard

Page 1 - Sales overview: Total Orders, Sales Revenue, Gross Sales, Net Sales, Average Order Value, Gross Profit, Cancellation %, Units Sold, Refund Amount. Visuals: revenue trend, orders by status, revenue by country, revenue by category and product. Slicers: country, order status, category.

Page 2 - Customers, payments and refunds: Unique Customers, Repeat Customer Rate, Payment Success %, Refund Rate %, Average Refund Value, Cancelled Orders. Visuals: top 10 customers, revenue by acquisition channel and customer segment, payment status breakdown. Slicers: country, customer segment, acquisition channel.

Key findings
Metric	Value
Total orders	100,000 (89,114 completed)
Sales revenue (completed orders)	$54.03M
Net sales	$55.33M
Gross profit	$27.23M (50.4% margin)
Average order value	$655.27
Cancellation rate	2.98%
Refund rate	7.91% ($3.39M refunded)
Payment success rate	92.06%
Repeat customer rate	96.33%
The US contributes 63.6% of revenue; the other four countries (GB, CA, AU, DE) each contribute 8-10%.
Revenue is flat at about $18M per year across 2023-2025.
Consumers drive 82.1% of revenue; organic is the largest acquisition channel at 30.3%.
Revenue and margin are evenly spread across categories (15.8-17.2% of revenue, 49.5-51.3% margin), with no standout category.
Refund reasons are almost evenly split across damaged, duplicate, customer return and late delivery (about 24-26% each).
How to run
Create a database in SQL Server (SSMS) and import the CSV files from Clean/ as tables.
Run SS.sql to reproduce the analysis.
Open Dashboard.pbix in Power BI Desktop and refresh the data source to your local files.
Author

Christin Sunny
