-- Package para CRUD
CREATE OR REPLACE PACKAGE "PKG_CRUD_PERGUNTAS" AS
    -- Procedure para inserir um nova pergunta
    PROCEDURE "INSERT_PERGUNTAS"(
        "p_ds_pergunta" VARCHAR2
    );

    -- UPDATE_PERGUNTAS: Não faz sentido ter uma função de update das perguntas para a nossa funcionalidade

    -- Procedure para deletar uma pergunta
    PROCEDURE "DELETE_PERGUNTAS"(
        "p_id_pergunta" NUMBER
    );

END "PKG_CRUD_PERGUNTAS";
/

-- Package Body para CRUD
CREATE OR REPLACE PACKAGE BODY "PKG_CRUD_PERGUNTAS" AS
    -- Exceções globais do pacote
    pergunta_exists EXCEPTION;

    -- Procedure de inserção
    PROCEDURE "INSERT_PERGUNTAS"(
        "p_ds_pergunta" VARCHAR2
    ) IS
        "pergunta_id" NUMBER;
        pergunta_exists EXCEPTION;
    BEGIN
        BEGIN
            SELECT "id_pergunta"
            INTO "pergunta_id"
            FROM "T_OPBD_PERGUNTAS"
            WHERE "ds_pergunta" = "p_ds_pergunta";
        EXCEPTION
            WHEN no_data_found THEN
                "pergunta_id" := NULL;
        END;
        IF "pergunta_id" IS NOT NULL THEN
            RAISE pergunta_exists;
        END IF;

        INSERT INTO "T_OPBD_PERGUNTAS"
        ("id_pergunta",
         "ds_pergunta")
        VALUES ("SEQ_T_OPBD_PERGUNTAS".nextval,
                "p_ds_pergunta");
        COMMIT;
        dbms_output.put_line('Pergunta inserida com sucesso.');
    EXCEPTION
        WHEN pergunta_exists THEN
            RAISE_APPLICATION_ERROR(-20001, 'Pergunta já existe.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'ERRO DESCONHECIDO.' || SQLERRM);
    END "INSERT_PERGUNTAS";


    -- Procedure de exclusão
    PROCEDURE "DELETE_PERGUNTAS"(
        "p_id_pergunta" NUMBER
    ) IS
    BEGIN
        -- Não vamos deletar uma pergunta se já tiver uma check_in que a utilizou anteriormente
        DELETE
        FROM "T_OPBD_PERGUNTAS"
        WHERE "id_pergunta" = "p_id_pergunta"
          AND "id_pergunta" NOT IN (SELECT "id_pergunta"
                                    FROM "T_OPBD_CHECK_IN");
        dbms_output
            .
            put_line
        ('Pergunta deletada com sucesso.');

        COMMIT;
    EXCEPTION
        WHEN no_data_found THEN
            RAISE_APPLICATION_ERROR(-20001, 'Pergunta não encontrada.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'ERRO DESCONHECIDO.' || SQLERRM);
    END "DELETE_PERGUNTAS";
END "PKG_CRUD_PERGUNTAS";
/