/*
Hi GPT!

This first T-SQL comment block is my "system prompt" to you, where I need your assistance
creating a lab for students to learn how to AI-enable their SQL Server database using the
new native vector data type and VECTOR_DISTANCE function in T-SQL. These capabilities are
available today in preview in Azure SQL Database, and will be generally available in SQL
Server 2025 as well, when it is eventually released later this year.

First, please have a look at the style and presentation of other labs that I've built
for SQL Server developers at this link: 

https://github.com/lennilobel/sql2022-workshop-hol/blob/main/HOL/2.%20Temporal%20Tables/1.%20Creating%20Temporal%20Tables.md

Use similar style for generating the lab content for this AI lab.

I need you to generate seven distinct .md (markdown) files from the content below.
Specifically, refer to each subsequent comment block for each markdown file, which
will be one for the introduction (which should be named README.md), and then one
for each step. There are seven steps in total, with .md files that should be named
accordingly as follows:

Step 1 - Connect to the SQL Server
Step 2 - Create the database
Step 3 - Create and populate the Movie table
Step 4 - Create the VectorizeText stored procedure
Step 5 - Vectorize the database
Step 6 - Create the VectorSearch stored procedure
Step 7 - Run AI queries

This is very important: There are certain sections below that I want you to completely ignore, because
they are notes just to myself. Ignore any content between /* START_IGNORE */ and /* END_IGNORE */
delimiters.

Finally, please generate distinct .md files and package them all up into a .zip file that I
can download, rather than displaying output on the page in response.
*/

/*
Introduction

We will be learning how to leverage AI in SQL Server 2025.

Explain that will we will be using Azure SQL Database to learn about new AI features
coming in SQL Server 2025, but not available in SQL Server 2022.

I have created a server named vslive-sql for all the students to share, where
each student will create and work with their own database on that server.

Also explain that we will be using AI models available in Azure Open AI, although
you can just as readily use AI models. These include self-hosted open-source AI models
such as Hugging Face, or FastText from Facebook Research, as well as third-party
(non-Azure) AI APIS such as Cohere and Google Vertex AI.

And so, I have also created an Azure OpenAI resource named vslive-openai for all the
students to share, where each student will consume AI models that I have already
deployed that resources prior to the lab.

*/

/*
Step 1 - Connect to the SQL Server

Assuming the user is already running SSMS, write the instructions to connect to the
server.

	Server name: vslive-sql.database.windows.net
	Authentication: SQL Server Authentication
	User name: vslive
	Password: HavingFunWithAI!

*/

/*
Step 2 - Create the database

Each attendee should each create a database with a unique name by appending their first
and last name to the database name AIDB. Below, I'm using my name lenni_lobel,
but your SQL snippet instructions should replace that with a placeholder for each
attendee to replace accordingly with their name (like so: "AIDB_<firstname_lastname>")

Also explain that the S0 database is being used for the demo, which supports
small workloads, and that it takes about a minute to create the database.

Open a new query window on the vslive-sql.database.windows.net connection, and
run the CREATE DATABASE statement. Then switch from the master database to the
new AIDB database using the dropdown list in the toolbar at the top of the screen.
*/

-- Create an S0 database for the demo (takes ~ 1 minute)
CREATE DATABASE AIDB_lenni_lobel (EDITION = 'Standard', SERVICE_OBJECTIVE = 'S0')

/*
Step 3 - Create and populate the Movie table

First, make sure you have switched from the master database to the
new AIDB database using the dropdown list in the toolbar at the top of the screen.

Explain that this database is deliberately super-simple, designed so in order
to focus on these foundational AI concepts:

1) vectorizing data in the database from an AI embedding model
2) vectorizing natural language user queries from the same AI embedding model
3) running a vector search in SQL Server to match the most similar result

So our table only has movie titles. To make the demo interesting, we're loading
it up with four populate movies. To make the demo even more interesting, add
a few more titles of your favorite movies as well.

Also call out the Vector column, with the special data type vector(1536). We
we will be using OpenAI's text-embedding-3-large model to vectorize text,
and that model returns 3072 values per vector. However, SQL Server does not
yet support more than 1998 values per vector (although it will by the time
SQL Server 2025 is released). Therefore, we will request that Azure OpenAI
compress each 3072-value vector down to 1536, so that we can store it
in a vector(1536) data type. While this will result in some reduced accuracy,
the impact is minimal, and we can still expect a good result running vector
searches against the compressed vector representations.

Explain that this native vector data type will be available in SQL Server 2025.

After populating the table, run a query to and note the movie titles each have
a Vector value of NULL. We will be populating this column with actual vectors
from Azure OpenAI. Explain that this will enable dramatic search capabilities
on this very minimal data, compared to traditional database queries that would
be limited to string matching on the movie title (substring, starts with, ends
with, and at most, regular expressions).
*/

DROP TABLE IF EXISTS Movie

-- Create a table to hold movie titles and associated vectors
CREATE TABLE Movie (
	MovieId int IDENTITY,
	Title varchar(50),
	Vector vector(1536)
)

-- Populate four movie titles
INSERT INTO Movie (Title) VALUES
	('Return of the Jedi'),
	('The Godfather'),
	('Animal House'),
	('The Two Towers')
	-- Add a few more of your favorite movies
/* START_IGNORE */
--	('2001: A Space Odyssey'),
--	('Vanilla Sky')
/* END_IGNORE */
GO

-- Query the table, note we have no vectors yet
SELECT * FROM Movie
GO

/*
Step 4 - Create the VectorizeText stored procedure

This stored procedure accepts any text, uses sp_invoke_external_rest_endpoint to
call Azure OpenAI passing in the text, receives a vector back from Azure OpenAI,
which then gets returned from the stored procedure via and output parameter
that uses the vector(1536) data type.

Explain that sp_invoke_external_rest_endpoint will be available in SQL Server 2025.

Explain how the call is constructed from these components:

/* START_IGNORE */
1. The URL starts with an endpoint formatted as 'https://<resource-name>.openai.azure.com/',
that specifies the Azure OpenAI resource that we are targeting, which is vslive-openai in
this case. This is available from the Azure portal, and can be copied and pasted in
as https://vslive-openai.openai.azure.com/.
/* END_IGNORE */

1. The URL starts with an endpoint to the model deployment. This is available from the Azure
portal, and can be copied and pasted in as https://lenni-m6wi7gcd-eastus2.cognitiveservices.azure.com/.

2. The URL continues with the text 'openai/deployments/', and then followed by the
name of the Azure OpenAI text embedding model that I (the instructor) have already deployed
to vslive-openai, which is text-embedding-3-small.

3. The URL terminates with '/embeddings' and a query string parameter that specifies
the version of the OpenAI API that the request should use.

4. The HTTP method used to call Azure OpenAI is POST.

5. The HTTP headers supply the model's API key. This should always be kept secret, since
call consumption will be billed to the associated Azure subscription. You can and should also
enable a network firewall around your Azure resource that blocks access to all but authorized
clients. For this lab, you will use the provided API key to access an Azure OpenAI resource with no
firewall, that will be deleted after completing the lab.

6. The payload supplies the actual text to be vectorized, which is passed in as
the @Text parameter.

Then explain the result:

1. If the API call fails, the stored procedure throws an error.

2. If the API call succeeds, the vector is retrieved from the JSON response. Specifically, it is
extracted from the embedding property of the first element in the data array of the result property
in the response. Explain that this simple demo is only vectorizing one piece of text per API
call, but that you could vectorize multiple pieces of vext in a single API call, and get the
vector returned for each piece of text fromt the result.data array in the response.

3. Finally, the raw JSON vector response is converted to a native vector data type in SQL Server,
sized at 1536 dimensions to match the number of dimensions returned per vector by the text-embedding-3-small
model, and stored in the output variable returned by the stored procedure.

After creating the stored procedure, test it by trying to vectorize any arbitrary text. If everything
is working properly you should see the first portion of the vector, as stored in the native
SQL Server vector data type. Click the Messages tab to view the raw JSON response with the vector
returned by Azure OpenAI. Note how the first few values in the raw JSON response match the first
few values visible in the native vector data type, although the native vector data type displays
each vector element in scientific notation.

Explain how, while these numbers aren't human readable, they describe a pattern that captures the
semantic meaning of the vectorized text, based on the deeply trained text embedding model
in Azure OpenAI.
*/

-- Create a stored procedure that can call Azure OpenAI to vectorize any text
CREATE OR ALTER PROCEDURE VectorizeText
	@Text varchar(max),
	@Vector vector(1536) OUTPUT
AS
BEGIN

	-- Your Azure OpenAI endpoint
/* START_IGNORE */
--	DECLARE @OpenAIEndpoint varchar(max) = 'https://vslive-openai.openai.azure.com/'
/* END_IGNORE */
DECLARE @OpenAIEndpoint varchar(max) = 'https://lenni-m6wi7gcd-eastus2.cognitiveservices.azure.com/'
	
/* START_IGNORE */
--	-- The 'text-embedding-3-small' model yields 1536 components (floating point values) per vector
--	DECLARE @OpenAIDeploymentName varchar(max) = 'text-embedding-3-smal'
/* END_IGNORE */

	-- The 'text-embedding-3-large' model yields 3072 components (floating point values) per vector
	DECLARE @OpenAIDeploymentName varchar(max) = 'text-embedding-3-large'

	-- Specify the API version
/* START_IGNORE */
--	DECLARE @OpenAIVersion varchar(max) = '2023-03-15-preview'	-- for text-embedding-3-small
/* END_IGNORE */
	DECLARE @OpenAIVersion varchar(max) = '2023-05-15'			-- for text-embedding-3-large

	-- Construct the URL from the Azure OpenAI endpoint, model deployment name, and API version		
	DECLARE @Url varchar(max) = CONCAT(@OpenAIEndpoint, 'openai/deployments/', @OpenAIDeploymentName, '/embeddings?api-version=', @OpenAIVersion)

	-- Your Azure OpenAI API key
/* START_IGNORE */
--	DECLARE @OpenAIApiKey varchar(max) = '5QhWOit1wdLVaPQ8DA2LV8kagSw02aXLE5e2BRi8UiMrNQAuiGBEJQQJ99BBACYeBjFXJ3w3AAABACOGb3ts'				
/* END_IGNORE */
	DECLARE @OpenAIApiKey varchar(max) = '1l01K92g5ObpFKmgMVs8RJ8XC3IY6bNTGtj0ECyQqRV0CztW8Qu4JQQJ99BBACHYHv6XJ3w3AAAAACOGrnno'				

	-- Construct the headers from the API key
	DECLARE @Headers varchar(max) = JSON_OBJECT('api-key': @OpenAIApiKey)

/* START_IGNORE */
	---- Construct the payload from the text to be vectorized
	--DECLARE @Payload varchar(max) = JSON_OBJECT('input': @Text)
/* END_IGNORE */

	-- Construct the payload from the text to be vectorized, and request that the vector returned be compressed
	-- from 3072 elements (the vector size for text-embedding-3-large) down to 1536 elements (the size of the
	-- native SQL Server verctor data type), since (currently) SQL Server supports a maximum vector size of 1998.
	DECLARE @Payload varchar(max) = JSON_OBJECT('input': @Text, 'dimensions': 1536)

	DECLARE @Response nvarchar(max)
	DECLARE @ReturnValue int

	-- Call Azure OpenAI via sp_invoke_external_rest_endpoint to vectorize the text
	EXEC @ReturnValue = sp_invoke_external_rest_endpoint
		@url = @Url,
		@method = 'POST',
		@headers = @Headers,
		@payload = @Payload,
		@response = @Response OUTPUT

	PRINT @Response

	IF @ReturnValue != 0
		THROW 50000, @Response, 1

	DECLARE @VectorJson nvarchar(max) = JSON_QUERY(@Response, '$.result.data[0].embedding')

	SET @Vector = CONVERT(vector(1536), @VectorJson)

END
GO

-- Test the stored procedure, and look in the Messages tab to see the raw JSON response
DECLARE @Vector vector(1536)
EXEC VectorizeText 'Vectorize this text please', @Vector OUTPUT
SELECT @Vector

/*
Step 5 - Vectorize the database

Run the following simple T-SQL code, which uses a cursor to iterate each movie title
in the Movie table, calls the stored procedure to vectorize the movie title, and then
uses an UPDATE statement to store each movie title's vector back to the Movie table.

Then query the Movie table and observe how each movie title has a vector value in the
Vector column that was previously all NULLs.
*/

DECLARE @MovieId int
DECLARE @Title varchar(max)
DECLARE @Vector vector(1536)

DECLARE curMovies CURSOR FOR
	SELECT MovieId, Title FROM Movie

OPEN curMovies
FETCH NEXT FROM curMovies INTO @MovieId, @Title

WHILE @@FETCH_STATUS = 0 BEGIN

	EXEC VectorizeText @Title, @Vector OUTPUT

	UPDATE Movie
	SET Vector = @Vector
	WHERE MovieId = @MovieId

	FETCH NEXT FROM curMovies INTO @MovieId, @Title

END

CLOSE curMovies
DEALLOCATE curMovies
GO

-- View the movie titles with vectors
SELECT * FROM Movie
GO

/*
Step 6 - Create the VectorSearch stored procedure

This stored procedure accepts a natural language query in the @Question parameter, calls the
VectorizeText stored procedure (the same one used to vectorize the Movie table) to vectorize
the question, and then uses the VECTOR_DISTANCE function in a SQL query to retrieve the
movie title that most similarly matches the question. Using TOP 1 with ORDER BY on the calculated
distance returns the most similar result (since least distant is most similar), based on the
semantic meaning embedded in the movie database vectors and the user's query vector.

Explain that VECTOR_DISTANCE will be available in SQL Server 2025.

Notice that the VECTOR_DISTANCE function accepts a "metric" property, which we are setting
as 'cosine'. This means that we are calculating the cosine distance between the user's
question and every movie in the database. Cosine is the most commonly used distance metric,
although others (such as Dot Product and Euclidean) are also supported for specialized use cases.
*/

-- Create a stored procedure to run a vector search using the Cosine Distance metric
CREATE OR ALTER PROCEDURE VectorSearch
	@Question varchar(max)
AS
BEGIN

	-- Prepare a vector variable to capture the question vector components returned from Azure OpenAI
	DECLARE @QuestionVector vector(1536)

	-- Vectorize the question, and store the question vector components in the table variable
	EXEC VectorizeText
		@Question,
		@QuestionVector OUTPUT

	SELECT TOP 1
		Question = @Question,
		Answer = Title,
		CosineDistance = VECTOR_DISTANCE('cosine', @QuestionVector, Vector)
	FROM
		Movie
	ORDER BY
		CosineDistance

END
GO

/*
Step 7 - Run AI queries

It's time to see the magic happen!

Run the following T-SQL to see how the semantic meanings of the movie titles and the
query text are matched by the vector search stored procedure.

It's best to run the first five sets of stored procedures, with four executions per set.

Then, run a few more vector searches passing in natural language questions that best
match some of your favorite movies that you added in to the Movie table earlier.
*/

-- Movie phrases
EXEC VectorSearch 'May the force be with you'
EXEC VectorSearch 'I''m gonna make him an offer he can''t refuse'
EXEC VectorSearch 'Drunk and stupid is no way to go through life, son'
EXEC VectorSearch 'One ring to rule them all'

-- Movie characters
EXEC VectorSearch 'Luke Skywalker'
EXEC VectorSearch 'Don Corleone'
EXEC VectorSearch 'James Blutarsky'
EXEC VectorSearch 'Gandalf'

-- Movie actors
EXEC VectorSearch 'Mark Hamill'
EXEC VectorSearch 'Al Pacino'
EXEC VectorSearch 'John Belushi'
EXEC VectorSearch 'Elijah Wood'

-- Movie location references
EXEC VectorSearch 'Tatooine'
EXEC VectorSearch 'Sicily'
EXEC VectorSearch 'Faber College'
EXEC VectorSearch 'Mordor'

-- Movie genres
EXEC VectorSearch 'Science fiction'
EXEC VectorSearch 'Crime'
EXEC VectorSearch 'Comedy'
EXEC VectorSearch 'Fantasy/Adventure'

-- Add a few more questions relating to your favorite movies
/* START_IGNORE */
EXEC VectorSearch 'HAL'
EXEC VectorSearch 'I''m sorry Dave, I''m afraid I can''t do that'
EXEC VectorSearch 'Tom Cruise'
EXEC VectorSearch 'Psycho Thriller'
/* END_IGNORE */



/* Post pass 1:

That's a good start. But you are not providing nearly enough detail for my needs. Again, I refer you to an example of an existing lab that I've built, at: https://github.com/lennilobel/sql2022-workshop-hol/blob/main/HOL/2.%20Temporal%20Tables/1.%20Creating%20Temporal%20Tables.md.

As you can see, I need you to explain important concepts. I've taken the time to elaborate on what needs to be conveyed in all the comment blocks. So I need you to paraphrase all those concepts, and provide clear step-by-step guidance to complete each step in the lab.

*/


/* Post pass 2:

Thanks! It's getting better, but can be definitely improved. I need you to include the complete T-SQL scripts that I provided, without reducing them down to a subset. And I need more explanation about why we need to reduce the vector size from 3072 to 1536, given that we're using a vector(1536) data type to store vectors from the text-embedding-3-large model (which have 3072 elements, but is being compressed by the dimensions value in the payload to Azure OpenAI).

*/
