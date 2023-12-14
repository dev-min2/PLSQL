SET SERVEROUTPUT ON;

DECLARE
    CURSOR emp_cursor IS
        SELECT employee_id, last_name, job_id
            FROM employees
            WHERE department_id = &부서번호;
BEGIN
    -- OPEN, PETCH, CLOSE안해도됨 (FOR IN LOOP 쓰믄!)
    -- emp_cursor가 가리키는 활성집합(결과집합)의 데이터가 하나도없으면 FOR IN LOOP는 동작조차안함(커서도 안열림)
    FOR emp_rec IN emp_cursor LOOP
        --DBMS_OUTPUT.PUT(emp_cursor%ROWCOUNT); 커서접근가능
        DBMS_OUTPUT.PUT(emp_rec.employee_id);
        DBMS_OUTPUT.PUT(', ' || emp_rec.last_name);
        DBMS_OUTPUT.PUT_LINE(', ' || emp_rec.job_id);
    END LOOP;
END;
/

DECLARE

BEGIN
    FOR emp_rec IN (SELECT employee_id, last_name
                        FROM employees
                        WHERE department_id = &부서번호) LOOP
        DBMS_OUTPUT.PUT(emp_rec.employee_id);          
        DBMS_OUTPUT.PUT_LINE(', ' || emp_rec.last_name);
    END LOOP; 
END;
/

--1
DECLARE
    CURSOR emp_cursor IS
        SELECT employee_id, last_name, NVL(department_name, '업서용') AS department_name
            FROM employees A
            LEFT JOIN departments B ON A.department_id = B.department_id;
BEGIN
    FOR emp_rec IN emp_cursor LOOP
        DBMS_OUTPUT.PUT(emp_rec.employee_id || ', ');
        DBMS_OUTPUT.PUT(emp_rec.last_name || ', ');
        DBMS_OUTPUT.PUT_LINE(emp_rec.department_name);
    END LOOP;
END;
/

--2
DECLARE

BEGIN
    FOR emp_rec IN (
        SELECT last_name, salary, (salary * 12 + (NVL(salary,0) * NVL(commission_pct,0) * 12)) as annualSal
            FROM employees
            WHERE department_id IN (50,80)
    ) LOOP
        DBMS_OUTPUT.PUT(emp_rec.last_name || ', ');
        DBMS_OUTPUT.PUT(emp_rec.salary || ', ');
        DBMS_OUTPUT.PUT_LINE(emp_rec.annualSal);
    END LOOP;
END;
/

-- 매개변수 명시적 커서
DECLARE
    CURSOR emp_cursor(p_deptno NUMBER) IS
        SELECT last_name, hire_date
            FROM employees
            WHERE department_id = p_deptno;
    
    emp_info emp_cursor%ROWTYPE;
BEGIN
    OPEN emp_cursor(60);
    
    FETCH emp_cursor INTO emp_info;
    DBMS_OUTPUT.PUT_LINE(emp_info.last_name);
    
    CLOSE emp_cursor;
END;
/


-- 현재 존재하는 모든 부서의 각 소속사원을 출력하고, 부서에 소속된 사원이 없는경우 '현재 소속사원이 없습니다.'
-- 
DECLARE
    CURSOR depart_cursor IS
        SELECT department_id, department_name
            FROM departments;
    
    CURSOR emp_cursor(deptNo NUMBER) IS
        SELECT employee_id, last_name, hire_date, JOB_ID
            FROM employees
            WHERE department_id = deptNo;
            
    departs depart_cursor%ROWTYPE;    
    emp_rec emp_cursor%ROWTYPE;
BEGIN
    -- 부서
    -- 사원번호
    -- FOR emp_rec IN
    FOR depart_rec IN depart_cursor LOOP
        DBMS_OUTPUT.PUT_LINE('부서명 : ' || depart_rec.department_name);
        
        OPEN emp_cursor(depart_rec.department_id);
        
        LOOP
            FETCH emp_cursor INTO emp_rec;
            EXIT WHEN emp_cursor%NOTFOUND;
            
            DBMS_OUTPUT.PUT(emp_rec.employee_id || ' ' || emp_rec.last_name || ' ' || emp_rec.hire_date || ' ' || emp_rec.JOB_ID);
            DBMS_OUTPUT.PUT_LINE(' ');
        END LOOP;
        
        IF emp_cursor%ROWCOUNT = 0 THEN -- FOR IN 루프에선 END LOOP에서 바로 emp_cursor가 닫히기때문에 이런 코드가 불가능함.
            DBMS_OUTPUT.PUT_LINE('소속된게 없나봄');
        END IF;
        
        CLOSE emp_cursor;
    END LOOP;
END;
/




-- 예외처리
DECLARE
    v_ename employees.last_name%TYPE;
BEGIN
    SELECT last_name
        INTO v_ename
        FROM employees
        WHERE department_id = &부서번호;
        
    -- no data founds 와 too many 어쩌고 발생할 수 있음
    DBMS_OUTPUT.PUT_LINE(v_ename);
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN 
        DBMS_OUTPUT.PUT_LINE('해당 부서에 속한 사원이 없슴둥');
    WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('넘 많엉');
    
    DBMS_OUTPUT.PUT_LINE('예외처리가 끝났습니다');
END;
/


-- 2 이미 정의는 되어있지만 고유의 이름이 존재하지 않는 예외사항
DECLARE
    e_emps_remaining EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_emps_remaining, -02292);
BEGIN
    DELETE FROM departments
    WHERE department_id = &부서번호;
EXCEPTION
    WHEN e_emps_remaining THEN
        DBMS_OUTPUT.PUT_LINE('해당 부서에 속한 사원이 존재합니다.');
END;
/

-- 사용자 정의 사항
DECLARE
    e_no_deptno EXCEPTION;
BEGIN
    DELETE FROM departments
    WHERE department_id = &부서번호;
    
    IF SQL%ROWCOUNT = 0 THEN
        RAISE e_no_deptno;
    END IF;
EXCEPTION
    WHEN e_no_deptno THEN
        DBMS_OUTPUT.PUT_LINE('해당 부서번호는 존재하지 않습니다.');
    WHEN OTERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLCODE);
END;
/

-- 사용자 정의사항
DECLARE 
    e_no_deptno EXCEPTION;
    v_ex_code NUMBER;
    v_ex_msg VARCHAR2(1000);
BEGIN
    DELETE FROM departments
    WHERE department_id = &부서번호;
EXCEPTION
    WHEN e_no_deptno THEN
        DBMS_OUTPUT.PUT_LINE('해당 부서번호는 존재하지 않습니다.');
    WHEN OTHERS THEN
        v_ex_code := SQLCODE;
        v_ex_msg := SQLERRM;
        DBMS_OUTPUT.PUT_LINE(v_ex_code);
        DBMS_OUTPUT.PUT_LINE(v_ex_msg);
END;
/
    
CREATE TABLE test_employee
AS
    SELECT *
        FROM EMPLOYEES;
COMMIT;



DECLARE
BEGIN
    DELETE FROM test_employee WHERE employee_id = &idㅋ;
    IF SQL%ROWCOUNT = 0 THEN
        RAISE NO_DATA_FOUND;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('삭제되었음니다.');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('해당 사원이 존재하지 않읍니다.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('니가 뭘할수있는데?');
END;
/

    
DECLARE
    v_eid employees.employee_id%TYPE := &사어버노;
    v_ne_emp EXCEPTION;
BEGIN
    DELETE FROM test_employee WHERE employee_id = v_eid;
    IF SQL%ROWCOUNT = 0 THEN
        RAISE v_ne_emp;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('삭');
EXCEPTION
    WHEN v_ne_emp THEN
        DBMS_OUTPUT.PUT(v_eid || ', ');
        DBMS_OUTPUT.PUT_LINE('현재 테이블에 존재하지 않아용~');
END;
/

CREATE PROCEDURE test_pro
--  () 매개변수가 있다면 정의
IS -- IS뒤에 DECLARE 처럼 변수선언.

BEGIN
    DBMS_OUTPUT.PUT_LINE('First Procedure');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ㅎㅇ용');    
        
END;
/

-- 스토어드 프로시저 호출법1
BEGIN
    TEST_PRO;
END;
/

-- 스토어드 프로시저 호출법2
-- 한번에 여러개 호출은 불가능
EXECUTE TEST_PRO;

-- 삭제염
DROP PROCEDURE TEST_PRO;
COMMIT;

-- 프로시저 in/out/in out

-- IN
--> 값을 서브 프로그램에 전달 (목적)
--> 형식 매개변수가 상수로 작용 (내부인식)
--> 실제 매개변수는 리터럴, 표현식, 상수 또는 초기화된 변수 (호출 시 사용가능한 형태)

-- OUT
-- 명시여부 지정해야함
-- 값을 호출 환경으로 반환 (목적)
-- 초기화되지 않은 변수 (내부인식)
    -- 변수여야 함 (호출 시 사용가능한 형태)

-- IN OUT
-- 지정해야함
-- 값을 서브 프로그램에 전달하고 호출 환경으로 반환 (목적)
-- 초기화된 변수 (내부인식)
-- 변수여야 함 (호출 시 사용가능한 형태)


-- IN
CREATE PROCEDURE RAISE_SALARY
(p_eid IN NUMBER)
IS
BEGIN
    UPDATE employees
    SET SALARY = SALARY * 1.1
    WHERE employee_id = p_eid;
END;
/

DECLARE
    v_id employees.employee_id%TYPE := &사원번호;
    v_num CONSTANT NUMBER := v_id;
BEGIN
    RAISE_SALARY(v_id); -- 변수가능
    RAISE_SALARY(v_num); -- 상수가능
    RAISE_SALARY(v_num + 10); -- 연산식 결과(리터럴)가능
END;
/

CREATE PROCEDURE PRO_PLUS
(p_x IN NUMBER,
 p_y IN NUMBER,
 p_result OUT NUMBER
 )
IS
    v_sum NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT(p_x);
    DBMS_OUTPUT.PUT('+' || p_x);
    DBMS_OUTPUT.PUT_LINE(' = ' || p_x + p_y);
    
    v_sum := p_x + p_y;
    p_result := v_sum;
END;
/

DECLARE
    v_first NUMBER := 10;
    v_second NUMBER := 12;
    v_result NUMBER := 100;
BEGIN
    DBMS_OUTPUT.PUT_LINE('before ' || v_result);
    PRO_PLUS(v_first, v_second, v_result);
    DBMS_OUTPUT.PUT_LINE('after ' || v_result);
END;
/

-- IN OUT
-- 
CREATE PROCEDURE format_phone
(p_phone_no IN OUT VARCHAR2) -- 
IS

BEGIN
    p_phone_no := SUBSTR(p_phone_no, 1, 3) || '-' || SUBSTR(p_phone_no, 4, 4) || '-' || SUBSTR(p_phone_no, 8);
    
END;
/

DECLARE
    v_phone VARCHAR2(100) := '01052476023';
BEGIN
    DBMS_OUTPUT.PUT_LINE(v_phone);
    format_phone(v_phone);   
    DBMS_OUTPUT.PUT_LINE(v_phone);
END;
/

-- 프로시저 실습 1번
create PROCEDURE yedam_ju
(p_private_num IN VARCHAR2)
IS
    v_check char(1) := '0';
    v_year  char(4) := 0;
    v_month char(2) := 0;
    v_day char(2) := 0;
    v_after_year char(2) := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE(SUBSTR(p_private_num, 1, 6) || '-' || SUBSTR(p_private_num,7,1) || '******');
    
    v_check := SUBSTR(p_private_num,7,1);
    v_after_year := SUBSTR(p_private_num,1,2);
    
    IF(v_check = '1' OR v_check = '2') THEN
        v_year := ('19' || v_after_year);
    ELSIF(v_check = '3' OR v_check = '4') THEN
        v_year := ('20' || v_after_year);
    END IF;
    
    v_month := SUBSTR(p_private_num,3,2);
    v_day := SUBSTR(p_private_num,5,2);
    DBMS_OUTPUT.PUT_LINE(v_year || '년' || v_month || '월' || v_day || '일');
END;

DECLARE
    v_p_no VARCHAR2(1000) := '9501011667777';
    V_P_no2 VARCHAR2(1000) := '1511013689977';
BEGIN
    yedam_ju(v_p_no);
    yedam_ju(v_p_no2);
END;
/

-- 프로시저 실습 2번
CREATE PROCEDURE TEST_PRO
(p_eid IN VARCHAR2)
IS
    v_data_exception EXCEPTION;
BEGIN
    DELETE FROM employees WHERE employee_id = p_eid;
    
    IF SQL%ROWCOUNT = 0 THEN
        RAISE v_data_exception;
    END IF;
EXCEPTION
    WHEN v_data_exception THEN
        DBMS_OUTPUT.PUT_LINE('해당 사원이 없습니다.');
END;
/

EXECUTE TEST_PRO(9999);

-- 프로시저 실습 3번
CREATE OR REPLACE PROCEDURE yedam_emp
(p_eid IN NUMBER)
IS
    v_ename employees.last_name%TYPE;
BEGIN
    SELECT last_name
        INTO v_ename
        FROM employees
        WHERE employee_id = p_eid;
    
    v_ename := RPAD(SUBSTR(v_ename,1,1), LENGTH(v_ename) - 1, '*');
    DBMS_OUTPUT.PUT_LINE(v_ename);
END;
/

EXECUTE yedam_emp(176);

-- 프로시저 4번
CREATE OR REPLACE PROCEDURE y_update
(p_eid IN NUMBER, p_sal_inc_percent IN NUMBER)
IS
    v_exception EXCEPTION;
BEGIN
    UPDATE employees
    SET SALARY = SALARY + (SALARY * (p_sal_inc_percent / 100))
    WHERE employee_id = p_eid;
    
    IF SQL%ROWCOUNT = 0 THEN
        RAISE v_exception;
    END IF;
    
EXCEPTION
    WHEN v_exception THEN
        DBMS_OUTPUT.PUT_LINE('No search employee!!');
END;
/

EXECUTE y_update(130,50);
SELECT * FROM EMPLOYEES WHERE EMPLOYEE_ID = 130;

-- 프로시저 5번
create table yedam01
(y_id number(10),
 y_name varchar2(20));

create table yedam02
(y_id number(10),
 y_name varchar2(20));
COMMIT;

SELECT * FROM EMPLOYEES;
-- 5-1번, 5-2번 
create or replace PROCEDURE y_proc
(p_dept_id IN NUMBER)
IS
    CURSOR emp_cursor(dept_id NUMBER) IS
        SELECT *
            FROM employees 
            WHERE department_id = dept_id;
            
    dept_rec departments.department_id%TYPE;
    emp_rec emp_cursor%ROWTYPE;
    emp_no_data_exection EXCEPTION;
BEGIN
    SELECT department_id
            INTO dept_rec
            FROM departments
            WHERE department_id = p_dept_id;
    
    OPEN emp_cursor(p_dept_id);
    
    LOOP
        FETCH emp_cursor INTO emp_rec;
        EXIT WHEN emp_cursor%NOTFOUND;
        
        IF emp_rec.hire_date < TO_DATE('2005-01-01','yyyy-MM-dd') THEN
            INSERT INTO yedam01 values(
                emp_rec.employee_id,
                emp_rec.last_name
            );
        ELSE
            INSERT INTO yedam02 values(
                emp_rec.employee_id,
                emp_rec.last_name
            );
        END IF;
    END LOOP;
    
    IF emp_cursor%ROWCOUNT = 0 THEN
        RAISE emp_no_data_exection;
    END IF;
    
    CLOSE emp_cursor;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('해당 부서가 없슴다');
    WHEN emp_no_data_exection THEN
        DBMS_OUTPUT.PUT_LINE('해당 부서에 사원이 없슴다');
        CLOSE emp_cursor;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('니가 뭘할수있는데?');
END;
/
EXECUTE y_proc(150);

    
SELECT *
    FROM yedam02;
    
SELECT *
    FROM EMPLOYEES;