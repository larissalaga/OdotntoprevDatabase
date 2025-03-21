-- Package para CRUD
CREATE OR REPLACE PACKAGE "PKG_CRUD_PACIENTE_DENTISTA" AS
    -- Procedure para inserir uma nova relação paciente-dentista
    PROCEDURE "INSERT_PACIENTE_DENTISTA"(
        "p_id_dentista" NUMBER,
        "p_id_paciente" NUMBER
    );

-- UPDATE_PACIENTE_DENTISTA: Não faz sentido ter uma função de update de Paciente_Dentista para a nossa funcionalidade

    -- Procedure para deletar uma relação paciente-dentista
    PROCEDURE "DELETE_PACIENTE_DENTISTA"(
        "p_ds_cro" VARCHAR2,
        "p_nr_cpf" VARCHAR2
    );

END "PKG_CRUD_PACIENTE_DENTISTA";
/

-- Package Body para CRUD
CREATE OR REPLACE PACKAGE BODY "PKG_CRUD_PACIENTE_DENTISTA" AS
    -- Exceções globais do pacote
    paciente_not_found EXCEPTION;
    dentista_not_found EXCEPTION;
    relacao_exists EXCEPTION;

    -- Procedure de inserção
    PROCEDURE "INSERT_PACIENTE_DENTISTA"(
        "p_id_dentista" NUMBER,
        "p_id_paciente" NUMBER
    ) IS
        paciente_not_found EXCEPTION;
        dentista_not_found EXCEPTION;
        relacao_exists EXCEPTION;
        "id_found" NUMBER;
    BEGIN
        -- Valida se a relação existe
        BEGIN
            SELECT "id_dentista"
            INTO "id_found"
            FROM "T_OPBD_PACIENTE_DENTISTA"
            WHERE "id_dentista" = "p_id_dentista"
              AND "id_paciente" = "p_id_paciente";
        EXCEPTION
            WHEN no_data_found THEN
                "id_found" := NULL;
        END;
        IF "id_found" IS NOT NULL THEN
            RAISE relacao_exists;
        END IF;
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

        -- Valida se o Dentista existe
        BEGIN
            SELECT "id_dentista"
            INTO "id_found"
            FROM "T_OPBD_DENTISTA"
            WHERE "id_dentista" = "p_id_dentista";
        EXCEPTION
            WHEN no_data_found THEN
                RAISE dentista_not_found;
        END;

        INSERT INTO "T_OPBD_PACIENTE_DENTISTA"
        ("id_dentista",
         "id_paciente")
        VALUES ("p_id_dentista",
                "p_id_paciente");
        COMMIT;
        dbms_output.put_line('Relação paciente dentista inserida com sucesso.');
    EXCEPTION
        WHEN relacao_exists THEN
            RAISE_APPLICATION_ERROR(-20001, 'Relação entre Paciente e Dentista já existe.');
        WHEN paciente_not_found THEN
            RAISE_APPLICATION_ERROR(-20002, 'Paciente não existe.');
        WHEN dentista_not_found THEN
            RAISE_APPLICATION_ERROR(-20003, 'Dentista não existe.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'ERRO DESCONHECIDO.' || SQLERRM);
            ROLLBACK;
    END "INSERT_PACIENTE_DENTISTA";

    -- Procedure de exclusão
    PROCEDURE "DELETE_PACIENTE_DENTISTA"(
        "p_ds_cro" VARCHAR2,
        "p_nr_cpf" VARCHAR2
    ) IS
        "dentista_id" NUMBER;
        "paciente_id"
                      NUMBER;
        dentista_not_found
            EXCEPTION;
        paciente_not_found
            EXCEPTION;
    BEGIN
        -- Busca o id do paciente por cpf
        BEGIN
            SELECT "id_paciente"
            INTO "paciente_id"
            FROM "T_OPBD_PACIENTE"
            WHERE "nr_cpf" = "p_nr_cpf";
        EXCEPTION
            WHEN no_data_found THEN
                RAISE paciente_not_found;
        END;

        -- Busca o id do Dentista por cro
        BEGIN
            SELECT "id_dentista"
            INTO "dentista_id"
            FROM "T_OPBD_DENTISTA"
            WHERE "ds_cro" = "p_ds_cro";
        EXCEPTION
            WHEN no_data_found THEN
                RAISE dentista_not_found;
        END;

        -- Deleta da tabela Paciente_Dentista
        DELETE
        FROM "T_OPBD_PACIENTE_DENTISTA"
        WHERE ("dentista_id" = "id_dentista")
          AND ("paciente_id" = "id_paciente");
        dbms_output
            .
            put_line
        ('Relacionamento paciente-dentista deletado com sucesso.');

        COMMIT;
    EXCEPTION
        WHEN paciente_not_found THEN
            RAISE_APPLICATION_ERROR(-20001, 'Paciente n�o existe.');
        WHEN dentista_not_found THEN
            RAISE_APPLICATION_ERROR(-20002, 'Dentista n�o existe.');
        WHEN no_data_found THEN
            RAISE_APPLICATION_ERROR(-20003, 'Relacionamento n�o encontrado.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'ERRO DESCONHECIDO.' || SQLERRM);
    END "DELETE_PACIENTE_DENTISTA";
END "PKG_CRUD_PACIENTE_DENTISTA";
/