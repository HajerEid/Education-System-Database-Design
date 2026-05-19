# Exam Management System - Database Architecture 🚀

A fully automated, high-performance relational database engine built with **MS SQL Server** to optimize and manage the entire examination lifecycle. The system automates everything from randomized question distribution to real-time grading, ensuring zero-tolerance data integrity and minimal administrative overhead.

---

## 📌 Project Overview
Traditional manual examination systems face inefficiencies such as non-randomized question distribution, time-heavy grading delays, and weak referential integrity. This project introduces a robust backend solution leveraging advanced programmable SQL objects to centralize core business logic directly within the database engine.

### 👥 User Roles & Responsibilities
* **Training Manager:** Supervises intakes, monitors overall results, and mass-grants student access permissions.
* **Instructor:** Creates exams, manages the question pool, and determines exam publication schedules.
* **Student:** Attempts available exams, submits responses in real-time, and reviews evaluated performance results.

---

## 🛠️ Core Database Implementations

### 1. Advanced Procedural Logic (Stored Procedures)
* **`SP_CreateNewExam`**: Automates exam deployment. It validates whether the course's question bank has sufficient content, computes a proportional mark-per-question distribution based on `TotalMarks`, and utilizes `ORDER BY NEWID()` to pull a completely randomized, isolated question set for that exam session.
* **`SP_SubmitAnswers`**: Manages the critical student submission flow. To guarantee absolute consistency and prevent half-saved states, the entire process—from logging responses via a User-Defined Table Type (`dbo.AnswerListType`) to finalizing timestamps—is wrapped inside an **Atomic SQL Transaction** (`BEGIN TRANSACTION`).
* **`SP_GrantExamAccess`**: Designed for high administrative scalability, allowing managers or instructors to mass-assign exam permissions to entire student cohorts (`IntakeID`) simultaneously while natively skipping duplicates using a `NOT EXISTS` layer.

### 2. Intelligent Scoring Engines (User-Defined Functions)
* **`FN_CalculateAttemptScore`**: The system's central grading engine. It bypasses classic subquery limitations within scalar aggregates by executing an optimized `LEFT JOIN` strategy. It automatically grades objective questions (MCQs, True/False) by matching user choices to correct options, while safely incorporating manual marks awarded by instructors for essay/written questions.
* **`FN_CheckPassingStatus`**: A modular validation helper that dynamically reads the `MinDegree` threshold required for a specific course and evaluates whether a given score constitutes a 'Passed' or 'Failed' outcome.

### 3. Absolute Data Integrity (Triggers)
* **`TR_PreventUserDeletion`**: An advanced `INSTEAD OF DELETE` architectural guardrail deployed on the `Users` table. Instead of failing abruptly with standard foreign key violation errors, this trigger intercepts hard delete commands, checks for historical sub-entity dependencies (active Students, Instructors, or Managers), fires a localized error using `RAISERROR`, and executes a `ROLLBACK TRANSACTION` to preserve system history and reporting baselines.

### 4. Performance Optimization & Reporting (Views & Indexes)
* **Performance Indexing**: Engineered strategic non-clustered indexes (`IX_StudentAnswers_Attempt`, `IX_Attempt_StudentExam`) on heavily queried foreign key and conditional filter columns to minimize disk I/O and optimize query execution plans.
* **`VW_StudentExamResults`**: Combines student information, raw scores, max available points, and real-time pass/fail evaluation statuses for all submitted attempts.
* **`VW_InstructorCourseExams`**: Provides a clean analytical dashboard summarizing total exam attempt counts and comprehensive statistical metrics per course for academic audits.

---

## 📐 Logical Architecture & Mapping
The logical schema is normalized up to the **Third Normal Form (3NF)** to eliminate data redundancy and ensure relational optimization:
* **User Management Segment**: Controls system identity and permission tiers (`Users`, `Roles`).
* **Content Management Segment**: Connects the centralized question bank to courses (`Question_Pool`, `Course`, `Exam`, `Exam_Questions`).
* **Transactions & Results Segment**: Tracks real-time transactional activity and user submissions (`Student_Exam_Attempt`, `Student_Answers`).

---

## 📂 Repository Contents
* `Database_Schema_And_Logic.sql`: Comprehensive SQL script containing tables initialization, foreign key constraints, indexes, triggers, custom functions, and stored procedures.
* `Project_Documentation.pdf`: Full structural technical documentation detailing business rules, logical mappings, and system specifications.

---
*Developed as part of the Instant-Backend Development Program.* **Author:** Hajer Eid  
**Instructor:** Eng. Ahmad Waled  
**Round:** Instant-Backend Round #34
