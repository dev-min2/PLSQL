-- 전민교

SET SERVEROUTPUT ON;
-- 2번 문제
DECLARE
    TYPE emp_rec_type IS RECORD(
        dept_name departments.department_name%TYPE,
        jobid employees.job_id%TYPE,
        salary employees.SALARY%TYPE,
        annualSal NUMBER
    );
    emp_rec emp_rec_type;
BEGIN
    SELECT B.department_name, A.job_id, A.salary, (A.salary * 12 + (NVL(A.salary,0) * NVL(commission_pct,0) * 12)) as annualSal
        INTO emp_rec
        FROM employees A
        LEFT JOIN departments B ON A.department_id = B.department_id
        WHERE A.employee_id = &사원번호;
        
    DBMS_OUTPUT.PUT_LINE(emp_rec.dept_name);
    DBMS_OUTPUT.PUT_LINE(emp_rec.jobid);
    DBMS_OUTPUT.PUT_LINE(emp_rec.salary);
    DBMS_OUTPUT.PUT_LINE(emp_rec.annualSal);
END;
/

-- 3번문제
DECLARE
    v_hire employees.hire_date%TYPE;
    v_str VARCHAR2(100);
BEGIN
    SELECT hire_date
        into v_hire
        FROM employees
        WHERE employee_id = &사원번호;
        
        IF TO_CHAR(v_hire,'yyyy') > '2015' THEN
            v_str := 'New employee';
        ELSE
            v_str := 'Career employee';
        END IF;
        DBMS_OUTPUT.PUT_LINE(v_str);
END;
/

-- 4번문제
DECLARE
BEGIN
    FOR dan IN 1..9 LOOP
        IF MOD(dan,2) = 0 THEN
            CONTINUE;
        END IF;
        
        FOR idx IN 1..9 LOOP
            DBMS_OUTPUT.PUT(dan || ' * ' || idx || ' = ' || (dan * idx));
            DBMS_OUTPUT.PUT(', ');
        END LOOP;
        DBMS_OUTPUT.PUT_Line('');
    END LOOP;
END;
/

-- 5번문제
DECLARE
    CURSOR emp_cur IS
        SELECT employee_id, last_name, salary
            FROM employees
            WHERE department_id = &부서번호;
BEGIN
    FOR emp_rec IN emp_cur LOOP
        DBMS_OUTPUT.PUT_LINE(emp_rec.employee_id);
        DBMS_OUTPUT.PUT_LINE(emp_rec.last_name);
        DBMS_OUTPUT.PUT_LINE(emp_rec.salary);
    END LOOP;
END;
/

-- 6번문제
CREATE PROCEDURE yedam06(p_empid IN employees.employee_id%TYPE, p_raise IN NUMBER)
IS
    v_exception EXCEPTION;
BEGIN
    UPDATE employees
    SET SALARY = SALARY + (SALARY * (p_raise / 100))
    WHERE employee_id = p_empid;
    
    IF SQL%ROWCOUNT = 0 THEN
        RAISE v_exception;
    END IF;
    
EXCEPTION
    WHEN v_exception THEN
        DBMS_OUTPUT.PUT_LINE('No search employee!!');
END;
/

EXECUTE yedam06(100);

-- 7번문제
CREATE OR REPLACE PROCEDURE yedam07(p_ssn IN VARCHAR)
IS
    v_human_year varchar2(10) := '';
    v_human_age number(3,0) := 0;
    v_gender char(1) := '';
BEGIN
    v_gender := SUBSTR(p_ssn,7,1);
    v_human_year := SUBSTR(p_ssn,1,6);
    
    IF v_gender = '1' OR v_gender = '2' THEN
        v_human_year := '19' || v_human_year;
    ELSIF v_gender = '3' OR v_gender = '4' THEN
        v_human_year := '20' || v_human_year;
    END IF;
    
    v_human_age := TRUNC(MONTHS_BETWEEN(TRUNC(SYSDATE), TO_DATE(v_human_year,'YYYYMMDD')) / 12);
    
    DBMS_OUTPUT.PUT_LINE(v_human_age); -- 나이
    IF v_gender = '1' OR v_gender = '3' THEN
        DBMS_OUTPUT.PUT_LINE('남성');
    ELSIF v_gender = '2' OR v_gender = '4' THEN
        DBMS_OUTPUT.PUT_LINE('여성');
    END IF;
END;
/

EXECUTE yedam07('0211023234567');

-- 8번문제
CREATE OR REPLACE FUNCTION yedam08(p_emp_id IN employees.employee_id%TYPE)
RETURN NUMBER
IS
    v_hire employees.hire_date%TYPE;
    v_result NUMBER := 0;
BEGIN
    SELECT hire_date
        INTO v_hire
        FROM employees
        WHERE employee_id = p_emp_id;
        
    v_result := months_between(sysdate, v_hire);
    v_result := TRUNC(v_result / 12,0);

    return v_result;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN '직원이 존재하지 않음.';
END;
/

EXECUTE DBMS_OUTPUT.PUT_LINE('근무년수 : ' || yedam08(100) || '년');
    
-- 9번문제
CREATE OR REPLACE FUNCTION yedam09(p_dept_name departments.department_name%TYPE)
RETURN VARCHAR2
IS
    v_dept_manager_name employees.last_name%TYPE;
    v_dept_exception EXCEPTION;
BEGIN
    SELECT last_name
        into v_dept_manager_name
        FROM employees
        WHERE employee_id = (
                    SELECT manager_id 
                        FROM departments
                        WHERE department_name = p_dept_name 
                    );

    
    return v_dept_manager_name;
END;
/

EXECUTE DBMS_OUTPUT.PUT_LINE('책임자(Manager) 이름 : ' || yedam09('IT'));

-- 10번문제
SELECT name,text
FROM user_source
WHERE type IN ('PROCEDURE', 'FUNCTION','PACKAGE','PACKAGE BODY');

-- 11번문제
DECLARE
    
BEGIN
    FOR idx IN 1..9 LOOP
        FOR innerIdx IN REVERSE 1..10 LOOP
            IF idx >= innerIdx THEN
                DBMS_OUTPUT.PUT('*');
            ELSE
                DBMS_OUTPUT.PUT('-');
            END IF;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;
END;
/