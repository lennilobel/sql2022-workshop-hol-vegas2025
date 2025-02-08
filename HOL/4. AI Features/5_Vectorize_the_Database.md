# Step 5 - Vectorize the Database

Now, we will **populate the Vector column** for all movies in our database.

## Why Do This?

Currently, our **Movie** table has NULL values in the **Vector** column. We need to:

1. **Loop through each movie title.**
2. **Generate a vector** using Azure OpenAI.
3. **Store the vector** in the Movie table.

---

## Run the Full Script

Run this SQL script:

```sql
DECLARE @MovieId int, @Title varchar(max), @Vector vector(1536);

DECLARE curMovies CURSOR FOR
    SELECT MovieId, Title FROM Movie;

OPEN curMovies;
FETCH NEXT FROM curMovies INTO @MovieId, @Title;

WHILE @@FETCH_STATUS = 0 BEGIN
    -- Generate vector for movie title
    EXEC VectorizeText @Title, @Vector OUTPUT;

    -- Store vector in the Movie table
    UPDATE Movie
    SET Vector = @Vector
    WHERE MovieId = @MovieId;

    FETCH NEXT FROM curMovies INTO @MovieId, @Title;
END;

CLOSE curMovies;
DEALLOCATE curMovies;
```

---

### Verify the Data

Run:

```sql
SELECT * FROM Movie;
```

✅ Each movie title now has a **vector representation** stored in SQL Server.
