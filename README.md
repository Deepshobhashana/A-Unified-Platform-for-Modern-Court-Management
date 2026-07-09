# A Unified Platform for Modern Court Management

A relational database project that models the end-to-end workflow of a court system — from litigants filing a case to judges, lawyers, hearings, evidence, and payments — designed and normalized to BCNF using PostgreSQL.

## Table of Contents

- [Overview](#overview)
- [Team](#team)
- [Repository Structure](#repository-structure)
- [Entity-Relationship Model](#entity-relationship-model)
- [Relational Schema](#relational-schema)
- [Database Schema Summary](#database-schema-summary)
- [Normalization](#normalization)
- [Sample Queries](#sample-queries)
- [Setup and Usage](#setup-and-usage)
- [Tech Stack](#tech-stack)

## Overview

This project designs a database to manage the daily operations of a court, capturing the relationships between the people involved (judges, lawyers, litigants, witnesses, admins) and the case lifecycle (filing, hearings, evidence, documents, interlocutory applications, FIRs, e-filings, and payments).

The project was built in stages typical of a formal DBMS course project:

1. Requirements analysis and entity identification
2. ER modeling
3. Mapping the ER model to a relational schema
4. Functional dependency analysis and normalization to BCNF
5. DDL implementation with constraints in PostgreSQL
6. Populating the database with realistic sample data
7. Writing complex analytical SQL queries against the schema

## Team

| No. | Name | Student ID |
|-----|------|------------|
| 1 | Sherathiya Darpan | 202401199 |
| 2 | Deep Shobhashana | 202401205 |
| 3 | Prins Satapara | 202401188 |
| 4 | Tirth Solanki | 202401211 |
| 5 | Shaurya Pratap | 202401197 |

## Repository Structure

```
.
├── documentation/
│   ├── ER Diagram.png                   # Entity-Relationship diagram
│   ├── Relational Schema Diagram.png    # Mapped relational schema
│   ├── Minimal_FD_Set.pdf               # Minimal (canonical) set of functional dependencies per relation
│   ├── BCNF_Proofs.pdf                  # BCNF verification/proof for every relation
│   └── Queries_and_their_Solution.pdf   # Categorized complex SQL queries with explanations
├── sql/
│   ├── DDL_Script.sql                   # Schema creation script (tables, keys, constraints)
│   └── Insert_Script.sql                # Sample data population script
└── README.md
```

## Entity-Relationship Model

The ER diagram (`documentation/ER Diagram.png`) captures the core entities of the court system and their relationships, including:

- **People**: User (generalized), Judge, Lawyer, Admin, Litigant, Witness
- **Case lifecycle**: Case, Cause List, Hearing, Case History, Interlocutory Application
- **Supporting records**: Evidence, Case Document, FIR, E-Filing, Payment

`User` is modeled as a supertype, with `Judge`, `Lawyer`, and `Admin` as role-specific subtypes that each hold a foreign key back to `User`, avoiding duplication of common attributes (name, DOB, nationality, password) across roles.

## Relational Schema

The ER model was mapped to **26 relations** (see `documentation/Relational Schema Diagram.png`), grouped as follows:

**Core actor tables**
`User`, `User_email`, `User_phone_number`, `Judge`, `Judge_specialisation`, `Lawyer`, `Lawyer_specialisation`, `Admin`, `Litigant`

**Case-centric tables**
`Case`, `Case_judges`, `Case_litigants`, `Case_lawyers`, `Case_history`, `Case_document`

**Hearing and scheduling**
`Cause_list`, `Hearing`, `Has_witness`

**Legal process tables**
`Interlocutory_applications`, `FIR`, `Evidence`, `E_filing`, `Payment`

**Witness tables**
`Witness`, `Witness_phone_number`, `Witness_email`

Multi-valued attributes (emails, phone numbers, specialisations) are each decomposed into their own relation, in line with 1NF requirements.

## Database Schema Summary

| Table | Purpose |
|---|---|
| `User` | Common attributes shared by every human actor (judge, lawyer, admin) in the system |
| `User_email` / `User_phone_number` | Multi-valued contact details for a user |
| `Judge` | Judge-specific attributes: working status, practising since, tenure |
| `Judge_specialisation` | Areas of legal specialisation per judge |
| `Lawyer` | Lawyer-specific attributes: bar council number, firm, working status |
| `Lawyer_specialisation` | Areas of legal specialisation per lawyer |
| `Admin` | Court administrative staff: post held, tenure |
| `Litigant` | Parties to a case: individual, organisation, or government, with identity numbers |
| `Cause_list` | Daily court listing: courtroom, date, and time slot |
| `Case` | Core case record: CNR, title, type, status, filing date |
| `Case_judges` / `Case_litigants` / `Case_lawyers` | Many-to-many associations between a case and its judges, litigants, and lawyers |
| `Case_history` | Historical record of a case as it moves across courts |
| `Interlocutory_applications` | Interim applications (stay, bail, injunction, etc.) filed within a case |
| `Payment` | Court-fee and related payments tied to a case |
| `FIR` | First Information Report linked to a criminal case |
| `Witness` / `Witness_phone_number` / `Witness_email` | Witness details and contact information |
| `Hearing` | A scheduled hearing: purpose, presiding judge, prosecutor, defense lawyer, verdict, next date |
| `Has_witness` | Witnesses summoned to a given hearing |
| `Evidence` | Evidence submitted for a case, who submitted and uploaded it |
| `Case_document` | Documents filed in relation to a case/hearing (petition, order, judgment, etc.) |
| `E_filing` | Electronic filing/diary record submitted by a litigant through a lawyer |

**Key design decisions enforced in the DDL:**
- Primary keys and composite primary keys for all associative/multi-valued tables
- `CHECK` constraints restricting enumerated columns (e.g. `Case_type`, `Current_status`, `Working_status`, `Application_type`) to valid domain values
- Referential integrity via `FOREIGN KEY` constraints with explicit `ON DELETE` / `ON UPDATE` actions (`CASCADE`, `RESTRICT`, `SET NULL`) chosen per relationship semantics
- `UNIQUE` constraints on natural keys such as CNR, Bar Council Number, and FIR number

## Normalization

The project includes full normalization documentation:

- **`Minimal_FD_Set.pdf`** — derives the minimal (canonical) cover of functional dependencies for every relation in the schema.
- **`BCNF_Proofs.pdf`** — for each relation, lists its attributes and candidate key(s), then proves that every non-trivial functional dependency has a superkey as its determinant, confirming the schema is in **Boyce-Codd Normal Form (BCNF)**.

This ensures the schema is free of redundancy-causing partial and transitive dependencies.

## Sample Queries

`documentation/Queries_and_their_Solution.pdf` contains a set of complex, real-world analytical queries grouped by theme, including:

1. **Case Centered Queries** — e.g. criminal cases that reached "Framing of Charges" with no chargesheet on file, cases pending well past their first hearing, judge specialisation vs. case-type mismatches
2. **Judge & Workload Related Queries** — e.g. monthly hearing load per judge, top 5 most active lawyers by case count
3. **Courtroom Related Queries** — e.g. detecting courtroom double-bookings, identifying overloaded vs. underused courtrooms relative to the average
4. **E-Filing Related Queries** — e.g. admin-wise e-filing rejection rates for audit purposes

Each query uses joins, correlated subqueries, window functions, `CTE`s, and aggregate functions over the schema described above, and is accompanied by its full SQL solution in the PDF.

## Setup and Usage

**Prerequisites:** PostgreSQL (13+ recommended)

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd <repository-folder>
   ```

2. Create the database and load the schema:
   ```bash
   psql -U <your_username> -d <your_database> -f sql/DDL_Script.sql
   ```
   This creates the `court_management` schema and all 26 tables with their constraints.

3. Load the sample data:
   ```bash
   psql -U <your_username> -d <your_database> -f sql/Insert_Script.sql
   ```

4. Set the search path (if not already set by the scripts) and run any of the queries from `documentation/Queries_and_their_Solution.pdf`:
   ```sql
   SET search_path TO court_management;
   ```

## Tech Stack

- **Database:** PostgreSQL
- **Language:** SQL (DDL, DML, complex analytical queries)
- **Documentation:** ER modeling, relational mapping, functional dependency and BCNF analysis

---

*This project was created as part of a Database Management Systems (DBMS) course assignment.*
