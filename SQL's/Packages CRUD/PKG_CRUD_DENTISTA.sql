-- Package para CRUD
CREATE OR REPLACE PACKAGE "PKG_CRUD_DENTISTA" AS
    -- Procedure para inserir um novo dentista
    PROCEDURE "INSERT_DENTISTA"(
        "p_nm_dentista" VARCHAR2,
        "p_ds_cro" VARCHAR2,
        "p_ds_email" VARCHAR2,
        "p_nr_telefone" VARCHAR2,
        "p_ds_doc_identificacao" VARCHAR2
    );

    -- Procedure para atualizar um dentista
    PROCEDURE "UPDATE_DENTISTA"(
        "p_nm_dentista" VARCHAR2,
        "p_ds_cro" VARCHAR2,
        "p_ds_email" VARCHAR2,
        "p_nr_telefone" VARCHAR2,
        "p_ds_doc" VARCHAR2
    );

    -- Procedure para deletar um dentista
    PROCEDURE "DELETE_DENTISTA"(
        "p_ds_cro" VARCHAR2
    );

END "PKG_CRUD_DENTISTA";
/


-- Package Body para CRUD
CREATE OR REPLACE PACKAGE BODY "PKG_CRUD_DENTISTA" AS
    -- Exceções globais do pacote
    invalid_doc EXCEPTION;
    dentista_exists EXCEPTION;
    cro_invalid EXCEPTION;
    telefone_invalid EXCEPTION;
    email_invalid EXCEPTION;
    dentista_not_found EXCEPTION;

    -- Procedure de inserção
    PROCEDURE "INSERT_DENTISTA"(
        "p_nm_dentista" VARCHAR2,
        "p_ds_cro" VARCHAR2,
        "p_ds_email" VARCHAR2,
        "p_nr_telefone" VARCHAR2,
        "p_ds_doc_identificacao" VARCHAR2
    ) IS
        invalid_doc EXCEPTION;
        dentista_exists EXCEPTION;
        cro_invalid EXCEPTION;
        telefone_invalid EXCEPTION;
        email_invalid EXCEPTION;
        "dentista_id" NUMBER;
    BEGIN
        -- Chamar a função para validar o CPF OU CNPJ
        IF (NOT "FUN_VALIDA_CPF"("p_ds_doc_identificacao")) AND (NOT "FUN_VALIDA_CNPJ"("p_ds_doc_identificacao")) THEN
            RAISE invalid_doc;
        END IF;

        -- Valida se o CRO está cadastrado
        BEGIN
            SELECT "id_dentista"
            INTO "dentista_id"
            FROM "T_OPBD_DENTISTA"
            WHERE "ds_cro" = "p_ds_cro";
        EXCEPTION
            WHEN no_data_found THEN
                "dentista_id" := NULL;
        END;
        IF "dentista_id" IS NOT NULL THEN
            RAISE dentista_exists;
        END IF;

        -- Valida o email
        IF NOT "FUN_VALIDA_EMAIL"("p_ds_email") THEN
            RAISE email_invalid;
        END IF;

        -- Valida o telefone
        IF NOT "FUN_VALIDA_TELEFONE"("p_nr_telefone") THEN
            RAISE telefone_invalid;
        END IF;

        INSERT INTO "T_OPBD_DENTISTA"
        ("id_dentista",
         "nm_dentista",
         "ds_cro",
         "ds_email",
         "nr_telefone",
         "ds_doc_identificacao")
        VALUES ("SEQ_T_OPBD_DENTISTA".nextval,
                "p_nm_dentista",
                "p_ds_cro",
                "p_ds_email",
                "p_nr_telefone",
                "p_ds_doc_identificacao");
        COMMIT;
        dbms_output.put_line('Dentista inserido com sucesso.');
    EXCEPTION
        WHEN invalid_doc THEN
            RAISE_APPLICATION_ERROR(-20001, 'CPF / CNPJ Inválido.');
        WHEN dentista_exists THEN
            RAISE_APPLICATION_ERROR(-20002, 'CRO já cadastrado.');
        WHEN cro_invalid THEN
            RAISE_APPLICATION_ERROR(-20003, 'CRO Inválido.');
        WHEN email_invalid THEN
            RAISE_APPLICATION_ERROR(-20004,
                                    'Email inválido. Email deve ter formato user@example.com, user@example.org, user@example.br');
        WHEN telefone_invalid THEN
            RAISE_APPLICATION_ERROR(-20005, 'Telefone inválido. Deve ter 11 dígitos, com DDD sem 0, ex 11987654321');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'ERRO DESCONHECIDO.' || SQLERRM);
    END "INSERT_DENTISTA";

    -- Procedure de atualização
    PROCEDURE "UPDATE_DENTISTA"(
        "p_nm_dentista" VARCHAR2,
        "p_ds_cro" VARCHAR2,
        "p_ds_email" VARCHAR2,
        "p_nr_telefone" VARCHAR2,
        "p_ds_doc" VARCHAR2
    ) IS
        invalid_doc EXCEPTION;
        dentista_not_found EXCEPTION;
        cro_invalid EXCEPTION;
        telefone_invalid EXCEPTION;
        email_invalid EXCEPTION;
        "dentista_id" NUMBER;
    BEGIN
        -- Busca o dentista pelo CRO
        BEGIN
            SELECT "id_dentista"
            INTO "dentista_id"
            FROM "T_OPBD_DENTISTA"
            WHERE "ds_cro" = "p_ds_cro";
        EXCEPTION
            WHEN no_data_found THEN
                RAISE dentista_not_found;
        END;

        IF NOT "FUN_VALIDA_CPF"("p_ds_doc") THEN
            IF NOT "FUN_VALIDA_CNPJ"("p_ds_doc") THEN
                RAISE invalid_doc;
            END IF;
        END IF;

        -- Valida o email
        IF NOT "FUN_VALIDA_EMAIL"("p_ds_email") THEN
            RAISE email_invalid;
        END IF;

        -- Valida o telefone
        IF NOT "FUN_VALIDA_TELEFONE"("p_nr_telefone") THEN
            RAISE telefone_invalid;
        END IF;

        -- Faz o Update
        UPDATE "T_OPBD_DENTISTA"
        SET "nm_dentista"          = "p_nm_dentista",
            "nr_telefone"          = "p_nr_telefone",
            "ds_email"             = "p_ds_email",
            "ds_doc_identificacao" = "p_ds_doc"
        WHERE "id_dentista" = "dentista_id";
    EXCEPTION
        WHEN invalid_doc THEN
            RAISE_APPLICATION_ERROR(-20001, 'CPF/CNPJ Inválido.');
        WHEN dentista_not_found THEN
            RAISE_APPLICATION_ERROR(-20002, 'Dentista não existe.');
        WHEN cro_invalid THEN
            RAISE_APPLICATION_ERROR(-20003, 'CRO Inválido.');
        WHEN email_invalid THEN
            RAISE_APPLICATION_ERROR(-20004,
                                    'Email inválido. Email deve ter formato user@example.com, user@example.org, user@example.br');
        WHEN telefone_invalid THEN
            RAISE_APPLICATION_ERROR(-20005, 'Telefone inválido. Deve ter 11 dígitos, com DDD sem 0, ex 11987654321');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'ERRO DESCONHECIDO.' || SQLERRM);
    END "UPDATE_DENTISTA";

    -- Procedure de exclusão
    PROCEDURE "DELETE_DENTISTA"(
        "p_ds_cro" VARCHAR2
    ) IS
    BEGIN

        -- Deleta os relacionamentos com o dentista
        DELETE
        FROM "T_OPBD_PACIENTE_DENTISTA"
        WHERE "id_dentista" IN (SELECT "id_dentista"
                                FROM "T_OPBD_DENTISTA"
                                WHERE "ds_cro" = "p_ds_cro");
        dbms_output
            .
            put_line
        ('Relacionamento Paciente_Dentista deletado com sucesso.');
        -- Deleta da tabela Dentista
        DELETE
        FROM "T_OPBD_DENTISTA"
        WHERE "ds_cro" = "p_ds_cro";
        dbms_output
            .
            put_line
        ('Dentista deletado com sucesso.');

        COMMIT;
    EXCEPTION
        WHEN no_data_found THEN
            RAISE_APPLICATION_ERROR(-20001, 'Documento não encontrado.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'ERRO DESCONHECIDO.' || SQLERRM);
    END "DELETE_DENTISTA";

END "PKG_CRUD_DENTISTA";
/
