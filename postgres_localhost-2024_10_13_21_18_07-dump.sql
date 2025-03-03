--
-- PostgreSQL database dump
--

-- Dumped from database version 16.4
-- Dumped by pg_dump version 16.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: clock; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA clock;


ALTER SCHEMA clock OWNER TO postgres;

--
-- Name: betalningsstatus; Type: TYPE; Schema: clock; Owner: postgres
--

CREATE TYPE clock.betalningsstatus AS ENUM (
    'betald',
    'ej betald',
    'väntar på betalning'
);


ALTER TYPE clock.betalningsstatus OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: auktion; Type: TABLE; Schema: clock; Owner: postgres
--

CREATE TABLE clock.auktion (
    id integer NOT NULL,
    start_datum date,
    "utgångspris" integer,
    slut_datum date,
    "säljare_id" integer,
    klocka_id integer NOT NULL,
    reservationspris integer,
    pausad boolean,
    betalningsstatus clock.betalningsstatus
);


ALTER TABLE clock.auktion OWNER TO postgres;

--
-- Name: klockor; Type: TABLE; Schema: clock; Owner: postgres
--

CREATE TABLE clock.klockor (
    id integer NOT NULL,
    "märke" character varying(32),
    modell character varying(32),
    diameter integer,
    urverk character varying(32),
    armband character varying(32),
    "färg" character varying(32),
    beskrivning character varying(128)
);


ALTER TABLE clock.klockor OWNER TO postgres;

--
-- Name: konto; Type: TABLE; Schema: clock; Owner: postgres
--

CREATE TABLE clock.konto (
    id integer NOT NULL,
    "användarnamn" character varying(65),
    profilbild character varying(600),
    admin boolean,
    reg_datum date,
    "lösenord" character varying(128),
    mail_id integer
);


ALTER TABLE clock.konto OWNER TO postgres;

--
-- Name: _aktiva_auktioner; Type: VIEW; Schema: clock; Owner: postgres
--

CREATE VIEW clock._aktiva_auktioner AS
 SELECT a.id,
    a.start_datum,
    a.slut_datum,
    konto."användarnamn",
    k."märke",
    k.modell,
    k."färg",
    k.diameter
   FROM ((clock.konto
     JOIN clock.auktion a ON ((konto.id = a."säljare_id")))
     JOIN clock.klockor k ON ((k.id = a.klocka_id)))
  WHERE (a.slut_datum > '2024-10-09'::date);


ALTER VIEW clock._aktiva_auktioner OWNER TO postgres;

--
-- Name: adresser; Type: TABLE; Schema: clock; Owner: postgres
--

CREATE TABLE clock.adresser (
    id integer NOT NULL,
    gatunamn character varying(32),
    gatunummer integer,
    ort character varying(32),
    postnummer integer,
    land character varying(32)
);


ALTER TABLE clock.adresser OWNER TO postgres;

--
-- Name: adresser_id_seq; Type: SEQUENCE; Schema: clock; Owner: postgres
--

CREATE SEQUENCE clock.adresser_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE clock.adresser_id_seq OWNER TO postgres;

--
-- Name: adresser_id_seq; Type: SEQUENCE OWNED BY; Schema: clock; Owner: postgres
--

ALTER SEQUENCE clock.adresser_id_seq OWNED BY clock.adresser.id;


--
-- Name: bud; Type: TABLE; Schema: clock; Owner: postgres
--

CREATE TABLE clock.bud (
    id integer NOT NULL,
    auktion_id integer,
    budgivare_id integer,
    bud_i_kr integer,
    bud_datum timestamp without time zone
);


ALTER TABLE clock.bud OWNER TO postgres;

--
-- Name: all_budgivningshistorik; Type: VIEW; Schema: clock; Owner: postgres
--

CREATE VIEW clock.all_budgivningshistorik AS
 SELECT auktion.id AS auktions_id,
    auktion."utgångspris",
    b.budgivare_id,
    budgivare_konto."användarnamn" AS budgivare,
    auktion.start_datum,
    auktion.slut_datum,
    b.bud_i_kr,
    b.bud_datum,
    k2."märke",
    k2.modell,
    k2."färg",
    k2.armband
   FROM ((((clock.auktion
     JOIN clock.konto "säljare_konto" ON (("säljare_konto".id = auktion."säljare_id")))
     JOIN clock.klockor k2 ON ((k2.id = auktion.klocka_id)))
     JOIN clock.bud b ON ((auktion.id = b.auktion_id)))
     JOIN clock.konto budgivare_konto ON ((budgivare_konto.id = b.budgivare_id)))
  ORDER BY b.bud_i_kr DESC;


ALTER VIEW clock.all_budgivningshistorik OWNER TO postgres;

--
-- Name: personuppgifter; Type: TABLE; Schema: clock; Owner: postgres
--

CREATE TABLE clock.personuppgifter (
    id integer NOT NULL,
    "förnamn" character varying(32),
    efternamn character varying(32),
    personnummer character varying(32)
);


ALTER TABLE clock.personuppgifter OWNER TO postgres;

--
-- Name: alla_användare_ej_admin; Type: VIEW; Schema: clock; Owner: postgres
--

CREATE VIEW clock."alla_användare_ej_admin" AS
 SELECT konto.id,
    konto."användarnamn",
    p."förnamn",
    p.efternamn,
    konto.admin
   FROM (clock.konto
     JOIN clock.personuppgifter p ON ((p.id = konto.id)))
  WHERE (konto.admin = false);


ALTER VIEW clock."alla_användare_ej_admin" OWNER TO postgres;

--
-- Name: alla_auktioner_som_inte_är_pausade; Type: VIEW; Schema: clock; Owner: postgres
--

CREATE VIEW clock."alla_auktioner_som_inte_är_pausade" AS
 SELECT id,
    start_datum,
    "utgångspris",
    slut_datum,
    "säljare_id",
    klocka_id,
    reservationspris AS dolt_pris,
    pausad,
    betalningsstatus
   FROM clock.auktion
  WHERE (pausad = false);


ALTER VIEW clock."alla_auktioner_som_inte_är_pausade" OWNER TO postgres;

--
-- Name: alla_bud; Type: VIEW; Schema: clock; Owner: postgres
--

CREATE VIEW clock.alla_bud AS
 SELECT konto."användarnamn",
    b.bud_i_kr,
    a.id AS auktion_id,
    k."märke",
    k.modell,
    k."färg",
    k.diameter
   FROM (((clock.konto
     JOIN clock.bud b ON ((konto.id = b.budgivare_id)))
     JOIN clock.auktion a ON ((a.id = b.auktion_id)))
     JOIN clock.klockor k ON ((k.id = a.klocka_id)))
  ORDER BY b.bud_i_kr DESC;


ALTER VIEW clock.alla_bud OWNER TO postgres;

--
-- Name: allas_auktioner; Type: VIEW; Schema: clock; Owner: postgres
--

CREATE VIEW clock.allas_auktioner AS
 SELECT konto.id AS konto_id,
    konto."användarnamn",
    a.id AS auktion_id,
    a.start_datum,
    a.slut_datum,
    k."märke",
    k.modell,
    k."färg",
    k.diameter
   FROM ((clock.konto
     JOIN clock.auktion a ON ((konto.id = a."säljare_id")))
     JOIN clock.klockor k ON ((k.id = a.klocka_id)));


ALTER VIEW clock.allas_auktioner OWNER TO postgres;

--
-- Name: email; Type: TABLE; Schema: clock; Owner: postgres
--

CREATE TABLE clock.email (
    id integer NOT NULL,
    mail character varying(32),
    personuppgift_id integer
);


ALTER TABLE clock.email OWNER TO postgres;

--
-- Name: telefonnummer; Type: TABLE; Schema: clock; Owner: postgres
--

CREATE TABLE clock.telefonnummer (
    id integer NOT NULL,
    telefonnummer character varying(32),
    personuppgifter_id integer
);


ALTER TABLE clock.telefonnummer OWNER TO postgres;

--
-- Name: användare_info; Type: VIEW; Schema: clock; Owner: postgres
--

CREATE VIEW clock."användare_info" AS
 SELECT konto.id,
    konto."användarnamn",
    p."förnamn",
    p.efternamn,
    t.telefonnummer,
    e.mail,
    a.gatunamn,
    a.gatunummer,
    a.ort,
    a.postnummer
   FROM ((((clock.konto
     JOIN clock.personuppgifter p ON ((p.id = konto.id)))
     JOIN clock.telefonnummer t ON ((p.id = t.personuppgifter_id)))
     JOIN clock.email e ON ((e.id = konto.mail_id)))
     JOIN clock.adresser a ON ((p.id = a.id)))
  WHERE (konto.admin = false);


ALTER VIEW clock."användare_info" OWNER TO postgres;

--
-- Name: användarprofil; Type: VIEW; Schema: clock; Owner: postgres
--

CREATE VIEW clock."användarprofil" AS
 SELECT "användarnamn",
    reg_datum,
    profilbild
   FROM clock.konto;


ALTER VIEW clock."användarprofil" OWNER TO postgres;

--
-- Name: auktion_id_seq; Type: SEQUENCE; Schema: clock; Owner: postgres
--

CREATE SEQUENCE clock.auktion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE clock.auktion_id_seq OWNER TO postgres;

--
-- Name: auktion_id_seq; Type: SEQUENCE OWNED BY; Schema: clock; Owner: postgres
--

ALTER SEQUENCE clock.auktion_id_seq OWNED BY clock.auktion.id;


--
-- Name: auktion_kontroll_admin; Type: VIEW; Schema: clock; Owner: postgres
--

CREATE VIEW clock.auktion_kontroll_admin AS
 SELECT auktion.id AS auktions_id,
    auktion.start_datum,
    auktion.slut_datum,
    k."användarnamn" AS "säljare",
        CASE
            WHEN (auktion.pausad = true) THEN 'Auktionen behöver kontrolleras'::text
            ELSE 'Auktionen är kontrollerad'::text
        END AS auktion_status_admin
   FROM (clock.auktion
     JOIN clock.konto k ON ((k.id = auktion."säljare_id")));


ALTER VIEW clock.auktion_kontroll_admin OWNER TO postgres;

--
-- Name: bilder; Type: TABLE; Schema: clock; Owner: postgres
--

CREATE TABLE clock.bilder (
    id integer NOT NULL,
    klock_id integer,
    bild character varying(456)
);


ALTER TABLE clock.bilder OWNER TO postgres;

--
-- Name: auktioner_med_bilder; Type: VIEW; Schema: clock; Owner: postgres
--

CREATE VIEW clock.auktioner_med_bilder AS
 SELECT auktion.id AS auktions_nummer,
    auktion.klocka_id,
    k2."märke",
    k2.modell,
    k2."färg",
    k2.diameter,
    k2.urverk,
    k2.armband,
    b.bild,
    k2.beskrivning
   FROM ((clock.auktion
     JOIN clock.klockor k2 ON ((auktion.klocka_id = k2.id)))
     JOIN clock.bilder b ON ((k2.id = b.klock_id)))
  WHERE (auktion.slut_datum >= CURRENT_DATE)
  ORDER BY auktion.klocka_id;


ALTER VIEW clock.auktioner_med_bilder OWNER TO postgres;

--
-- Name: auktioners_och_bud; Type: VIEW; Schema: clock; Owner: postgres
--

CREATE VIEW clock.auktioners_och_bud AS
 SELECT auktion.id AS auktions_nummer,
    k."användarnamn" AS budgivare,
    b.bud_i_kr,
    b.bud_datum,
    k2."märke",
    k2.modell,
    k2."färg",
    k2.diameter,
    k2.urverk
   FROM (((clock.auktion
     JOIN clock.bud b ON ((auktion.id = b.auktion_id)))
     JOIN clock.konto k ON ((b.budgivare_id = k.id)))
     JOIN clock.klockor k2 ON ((auktion.klocka_id = k2.id)))
  WHERE (b.bud_i_kr IS NOT NULL);


ALTER VIEW clock.auktioners_och_bud OWNER TO postgres;

--
-- Name: bilder_id_seq; Type: SEQUENCE; Schema: clock; Owner: postgres
--

CREATE SEQUENCE clock.bilder_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE clock.bilder_id_seq OWNER TO postgres;

--
-- Name: bilder_id_seq; Type: SEQUENCE OWNED BY; Schema: clock; Owner: postgres
--

ALTER SEQUENCE clock.bilder_id_seq OWNED BY clock.bilder.id;


--
-- Name: bud_id_seq; Type: SEQUENCE; Schema: clock; Owner: postgres
--

CREATE SEQUENCE clock.bud_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE clock.bud_id_seq OWNER TO postgres;

--
-- Name: bud_id_seq; Type: SEQUENCE OWNED BY; Schema: clock; Owner: postgres
--

ALTER SEQUENCE clock.bud_id_seq OWNED BY clock.bud.id;


--
-- Name: email_id_seq; Type: SEQUENCE; Schema: clock; Owner: postgres
--

CREATE SEQUENCE clock.email_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE clock.email_id_seq OWNER TO postgres;

--
-- Name: email_id_seq; Type: SEQUENCE OWNED BY; Schema: clock; Owner: postgres
--

ALTER SEQUENCE clock.email_id_seq OWNED BY clock.email.id;


--
-- Name: klockor_id_seq; Type: SEQUENCE; Schema: clock; Owner: postgres
--

CREATE SEQUENCE clock.klockor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE clock.klockor_id_seq OWNER TO postgres;

--
-- Name: klockor_id_seq; Type: SEQUENCE OWNED BY; Schema: clock; Owner: postgres
--

ALTER SEQUENCE clock.klockor_id_seq OWNED BY clock.klockor.id;


--
-- Name: kortfattad_auktionsinfo; Type: VIEW; Schema: clock; Owner: postgres
--

CREATE VIEW clock.kortfattad_auktionsinfo AS
 SELECT id AS auktionsnummer,
    start_datum,
    slut_datum,
    "utgångspris",
    reservationspris
   FROM clock.auktion
  ORDER BY slut_datum;


ALTER VIEW clock.kortfattad_auktionsinfo OWNER TO postgres;

--
-- Name: meddelanden; Type: TABLE; Schema: clock; Owner: postgres
--

CREATE TABLE clock.meddelanden (
    id integer NOT NULL,
    "från_konto" integer,
    till_konto integer,
    text character varying(128),
    skickat_tid timestamp without time zone
);


ALTER TABLE clock.meddelanden OWNER TO postgres;

--
-- Name: meddelanden_id_seq; Type: SEQUENCE; Schema: clock; Owner: postgres
--

CREATE SEQUENCE clock.meddelanden_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE clock.meddelanden_id_seq OWNER TO postgres;

--
-- Name: meddelanden_id_seq; Type: SEQUENCE OWNED BY; Schema: clock; Owner: postgres
--

ALTER SEQUENCE clock.meddelanden_id_seq OWNED BY clock.meddelanden.id;


--
-- Name: reservpris_ej_pausad; Type: VIEW; Schema: clock; Owner: postgres
--

CREATE VIEW clock.reservpris_ej_pausad AS
 SELECT id,
    start_datum,
    "utgångspris",
    slut_datum,
    "säljare_id",
    klocka_id,
    reservationspris,
    pausad,
    betalningsstatus
   FROM clock.auktion
  WHERE ((reservationspris IS NOT NULL) AND (pausad IS FALSE));


ALTER VIEW clock.reservpris_ej_pausad OWNER TO postgres;

--
-- Name: vinnare_av_auktion; Type: VIEW; Schema: clock; Owner: postgres
--

CREATE VIEW clock.vinnare_av_auktion AS
SELECT
    NULL::integer AS auktions_id,
    NULL::character varying(32) AS "märke",
    NULL::character varying(32) AS modell,
    NULL::integer AS "högsta_bud",
    NULL::character varying(65) AS vinnare;


ALTER VIEW clock.vinnare_av_auktion OWNER TO postgres;

--
-- Name: vinst_eller_högsta_bud; Type: VIEW; Schema: clock; Owner: postgres
--

CREATE VIEW clock."vinst_eller_högsta_bud" AS
 SELECT auktion.id,
    k."märke",
    k.modell,
    bud.budgivare_id,
    konto."användarnamn" AS vinnare,
    bud.bud_i_kr AS vinnande_bud,
    auktion.slut_datum
   FROM (((clock.auktion
     JOIN clock.klockor k ON ((k.id = auktion.klocka_id)))
     JOIN clock.bud bud ON ((auktion.id = bud.auktion_id)))
     JOIN clock.konto ON ((bud.budgivare_id = konto.id)))
  WHERE (bud.bud_i_kr = ( SELECT max(bud_1.bud_i_kr) AS max
           FROM clock.bud bud_1
          WHERE (bud_1.auktion_id = auktion.id)));


ALTER VIEW clock."vinst_eller_högsta_bud" OWNER TO postgres;

--
-- Name: adresser id; Type: DEFAULT; Schema: clock; Owner: postgres
--

ALTER TABLE ONLY clock.adresser ALTER COLUMN id SET DEFAULT nextval('clock.adresser_id_seq'::regclass);


--
-- Name: auktion id; Type: DEFAULT; Schema: clock; Owner: postgres
--

ALTER TABLE ONLY clock.auktion ALTER COLUMN id SET DEFAULT nextval('clock.auktion_id_seq'::regclass);


--
-- Name: bilder id; Type: DEFAULT; Schema: clock; Owner: postgres
--

ALTER TABLE ONLY clock.bilder ALTER COLUMN id SET DEFAULT nextval('clock.bilder_id_seq'::regclass);


--
-- Name: bud id; Type: DEFAULT; Schema: clock; Owner: postgres
--

ALTER TABLE ONLY clock.bud ALTER COLUMN id SET DEFAULT nextval('clock.bud_id_seq'::regclass);


--
-- Name: email id; Type: DEFAULT; Schema: clock; Owner: postgres
--

ALTER TABLE ONLY clock.email ALTER COLUMN id SET DEFAULT nextval('clock.email_id_seq'::regclass);


--
-- Name: klockor id; Type: DEFAULT; Schema: clock; Owner: postgres
--

ALTER TABLE ONLY clock.klockor ALTER COLUMN id SET DEFAULT nextval('clock.klockor_id_seq'::regclass);


--
-- Name: meddelanden id; Type: DEFAULT; Schema: clock; Owner: postgres
--

ALTER TABLE ONLY clock.meddelanden ALTER COLUMN id SET DEFAULT nextval('clock.meddelanden_id_seq'::regclass);


--
-- Data for Name: adresser; Type: TABLE DATA; Schema: clock; Owner: postgres
--

INSERT INTO clock.adresser (id, gatunamn, gatunummer, ort, postnummer, land) VALUES (1, 'Musikalvägen', 34, 'Skogås', 14264, 'Sverige');
INSERT INTO clock.adresser (id, gatunamn, gatunummer, ort, postnummer, land) VALUES (2, 'Duettvägen', 2, 'Huddinge', 14145, 'Sverige');
INSERT INTO clock.adresser (id, gatunamn, gatunummer, ort, postnummer, land) VALUES (3, 'Sanktgatan', 5, 'hudiksvall', 17945, 'Sverige');
INSERT INTO clock.adresser (id, gatunamn, gatunummer, ort, postnummer, land) VALUES (4, 'Vita huset', 1, 'Washington DC', 11111, 'USA');
INSERT INTO clock.adresser (id, gatunamn, gatunummer, ort, postnummer, land) VALUES (7, 'Blåklintsvägen ', 7, 'Huddinge', 14261, 'Sverige');
INSERT INTO clock.adresser (id, gatunamn, gatunummer, ort, postnummer, land) VALUES (8, 'blåklinstvägen ', 5, 'Huddinge', 14043, 'Sverige');
INSERT INTO clock.adresser (id, gatunamn, gatunummer, ort, postnummer, land) VALUES (6, 'Sleipnervägen', 3, 'Järpen', 11345, 'Sverige');
INSERT INTO clock.adresser (id, gatunamn, gatunummer, ort, postnummer, land) VALUES (5, 'Sanktgatan ', 3, 'Jokkmokk', 11754, 'Sverige');


--
-- Data for Name: auktion; Type: TABLE DATA; Schema: clock; Owner: postgres
--

INSERT INTO clock.auktion (id, start_datum, "utgångspris", slut_datum, "säljare_id", klocka_id, reservationspris, pausad, betalningsstatus) VALUES (8, '2024-10-15', 150, '2024-10-31', 3, 8, NULL, false, 'ej betald');
INSERT INTO clock.auktion (id, start_datum, "utgångspris", slut_datum, "säljare_id", klocka_id, reservationspris, pausad, betalningsstatus) VALUES (6, '2024-09-11', 300, '2024-09-25', 1, 6, NULL, false, 'betald');
INSERT INTO clock.auktion (id, start_datum, "utgångspris", slut_datum, "säljare_id", klocka_id, reservationspris, pausad, betalningsstatus) VALUES (9, '2024-10-01', 10, '2024-11-01', 3, 9, NULL, false, 'ej betald');
INSERT INTO clock.auktion (id, start_datum, "utgångspris", slut_datum, "säljare_id", klocka_id, reservationspris, pausad, betalningsstatus) VALUES (3, '2024-10-03', 150, '2024-12-24', 1, 4, 20000, false, 'ej betald');
INSERT INTO clock.auktion (id, start_datum, "utgångspris", slut_datum, "säljare_id", klocka_id, reservationspris, pausad, betalningsstatus) VALUES (7, '2024-07-11', 300, '2024-07-31', 2, 7, 12000, false, 'betald');
INSERT INTO clock.auktion (id, start_datum, "utgångspris", slut_datum, "säljare_id", klocka_id, reservationspris, pausad, betalningsstatus) VALUES (1, '2024-10-10', 300, '2024-11-19', 2, 3, 14000, true, 'ej betald');
INSERT INTO clock.auktion (id, start_datum, "utgångspris", slut_datum, "säljare_id", klocka_id, reservationspris, pausad, betalningsstatus) VALUES (4, '2024-10-10', 150, '2024-12-26', 1, 1, NULL, false, 'ej betald');
INSERT INTO clock.auktion (id, start_datum, "utgångspris", slut_datum, "säljare_id", klocka_id, reservationspris, pausad, betalningsstatus) VALUES (5, '2024-09-18', 200, '2024-09-23', 1, 5, 17000, false, 'väntar på betalning');
INSERT INTO clock.auktion (id, start_datum, "utgångspris", slut_datum, "säljare_id", klocka_id, reservationspris, pausad, betalningsstatus) VALUES (2, '2024-10-01', 200, '2024-12-11', 2, 2, NULL, false, 'ej betald');


--
-- Data for Name: bilder; Type: TABLE DATA; Schema: clock; Owner: postgres
--

INSERT INTO clock.bilder (id, klock_id, bild) VALUES (13, 6, 'bild');
INSERT INTO clock.bilder (id, klock_id, bild) VALUES (8, 1, 'bild');
INSERT INTO clock.bilder (id, klock_id, bild) VALUES (12, 2, 'bild');
INSERT INTO clock.bilder (id, klock_id, bild) VALUES (11, 3, 'bild');
INSERT INTO clock.bilder (id, klock_id, bild) VALUES (9, 5, 'bild');
INSERT INTO clock.bilder (id, klock_id, bild) VALUES (10, 4, 'bild');
INSERT INTO clock.bilder (id, klock_id, bild) VALUES (1, 7, 'bild');
INSERT INTO clock.bilder (id, klock_id, bild) VALUES (3, 8, 'bild');
INSERT INTO clock.bilder (id, klock_id, bild) VALUES (2, 9, 'bild');
INSERT INTO clock.bilder (id, klock_id, bild) VALUES (5, 2, 'bild');
INSERT INTO clock.bilder (id, klock_id, bild) VALUES (7, 2, 'bild');
INSERT INTO clock.bilder (id, klock_id, bild) VALUES (4, 1, 'bild');
INSERT INTO clock.bilder (id, klock_id, bild) VALUES (6, 1, 'bild');
INSERT INTO clock.bilder (id, klock_id, bild) VALUES (14, 2, 'bild');
INSERT INTO clock.bilder (id, klock_id, bild) VALUES (15, 3, 'bild');
INSERT INTO clock.bilder (id, klock_id, bild) VALUES (16, 2, 'bild');
INSERT INTO clock.bilder (id, klock_id, bild) VALUES (17, 4, 'bild');
INSERT INTO clock.bilder (id, klock_id, bild) VALUES (18, 1, 'bild');
INSERT INTO clock.bilder (id, klock_id, bild) VALUES (19, 1, 'bild');
INSERT INTO clock.bilder (id, klock_id, bild) VALUES (20, 6, 'bild');
INSERT INTO clock.bilder (id, klock_id, bild) VALUES (21, 7, 'bild');
INSERT INTO clock.bilder (id, klock_id, bild) VALUES (22, 8, 'bild');


--
-- Data for Name: bud; Type: TABLE DATA; Schema: clock; Owner: postgres
--

INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (11, 3, 6, 987, '2024-10-01 15:17:10');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (3, 3, 4, 565, '2024-10-01 04:09:46');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (9, 3, 5, 678, '2024-10-01 12:16:28');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (13, 4, 5, 1400, '2024-10-01 11:13:44');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (10, 3, 4, 768, '2024-10-01 10:17:07');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (2, 3, 4, 450, '2024-09-30 12:09:38');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (8, 2, 3, 971, '2024-09-30 12:18:37');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (14, 4, 6, 2000, '2024-10-05 11:13:48');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (25, 7, 2, 900, '2024-07-09 09:11:55');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (22, 7, 1, 400, '2024-07-07 09:11:38');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (24, 7, 1, 700, '2024-07-07 09:11:48');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (23, 7, 2, 500, '2024-07-08 09:11:43');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (26, 7, 3, 1100, '2024-07-24 09:13:04');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (27, 7, 5, 1600, '2024-07-28 09:13:16');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (28, 7, 1, 1900, '2024-07-30 09:13:33');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (29, 8, 1, 300, '2024-10-04 09:20:42');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (32, 8, 1, 800, '2024-10-09 09:20:56');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (33, 8, 4, 900, '2024-10-09 09:21:00');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (34, 8, 5, 1200, '2024-10-10 09:21:03');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (35, 8, 1, 1900, '2024-10-14 09:21:07');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (36, 9, 2, 400, '2024-10-07 12:36:14');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (37, 9, 3, 600, '2024-10-07 16:36:17');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (38, 9, 4, 1200, '2024-10-07 21:36:21');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (39, 9, 5, 2499, '2024-10-08 12:36:26');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (40, 9, 2, 2500, '2024-10-10 12:36:30');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (41, 9, 3, 3000, '2024-10-13 12:36:34');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (42, 9, 4, 4500, '2024-10-14 12:36:38');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (43, 9, 5, 4800, '2024-10-27 12:36:45');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (6, 1, 5, 595, '2024-10-13 15:10:30');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (5, 1, 5, 453, '2024-10-11 13:10:24');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (46, 1, 4, 4000, '2024-10-29 12:40:42');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (47, 1, 5, 12000, '2024-10-30 12:40:48');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (48, 4, 5, 3000, '2024-10-13 12:43:11');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (50, 4, 5, 6000, '2024-10-14 12:43:20');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (52, 4, 5, 6400, '2024-10-17 12:43:31');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (53, 4, 6, 11000, '2024-10-23 12:43:35');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (54, 4, 5, 11500, '2024-10-26 12:43:39');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (55, 4, 6, 12500, '2024-10-26 12:43:43');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (56, 4, 5, 13000, '2024-10-28 12:43:48');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (57, 4, 6, 15000, '2024-10-31 12:43:52');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (45, 1, 5, 2300, '2024-10-20 12:40:38');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (44, 1, 4, 1100, '2024-10-19 12:39:40');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (7, 1, 3, 911, '2024-10-14 12:15:34');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (1, 1, 4, 683, '2024-10-13 17:09:32');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (4, 2, 4, 1001, '2024-09-30 14:09:48');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (12, 3, 6, 1002, '2024-10-04 10:17:11');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (49, 4, 6, 5400, '2024-10-14 12:43:16');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (51, 4, 6, 5000, '2024-10-13 12:43:24');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (30, 8, 4, 600, '2024-10-06 09:20:45');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (31, 8, 5, 400, '2024-10-04 09:20:43');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (20, 6, 5, 4100, '2024-09-14 11:16:28');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (21, 6, 4, 4999, '2024-09-19 11:16:29');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (16, 5, 6, 2000, '2024-09-19 12:15:20');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (18, 5, 6, 5000, '2024-07-20 13:15:23');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (17, 5, 3, 3000, '2024-09-19 11:15:22');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (19, 6, 6, 3737, '2024-07-20 12:16:26');
INSERT INTO clock.bud (id, auktion_id, budgivare_id, bud_i_kr, bud_datum) VALUES (15, 5, 5, 1000, '2024-07-21 14:15:17');


--
-- Data for Name: email; Type: TABLE DATA; Schema: clock; Owner: postgres
--

INSERT INTO clock.email (id, mail, personuppgift_id) VALUES (1, '123mail@hotmail.com', 1);
INSERT INTO clock.email (id, mail, personuppgift_id) VALUES (2, 'hejhallå@hotmail.se', 2);
INSERT INTO clock.email (id, mail, personuppgift_id) VALUES (7, 'strömbrytare@gmail.com', 7);
INSERT INTO clock.email (id, mail, personuppgift_id) VALUES (6, 'stol.bord@hotmail.se', 6);
INSERT INTO clock.email (id, mail, personuppgift_id) VALUES (5, 'lampa@gmail.com', 5);
INSERT INTO clock.email (id, mail, personuppgift_id) VALUES (8, 'snusdosa@gmail.com', 8);
INSERT INTO clock.email (id, mail, personuppgift_id) VALUES (3, 'Nymailadressförmig@gmail.com', 3);
INSERT INTO clock.email (id, mail, personuppgift_id) VALUES (4, 'POTUS@whitehouse.gov', 4);


--
-- Data for Name: klockor; Type: TABLE DATA; Schema: clock; Owner: postgres
--

INSERT INTO clock.klockor (id, "märke", modell, diameter, urverk, armband, "färg", beskrivning) VALUES (3, 'Daniel Wellington', 'Iconic', 40, 'automatisk', 'metall', 'silver', ' Djärv design, lite repig');
INSERT INTO clock.klockor (id, "märke", modell, diameter, urverk, armband, "färg", beskrivning) VALUES (9, 'Seiko', 'Sport', 38, 'automatisk', 'metall', 'svart', 'Elegant dressklocka med ren urtavla, småskador');
INSERT INTO clock.klockor (id, "märke", modell, diameter, urverk, armband, "färg", beskrivning) VALUES (2, 'Certina', 'Chronometer', 38, 'automatisk', 'metall', 'silver', 'Pilotklocka med avancerade flygfunktioner och ikonisk rund räknesticka');
INSERT INTO clock.klockor (id, "märke", modell, diameter, urverk, armband, "färg", beskrivning) VALUES (7, 'Gant', 'Park Hill', 42, 'mekanisk', 'läder', 'röd', 'Känd för att vara "Moonwatch", med kronograf och robust design.');
INSERT INTO clock.klockor (id, "märke", modell, diameter, urverk, armband, "färg", beskrivning) VALUES (8, 'Tissot', 'Pr100', 38, 'automatisk', 'metall', 'orange', 'Tidlös klocka med rektangulär boett och klassisk romersk numrering.');
INSERT INTO clock.klockor (id, "märke", modell, diameter, urverk, armband, "färg", beskrivning) VALUES (5, 'Omega', 'Seamaster', 40, 'automatisk', 'metall', 'svart', 'Ikonisk design med åttakantig boett');
INSERT INTO clock.klockor (id, "märke", modell, diameter, urverk, armband, "färg", beskrivning) VALUES (4, 'Certina', 'Priska', 40, 'automatisk', 'läder', 'blå', 'Klassisk dykklocka i läderarmband');
INSERT INTO clock.klockor (id, "märke", modell, diameter, urverk, armband, "färg", beskrivning) VALUES (1, 'Omega', 'Seamaster', 42, 'automatisk', 'metall', 'svart', ' Sportig klocka med elegant urtavla och tachymeter för racingentusiaster');
INSERT INTO clock.klockor (id, "märke", modell, diameter, urverk, armband, "färg", beskrivning) VALUES (6, 'Certina', 'Priska', 40, 'mekanisk', 'läder', 'gul', 'Lyxig och fin klocka med LOTR tema');


--
-- Data for Name: konto; Type: TABLE DATA; Schema: clock; Owner: postgres
--

INSERT INTO clock.konto (id, "användarnamn", profilbild, admin, reg_datum, "lösenord", mail_id) VALUES (1, 'Melkor', 'https://www.google.se/imgres?q=profilbilder&imgurl=https%3A%2F%2Fimage.spreadshirtmedia.net%2Fimage-server%2Fv1%2Fproducts%2FT1459A839PA4459PT28D192476768W8836H10000%2Fviews%2F1%2Cwidth%3D1200%2Cheight%3D630%2CappearanceId%3D839%2CbackgroundColor%3DF2F2F2%2Fklon-av-profilbild-klistermaerke.jpg&imgrefurl=https%3A%2F%2Fwww.spreadshirt.se%2Fshop%2Fdesign%2Fklon%2Bav%2Bprofilbild%2Bklistermaerke-D60b390ad9bee310dd5bf1916%3Fsellable%3DyreryjjnqlSXqXJj0Vwg-1459-215&docid=fBGUZmifqwkq4M&tbnid=nXVy6Hoz0uRGSM&vet=12ahUKEwi118TNlPSIAxXvKRAIHSolAp8QM3oECFIQAA..i&w=1200&h=630&hcb=2&ved=2ahUKEwi118TNlPSIAx', false, '2024-07-31', 'SlutaglömDITTlösenord123', 1);
INSERT INTO clock.konto (id, "användarnamn", profilbild, admin, reg_datum, "lösenord", mail_id) VALUES (6, 'Durin', 'https://www.google.se/imgres?q=profilbilder&imgurl=https%3A%2F%2Fimage.spreadshirtmedia.net%2Fimage-server%2Fv1%2Fproducts%2FT1459A839PA4459PT28D192476768W8836H10000%2Fviews%2F1%2Cwidth%3D1200%2Cheight%3D630%2CappearanceId%3D839%2CbackgroundColor%3DF2F2F2%2Fklon-av-profilbild-klistermaerke.jpg&imgrefurl=https%3A%2F%2Fwww.spreadshirt.se%2Fshop%2Fdesign%2Fklon%2Bav%2Bprofilbild%2Bklistermaerke-D60b390ad9bee310dd5bf1916%3Fsellable%3DyreryjjnqlSXqXJj0Vwg-1459-215&docid=fBGUZmifqwkq4M&tbnid=nXVy6Hoz0uRGSM&vet=12ahUKEwi118TNlPSIAxXvKRAIHSolAp8QM3oECFIQAA..i&w=1200&h=630&hcb=2&ved=2ahUKEwi118TNlPSIAx', false, '2024-07-30', 'dfgdf5', 6);
INSERT INTO clock.konto (id, "användarnamn", profilbild, admin, reg_datum, "lösenord", mail_id) VALUES (5, 'Elendil', 'https://www.google.se/imgres?q=profilbilder&imgurl=https%3A%2F%2Fwww.nystartad.se%2Fwp-content%2Fuploads%2F2017%2F02%2Fprofilbild-linkedin-dino.png&imgrefurl=https%3A%2F%2Fwww.nystartad.se%2Ftips-for-en-bra-linkedinprofil%2Fprofilbild-linkedin-dino%2F&docid=RpSPxmtfNGqXZM&tbnid=Iau93Kgs9iLDeM&vet=12ahUKEwi118TNlPSIAxXvKRAIHSolAp8QM3oECCgQAA..i&w=464&h=460&hcb=2&ved=2ahUKEwi118TNlPSIAxXvKRAIHSolAp8QM3oECCgQAA', false, '2024-08-02', '"456fbdf4"', 5);
INSERT INTO clock.konto (id, "användarnamn", profilbild, admin, reg_datum, "lösenord", mail_id) VALUES (2, 'Skywalker', 'https://www.google.se/imgres?q=profilbilder&imgurl=https%3A%2F%2Fwww.nystartad.se%2Fwp-content%2Fuploads%2F2017%2F02%2Fprofilbild-linkedin-dino.png&imgrefurl=https%3A%2F%2Fwww.nystartad.se%2Ftips-for-en-bra-linkedinprofil%2Fprofilbild-linkedin-dino%2F&docid=RpSPxmtfNGqXZM&tbnid=Iau93Kgs9iLDeM&vet=12ahUKEwi118TNlPSIAxXvKRAIHSolAp8QM3oECCgQAA..i&w=464&h=460&hcb=2&ved=2ahUKEwi118TNlPSIAxXvKRAIHSolAp8QM3oECCgQAA', false, '2024-08-01', 'dfsd345', 2);
INSERT INTO clock.konto (id, "användarnamn", profilbild, admin, reg_datum, "lösenord", mail_id) VALUES (4, 'Angmar', 'https://www.google.se/imgres?q=profilbilder&imgurl=https%3A%2F%2Fmedia.decentralized-content.com%2F-%2Frs%3Afit%3A1920%3A1920%2FaHR0cHM6Ly9tYWdpYy5kZWNlbnRyYWxpemVkLWNvbnRlbnQuY29tL2lwZnMvYmFma3JlaWZ6aDN1aHh2cGxxYnB3cHh4b2Q0aXNxYnA2Mm83dml4dHBmY2ZrYjJoM2FiajJidXdleHE&imgrefurl=https%3A%2F%2Fzora.co%2Fcollect%2Fzora%3A0x3666f60d7dd7a26f167599496fbeb69e1a4ed4a7%2F1&docid=fld7tjHKKykeAM&tbnid=1yeoRBEtXz8wcM&vet=12ahUKEwi118TNlPSIAxXvKRAIHSolAp8QM3oFCIQBEAA..i&w=1024&h=1024&hcb=2&ved=2ahUKEwi118TNlPSIAxXvKRAIHSolAp8QM3oFCIQBEAA', false, '2024-08-14', 'sfdgj63', 4);
INSERT INTO clock.konto (id, "användarnamn", profilbild, admin, reg_datum, "lösenord", mail_id) VALUES (3, 'Wraith', 'https://www.google.se/imgres?q=profilbilder&imgurl=https%3A%2F%2Fwallpapers.com%2Fimages%2Fhd%2Fcool-tiktok-profile-pictures-fiv6ulz4qdggujwo.jpg&imgrefurl=https%3A%2F%2Fse.wallpapers.com%2Fcoola-tiktok-profilbilder&docid=YJlY02-xDehbEM&tbnid=UiG5YrIGZac94M&vet=12ahUKEwi118TNlPSIAxXvKRAIHSolAp8QM3oECG0QAA..i&w=900&h=900&hcb=2&ved=2ahUKEwi118TNlPSIAxXvKRAIHSolAp8QM3oECG0QAA', false, '2024-08-03', 'sgae345', 3);
INSERT INTO clock.konto (id, "användarnamn", profilbild, admin, reg_datum, "lösenord", mail_id) VALUES (7, 'Angerboda', 'https://www.google.se/imgres?q=profilbilder&imgurl=https%3A%2F%2Fimage.spreadshirtmedia.net%2Fimage-server%2Fv1%2Fproducts%2FT1459A839PA4459PT28D192476768W8836H10000%2Fviews%2F1%2Cwidth%3D1200%2Cheight%3D630%2CappearanceId%3D839%2CbackgroundColor%3DF2F2F2%2Fklon-av-profilbild-klistermaerke.jpg&imgrefurl=https%3A%2F%2Fwww.spreadshirt.se%2Fshop%2Fdesign%2Fklon%2Bav%2Bprofilbild%2Bklistermaerke-D60b390ad9bee310dd5bf1916%3Fsellable%3DyreryjjnqlSXqXJj0Vwg-1459-215&docid=fBGUZmifqwkq4M&tbnid=nXVy6Hoz0uRGSM&vet=12ahUKEwi118TNlPSIAxXvKRAIHSolAp8QM3oECFIQAA..i&w=1200&h=630&hcb=2&ved=2ahUKEwi118TNlPSIAx', true, '2024-07-09', 'dfgd4', 7);
INSERT INTO clock.konto (id, "användarnamn", profilbild, admin, reg_datum, "lösenord", mail_id) VALUES (8, 'Noclip', 'https://www.google.se/imgres?q=profilbilder&imgurl=https%3A%2F%2Fimage.spreadshirtmedia.net%2Fimage-server%2Fv1%2Fproducts%2FT1459A839PA4459PT28D192476768W8836H10000%2Fviews%2F1%2Cwidth%3D1200%2Cheight%3D630%2CappearanceId%3D839%2CbackgroundColor%3DF2F2F2%2Fklon-av-profilbild-klistermaerke.jpg&imgrefurl=https%3A%2F%2Fwww.spreadshirt.se%2Fshop%2Fdesign%2Fklon%2Bav%2Bprofilbild%2Bklistermaerke-D60b390ad9bee310dd5bf1916%3Fsellable%3DyreryjjnqlSXqXJj0Vwg-1459-215&docid=fBGUZmifqwkq4M&tbnid=nXVy6Hoz0uRGSM&vet=12ahUKEwi118TNlPSIAxXvKRAIHSolAp8QM3oECFIQAA..i&w=1200&h=630&hcb=2&ved=2ahUKEwi118TNlPSIAx', true, '2024-07-09', 'sdfa34', 8);


--
-- Data for Name: meddelanden; Type: TABLE DATA; Schema: clock; Owner: postgres
--

INSERT INTO clock.meddelanden (id, "från_konto", till_konto, text, skickat_tid) VALUES (1, 1, 3, 'Hejhej', '2024-10-04 12:56:07');
INSERT INTO clock.meddelanden (id, "från_konto", till_konto, text, skickat_tid) VALUES (3, 1, 5, 'Ser du mitt bud?', '2024-10-04 12:56:12');
INSERT INTO clock.meddelanden (id, "från_konto", till_konto, text, skickat_tid) VALUES (2, 3, 1, 'Hej! hur mår du?', '2024-10-04 13:56:10');
INSERT INTO clock.meddelanden (id, "från_konto", till_konto, text, skickat_tid) VALUES (4, 5, 1, 'Ja! :)', '2024-10-04 12:59:15');
INSERT INTO clock.meddelanden (id, "från_konto", till_konto, text, skickat_tid) VALUES (5, 1, 3, 'Bra :)', '2024-10-04 15:48:19');
INSERT INTO clock.meddelanden (id, "från_konto", till_konto, text, skickat_tid) VALUES (8, 8, 1, 'Ditt lösenord är återställt, skapa ett nytt OMEDELBART', '2024-10-09 08:11:17.827987');
INSERT INTO clock.meddelanden (id, "från_konto", till_konto, text, skickat_tid) VALUES (9, 1, 8, 'Tack för snabb hjälp!', '2024-10-09 08:11:57.851226');


--
-- Data for Name: personuppgifter; Type: TABLE DATA; Schema: clock; Owner: postgres
--

INSERT INTO clock.personuppgifter (id, "förnamn", efternamn, personnummer) VALUES (4, 'POTUS', 'Eriksson', '81-03-30');
INSERT INTO clock.personuppgifter (id, "förnamn", efternamn, personnummer) VALUES (5, 'Sebastian', 'Östlid', '80-09-15');
INSERT INTO clock.personuppgifter (id, "förnamn", efternamn, personnummer) VALUES (6, 'Klara', 'Andersson', '79-02-19');
INSERT INTO clock.personuppgifter (id, "förnamn", efternamn, personnummer) VALUES (3, 'Johan', 'Johansson', '94-08-06');
INSERT INTO clock.personuppgifter (id, "förnamn", efternamn, personnummer) VALUES (2, 'Adam', 'Svensson', '91-02-24');
INSERT INTO clock.personuppgifter (id, "förnamn", efternamn, personnummer) VALUES (1, 'Axel ', 'Eriksson', '96-05-18');
INSERT INTO clock.personuppgifter (id, "förnamn", efternamn, personnummer) VALUES (7, 'Emelie', 'Gustafsson', '95-01-25');
INSERT INTO clock.personuppgifter (id, "förnamn", efternamn, personnummer) VALUES (8, 'Pia', 'Andersson', '94-01-02');


--
-- Data for Name: telefonnummer; Type: TABLE DATA; Schema: clock; Owner: postgres
--

INSERT INTO clock.telefonnummer (id, telefonnummer, personuppgifter_id) VALUES (1, '086090646', 1);
INSERT INTO clock.telefonnummer (id, telefonnummer, personuppgifter_id) VALUES (2, '084568356', 2);
INSERT INTO clock.telefonnummer (id, telefonnummer, personuppgifter_id) VALUES (3, '081234543', 3);
INSERT INTO clock.telefonnummer (id, telefonnummer, personuppgifter_id) VALUES (4, '087675467', 4);
INSERT INTO clock.telefonnummer (id, telefonnummer, personuppgifter_id) VALUES (5, '0702041754', 5);
INSERT INTO clock.telefonnummer (id, telefonnummer, personuppgifter_id) VALUES (6, '0734561756', 6);
INSERT INTO clock.telefonnummer (id, telefonnummer, personuppgifter_id) VALUES (7, '0735677654', 7);
INSERT INTO clock.telefonnummer (id, telefonnummer, personuppgifter_id) VALUES (8, '0702041655', 8);


--
-- Name: adresser_id_seq; Type: SEQUENCE SET; Schema: clock; Owner: postgres
--

SELECT pg_catalog.setval('clock.adresser_id_seq', 10, true);


--
-- Name: auktion_id_seq; Type: SEQUENCE SET; Schema: clock; Owner: postgres
--

SELECT pg_catalog.setval('clock.auktion_id_seq', 9, true);


--
-- Name: bilder_id_seq; Type: SEQUENCE SET; Schema: clock; Owner: postgres
--

SELECT pg_catalog.setval('clock.bilder_id_seq', 22, true);


--
-- Name: bud_id_seq; Type: SEQUENCE SET; Schema: clock; Owner: postgres
--

SELECT pg_catalog.setval('clock.bud_id_seq', 57, true);


--
-- Name: email_id_seq; Type: SEQUENCE SET; Schema: clock; Owner: postgres
--

SELECT pg_catalog.setval('clock.email_id_seq', 10, true);


--
-- Name: klockor_id_seq; Type: SEQUENCE SET; Schema: clock; Owner: postgres
--

SELECT pg_catalog.setval('clock.klockor_id_seq', 9, true);


--
-- Name: meddelanden_id_seq; Type: SEQUENCE SET; Schema: clock; Owner: postgres
--

SELECT pg_catalog.setval('clock.meddelanden_id_seq', 14, true);


--
-- Name: adresser adresser_pk; Type: CONSTRAINT; Schema: clock; Owner: postgres
--

ALTER TABLE ONLY clock.adresser
    ADD CONSTRAINT adresser_pk PRIMARY KEY (id);


--
-- Name: personuppgifter användare_pk; Type: CONSTRAINT; Schema: clock; Owner: postgres
--

ALTER TABLE ONLY clock.personuppgifter
    ADD CONSTRAINT "användare_pk" PRIMARY KEY (id);


--
-- Name: auktion auktion_pk; Type: CONSTRAINT; Schema: clock; Owner: postgres
--

ALTER TABLE ONLY clock.auktion
    ADD CONSTRAINT auktion_pk PRIMARY KEY (id);


--
-- Name: bilder bilder_pk; Type: CONSTRAINT; Schema: clock; Owner: postgres
--

ALTER TABLE ONLY clock.bilder
    ADD CONSTRAINT bilder_pk PRIMARY KEY (id);


--
-- Name: bud bud_pk; Type: CONSTRAINT; Schema: clock; Owner: postgres
--

ALTER TABLE ONLY clock.bud
    ADD CONSTRAINT bud_pk PRIMARY KEY (id);


--
-- Name: email email_pk; Type: CONSTRAINT; Schema: clock; Owner: postgres
--

ALTER TABLE ONLY clock.email
    ADD CONSTRAINT email_pk PRIMARY KEY (id);


--
-- Name: klockor klockor_pk; Type: CONSTRAINT; Schema: clock; Owner: postgres
--

ALTER TABLE ONLY clock.klockor
    ADD CONSTRAINT klockor_pk PRIMARY KEY (id);


--
-- Name: konto konto_pk; Type: CONSTRAINT; Schema: clock; Owner: postgres
--

ALTER TABLE ONLY clock.konto
    ADD CONSTRAINT konto_pk PRIMARY KEY (id);


--
-- Name: meddelanden meddelanden_pk; Type: CONSTRAINT; Schema: clock; Owner: postgres
--

ALTER TABLE ONLY clock.meddelanden
    ADD CONSTRAINT meddelanden_pk PRIMARY KEY (id);


--
-- Name: telefonnummer telefonnummer_pk; Type: CONSTRAINT; Schema: clock; Owner: postgres
--

ALTER TABLE ONLY clock.telefonnummer
    ADD CONSTRAINT telefonnummer_pk PRIMARY KEY (id);


--
-- Name: vinnare_av_auktion _RETURN; Type: RULE; Schema: clock; Owner: postgres
--

CREATE OR REPLACE VIEW clock.vinnare_av_auktion AS
 SELECT auktion.id AS auktions_id,
    k2."märke",
    k2.modell,
    max(bud.bud_i_kr) AS "högsta_bud",
    budgivare_konto."användarnamn" AS vinnare
   FROM (((clock.auktion
     JOIN clock.bud bud ON ((auktion.id = bud.auktion_id)))
     JOIN clock.konto budgivare_konto ON ((bud.budgivare_id = budgivare_konto.id)))
     JOIN clock.klockor k2 ON ((auktion.klocka_id = k2.id)))
  WHERE (auktion.slut_datum < CURRENT_DATE)
  GROUP BY auktion.id, k2."märke", k2.modell, budgivare_konto."användarnamn"
  ORDER BY auktion.slut_datum DESC;


--
-- Name: adresser adresser_personuppgifter_id_fk; Type: FK CONSTRAINT; Schema: clock; Owner: postgres
--

ALTER TABLE ONLY clock.adresser
    ADD CONSTRAINT adresser_personuppgifter_id_fk FOREIGN KEY (id) REFERENCES clock.personuppgifter(id);


--
-- Name: auktion auktion_klockor_id_fk; Type: FK CONSTRAINT; Schema: clock; Owner: postgres
--

ALTER TABLE ONLY clock.auktion
    ADD CONSTRAINT auktion_klockor_id_fk FOREIGN KEY (klocka_id) REFERENCES clock.klockor(id);


--
-- Name: auktion auktion_konto_id_fk; Type: FK CONSTRAINT; Schema: clock; Owner: postgres
--

ALTER TABLE ONLY clock.auktion
    ADD CONSTRAINT auktion_konto_id_fk FOREIGN KEY ("säljare_id") REFERENCES clock.konto(id);


--
-- Name: bilder bilder_klockor_id_fk; Type: FK CONSTRAINT; Schema: clock; Owner: postgres
--

ALTER TABLE ONLY clock.bilder
    ADD CONSTRAINT bilder_klockor_id_fk FOREIGN KEY (klock_id) REFERENCES clock.klockor(id);


--
-- Name: bud bud_auktion_id_fk; Type: FK CONSTRAINT; Schema: clock; Owner: postgres
--

ALTER TABLE ONLY clock.bud
    ADD CONSTRAINT bud_auktion_id_fk FOREIGN KEY (auktion_id) REFERENCES clock.auktion(id);


--
-- Name: bud bud_konto_id_fk; Type: FK CONSTRAINT; Schema: clock; Owner: postgres
--

ALTER TABLE ONLY clock.bud
    ADD CONSTRAINT bud_konto_id_fk FOREIGN KEY (budgivare_id) REFERENCES clock.konto(id);


--
-- Name: email email_personuppgifter_id_fk; Type: FK CONSTRAINT; Schema: clock; Owner: postgres
--

ALTER TABLE ONLY clock.email
    ADD CONSTRAINT email_personuppgifter_id_fk FOREIGN KEY (personuppgift_id) REFERENCES clock.personuppgifter(id);


--
-- Name: konto konto_email_id_fk; Type: FK CONSTRAINT; Schema: clock; Owner: postgres
--

ALTER TABLE ONLY clock.konto
    ADD CONSTRAINT konto_email_id_fk FOREIGN KEY (mail_id) REFERENCES clock.email(id);


--
-- Name: konto konto_personuppgifter_id_fk; Type: FK CONSTRAINT; Schema: clock; Owner: postgres
--

ALTER TABLE ONLY clock.konto
    ADD CONSTRAINT konto_personuppgifter_id_fk FOREIGN KEY (id) REFERENCES clock.personuppgifter(id);


--
-- Name: meddelanden meddelanden_konto_id_fk; Type: FK CONSTRAINT; Schema: clock; Owner: postgres
--

ALTER TABLE ONLY clock.meddelanden
    ADD CONSTRAINT meddelanden_konto_id_fk FOREIGN KEY ("från_konto") REFERENCES clock.konto(id);


--
-- Name: meddelanden meddelanden_konto_id_fk_2; Type: FK CONSTRAINT; Schema: clock; Owner: postgres
--

ALTER TABLE ONLY clock.meddelanden
    ADD CONSTRAINT meddelanden_konto_id_fk_2 FOREIGN KEY (till_konto) REFERENCES clock.konto(id);


--
-- Name: telefonnummer telefonnummer_personuppgifter_id_fk; Type: FK CONSTRAINT; Schema: clock; Owner: postgres
--

ALTER TABLE ONLY clock.telefonnummer
    ADD CONSTRAINT telefonnummer_personuppgifter_id_fk FOREIGN KEY (personuppgifter_id) REFERENCES clock.personuppgifter(id);


--
-- PostgreSQL database dump complete
--

