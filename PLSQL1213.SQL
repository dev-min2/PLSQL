SET SERVEROUTPUT ON

DECLARE
    CURSOR emp_cursor IS
        SELECT employee_id, last_name, job_id
            FROM employees
            WHERE department_id = &�μ���ȣ;
BEGIN
    -- OPEN, PETCH, CLOSE���ص��� (FOR IN LOOP ����!)
    -- emp_cursor�� ����Ű�� Ȱ������(�������)�� �����Ͱ� �ϳ��������� FOR IN LOOP�� ������������(Ŀ���� �ȿ���)
    FOR emp_rec IN emp_cursor LOOP
        --DBMS_OUTPUT.PUT(emp_cursor%ROWCOUNT); Ŀ�����ٰ���
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
                        WHERE department_id = &�μ���ȣ) LOOP
        DBMS_OUTPUT.PUT(emp_rec.employee_id);          
        DBMS_OUTPUT.PUT_LINE(', ' || emp_rec.last_name);
    END LOOP; 
END;
/

--1
DECLARE
    CURSOR emp_cursor IS
        SELECT employee_id, last_name, NVL(department_name, '������') AS department_name
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

-- �Ű����� ������ Ŀ��
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


-- ���� �����ϴ� ��� �μ��� �� �Ҽӻ���� ����ϰ�, �μ��� �Ҽӵ� ����� ���°�� '���� �Ҽӻ���� �����ϴ�.'
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
    -- �μ�
    -- �����ȣ
    -- FOR emp_rec IN
    FOR depart_rec IN depart_cursor LOOP
        DBMS_OUTPUT.PUT_LINE('�μ��� : ' || depart_rec.department_name);
        
        OPEN emp_cursor(depart_rec.department_id);
        
        LOOP
            FETCH emp_cursor INTO emp_rec;
            EXIT WHEN emp_cursor%NOTFOUND;
            
            DBMS_OUTPUT.PUT(emp_rec.employee_id || ' ' || emp_rec.last_name || ' ' || emp_rec.hire_date || ' ' || emp_rec.JOB_ID);
            DBMS_OUTPUT.PUT_LINE(' ');
        END LOOP;
        
        IF emp_cursor%ROWCOUNT = 0 THEN -- FOR IN �������� END LOOP���� �ٷ� emp_cursor�� �����⶧���� �̷� �ڵ尡 �Ұ�����.
            DBMS_OUTPUT.PUT_LINE('�ҼӵȰ� ������');
        END IF;
        
        CLOSE emp_cursor;
    END LOOP;
END;
/




-- ����ó��
DECLARE
    v_ename employees.last_name%TYPE;
BEGIN
    SELECT last_name
        INTO v_ename
        FROM employees
        WHERE department_id = &�μ���ȣ;
        
    -- no data founds �� too many ��¼�� �߻��� �� ����
    DBMS_OUTPUT.PUT_LINE(v_ename);
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN 
        DBMS_OUTPUT.PUT_LINE('�ش� �μ��� ���� ����� ������');
    WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('�� ����');
    
    DBMS_OUTPUT.PUT_LINE('����ó���� �������ϴ�');
END;
/


-- 2 �̹� ���Ǵ� �Ǿ������� ������ �̸��� �������� �ʴ� ���ܻ���
DECLARE
    e_emps_remaining EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_emps_remaining, -02292);
BEGIN
    DELETE FROM departments
    WHERE department_id = &�μ���ȣ;
EXCEPTION
    WHEN e_emps_remaining THEN
        DBMS_OUTPUT.PUT_LINE('�ش� �μ��� ���� ����� �����մϴ�.');
END;
/

-- ����� ���� ����
DECLARE
    e_no_deptno EXCEPTION;
BEGIN
    DELETE FROM departments
    WHERE department_id = &�μ���ȣ;
    
    IF SQL%ROWCOUNT = 0 THEN
        RAISE e_no_deptno;
    END IF;
EXCEPTION
    WHEN e_no_deptno THEN
        DBMS_OUTPUT.PUT_LINE('�ش� �μ���ȣ�� �������� �ʽ��ϴ�.');
    WHEN OTERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLCODE);
END;
/

-- ����� ���ǻ���
DECLARE 
    e_no_deptno EXCEPTION;
    v_ex_code NUMBER;
    v_ex_msg VARCHAR2(1000);
BEGIN
    DELETE FROM departments
    WHERE department_id = &�μ���ȣ;
EXCEPTION
    WHEN e_no_deptno THEN
        DBMS_OUTPUT.PUT_LINE('�ش� �μ���ȣ�� �������� �ʽ��ϴ�.');
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
    DELETE FROM test_employee WHERE employee_id = &id��;
    IF SQL%ROWCOUNT = 0 THEN
        RAISE NO_DATA_FOUND;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('�����Ǿ����ϴ�.');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('�ش� ����� �������� �����ϴ�.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('�ϰ� ���Ҽ��ִµ�?');
END;
/

    
DECLARE
    v_eid employees.employee_id%TYPE := &������;
    v_ne_emp EXCEPTION;
BEGIN
    DELETE FROM test_employee WHERE employee_id = v_eid;
    IF SQL%ROWCOUNT = 0 THEN
        RAISE v_ne_emp;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('��');
EXCEPTION
    WHEN v_ne_emp THEN
        DBMS_OUTPUT.PUT(v_eid || ', ');
        DBMS_OUTPUT.PUT_LINE('���� ���̺��� �������� �ʾƿ�~');
END;
/

CREATE PROCEDURE test_pro
--  () �Ű������� �ִٸ� ����
IS -- IS�ڿ� DECLARE ó�� ��������.

BEGIN
    DBMS_OUTPUT.PUT_LINE('First Procedure');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('������');    
        
END;
/

-- ������ ���ν��� ȣ���1
BEGIN
    TEST_PRO;
END;
/

-- ������ ���ν��� ȣ���2
-- �ѹ��� ������ ȣ���� �Ұ���
EXECUTE TEST_PRO;

-- ������
DROP PROCEDURE TEST_PRO;
COMMIT;

-- ���ν��� in/out/in out

-- IN
--> ���� ���� ���α׷��� ���� (����)
--> ���� �Ű������� ����� �ۿ� (�����ν�)
--> ���� �Ű������� ���ͷ�, ǥ����, ��� �Ǵ� �ʱ�ȭ�� ���� (ȣ�� �� ��밡���� ����)

-- OUT
-- ���ÿ��� �����ؾ���
-- ���� ȣ�� ȯ������ ��ȯ (����)
-- �ʱ�ȭ���� ���� ���� (�����ν�)
    -- �������� �� (ȣ�� �� ��밡���� ����)

-- IN OUT
-- �����ؾ���
-- ���� ���� ���α׷��� �����ϰ� ȣ�� ȯ������ ��ȯ (����)
-- �ʱ�ȭ�� ���� (�����ν�)
-- �������� �� (ȣ�� �� ��밡���� ����)


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
    v_id employees.employee_id%TYPE := &�����ȣ;
    v_num CONSTANT NUMBER := v_id;
BEGIN
    RAISE_SALARY(v_id); -- ��������
    RAISE_SALARY(v_num); -- �������
    RAISE_SALARY(v_num + 10); -- ����� ���(���ͷ�)����
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

-- ���ν��� �ǽ� 1��
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
    DBMS_OUTPUT.PUT_LINE(v_year || '��' || v_month || '��' || v_day || '��');
END;

DECLARE
    v_p_no VARCHAR2(1000) := '9501011667777';
    V_P_no2 VARCHAR2(1000) := '1511013689977';
BEGIN
    yedam_ju(v_p_no);
    yedam_ju(v_p_no2);
END;
/

-- ���ν��� �ǽ� 2��
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
        DBMS_OUTPUT.PUT_LINE('�ش� ����� �����ϴ�.');
END;
/

EXECUTE TEST_PRO(9999);

-- ���ν��� �ǽ� 3��
CREATE PROCEDURE yedam_emp
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

-- ���ν��� 4��
CREATE PROCEDURE y_update
(p_eid NUMBER, p_sal_inc_percent NUMBER)
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

-- ���ν��� 5��
create table yedam01
(y_id number(10),
 y_name varchar2(20));

create table yedam02
(y_id number(10),
 y_name varchar2(20));
COMMIT;

SELECT * FROM EMPLOYEES;
-- 5-1��, 5-2�� 
create PROCEDURE y_proc
(p_dept_id NUMBER)
IS
    CURSOR emp_cursor IS
        SELECT *
            FROM employees 
            WHERE department_id = p_dept_id;
BEGIN
    FOR emp_rec IN emp_cursor LOOP
        IF emp_rec.hire_date < '2005-01-01' THEN
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
END;
/

EXECUTE y_proc(50);
    
SELECT *
    FROM EMPLOYEES
    WHERE DEPARTMENT_ID = 50 AND HIRE_DATE < '2005-01-01';

SELECT *
    FROM EMPLOYEES;