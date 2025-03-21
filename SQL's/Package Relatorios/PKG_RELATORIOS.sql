CREATE OR REPLACE PACKAGE "PKG_RELATORIOS" AS

    -- Procedure para exibir histórico de respostas dos pacientes podendo ser filtrada por CPF e total de pontos
    PROCEDURE "RELATORIO_HISTORICO_RESPOSTAS"(p_nr_cpf VARCHAR2 DEFAULT NULL);

    -- Procedure para exibir os Raios-X e suas análises por paciente e qtd
    PROCEDURE "RELATORIO_RAIOX_ANALISES"(p_nr_cpf VARCHAR2 DEFAULT NULL);

END "PKG_RELATORIOS";
/

CREATE OR REPLACE PACKAGE BODY "PKG_RELATORIOS" AS
    -- Exceções globais do pacote
    invalid_cpf EXCEPTION;
    paciente_not_found EXCEPTION;

    -- Procedure para exibir histórico de respostas dos pacientes e total de pontos
    PROCEDURE "RELATORIO_HISTORICO_RESPOSTAS"(
        p_nr_cpf VARCHAR2
    )
        IS
        paciente_id NUMBER;
        CURSOR c_historico IS
            SELECT p."nm_paciente"                         AS nome_paciente
                 , perg."ds_pergunta"                      AS pergunta
                 , resp."ds_resposta"                      AS resposta
                 , TO_CHAR(ci."dt_check_in", 'DD/MM/YYYY') AS data_resposta
                 -- soma de pontos
                 , NVL(SUM(ep."nr_numero_pontos"), 0)      AS total_pontos
            FROM "T_OPBD_CHECK_IN" ci
                     INNER JOIN "T_OPBD_PACIENTE" p ON ci."id_paciente" = p."id_paciente"
                     INNER JOIN "T_OPBD_PERGUNTAS" perg ON ci."id_pergunta" = perg."id_pergunta"
                     INNER JOIN "T_OPBD_RESPOSTAS" resp ON ci."id_resposta" = resp."id_resposta"
                     LEFT JOIN "T_OPBD_EXTRATO_PONTOS" ep ON ep."id_paciente" = p."id_paciente"
            WHERE p_nr_cpf IS NULL
               OR p."nr_cpf" = p_nr_cpf
            GROUP BY p."nm_paciente", perg."ds_pergunta", resp."ds_resposta", ci."dt_check_in"
            ORDER BY p."nm_paciente", ci."dt_check_in";
        v_historico C_HISTORICO%ROWTYPE;
    BEGIN
        -- Validação de CPF
        IF NOT "FUN_VALIDA_CPF"(p_nr_cpf) THEN
            RAISE invalid_cpf;
        END IF;

        -- Busca o paciente
        BEGIN
            SELECT "id_paciente"
            INTO paciente_id
            FROM "T_OPBD_PACIENTE"
            WHERE "nr_cpf" = p_nr_cpf;
        EXCEPTION
            WHEN no_data_found THEN
                RAISE paciente_not_found;
        END;

        OPEN c_historico;
        LOOP
            FETCH c_historico INTO v_historico;
            EXIT WHEN c_historico%NOTFOUND;

            dbms_output.put_line('Paciente: ' || v_historico.nome_paciente ||
                                 CHR(10) || 'Pergunta: ' || v_historico.pergunta ||
                                 CHR(10) || 'Resposta: ' || v_historico.resposta ||
                                 CHR(10) || 'Data: ' || v_historico.data_resposta ||
                                 CHR(10) || 'Total de Pontos: ' || v_historico.total_pontos);
        END LOOP;
        CLOSE c_historico;
    EXCEPTION
        WHEN invalid_cpf THEN
            RAISE_APPLICATION_ERROR(-20001, 'CPF Inválido.');
        WHEN paciente_not_found THEN
            RAISE_APPLICATION_ERROR(-20002, 'Paciente não existe.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'ERRO DESCONHECIDO: ' || SQLERRM);
    END "RELATORIO_HISTORICO_RESPOSTAS";

    -- Procedure para exibir raios-X e suas análises por paciente e quantos raios-X foram avaliados
    PROCEDURE "RELATORIO_RAIOX_ANALISES"(
        p_nr_cpf VARCHAR2 DEFAULT NULL
    )
        IS
        paciente_id NUMBER;
        CURSOR c_raiox IS
            SELECT p."nm_paciente"                              AS nome_paciente
                 , TO_CHAR(rx."dt_data_raio_x", 'DD/MM/YYYY')   AS data_raiox
                 , NVL(arx."ds_analise_raio_x", 'Sem análise')  AS descricao_analise
                 -- Contador
                 , (SELECT COUNT(*)
                    FROM "T_OPBD_ANALISE_RAIO_X" arx_sub
                    WHERE arx_sub."id_raio_x" = rx."id_raio_x") AS total_raiox_analisados
                 , pl."nm_plano"                                AS nome_plano
            FROM "T_OPBD_RAIO_X" rx
                     INNER JOIN "T_OPBD_PACIENTE" p ON rx."id_paciente" = p."id_paciente"
                     INNER JOIN "T_OPBD_PLANO" pl ON p."id_plano" = pl."id_plano"
                     LEFT JOIN "T_OPBD_ANALISE_RAIO_X" arx ON rx."id_raio_x" = arx."id_raio_x"
            WHERE p_nr_cpf IS NULL
               OR p."nr_cpf" = p_nr_cpf
            ORDER BY p."nm_paciente", rx."dt_data_raio_x";
        v_raiox     C_RAIOX%ROWTYPE;
    BEGIN
        -- Validação de CPF
        IF NOT "FUN_VALIDA_CPF"(p_nr_cpf) THEN
            RAISE invalid_cpf;
        END IF;
        -- Busca o paciente
        BEGIN
            SELECT "id_paciente"
            INTO paciente_id
            FROM "T_OPBD_PACIENTE"
            WHERE "nr_cpf" = p_nr_cpf;
        EXCEPTION
            WHEN no_data_found THEN
                RAISE paciente_not_found;
        END;
        OPEN c_raiox;
        LOOP
            FETCH c_raiox INTO v_raiox;
            EXIT WHEN c_raiox%NOTFOUND;

            dbms_output.put_line('Paciente: ' || v_raiox.nome_paciente ||
                                 CHR(10) || 'Data Raio-X: ' || v_raiox.data_raiox ||
                                 CHR(10) || 'Análise: ' || v_raiox.descricao_analise ||
                                 CHR(10) || 'Total de Raios-X Analisados: ' || v_raiox.total_raiox_analisados ||
                                 CHR(10) || 'Plano Odontológico: ' || v_raiox.nome_plano);
        END LOOP;
        CLOSE c_raiox;
    EXCEPTION
        WHEN invalid_cpf THEN
            RAISE_APPLICATION_ERROR(-20001, 'CPF Inválido.');
        WHEN paciente_not_found THEN
            RAISE_APPLICATION_ERROR(-20002, 'Paciente não existe.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'ERRO DESCONHECIDO: ' || SQLERRM);
    END "RELATORIO_RAIOX_ANALISES";
END "PKG_RELATORIOS";
/
