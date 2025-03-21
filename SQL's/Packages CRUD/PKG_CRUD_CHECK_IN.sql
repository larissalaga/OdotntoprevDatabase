-- Package para CRUD
CREATE OR REPLACE PACKAGE "PKG_CRUD_CHECK_IN" AS
    -- Procedure para inserir um novo check-in
    PROCEDURE "INSERT_CHECK_IN"(
        "p_dt_check_in" DATE,
        "p_id_paciente" NUMBER,
        "p_id_pergunta" NUMBER,
        "p_id_resposta" NUMBER
    );

    -- UPDATE_CHECK_IN: Não faz sentido ter uma função de update do Check_In para a nossa funcionalidade

    -- Procedure para deletar um check-in
    PROCEDURE "DELETE_CHECK_IN"(
        "p_id_check_in" NUMBER
    );

END "PKG_CRUD_CHECK_IN";
/


-- Package Body para CRUD
CREATE OR REPLACE PACKAGE BODY "PKG_CRUD_CHECK_IN" AS
    -- Exceções globais do pacote
    data_doc_invalid EXCEPTION;
    paciente_not_found EXCEPTION;
    pergunta_not_found EXCEPTION;
    resposta_not_found EXCEPTION;

    -- Procedure de inserção
    PROCEDURE "INSERT_CHECK_IN"(
        "p_dt_check_in" DATE,
        "p_id_paciente" NUMBER,
        "p_id_pergunta" NUMBER,
        "p_id_resposta" NUMBER
    ) IS
        data_doc_invalid EXCEPTION;
        paciente_not_found EXCEPTION;
        pergunta_not_found EXCEPTION;
        resposta_not_found EXCEPTION;
        "id_found" NUMBER;
    BEGIN
        -- Valida se a Pergunta existe
        BEGIN
            SELECT "id_pergunta"
            INTO "id_found"
            FROM "T_OPBD_PERGUNTAS"
            WHERE "id_pergunta" = "p_id_pergunta";
        EXCEPTION
            WHEN no_data_found THEN
                RAISE pergunta_not_found;
        END;

        -- Valida se a Resposta existe
        BEGIN
            SELECT "id_resposta"
            INTO "id_found"
            FROM "T_OPBD_RESPOSTAS"
            WHERE "id_resposta" = "p_id_resposta";
        EXCEPTION
            WHEN no_data_found THEN
                RAISE resposta_not_found;
        END;

        -- Valida se o Paciente existe
        BEGIN
            SELECT "id_paciente"
            INTO "id_found"
            FROM "T_OPBD_PACIENTE"
            WHERE "id_paciente" = "p_id_paciente";
        EXCEPTION
            WHEN no_data_found THEN
                RAISE paciente_not_found;
        END;

        -- Valida a data
        IF NOT "FUN_VALIDA_DATA_DOC"("p_dt_check_in", "p_id_paciente") THEN
            RAISE data_doc_invalid;
        END IF;

        INSERT INTO "T_OPBD_CHECK_IN"
        ("id_check_in",
         "dt_check_in",
         "id_paciente",
         "id_pergunta",
         "id_resposta")
        VALUES ("SEQ_T_OPBD_CHECK_IN".nextval,
                "p_dt_check_in",
                "p_id_paciente",
                "p_id_pergunta",
                "p_id_resposta");
        COMMIT;
        dbms_output.put_line('Check_in inserido com sucesso.');
    EXCEPTION
        WHEN paciente_not_found THEN
            RAISE_APPLICATION_ERROR(-20001, 'Paciente não existe.');
        WHEN pergunta_not_found THEN
            RAISE_APPLICATION_ERROR(-20002, 'Pergunta não existe.');
        WHEN resposta_not_found THEN
            RAISE_APPLICATION_ERROR(-20003, 'Resposta não existe.');
        WHEN data_doc_invalid THEN
            RAISE_APPLICATION_ERROR(-20004, 'Data do extrato não é válida.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'ERRO DESCONHECIDO.' || SQLERRM);
            ROLLBACK;
    END "INSERT_CHECK_IN";

    -- Procedure de exclusão
    PROCEDURE "DELETE_CHECK_IN"(
        "p_id_check_in" NUMBER
    ) IS
        "resposta_id" NUMBER;
    BEGIN
        SELECT "id_resposta"
        INTO "resposta_id"
        FROM "T_OPBD_CHECK_IN"
        WHERE "id_check_in" = "p_id_check_in";

-- Deleta da tabela Check_in
        DELETE
        FROM "T_OPBD_CHECK_IN"
        WHERE "id_check_in" = "p_id_check_in";
        dbms_output
            .
            put_line
        ('Check_in deletado com sucesso.');

        -- Deleta da tabela Respostas
        DELETE
        FROM "T_OPBD_RESPOSTAS"
        WHERE "id_resposta" = "resposta_id";
        dbms_output
            .
            put_line
        ('Resposta deletada com sucesso.');

        COMMIT;
    EXCEPTION
        WHEN no_data_found THEN
            RAISE_APPLICATION_ERROR(-20001, 'Check_in não encontrado.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'ERRO DESCONHECIDO.' || SQLERRM);
    END "DELETE_CHECK_IN";

END "PKG_CRUD_CHECK_IN";
/
