Simple api project for CRUD todos

Bussiness rules:
- Table TODOS(ID, NAME, DESCRIPTION) have primary key ID type integer, NAME can't be null

Using oracle database and nodejs (express)

Controller is written inside procedure of oracle database

Result of api format is { errorCode, errorMessage } and errorCode is declared in ERRORS table
