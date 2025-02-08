# Step 1 - Connect to the SQL Server

In this step, you will connect to **Azure SQL Database** using **SQL Server Management Studio (SSMS)**.

## Why Are We Using Azure SQL Database?

The AI capabilities we are exploring are currently **only available in preview in Azure SQL Database**. When **SQL Server 2025** is released, they will also be available **on-premises**.

### Connection Details

- **Server name**: `vslive-sql.database.windows.net`
- **Authentication**: SQL Server Authentication
- **User name**: `vslive`
- **Password**: `HavingFunWithAI!`

### Instructions

1. Open **SQL Server Management Studio (SSMS)**.
2. Click on **Connect** → **Database Engine**.
3. In the **Server name** field, enter: `vslive-sql.database.windows.net`.
4. Set **Authentication** to **SQL Server Authentication**.
5. Enter:
   - **User name**: `vslive`
   - **Password**: `HavingFunWithAI!`
6. Click **Connect**.

✅ You are now connected and ready to create your own database.
