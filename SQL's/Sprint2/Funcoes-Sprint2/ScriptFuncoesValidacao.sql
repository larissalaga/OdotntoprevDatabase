--------------------------------------------------------------------------------------------------------------------------------
-- Validação de CPF: "FUN_VALIDA_CPF"
DECLARE
    "cpf_number" VARCHAR2(11) := '15288546320';
    "is_valid"   BOOLEAN;
BEGIN
    "is_valid" := "FUN_VALIDA_CPF"("cpf_number");
    IF "is_valid" THEN
        dbms_output.put_line('CPF is valid.');
    ELSE
        dbms_output.put_line('CPF is invalid.');
    END IF;
END;
/
--
CREATE OR REPLACE FUNCTION "FUN_VALIDA_CPF"(
    "cpf" VARCHAR
) RETURN BOOLEAN IS
    "sum1"   NUMBER := 0;
    "sum2"   NUMBER := 0;
    "digit1" NUMBER;
    "digit2" NUMBER;
    "i"      NUMBER;
BEGIN
    -- Verifica se tem 11 dígitos e se só tem números (usei o REGEXP_LIKE E O LENGTH)
    IF LENGTH("cpf") != 11 OR NOT REGEXP_LIKE("cpf", '^\d{11}$') THEN
        RETURN FALSE;
    END IF;

    -- Verifica se todos os números são iguais (ex 00000000000, 11111111111)
    IF "cpf" = LPAD(SUBSTR("cpf", 1, 1), 11, SUBSTR("cpf", 1, 1)) THEN
        RETURN FALSE;
    END IF;

    -- Calcular primeiro dígito verificador (ex 111.111.111-X1 verifica o dígito X)
    -- Para esse cálculo deve-se multiplicar os 9 primeiros dígitos do cpf (usei SUBSTR para
    -- separar os dígitos e depois transformar em número), um por um, por valores
    -- decrescentes de 10 até 2 (11-1, 11-2,..., 11-9). Depois verifica-se o resto da
    -- divisão da soma por 11. Se o resto for menor ou igual a 1 o penúltimo dígito
    -- deve ser igual a zero. E se o resto for maior que 2 então o penúltimo dígito
    -- deve ser igual à diferença entre 11 e o valor do resto (multipliquei por 10, para facilitar).
    FOR "i" IN 1..9
        LOOP
            "sum1" := "sum1" + TO_NUMBER(SUBSTR("cpf", "i", 1)) * (11 - "i");
        END LOOP;
    "digit1" := ("sum1" * 10) MOD 11;
    IF "digit1" = 10 THEN
        "digit1" := 0;
    END IF;

    -- Verifica se o primeiro dígito digitado está correto
    IF "digit1" != TO_NUMBER(SUBSTR("cpf", 10, 1)) THEN
        RETURN FALSE;
    END IF;

    -- Calcular segundo dígito verificador
    -- Para esse cálculo fazemos a soma como no outro, porém a multiplicação começa a partir de 11, e
    -- adiciona-se na soma o primeiro dígito verificador (multiplicação dos 10 primeiros dígitos do cpf).
    -- Depois se verifica o resto da divisão por 11, como no anterior.
    FOR "i" IN 1..10
        LOOP
            "sum2" := "sum2" + TO_NUMBER(SUBSTR("cpf", "i", 1)) * (12 - "i");
        END LOOP;
    "digit2" := ("sum2" * 10) MOD 11;
    IF "digit2" = 10 THEN
        "digit2" := 0;
    END IF;

    -- Verifica se o segundo dígito digitado está correto
    IF "digit2" != TO_NUMBER(SUBSTR("cpf", 11, 1)) THEN
        RETURN FALSE;
    END IF;

    -- Se tudo passar, é válido
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(2000, 'ERRO DESCONHECIDO.');
        RETURN FALSE;
END "FUN_VALIDA_CPF";
/
--------------------------------------------------------------------------------------------------------------------------------
-- Validação de CNPJ: "FUN_VALIDA_CNPJ"
DECLARE
    "cnpj_number" VARCHAR2(14) := '28797727000160';
    "is_valid"    BOOLEAN;
BEGIN
    "is_valid" := "FUN_VALIDA_CNPJ"("cnpj_number");
    IF "is_valid" THEN
        dbms_output.put_line('CNPJ is valid.');
    ELSE
        dbms_output.put_line('CNPJ is invalid.');
    END IF;
END;
/
--
CREATE OR REPLACE FUNCTION "FUN_VALIDA_CNPJ"(
    "cnpj" VARCHAR
) RETURN BOOLEAN IS
    "sum1"              NUMBER             := 0;
    "sum2"              NUMBER             := 0;
    "digit1"            NUMBER;
    "digit2"            NUMBER;

    -- Essas são listas que contêm os pesos para verificação dos CNPJ's de 2 a 9 de trás para frente
    "weights1" CONSTANT sys.ODCINUMBERLIST := sys.odcinumberlist(5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2);
    "weights2" CONSTANT sys.ODCINUMBERLIST := sys.odcinumberlist(6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2);
    "i"                 NUMBER;
BEGIN
    -- Verifica se tem 14 dígitos e se só tem números
    IF LENGTH("cnpj") != 14 OR NOT REGEXP_LIKE("cnpj", '^\d{14}$') THEN
        RETURN FALSE;
    END IF;

    -- Verifica se todos os números são iguais (ex 00000000000, 11111111111)
    IF "cnpj" = LPAD(SUBSTR("cnpj", 1, 1), 14, SUBSTR("cnpj", 1, 1)) THEN
        RETURN FALSE;
    END IF;

    -- Calcular primeiro dígito verificador (o penúltimo número) se multiplica os 12 primeiros
    -- números pelos pesos das listas 1, um por um e somam-se os resultados. Depois verifica-se o resto da
    -- divisão dessa soma por 11. Se o resto for menor ou igual a 1 o penúltimo dígito
    -- deve ser igual a zero. E se o resto for maior que 2 então o penúltimo dígito deve ser igual a
    -- diferença entre 11 e o valor do resto (Essa conta é feita direto aqui: "digit1" := ("sum1" * 10) MOD 11).
    FOR "i" IN 1..12
        LOOP
            "sum1" := "sum1" + TO_NUMBER(SUBSTR("cnpj", "i", 1)) * "weights1"("i");
        END LOOP;
    "digit1" := ("sum1" * 10) MOD 11;
    IF "digit1" = 10 THEN
        "digit1" := 0;
    END IF;

    -- Verifica se o primeiro dígito digitado está correto
    IF "digit1" != TO_NUMBER(SUBSTR("cnpj", 13, 1)) THEN
        RETURN FALSE;
    END IF;

    -- Calcular segundo dígito verificador. Se multiplica os 13 primeiros
    -- números pelos pesos das listas 1, um por um e somam-se os resultados.
    -- Depois se verifica o resto da divisão por 11, como no anterior.
    FOR "i" IN 1..13
        LOOP
            "sum2" := "sum2" + TO_NUMBER(SUBSTR("cnpj", "i", 1)) * "weights2"("i");
        END LOOP;
    "digit2" := ("sum2" * 10) MOD 11;
    IF "digit2" = 10 THEN
        "digit2" := 0;
    END IF;
    -- Verifica se o segundo dígito digitado está correto
    IF "digit2" != TO_NUMBER(SUBSTR("cnpj", 14, 1)) THEN
        RETURN FALSE;
    END IF;

    -- Se tudo passar, é válido
    RETURN TRUE;
END "FUN_VALIDA_CNPJ";
/
--------------------------------------------------------------------------------------------------------------------------------
-- Validação de Nascimento: "FUN_VALIDA_NASCIMENTO"
DECLARE
    "data_nasc" DATE := TO_DATE('01/01/1900');
    "is_valid"  BOOLEAN;
BEGIN
    "is_valid" := "FUN_VALIDA_NASCIMENTO"("data_nasc");
    IF "is_valid" THEN
        dbms_output.put_line('Date is valid.');
    ELSE
        dbms_output.put_line('Date is invalid.');
    END IF;
END;
/
--
CREATE OR REPLACE FUNCTION "FUN_VALIDA_NASCIMENTO"("data_nascimento" DATE) RETURN BOOLEAN IS
BEGIN
    IF "data_nascimento" < TO_DATE('01/01/1900') OR "data_nascimento" > CURRENT_DATE THEN
        RETURN FALSE;
    END IF;
    RETURN TRUE;
END;
/
--------------------------------------------------------------------------------------------------------------------------------
-- Validação de Telefone: "FUN_VALIDA_TELEFONE"
DECLARE
    "telefone" VARCHAR2(11) := '11987664790';
    "is_valid" BOOLEAN;
BEGIN
    "is_valid" := "FUN_VALIDA_TELEFONE"("telefone");
    IF "is_valid" THEN
        dbms_output.put_line('telefone is valid.');
    ELSE
        dbms_output.put_line('telefone is invalid.');
    END IF;
END;
/
--
CREATE OR REPLACE FUNCTION "FUN_VALIDA_TELEFONE"("telefone" VARCHAR2) RETURN BOOLEAN IS
BEGIN
    -- Verifica se tem 11 dígitos e se só tem números
    IF LENGTH("telefone") != 11 OR NOT REGEXP_LIKE("telefone", '^\d{11}$') THEN
        RETURN FALSE;
    END IF;
    RETURN TRUE;
END;
/
--------------------------------------------------------------------------------------------------------------------------------
-- Validação de Email: "FUN_VALIDA_EMAIL"
DECLARE
    "email_test" VARCHAR2(100);
    "is_valid"   BOOLEAN;
BEGIN
    -- Test cases
    FOR "email_test" IN (
        SELECT 'user@example.com' AS "email"
        FROM dual
        UNION ALL
        SELECT 'user.name@domain.co.uk'
        FROM dual
        UNION ALL
        SELECT 'user-name@domain.org'
        FROM dual
        UNION ALL
        SELECT 'user@.com'
        FROM dual
        UNION ALL
        SELECT '@domain.com'
        FROM dual
        UNION ALL
        SELECT 'user@domain'
        FROM dual
        UNION ALL
        SELECT 'user@domain..com'
        FROM dual
        )
        LOOP
            "is_valid" := "FUN_VALIDA_EMAIL"("email_test"."email");
            dbms_output.put_line('Email: ' || "email_test"."email" || ' | Valid: ' ||
                                 CASE WHEN "is_valid" THEN 'TRUE' ELSE 'FALSE' END);
        END LOOP;
END;
/
--
CREATE OR REPLACE FUNCTION "FUN_VALIDA_EMAIL"("email" VARCHAR2) RETURN BOOLEAN IS
BEGIN
    /*
     Regex:
        ^: Marca o início da string, garantindo que a verificação comece do início.
        [A-Za-z0-9._%-]+: Representa a parte local do e-mail (antes do @), permitindo letras maiúsculas e minúsculas (A-Za-z), números (0-9), ponto (.), sublinhado (_), percentual (%) e hífen (-). O símbolo + exige que haja pelo menos um desses caracteres.
        @: Exige o símbolo @ separando a parte local do domínio.
        [A-Za-z0-9-]+: Representa o primeiro nível do domínio (após o @), permitindo letras (A-Za-z), números (0-9) e hífen (-), mas não pontos. O + indica que precisa haver pelo menos um desses caracteres.
        (\.[A-Za-z0-9-]+)*: Permite subdomínios adicionais precedidos por um ponto (.), seguidos por letras, números ou hífens. O * indica que essa parte é opcional e pode ocorrer várias vezes, mas sempre com um ponto seguido de caracteres válidos.
        \.[A-Za-z]{2,}$: Exige um ponto (.) seguido de pelo menos duas letras no final da string, representando a extensão do domínio (como .com ou .br).
        $: Marca o final da string, garantindo que toda a string do e-mail se encaixe no padrão.
    */
    RETURN REGEXP_LIKE("email", '^[A-Za-z0-9._%-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}$', 'c');
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END;
/
--------------------------------------------------------------------------------------------------------------------------------
-- Validação de Sexo: "FUN_VALIDA_SEXO"
DECLARE
    "sexo"     VARCHAR2(30) := 'F';
    "is_valid" BOOLEAN;
BEGIN
    "is_valid" := "FUN_VALIDA_SEXO"("sexo");
    IF "is_valid" THEN
        dbms_output.put_line('sexo is valid.');
    ELSE
        dbms_output.put_line('sexo is invalid.');
    END IF;
END;
/
--
CREATE OR REPLACE FUNCTION "FUN_VALIDA_SEXO"("sexo" VARCHAR2) RETURN BOOLEAN IS
BEGIN
    RETURN ("sexo" = 'F') OR ("sexo" = 'M') OR ("sexo" = 'N');
END;
/
--------------------------------------------------------------------------------------------------------------------------------
-- Validação de Data: "FUN_VALIDA_DATA_DOC"
DECLARE
    "data_nasc" DATE := TO_DATE('01/01/2024');
    "is_valid"  BOOLEAN;
BEGIN
    "is_valid" := "FUN_VALIDA_DATA_DOC"("data_nasc", 1);
    IF "is_valid" THEN
        dbms_output.put_line('Date is valid.');
    ELSE
        dbms_output.put_line('Date is invalid.');
    END IF;
END;
/
--
CREATE OR REPLACE FUNCTION "FUN_VALIDA_DATA_DOC"("doc_date" DATE, "paciente_id" NUMBER) RETURN BOOLEAN IS
    "data_nasc" DATE;
    data_nasc_not_found EXCEPTION;
BEGIN
    BEGIN
        SELECT "dt_nascimento"
        INTO "data_nasc"
        FROM "T_OPBD_PACIENTE"
        WHERE "id_paciente" = "paciente_id";
    EXCEPTION
        WHEN no_data_found THEN
            RAISE data_nasc_not_found;
    END;
    IF "doc_date" NOT BETWEEN "data_nasc" AND CURRENT_DATE THEN
        RETURN FALSE;
    END IF;
    RETURN TRUE;
EXCEPTION
    WHEN data_nasc_not_found THEN
        RAISE_APPLICATION_ERROR(-20001, 'Data de Nascimento do paciente não existe.');
        RETURN FALSE;
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, 'ERRO DESCONHECIDO.' || SQLERRM);
        RETURN FALSE;
END;
/
