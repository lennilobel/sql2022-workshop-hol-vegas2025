# Step 4 - Create the VectorizeText Stored Procedure

Now, we will create a **stored procedure** that calls **Azure OpenAI** to generate **vector embeddings**.

## Why Do We Need This?

AI models transform text into **vectors** that store semantic meaning. We need a stored procedure to:

- **Send text** (movie titles) to Azure OpenAI.
- **Receive a vector** representation of the text.
- **Store the vector** in our SQL database.

---

## Vector Size Considerations

We are using **OpenAI's text-embedding-3-large model**, which **returns 3072-dimensional vectors**.  
However, **SQL Server 2025 currently only supports vectors up to 1998 dimensions**.  

To fit within this limit, we **request Azure OpenAI to compress the vectors to 1536 dimensions** by adding `'dimensions': 1536` in the API payload.

This allows us to:

✔ Store vectors inside a `vector(1536)` column in SQL Server.  
✔ Preserve **high accuracy** while reducing storage size.  
✔ Ensure compatibility with **SQL Server’s current vector limit**.  

This compression **minimally affects accuracy**, as OpenAI optimizes dimensionality reduction to **retain meaningful vector relationships**.

---

## Create the Stored Procedure

Run this full T-SQL script:

```sql
CREATE OR ALTER PROCEDURE VectorizeText
    @Text varchar(max),
    @Vector vector(1536) OUTPUT
AS
BEGIN
    -- Define Azure OpenAI endpoint
    DECLARE @OpenAIEndpoint varchar(max) = 'https://lenni-m6wi7gcd-eastus2.cognitiveservices.azure.com/';
    DECLARE @OpenAIDeploymentName varchar(max) = 'text-embedding-3-large';
    DECLARE @OpenAIVersion varchar(max) = '2023-05-15';
    DECLARE @Url varchar(max) = CONCAT(@OpenAIEndpoint, 'openai/deployments/', @OpenAIDeploymentName, '/embeddings?api-version=', @OpenAIVersion);

    -- API key (Replace with your valid key)
    DECLARE @OpenAIApiKey varchar(max) = 'YOUR_OPENAI_API_KEY';
    DECLARE @Headers varchar(max) = JSON_OBJECT('api-key': @OpenAIApiKey);

    -- Payload: requests 1536-dimensional vectors instead of 3072
    DECLARE @Payload varchar(max) = JSON_OBJECT('input': @Text, 'dimensions': 1536);

    -- Prepare response variable
    DECLARE @Response nvarchar(max);
    DECLARE @ReturnValue int;

    -- Call Azure OpenAI to get vector representation
    EXEC @ReturnValue = sp_invoke_external_rest_endpoint
        @url = @Url,
        @method = 'POST',
        @headers = @Headers,
        @payload = @Payload,
        @response = @Response OUTPUT;

    -- Print raw JSON response for debugging
    PRINT @Response;

    -- Handle API errors
    IF @ReturnValue != 0
        THROW 50000, @Response, 1;

    -- Extract vector from JSON response
    DECLARE @VectorJson nvarchar(max) = JSON_QUERY(@Response, '$.result.data[0].embedding');

    -- Convert JSON vector to SQL Server's vector type
    SET @Vector = CONVERT(vector(1536), @VectorJson);
END;
GO
```

---

### Test the Stored Procedure

Run:

```sql
DECLARE @Vector vector(1536);
EXEC VectorizeText 'Vectorize this text', @Vector OUTPUT;
SELECT @Vector;
```

✅ Check the **Messages tab** to see the raw JSON response.

The first few values in the JSON response should match the values in SQL Server’s **vector(1536)** column.
