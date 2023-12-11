set serveroutput on;

DECLARE
    v_eid NUMBER;
    v_ename employees.first_name%TYPE;
    v_job VARCHAR2(1000);
BEGIN
    SELECT employee_id, first_name, job_id
    INTO v_eid, v_ename, v_job
    FROM employees 
    WHERE employee_id = 0;
    
    DBMS_OUTPUT.PUT_LINE('사원번호 : ' || v_eid);
    DBMS_OUTPUT.PUT_LINE('네미 : ' || v_ename);
    DBMS_OUTPUT.PUT_LINE('지겁 : ' || v_job);  
END;
/ 

DECLARE
    v_tt NUMBER := 100; -- 치환변수에 변수도 넣을수있음.
    v_eid employees.employee_Id%TYPE := &사원번호; -- 치환변수(PLSQL 컴파일전에 입력을 받고 수행)
    v_ename employees.first_name%TYPE; -- 먼타입인지 모를떄 ㅎ
BEGIN
    SELECT first_name || ',' || last_name
    INTO v_ename
    FROM employees
    WHERE employee_id = v_eid;
    
    DBMS_OUTPUT.PUT_LINE('사원번호 : ' || v_eid);
    DBMS_OUTPUT.PUT_LINE('네미 : ' || v_ename);
END;
/

select *
    from employees
    order by employee_id;

--1) 특정 사원의 매니저에 해당하는 사원번호를 출력 : 특정 사원은 치환변수를 사용
DECLARE
    v_emid employees.employee_id%TYPE := &사원번호; -- 치환변수(PLSQL 컴파일전에 입력을 받고 수행)
    v_managerid employees.manager_id%TYPE;
BEGIN
    SELECT manager_id
    INTO v_managerid
    FROM employees
    WHERE employee_id = v_emid;
    
    DBMS_OUTPUT.PUT_LINE('사원번호 : ' || v_emid);
    DBMS_OUTPUT.PUT_LINE('매니저번호 : ' || v_managerid);
END;
/

DECLARE 
    v_deptno departments.department_id%TYPE;
    v_comm employees.commission_pct%TYPE;
BEGIN
    SELECT department_id
    INTO v_deptno
    FROM employees
    WHERE employee_id = &사원번호;
    
    INSERT INTO employees(employee_id, last_name, email, hire_date, department_id, job_id)
    VALUES(1000,'Hong', 'hkd@google.com', sysdate, v_deptno, 'IT_PROG');
    
    -- SQL 커서
    DBMS_OUTPUT.PUT_LINE('등록 결과 : ' || SQL%ROWCOUNT);
    
    UPDATE employees
    SET salary = (NVL(salary,0) + 10000) * v_comm
    WHERE employee_id = 1000;
    
    -- SQL 커서 (ROWCOUNT WHERE 절에 )
    DBMS_OUTPUT.PUT_LINE('수정 결과 : ' || SQL%ROWCOUNT);
END;
/

ROLLBACK;
DELETE FROM EMPLOYEES WHERE EMPLOYEE_ID = 1000;
SELECT *
    FROM EMPLOYEES
    WHERE EMPLOYEE_ID = 1000;
/    

BEGIN
    DELETE FROM employees
    WHERE employee_id = &사원번호;
    
    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('해당 사원은 존재하지 않습니다.');
    END IF;
END;
/
    
    
    
    
/*
    1. 사원번호를 입력할 경우 사원번호, 사원이름, 부서이름을 출력하는 PL/SQL을 작성하시오.
    사원번호는 치환변수를 통해 입력
    
    2. 사원번호를 입력할 경우 사원이름,급여,연봉을 출력하는 PL/SQL작성
    사원번호는 치환변수 사용
    연봉은 아래 공식을 기반으로 연산
    (급여 * 12 + ( NVL(급여,0) * NVL(커미션,0 ) * 12 ))
*/

DECLARE
    v_empid employees.EMPLOYEE_ID%TYPE;
    v_name employees.LAST_NAME%TYPE;
    v_departname departments.department_name%TYPE;
BEGIN
    SELECT A.EMPLOYEE_ID, A.LAST_NAME, B.DEPARTMENT_NAME
        INTO v_empid, v_name, v_departname
        FROM EMPLOYEES A
        JOIN DEPARTMENTS B ON A.DEPARTMENT_ID = B.DEPARTMENT_ID
        WHERE A.employee_id = &사원버노;
        
    DBMS_OUTPUT.PUT_LINE('사원번호' || v_empid);
    DBMS_OUTPUT.PUT_LINE('사원이름' || v_name);
    DBMS_OUTPUT.PUT_LINE('사원부서명' || v_departname);
END;
/
DECLARE
    v_name employees.LAST_NAME%TYPE;
    v_salary employees.salary%TYPE;
    v_annualSal NUMBER;
BEGIN
    SELECT LAST_NAME, SALARY, (SALARY * 12 + (NVL(SALARY,0) * NVL(COMMISSION_PCT,0) * 12)) AS annualSal
        INTO v_name, v_salary, v_annualSal
        FROM EMPLOYEES
        WHERE EMPLOYEE_ID = &사원버농;
    
    DBMS_OUTPUT.PUT_LINE('사원이름' || v_name);
    DBMS_OUTPUT.PUT_LINE('사원급여' || v_salary);
    DBMS_OUTPUT.PUT_LINE('사원연봉' || v_annualSal);
END;
/    


-- IF문

BEGIN
    DELETE FROM employees
    WHERE employee_id = &사원번호;
    
    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('멀봄?');    
    END IF;
END;
/

DECLARE
    v_count NUMBER;
    
BEGIN
    SELECT COUNT(EMPLOYEE_ID)
        INTO v_count
        FROM employees
        WHERE manager_id = &eid;
        
    IF v_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('일반사원임');
    ELSE
        DBMS_OUTPUT.PUT_LINE('팀장임');
    END IF;
END;
/

-- IF ELSIF ELSE 문 : 연차
DECLARE
    v_hdate NUMBER;
BEGIN
    SELECT TRUNC(MONTHS_BETWEEN(SYSDATE, HIRE_DATE) / 12) AS HI
    INTO v_hdate
    FROM employees
    WHERE employee_id = &사원번호;
    
    IF v_hdate < 5 THEN -- 입사한지 5년 미만
        DBMS_OUTPUT.PUT_LINE('입사한지 5년 미만 임둥.');   
    ELSIF v_hdate < 10 THEN -- 입사한지 10년 미만
        DBMS_OUTPUT.PUT_LINE('입사한지 10년 미만 임둥.');
    ELSIF v_hdate < 15 THEN -- 입사한지 15년 미만
        DBMS_OUTPUT.PUT_LINE('입사한지 15년 미만 임둥.');
    ELSIF v_hdate < 20 THEN -- 20미만
        DBMS_OUTPUT.PUT_LINE('입사한지 20년 미만 임둥.');
    ELSE  -- 그 외.
        DBMS_OUTPUT.PUT_LINE('입사한지 20년 이상 임둥.');
    END IF;
END;
/

DECLARE
    v_hire date;
    v_str VARCHAR2(100);
BEGIN
    SELECT hire_date
        into v_hire
        FROM employees
        WHERE employee_id = &사원번호;
        
        IF v_hire >= TO_DATE('2005-01-01', 'YYYY-MM-DD') THEN
            v_str := 'new employee';
        ELSE
            v_str := 'career employee';
        END IF;
        DBMS_OUTPUT.PUT_LINE(v_str);
END;
/

DECLARE
    v_sal employees.salary%TYPE;
    v_name employees.last_name%TYPE;
BEGIN
    SELECT SALARY, LAST_NAME
        INTO v_sal, v_name
        FROM employees
        WHERE employee_id = &버농;
              
    IF v_sal <= 5000 THEN
        DBMS_OUTPUT.PUT_LINE(v_sal + (v_sal * (20 / 100)));
    ELSIF v_sal <= 10000 THEN
        DBMS_OUTPUT.PUT_LINE(v_sal + (v_sal * (15 / 100)));
    ELSIF v_sal <= 15000 THEN 
        DBMS_OUTPUT.PUT_LINE(v_sal + (v_sal * (10 / 100)));
    ELSE 
        DBMS_OUTPUT.PUT_LINE('나가');
    END IF;
    
    DBMS_OUTPUT.PUT_LINE(v_name);
    DBMS_OUTPUT.PUT_LINE(v_sal);
END;
/


DECLARE
    v_idx NUMBER := 1;
    v_sum NUMBER := 0;
BEGIN
    LOOP
        EXIT WHEN v_idx > 10;
        DBMS_OUTPUT.PUT_LINE(v_idx);
        v_sum := v_sum + v_idx;
        v_idx := v_idx + 1;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('총합 : ' || v_sum);
END;
/

DECLARE
    v_idx NUMBER := 1;
    v_sum NUMBER := 0;
BEGIN
    WHILE v_idx <= 10 LOOP        
        DBMS_OUTPUT.PUT_LINE(v_idx);
        v_sum := v_sum + v_idx;
        v_idx := v_idx + 1;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('총합(WHILE) : ' || v_sum);
END;
/

DECLARE
    v_sum NUMBER := 0;
BEGIN
    -- idx라는 변수를 LOOP내부에서 사용
    FOR idx IN REVERSE 1..10 LOOP
        v_sum := v_sum + idx;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(v_sum);
END;
/

DECLARE
    v_str VARCHAR2(100) := '*';
BEGIN
    DBMS_OUTPUT.PUT_LINE('for in 별');
    FOR idx IN 1..5 LOOP
        DBMS_OUTPUT.PUT_LINE(v_str);   
        v_str := v_str || '*';
    END LOOP;    
END;
/

DECLARE
    v_str VARCHAR2(100) := '*';
    v_idx NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('while문 별');
    WHILE v_idx < 5 LOOP
        DBMS_OUTPUT.PUT_LINE(v_str);
        v_idx := v_idx + 1;
        v_str := v_str || '*';
    END LOOP;
END;
/

DECLARE
    v_str VARCHAR2(100) := '*';
    v_idx NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('For문 별');
    LOOP
        EXIT WHEN v_idx >= 5;
        DBMS_OUTPUT.PUT_LINE(v_str);
        v_idx := v_idx + 1;
        v_str := v_str || '*';
    END LOOP;
END;
/

DECLARE

BEGIN
    DBMS_OUTPUT.PUT_LINE('for in 2중 반복문 별');
    FOR idx IN 1..5 LOOP
        FOR innerIdx IN 1..idx LOOP
            DBMS_OUTPUT.PUT('*');
        END LOOP;
    DBMS_OUTPUT.PUT_LINE('');
    END LOOP;    
END;
/

DECLARE
    v_idx number := 1;
    v_innerIdx number := 1;
BEGIN
    DBMS_OUTPUT.PUT_LINE('While 2중 반복문 별');
    WHILE v_idx <= 5 LOOP
        v_innerIdx := 1;
        
        WHILE v_innerIdx <= v_idx LOOP
            DBMS_OUTPUT.PUT('*');
            v_innerIdx := v_innerIdx + 1;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('');
        v_idx := v_idx + 1;
    END LOOP;
END;
/

DECLARE 
    v_idx number := 0;
    v_innerIdx number := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('일반 LOOP');
    LOOP 
        EXIT WHEN v_idx > 4;
            LOOP
            EXIT WHEN v_innerIdx > v_idx;
                DBMS_OUTPUT.PUT('*');
                v_innerIdx := v_innerIdx + 1;
            END LOOP;
        v_idx := v_idx + 1;
        v_innerIdx := 0;
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;
END;
/