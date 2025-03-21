DROP TABLE "T_OPBD_CHECK_IN";
DROP SEQUENCE "SEQ_T_OPBD_CHECK_IN";

DROP TABLE "T_OPBD_RESPOSTAS";
DROP SEQUENCE "SEQ_T_OPBD_RESPOSTAS";

DROP TABLE "T_OPBD_EXTRATO_PONTOS";
DROP SEQUENCE "SEQ_T_OPBD_EXTRATO_PONTOS";

DROP TABLE "T_OPBD_PACIENTE_DENTISTA";

DROP TABLE "T_OPBD_ANALISE_RAIO_X";
DROP SEQUENCE "SEQ_T_OPBD_ANALISE_RAIO_X";

DROP TABLE "T_OPBD_RAIO_X";
DROP SEQUENCE "SEQ_T_OPBD_RAIO_X";

DROP TABLE "T_OPBD_DENTISTA";
DROP SEQUENCE "SEQ_T_OPBD_DENTISTA";

DROP TABLE "T_OPBD_PERGUNTAS";
DROP SEQUENCE "SEQ_T_OPBD_PERGUNTAS";

DROP TABLE "T_OPBD_PACIENTE";
DROP SEQUENCE "SEQ_T_OPBD_PACIENTE";

DROP TABLE "T_OPBD_PLANO";
DROP SEQUENCE "SEQ_T_OPBD_PLANO";

--------------------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE "SEQ_T_OPBD_PLANO";

CREATE TABLE "T_OPBD_PLANO" (
    "id_plano" NUMBER(20) PRIMARY KEY,
    "ds_codigo_plano" VARCHAR2(15 CHAR),
    "nm_plano" VARCHAR2(60 CHAR)
);

--------------------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE "SEQ_T_OPBD_DENTISTA";

CREATE TABLE "T_OPBD_DENTISTA" (
    "id_dentista" NUMBER(20) PRIMARY KEY,
    "nm_dentista" VARCHAR2(100 CHAR),
    "ds_cro" VARCHAR2(20 CHAR),
    "ds_email" VARCHAR2(70 CHAR),
    "nr_telefone" VARCHAR2(30 CHAR),
    "ds_doc_identificacao" VARCHAR2(14 CHAR)
);

--------------------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE "SEQ_T_OPBD_PERGUNTAS";

CREATE TABLE "T_OPBD_PERGUNTAS" (
    "id_pergunta" NUMBER(20) PRIMARY KEY,
    "ds_pergunta" VARCHAR2(300 CHAR)
);

--------------------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE "SEQ_T_OPBD_PACIENTE";

CREATE TABLE "T_OPBD_PACIENTE" (
    "id_paciente" NUMBER(20) PRIMARY KEY,
    "nm_paciente" VARCHAR2(100 CHAR),
    "dt_nascimento" DATE,
    "nr_cpf" VARCHAR2(11 CHAR),
    "ds_sexo" VARCHAR2(1 CHAR),
    "nr_telefone" VARCHAR2(30 CHAR),
    "ds_email" VARCHAR2(70 CHAR),
    "id_plano" NUMBER(20),
    CONSTRAINT "FK_OPBD_PACIENTE_PLANO"
    FOREIGN KEY ("id_plano") REFERENCES "T_OPBD_PLANO"("id_plano")
);

--------------------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE "SEQ_T_OPBD_EXTRATO_PONTOS";

CREATE TABLE "T_OPBD_EXTRATO_PONTOS" (
    "id_extrato_pontos" NUMBER(20) PRIMARY KEY,
    "dt_extrato" DATE,
    "nr_numero_pontos" NUMBER(10),
    "ds_movimentacao" VARCHAR2(50),
    "id_paciente" NUMBER(20),
    CONSTRAINT "FK_OPBD_EXTRATO_PONTOS_PACIENTE"
    FOREIGN KEY ("id_paciente") REFERENCES "T_OPBD_PACIENTE"("id_paciente")
);

--------------------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE "SEQ_T_OPBD_RESPOSTAS";

CREATE TABLE "T_OPBD_RESPOSTAS" (
    "id_resposta" NUMBER(20) PRIMARY KEY,
    "ds_resposta" VARCHAR2(400 CHAR)
);

--------------------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE "SEQ_T_OPBD_CHECK_IN";

CREATE TABLE "T_OPBD_CHECK_IN" (
    "id_check_in" NUMBER(20) PRIMARY KEY,
    "dt_check_in" DATE,
    "id_paciente" NUMBER(20),
    "id_pergunta" NUMBER(20),
    "id_resposta" NUMBER(20),
    CONSTRAINT "FK_CHECK_IN_PACIENTE"
    FOREIGN KEY ("id_paciente") REFERENCES "T_OPBD_PACIENTE"("id_paciente"),
    CONSTRAINT "FK_CHECK_IN_PERGUNTAS"
    FOREIGN KEY ("id_pergunta") REFERENCES "T_OPBD_PERGUNTAS"("id_pergunta"),
    CONSTRAINT "FK_CHECK_IN_RESPOSTAS"
    FOREIGN KEY ("id_resposta") REFERENCES "T_OPBD_RESPOSTAS"("id_resposta")
);

--------------------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE "SEQ_T_OPBD_RAIO_X";

CREATE TABLE "T_OPBD_RAIO_X" (
    "id_raio_x" NUMBER(20) PRIMARY KEY,
    "ds_raio_x" VARCHAR2(200 CHAR),
    "im_raio_x" BLOB,
    "dt_data_raio_x" DATE,
    "id_paciente" NUMBER(20),
    CONSTRAINT "FK_RAIO_X_PACIENTE"
    FOREIGN KEY ("id_paciente") REFERENCES "T_OPBD_PACIENTE"("id_paciente")
);

--------------------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE "SEQ_T_OPBD_ANALISE_RAIO_X";

CREATE TABLE "T_OPBD_ANALISE_RAIO_X" (
    "id_analise_raio_x" NUMBER(20) PRIMARY KEY,
    "ds_analise_raio_x" CLOB,
    "dt_analise_raio_x" DATE,
    "id_raio_x" NUMBER(20),
    CONSTRAINT "FK_ANALISE_RAIO_X_RAIO_X"
    FOREIGN KEY ("id_raio_x") REFERENCES "T_OPBD_RAIO_X"("id_raio_x")
);

--------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE "T_OPBD_PACIENTE_DENTISTA" (
    "id_dentista" NUMBER(20),
    "id_paciente" NUMBER(20),
    PRIMARY KEY ("id_dentista", "id_paciente"),
    CONSTRAINT "FK_OPBD_PACIENTE_DENTISTA_DENTISTA"
    FOREIGN KEY ("id_dentista") REFERENCES "T_OPBD_DENTISTA"("id_dentista"),
    CONSTRAINT "FK_OPBD_PACIENTE_DENTISTA_PACIENTE"
    FOREIGN KEY ("id_paciente") REFERENCES "T_OPBD_PACIENTE"("id_paciente")
);
