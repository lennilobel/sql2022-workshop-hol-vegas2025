# Step 3 - Create and Populate the Movie Table

Now, we will create a **simple table** to store movie titles and their AI-generated vector embeddings.

## Why Are We Storing Movie Titles?

We will use **movie titles** as our dataset because:

1. It’s a **simple dataset** that helps focus on learning AI concepts.
2. It allows us to see **how AI understands relationships** between words.
3. We can use **AI-powered search** to match movies based on meaning.

---

## Table Structure

We will create a table named `Movie` with **three columns**:

1. `MovieId` - A unique identifier.
2. `Title` - The movie title.
3. `Vector` - A **vector(1536)** column that will store AI-generated embeddings.

```sql
DROP TABLE IF EXISTS Movie;

CREATE TABLE Movie (
    MovieId int IDENTITY PRIMARY KEY,
    Title varchar(50),
    Vector vector(1536) -- New SQL Server vector data type
);
```

Next, insert some movies:

```sql
INSERT INTO Movie (Title) VALUES
    ('Return of the Jedi'),
    ('The Godfather'),
    ('Animal House'),
    ('The Two Towers');
```

---

### What Is a Vector?

A **vector** is a list of numbers that represents **meaning**. For example:

| Text                   | Vector Representation (Shortened) |
|------------------------|--------------------------------|
| "The Godfather"       | `[0.45, -0.12, 0.98, ...]`    |
| "Crime Drama"        | `[0.44, -0.10, 0.95, ...]`    |

If two vectors are **close together**, they mean similar things!

---

### Verify the Data

Run:

```sql
SELECT * FROM Movie;
```

At this stage, the **Vector** column is `NULL`. In the next steps, we will **generate AI-powered embeddings**.
