set serveroutput on;

DECLARE
    v_gugudan number := &번호입력;
    v_tempIdx number := 1;
BEGIN
    LOOP
        EXIT WHEN v_tempIdx > 9;
        
        DBMS_OUTPUT.PUT_LINE(v_gugudan || ' * ' || v_tempIdx || ' = ' || (v_gugudan * v_tempIdx));
        v_tempIdx := v_tempIdx + 1;
    END LOOP;
END;
/

DECLARE
    v_gugudan number := &번호입력;
BEGIN
    FOR idx IN 1..9 LOOP
        DBMS_OUTPUT.PUT_LINE(v_gugudan || ' * ' || idx || ' = ' || (v_gugudan * idx));
    END LOOP;
END;
/


DECLARE
    v_gugudan number := &번호입력;
    v_tempIdx number := 1;
BEGIN
    WHILE v_tempIdx <= 9 LOOP
        DBMS_OUTPUT.PUT_LINE(v_gugudan || ' * ' || v_tempIdx || ' = ' || (v_gugudan * v_tempIdx));
        v_tempIdx := v_tempIdx + 1;
    END LOOP;
END;
/

DECLARE
BEGIN
    FOR dan IN 2..9 LOOP
        FOR idx IN 1..9 LOOP
            DBMS_OUTPUT.PUT(dan || ' * ' || idx || ' = ' || (dan * idx));
            DBMS_OUTPUT.PUT(', ');
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;
END;
/


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

DECLARE
    TYPE RECORD_TEST IS RECORD(
        wanttogohome varchar2(1000) := '집가고싶어요',
        num number := 10
    );
    
    test RECORD_TEST;
BEGIN
    DBMS_OUTPUT.PUT_LINE(test.wanttogohome);
    DBMS_OUTPUT.PUT_LINE(test.num);
    
    test.num := 500;
    DBMS_OUTPUT.PUT_LINE(test.num);
END;
/

--ROWTYPE
DECLARE
    emp_info_rec employees%ROWTYPE;
BEGIN
    SELECT *
        INTO emp_info_rec
        FROM employees
        WHERE employee_id = &사원번호;
    
    DBMS_OUTPUT.PUT_LINE(emp_info_rec.employee_id);
    DBMS_OUTPUT.PUT_LINE(emp_info_rec.job_id);
    DBMS_OUTPUT.PUT_LINE(emp_info_rec.last_name);
    DBMS_OUTPUT.PUT_LINE(emp_info_rec.first_name);
    DBMS_OUTPUT.PUT_LINE(emp_info_rec.department_id);
END;
/

-- Join된 결과는 RECORD Type이 나음.

DECLARE 
    TYPE emp_rec_type IS RECORD(
        eid employees.employee_id%TYPE,
        ename employees.last_name%TYPE,
        deptname departments.department_name%TYPE
    );
    emp_rec emp_rec_type;
BEGIN
    SELECT A.employee_id, A.LAST_NAME, B.department_name
        INTO emp_rec -- select한 데이터의 Type과 emp_rec의 Type이 순서상으로 일치하면 ok
        FROM employees A
        JOIN departments B ON A.department_id = B.department_id
        WHERE A.employee_id = &번홍;
        
    DBMS_OUTPUT.PUT_LINE(emp_rec.ename);
    DBMS_OUTPUT.PUT_LINE(emp_rec.deptname);
END;
/

DECLARE
    -- 1) 정의
    TYPE num_table_type IS TABLE OF NUMBER
        INDEX BY BINARY_INTEGER;
    -- 2) 선언
    num_list num_table_type;
BEGIN
    FOR i IN 1..9 LOOP
        num_list(i) := i * 1;
    END LOOP;
    
    FOR idx IN num_list.FIRST..num_list.LAST LOOP
        IF num_list.EXISTS(idx) THEN -- 리스트 내부의 데이터를 순차적으로 가져올 때 안전하게 가져오기 위해.
            DBMS_OUTPUT.PUT_LINE(num_list(idx));
        END IF;
    END LOOP;
END;
/

DECLARE
    TYPE emp_table_type IS TABLE OF employees%ROWTYPE
    INDEX BY BINARY_INTEGER;
    
    emp_table emp_table_type;
    emp_rec employees%ROWTYPE;
BEGIN
    FOR eid IN 100 .. 110 LOOP
        SELECT *
            INTO emp_rec
            FROM employees
            WHERE employee_id = eid;
            emp_table(eid) := emp_rec;
    END LOOP;
    
    FOR idx IN emp_table.FIRST .. emp_table.LAST LOOP
        IF emp_table.EXISTS(idx) THEN -- 리스트 내부의 데이터를 순차적으로 가져올 때 안전하게 가져오기 위해.
            DBMS_OUTPUT.PUT_LINE(emp_table(idx).employee_id);
            DBMS_OUTPUT.PUT_LINE(emp_table(idx).last_name);        
            DBMS_OUTPUT.PUT_LINE(emp_table(idx).job_id);
        END IF;
    END LOOP;
END;
/


SELECT *
    FROM EMPLOYEES;
DECLARE
    TYPE emp_table_type IS TABLE OF employees%ROWTYPE
    INDEX BY BINARY_INTEGER;
    
    emp_table emp_table_type;
    emp_rec employees%ROWTYPE;
    
    firstEmployeeId Number := 0;
    lastEmployeeId Number := 0;
    v_result NUMBER(1,0);             -- 사원의 존재유무를 확인
BEGIN
    SELECT min(employee_id), MAX(employee_id)
        INTO firstEmployeeId, lastEmployeeId
        FROM EMPLOYEES;
    
    FOR eid IN firstEmployeeId .. lastEmployeeId LOOP
        SELECT COUNT(*)
        INTO v_result
        FROM employees
        WHERE employee_id = eid;
        
        IF v_result = 0 THEN
            CONTINUE;
        END IF;
        
        SELECT *
            INTO emp_rec
            FROM employees
            WHERE employee_id = eid;
            emp_table(eid) := emp_rec;
    END LOOP;
    
    FOR idx IN emp_table.FIRST .. emp_table.LAST LOOP
        IF emp_table.EXISTS(idx) THEN -- 리스트 내부의 데이터를 순차적으로 가져올 때 안전하게 가져오기 위해.
            DBMS_OUTPUT.PUT(emp_table(idx).employee_id || ' ');
            DBMS_OUTPUT.PUT_LINE(emp_table(idx).last_name);
        END IF;
    END LOOP;
END;
/

-- 명시적 커서
DECLARE
    CURSOR emp_dept_cursor IS
        SELECT employee_id, last_name
            FROM employees
            WHERE department_id = &부서번호;
            
    v_eid employees.employee_id%TYPE;
    v_ename employees.last_name%TYPE;
BEGIN
    -- 실제 명시적 커서(쿼리문 실행)가 오픈되는 순간.
    OPEN emp_dept_cursor;
    
    -- 커서가 다음행을 가리키며(커서이동) 행을 반환. 
    FETCH emp_dept_cursor INTO v_eid, v_ename;
    
    DBMS_OUTPUT.PUT_LINE(v_eid);
    DBMS_OUTPUT.PUT_LINE(v_ename);
    
    -- 커서 끝
    CLOSE emp_dept_cursor;
END;
/

DECLARE
    CURSOR emp_info_cursor IS
        SELECT employee_id as eid, last_name as ename, hire_date as hdate
            FROM employees
            WHERE department_id = &부서버농
            ORDER BY hire_date;
            
    -- 커서기반의 rowtype. 위에서 별칭을 사용했으니 별칭으로ㅓ 접근해야함.
    emp_rec emp_info_cursor%ROWTYPE;
BEGIN
    OPEN emp_info_cursor;
    
    LOOP
        FETCH emp_info_cursor INTO emp_rec;
        --EXIT WHEN emp_info_cursor%ROWCOUNT > 15; -- ROWCOUNT 현재 커서의 INDEX
        EXIT WHEN emp_info_cursor%NOTFOUND;
        
        DBMS_OUTPUT.PUT(emp_info_cursor%ROWCOUNT || ', ');
        DBMS_OUTPUT.PUT(emp_rec.eid || ', ');
        DBMS_OUTPUT.PUT(emp_rec.ename || ', ');
        DBMS_OUTPUT.PUT_LINE(emp_rec.hdate);
    END LOOP;
    IF emp_info_cursor%ROWCOUNT = 0 THEN -- ENDLOOP를 만나 LOOP를 빠져나오면 ROWCOUNT는 고정이기에.
        DBMS_OUTPUT.PUT_LINE('현재 커서의 데이터는 없습니다!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    END IF;
    CLOSE emp_info_cursor;
END;
/

-- 모든 사원의 사원번호, 이름, 부서이름 출력(명시적 커서사용)
DECLARE
    CURSOR emp_info_cursor IS
        SELECT employee_id, last_name, NVL(department_name,'NULL') as department_name
            FROM EMPLOYEES A
            LEFT JOIN DEPARTMENTS B ON A.DEPARTMENT_ID = B.DEPARTMENT_ID
            ORDER BY A.EMPLOYEE_ID;
            
    -- 커서기반의 rowtype. 위에서 별칭을 사용했으니 별칭으로ㅓ 접근해야함.
    emp_rec emp_info_cursor%ROWTYPE;
BEGIN
    OPEN emp_info_cursor;
    
    LOOP
        FETCH emp_info_cursor INTO emp_rec;
        EXIT WHEN emp_info_cursor%NOTFOUND;
        
        DBMS_OUTPUT.PUT(emp_rec.employee_id || ', ');
        DBMS_OUTPUT.PUT(emp_rec.last_name || ', ');
        DBMS_OUTPUT.PUT_LINE(emp_rec.department_name);
    END LOOP;
    IF emp_info_cursor%ROWCOUNT = 0 THEN -- ENDLOOP를 만나 LOOP를 빠져나오면 ROWCOUNT는 고정이기에.
        DBMS_OUTPUT.PUT_LINE('현재 커서의 데이터는 없습니다!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    END IF;
    CLOSE emp_info_cursor;
END;
/


