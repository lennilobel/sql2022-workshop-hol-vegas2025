# Step 6 - Create the VectorSearch Stored Procedure

Now, we will create a **stored procedure** that finds the **most similar movie** based on a **natural language query**.

## Why Is This Important?

Traditional SQL searches rely on **exact text matching**, but **vector search** allows us to:

✔ Find movies **based on meaning**, not just words.  
✔ Handle **typos and variations** in queries.  
✔ Perform **AI-powered recommendations**.

---

## How It Works

1. **Vectorizes** the user's question using `VectorizeText`.
2. **Finds the most similar movie** using `VECTOR_DISTANCE('cosine', query_vector, movie_vector)`.
3. **Returns the closest match**.

---

## Full SQL Script

Run:

```sql
CREATE OR ALTER PROCEDURE VectorSearch
    @Question varchar(max)
AS
BEGIN
    -- Prepare a vector variable to capture the question vector components
    DECLARE @QuestionVector vector(1536);

    -- Vectorize the question using Azure OpenAI
    EXEC VectorizeText @Question, @QuestionVector OUTPUT;

    -- Find the most similar movie based on cosine similarity
    SELECT TOP 1 
        Title, 
        VECTOR_DISTANCE('cosine', @QuestionVector, Vector) AS CosineDistance
    FROM Movie
    ORDER BY CosineDistance;
END;
GO
```

---

### Test the Search

Run:

```sql
EXEC VectorSearch 'May the force be with you';
EXEC VectorSearch 'I''m gonna make him an offer he can''t refuse';
```

✅ The most **semantically similar** movie will be returned!
