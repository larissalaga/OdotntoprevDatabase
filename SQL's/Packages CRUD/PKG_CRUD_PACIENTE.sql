-- Package para CRUD
CREATE OR REPLACE PACKAGE "PKG_CRUD_PACIENTE" AS
    -- Procedure para inserir um novo paciente
    PROCEDURE "INSERT_PACIENTE"(
        "p_nm_paciente" VARCHAR2,
        "p_dt_nascimento" DATE,
        "p_nr_cpf" VARCHAR2,
        "p_ds_sexo" VARCHAR2,
        "p_nr_telefone" VARCHAR2,
        "p_ds_email" VARCHAR2,
        "p_id_plano" NUMBER
    );

    -- Procedure para atualizar um paciente
    PROCEDURE "UPDATE_PACIENTE"(
        "p_nr_cpf" VARCHAR2,
        "p_ds_nome" VARCHAR2,
        "p_nr_telefone" VARCHAR2,
        "p_ds_email" VARCHAR2,
        "p_dt_nasc" DATE,
        "p_ds_sexo" VARCHAR2,
        "p_ds_cod_plano" VARCHAR2
    );

    -- Procedure para deletar um paciente
    PROCEDURE "DELETE_PACIENTE"(
        "p_nr_cpf" VARCHAR2
    );

END "PKG_CRUD_PACIENTE";
/


-- Package Body para CRUD
CREATE OR REPLACE PACKAGE BODY "PKG_CRUD_PACIENTE" AS

    -- Procedure de inserção
    PROCEDURE "INSERT_PACIENTE"(
        "p_nm_paciente" VARCHAR2,
        "p_dt_nascimento" DATE,
        "p_nr_cpf" VARCHAR2,
        "p_ds_sexo" VARCHAR2,
        "p_nr_telefone" VARCHAR2,
        "p_ds_email" VARCHAR2,
        "p_id_plano" NUMBER
    ) IS
        invalid_cpf EXCEPTION;
        paciente_exists EXCEPTION;
        plano_not_found EXCEPTION;
        data_nasc_invalid EXCEPTION;
        telefone_invalid EXCEPTION;
        sexo_invalid EXCEPTION;
        email_invalid EXCEPTION;
        "paciente_id" NUMBER;
        "plano_id"    NUMBER;
    BEGIN
        -- Validação de CPF
        IF NOT "FUN_VALIDA_CPF"("p_nr_cpf") THEN
            RAISE invalid_cpf;
        END IF;

        -- Busca o paciente
        BEGIN
            SELECT "id_paciente"
            INTO "paciente_id"
            FROM "T_OPBD_PACIENTE"
            WHERE "nr_cpf" = "p_nr_cpf";
        EXCEPTION
            WHEN no_data_found THEN
                "paciente_id" := NULL;
        END;
        IF "paciente_id" IS NOT NULL THEN
            RAISE paciente_exists;
        END IF;

        -- Busca o Plano
        BEGIN
            SELECT "id_plano"
            INTO "plano_id"
            FROM "T_OPBD_PLANO"
            WHERE "id_plano" = "p_id_plano";
        EXCEPTION
            WHEN no_data_found THEN
                RAISE plano_not_found;
        END;

        -- Valida a data de nascimento
        IF NOT "FUN_VALIDA_NASCIMENTO"("p_dt_nascimento") THEN
            RAISE data_nasc_invalid;
        END IF;

        -- Valida o email
        IF NOT "FUN_VALIDA_EMAIL"("p_ds_email") THEN
            RAISE email_invalid;
        END IF;

        -- Valida o telefone
        IF NOT "FUN_VALIDA_TELEFONE"("p_nr_telefone") THEN
            RAISE telefone_invalid;
        END IF;

        -- Valida o sexo
        IF NOT "FUN_VALIDA_SEXO"("p_ds_sexo") THEN
            RAISE sexo_invalid;
        END IF;

        -- Inserindo pacientes
        INSERT INTO "T_OPBD_PACIENTE"
        ("id_paciente",
         "nm_paciente",
         "dt_nascimento",
         "nr_cpf",
         "ds_sexo",
         "nr_telefone",
         "ds_email",
         "id_plano")
        VALUES ("SEQ_T_OPBD_PACIENTE".nextval,
                "p_nm_paciente",
                "p_dt_nascimento",
                "p_nr_cpf",
                "p_ds_sexo",
                "p_nr_telefone",
                "p_ds_email",
                "p_id_plano");
        COMMIT;
        dbms_output.put_line('Paciente inserido com sucesso.');
    EXCEPTION
        WHEN invalid_cpf THEN
            RAISE_APPLICATION_ERROR(-20001, 'CPF Inválido.');
        WHEN paciente_exists THEN
            RAISE_APPLICATION_ERROR(-20002, 'CPF já cadastrado.');
        WHEN plano_not_found THEN
            RAISE_APPLICATION_ERROR(-20003, 'Plano não existe.');
        WHEN data_nasc_invalid THEN
            RAISE_APPLICATION_ERROR(-20004, 'Data de nascimento inválida. Nascimento deve ser entre 01/01/1900 e hoje');
        WHEN email_invalid THEN
            RAISE_APPLICATION_ERROR(-20005,
                                    'Email inválido. Email deve ter formato user@example.com, user@example.org, user@example.br');
        WHEN telefone_invalid THEN
            RAISE_APPLICATION_ERROR(-20006, 'Telefone inválido. Deve ter 11 dígitos, com DDD sem 0, ex 11987654321');
        WHEN sexo_invalid THEN
            RAISE_APPLICATION_ERROR(-20007, 'Sexo Inválido. Deve ser M, F ou N');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'ERRO DESCONHECIDO.' || SQLERRM);
    END "INSERT_PACIENTE";

    -- Procedure de atualização
    PROCEDURE "UPDATE_PACIENTE"(
        "p_nr_cpf" VARCHAR2,
        "p_ds_nome" VARCHAR2,
        "p_nr_telefone" VARCHAR2,
        "p_ds_email" VARCHAR2,
        "p_dt_nasc" DATE,
        "p_ds_sexo" VARCHAR2,
        "p_ds_cod_plano" VARCHAR2
    ) IS
        invalid_cpf EXCEPTION;
        paciente_not_found EXCEPTION;
        plano_not_found EXCEPTION;
        data_nasc_invalid EXCEPTION;
        telefone_invalid EXCEPTION;
        sexo_invalid EXCEPTION;
        email_invalid EXCEPTION;
        "paciente_id" NUMBER;
        "plano_id"    NUMBER;
    BEGIN
        -- Validação de CPF
        IF NOT "FUN_VALIDA_CPF"("p_nr_cpf") THEN
            RAISE invalid_cpf;
        END IF;

        -- Busca o paciente
        BEGIN
            SELECT "id_paciente"
            INTO "paciente_id"
            FROM "T_OPBD_PACIENTE"
            WHERE "nr_cpf" = "p_nr_cpf";
        EXCEPTION
            WHEN no_data_found THEN
                RAISE paciente_not_found;
        END;

        -- Busca o Plano
        BEGIN
            SELECT "id_plano"
            INTO "plano_id"
            FROM "T_OPBD_PLANO"
            WHERE "ds_codigo_plano" = "p_ds_cod_plano";
        EXCEPTION
            WHEN no_data_found THEN
                RAISE plano_not_found;
        END;

        -- Valida a data de nascimento
        IF NOT "FUN_VALIDA_NASCIMENTO"("p_dt_nasc") THEN
            RAISE data_nasc_invalid;
        END IF;

        -- Valida o email
        IF NOT "FUN_VALIDA_EMAIL"("p_ds_email") THEN
            RAISE email_invalid;
        END IF;

        -- Valida o telefone
        IF NOT "FUN_VALIDA_TELEFONE"("p_nr_telefone") THEN
            RAISE telefone_invalid;
        END IF;

        -- Valida o sexo
        IF NOT "FUN_VALIDA_SEXO"("p_ds_sexo") THEN
            RAISE sexo_invalid;
        END IF;

        -- Faz o Update
        UPDATE "T_OPBD_PACIENTE"
        SET "nm_paciente"   = "p_ds_nome",
            "nr_telefone"   = "p_nr_telefone",
            "ds_email"      = "p_ds_email",
            "dt_nascimento" = TO_DATE("p_dt_nasc"),
            "ds_sexo"       = "p_ds_sexo",
            "id_plano"      = "plano_id"
        WHERE "id_paciente" = "paciente_id";


    EXCEPTION
        WHEN invalid_cpf THEN
            RAISE_APPLICATION_ERROR(-20001, 'CPF Inv�lido.');
        WHEN paciente_not_found THEN
            RAISE_APPLICATION_ERROR(-20002, 'Paciente n�o existe.');
        WHEN plano_not_found THEN
            RAISE_APPLICATION_ERROR(-20003, 'Plano n�o existe.');
        WHEN data_nasc_invalid THEN
            RAISE_APPLICATION_ERROR(-20004, 'Data de nascimento inv�lida. Nascimento deve ser entre 01/01/1900 e hoje');
        WHEN email_invalid THEN
            RAISE_APPLICATION_ERROR(-20005,
                                    'Email inv�lido. Email deve ter formato user@example.com, user@example.org, user@example.br');
        WHEN telefone_invalid THEN
            RAISE_APPLICATION_ERROR(-20006, 'Telefone inv�lido. Deve ter 11 digitos, com DDD sem 0, ex 11987654321');
        WHEN sexo_invalid THEN
            RAISE_APPLICATION_ERROR(-20007, 'Sexo Invalido. Deve ser M, F ou N');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'ERRO DESCONHECIDO.' || SQLERRM);
    END "UPDATE_PACIENTE";

    -- Procedure de exclusão
    PROCEDURE "DELETE_PACIENTE"(
        "p_nr_cpf" VARCHAR2
    ) IS
        paciente_id NUMBER;
        paciente_not_found EXCEPTION;
        -- Preparação para deletar as tabelas de check in e respostas
        TYPE LISTA_T IS TABLE OF "T_OPBD_RESPOSTAS"."id_resposta"%TYPE;
        lista_respostas LISTA_T;

    BEGIN
        -- Busca o id do paciente por cpf
        BEGIN
            SELECT "id_paciente"
            INTO paciente_id
            FROM "T_OPBD_PACIENTE"
            WHERE "nr_cpf" = "p_nr_cpf";
        EXCEPTION
            WHEN no_data_found THEN
                RAISE paciente_not_found;
        END;

        -- Deleta da tabela Check_in. Foi feito dessa forma pois se o check in é deletado a tabela de respostas
        -- perde a referência. E a tabela de respostas não pode ser deletada antes pois a check in usa uma FK dela

        DELETE
        FROM "T_OPBD_CHECK_IN"
        WHERE "id_paciente" = paciente_id
        RETURNING "id_resposta"
            BULK COLLECT INTO lista_respostas;

        IF lista_respostas.count > 0 THEN
            FOR i IN lista_respostas.first .. lista_respostas.last
                LOOP
                    DELETE
                    FROM "T_OPBD_RESPOSTAS"
                    WHERE "id_resposta" = lista_respostas(i);
                END LOOP;
            dbms_output.put_line('Respostas deletadas com sucesso.');
        END IF;
        dbms_output.put_line('Check_in deletado com sucesso.');

        -- Deleta da tabela Analise_Raio_x
        DELETE
        FROM "T_OPBD_ANALISE_RAIO_X"
        WHERE "id_raio_x" IN (SELECT "id_raio_x"
                              FROM "T_OPBD_RAIO_X"
                              WHERE "id_paciente" = paciente_id);
        dbms_output.put_line('Análise deletada com sucesso.');

        -- Deleta da tabela Raio_x
        DELETE
        FROM "T_OPBD_RAIO_X"
        WHERE "id_paciente" = paciente_id;
        dbms_output.put_line('Raio_x deletado com sucesso.');

        -- Deleta da tabela Paciente_Dentista
        DELETE
        FROM "T_OPBD_PACIENTE_DENTISTA"
        WHERE "id_paciente" = paciente_id;
        dbms_output.put_line('Relacionamentos Paciente_Dentista deletados com sucesso.');

        -- Deleta da tabela Extrato_Pontos
        DELETE
        FROM "T_OPBD_EXTRATO_PONTOS"
        WHERE "id_paciente" = paciente_id;
        dbms_output.put_line('Extratos de Pontos deletados com sucesso.');

        -- Deleta da tabela Paciente
        DELETE
        FROM "T_OPBD_PACIENTE"
        WHERE "nr_cpf" = "p_nr_cpf";
        dbms_output.put_line('Paciente deletado com sucesso.');

        COMMIT;
    EXCEPTION
        WHEN paciente_not_found THEN
            RAISE_APPLICATION_ERROR(-20001, 'Paciente não existe.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'ERRO DESCONHECIDO: ' || SQLERRM);
    END "DELETE_PACIENTE";

END "PKG_CRUD_PACIENTE";
/
