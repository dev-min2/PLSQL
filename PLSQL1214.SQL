-- �Լ��� ���ν��� ����
-- �Լ��� �Ű������� IN�� ����. ��� RETURN�� �ݵ�� �־���Ѵ�.
-- �Լ��� ���� ���ڵ�(�� ������)ó���� ������ �Լ��� ����
-- DML(INSERT,UPDATE,DELETE) ���� X (SELECT������ ���̴� �Լ���.)


-- ���ν��� VS �Լ�
-- PL/SQL ������ ���� VS ǥ������ �Ϻη� ȣ��
-- RETURN ������ ������ ����X VS RETURN ������ ������ ����
-- ���� ��ȯ�����ʰų� �ϳ� �̻��� ���� ��ȯ ���� VS ������ �ϳ��� ���� ��ȯ.

CREATE FUNCTION plus
(p_x IN NUMBER, p_y NUMBER)
RETURN NUMBER -- RETURN TYPE ����.(�����ݷ� ��������)
IS
    v_result NUMBER;
BEGIN
    v_result := p_x + p_y;
    
    RETURN v_result;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN '�����Ͱ� �������� �ʽ��ϴ�.';
    WHEN TOO_MANY_ROWS THEN
        RETURN '�����Ͱ� �䱸�� �ͺ��� �����ϴ�.';
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
        RETURN '�����Ͱ� �������� �ʽ��ϴ�.';
    WHEN TOO_MANY_ROWS THEN
        RETURN '�����Ͱ� �䱸�� �ͺ��� �����ϴ�.';
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
        RETURN '�����Ͱ� �������� �ʽ��ϴ�.';
    WHEN TOO_MANY_ROWS THEN
        RETURN '�����Ͱ� �䱸�� �ͺ��� �����ϴ�.';
END;
/

SELECT last_name, salary, ydinc(employee_id)
    FROM employees;

-- 3��
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
        RETURN '�����Ͱ� �������� �ʽ��ϴ�.';
    WHEN TOO_MANY_ROWS THEN
        RETURN '�����Ͱ� �䱸�� �ͺ��� �����ϴ�.';
END;
/

SELECT last_name, salary, YD_FUNC(employee_id)
     FROM employees;
     
-- 4��
CREATE OR REPLACE FUNCTION subname
(p_last_name employees.last_name%TYPE)
RETURN VARCHAR
IS

BEGIN
    return RPAD(SUBSTR(p_last_name,1,1),LENGTH(p_last_name), '*');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN '�����Ͱ� �������� �ʽ��ϴ�.';
    WHEN TOO_MANY_ROWS THEN
        RETURN '�����Ͱ� �䱸�� �ͺ��� �����ϴ�.';
END;
/

SELECT last_name, subname(last_name)
FROM   employees;

-- 5��
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
        RETURN '�ش� �μ��� å���ڰ� ������';
    WHEN NO_DATA_FOUND THEN
        RETURN '�ش� �μ��� �������� �ʾƿ�';
END;
/
EXECUTE DBMS_OUTPUT.PUT_LINE(y_dept(110));
SELECT department_id, y_dept(department_id)
    FROM   departments;
    
-- ���̵� ��Ťóʸ�
-- Ư�� ��ü�� ������ Ȯ���ϰ� �������
SELECT name,text
FROM user_source
WHERE type IN ('PROCEDURE', 'FUNCTION','PACKAGE','PACKAGE BODY');