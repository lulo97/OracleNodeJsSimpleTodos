-- Start of DDL Script for Procedure LULO97.PRC_CRUD_TODOS
-- Generated 08-Dec-2024 09:50:18 from LULO97@(DESCRIPTION =(ADDRESS_LIST =(ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521)))(CONNECT_DATA =(SERVICE_NAME = XE)))

CREATE OR REPLACE 
PROCEDURE prc_crud_todos (p_refcursor     OUT SYS_REFCURSOR,
/* Formatted on 08-Dec-2024 09:47:06 (QP5 v5.336) */
                          p_id                VARCHAR2,
                          p_name              VARCHAR2,
                          p_description       VARCHAR2,
                          p_action            VARCHAR2)
AS
    --Local variable
    l_count     NUMBER := 0;

    --Error object
    TYPE objtype IS TABLE OF VARCHAR2 (4000)
        INDEX BY VARCHAR2 (200);

    error_obj   objtype;

    --Procedure
    PROCEDURE handlereturnerror (p_refcursor   OUT SYS_REFCURSOR,
                                 errorcode         NUMBER)
    AS
        l_errorcode   NUMBER := errorcode;
    BEGIN
        SELECT COUNT (*)
        INTO l_count
        FROM errors
        WHERE code = errorcode;

        IF l_count = 0
        THEN
            l_errorcode := -1;
        END IF;

        OPEN p_refcursor FOR
            SELECT code AS "errorCode",
                   CASE
                       WHEN l_errorcode = -1
                       THEN
                           description || ' ' || errorcode
                       ELSE
                           description
                   END AS "errorMessage"
            FROM errors
            WHERE code = l_errorcode;
    END;

    PROCEDURE handlelogs (content VARCHAR2)
    AS
    BEGIN
        error_obj ('msg') := SQLERRM;
        error_obj ('code') := SQLCODE;
        error_obj ('backtrace') := DBMS_UTILITY.format_error_backtrace;
        error_obj ('stack') := DBMS_UTILITY.format_error_stack;


        INSERT INTO logs (id,
                          time,
                          errorcode,
                          errormsg,
                          backtrace,
                          errorstack,
                          content)
        VALUES (seq_logs.NEXTVAL,
                SYSDATE,
                error_obj ('code'),
                error_obj ('msg'),
                error_obj ('backtrace'),
                error_obj ('stack'),
                content);

        --If insert into not work inside exception, maybe it not commit
        COMMIT;
    END;
BEGIN
    --Check p_id is not number
    IF p_id IS NOT NULL AND NOT REGEXP_LIKE (p_id, '^-?\d+$')
    THEN
        handlereturnerror (p_refcursor, 3);
        RETURN;
    END IF;

    --Validate name
    IF p_action IN ('ADD', 'EDIT') AND p_name IS NULL
    THEN
        handlereturnerror (p_refcursor, 2);
        RETURN;
    END IF;

    --Check if record exist
    IF p_action IN ('DELETE', 'EDIT')
    THEN
        SELECT COUNT (*)
        INTO l_count
        FROM todos
        WHERE id = p_id;

        IF l_count = 0
        THEN
            handlereturnerror (p_refcursor, 4);
            RETURN;
        END IF;
    END IF;

    handlelogs ('begin add');

    IF p_action = 'ADD'
    THEN
        SELECT COUNT (*)
        INTO l_count
        FROM todos
        WHERE id = p_id;

        --Check have existing record
        IF l_count > 0
        THEN
            handlereturnerror (p_refcursor, 1);
            RETURN;
        END IF;

        INSERT INTO todos (id, name, description)
        VALUES (p_id, p_name, p_description);
    END IF;

    IF p_action = 'DELETE'
    THEN
        DELETE FROM todos
        WHERE id = p_id;
    END IF;

    IF p_action = 'EDIT'
    THEN
        UPDATE todos
        SET name = p_name, description = p_description
        WHERE id = p_id;
    END IF;

    IF p_action = 'READ'
    THEN
        OPEN p_refcursor FOR SELECT * FROM todos;

        RETURN;
    END IF;

    COMMIT;

    OPEN p_refcursor FOR SELECT 0 AS "errorCode" FROM DUAL;
EXCEPTION
    WHEN OTHERS
    THEN
        handlelogs ('');

        OPEN p_refcursor FOR SELECT -1 AS "errorCode" FROM DUAL;
END;
/



-- End of DDL Script for Procedure LULO97.PRC_CRUD_TODOS

