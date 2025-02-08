# Step 2 - Create the Database

Each student must create a **unique database** by appending their **first and last name** to `AIDB`.

## Why Do We Need Unique Databases?

Since multiple students are sharing the same SQL Server, each person needs their own **isolated database**.

### Instructions

1. Open a **new query window** in SSMS.
2. Replace `<firstname_lastname>` with your own name.
3. Run the following SQL script:

```sql
CREATE DATABASE AIDB_<firstname_lastname> (EDITION = 'Standard', SERVICE_OBJECTIVE = 'S0');
```

4. Wait about **1 minute** for the database to be created.
5. Switch to your new database by selecting it from the **dropdown menu** at the top of SSMS.

✅ Your database is now ready!

---

## Why Are We Using the S0 Tier?

Azure SQL Database supports different **performance tiers**. The **S0** tier:

- Is **low-cost** and ideal for small workloads.
- Has enough power to run **vector search queries**.
