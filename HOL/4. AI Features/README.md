# AI-Enabled SQL Server Lab

## Introduction

### Welcome to the AI-Enabled SQL Server Lab!

In this hands-on lab, you will learn how to integrate **AI capabilities** into SQL Server using the new **vector** data type and the `VECTOR_DISTANCE` function in T-SQL. These features are currently in **preview in Azure SQL Database** and will be **generally available in SQL Server 2025**.

By the end of this lab, you will be able to:

- **Store and manage vector embeddings** directly inside SQL Server.
- **Generate AI-based vector embeddings** using Azure OpenAI.
- **Perform similarity searches** using SQL Server’s native `VECTOR_DISTANCE` function.

This lab is designed for **SQL Server developers** who want to explore AI in **SQL Server 2025**.

---

## What You Will Learn

1. **How vector embeddings work in SQL Server.**
2. **How to generate embeddings using Azure OpenAI.**
3. **How to perform AI-powered searches using vector distance calculations.**

### Pre-requisites

To complete this lab, you need:

- **SQL Server Management Studio (SSMS)**
- **Access to Azure SQL Database** (`vslive-sql.database.windows.net`)
- **Access to Azure OpenAI** (`vslive-openai`)

Each student will create their own **database** and will use **pre-configured AI models**.

---

## Lab Steps

1. [Connect to the SQL Server](1_Connect_to_the_SQL_Server.md)
2. [Create the Database](2_Create_the_Database.md)
3. [Create and Populate the Movie Table](3_Create_and_Populate_the_Movie_Table.md)
4. [Create the VectorizeText Stored Procedure](4_Create_the_VectorizeText_Stored_Procedure.md)
5. [Vectorize the Database](5_Vectorize_the_Database.md)
6. [Create the VectorSearch Stored Procedure](6_Create_the_VectorSearch_Stored_Procedure.md)
7. [Run AI Queries](7_Run_AI_Queries.md)

---

### Why Is This Important?

Traditional databases are great for **structured queries**, but they struggle with **semantic searches**. For example:

- If you search for **"The Godfather"**, a normal SQL query would only match **exact or partial text**.
- With **vector embeddings**, SQL Server can find movies based on **meaning**, not just words.

This lab will teach you how to **AI-enable your SQL Server queries**.
