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
    
    DBMS_OUTPUT.PUT_LINE('�����ȣ : ' || v_eid);
    DBMS_OUTPUT.PUT_LINE('�׹� : ' || v_ename);
    DBMS_OUTPUT.PUT_LINE('���� : ' || v_job);  
END;
/ 

DECLARE
    v_tt NUMBER := 100; -- ġȯ������ ������ ����������.
    v_eid employees.employee_Id%TYPE := &�����ȣ; -- ġȯ����(PLSQL ���������� �Է��� �ް� ����)
    v_ename employees.first_name%TYPE; -- ��Ÿ������ �𸦋� ��
BEGIN
    SELECT first_name || ',' || last_name
    INTO v_ename
    FROM employees
    WHERE employee_id = v_eid;
    
    DBMS_OUTPUT.PUT_LINE('�����ȣ : ' || v_eid);
    DBMS_OUTPUT.PUT_LINE('�׹� : ' || v_ename);
END;
/

select *
    from employees
    order by employee_id;

--1) Ư�� ����� �Ŵ����� �ش��ϴ� �����ȣ�� ��� : Ư�� ����� ġȯ������ ���
DECLARE
    v_emid employees.employee_id%TYPE := &�����ȣ; -- ġȯ����(PLSQL ���������� �Է��� �ް� ����)
    v_managerid employees.manager_id%TYPE;
BEGIN
    SELECT manager_id
    INTO v_managerid
    FROM employees
    WHERE employee_id = v_emid;
    
    DBMS_OUTPUT.PUT_LINE('�����ȣ : ' || v_emid);
    DBMS_OUTPUT.PUT_LINE('�Ŵ�����ȣ : ' || v_managerid);
END;
/

DECLARE 
    v_deptno departments.department_id%TYPE;
    v_comm employees.commission_pct%TYPE;
BEGIN
    SELECT department_id
    INTO v_deptno
    FROM employees
    WHERE employee_id = &�����ȣ;
    
    INSERT INTO employees(employee_id, last_name, email, hire_date, department_id, job_id)
    VALUES(1000,'Hong', 'hkd@google.com', sysdate, v_deptno, 'IT_PROG');
    
    -- SQL Ŀ��
    DBMS_OUTPUT.PUT_LINE('��� ��� : ' || SQL%ROWCOUNT);
    
    UPDATE employees
    SET salary = (NVL(salary,0) + 10000) * v_comm
    WHERE employee_id = 1000;
    
    -- SQL Ŀ�� (ROWCOUNT WHERE ���� )
    DBMS_OUTPUT.PUT_LINE('���� ��� : ' || SQL%ROWCOUNT);
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
    WHERE employee_id = &�����ȣ;
    
    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('�ش� ����� �������� �ʽ��ϴ�.');
    END IF;
END;
/
    
    
    
    
/*
    1. �����ȣ�� �Է��� ��� �����ȣ, ����̸�, �μ��̸��� ����ϴ� PL/SQL�� �ۼ��Ͻÿ�.
    �����ȣ�� ġȯ������ ���� �Է�
    
    2. �����ȣ�� �Է��� ��� ����̸�,�޿�,������ ����ϴ� PL/SQL�ۼ�
    �����ȣ�� ġȯ���� ���
    ������ �Ʒ� ������ ������� ����
    (�޿� * 12 + ( NVL(�޿�,0) * NVL(Ŀ�̼�,0 ) * 12 ))
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
        WHERE A.employee_id = &�������;
        
    DBMS_OUTPUT.PUT_LINE('�����ȣ' || v_empid);
    DBMS_OUTPUT.PUT_LINE('����̸�' || v_name);
    DBMS_OUTPUT.PUT_LINE('����μ���' || v_departname);
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
        WHERE EMPLOYEE_ID = &�������;
    
    DBMS_OUTPUT.PUT_LINE('����̸�' || v_name);
    DBMS_OUTPUT.PUT_LINE('����޿�' || v_salary);
    DBMS_OUTPUT.PUT_LINE('�������' || v_annualSal);
END;
/    


-- IF��

BEGIN
    DELETE FROM employees
    WHERE employee_id = &�����ȣ;
    
    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('�ֺ�?');    
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
        DBMS_OUTPUT.PUT_LINE('�Ϲݻ����');
    ELSE
        DBMS_OUTPUT.PUT_LINE('������');
    END IF;
END;
/

-- IF ELSIF ELSE �� : ����
DECLARE
    v_hdate NUMBER;
BEGIN
    SELECT TRUNC(MONTHS_BETWEEN(SYSDATE, HIRE_DATE) / 12) AS HI
    INTO v_hdate
    FROM employees
    WHERE employee_id = &�����ȣ;
    
    IF v_hdate < 5 THEN -- �Ի����� 5�� �̸�
        DBMS_OUTPUT.PUT_LINE('�Ի����� 5�� �̸� �ӵ�.');   
    ELSIF v_hdate < 10 THEN -- �Ի����� 10�� �̸�
        DBMS_OUTPUT.PUT_LINE('�Ի����� 10�� �̸� �ӵ�.');
    ELSIF v_hdate < 15 THEN -- �Ի����� 15�� �̸�
        DBMS_OUTPUT.PUT_LINE('�Ի����� 15�� �̸� �ӵ�.');
    ELSIF v_hdate < 20 THEN -- 20�̸�
        DBMS_OUTPUT.PUT_LINE('�Ի����� 20�� �̸� �ӵ�.');
    ELSE  -- �� ��.
        DBMS_OUTPUT.PUT_LINE('�Ի����� 20�� �̻� �ӵ�.');
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
        WHERE employee_id = &�����ȣ;
        
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
        WHERE employee_id = &����;
              
    IF v_sal <= 5000 THEN
        DBMS_OUTPUT.PUT_LINE(v_sal + (v_sal * (20 / 100)));
    ELSIF v_sal <= 10000 THEN
        DBMS_OUTPUT.PUT_LINE(v_sal + (v_sal * (15 / 100)));
    ELSIF v_sal <= 15000 THEN 
        DBMS_OUTPUT.PUT_LINE(v_sal + (v_sal * (10 / 100)));
    ELSE 
        DBMS_OUTPUT.PUT_LINE('����');
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
    
    DBMS_OUTPUT.PUT_LINE('���� : ' || v_sum);
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
    
    DBMS_OUTPUT.PUT_LINE('����(WHILE) : ' || v_sum);
END;
/

DECLARE
    v_sum NUMBER := 0;
BEGIN
    -- idx��� ������ LOOP���ο��� ���
    FOR idx IN REVERSE 1..10 LOOP
        v_sum := v_sum + idx;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(v_sum);
END;
/

DECLARE
    v_str VARCHAR2(100) := '*';
BEGIN
    DBMS_OUTPUT.PUT_LINE('for in ��');
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
    DBMS_OUTPUT.PUT_LINE('while�� ��');
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
    DBMS_OUTPUT.PUT_LINE('For�� ��');
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
    DBMS_OUTPUT.PUT_LINE('for in 2�� �ݺ��� ��');
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
    DBMS_OUTPUT.PUT_LINE('While 2�� �ݺ��� ��');
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
    DBMS_OUTPUT.PUT_LINE('�Ϲ� LOOP');
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