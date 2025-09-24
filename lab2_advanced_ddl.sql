CREATE TABLESPACE student_data
LOCATION 'C:/pg_tblsp/students';

CREATE TABLESPACE course_data
LOCATION 'C:/pg_tblsp/courses';

ALTER TABLESPACE course_data OWNER TO postgres;

CREATE DATABASE university_main
WITH
    TEMPLATE = template0
    ENCODING = 'UTF8';

CREATE DATABASE university_archive
WITH
    TEMPLATE = template0
    CONNECTION LIMIT 50;

CREATE DATABASE university_test
WITH
    TEMPLATE = template0
    CONNECTION LIMIT 10;

ALTER DATABASE university_test IS_TEMPLATE = TRUE;

CREATE DATABASE university_distributed
WITH
    TEMPLATE = template0
    ENCODING = 'UTF8'
    TABLESPACE = student_data;

CREATE DATABASE university_main
WITH
    TEMPLATE = template0
    ENCODING = 'UTF8';

SELECT datname, datistemplate
FROM pg_database
WHERE datname LIKE 'university%';

CREATE TABLE IF NOT EXISTS students (
    student_id        SERIAL PRIMARY KEY,
    first_name        VARCHAR(50)  NOT NULL,
    last_name         VARCHAR(50)  NOT NULL,
    email             VARCHAR(100) UNIQUE NOT NULL,
    phone             CHAR(15),
    date_of_birth     DATE,
    enrollment_date   DATE,
    gpa               NUMERIC(3,2),
    is_active         BOOLEAN DEFAULT TRUE,
    graduation_year   SMALLINT
);

CREATE TABLE IF NOT EXISTS professors (
    professor_id      SERIAL PRIMARY KEY,
    first_name        VARCHAR(50)  NOT NULL,
    last_name         VARCHAR(50)  NOT NULL,
    email             VARCHAR(100) UNIQUE NOT NULL,
    office_number     VARCHAR(20),
    hire_date         DATE,
    salary            NUMERIC(12,2),
    is_tenured        BOOLEAN,
    years_experience  INTEGER
);

CREATE TABLE IF NOT EXISTS courses (
    course_id      SERIAL PRIMARY KEY,
    course_code    CHAR(8) NOT NULL,
    course_title   VARCHAR(100) NOT NULL,
    description    TEXT,
    credits        SMALLINT,
    max_enrollment INTEGER,
    course_fee     NUMERIC(10,2),
    is_online      BOOLEAN DEFAULT FALSE,
    created_at     TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS class_schedule (
    schedule_id  SERIAL PRIMARY KEY,
    course_id    INTEGER NOT NULL,
    professor_id INTEGER NOT NULL,
    classroom    VARCHAR(20),
    class_date   DATE,
    start_time   TIME WITHOUT TIME ZONE,
    end_time     TIME WITHOUT TIME ZONE,
    duration     INTERVAL
);

CREATE TABLE IF NOT EXISTS student_records (
    record_id             SERIAL PRIMARY KEY,
    student_id            INTEGER NOT NULL,
    course_id             INTEGER NOT NULL,
    semester              VARCHAR(20),
    year                  INTEGER,
    grade                 CHAR(2),
    attendance_percentage NUMERIC(4,1),
    submission_timestamp  TIMESTAMPTZ,
    last_updated          TIMESTAMPTZ
);

ALTER TABLE students
  ADD COLUMN IF NOT EXISTS middle_name VARCHAR(30);
ALTER TABLE students
  ADD COLUMN IF NOT EXISTS student_status VARCHAR(20);
ALTER TABLE students
  ALTER COLUMN phone TYPE VARCHAR(20);
ALTER TABLE students
  ALTER COLUMN student_status SET DEFAULT 'ACTIVE';
ALTER TABLE students
  ALTER COLUMN gpa SET DEFAULT 0.00;

ALTER TABLE professors
  ADD COLUMN IF NOT EXISTS department_code CHAR(5);
ALTER TABLE professors
  ADD COLUMN IF NOT EXISTS research_area TEXT;
ALTER TABLE professors
  ALTER COLUMN years_experience TYPE SMALLINT;
ALTER TABLE professors
  ALTER COLUMN is_tenured SET DEFAULT FALSE;
ALTER TABLE professors
  ADD COLUMN IF NOT EXISTS last_promotion_date DATE;

ALTER TABLE courses
  ADD COLUMN IF NOT EXISTS prerequisite_course_id INTEGER;
ALTER TABLE courses
  ADD COLUMN IF NOT EXISTS difficulty_level SMALLINT;
ALTER TABLE courses
  ALTER COLUMN course_code TYPE VARCHAR(10);
ALTER TABLE courses
  ALTER COLUMN credits SET DEFAULT 3;
ALTER TABLE courses
  ADD COLUMN IF NOT EXISTS lab_required BOOLEAN DEFAULT FALSE;

ALTER TABLE class_schedule
  ADD COLUMN IF NOT EXISTS room_capacity INTEGER;
ALTER TABLE class_schedule
  DROP COLUMN IF EXISTS duration;
ALTER TABLE class_schedule
  ADD COLUMN IF NOT EXISTS session_type VARCHAR(15);
ALTER TABLE class_schedule
  ALTER COLUMN classroom TYPE VARCHAR(30);
ALTER TABLE class_schedule
  ADD COLUMN IF NOT EXISTS equipment_needed TEXT;

ALTER TABLE student_records
  ADD COLUMN IF NOT EXISTS extra_credit_points NUMERIC(4,1);
ALTER TABLE student_records
  ALTER COLUMN grade TYPE VARCHAR(5);
ALTER TABLE student_records
  ALTER COLUMN extra_credit_points SET DEFAULT 0.0;
ALTER TABLE student_records
  ADD COLUMN IF NOT EXISTS final_exam_date DATE;
ALTER TABLE student_records
  DROP COLUMN IF EXISTS last_updated;

CREATE TABLE IF NOT EXISTS departments (
    department_id   SERIAL PRIMARY KEY,
    department_code CHAR(5) UNIQUE NOT NULL,
    department_name VARCHAR(100) NOT NULL,
    building        VARCHAR(50),
    budget          NUMERIC(12,2)
);

CREATE TABLE IF NOT EXISTS library_books (
    book_id     SERIAL PRIMARY KEY,
    title       VARCHAR(200) NOT NULL,
    author      VARCHAR(100),
    isbn        CHAR(13) UNIQUE,
    published_year SMALLINT,
    available_copies INTEGER DEFAULT 1
);

CREATE TABLE IF NOT EXISTS student_book_loans (
    loan_id      SERIAL PRIMARY KEY,
    student_id   INTEGER NOT NULL,
    book_id      INTEGER NOT NULL,
    loan_date    DATE NOT NULL DEFAULT CURRENT_DATE,
    return_date  DATE,
    is_returned  BOOLEAN DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS semester_calendar (
    semester_code VARCHAR(10) PRIMARY KEY,
    start_date    DATE NOT NULL,
    end_date      DATE NOT NULL,
    description   VARCHAR(100)
);

ALTER TABLE professors ADD COLUMN IF NOT EXISTS department_id INTEGER;
ALTER TABLE students   ADD COLUMN IF NOT EXISTS advisor_id    INTEGER;
ALTER TABLE courses    ADD COLUMN IF NOT EXISTS department_id INTEGER;

CREATE TABLE IF NOT EXISTS grade_scale (
    grade_id       SERIAL PRIMARY KEY,
    letter_grade   CHAR(2) NOT NULL,
    min_percentage NUMERIC(4,1) NOT NULL,
    max_percentage NUMERIC(4,1) NOT NULL
);

ALTER TABLE students   ADD CONSTRAINT uq_students_email   UNIQUE (email);
ALTER TABLE professors ADD CONSTRAINT uq_professors_email UNIQUE (email);

ALTER TABLE courses ADD CONSTRAINT uq_courses_code UNIQUE (course_code);

ALTER TABLE student_records
  ADD CONSTRAINT uq_student_course UNIQUE (student_id, course_id, semester, year);

ALTER TABLE professors
  ADD CONSTRAINT fk_professors_department
  FOREIGN KEY (department_id) REFERENCES departments(department_id);

ALTER TABLE students
  ADD CONSTRAINT fk_students_advisor
  FOREIGN KEY (advisor_id) REFERENCES professors(professor_id);

ALTER TABLE courses
  ADD CONSTRAINT fk_courses_department
  FOREIGN KEY (department_id) REFERENCES departments(department_id);

ALTER TABLE class_schedule
  ADD CONSTRAINT fk_schedule_course
  FOREIGN KEY (course_id) REFERENCES courses(course_id);

ALTER TABLE class_schedule
  ADD CONSTRAINT fk_schedule_professor
  FOREIGN KEY (professor_id) REFERENCES professors(professor_id);

ALTER TABLE student_records
  ADD CONSTRAINT fk_records_student
  FOREIGN KEY (student_id) REFERENCES students(student_id);

ALTER TABLE student_records
  ADD CONSTRAINT fk_records_course
  FOREIGN KEY (course_id) REFERENCES courses(course_id);

ALTER TABLE student_records
  ADD CONSTRAINT fk_records_grade
  FOREIGN KEY (grade) REFERENCES grade_scale(letter_grade);

ALTER TABLE student_book_loans
  ADD CONSTRAINT fk_loans_student
  FOREIGN KEY (student_id) REFERENCES students(student_id);

ALTER TABLE student_book_loans
  ADD CONSTRAINT fk_loans_book
  FOREIGN KEY (book_id) REFERENCES library_books(book_id);

ALTER TABLE students
  ADD CONSTRAINT chk_students_gpa CHECK (gpa >= 0.0 AND gpa <= 4.0);

ALTER TABLE courses
  ADD CONSTRAINT chk_courses_credits CHECK (credits >= 0);

ALTER TABLE student_records
  ADD CONSTRAINT chk_records_attendance CHECK (attendance_percentage BETWEEN 0 AND 100);

ALTER TABLE grade_scale
  ADD CONSTRAINT chk_grade_scale_min CHECK (min_percentage >= 0 AND min_percentage <= 100);
ALTER TABLE grade_scale
  ADD CONSTRAINT chk_grade_scale_max CHECK (max_percentage >= 0 AND max_percentage <= 100);

