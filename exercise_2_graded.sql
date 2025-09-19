/* Create a table medication_stock in your Smart Old Age Home database. The table must have the following attributes:
 1. medication_id (integer, primary key)
 2. medication_name (varchar, not null)
 3. quantity (integer, not null)
 Insert some values into the medication_stock table. 
 Practice SQL with the following:
 */
CREATE TABLE doctors (
    doctor_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    specialization TEXT NOT NULL
);

CREATE TABLE patients (
    patient_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    age INT NOT NULL,
    room_no INT NOT NULL,
    doctor_id INT REFERENCES doctors(doctor_id)
);

create table nurses (
	nurse_id SERIAL PRIMARY KEY,
	nurse_name TEXT NOT NULL,
	nurse_shift TEXT NOT NULL
);

CREATE TABLE treatments (
    treatment_id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id),
    nurse_id INT REFERENCES nurses(nurse_id),
    treatment_type TEXT NOT NULL,
    treatment_time TIMESTAMP NOT NULL
);

CREATE TABLE sensors (
    sensor_id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id),
    sensor_type TEXT NOT NULL,
    reading NUMERIC NOT NULL,
    reading_time TIMESTAMP NOT NULL
);

INSERT INTO doctors (name, specialization) VALUES
('Dr. Smith', 'Geriatrics'),
('Dr. Johnson', 'Cardiology'),
('Dr. Lee', 'Neurology'),
('Dr. Patel', 'Endocrinology'),
('Dr. Adams', 'General Medicine');

INSERT INTO nurses (nurse_name, nurse_shift) VALUES
('Nurse Ann', 'Morning'),
('Nurse Ben', 'Evening'),
('Nurse Eva', 'Night'),
('Nurse Kim', 'Morning'),
('Nurse Omar', 'Evening');

INSERT INTO patients (name, age, room_no, doctor_id) 
VALUES
('Alice', 82, 101, 1),
('Bob', 79, 102, 2),
('Carol', 85, 103, 1),
('David', 88, 104, 3),
('Ella', 77, 105, 2),
('Frank', 91, 106, 4);

INSERT INTO treatments (patient_id, nurse_id, treatment_type, treatment_time) VALUES
(1, 1, 'Physiotherapy', '2025-09-10 09:00:00'),
(2, 2, 'Medication', '2025-09-10 18:00:00'),
(1, 3, 'Medication', '2025-09-11 21:00:00'),
(3, 1, 'Checkup', '2025-09-12 10:00:00'),
(4, 2, 'Physiotherapy', '2025-09-12 17:00:00'),
(5, 5, 'Medication', '2025-09-12 18:00:00'),
(6, 4, 'Physiotherapy', '2025-09-13 09:00:00');

CREATE TABLE medication_stock (
    medication_id SERIAL PRIMARY KEY,
    medication_name VARCHAR(30) NOT NULL,
    quantity INT NOT NULL
);

INSERT INTO medication_stock (medication_name, quantity) 
VALUES
('AMX', 50),
('FEP', 100),
('P', 25),
('TIC', 5);

 -- Q!: List all patients name and ages 
select name, age from patients;

 -- Q2: List all doctors specializing in 'Cardiology'

select * from doctors where specialization = 'Cardiology';
 
 -- Q3: Find all patients that are older than 80

select * from patients where age > 80;


-- Q4: List all the patients ordered by their age (youngest first)

select * from patients ORDER BY age asc;


-- Q5: Count the number of doctors in each specialization

select specialization, count(*) AS doctor_count from doctors
GROUP BY specialization;

-- Q6: List patients and their doctors' names

select p.name AS patients_name, d.name AS doctors_name 
from patients p JOIN doctors d ON d.doctor_id = p.doctor_id;


-- Q7: Show treatments along with patient names and doctor names
SELECT t.treatment_id, p.name AS patient_name, d.name AS doctor_name, t.treatment_type, t.treatment_time
FROM treatments t
JOIN patients p ON t.patient_id = p.patient_id
JOIN doctors d ON p.doctor_id = d.doctor_id;

-- Q8: Count how many patients each doctor supervises

select d.name AS doctors_name, count(p.patient_id) AS patients_count 
from doctors d JOIN patients p 
ON d.doctor_id = p.doctor_id
GROUP BY d.doctor_id;

-- Q9: List the average age of patients and display it as average_age

select AVG(age) AS average_age from patients;

-- Q10: Find the most common treatment type, and display only that

select treatment_type from treatments
group by treatment_type
order by count(*) DESC
limit 1;

-- Q11: List patients who are older than the average age of all patients

select * from patients
where age > (select avg(age) from patients);

-- Q12: List all the doctors who have more than 5 patients

select d.doctor_id, d.name, d.specialization, count(p.patient_id) as patient_count
from doctors d join patients p on d.doctor_id = p.doctor_id
group by d.doctor_id, d.name, d.specialization
having count(p.patient_id) > 5 ;


-- Q13: List all the treatments that are provided by nurses that work in the morning shift. List patient name as well. 

SELECT t.treatment_id, p.name AS patient_name, t.treatment_type, t.treatment_time, n.nurse_name AS nurse_name
FROM treatments t
JOIN nurses n ON t.nurse_id = n.nurse_id
JOIN patients p ON t.patient_id = p.patient_id
WHERE n.nurse_shift = 'Morning';


-- Q14: Find the latest treatment for each patient

WITH ranked_treatments AS (
    SELECT t.*, p.name AS patient_name,
        ROW_NUMBER() OVER (
            PARTITION BY t.patient_id 
            ORDER BY t.treatment_time DESC
        ) AS rn
    FROM treatments t
    JOIN patients p ON t.patient_id = p.patient_id
)
SELECT patient_id, patient_name, treatment_id, nurse_id, treatment_type, treatment_time AS latest_treatment_time
FROM ranked_treatments
WHERE rn = 1;

-- Q15: List all the doctors and average age of their patients

SELECT d.doctor_id, d.name AS doctor_name, d.specialization, AVG(p.age) AS average_patient_age
FROM doctors d
LEFT JOIN patients p ON d.doctor_id = p.doctor_id
GROUP BY d.doctor_id, d.name, d.specialization;

-- Q16: List the names of the doctors who supervise more than 3 patients

SELECT d.name AS doctor_name
FROM doctors d
JOIN patients p ON d.doctor_id = p.doctor_id
GROUP BY d.doctor_id, d.name
HAVING COUNT(p.patient_id) > 3;

-- Q17: List all the patients who have not received any treatments (HINT: Use NOT IN)

SELECT *
FROM patients
WHERE patient_id NOT IN (
    SELECT DISTINCT patient_id
    FROM treatments
);


-- Q18: List all the medicines whose stock (quantity) is less than the average stock

SELECT medication_id, medication_name, quantity
FROM medication_stock
WHERE quantity < (SELECT AVG(quantity) FROM medication_stock);


-- Q19: For each doctor, rank their patients by age

SELECT d.doctor_id, d.name AS doctor_name, p.patient_id, p.name AS patient_name, p.age,
    RANK() OVER (
        PARTITION BY d.doctor_id 
        ORDER BY p.age DESC
    ) AS age_rank
FROM doctors d
JOIN patients p ON d.doctor_id = p.doctor_id
ORDER BY d.doctor_id, age_rank;

-- Q20: For each specialization, find the doctor with the oldest patient

WITH patient_age_rank AS (
    SELECT d.doctor_id, d.name AS doctor_name, d.specialization, p.patient_id, p.name AS patient_name, p.age,
        ROW_NUMBER() OVER (
            PARTITION BY d.specialization 
            ORDER BY p.age DESC
        ) AS rn
    FROM doctors d
    JOIN patients p ON d.doctor_id = p.doctor_id
)
SELECT specialization, doctor_name, patient_name AS oldest_patient_name, age AS oldest_patient_age
FROM patient_age_rank
WHERE rn = 1
ORDER BY specialization;










