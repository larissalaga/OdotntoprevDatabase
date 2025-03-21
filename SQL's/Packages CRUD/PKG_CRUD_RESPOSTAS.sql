-- Package para CRUD
CREATE OR REPLACE PACKAGE "PKG_CRUD_RESPOSTAS" AS
    -- Procedure para inserir um nova resposta
    PROCEDURE "INSERT_RESPOSTAS"(
        "p_ds_resposta" VARCHAR2
    );

    -- Procedure para atualizar uma resposta
    PROCEDURE "UPDATE_RESPOSTAS"(
        "p_id_paciente" NUMBER,
        "p_id_pergunta" NUMBER,
        "p_dt_date_checkin" DATE,
        "p_ds_resposta" VARCHAR2
    );

    -- Procedure para deletar uma resposta
    PROCEDURE "DELETE_RESPOSTAS"(
        "p_id_resposta" NUMBER
    );

END "PKG_CRUD_RESPOSTAS";
/

-- Package Body para CRUD
CREATE OR REPLACE PACKAGE BODY "PKG_CRUD_RESPOSTAS" AS
    -- Exceções globais do pacote
    resposta_not_found EXCEPTION;

    -- Procedure de inserção
    PROCEDURE "INSERT_RESPOSTAS"(
        "p_ds_resposta" VARCHAR2
    ) IS
    BEGIN
        INSERT INTO "T_OPBD_RESPOSTAS"
        ("id_resposta",
         "ds_resposta")
        VALUES ("SEQ_T_OPBD_RESPOSTAS".nextval,
                "p_ds_resposta");
        COMMIT;
        dbms_output.put_line('Resposta inserida com sucesso.');
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001, 'ERRO DESCONHECIDO.' || SQLERRM);
    END "INSERT_RESPOSTAS";

    -- Procedure de atualização
    PROCEDURE "UPDATE_RESPOSTAS"(
        "p_id_paciente" NUMBER,
        "p_id_pergunta" NUMBER,
        "p_dt_date_checkin" DATE,
        "p_ds_resposta" VARCHAR2
    )
        IS
        "resposta_id" NUMBER;
        resposta_not_found EXCEPTION;
    BEGIN
        -- Busca a resposta com base na pergunta e na data
        BEGIN
            SELECT "id_resposta"
            INTO "resposta_id"
            FROM "T_OPBD_CHECK_IN"
            WHERE "id_pergunta" = "p_id_pergunta"
              AND "dt_check_in" = "p_dt_date_checkin"
              AND "id_paciente" = "p_id_paciente";
        EXCEPTION
            WHEN no_data_found THEN
                RAISE resposta_not_found;
        END;

        -- Faz o update
        UPDATE "T_OPBD_RESPOSTAS"
        SET "ds_resposta" = "p_ds_resposta"
        WHERE "id_resposta" = "resposta_id";
    EXCEPTION
        WHEN resposta_not_found THEN
            RAISE_APPLICATION_ERROR(-20001, 'Resposta não existe.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'ERRO DESCONHECIDO.' || SQLERRM);
    END "UPDATE_RESPOSTAS";

    -- Procedure de exclusão
    PROCEDURE "DELETE_RESPOSTAS"(
        "p_id_resposta" NUMBER
    ) IS
    BEGIN
        -- Deleta da tabela Check_in
        DELETE
        FROM "T_OPBD_CHECK_IN"
        WHERE "id_resposta" = "p_id_resposta";
        dbms_output
            .
            put_line
        ('Resposta deletada com sucesso.');

        -- Deleta da tabela Respostas
        DELETE
        FROM "T_OPBD_RESPOSTAS"
        WHERE "id_resposta" = "p_id_resposta";

        COMMIT;
    EXCEPTION
        WHEN no_data_found THEN
            RAISE_APPLICATION_ERROR(-20001, 'Resposta não encontrada.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'ERRO DESCONHECIDO.' || SQLERRM);
    END "DELETE_RESPOSTAS";
END "PKG_CRUD_RESPOSTAS";
/