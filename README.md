# Project Title
AI-Assisted Drought Intelligence and Aid Allocation System Using Oracle PL/SQL

# Overview
DroughtAid is an Oracle PL/SQL-based system designed to support drought monitoring and aid allocation. The system stores drought reports, calculates drought priority scores, manages aid inventory, receives aid requests, processes aid allocations, and records audit logs.

The main focus of this project is the Oracle PL/SQL backend. FastAPI and React are used as supporting tools to demonstrate interaction with the Oracle database.

## Technologies Used
- Oracle Database / Oracle XE
- Oracle PL/SQL
- FastAPI
- React
- Vite
- GitHub

## Project Structure
DroughtAid/
- backend/
- frontend/
- 01_schema.sql
- 02_data.sql
- 03_plsql.sql
- 04_demo.sql
- README.md
- .gitignore

## SQL Files
- 01_schema.sql: Creates tables, constraints, sequences, and views.
- 02_data.sql: Inserts sample data.
- 03_plsql.sql: Creates the PL/SQL package, procedures, functions, triggers, cursors, records, collections, and exception handling.
- 04_demo.sql: Demonstrates and tests the system features.

## Main PL/SQL Features
- Related tables with primary keys and foreign keys
- Check and unique constraints
- Sample data with at least ten rows per table
- Procedures and functions
- Package specification and package body
- BEFORE and AFTER triggers
- Explicit cursor and cursor FOR loop
- %ROWTYPE record
- User-defined record type
- Associative array and nested table
- Collection methods
- Predefined and user-defined exceptions

## Backend Setup
Go to the backend folder:

cd backend

Create and activate virtual environment:

python3 -m venv venv
source venv/bin/activate

Install requirements:

pip install -r requirements.txt

Create a real .env file based on backend/.env.example.

Run FastAPI:

python -m uvicorn app.main:app --reload

Open:

http://127.0.0.1:8000/docs

## Frontend Setup
Go to the frontend folder:

cd frontend

Install packages:

npm install

Run the frontend:

npm run dev

Open:

http://localhost:5173

## Database Setup
Connect to Oracle using:

Username: drought_aid_db
Service: XEPDB1

Run SQL files in this order:

1. 01_schema.sql
2. 02_data.sql
3. 03_plsql.sql
4. 04_demo.sql

## Group Members
- Member 1: Aymen Mahmoud Abdi
- Member 2: Anas Abdiwahab Mohamed
- Member 3: Fartun Muqtar Abdikadir
- Member 4: Maryama Ali Mohamud
- Member 5: Hussein Abdullahi Keinan
- Member 6: Umaymo Ahmed Abukar

