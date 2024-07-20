## 1) Indexing:

### What is indexing:
Indexes are a common way to enhance database performance because they allow the database server to find and retrieve specific rows much faster than it could do without an index. This speed-up occurs because an index creates a sorted data structure (such as a B-tree or hash table) that allows the database to perform quick lookups, binary searches, and efficient retrieval of rows that match specific query conditions.

```sql
--Sessions Table: Index on start_time and end_time columns to speed up the filtering process.
CREATE INDEX idx_sessions_start_time ON Sessions(start_time);

CREATE INDEX idx_sessions_end_time ON Sessions(end_time);

--Purchases Table: Index on purchase_time and player_id columns for quicker filtering and joins.
CREATE INDEX idx_purchases_purchase_time ON Purchases(purchase_time);

CREATE INDEX idx_purchases_player_id ON Purchases(player_id);


--Players Table: Index on player_id to optimize joins with the Sessions and Purchases tables.
CREATE INDEX idx_players_player_id ON Players(player_id);

```
### Caveats:

Indexes need to be maintained, and they come with overhead costs:

- Disk Space: Indexes consume disk space.
- Insert/Update/Delete Operations: Each of these operations can be slower because the index must be updated accordingly.

## 2) Partitioning:

### What is Partitioning:
Partitioning refers to splitting what is logically one large table into smaller physical pieces. 

Partitioning can improve Query performance can be improved dramatically in certain situations, particularly when most of the heavily accessed rows of the table are in a single partition.

- Bulk loads and deletes can be accomplished by adding or removing partitions.



- Partition the Sessions and Purchases tables by month or day to make queries on recent data more efficient. Partitioning on start_time or purchase_time is appropriate here because these columns are used in filtering and range queries.

```sql
-- Create the main Sessions table with partitioning by range on start_time
CREATE TABLE Sessions (
    session_id UUID PRIMARY KEY,
    player_id UUID,
    start_time TIMESTAMP,
    end_time TIMESTAMP
) PARTITION BY RANGE (start_time);

-- Create a partition for the month of July 2024
CREATE TABLE Sessions_2024_07 PARTITION OF Sessions
FOR VALUES FROM ('2024-07-01 00:00:00') TO ('2024-08-01 00:00:00');

-- Create a partition for the month of August 2024
CREATE TABLE Sessions_2024_08 PARTITION OF Sessions
FOR VALUES FROM ('2024-08-01 00:00:00') TO ('2024-09-01 00:00:00');

-- Create a partition for the month of September 2024
CREATE TABLE Sessions_2024_09 PARTITION OF Sessions
FOR VALUES FROM ('2024-09-01 00:00:00') TO ('2024-10-01 00:00:00');
```

Here is an explicit example, we can automate the process of creating partitions using PostgreSQL's **pg_partman**

## 3) MATERIALIZED VIEWS:
### What is a MATERIALIZED VIEW:


Unlike regular views, which execute the query each time they are ran, materialized views stores the result of a query physically on disk without the need of re-executing it. 

This improve performance for queies that have complex joins, aggregations, or large datasets. Materialized views should be ran periodically to keep the data up-to-date.

```sql
-- Materialized view for daily active users
CREATE MATERIALIZED VIEW daily_active_users_mv AS
WITH recent_sessions AS (
    SELECT 
        player_id, 
        start_time::date AS session_date
    FROM 
        Sessions
    WHERE 
        start_time::date > CURRENT_DATE - INTERVAL '30 days'
)
SELECT 
    session_date, 
    COUNT(DISTINCT player_id) AS daily_active_users
FROM 
    recent_sessions
GROUP BY 
    session_date
ORDER BY 
    session_date DESC;
```

## 4) De-normalization:
### What is normalization in Databases:

Database normalization is a database technique that modify an existing schema to minimize data redundancy and consistency.

Normalization split a large table into smaller tables and define relationships between them to increases the clarity in organizing data.

Highly normalized databases often require complex joins across multiple tables to retrieve related data. This can lead to slower query performance. In scenarios where quick read access is critical, such as in real-time analytics, the overhead of joining many normalized tables can become a significant bottleneck.

### How to deal with Highly Normalized Databases

 Generally De-normalization can be done by combining tables to reduce the number of joins needed for operations.