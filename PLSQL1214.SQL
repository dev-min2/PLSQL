-- 함수랑 프로시져 같음
-- 함수는 매개변수에 IN만 있음. 대신 RETURN이 반드시 있어야한다.
-- 함수는 단일 레코드(한 데이터)처리만 가능한 함수를 정의
-- DML(INSERT,UPDATE,DELETE) 명령 X (SELECT절에서 쓰이는 함수니.)


-- 프로시저 VS 함수
-- PL/SQL 문으로 실행 VS 표현식의 일부로 호출
-- RETURN 데이터 유형을 포함X VS RETURN 데이터 유형을 포함
-- 값을 반환하지않거나 하나 이상의 값을 반환 가능 VS 무조건 하나의 값만 반환.

CREATE FUNCTION plus
(p_x IN NUMBER, p_y NUMBER)
RETURN NUMBER -- RETURN TYPE 세팅.(세미콜론 빠져야함)
IS
    v_result NUMBER;
BEGIN
    v_result := p_x + p_y;
    
    RETURN v_result;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN '데이터가 존재하지 않습니다.';
    WHEN TOO_MANY_ROWS THEN
        RETURN '데이터가 요구한 것보다 많습니다.';
END;
/

DECLARE
    v_sum NUMBER;
BEGIN
    v_sum := plus(10,20); -- 
    DBMS_OUTPUT.PUT_LINE(v_sum);
END;
/

EXECUTE DBMS_OUTPUT.PUT_LINE(plus(10,20));

CREATE OR REPLACE FUNCTION y_factorial_recursive
(p_n IN NUMBER)
RETURN NUMBER
IS

BEGIN
    IF p_n <= 1 THEN
        RETURN 1;
    END IF;
    
    RETURN p_n * y_factorial_recursive(p_n - 1);
END;
/

CREATE FUNCTION y_factorial
(p_n IN NUMBER)
RETURN NUMBER
IS
    v_result NUMBER := 1;
BEGIN
    FOR idx IN 1..p_n LOOP
        v_result := v_result * idx;
    END LOOP;
    
    RETURN v_result;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN '데이터가 존재하지 않습니다.';
    WHEN TOO_MANY_ROWS THEN
        RETURN '데이터가 요구한 것보다 많습니다.';
END;
/

SELECT y_factorial(5) FROM DUAL;
SELECT y_factorial_recursive(5) FROM DUAL;


-- 1. 
CREATE OR REPLACE FUNCTION y_yedam
(p_emp_id IN NUMBER)
RETURN VARCHAR2
IS
    v_first_name employees.first_name%TYPE := '';
    v_last_name employees.last_name%TYPE := '';
BEGIN
    SELECT first_name, last_name
        INTO v_first_name, v_last_name
        FROM employees
        WHERE employee_id = p_emp_id;
        
    return v_last_name || ' ' || v_first_name;
END;
/

SELECT y_yedam(150) FROM DUAL;

-- 2.
CREATE FUNCTION ydinc
(p_empid employees.employee_id%TYPE)
RETURN NUMBER
IS
    v_sal employees.salary%TYPE;
BEGIN
    SELECT salary
        INTO v_sal
        FROM employees
        WHERE employee_id = p_empid;
        
        IF v_sal <= 5000 THEN
            v_sal := v_sal + (v_sal * 0.2);
        ELSIF v_sal <= 10000 THEN
            v_sal := v_sal + (v_sal * 0.15);
        ELSIF v_sal <= 20000 THEN
            v_sal := v_sal + (v_sal * 0.1);
        END IF;
        return v_sal;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN '데이터가 존재하지 않습니다.';
    WHEN TOO_MANY_ROWS THEN
        RETURN '데이터가 요구한 것보다 많습니다.';
END;
/

SELECT last_name, salary, ydinc(employee_id)
    FROM employees;

-- 3번
CREATE OR REPLACE FUNCTION yd_func
(p_empid employees.employee_id%TYPE)
RETURN NUMBER
IS
    v_sal employees.salary%TYPE;
    v_comm employees.commission_pct%TYPE;
BEGIN
    SELECT salary, commission_pct
        INTO v_sal, v_comm
        FROM employees
        WHERE employee_id = p_empid;
        
    return (v_sal+(v_sal * NVL(v_comm,0))) * 12;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN '데이터가 존재하지 않습니다.';
    WHEN TOO_MANY_ROWS THEN
        RETURN '데이터가 요구한 것보다 많습니다.';
END;
/

SELECT last_name, salary, YD_FUNC(employee_id)
     FROM employees;
     
-- 4번
CREATE OR REPLACE FUNCTION subname
(p_last_name employees.last_name%TYPE)
RETURN VARCHAR
IS

BEGIN
    return RPAD(SUBSTR(p_last_name,1,1),LENGTH(p_last_name), '*');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN '데이터가 존재하지 않습니다.';
    WHEN TOO_MANY_ROWS THEN
        RETURN '데이터가 요구한 것보다 많습니다.';
END;
/

SELECT last_name, subname(last_name)
FROM   employees;

-- 5번
CREATE OR REPLACE FUNCTION y_dept
(p_deptid departments.department_id%TYPE)
RETURN VARCHAR2

IS
    v_dept_manager_name employees.last_name%TYPE;
    v_deptid departments.department_id%TYPE;
    v_dept_exception EXCEPTION;
    v_dept_cnt Number := 0;
    
BEGIN
--    SELECT COUNT(*)
--        INTO v_dept_cnt
--        FROM departments
--        WHERE department_id = p_deptid;
--    
--    IF v_dept_cnt = 0 THEN
--        RAISE v_dept_exception;
--    END IF;
--        
--    SELECT last_name
--        INTO v_dept_manager_name
--        FROM employees A
--        JOIN departments B ON A.employee_id = B.manager_id
--        WHERE B.department_id = p_deptid;
        
    SELECT a.last_name
        into v_dept_manager_name
        FROM employees A
        RIGHT JOIN departments B ON A.employee_id = B.manager_id
        WHERE B.department_id = p_deptid;
        
    IF v_dept_manager_name IS NULL THEN
        RAISE v_dept_exception;
    END IF;
    
    return v_dept_manager_name;
EXCEPTION
    WHEN v_dept_exception THEN
        RETURN '해당 부서의 책임자가 없서용';
    WHEN NO_DATA_FOUND THEN
        RETURN '해당 부서가 존재하지 않아용';
END;
/
EXECUTE DBMS_OUTPUT.PUT_LINE(y_dept(110));
SELECT department_id, y_dept(department_id)
    FROM   departments;
    
-- 데이따 딕셔ㅓ너리
-- 특정 객체의 정보를 확인하고 싶을경우
SELECT name,text
FROM user_source
WHERE type IN ('PROCEDURE', 'FUNCTION','PACKAGE','PACKAGE BODY');