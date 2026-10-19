--
-- PostgreSQL database dump
--

\restrict lmhjk702lhC39CUAFaUAwNxfBehDIloYG6ghsxNr39rREjM0Dbpt5uQos4XCd4O

-- Dumped from database version 18.6
-- Dumped by pg_dump version 18.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: liberar_arma_por_fallecimiento(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.liberar_arma_por_fallecimiento() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_id_soldado INT;
BEGIN
    -- Si el estado de salud se actualiza a 'Fallecido'
    IF NEW.estado_salud = 'Fallecido' THEN
        
        -- Buscamos cuál es el ID del soldado dueño de este historial
        SELECT id_soldado INTO v_id_soldado 
        FROM soldado 
        WHERE id_historial = NEW.id_historial;
        
        -- Le quitamos el arma (queda en NULL) pero NO cambiamos el estado del arma
        UPDATE armamento 
        SET id_soldado = NULL 
        WHERE id_soldado = v_id_soldado;
        
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.liberar_arma_por_fallecimiento() OWNER TO postgres;

--
-- Name: verificar_salud_soldado(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.verificar_salud_soldado() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    estado_actual VARCHAR;
BEGIN
    SELECT hm.estado_salud INTO estado_actual
    FROM soldado s
    JOIN historial_medico hm ON s.id_historial = hm.id_historial
    WHERE s.id_soldado = NEW.id_soldado;

    IF estado_actual = 'Baja Medica' THEN
        RAISE EXCEPTION 'AutomatizaciÃ³n: El soldado % estÃ¡ de Baja MÃ©dica y no puede ir a misiones', NEW.id_soldado;
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.verificar_salud_soldado() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: arma_fuego; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.arma_fuego (
    id_arma integer NOT NULL,
    capacidad_cargador integer NOT NULL,
    peso_vacia_kg numeric(6,2) NOT NULL,
    modo_disparo character varying(50) NOT NULL,
    id_calibre integer NOT NULL
);


ALTER TABLE public.arma_fuego OWNER TO postgres;

--
-- Name: armamento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.armamento (
    id_arma integer NOT NULL,
    numero_serie character varying(50) NOT NULL,
    estado_arma character varying(50) NOT NULL,
    id_categoria integer NOT NULL,
    id_soldado integer,
    CONSTRAINT chk_arma_danada_sin_soldado CHECK ((NOT (((estado_arma)::text = 'Da¤ada'::text) AND (id_soldado IS NOT NULL))))
);


ALTER TABLE public.armamento OWNER TO postgres;

--
-- Name: asignacion_mision; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.asignacion_mision (
    id_asignacion integer NOT NULL,
    rol_asignado character varying(100) NOT NULL,
    id_mision integer NOT NULL,
    id_soldado integer NOT NULL
);


ALTER TABLE public.asignacion_mision OWNER TO postgres;

--
-- Name: base_militar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.base_militar (
    id_base integer NOT NULL,
    nombre_base character varying(100) NOT NULL,
    ubicacion character varying(150) NOT NULL
);


ALTER TABLE public.base_militar OWNER TO postgres;

--
-- Name: batallon; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.batallon (
    id_batallon integer NOT NULL,
    nombre_batallon character varying(100) NOT NULL,
    id_base integer NOT NULL
);


ALTER TABLE public.batallon OWNER TO postgres;

--
-- Name: calibre; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.calibre (
    id_calibre integer NOT NULL,
    nombre_calibre character varying(20) NOT NULL,
    tipo_penetracion character varying(50) NOT NULL
);


ALTER TABLE public.calibre OWNER TO postgres;

--
-- Name: categoria_arma; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categoria_arma (
    id_categoria integer NOT NULL,
    nombre_categoria character varying(50) NOT NULL,
    nivel_restriccion character varying(20) NOT NULL
);


ALTER TABLE public.categoria_arma OWNER TO postgres;

--
-- Name: especialidad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.especialidad (
    id_especialidad integer NOT NULL,
    nombre_especialidad character varying(50) NOT NULL,
    descripcion_rol character varying(255) NOT NULL,
    nivel_riesgo character varying(20) NOT NULL,
    bono_salarial numeric(10,2) NOT NULL
);


ALTER TABLE public.especialidad OWNER TO postgres;

--
-- Name: explosivo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.explosivo (
    id_arma integer NOT NULL,
    fecha_caducidad date NOT NULL,
    peso_kg numeric(6,2) NOT NULL
);


ALTER TABLE public.explosivo OWNER TO postgres;

--
-- Name: historial_medico; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.historial_medico (
    id_historial integer NOT NULL,
    tipo_sangre character varying(5) NOT NULL,
    alergias character varying(255),
    estado_salud character varying(255) NOT NULL
);


ALTER TABLE public.historial_medico OWNER TO postgres;

--
-- Name: mision; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mision (
    id_mision integer NOT NULL,
    nombre_mision character varying(100) NOT NULL,
    fecha_inicio date NOT NULL,
    estado_mision character varying(50) NOT NULL
);


ALTER TABLE public.mision OWNER TO postgres;

--
-- Name: municion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.municion (
    id_municion integer NOT NULL,
    cantidad_disponible integer NOT NULL,
    fecha_vencimiento date NOT NULL,
    lote character varying(50) NOT NULL,
    id_calibre integer NOT NULL,
    id_base integer NOT NULL
);


ALTER TABLE public.municion OWNER TO postgres;

--
-- Name: rango; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rango (
    id_rango integer NOT NULL,
    nombre_rango character varying(50) NOT NULL,
    nivel_jerarquico integer NOT NULL,
    sueldo_base numeric(12,2) NOT NULL
);


ALTER TABLE public.rango OWNER TO postgres;

--
-- Name: soldado; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.soldado (
    id_soldado integer NOT NULL,
    nombres_apellidos character varying(150) NOT NULL,
    id_rango integer NOT NULL,
    id_especialidad integer NOT NULL,
    id_batallon integer NOT NULL,
    id_historial integer NOT NULL
);


ALTER TABLE public.soldado OWNER TO postgres;

--
-- Name: vehiculo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vehiculo (
    id_vehiculo integer NOT NULL,
    placa_identificacion character varying(20) NOT NULL,
    tipo_vehiculo character varying(50) NOT NULL,
    id_base integer NOT NULL
);


ALTER TABLE public.vehiculo OWNER TO postgres;

--
-- Data for Name: arma_fuego; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.arma_fuego (id_arma, capacidad_cargador, peso_vacia_kg, modo_disparo, id_calibre) FROM stdin;
1	82	4.27	Rafaga	16
2	9	10.51	Auto	9
3	57	12.01	Semi	29
4	83	7.67	Semi	28
5	16	14.18	Rafaga	2
6	49	3.51	Semi	14
7	47	14.44	Auto	18
8	54	4.90	Rafaga	22
9	38	14.39	Auto	27
10	22	7.24	Rafaga	14
11	78	12.99	Auto	3
12	59	3.74	Auto	29
13	43	4.17	Semi	19
14	24	4.30	Rafaga	28
15	9	10.00	Semi	17
16	22	5.11	Semi	21
18	72	12.21	Rafaga	7
19	58	3.47	Rafaga	15
21	57	10.06	Auto	9
22	7	12.23	Semi	26
23	72	9.63	Semi	19
24	31	1.54	Rafaga	12
25	19	3.48	Auto	6
26	79	3.50	Rafaga	29
27	9	1.04	Auto	25
28	20	6.91	Rafaga	21
29	63	9.30	Auto	20
30	35	4.24	Semi	28
31	22	9.13	Semi	8
32	91	5.27	Rafaga	3
33	40	10.32	Semi	30
34	11	5.75	Rafaga	23
35	82	14.12	Rafaga	5
36	65	4.20	Rafaga	4
37	29	11.87	Semi	19
38	29	3.33	Rafaga	4
39	55	6.76	Auto	19
40	18	11.04	Semi	12
41	45	14.24	Semi	3
42	19	9.61	Auto	14
43	49	5.76	Auto	6
44	38	14.84	Rafaga	13
45	30	14.77	Auto	16
46	45	3.32	Auto	12
47	49	2.02	Auto	20
48	8	5.21	Rafaga	18
49	80	5.31	Rafaga	23
50	46	3.41	Semi	5
51	97	13.33	Auto	9
52	29	3.55	Semi	23
53	83	10.47	Semi	2
54	73	11.09	Auto	22
55	99	13.57	Auto	6
56	79	12.83	Semi	8
57	23	2.46	Rafaga	11
58	13	7.63	Semi	22
59	81	10.55	Rafaga	29
60	88	7.19	Auto	30
61	54	4.69	Rafaga	19
62	75	2.33	Auto	21
63	57	4.83	Rafaga	7
64	37	5.30	Rafaga	19
65	41	10.37	Rafaga	2
66	61	14.17	Semi	18
67	97	13.98	Semi	7
68	85	10.28	Rafaga	5
69	40	2.16	Rafaga	16
70	34	2.16	Rafaga	14
71	64	11.37	Semi	8
72	42	10.78	Auto	17
73	47	14.47	Auto	17
74	74	11.15	Auto	8
75	50	4.74	Semi	20
76	89	9.74	Rafaga	6
77	5	1.00	Auto	5
78	41	2.22	Rafaga	25
79	42	9.90	Rafaga	17
80	98	3.81	Rafaga	14
81	24	8.97	Semi	15
82	31	5.92	Rafaga	16
83	28	12.45	Semi	6
84	54	5.81	Semi	15
85	100	11.65	Rafaga	11
86	73	6.28	Rafaga	8
88	25	12.88	Semi	15
89	82	5.12	Semi	15
90	52	11.91	Rafaga	29
91	34	7.64	Auto	14
92	65	6.39	Auto	30
93	62	13.31	Rafaga	7
94	28	11.77	Rafaga	13
96	81	3.77	Semi	14
97	68	9.15	Rafaga	4
99	90	1.87	Semi	26
100	18	3.41	Auto	20
101	74	7.44	Semi	15
102	87	12.44	Rafaga	13
103	41	13.01	Semi	27
104	60	1.29	Auto	5
105	8	2.71	Semi	22
106	18	2.15	Auto	4
107	30	11.36	Rafaga	29
108	25	14.83	Rafaga	11
109	53	12.03	Rafaga	16
110	50	12.84	Semi	16
111	65	2.66	Rafaga	9
112	49	12.82	Auto	23
113	66	6.26	Rafaga	6
114	92	8.14	Rafaga	11
115	31	4.17	Rafaga	11
116	30	8.70	Rafaga	22
117	49	13.84	Auto	29
118	81	4.05	Auto	13
119	80	2.36	Auto	12
120	50	9.72	Rafaga	1
121	5	10.63	Rafaga	5
122	81	12.08	Auto	15
123	70	2.21	Rafaga	14
124	53	2.32	Rafaga	22
125	56	3.91	Semi	27
126	98	7.34	Semi	1
127	22	6.13	Rafaga	11
128	78	5.61	Auto	6
129	50	6.57	Auto	29
130	85	5.85	Auto	5
131	6	14.88	Semi	20
132	84	5.76	Semi	16
133	33	2.31	Auto	12
134	57	4.57	Semi	5
135	59	13.71	Auto	14
136	47	1.79	Auto	17
137	21	11.14	Semi	22
138	23	2.92	Rafaga	24
139	42	14.35	Semi	27
140	96	8.26	Semi	11
141	92	1.85	Semi	2
142	11	14.80	Rafaga	29
143	97	5.10	Rafaga	1
144	91	12.15	Semi	9
145	38	12.36	Semi	15
146	35	12.44	Semi	19
147	86	10.64	Semi	14
148	75	1.54	Rafaga	22
149	42	8.45	Semi	23
150	24	6.04	Auto	3
151	52	3.84	Auto	4
152	81	6.58	Auto	3
153	58	9.38	Auto	23
154	32	9.57	Auto	10
155	60	11.03	Auto	12
156	77	12.53	Rafaga	25
157	34	10.86	Semi	14
158	15	11.48	Auto	30
159	70	11.61	Auto	27
160	75	8.65	Semi	2
161	21	1.81	Rafaga	30
162	74	2.14	Auto	12
163	52	7.89	Semi	7
164	94	14.10	Auto	26
165	60	1.46	Auto	12
166	89	1.62	Semi	21
167	88	1.48	Semi	9
168	51	14.14	Auto	22
169	54	9.88	Auto	9
170	21	2.88	Semi	18
171	23	5.69	Semi	18
172	42	14.83	Semi	9
173	56	6.85	Auto	28
174	49	6.06	Auto	27
175	81	8.88	Rafaga	20
176	69	4.88	Rafaga	17
177	60	11.96	Semi	9
178	44	1.10	Semi	6
179	45	12.28	Rafaga	16
180	15	11.51	Semi	19
181	83	12.94	Rafaga	4
182	55	6.92	Auto	9
183	11	6.86	Auto	25
184	20	14.36	Semi	19
185	15	14.20	Auto	15
186	21	3.97	Semi	12
187	16	11.71	Rafaga	21
188	95	8.99	Auto	10
189	40	14.02	Auto	10
190	86	6.30	Semi	10
191	83	13.17	Rafaga	2
192	96	2.22	Rafaga	20
193	49	11.43	Semi	21
194	47	13.06	Rafaga	19
195	45	10.26	Semi	29
196	34	11.32	Auto	18
197	76	2.04	Semi	21
198	5	6.05	Rafaga	10
199	35	13.84	Rafaga	14
200	70	9.37	Rafaga	29
201	94	5.42	Rafaga	20
202	37	5.20	Auto	13
203	47	11.39	Semi	30
204	7	11.23	Rafaga	29
205	74	8.32	Semi	29
206	96	3.85	Semi	28
207	96	14.75	Semi	5
208	27	12.18	Auto	21
209	98	4.21	Rafaga	17
210	76	11.59	Semi	2
211	25	10.31	Auto	16
212	86	7.96	Auto	18
213	24	8.48	Semi	13
214	81	9.89	Auto	29
215	92	9.56	Rafaga	8
216	12	2.92	Rafaga	17
217	29	5.60	Rafaga	28
218	51	6.10	Rafaga	24
219	63	11.57	Semi	26
220	52	6.42	Semi	1
221	20	4.62	Rafaga	16
222	82	4.29	Auto	23
223	64	1.17	Auto	13
224	38	8.68	Semi	22
225	58	2.62	Rafaga	13
226	29	7.91	Auto	22
227	35	5.47	Rafaga	21
228	39	3.78	Semi	15
229	27	10.62	Rafaga	22
230	18	3.13	Auto	30
231	59	6.75	Rafaga	21
232	18	12.57	Semi	20
233	5	3.95	Auto	14
234	19	5.55	Semi	29
236	57	14.56	Semi	30
237	65	12.88	Auto	23
238	52	1.27	Rafaga	17
239	44	7.53	Rafaga	11
240	100	7.06	Semi	26
241	71	7.34	Rafaga	19
242	28	7.84	Rafaga	26
243	80	4.23	Semi	12
244	27	9.86	Auto	30
245	82	9.70	Semi	19
246	14	7.02	Auto	24
247	9	10.08	Auto	13
248	15	2.24	Semi	4
249	39	11.14	Rafaga	20
250	81	2.05	Rafaga	16
251	17	6.42	Semi	2
252	49	11.65	Semi	8
253	97	3.37	Rafaga	27
254	61	11.11	Auto	28
255	70	11.62	Rafaga	21
256	98	13.01	Rafaga	29
257	15	6.90	Auto	9
258	62	2.41	Semi	28
260	66	2.64	Semi	21
261	97	11.29	Rafaga	26
262	32	7.49	Auto	1
263	93	10.13	Semi	18
264	8	11.48	Rafaga	15
265	22	12.32	Rafaga	28
267	40	9.50	Semi	26
268	37	13.10	Rafaga	30
269	58	4.05	Auto	25
271	71	12.87	Rafaga	6
272	61	7.44	Auto	20
274	75	1.07	Semi	27
275	91	5.39	Rafaga	18
276	26	1.06	Semi	8
277	6	6.13	Semi	2
278	48	11.03	Auto	11
279	83	7.19	Rafaga	2
280	53	11.66	Semi	10
281	22	12.59	Auto	2
282	34	2.13	Rafaga	11
283	38	11.53	Rafaga	10
284	99	7.58	Auto	7
285	11	1.14	Rafaga	24
286	13	13.03	Semi	1
287	11	3.55	Semi	6
288	27	11.18	Rafaga	4
289	61	3.94	Auto	16
290	99	7.22	Auto	17
291	82	3.04	Semi	25
292	70	14.76	Rafaga	3
293	28	7.12	Auto	15
294	76	11.55	Auto	14
295	77	5.18	Auto	23
296	25	1.51	Auto	9
297	77	9.88	Semi	12
298	75	1.44	Rafaga	20
299	92	2.83	Semi	14
300	68	10.86	Auto	25
301	9	2.77	Auto	26
302	98	4.19	Auto	1
303	79	8.06	Semi	27
304	40	10.96	Auto	12
305	12	13.70	Auto	23
306	55	9.73	Rafaga	28
307	48	7.19	Semi	5
308	11	12.33	Semi	11
309	91	1.52	Auto	1
310	51	10.88	Auto	11
311	91	10.46	Auto	18
312	99	3.74	Semi	21
314	77	2.23	Semi	27
315	22	9.31	Auto	24
316	8	11.29	Semi	25
317	42	4.53	Rafaga	2
318	88	5.48	Semi	17
319	74	2.24	Semi	20
320	31	10.47	Semi	11
321	95	10.31	Auto	20
322	80	3.39	Rafaga	2
323	79	11.04	Auto	30
324	7	1.11	Auto	7
325	77	13.34	Rafaga	6
326	75	14.14	Rafaga	12
327	92	3.18	Auto	16
328	18	14.46	Semi	10
329	59	11.17	Semi	24
330	81	13.32	Rafaga	14
331	60	14.72	Auto	23
332	65	10.35	Auto	4
333	31	5.79	Rafaga	3
334	62	5.23	Auto	23
335	17	1.66	Rafaga	14
336	5	14.16	Semi	25
337	26	11.07	Auto	9
338	55	3.74	Auto	2
339	65	7.06	Semi	26
340	64	1.69	Semi	7
341	34	3.42	Semi	22
342	39	12.42	Auto	1
344	68	2.75	Semi	3
345	21	4.97	Rafaga	6
346	78	2.07	Auto	25
347	78	5.38	Semi	21
348	34	6.62	Rafaga	28
349	11	1.19	Rafaga	30
350	31	1.39	Auto	23
351	77	11.66	Auto	22
352	71	14.28	Semi	6
353	93	8.77	Rafaga	1
354	80	7.08	Rafaga	10
355	75	1.53	Auto	10
356	58	9.68	Semi	7
357	38	7.17	Rafaga	4
358	45	6.11	Rafaga	18
359	85	1.07	Semi	1
360	22	2.17	Rafaga	10
361	87	2.85	Rafaga	11
362	19	11.02	Auto	3
363	44	12.82	Auto	23
364	66	1.70	Auto	28
365	79	5.58	Rafaga	4
366	8	7.93	Auto	4
367	80	12.96	Auto	5
368	24	11.27	Rafaga	15
369	51	1.11	Rafaga	29
370	65	5.89	Rafaga	14
371	48	4.91	Semi	5
372	61	1.77	Rafaga	15
373	72	4.82	Semi	2
374	72	7.46	Rafaga	3
375	23	1.63	Auto	28
376	43	3.47	Semi	24
377	35	7.24	Semi	10
378	44	4.09	Auto	11
379	44	6.72	Rafaga	3
380	34	4.99	Auto	27
381	81	3.43	Rafaga	23
382	55	1.15	Semi	24
383	20	9.94	Auto	23
384	74	9.25	Semi	24
385	52	13.83	Rafaga	27
386	41	9.61	Semi	6
387	72	8.42	Rafaga	1
388	85	13.97	Semi	1
389	8	6.59	Semi	15
390	33	9.11	Auto	23
391	26	6.99	Rafaga	18
392	91	9.04	Semi	5
394	89	8.02	Semi	21
395	96	11.11	Auto	4
396	13	12.19	Semi	9
397	96	13.97	Rafaga	24
398	57	14.05	Auto	22
399	88	9.60	Rafaga	18
400	25	10.91	Auto	15
401	85	13.77	Rafaga	19
402	42	5.41	Semi	27
403	96	8.82	Auto	30
404	93	4.40	Semi	14
405	54	5.52	Auto	26
406	87	7.17	Rafaga	28
407	58	14.97	Semi	29
408	71	9.64	Semi	4
409	99	6.69	Semi	13
410	60	4.03	Semi	19
411	79	10.79	Auto	18
412	61	6.55	Rafaga	14
413	19	1.84	Auto	10
414	38	2.42	Semi	2
415	75	14.76	Rafaga	19
416	46	13.84	Rafaga	5
417	85	1.46	Semi	21
418	82	11.16	Rafaga	3
419	85	1.05	Rafaga	24
420	10	13.98	Auto	6
421	94	13.09	Semi	16
422	67	6.56	Semi	5
423	43	7.99	Semi	28
424	13	1.19	Rafaga	21
425	57	3.09	Auto	1
426	73	6.15	Rafaga	26
427	54	12.12	Auto	24
428	42	1.74	Semi	18
429	58	8.33	Rafaga	9
430	62	12.47	Rafaga	16
431	100	13.33	Semi	18
432	68	7.56	Auto	11
433	29	7.55	Rafaga	4
434	50	11.21	Auto	21
435	91	10.91	Semi	23
436	70	14.61	Auto	5
437	31	14.73	Semi	17
438	11	2.66	Auto	10
439	75	11.25	Semi	1
440	7	5.63	Rafaga	11
441	50	8.14	Semi	2
442	48	12.94	Auto	17
443	55	2.14	Semi	5
444	60	13.42	Auto	2
445	34	10.16	Semi	29
446	50	14.79	Rafaga	26
447	46	6.04	Rafaga	24
448	13	6.66	Semi	16
449	95	4.43	Semi	12
450	7	1.38	Auto	24
451	22	5.79	Rafaga	18
452	59	11.66	Rafaga	15
453	43	7.29	Auto	6
454	7	4.23	Auto	20
455	90	9.89	Auto	14
456	47	6.12	Semi	6
457	39	10.11	Auto	8
458	59	5.29	Auto	13
459	14	2.02	Semi	7
460	77	11.56	Rafaga	30
461	60	6.40	Rafaga	27
462	82	14.47	Auto	15
463	38	12.19	Semi	18
464	24	11.32	Auto	15
465	86	14.21	Rafaga	17
466	66	13.13	Semi	28
467	82	10.74	Auto	17
468	62	5.04	Semi	4
469	21	3.62	Semi	29
470	83	12.79	Auto	23
471	16	4.33	Semi	28
472	85	11.03	Rafaga	11
473	39	8.45	Rafaga	16
474	21	5.71	Semi	6
475	37	7.85	Semi	19
476	88	10.15	Rafaga	9
477	44	11.05	Rafaga	12
478	60	6.43	Auto	24
479	22	7.85	Semi	23
480	31	12.25	Semi	24
481	97	10.64	Rafaga	3
482	46	7.63	Semi	2
483	18	3.40	Rafaga	30
484	93	6.52	Auto	21
485	56	2.83	Auto	26
486	84	5.34	Semi	13
487	9	1.69	Auto	30
489	70	1.06	Rafaga	21
490	34	4.83	Rafaga	7
491	47	5.18	Rafaga	2
492	56	1.43	Semi	10
493	12	13.17	Rafaga	20
494	41	9.43	Semi	25
495	58	3.48	Rafaga	13
496	25	6.31	Auto	8
497	51	7.80	Semi	28
498	8	2.47	Semi	5
499	88	6.59	Auto	1
500	13	6.41	Rafaga	17
501	76	5.86	Rafaga	13
502	83	12.52	Semi	15
503	87	3.79	Rafaga	27
504	63	9.73	Auto	15
505	9	8.21	Semi	2
506	23	8.56	Rafaga	28
507	40	9.79	Auto	3
508	44	2.52	Auto	17
509	66	14.88	Semi	9
510	12	5.62	Rafaga	17
511	54	1.81	Semi	23
512	89	13.28	Auto	22
513	12	12.70	Rafaga	3
514	10	12.22	Semi	17
515	69	8.62	Rafaga	6
516	54	5.81	Auto	29
517	90	3.34	Semi	11
519	51	12.10	Rafaga	24
520	91	4.72	Semi	27
521	65	3.80	Rafaga	2
522	48	7.66	Rafaga	26
523	30	1.16	Auto	3
524	97	3.46	Rafaga	13
525	36	6.95	Semi	30
526	44	12.91	Auto	14
527	83	4.34	Rafaga	26
528	49	9.65	Rafaga	21
529	52	12.04	Rafaga	10
530	43	14.73	Rafaga	15
531	71	4.17	Rafaga	20
532	50	8.37	Rafaga	3
533	19	11.44	Auto	26
534	58	7.90	Auto	19
535	68	13.69	Rafaga	9
536	93	12.22	Auto	23
537	99	7.10	Semi	12
538	79	4.48	Rafaga	23
539	52	11.47	Rafaga	9
540	33	5.57	Auto	24
541	90	5.63	Auto	4
542	97	1.65	Rafaga	1
543	60	7.48	Semi	11
544	38	10.41	Rafaga	1
545	36	9.35	Rafaga	11
546	50	10.87	Auto	29
547	84	9.68	Auto	30
548	44	12.31	Auto	8
549	20	3.48	Semi	10
550	7	13.90	Rafaga	18
551	96	13.84	Rafaga	14
552	21	12.55	Auto	7
553	90	11.21	Auto	26
554	24	9.91	Auto	22
555	95	5.22	Semi	15
556	80	13.66	Semi	11
557	16	8.59	Semi	21
558	61	8.95	Auto	7
559	22	7.25	Rafaga	13
560	60	11.40	Rafaga	15
561	81	10.34	Rafaga	8
562	21	13.48	Semi	27
563	91	10.61	Rafaga	17
565	14	4.81	Auto	25
566	55	7.09	Auto	22
567	93	13.09	Auto	17
568	78	1.95	Rafaga	9
569	61	11.92	Rafaga	28
570	25	5.34	Auto	19
571	69	10.73	Semi	16
572	37	3.88	Auto	12
573	83	10.35	Rafaga	20
574	63	5.73	Semi	9
575	17	12.53	Auto	4
577	15	9.49	Semi	7
578	20	8.58	Semi	6
579	44	14.97	Semi	14
580	88	6.18	Auto	6
581	74	7.80	Auto	21
582	31	8.67	Semi	26
583	51	12.68	Auto	16
584	52	4.98	Auto	3
585	86	7.51	Semi	12
586	79	4.99	Rafaga	1
587	39	11.57	Rafaga	30
588	67	1.74	Auto	25
589	72	13.44	Auto	3
590	30	1.83	Auto	25
591	38	13.59	Auto	24
592	100	11.65	Semi	15
593	82	12.54	Semi	29
594	9	5.25	Semi	15
595	50	10.44	Auto	17
596	69	12.51	Auto	17
597	43	14.07	Auto	29
598	52	8.92	Auto	13
599	20	6.93	Semi	26
600	44	3.37	Auto	13
601	88	11.27	Semi	5
602	16	2.93	Auto	9
603	22	2.29	Auto	4
604	96	11.90	Auto	15
605	86	12.03	Auto	22
606	72	6.57	Semi	7
607	64	1.13	Auto	28
608	14	4.55	Rafaga	7
609	24	5.77	Rafaga	21
610	95	8.96	Semi	5
611	54	14.22	Semi	24
612	74	7.25	Rafaga	21
613	20	4.50	Semi	24
614	47	10.73	Rafaga	25
615	49	11.90	Semi	1
616	50	13.19	Semi	23
617	29	2.12	Auto	3
618	65	3.79	Semi	26
619	23	14.49	Rafaga	14
620	37	8.47	Auto	21
622	84	11.61	Rafaga	24
623	51	4.92	Rafaga	4
624	88	1.31	Auto	3
625	97	10.46	Semi	26
626	49	10.59	Semi	20
627	63	10.56	Semi	19
628	30	12.41	Rafaga	6
629	49	6.90	Auto	17
630	91	2.77	Semi	8
631	68	3.56	Semi	28
632	40	10.61	Auto	20
633	46	2.35	Semi	27
634	48	9.51	Rafaga	29
635	24	2.96	Rafaga	10
636	14	6.63	Auto	27
637	40	8.90	Semi	1
638	55	14.91	Semi	16
639	91	13.28	Auto	12
640	80	11.16	Auto	28
641	19	9.00	Rafaga	10
642	40	8.03	Auto	20
643	18	11.84	Auto	28
644	73	7.44	Semi	27
645	33	3.49	Rafaga	9
646	77	3.78	Rafaga	10
647	75	11.70	Semi	9
648	85	1.66	Auto	30
649	89	4.77	Auto	7
650	26	9.69	Semi	25
651	73	8.74	Semi	16
652	51	10.66	Rafaga	19
653	35	3.01	Rafaga	7
654	14	14.68	Auto	29
656	43	2.58	Auto	28
657	78	8.54	Semi	7
658	60	10.14	Auto	2
659	43	13.03	Semi	8
660	36	11.77	Semi	18
661	25	13.95	Rafaga	21
662	83	6.13	Semi	18
663	96	5.19	Semi	4
664	65	7.97	Auto	8
665	20	4.46	Semi	28
666	56	14.18	Auto	30
667	62	11.71	Rafaga	18
668	55	12.34	Rafaga	27
669	93	4.78	Semi	20
670	7	13.70	Auto	14
671	39	9.24	Auto	15
672	68	11.66	Auto	30
673	32	4.90	Auto	25
674	72	2.56	Semi	14
675	56	12.23	Rafaga	25
676	28	2.18	Auto	2
677	42	6.45	Rafaga	2
678	57	3.16	Rafaga	15
679	54	5.43	Auto	27
680	40	10.45	Semi	21
681	5	12.51	Auto	17
682	39	10.18	Semi	15
683	54	6.98	Auto	26
684	14	11.85	Auto	21
685	84	3.53	Auto	2
686	98	7.18	Rafaga	20
687	99	6.69	Auto	2
688	65	7.63	Rafaga	1
689	69	4.59	Auto	19
690	65	9.90	Auto	12
691	26	9.77	Rafaga	8
692	26	10.03	Semi	29
693	70	3.41	Semi	11
694	78	5.58	Rafaga	28
695	75	6.03	Semi	24
696	23	6.50	Semi	30
697	51	4.00	Rafaga	6
698	37	14.23	Auto	17
699	36	4.54	Semi	25
700	20	5.41	Semi	25
701	44	2.65	Rafaga	3
702	69	1.77	Rafaga	4
703	66	13.06	Auto	28
704	100	3.08	Auto	20
705	29	6.61	Auto	4
706	66	2.48	Auto	22
707	61	7.91	Semi	23
708	16	13.63	Rafaga	7
709	20	13.81	Semi	16
710	86	10.76	Rafaga	28
711	18	2.73	Rafaga	1
713	30	4.51	Rafaga	7
714	21	3.12	Auto	8
715	34	9.19	Auto	30
716	44	4.47	Auto	4
717	83	13.97	Semi	11
718	94	5.85	Rafaga	29
719	41	11.54	Semi	29
720	69	11.47	Auto	19
721	70	1.43	Auto	25
722	57	6.70	Rafaga	2
723	30	7.45	Semi	5
724	38	8.83	Semi	12
725	39	4.61	Rafaga	8
726	96	14.09	Auto	8
727	63	8.29	Auto	17
728	95	3.23	Auto	6
729	71	13.08	Rafaga	4
730	77	1.95	Auto	4
731	94	2.02	Semi	12
732	60	8.03	Auto	9
733	18	6.59	Rafaga	2
734	58	12.58	Semi	11
735	57	2.14	Auto	11
736	75	6.33	Auto	5
739	11	10.30	Semi	20
740	27	13.74	Auto	12
741	81	8.76	Auto	1
742	84	7.09	Rafaga	29
743	54	1.95	Auto	27
744	52	10.42	Auto	11
745	100	6.10	Rafaga	5
746	92	10.98	Semi	5
747	57	12.61	Auto	7
748	6	2.71	Auto	30
749	16	9.62	Rafaga	3
750	46	6.15	Rafaga	19
751	78	7.67	Auto	24
752	89	9.00	Semi	9
753	12	7.44	Semi	22
754	64	1.06	Semi	18
755	35	8.49	Rafaga	26
756	25	5.51	Semi	20
757	52	8.07	Auto	24
758	90	3.40	Auto	19
760	61	3.01	Auto	15
761	94	12.70	Rafaga	23
762	49	12.83	Semi	3
763	76	6.02	Auto	23
764	93	9.89	Auto	10
765	75	1.53	Rafaga	21
766	78	4.73	Semi	16
767	52	6.78	Auto	7
768	44	9.75	Rafaga	8
769	85	6.54	Rafaga	5
770	24	8.97	Auto	2
771	68	12.93	Semi	23
772	20	1.97	Auto	9
773	54	4.11	Auto	19
774	22	12.98	Auto	23
775	42	7.62	Rafaga	1
776	9	6.89	Rafaga	27
777	6	9.27	Semi	11
778	37	12.73	Semi	18
779	71	9.17	Auto	23
780	8	10.57	Auto	4
781	11	1.10	Semi	17
782	17	10.62	Semi	15
783	83	2.60	Auto	23
784	24	4.24	Auto	11
785	14	6.37	Semi	27
786	81	7.10	Rafaga	25
787	27	6.07	Auto	14
788	18	6.81	Auto	22
789	65	13.84	Rafaga	19
790	74	12.23	Rafaga	23
791	100	7.99	Rafaga	19
792	59	8.92	Auto	1
793	97	7.64	Rafaga	13
794	37	7.98	Rafaga	30
795	55	4.38	Rafaga	16
796	42	13.28	Semi	29
797	12	7.35	Rafaga	11
798	55	4.97	Rafaga	9
800	18	10.90	Rafaga	12
801	9	10.58	Rafaga	21
802	63	8.89	Auto	28
803	55	10.24	Auto	27
804	60	12.70	Rafaga	8
805	36	10.83	Semi	25
806	52	4.41	Semi	4
807	10	7.50	Rafaga	19
808	53	13.90	Semi	21
809	57	4.95	Semi	3
810	8	10.20	Semi	4
811	91	4.03	Auto	11
812	67	7.89	Semi	8
813	5	11.07	Auto	18
814	78	14.60	Rafaga	21
815	61	3.17	Auto	6
816	31	2.91	Auto	13
817	21	14.41	Semi	28
818	96	7.24	Rafaga	17
819	70	11.39	Rafaga	2
820	14	2.84	Semi	19
821	22	3.47	Semi	18
822	66	12.00	Auto	30
823	66	8.48	Semi	23
824	80	12.81	Auto	6
825	23	11.62	Rafaga	28
826	72	2.98	Auto	20
827	47	4.29	Semi	23
828	48	8.58	Semi	3
829	83	13.53	Semi	6
830	28	10.37	Semi	17
831	70	14.54	Semi	25
832	88	14.50	Rafaga	27
833	49	11.79	Rafaga	2
834	53	2.81	Rafaga	27
835	61	6.16	Semi	10
837	98	6.15	Semi	14
838	31	6.05	Semi	11
839	99	3.81	Auto	21
840	52	14.21	Semi	4
841	54	4.92	Semi	6
842	10	14.00	Rafaga	30
843	57	11.58	Semi	14
844	86	8.76	Rafaga	22
845	64	13.58	Auto	6
846	8	3.16	Semi	12
847	64	8.67	Auto	10
848	26	3.67	Rafaga	19
849	49	8.36	Auto	5
850	29	2.58	Rafaga	18
851	61	11.19	Semi	16
852	90	12.91	Auto	9
853	95	6.05	Auto	11
854	58	13.18	Auto	23
855	12	2.36	Semi	28
856	81	11.41	Semi	21
857	26	4.53	Auto	10
858	39	1.17	Semi	26
859	83	3.47	Auto	27
860	48	8.94	Rafaga	19
861	91	8.59	Rafaga	15
862	26	7.58	Auto	9
864	34	9.72	Semi	9
865	83	14.28	Auto	11
866	96	3.55	Auto	19
867	63	5.69	Auto	9
868	10	5.76	Semi	10
869	82	1.93	Semi	11
870	72	1.35	Auto	9
871	48	9.95	Rafaga	5
872	43	5.56	Rafaga	24
873	80	2.27	Rafaga	15
874	49	2.94	Auto	11
875	28	1.96	Semi	26
876	15	10.37	Rafaga	10
877	71	7.81	Auto	26
878	91	7.98	Semi	5
879	51	12.88	Rafaga	15
880	21	3.32	Rafaga	15
881	77	7.89	Semi	5
882	50	8.48	Semi	10
883	14	4.55	Rafaga	11
884	33	9.60	Semi	2
885	76	5.67	Rafaga	26
886	57	5.44	Rafaga	14
887	70	14.89	Rafaga	10
888	71	8.51	Semi	29
889	27	5.52	Auto	20
890	82	11.11	Rafaga	7
891	42	5.46	Semi	28
892	53	5.60	Semi	3
893	83	4.64	Semi	14
894	55	6.53	Rafaga	10
895	62	6.46	Rafaga	15
896	100	11.58	Semi	3
897	42	4.85	Rafaga	25
898	66	4.99	Semi	16
899	19	5.12	Semi	14
900	18	5.26	Rafaga	4
901	12	7.59	Auto	4
902	40	6.92	Auto	4
903	71	14.93	Rafaga	10
904	39	7.90	Rafaga	6
905	92	7.71	Rafaga	2
906	83	12.53	Rafaga	5
907	69	3.77	Semi	1
908	60	5.10	Semi	17
909	12	9.65	Auto	3
910	46	14.47	Rafaga	12
911	26	5.14	Rafaga	16
912	7	10.50	Rafaga	13
913	35	13.50	Auto	9
914	97	11.74	Semi	12
915	14	14.90	Rafaga	6
916	65	7.58	Rafaga	29
917	14	6.94	Rafaga	12
918	76	13.84	Semi	22
919	84	1.33	Semi	6
920	13	12.06	Auto	23
921	50	14.44	Semi	13
922	36	7.06	Auto	21
923	18	1.73	Semi	18
924	91	1.77	Auto	7
925	66	1.23	Semi	14
926	78	7.89	Rafaga	30
927	31	4.58	Rafaga	21
928	45	14.31	Rafaga	23
929	47	4.81	Auto	4
930	76	8.72	Auto	15
931	9	14.21	Auto	11
932	59	14.62	Rafaga	11
933	21	10.94	Rafaga	5
934	22	14.97	Rafaga	21
935	26	7.74	Rafaga	9
936	30	9.53	Rafaga	16
937	40	3.41	Semi	18
938	88	8.12	Semi	12
939	84	11.99	Rafaga	27
940	84	11.63	Rafaga	21
941	31	2.40	Auto	15
942	68	9.59	Rafaga	26
943	58	11.10	Semi	18
944	25	14.29	Auto	9
945	97	5.32	Semi	28
946	70	14.47	Rafaga	16
947	95	6.33	Auto	6
948	87	1.91	Rafaga	14
949	63	10.48	Semi	5
950	99	14.95	Auto	2
951	21	7.00	Auto	16
952	83	1.16	Auto	21
953	56	8.09	Semi	20
954	51	13.55	Semi	3
955	97	1.69	Rafaga	8
956	34	7.11	Rafaga	4
957	26	12.45	Semi	27
958	81	14.36	Rafaga	1
959	72	12.14	Auto	22
960	8	5.72	Semi	19
961	91	11.29	Auto	3
962	36	2.15	Rafaga	28
963	25	6.90	Semi	18
964	66	13.99	Rafaga	7
965	89	6.55	Semi	28
966	67	5.47	Semi	25
967	33	8.39	Semi	9
968	87	13.54	Auto	22
969	11	14.81	Auto	20
970	7	11.28	Semi	9
971	5	7.24	Semi	20
972	66	8.15	Auto	5
973	99	5.17	Auto	15
974	44	11.15	Semi	19
975	56	4.45	Semi	18
976	66	10.65	Semi	28
977	33	4.16	Semi	24
978	40	2.53	Semi	3
979	10	14.82	Rafaga	21
980	82	1.22	Semi	17
981	95	10.35	Rafaga	29
982	42	1.79	Semi	7
983	88	12.50	Rafaga	27
984	75	3.39	Semi	24
985	49	4.10	Rafaga	16
986	40	14.72	Semi	28
987	55	9.12	Rafaga	7
988	20	6.80	Semi	29
989	94	1.76	Auto	5
990	86	13.70	Semi	17
991	14	14.74	Semi	15
992	22	1.04	Rafaga	22
993	15	11.41	Rafaga	21
994	55	6.63	Auto	25
995	25	7.69	Rafaga	24
996	57	13.44	Auto	6
997	15	14.79	Semi	22
998	73	10.79	Rafaga	22
999	10	1.13	Rafaga	27
1000	9	5.74	Semi	17
\.


--
-- Data for Name: armamento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.armamento (id_arma, numero_serie, estado_arma, id_categoria, id_soldado) FROM stdin;
1	WPN-37575623	En Mantenimiento	18	2771
4	WPN-82708834	En Mantenimiento	9	\N
6	WPN-56387610	En Mantenimiento	16	2823
7	WPN-97620520	Operativa	18	839
9	WPN-27292060	Operativa	2	1898
10	WPN-19675490	Operativa	1	\N
11	WPN-97359434	Operativa	18	\N
12	WPN-57434231	Operativa	14	\N
13	WPN-48418405	En Mantenimiento	10	\N
15	WPN-80928703	En Mantenimiento	14	\N
1482	WPN-65646277	En Mantenimiento	1	\N
18	WPN-72849670	Operativa	9	209
19	WPN-53711075	En Mantenimiento	20	\N
1483	WPN-57276118	En Mantenimiento	7	2966
21	WPN-14290589	En Mantenimiento	18	357
22	WPN-62018051	Operativa	5	782
23	WPN-59087990	En Mantenimiento	3	\N
24	WPN-65449773	Operativa	11	\N
25	WPN-85983941	En Mantenimiento	17	593
26	WPN-38700988	En Mantenimiento	1	\N
27	WPN-80719223	Operativa	15	\N
31	WPN-13979212	En Mantenimiento	1	1311
32	WPN-25802594	En Mantenimiento	17	2547
33	WPN-23485476	En Mantenimiento	13	\N
34	WPN-57635706	En Mantenimiento	20	\N
35	WPN-86847288	En Mantenimiento	2	492
39	WPN-30741270	En Mantenimiento	11	\N
40	WPN-49711854	En Mantenimiento	20	1366
41	WPN-88361317	Operativa	2	\N
42	WPN-71995011	Operativa	5	1651
43	WPN-07820567	En Mantenimiento	14	\N
44	WPN-14568024	Operativa	16	1067
45	WPN-87239237	Operativa	9	\N
46	WPN-09453679	En Mantenimiento	18	\N
50	WPN-18319824	Operativa	17	\N
52	WPN-29356899	Operativa	19	\N
54	WPN-30275866	Operativa	20	1296
56	WPN-82935628	En Mantenimiento	16	1176
57	WPN-17384468	Operativa	15	2611
59	WPN-82045128	Operativa	17	374
60	WPN-70237796	Operativa	10	\N
61	WPN-72769187	En Mantenimiento	15	\N
62	WPN-91559815	En Mantenimiento	19	\N
63	WPN-25986405	En Mantenimiento	12	\N
64	WPN-11478851	Operativa	17	\N
65	WPN-00225146	Operativa	7	845
66	WPN-82172518	Operativa	20	940
67	WPN-99889761	Operativa	1	\N
68	WPN-84309417	Operativa	1	\N
70	WPN-18551216	Operativa	5	\N
72	WPN-52000842	Operativa	7	\N
74	WPN-92065766	Operativa	13	568
78	WPN-86260881	En Mantenimiento	9	1206
79	WPN-07876826	Operativa	7	2294
80	WPN-09492384	En Mantenimiento	18	1621
82	WPN-81225350	Operativa	10	1659
83	WPN-58583732	En Mantenimiento	18	2976
84	WPN-60789398	En Mantenimiento	1	1035
86	WPN-29070936	En Mantenimiento	2	2091
88	WPN-77904801	Operativa	1	\N
90	WPN-99559933	En Mantenimiento	18	\N
92	WPN-43020197	En Mantenimiento	4	1665
93	WPN-60734281	Operativa	1	\N
94	WPN-21734134	Operativa	9	1055
96	WPN-95343844	En Mantenimiento	4	1931
1486	WPN-14293422	Operativa	12	1216
99	WPN-24507322	En Mantenimiento	14	\N
101	WPN-17064770	En Mantenimiento	15	\N
102	WPN-18009819	Operativa	11	\N
106	WPN-04069393	En Mantenimiento	13	\N
108	WPN-81451236	En Mantenimiento	5	1415
114	WPN-29397626	Operativa	12	2453
116	WPN-34376338	En Mantenimiento	18	\N
118	WPN-47448431	Operativa	1	2695
120	WPN-78516548	En Mantenimiento	10	255
122	WPN-71392046	Operativa	16	2816
8	WPN-37355946	Operativa	10	15
28	WPN-73469930	Dañada	8	\N
123	WPN-38999917	Operativa	10	\N
124	WPN-17335639	Operativa	6	\N
125	WPN-60542951	Operativa	16	454
127	WPN-82181298	Operativa	10	\N
130	WPN-59122418	En Mantenimiento	18	\N
131	WPN-98097403	Operativa	15	1833
132	WPN-80935244	Operativa	3	2592
133	WPN-86165220	Operativa	15	2920
134	WPN-26535924	Operativa	16	810
135	WPN-83182329	Operativa	7	\N
137	WPN-65900299	En Mantenimiento	12	327
138	WPN-22661996	En Mantenimiento	15	\N
139	WPN-44872737	Operativa	11	534
140	WPN-27955065	Operativa	6	\N
142	WPN-06934137	En Mantenimiento	4	\N
145	WPN-05174001	En Mantenimiento	11	\N
146	WPN-22290317	En Mantenimiento	3	640
147	WPN-53747373	Operativa	17	\N
149	WPN-83952111	Operativa	20	2986
150	WPN-88467782	En Mantenimiento	9	\N
151	WPN-00190473	En Mantenimiento	10	\N
152	WPN-37494383	Operativa	6	1906
153	WPN-71530479	En Mantenimiento	8	\N
154	WPN-78064543	Operativa	1	\N
155	WPN-01110993	En Mantenimiento	18	1031
156	WPN-26852882	Operativa	1	\N
158	WPN-44827359	En Mantenimiento	10	1968
162	WPN-72268755	En Mantenimiento	15	\N
163	WPN-14930133	En Mantenimiento	9	\N
165	WPN-41131366	Operativa	6	\N
166	WPN-46245786	Operativa	3	\N
168	WPN-65219681	En Mantenimiento	12	\N
169	WPN-74146830	Operativa	8	\N
170	WPN-43915716	Operativa	1	1914
171	WPN-78550284	En Mantenimiento	17	2769
172	WPN-06558141	Operativa	2	1799
173	WPN-89174851	Operativa	8	2296
174	WPN-31781311	En Mantenimiento	9	\N
175	WPN-19351003	Operativa	14	1013
176	WPN-40913009	En Mantenimiento	5	\N
177	WPN-65301393	Operativa	13	\N
179	WPN-13135159	Operativa	9	2169
181	WPN-24696120	En Mantenimiento	5	406
182	WPN-72674744	En Mantenimiento	4	\N
183	WPN-28757037	En Mantenimiento	8	2361
184	WPN-68486887	En Mantenimiento	15	339
185	WPN-30804384	En Mantenimiento	9	\N
189	WPN-44053330	En Mantenimiento	16	\N
190	WPN-31298792	En Mantenimiento	9	1876
192	WPN-30850212	En Mantenimiento	19	\N
193	WPN-86271740	Operativa	1	\N
194	WPN-05515242	En Mantenimiento	4	\N
195	WPN-76999937	En Mantenimiento	20	\N
196	WPN-10894799	Operativa	19	\N
199	WPN-63529334	Operativa	19	2290
202	WPN-37327721	En Mantenimiento	2	\N
203	WPN-51843645	En Mantenimiento	3	\N
205	WPN-92222894	Operativa	14	526
207	WPN-75410598	En Mantenimiento	11	1322
208	WPN-93274258	En Mantenimiento	15	\N
209	WPN-23580801	Operativa	12	\N
210	WPN-65145267	En Mantenimiento	17	1587
211	WPN-15109618	En Mantenimiento	8	473
212	WPN-98300575	Operativa	11	\N
214	WPN-79153749	Operativa	5	\N
215	WPN-86910485	Operativa	13	\N
217	WPN-46016397	Operativa	3	\N
218	WPN-34631986	En Mantenimiento	9	\N
219	WPN-31531819	Operativa	1	479
220	WPN-70424655	En Mantenimiento	14	2871
221	WPN-06005499	Operativa	4	\N
222	WPN-92239249	Operativa	5	\N
223	WPN-66840985	Operativa	8	28
225	WPN-39698197	Operativa	16	1246
226	WPN-18748027	Operativa	16	463
227	WPN-81947390	En Mantenimiento	13	\N
229	WPN-99995860	En Mantenimiento	16	\N
230	WPN-47157407	En Mantenimiento	10	2056
231	WPN-93717245	Operativa	14	1289
233	WPN-71730943	En Mantenimiento	16	\N
1487	WPN-64836489	En Mantenimiento	4	\N
236	WPN-64689833	Operativa	9	1391
238	WPN-22273583	En Mantenimiento	4	\N
239	WPN-08114087	Operativa	7	2587
240	WPN-35899428	En Mantenimiento	14	952
241	WPN-96875415	Operativa	3	2888
242	WPN-38485770	En Mantenimiento	10	2014
243	WPN-70805116	En Mantenimiento	3	\N
244	WPN-19942455	Operativa	4	\N
245	WPN-21804951	En Mantenimiento	13	\N
248	WPN-11473696	En Mantenimiento	20	96
249	WPN-47366031	En Mantenimiento	9	2959
250	WPN-19980710	En Mantenimiento	11	661
251	WPN-53239761	Operativa	2	\N
254	WPN-45782758	Operativa	3	1784
255	WPN-70563756	En Mantenimiento	11	\N
257	WPN-32453542	Operativa	1	\N
1488	WPN-85088983	Operativa	3	\N
260	WPN-65913210	Operativa	3	1993
261	WPN-00419556	Operativa	5	\N
262	WPN-95514507	En Mantenimiento	14	\N
263	WPN-35761927	En Mantenimiento	18	1951
264	WPN-96309462	En Mantenimiento	12	\N
265	WPN-69331304	Operativa	6	\N
1629	WPN-19925695	En Mantenimiento	16	2957
268	WPN-60073659	En Mantenimiento	2	\N
269	WPN-97067727	Operativa	15	\N
1630	WPN-95714515	En Mantenimiento	6	\N
272	WPN-85971537	En Mantenimiento	13	\N
1631	WPN-91822678	Operativa	18	\N
274	WPN-13295859	Operativa	9	\N
275	WPN-81103528	En Mantenimiento	1	1751
276	WPN-32847534	En Mantenimiento	10	\N
279	WPN-99215820	En Mantenimiento	12	2134
280	WPN-55653723	En Mantenimiento	8	\N
281	WPN-09773000	Operativa	7	536
284	WPN-58643005	Operativa	15	\N
286	WPN-62570961	En Mantenimiento	10	1541
287	WPN-98305028	En Mantenimiento	10	1775
288	WPN-97598864	Operativa	17	\N
290	WPN-41546730	En Mantenimiento	10	\N
292	WPN-16547550	En Mantenimiento	20	2736
293	WPN-34061552	En Mantenimiento	4	1901
295	WPN-49036135	Operativa	1	\N
297	WPN-46372714	Operativa	15	2743
298	WPN-18891997	Operativa	5	2359
301	WPN-44296257	Operativa	1	\N
302	WPN-17251768	Operativa	15	1653
303	WPN-41280811	Operativa	14	\N
305	WPN-80551253	En Mantenimiento	9	\N
306	WPN-26464500	En Mantenimiento	4	\N
307	WPN-01603182	En Mantenimiento	19	\N
308	WPN-27762451	En Mantenimiento	6	\N
309	WPN-31034325	En Mantenimiento	14	\N
310	WPN-13007515	Operativa	5	\N
311	WPN-61897827	Operativa	17	\N
312	WPN-46731134	Operativa	5	\N
315	WPN-58862544	En Mantenimiento	1	737
316	WPN-51897042	En Mantenimiento	17	2626
319	WPN-52763587	En Mantenimiento	14	\N
320	WPN-66628530	En Mantenimiento	11	1030
321	WPN-08518602	Operativa	1	999
322	WPN-22355852	Operativa	20	\N
323	WPN-53540880	En Mantenimiento	20	\N
325	WPN-71200095	Operativa	7	2631
327	WPN-86615359	En Mantenimiento	20	\N
328	WPN-79479986	Operativa	6	\N
329	WPN-98131004	Operativa	10	\N
330	WPN-53330793	Operativa	12	\N
331	WPN-02362096	Operativa	8	\N
332	WPN-66055722	Operativa	10	942
333	WPN-03597221	Operativa	4	\N
334	WPN-69967198	Operativa	2	\N
335	WPN-28766164	Operativa	6	14
336	WPN-62671321	En Mantenimiento	4	504
337	WPN-20721417	En Mantenimiento	18	2146
339	WPN-27736178	Operativa	17	2645
340	WPN-47582259	En Mantenimiento	19	2066
341	WPN-89312698	Operativa	14	754
342	WPN-67416684	Operativa	13	\N
1633	WPN-99176082	Operativa	14	\N
344	WPN-08635535	En Mantenimiento	12	\N
345	WPN-23459715	En Mantenimiento	12	2000
346	WPN-41165142	En Mantenimiento	20	\N
348	WPN-40367934	En Mantenimiento	8	2750
350	WPN-43890334	Operativa	7	891
352	WPN-82024807	En Mantenimiento	13	2496
353	WPN-66718768	En Mantenimiento	6	\N
354	WPN-61834987	En Mantenimiento	2	\N
355	WPN-93591985	En Mantenimiento	1	\N
357	WPN-00518274	Operativa	17	3
358	WPN-09181582	Operativa	3	1394
359	WPN-68665551	Operativa	12	\N
360	WPN-48659894	Operativa	4	986
362	WPN-59149177	En Mantenimiento	20	2616
363	WPN-26725482	Operativa	10	719
364	WPN-45384254	En Mantenimiento	10	281
365	WPN-58324060	En Mantenimiento	7	1377
367	WPN-02051444	En Mantenimiento	11	2834
368	WPN-69181522	En Mantenimiento	18	2023
369	WPN-20862259	En Mantenimiento	16	\N
370	WPN-34419247	En Mantenimiento	10	1189
372	WPN-22854807	En Mantenimiento	9	376
374	WPN-05117240	En Mantenimiento	20	\N
375	WPN-24710609	En Mantenimiento	12	\N
376	WPN-69554670	En Mantenimiento	6	137
377	WPN-00574914	En Mantenimiento	4	551
378	WPN-13217147	En Mantenimiento	18	2701
379	WPN-57072967	En Mantenimiento	9	\N
380	WPN-31004162	Operativa	3	1529
381	WPN-48246729	En Mantenimiento	11	\N
387	WPN-83796390	En Mantenimiento	19	956
389	WPN-19931449	En Mantenimiento	15	\N
391	WPN-93074752	Operativa	15	1656
392	WPN-04314984	Operativa	4	2827
1489	WPN-51836940	En Mantenimiento	10	\N
395	WPN-76345461	En Mantenimiento	3	2576
396	WPN-20517586	En Mantenimiento	12	\N
402	WPN-18060380	En Mantenimiento	10	927
403	WPN-87206575	En Mantenimiento	5	\N
404	WPN-48108998	Operativa	15	2314
406	WPN-38768242	En Mantenimiento	2	1403
407	WPN-41176072	En Mantenimiento	17	\N
408	WPN-49839166	Operativa	2	906
410	WPN-75138377	En Mantenimiento	13	877
411	WPN-28410745	En Mantenimiento	1	694
412	WPN-25548423	Operativa	2	2015
413	WPN-04885894	Operativa	11	2963
414	WPN-93153038	En Mantenimiento	8	1961
416	WPN-11505281	Operativa	1	\N
417	WPN-65138348	En Mantenimiento	17	1086
418	WPN-02875603	Operativa	19	\N
419	WPN-02367195	Operativa	15	\N
420	WPN-68730022	Operativa	1	\N
421	WPN-35583617	Operativa	13	1107
422	WPN-99090761	En Mantenimiento	7	1067
423	WPN-19799329	Operativa	4	1839
424	WPN-01232660	Operativa	10	490
425	WPN-10006840	Operativa	3	2251
427	WPN-42522816	En Mantenimiento	13	\N
428	WPN-97180868	En Mantenimiento	10	2481
429	WPN-46756512	En Mantenimiento	5	\N
432	WPN-82891959	En Mantenimiento	16	\N
434	WPN-27764804	Operativa	7	\N
436	WPN-27734635	En Mantenimiento	5	\N
437	WPN-17717546	Operativa	6	1842
438	WPN-58894170	Operativa	16	205
439	WPN-20517339	En Mantenimiento	16	\N
440	WPN-81938766	Operativa	17	1259
441	WPN-72339816	En Mantenimiento	5	\N
444	WPN-10803756	En Mantenimiento	19	\N
447	WPN-86140305	Operativa	9	779
448	WPN-51254354	Operativa	14	\N
451	WPN-25433573	Operativa	6	2379
452	WPN-11629996	Operativa	15	2214
453	WPN-96729002	En Mantenimiento	12	\N
454	WPN-79047787	Operativa	16	2009
455	WPN-52722394	En Mantenimiento	10	501
457	WPN-17146075	Operativa	7	114
458	WPN-20953444	En Mantenimiento	6	\N
459	WPN-47944949	En Mantenimiento	1	\N
462	WPN-50375665	En Mantenimiento	1	477
463	WPN-80874134	Operativa	5	\N
467	WPN-38027448	En Mantenimiento	8	\N
468	WPN-83254302	En Mantenimiento	12	2571
471	WPN-02602060	En Mantenimiento	11	\N
472	WPN-43739991	En Mantenimiento	2	1795
473	WPN-40648091	En Mantenimiento	6	\N
474	WPN-40185690	Operativa	16	494
475	WPN-45014836	En Mantenimiento	20	1294
477	WPN-09085748	Operativa	15	2894
478	WPN-86752844	Operativa	3	673
482	WPN-80893921	Operativa	10	\N
485	WPN-33711504	Operativa	15	\N
486	WPN-34074876	Operativa	7	\N
487	WPN-18296405	En Mantenimiento	5	\N
1634	WPN-71655079	En Mantenimiento	19	880
489	WPN-70826548	Operativa	18	2790
490	WPN-00473430	En Mantenimiento	20	2599
492	WPN-43768608	En Mantenimiento	12	2690
493	WPN-76167537	En Mantenimiento	19	\N
494	WPN-59144199	En Mantenimiento	2	\N
495	WPN-78459764	Operativa	3	\N
497	WPN-61037740	Operativa	12	\N
498	WPN-00104462	Operativa	18	2126
499	WPN-81284991	Operativa	18	\N
501	WPN-71866452	En Mantenimiento	12	2186
505	WPN-92921973	Operativa	7	\N
506	WPN-47186116	Operativa	2	\N
507	WPN-75461603	Operativa	6	974
508	WPN-46969120	En Mantenimiento	2	301
510	WPN-55054979	Operativa	6	\N
511	WPN-15434698	En Mantenimiento	18	1415
512	WPN-16090698	Operativa	2	\N
513	WPN-80556719	En Mantenimiento	4	\N
514	WPN-43546389	Operativa	5	\N
515	WPN-82367848	Operativa	14	\N
516	WPN-73362434	Operativa	13	\N
1490	WPN-19037478	Operativa	19	452
520	WPN-35390631	En Mantenimiento	15	\N
522	WPN-63946556	Operativa	9	\N
524	WPN-39784491	En Mantenimiento	8	2643
526	WPN-77631799	Operativa	1	1031
528	WPN-78092307	En Mantenimiento	11	2027
529	WPN-10399948	En Mantenimiento	16	2865
534	WPN-72030812	En Mantenimiento	8	\N
535	WPN-58535169	En Mantenimiento	17	107
536	WPN-75510646	Operativa	8	\N
537	WPN-62312184	En Mantenimiento	13	2377
538	WPN-31665426	En Mantenimiento	6	\N
539	WPN-11980795	En Mantenimiento	17	\N
540	WPN-65113241	Operativa	14	\N
542	WPN-72041638	En Mantenimiento	19	794
544	WPN-45981837	En Mantenimiento	15	\N
545	WPN-41855175	En Mantenimiento	15	\N
546	WPN-87328902	Operativa	9	\N
547	WPN-19691064	Operativa	5	411
549	WPN-46006850	Operativa	2	2024
550	WPN-47599446	En Mantenimiento	10	1794
551	WPN-53725136	En Mantenimiento	12	\N
554	WPN-61460868	Operativa	18	\N
555	WPN-03195904	Operativa	15	624
556	WPN-69120397	En Mantenimiento	11	2532
558	WPN-66144884	En Mantenimiento	7	2213
560	WPN-62235103	Operativa	3	2441
563	WPN-19923257	En Mantenimiento	5	\N
565	WPN-51792732	Operativa	11	\N
566	WPN-50476607	En Mantenimiento	12	977
571	WPN-27632997	Operativa	5	\N
573	WPN-81037445	Operativa	1	\N
574	WPN-21074529	En Mantenimiento	6	\N
1492	WPN-23030154	Operativa	19	2071
577	WPN-60366055	En Mantenimiento	9	\N
579	WPN-31269820	Operativa	13	961
580	WPN-81465221	Operativa	2	2016
582	WPN-93129634	Operativa	14	\N
587	WPN-10368754	Operativa	9	\N
588	WPN-85382691	Operativa	10	\N
589	WPN-43580433	En Mantenimiento	11	2749
591	WPN-21756953	Operativa	8	1103
595	WPN-68976345	Operativa	13	\N
597	WPN-18714344	En Mantenimiento	17	2005
601	WPN-23197115	En Mantenimiento	15	1382
602	WPN-70534187	En Mantenimiento	9	420
603	WPN-47849201	En Mantenimiento	17	\N
604	WPN-62567673	En Mantenimiento	11	1975
605	WPN-27983318	Operativa	12	\N
606	WPN-67551400	En Mantenimiento	12	\N
607	WPN-52996619	En Mantenimiento	17	988
608	WPN-99308714	En Mantenimiento	16	\N
609	WPN-03681922	Operativa	11	1232
610	WPN-47994683	En Mantenimiento	9	2225
611	WPN-81790252	En Mantenimiento	17	\N
612	WPN-72930679	En Mantenimiento	16	\N
613	WPN-75240333	En Mantenimiento	7	\N
614	WPN-42567389	Operativa	11	91
615	WPN-94191232	En Mantenimiento	20	\N
616	WPN-39591326	En Mantenimiento	16	1602
618	WPN-94907091	Operativa	2	889
619	WPN-53598380	Operativa	5	1747
620	WPN-16500331	Operativa	4	\N
1493	WPN-50646905	En Mantenimiento	14	\N
623	WPN-10815379	Operativa	14	1112
624	WPN-91284883	En Mantenimiento	5	729
625	WPN-92738279	Operativa	15	\N
626	WPN-40276003	En Mantenimiento	7	\N
627	WPN-40129741	En Mantenimiento	15	\N
628	WPN-00065753	En Mantenimiento	17	\N
631	WPN-76739148	Operativa	11	\N
632	WPN-74830503	Operativa	14	\N
633	WPN-64578125	En Mantenimiento	16	14
638	WPN-98900789	En Mantenimiento	10	2310
639	WPN-75212633	Operativa	7	550
640	WPN-13195126	En Mantenimiento	9	\N
641	WPN-97337175	Operativa	11	\N
643	WPN-44470240	Operativa	12	\N
644	WPN-45481391	En Mantenimiento	12	131
645	WPN-34849161	Operativa	16	\N
648	WPN-87722598	Operativa	2	1367
649	WPN-54294337	En Mantenimiento	5	\N
650	WPN-80654364	Operativa	2	\N
651	WPN-97178637	En Mantenimiento	18	\N
652	WPN-87709167	En Mantenimiento	10	\N
653	WPN-55584130	En Mantenimiento	3	\N
654	WPN-67024904	En Mantenimiento	18	2542
1494	WPN-67747455	Operativa	6	1759
656	WPN-19469614	Operativa	7	\N
657	WPN-94797918	Operativa	5	\N
658	WPN-43226744	En Mantenimiento	13	\N
661	WPN-51328195	En Mantenimiento	8	\N
662	WPN-45446643	En Mantenimiento	9	\N
664	WPN-45605424	Operativa	18	276
665	WPN-78423327	En Mantenimiento	4	2768
666	WPN-82015769	En Mantenimiento	18	2488
668	WPN-07925529	Operativa	9	\N
669	WPN-44248930	En Mantenimiento	17	\N
670	WPN-68833092	En Mantenimiento	13	1121
672	WPN-10334448	Operativa	10	\N
673	WPN-76093530	En Mantenimiento	10	2802
674	WPN-80202657	Operativa	7	1041
675	WPN-79818475	En Mantenimiento	3	\N
676	WPN-46998746	En Mantenimiento	7	\N
677	WPN-02685234	Operativa	5	\N
678	WPN-04675972	Operativa	5	\N
679	WPN-82996707	En Mantenimiento	14	1526
680	WPN-65352255	Operativa	18	\N
682	WPN-16348109	Operativa	19	\N
683	WPN-25309745	Operativa	14	1270
684	WPN-38160648	En Mantenimiento	5	\N
685	WPN-66687534	Operativa	8	\N
687	WPN-77628634	En Mantenimiento	1	\N
688	WPN-20657180	Operativa	15	635
689	WPN-83262328	En Mantenimiento	3	694
691	WPN-25971788	Operativa	1	\N
692	WPN-29595767	Operativa	16	153
693	WPN-60230652	Operativa	10	1562
694	WPN-82494689	En Mantenimiento	9	1980
696	WPN-16783003	En Mantenimiento	14	1751
698	WPN-56942868	Operativa	10	2035
701	WPN-53997619	Operativa	2	\N
702	WPN-37278620	En Mantenimiento	2	644
703	WPN-69123084	Operativa	17	\N
704	WPN-47297795	En Mantenimiento	20	\N
705	WPN-79204219	En Mantenimiento	6	2420
706	WPN-31523810	Operativa	11	2988
707	WPN-65247874	En Mantenimiento	7	349
708	WPN-46153726	Operativa	15	2001
709	WPN-97339640	En Mantenimiento	5	2112
710	WPN-25443711	Operativa	11	\N
711	WPN-16630652	Operativa	14	2997
1495	WPN-99578627	Operativa	15	1730
713	WPN-78279463	En Mantenimiento	12	834
716	WPN-47438439	Operativa	20	\N
718	WPN-91591313	En Mantenimiento	19	2943
720	WPN-14581814	Operativa	18	2940
721	WPN-32537477	En Mantenimiento	1	\N
724	WPN-40004745	En Mantenimiento	16	\N
729	WPN-69733218	Operativa	9	1382
731	WPN-81838745	Operativa	19	\N
733	WPN-95923609	En Mantenimiento	16	\N
735	WPN-55062730	Operativa	10	\N
736	WPN-64946315	En Mantenimiento	19	2717
1496	WPN-44443420	En Mantenimiento	9	\N
739	WPN-30827528	En Mantenimiento	19	\N
740	WPN-50795719	Operativa	7	387
742	WPN-96375374	Operativa	2	2433
743	WPN-02843238	En Mantenimiento	14	2437
744	WPN-78626414	En Mantenimiento	11	1474
745	WPN-24658891	Operativa	1	2024
746	WPN-19953276	Operativa	19	\N
747	WPN-75973674	Operativa	10	582
748	WPN-48484192	Operativa	5	\N
749	WPN-47390770	Operativa	17	\N
750	WPN-60108663	Operativa	9	2831
751	WPN-45603506	En Mantenimiento	11	608
752	WPN-11310375	En Mantenimiento	17	1406
753	WPN-41783004	Operativa	12	80
757	WPN-02518158	Operativa	3	\N
758	WPN-63465676	Operativa	18	\N
1498	WPN-54433614	En Mantenimiento	16	\N
760	WPN-78952745	En Mantenimiento	13	\N
761	WPN-26408430	En Mantenimiento	13	68
762	WPN-89292846	Operativa	9	133
763	WPN-15427399	En Mantenimiento	15	2563
764	WPN-90663329	En Mantenimiento	15	\N
765	WPN-22940094	En Mantenimiento	14	1853
766	WPN-24995865	Operativa	3	\N
767	WPN-18215552	Operativa	11	79
768	WPN-28372862	En Mantenimiento	7	\N
769	WPN-27395090	En Mantenimiento	3	1091
770	WPN-22816370	En Mantenimiento	16	329
771	WPN-82178301	En Mantenimiento	11	\N
772	WPN-78978232	En Mantenimiento	13	2474
773	WPN-40112298	En Mantenimiento	20	566
775	WPN-08311289	Operativa	15	\N
776	WPN-29311020	En Mantenimiento	16	\N
777	WPN-63083419	En Mantenimiento	12	503
778	WPN-62171922	En Mantenimiento	17	558
779	WPN-73097171	En Mantenimiento	17	\N
780	WPN-37116778	En Mantenimiento	11	\N
781	WPN-74179062	En Mantenimiento	10	\N
782	WPN-89244669	En Mantenimiento	17	264
783	WPN-82904356	En Mantenimiento	19	\N
784	WPN-04981999	En Mantenimiento	4	\N
785	WPN-53476469	En Mantenimiento	17	2363
786	WPN-66179299	En Mantenimiento	8	\N
787	WPN-65882117	Operativa	3	\N
789	WPN-14037808	Operativa	12	699
790	WPN-36893839	Operativa	9	2329
791	WPN-72371585	Operativa	18	\N
792	WPN-68691799	Operativa	16	\N
794	WPN-85181204	En Mantenimiento	14	\N
796	WPN-66839549	Operativa	13	1816
797	WPN-92733365	En Mantenimiento	17	953
798	WPN-74374161	En Mantenimiento	8	\N
1499	WPN-46274667	Operativa	17	\N
800	WPN-49555813	En Mantenimiento	4	1587
803	WPN-61832740	Operativa	15	\N
805	WPN-17269276	Operativa	9	2948
806	WPN-77151737	Operativa	8	\N
810	WPN-90591629	En Mantenimiento	17	\N
811	WPN-81494368	Operativa	9	\N
812	WPN-39249204	En Mantenimiento	17	\N
815	WPN-15649992	En Mantenimiento	14	1743
816	WPN-78043494	Operativa	8	\N
819	WPN-24935607	Operativa	5	\N
820	WPN-11460609	Operativa	20	\N
821	WPN-41050836	En Mantenimiento	15	2933
822	WPN-16713380	En Mantenimiento	16	1451
823	WPN-76235396	En Mantenimiento	12	\N
825	WPN-25025417	En Mantenimiento	6	1831
826	WPN-71473172	En Mantenimiento	11	\N
828	WPN-51576819	Operativa	6	1377
829	WPN-45611310	Operativa	3	\N
830	WPN-24194446	Operativa	4	\N
831	WPN-00777100	Operativa	8	\N
835	WPN-85216646	Operativa	7	\N
839	WPN-83802956	Operativa	12	1273
840	WPN-91160333	En Mantenimiento	15	823
843	WPN-12189009	En Mantenimiento	7	\N
844	WPN-47906244	Operativa	5	2103
845	WPN-49109419	Operativa	14	2785
846	WPN-95210211	En Mantenimiento	4	\N
847	WPN-48639110	En Mantenimiento	2	\N
848	WPN-98856934	En Mantenimiento	12	967
849	WPN-87321524	Operativa	5	828
852	WPN-27058202	En Mantenimiento	11	854
853	WPN-38283656	Operativa	15	762
854	WPN-99934587	Operativa	18	410
856	WPN-57494423	En Mantenimiento	13	2871
857	WPN-70456888	En Mantenimiento	16	\N
860	WPN-49651139	En Mantenimiento	6	\N
862	WPN-58787808	En Mantenimiento	3	\N
864	WPN-54546265	En Mantenimiento	1	2837
865	WPN-61688775	En Mantenimiento	15	\N
867	WPN-67429763	En Mantenimiento	11	613
868	WPN-08557682	Operativa	13	\N
869	WPN-62394167	En Mantenimiento	10	\N
870	WPN-47723271	Operativa	11	2150
871	WPN-71170187	En Mantenimiento	18	1478
872	WPN-28634592	Operativa	8	\N
873	WPN-18187732	En Mantenimiento	14	\N
874	WPN-09787444	Operativa	16	2238
876	WPN-75131616	Operativa	8	\N
877	WPN-95557158	En Mantenimiento	20	\N
878	WPN-91309236	En Mantenimiento	17	\N
879	WPN-62318535	Operativa	8	\N
880	WPN-08678857	Operativa	17	\N
882	WPN-54917432	En Mantenimiento	9	\N
884	WPN-00712189	En Mantenimiento	1	\N
885	WPN-62705304	En Mantenimiento	18	\N
886	WPN-62742236	Operativa	19	\N
887	WPN-07281382	En Mantenimiento	9	\N
888	WPN-92415446	En Mantenimiento	1	833
889	WPN-88139075	En Mantenimiento	10	430
890	WPN-81479259	Operativa	9	2924
893	WPN-11068033	En Mantenimiento	11	2104
894	WPN-73858842	En Mantenimiento	20	1924
895	WPN-63042663	Operativa	6	836
896	WPN-29025618	Operativa	10	\N
899	WPN-77886188	Operativa	17	\N
900	WPN-84632699	En Mantenimiento	16	953
901	WPN-52448384	Operativa	13	\N
902	WPN-95510391	Operativa	9	1369
903	WPN-85410429	En Mantenimiento	8	\N
907	WPN-26908789	En Mantenimiento	15	\N
908	WPN-83252143	En Mantenimiento	10	49
909	WPN-88051954	Operativa	4	\N
910	WPN-25281777	Operativa	8	2790
911	WPN-01433383	Operativa	20	2896
912	WPN-17224187	Operativa	11	\N
913	WPN-56370756	Operativa	18	\N
914	WPN-12315045	En Mantenimiento	12	\N
915	WPN-75252363	Operativa	15	\N
919	WPN-76387718	Operativa	1	2761
921	WPN-38992016	En Mantenimiento	17	2407
923	WPN-65724570	En Mantenimiento	9	2091
924	WPN-27803510	Operativa	19	\N
925	WPN-89434811	Operativa	16	2631
926	WPN-98225600	En Mantenimiento	5	1330
930	WPN-30746193	Operativa	17	1945
933	WPN-08387261	En Mantenimiento	20	2269
934	WPN-74598647	Operativa	19	380
935	WPN-81970447	Operativa	3	52
936	WPN-43857386	Operativa	11	918
937	WPN-18779790	En Mantenimiento	20	1225
938	WPN-96782907	Operativa	3	\N
939	WPN-44835693	Operativa	16	2462
941	WPN-85324739	Operativa	16	719
943	WPN-98651379	Operativa	3	713
944	WPN-02064145	Operativa	7	1328
946	WPN-28154088	En Mantenimiento	15	403
948	WPN-28241678	Operativa	6	\N
949	WPN-86666784	Operativa	8	651
950	WPN-27315540	En Mantenimiento	6	907
951	WPN-56121962	Operativa	2	140
954	WPN-35994336	Operativa	17	\N
955	WPN-20231868	Operativa	5	1808
957	WPN-46259460	Operativa	18	2933
959	WPN-14646113	Operativa	11	\N
960	WPN-57336435	Operativa	13	\N
962	WPN-03851986	Operativa	9	\N
963	WPN-13660853	Operativa	18	323
966	WPN-30961468	Operativa	4	\N
967	WPN-89464401	En Mantenimiento	9	\N
968	WPN-38371279	En Mantenimiento	3	\N
969	WPN-91166098	En Mantenimiento	6	\N
971	WPN-62633871	Operativa	12	\N
972	WPN-60897418	Operativa	4	525
973	WPN-67602580	En Mantenimiento	10	\N
975	WPN-99588246	Operativa	15	\N
976	WPN-02565743	Operativa	6	1379
978	WPN-06106760	Operativa	14	\N
981	WPN-16549499	En Mantenimiento	12	2862
982	WPN-53773000	En Mantenimiento	2	\N
984	WPN-19177055	En Mantenimiento	10	1978
986	WPN-83835193	Operativa	3	\N
989	WPN-44522092	Operativa	13	\N
990	WPN-46636762	Operativa	1	\N
991	WPN-24430968	Operativa	8	\N
994	WPN-11691625	Operativa	1	1090
995	WPN-64392904	En Mantenimiento	2	941
996	WPN-29522387	En Mantenimiento	1	\N
997	WPN-70232698	Operativa	1	91
998	WPN-00612322	En Mantenimiento	19	1740
999	WPN-77229297	En Mantenimiento	19	\N
1000	WPN-51667286	Operativa	5	2556
1001	WPN-71267185	En Mantenimiento	10	\N
1002	WPN-93587065	En Mantenimiento	10	579
1004	WPN-74927679	En Mantenimiento	13	615
1005	WPN-25579683	En Mantenimiento	6	174
1501	WPN-66019754	En Mantenimiento	7	1656
1008	WPN-35851932	En Mantenimiento	19	1433
1009	WPN-02271792	En Mantenimiento	13	2927
1010	WPN-12474446	Operativa	13	\N
1011	WPN-39373951	En Mantenimiento	15	2249
1012	WPN-99437231	Operativa	4	686
1013	WPN-46090945	Operativa	20	\N
1014	WPN-07873266	Operativa	7	\N
1015	WPN-16317082	Operativa	17	\N
1016	WPN-69394602	En Mantenimiento	14	101
1017	WPN-42518080	Operativa	16	1587
1018	WPN-94834548	Operativa	3	\N
1019	WPN-78805355	En Mantenimiento	11	2821
1020	WPN-71548493	Operativa	17	\N
1021	WPN-36874300	Operativa	6	\N
1022	WPN-12174017	Operativa	3	1542
1023	WPN-20686987	Operativa	17	2286
1024	WPN-40219564	En Mantenimiento	14	\N
1026	WPN-37394652	Operativa	12	1233
1027	WPN-35735983	En Mantenimiento	13	998
1028	WPN-44555505	En Mantenimiento	9	1503
1030	WPN-09280532	En Mantenimiento	12	\N
1031	WPN-79383706	Operativa	11	1546
1033	WPN-76507914	En Mantenimiento	13	2376
1037	WPN-45819911	Operativa	4	2916
1038	WPN-42940179	En Mantenimiento	15	773
1039	WPN-84765474	Operativa	1	2517
1040	WPN-08487975	En Mantenimiento	11	2497
1502	WPN-27686577	Operativa	1	400
1042	WPN-50036362	Operativa	13	\N
1047	WPN-56312696	En Mantenimiento	3	2031
1048	WPN-26008983	Operativa	19	\N
1050	WPN-44397043	Operativa	5	\N
1053	WPN-87058907	En Mantenimiento	2	\N
1055	WPN-65167332	Operativa	5	\N
1056	WPN-26722110	En Mantenimiento	20	\N
1058	WPN-88838673	Operativa	20	\N
1059	WPN-11316565	Operativa	8	306
1060	WPN-69235827	Operativa	8	880
1064	WPN-44196988	Operativa	6	\N
1065	WPN-16946256	Operativa	11	1000
1066	WPN-89737240	En Mantenimiento	16	635
1067	WPN-27396049	Operativa	8	318
1068	WPN-38395402	Operativa	3	992
1069	WPN-31346248	En Mantenimiento	20	\N
1070	WPN-05205614	Operativa	15	44
1073	WPN-42010247	En Mantenimiento	10	\N
1075	WPN-69169805	Operativa	2	2029
1504	WPN-57276879	Operativa	7	859
1077	WPN-92868392	En Mantenimiento	4	1269
1078	WPN-63448790	En Mantenimiento	15	\N
1079	WPN-46128138	Operativa	16	\N
1080	WPN-03846725	Operativa	4	709
1084	WPN-74105201	Operativa	16	\N
1085	WPN-81447917	En Mantenimiento	5	\N
1087	WPN-30649910	Operativa	5	603
1088	WPN-47675232	Operativa	2	\N
1089	WPN-30226465	Operativa	4	201
1091	WPN-17539260	En Mantenimiento	19	\N
1093	WPN-86285331	En Mantenimiento	1	\N
1095	WPN-06702333	En Mantenimiento	14	1127
1097	WPN-80062963	En Mantenimiento	14	\N
1098	WPN-98263721	Operativa	2	1806
1099	WPN-84169360	Operativa	6	\N
1505	WPN-87165504	Operativa	9	\N
1103	WPN-63320423	En Mantenimiento	9	1089
1506	WPN-36408100	Operativa	14	2086
1107	WPN-17691684	En Mantenimiento	15	\N
1109	WPN-50906876	Operativa	3	\N
1110	WPN-45513692	Operativa	7	1476
1111	WPN-39504651	Operativa	19	\N
1112	WPN-81046393	Operativa	1	\N
1113	WPN-46753006	En Mantenimiento	7	\N
1114	WPN-92424441	Operativa	8	95
1115	WPN-10716580	En Mantenimiento	13	2919
1116	WPN-69098357	Operativa	4	\N
1118	WPN-17614653	En Mantenimiento	1	\N
1119	WPN-66452103	En Mantenimiento	11	83
1120	WPN-45243154	En Mantenimiento	11	\N
1121	WPN-69990003	Operativa	10	124
1122	WPN-08765706	Operativa	6	1297
1508	WPN-00483425	Operativa	8	\N
1124	WPN-75388908	Operativa	20	1308
1125	WPN-32491674	Operativa	3	\N
1126	WPN-32086191	En Mantenimiento	14	649
1127	WPN-76410298	En Mantenimiento	5	\N
1128	WPN-42986456	En Mantenimiento	19	\N
1129	WPN-37953711	Operativa	12	\N
1131	WPN-23370161	En Mantenimiento	9	\N
1132	WPN-21910715	En Mantenimiento	4	\N
1135	WPN-67622584	Operativa	14	\N
1136	WPN-38307085	Operativa	17	1270
1137	WPN-16997787	En Mantenimiento	6	1027
1138	WPN-92531709	En Mantenimiento	1	1997
1139	WPN-82692358	Operativa	17	\N
1140	WPN-47286239	En Mantenimiento	8	781
1142	WPN-00779457	En Mantenimiento	11	1147
1143	WPN-70086826	Operativa	2	1775
1146	WPN-79651540	En Mantenimiento	15	1119
1150	WPN-80148625	Operativa	19	376
1509	WPN-81544977	En Mantenimiento	10	2042
1153	WPN-82643435	En Mantenimiento	13	\N
1155	WPN-82333790	En Mantenimiento	11	\N
1157	WPN-81808481	En Mantenimiento	5	\N
1159	WPN-29353547	Operativa	3	\N
1162	WPN-78419255	Operativa	14	\N
1163	WPN-52015009	Operativa	6	1419
1166	WPN-18867801	En Mantenimiento	3	690
1167	WPN-71957426	Operativa	3	2173
1168	WPN-11667948	Operativa	7	\N
1169	WPN-29836114	Operativa	3	2518
1170	WPN-13737854	Operativa	5	\N
1173	WPN-83260551	Operativa	19	\N
1174	WPN-63977004	En Mantenimiento	6	\N
1176	WPN-80810875	Operativa	10	\N
1177	WPN-29624613	Operativa	8	1187
1179	WPN-72231825	En Mantenimiento	16	\N
1180	WPN-58783284	Operativa	1	1245
1510	WPN-65134973	Operativa	3	\N
1183	WPN-55827843	Operativa	4	\N
1186	WPN-88601728	Operativa	4	1148
1189	WPN-04838126	En Mantenimiento	5	\N
1190	WPN-20525203	Operativa	2	\N
1191	WPN-43394645	Operativa	6	36
1192	WPN-87116459	Operativa	11	1597
1193	WPN-03339717	Operativa	1	\N
1194	WPN-25735720	Operativa	17	402
1195	WPN-12812106	Operativa	15	\N
1197	WPN-85106621	Operativa	20	1119
1198	WPN-93753542	En Mantenimiento	7	\N
1201	WPN-86007214	En Mantenimiento	3	\N
1202	WPN-00884513	Operativa	1	152
1205	WPN-22883465	En Mantenimiento	10	\N
1210	WPN-20542906	En Mantenimiento	17	2349
1211	WPN-25755663	En Mantenimiento	16	1090
1212	WPN-78039834	En Mantenimiento	2	1587
1215	WPN-94967709	Operativa	17	2133
1217	WPN-30656754	Operativa	6	495
1224	WPN-29078727	Operativa	1	\N
1226	WPN-01766735	En Mantenimiento	10	\N
1227	WPN-22438569	Operativa	20	1773
1228	WPN-45285931	Operativa	12	\N
1230	WPN-39633612	Operativa	3	\N
1231	WPN-76062194	En Mantenimiento	2	\N
1236	WPN-05811233	Operativa	9	\N
1237	WPN-23206247	En Mantenimiento	13	365
1239	WPN-50461484	Operativa	20	707
1243	WPN-67747274	Operativa	5	\N
1244	WPN-72325453	Operativa	4	523
1245	WPN-62554544	Operativa	15	\N
1247	WPN-08644874	Operativa	8	1453
1248	WPN-90306419	Operativa	15	2163
1249	WPN-68004892	En Mantenimiento	3	2556
1251	WPN-28338465	En Mantenimiento	8	2173
1252	WPN-93127664	Operativa	1	991
1256	WPN-44346309	En Mantenimiento	16	1150
1257	WPN-18676863	Operativa	1	\N
1258	WPN-54190833	En Mantenimiento	4	\N
1259	WPN-73113646	Operativa	15	\N
1512	WPN-25993218	En Mantenimiento	14	1034
1263	WPN-92331636	Operativa	18	31
1264	WPN-91831520	En Mantenimiento	3	\N
1266	WPN-74191193	En Mantenimiento	5	2629
1513	WPN-41481192	En Mantenimiento	13	\N
1269	WPN-52701243	En Mantenimiento	12	2442
1270	WPN-34308838	En Mantenimiento	9	792
1271	WPN-65698803	En Mantenimiento	11	\N
1273	WPN-61768724	Operativa	1	\N
1274	WPN-38326606	En Mantenimiento	6	1343
1276	WPN-11570284	Operativa	1	\N
1277	WPN-65933306	Operativa	20	1265
1278	WPN-31686045	En Mantenimiento	20	\N
1280	WPN-59909645	En Mantenimiento	8	867
1282	WPN-52074110	Operativa	6	2654
1283	WPN-98219650	Operativa	13	1333
1285	WPN-16451266	Operativa	20	1196
1286	WPN-63009021	En Mantenimiento	14	\N
1287	WPN-53526403	Operativa	14	1329
1289	WPN-44620517	Operativa	15	\N
1290	WPN-89970268	En Mantenimiento	13	\N
1292	WPN-48446223	Operativa	20	488
1294	WPN-52553889	En Mantenimiento	19	\N
1295	WPN-28098758	En Mantenimiento	19	1798
1297	WPN-28544540	Operativa	15	\N
1298	WPN-88827620	Operativa	2	2983
1299	WPN-51238716	Operativa	13	\N
1300	WPN-95785197	Operativa	8	1412
1301	WPN-81779223	En Mantenimiento	1	\N
1302	WPN-60823914	Operativa	15	\N
1305	WPN-46419247	En Mantenimiento	8	\N
1306	WPN-17291819	Operativa	18	\N
1307	WPN-36097097	En Mantenimiento	15	644
1308	WPN-30501613	Operativa	5	\N
1309	WPN-07422878	En Mantenimiento	11	\N
1310	WPN-23173633	Operativa	4	\N
1312	WPN-89887544	Operativa	15	1487
1313	WPN-38279205	En Mantenimiento	8	\N
1315	WPN-93667178	En Mantenimiento	5	709
1317	WPN-77240959	Operativa	16	\N
1318	WPN-56818828	Operativa	3	\N
1320	WPN-27119700	En Mantenimiento	19	2786
1321	WPN-48673655	En Mantenimiento	6	\N
1323	WPN-94167309	Operativa	19	1927
1324	WPN-13114772	Operativa	1	\N
1327	WPN-07259073	En Mantenimiento	6	1471
1329	WPN-12731168	En Mantenimiento	18	\N
1330	WPN-46789198	Operativa	20	2417
1331	WPN-23572595	En Mantenimiento	8	2858
1332	WPN-57118492	En Mantenimiento	12	1848
1333	WPN-51737706	En Mantenimiento	11	237
1335	WPN-11990471	En Mantenimiento	12	2330
1336	WPN-79177487	Operativa	14	1810
1339	WPN-48595838	En Mantenimiento	2	2439
1340	WPN-88721622	En Mantenimiento	13	\N
1341	WPN-45026482	Operativa	11	127
1343	WPN-32493455	Operativa	12	1302
1346	WPN-32944792	Operativa	3	\N
1350	WPN-84795519	Operativa	10	\N
1352	WPN-96989613	En Mantenimiento	18	1376
1353	WPN-38903290	Operativa	5	491
1354	WPN-75397245	En Mantenimiento	11	\N
1355	WPN-79623424	En Mantenimiento	13	\N
1356	WPN-73999534	En Mantenimiento	13	228
1360	WPN-45382501	Operativa	11	1132
1362	WPN-14091511	Operativa	4	1104
1363	WPN-14326104	Operativa	11	\N
1364	WPN-62016409	Operativa	7	\N
1367	WPN-10352593	Operativa	11	\N
1368	WPN-39126579	En Mantenimiento	6	\N
1369	WPN-93346231	En Mantenimiento	11	\N
1370	WPN-98349073	Operativa	5	\N
1371	WPN-82723127	Operativa	4	\N
1373	WPN-31420128	Operativa	6	531
1374	WPN-56356589	En Mantenimiento	2	\N
1375	WPN-04958231	En Mantenimiento	8	\N
1376	WPN-86123925	Operativa	11	\N
1378	WPN-50964989	En Mantenimiento	14	\N
1379	WPN-20585511	Operativa	11	1952
1381	WPN-18396954	En Mantenimiento	13	\N
1382	WPN-82415607	Operativa	17	\N
1383	WPN-72094979	En Mantenimiento	18	\N
1384	WPN-27034801	Operativa	13	2168
1386	WPN-42030994	En Mantenimiento	10	\N
1389	WPN-80712205	Operativa	1	\N
1391	WPN-54699374	Operativa	2	1729
1392	WPN-03347489	En Mantenimiento	4	1552
1394	WPN-22516402	Operativa	20	2936
1395	WPN-01186371	En Mantenimiento	18	2590
1397	WPN-88728695	Operativa	3	\N
1398	WPN-39766740	En Mantenimiento	12	\N
1399	WPN-71420583	En Mantenimiento	10	\N
1403	WPN-71144457	Operativa	17	223
1404	WPN-23396172	Operativa	13	1344
1407	WPN-77375285	Operativa	2	\N
1409	WPN-83433107	Operativa	4	1693
1410	WPN-56436275	Operativa	4	\N
1413	WPN-12505225	Operativa	10	2485
1417	WPN-94179203	Operativa	11	\N
1418	WPN-88737766	En Mantenimiento	14	2521
1419	WPN-37575661	En Mantenimiento	14	1279
1423	WPN-28790333	En Mantenimiento	4	2676
1425	WPN-57144298	En Mantenimiento	17	\N
1426	WPN-59767800	Operativa	14	2867
1427	WPN-94638890	En Mantenimiento	3	\N
1428	WPN-83261089	Operativa	18	\N
1430	WPN-30688949	Operativa	2	2464
1431	WPN-03238646	Operativa	14	\N
1432	WPN-74522153	Operativa	5	746
1514	WPN-63681704	Operativa	4	1241
1434	WPN-69091951	En Mantenimiento	16	\N
1436	WPN-60015231	Operativa	20	1008
1437	WPN-62989389	En Mantenimiento	1	\N
1440	WPN-14184354	Operativa	19	\N
1441	WPN-11612390	En Mantenimiento	20	\N
1442	WPN-49580835	Operativa	20	\N
1444	WPN-66282474	Operativa	19	1708
1445	WPN-98669984	Operativa	8	\N
1446	WPN-98110555	En Mantenimiento	4	2893
1453	WPN-55379548	En Mantenimiento	18	1570
1454	WPN-01358130	Operativa	2	2768
1455	WPN-77292700	En Mantenimiento	14	889
1457	WPN-65697064	Operativa	14	2260
1458	WPN-01013263	Operativa	10	663
1460	WPN-91186450	En Mantenimiento	17	\N
1464	WPN-65244492	En Mantenimiento	7	\N
1466	WPN-44297551	Operativa	9	320
1468	WPN-22156588	En Mantenimiento	19	121
1469	WPN-30685430	Operativa	18	2612
1471	WPN-37786445	Operativa	18	2998
1472	WPN-90079491	En Mantenimiento	1	2104
1473	WPN-95490358	Operativa	1	1371
1481	WPN-58303030	En Mantenimiento	5	2859
1478	WPN-31902044	Operativa	9	\N
1479	WPN-89196233	En Mantenimiento	5	1297
1517	WPN-41107554	En Mantenimiento	5	1075
1518	WPN-82155750	En Mantenimiento	15	\N
1519	WPN-16190162	Operativa	14	\N
1521	WPN-42215016	En Mantenimiento	14	2416
1522	WPN-85444802	Operativa	6	2914
1525	WPN-37095349	En Mantenimiento	6	\N
1526	WPN-90470403	Operativa	18	2469
1527	WPN-80246793	Operativa	17	\N
1528	WPN-45251546	Operativa	11	658
1529	WPN-61415922	Operativa	8	\N
1530	WPN-61849758	En Mantenimiento	18	2590
1531	WPN-63840463	Operativa	6	\N
1533	WPN-42304349	Operativa	13	\N
1534	WPN-73292581	Operativa	16	1563
1535	WPN-47883397	En Mantenimiento	1	\N
1537	WPN-89818477	En Mantenimiento	5	2943
1540	WPN-97969127	Operativa	9	1894
1541	WPN-35316231	Operativa	13	2681
1542	WPN-50252048	Operativa	12	\N
1543	WPN-39949770	En Mantenimiento	6	\N
1545	WPN-35279663	En Mantenimiento	11	582
1546	WPN-46052376	Operativa	18	2660
1549	WPN-45561835	Operativa	13	2143
1551	WPN-58290634	En Mantenimiento	10	\N
1552	WPN-11778559	En Mantenimiento	10	\N
1554	WPN-96057542	En Mantenimiento	5	\N
1555	WPN-96036032	En Mantenimiento	17	2906
1556	WPN-75489791	Operativa	6	\N
1557	WPN-55432938	En Mantenimiento	20	\N
1558	WPN-26085840	Operativa	20	\N
1560	WPN-85048010	En Mantenimiento	10	\N
1562	WPN-74248072	En Mantenimiento	15	\N
1563	WPN-02918461	Operativa	16	\N
1564	WPN-23215814	Operativa	12	1649
1565	WPN-14428026	Operativa	8	\N
1566	WPN-22204803	Operativa	9	371
1568	WPN-24816155	En Mantenimiento	13	2799
1569	WPN-87450844	Operativa	17	458
1570	WPN-83968163	En Mantenimiento	11	1449
1571	WPN-25920922	Operativa	1	\N
1573	WPN-72226181	Operativa	2	\N
1574	WPN-28299721	En Mantenimiento	11	\N
1575	WPN-11619117	En Mantenimiento	4	\N
1576	WPN-10978201	En Mantenimiento	18	\N
1578	WPN-31060393	Operativa	4	584
1579	WPN-67268259	Operativa	15	2622
1580	WPN-17806255	Operativa	20	524
1582	WPN-63041680	Operativa	7	\N
1585	WPN-61624057	Operativa	11	404
1586	WPN-02876563	Operativa	4	\N
1591	WPN-57802362	Operativa	13	\N
1592	WPN-50822605	Operativa	18	730
1593	WPN-27654111	Operativa	5	1411
1595	WPN-45021713	En Mantenimiento	1	\N
1599	WPN-01193682	En Mantenimiento	5	\N
1600	WPN-78666299	En Mantenimiento	2	\N
1602	WPN-14822506	Operativa	18	2982
1603	WPN-34761678	En Mantenimiento	19	\N
1605	WPN-48371923	En Mantenimiento	15	2076
1607	WPN-04854143	Operativa	5	303
1608	WPN-20209542	En Mantenimiento	20	2029
1610	WPN-81983590	Operativa	2	1322
1611	WPN-46547263	Operativa	3	2027
1615	WPN-95149589	Operativa	20	372
1616	WPN-38641855	En Mantenimiento	1	2316
1617	WPN-93859480	En Mantenimiento	5	2022
1618	WPN-24732634	Operativa	19	\N
1619	WPN-01494302	En Mantenimiento	12	870
1621	WPN-01078160	En Mantenimiento	3	2307
1622	WPN-29897461	En Mantenimiento	3	2163
1623	WPN-27683461	Operativa	4	1758
1624	WPN-66619546	Operativa	5	1143
1626	WPN-63853314	En Mantenimiento	7	\N
1627	WPN-80546069	Operativa	20	\N
1636	WPN-29183340	Operativa	12	518
1637	WPN-62265273	Operativa	1	\N
1638	WPN-76272709	Operativa	17	\N
1643	WPN-74378742	Operativa	10	2862
1645	WPN-62547860	En Mantenimiento	12	926
1646	WPN-64884369	Operativa	17	\N
1647	WPN-04870345	Operativa	19	1710
1649	WPN-89011166	Operativa	8	1467
1650	WPN-65798914	Operativa	6	2753
1651	WPN-18090814	Operativa	6	903
1652	WPN-80767426	Operativa	20	\N
1654	WPN-89131282	Operativa	2	\N
1656	WPN-60758724	En Mantenimiento	16	\N
1657	WPN-69209877	Operativa	2	2756
1658	WPN-37907745	En Mantenimiento	10	\N
1659	WPN-64460885	Operativa	11	2832
1661	WPN-70889047	En Mantenimiento	7	\N
1663	WPN-33924589	Operativa	20	\N
1667	WPN-07160690	En Mantenimiento	17	194
1668	WPN-77632035	En Mantenimiento	15	2125
1669	WPN-98448464	En Mantenimiento	14	\N
1670	WPN-49500493	Operativa	10	232
1671	WPN-61210128	En Mantenimiento	13	\N
1673	WPN-15412003	Operativa	5	\N
1676	WPN-77028256	Operativa	20	375
1677	WPN-15699278	En Mantenimiento	19	\N
1678	WPN-56313381	Operativa	14	1163
1679	WPN-63180293	Operativa	20	\N
1681	WPN-26876241	Operativa	14	726
1682	WPN-32153998	Operativa	7	387
1684	WPN-90008227	En Mantenimiento	7	\N
1685	WPN-63657775	Operativa	7	965
1686	WPN-43342084	Operativa	5	\N
1687	WPN-44545650	En Mantenimiento	15	\N
1689	WPN-37868684	En Mantenimiento	8	2854
1690	WPN-60668216	En Mantenimiento	9	\N
1693	WPN-39117390	Operativa	1	\N
1695	WPN-81905919	En Mantenimiento	15	\N
1696	WPN-84106534	Operativa	2	\N
1697	WPN-48257006	En Mantenimiento	16	864
1698	WPN-94701584	En Mantenimiento	13	359
1701	WPN-22066729	En Mantenimiento	8	521
1702	WPN-87012655	Operativa	17	\N
1704	WPN-38387157	Operativa	1	\N
1705	WPN-93513926	En Mantenimiento	18	217
1707	WPN-98449991	En Mantenimiento	13	741
1709	WPN-14454283	En Mantenimiento	17	2055
1710	WPN-77319693	En Mantenimiento	19	2092
1711	WPN-35059185	Operativa	8	\N
1712	WPN-70382747	Operativa	14	461
1713	WPN-96389960	En Mantenimiento	12	\N
1714	WPN-10299148	Operativa	9	419
1717	WPN-19018596	En Mantenimiento	20	\N
1718	WPN-54162537	En Mantenimiento	9	1364
1719	WPN-19112669	En Mantenimiento	6	\N
1720	WPN-74449506	Operativa	17	2148
1721	WPN-03610767	En Mantenimiento	18	728
1722	WPN-76130185	Operativa	16	1982
1723	WPN-94789812	En Mantenimiento	14	\N
1725	WPN-80951391	Operativa	16	\N
1727	WPN-35839692	En Mantenimiento	6	720
1729	WPN-47694305	Operativa	13	601
1730	WPN-59096513	En Mantenimiento	8	\N
1731	WPN-60138681	En Mantenimiento	12	\N
1732	WPN-81690907	En Mantenimiento	12	\N
1734	WPN-47328017	Operativa	10	\N
1737	WPN-87516022	Operativa	16	67
1739	WPN-93219450	En Mantenimiento	4	\N
1740	WPN-60047096	En Mantenimiento	4	\N
1743	WPN-51191648	Operativa	19	2453
1744	WPN-94397315	En Mantenimiento	13	1418
1745	WPN-39922123	Operativa	5	\N
1747	WPN-05106487	En Mantenimiento	16	\N
1750	WPN-67292707	En Mantenimiento	8	\N
1752	WPN-04016323	Operativa	7	768
1753	WPN-21356993	En Mantenimiento	6	\N
1754	WPN-56578389	En Mantenimiento	5	\N
1755	WPN-97734855	En Mantenimiento	3	\N
1757	WPN-05271311	En Mantenimiento	10	\N
1758	WPN-77018378	En Mantenimiento	12	\N
1759	WPN-00491712	En Mantenimiento	9	\N
1761	WPN-34246820	En Mantenimiento	8	629
1762	WPN-37893551	Operativa	12	\N
1763	WPN-69574014	Operativa	5	\N
1765	WPN-74772333	Operativa	1	1394
1766	WPN-77004178	Operativa	20	328
1767	WPN-26248104	En Mantenimiento	11	2365
1768	WPN-36742722	Operativa	17	350
1769	WPN-70820803	Operativa	3	2182
1770	WPN-97459758	Operativa	11	\N
1771	WPN-01038048	En Mantenimiento	16	2157
1773	WPN-60126509	Operativa	6	2099
1774	WPN-86768618	En Mantenimiento	7	864
1776	WPN-93480280	Operativa	6	1944
1777	WPN-06042562	En Mantenimiento	8	738
1779	WPN-75734288	En Mantenimiento	12	\N
1780	WPN-22629362	En Mantenimiento	1	197
1781	WPN-38635885	En Mantenimiento	4	\N
1782	WPN-16439590	En Mantenimiento	6	\N
1784	WPN-77655921	En Mantenimiento	5	\N
1785	WPN-63071298	Operativa	6	2575
1787	WPN-74063251	Operativa	10	\N
1788	WPN-35715330	Operativa	2	\N
1791	WPN-52157398	Operativa	1	\N
1793	WPN-31785086	Operativa	8	504
1796	WPN-47763898	En Mantenimiento	2	\N
1797	WPN-08630562	En Mantenimiento	16	462
1798	WPN-40410263	En Mantenimiento	19	\N
1799	WPN-92025428	Operativa	9	3
1801	WPN-47334832	Operativa	17	7
1802	WPN-01659570	En Mantenimiento	2	\N
1803	WPN-44228608	Operativa	4	\N
1804	WPN-39447484	En Mantenimiento	4	885
1805	WPN-35292101	Operativa	8	\N
1806	WPN-23022905	Operativa	14	\N
1807	WPN-55814252	En Mantenimiento	4	2829
1808	WPN-93963606	En Mantenimiento	3	1035
1810	WPN-72573833	Operativa	8	2379
1811	WPN-51746713	Operativa	20	1416
1812	WPN-52658456	Operativa	17	\N
1813	WPN-20298216	En Mantenimiento	8	1203
1815	WPN-30591385	Operativa	20	620
1816	WPN-49786226	Operativa	15	\N
1821	WPN-59433533	En Mantenimiento	19	\N
1822	WPN-76243838	En Mantenimiento	11	\N
1823	WPN-22185504	Operativa	19	\N
1824	WPN-66041026	Operativa	11	1522
1826	WPN-29697831	Operativa	3	\N
1829	WPN-55048302	Operativa	7	777
1830	WPN-41825401	Operativa	7	2495
1834	WPN-72440999	En Mantenimiento	6	\N
1835	WPN-74765918	En Mantenimiento	11	\N
1836	WPN-80101385	En Mantenimiento	8	\N
1837	WPN-82153847	En Mantenimiento	10	\N
1838	WPN-06120561	Operativa	8	\N
1840	WPN-03529259	Operativa	3	\N
1841	WPN-11596700	Operativa	17	\N
1842	WPN-95896501	En Mantenimiento	12	\N
1843	WPN-50444633	En Mantenimiento	9	729
1844	WPN-91667818	Operativa	14	\N
1845	WPN-83851716	Operativa	12	\N
1847	WPN-22672560	En Mantenimiento	15	588
1849	WPN-10085638	En Mantenimiento	11	\N
141	WPN-03991492	Dañada	16	\N
143	WPN-93156922	Dañada	13	\N
1853	WPN-45921454	Operativa	7	\N
1854	WPN-03703054	En Mantenimiento	15	\N
3	WPN-14472752	Da¤ada	17	\N
1856	WPN-46095178	Operativa	1	\N
144	WPN-40189087	Dañada	14	\N
1858	WPN-69875396	En Mantenimiento	2	\N
1859	WPN-87250491	Operativa	9	\N
1860	WPN-31890362	En Mantenimiento	13	\N
148	WPN-26951854	Dañada	13	\N
1862	WPN-41177242	En Mantenimiento	3	2639
1863	WPN-74401257	Operativa	12	\N
157	WPN-92652889	Dañada	3	\N
159	WPN-80636366	Dañada	3	\N
1866	WPN-34557866	Operativa	3	\N
160	WPN-42904048	Dañada	15	\N
1868	WPN-71781808	En Mantenimiento	20	2879
161	WPN-49556034	Dañada	7	\N
164	WPN-41812042	Dañada	17	\N
167	WPN-50416729	Dañada	14	\N
1872	WPN-42786317	Operativa	6	2909
178	WPN-13597687	Dañada	10	\N
1874	WPN-83096145	En Mantenimiento	2	\N
1875	WPN-96607524	En Mantenimiento	14	\N
1876	WPN-11365903	En Mantenimiento	2	1015
180	WPN-14495691	Dañada	17	\N
186	WPN-81971554	Dañada	13	\N
1879	WPN-89223747	Operativa	8	\N
1880	WPN-47219206	Operativa	16	\N
1881	WPN-87804074	Operativa	16	2304
187	WPN-16380414	Dañada	11	\N
188	WPN-69736410	Dañada	10	\N
191	WPN-03716171	Dañada	5	\N
1884	WPN-69060680	Operativa	16	1430
1886	WPN-66183014	Operativa	9	3000
1887	WPN-86142754	Operativa	17	313
1889	WPN-63414838	Operativa	3	1155
1890	WPN-81428694	Operativa	20	673
1891	WPN-50153670	En Mantenimiento	8	\N
1892	WPN-90030881	Operativa	16	\N
1893	WPN-90668753	Operativa	19	\N
1894	WPN-25120415	En Mantenimiento	16	1556
29	WPN-78238705	Dañada	4	\N
30	WPN-68808735	Dañada	6	\N
1897	WPN-91290593	En Mantenimiento	8	\N
1898	WPN-98752633	Operativa	8	1046
1899	WPN-46814649	En Mantenimiento	15	\N
1900	WPN-31260358	Operativa	7	1163
36	WPN-10623851	Dañada	17	\N
37	WPN-38477826	Dañada	12	\N
1903	WPN-13016922	Operativa	8	\N
38	WPN-85786163	Dañada	15	\N
1905	WPN-99508061	Operativa	10	1894
47	WPN-57631352	Dañada	7	\N
1907	WPN-84779436	Operativa	19	2850
1908	WPN-66684707	Operativa	10	1818
1909	WPN-90321335	En Mantenimiento	1	\N
1910	WPN-03882127	En Mantenimiento	20	\N
1911	WPN-85250006	Operativa	16	\N
48	WPN-70889876	Dañada	14	\N
1913	WPN-13211263	Operativa	19	252
1914	WPN-87527821	En Mantenimiento	3	1395
49	WPN-78679329	Dañada	7	\N
1916	WPN-75031213	Operativa	17	\N
1917	WPN-69088020	En Mantenimiento	9	\N
1918	WPN-92915207	En Mantenimiento	13	1925
51	WPN-65602031	Dañada	15	\N
1920	WPN-88078406	En Mantenimiento	4	\N
1921	WPN-88440599	Operativa	5	\N
1922	WPN-03858787	En Mantenimiento	1	1759
53	WPN-06934064	Dañada	10	\N
1924	WPN-92568275	En Mantenimiento	3	\N
1925	WPN-79368921	Operativa	4	1822
55	WPN-20120258	Dañada	16	\N
58	WPN-32313815	Dañada	12	\N
1928	WPN-98624420	En Mantenimiento	18	\N
69	WPN-23190012	Dañada	19	\N
1930	WPN-67152366	Operativa	15	\N
1931	WPN-17173739	En Mantenimiento	9	938
1932	WPN-36999116	Operativa	12	\N
1933	WPN-21303885	En Mantenimiento	19	247
71	WPN-24142957	Dañada	10	\N
1935	WPN-29892040	En Mantenimiento	6	1986
1936	WPN-77118404	Operativa	16	\N
73	WPN-18570557	Dañada	10	\N
75	WPN-36019981	Dañada	18	\N
1939	WPN-20710363	En Mantenimiento	10	\N
76	WPN-62001445	Dañada	14	\N
1941	WPN-67297374	Operativa	4	\N
77	WPN-07524253	Dañada	18	\N
1943	WPN-10189336	En Mantenimiento	12	331
1944	WPN-10589522	Operativa	3	\N
81	WPN-43824439	Dañada	4	\N
1946	WPN-87166358	En Mantenimiento	1	\N
1947	WPN-30591350	Operativa	15	\N
1948	WPN-41193495	En Mantenimiento	13	2598
85	WPN-61634364	Dañada	13	\N
1484	WPN-50455321	Dañada	18	\N
1951	WPN-55405336	Operativa	18	2740
1952	WPN-82477651	Operativa	6	\N
89	WPN-48973795	Dañada	20	\N
1954	WPN-29800434	En Mantenimiento	8	\N
1955	WPN-86313449	En Mantenimiento	13	2013
1956	WPN-28869108	En Mantenimiento	2	1656
91	WPN-54772597	Dañada	4	\N
1958	WPN-67138664	Operativa	17	2088
1485	WPN-54770342	Dañada	4	\N
97	WPN-47654771	Dañada	4	\N
1961	WPN-24525734	Operativa	7	\N
1962	WPN-23428177	Operativa	17	\N
1963	WPN-57346047	En Mantenimiento	14	\N
100	WPN-20753879	Dañada	8	\N
1965	WPN-01142746	Operativa	4	\N
1966	WPN-87723418	En Mantenimiento	5	\N
1967	WPN-35708821	En Mantenimiento	14	\N
1968	WPN-93719178	En Mantenimiento	15	601
1969	WPN-19132827	En Mantenimiento	7	2825
1970	WPN-15944985	En Mantenimiento	15	\N
103	WPN-35707948	Dañada	12	\N
1972	WPN-48085595	En Mantenimiento	19	2997
1973	WPN-03072959	En Mantenimiento	17	791
1974	WPN-16084666	En Mantenimiento	15	2641
104	WPN-13597333	Dañada	7	\N
1976	WPN-17288053	Operativa	6	2376
1977	WPN-25340978	Operativa	3	\N
105	WPN-67671505	Dañada	17	\N
1979	WPN-78886575	En Mantenimiento	13	2020
1980	WPN-65986321	En Mantenimiento	6	1557
1981	WPN-86842455	Operativa	5	\N
1982	WPN-37888596	Operativa	17	2577
1983	WPN-45992914	En Mantenimiento	13	366
107	WPN-00965981	Dañada	8	\N
1985	WPN-08356958	Operativa	14	\N
109	WPN-54066683	Dañada	12	\N
1987	WPN-97782710	En Mantenimiento	8	2578
110	WPN-45841143	Dañada	20	\N
111	WPN-59156289	Dañada	15	\N
1990	WPN-53976529	Operativa	6	986
1991	WPN-77693945	Operativa	8	924
1992	WPN-91219111	Operativa	6	\N
1993	WPN-97839166	En Mantenimiento	20	\N
1994	WPN-55640999	Operativa	14	\N
1995	WPN-03204310	Operativa	18	1374
112	WPN-62982606	Dañada	8	\N
1997	WPN-25544119	En Mantenimiento	6	2
1998	WPN-24384822	Operativa	10	349
113	WPN-77569028	Dañada	13	\N
115	WPN-71959962	Dañada	12	\N
117	WPN-97812655	Dañada	12	\N
119	WPN-70912868	Dañada	19	\N
121	WPN-96984896	Dañada	4	\N
126	WPN-27727064	Dañada	17	\N
128	WPN-22499076	Dañada	18	\N
129	WPN-85932690	Dañada	7	\N
136	WPN-84421331	Dañada	16	\N
197	WPN-23565859	Dañada	16	\N
198	WPN-26877689	Dañada	17	\N
200	WPN-73132046	Dañada	14	\N
201	WPN-72593719	Dañada	9	\N
204	WPN-65014094	Dañada	19	\N
206	WPN-93584479	Dañada	9	\N
213	WPN-96484278	Dañada	3	\N
216	WPN-11859172	Dañada	5	\N
224	WPN-39168951	Dañada	13	\N
228	WPN-01533220	Dañada	12	\N
232	WPN-21782059	Dañada	16	\N
234	WPN-93172528	Dañada	9	\N
237	WPN-26756942	Dañada	9	\N
246	WPN-60314504	Dañada	20	\N
247	WPN-08590229	Dañada	9	\N
252	WPN-72305090	Dañada	10	\N
253	WPN-91314643	Dañada	3	\N
256	WPN-58525323	Dañada	5	\N
258	WPN-51873344	Dañada	1	\N
267	WPN-73961582	Dañada	20	\N
271	WPN-88638218	Dañada	14	\N
277	WPN-82695260	Dañada	8	\N
278	WPN-88750796	Dañada	8	\N
282	WPN-33087607	Dañada	15	\N
283	WPN-07217609	Dañada	5	\N
285	WPN-75024507	Dañada	7	\N
289	WPN-36293905	Dañada	9	\N
291	WPN-78286232	Dañada	16	\N
294	WPN-63954778	Dañada	8	\N
296	WPN-87007848	Dañada	5	\N
299	WPN-94866528	Dañada	3	\N
300	WPN-22366684	Dañada	8	\N
304	WPN-49874116	Dañada	6	\N
1632	WPN-07894472	Dañada	16	\N
314	WPN-53910954	Dañada	14	\N
317	WPN-50709596	Dañada	2	\N
318	WPN-15399178	Dañada	3	\N
324	WPN-09485932	Dañada	7	\N
326	WPN-99023177	Dañada	18	\N
338	WPN-22798218	Dañada	19	\N
347	WPN-22649354	Dañada	12	\N
349	WPN-63527556	Dañada	7	\N
351	WPN-44936361	Dañada	20	\N
356	WPN-38648106	Dañada	18	\N
361	WPN-87846060	Dañada	7	\N
366	WPN-48581587	Dañada	1	\N
371	WPN-33776313	Dañada	13	\N
373	WPN-55103275	Dañada	19	\N
382	WPN-24283980	Dañada	20	\N
383	WPN-56914327	Dañada	4	\N
384	WPN-46610109	Dañada	13	\N
385	WPN-69934879	Dañada	9	\N
386	WPN-28525544	Dañada	15	\N
388	WPN-02600733	Dañada	7	\N
390	WPN-32674873	Dañada	15	\N
394	WPN-08187153	Dañada	15	\N
397	WPN-70569049	Dañada	20	\N
398	WPN-11498983	Dañada	17	\N
399	WPN-87196098	Dañada	4	\N
400	WPN-08978127	Dañada	20	\N
401	WPN-06356643	Dañada	10	\N
405	WPN-08042980	Dañada	10	\N
409	WPN-88975084	Dañada	9	\N
415	WPN-71360178	Dañada	2	\N
426	WPN-92097868	Dañada	16	\N
430	WPN-87924049	Dañada	3	\N
431	WPN-44826823	Dañada	16	\N
433	WPN-14517728	Dañada	9	\N
435	WPN-76638787	Dañada	18	\N
442	WPN-17115529	Dañada	1	\N
443	WPN-22993212	Dañada	18	\N
445	WPN-88422465	Dañada	13	\N
446	WPN-70278970	Dañada	18	\N
449	WPN-62748167	Dañada	1	\N
450	WPN-75622392	Dañada	1	\N
456	WPN-95092674	Dañada	1	\N
460	WPN-75348723	Dañada	7	\N
461	WPN-45850999	Dañada	19	\N
464	WPN-19232334	Dañada	5	\N
465	WPN-78367869	Dañada	8	\N
466	WPN-25989307	Dañada	20	\N
469	WPN-30519180	Dañada	16	\N
470	WPN-32869950	Dañada	12	\N
476	WPN-01276775	Dañada	19	\N
479	WPN-98192127	Dañada	17	\N
480	WPN-12757828	Dañada	20	\N
481	WPN-44793077	Dañada	19	\N
483	WPN-44847722	Dañada	10	\N
484	WPN-66562791	Dañada	20	\N
491	WPN-21197339	Dañada	1	\N
496	WPN-41816142	Dañada	10	\N
500	WPN-89712958	Dañada	10	\N
502	WPN-73230058	Dañada	18	\N
503	WPN-75775187	Dañada	14	\N
504	WPN-62867994	Dañada	14	\N
509	WPN-72635862	Dañada	1	\N
517	WPN-86439879	Dañada	1	\N
519	WPN-67705507	Dañada	1	\N
521	WPN-50008462	Dañada	19	\N
523	WPN-97731653	Dañada	1	\N
525	WPN-85129902	Dañada	10	\N
527	WPN-80854537	Dañada	9	\N
530	WPN-44067088	Dañada	1	\N
531	WPN-65106069	Dañada	14	\N
532	WPN-49835736	Dañada	8	\N
533	WPN-62989244	Dañada	8	\N
541	WPN-52277262	Dañada	18	\N
543	WPN-06636430	Dañada	17	\N
548	WPN-98137568	Dañada	13	\N
552	WPN-64874763	Dañada	9	\N
553	WPN-68200623	Dañada	19	\N
557	WPN-45203821	Dañada	10	\N
559	WPN-25629146	Dañada	7	\N
561	WPN-13313812	Dañada	4	\N
562	WPN-79670657	Dañada	2	\N
1491	WPN-46159058	Dañada	14	\N
567	WPN-61945767	Dañada	6	\N
568	WPN-92291635	Dañada	8	\N
569	WPN-74612168	Dañada	1	\N
570	WPN-01101580	Dañada	20	\N
572	WPN-57523370	Dañada	6	\N
575	WPN-27508009	Dañada	14	\N
578	WPN-20339117	Dañada	20	\N
581	WPN-13934129	Dañada	5	\N
583	WPN-46527012	Dañada	13	\N
584	WPN-25569003	Dañada	3	\N
585	WPN-00164852	Dañada	17	\N
586	WPN-90576331	Dañada	3	\N
590	WPN-26668914	Dañada	14	\N
592	WPN-11045110	Dañada	3	\N
593	WPN-96599110	Dañada	17	\N
594	WPN-67356875	Dañada	12	\N
596	WPN-99219770	Dañada	4	\N
598	WPN-07620555	Dañada	15	\N
599	WPN-62106932	Dañada	5	\N
600	WPN-17533238	Dañada	13	\N
617	WPN-89331217	Dañada	1	\N
622	WPN-60491615	Dañada	5	\N
629	WPN-58608999	Dañada	7	\N
630	WPN-76912515	Dañada	9	\N
634	WPN-30125002	Dañada	16	\N
635	WPN-53236950	Dañada	8	\N
636	WPN-39226909	Dañada	3	\N
637	WPN-06516905	Dañada	14	\N
642	WPN-07098191	Dañada	3	\N
646	WPN-09104712	Dañada	10	\N
647	WPN-51222904	Dañada	3	\N
659	WPN-32022051	Dañada	13	\N
660	WPN-50544231	Dañada	10	\N
663	WPN-53937273	Dañada	1	\N
667	WPN-25563611	Dañada	20	\N
671	WPN-11670652	Dañada	14	\N
681	WPN-44791641	Dañada	2	\N
686	WPN-45367783	Dañada	15	\N
690	WPN-45460164	Dañada	13	\N
695	WPN-48360721	Dañada	3	\N
697	WPN-28199550	Dañada	6	\N
699	WPN-51745051	Dañada	17	\N
700	WPN-38918423	Dañada	18	\N
714	WPN-15039906	Dañada	10	\N
715	WPN-97537412	Dañada	18	\N
717	WPN-35366627	Dañada	19	\N
719	WPN-82561037	Dañada	7	\N
722	WPN-64772545	Dañada	9	\N
723	WPN-42132832	Dañada	15	\N
725	WPN-94479493	Dañada	6	\N
726	WPN-99019770	Dañada	10	\N
727	WPN-72370892	Dañada	11	\N
728	WPN-25343819	Dañada	5	\N
730	WPN-06409450	Dañada	4	\N
732	WPN-60595991	Dañada	4	\N
734	WPN-78084931	Dañada	12	\N
1497	WPN-70903770	Dañada	19	\N
741	WPN-78794995	Dañada	1	\N
754	WPN-02015700	Dañada	1	\N
755	WPN-06417116	Dañada	15	\N
756	WPN-84497221	Dañada	4	\N
774	WPN-78448425	Dañada	18	\N
788	WPN-49855313	Dañada	9	\N
793	WPN-35885609	Dañada	13	\N
795	WPN-22947591	Dañada	11	\N
801	WPN-68013443	Dañada	14	\N
802	WPN-47939363	Dañada	14	\N
804	WPN-02471462	Dañada	1	\N
807	WPN-60036833	Dañada	13	\N
808	WPN-27203444	Dañada	13	\N
809	WPN-30291203	Dañada	2	\N
813	WPN-56224663	Dañada	12	\N
814	WPN-24066691	Dañada	16	\N
817	WPN-27171433	Dañada	7	\N
818	WPN-55501656	Dañada	11	\N
824	WPN-97271028	Dañada	15	\N
827	WPN-00029316	Dañada	8	\N
832	WPN-65956226	Dañada	8	\N
833	WPN-19710571	Dañada	4	\N
834	WPN-90360156	Dañada	9	\N
1500	WPN-22895414	Dañada	4	\N
837	WPN-43742843	Dañada	12	\N
838	WPN-61641712	Dañada	13	\N
841	WPN-66528402	Dañada	1	\N
842	WPN-19522436	Dañada	6	\N
850	WPN-02617262	Dañada	20	\N
851	WPN-63164813	Dañada	6	\N
855	WPN-38252598	Dañada	17	\N
858	WPN-07189772	Dañada	4	\N
859	WPN-53753305	Dañada	18	\N
861	WPN-41028081	Dañada	18	\N
1635	WPN-18136729	Dañada	14	\N
866	WPN-95245858	Dañada	7	\N
875	WPN-12045396	Dañada	8	\N
881	WPN-34897966	Dañada	14	\N
883	WPN-12445898	Dañada	12	\N
891	WPN-93480136	Dañada	18	\N
892	WPN-24952912	Dañada	9	\N
897	WPN-60483718	Dañada	8	\N
898	WPN-98155986	Dañada	9	\N
904	WPN-06095561	Dañada	1	\N
905	WPN-52898218	Dañada	10	\N
906	WPN-63900747	Dañada	18	\N
916	WPN-61028050	Dañada	8	\N
917	WPN-30129306	Dañada	16	\N
918	WPN-88222173	Dañada	2	\N
920	WPN-00830691	Dañada	18	\N
922	WPN-03344485	Dañada	9	\N
927	WPN-08139512	Dañada	14	\N
928	WPN-29641224	Dañada	11	\N
929	WPN-62308581	Dañada	16	\N
931	WPN-00401285	Dañada	18	\N
932	WPN-39082962	Dañada	13	\N
940	WPN-86854444	Dañada	18	\N
942	WPN-81968930	Dañada	19	\N
945	WPN-68087674	Dañada	1	\N
947	WPN-93636602	Dañada	19	\N
952	WPN-88325024	Dañada	20	\N
953	WPN-18564881	Dañada	1	\N
956	WPN-91958625	Dañada	18	\N
958	WPN-75581389	Dañada	17	\N
961	WPN-35098343	Dañada	3	\N
964	WPN-04616153	Dañada	18	\N
965	WPN-20143289	Dañada	13	\N
970	WPN-02672610	Dañada	16	\N
974	WPN-00882524	Dañada	17	\N
977	WPN-29675203	Dañada	14	\N
979	WPN-68249412	Dañada	12	\N
980	WPN-67791379	Dañada	9	\N
983	WPN-86322826	Dañada	11	\N
985	WPN-63186131	Dañada	16	\N
987	WPN-56599968	Dañada	20	\N
988	WPN-01239679	Dañada	13	\N
992	WPN-04142447	Dañada	3	\N
993	WPN-57560847	Dañada	4	\N
1003	WPN-57709567	Dañada	9	\N
1006	WPN-22376510	Dañada	12	\N
1025	WPN-26507228	Dañada	20	\N
1029	WPN-72914033	Dañada	11	\N
1032	WPN-83670889	Dañada	12	\N
1034	WPN-07975550	Dañada	17	\N
1035	WPN-99697671	Dañada	2	\N
1036	WPN-40645231	Dañada	20	\N
1043	WPN-68417580	Dañada	6	\N
1044	WPN-12247366	Dañada	13	\N
1045	WPN-48170563	Dañada	2	\N
1046	WPN-01441429	Dañada	7	\N
1049	WPN-80255950	Dañada	3	\N
1051	WPN-92929267	Dañada	9	\N
1052	WPN-96083664	Dañada	12	\N
1054	WPN-34289169	Dañada	16	\N
1057	WPN-54127802	Dañada	9	\N
1061	WPN-77689919	Dañada	5	\N
1062	WPN-54551620	Dañada	4	\N
1503	WPN-28093306	Dañada	12	\N
1071	WPN-12896105	Dañada	18	\N
1072	WPN-49253778	Dañada	16	\N
1074	WPN-89374087	Dañada	15	\N
1081	WPN-55030231	Dañada	7	\N
1082	WPN-38720674	Dañada	9	\N
1083	WPN-92238423	Dañada	5	\N
1086	WPN-36645318	Dañada	18	\N
1090	WPN-60752040	Dañada	20	\N
1092	WPN-22271494	Dañada	11	\N
1094	WPN-72558170	Dañada	20	\N
1096	WPN-28889068	Dañada	9	\N
1100	WPN-78600857	Dañada	13	\N
1101	WPN-18990055	Dañada	15	\N
1104	WPN-85524137	Dañada	16	\N
1507	WPN-05259498	Dañada	13	\N
1108	WPN-28859461	Dañada	5	\N
1117	WPN-57522080	Dañada	9	\N
1130	WPN-42354923	Dañada	17	\N
1133	WPN-22350730	Dañada	7	\N
1134	WPN-66874563	Dañada	8	\N
1141	WPN-69546191	Dañada	1	\N
1144	WPN-05044205	Dañada	20	\N
1145	WPN-04667268	Dañada	4	\N
1147	WPN-41361144	Dañada	3	\N
1148	WPN-42297980	Dañada	5	\N
1149	WPN-35899047	Dañada	8	\N
1151	WPN-47991868	Dañada	17	\N
1154	WPN-96858220	Dañada	9	\N
1156	WPN-36791945	Dañada	8	\N
1158	WPN-32742093	Dañada	11	\N
1160	WPN-69168981	Dañada	18	\N
1161	WPN-86160039	Dañada	7	\N
1164	WPN-58807264	Dañada	16	\N
1165	WPN-39276885	Dañada	2	\N
1171	WPN-52606106	Dañada	11	\N
1172	WPN-15057301	Dañada	14	\N
1175	WPN-60644421	Dañada	18	\N
1178	WPN-69240454	Dañada	9	\N
1181	WPN-52324766	Dañada	7	\N
1184	WPN-88668483	Dañada	17	\N
1511	WPN-99194853	Dañada	6	\N
1187	WPN-51776837	Dañada	5	\N
1188	WPN-91750529	Dañada	10	\N
1196	WPN-71248603	Dañada	17	\N
1199	WPN-79946190	Dañada	18	\N
1200	WPN-09783981	Dañada	2	\N
1203	WPN-08969567	Dañada	3	\N
1204	WPN-88419880	Dañada	1	\N
1206	WPN-23032667	Dañada	19	\N
1207	WPN-14099060	Dañada	10	\N
1208	WPN-77486538	Dañada	9	\N
1209	WPN-60144734	Dañada	12	\N
1213	WPN-10488121	Dañada	1	\N
1214	WPN-44116470	Dañada	13	\N
1216	WPN-52838444	Dañada	14	\N
1218	WPN-05778758	Dañada	20	\N
1219	WPN-68529324	Dañada	11	\N
1220	WPN-15085131	Dañada	3	\N
1221	WPN-53598746	Dañada	13	\N
1222	WPN-01074351	Dañada	13	\N
1223	WPN-29134393	Dañada	3	\N
1225	WPN-85658475	Dañada	18	\N
1229	WPN-63035288	Dañada	3	\N
1232	WPN-22189550	Dañada	14	\N
1233	WPN-76677475	Dañada	8	\N
1234	WPN-77523873	Dañada	18	\N
1235	WPN-93655469	Dañada	17	\N
1238	WPN-97194800	Dañada	20	\N
1240	WPN-15182833	Dañada	17	\N
1241	WPN-31777960	Dañada	2	\N
1242	WPN-57082066	Dañada	15	\N
1246	WPN-14180673	Dañada	8	\N
1250	WPN-20458901	Dañada	18	\N
1253	WPN-02767680	Dañada	10	\N
1254	WPN-20669902	Dañada	16	\N
1255	WPN-24079788	Dañada	6	\N
1260	WPN-45882094	Dañada	20	\N
1262	WPN-01212568	Dañada	1	\N
1265	WPN-65071208	Dañada	1	\N
1268	WPN-02839916	Dañada	20	\N
1272	WPN-42074250	Dañada	5	\N
1275	WPN-45968658	Dañada	15	\N
1279	WPN-44582890	Dañada	7	\N
1281	WPN-23460450	Dañada	20	\N
1284	WPN-03745101	Dañada	12	\N
1288	WPN-48177879	Dañada	5	\N
1291	WPN-89968105	Dañada	9	\N
1293	WPN-50775902	Dañada	2	\N
1296	WPN-68746980	Dañada	8	\N
1303	WPN-23536232	Dañada	4	\N
1304	WPN-21438549	Dañada	13	\N
1311	WPN-63050853	Dañada	17	\N
1314	WPN-26669513	Dañada	16	\N
1316	WPN-97678592	Dañada	12	\N
1319	WPN-34711803	Dañada	9	\N
1322	WPN-69026830	Dañada	19	\N
1325	WPN-29626003	Dañada	14	\N
1326	WPN-63039801	Dañada	3	\N
1328	WPN-13758995	Dañada	19	\N
1334	WPN-68458348	Dañada	20	\N
1337	WPN-16556583	Dañada	16	\N
1338	WPN-43623512	Dañada	16	\N
1342	WPN-49502099	Dañada	8	\N
1344	WPN-29448660	Dañada	9	\N
1345	WPN-95199012	Dañada	16	\N
1347	WPN-90107596	Dañada	11	\N
1348	WPN-47058973	Dañada	20	\N
1349	WPN-87504702	Dañada	2	\N
1351	WPN-56134744	Dañada	2	\N
1357	WPN-17353492	Dañada	4	\N
1358	WPN-16484665	Dañada	19	\N
1359	WPN-04167408	Dañada	3	\N
1361	WPN-44143555	Dañada	7	\N
1365	WPN-93447995	Dañada	5	\N
1366	WPN-10226828	Dañada	8	\N
1372	WPN-11745321	Dañada	17	\N
1377	WPN-13068443	Dañada	19	\N
1380	WPN-43051648	Dañada	5	\N
1385	WPN-50523751	Dañada	13	\N
1387	WPN-38120984	Dañada	5	\N
1388	WPN-79309941	Dañada	3	\N
1390	WPN-56812169	Dañada	19	\N
1393	WPN-23475852	Dañada	10	\N
1396	WPN-79847763	Dañada	11	\N
1400	WPN-38302857	Dañada	7	\N
1401	WPN-86132614	Dañada	8	\N
1402	WPN-72794583	Dañada	1	\N
1405	WPN-64072301	Dañada	17	\N
1406	WPN-76677979	Dañada	8	\N
1408	WPN-51349959	Dañada	2	\N
1411	WPN-22200897	Dañada	6	\N
1412	WPN-92556793	Dañada	20	\N
1414	WPN-83758236	Dañada	2	\N
1415	WPN-43951012	Dañada	12	\N
1416	WPN-10792895	Dañada	16	\N
1420	WPN-97525741	Dañada	16	\N
1421	WPN-25387129	Dañada	13	\N
1422	WPN-57934418	Dañada	20	\N
1424	WPN-80683971	Dañada	10	\N
1429	WPN-40998955	Dañada	16	\N
1435	WPN-98738150	Dañada	7	\N
1438	WPN-77492638	Dañada	4	\N
1439	WPN-24248832	Dañada	8	\N
1443	WPN-94829419	Dañada	17	\N
1447	WPN-03379566	Dañada	12	\N
1448	WPN-52638430	Dañada	18	\N
1449	WPN-57551881	Dañada	16	\N
1450	WPN-94143087	Dañada	19	\N
1515	WPN-22249967	Dañada	2	\N
1452	WPN-45560432	Dañada	14	\N
1456	WPN-60771871	Dañada	16	\N
1459	WPN-47660174	Dañada	6	\N
1461	WPN-27954995	Dañada	19	\N
1462	WPN-15656549	Dañada	16	\N
1463	WPN-98262000	Dañada	3	\N
1465	WPN-41935800	Dañada	5	\N
1467	WPN-11050056	Dañada	9	\N
1470	WPN-84966781	Dañada	15	\N
1474	WPN-17137436	Dañada	10	\N
1475	WPN-64505322	Dañada	10	\N
1476	WPN-92689448	Dañada	16	\N
1516	WPN-71881417	Dañada	13	\N
1523	WPN-35169968	Dañada	17	\N
1524	WPN-83751623	Dañada	12	\N
1532	WPN-15442961	Dañada	3	\N
1536	WPN-94425589	Dañada	12	\N
1538	WPN-34346205	Dañada	12	\N
1539	WPN-40339685	Dañada	4	\N
1548	WPN-54343487	Dañada	6	\N
1553	WPN-56957412	Dañada	4	\N
1559	WPN-04746989	Dañada	9	\N
1561	WPN-67423842	Dañada	12	\N
1567	WPN-86087201	Dañada	1	\N
1572	WPN-65476887	Dañada	4	\N
1577	WPN-60634079	Dañada	12	\N
1581	WPN-28284491	Dañada	8	\N
1583	WPN-63142438	Dañada	5	\N
1584	WPN-39708305	Dañada	15	\N
1587	WPN-40525137	Dañada	4	\N
1588	WPN-02725943	Dañada	20	\N
1594	WPN-17779062	Dañada	11	\N
1596	WPN-36071968	Dañada	15	\N
1597	WPN-64245615	Dañada	11	\N
1598	WPN-36365840	Dañada	17	\N
1604	WPN-09127199	Dañada	3	\N
1606	WPN-66394023	Dañada	11	\N
1609	WPN-41585758	Dañada	2	\N
1612	WPN-83192429	Dañada	10	\N
1613	WPN-52940357	Dañada	4	\N
1614	WPN-19746681	Dañada	11	\N
1625	WPN-62417095	Dañada	18	\N
1628	WPN-43595592	Dañada	4	\N
1639	WPN-28997918	Dañada	9	\N
1641	WPN-31568961	Dañada	16	\N
1642	WPN-01563839	Dañada	12	\N
1644	WPN-49568056	Dañada	7	\N
1648	WPN-76767734	Dañada	20	\N
1653	WPN-00033069	Dañada	6	\N
1655	WPN-10331927	Dañada	7	\N
1660	WPN-17821835	Dañada	7	\N
1662	WPN-00478446	Dañada	5	\N
1664	WPN-63446663	Dañada	3	\N
1665	WPN-45997774	Dañada	15	\N
1666	WPN-14242579	Dañada	7	\N
1674	WPN-29374015	Dañada	9	\N
1675	WPN-29837963	Dañada	7	\N
1680	WPN-73975928	Dañada	8	\N
1683	WPN-95715474	Dañada	14	\N
1691	WPN-88367023	Dañada	12	\N
1692	WPN-83081598	Dañada	5	\N
1694	WPN-43962735	Dañada	14	\N
1699	WPN-00538827	Dañada	8	\N
1703	WPN-08015891	Dañada	11	\N
1706	WPN-17882093	Dañada	1	\N
1708	WPN-08674582	Dañada	1	\N
1715	WPN-13434603	Dañada	19	\N
1716	WPN-70290304	Dañada	3	\N
1724	WPN-15090515	Dañada	8	\N
1726	WPN-93076483	Dañada	9	\N
1728	WPN-42786051	Dañada	9	\N
1733	WPN-32945370	Dañada	13	\N
1735	WPN-12271716	Dañada	7	\N
1736	WPN-83523953	Dañada	19	\N
1738	WPN-04944153	Dañada	3	\N
1741	WPN-11435934	Dañada	12	\N
1742	WPN-64276603	Dañada	7	\N
1746	WPN-20838119	Dañada	19	\N
1748	WPN-36618341	Dañada	14	\N
1749	WPN-03660417	Dañada	19	\N
1751	WPN-70835134	Dañada	3	\N
1756	WPN-05584928	Dañada	20	\N
1764	WPN-94393758	Dañada	4	\N
1772	WPN-80776530	Dañada	12	\N
1775	WPN-43978314	Dañada	20	\N
1778	WPN-99938091	Dañada	11	\N
1783	WPN-00164333	Dañada	6	\N
1786	WPN-74429247	Dañada	2	\N
1789	WPN-34075378	Dañada	13	\N
1790	WPN-46588454	Dañada	12	\N
1792	WPN-25291613	Dañada	14	\N
1794	WPN-04801766	Dañada	18	\N
1795	WPN-37994954	Dañada	2	\N
1800	WPN-16339903	Dañada	6	\N
1809	WPN-89096187	Dañada	10	\N
1814	WPN-16594106	Dañada	3	\N
1817	WPN-15430521	Dañada	3	\N
1818	WPN-38216680	Dañada	9	\N
1819	WPN-67310186	Dañada	3	\N
1820	WPN-29047993	Dañada	18	\N
1825	WPN-29791898	Dañada	18	\N
1827	WPN-04775322	Dañada	9	\N
1828	WPN-72138998	Dañada	4	\N
1831	WPN-52823858	Dañada	14	\N
1832	WPN-48390941	Dañada	18	\N
1833	WPN-66887500	Dañada	7	\N
1839	WPN-31163681	Dañada	18	\N
1846	WPN-52332227	Dañada	6	\N
1848	WPN-56735575	Dañada	14	\N
1850	WPN-42208956	Dañada	3	\N
1851	WPN-87734726	Dañada	15	\N
1852	WPN-88701149	Dañada	9	\N
1855	WPN-42728320	Dañada	1	\N
1857	WPN-25666259	Dañada	19	\N
1861	WPN-78421291	Dañada	19	\N
1864	WPN-17732446	Dañada	15	\N
1865	WPN-56571410	Dañada	5	\N
1867	WPN-95067421	Dañada	4	\N
1869	WPN-56043318	Dañada	19	\N
1870	WPN-08607813	Dañada	3	\N
1871	WPN-67584693	Dañada	9	\N
1873	WPN-59332181	Dañada	15	\N
1877	WPN-57693808	Dañada	9	\N
1878	WPN-92725310	Dañada	18	\N
1882	WPN-31640754	Dañada	16	\N
1883	WPN-21297101	Dañada	10	\N
1885	WPN-58141743	Dañada	5	\N
1888	WPN-90548132	Dañada	16	\N
1895	WPN-85940940	Dañada	16	\N
1896	WPN-71029971	Dañada	5	\N
1901	WPN-99879801	Dañada	4	\N
1902	WPN-15930387	Dañada	6	\N
1904	WPN-64597599	Dañada	20	\N
1906	WPN-45650634	Dañada	14	\N
1912	WPN-73467282	Dañada	1	\N
1915	WPN-85411266	Dañada	20	\N
1919	WPN-49404755	Dañada	6	\N
1923	WPN-00606954	Dañada	13	\N
1926	WPN-28675489	Dañada	1	\N
1927	WPN-70937592	Dañada	13	\N
1934	WPN-88973471	Dañada	17	\N
1938	WPN-54782064	Dañada	8	\N
1940	WPN-48354070	Dañada	1	\N
1942	WPN-95648520	Dañada	6	\N
1945	WPN-90144562	Dañada	7	\N
1949	WPN-28564328	Dañada	19	\N
1950	WPN-94952907	Dañada	2	\N
1953	WPN-43816101	Dañada	6	\N
1957	WPN-98804838	Dañada	12	\N
1959	WPN-04814854	Dañada	10	\N
1960	WPN-47581879	Dañada	4	\N
1964	WPN-30073163	Dañada	4	\N
1971	WPN-88112278	Dañada	8	\N
1975	WPN-08376852	Dañada	11	\N
1978	WPN-11118384	Dañada	9	\N
1984	WPN-70332884	Dañada	16	\N
1986	WPN-59509183	Dañada	1	\N
1989	WPN-59235922	Dañada	18	\N
1996	WPN-28299624	Dañada	8	\N
1999	WPN-21139202	Dañada	8	\N
2	WPN-82470868	Da¤ada	4	\N
5	WPN-60564489	Dañada	20	\N
14	WPN-02070874	Dañada	18	\N
16	WPN-85717513	Dañada	7	\N
\.


--
-- Data for Name: asignacion_mision; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.asignacion_mision (id_asignacion, rol_asignado, id_mision, id_soldado) FROM stdin;
2	Francotirador	441	2463
3	Ingeniero	399	300
4	Ingeniero	252	2836
5	Apoyo	355	835
6	Medico	461	772
7	Asalto	436	234
8	Apoyo	134	2847
9	Ingeniero	441	981
10	Medico	188	1373
11	Apoyo	307	461
12	Asalto	312	2748
13	Apoyo	290	2015
14	Medico	369	2933
15	Francotirador	91	2679
16	Apoyo	115	2889
17	Asalto	157	1266
18	Francotirador	275	287
19	Medico	156	2436
9001	Asalto	1	15
21	Francotirador	94	493
22	Ingeniero	179	2259
23	Apoyo	447	2129
24	Ingeniero	30	2038
26	Medico	87	1560
27	Ingeniero	144	2875
28	Asalto	30	1498
29	Francotirador	129	676
30	Apoyo	358	1747
31	Apoyo	220	1554
32	Medico	442	2681
33	Ingeniero	389	2355
34	Francotirador	72	103
35	Francotirador	284	682
36	Francotirador	438	688
37	Asalto	30	1699
38	Francotirador	77	1436
39	Apoyo	423	1733
40	Apoyo	378	243
41	Ingeniero	192	2675
42	Ingeniero	286	62
43	Apoyo	465	266
44	Asalto	42	254
45	Medico	400	2976
46	Apoyo	365	2162
47	Apoyo	369	309
48	Asalto	105	75
50	Francotirador	457	232
51	Medico	111	2073
52	Ingeniero	472	1453
53	Apoyo	459	427
54	Ingeniero	119	296
56	Apoyo	265	1756
57	Medico	369	2891
58	Ingeniero	181	890
59	Asalto	15	2405
60	Francotirador	134	1621
61	Ingeniero	93	1157
62	Francotirador	141	2706
63	Ingeniero	308	2586
64	Ingeniero	318	2708
65	Francotirador	476	2173
66	Asalto	393	1384
67	Ingeniero	413	1439
68	Medico	396	1502
69	Francotirador	489	313
70	Francotirador	6	2227
71	Apoyo	432	652
72	Medico	227	936
73	Apoyo	77	47
74	Asalto	9	2283
75	Asalto	23	2655
76	Ingeniero	7	1551
77	Francotirador	75	2089
78	Medico	227	1199
79	Medico	121	2501
80	Asalto	411	573
81	Medico	45	1021
82	Medico	56	318
83	Ingeniero	286	958
84	Apoyo	109	1522
85	Ingeniero	424	1786
86	Francotirador	348	2412
87	Ingeniero	87	990
88	Medico	178	1909
90	Medico	239	1952
91	Medico	192	2510
92	Medico	169	172
94	Apoyo	391	2996
95	Francotirador	74	2458
97	Francotirador	87	1630
98	Ingeniero	413	2271
99	Francotirador	346	915
100	Asalto	377	2781
101	Ingeniero	404	284
102	Francotirador	469	1650
103	Francotirador	285	2088
105	Francotirador	231	1522
106	Apoyo	169	1549
107	Ingeniero	310	17
108	Medico	64	419
109	Apoyo	17	1565
110	Ingeniero	194	925
111	Asalto	369	2794
112	Francotirador	177	1746
113	Apoyo	16	2952
114	Apoyo	434	2862
115	Asalto	355	2856
116	Asalto	330	784
117	Apoyo	83	2810
118	Apoyo	405	761
119	Apoyo	276	2758
120	Francotirador	261	1475
121	Medico	319	2586
122	Asalto	431	136
123	Medico	449	863
124	Asalto	25	2474
125	Ingeniero	96	842
126	Apoyo	373	1948
127	Asalto	53	1195
128	Francotirador	135	1123
129	Francotirador	112	2296
130	Medico	311	1232
131	Francotirador	213	1523
132	Apoyo	299	37
133	Asalto	461	2233
136	Medico	234	2890
137	Asalto	165	1101
138	Medico	39	2775
139	Medico	382	630
140	Medico	111	1134
141	Medico	47	2581
143	Ingeniero	94	107
144	Asalto	232	1616
145	Francotirador	80	1319
146	Francotirador	356	1330
147	Francotirador	95	1025
149	Asalto	107	343
150	Francotirador	357	778
151	Asalto	212	1885
152	Ingeniero	264	2828
153	Ingeniero	10	1049
154	Apoyo	404	1150
155	Asalto	435	609
156	Asalto	416	2459
157	Apoyo	273	2557
158	Medico	258	1340
159	Asalto	211	1266
160	Apoyo	370	2396
161	Asalto	500	2359
162	Medico	376	1430
163	Apoyo	372	1717
164	Medico	136	2805
165	Apoyo	387	944
166	Apoyo	302	1461
167	Ingeniero	371	398
169	Apoyo	92	103
170	Ingeniero	475	551
171	Francotirador	270	2447
172	Francotirador	323	1292
173	Ingeniero	474	1090
174	Apoyo	186	86
175	Asalto	402	1230
176	Medico	34	333
177	Medico	87	617
178	Medico	468	198
179	Asalto	457	1794
180	Medico	410	302
181	Medico	180	1999
182	Apoyo	229	2479
183	Apoyo	321	1717
184	Asalto	322	1147
185	Ingeniero	138	578
186	Asalto	403	434
187	Asalto	337	2679
188	Asalto	236	1414
189	Medico	446	164
190	Francotirador	426	596
191	Francotirador	334	1430
192	Medico	120	2119
193	Ingeniero	10	2898
194	Asalto	217	1988
195	Francotirador	143	1309
196	Asalto	202	595
198	Apoyo	211	2785
199	Ingeniero	149	2636
200	Francotirador	38	286
201	Asalto	348	824
202	Apoyo	332	2421
203	Asalto	256	2068
204	Ingeniero	194	626
205	Asalto	411	165
206	Apoyo	441	544
207	Francotirador	57	1749
208	Ingeniero	70	120
209	Francotirador	461	1817
210	Medico	180	958
211	Asalto	497	23
212	Asalto	403	110
213	Apoyo	275	1283
214	Ingeniero	165	800
216	Apoyo	410	858
217	Apoyo	344	41
218	Asalto	293	915
219	Asalto	140	1853
220	Francotirador	42	941
221	Apoyo	311	2784
222	Francotirador	341	2348
223	Asalto	189	2560
224	Medico	344	2334
225	Ingeniero	194	1309
226	Medico	90	1111
227	Medico	347	1633
228	Medico	21	2047
229	Asalto	376	832
230	Medico	386	2648
231	Apoyo	414	226
232	Apoyo	472	2596
233	Asalto	134	1904
235	Francotirador	235	2119
236	Medico	274	2306
237	Ingeniero	312	1477
238	Asalto	45	1338
239	Apoyo	453	653
240	Asalto	379	1498
242	Ingeniero	301	1884
244	Asalto	27	2000
245	Medico	84	1871
246	Apoyo	33	864
247	Asalto	77	949
248	Apoyo	472	1725
249	Ingeniero	433	1831
250	Asalto	37	2672
251	Medico	471	116
252	Ingeniero	324	382
253	Francotirador	241	957
254	Francotirador	181	2561
255	Medico	438	325
256	Medico	284	2049
257	Francotirador	292	1315
258	Ingeniero	201	2976
259	Asalto	169	852
260	Francotirador	147	2820
261	Medico	162	1690
262	Medico	217	2971
263	Apoyo	184	2182
264	Apoyo	479	812
265	Apoyo	289	2120
266	Asalto	174	667
267	Ingeniero	374	295
268	Ingeniero	157	2851
269	Asalto	249	636
270	Asalto	237	2144
271	Medico	312	2523
273	Ingeniero	124	2853
274	Francotirador	430	1227
275	Medico	350	242
276	Medico	461	2682
277	Medico	190	2181
279	Francotirador	44	833
280	Ingeniero	280	2247
281	Apoyo	124	2174
282	Medico	218	1599
284	Medico	61	658
285	Asalto	187	2554
286	Asalto	468	5
287	Ingeniero	446	1778
288	Medico	207	2044
289	Medico	312	2881
290	Apoyo	266	2374
291	Medico	484	2578
292	Ingeniero	196	2323
293	Ingeniero	417	1308
294	Asalto	457	2193
295	Medico	487	2856
296	Ingeniero	212	708
297	Ingeniero	393	288
298	Ingeniero	120	2823
299	Asalto	102	1428
300	Francotirador	323	503
301	Apoyo	226	1139
302	Apoyo	51	2714
303	Apoyo	346	114
304	Apoyo	475	30
305	Ingeniero	288	1895
306	Francotirador	17	903
307	Apoyo	298	876
308	Francotirador	141	914
309	Ingeniero	273	2284
310	Apoyo	359	1975
311	Asalto	465	934
312	Medico	188	545
313	Medico	312	1758
314	Medico	251	2496
315	Ingeniero	247	766
316	Asalto	494	2426
317	Medico	230	971
318	Asalto	200	1649
319	Apoyo	143	2932
320	Francotirador	40	2644
321	Asalto	126	196
322	Asalto	107	384
323	Asalto	457	1737
324	Ingeniero	61	149
325	Francotirador	271	54
326	Medico	254	2116
327	Francotirador	7	736
328	Asalto	100	1777
329	Asalto	303	304
330	Apoyo	109	492
331	Asalto	478	2667
332	Ingeniero	408	1522
333	Ingeniero	351	179
334	Medico	36	732
335	Asalto	378	1029
336	Medico	60	407
337	Asalto	68	343
339	Apoyo	275	828
340	Francotirador	274	387
341	Ingeniero	357	1844
342	Ingeniero	350	1526
343	Francotirador	137	2000
344	Medico	290	24
345	Medico	413	340
346	Medico	444	2801
347	Asalto	450	1371
348	Medico	462	60
349	Francotirador	393	1305
350	Asalto	210	1893
351	Apoyo	188	421
352	Asalto	471	413
354	Francotirador	21	648
355	Apoyo	378	1893
356	Ingeniero	270	2980
357	Francotirador	149	2197
358	Francotirador	399	1225
359	Francotirador	286	2084
360	Medico	223	742
361	Ingeniero	192	1444
362	Francotirador	77	2598
364	Francotirador	61	1299
365	Ingeniero	492	2547
366	Francotirador	352	372
367	Ingeniero	499	232
368	Ingeniero	59	1217
369	Francotirador	73	2874
370	Francotirador	114	1935
371	Ingeniero	37	652
372	Medico	254	1663
373	Asalto	195	219
374	Medico	215	2936
375	Francotirador	201	1518
376	Apoyo	314	1296
377	Ingeniero	92	283
378	Ingeniero	408	2790
379	Asalto	248	1239
380	Apoyo	10	2510
381	Ingeniero	35	1298
382	Francotirador	231	2332
383	Ingeniero	267	2243
384	Ingeniero	486	443
385	Francotirador	75	1703
386	Medico	6	1944
387	Asalto	260	2351
388	Ingeniero	214	2780
389	Medico	301	2959
390	Asalto	456	2462
391	Francotirador	326	1864
392	Ingeniero	122	1146
393	Asalto	191	1913
394	Francotirador	351	1514
395	Ingeniero	468	1309
396	Medico	460	2451
397	Ingeniero	258	1940
398	Apoyo	166	2027
399	Medico	497	1259
400	Asalto	63	955
401	Apoyo	244	2173
402	Asalto	16	1240
403	Medico	424	738
404	Medico	317	1156
405	Medico	98	808
406	Asalto	490	532
407	Ingeniero	65	2770
408	Apoyo	192	2129
409	Medico	448	950
410	Francotirador	295	1107
411	Francotirador	414	936
412	Asalto	380	2974
413	Apoyo	350	2736
414	Francotirador	449	230
415	Francotirador	253	38
416	Ingeniero	161	1146
417	Asalto	311	932
418	Ingeniero	76	418
419	Apoyo	326	1700
420	Apoyo	167	2090
421	Francotirador	276	2927
422	Medico	132	2262
423	Apoyo	428	569
424	Medico	30	1804
425	Francotirador	139	2570
426	Apoyo	311	1631
427	Asalto	138	2803
429	Francotirador	388	2235
430	Apoyo	221	1867
431	Asalto	17	445
432	Ingeniero	36	1242
433	Asalto	92	542
434	Medico	105	2982
435	Apoyo	330	965
437	Asalto	87	569
438	Ingeniero	495	1208
439	Ingeniero	88	223
440	Apoyo	497	2361
441	Medico	478	958
442	Francotirador	206	1823
443	Medico	331	2436
444	Francotirador	187	1099
445	Medico	40	2111
446	Asalto	243	1799
447	Ingeniero	356	2265
448	Ingeniero	133	1423
449	Ingeniero	475	1621
450	Apoyo	175	1414
451	Medico	55	2151
452	Ingeniero	337	2301
453	Francotirador	334	1175
454	Asalto	20	2364
455	Francotirador	27	1846
456	Apoyo	214	2755
457	Asalto	209	2336
458	Apoyo	203	2853
459	Apoyo	404	2620
460	Apoyo	100	2659
461	Ingeniero	458	833
462	Apoyo	181	1557
463	Francotirador	236	984
464	Medico	6	762
465	Asalto	282	398
466	Ingeniero	241	2901
467	Apoyo	327	2190
469	Asalto	221	2345
470	Francotirador	332	376
471	Ingeniero	296	1831
472	Asalto	220	2977
473	Francotirador	489	2440
474	Apoyo	63	371
475	Medico	368	2332
476	Medico	179	1028
477	Asalto	466	862
478	Francotirador	218	1244
479	Medico	478	395
480	Asalto	251	1237
481	Francotirador	486	2499
482	Apoyo	64	2002
483	Asalto	432	1100
484	Francotirador	467	104
485	Asalto	182	1431
486	Ingeniero	395	78
487	Apoyo	149	428
488	Asalto	397	195
489	Asalto	231	1810
490	Francotirador	460	2345
491	Medico	343	2859
492	Medico	278	579
493	Apoyo	45	247
494	Asalto	477	2019
495	Asalto	480	54
496	Ingeniero	145	963
497	Apoyo	134	2093
499	Medico	80	1561
500	Ingeniero	185	483
501	Apoyo	225	2957
502	Medico	496	2092
503	Asalto	297	2204
504	Apoyo	398	1600
505	Francotirador	111	2459
506	Asalto	286	2146
507	Ingeniero	136	1777
508	Francotirador	343	2540
509	Asalto	122	1426
510	Apoyo	414	2680
511	Francotirador	460	745
512	Francotirador	158	2502
513	Medico	368	1427
514	Medico	476	2070
515	Medico	424	656
516	Asalto	476	1477
517	Asalto	305	1237
518	Apoyo	101	1283
519	Ingeniero	337	122
520	Ingeniero	144	1782
521	Ingeniero	460	1187
522	Apoyo	217	1557
523	Medico	165	685
524	Medico	229	637
525	Francotirador	182	1859
526	Ingeniero	150	150
527	Ingeniero	139	2753
528	Ingeniero	69	113
529	Ingeniero	292	1088
530	Asalto	211	343
531	Apoyo	36	1912
532	Medico	410	1501
533	Ingeniero	229	905
535	Asalto	1	2767
536	Medico	94	2300
538	Medico	444	422
539	Asalto	470	2235
540	Ingeniero	449	1237
541	Francotirador	325	1640
542	Medico	346	1917
543	Ingeniero	297	371
544	Asalto	29	2469
545	Apoyo	248	631
546	Apoyo	168	1667
547	Ingeniero	271	1010
548	Ingeniero	75	869
549	Francotirador	325	284
550	Francotirador	348	911
551	Apoyo	345	2157
552	Asalto	444	900
553	Apoyo	150	1990
554	Apoyo	192	1900
555	Apoyo	196	2000
556	Medico	258	1506
557	Ingeniero	181	1133
558	Apoyo	164	1631
559	Apoyo	477	1505
560	Medico	92	1012
561	Asalto	119	1177
562	Ingeniero	233	924
563	Ingeniero	245	1006
564	Francotirador	202	2951
565	Asalto	180	2402
566	Francotirador	397	2734
567	Medico	22	2848
568	Asalto	306	74
569	Asalto	311	293
570	Asalto	390	656
571	Medico	443	1710
572	Asalto	148	920
573	Francotirador	255	1710
574	Medico	168	60
575	Ingeniero	495	754
576	Medico	345	184
577	Ingeniero	420	2267
578	Francotirador	320	2992
579	Francotirador	25	649
580	Asalto	203	220
581	Medico	84	2884
582	Medico	498	2534
584	Ingeniero	435	247
585	Asalto	426	1057
586	Apoyo	97	100
587	Apoyo	393	2759
588	Apoyo	78	2258
589	Medico	420	2113
590	Ingeniero	144	150
591	Apoyo	334	2757
592	Apoyo	374	2969
593	Ingeniero	200	2130
594	Apoyo	186	689
595	Asalto	384	1301
596	Apoyo	104	1814
597	Francotirador	219	2982
598	Asalto	24	2513
599	Apoyo	298	1794
600	Apoyo	222	2507
601	Ingeniero	475	640
603	Asalto	179	1557
604	Francotirador	435	947
606	Medico	457	747
607	Francotirador	158	92
608	Medico	205	1044
609	Apoyo	268	2518
610	Francotirador	19	1886
611	Francotirador	30	1312
612	Apoyo	31	1888
613	Medico	221	832
614	Asalto	353	2563
615	Francotirador	123	635
617	Medico	195	2806
618	Ingeniero	368	2942
619	Francotirador	351	1914
620	Francotirador	186	1028
621	Medico	494	1891
622	Francotirador	444	351
623	Francotirador	359	743
624	Asalto	493	641
625	Medico	272	1147
626	Ingeniero	87	2076
627	Medico	115	2254
628	Medico	475	1072
629	Ingeniero	425	1442
630	Asalto	238	1934
631	Asalto	434	112
632	Apoyo	274	1595
633	Medico	195	1110
634	Medico	400	2963
635	Francotirador	200	826
636	Asalto	455	2514
637	Ingeniero	161	2757
638	Ingeniero	139	2359
639	Asalto	42	396
640	Asalto	377	2706
641	Asalto	280	971
642	Medico	470	2303
643	Francotirador	7	2264
644	Asalto	433	2469
645	Asalto	75	2094
646	Francotirador	475	928
647	Apoyo	363	28
648	Apoyo	380	61
649	Ingeniero	396	192
650	Asalto	308	2011
651	Ingeniero	373	820
653	Apoyo	174	2796
654	Apoyo	461	2275
655	Francotirador	496	1187
656	Asalto	228	1784
657	Asalto	80	2397
658	Medico	12	2173
659	Francotirador	350	828
660	Medico	204	2392
661	Apoyo	322	1919
662	Ingeniero	27	850
663	Apoyo	5	1169
664	Apoyo	484	2415
665	Medico	186	715
666	Medico	19	2207
667	Ingeniero	426	2344
668	Ingeniero	43	1031
669	Ingeniero	342	1195
670	Francotirador	331	190
671	Ingeniero	436	2255
672	Apoyo	228	1732
673	Ingeniero	442	1280
674	Asalto	279	2770
675	Asalto	83	1635
676	Medico	321	1546
677	Apoyo	94	20
678	Asalto	238	2836
679	Asalto	36	1999
680	Ingeniero	10	2043
681	Medico	465	876
682	Francotirador	270	1379
683	Francotirador	86	2886
684	Apoyo	477	1654
685	Apoyo	293	462
686	Medico	164	2742
687	Ingeniero	366	2810
688	Medico	332	1130
689	Medico	324	1980
691	Medico	365	2703
692	Asalto	375	2678
693	Francotirador	126	2070
694	Francotirador	130	2183
695	Ingeniero	72	1079
696	Francotirador	472	1184
697	Ingeniero	63	1003
699	Francotirador	89	846
700	Francotirador	372	384
701	Francotirador	418	2306
702	Medico	468	578
703	Ingeniero	461	642
704	Francotirador	93	974
705	Asalto	489	2596
706	Apoyo	156	2703
707	Ingeniero	189	613
708	Francotirador	327	1018
709	Francotirador	297	2288
710	Asalto	31	461
711	Apoyo	254	1667
712	Apoyo	204	1377
713	Ingeniero	193	2270
714	Ingeniero	480	1766
715	Ingeniero	414	553
716	Ingeniero	466	1997
718	Francotirador	124	680
719	Francotirador	23	1665
720	Apoyo	39	622
721	Medico	100	2906
723	Ingeniero	414	1275
724	Asalto	196	2990
725	Francotirador	330	1948
726	Apoyo	251	708
727	Apoyo	130	1640
728	Asalto	357	334
729	Francotirador	429	2594
730	Francotirador	31	908
731	Asalto	325	2600
732	Ingeniero	412	2417
733	Ingeniero	448	142
734	Asalto	323	2775
735	Apoyo	52	744
736	Asalto	321	2578
737	Apoyo	209	1139
738	Francotirador	234	1554
739	Apoyo	399	715
740	Ingeniero	33	953
741	Francotirador	420	1245
742	Ingeniero	476	545
743	Francotirador	72	497
744	Medico	367	676
745	Francotirador	177	1804
746	Medico	415	297
747	Asalto	435	2567
748	Apoyo	414	80
749	Asalto	94	72
751	Asalto	390	1692
752	Francotirador	182	2462
754	Ingeniero	260	1240
755	Francotirador	470	171
756	Asalto	263	2085
757	Apoyo	329	2951
758	Francotirador	147	1164
759	Apoyo	377	1659
760	Apoyo	295	1643
761	Asalto	271	917
762	Asalto	92	639
763	Apoyo	368	1227
764	Asalto	202	1846
765	Asalto	347	878
766	Asalto	368	2409
767	Asalto	494	1298
768	Medico	251	2594
769	Francotirador	117	2158
770	Francotirador	310	1333
771	Ingeniero	45	637
772	Medico	27	136
773	Apoyo	390	1380
774	Apoyo	219	1341
775	Asalto	287	1703
776	Asalto	206	2626
777	Apoyo	482	2691
778	Apoyo	412	1666
779	Ingeniero	310	1253
780	Apoyo	181	2921
781	Francotirador	164	198
782	Francotirador	326	738
783	Francotirador	152	1870
784	Francotirador	84	1927
785	Asalto	21	2740
786	Apoyo	184	2154
787	Francotirador	41	718
789	Apoyo	359	2743
790	Francotirador	196	2689
791	Asalto	176	2929
792	Apoyo	322	338
793	Apoyo	245	471
794	Asalto	432	2218
795	Apoyo	359	2739
796	Francotirador	217	2487
797	Ingeniero	220	2926
798	Francotirador	200	2119
799	Apoyo	77	714
800	Medico	332	2183
801	Medico	1	2120
802	Francotirador	55	2255
804	Apoyo	223	1205
805	Medico	71	1900
806	Apoyo	130	2097
807	Asalto	409	690
808	Francotirador	452	1469
809	Francotirador	388	2249
810	Francotirador	62	109
811	Apoyo	243	2999
812	Ingeniero	146	473
813	Francotirador	234	104
815	Medico	342	463
816	Francotirador	302	2131
817	Francotirador	224	2986
818	Medico	391	887
819	Apoyo	265	2476
820	Apoyo	260	15
821	Medico	340	737
822	Apoyo	481	795
823	Ingeniero	145	2909
824	Ingeniero	288	2261
825	Asalto	142	234
826	Ingeniero	167	723
827	Francotirador	359	1350
828	Ingeniero	64	1826
829	Medico	486	1664
830	Apoyo	241	1176
831	Asalto	379	2722
832	Apoyo	37	1771
833	Ingeniero	105	912
834	Francotirador	417	1529
835	Asalto	315	2595
836	Medico	465	1989
837	Francotirador	399	803
838	Apoyo	309	277
839	Apoyo	76	2818
840	Apoyo	340	1903
841	Apoyo	374	1128
842	Ingeniero	136	1784
843	Ingeniero	164	997
844	Ingeniero	181	1731
845	Apoyo	369	1096
846	Ingeniero	143	903
847	Apoyo	499	2716
848	Ingeniero	134	1497
849	Asalto	75	547
850	Medico	297	887
851	Apoyo	176	590
852	Ingeniero	387	412
853	Ingeniero	184	2410
854	Apoyo	310	1876
855	Medico	326	1940
856	Medico	430	1778
857	Apoyo	155	936
858	Medico	247	2105
859	Francotirador	130	2622
860	Ingeniero	30	1643
861	Francotirador	500	1413
862	Francotirador	273	913
863	Francotirador	414	1348
864	Medico	306	1859
865	Apoyo	273	1395
866	Apoyo	320	669
867	Francotirador	17	581
868	Ingeniero	241	1370
869	Ingeniero	203	2429
870	Apoyo	485	2993
871	Apoyo	296	428
873	Asalto	4	2487
874	Ingeniero	126	1368
875	Medico	11	444
876	Medico	193	1225
877	Apoyo	431	415
878	Asalto	302	2445
879	Apoyo	38	1086
880	Asalto	389	1109
881	Asalto	221	2053
882	Ingeniero	233	1699
883	Medico	296	80
884	Asalto	251	1451
885	Medico	403	1990
886	Francotirador	15	834
887	Apoyo	79	2972
888	Apoyo	325	2521
890	Medico	375	306
891	Medico	133	2481
892	Ingeniero	200	2836
893	Francotirador	92	118
894	Asalto	247	592
896	Francotirador	271	375
897	Asalto	132	2907
898	Apoyo	365	2569
901	Medico	98	2610
903	Medico	403	2917
904	Asalto	74	1851
905	Ingeniero	391	8
906	Medico	154	2397
907	Asalto	104	2784
908	Francotirador	295	767
909	Apoyo	482	2209
910	Apoyo	309	2304
911	Apoyo	146	1031
912	Apoyo	324	2481
913	Ingeniero	165	1432
914	Apoyo	292	1248
915	Francotirador	23	1213
916	Medico	14	243
917	Medico	405	2629
918	Apoyo	281	127
919	Francotirador	241	2570
920	Francotirador	443	2842
921	Medico	278	2548
922	Medico	134	378
923	Apoyo	164	152
924	Medico	196	1737
925	Apoyo	282	1754
926	Apoyo	289	2772
927	Asalto	395	185
928	Apoyo	307	743
929	Asalto	269	1320
930	Apoyo	24	2777
931	Medico	404	2412
932	Apoyo	94	1188
934	Apoyo	157	1449
935	Ingeniero	170	689
936	Apoyo	130	1442
938	Ingeniero	390	1333
939	Asalto	452	1567
940	Apoyo	23	649
941	Ingeniero	233	2052
942	Francotirador	369	1913
943	Apoyo	348	2737
944	Asalto	317	658
945	Apoyo	342	26
946	Asalto	322	1691
947	Ingeniero	429	1341
948	Medico	19	1992
949	Apoyo	484	418
950	Ingeniero	82	1592
951	Asalto	420	304
952	Apoyo	159	1525
953	Asalto	345	1193
954	Ingeniero	224	2458
955	Medico	368	1187
956	Ingeniero	195	141
957	Medico	291	364
958	Ingeniero	338	580
959	Medico	363	495
960	Apoyo	57	1760
961	Apoyo	319	1983
962	Francotirador	88	1318
963	Francotirador	401	694
965	Francotirador	163	496
966	Ingeniero	194	640
967	Ingeniero	274	920
968	Asalto	479	2518
969	Ingeniero	61	1193
970	Asalto	497	1003
971	Apoyo	210	785
972	Ingeniero	347	2877
973	Medico	332	2852
974	Ingeniero	491	2706
975	Medico	447	2339
976	Asalto	58	2856
977	Medico	463	2949
979	Medico	475	476
981	Medico	439	993
982	Medico	300	2430
983	Apoyo	204	41
984	Medico	275	830
985	Apoyo	424	1836
987	Asalto	421	1635
988	Apoyo	5	1379
989	Ingeniero	69	2366
990	Francotirador	278	417
991	Asalto	411	274
992	Asalto	3	2389
993	Francotirador	406	713
994	Asalto	298	372
995	Medico	97	453
996	Apoyo	232	210
997	Medico	438	1618
998	Medico	177	1568
999	Medico	47	2435
1000	Asalto	11	2107
1001	Medico	371	324
1002	Ingeniero	337	1152
1003	Francotirador	122	1607
1004	Francotirador	307	136
1005	Medico	144	1552
1007	Francotirador	310	403
1008	Francotirador	464	2936
1009	Apoyo	73	914
1010	Ingeniero	306	2930
1011	Francotirador	50	1175
1012	Ingeniero	86	2094
1013	Medico	322	2523
1014	Francotirador	308	1187
1015	Francotirador	458	2979
1016	Francotirador	443	254
1017	Medico	218	585
1018	Ingeniero	25	1541
1019	Ingeniero	271	2634
1020	Ingeniero	235	2701
1021	Francotirador	490	2073
1022	Ingeniero	89	2687
1023	Ingeniero	1	425
1024	Ingeniero	495	102
1025	Ingeniero	68	2355
1026	Francotirador	392	333
1027	Ingeniero	104	545
1028	Francotirador	106	2340
1030	Asalto	482	582
1031	Ingeniero	105	757
1032	Francotirador	148	991
1033	Asalto	403	1028
1034	Apoyo	303	2909
1035	Apoyo	416	2243
1036	Ingeniero	496	56
1037	Ingeniero	77	121
1038	Apoyo	283	2084
1039	Asalto	133	1981
1041	Ingeniero	220	1181
1042	Asalto	469	1286
1043	Francotirador	468	2874
1044	Apoyo	494	636
1045	Apoyo	57	980
1046	Ingeniero	272	2629
1047	Apoyo	88	1434
1048	Ingeniero	462	874
1049	Asalto	314	2871
1050	Asalto	407	2608
1051	Medico	429	223
1052	Ingeniero	340	2596
1053	Ingeniero	41	1106
1054	Asalto	141	110
1055	Apoyo	2	2855
1057	Ingeniero	150	241
1058	Ingeniero	131	2477
1060	Apoyo	356	1996
1061	Asalto	196	350
1062	Ingeniero	450	1303
1063	Medico	124	2156
1064	Apoyo	319	362
1065	Apoyo	285	1626
1066	Medico	367	2657
1067	Apoyo	290	2969
1068	Asalto	265	2337
1069	Medico	32	2353
1070	Francotirador	276	499
1071	Asalto	147	1644
1072	Ingeniero	413	551
1073	Francotirador	310	68
1074	Ingeniero	401	2348
1075	Asalto	356	2057
1076	Medico	3	1626
1077	Ingeniero	361	1489
1078	Asalto	103	1415
1079	Medico	84	729
1080	Francotirador	424	493
1082	Asalto	331	2835
1083	Medico	220	183
1084	Apoyo	418	1034
1085	Francotirador	491	839
1086	Francotirador	383	1709
1087	Apoyo	319	409
1088	Apoyo	84	1252
1089	Francotirador	260	2597
1090	Asalto	252	2464
1091	Francotirador	197	1640
1092	Asalto	173	2258
1093	Francotirador	497	40
1094	Apoyo	257	1847
1095	Asalto	261	2093
1096	Apoyo	203	1481
1097	Apoyo	230	2622
1098	Asalto	179	2586
1099	Francotirador	484	1545
1100	Asalto	333	2732
1101	Apoyo	428	2274
1102	Ingeniero	378	2480
1103	Ingeniero	480	307
1104	Asalto	480	777
1105	Medico	10	605
1106	Francotirador	396	287
1107	Ingeniero	144	1103
1108	Medico	482	363
1109	Asalto	217	1892
1110	Ingeniero	216	1377
1111	Apoyo	118	2387
1112	Apoyo	101	2472
1113	Ingeniero	413	1809
1114	Francotirador	138	2425
1115	Ingeniero	485	2491
1116	Ingeniero	5	1978
1117	Ingeniero	37	1468
1118	Francotirador	322	406
1120	Francotirador	392	2045
1121	Francotirador	8	2373
1122	Asalto	24	1980
1123	Medico	395	588
1124	Medico	311	116
1125	Ingeniero	257	935
1126	Apoyo	123	960
1127	Francotirador	169	152
1128	Apoyo	17	267
1129	Francotirador	499	476
1130	Francotirador	263	2190
1131	Francotirador	379	2613
1132	Asalto	313	2131
1133	Medico	306	919
1134	Medico	68	1878
1135	Ingeniero	3	685
1136	Apoyo	322	444
1137	Apoyo	144	2154
1138	Asalto	301	2088
1139	Medico	57	2045
1140	Ingeniero	263	596
1141	Medico	200	1969
1142	Ingeniero	305	1306
1143	Ingeniero	19	569
1144	Ingeniero	369	2234
1145	Asalto	245	2458
1146	Ingeniero	497	386
1147	Asalto	110	2715
1148	Ingeniero	48	61
1149	Apoyo	397	130
1150	Apoyo	324	1217
1152	Apoyo	392	268
1153	Francotirador	9	2537
1154	Medico	347	2892
1155	Ingeniero	242	688
1156	Francotirador	470	1823
1157	Medico	188	731
1158	Asalto	157	1367
1159	Francotirador	2	804
1160	Medico	387	2261
1161	Medico	499	1943
1162	Apoyo	83	920
1163	Apoyo	200	628
1164	Apoyo	432	1727
1165	Ingeniero	44	533
1166	Francotirador	71	421
1167	Ingeniero	304	2176
1169	Asalto	70	2506
1170	Ingeniero	351	1328
1171	Apoyo	465	2677
1172	Francotirador	9	952
1173	Asalto	105	1986
1174	Asalto	194	2304
1175	Francotirador	338	109
1176	Medico	475	1008
1177	Medico	300	1929
1178	Asalto	369	299
1179	Apoyo	103	830
1180	Francotirador	308	303
1181	Francotirador	154	2811
1182	Medico	313	1522
1183	Ingeniero	443	1692
1184	Francotirador	369	1718
1185	Ingeniero	490	1310
1186	Apoyo	209	2575
1187	Apoyo	487	1420
1188	Asalto	300	2717
1189	Asalto	480	1043
1190	Medico	384	282
1191	Asalto	302	1627
1192	Francotirador	282	1908
1193	Asalto	456	675
1194	Medico	317	2901
1195	Medico	145	1505
1196	Francotirador	277	1207
1197	Ingeniero	58	2874
1198	Ingeniero	80	1687
1199	Ingeniero	330	2920
1200	Apoyo	363	125
1201	Asalto	202	366
1202	Apoyo	77	1740
1203	Francotirador	94	990
1204	Apoyo	114	1914
1205	Ingeniero	485	1214
1206	Medico	271	444
1207	Apoyo	254	1614
1208	Apoyo	338	78
1209	Francotirador	365	1819
1210	Francotirador	201	2414
1211	Asalto	300	2903
1212	Asalto	217	1691
1214	Apoyo	283	2491
1215	Francotirador	151	179
1216	Medico	405	2249
1217	Asalto	98	2767
1218	Ingeniero	362	697
1219	Francotirador	23	2806
1220	Asalto	178	118
1221	Ingeniero	319	2034
1222	Apoyo	55	2345
1223	Medico	94	854
1224	Apoyo	302	1746
1225	Apoyo	269	2049
1226	Medico	413	2439
1227	Francotirador	266	1795
1228	Asalto	70	870
1229	Francotirador	220	639
1230	Asalto	101	1703
1231	Apoyo	401	2862
1232	Medico	46	819
1233	Apoyo	400	635
1234	Medico	453	1344
1235	Medico	320	716
1237	Medico	421	2805
1238	Ingeniero	434	1975
1239	Apoyo	382	2063
1240	Asalto	487	1463
1241	Apoyo	197	526
1242	Medico	209	1641
1243	Francotirador	94	1489
1244	Medico	82	1923
1245	Ingeniero	408	1115
1247	Ingeniero	400	683
1248	Medico	459	836
1249	Ingeniero	184	1475
1250	Apoyo	35	1196
1251	Francotirador	198	2480
1252	Francotirador	311	738
1253	Ingeniero	26	1954
1255	Asalto	63	1905
1256	Apoyo	303	2382
1257	Asalto	112	518
1258	Asalto	413	2809
1259	Medico	216	2082
1260	Asalto	440	2210
1261	Ingeniero	409	1010
1262	Medico	63	1145
1263	Medico	264	2250
1264	Francotirador	62	370
1265	Ingeniero	216	683
1266	Ingeniero	330	2988
1267	Medico	65	1405
1268	Apoyo	314	1725
1269	Ingeniero	303	232
1271	Medico	122	842
1272	Ingeniero	31	456
1273	Apoyo	449	266
1274	Apoyo	493	1518
1275	Ingeniero	483	1524
1276	Asalto	304	310
1277	Francotirador	395	2084
1278	Ingeniero	401	1563
1279	Apoyo	287	1394
1280	Apoyo	2	2580
1281	Francotirador	478	1869
1282	Ingeniero	466	691
1283	Ingeniero	224	381
1284	Medico	84	1609
1285	Apoyo	3	1950
1286	Ingeniero	210	984
1287	Francotirador	138	1407
1288	Asalto	224	988
1289	Francotirador	378	2368
1290	Francotirador	425	2
1291	Francotirador	396	2087
1292	Asalto	417	2774
1293	Ingeniero	345	1943
1294	Asalto	167	2223
1295	Apoyo	355	1148
1296	Asalto	35	84
1297	Apoyo	104	1338
1298	Medico	196	507
1299	Ingeniero	223	1851
1300	Asalto	428	2877
1301	Ingeniero	111	1758
1302	Ingeniero	85	927
1303	Francotirador	93	1466
1304	Apoyo	47	516
1305	Medico	392	669
1306	Medico	63	2251
1307	Asalto	398	2140
1308	Asalto	144	1630
1309	Francotirador	149	2663
1310	Francotirador	22	1151
1311	Apoyo	193	172
1312	Apoyo	334	2630
1313	Asalto	208	296
1314	Medico	49	2771
1315	Apoyo	355	551
1316	Asalto	285	1160
1317	Apoyo	65	1892
1318	Apoyo	8	2676
1319	Asalto	274	2678
1320	Apoyo	128	1449
1321	Medico	304	68
1322	Asalto	50	1949
1323	Asalto	113	1340
1324	Apoyo	161	1819
1325	Ingeniero	63	2786
1326	Medico	197	2212
1327	Asalto	199	1914
1328	Ingeniero	321	904
1329	Ingeniero	217	1133
1330	Medico	482	1428
1331	Ingeniero	186	2471
1332	Francotirador	267	232
1333	Asalto	353	2942
1334	Medico	306	1207
1335	Ingeniero	375	2946
1336	Ingeniero	222	1078
1337	Medico	273	2402
1338	Apoyo	307	360
1339	Apoyo	431	517
1340	Ingeniero	190	1230
1341	Ingeniero	340	1623
1342	Francotirador	370	1569
1343	Medico	124	2474
1344	Francotirador	282	1811
1345	Medico	42	635
1346	Asalto	152	624
1347	Asalto	308	2859
1348	Apoyo	4	1181
1349	Apoyo	221	569
1350	Francotirador	61	483
1351	Asalto	277	123
1352	Ingeniero	396	803
1353	Apoyo	273	2735
1354	Ingeniero	491	1776
1355	Asalto	109	2521
1356	Ingeniero	217	2363
1357	Asalto	464	1653
1358	Ingeniero	395	1553
1359	Asalto	214	2004
1360	Asalto	475	1626
1361	Francotirador	114	332
1362	Asalto	397	1752
1363	Asalto	37	862
1364	Apoyo	234	140
1365	Francotirador	391	2709
1366	Medico	53	2729
1367	Apoyo	83	2305
1368	Apoyo	155	1112
1369	Asalto	482	258
1370	Apoyo	185	2112
1372	Francotirador	410	780
1373	Apoyo	213	315
1374	Medico	199	2374
1375	Asalto	353	674
1376	Apoyo	13	1191
1377	Asalto	428	31
1378	Ingeniero	121	485
1379	Medico	354	1584
1380	Asalto	465	2993
1381	Ingeniero	449	488
1382	Ingeniero	331	2843
1383	Asalto	109	869
1384	Asalto	423	1566
1385	Apoyo	142	1360
1386	Asalto	477	481
1387	Francotirador	42	1520
1388	Asalto	411	2831
1390	Apoyo	457	265
1392	Asalto	90	1623
1393	Asalto	306	2770
1394	Medico	457	719
1395	Ingeniero	325	377
1396	Francotirador	389	2947
1398	Asalto	164	2562
1399	Ingeniero	207	553
1400	Medico	267	1735
1401	Apoyo	422	2147
1402	Ingeniero	153	1295
1404	Ingeniero	64	510
1405	Ingeniero	268	1076
1406	Francotirador	153	2205
1408	Asalto	214	1916
1409	Francotirador	455	358
1410	Apoyo	425	1099
1411	Apoyo	31	475
1412	Francotirador	472	2791
1413	Medico	34	2028
1414	Asalto	475	1342
1415	Ingeniero	20	2016
1416	Ingeniero	38	2866
1417	Medico	289	623
1418	Asalto	396	750
1419	Medico	104	328
1420	Ingeniero	39	1504
1421	Apoyo	54	288
1422	Medico	264	409
1423	Ingeniero	367	2613
1424	Francotirador	236	1196
1425	Medico	450	381
1426	Apoyo	461	1473
1427	Asalto	265	1023
1428	Ingeniero	275	443
1429	Apoyo	353	2146
1430	Francotirador	94	1587
1431	Ingeniero	394	2725
1432	Ingeniero	141	1191
1433	Ingeniero	456	1577
1434	Apoyo	144	1484
1435	Apoyo	477	2119
1436	Apoyo	159	2547
1437	Ingeniero	287	2030
1438	Francotirador	76	170
1439	Medico	2	1498
1440	Asalto	172	2473
1441	Medico	84	1018
1442	Asalto	160	580
1443	Medico	165	2549
1444	Medico	118	706
1445	Francotirador	329	2996
1446	Medico	271	1323
1447	Francotirador	35	2804
1448	Ingeniero	389	2137
1449	Medico	58	847
1450	Ingeniero	303	2240
1451	Ingeniero	268	1405
1452	Apoyo	326	471
1453	Apoyo	300	1570
1454	Asalto	469	1271
1455	Apoyo	19	266
1456	Apoyo	52	490
1457	Medico	420	2030
1458	Francotirador	101	1975
1459	Asalto	417	2344
1460	Francotirador	41	1223
1461	Medico	29	2939
1462	Francotirador	146	565
1463	Asalto	92	1444
1464	Ingeniero	293	1795
1465	Medico	309	2837
1466	Medico	269	744
1467	Apoyo	240	1283
1468	Ingeniero	86	2139
1469	Apoyo	273	2289
1470	Apoyo	199	2407
1471	Apoyo	337	305
1472	Asalto	168	1517
1473	Apoyo	148	2564
1474	Asalto	370	2328
1475	Medico	423	321
1476	Francotirador	446	2290
1477	Francotirador	246	384
1478	Ingeniero	133	1097
1479	Asalto	254	111
1480	Francotirador	437	2415
1481	Apoyo	334	1588
1482	Apoyo	266	138
1483	Francotirador	16	2459
1485	Medico	302	543
1486	Asalto	495	1652
1488	Francotirador	434	1748
1489	Medico	102	2956
1490	Asalto	449	587
1491	Ingeniero	227	2035
1492	Ingeniero	335	1934
1493	Medico	491	1007
1494	Francotirador	479	2053
1495	Medico	216	456
1496	Medico	23	1631
1497	Ingeniero	200	1341
1498	Ingeniero	311	2342
1499	Francotirador	361	327
1500	Asalto	111	2448
1501	Medico	248	148
1502	Medico	174	180
1503	Medico	120	2366
1504	Medico	88	470
1505	Asalto	462	2971
1506	Medico	188	1098
1507	Francotirador	403	2873
1508	Apoyo	361	935
1509	Francotirador	176	1406
1510	Ingeniero	68	2287
1511	Apoyo	409	199
1512	Asalto	257	2936
1513	Francotirador	387	221
1514	Francotirador	370	2746
1515	Medico	426	1767
1516	Apoyo	318	1253
1517	Apoyo	185	2477
1518	Asalto	234	400
1519	Medico	268	1379
1520	Medico	363	1958
1521	Ingeniero	330	1953
1522	Apoyo	278	2215
1523	Ingeniero	473	196
1524	Ingeniero	81	419
1525	Ingeniero	183	2687
1526	Apoyo	368	1988
1527	Ingeniero	280	2823
1528	Asalto	20	2554
1529	Asalto	115	1903
1531	Francotirador	360	1938
1532	Asalto	131	2184
1533	Asalto	245	145
1534	Medico	245	1827
1535	Francotirador	378	619
1537	Medico	326	253
1538	Medico	267	2670
1539	Asalto	470	2906
1540	Apoyo	417	1091
1541	Ingeniero	130	1479
1542	Francotirador	333	1381
1543	Medico	312	1083
1544	Ingeniero	186	1582
1545	Ingeniero	376	758
1546	Ingeniero	270	1821
1547	Ingeniero	282	2634
1548	Francotirador	16	2303
1549	Medico	119	2580
1550	Apoyo	243	1672
1551	Asalto	214	2069
1552	Ingeniero	232	200
1553	Asalto	398	812
1554	Francotirador	429	1747
1555	Medico	139	2197
1556	Medico	397	2265
1557	Ingeniero	343	1379
1558	Ingeniero	286	1219
1559	Francotirador	464	2398
1560	Medico	362	1086
1561	Ingeniero	192	491
1562	Medico	224	1791
1563	Apoyo	310	188
1564	Francotirador	459	412
1565	Ingeniero	156	2382
1566	Ingeniero	128	1379
1567	Francotirador	206	885
1568	Francotirador	73	849
1569	Medico	396	2912
1570	Asalto	164	1547
1571	Medico	294	821
1572	Francotirador	476	602
1573	Medico	265	2709
1574	Asalto	62	2257
1576	Medico	123	1577
1577	Francotirador	60	1844
1578	Francotirador	18	283
1580	Ingeniero	198	792
1581	Apoyo	115	2348
1582	Apoyo	287	1726
1583	Ingeniero	287	1181
1584	Apoyo	1	2310
1585	Ingeniero	149	92
1586	Apoyo	54	2647
1587	Asalto	265	2902
1588	Asalto	462	2112
1589	Asalto	135	1258
1590	Asalto	24	532
1591	Asalto	205	1770
1592	Asalto	377	1710
1593	Francotirador	285	1184
1594	Ingeniero	253	1195
1595	Asalto	247	1640
1596	Francotirador	219	1660
1597	Medico	150	2667
1598	Ingeniero	133	161
1599	Asalto	461	177
1600	Ingeniero	480	304
1601	Francotirador	180	887
1602	Medico	127	2432
1603	Apoyo	15	2302
1604	Asalto	383	851
1605	Ingeniero	397	2833
1606	Francotirador	180	980
1607	Ingeniero	459	1440
1608	Apoyo	278	1992
1609	Ingeniero	33	2113
1610	Ingeniero	78	1175
1611	Asalto	447	289
1612	Apoyo	497	1620
1613	Ingeniero	465	2940
1614	Francotirador	391	1448
1615	Ingeniero	90	1420
1616	Medico	395	2127
1617	Asalto	25	495
1618	Medico	351	518
1619	Apoyo	292	59
1620	Ingeniero	278	2850
1621	Apoyo	122	1082
1622	Francotirador	422	2155
1623	Medico	243	1326
1624	Asalto	429	731
1626	Apoyo	307	1820
1627	Ingeniero	129	320
1628	Asalto	480	1550
1630	Apoyo	118	1862
1631	Asalto	357	167
1632	Apoyo	366	559
1633	Medico	481	686
1634	Ingeniero	27	2473
1635	Medico	121	2273
1636	Ingeniero	211	156
1638	Francotirador	407	1883
1639	Francotirador	163	2059
1640	Apoyo	284	2519
1641	Ingeniero	139	419
1642	Ingeniero	436	580
1643	Francotirador	387	2775
1644	Ingeniero	449	2832
1645	Francotirador	123	1870
1646	Asalto	443	1564
1647	Asalto	481	2739
1648	Francotirador	407	1157
1649	Asalto	209	2012
1650	Medico	333	325
1651	Francotirador	28	1887
1652	Medico	377	574
1653	Francotirador	368	557
1654	Asalto	245	406
1655	Francotirador	143	2643
1656	Medico	483	630
1657	Francotirador	84	676
1658	Francotirador	351	920
1659	Apoyo	214	756
1660	Apoyo	166	2490
1661	Asalto	272	2475
1662	Ingeniero	124	1543
1664	Francotirador	107	1332
1665	Asalto	50	1444
1666	Medico	352	108
1668	Asalto	150	2420
1669	Ingeniero	382	2604
1670	Francotirador	194	2022
1671	Apoyo	477	2993
1673	Francotirador	379	899
1674	Francotirador	228	1244
1675	Francotirador	54	2283
1676	Apoyo	165	304
1677	Medico	271	1224
1678	Francotirador	435	563
1679	Francotirador	242	1022
1680	Apoyo	87	743
1682	Ingeniero	272	1610
1683	Asalto	131	768
1684	Apoyo	117	2860
1685	Asalto	127	216
1686	Ingeniero	287	2765
1687	Ingeniero	233	1153
1688	Asalto	230	1903
1689	Ingeniero	41	2307
1690	Apoyo	47	1449
1691	Ingeniero	12	2678
1693	Ingeniero	449	1490
1694	Asalto	360	909
1695	Ingeniero	324	740
1696	Medico	266	124
1697	Asalto	468	204
1698	Asalto	309	2590
1699	Medico	335	429
1700	Apoyo	275	1782
1701	Ingeniero	396	1457
1702	Asalto	10	1771
1703	Francotirador	41	1691
1704	Ingeniero	249	1763
1705	Francotirador	60	1567
1707	Medico	132	4
1708	Medico	52	1546
1709	Francotirador	331	2797
1710	Medico	259	2353
1711	Medico	152	2956
1712	Apoyo	35	1636
1713	Ingeniero	355	1912
1714	Francotirador	88	1787
1715	Ingeniero	61	424
1716	Ingeniero	495	2740
1717	Medico	195	124
1718	Francotirador	402	779
1719	Medico	394	1698
1720	Asalto	313	2451
1721	Apoyo	431	2060
1722	Asalto	321	945
1723	Apoyo	68	1186
1724	Asalto	152	639
1725	Apoyo	437	1627
1726	Asalto	364	1625
1727	Ingeniero	216	652
1728	Asalto	203	2023
1729	Francotirador	375	2492
1731	Apoyo	210	902
1732	Francotirador	279	2322
1733	Asalto	139	2119
1734	Francotirador	38	1278
1735	Francotirador	375	285
1736	Medico	73	2601
1737	Francotirador	400	1744
1738	Francotirador	157	1368
1739	Apoyo	454	2891
1740	Ingeniero	300	342
1741	Francotirador	489	2594
1742	Medico	4	2027
1743	Francotirador	269	1207
1745	Francotirador	24	193
1746	Asalto	91	1925
1747	Apoyo	482	845
1748	Medico	272	602
1749	Francotirador	305	1956
1750	Ingeniero	191	340
1751	Asalto	18	1969
1752	Francotirador	1	1754
1754	Medico	136	2072
1755	Francotirador	198	1700
1756	Ingeniero	414	2501
1757	Medico	69	1572
1758	Asalto	145	2631
1759	Asalto	200	2122
1760	Francotirador	90	589
1761	Ingeniero	116	983
1762	Francotirador	308	1633
1763	Ingeniero	176	2990
1764	Ingeniero	244	570
1765	Apoyo	41	2425
1766	Apoyo	178	2400
1767	Francotirador	11	2752
1768	Asalto	10	1685
1769	Francotirador	340	1192
1770	Medico	279	217
1771	Ingeniero	385	581
1772	Ingeniero	140	375
1774	Francotirador	159	184
1775	Apoyo	180	2537
1776	Medico	310	789
1779	Ingeniero	378	972
1780	Apoyo	240	2728
1781	Medico	400	2479
1782	Apoyo	417	391
1783	Ingeniero	205	956
1784	Medico	90	238
1785	Francotirador	476	153
1786	Ingeniero	184	230
1787	Apoyo	303	1021
1788	Asalto	229	671
1789	Apoyo	391	1838
1790	Francotirador	357	625
1791	Medico	117	585
1792	Ingeniero	124	2154
1793	Apoyo	328	1045
1794	Ingeniero	47	79
1795	Francotirador	290	377
1796	Medico	197	479
1797	Asalto	82	1318
1798	Francotirador	201	1384
1799	Francotirador	242	2849
1800	Francotirador	493	126
1801	Ingeniero	285	893
1802	Medico	339	2250
1803	Asalto	382	1582
1804	Ingeniero	59	1641
1805	Apoyo	431	1599
1806	Apoyo	50	280
1807	Asalto	282	797
1808	Ingeniero	165	2759
1809	Ingeniero	250	1137
1810	Medico	44	17
1811	Medico	389	2290
1812	Ingeniero	177	1651
1813	Medico	115	551
1814	Apoyo	424	1994
1815	Apoyo	242	253
1816	Francotirador	145	2254
1817	Medico	92	1963
1818	Apoyo	9	749
1819	Ingeniero	178	2751
1820	Francotirador	470	1935
1821	Asalto	50	2424
1822	Medico	341	1468
1823	Asalto	162	796
1824	Medico	30	1771
1825	Apoyo	275	2721
1826	Apoyo	399	948
1827	Medico	412	2611
1828	Francotirador	264	2679
1830	Asalto	23	1595
1831	Francotirador	466	2411
1832	Apoyo	276	1821
1833	Asalto	56	336
1834	Medico	386	165
1835	Francotirador	220	2377
1836	Francotirador	301	2988
1837	Francotirador	299	2215
1838	Apoyo	413	31
1839	Medico	201	1344
1840	Medico	499	750
1841	Apoyo	387	2587
1842	Francotirador	299	573
1843	Asalto	303	2915
1844	Francotirador	309	1533
1845	Francotirador	358	2658
1846	Francotirador	412	1805
1848	Medico	258	484
1849	Medico	499	1839
1850	Apoyo	385	1790
1851	Francotirador	314	276
1852	Asalto	225	908
1853	Apoyo	383	30
1854	Asalto	256	48
1855	Medico	95	1521
1856	Apoyo	217	2449
1857	Francotirador	100	103
1858	Ingeniero	217	1246
1859	Apoyo	356	467
1860	Apoyo	100	2587
1861	Francotirador	16	1354
1862	Asalto	310	1015
1863	Francotirador	158	1314
1864	Medico	27	1701
1865	Asalto	20	246
1866	Francotirador	67	1853
1867	Medico	173	761
1868	Asalto	265	2933
1869	Medico	46	2607
1870	Medico	294	2881
1871	Asalto	250	927
1872	Ingeniero	223	791
1873	Apoyo	7	1215
1874	Medico	485	1226
1875	Asalto	120	2115
1876	Apoyo	338	2652
1878	Medico	36	543
1879	Apoyo	180	1541
1880	Francotirador	152	1758
1881	Asalto	128	1435
1882	Medico	297	2602
1884	Apoyo	490	60
1885	Asalto	68	2120
1886	Asalto	415	130
1887	Asalto	254	2534
1888	Ingeniero	7	2193
1889	Apoyo	199	420
1890	Asalto	46	2548
1891	Medico	421	2110
1892	Apoyo	268	2424
1894	Francotirador	399	918
1895	Ingeniero	172	900
1896	Francotirador	458	1015
1897	Apoyo	370	1523
1898	Ingeniero	9	1961
1899	Asalto	273	27
1900	Medico	249	542
1901	Medico	162	1144
1902	Asalto	48	2533
1903	Asalto	414	2293
1904	Asalto	308	1016
1905	Francotirador	36	1975
1906	Apoyo	337	849
1907	Medico	176	1555
1908	Asalto	326	1468
1910	Francotirador	81	2630
1911	Ingeniero	78	2365
1912	Ingeniero	358	702
1913	Ingeniero	481	1711
1914	Apoyo	202	1056
1915	Francotirador	142	2316
1916	Francotirador	476	2527
1917	Medico	282	1730
1918	Francotirador	90	2673
1919	Asalto	312	1639
1920	Apoyo	54	2131
1921	Medico	404	2945
1922	Ingeniero	419	1755
1923	Medico	188	653
1924	Medico	162	2538
1925	Ingeniero	392	295
1926	Asalto	260	2716
1927	Apoyo	78	1303
1928	Apoyo	361	2262
1929	Asalto	375	406
1930	Apoyo	363	463
1931	Francotirador	108	849
1932	Apoyo	386	54
1933	Ingeniero	259	1475
1934	Asalto	170	1826
1935	Asalto	189	2205
1936	Apoyo	288	1420
1937	Apoyo	433	1680
1938	Asalto	124	1085
1939	Apoyo	143	1578
1940	Apoyo	295	2997
1941	Apoyo	165	2191
1942	Asalto	277	2725
1943	Ingeniero	204	662
1944	Ingeniero	335	768
1945	Medico	370	1834
1946	Ingeniero	159	1757
1947	Medico	81	122
1948	Asalto	230	2172
1949	Asalto	261	783
1950	Medico	340	2188
1951	Francotirador	260	1789
1952	Asalto	448	807
1953	Medico	327	242
1954	Apoyo	452	1836
1956	Apoyo	190	37
1957	Apoyo	272	2021
1958	Apoyo	492	952
1959	Francotirador	84	594
1960	Medico	192	2531
1961	Francotirador	158	1203
1962	Francotirador	488	2768
1963	Ingeniero	131	2153
1964	Francotirador	178	1909
1965	Ingeniero	373	336
1966	Medico	373	267
1967	Apoyo	417	2057
1968	Medico	309	1188
1969	Ingeniero	279	2180
1970	Apoyo	114	501
1971	Asalto	98	2031
1972	Medico	355	2042
1973	Apoyo	434	501
1974	Medico	161	601
1975	Medico	20	1648
1976	Apoyo	98	1715
1977	Ingeniero	134	180
1978	Ingeniero	127	1773
1979	Ingeniero	61	1036
1980	Ingeniero	284	600
1981	Francotirador	369	2770
1982	Ingeniero	444	810
1983	Apoyo	430	280
1984	Francotirador	221	2213
1986	Asalto	33	232
1987	Francotirador	195	344
1988	Medico	203	1011
1989	Asalto	94	2495
1990	Ingeniero	153	2902
1991	Francotirador	225	44
1992	Medico	16	2494
1993	Asalto	69	1409
1994	Apoyo	174	2209
1995	Asalto	38	2624
1996	Francotirador	111	1751
1997	Asalto	370	1031
1999	Medico	325	533
2000	Apoyo	408	2407
\.


--
-- Data for Name: base_militar; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.base_militar (id_base, nombre_base, ubicacion) FROM stdin;
1	Base Herrera	Quimbaya
2	Base Osorio	Villanueva
3	Base Orozco	CharalÃ¡
4	Base Rojas	Yopal
5	Base Cardozo	Natagaima
6	Base RodrÃ­guez	Valdivia
7	Base Sandoval	El Doncello
8	Base GonzÃ¡lez	Falan
9	Base MejÃ­a	Puerto BoyacÃ¡
10	Base Castro	Puerto BoyacÃ¡
11	Base Contreras	Puerto LÃ³pez
12	Base Cruz	San Bernardo
13	Base BermÃºdez	SotaquirÃ¡
14	Base GÃ³mez	Santander de Quilichao
15	Base Cabrera	Anolaima
16	Base CÃ³rdoba	MistratÃ³
17	Base Vargas	Cumbitara
18	Base GarcÃ­a	ChigorodÃ³
19	Base Espinosa	Sapuyes
20	Base Arenas	Yotoco
21	Base DÃ­az	CoveÃ±as
22	Base CalderÃ³n	Cisneros
23	Base BenÃ­tez	Armenia
24	Base PÃ©rez	Florencia
25	Base Castillo	PurÃ­sima de la ConcepciÃ³n
26	Base RamÃ­rez	Sevilla
27	Base GonzÃ¡lez	PotosÃ­
28	Base Morales	Guayabetal
29	Base MuÃ±oz	Jenesano
30	Base Lozano	Arroyohondo
31	Base Serna	GonzÃ¡lez
32	Base Vallejo	Palmito
33	Base GarcÃ­a	Momil
34	Base Ochoa	GÃ¼icÃ¡n de la Sierra
35	Base RamÃ­rez	NunchÃ­a
36	Base Cano	Tipacoque
37	Base Guerrero	San Pablo
38	Base Solano	TurmequÃ©
39	Base MuÃ±oz	TarapacÃ¡
40	Base Soto	ChocontÃ¡
41	Base JimÃ©nez	MitÃº
42	Base Benavides	SusacÃ³n
43	Base Montoya	Roncesvalles
45	Base RodrÃ­guez	San Jacinto del Cauca
46	Base GutiÃ©rrez	Cimitarra
47	Base Herrera	Bajo BaudÃ³
48	Base Ramos	La UniÃ³n
49	Base Henao	San Luis de SincÃ©
50	Base HernÃ¡ndez	Valencia
\.


--
-- Data for Name: batallon; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.batallon (id_batallon, nombre_batallon, id_base) FROM stdin;
1	Batallon de Vendedor de comidas 	46
2	Batallon de Trabajador agrÃ­cola 	36
3	Batallon de Optometrista	36
4	Batallon de Juez	14
5	Batallon de TÃ©cnico en ciencias 	17
6	Batallon de Vendedor ambulantes 	12
7	Batallon de Prestamista	30
8	Batallon de Organizador de confe	22
9	Batallon de Criador de ganado	20
10	Batallon de Electricista de obra	41
11	Batallon de MecÃ¡nico y reparador	17
12	Batallon de MÃ©dico general	24
13	Batallon de CapitÃ¡n decubierta	17
14	Batallon de Oficial de las fuerz	18
15	Batallon de Bibliotecarios	22
16	Batallon de MecÃ¡nico y reparador	49
17	Batallon de Aparejador	45
18	Batallon de Ayudante de ambulanc	20
19	Batallon de Criador de ganado	47
21	Batallon de CartÃ³grafo	50
22	Batallon de Asistente de venta	22
23	Batallon de Profesional de nivel	20
24	Batallon de Suboficial de las fu	49
25	Batallon de Analista de gestiÃ³n 	9
26	Batallon de Operario del tratami	46
27	Batallon de Empleado de control 	1
28	Batallon de Prestamista	31
29	Batallon de Entrevistador de inv	4
30	Batallon de Barrendero	38
31	Batallon de Mayordomo domÃ©stico	46
32	Batallon de Practicante y asiste	47
33	Batallon de Profesional de la sa	38
34	Batallon de PeÃ³n de obras pÃºblic	24
35	Batallon de Curtidor	31
36	Batallon de TÃ©cnico en seguridad	13
37	Batallon de Vendedor de comidas 	1
38	Batallon de Trabajador social de	16
39	Batallon de Oficial de cubierta	18
40	Batallon de Platero	7
41	Batallon de Nutricionista	30
42	Batallon de Agente inmobiliario	41
43	Batallon de Catador de alimentos	29
44	Batallon de Ebanista	14
45	Batallon de Fumigador	11
46	Batallon de Gerente general	40
47	Batallon de Curador de museos	45
48	Batallon de Profesional del trab	30
49	Batallon de Operador de mÃ¡quinas	3
50	Batallon de Demostrador de tiend	48
51	Batallon de Operador de mÃ¡quinas	50
52	Batallon de TÃ©cnico forestal	28
53	Batallon de TÃ©cnico en ciencias 	3
54	Batallon de Maestro preescolar	8
55	Batallon de TÃ©cnico en optometrÃ­	25
56	Batallon de Ayudante de ambulanc	40
57	Batallon de Marinero de cubierta	16
58	Batallon de Instalador y reparad	36
59	Batallon de Limpiador y asistent	1
60	Batallon de Vendedor ambulantes 	16
61	Batallon de Repartidor	43
62	Batallon de Tasador	36
63	Batallon de Compositor	22
64	Batallon de Tasador	15
65	Batallon de Operador de instalac	8
66	Batallon de Asistente de venta	39
67	Batallon de Conductor de taxis	1
68	Batallon de PeÃ³n de explotacione	15
69	Batallon de TÃ©cnico de la Web	22
70	Batallon de MÃ©dico especialista	36
71	Batallon de Buzo	20
72	Batallon de Fontanero	25
73	Batallon de TÃ©cnico en quÃ­mica i	16
74	Batallon de Expendedor de gasoli	43
75	Batallon de CoreÃ³grafo	5
76	Batallon de Analista de gestiÃ³n 	29
77	Batallon de PeÃ³n de explotacione	37
78	Batallon de PeÃ³n de explotacione	41
79	Batallon de Carpintero	22
80	Batallon de Empleado de servicio	42
81	Batallon de Regulador y operador	17
82	Batallon de Trabajador social de	2
83	Batallon de Director de polÃ­tica	34
84	Batallon de PeÃ³n de carga	3
85	Batallon de Artista plÃ¡stico	10
86	Batallon de AlbaÃ±il	33
87	Batallon de TÃ©cnico en ingenierÃ­	11
88	Batallon de Especialista en mÃ©to	36
90	Batallon de Profesional de nivel	23
91	Batallon de Conductor de camione	9
92	Batallon de Expendedor de gasoli	48
93	Batallon de Clasificador de prod	22
94	Batallon de Maestro de enseÃ±anza	34
95	Batallon de Trabajador forestal 	1
96	Batallon de PeÃ³n de explotacione	12
97	Batallon de Director de recursos	39
98	Batallon de Supervisor de manten	45
99	Batallon de Operador de instalac	35
100	Batallon de Chapista	13
\.


--
-- Data for Name: calibre; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.calibre (id_calibre, nombre_calibre, tipo_penetracion) FROM stdin;
1	48mm	Perforante
2	5mm	Media
3	7mm	Perforante
4	31mm	Perforante
5	11mm	Perforante
6	21mm	Ligera
7	8mm	Media
8	22mm	Media
9	38mm	Media
10	35mm	Media
11	17mm	Media
12	24mm	Ligera
13	5mm	Perforante
14	11mm	Perforante
15	33mm	Perforante
16	37mm	Ligera
17	42mm	Media
18	5mm	Ligera
19	7mm	Perforante
20	34mm	Perforante
21	12mm	Media
22	5mm	Media
23	30mm	Perforante
24	16mm	Perforante
25	5mm	Ligera
26	9mm	Perforante
27	7mm	Ligera
28	39mm	Media
29	25mm	Perforante
30	16mm	Media
\.


--
-- Data for Name: categoria_arma; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.categoria_arma (id_categoria, nombre_categoria, nivel_restriccion) FROM stdin;
1	Categoria 1	Estandar
2	Categoria 2	Estandar
3	Categoria 3	Clasificada
4	Categoria 4	Restringida
5	Categoria 5	Clasificada
6	Categoria 6	Restringida
7	Categoria 7	Restringida
8	Categoria 8	Clasificada
9	Categoria 9	Estandar
10	Categoria 10	Restringida
11	Categoria 11	Restringida
12	Categoria 12	Estandar
13	Categoria 13	Clasificada
14	Categoria 14	Estandar
15	Categoria 15	Estandar
16	Categoria 16	Clasificada
17	Categoria 17	Estandar
18	Categoria 18	Restringida
19	Categoria 19	Estandar
20	Categoria 20	Clasificada
\.


--
-- Data for Name: especialidad; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.especialidad (id_especialidad, nombre_especialidad, descripcion_rol, nivel_riesgo, bono_salarial) FROM stdin;
1	Esp-1	EcÃ³nomo y mayordomos domÃ©sticos	Extremo	211.68
2	Esp-2	Especialista en polÃ­ticas de administrac	Medio	716.39
3	Esp-3	Mayordomo domÃ©stico	Extremo	334.79
4	Esp-4	Operador de mÃ¡quinas de preparaciÃ³n de f	Bajo	980.78
5	Esp-5	Nutricionista	Bajo	190.97
6	Esp-6	Trabajador ambulante de servicios	Bajo	340.94
7	Esp-7	Corrector de pruebas de imprenta	Medio	348.58
8	Esp-8	Perforador y sondista de pozos	Bajo	948.76
9	Esp-9	Director de empresas de abastecimiento, 	Bajo	929.68
10	Esp-10	Director financiero	Alto	596.32
11	Esp-11	Barnizador	Alto	150.96
12	Esp-12	Lavador de vehÃ­culos	Alto	314.33
13	Esp-13	Oficinista general	Bajo	256.74
14	Esp-14	Conductor de taxis	Bajo	384.15
15	Esp-15	Maestro preescolar	Extremo	833.62
16	Esp-16	Ingeniero quÃ­mico	Extremo	756.08
17	Esp-17	Operador de instalaciones para la prepar	Medio	490.87
18	Esp-18	Vendedor de comidas al mostrador	Extremo	660.13
19	Esp-19	Operador de mÃ¡quinas de embalaje, embote	Alto	647.63
20	Esp-20	Especialista en formaciÃ³n del personal	Alto	437.19
21	Esp-21	Operador de maquinaria agrÃ­cola y forest	Bajo	967.54
22	Esp-22	Director de recursos humanos	Medio	268.30
23	Esp-23	AlbaÃ±il	Bajo	124.74
24	Esp-24	Tapicero	Bajo	783.54
25	Esp-25	Inspector de la salud laboral	Medio	716.13
26	Esp-26	Profesional de nivel medio de medicina t	Extremo	744.43
27	Esp-27	Agente de empleo	Extremo	936.17
28	Esp-28	Empleado de agencia de viajes	Alto	910.49
29	Esp-29	Chapista	Medio	113.23
30	Esp-30	Lavandero	Medio	857.25
31	Esp-31	TÃ©cnico en aparatos de diagnÃ³stico y tra	Bajo	137.85
32	Esp-32	Agente de bolsa	Medio	346.49
33	Esp-33	Carpintero	Extremo	735.97
34	Esp-34	Profesor de formaciÃ³n profesional	Medio	306.35
35	Esp-35	Operario del tratamiento de la madera	Alto	318.12
36	Esp-36	Camarero de barra	Bajo	185.58
37	Esp-37	Ensamblador de equipos electrÃ³nicos	Bajo	323.88
38	Esp-38	Dinamitero	Medio	183.33
39	Esp-39	Herramentista	Extremo	999.50
40	Esp-40	MatemÃ¡tico	Alto	240.02
41	Esp-41	Carpintero	Alto	249.49
42	Esp-42	Revisor y cobrador de los transportes pÃº	Medio	801.18
43	Esp-43	Operador de mÃ¡quinas pulidoras, galvaniz	Medio	559.18
44	Esp-44	Mayordomo domÃ©stico	Alto	550.16
45	Esp-45	Tapicero	Extremo	579.60
46	Esp-46	Profesional de parterÃ­a	Alto	602.76
47	Esp-47	Oficial maquinistas en navegaciÃ³n	Bajo	571.13
48	Esp-48	Operador de grÃºas y aparatos elevadores	Bajo	525.68
49	Esp-49	CartÃ³grafo	Bajo	588.97
50	Esp-50	MecÃ¡nico y ajustador electricista	Bajo	519.60
\.


--
-- Data for Name: explosivo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.explosivo (id_arma, fecha_caducidad, peso_kg) FROM stdin;
1001	2027-01-27	43.45
1002	2029-05-21	30.98
1003	2028-06-15	2.26
1004	2031-03-23	18.05
1005	2029-10-04	7.77
1006	2030-03-04	29.92
1008	2028-04-12	30.81
1009	2027-12-07	18.27
1010	2029-12-07	6.93
1011	2028-09-27	20.23
1012	2028-12-25	37.13
1013	2029-09-19	20.79
1014	2031-04-13	9.59
1015	2027-10-09	19.73
1016	2028-05-09	40.11
1017	2027-06-18	37.85
1018	2030-02-04	29.52
1019	2030-09-20	20.83
1020	2029-05-06	3.58
1021	2029-09-21	48.03
1022	2028-12-14	23.12
1023	2030-07-01	22.81
1024	2031-04-09	24.11
1025	2030-07-31	33.13
1026	2027-08-22	17.89
1027	2030-01-18	47.37
1028	2028-06-09	16.13
1029	2029-04-16	19.15
1030	2028-05-08	41.44
1031	2029-07-13	11.41
1032	2029-10-26	46.95
1033	2027-08-28	24.10
1034	2027-09-03	30.23
1035	2029-09-17	44.15
1036	2028-05-08	44.73
1037	2030-08-03	38.45
1038	2030-04-29	47.03
1039	2027-12-31	41.54
1040	2029-04-23	31.07
1042	2029-03-07	7.37
1043	2028-08-12	32.26
1044	2031-02-02	25.37
1045	2029-03-25	20.69
1046	2031-07-23	29.96
1047	2029-11-28	1.18
1048	2031-08-15	23.97
1049	2027-07-24	18.66
1050	2030-11-11	47.69
1051	2028-12-25	4.82
1052	2030-07-03	19.93
1053	2029-08-01	12.39
1054	2027-04-16	7.64
1055	2027-10-19	23.96
1056	2030-08-01	28.57
1057	2031-04-27	35.34
1058	2029-09-13	4.30
1059	2027-09-17	11.20
1060	2027-05-23	41.39
1061	2031-04-28	32.62
1062	2031-03-10	44.93
1064	2030-03-21	8.23
1065	2028-08-15	13.10
1066	2029-07-18	16.39
1067	2031-03-21	48.50
1068	2027-03-30	7.83
1069	2029-07-26	8.00
1070	2031-06-15	22.09
1071	2030-04-29	40.08
1072	2029-10-08	9.61
1073	2029-06-16	40.57
1074	2029-02-25	2.33
1075	2028-11-03	11.73
1077	2029-10-10	32.74
1078	2030-08-10	8.91
1079	2031-03-31	27.67
1080	2028-02-18	43.11
1081	2030-08-20	31.23
1082	2029-05-24	33.11
1083	2030-12-15	43.37
1084	2029-08-18	31.57
1085	2027-03-29	41.65
1086	2031-05-02	38.19
1087	2027-12-02	3.72
1088	2027-02-23	24.65
1089	2027-10-19	35.55
1090	2027-01-01	24.46
1091	2027-10-19	40.62
1092	2027-08-27	3.74
1093	2028-04-24	45.84
1094	2029-12-03	49.28
1095	2027-05-02	23.79
1096	2028-01-12	46.69
1097	2027-11-04	20.84
1098	2031-08-10	45.84
1099	2030-07-28	7.44
1100	2027-05-17	32.78
1101	2030-08-10	7.85
1103	2029-03-11	19.18
1104	2028-02-26	20.14
1107	2030-11-08	29.14
1108	2029-07-18	37.88
1109	2027-03-12	14.13
1110	2027-03-11	12.90
1111	2030-02-14	2.80
1112	2027-12-27	33.04
1113	2028-07-19	33.43
1114	2031-07-25	41.46
1115	2026-10-10	43.85
1116	2030-12-19	9.82
1117	2030-03-10	45.36
1118	2028-08-10	15.98
1119	2031-03-15	41.43
1120	2031-03-18	19.43
1121	2030-05-12	21.76
1122	2028-02-17	21.11
1124	2027-08-13	49.38
1125	2027-11-04	16.04
1126	2028-02-09	27.68
1127	2028-01-24	6.36
1128	2027-08-20	7.39
1129	2029-02-20	25.53
1130	2029-05-25	44.41
1131	2030-11-25	21.86
1132	2029-07-28	13.45
1133	2030-12-03	28.35
1134	2027-02-22	21.14
1135	2027-03-15	34.57
1136	2027-02-19	49.94
1137	2030-02-25	34.25
1138	2026-12-18	19.48
1139	2028-07-14	35.28
1140	2030-04-16	49.84
1141	2031-01-25	29.91
1142	2028-05-22	22.96
1143	2028-08-20	26.25
1144	2027-01-15	3.82
1145	2027-11-02	2.98
1146	2030-08-26	16.22
1147	2027-05-26	37.72
1148	2028-02-14	26.28
1149	2027-06-20	19.11
1150	2029-10-07	25.11
1151	2031-03-26	12.19
1153	2029-05-03	18.93
1154	2030-11-21	16.28
1155	2026-10-30	6.99
1156	2031-08-20	8.34
1157	2029-07-03	42.44
1158	2031-02-27	29.37
1159	2031-09-03	49.10
1160	2030-01-05	15.58
1161	2027-12-10	45.12
1162	2027-06-21	21.34
1163	2028-06-21	12.50
1164	2027-03-14	11.85
1165	2031-06-03	27.03
1166	2028-03-08	27.54
1167	2029-05-30	37.84
1168	2027-03-21	48.57
1169	2031-04-12	39.46
1170	2031-02-09	43.82
1171	2031-06-28	7.50
1172	2031-08-25	49.61
1173	2029-01-18	18.75
1174	2027-04-27	44.98
1175	2027-07-26	28.03
1176	2028-04-17	2.59
1177	2029-11-02	17.13
1178	2031-08-31	45.48
1179	2030-02-16	36.05
1180	2027-04-11	47.69
1181	2029-04-27	28.90
1183	2027-02-11	1.90
1184	2029-11-30	34.13
1186	2027-05-15	8.63
1187	2030-11-19	22.82
1188	2030-01-06	30.20
1189	2028-05-10	5.50
1190	2030-11-03	46.32
1191	2027-07-21	43.68
1192	2028-02-11	4.31
1193	2027-07-15	13.12
1194	2028-01-22	31.16
1195	2028-06-18	29.86
1196	2028-01-06	23.95
1197	2027-12-22	39.57
1198	2027-08-15	23.93
1199	2030-08-09	6.91
1200	2030-07-24	11.46
1201	2027-05-19	43.33
1202	2027-11-02	12.97
1203	2027-01-12	31.83
1204	2029-08-27	28.78
1205	2029-02-20	18.48
1206	2028-12-25	7.82
1207	2028-05-20	24.84
1208	2028-01-10	10.91
1209	2031-05-07	48.77
1210	2027-12-27	46.98
1211	2031-07-16	47.22
1212	2029-04-12	0.96
1213	2027-01-12	21.49
1214	2027-05-18	20.26
1215	2027-03-21	12.92
1216	2027-12-29	31.29
1217	2030-02-24	8.62
1218	2026-10-09	18.44
1219	2027-02-14	19.71
1220	2030-11-27	49.47
1221	2030-01-21	7.12
1222	2030-04-07	43.55
1223	2029-11-30	34.45
1224	2031-01-30	19.48
1225	2029-03-22	12.67
1226	2026-10-06	45.85
1227	2029-09-24	8.36
1228	2026-10-23	37.01
1229	2031-08-08	49.53
1230	2026-10-18	22.65
1231	2026-11-18	43.40
1232	2030-08-09	7.14
1233	2027-06-28	29.87
1234	2027-01-09	12.71
1235	2031-06-07	41.39
1236	2027-06-03	13.03
1237	2026-11-20	24.97
1238	2026-12-10	7.03
1239	2029-06-28	14.48
1240	2031-02-09	29.93
1241	2028-03-18	39.63
1242	2029-12-29	47.15
1243	2027-02-20	12.53
1244	2028-08-10	1.75
1245	2030-09-22	27.66
1246	2026-10-07	34.35
1247	2026-11-05	32.55
1248	2027-04-20	23.36
1249	2031-02-14	13.78
1250	2031-09-25	43.91
1251	2026-10-08	10.13
1252	2030-09-06	25.05
1253	2030-04-07	26.16
1254	2029-02-18	8.76
1255	2027-06-23	42.53
1256	2031-03-11	35.01
1257	2029-11-19	35.70
1258	2027-01-03	34.52
1259	2031-01-05	32.34
1260	2030-01-08	20.99
1262	2026-10-04	8.64
1263	2030-09-14	41.40
1264	2027-12-01	1.75
1265	2031-07-01	41.63
1266	2027-09-10	41.34
1268	2027-01-16	13.27
1269	2029-05-24	14.85
1270	2026-11-04	39.96
1271	2026-10-21	34.45
1272	2027-06-08	41.54
1273	2028-09-18	35.36
1274	2029-07-14	37.31
1275	2027-07-09	36.43
1276	2029-04-22	24.68
1277	2031-03-13	49.59
1278	2029-05-26	31.46
1279	2026-11-21	28.35
1280	2029-08-19	16.46
1281	2030-10-02	21.79
1282	2027-04-05	28.96
1283	2030-12-06	41.04
1284	2030-08-19	35.22
1285	2029-06-26	33.86
1286	2029-03-15	11.94
1287	2027-12-03	41.33
1288	2030-06-13	10.46
1289	2026-10-14	20.50
1290	2029-02-03	20.24
1291	2026-10-27	41.15
1292	2029-12-01	15.68
1293	2026-12-04	6.27
1294	2028-04-08	0.99
1295	2030-07-08	4.18
1296	2029-11-11	17.16
1297	2031-02-16	37.99
1298	2027-06-21	4.68
1299	2030-07-03	11.86
1300	2030-05-20	23.69
1301	2031-02-17	29.00
1302	2027-05-10	20.85
1303	2026-12-26	12.15
1304	2030-09-13	11.30
1305	2030-06-24	10.88
1306	2027-10-18	0.50
1307	2028-10-16	15.10
1308	2027-12-17	42.79
1309	2027-10-28	41.35
1310	2029-02-03	25.60
1311	2030-09-01	5.03
1312	2031-02-12	17.55
1313	2030-08-30	28.02
1314	2028-01-19	49.11
1315	2030-09-25	45.10
1316	2030-12-19	31.83
1317	2028-02-27	31.25
1318	2030-11-28	49.81
1319	2028-01-15	9.80
1320	2029-02-07	47.51
1321	2029-12-06	35.91
1322	2029-01-26	36.38
1323	2030-06-26	29.38
1324	2030-05-16	32.79
1325	2030-12-04	46.37
1326	2030-03-13	36.29
1327	2028-07-15	8.43
1328	2031-04-16	6.66
1329	2031-02-07	29.91
1330	2028-08-15	33.26
1331	2030-07-23	20.09
1332	2028-08-10	28.22
1333	2029-07-19	16.21
1334	2029-02-05	23.92
1335	2030-03-10	4.10
1336	2027-12-18	8.56
1337	2030-11-10	26.23
1338	2028-09-13	24.29
1339	2027-01-04	44.07
1340	2031-07-09	46.42
1341	2028-01-09	22.86
1342	2029-05-15	48.25
1343	2030-06-21	44.83
1344	2031-07-29	4.24
1345	2027-07-23	17.92
1346	2029-12-20	37.86
1347	2030-07-10	32.81
1348	2029-03-25	12.11
1349	2026-10-27	28.98
1350	2030-10-28	16.63
1351	2027-04-25	36.47
1352	2028-01-14	11.18
1353	2029-07-08	16.83
1354	2027-10-04	22.20
1355	2028-03-18	24.75
1356	2028-03-09	41.30
1357	2030-02-03	40.82
1358	2031-02-28	39.43
1359	2029-12-14	20.53
1360	2028-08-04	6.60
1361	2029-08-31	18.79
1362	2026-11-12	49.19
1363	2029-07-09	0.97
1364	2031-01-29	18.39
1365	2026-12-26	49.31
1366	2030-03-31	40.91
1367	2027-04-17	13.64
1368	2030-04-29	42.18
1369	2027-03-26	45.02
1370	2031-04-07	5.54
1371	2030-01-03	10.93
1372	2031-01-06	47.53
1373	2029-08-01	1.26
1374	2029-02-11	7.29
1375	2028-06-28	19.31
1376	2031-06-12	6.26
1377	2030-11-15	0.65
1378	2027-10-01	39.67
1379	2027-11-10	19.17
1380	2027-05-30	13.30
1381	2031-07-13	24.05
1382	2030-03-22	21.55
1383	2027-06-05	4.07
1384	2027-11-06	1.00
1385	2027-03-16	4.32
1386	2028-06-07	11.33
1387	2026-12-31	34.18
1388	2029-04-08	47.60
1389	2026-10-26	7.25
1390	2026-12-30	28.06
1391	2028-09-25	49.67
1392	2030-06-22	16.77
1393	2028-09-01	41.03
1394	2031-06-18	19.52
1395	2030-04-05	38.89
1396	2027-03-24	43.56
1397	2029-09-18	20.00
1398	2030-06-25	14.86
1399	2028-09-24	4.96
1400	2029-03-15	4.69
1401	2030-05-05	19.48
1402	2030-03-10	7.71
1403	2029-01-28	4.92
1404	2027-06-18	35.70
1405	2028-04-22	37.18
1406	2028-12-05	6.95
1407	2029-10-03	35.65
1408	2029-12-18	37.47
1409	2030-04-23	37.31
1410	2028-02-14	47.10
1411	2031-01-16	14.15
1412	2030-07-10	18.55
1413	2026-12-26	37.12
1414	2028-08-14	46.21
1415	2029-06-28	8.02
1416	2030-11-21	48.83
1417	2028-11-05	22.94
1418	2030-01-25	46.88
1419	2028-12-17	37.88
1420	2028-03-18	20.00
1421	2027-08-08	37.51
1422	2031-06-05	11.32
1423	2029-11-03	38.25
1424	2029-12-05	33.21
1425	2027-12-18	1.11
1426	2030-03-23	19.32
1427	2027-01-30	13.83
1428	2030-12-30	31.39
1429	2026-10-08	13.93
1430	2030-12-28	21.94
1431	2030-05-30	28.82
1432	2029-12-31	27.71
1434	2027-10-28	45.76
1435	2027-06-28	10.85
1436	2030-11-21	4.02
1437	2029-05-28	42.85
1438	2030-09-20	37.83
1439	2031-03-24	44.43
1440	2029-07-13	10.29
1441	2031-09-17	34.58
1442	2030-08-12	22.82
1443	2028-08-01	30.03
1444	2031-05-05	42.99
1445	2031-05-02	27.27
1446	2030-12-03	10.37
1447	2026-11-30	0.55
1448	2029-11-07	39.02
1449	2028-12-22	43.47
1450	2028-10-11	18.42
1452	2028-09-23	43.51
1453	2028-12-19	49.14
1454	2030-11-09	7.72
1455	2027-06-12	14.81
1456	2028-02-10	29.04
1457	2031-06-28	22.15
1458	2029-09-01	45.67
1459	2027-09-23	14.21
1460	2027-12-03	21.15
1461	2027-01-15	8.82
1462	2027-10-19	35.26
1463	2029-08-15	41.56
1464	2030-06-24	5.62
1465	2028-10-17	20.88
1466	2030-03-14	39.23
1467	2030-10-18	19.07
1468	2030-12-27	19.14
1469	2027-09-14	21.60
1470	2030-07-30	46.77
1471	2030-04-23	42.55
1472	2031-09-12	26.32
1473	2029-12-06	47.37
1474	2028-07-25	3.87
1475	2026-12-19	43.17
1476	2028-05-16	5.83
1478	2030-06-16	44.49
1479	2027-12-27	49.75
1481	2028-09-23	11.34
1482	2028-01-27	41.63
1483	2027-11-18	33.27
1484	2028-12-13	47.64
1485	2027-10-07	17.38
1486	2027-07-22	8.41
1487	2028-05-14	47.54
1488	2029-01-27	6.27
1489	2030-01-22	43.25
1490	2028-06-23	49.77
1491	2030-03-22	26.64
1492	2030-10-16	12.22
1493	2029-04-04	3.95
1494	2030-10-18	23.02
1495	2028-11-13	2.06
1496	2029-02-09	43.36
1497	2027-02-14	45.99
1498	2028-02-25	30.98
1499	2027-06-26	25.35
1500	2030-05-25	21.88
1501	2029-12-17	31.58
1502	2031-09-26	29.16
1503	2028-08-07	38.74
1504	2027-10-04	33.35
1505	2028-09-19	20.44
1506	2027-08-28	44.57
1507	2030-09-30	27.67
1508	2030-08-02	11.36
1509	2026-11-27	5.09
1510	2031-02-26	30.05
1511	2028-07-05	19.39
1512	2028-02-26	16.41
1513	2027-12-07	0.61
1514	2030-03-24	19.82
1515	2029-08-12	37.09
1516	2029-05-25	35.70
1517	2031-01-04	15.31
1518	2030-02-02	26.34
1519	2028-12-27	1.52
1521	2028-11-18	45.09
1522	2029-01-25	5.34
1523	2029-03-04	26.92
1524	2028-03-29	4.22
1525	2027-12-28	39.14
1526	2030-05-20	12.41
1527	2028-05-07	16.60
1528	2029-03-21	26.39
1529	2031-02-27	46.23
1530	2027-09-18	5.70
1531	2029-09-05	42.94
1532	2030-08-14	6.02
1533	2028-11-23	42.00
1534	2029-10-28	10.96
1535	2029-05-26	9.44
1536	2031-02-12	21.04
1537	2028-08-07	1.75
1538	2028-02-24	22.37
1539	2027-03-08	14.00
1540	2029-10-11	12.23
1541	2028-07-30	15.27
1542	2030-12-27	41.58
1543	2031-06-24	18.89
1545	2029-07-28	42.84
1546	2028-06-22	16.29
1548	2030-04-04	31.11
1549	2029-06-22	25.77
1551	2029-11-11	5.88
1552	2031-09-27	47.82
1553	2029-08-08	43.63
1554	2029-11-12	34.98
1555	2028-07-11	11.47
1556	2027-04-28	34.11
1557	2029-04-23	36.29
1558	2030-11-24	40.31
1559	2027-04-17	16.99
1560	2030-11-10	17.24
1561	2029-08-30	26.49
1562	2030-05-22	33.03
1563	2027-12-19	41.05
1564	2030-06-02	45.75
1565	2028-12-10	12.49
1566	2030-06-23	3.09
1567	2030-11-23	22.60
1568	2028-12-02	13.23
1569	2030-05-18	3.97
1570	2030-07-03	13.18
1571	2030-05-12	32.88
1572	2031-09-26	28.76
1573	2031-04-11	33.94
1574	2028-10-21	6.86
1575	2028-12-25	13.80
1576	2028-09-28	29.36
1577	2028-03-16	21.06
1578	2030-02-05	31.91
1579	2030-05-04	38.92
1580	2029-11-17	4.22
1581	2028-11-11	2.28
1582	2028-02-27	33.00
1583	2029-06-18	28.28
1584	2031-03-13	1.19
1585	2028-10-22	16.57
1586	2029-07-04	40.72
1587	2031-08-23	20.16
1588	2030-04-26	10.07
1591	2029-01-29	33.56
1592	2030-09-26	16.49
1593	2030-05-31	16.38
1594	2030-06-22	4.34
1595	2028-07-15	23.16
1596	2031-09-10	16.77
1597	2027-12-26	1.92
1598	2028-07-18	38.06
1599	2027-01-08	12.90
1600	2030-10-09	44.20
1602	2028-02-17	40.59
1603	2030-11-28	42.53
1604	2027-02-20	45.80
1605	2031-03-01	15.18
1606	2027-08-07	10.99
1607	2030-03-18	48.14
1608	2028-01-04	15.39
1609	2027-09-06	34.58
1610	2028-05-09	34.68
1611	2031-02-21	20.45
1612	2028-07-30	33.90
1613	2027-12-09	5.14
1614	2028-05-18	13.16
1615	2029-12-16	27.11
1616	2029-11-19	44.09
1617	2029-10-20	42.21
1618	2026-10-27	1.06
1619	2030-04-01	33.25
1621	2026-11-15	42.09
1622	2028-11-30	37.16
1623	2029-06-14	20.10
1624	2030-06-08	38.83
1625	2028-03-31	35.17
1626	2031-03-07	44.61
1627	2028-01-21	17.54
1628	2031-02-18	36.16
1629	2030-01-19	6.27
1630	2028-10-11	10.44
1631	2029-09-04	43.35
1632	2031-07-21	6.99
1633	2027-03-26	49.94
1634	2027-06-03	44.77
1635	2031-02-12	15.45
1636	2026-11-02	46.16
1637	2029-06-28	13.62
1638	2030-04-14	5.33
1639	2031-09-20	48.52
1641	2030-02-07	20.39
1642	2026-12-13	42.02
1643	2030-07-24	25.02
1644	2028-12-30	4.44
1645	2031-06-11	38.02
1646	2031-06-24	20.44
1647	2030-03-13	14.80
1648	2027-05-07	0.97
1649	2030-03-12	39.42
1650	2029-03-05	34.36
1651	2029-04-02	0.66
1652	2027-06-15	10.39
1653	2028-09-26	42.48
1654	2028-09-12	41.06
1655	2026-12-14	40.86
1656	2028-12-06	6.33
1657	2030-07-04	29.24
1658	2028-01-10	41.40
1659	2030-03-14	42.26
1660	2028-03-25	6.20
1661	2027-12-01	44.02
1662	2031-02-02	20.66
1663	2030-03-20	25.94
1664	2027-02-14	7.92
1665	2027-03-13	43.44
1666	2031-09-02	0.72
1667	2029-01-21	22.28
1668	2028-12-17	4.99
1669	2031-05-08	33.10
1670	2027-01-12	1.93
1671	2029-02-25	29.04
1673	2029-10-11	29.27
1674	2029-02-17	37.94
1675	2029-05-04	22.34
1676	2030-04-13	34.32
1677	2029-02-03	39.29
1678	2030-04-01	41.03
1679	2027-07-13	35.67
1680	2027-10-30	48.19
1681	2027-05-20	48.16
1682	2030-11-11	17.43
1683	2029-09-23	46.09
1684	2028-07-18	2.85
1685	2027-08-19	7.09
1686	2029-04-26	0.68
1687	2031-09-16	11.31
1689	2031-08-21	39.43
1690	2030-08-23	45.67
1691	2030-06-01	47.14
1692	2027-07-17	43.52
1693	2027-02-01	28.43
1694	2026-11-02	43.51
1695	2030-02-15	45.88
1696	2026-12-21	3.72
1697	2027-12-29	21.42
1698	2029-10-15	25.07
1699	2028-01-15	21.49
1701	2029-03-01	28.18
1702	2031-01-08	35.42
1703	2031-03-07	23.11
1704	2027-07-13	46.87
1705	2028-05-17	19.12
1706	2029-11-25	42.78
1707	2030-04-12	40.96
1708	2029-08-24	31.41
1709	2030-03-06	5.11
1710	2031-06-28	14.54
1711	2027-11-23	3.43
1712	2030-05-19	49.78
1713	2027-02-26	8.88
1714	2028-06-27	36.94
1715	2028-02-22	34.02
1716	2029-10-30	17.20
1717	2028-12-28	17.74
1718	2027-06-22	29.94
1719	2029-05-11	15.47
1720	2031-03-08	11.54
1721	2028-11-22	27.18
1722	2031-08-29	18.87
1723	2028-01-30	18.33
1724	2028-06-27	29.73
1725	2030-07-21	3.48
1726	2029-03-27	7.70
1727	2031-07-28	18.01
1728	2029-05-10	43.36
1729	2029-05-11	29.05
1730	2030-12-12	14.78
1731	2031-01-08	4.85
1732	2031-06-19	34.12
1733	2028-09-15	20.85
1734	2028-06-09	23.22
1735	2028-09-13	42.63
1736	2028-09-22	10.86
1737	2027-01-30	31.24
1738	2031-08-07	14.49
1739	2029-04-11	2.49
1740	2029-03-03	11.68
1741	2028-05-30	19.24
1742	2030-05-06	34.33
1743	2029-11-13	16.08
1744	2031-01-20	30.55
1745	2031-09-26	3.90
1746	2030-05-20	17.47
1747	2027-09-06	33.95
1748	2027-06-28	33.76
1749	2028-03-25	45.06
1750	2029-11-26	11.01
1751	2027-11-17	6.07
1752	2029-11-29	10.14
1753	2027-07-21	39.37
1754	2026-12-28	40.58
1755	2029-09-18	47.10
1756	2031-07-27	21.44
1757	2030-03-17	4.21
1758	2029-08-05	43.38
1759	2028-12-28	19.65
1761	2031-06-08	30.83
1762	2028-03-09	32.42
1763	2031-04-10	48.80
1764	2030-08-09	3.24
1765	2029-04-07	15.09
1766	2029-01-30	35.10
1767	2028-05-01	4.60
1768	2030-09-25	49.43
1769	2030-06-20	11.94
1770	2030-04-11	1.61
1771	2027-12-19	48.29
1772	2028-05-13	48.25
1773	2028-10-09	5.94
1774	2028-09-30	43.20
1775	2027-11-01	36.93
1776	2027-02-16	43.39
1777	2030-02-25	19.79
1778	2027-02-26	5.28
1779	2027-02-04	22.23
1780	2029-07-10	47.45
1781	2029-09-25	27.35
1782	2029-03-29	23.12
1783	2030-11-25	37.41
1784	2029-04-20	32.32
1785	2029-02-26	12.52
1786	2028-10-02	26.80
1787	2030-07-03	35.16
1788	2029-07-08	12.98
1789	2027-01-20	34.26
1790	2027-11-21	31.99
1791	2028-06-04	35.05
1792	2028-11-03	3.71
1793	2027-11-27	12.48
1794	2029-04-15	46.50
1795	2029-09-14	46.37
1796	2030-12-09	29.14
1797	2029-11-23	45.93
1798	2028-11-23	15.64
1799	2028-03-27	42.10
1800	2026-12-13	31.52
1801	2027-07-25	34.37
1802	2029-12-04	16.37
1803	2027-09-25	44.55
1804	2028-01-09	17.03
1805	2028-06-12	19.00
1806	2027-05-02	33.62
1807	2027-09-08	33.55
1808	2028-11-04	45.18
1809	2031-03-01	35.61
1810	2027-03-01	26.08
1811	2029-10-24	27.02
1812	2028-01-05	3.84
1813	2028-04-12	24.55
1814	2028-05-21	18.84
1815	2029-12-15	48.79
1816	2030-07-27	33.53
1817	2028-08-16	31.75
1818	2027-11-05	39.66
1819	2030-10-03	47.38
1820	2027-10-16	17.18
1821	2030-03-28	25.84
1822	2029-08-25	6.51
1823	2026-12-21	31.99
1824	2031-04-02	25.29
1825	2028-07-18	4.39
1826	2028-08-01	23.65
1827	2028-01-18	29.20
1828	2031-09-17	14.52
1829	2027-02-15	15.03
1830	2030-04-21	21.61
1831	2030-05-19	25.52
1832	2030-04-28	28.71
1833	2028-02-17	17.47
1834	2027-08-26	28.66
1835	2030-03-15	43.78
1836	2028-08-01	31.51
1837	2027-12-09	44.14
1838	2027-05-22	36.48
1839	2029-05-08	39.48
1840	2031-07-14	16.92
1841	2028-07-01	24.51
1842	2028-03-30	24.75
1843	2031-09-25	13.66
1844	2026-12-05	17.94
1845	2031-01-15	30.59
1846	2028-04-17	3.83
1847	2029-09-11	16.39
1848	2028-07-31	7.58
1849	2028-10-27	10.45
1850	2029-05-22	14.49
1851	2031-08-28	10.56
1852	2031-09-04	5.05
1853	2030-11-24	41.89
1854	2029-05-09	31.43
1855	2027-05-29	26.56
1856	2028-12-26	1.01
1857	2029-08-06	46.86
1858	2029-04-12	37.09
1859	2026-12-23	47.00
1860	2029-01-19	40.26
1861	2030-11-12	27.83
1862	2029-05-13	16.44
1863	2030-08-25	16.09
1864	2030-06-23	45.85
1865	2031-01-11	13.06
1866	2027-03-30	47.75
1867	2027-01-19	29.49
1868	2029-03-20	5.63
1869	2031-09-22	5.10
1870	2029-04-27	17.62
1871	2027-04-06	11.13
1872	2026-10-27	1.85
1873	2027-01-25	43.33
1874	2030-10-10	43.56
1875	2027-09-27	1.71
1876	2028-03-04	27.34
1877	2027-03-15	43.92
1878	2029-07-10	3.73
1879	2028-09-24	46.71
1880	2031-02-25	10.79
1881	2029-10-03	46.12
1882	2028-04-27	1.19
1883	2027-10-10	18.07
1884	2027-04-28	2.65
1885	2031-05-18	40.21
1886	2028-04-11	38.63
1887	2030-12-17	32.62
1888	2027-05-08	2.71
1889	2029-05-30	45.37
1890	2028-11-29	4.90
1891	2028-12-24	37.42
1892	2030-09-28	44.15
1893	2031-07-09	26.39
1894	2027-08-07	23.04
1895	2027-05-31	44.72
1896	2029-11-16	16.96
1897	2027-10-09	18.03
1898	2027-03-12	49.01
1899	2027-07-23	48.88
1900	2027-04-24	12.23
1901	2028-08-08	14.97
1902	2031-08-29	38.65
1903	2029-12-16	7.82
1904	2031-09-02	1.48
1905	2030-03-13	29.35
1906	2027-03-28	38.73
1907	2028-02-01	35.93
1908	2027-03-13	45.47
1909	2028-02-19	36.26
1910	2029-12-17	37.46
1911	2031-01-23	4.28
1912	2029-09-28	41.67
1913	2028-05-10	49.20
1914	2027-04-06	37.35
1915	2027-10-04	8.36
1916	2028-01-23	2.91
1917	2031-07-19	41.21
1918	2030-08-10	28.41
1919	2026-10-19	22.45
1920	2027-10-27	40.56
1921	2028-11-30	31.26
1922	2027-05-21	13.82
1923	2028-05-02	2.07
1924	2027-11-12	32.62
1925	2030-03-31	6.72
1926	2026-11-15	17.72
1927	2027-02-08	21.14
1928	2029-02-15	19.85
1930	2028-01-26	27.89
1931	2030-10-16	21.40
1932	2028-04-05	38.19
1933	2027-09-07	0.69
1934	2031-02-08	6.83
1935	2028-12-04	9.22
1936	2029-12-10	44.74
1938	2029-01-29	19.19
1939	2029-05-06	12.92
1940	2029-08-29	46.42
1941	2027-07-04	25.60
1942	2031-06-07	11.47
1943	2031-03-06	13.41
1944	2030-12-07	4.03
1945	2026-12-31	24.02
1946	2031-05-08	20.76
1947	2027-05-07	21.71
1948	2028-02-28	24.36
1949	2026-11-09	42.74
1950	2031-09-13	25.76
1951	2031-07-14	33.90
1952	2029-06-11	46.52
1953	2029-03-07	19.23
1954	2031-02-18	17.77
1955	2028-11-13	31.30
1956	2030-03-20	24.21
1957	2030-05-01	41.07
1958	2028-09-09	2.17
1959	2029-01-30	37.16
1960	2028-10-28	12.90
1961	2028-11-11	44.85
1962	2028-12-14	39.83
1963	2029-07-31	7.17
1964	2029-01-07	15.03
1965	2028-09-25	9.96
1966	2026-12-20	12.73
1967	2030-10-10	15.52
1968	2029-05-18	16.36
1969	2028-10-04	35.91
1970	2027-05-22	18.33
1971	2029-11-20	12.24
1972	2027-02-19	41.85
1973	2028-11-08	22.17
1974	2027-06-30	40.25
1975	2031-07-16	0.72
1976	2030-12-21	46.38
1977	2029-11-09	33.07
1978	2031-02-12	21.80
1979	2027-02-09	10.86
1980	2030-05-16	48.87
1981	2027-03-13	9.16
1982	2029-07-27	18.13
1983	2028-04-07	8.34
1984	2028-01-13	12.87
1985	2030-07-01	48.85
1986	2027-05-26	33.83
1987	2029-06-23	27.42
1989	2028-12-31	2.73
1990	2030-06-04	28.61
1991	2027-02-09	7.77
1992	2027-10-13	37.44
1993	2030-04-22	22.65
1994	2027-10-14	31.35
1995	2029-11-11	2.88
1996	2031-03-29	1.80
1997	2031-02-08	42.49
1998	2029-07-08	41.70
1999	2027-07-26	8.18
\.


--
-- Data for Name: historial_medico; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.historial_medico (id_historial, tipo_sangre, alergias, estado_salud) FROM stdin;
1	B-	\N	Baja Medica
2	B+	\N	En Recuperacion
3	O+	quis	En Recuperacion
4	A+	\N	Herido
5	AB+	pariatur	Herido
6	O-	\N	En Recuperacion
7	B+	sint	En Recuperacion
8	O+	\N	Baja Medica
9	O+	tenetur	Herido
10	AB+	quaerat	Herido
11	O+	magni	Herido
12	AB+	ducimus	En Recuperacion
13	O+	expedita	Herido
14	A-	asperiores	En Recuperacion
15	A+	occaecati	Optimo
16	B-	\N	Optimo
17	AB-	exercitationem	Optimo
18	O+	consectetur	Herido
19	AB-	asperiores	Optimo
20	A-	perspiciatis	Baja Medica
21	B+	accusantium	Herido
22	B-	\N	Baja Medica
23	A-	\N	Baja Medica
24	O+	\N	Optimo
25	B+	\N	Optimo
26	O-	aliquid	En Recuperacion
27	O+	suscipit	Herido
28	AB+	\N	En Recuperacion
29	B-	\N	Optimo
30	A-	voluptatibus	Optimo
31	AB-	\N	Baja Medica
32	O+	illo	Optimo
33	B+	\N	Baja Medica
34	B+	earum	En Recuperacion
35	O-	suscipit	Optimo
36	O+	\N	Optimo
37	O+	\N	Optimo
38	B+	libero	Optimo
39	AB+	\N	Optimo
40	O+	voluptates	Optimo
41	B+	est	Optimo
42	B-	reprehenderit	Herido
43	O+	\N	Baja Medica
44	O+	\N	Herido
45	A-	impedit	Optimo
46	A-	laudantium	En Recuperacion
47	AB-	fugiat	En Recuperacion
48	AB+	\N	En Recuperacion
49	A+	soluta	Optimo
50	B+	consequatur	Optimo
51	O-	molestias	Baja Medica
52	B-	quod	En Recuperacion
53	AB-	quia	En Recuperacion
54	B-	delectus	Baja Medica
55	AB+	error	Optimo
56	A-	\N	Baja Medica
57	O-	\N	En Recuperacion
58	AB-	unde	Baja Medica
59	B+	repellat	Baja Medica
60	O-	facere	Baja Medica
61	B+	\N	Baja Medica
62	A-	corporis	Baja Medica
63	O-	inventore	Herido
64	B-	expedita	Herido
65	B+	et	Herido
66	O-	explicabo	Herido
67	A-	dolores	Herido
68	A+	laboriosam	Baja Medica
69	B-	aspernatur	Baja Medica
70	A-	\N	Baja Medica
71	AB-	nam	En Recuperacion
72	A-	commodi	Optimo
73	AB-	recusandae	Optimo
74	A+	\N	Herido
75	B+	\N	Baja Medica
76	B-	autem	Herido
77	O-	sequi	Optimo
78	O+	officia	Baja Medica
79	A-	\N	Herido
80	AB-	\N	Baja Medica
81	A-	\N	Herido
82	A-	\N	En Recuperacion
83	A-	vel	Baja Medica
84	AB-	tempore	Optimo
85	AB+	velit	Herido
86	B-	\N	En Recuperacion
87	B+	\N	Baja Medica
88	AB+	excepturi	Baja Medica
89	AB-	magni	En Recuperacion
90	O+	\N	Optimo
91	AB-	cum	Herido
92	AB-	cum	En Recuperacion
93	B-	\N	En Recuperacion
94	B+	reprehenderit	Baja Medica
95	B+	sequi	Optimo
96	B+	sit	Baja Medica
97	AB+	\N	Optimo
98	O+	dolorum	Optimo
99	B-	\N	Optimo
100	O-	\N	En Recuperacion
101	AB+	\N	En Recuperacion
102	A-	\N	En Recuperacion
103	A+	\N	Baja Medica
104	O-	corrupti	Herido
105	A-	eveniet	Optimo
106	A+	\N	Herido
107	B+	\N	Optimo
108	O-	\N	Optimo
109	AB+	nostrum	Herido
110	A-	sit	Optimo
111	O-	deleniti	Optimo
112	A+	\N	Baja Medica
113	B-	cumque	Baja Medica
114	O+	\N	Optimo
115	O+	assumenda	Optimo
116	O+	assumenda	En Recuperacion
117	A+	nulla	Baja Medica
118	A-	\N	Optimo
119	B+	aliquid	Optimo
120	AB+	\N	Baja Medica
121	O-	\N	Baja Medica
122	AB+	\N	Herido
123	O+	quod	Baja Medica
124	AB+	\N	Optimo
125	A-	deleniti	Baja Medica
126	AB+	\N	Baja Medica
127	B+	delectus	Herido
128	B+	\N	Herido
129	B-	officia	Optimo
130	A+	sit	Herido
131	AB-	\N	Herido
132	A+	minima	Baja Medica
133	A+	\N	En Recuperacion
134	AB+	\N	En Recuperacion
135	B-	tenetur	Baja Medica
136	B+	corporis	Optimo
137	O-	\N	Optimo
138	AB-	repellat	Baja Medica
139	AB-	\N	Herido
140	AB+	\N	Herido
141	B-	\N	En Recuperacion
142	A-	\N	Baja Medica
143	B-	\N	En Recuperacion
144	B+	\N	En Recuperacion
145	A-	\N	Baja Medica
146	B-	rem	Herido
147	A+	fugit	En Recuperacion
148	AB-	architecto	En Recuperacion
149	B+	\N	En Recuperacion
150	B+	dolor	Baja Medica
151	AB-	\N	Herido
152	B+	commodi	Baja Medica
153	B+	\N	Baja Medica
154	O+	odit	En Recuperacion
155	A-	accusamus	Optimo
156	AB-	praesentium	En Recuperacion
157	B+	eaque	Baja Medica
158	AB+	\N	En Recuperacion
159	B+	\N	Optimo
160	O+	\N	En Recuperacion
161	A-	delectus	En Recuperacion
162	O-	amet	Optimo
163	O-	illo	Herido
164	B-	odit	Baja Medica
165	B+	\N	Herido
166	O-	\N	En Recuperacion
167	AB-	nesciunt	Optimo
168	AB-	\N	En Recuperacion
169	O-	fuga	Baja Medica
170	O+	cum	En Recuperacion
171	AB+	\N	En Recuperacion
172	AB-	\N	Baja Medica
173	A-	\N	Herido
174	O-	\N	Herido
175	B-	\N	En Recuperacion
176	AB-	asperiores	Herido
177	AB-	minus	Optimo
178	AB-	\N	En Recuperacion
179	B-	sapiente	En Recuperacion
180	B-	\N	En Recuperacion
181	AB-	\N	Optimo
182	B-	\N	Herido
183	O+	\N	Herido
184	B+	\N	Herido
185	B-	\N	Baja Medica
186	AB+	consequatur	Herido
187	O-	dolores	Herido
188	O-	\N	En Recuperacion
189	AB+	\N	Herido
190	B-	\N	En Recuperacion
191	AB-	\N	Optimo
192	A-	vero	Optimo
193	B-	esse	Baja Medica
194	A+	adipisci	Optimo
195	A-	\N	Optimo
196	B+	ipsam	Baja Medica
197	A-	\N	Optimo
198	A-	distinctio	Herido
199	B-	\N	En Recuperacion
200	AB-	quibusdam	Optimo
201	A+	\N	Baja Medica
202	AB-	\N	En Recuperacion
203	O+	\N	Herido
204	AB-	ullam	Herido
205	O-	exercitationem	En Recuperacion
206	AB-	\N	Optimo
207	B+	\N	Herido
208	O+	\N	Optimo
209	B+	\N	Herido
210	B+	\N	Herido
211	AB+	\N	Herido
212	AB+	officia	Baja Medica
213	B-	sunt	Baja Medica
214	B-	\N	Baja Medica
215	A-	\N	Herido
216	A+	\N	Herido
217	B-	est	Herido
218	O-	\N	Herido
219	A+	laborum	Optimo
220	A+	\N	Baja Medica
221	B-	\N	Optimo
222	AB-	\N	Herido
223	A-	\N	Herido
224	B-	\N	Herido
225	A+	provident	Baja Medica
226	B-	harum	Optimo
227	O-	\N	Baja Medica
228	A+	distinctio	Optimo
229	AB+	\N	Herido
230	A-	porro	Optimo
231	B+	eaque	Baja Medica
232	B-	\N	Optimo
233	AB-	\N	Optimo
234	A-	odit	Herido
235	AB+	aut	Optimo
236	A-	accusantium	Optimo
237	AB-	\N	Herido
238	AB+	\N	Optimo
239	O-	provident	Optimo
240	AB-	\N	Optimo
241	A-	iure	En Recuperacion
242	AB+	\N	Baja Medica
243	O+	dolores	Optimo
244	B-	\N	Optimo
245	O-	\N	En Recuperacion
246	A-	nesciunt	Optimo
247	O-	\N	Herido
248	A+	perferendis	Herido
249	O-	odio	Baja Medica
250	B-	\N	Herido
251	AB+	possimus	En Recuperacion
252	O-	\N	Baja Medica
253	O+	odio	Herido
254	O+	voluptatem	Baja Medica
255	AB-	\N	En Recuperacion
256	O-	\N	Baja Medica
257	AB-	repellat	Optimo
258	O+	earum	Herido
259	B+	error	En Recuperacion
260	B+	\N	Baja Medica
261	AB+	\N	Optimo
262	O-	dolorum	En Recuperacion
263	O-	reiciendis	Optimo
264	A+	\N	Optimo
265	O-	deleniti	En Recuperacion
266	O-	ea	En Recuperacion
267	O+	molestiae	En Recuperacion
268	B-	odit	Baja Medica
269	A+	asperiores	En Recuperacion
270	AB+	\N	Optimo
271	B+	\N	Baja Medica
272	AB-	animi	En Recuperacion
273	A+	nostrum	Herido
274	O-	\N	En Recuperacion
275	A-	dolorum	Baja Medica
276	O-	\N	En Recuperacion
277	O-	\N	Herido
278	A-	saepe	Optimo
279	AB-	laudantium	En Recuperacion
280	O+	a	Herido
281	A+	\N	Optimo
282	A-	\N	En Recuperacion
283	B+	\N	En Recuperacion
284	A+	nesciunt	Optimo
285	B-	ratione	Baja Medica
286	AB+	blanditiis	Optimo
287	B-	\N	Baja Medica
288	A-	temporibus	Herido
289	B+	incidunt	Herido
290	AB+	praesentium	Baja Medica
291	A+	alias	Optimo
292	B-	fuga	Herido
293	O+	cumque	Herido
294	O-	sapiente	Baja Medica
295	O-	\N	Optimo
296	B+	\N	Baja Medica
297	AB+	\N	Optimo
298	A-	\N	Herido
299	A-	labore	Optimo
300	B+	delectus	En Recuperacion
301	AB+	fuga	Herido
302	B+	labore	Baja Medica
303	B+	\N	En Recuperacion
304	AB+	in	Optimo
305	A-	possimus	Herido
306	B+	\N	Herido
307	A+	error	Herido
308	B-	voluptates	En Recuperacion
309	O-	quaerat	En Recuperacion
310	B-	delectus	Herido
311	AB+	\N	Optimo
312	AB-	\N	En Recuperacion
313	AB+	\N	En Recuperacion
314	A+	\N	Optimo
315	O+	quaerat	Optimo
316	O+	corporis	Herido
317	B-	\N	En Recuperacion
318	B-	pariatur	Optimo
319	A+	\N	Herido
320	AB-	\N	Baja Medica
321	AB-	quibusdam	Optimo
322	A-	\N	Optimo
323	A-	\N	Optimo
324	B+	vitae	Optimo
325	AB-	hic	Baja Medica
326	O-	praesentium	Optimo
327	B+	dolor	Herido
328	B-	cumque	Optimo
329	A-	\N	Optimo
330	B+	itaque	En Recuperacion
331	B-	\N	Optimo
332	A+	modi	Baja Medica
333	A-	\N	Baja Medica
334	O+	vitae	Baja Medica
335	A-	quidem	Baja Medica
336	A+	ipsam	En Recuperacion
337	AB+	illo	En Recuperacion
338	O+	\N	Optimo
339	AB-	\N	En Recuperacion
340	B+	\N	Optimo
341	AB+	soluta	Herido
342	O+	\N	Herido
343	O+	\N	Baja Medica
344	AB+	\N	Baja Medica
345	B+	\N	Optimo
346	B+	\N	Optimo
347	O+	dolores	Optimo
348	A-	quidem	Optimo
349	AB+	possimus	Baja Medica
350	O+	\N	En Recuperacion
351	AB+	\N	En Recuperacion
352	O-	\N	Optimo
353	AB+	\N	Baja Medica
354	B-	odio	Optimo
355	A+	\N	En Recuperacion
356	O+	\N	Herido
357	B+	\N	En Recuperacion
358	AB-	saepe	Herido
359	O+	\N	Herido
360	B-	\N	Optimo
361	O+	in	En Recuperacion
362	A+	autem	Baja Medica
363	B-	voluptatum	Optimo
364	A-	\N	Optimo
365	A+	\N	Optimo
366	B+	\N	Herido
367	O-	molestiae	Baja Medica
368	O-	\N	En Recuperacion
369	A-	voluptates	Herido
370	B-	\N	Optimo
371	AB+	\N	Baja Medica
372	AB-	maxime	En Recuperacion
373	B+	et	Herido
374	AB-	enim	Baja Medica
375	A+	\N	En Recuperacion
376	A+	consectetur	En Recuperacion
377	B+	veniam	Baja Medica
378	O-	\N	Baja Medica
379	B-	exercitationem	En Recuperacion
380	A+	eius	Optimo
381	O-	quidem	En Recuperacion
382	O+	\N	En Recuperacion
383	B-	minus	En Recuperacion
384	AB-	\N	Herido
385	A-	\N	En Recuperacion
386	A-	\N	Baja Medica
387	A+	dolores	Herido
388	O-	\N	Baja Medica
389	A+	fuga	Herido
390	B+	explicabo	Baja Medica
391	AB-	\N	En Recuperacion
392	O-	quod	Optimo
393	O+	\N	En Recuperacion
394	B-	\N	En Recuperacion
395	O+	\N	Herido
396	A-	beatae	Optimo
397	A-	\N	Baja Medica
398	B-	\N	En Recuperacion
399	B-	optio	Baja Medica
400	A+	\N	Herido
401	B+	\N	Optimo
402	AB+	laudantium	Herido
403	O-	\N	Baja Medica
404	B+	dolores	Baja Medica
405	B-	perferendis	Baja Medica
406	O+	\N	En Recuperacion
407	AB-	est	Herido
408	O+	similique	Baja Medica
409	B+	temporibus	Optimo
410	A+	soluta	Herido
411	B-	vel	En Recuperacion
412	A-	atque	Herido
413	O+	veniam	En Recuperacion
414	A+	dicta	Herido
415	A-	optio	En Recuperacion
416	A-	\N	Optimo
417	AB-	expedita	Baja Medica
418	O+	\N	En Recuperacion
419	A-	\N	En Recuperacion
420	O+	\N	Baja Medica
421	B-	\N	Baja Medica
422	A+	pariatur	Herido
423	O+	hic	Herido
424	O+	\N	Optimo
425	B-	\N	En Recuperacion
426	A-	\N	Optimo
427	B-	eligendi	Baja Medica
428	A+	\N	Herido
429	A-	\N	Herido
430	B-	a	En Recuperacion
431	A+	modi	Herido
432	AB-	optio	Herido
433	AB+	alias	Baja Medica
434	B-	iusto	Baja Medica
435	A+	\N	Optimo
436	AB-	ipsa	Baja Medica
437	AB+	\N	En Recuperacion
438	B-	\N	Baja Medica
439	AB-	dolor	Optimo
440	AB-	amet	Herido
441	AB-	\N	Optimo
442	B-	fugiat	En Recuperacion
443	O-	accusamus	Herido
444	AB+	et	Optimo
445	B-	\N	Herido
446	O+	vel	Optimo
447	AB-	\N	Herido
448	AB-	\N	En Recuperacion
449	AB+	\N	Baja Medica
450	AB+	\N	Herido
451	AB-	\N	En Recuperacion
452	O+	iure	En Recuperacion
453	B-	dolorem	En Recuperacion
454	B-	\N	Herido
455	B+	voluptatibus	Baja Medica
456	B-	accusantium	Baja Medica
457	B+	inventore	Baja Medica
458	B-	quos	Herido
459	AB+	\N	Baja Medica
460	AB+	non	Baja Medica
461	A+	incidunt	Herido
462	AB+	corrupti	Optimo
463	B+	\N	Herido
464	AB-	iusto	En Recuperacion
465	B+	at	Herido
466	AB-	\N	En Recuperacion
467	AB+	\N	Herido
468	AB+	\N	Baja Medica
469	B+	\N	Herido
470	O+	magnam	Baja Medica
471	AB-	eos	Herido
472	B+	autem	Baja Medica
473	O-	fugiat	Herido
474	B-	consequuntur	Optimo
475	A-	\N	En Recuperacion
476	B+	commodi	Herido
477	AB-	occaecati	Optimo
478	A-	accusantium	Optimo
479	O+	\N	En Recuperacion
480	O+	explicabo	Herido
481	A-	\N	Herido
482	AB+	error	Optimo
483	AB-	\N	Baja Medica
484	A-	minima	Optimo
485	B-	amet	Optimo
486	A-	\N	En Recuperacion
487	AB-	\N	Baja Medica
488	AB-	\N	En Recuperacion
489	A-	\N	Herido
490	O-	\N	Herido
491	O-	architecto	Baja Medica
492	AB-	\N	Optimo
493	B+	\N	Herido
494	O+	veritatis	Optimo
495	AB-	beatae	Herido
496	A-	\N	Herido
497	AB-	reprehenderit	En Recuperacion
498	AB-	\N	Herido
499	A+	\N	Herido
500	B-	\N	Herido
501	A+	\N	En Recuperacion
502	A+	tempore	En Recuperacion
503	AB+	ipsa	En Recuperacion
504	O+	\N	Herido
505	AB+	enim	Herido
506	O-	\N	Baja Medica
507	B-	accusamus	Baja Medica
508	O+	\N	Optimo
509	AB+	\N	En Recuperacion
510	B-	\N	Optimo
511	O+	qui	Baja Medica
512	AB+	\N	Optimo
513	B-	\N	En Recuperacion
514	A-	\N	Baja Medica
515	AB+	adipisci	Herido
516	B-	culpa	Herido
517	O+	\N	En Recuperacion
518	AB-	voluptatem	En Recuperacion
519	AB+	veniam	Baja Medica
520	O+	\N	En Recuperacion
521	AB-	\N	Herido
522	O-	\N	En Recuperacion
523	A-	\N	Optimo
524	AB+	\N	Optimo
525	AB+	assumenda	Herido
526	A-	\N	Optimo
527	B-	aliquam	Baja Medica
528	O+	\N	Herido
529	AB+	iste	En Recuperacion
530	B+	\N	Optimo
531	O+	numquam	Optimo
532	A-	ipsa	Optimo
533	AB+	sequi	En Recuperacion
534	O+	quod	Optimo
535	A+	\N	Baja Medica
536	B-	ratione	Baja Medica
537	AB+	\N	Optimo
538	O-	id	En Recuperacion
539	AB-	\N	Herido
540	O+	\N	En Recuperacion
541	AB-	placeat	Baja Medica
542	AB+	\N	Baja Medica
543	O-	neque	En Recuperacion
544	AB-	\N	Herido
545	B+	error	Baja Medica
546	AB+	\N	Baja Medica
547	B-	delectus	Herido
548	O-	nulla	Herido
549	B-	fugit	En Recuperacion
550	AB+	\N	Optimo
551	O-	\N	Optimo
552	B-	qui	Optimo
553	A-	\N	Baja Medica
554	A+	animi	Optimo
555	A+	sed	Herido
556	B-	\N	Baja Medica
557	O+	perferendis	Herido
558	B+	iste	Optimo
559	B-	earum	En Recuperacion
560	AB-	voluptates	En Recuperacion
561	AB-	\N	Baja Medica
562	O-	doloremque	Optimo
563	A+	occaecati	Baja Medica
564	O+	autem	Baja Medica
565	A+	\N	Herido
566	AB-	\N	En Recuperacion
567	AB+	\N	Herido
568	AB+	\N	En Recuperacion
569	B-	\N	Baja Medica
570	O-	\N	En Recuperacion
571	B-	vel	Herido
572	AB+	\N	Herido
573	O+	\N	En Recuperacion
574	B-	velit	Optimo
575	B+	\N	Optimo
576	O+	\N	En Recuperacion
577	O-	\N	Herido
578	A-	\N	Herido
579	B+	reiciendis	Optimo
580	AB+	\N	Herido
581	O+	\N	Optimo
582	O+	illo	En Recuperacion
583	A+	\N	Baja Medica
584	A+	soluta	Baja Medica
585	B+	\N	Herido
586	AB-	\N	Optimo
587	A-	nemo	Baja Medica
588	A-	reiciendis	Herido
589	AB-	\N	Optimo
590	B+	\N	Herido
591	O+	amet	Baja Medica
592	O+	\N	En Recuperacion
593	O+	\N	En Recuperacion
594	O+	iusto	Herido
595	B+	\N	Baja Medica
596	O-	\N	Baja Medica
597	B-	\N	Herido
598	O+	\N	Optimo
599	B-	\N	Optimo
600	B+	\N	Herido
601	A-	accusamus	En Recuperacion
602	B-	\N	Optimo
603	B+	\N	Herido
604	AB+	\N	Herido
605	O-	\N	En Recuperacion
606	AB+	voluptas	Herido
607	A-	\N	En Recuperacion
608	A+	adipisci	Herido
609	AB+	\N	Baja Medica
610	AB-	\N	Baja Medica
611	O-	pariatur	Baja Medica
612	AB+	\N	Optimo
613	O+	ad	En Recuperacion
614	O-	\N	Baja Medica
615	A+	\N	En Recuperacion
616	B+	neque	Optimo
617	O+	commodi	Baja Medica
618	A+	\N	Baja Medica
619	AB+	voluptatibus	Herido
620	A-	repellendus	En Recuperacion
621	B+	distinctio	Optimo
622	AB+	\N	Baja Medica
623	A+	\N	Herido
624	B-	\N	Optimo
625	O+	\N	Baja Medica
626	B-	voluptas	Herido
627	AB+	commodi	Baja Medica
628	O-	\N	Herido
629	AB-	sint	Baja Medica
630	O+	\N	En Recuperacion
631	A+	omnis	En Recuperacion
632	A-	\N	Herido
633	B-	dolore	En Recuperacion
634	AB+	\N	Optimo
635	B+	delectus	En Recuperacion
636	O-	\N	Herido
637	B-	nam	Herido
638	O-	\N	En Recuperacion
639	B-	\N	En Recuperacion
640	O+	itaque	Baja Medica
641	B+	\N	Herido
642	O-	\N	Baja Medica
643	A-	\N	Optimo
644	A+	\N	Optimo
645	A+	\N	Baja Medica
646	B-	beatae	Optimo
647	B-	ratione	Baja Medica
648	A-	\N	Herido
649	O+	in	Herido
650	O+	\N	Optimo
651	O-	\N	Baja Medica
652	A+	qui	Herido
653	A-	debitis	En Recuperacion
654	B+	\N	Baja Medica
655	A+	quidem	En Recuperacion
656	A+	\N	Optimo
657	B+	\N	Optimo
658	AB+	\N	Herido
659	O-	\N	Baja Medica
660	A-	voluptatum	Baja Medica
661	AB+	culpa	Herido
662	AB-	itaque	En Recuperacion
663	O+	tempore	Optimo
664	A+	voluptatum	En Recuperacion
665	AB-	saepe	En Recuperacion
666	AB-	\N	En Recuperacion
667	AB-	\N	Optimo
668	B-	ad	En Recuperacion
669	O+	excepturi	Herido
670	AB-	\N	Optimo
671	A-	\N	Baja Medica
672	B-	sunt	Herido
673	AB+	\N	En Recuperacion
674	AB-	odit	Optimo
675	B-	\N	Optimo
676	AB-	blanditiis	Herido
677	AB-	ea	Optimo
678	O+	\N	Baja Medica
679	AB+	iusto	Herido
680	O+	\N	Herido
681	A+	porro	Optimo
682	B-	dolore	Baja Medica
683	B-	\N	Baja Medica
684	O-	\N	Optimo
685	AB-	\N	En Recuperacion
686	A+	\N	Herido
687	O-	recusandae	Herido
688	B+	\N	Baja Medica
689	O-	voluptates	Baja Medica
690	AB-	\N	Herido
691	B-	\N	Optimo
692	B-	inventore	Herido
693	AB-	quam	Baja Medica
694	B-	\N	En Recuperacion
695	AB+	\N	Herido
696	O+	\N	Herido
697	A-	\N	En Recuperacion
698	AB+	\N	Baja Medica
699	A-	praesentium	Optimo
700	O+	\N	Baja Medica
701	O-	\N	Herido
702	O+	recusandae	Herido
703	A-	\N	Baja Medica
704	AB+	minima	Herido
705	B+	explicabo	Optimo
706	A-	possimus	Optimo
707	AB+	\N	Herido
708	O+	nostrum	Optimo
709	O+	\N	Herido
710	B+	ab	Herido
711	A-	fugiat	Baja Medica
712	A-	\N	Herido
713	B+	\N	En Recuperacion
714	AB+	iure	Herido
715	B+	\N	Herido
716	O-	dolor	Baja Medica
717	O-	\N	Herido
718	AB+	\N	Herido
719	A+	sequi	Herido
720	O+	\N	Optimo
721	A+	\N	Baja Medica
722	O-	\N	Herido
723	O-	placeat	En Recuperacion
724	B-	molestiae	Herido
725	B+	\N	En Recuperacion
726	B-	voluptas	Baja Medica
727	B+	\N	Optimo
728	B-	laborum	Optimo
729	B+	\N	Baja Medica
730	O+	\N	Optimo
731	O-	sint	Baja Medica
732	AB+	quae	Baja Medica
733	B+	\N	Herido
734	AB+	ad	En Recuperacion
735	B-	\N	Baja Medica
736	A-	\N	Herido
737	A-	sint	Herido
738	AB+	\N	Optimo
739	B-	quasi	Optimo
740	B+	praesentium	Optimo
741	AB-	distinctio	Optimo
742	O-	nesciunt	Baja Medica
743	AB-	laborum	En Recuperacion
744	B+	\N	En Recuperacion
745	B-	quas	Baja Medica
746	B-	a	Herido
747	O-	\N	Herido
748	B-	iusto	En Recuperacion
749	AB-	omnis	Herido
750	A+	\N	Optimo
751	A+	in	Baja Medica
752	B-	omnis	En Recuperacion
753	A+	dicta	Optimo
754	AB-	officiis	Baja Medica
755	B-	\N	En Recuperacion
756	O-	alias	Herido
757	A-	\N	Herido
758	B-	temporibus	Optimo
759	B-	doloremque	Herido
760	A-	\N	En Recuperacion
761	B+	\N	Herido
762	AB+	\N	Baja Medica
763	A-	similique	Baja Medica
764	O+	assumenda	En Recuperacion
765	AB+	\N	Optimo
766	B-	earum	Baja Medica
767	A-	tempora	Baja Medica
768	B-	perspiciatis	Baja Medica
769	AB-	\N	Baja Medica
770	O-	quidem	Optimo
771	O-	quibusdam	En Recuperacion
772	B-	natus	Herido
773	AB-	\N	En Recuperacion
774	A-	\N	Optimo
775	A+	iusto	Herido
776	AB+	corrupti	Optimo
777	A-	\N	Optimo
778	A-	\N	En Recuperacion
779	AB-	porro	En Recuperacion
780	B-	\N	Optimo
781	A+	\N	Baja Medica
782	A-	animi	En Recuperacion
783	O-	\N	Herido
784	O+	dolorum	Herido
785	A-	\N	Herido
786	O+	quod	Herido
787	O-	\N	En Recuperacion
788	B-	\N	Herido
789	AB+	iste	En Recuperacion
790	B-	impedit	En Recuperacion
791	A-	\N	Baja Medica
792	A+	quibusdam	Optimo
793	O-	\N	En Recuperacion
794	O-	\N	Herido
795	B-	\N	Optimo
796	B-	autem	Optimo
797	B+	\N	En Recuperacion
798	O-	nemo	Herido
799	A+	\N	Herido
800	O-	accusamus	Herido
801	B+	nulla	Baja Medica
802	A+	\N	En Recuperacion
803	B+	\N	Optimo
804	O-	\N	Baja Medica
805	O+	veritatis	Baja Medica
806	O-	impedit	Optimo
807	O+	\N	En Recuperacion
808	B+	impedit	En Recuperacion
809	A+	eaque	En Recuperacion
810	A-	\N	Baja Medica
811	B+	\N	Optimo
812	AB+	sed	Herido
813	AB-	occaecati	Herido
814	AB+	illo	Optimo
815	AB+	\N	Optimo
816	O-	\N	Herido
817	AB+	molestiae	En Recuperacion
818	O+	\N	Herido
819	O+	atque	Baja Medica
820	AB-	\N	Baja Medica
821	O+	\N	Optimo
822	A-	\N	Optimo
823	O+	tenetur	Baja Medica
824	AB-	\N	Herido
825	B+	\N	Herido
826	AB-	officia	Herido
827	A-	\N	Herido
828	AB-	\N	Baja Medica
829	B-	\N	Optimo
830	A-	voluptates	Herido
831	O+	sint	Optimo
832	A-	dolor	Herido
833	A-	\N	Baja Medica
834	B-	\N	En Recuperacion
835	A-	\N	En Recuperacion
836	O+	debitis	En Recuperacion
837	AB+	\N	Optimo
838	AB-	vitae	Herido
839	B-	deleniti	Herido
840	B-	\N	Optimo
841	A-	\N	Herido
842	B-	\N	Optimo
843	O+	exercitationem	Baja Medica
844	A-	quae	Baja Medica
845	A+	\N	Herido
846	A-	\N	Herido
847	B+	molestias	Optimo
848	O+	\N	En Recuperacion
849	O-	mollitia	Optimo
850	A+	quisquam	Baja Medica
851	AB-	eum	Herido
852	O+	\N	Baja Medica
853	B-	ullam	En Recuperacion
854	AB-	provident	En Recuperacion
855	A+	voluptates	En Recuperacion
856	AB-	\N	Herido
857	A-	quidem	En Recuperacion
858	O+	repellat	Baja Medica
859	B-	iusto	Baja Medica
860	O+	dolore	Herido
861	AB-	nulla	En Recuperacion
862	O-	\N	Baja Medica
863	O-	similique	Optimo
864	B+	\N	En Recuperacion
865	AB-	autem	Herido
866	O+	\N	En Recuperacion
867	B-	iste	Herido
868	AB+	similique	Herido
869	A-	architecto	Optimo
870	A+	\N	Baja Medica
871	A-	\N	Baja Medica
872	B+	consequuntur	En Recuperacion
873	B+	\N	Optimo
874	A-	odit	Herido
875	B+	\N	En Recuperacion
876	A+	suscipit	Herido
877	AB-	voluptatem	Optimo
878	AB+	ea	En Recuperacion
879	B+	\N	Baja Medica
880	O+	\N	Optimo
881	B-	\N	Herido
882	O-	\N	Baja Medica
883	O+	rem	Baja Medica
884	O+	\N	Herido
885	B-	officiis	Baja Medica
886	O+	\N	Baja Medica
887	B-	nisi	Herido
888	AB-	\N	Optimo
889	O+	maxime	Herido
890	O-	facilis	Optimo
891	B+	\N	Baja Medica
892	A+	eligendi	Optimo
893	B+	\N	Herido
894	A-	\N	Baja Medica
895	AB-	consequuntur	Baja Medica
896	O-	quaerat	Baja Medica
897	AB+	\N	Herido
898	A-	itaque	Baja Medica
899	B-	magni	En Recuperacion
900	AB-	minus	Baja Medica
901	A-	sint	Herido
902	AB+	\N	Optimo
903	AB-	\N	Herido
904	AB-	recusandae	Optimo
905	B-	autem	Herido
906	A-	\N	Herido
907	AB-	ipsa	Baja Medica
908	B+	\N	En Recuperacion
909	B+	\N	Baja Medica
910	O-	perspiciatis	Optimo
911	AB+	dolorem	Baja Medica
912	AB+	\N	En Recuperacion
913	A+	ullam	Baja Medica
914	B+	recusandae	En Recuperacion
915	AB+	quia	Optimo
916	A+	\N	Baja Medica
917	A-	\N	Herido
918	B-	natus	Baja Medica
919	O+	\N	En Recuperacion
920	B+	ipsum	Herido
921	O-	\N	Herido
922	B+	culpa	Baja Medica
923	A-	quaerat	En Recuperacion
924	A-	eligendi	Herido
925	O-	\N	Baja Medica
926	O-	\N	Optimo
927	AB+	excepturi	Herido
928	O-	\N	Optimo
929	A+	\N	Herido
930	O-	delectus	En Recuperacion
931	AB+	\N	Baja Medica
932	AB+	delectus	Baja Medica
933	B+	\N	Baja Medica
934	AB-	\N	Optimo
935	B-	\N	Baja Medica
936	B+	\N	Baja Medica
937	O+	aperiam	En Recuperacion
938	O+	\N	Herido
939	O-	deserunt	En Recuperacion
940	A-	\N	En Recuperacion
941	O+	\N	En Recuperacion
942	B+	et	Baja Medica
943	O+	quasi	Baja Medica
944	AB-	explicabo	En Recuperacion
945	AB+	eius	Herido
946	A-	molestiae	En Recuperacion
947	AB+	\N	Optimo
948	A-	\N	Herido
949	A-	\N	Herido
950	A+	perferendis	Optimo
951	B-	nostrum	Herido
952	B-	repudiandae	Herido
953	O-	\N	Baja Medica
954	B-	optio	Herido
955	B-	quo	En Recuperacion
956	B-	quidem	Baja Medica
957	AB+	\N	Optimo
958	O+	earum	Optimo
959	AB-	\N	En Recuperacion
960	A-	\N	En Recuperacion
961	B-	\N	Optimo
962	B-	enim	Herido
963	O-	temporibus	Optimo
964	O-	qui	Herido
965	B-	\N	Optimo
966	A-	\N	En Recuperacion
967	AB+	atque	En Recuperacion
968	B+	\N	En Recuperacion
969	AB+	eveniet	Herido
970	B-	quas	Baja Medica
971	AB-	inventore	En Recuperacion
972	AB+	nobis	En Recuperacion
973	B+	a	Herido
974	AB+	\N	Herido
975	O-	a	En Recuperacion
976	B-	\N	Baja Medica
977	B-	\N	Herido
978	A-	\N	Optimo
979	O+	at	Optimo
980	AB-	\N	Optimo
981	B+	corporis	En Recuperacion
982	A+	labore	En Recuperacion
983	AB+	\N	Optimo
984	B+	\N	En Recuperacion
985	B-	\N	En Recuperacion
986	AB-	beatae	Optimo
987	B+	\N	Baja Medica
988	B+	tenetur	Baja Medica
989	O+	\N	Optimo
990	O+	quisquam	En Recuperacion
991	A+	\N	Baja Medica
992	AB-	\N	Optimo
993	A+	\N	Optimo
994	AB+	\N	Optimo
995	B-	\N	Baja Medica
996	A+	\N	En Recuperacion
997	B-	esse	Herido
998	O-	id	En Recuperacion
999	O-	ratione	Herido
1000	B+	\N	En Recuperacion
1001	B+	\N	Herido
1002	B-	libero	En Recuperacion
1003	O+	minus	En Recuperacion
1004	AB+	\N	En Recuperacion
1005	B+	\N	Optimo
1006	A-	maiores	Optimo
1007	B+	fuga	Optimo
1008	AB+	commodi	Baja Medica
1009	A+	libero	Baja Medica
1010	A-	molestiae	Herido
1011	A-	officia	Herido
1012	O+	\N	Herido
1013	AB+	\N	Herido
1014	B-	\N	En Recuperacion
1015	B+	\N	Herido
1016	A+	\N	Herido
1017	A+	\N	Herido
1018	A-	\N	Baja Medica
1019	O-	\N	Optimo
1020	O-	\N	Baja Medica
1021	O-	eligendi	En Recuperacion
1022	O+	illum	Herido
1023	O+	natus	Optimo
1024	B+	eius	Herido
1025	AB+	\N	En Recuperacion
1026	A-	\N	En Recuperacion
1027	AB-	quod	Optimo
1028	B+	earum	Herido
1029	B+	tempore	Baja Medica
1030	O+	\N	Optimo
1031	A-	\N	Optimo
1032	O-	sapiente	En Recuperacion
1033	AB+	\N	En Recuperacion
1034	B-	\N	Optimo
1035	O-	assumenda	Baja Medica
1036	AB+	incidunt	Optimo
1037	O+	\N	Herido
1038	B-	\N	En Recuperacion
1039	A-	\N	Herido
1040	AB-	\N	Baja Medica
1041	B-	quo	En Recuperacion
1042	AB+	\N	Herido
1043	O+	nisi	Herido
1044	AB+	\N	Baja Medica
1045	AB-	\N	En Recuperacion
1046	B+	\N	En Recuperacion
1047	B+	quia	En Recuperacion
1048	O-	\N	Optimo
1049	O+	\N	Optimo
1050	A+	illo	En Recuperacion
1051	O+	\N	Herido
1052	O-	ex	Optimo
1053	B-	\N	Baja Medica
1054	O-	\N	Herido
1055	O-	\N	En Recuperacion
1056	O+	in	Optimo
1057	O+	quas	En Recuperacion
1058	AB-	\N	Herido
1059	B-	\N	En Recuperacion
1060	B-	\N	Herido
1061	AB-	doloribus	Baja Medica
1062	B-	\N	Herido
1063	A+	\N	Baja Medica
1064	B-	\N	Optimo
1065	AB-	aperiam	Baja Medica
1066	B-	officiis	Optimo
1067	B+	ipsum	Herido
1068	AB-	illo	Optimo
1069	A-	animi	En Recuperacion
1070	A-	quod	En Recuperacion
1071	AB+	\N	En Recuperacion
1072	B-	\N	En Recuperacion
1073	AB-	\N	Optimo
1074	A+	et	Optimo
1075	AB+	pariatur	Herido
1076	O+	\N	Optimo
1077	B-	\N	Optimo
1078	O+	assumenda	Optimo
1079	AB+	illo	Baja Medica
1080	O-	vel	Baja Medica
1081	AB-	\N	En Recuperacion
1082	O+	iure	En Recuperacion
1083	AB-	modi	Baja Medica
1084	A+	nihil	Optimo
1085	A+	cum	En Recuperacion
1086	O+	\N	Herido
1087	AB+	\N	Optimo
1088	B+	nobis	Herido
1089	A+	\N	Optimo
1090	B+	cum	Optimo
1091	O-	esse	Herido
1092	AB-	\N	Herido
1093	AB+	alias	Baja Medica
1094	O-	\N	En Recuperacion
1095	AB-	\N	Optimo
1096	B-	nulla	Baja Medica
1097	O-	accusantium	Baja Medica
1098	O-	nesciunt	Herido
1099	O-	\N	Optimo
1100	O+	non	Herido
1101	AB+	\N	En Recuperacion
1102	AB-	\N	En Recuperacion
1103	B+	\N	Baja Medica
1104	O-	maiores	Baja Medica
1105	AB+	\N	Herido
1106	AB-	\N	Herido
1107	O+	dolorem	Herido
1108	AB+	\N	Baja Medica
1109	A-	natus	Herido
1110	B-	sit	Optimo
1111	O+	nulla	Herido
1112	B-	consectetur	Baja Medica
1113	AB+	aliquam	Herido
1114	AB-	aperiam	En Recuperacion
1115	O-	excepturi	Optimo
1116	A-	\N	En Recuperacion
1117	A-	quod	Baja Medica
1118	B+	eligendi	Optimo
1119	O-	nobis	Herido
1120	AB+	a	En Recuperacion
1121	A-	\N	Herido
1122	A-	enim	En Recuperacion
1123	B+	\N	En Recuperacion
1124	O+	\N	Baja Medica
1125	B-	\N	En Recuperacion
1126	A+	\N	Baja Medica
1127	AB-	\N	Herido
1128	B-	asperiores	Optimo
1129	O-	aliquam	Optimo
1130	A-	harum	Baja Medica
1131	AB+	debitis	Herido
1132	O-	\N	Herido
1133	B-	aliquam	Herido
1134	A+	amet	Herido
1135	O+	corporis	Herido
1136	A-	unde	En Recuperacion
1137	AB-	\N	Herido
1138	B+	fuga	Baja Medica
1139	B+	error	Herido
1140	A+	cum	Herido
1141	B-	\N	Herido
1142	AB-	\N	Herido
1143	A+	odio	En Recuperacion
1144	B+	animi	Baja Medica
1145	A+	\N	Baja Medica
1146	O-	\N	Optimo
1147	A-	\N	Herido
1148	B+	\N	Baja Medica
1149	O+	numquam	Baja Medica
1150	AB-	\N	Herido
1151	A+	\N	Herido
1152	B+	ut	Herido
1153	B-	non	Baja Medica
1154	B+	\N	En Recuperacion
1155	O+	\N	Optimo
1156	AB-	sint	Baja Medica
1157	A+	delectus	En Recuperacion
1158	B-	suscipit	En Recuperacion
1159	AB+	\N	Herido
1160	A+	in	Optimo
1161	O-	minus	Herido
1162	O+	distinctio	Optimo
1163	A-	accusantium	Optimo
1164	B-	atque	Optimo
1165	AB-	nemo	Baja Medica
1166	AB-	\N	En Recuperacion
1167	B+	\N	Optimo
1168	O+	\N	Herido
1169	A-	quod	Baja Medica
1170	A+	\N	En Recuperacion
1171	A+	\N	Baja Medica
1172	A-	\N	Herido
1173	B-	\N	Baja Medica
1174	AB+	\N	En Recuperacion
1175	A-	at	Baja Medica
1176	A+	possimus	Optimo
1177	AB+	magni	En Recuperacion
1178	A+	\N	Optimo
1179	O-	\N	Baja Medica
1180	B-	sit	Herido
1181	AB-	deserunt	Baja Medica
1182	AB+	doloremque	Herido
1183	B-	\N	Optimo
1184	AB+	odit	En Recuperacion
1185	O-	\N	En Recuperacion
1186	AB+	\N	Herido
1187	B+	tenetur	Herido
1188	A+	\N	Baja Medica
1189	AB+	facere	Herido
1190	B+	\N	Baja Medica
1191	B-	\N	Optimo
1192	A-	\N	Baja Medica
1193	O+	\N	En Recuperacion
1194	B-	\N	En Recuperacion
1195	O-	iusto	En Recuperacion
1196	O+	\N	Optimo
1197	O-	quod	Herido
1198	A+	mollitia	Optimo
1199	A+	odit	Optimo
1200	A-	\N	Herido
1201	B-	\N	Herido
1202	O+	temporibus	En Recuperacion
1203	B+	ipsam	Baja Medica
1204	B+	\N	Herido
1205	O-	sapiente	En Recuperacion
1206	B+	\N	Herido
1207	AB-	quis	Optimo
1208	AB-	\N	Baja Medica
1209	B-	\N	Baja Medica
1210	AB-	\N	Baja Medica
1211	O+	\N	Herido
1212	AB-	est	Optimo
1213	A+	consequatur	Optimo
1214	O-	quae	En Recuperacion
1215	O+	\N	Optimo
1216	B+	et	Optimo
1217	AB-	\N	Baja Medica
1218	B+	\N	Optimo
1219	B+	pariatur	Herido
1220	A-	\N	Herido
1221	AB-	\N	En Recuperacion
1222	O+	dolore	En Recuperacion
1223	AB+	natus	En Recuperacion
1224	O+	\N	En Recuperacion
1225	B-	velit	Optimo
1226	A-	\N	Herido
1227	B-	\N	Baja Medica
1228	B+	\N	Herido
1229	O-	quos	Herido
1230	O-	et	Herido
1231	O-	\N	Herido
1232	AB-	error	Herido
1233	B+	\N	Herido
1234	B+	\N	En Recuperacion
1235	B-	distinctio	Optimo
1236	O-	distinctio	Baja Medica
1237	B+	\N	En Recuperacion
1238	B+	cumque	Optimo
1239	A-	\N	Optimo
1240	A+	incidunt	Herido
1241	AB-	\N	Herido
1242	AB-	\N	Baja Medica
1243	O-	ad	Baja Medica
1244	A+	\N	Baja Medica
1245	B+	pariatur	En Recuperacion
1246	A+	\N	En Recuperacion
1247	O-	quasi	Optimo
1248	A-	\N	Optimo
1249	O+	\N	Baja Medica
1250	B+	exercitationem	Optimo
1251	A+	autem	Optimo
1252	B+	rerum	Optimo
1253	B-	\N	En Recuperacion
1254	O+	totam	En Recuperacion
1255	B+	veritatis	Optimo
1256	AB-	corporis	Herido
1257	AB-	\N	En Recuperacion
1258	O+	\N	Optimo
1259	AB-	\N	Optimo
1260	B-	\N	En Recuperacion
1261	O-	\N	Herido
1262	A-	\N	En Recuperacion
1263	O-	\N	Baja Medica
1264	O+	consequatur	Baja Medica
1265	O-	\N	Optimo
1266	AB+	cum	Optimo
1267	AB-	\N	Herido
1268	O+	deleniti	Optimo
1269	AB+	rerum	Optimo
1270	A+	\N	Herido
1271	AB-	omnis	Baja Medica
1272	AB+	\N	Optimo
1273	O-	\N	Baja Medica
1274	A-	mollitia	Baja Medica
1275	B+	pariatur	Baja Medica
1276	O+	\N	En Recuperacion
1277	A-	\N	Herido
1278	AB-	soluta	Baja Medica
1279	B+	maxime	En Recuperacion
1280	B+	rerum	Optimo
1281	AB+	fugiat	Baja Medica
1282	O+	\N	En Recuperacion
1283	A+	\N	Herido
1284	AB-	voluptatum	En Recuperacion
1285	B-	\N	Baja Medica
1286	O-	\N	En Recuperacion
1287	O+	\N	Herido
1288	A-	\N	Optimo
1289	AB+	reprehenderit	Herido
1290	A-	\N	Herido
1291	O-	\N	Baja Medica
1292	B-	facilis	Herido
1293	O+	\N	Herido
1294	B-	\N	Baja Medica
1295	AB-	nemo	Optimo
1296	A+	\N	Baja Medica
1297	A-	explicabo	Herido
1298	B+	\N	Baja Medica
1299	O+	\N	Herido
1300	A+	beatae	Optimo
1301	O-	sint	Optimo
1302	B-	sequi	Baja Medica
1303	B+	\N	En Recuperacion
1304	B-	\N	En Recuperacion
1305	O+	nisi	Herido
1306	O-	molestias	En Recuperacion
1307	A+	\N	Optimo
1308	O-	doloremque	En Recuperacion
1309	B+	\N	En Recuperacion
1310	A+	enim	En Recuperacion
1311	A-	\N	Baja Medica
1312	A-	\N	Herido
1313	AB+	\N	Baja Medica
1314	B+	\N	En Recuperacion
1315	O-	\N	En Recuperacion
1316	AB+	\N	Optimo
1317	AB+	iste	Optimo
1318	A+	\N	Herido
1319	B+	repellat	Herido
1320	B+	\N	En Recuperacion
1321	A+	natus	Baja Medica
1322	O-	velit	Herido
1323	AB+	\N	Herido
1324	A+	\N	Baja Medica
1325	AB-	\N	En Recuperacion
1326	A-	\N	En Recuperacion
1327	AB-	modi	Herido
1328	AB+	voluptatem	Optimo
1329	O+	\N	Optimo
1330	B-	\N	En Recuperacion
1331	A+	\N	Optimo
1332	O+	\N	En Recuperacion
1333	O-	debitis	Herido
1334	B-	\N	Herido
1335	A-	\N	Herido
1336	O+	\N	Herido
1337	A+	\N	Baja Medica
1338	O-	iure	Baja Medica
1339	B-	doloremque	Optimo
1340	B+	repellendus	Herido
1341	A-	\N	Optimo
1342	A-	\N	Baja Medica
1343	O+	\N	En Recuperacion
1344	A+	\N	En Recuperacion
1345	AB+	eos	Baja Medica
1346	A-	perferendis	Herido
1347	A-	\N	Herido
1348	O-	\N	Herido
1349	O+	\N	Optimo
1350	B-	\N	En Recuperacion
1351	B-	ullam	Herido
1352	AB+	laborum	Baja Medica
1353	O-	odit	Optimo
1354	A-	\N	En Recuperacion
1355	AB-	\N	Baja Medica
1356	AB+	distinctio	Optimo
1357	B+	officiis	Herido
1358	AB-	\N	En Recuperacion
1359	A-	\N	En Recuperacion
1360	AB-	consequuntur	En Recuperacion
1361	A-	\N	Herido
1362	A+	dolores	En Recuperacion
1363	O+	nisi	Herido
1364	A+	\N	Baja Medica
1365	AB-	repellat	Baja Medica
1366	O+	\N	Herido
1367	B+	dolores	En Recuperacion
1368	O-	\N	Optimo
1369	B-	vitae	En Recuperacion
1370	A+	neque	Optimo
1371	A+	vero	Herido
1372	AB-	facere	Optimo
1373	O-	esse	En Recuperacion
1374	AB-	\N	Herido
1375	B-	cum	Baja Medica
1376	AB+	\N	Herido
1377	O-	vero	Baja Medica
1378	AB+	\N	En Recuperacion
1379	B-	\N	Optimo
1380	B-	minus	Optimo
1381	B-	\N	En Recuperacion
1382	AB+	provident	Optimo
1383	A-	\N	Baja Medica
1384	B+	vitae	En Recuperacion
1385	A-	\N	Baja Medica
1386	A+	iusto	En Recuperacion
1387	A+	architecto	Herido
1388	A-	maxime	Herido
1389	A+	quasi	Optimo
1390	AB+	quo	Baja Medica
1391	A+	\N	Baja Medica
1392	AB-	cumque	Baja Medica
1393	A-	excepturi	Baja Medica
1394	A+	\N	Baja Medica
1395	A+	\N	Optimo
1396	AB-	\N	En Recuperacion
1397	A-	amet	Baja Medica
1398	O-	quae	En Recuperacion
1399	B+	itaque	Baja Medica
1400	O-	\N	Baja Medica
1401	AB-	ut	Baja Medica
1402	B+	quisquam	Herido
1403	A-	\N	En Recuperacion
1404	O-	commodi	Baja Medica
1405	O+	non	En Recuperacion
1406	A+	\N	En Recuperacion
1407	O-	\N	En Recuperacion
1408	B+	\N	Herido
1409	O-	\N	Baja Medica
1410	A+	commodi	En Recuperacion
1411	AB-	\N	Herido
1412	B-	recusandae	En Recuperacion
1413	O+	voluptatibus	Herido
1414	A-	natus	Herido
1415	B-	saepe	En Recuperacion
1416	O-	magni	Optimo
1417	AB+	nobis	Optimo
1418	B+	fugit	Herido
1419	O-	nostrum	Baja Medica
1420	AB-	\N	Herido
1421	O-	\N	Optimo
1422	O+	\N	En Recuperacion
1423	O-	pariatur	Optimo
1424	A+	\N	Herido
1425	AB+	unde	En Recuperacion
1426	B+	\N	Optimo
1427	O+	voluptate	Herido
1428	AB+	\N	Baja Medica
1429	AB+	libero	Herido
1430	AB-	reprehenderit	Herido
1431	AB-	\N	En Recuperacion
1432	AB-	aliquam	Baja Medica
1433	B-	aliquam	Optimo
1434	O-	\N	Herido
1435	A+	quisquam	Baja Medica
1436	O-	\N	Optimo
1437	AB-	\N	Baja Medica
1438	O+	itaque	Baja Medica
1439	A-	\N	Herido
1440	O-	quibusdam	Optimo
1441	A-	natus	Herido
1442	B-	\N	Baja Medica
1443	AB+	iusto	Optimo
1444	O+	facilis	Optimo
1445	AB-	sapiente	Herido
1446	AB-	\N	Herido
1447	AB+	placeat	En Recuperacion
1448	B+	\N	Herido
1449	AB-	\N	Optimo
1450	A-	\N	Baja Medica
1451	O+	consequuntur	Baja Medica
1452	B+	odio	Baja Medica
1453	AB-	\N	En Recuperacion
1454	A+	perspiciatis	Optimo
1455	O-	veniam	Optimo
1456	O-	\N	Optimo
1457	B-	cum	Herido
1458	O-	\N	Optimo
1459	B-	\N	En Recuperacion
1460	A-	officiis	Herido
1461	AB-	\N	Herido
1462	B-	voluptate	En Recuperacion
1463	O-	\N	En Recuperacion
1464	B+	harum	Baja Medica
1465	A-	libero	En Recuperacion
1466	A+	itaque	Baja Medica
1467	O-	\N	En Recuperacion
1468	A+	\N	Baja Medica
1469	AB+	molestiae	Optimo
1470	AB+	odit	En Recuperacion
1471	AB+	\N	Baja Medica
1472	A-	voluptatem	En Recuperacion
1473	B+	consequatur	Baja Medica
1474	O-	facere	Baja Medica
1475	AB-	\N	Optimo
1476	AB+	\N	En Recuperacion
1477	AB+	dicta	Herido
1478	O-	iste	En Recuperacion
1479	B-	aspernatur	Baja Medica
1480	O+	\N	En Recuperacion
1481	B-	temporibus	Baja Medica
1482	O-	assumenda	Herido
1483	O+	\N	Herido
1484	O+	\N	Herido
1485	B-	eius	En Recuperacion
1486	AB-	\N	Baja Medica
1487	O-	\N	En Recuperacion
1488	A-	voluptate	Baja Medica
1489	A-	\N	En Recuperacion
1490	B+	aspernatur	En Recuperacion
1491	B+	\N	Herido
1492	A+	\N	Baja Medica
1493	O-	\N	En Recuperacion
1494	AB+	quos	Baja Medica
1495	O-	\N	En Recuperacion
1496	A+	ipsam	Herido
1497	AB+	\N	Baja Medica
1498	AB-	ex	Optimo
1499	B+	maxime	En Recuperacion
1500	B+	perspiciatis	En Recuperacion
1501	A-	\N	Herido
1502	AB+	\N	Optimo
1503	AB+	accusamus	Herido
1504	AB-	\N	Herido
1505	O+	similique	Baja Medica
1506	O+	\N	En Recuperacion
1507	AB-	sit	Optimo
1508	B-	\N	Optimo
1509	O-	\N	Baja Medica
1510	O-	\N	Baja Medica
1511	O+	accusantium	Baja Medica
1512	B-	\N	En Recuperacion
1513	B-	\N	Baja Medica
1514	AB-	ducimus	Herido
1515	O+	facilis	En Recuperacion
1516	A+	\N	Baja Medica
1517	O+	voluptatem	Optimo
1518	B+	\N	Baja Medica
1519	O-	quasi	En Recuperacion
1520	AB-	\N	Herido
1521	A+	\N	En Recuperacion
1522	B+	voluptates	En Recuperacion
1523	O+	reprehenderit	Herido
1524	B+	harum	Herido
1525	B-	\N	Optimo
1526	B-	\N	Optimo
1527	A-	\N	Baja Medica
1528	B+	delectus	Optimo
1529	B-	\N	Herido
1530	AB+	\N	Herido
1531	A-	\N	Optimo
1532	B-	corrupti	Baja Medica
1533	AB-	\N	Optimo
1534	O-	\N	Baja Medica
1535	B-	pariatur	Baja Medica
1536	AB+	odit	Herido
1537	O-	autem	Optimo
1538	O-	odio	Optimo
1539	AB-	\N	Optimo
1540	A+	accusamus	En Recuperacion
1541	O-	inventore	Baja Medica
1542	AB-	\N	En Recuperacion
1543	A-	\N	En Recuperacion
1544	AB+	ipsa	Baja Medica
1545	A+	\N	Optimo
1546	B+	\N	Baja Medica
1547	O+	similique	Herido
1548	B-	a	En Recuperacion
1549	B+	alias	Herido
1550	O-	quae	En Recuperacion
1551	B-	\N	Herido
1552	A+	\N	Optimo
1553	AB+	\N	Herido
1554	AB+	\N	Herido
1555	A+	\N	Baja Medica
1556	O-	\N	En Recuperacion
1557	A+	\N	En Recuperacion
1558	O-	\N	Baja Medica
1559	AB+	\N	Herido
1560	A-	\N	Optimo
1561	A+	\N	Optimo
1562	O+	\N	Optimo
1563	O-	veritatis	Baja Medica
1564	AB-	\N	Optimo
1565	A+	est	Baja Medica
1566	B+	\N	Optimo
1567	B+	\N	Herido
1568	B-	eaque	Optimo
1569	B-	vitae	Herido
1570	B-	in	Optimo
1571	AB-	\N	Herido
1572	A-	eum	En Recuperacion
1573	O+	\N	Optimo
1574	AB+	iure	En Recuperacion
1575	B-	\N	En Recuperacion
1576	AB-	tenetur	Optimo
1577	AB-	\N	Baja Medica
1578	AB-	ipsum	Baja Medica
1579	A-	doloremque	Baja Medica
1580	A+	\N	En Recuperacion
1581	O+	aspernatur	Herido
1582	AB-	\N	Optimo
1583	AB+	\N	Optimo
1584	B+	\N	Herido
1585	A+	\N	Herido
1586	B+	reiciendis	En Recuperacion
1587	B+	quasi	Baja Medica
1588	O+	\N	Optimo
1589	B+	\N	Optimo
1590	B+	cum	Optimo
1591	B-	nihil	Baja Medica
1592	O-	nemo	En Recuperacion
1593	O+	ut	Herido
1594	AB-	\N	Optimo
1595	O-	placeat	Herido
1596	O+	recusandae	En Recuperacion
1597	AB-	ipsam	Optimo
1598	A-	autem	Optimo
1599	A-	repellat	En Recuperacion
1600	A+	eos	Herido
1601	B+	\N	Optimo
1602	B-	assumenda	Baja Medica
1603	A-	deleniti	Herido
1604	O-	\N	Herido
1605	A+	adipisci	En Recuperacion
1606	B+	consequatur	En Recuperacion
1607	O-	\N	En Recuperacion
1608	A+	\N	Optimo
1609	A+	distinctio	En Recuperacion
1610	A+	\N	Optimo
1611	B+	expedita	Herido
1612	B-	\N	En Recuperacion
1613	A+	\N	Herido
1614	O+	\N	Optimo
1615	B+	atque	Baja Medica
1616	AB+	\N	En Recuperacion
1617	O+	accusantium	Herido
1618	AB+	atque	En Recuperacion
1619	A-	\N	Herido
1620	A-	\N	Baja Medica
1621	B+	\N	Herido
1622	AB-	\N	Herido
1623	AB-	\N	Optimo
1624	O+	numquam	Baja Medica
1625	AB-	\N	En Recuperacion
1626	A-	\N	En Recuperacion
1627	B+	magnam	Baja Medica
1628	AB+	\N	En Recuperacion
1629	O+	est	Baja Medica
1630	O+	\N	En Recuperacion
1631	AB+	\N	Baja Medica
1632	A-	\N	Herido
1633	B+	alias	Herido
1634	O-	et	Optimo
1635	A-	\N	Baja Medica
1636	AB+	numquam	Optimo
1637	A+	soluta	Herido
1638	AB+	\N	Optimo
1639	AB+	pariatur	En Recuperacion
1640	A+	dicta	En Recuperacion
1641	A+	\N	Herido
1642	B-	\N	Optimo
1643	A-	earum	Optimo
1644	A+	possimus	En Recuperacion
1645	O-	\N	Baja Medica
1646	O+	\N	En Recuperacion
1647	AB+	eius	Baja Medica
1648	O+	\N	Baja Medica
1649	B+	sapiente	En Recuperacion
1650	AB+	quidem	Herido
1651	B-	odio	En Recuperacion
1652	AB+	laudantium	En Recuperacion
1653	A-	\N	Baja Medica
1654	A+	\N	Baja Medica
1655	AB+	\N	Baja Medica
1656	AB+	\N	Optimo
1657	O-	\N	Baja Medica
1658	B+	\N	Herido
1659	O+	\N	Baja Medica
1660	O-	veniam	En Recuperacion
1661	O+	\N	Optimo
1662	AB+	quae	Herido
1663	O+	quaerat	Herido
1664	AB+	odit	Baja Medica
1665	O-	\N	Herido
1666	AB-	\N	Optimo
1667	A+	\N	Baja Medica
1668	O+	culpa	En Recuperacion
1669	AB+	\N	Baja Medica
1670	AB-	necessitatibus	Herido
1671	AB+	quae	En Recuperacion
1672	A-	\N	Optimo
1673	O+	\N	Herido
1674	O+	recusandae	Baja Medica
1675	AB+	\N	Baja Medica
1676	AB+	\N	Baja Medica
1677	B+	neque	Baja Medica
1678	A+	\N	Baja Medica
1679	A-	\N	Herido
1680	AB+	ea	En Recuperacion
1681	A-	alias	Optimo
1682	A-	\N	Herido
1683	O+	\N	Herido
1684	O-	quisquam	Optimo
1685	O-	voluptatem	Baja Medica
1686	B-	\N	Herido
1687	A-	\N	Optimo
1688	AB-	quos	Herido
1689	B-	\N	Herido
1690	O+	laboriosam	Optimo
1691	AB-	sed	Baja Medica
1692	B+	fuga	Herido
1693	AB-	\N	En Recuperacion
1694	B+	iste	Herido
1695	O+	dolores	Baja Medica
1696	B-	cupiditate	Optimo
1697	AB+	quisquam	En Recuperacion
1698	AB-	\N	Baja Medica
1699	B-	\N	Optimo
1700	B+	voluptate	En Recuperacion
1701	A+	libero	Optimo
1702	O-	voluptatum	Baja Medica
1703	B-	ipsa	En Recuperacion
1704	AB+	ex	Herido
1705	B+	sequi	Herido
1706	AB-	\N	Optimo
1707	B+	\N	Baja Medica
1708	A-	aperiam	Baja Medica
1709	AB-	\N	En Recuperacion
1710	O-	nisi	Herido
1711	A-	magnam	Optimo
1712	AB+	\N	Baja Medica
1713	B+	excepturi	Baja Medica
1714	AB+	\N	En Recuperacion
1715	B+	\N	Baja Medica
1716	O-	esse	En Recuperacion
1717	A-	impedit	Optimo
1718	AB-	\N	Optimo
1719	O+	\N	Baja Medica
1720	AB-	\N	Baja Medica
1721	O-	\N	En Recuperacion
1722	A+	\N	Optimo
1723	AB+	\N	Herido
1724	A-	quibusdam	Baja Medica
1725	B-	voluptas	En Recuperacion
1726	O-	atque	Herido
1727	AB-	\N	En Recuperacion
1728	O+	quod	En Recuperacion
1729	O+	cum	Baja Medica
1730	AB-	\N	Baja Medica
1731	AB-	\N	Herido
1732	B-	facilis	Optimo
1733	O+	\N	Baja Medica
1734	O-	quae	Herido
1735	A+	\N	En Recuperacion
1736	O-	\N	En Recuperacion
1737	AB+	eligendi	Herido
1738	O-	\N	Optimo
1739	O-	\N	En Recuperacion
1740	B-	\N	En Recuperacion
1741	B+	omnis	Herido
1742	B-	\N	Herido
1743	O-	eveniet	Baja Medica
1744	B-	ab	Optimo
1745	O-	eligendi	En Recuperacion
1746	A+	cum	Herido
1747	O-	velit	Herido
1748	B-	\N	Optimo
1749	O-	aut	Herido
1750	B+	iste	Optimo
1751	O-	sint	Optimo
1752	AB+	\N	Herido
1753	AB+	magni	En Recuperacion
1754	O+	sunt	Baja Medica
1755	O-	\N	Baja Medica
1756	A+	consequuntur	Optimo
1757	O+	voluptate	Herido
1758	O-	\N	Optimo
1759	B-	repellat	Optimo
1760	O+	\N	Baja Medica
1761	A+	ullam	Baja Medica
1762	B-	\N	Herido
1763	A-	\N	Baja Medica
1764	O+	\N	En Recuperacion
1765	A-	ad	En Recuperacion
1766	B+	earum	Optimo
1767	O-	\N	Optimo
1768	O-	autem	En Recuperacion
1769	B-	voluptatibus	Baja Medica
1770	A-	inventore	Baja Medica
1771	B-	quos	En Recuperacion
1772	AB-	sint	Optimo
1773	AB+	\N	En Recuperacion
1774	B+	ab	En Recuperacion
1775	AB-	error	Baja Medica
1776	A-	\N	Optimo
1777	AB-	\N	En Recuperacion
1778	AB+	occaecati	Herido
1779	AB+	\N	Baja Medica
1780	B-	\N	Baja Medica
1781	O-	\N	En Recuperacion
1782	B+	\N	Herido
1783	A+	dicta	Herido
1784	AB+	iure	En Recuperacion
1785	AB-	earum	En Recuperacion
1786	B+	\N	Optimo
1787	AB-	ducimus	En Recuperacion
1788	AB-	sunt	Herido
1789	B-	illo	Herido
1790	AB+	\N	Herido
1791	A-	voluptas	Baja Medica
1792	AB-	\N	Baja Medica
1793	B-	minus	Baja Medica
1794	AB-	vitae	Optimo
1795	A-	rem	Herido
1796	O+	\N	En Recuperacion
1797	B+	\N	Baja Medica
1798	A-	\N	Herido
1799	AB-	\N	Optimo
1800	AB+	pariatur	Herido
1801	A-	ducimus	Optimo
1802	AB+	\N	En Recuperacion
1803	O+	\N	Herido
1804	B+	repellendus	Herido
1805	B+	deserunt	En Recuperacion
1806	O+	nesciunt	En Recuperacion
1807	A+	perferendis	Optimo
1808	O-	\N	Herido
1809	B-	\N	Herido
1810	B-	expedita	Baja Medica
1811	B-	minus	Optimo
1812	O-	\N	Herido
1813	O-	\N	Herido
1814	O+	\N	Herido
1815	A-	\N	Baja Medica
1816	A-	iure	Optimo
1817	A-	quam	Herido
1818	B-	\N	Baja Medica
1819	A-	fugiat	Optimo
1820	O-	perferendis	Optimo
1821	AB-	\N	Herido
1822	B+	\N	Baja Medica
1823	AB+	ipsa	Optimo
1824	O-	\N	En Recuperacion
1825	B+	\N	Optimo
1826	B+	ipsum	Baja Medica
1827	B-	\N	Optimo
1828	A+	\N	Optimo
1829	A+	quia	En Recuperacion
1830	O-	voluptatum	Herido
1831	O+	voluptatem	En Recuperacion
1832	AB+	tempore	En Recuperacion
1833	O-	asperiores	Herido
1834	AB+	quibusdam	Herido
1835	AB-	\N	Herido
1836	A+	\N	Optimo
1837	O+	laudantium	Herido
1838	O-	\N	En Recuperacion
1839	A+	\N	Baja Medica
1840	AB+	corporis	Optimo
1841	B-	nemo	En Recuperacion
1842	O+	commodi	Optimo
1843	O+	maxime	Baja Medica
1844	AB-	\N	En Recuperacion
1845	AB-	\N	Baja Medica
1846	A-	\N	En Recuperacion
1847	O-	sunt	Herido
1848	AB-	\N	En Recuperacion
1849	A-	\N	En Recuperacion
1850	B+	\N	En Recuperacion
1851	A+	nihil	Optimo
1852	A-	ipsa	Optimo
1853	B+	\N	En Recuperacion
1854	B-	officia	Herido
1855	B-	\N	Baja Medica
1856	A+	\N	Herido
1857	A-	earum	En Recuperacion
1858	B-	\N	Herido
1859	B+	suscipit	Herido
1860	O-	quo	Baja Medica
1861	B+	soluta	Optimo
1862	A+	illum	Baja Medica
1863	B+	similique	Herido
1864	A+	\N	Baja Medica
1865	B+	\N	En Recuperacion
1866	O+	ratione	En Recuperacion
1867	AB+	\N	Optimo
1868	AB-	optio	Optimo
1869	A+	porro	Optimo
1870	A+	\N	Optimo
1871	A+	magnam	En Recuperacion
1872	A-	\N	Optimo
1873	AB-	\N	Herido
1874	AB-	iure	Baja Medica
1875	B-	aperiam	En Recuperacion
1876	B-	\N	Herido
1877	AB+	\N	Herido
1878	B-	occaecati	Herido
1879	A-	\N	En Recuperacion
1880	AB+	inventore	Herido
1881	A+	\N	Herido
1882	B-	omnis	Herido
1883	B-	\N	Herido
1884	AB-	\N	Herido
1885	B+	\N	Optimo
1886	O+	repudiandae	En Recuperacion
1887	A-	fugit	Baja Medica
1888	O-	\N	En Recuperacion
1889	A+	tempore	Optimo
1890	B-	nulla	Optimo
1891	B-	architecto	Optimo
1892	O-	\N	Baja Medica
1893	O-	\N	Optimo
1894	AB-	\N	Herido
1895	AB+	\N	En Recuperacion
1896	O+	\N	Herido
1897	B+	\N	En Recuperacion
1898	B-	totam	Baja Medica
1899	A+	consectetur	Optimo
1900	AB-	\N	Optimo
1901	A-	quaerat	Herido
1902	A-	\N	Baja Medica
1903	AB+	exercitationem	En Recuperacion
1904	A+	\N	En Recuperacion
1905	B+	\N	Herido
1906	B-	architecto	Herido
1907	A-	\N	Baja Medica
1908	B-	adipisci	En Recuperacion
1909	AB-	\N	Optimo
1910	B-	\N	En Recuperacion
1911	A+	\N	Baja Medica
1912	AB+	ipsa	Herido
1913	B+	maiores	En Recuperacion
1914	B+	delectus	Herido
1915	B-	ipsa	Baja Medica
1916	A+	doloremque	En Recuperacion
1917	B+	sapiente	Baja Medica
1918	B+	\N	Baja Medica
1919	O-	sunt	Optimo
1920	A+	dicta	Baja Medica
1921	B-	\N	En Recuperacion
1922	O-	\N	Optimo
1923	A+	aliquam	Baja Medica
1924	O-	\N	Herido
1925	A-	voluptatum	Optimo
1926	A-	repudiandae	Herido
1927	AB-	\N	Baja Medica
1928	AB-	eligendi	Herido
1929	AB+	occaecati	Herido
1930	O+	\N	Baja Medica
1931	O+	\N	Optimo
1932	A+	eum	Herido
1933	AB+	\N	Optimo
1934	AB-	temporibus	Herido
1935	B+	provident	Baja Medica
1936	A+	\N	Optimo
1937	AB+	culpa	Herido
1938	A+	\N	En Recuperacion
1939	B+	fugit	Herido
1940	AB-	\N	Herido
1941	A+	\N	Herido
1942	A-	\N	En Recuperacion
1943	A+	\N	Optimo
1944	B+	\N	Herido
1945	A-	\N	En Recuperacion
1946	B-	vero	Herido
1947	A+	\N	Optimo
1948	AB+	rerum	Herido
1949	B-	ex	Herido
1950	B+	\N	En Recuperacion
1951	O-	\N	Herido
1952	AB-	autem	Herido
1953	B-	eius	Baja Medica
1954	AB+	\N	Herido
1955	A-	\N	Optimo
1956	A-	doloribus	Optimo
1957	A-	accusamus	Baja Medica
1958	AB-	\N	Herido
1959	A+	\N	Herido
1960	O-	illum	Baja Medica
1961	A+	\N	En Recuperacion
1962	O-	\N	En Recuperacion
1963	O+	earum	Baja Medica
1964	B-	quae	Optimo
1965	A+	\N	En Recuperacion
1966	A-	magni	Baja Medica
1967	AB-	minus	Baja Medica
1968	A-	saepe	Herido
1969	AB-	cupiditate	Baja Medica
1970	A+	\N	Optimo
1971	B-	ab	En Recuperacion
1972	O-	molestias	Herido
1973	B+	\N	En Recuperacion
1974	AB-	\N	Baja Medica
1975	AB-	minus	Herido
1976	A-	expedita	En Recuperacion
1977	O-	\N	En Recuperacion
1978	A+	\N	Baja Medica
1979	A+	accusamus	Optimo
1980	A-	\N	Herido
1981	B-	exercitationem	Herido
1982	O-	rerum	Baja Medica
1983	AB-	iure	En Recuperacion
1984	A+	vel	Baja Medica
1985	B+	incidunt	Baja Medica
1986	O+	\N	En Recuperacion
1987	O+	dolores	Baja Medica
1988	AB+	laboriosam	En Recuperacion
1989	O-	\N	Baja Medica
1990	A-	inventore	Optimo
1991	AB+	eius	Herido
1992	A+	rem	Baja Medica
1993	AB-	veritatis	Optimo
1994	O-	\N	Herido
1995	B+	\N	Optimo
1996	B-	\N	En Recuperacion
1997	A+	\N	Optimo
1998	A+	\N	Herido
1999	O+	\N	En Recuperacion
2000	B+	tempora	Optimo
2001	A-	vitae	Baja Medica
2002	AB-	iusto	Baja Medica
2003	A-	voluptatum	Herido
2004	A-	numquam	En Recuperacion
2005	B+	modi	Baja Medica
2006	B-	odit	Optimo
2007	A+	\N	Baja Medica
2008	AB+	\N	En Recuperacion
2009	AB-	\N	Baja Medica
2010	AB+	quam	Optimo
2011	O-	\N	En Recuperacion
2012	AB-	\N	Baja Medica
2013	B-	\N	Optimo
2014	AB-	sed	Optimo
2015	O+	\N	Baja Medica
2016	O+	qui	En Recuperacion
2017	A-	inventore	En Recuperacion
2018	B-	\N	En Recuperacion
2019	O+	ex	Optimo
2020	A+	\N	Optimo
2021	O-	nostrum	Optimo
2022	O+	fugit	Herido
2023	B+	\N	Herido
2024	O-	\N	Optimo
2025	AB+	\N	Optimo
2026	AB-	similique	En Recuperacion
2027	AB-	\N	Baja Medica
2028	B-	maiores	Baja Medica
2029	AB+	consequuntur	Herido
2030	B-	amet	Baja Medica
2031	B+	maiores	Herido
2032	A+	impedit	Baja Medica
2033	O-	\N	En Recuperacion
2034	O+	\N	Baja Medica
2035	AB-	\N	En Recuperacion
2036	AB-	placeat	Herido
2037	A+	\N	Baja Medica
2038	O+	commodi	Optimo
2039	B-	exercitationem	Baja Medica
2040	AB+	quia	En Recuperacion
2041	A-	vel	Baja Medica
2042	O+	\N	Optimo
2043	A+	\N	Baja Medica
2044	O-	assumenda	Herido
2045	O-	\N	Optimo
2046	A+	\N	Optimo
2047	A-	quasi	Herido
2048	B-	\N	En Recuperacion
2049	B-	\N	Baja Medica
2050	B-	\N	Optimo
2051	A+	dolorem	Optimo
2052	O+	eaque	En Recuperacion
2053	AB-	\N	Optimo
2054	O+	asperiores	Herido
2055	AB+	perspiciatis	Optimo
2056	AB+	\N	Optimo
2057	B+	inventore	Herido
2058	AB-	\N	Baja Medica
2059	B-	labore	En Recuperacion
2060	A+	\N	Herido
2061	AB-	tenetur	Optimo
2062	B+	excepturi	En Recuperacion
2063	AB-	pariatur	En Recuperacion
2064	AB+	fuga	Herido
2065	AB-	deserunt	Herido
2066	O+	\N	Herido
2067	O+	necessitatibus	Herido
2068	O-	aliquid	Optimo
2069	O-	\N	En Recuperacion
2070	AB+	\N	En Recuperacion
2071	A+	\N	Optimo
2072	AB-	\N	En Recuperacion
2073	B-	\N	En Recuperacion
2074	AB+	\N	Baja Medica
2075	B+	\N	Baja Medica
2076	B+	enim	Optimo
2077	B+	\N	En Recuperacion
2078	A-	\N	Baja Medica
2079	AB+	\N	Optimo
2080	O+	\N	Optimo
2081	B-	\N	Herido
2082	A-	tempora	Baja Medica
2083	A+	maxime	Baja Medica
2084	B+	\N	Optimo
2085	A+	\N	Optimo
2086	B+	dolorem	Baja Medica
2087	A-	\N	Baja Medica
2088	B+	\N	Herido
2089	O+	\N	Herido
2090	AB+	qui	En Recuperacion
2091	A+	quidem	Baja Medica
2092	A+	\N	Baja Medica
2093	B-	nesciunt	Optimo
2094	O+	hic	Optimo
2095	B-	\N	Baja Medica
2096	AB+	\N	Herido
2097	A-	\N	Optimo
2098	O-	repudiandae	Optimo
2099	A-	deserunt	Baja Medica
2100	A-	beatae	Optimo
2101	B-	repellat	Herido
2102	A+	\N	En Recuperacion
2103	O-	enim	Baja Medica
2104	B-	eveniet	Optimo
2105	O+	\N	Herido
2106	AB+	\N	En Recuperacion
2107	O+	\N	Optimo
2108	AB-	dolor	Optimo
2109	B-	suscipit	Optimo
2110	A+	\N	En Recuperacion
2111	A-	\N	En Recuperacion
2112	B-	vero	Baja Medica
2113	O-	\N	En Recuperacion
2114	AB-	\N	Herido
2115	B+	\N	Baja Medica
2116	O-	\N	Herido
2117	AB+	\N	Herido
2118	A-	labore	Baja Medica
2119	O-	\N	Baja Medica
2120	O+	\N	Herido
2121	O-	\N	Optimo
2122	AB+	in	Herido
2123	B+	aliquid	En Recuperacion
2124	O-	maiores	Herido
2125	O-	\N	Baja Medica
2126	AB-	\N	Baja Medica
2127	O-	laboriosam	Herido
2128	O-	\N	Optimo
2129	B-	quasi	Baja Medica
2130	O+	repudiandae	Herido
2131	A+	\N	Herido
2132	O-	pariatur	En Recuperacion
2133	A-	perferendis	Baja Medica
2134	B+	quas	Herido
2135	B-	\N	Baja Medica
2136	O-	\N	Baja Medica
2137	O-	\N	En Recuperacion
2138	AB-	\N	Optimo
2139	AB+	\N	Herido
2140	A-	ab	En Recuperacion
2141	AB-	\N	Baja Medica
2142	AB-	\N	Optimo
2143	A-	\N	Herido
2144	AB+	necessitatibus	En Recuperacion
2145	B-	perferendis	Herido
2146	A-	enim	Optimo
2147	A-	cumque	En Recuperacion
2148	O-	ut	Herido
2149	O+	\N	Herido
2150	A+	\N	Herido
2151	O-	\N	Baja Medica
2152	B-	\N	Herido
2153	AB+	tenetur	En Recuperacion
2154	B-	sit	Baja Medica
2155	O-	\N	Optimo
2156	AB-	voluptates	Herido
2157	AB-	repellat	Baja Medica
2158	AB+	atque	Herido
2159	B-	\N	Herido
2160	AB-	\N	Optimo
2161	AB+	\N	Optimo
2162	AB-	beatae	Optimo
2163	AB-	consequuntur	Optimo
2164	O+	nisi	Baja Medica
2165	O+	porro	Optimo
2166	B+	ab	Optimo
2167	B-	\N	En Recuperacion
2168	B+	\N	Baja Medica
2169	O+	\N	Optimo
2170	A+	mollitia	En Recuperacion
2171	A+	\N	Baja Medica
2172	B-	\N	Optimo
2173	B-	dolores	Baja Medica
2174	AB-	similique	Herido
2175	AB-	\N	Baja Medica
2176	AB-	\N	Baja Medica
2177	O+	minus	Optimo
2178	A+	\N	En Recuperacion
2179	A-	\N	Baja Medica
2180	B-	\N	Optimo
2181	B-	dignissimos	En Recuperacion
2182	B-	\N	Herido
2183	O-	\N	Optimo
2184	A-	molestiae	Optimo
2185	AB-	fugit	Optimo
2186	A+	distinctio	En Recuperacion
2187	A+	blanditiis	En Recuperacion
2188	B-	in	En Recuperacion
2189	A-	perferendis	Herido
2190	A+	officiis	Baja Medica
2191	O+	\N	En Recuperacion
2192	AB-	architecto	Optimo
2193	A-	eaque	Baja Medica
2194	B+	hic	Baja Medica
2195	AB+	ipsa	Herido
2196	O+	\N	En Recuperacion
2197	A-	\N	En Recuperacion
2198	O-	consectetur	En Recuperacion
2199	AB-	consequuntur	Herido
2200	B+	magnam	En Recuperacion
2201	O+	quo	Optimo
2202	B+	\N	En Recuperacion
2203	O-	repellendus	Herido
2204	B-	blanditiis	Baja Medica
2205	B+	quisquam	En Recuperacion
2206	A+	\N	Herido
2207	O+	veritatis	En Recuperacion
2208	O-	\N	Optimo
2209	B+	dolor	En Recuperacion
2210	AB-	distinctio	Optimo
2211	A+	\N	En Recuperacion
2212	B-	incidunt	Herido
2213	O-	ex	En Recuperacion
2214	B-	\N	Herido
2215	O-	\N	Herido
2216	A+	\N	Optimo
2217	AB+	\N	Herido
2218	B+	amet	Optimo
2219	A+	quod	Optimo
2220	B-	\N	Baja Medica
2221	A+	\N	Herido
2222	B+	maiores	Optimo
2223	O-	vitae	Baja Medica
2224	B-	eum	Baja Medica
2225	AB-	quia	Optimo
2226	B-	\N	Baja Medica
2227	AB-	molestias	Baja Medica
2228	B-	dolor	Optimo
2229	AB+	corporis	Optimo
2230	O+	\N	Baja Medica
2231	A+	dicta	Optimo
2232	B-	eligendi	Baja Medica
2233	A-	maiores	Optimo
2234	O+	impedit	En Recuperacion
2235	AB+	ex	Optimo
2236	B-	doloremque	Herido
2237	B+	numquam	Herido
2238	B+	\N	En Recuperacion
2239	O-	quidem	Herido
2240	A+	\N	Baja Medica
2241	O+	\N	Baja Medica
2242	A-	\N	En Recuperacion
2243	AB-	\N	Herido
2244	B+	aliquam	Baja Medica
2245	A+	\N	En Recuperacion
2246	B-	quod	En Recuperacion
2247	O+	quas	Optimo
2248	A-	eligendi	Optimo
2249	A-	\N	Baja Medica
2250	AB-	\N	En Recuperacion
2251	B+	\N	Herido
2252	A+	\N	Baja Medica
2253	O-	\N	En Recuperacion
2254	AB-	animi	Optimo
2255	O+	distinctio	En Recuperacion
2256	O+	earum	Herido
2257	B-	\N	Baja Medica
2258	AB-	totam	En Recuperacion
2259	O-	\N	En Recuperacion
2260	B-	\N	Herido
2261	A+	\N	Optimo
2262	B-	\N	Baja Medica
2263	O+	eligendi	Optimo
2264	B+	\N	Herido
2265	B+	deleniti	En Recuperacion
2266	O-	\N	Optimo
2267	O-	\N	En Recuperacion
2268	B-	\N	Optimo
2269	A+	\N	Optimo
2270	O+	\N	Baja Medica
2271	A+	sit	Herido
2272	B-	\N	Optimo
2273	AB-	quae	Optimo
2274	AB-	eum	Optimo
2275	B+	facilis	Herido
2276	A+	laudantium	Baja Medica
2277	O-	reprehenderit	Optimo
2278	A+	\N	En Recuperacion
2279	O+	tempora	Baja Medica
2280	O+	\N	Optimo
2281	O-	\N	En Recuperacion
2282	AB-	non	En Recuperacion
2283	A-	eos	Baja Medica
2284	B+	corrupti	Baja Medica
2285	AB-	\N	En Recuperacion
2286	O+	deleniti	Baja Medica
2287	B+	\N	Baja Medica
2288	AB+	id	Herido
2289	B-	\N	Optimo
2290	B+	facere	Herido
2291	AB+	cumque	Herido
2292	AB-	\N	Baja Medica
2293	AB+	laudantium	En Recuperacion
2294	B-	corporis	Optimo
2295	B+	cupiditate	Baja Medica
2296	O+	\N	Optimo
2297	B-	\N	Baja Medica
2298	A+	\N	Herido
2299	B-	mollitia	En Recuperacion
2300	AB+	autem	Baja Medica
2301	A-	facilis	Optimo
2302	A+	delectus	Optimo
2303	A-	esse	Baja Medica
2304	A+	dolor	Optimo
2305	B-	quia	Optimo
2306	A+	\N	Herido
2307	B-	vel	Baja Medica
2308	A-	\N	Baja Medica
2309	O+	iusto	Optimo
2310	B-	\N	Baja Medica
2311	O-	veniam	Optimo
2312	O-	recusandae	Baja Medica
2313	A+	provident	En Recuperacion
2314	AB-	eum	Optimo
2315	B+	\N	Baja Medica
2316	B+	\N	Baja Medica
2317	A-	cum	En Recuperacion
2318	A+	rerum	Herido
2319	AB+	placeat	En Recuperacion
2320	A+	\N	Baja Medica
2321	O+	\N	Herido
2322	O+	dicta	En Recuperacion
2323	B+	\N	Optimo
2324	AB+	voluptates	Baja Medica
2325	AB+	ex	Optimo
2326	AB-	\N	Herido
2327	O-	\N	Optimo
2328	A+	ipsum	Herido
2329	O+	\N	Baja Medica
2330	A-	\N	En Recuperacion
2331	B-	\N	Optimo
2332	O-	\N	En Recuperacion
2333	AB-	\N	Herido
2334	B+	quod	Optimo
2335	B+	fugit	Baja Medica
2336	O-	\N	En Recuperacion
2337	AB+	voluptatum	Herido
2338	B+	itaque	Herido
2339	O-	veritatis	Optimo
2340	B-	\N	En Recuperacion
2341	A+	\N	En Recuperacion
2342	A-	voluptate	Optimo
2343	AB-	\N	Baja Medica
2344	B+	\N	Herido
2345	O-	\N	Herido
2346	A+	\N	Herido
2347	O+	nesciunt	Optimo
2348	AB+	debitis	Baja Medica
2349	A+	\N	Baja Medica
2350	A-	similique	Baja Medica
2351	A+	\N	Herido
2352	B-	\N	Optimo
2353	AB+	dicta	Baja Medica
2354	B+	\N	En Recuperacion
2355	AB+	quas	Baja Medica
2356	A+	distinctio	Baja Medica
2357	AB-	fuga	Baja Medica
2358	AB-	\N	Herido
2359	A+	molestias	Optimo
2360	AB-	\N	Baja Medica
2361	A-	\N	Herido
2362	AB-	\N	En Recuperacion
2363	O-	non	Optimo
2364	B-	\N	Baja Medica
2365	O-	atque	Baja Medica
2366	A-	\N	Optimo
2367	B-	quasi	Optimo
2368	O+	ducimus	En Recuperacion
2369	O+	\N	Optimo
2370	A-	\N	Herido
2371	O-	\N	Herido
2372	B-	ab	En Recuperacion
2373	O-	\N	Optimo
2374	B-	\N	Herido
2375	O+	vero	Baja Medica
2376	B-	perferendis	Optimo
2377	A+	\N	En Recuperacion
2378	A-	aperiam	Optimo
2379	AB-	\N	Herido
2380	AB-	inventore	En Recuperacion
2381	O-	\N	En Recuperacion
2382	O+	saepe	Optimo
2383	A+	\N	Optimo
2384	A-	provident	Herido
2385	A+	\N	Optimo
2386	A+	\N	En Recuperacion
2387	AB-	\N	Herido
2388	AB+	\N	Optimo
2389	O-	\N	En Recuperacion
2390	AB-	\N	Herido
2391	AB+	\N	Baja Medica
2392	O-	est	Herido
2393	AB+	nisi	Baja Medica
2394	B-	quasi	En Recuperacion
2395	A-	praesentium	Baja Medica
2396	B+	error	Herido
2397	O-	inventore	Herido
2398	AB-	\N	En Recuperacion
2399	B+	\N	Baja Medica
2400	B+	neque	Optimo
2401	B+	molestias	Baja Medica
2402	O+	\N	Optimo
2403	AB-	labore	En Recuperacion
2404	B-	\N	Herido
2405	AB+	totam	Optimo
2406	AB-	\N	Herido
2407	A-	provident	Herido
2408	O+	mollitia	Baja Medica
2409	B+	laborum	Baja Medica
2410	B+	\N	En Recuperacion
2411	O-	\N	Baja Medica
2412	A+	quo	Optimo
2413	A+	\N	Baja Medica
2414	A+	\N	En Recuperacion
2415	B+	at	Optimo
2416	A-	iure	En Recuperacion
2417	AB+	\N	Optimo
2418	A-	\N	Baja Medica
2419	AB+	\N	Herido
2420	O-	\N	Optimo
2421	O-	asperiores	Herido
2422	O+	\N	En Recuperacion
2423	AB+	\N	Optimo
2424	A+	\N	Optimo
2425	B-	\N	En Recuperacion
2426	B+	aspernatur	Optimo
2427	B-	\N	En Recuperacion
2428	A+	\N	Optimo
2429	A-	quasi	Herido
2430	AB-	cumque	En Recuperacion
2431	B-	\N	En Recuperacion
2432	A-	\N	Baja Medica
2433	B-	vitae	Herido
2434	A-	laboriosam	Baja Medica
2435	B+	\N	Optimo
2436	AB-	\N	Herido
2437	O-	\N	Optimo
2438	AB-	autem	Baja Medica
2439	AB+	ratione	Herido
2440	AB+	explicabo	Optimo
2441	A-	\N	En Recuperacion
2442	AB+	repellendus	En Recuperacion
2443	B-	quasi	Optimo
2444	A-	\N	Optimo
2445	A-	corporis	En Recuperacion
2446	O+	\N	Herido
2447	O-	ratione	Baja Medica
2448	A-	repellendus	En Recuperacion
2449	B+	quas	En Recuperacion
2450	AB-	\N	En Recuperacion
2451	AB-	quae	Optimo
2452	AB+	\N	Baja Medica
2453	B+	\N	Baja Medica
2454	AB-	laudantium	Baja Medica
2455	B+	voluptatum	Optimo
2456	A+	sequi	Optimo
2457	O-	voluptatum	En Recuperacion
2458	A-	assumenda	Herido
2459	O-	\N	Optimo
2460	A-	perspiciatis	Baja Medica
2461	AB-	est	Optimo
2462	AB-	vero	Optimo
2463	B+	in	Herido
2464	B+	\N	Baja Medica
2465	B-	\N	Herido
2466	AB-	\N	Herido
2467	A-	\N	En Recuperacion
2468	O-	\N	Herido
2469	B+	placeat	Herido
2470	B-	\N	Herido
2471	A+	temporibus	Herido
2472	AB-	\N	Herido
2473	O-	incidunt	Baja Medica
2474	AB+	hic	Baja Medica
2475	A-	\N	En Recuperacion
2476	AB-	mollitia	Herido
2477	O+	\N	Baja Medica
2478	B-	\N	Herido
2479	B+	suscipit	En Recuperacion
2480	AB+	amet	Baja Medica
2481	B-	\N	Herido
2482	AB+	\N	Optimo
2483	O+	\N	Herido
2484	B+	numquam	En Recuperacion
2485	AB+	ratione	En Recuperacion
2486	B-	\N	En Recuperacion
2487	A-	nostrum	Herido
2488	AB+	\N	Herido
2489	O-	\N	Baja Medica
2490	O-	possimus	Baja Medica
2491	O-	\N	En Recuperacion
2492	O-	placeat	En Recuperacion
2493	B-	\N	Optimo
2494	B-	quas	En Recuperacion
2495	AB-	\N	Baja Medica
2496	AB+	facere	En Recuperacion
2497	B+	facilis	En Recuperacion
2498	O-	velit	Optimo
2499	O+	sed	Herido
2500	A+	necessitatibus	Baja Medica
2501	AB+	\N	Optimo
2502	AB+	eveniet	Baja Medica
2503	O-	maiores	En Recuperacion
2504	B-	ipsa	Optimo
2505	A-	\N	Herido
2506	B-	\N	Baja Medica
2507	B-	illo	Optimo
2508	AB-	reprehenderit	En Recuperacion
2509	AB+	veniam	Optimo
2510	O+	quaerat	Herido
2511	A+	\N	Herido
2512	B+	animi	Herido
2513	A-	\N	Baja Medica
2514	A+	\N	Baja Medica
2515	AB-	\N	Baja Medica
2516	B+	\N	En Recuperacion
2517	A-	quidem	Baja Medica
2518	O-	\N	Herido
2519	A+	\N	Herido
2520	B+	\N	Optimo
2521	O+	\N	En Recuperacion
2522	A+	\N	Herido
2523	O+	\N	Optimo
2524	AB+	accusamus	Herido
2525	A-	\N	Baja Medica
2526	AB+	\N	Optimo
2527	AB+	illo	Optimo
2528	A+	\N	Optimo
2529	B+	\N	Herido
2530	B+	nam	En Recuperacion
2531	O+	\N	Optimo
2532	B-	ipsum	Optimo
2533	B-	\N	Baja Medica
2534	O-	aspernatur	En Recuperacion
2535	O+	excepturi	Baja Medica
2536	B+	\N	Baja Medica
2537	B+	deserunt	Baja Medica
2538	O-	doloremque	Herido
2539	B+	blanditiis	En Recuperacion
2540	O+	\N	Herido
2541	O+	\N	En Recuperacion
2542	A-	eos	Optimo
2543	O-	\N	Optimo
2544	B-	\N	Baja Medica
2545	AB-	\N	Optimo
2546	O+	\N	Baja Medica
2547	B-	\N	En Recuperacion
2548	AB-	\N	En Recuperacion
2549	A-	\N	En Recuperacion
2550	O-	modi	Baja Medica
2551	B+	sunt	Herido
2552	AB-	fuga	Herido
2553	B+	hic	En Recuperacion
2554	AB-	\N	Optimo
2555	B+	\N	Optimo
2556	A+	praesentium	Optimo
2557	O-	\N	En Recuperacion
2558	A-	\N	Baja Medica
2559	O+	\N	Baja Medica
2560	B+	quae	Optimo
2561	B-	sed	Baja Medica
2562	B-	\N	Herido
2563	AB-	laudantium	Herido
2564	AB+	sapiente	En Recuperacion
2565	AB+	\N	Baja Medica
2566	B+	\N	Baja Medica
2567	O-	quia	Herido
2568	O+	ratione	Optimo
2569	O+	\N	Baja Medica
2570	B-	\N	En Recuperacion
2571	B+	\N	En Recuperacion
2572	AB+	\N	Herido
2573	O-	omnis	Optimo
2574	A+	qui	Optimo
2575	B-	magnam	Optimo
2576	O+	enim	Optimo
2577	AB-	\N	Herido
2578	O-	\N	En Recuperacion
2579	O-	\N	Baja Medica
2580	A-	\N	Baja Medica
2581	B-	\N	En Recuperacion
2582	B+	vero	Herido
2583	AB+	\N	Herido
2584	B+	\N	En Recuperacion
2585	B-	\N	Herido
2586	A+	possimus	Optimo
2587	O+	veritatis	Baja Medica
2588	A-	facere	En Recuperacion
2589	A+	\N	Optimo
2590	AB+	doloremque	Herido
2591	A+	\N	Herido
2592	A-	\N	En Recuperacion
2593	O+	\N	Baja Medica
2594	A-	\N	Herido
2595	B-	\N	Optimo
2596	O-	\N	Herido
2597	AB+	\N	En Recuperacion
2598	O-	\N	En Recuperacion
2599	A+	\N	Baja Medica
2600	O-	aliquid	Optimo
2601	AB-	numquam	Herido
2602	AB-	assumenda	Baja Medica
2603	A+	\N	Herido
2604	B+	similique	Baja Medica
2605	B-	\N	Baja Medica
2606	A-	\N	Optimo
2607	A-	\N	Optimo
2608	B+	\N	Baja Medica
2609	AB-	voluptatibus	En Recuperacion
2610	O-	\N	Optimo
2611	A-	\N	En Recuperacion
2612	B-	\N	Optimo
2613	B-	quaerat	Baja Medica
2614	O-	repudiandae	Optimo
2615	A+	velit	En Recuperacion
2616	AB+	\N	Optimo
2617	A-	minus	En Recuperacion
2618	B+	neque	Baja Medica
2619	A+	quia	Herido
2620	AB+	itaque	En Recuperacion
2621	A+	beatae	Herido
2622	O-	\N	En Recuperacion
2623	B+	\N	Optimo
2624	A+	placeat	Herido
2625	AB-	sed	Herido
2626	AB-	\N	En Recuperacion
2627	B-	\N	Herido
2628	B+	\N	Baja Medica
2629	B+	\N	En Recuperacion
2630	A-	harum	En Recuperacion
2631	O+	\N	Herido
2632	AB+	\N	Optimo
2633	B-	quisquam	Optimo
2634	O-	\N	Baja Medica
2635	AB-	amet	Baja Medica
2636	A+	expedita	En Recuperacion
2637	B+	consequatur	Herido
2638	O+	soluta	Baja Medica
2639	A+	excepturi	En Recuperacion
2640	AB-	commodi	Baja Medica
2641	A-	assumenda	Herido
2642	A+	\N	En Recuperacion
2643	O+	cupiditate	Optimo
2644	AB+	\N	Baja Medica
2645	AB+	\N	Herido
2646	B-	\N	En Recuperacion
2647	O-	iusto	Baja Medica
2648	B+	\N	En Recuperacion
2649	A-	\N	Optimo
2650	A-	\N	Optimo
2651	AB+	quod	Baja Medica
2652	A-	similique	Optimo
2653	A+	\N	Optimo
2654	A+	accusantium	En Recuperacion
2655	O-	dolorem	Herido
2656	B+	doloribus	Baja Medica
2657	AB-	recusandae	Herido
2658	A+	veniam	Optimo
2659	A-	\N	En Recuperacion
2660	A-	nostrum	En Recuperacion
2661	A+	recusandae	Herido
2662	AB+	\N	En Recuperacion
2663	B+	\N	Optimo
2664	B-	unde	Baja Medica
2665	A+	\N	Herido
2666	O-	\N	Optimo
2667	AB-	\N	Baja Medica
2668	O-	\N	Optimo
2669	A-	sed	En Recuperacion
2670	O-	\N	Optimo
2671	AB-	praesentium	Herido
2672	B+	aliquid	Optimo
2673	AB-	\N	En Recuperacion
2674	B-	\N	Optimo
2675	O-	\N	Optimo
2676	B-	\N	En Recuperacion
2677	B-	\N	Baja Medica
2678	AB-	\N	Baja Medica
2679	AB+	\N	Herido
2680	O-	nobis	Herido
2681	AB-	\N	Optimo
2682	B+	\N	Optimo
2683	B-	\N	Herido
2684	AB+	porro	Herido
2685	B+	vitae	Baja Medica
2686	O-	\N	Optimo
2687	AB-	voluptate	Baja Medica
2688	AB+	\N	En Recuperacion
2689	AB+	odit	En Recuperacion
2690	B-	\N	Herido
2691	A+	\N	Herido
2692	O-	\N	En Recuperacion
2693	B-	\N	Herido
2694	O+	\N	Optimo
2695	O+	\N	En Recuperacion
2696	O-	nesciunt	En Recuperacion
2697	AB-	odit	Baja Medica
2698	AB+	\N	En Recuperacion
2699	A+	\N	Optimo
2700	A+	illo	Optimo
2701	B+	\N	Herido
2702	AB-	\N	Herido
2703	O+	\N	En Recuperacion
2704	A-	\N	Optimo
2705	O-	\N	En Recuperacion
2706	B+	\N	En Recuperacion
2707	A-	neque	En Recuperacion
2708	B+	optio	En Recuperacion
2709	AB-	soluta	En Recuperacion
2710	O-	repellat	Baja Medica
2711	O-	\N	Baja Medica
2712	O+	laudantium	Baja Medica
2713	O+	\N	Herido
2714	O-	\N	Herido
2715	O-	quidem	Optimo
2716	O-	\N	Optimo
2717	A-	\N	En Recuperacion
2718	B+	eos	En Recuperacion
2719	AB+	\N	Baja Medica
2720	O-	\N	Baja Medica
2721	O-	cumque	Herido
2722	A+	aut	Baja Medica
2723	B+	\N	Baja Medica
2724	B-	quisquam	En Recuperacion
2725	O-	illum	Baja Medica
2726	O-	\N	En Recuperacion
2727	A-	\N	Optimo
2728	A-	culpa	Herido
2729	O+	\N	Baja Medica
2730	A-	sequi	Baja Medica
2731	O+	nam	Herido
2732	AB-	incidunt	En Recuperacion
2733	B+	\N	Optimo
2734	O+	totam	Baja Medica
2735	AB-	\N	En Recuperacion
2736	B+	\N	Optimo
2737	AB+	\N	Optimo
2738	A-	\N	Herido
2739	B-	\N	Optimo
2740	B+	neque	Optimo
2741	B+	\N	Herido
2742	AB+	mollitia	Optimo
2743	AB-	ut	Optimo
2744	AB-	cum	Baja Medica
2745	A+	similique	Optimo
2746	AB-	\N	En Recuperacion
2747	O+	pariatur	Optimo
2748	A-	accusantium	Baja Medica
2749	O+	molestiae	En Recuperacion
2750	A+	\N	Herido
2751	B+	beatae	Herido
2752	A+	\N	Herido
2753	AB+	libero	Herido
2754	B-	dolorem	En Recuperacion
2755	AB-	\N	Optimo
2756	A+	\N	Optimo
2757	O+	\N	En Recuperacion
2758	AB+	maxime	Optimo
2759	AB+	maxime	Herido
2760	A+	modi	Herido
2761	A+	\N	Baja Medica
2762	O-	est	En Recuperacion
2763	AB+	\N	Baja Medica
2764	A-	\N	En Recuperacion
2765	B+	fugit	En Recuperacion
2766	B-	\N	Optimo
2767	O-	quam	En Recuperacion
2768	O+	enim	Herido
2769	O+	\N	Baja Medica
2770	B-	\N	Optimo
2771	A-	\N	Herido
2772	O+	\N	Herido
2773	B-	nulla	Optimo
2774	B-	nostrum	Herido
2775	AB+	\N	Optimo
2776	B+	\N	Optimo
2777	O-	\N	En Recuperacion
2778	AB-	\N	Herido
2779	AB-	\N	En Recuperacion
2780	O+	\N	Optimo
2781	O-	dicta	Baja Medica
2782	AB+	\N	En Recuperacion
2783	O-	\N	Optimo
2784	B-	ipsa	Optimo
2785	O+	odio	Optimo
2786	O+	ut	Optimo
2787	A-	\N	Herido
2788	A+	\N	Herido
2789	A-	\N	Optimo
2790	AB-	facere	Baja Medica
2791	B-	\N	Baja Medica
2792	A-	\N	Herido
2793	A-	modi	Baja Medica
2794	B+	\N	Baja Medica
2795	A-	\N	Baja Medica
2796	B+	eius	Optimo
2797	B-	\N	En Recuperacion
2798	B+	placeat	Baja Medica
2799	A-	cumque	Optimo
2800	B-	tempora	Optimo
2801	A-	\N	Herido
2802	O-	consequatur	Herido
2803	B-	\N	En Recuperacion
2804	O+	necessitatibus	Optimo
2805	A-	sint	En Recuperacion
2806	B-	aliquid	En Recuperacion
2807	A+	ea	En Recuperacion
2808	A-	dignissimos	Optimo
2809	B-	error	Baja Medica
2810	B-	accusantium	Herido
2811	B-	quibusdam	Herido
2812	A-	\N	Herido
2813	O-	\N	Optimo
2814	B+	beatae	En Recuperacion
2815	A-	quasi	Herido
2816	O+	velit	Herido
2817	O+	doloribus	Herido
2818	AB+	quaerat	Herido
2819	A-	\N	Optimo
2820	O-	maiores	En Recuperacion
2821	A-	pariatur	Herido
2822	AB+	\N	Optimo
2823	O+	\N	En Recuperacion
2824	AB-	\N	Baja Medica
2825	O+	sapiente	En Recuperacion
2826	B+	\N	Optimo
2827	O-	nemo	Herido
2828	A-	corporis	Baja Medica
2829	O-	pariatur	Herido
2830	B-	ut	En Recuperacion
2831	A-	\N	Optimo
2832	A+	unde	Baja Medica
2833	O+	ab	Herido
2834	AB-	laboriosam	Herido
2835	AB-	necessitatibus	Baja Medica
2836	AB-	rem	Herido
2837	A-	est	Optimo
2838	A+	\N	Herido
2839	B-	\N	En Recuperacion
2840	O-	quod	Herido
2841	AB+	\N	En Recuperacion
2842	A-	\N	Herido
2843	B+	dolores	Optimo
2844	O-	eos	Baja Medica
2845	B-	\N	En Recuperacion
2846	AB+	\N	Herido
2847	O-	\N	Baja Medica
2848	AB+	natus	Herido
2849	B-	excepturi	Baja Medica
2850	O+	labore	Baja Medica
2851	A+	\N	Baja Medica
2852	A-	\N	Baja Medica
2853	AB+	vitae	Herido
2854	AB-	\N	Herido
2855	B-	\N	En Recuperacion
2856	AB-	explicabo	Herido
2857	B+	\N	Herido
2858	AB-	alias	Baja Medica
2859	O-	laboriosam	En Recuperacion
2860	O-	id	En Recuperacion
2861	AB+	eaque	Optimo
2862	AB-	voluptas	Optimo
2863	A-	\N	Herido
2864	AB-	voluptatum	Herido
2865	O-	\N	Herido
2866	O+	\N	Herido
2867	B-	\N	Optimo
2868	A-	voluptatem	Baja Medica
2869	A+	quae	En Recuperacion
2870	O+	non	Baja Medica
2871	AB-	\N	Baja Medica
2872	AB-	\N	En Recuperacion
2873	B+	\N	Baja Medica
2874	AB-	odit	Optimo
2875	A-	\N	En Recuperacion
2876	B+	\N	Optimo
2877	A+	\N	Optimo
2878	A-	exercitationem	Optimo
2879	A-	molestias	Baja Medica
2880	B+	beatae	En Recuperacion
2881	B+	\N	En Recuperacion
2882	B+	ad	En Recuperacion
2883	AB-	dolore	Optimo
2884	A-	\N	Herido
2885	O+	officia	Herido
2886	A-	unde	En Recuperacion
2887	AB-	\N	Herido
2888	B-	\N	Optimo
2889	B-	\N	Optimo
2890	A+	laudantium	Baja Medica
2891	AB-	rerum	Herido
2892	AB+	\N	En Recuperacion
2893	O+	\N	Optimo
2894	B+	\N	Herido
2895	AB+	doloremque	Optimo
2896	AB-	\N	En Recuperacion
2897	A-	voluptate	Baja Medica
2898	AB-	beatae	Herido
2899	AB-	\N	Baja Medica
2900	O-	\N	En Recuperacion
2901	A-	autem	Herido
2902	A-	reiciendis	En Recuperacion
2903	A-	\N	Baja Medica
2904	O-	non	Optimo
2905	AB+	architecto	Optimo
2906	O+	\N	Baja Medica
2907	B-	fugiat	Baja Medica
2908	B-	\N	Baja Medica
2909	AB+	delectus	En Recuperacion
2910	B-	\N	Optimo
2911	A+	repellat	Optimo
2912	O+	optio	Herido
2913	AB+	magni	Optimo
2914	B+	officia	En Recuperacion
2915	AB-	libero	En Recuperacion
2916	B-	\N	En Recuperacion
2917	O-	praesentium	Baja Medica
2918	B-	\N	En Recuperacion
2919	O-	\N	Herido
2920	O+	velit	Optimo
2921	O+	corporis	Baja Medica
2922	A+	\N	Optimo
2923	O-	quia	En Recuperacion
2924	AB+	\N	En Recuperacion
2925	AB-	\N	Optimo
2926	B+	\N	Baja Medica
2927	B-	\N	Optimo
2928	A-	in	Herido
2929	B-	\N	Baja Medica
2930	A-	\N	Herido
2931	A-	\N	Optimo
2932	A-	minima	Herido
2933	AB-	\N	Herido
2934	A-	accusantium	En Recuperacion
2935	A-	\N	En Recuperacion
2936	A-	\N	Herido
2937	A-	\N	Optimo
2938	O-	sequi	Optimo
2939	A-	\N	En Recuperacion
2940	B+	\N	Herido
2941	A+	\N	En Recuperacion
2942	B-	\N	Optimo
2943	A-	fuga	Baja Medica
2944	A-	\N	En Recuperacion
2945	B-	\N	En Recuperacion
2946	A+	\N	Baja Medica
2947	AB+	\N	Baja Medica
2948	O+	\N	Herido
2949	O+	\N	Herido
2950	A+	\N	En Recuperacion
2951	B-	\N	Baja Medica
2952	O+	\N	Baja Medica
2953	O-	consequatur	Herido
2954	O+	\N	Baja Medica
2955	O-	quasi	Baja Medica
2956	O+	laborum	Baja Medica
2957	O+	\N	Baja Medica
2958	O+	\N	Herido
2959	AB+	libero	En Recuperacion
2960	O-	unde	En Recuperacion
2961	A-	\N	En Recuperacion
2962	AB+	\N	En Recuperacion
2963	A+	excepturi	Herido
2964	B-	occaecati	Optimo
2965	AB+	\N	Baja Medica
2966	AB+	quidem	Herido
2967	B-	reiciendis	En Recuperacion
2968	O-	nostrum	Baja Medica
2969	O-	autem	En Recuperacion
2970	O+	qui	Baja Medica
2971	B-	\N	Optimo
2972	B+	necessitatibus	Optimo
2973	O+	animi	En Recuperacion
2974	AB+	omnis	Optimo
2975	O-	vel	En Recuperacion
2976	AB-	quod	Optimo
2977	B-	\N	En Recuperacion
2978	B+	eligendi	En Recuperacion
2979	O+	nesciunt	En Recuperacion
2980	B+	sequi	Herido
2981	B-	hic	Optimo
2982	AB+	\N	Baja Medica
2983	A+	\N	Baja Medica
2984	B+	\N	Baja Medica
2985	AB+	magni	Herido
2986	AB+	\N	Optimo
2987	O-	\N	En Recuperacion
2988	B+	\N	Baja Medica
2989	AB-	inventore	Optimo
2990	AB+	\N	Optimo
2991	A-	corrupti	En Recuperacion
2992	B+	\N	Baja Medica
2993	B+	ab	Baja Medica
2994	B+	et	Optimo
2995	B+	\N	Optimo
2996	AB-	consequuntur	En Recuperacion
2997	AB+	harum	Optimo
2998	O+	fuga	En Recuperacion
2999	B+	\N	En Recuperacion
3000	A-	\N	Optimo
\.


--
-- Data for Name: mision; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mision (id_mision, nombre_mision, fecha_inicio, estado_mision) FROM stdin;
1	Operacion Iure	2025-11-28	En Progreso
2	Operacion Fugiat	2026-05-31	Abortada
3	Operacion Veniam	2025-02-15	Abortada
4	Operacion Maiores	2025-08-28	Abortada
5	Operacion Sunt	2026-06-22	Completada
6	Operacion Temporibus	2027-05-12	Completada
7	Operacion Facilis	2025-08-11	Completada
8	Operacion Repudiandae	2025-02-05	Planificacion
9	Operacion Suscipit	2025-12-22	Abortada
10	Operacion Quaerat	2026-02-19	Planificacion
11	Operacion Modi	2025-09-24	Planificacion
12	Operacion Vel	2025-12-02	En Progreso
13	Operacion Ipsum	2026-06-08	Planificacion
14	Operacion Ipsam	2026-03-02	Planificacion
15	Operacion Rerum	2027-04-07	En Progreso
16	Operacion Accusantium	2025-06-29	En Progreso
17	Operacion Animi	2026-07-28	Planificacion
18	Operacion Tempora	2027-06-19	Completada
19	Operacion Quisquam	2024-12-30	Completada
20	Operacion Atque	2027-03-06	Abortada
21	Operacion Nam	2027-09-16	Planificacion
22	Operacion Reiciendis	2025-04-29	En Progreso
23	Operacion Dignissimos	2026-07-30	Planificacion
24	Operacion Fuga	2025-03-03	Planificacion
25	Operacion Repellendus	2026-11-05	Planificacion
26	Operacion Voluptatibus	2026-09-16	En Progreso
27	Operacion Voluptatum	2026-12-09	Completada
28	Operacion Accusamus	2025-09-04	Planificacion
29	Operacion Ipsam	2026-04-15	En Progreso
30	Operacion Tempore	2025-09-24	En Progreso
31	Operacion Dignissimos	2027-02-04	Completada
32	Operacion Deserunt	2025-11-12	Completada
33	Operacion Quasi	2027-03-24	En Progreso
34	Operacion Occaecati	2025-02-08	Planificacion
35	Operacion Natus	2026-07-21	En Progreso
36	Operacion Asperiores	2024-12-06	Abortada
37	Operacion Occaecati	2027-04-29	Completada
38	Operacion Nulla	2025-09-15	Abortada
39	Operacion Porro	2027-07-23	En Progreso
40	Operacion Provident	2026-06-30	Abortada
41	Operacion Praesentium	2025-09-24	Completada
42	Operacion Ducimus	2025-05-11	Planificacion
43	Operacion Officiis	2025-05-03	En Progreso
44	Operacion Eaque	2027-07-04	En Progreso
45	Operacion Ducimus	2025-04-09	En Progreso
46	Operacion Omnis	2024-12-19	Planificacion
47	Operacion Earum	2025-09-23	En Progreso
48	Operacion Aperiam	2026-03-15	Planificacion
49	Operacion Pariatur	2024-12-23	Completada
50	Operacion Fugiat	2026-12-06	Planificacion
51	Operacion Sed	2025-04-22	Completada
52	Operacion Dolores	2025-07-28	En Progreso
53	Operacion Qui	2026-03-13	Abortada
54	Operacion Aspernatur	2027-06-11	Abortada
55	Operacion Ducimus	2024-12-17	En Progreso
56	Operacion Recusandae	2027-06-02	Completada
57	Operacion Soluta	2025-05-02	Completada
58	Operacion Quos	2026-05-14	Abortada
59	Operacion Provident	2026-01-05	Planificacion
60	Operacion Libero	2027-09-17	Planificacion
61	Operacion Iure	2025-04-17	En Progreso
62	Operacion Distinctio	2024-11-24	Abortada
63	Operacion Fugit	2027-08-19	Planificacion
64	Operacion Iste	2025-10-20	En Progreso
65	Operacion Nemo	2025-09-18	Planificacion
66	Operacion Expedita	2026-05-23	Planificacion
67	Operacion Corrupti	2027-09-21	En Progreso
68	Operacion Dolorum	2027-07-21	En Progreso
69	Operacion Nihil	2025-08-27	Planificacion
70	Operacion Ducimus	2024-11-21	Completada
71	Operacion Sunt	2026-09-14	Completada
72	Operacion Corporis	2024-12-07	En Progreso
73	Operacion Numquam	2025-08-24	Completada
74	Operacion Recusandae	2025-07-17	Completada
75	Operacion Consectetur	2026-11-13	Abortada
76	Operacion Ducimus	2027-08-08	Abortada
77	Operacion Rerum	2026-05-20	En Progreso
78	Operacion Tempora	2027-05-12	En Progreso
79	Operacion Dicta	2025-05-05	Abortada
80	Operacion Debitis	2026-12-25	Abortada
81	Operacion Pariatur	2026-03-20	Completada
82	Operacion Culpa	2026-01-19	En Progreso
83	Operacion Id	2027-01-31	Completada
84	Operacion Neque	2026-03-07	Planificacion
85	Operacion Voluptatum	2025-03-26	Planificacion
86	Operacion Impedit	2025-03-11	Planificacion
87	Operacion Nesciunt	2025-06-15	Completada
88	Operacion Iure	2025-01-01	Completada
89	Operacion Sapiente	2025-03-19	En Progreso
90	Operacion Et	2027-02-05	Abortada
91	Operacion Suscipit	2026-12-23	Completada
92	Operacion Hic	2026-12-11	Completada
93	Operacion Nisi	2026-02-03	Completada
94	Operacion Cum	2026-04-23	Completada
95	Operacion Mollitia	2026-07-17	Planificacion
96	Operacion Nostrum	2027-08-05	Completada
97	Operacion Accusamus	2026-04-23	Completada
98	Operacion Doloribus	2024-10-02	Planificacion
99	Operacion Hic	2026-02-06	Abortada
100	Operacion Pariatur	2025-06-25	Completada
101	Operacion Eius	2026-07-26	Planificacion
102	Operacion Deleniti	2027-04-25	En Progreso
103	Operacion Consequatur	2026-05-25	Planificacion
104	Operacion Molestiae	2025-07-29	Abortada
105	Operacion Culpa	2024-10-21	Planificacion
106	Operacion Ipsa	2025-01-15	En Progreso
107	Operacion Voluptatum	2025-08-11	Planificacion
108	Operacion Repellat	2025-08-13	En Progreso
109	Operacion Nemo	2026-01-29	Completada
110	Operacion Explicabo	2025-02-08	Completada
111	Operacion Voluptate	2026-11-05	En Progreso
112	Operacion Dolore	2027-03-22	En Progreso
113	Operacion Laborum	2027-09-27	Planificacion
114	Operacion Pariatur	2026-08-30	En Progreso
115	Operacion Quaerat	2026-02-22	Completada
116	Operacion Eaque	2027-02-13	Completada
117	Operacion Culpa	2025-02-10	Planificacion
118	Operacion Molestiae	2025-02-05	Planificacion
119	Operacion Facilis	2026-07-06	Abortada
120	Operacion Nam	2025-07-04	Planificacion
121	Operacion Perferendis	2027-01-30	En Progreso
122	Operacion Totam	2025-05-09	Abortada
123	Operacion Quam	2025-06-30	Planificacion
124	Operacion Ab	2026-12-16	Completada
125	Operacion Quod	2027-01-29	Planificacion
126	Operacion Amet	2026-06-02	Planificacion
127	Operacion Recusandae	2027-08-23	Completada
128	Operacion Labore	2025-02-11	Completada
129	Operacion Quisquam	2026-03-28	Completada
130	Operacion Assumenda	2026-04-18	Completada
131	Operacion Neque	2024-10-25	En Progreso
132	Operacion Delectus	2025-03-06	Completada
133	Operacion Deserunt	2024-12-07	Abortada
134	Operacion Fugiat	2025-02-06	Abortada
135	Operacion Officia	2025-05-18	Abortada
136	Operacion Exercitationem	2027-05-23	Planificacion
137	Operacion Recusandae	2025-07-18	Completada
138	Operacion Voluptatibus	2024-10-25	Abortada
139	Operacion Unde	2026-10-09	Planificacion
140	Operacion Laborum	2027-05-02	Abortada
141	Operacion Sapiente	2025-12-22	En Progreso
142	Operacion Voluptas	2027-09-18	Planificacion
143	Operacion Praesentium	2027-07-10	En Progreso
144	Operacion Sit	2025-05-19	Planificacion
145	Operacion Quaerat	2026-04-11	Abortada
146	Operacion Eligendi	2025-11-23	En Progreso
147	Operacion Id	2025-02-11	En Progreso
148	Operacion Similique	2027-02-01	Planificacion
149	Operacion Quo	2027-03-25	Abortada
150	Operacion Harum	2026-01-31	En Progreso
151	Operacion Debitis	2025-11-29	Abortada
152	Operacion Sint	2024-12-09	Planificacion
153	Operacion Earum	2025-07-16	Completada
154	Operacion Aperiam	2024-09-27	Abortada
155	Operacion Corporis	2025-03-09	Completada
156	Operacion Voluptatibus	2025-01-01	Planificacion
157	Operacion Quia	2027-07-09	Planificacion
158	Operacion Sequi	2024-10-26	Planificacion
159	Operacion Voluptate	2027-09-15	Planificacion
160	Operacion Dolorem	2025-02-22	Planificacion
161	Operacion Labore	2026-03-20	En Progreso
162	Operacion Ipsam	2026-11-24	En Progreso
163	Operacion Dolorum	2025-03-03	Planificacion
164	Operacion Error	2025-05-13	Abortada
165	Operacion Ea	2025-11-06	Planificacion
166	Operacion Atque	2027-04-01	Completada
167	Operacion Esse	2026-01-12	Completada
168	Operacion Architecto	2026-09-01	Abortada
169	Operacion Laboriosam	2025-07-04	Planificacion
170	Operacion Voluptatibus	2025-12-20	En Progreso
171	Operacion Doloremque	2027-07-15	Completada
172	Operacion Dolore	2027-04-20	Completada
173	Operacion Culpa	2025-02-04	Planificacion
174	Operacion Sequi	2026-10-25	En Progreso
175	Operacion Laudantium	2025-06-11	Abortada
176	Operacion Qui	2026-12-14	Abortada
177	Operacion Eveniet	2026-04-03	Abortada
178	Operacion Doloremque	2026-09-15	Planificacion
179	Operacion Commodi	2027-07-19	Completada
180	Operacion Velit	2027-07-15	Abortada
181	Operacion Consequuntur	2025-09-15	Completada
182	Operacion Blanditiis	2026-07-05	Abortada
183	Operacion Molestias	2025-04-17	Abortada
184	Operacion Sequi	2025-06-03	Abortada
185	Operacion Illo	2024-10-25	Abortada
186	Operacion Saepe	2026-03-18	Abortada
187	Operacion Explicabo	2026-05-11	Abortada
188	Operacion Magnam	2024-11-25	Planificacion
189	Operacion Sed	2027-08-27	En Progreso
190	Operacion Quas	2025-05-30	En Progreso
191	Operacion Iste	2026-07-03	En Progreso
192	Operacion Recusandae	2025-08-30	En Progreso
193	Operacion Facere	2027-06-03	Planificacion
194	Operacion A	2026-08-15	Planificacion
195	Operacion Impedit	2025-05-02	En Progreso
196	Operacion Minima	2026-07-31	Abortada
197	Operacion Enim	2026-01-01	En Progreso
198	Operacion Fuga	2025-01-29	Planificacion
199	Operacion Quibusdam	2025-12-16	Completada
200	Operacion Officia	2024-12-19	Planificacion
201	Operacion Molestias	2025-09-30	Completada
202	Operacion A	2026-04-05	Completada
203	Operacion Consectetur	2026-12-12	Completada
204	Operacion Aspernatur	2025-07-20	En Progreso
205	Operacion Sunt	2027-05-18	Completada
206	Operacion Vero	2027-01-03	En Progreso
207	Operacion Voluptatum	2025-03-10	Completada
208	Operacion Enim	2024-10-10	Abortada
209	Operacion Quas	2027-02-07	En Progreso
210	Operacion Dolor	2027-04-20	Abortada
211	Operacion Sunt	2026-08-05	Completada
212	Operacion Cumque	2025-10-17	Completada
213	Operacion Expedita	2026-10-28	Planificacion
214	Operacion Mollitia	2026-02-09	Planificacion
215	Operacion Blanditiis	2027-08-09	En Progreso
216	Operacion Inventore	2027-06-11	Planificacion
217	Operacion Perspiciatis	2027-03-15	En Progreso
218	Operacion Cum	2025-05-07	Planificacion
219	Operacion Voluptatem	2026-02-11	Abortada
220	Operacion Laborum	2025-12-25	Completada
221	Operacion Dolores	2027-04-23	En Progreso
222	Operacion Ad	2026-10-07	En Progreso
223	Operacion Facere	2027-01-04	Abortada
224	Operacion Veritatis	2026-11-21	Planificacion
225	Operacion Tempora	2025-07-23	Abortada
226	Operacion Laborum	2025-07-28	En Progreso
227	Operacion Voluptatum	2026-04-08	En Progreso
228	Operacion Mollitia	2026-01-08	Abortada
229	Operacion Omnis	2027-03-18	En Progreso
230	Operacion Fugiat	2026-11-15	Planificacion
231	Operacion Nemo	2026-01-20	Planificacion
232	Operacion Dolorum	2026-06-07	Completada
233	Operacion Velit	2026-05-11	Abortada
234	Operacion A	2025-06-11	Planificacion
235	Operacion Perspiciatis	2027-08-26	En Progreso
236	Operacion Voluptates	2025-02-03	Completada
237	Operacion Delectus	2026-11-08	Abortada
238	Operacion Iste	2025-05-07	Abortada
239	Operacion Omnis	2025-04-09	Completada
240	Operacion Maxime	2025-09-23	Abortada
241	Operacion Distinctio	2026-01-24	En Progreso
242	Operacion Possimus	2027-08-14	Completada
243	Operacion Totam	2025-03-18	En Progreso
244	Operacion Molestias	2024-11-01	En Progreso
245	Operacion Eos	2026-04-02	Planificacion
246	Operacion Accusamus	2027-03-31	Planificacion
247	Operacion Consectetur	2026-01-08	Planificacion
248	Operacion Temporibus	2026-09-01	En Progreso
249	Operacion Accusantium	2026-10-24	En Progreso
250	Operacion Fuga	2024-10-08	En Progreso
251	Operacion Eum	2026-01-20	Completada
252	Operacion Alias	2026-12-06	Planificacion
253	Operacion Aspernatur	2027-05-18	Planificacion
254	Operacion Sequi	2027-02-19	Abortada
255	Operacion Consectetur	2025-05-31	Completada
256	Operacion Soluta	2025-05-09	En Progreso
257	Operacion Error	2027-01-04	Completada
258	Operacion Animi	2025-11-23	En Progreso
259	Operacion Mollitia	2026-10-23	En Progreso
260	Operacion Quos	2026-09-28	Abortada
261	Operacion Nesciunt	2026-11-29	Planificacion
262	Operacion Quae	2026-09-07	Planificacion
263	Operacion Reprehenderit	2025-08-17	Planificacion
264	Operacion Atque	2025-08-25	Planificacion
265	Operacion Corporis	2026-12-06	Abortada
266	Operacion Debitis	2026-05-31	Completada
267	Operacion Officia	2026-12-15	Completada
268	Operacion Illo	2025-05-30	Planificacion
269	Operacion Accusantium	2025-05-08	Completada
270	Operacion Eos	2027-07-26	Planificacion
271	Operacion Quos	2025-10-17	Abortada
272	Operacion Est	2025-04-24	Abortada
273	Operacion Earum	2027-01-07	Planificacion
274	Operacion Quaerat	2025-04-30	Abortada
275	Operacion Harum	2025-07-16	Abortada
276	Operacion Rerum	2026-01-25	Planificacion
277	Operacion Ut	2027-01-16	Abortada
278	Operacion Commodi	2026-05-01	Planificacion
279	Operacion Laborum	2025-09-12	Completada
280	Operacion Iusto	2026-09-12	Planificacion
281	Operacion Quasi	2026-02-15	En Progreso
282	Operacion Ullam	2026-12-02	Completada
283	Operacion Enim	2026-10-01	Completada
284	Operacion Maxime	2024-12-22	Completada
285	Operacion Laudantium	2027-02-27	Completada
286	Operacion Vel	2026-10-01	En Progreso
287	Operacion A	2025-07-02	En Progreso
288	Operacion Asperiores	2027-03-26	Abortada
289	Operacion Hic	2025-09-09	En Progreso
290	Operacion Ducimus	2025-12-03	Planificacion
291	Operacion Labore	2025-06-13	Planificacion
292	Operacion Dolor	2027-06-11	En Progreso
293	Operacion Dignissimos	2026-11-18	Completada
294	Operacion Cum	2025-03-29	Abortada
295	Operacion Laboriosam	2024-10-22	Abortada
296	Operacion Cupiditate	2026-11-20	En Progreso
297	Operacion Odit	2025-01-16	Planificacion
298	Operacion Ut	2027-04-01	Completada
299	Operacion Nam	2026-03-12	Planificacion
300	Operacion Ipsa	2025-07-02	Planificacion
301	Operacion Porro	2025-07-13	Planificacion
302	Operacion Iure	2027-01-23	En Progreso
303	Operacion Placeat	2027-09-26	En Progreso
304	Operacion Magni	2027-02-04	Planificacion
305	Operacion Et	2026-05-06	Abortada
306	Operacion Corporis	2027-01-02	Planificacion
307	Operacion Vero	2025-11-14	En Progreso
308	Operacion Animi	2027-06-18	En Progreso
309	Operacion Officia	2027-09-19	Completada
310	Operacion Voluptatum	2027-03-08	En Progreso
311	Operacion Corrupti	2027-09-02	Planificacion
312	Operacion Iste	2026-11-17	En Progreso
313	Operacion Officia	2026-09-02	Planificacion
314	Operacion Nam	2026-08-27	En Progreso
315	Operacion Quaerat	2026-12-19	En Progreso
316	Operacion Voluptatem	2026-05-25	Completada
317	Operacion Officia	2025-03-01	En Progreso
318	Operacion Distinctio	2026-08-07	Completada
319	Operacion Non	2027-08-20	Completada
320	Operacion Omnis	2026-02-17	Abortada
321	Operacion Laboriosam	2025-08-27	En Progreso
322	Operacion Porro	2026-01-21	Abortada
323	Operacion Labore	2025-09-05	Planificacion
324	Operacion Deserunt	2025-12-25	Planificacion
325	Operacion Ab	2026-08-16	Abortada
326	Operacion Accusantium	2024-10-22	En Progreso
327	Operacion Vitae	2026-09-04	Abortada
328	Operacion Necessitatibus	2026-12-17	En Progreso
329	Operacion Fuga	2025-02-08	Planificacion
330	Operacion Velit	2025-08-24	Completada
331	Operacion Quam	2026-04-25	Completada
332	Operacion At	2025-09-17	Abortada
333	Operacion Magni	2025-11-28	Planificacion
334	Operacion Quos	2024-10-01	En Progreso
335	Operacion Nesciunt	2025-07-04	Completada
336	Operacion Id	2026-11-07	Abortada
337	Operacion Perferendis	2024-10-31	Planificacion
338	Operacion Culpa	2026-10-04	Abortada
339	Operacion Laborum	2027-03-05	Completada
340	Operacion Cupiditate	2025-06-13	Abortada
341	Operacion Dicta	2027-08-27	Completada
342	Operacion Et	2026-11-21	Abortada
343	Operacion Deserunt	2027-02-23	En Progreso
344	Operacion Quam	2027-03-23	Abortada
345	Operacion Blanditiis	2027-05-06	Completada
346	Operacion Magni	2026-10-20	Abortada
347	Operacion Quod	2027-04-26	Abortada
348	Operacion Architecto	2026-08-10	Planificacion
349	Operacion Harum	2025-02-15	Completada
350	Operacion Dolores	2026-10-26	En Progreso
351	Operacion Illo	2025-04-12	Abortada
352	Operacion Quos	2025-04-29	Abortada
353	Operacion Sunt	2025-04-16	En Progreso
354	Operacion Nihil	2027-06-18	En Progreso
355	Operacion Magni	2026-10-02	Completada
356	Operacion Nesciunt	2027-05-27	En Progreso
357	Operacion Veniam	2025-03-09	En Progreso
358	Operacion Ipsam	2027-03-19	Abortada
359	Operacion Corrupti	2027-04-14	Planificacion
360	Operacion Provident	2026-07-05	Planificacion
361	Operacion Veniam	2027-01-23	Planificacion
362	Operacion Perferendis	2025-05-08	Planificacion
363	Operacion Aliquam	2025-01-31	En Progreso
364	Operacion Voluptates	2025-02-14	Abortada
365	Operacion Ut	2025-09-26	Completada
366	Operacion Inventore	2025-05-25	Abortada
367	Operacion Iste	2027-08-26	Completada
368	Operacion Modi	2026-06-30	Abortada
369	Operacion Nobis	2026-06-06	Planificacion
370	Operacion Aut	2025-02-12	Completada
371	Operacion Culpa	2024-10-17	Abortada
372	Operacion Et	2027-05-09	Abortada
373	Operacion Placeat	2025-01-22	Abortada
374	Operacion Iste	2027-03-06	Abortada
375	Operacion Amet	2025-05-25	En Progreso
376	Operacion Deserunt	2025-05-17	Abortada
377	Operacion Velit	2026-06-25	En Progreso
378	Operacion Libero	2027-02-02	Abortada
379	Operacion Consequuntur	2026-07-13	En Progreso
380	Operacion Corrupti	2025-03-08	En Progreso
381	Operacion Repellendus	2027-05-26	Abortada
382	Operacion Soluta	2027-05-08	En Progreso
383	Operacion Tenetur	2026-12-04	Planificacion
384	Operacion Possimus	2027-06-08	Completada
385	Operacion Neque	2025-09-22	Abortada
386	Operacion Earum	2026-12-16	En Progreso
387	Operacion Nobis	2026-07-25	Abortada
388	Operacion Animi	2026-09-12	Completada
389	Operacion Similique	2026-03-28	Completada
390	Operacion Recusandae	2027-08-08	Abortada
391	Operacion Accusantium	2025-10-07	Abortada
392	Operacion Eveniet	2025-11-23	Abortada
393	Operacion Debitis	2027-01-31	Completada
394	Operacion Voluptatum	2025-03-11	Abortada
395	Operacion Quam	2024-12-13	Planificacion
396	Operacion Exercitationem	2025-03-10	En Progreso
397	Operacion Eius	2027-05-12	Planificacion
398	Operacion Et	2025-04-19	Completada
399	Operacion Qui	2025-05-01	Planificacion
400	Operacion Ipsa	2025-01-11	Completada
401	Operacion At	2024-11-14	En Progreso
402	Operacion Praesentium	2025-01-14	Planificacion
403	Operacion Dolore	2026-03-20	En Progreso
404	Operacion Cum	2025-01-22	Abortada
405	Operacion Repellendus	2025-02-13	En Progreso
406	Operacion Perferendis	2026-08-10	En Progreso
407	Operacion Ea	2025-09-28	Planificacion
408	Operacion Magnam	2025-01-11	Abortada
409	Operacion Cupiditate	2027-01-02	Planificacion
410	Operacion Beatae	2026-05-14	Planificacion
411	Operacion Quod	2026-05-15	Planificacion
412	Operacion Quo	2025-12-11	Planificacion
413	Operacion Deleniti	2026-11-11	Completada
414	Operacion Porro	2025-03-23	Planificacion
415	Operacion Accusamus	2026-01-15	Completada
416	Operacion Pariatur	2026-06-28	Completada
417	Operacion Saepe	2025-01-15	Abortada
418	Operacion Neque	2025-04-11	Planificacion
419	Operacion Quia	2025-07-24	Abortada
420	Operacion Quisquam	2025-02-22	En Progreso
421	Operacion Eaque	2026-05-24	En Progreso
422	Operacion Atque	2026-11-07	Planificacion
423	Operacion Autem	2027-07-02	Abortada
424	Operacion Aliquam	2027-04-10	Abortada
425	Operacion Qui	2026-10-02	En Progreso
426	Operacion Rem	2027-06-26	En Progreso
427	Operacion Tenetur	2026-03-26	Completada
428	Operacion Deserunt	2025-08-21	Planificacion
429	Operacion Eaque	2027-06-30	Abortada
430	Operacion Quisquam	2027-09-11	Abortada
431	Operacion Perspiciatis	2026-04-01	Abortada
432	Operacion Praesentium	2025-12-12	Completada
433	Operacion Ducimus	2026-10-27	Planificacion
434	Operacion Rem	2026-06-15	Planificacion
435	Operacion Iste	2026-05-21	Planificacion
436	Operacion Voluptates	2024-10-05	Completada
437	Operacion Consectetur	2026-04-07	En Progreso
438	Operacion Eius	2027-09-22	Planificacion
439	Operacion Ducimus	2025-11-29	Abortada
440	Operacion Laudantium	2027-05-12	Completada
441	Operacion Maxime	2027-06-01	Planificacion
442	Operacion Fugiat	2027-08-06	Abortada
443	Operacion Velit	2027-03-24	En Progreso
444	Operacion Reprehenderit	2025-12-20	Planificacion
446	Operacion Quidem	2026-10-19	En Progreso
447	Operacion Impedit	2027-07-18	Abortada
448	Operacion Ducimus	2027-07-03	Abortada
449	Operacion Nostrum	2027-05-31	Abortada
450	Operacion Aspernatur	2024-10-11	Abortada
451	Operacion Necessitatibus	2027-06-18	Planificacion
452	Operacion Omnis	2026-09-15	En Progreso
453	Operacion Est	2026-05-06	Abortada
454	Operacion Necessitatibus	2026-09-14	En Progreso
455	Operacion Illo	2025-06-25	En Progreso
456	Operacion Veritatis	2026-01-26	Planificacion
457	Operacion Vero	2026-04-05	Planificacion
458	Operacion Rem	2027-03-14	Abortada
459	Operacion Ullam	2026-01-16	Abortada
460	Operacion Consectetur	2027-09-27	Completada
461	Operacion Aliquid	2024-12-13	Abortada
462	Operacion Deserunt	2025-05-31	Completada
463	Operacion Velit	2026-06-08	En Progreso
464	Operacion Iusto	2025-03-26	Planificacion
465	Operacion Numquam	2027-03-01	Abortada
466	Operacion Amet	2026-05-09	En Progreso
467	Operacion Placeat	2026-08-26	En Progreso
468	Operacion Consequuntur	2025-04-15	Planificacion
469	Operacion Fuga	2024-10-17	Planificacion
470	Operacion Placeat	2025-07-17	Completada
471	Operacion Nam	2027-08-20	Completada
472	Operacion Libero	2025-04-04	Abortada
473	Operacion Repudiandae	2025-10-26	Abortada
474	Operacion Hic	2025-09-18	Planificacion
475	Operacion Totam	2026-12-25	Completada
476	Operacion Eius	2027-02-14	En Progreso
477	Operacion Quibusdam	2025-07-28	Planificacion
478	Operacion Similique	2025-09-16	En Progreso
479	Operacion Laudantium	2024-10-25	En Progreso
480	Operacion Eaque	2027-04-18	Planificacion
481	Operacion Pariatur	2026-11-07	Planificacion
482	Operacion Nesciunt	2027-06-08	Planificacion
483	Operacion Voluptatibus	2027-08-11	Completada
484	Operacion Officiis	2025-07-12	En Progreso
485	Operacion Distinctio	2026-05-24	En Progreso
486	Operacion Fugit	2027-01-27	Abortada
487	Operacion Quasi	2025-01-16	Abortada
488	Operacion Deserunt	2026-01-18	En Progreso
489	Operacion Fuga	2026-01-01	Abortada
490	Operacion Ut	2026-04-27	Abortada
491	Operacion Laudantium	2024-11-05	Completada
492	Operacion Commodi	2026-06-12	Completada
493	Operacion Earum	2026-05-01	Abortada
494	Operacion Est	2025-12-23	Completada
495	Operacion Mollitia	2024-11-03	En Progreso
496	Operacion Asperiores	2025-06-18	Completada
497	Operacion Asperiores	2026-11-30	Abortada
498	Operacion Dignissimos	2027-09-19	Planificacion
499	Operacion Tempore	2026-07-06	En Progreso
500	Operacion Consequatur	2026-04-04	Completada
\.


--
-- Data for Name: municion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.municion (id_municion, cantidad_disponible, fecha_vencimiento, lote, id_calibre, id_base) FROM stdin;
1	3446	2034-01-27	LT-7506	19	49
2	8103	2032-06-13	LT-1509	18	40
3	797	2035-12-15	LT-1034	28	24
4	8877	2036-04-23	LT-7247	1	40
5	9913	2029-10-29	LT-1850	10	46
6	1458	2033-06-10	LT-1601	16	30
7	2176	2033-06-03	LT-7409	10	23
8	1358	2027-12-20	LT-1959	24	12
9	5915	2028-08-04	LT-3131	25	28
10	2835	2028-07-07	LT-1890	9	40
11	6523	2031-04-04	LT-6377	30	28
12	9056	2031-11-04	LT-7960	1	38
13	8071	2032-06-03	LT-7612	1	10
14	8429	2031-01-16	LT-5709	29	43
15	6269	2033-02-16	LT-4900	24	3
16	9883	2027-08-31	LT-3704	1	25
17	4828	2034-11-01	LT-9079	22	43
18	7538	2028-05-21	LT-8636	11	47
19	2948	2036-02-03	LT-5578	18	32
20	6953	2034-03-03	LT-0764	17	45
21	7825	2029-11-17	LT-9449	30	28
22	9475	2033-08-09	LT-0426	1	31
23	6297	2027-01-16	LT-8122	2	33
24	1709	2031-08-25	LT-3124	20	26
25	7467	2035-01-20	LT-5286	27	36
26	575	2028-05-13	LT-7386	10	8
27	4926	2034-05-19	LT-1501	23	19
28	8307	2034-10-19	LT-4354	20	47
29	2234	2035-12-09	LT-6329	28	2
30	4884	2029-11-28	LT-1805	15	6
31	9023	2033-12-13	LT-1965	24	24
32	7543	2035-05-10	LT-2137	17	46
33	2183	2028-08-11	LT-2343	5	13
34	4840	2032-02-11	LT-4458	19	41
35	7097	2030-01-18	LT-8334	16	34
36	6016	2035-06-04	LT-1466	5	50
37	9230	2033-10-19	LT-4152	3	37
38	5342	2032-03-10	LT-5660	13	26
39	1753	2028-09-01	LT-4519	9	19
40	2799	2029-08-08	LT-5256	13	21
41	4832	2032-02-18	LT-1311	28	25
42	1403	2035-12-23	LT-8052	2	6
43	8538	2031-10-27	LT-3756	6	50
44	3704	2033-03-02	LT-5970	4	48
45	9115	2035-08-26	LT-8048	30	47
46	3487	2030-08-04	LT-1498	19	32
47	877	2028-03-27	LT-2556	28	4
48	9489	2027-07-22	LT-4388	6	47
49	6378	2028-01-29	LT-0701	20	10
50	9381	2035-08-02	LT-5774	19	42
51	6358	2028-09-16	LT-8885	24	17
52	2592	2029-10-15	LT-5644	6	2
53	3876	2036-02-02	LT-7794	15	20
54	3873	2027-11-10	LT-8736	25	4
55	1429	2031-08-07	LT-5812	14	10
56	7306	2034-08-01	LT-2359	22	15
57	4624	2034-09-17	LT-7910	10	17
59	6765	2029-09-28	LT-2696	1	34
60	284	2031-03-05	LT-5999	20	47
61	1480	2030-09-24	LT-1844	3	2
62	2664	2034-01-19	LT-6209	23	13
63	9448	2032-12-05	LT-8927	9	33
64	3186	2031-08-04	LT-5311	26	43
65	544	2031-04-16	LT-2187	17	35
67	9755	2035-08-06	LT-9770	19	45
68	3804	2035-12-16	LT-9149	4	23
69	7043	2032-06-24	LT-8330	30	1
70	746	2034-04-07	LT-2278	15	22
71	7709	2035-03-20	LT-7364	16	35
72	1152	2030-08-04	LT-3605	14	28
73	7306	2032-02-03	LT-5493	4	26
74	8857	2029-02-13	LT-0342	4	2
75	6131	2028-09-26	LT-5014	28	35
76	6315	2035-12-12	LT-6932	28	46
77	5858	2032-04-12	LT-1470	5	47
78	7048	2034-09-03	LT-0222	19	1
79	6361	2030-08-28	LT-9345	19	29
80	2756	2034-01-05	LT-0363	24	2
81	9459	2034-09-25	LT-8660	21	45
82	8280	2028-05-29	LT-4199	29	16
83	7714	2033-03-22	LT-1564	20	46
84	9657	2036-01-12	LT-7003	21	47
85	605	2028-07-28	LT-8029	6	36
86	2183	2028-02-04	LT-4091	29	48
87	2007	2034-02-22	LT-5373	4	36
88	1615	2033-11-11	LT-7769	13	32
89	4994	2033-03-01	LT-5508	28	23
90	1871	2035-07-07	LT-6490	7	43
91	8478	2028-02-18	LT-4589	25	30
92	2461	2031-04-14	LT-3604	26	10
93	4109	2027-11-22	LT-7525	2	35
94	3500	2028-08-25	LT-0423	1	42
95	1469	2032-08-26	LT-6609	5	34
96	8568	2031-02-08	LT-4768	5	30
97	6418	2029-05-27	LT-1437	28	20
98	3311	2031-12-07	LT-0601	14	41
99	7954	2034-10-23	LT-3533	2	37
100	1714	2036-01-10	LT-3600	20	20
101	1550	2031-11-14	LT-2356	21	14
102	9040	2033-05-19	LT-4303	20	18
103	1765	2034-03-08	LT-9540	13	20
104	4486	2034-04-13	LT-8904	10	11
105	7588	2036-09-25	LT-0964	10	22
106	1360	2036-07-02	LT-4917	19	7
107	884	2034-05-28	LT-2168	9	8
108	2461	2028-06-02	LT-9118	14	18
110	1963	2034-12-02	LT-0076	9	4
111	1081	2026-10-18	LT-3063	27	37
112	9974	2029-07-26	LT-3189	2	30
113	5384	2031-06-05	LT-5514	15	27
114	4389	2030-12-22	LT-0623	26	33
115	9451	2033-02-01	LT-7139	24	46
116	7840	2032-07-10	LT-0467	10	22
117	9583	2033-10-19	LT-6897	6	19
118	9256	2027-06-14	LT-3809	4	45
119	761	2035-04-22	LT-8087	30	32
120	1538	2028-01-01	LT-2519	11	14
121	892	2034-12-11	LT-1998	20	31
122	902	2031-01-08	LT-5067	21	23
124	2375	2032-12-18	LT-2798	14	27
125	911	2034-01-24	LT-3086	20	36
126	2218	2027-01-03	LT-6214	19	43
127	2759	2028-10-14	LT-4066	8	12
128	3164	2035-08-15	LT-3132	28	8
129	1578	2027-06-11	LT-2671	25	20
130	5149	2028-06-26	LT-8592	23	1
131	8850	2036-06-21	LT-0564	6	42
132	9968	2030-03-13	LT-0297	5	9
133	8572	2027-04-24	LT-4186	19	48
135	5384	2030-01-30	LT-3810	21	43
136	1521	2027-12-23	LT-4226	30	39
137	207	2032-04-04	LT-8479	6	20
138	860	2027-02-03	LT-1914	5	32
139	7307	2030-10-17	LT-5070	3	32
141	4220	2028-01-12	LT-4664	1	22
142	9607	2036-09-22	LT-3901	4	30
143	9589	2036-05-20	LT-0510	30	25
144	1849	2030-05-24	LT-5689	19	34
145	1284	2031-01-20	LT-6794	5	47
146	5179	2027-01-03	LT-6713	12	37
148	7977	2029-01-23	LT-6034	8	27
149	3551	2033-06-29	LT-0980	23	19
150	1820	2027-01-25	LT-6540	5	25
151	502	2032-08-03	LT-7443	4	13
152	585	2031-07-28	LT-9099	5	20
153	7947	2032-01-04	LT-8241	12	46
154	1498	2030-02-16	LT-2548	17	26
155	9670	2028-09-27	LT-6041	16	32
156	2195	2036-09-07	LT-3213	1	31
157	1719	2031-12-08	LT-8485	29	40
159	8473	2027-06-10	LT-3253	23	2
160	1906	2029-10-15	LT-6253	24	13
161	9304	2029-05-20	LT-7457	22	13
162	2026	2026-12-28	LT-1728	1	38
163	4894	2028-06-07	LT-2056	24	33
164	8887	2030-09-20	LT-0982	5	15
165	6613	2031-02-15	LT-1521	16	45
166	3891	2033-07-23	LT-4413	18	11
167	3022	2034-07-02	LT-7386	24	16
168	133	2034-01-11	LT-0234	12	42
169	6887	2032-06-28	LT-8212	24	33
170	3499	2030-06-09	LT-0381	2	41
171	6376	2031-02-16	LT-2170	30	3
172	6188	2034-12-05	LT-2887	2	42
173	7324	2032-06-22	LT-0278	13	6
174	2001	2031-02-24	LT-5871	7	35
175	7203	2028-03-19	LT-0545	19	8
176	1604	2027-01-17	LT-1110	20	30
177	5463	2029-03-20	LT-9661	11	37
178	7171	2036-03-12	LT-7059	6	48
179	8105	2031-09-11	LT-4891	22	48
180	2616	2035-09-05	LT-8593	12	19
181	4525	2031-10-20	LT-2901	4	34
182	9013	2035-09-21	LT-2379	12	11
183	5268	2028-04-24	LT-7576	19	14
184	6766	2028-08-05	LT-8520	5	41
185	8094	2034-02-26	LT-5601	1	9
186	5521	2031-12-18	LT-4557	21	22
187	1083	2036-04-14	LT-3368	26	3
188	525	2031-09-06	LT-9633	11	6
189	4956	2036-08-03	LT-5135	1	23
190	4056	2030-12-05	LT-5712	11	6
191	6648	2027-09-03	LT-4679	12	15
192	4810	2036-03-02	LT-8319	15	37
193	4914	2035-07-14	LT-0786	21	38
194	1726	2031-12-07	LT-9917	9	19
195	247	2033-05-16	LT-0032	22	27
196	1282	2036-06-14	LT-5490	21	7
197	1261	2032-08-15	LT-8278	6	31
198	977	2029-02-25	LT-5204	13	22
199	8329	2034-04-30	LT-2081	4	12
200	1618	2027-02-12	LT-7781	29	37
201	7147	2030-03-19	LT-2354	17	2
202	9284	2036-01-21	LT-7134	28	30
203	9836	2027-08-09	LT-3971	25	2
204	6796	2035-12-20	LT-5795	18	22
205	6706	2028-08-07	LT-7113	5	27
206	9057	2031-12-16	LT-3160	4	17
207	1334	2029-02-04	LT-8110	9	12
208	1588	2035-07-22	LT-1464	16	11
209	2701	2028-12-01	LT-6319	2	26
210	8094	2036-02-12	LT-3220	9	30
211	2042	2036-04-09	LT-2025	3	29
212	3608	2035-05-14	LT-0736	16	46
213	3644	2028-07-27	LT-3274	23	10
214	8367	2032-04-15	LT-7056	7	13
215	1902	2026-12-22	LT-5799	28	26
216	6284	2035-08-13	LT-3566	19	36
217	4893	2031-09-25	LT-7646	19	8
218	7946	2027-11-13	LT-8780	25	1
219	817	2028-11-25	LT-8565	15	21
221	9232	2027-02-09	LT-7451	21	33
222	8098	2028-03-24	LT-9404	6	37
223	7103	2029-03-29	LT-4207	19	23
224	7282	2030-05-11	LT-9675	1	18
225	4309	2030-08-28	LT-9914	29	10
226	6832	2032-10-22	LT-6282	29	13
227	6789	2031-03-28	LT-7246	17	41
228	8394	2034-04-08	LT-9081	15	40
229	3107	2027-07-16	LT-5589	24	14
230	4160	2036-07-09	LT-8492	21	40
231	3535	2029-05-23	LT-9855	24	27
232	5713	2032-07-11	LT-1045	24	47
233	6010	2031-07-28	LT-3049	4	45
234	9765	2029-05-03	LT-5201	14	46
235	8894	2035-05-24	LT-3490	29	45
236	8370	2035-01-22	LT-1260	20	4
237	1439	2029-06-11	LT-9143	4	11
238	7072	2029-01-05	LT-7563	9	28
239	9832	2029-04-24	LT-5884	5	29
240	2965	2032-07-23	LT-9977	12	46
241	5738	2028-07-24	LT-5686	8	13
242	2233	2030-11-09	LT-6235	18	37
243	2468	2031-08-16	LT-1732	24	39
244	8793	2031-12-12	LT-1660	10	2
245	5102	2033-08-04	LT-9672	10	12
246	7333	2028-10-23	LT-6639	10	41
247	8281	2033-09-28	LT-9899	9	11
249	4786	2034-09-22	LT-4503	8	23
250	8286	2030-02-22	LT-1252	22	36
251	6807	2035-11-04	LT-6014	18	10
252	2193	2028-01-17	LT-1335	20	25
253	9487	2035-10-07	LT-9634	8	48
254	4139	2028-07-20	LT-3208	25	9
255	4349	2028-10-03	LT-8523	23	12
256	8879	2027-06-13	LT-2843	26	9
257	2979	2035-04-14	LT-4441	30	37
258	6667	2032-01-15	LT-2427	9	21
259	7023	2027-11-07	LT-8396	29	1
261	8940	2036-09-01	LT-6540	10	24
262	6037	2033-07-24	LT-7745	21	2
263	2730	2029-05-05	LT-2573	4	45
264	9632	2034-03-25	LT-7779	19	42
265	428	2035-12-14	LT-0737	5	1
266	5151	2034-10-16	LT-5955	28	47
267	8656	2029-06-10	LT-0057	12	4
268	390	2033-10-05	LT-1280	6	32
269	3298	2032-04-29	LT-8986	16	3
270	3801	2031-10-28	LT-6441	7	46
271	307	2028-06-26	LT-5790	9	2
272	6760	2033-10-02	LT-6464	13	48
273	1492	2032-04-24	LT-6369	11	35
275	2121	2032-05-05	LT-1559	26	32
276	5673	2029-07-02	LT-1529	24	49
277	621	2028-06-04	LT-0408	18	2
278	4825	2033-08-17	LT-6034	19	42
279	4559	2031-09-08	LT-1564	23	7
281	8723	2028-03-18	LT-7188	9	4
282	4204	2032-01-08	LT-9956	22	31
283	1979	2031-11-19	LT-4972	1	31
284	5375	2028-03-21	LT-9907	29	14
285	3934	2029-11-12	LT-4658	11	9
286	8492	2028-12-01	LT-2629	16	35
287	2200	2031-01-30	LT-6454	1	2
288	1544	2036-09-17	LT-5597	27	32
289	4688	2028-01-31	LT-2821	22	4
290	4675	2034-05-14	LT-5173	10	41
291	9766	2032-07-13	LT-3435	10	19
292	1622	2029-05-25	LT-5423	27	37
293	8489	2034-05-19	LT-7797	13	47
294	6836	2035-01-31	LT-0486	14	3
295	5993	2030-02-23	LT-3696	4	15
296	7926	2034-11-28	LT-5649	15	30
297	7874	2030-05-11	LT-4158	17	42
298	4416	2031-07-11	LT-3457	1	36
299	4671	2035-03-20	LT-1264	16	36
300	8370	2027-03-25	LT-8108	10	17
301	1409	2031-03-31	LT-1861	22	11
302	530	2029-05-19	LT-0309	30	20
303	6435	2030-03-30	LT-4457	10	50
304	3566	2029-10-17	LT-8169	14	15
305	9915	2027-01-30	LT-1588	21	10
306	352	2035-12-04	LT-4792	9	3
307	1599	2029-03-05	LT-8943	24	34
308	5546	2030-05-08	LT-1656	4	22
309	531	2027-12-05	LT-5107	14	4
310	6412	2036-01-11	LT-8660	7	22
311	7799	2031-12-14	LT-6632	7	31
312	509	2030-08-30	LT-6380	15	20
313	1414	2036-08-04	LT-2726	20	18
314	8377	2027-01-28	LT-8698	6	38
315	5886	2033-07-15	LT-8959	1	15
316	4842	2029-01-08	LT-1995	23	4
317	6666	2029-01-12	LT-3725	2	18
318	3991	2027-09-02	LT-0507	29	20
319	3517	2030-07-24	LT-5525	15	37
320	9408	2030-11-29	LT-9982	23	36
321	7024	2030-01-24	LT-8762	13	21
322	1280	2033-05-11	LT-3216	6	15
323	3446	2028-08-31	LT-2975	29	17
324	5398	2030-01-22	LT-4484	11	43
325	9269	2031-04-08	LT-7908	11	11
326	3916	2028-03-16	LT-5080	10	21
327	212	2034-05-20	LT-6803	22	38
328	447	2035-03-07	LT-3040	5	46
329	9166	2033-11-26	LT-3879	4	17
330	9374	2032-07-22	LT-9228	8	2
331	3008	2030-12-07	LT-9263	13	23
332	9465	2033-09-20	LT-6888	4	4
333	4345	2031-04-09	LT-9804	11	2
334	7780	2035-04-08	LT-8675	17	27
335	2548	2034-12-29	LT-3032	29	45
336	1986	2029-08-05	LT-1742	6	16
337	8745	2031-10-15	LT-8965	30	26
338	8998	2029-06-15	LT-7288	1	29
339	9470	2030-02-10	LT-6381	26	40
340	2956	2026-11-26	LT-7948	5	15
341	5502	2031-08-20	LT-9844	2	49
342	4959	2034-10-09	LT-4356	17	32
343	8622	2035-05-16	LT-4458	12	41
344	8453	2031-06-21	LT-5488	13	27
345	8091	2027-04-30	LT-1774	5	35
346	8335	2035-08-16	LT-9361	14	6
347	4794	2034-09-09	LT-6336	24	29
348	1163	2033-06-24	LT-6050	27	17
349	8864	2034-10-06	LT-8746	13	43
350	6012	2034-08-08	LT-5487	12	5
351	3928	2034-06-13	LT-3790	2	6
353	5692	2034-10-01	LT-6640	26	25
354	3743	2034-10-31	LT-2269	1	49
355	2385	2027-05-07	LT-7542	8	1
356	761	2035-07-11	LT-2719	15	20
357	9813	2026-10-05	LT-7775	11	1
358	787	2032-02-19	LT-1561	13	27
359	7318	2029-05-11	LT-0630	27	18
360	3443	2027-01-18	LT-1564	3	30
361	2675	2031-11-22	LT-5212	16	46
362	618	2030-09-14	LT-1594	5	18
363	7751	2036-04-03	LT-1798	9	9
364	2966	2036-04-15	LT-2738	12	4
365	3423	2033-04-09	LT-3185	5	7
366	3531	2029-02-11	LT-7634	21	24
367	6559	2034-06-20	LT-9487	4	40
368	2293	2026-11-03	LT-1214	6	31
369	163	2028-04-26	LT-2249	5	48
370	7385	2029-06-26	LT-1408	9	6
371	8787	2036-07-16	LT-6924	9	18
372	9752	2030-11-19	LT-7562	26	42
373	6646	2036-07-04	LT-8868	26	1
374	4412	2034-06-13	LT-3214	28	5
375	2286	2027-08-28	LT-2444	19	21
376	5207	2031-10-25	LT-2824	8	42
377	8856	2031-11-08	LT-6546	5	16
378	1331	2035-06-30	LT-4506	11	36
379	5073	2026-10-06	LT-0146	24	1
380	3114	2027-08-21	LT-2320	2	16
381	4754	2032-02-03	LT-6675	5	37
382	1889	2030-08-18	LT-7996	30	13
383	4138	2031-04-28	LT-3970	24	40
384	2316	2034-10-23	LT-3734	22	8
385	9583	2034-05-05	LT-7757	19	48
386	9005	2027-04-24	LT-2304	8	48
387	2934	2031-08-07	LT-3214	22	40
388	3565	2034-04-20	LT-7333	24	39
389	6930	2035-01-09	LT-4845	23	11
390	3158	2029-11-04	LT-7380	3	28
391	2248	2028-10-31	LT-5800	7	10
392	1877	2026-10-02	LT-3889	29	9
393	7956	2032-02-20	LT-0637	11	9
394	6194	2029-01-08	LT-1449	6	34
395	3470	2028-09-26	LT-1422	15	49
396	3136	2035-09-18	LT-6873	3	4
397	8365	2032-12-23	LT-2665	8	35
398	9294	2031-01-25	LT-7634	15	35
399	5399	2033-09-25	LT-9237	10	42
400	566	2034-09-25	LT-9855	3	15
401	4520	2029-05-05	LT-8858	8	42
402	7974	2028-09-09	LT-1549	8	30
403	3616	2029-02-16	LT-3295	2	8
404	8904	2027-01-21	LT-2205	8	39
405	1896	2032-03-18	LT-4631	28	46
406	1534	2027-05-31	LT-9585	10	41
407	1460	2029-11-27	LT-2845	8	40
409	5033	2032-01-16	LT-5222	8	41
410	3479	2036-07-05	LT-6441	15	27
411	6853	2031-12-06	LT-1502	29	46
412	5865	2029-05-20	LT-0398	16	46
413	4943	2035-11-08	LT-6465	1	10
414	3810	2028-01-19	LT-0987	4	39
415	6544	2035-08-04	LT-4628	10	10
416	9323	2034-08-24	LT-7000	25	6
417	7594	2035-09-19	LT-7774	4	25
418	2427	2035-06-11	LT-8273	20	15
419	347	2028-06-09	LT-2393	6	27
420	2518	2034-12-28	LT-1262	29	42
421	4998	2036-08-24	LT-7981	19	35
422	2284	2033-06-26	LT-6056	13	34
423	4537	2030-10-07	LT-1833	18	28
424	7958	2031-08-04	LT-2193	4	26
425	5746	2027-05-30	LT-6624	22	25
426	581	2028-10-13	LT-6160	15	7
427	3361	2027-02-23	LT-5754	21	36
428	1501	2030-07-31	LT-0799	21	50
429	5619	2035-06-26	LT-8777	30	36
430	8156	2035-10-06	LT-7281	2	5
431	9898	2034-07-14	LT-4942	27	8
432	2638	2027-01-25	LT-7378	10	16
433	4609	2036-02-10	LT-8358	5	39
434	5578	2027-04-08	LT-3027	22	9
435	7249	2029-09-28	LT-6919	24	15
436	5514	2026-10-31	LT-5934	11	15
437	7066	2028-08-01	LT-4315	4	42
438	8865	2034-07-01	LT-4683	16	22
439	3729	2030-04-26	LT-9920	3	3
440	6993	2027-02-06	LT-6868	10	24
441	9458	2035-11-05	LT-2686	7	50
442	4594	2033-09-04	LT-0008	29	15
443	3064	2033-05-12	LT-0178	15	19
444	8662	2036-05-18	LT-2129	4	18
445	6491	2036-07-22	LT-4483	27	4
446	2490	2031-12-16	LT-2130	21	37
447	3018	2031-07-25	LT-5812	25	23
448	2700	2031-03-15	LT-1892	29	1
449	3537	2028-02-06	LT-1495	18	35
450	4035	2035-02-26	LT-3662	10	17
451	9266	2032-07-12	LT-1777	13	29
452	146	2029-09-17	LT-1294	4	30
453	3203	2032-01-28	LT-0858	5	45
454	168	2033-07-31	LT-2836	1	11
455	1351	2033-02-23	LT-6887	24	3
456	6123	2028-06-30	LT-6560	1	23
458	3203	2028-01-08	LT-5818	5	13
459	4456	2034-06-09	LT-7418	8	7
460	920	2030-10-16	LT-1977	7	36
461	3137	2034-08-26	LT-9794	15	7
462	5234	2030-12-06	LT-1720	8	36
463	1356	2034-11-23	LT-4302	10	40
464	5621	2035-02-01	LT-4700	29	32
465	4513	2036-09-19	LT-4041	19	18
466	3034	2028-03-30	LT-4319	27	23
467	3883	2028-03-02	LT-8030	18	24
468	9030	2031-04-04	LT-4097	3	36
469	6847	2029-05-25	LT-2321	23	37
470	5971	2034-09-14	LT-7932	2	30
471	701	2034-06-19	LT-7270	13	18
472	1068	2034-03-25	LT-2106	20	46
473	2385	2036-09-21	LT-8380	11	43
474	2745	2033-05-11	LT-1414	3	38
475	114	2027-08-25	LT-4856	3	13
476	9932	2034-12-11	LT-7045	3	12
477	2310	2028-02-14	LT-8384	10	13
478	6468	2029-09-06	LT-4514	27	23
479	5621	2033-05-16	LT-5635	12	1
480	2307	2033-07-17	LT-2086	23	10
481	8103	2035-06-01	LT-8486	25	50
482	8752	2033-10-06	LT-5645	25	39
483	3517	2029-08-24	LT-0681	30	15
484	4803	2031-05-28	LT-4072	21	18
485	6360	2033-07-12	LT-3472	25	27
486	6707	2031-05-12	LT-3575	17	34
487	3132	2031-08-21	LT-5251	17	37
488	5541	2035-07-23	LT-8749	19	42
489	8814	2028-12-31	LT-8147	2	36
490	5166	2030-10-30	LT-9036	15	15
491	8817	2030-06-17	LT-4443	12	43
492	3513	2034-08-19	LT-7959	26	37
493	1940	2028-07-15	LT-7234	2	8
494	4021	2032-12-05	LT-6400	17	1
495	2458	2033-04-02	LT-4293	14	2
496	143	2034-06-22	LT-9671	21	45
497	4054	2028-02-28	LT-3643	16	47
498	8153	2033-05-11	LT-4555	9	23
499	2276	2031-09-15	LT-8122	21	42
500	505	2027-10-15	LT-3848	7	3
501	4054	2027-08-12	LT-3657	17	45
502	2503	2033-11-29	LT-9151	29	37
503	4144	2029-02-08	LT-4347	5	12
504	5484	2035-10-15	LT-9484	13	35
505	1995	2032-01-12	LT-9731	18	30
506	8649	2029-07-20	LT-5049	26	35
507	3040	2028-11-01	LT-1364	3	14
508	464	2031-09-09	LT-0760	22	15
509	6116	2033-06-15	LT-2650	26	13
510	2884	2033-05-12	LT-3158	17	7
511	4690	2029-10-25	LT-2646	27	21
512	8176	2035-05-07	LT-6155	23	31
513	6988	2029-07-28	LT-8743	8	50
514	3949	2036-09-13	LT-7086	6	48
515	1264	2029-07-26	LT-8589	20	39
516	6650	2035-09-20	LT-9382	25	42
517	5213	2031-12-08	LT-0500	12	4
518	1734	2036-03-29	LT-4610	1	2
519	9273	2029-08-03	LT-3295	27	31
520	6863	2027-07-28	LT-3169	28	13
521	9059	2035-04-03	LT-4517	4	26
522	9547	2029-04-13	LT-4100	11	47
523	1329	2031-10-09	LT-2386	11	3
524	6525	2030-02-26	LT-5038	27	46
525	1624	2026-10-06	LT-6752	15	22
526	7396	2029-01-19	LT-4993	25	30
527	960	2029-02-27	LT-7744	6	13
528	6102	2036-02-22	LT-1657	8	40
529	3506	2027-08-13	LT-4688	16	1
530	3865	2032-02-29	LT-8471	7	24
531	8733	2026-10-05	LT-8791	29	35
532	4193	2031-06-29	LT-6187	30	10
533	4486	2029-12-15	LT-0505	25	45
534	6641	2033-04-02	LT-1468	4	17
535	9680	2034-10-17	LT-2671	12	40
536	9115	2033-12-31	LT-7300	14	5
537	5207	2033-07-21	LT-8710	4	16
538	623	2035-05-14	LT-0609	24	3
539	6545	2030-06-16	LT-7868	27	15
540	9278	2033-05-28	LT-2487	1	41
541	2528	2035-05-17	LT-0834	12	4
542	5299	2030-01-09	LT-2710	12	35
543	5437	2027-05-25	LT-6163	15	10
544	4163	2034-05-30	LT-3521	23	29
545	4185	2032-10-07	LT-3879	25	19
546	753	2028-05-11	LT-5874	27	49
547	7809	2027-07-31	LT-1685	14	9
548	8936	2036-01-29	LT-6238	9	23
549	7346	2029-09-12	LT-4797	15	16
550	2293	2027-09-16	LT-0416	12	4
551	6493	2029-04-02	LT-2415	30	50
552	2909	2029-02-27	LT-4373	13	41
553	4467	2030-11-21	LT-9829	14	7
554	4451	2029-10-15	LT-3628	2	39
555	2620	2028-02-15	LT-4255	4	38
556	5439	2034-05-01	LT-0900	6	25
557	1753	2031-01-17	LT-2531	7	32
558	5518	2027-08-30	LT-0400	23	27
559	5704	2031-08-31	LT-1466	28	46
560	2253	2030-05-15	LT-5268	12	35
561	175	2027-04-08	LT-6799	10	17
562	8298	2033-10-03	LT-2852	8	32
563	3613	2027-07-24	LT-9044	20	4
564	8069	2028-12-14	LT-5073	15	41
565	4823	2034-09-28	LT-3871	15	4
566	6080	2030-07-25	LT-7625	26	14
567	7011	2033-08-15	LT-7172	26	2
568	291	2036-02-29	LT-8200	27	7
569	6544	2030-01-16	LT-0995	24	41
570	1376	2031-12-01	LT-8373	22	29
571	1533	2029-03-06	LT-1453	15	45
572	1150	2027-10-02	LT-9211	19	34
573	858	2027-11-13	LT-2996	7	35
574	5118	2027-02-03	LT-2630	8	39
575	4120	2033-07-14	LT-3801	15	31
576	7814	2033-02-26	LT-7720	2	30
577	6334	2031-02-12	LT-0422	10	30
578	1758	2029-07-14	LT-2452	15	50
579	9791	2035-03-03	LT-2338	19	5
580	2819	2035-02-09	LT-2398	11	29
581	6025	2036-05-30	LT-8749	19	13
582	7447	2031-06-26	LT-9625	8	48
583	5394	2034-07-24	LT-1133	21	8
584	337	2033-09-24	LT-7223	11	6
585	8050	2030-03-25	LT-7603	8	6
586	1214	2029-03-30	LT-7856	21	34
587	8900	2035-11-04	LT-3152	16	31
588	3136	2035-02-12	LT-9968	30	40
589	8646	2034-05-31	LT-4952	17	24
590	2893	2032-01-06	LT-4935	13	11
591	3329	2029-07-22	LT-8252	17	9
592	8510	2030-02-05	LT-0990	6	50
593	6553	2036-03-20	LT-5605	3	25
594	6562	2031-10-28	LT-2021	24	29
596	7491	2034-01-02	LT-1389	2	7
597	3783	2031-10-27	LT-4501	15	33
598	1887	2034-10-29	LT-0023	27	39
599	8254	2026-09-30	LT-4763	24	48
600	8454	2031-04-18	LT-6388	20	39
601	3248	2030-07-08	LT-9667	13	36
602	172	2032-12-04	LT-3940	15	7
603	4205	2028-02-11	LT-6747	25	34
604	8227	2036-02-26	LT-4471	28	36
605	5419	2027-06-24	LT-4215	7	10
606	7261	2035-07-01	LT-6712	20	5
607	4273	2029-04-11	LT-2619	13	12
608	1449	2026-12-23	LT-4186	8	39
609	3262	2029-06-25	LT-4949	11	24
611	736	2034-10-26	LT-7314	12	39
612	3899	2027-03-30	LT-5035	15	30
613	4444	2029-08-04	LT-3888	13	48
614	2678	2036-08-23	LT-5346	25	29
615	4416	2036-07-30	LT-1411	2	50
616	8729	2029-01-29	LT-5181	27	17
617	7703	2031-01-19	LT-4467	29	31
618	2909	2031-10-29	LT-3118	16	3
619	1935	2029-09-04	LT-1816	1	31
620	186	2030-10-08	LT-0793	11	37
621	6885	2035-03-08	LT-7994	11	1
622	8290	2036-08-10	LT-5987	24	14
623	9584	2036-05-12	LT-5570	25	38
624	2468	2033-07-11	LT-2154	6	7
625	5253	2032-04-28	LT-8521	5	32
626	4728	2027-04-30	LT-0959	6	38
627	195	2031-11-28	LT-0741	5	15
628	3096	2029-06-19	LT-6763	12	23
629	4102	2032-05-25	LT-0616	13	30
630	7389	2035-03-04	LT-1207	1	40
631	2536	2032-09-09	LT-2838	15	32
633	4424	2033-08-28	LT-5310	4	6
634	6830	2026-10-11	LT-7360	13	39
635	5745	2036-05-21	LT-9426	13	3
636	9891	2027-02-11	LT-3484	20	15
637	6962	2030-08-04	LT-9379	7	4
638	5902	2030-02-17	LT-0025	9	32
639	4607	2029-07-08	LT-4413	26	38
640	3940	2031-06-03	LT-5584	4	5
641	3196	2028-02-19	LT-8660	19	10
642	2389	2036-05-30	LT-0116	23	14
643	4731	2026-11-19	LT-2248	23	16
644	2137	2033-08-17	LT-0092	11	42
645	1995	2035-10-29	LT-7561	3	24
646	7339	2030-11-29	LT-9026	10	25
647	9192	2032-01-10	LT-1065	9	48
648	7827	2034-07-09	LT-6465	26	24
649	5464	2027-01-10	LT-2234	8	12
651	5641	2029-08-06	LT-1354	13	24
652	8806	2029-06-03	LT-8466	23	42
653	1043	2034-08-20	LT-6136	15	40
654	2013	2028-05-31	LT-7093	16	17
655	3935	2030-12-08	LT-9177	17	36
656	2794	2034-03-07	LT-2141	28	1
657	382	2032-09-25	LT-1205	2	2
658	5078	2027-02-17	LT-0143	7	15
659	8253	2028-05-27	LT-0052	13	32
660	2891	2034-02-09	LT-0528	6	39
661	4614	2034-11-11	LT-1727	14	33
662	3372	2029-06-15	LT-2741	6	35
663	5203	2034-03-23	LT-8378	22	6
664	6066	2027-05-04	LT-8166	17	37
665	1244	2030-05-15	LT-2642	19	23
666	4141	2032-08-03	LT-6575	22	29
667	765	2027-04-30	LT-6380	14	33
668	1023	2034-03-05	LT-9071	19	41
669	8207	2032-12-04	LT-6227	14	31
670	3800	2035-08-19	LT-2381	26	38
671	676	2036-06-12	LT-4262	28	20
672	7578	2033-03-06	LT-0253	10	12
673	797	2034-05-15	LT-4141	7	8
674	7377	2028-10-29	LT-2594	18	49
675	5247	2026-11-19	LT-6585	5	40
676	8921	2027-05-29	LT-4937	3	30
677	3523	2030-03-03	LT-0041	7	40
678	2146	2028-11-19	LT-7386	7	2
679	9064	2028-02-20	LT-2063	2	7
680	1834	2029-08-13	LT-6304	7	24
682	7288	2027-03-07	LT-7673	13	3
683	3845	2032-10-31	LT-2931	4	16
684	9882	2031-10-26	LT-1592	25	37
685	384	2032-09-27	LT-1509	11	4
686	7006	2034-08-21	LT-5393	2	3
687	2894	2030-03-27	LT-0736	5	47
688	3902	2036-05-07	LT-5287	16	19
689	1633	2028-02-01	LT-0658	4	39
690	3673	2033-07-30	LT-3670	8	8
691	8280	2029-11-29	LT-9725	19	18
692	1265	2031-05-10	LT-5312	7	15
693	3346	2033-04-15	LT-5722	17	23
694	7431	2028-09-24	LT-2329	9	26
695	7572	2034-05-19	LT-8945	16	36
696	5345	2027-04-11	LT-3084	21	14
697	6610	2030-11-25	LT-8191	11	48
698	340	2028-02-10	LT-0867	30	48
699	1950	2034-07-06	LT-1580	1	11
700	9128	2029-01-06	LT-6749	1	33
701	2308	2031-08-18	LT-8073	22	39
702	3922	2032-05-22	LT-7632	28	17
703	6394	2027-03-12	LT-9216	14	21
704	1081	2031-12-12	LT-8678	17	12
705	6415	2033-05-25	LT-5579	8	17
706	2358	2035-06-13	LT-6863	21	48
707	7279	2028-11-01	LT-6372	15	24
708	8903	2028-01-03	LT-3576	18	47
709	1642	2029-08-13	LT-8590	20	34
710	1500	2029-10-27	LT-2939	24	18
711	5214	2035-04-17	LT-3641	17	46
712	6452	2034-09-01	LT-5237	12	1
713	9423	2029-08-15	LT-8009	8	27
714	2173	2029-01-07	LT-5757	10	15
715	8351	2032-06-11	LT-1526	14	41
716	7033	2033-04-01	LT-6488	4	13
717	4431	2032-02-16	LT-2619	24	16
718	4052	2027-11-30	LT-8460	1	6
719	5594	2033-11-03	LT-6584	20	38
720	2718	2028-01-15	LT-4244	16	23
721	607	2036-07-19	LT-3953	8	34
722	7110	2033-08-21	LT-6085	21	13
723	7489	2032-03-26	LT-5058	10	47
724	4004	2032-04-27	LT-7381	23	15
725	1254	2034-01-22	LT-0754	13	41
726	6314	2027-10-12	LT-4267	4	14
727	9765	2033-11-08	LT-0381	17	49
728	3585	2028-09-01	LT-3790	9	16
729	8868	2026-11-03	LT-5194	1	3
730	2172	2029-10-01	LT-1851	9	28
731	6533	2032-04-20	LT-8096	8	42
732	9664	2033-01-12	LT-3526	24	46
733	2241	2027-04-21	LT-3511	30	29
734	6581	2029-08-24	LT-5281	21	35
735	4300	2032-12-27	LT-8188	19	15
736	4079	2035-08-21	LT-6139	2	32
737	1051	2032-09-20	LT-4822	5	37
738	6161	2031-11-02	LT-1659	23	33
739	8531	2026-10-21	LT-7052	17	16
740	403	2031-03-03	LT-5753	4	18
741	3705	2031-02-07	LT-5555	16	33
742	5428	2026-10-16	LT-5317	6	10
743	221	2033-03-01	LT-3382	30	33
744	487	2030-08-31	LT-8494	14	10
745	2581	2030-08-30	LT-4679	13	19
746	6208	2033-02-21	LT-3009	16	31
747	6424	2034-07-17	LT-2079	27	39
748	6220	2033-07-01	LT-5160	27	21
749	5421	2028-02-19	LT-6637	16	49
750	8708	2033-11-15	LT-6758	30	30
751	7090	2028-09-24	LT-7069	3	1
752	2916	2031-05-23	LT-9438	24	35
753	3574	2033-03-08	LT-3005	8	40
754	3688	2030-02-04	LT-3021	19	41
755	6808	2030-07-14	LT-4961	23	23
756	939	2029-06-16	LT-3631	27	50
757	373	2029-07-08	LT-6976	30	8
758	2736	2030-10-18	LT-9789	20	25
759	6140	2035-02-26	LT-6904	8	47
760	5383	2031-05-10	LT-5479	16	37
761	9974	2035-10-11	LT-5023	17	50
762	2714	2034-03-21	LT-3563	19	6
763	3813	2029-02-01	LT-1298	10	3
764	3763	2034-11-23	LT-1366	4	25
765	4482	2030-07-20	LT-6918	3	48
766	4269	2030-06-02	LT-1392	28	8
767	7267	2035-10-21	LT-8677	26	38
768	946	2035-05-16	LT-0845	11	5
769	9899	2032-05-25	LT-4821	13	13
770	9982	2029-11-26	LT-0383	9	3
771	7263	2029-05-08	LT-1717	15	11
772	1393	2034-07-27	LT-5709	24	37
773	6167	2035-01-05	LT-5577	30	3
774	6250	2035-11-03	LT-2464	27	8
775	2958	2028-05-24	LT-9849	25	50
776	4103	2031-01-05	LT-1937	17	34
777	6507	2035-06-04	LT-1134	26	24
778	7489	2035-11-19	LT-7594	14	2
779	853	2033-02-17	LT-3125	1	30
780	306	2028-04-04	LT-2717	23	42
781	8949	2034-09-13	LT-4502	16	6
782	1233	2029-12-11	LT-9300	8	25
783	6973	2034-03-31	LT-7741	19	8
784	9162	2027-06-04	LT-3546	17	15
785	439	2035-02-10	LT-8022	15	9
786	5434	2032-08-05	LT-1153	2	10
788	4796	2030-10-31	LT-3511	18	6
789	9061	2033-12-22	LT-5500	11	9
790	8943	2036-08-02	LT-5626	25	49
791	7272	2029-01-31	LT-6988	26	42
792	7620	2028-09-20	LT-3855	13	39
793	2547	2032-06-03	LT-0380	21	7
794	8455	2027-01-04	LT-8042	23	26
795	7122	2033-06-07	LT-3557	6	38
796	5329	2031-02-13	LT-4664	23	18
797	1692	2028-01-09	LT-0095	5	38
798	1832	2029-07-03	LT-5416	23	20
799	4760	2030-01-12	LT-5856	30	3
800	2118	2030-04-24	LT-3429	3	28
801	1688	2032-02-09	LT-3496	15	17
802	4292	2030-01-06	LT-3916	8	41
803	2008	2032-06-28	LT-6860	24	32
804	8151	2027-07-02	LT-5582	21	28
805	2432	2031-08-21	LT-5778	19	27
806	8837	2031-08-23	LT-7176	14	2
807	1741	2036-04-21	LT-6506	10	21
808	9311	2029-07-13	LT-2930	30	30
809	5589	2035-07-21	LT-4669	24	40
810	7950	2029-04-20	LT-0760	12	21
811	7695	2033-01-25	LT-5297	22	39
812	5231	2029-12-23	LT-7529	7	30
813	1771	2030-02-24	LT-0911	22	45
814	5114	2033-10-29	LT-9998	8	10
815	3090	2030-06-11	LT-5226	2	6
816	3088	2032-11-11	LT-5529	8	4
817	5835	2028-06-21	LT-5477	25	31
818	8998	2035-02-28	LT-6729	19	6
819	9153	2034-09-03	LT-5603	11	6
820	3272	2028-02-03	LT-6862	29	11
821	8064	2035-12-11	LT-5003	10	10
822	338	2030-05-23	LT-7479	3	32
823	4237	2028-10-02	LT-8586	16	43
824	2753	2035-06-20	LT-7389	4	34
825	3897	2027-11-13	LT-0202	12	33
826	2207	2030-05-07	LT-2143	22	43
827	735	2033-03-26	LT-3772	4	24
828	9707	2027-03-21	LT-4188	18	34
829	3332	2027-04-18	LT-9863	27	48
830	9417	2034-07-27	LT-8287	27	7
831	5350	2028-11-09	LT-1265	16	41
832	3872	2027-01-20	LT-5939	6	5
833	1590	2033-12-13	LT-3064	23	16
834	844	2035-03-16	LT-7777	22	26
835	8470	2026-11-24	LT-7288	17	22
836	6201	2028-04-15	LT-7763	25	23
837	8594	2036-01-02	LT-6035	12	11
838	9624	2033-04-22	LT-9167	4	29
839	1157	2033-04-29	LT-3145	21	10
840	9011	2034-03-03	LT-5313	25	15
841	2363	2033-06-01	LT-3032	3	35
842	8483	2030-10-02	LT-2021	27	31
843	2810	2032-08-18	LT-9151	20	2
844	8872	2032-04-04	LT-2620	21	47
845	2473	2033-08-24	LT-7584	22	46
846	2615	2031-10-08	LT-1735	18	5
847	441	2029-07-19	LT-0792	16	12
848	3808	2027-07-18	LT-9825	7	29
849	6725	2036-03-31	LT-3822	16	14
850	8222	2036-04-13	LT-5135	30	10
851	1440	2035-04-28	LT-7928	5	48
852	7246	2035-06-27	LT-1968	19	40
853	771	2029-05-03	LT-8836	3	30
854	1379	2026-11-24	LT-4248	3	41
855	2076	2035-05-05	LT-5549	29	2
856	4210	2035-06-17	LT-6700	6	39
857	7907	2028-03-02	LT-8659	17	1
858	8866	2028-04-29	LT-1686	17	24
859	4949	2026-11-19	LT-8384	6	14
860	8808	2032-03-23	LT-3276	21	10
861	1380	2033-06-04	LT-8079	3	37
862	1384	2028-04-21	LT-5212	28	23
863	920	2035-06-11	LT-0903	26	17
864	4994	2027-11-21	LT-0558	10	36
865	5886	2034-02-18	LT-9646	15	23
866	5166	2027-01-31	LT-5058	8	21
867	6860	2032-01-23	LT-4055	27	23
868	3435	2033-04-19	LT-3298	14	22
869	8130	2032-12-25	LT-2563	21	38
870	3150	2035-09-24	LT-7079	23	1
871	5990	2028-01-27	LT-6216	15	48
872	5431	2036-04-08	LT-6996	8	28
873	761	2034-10-28	LT-2064	2	31
874	1516	2031-07-20	LT-0884	26	50
875	6767	2032-10-14	LT-4923	5	40
876	6748	2028-03-19	LT-6210	11	12
877	3675	2033-11-09	LT-7036	3	28
878	1175	2030-12-25	LT-2852	12	37
879	5902	2031-04-12	LT-5261	9	18
880	5666	2030-09-05	LT-7788	13	39
881	2434	2035-04-19	LT-8438	19	26
882	6645	2032-08-17	LT-7510	25	12
883	2467	2032-07-04	LT-7236	19	28
884	603	2032-09-24	LT-0026	26	3
885	5393	2027-01-05	LT-1582	11	41
886	958	2033-11-18	LT-4138	28	8
887	220	2032-02-29	LT-9362	14	7
888	9640	2031-04-14	LT-8275	1	23
889	8369	2034-10-16	LT-8834	8	23
890	6474	2033-04-14	LT-5316	6	19
891	7593	2032-01-11	LT-3990	30	24
892	454	2028-12-27	LT-8981	10	17
893	5939	2031-02-25	LT-1304	28	32
894	1305	2036-04-15	LT-0228	19	43
895	9854	2029-01-06	LT-8694	23	46
896	2235	2029-12-04	LT-5565	13	1
897	2787	2031-02-17	LT-9337	26	49
898	9365	2032-01-12	LT-0443	9	25
899	3109	2033-04-12	LT-1861	2	19
900	4794	2030-11-19	LT-0063	20	38
901	3053	2026-10-15	LT-4092	19	48
902	3164	2032-03-28	LT-3248	5	36
903	8693	2035-11-14	LT-3698	24	34
904	721	2027-06-23	LT-4435	8	9
905	1227	2032-03-13	LT-6388	4	18
906	1977	2031-10-26	LT-7398	15	28
907	7101	2028-07-02	LT-0392	7	10
908	4234	2030-06-06	LT-6825	15	2
909	5521	2031-12-03	LT-1419	8	17
911	1705	2028-04-19	LT-1652	5	41
912	8324	2036-08-06	LT-3786	2	42
913	6090	2028-07-10	LT-8055	9	43
914	9011	2033-07-19	LT-1906	11	10
915	4805	2033-03-26	LT-7247	9	37
916	5863	2034-05-27	LT-4487	25	45
917	8049	2030-12-16	LT-4438	30	8
918	1587	2030-12-21	LT-6758	12	3
919	906	2033-02-02	LT-4065	30	45
920	1001	2031-04-06	LT-5805	16	15
921	9943	2027-08-15	LT-9939	26	50
922	3269	2033-10-03	LT-1256	11	4
923	2587	2031-02-20	LT-2188	16	10
924	3967	2031-04-22	LT-5628	15	23
925	4675	2032-06-13	LT-9288	2	24
926	2193	2032-11-10	LT-2807	13	12
927	7393	2032-09-14	LT-0935	19	33
928	7560	2028-11-04	LT-9873	19	12
929	6985	2030-07-14	LT-3713	10	22
930	3700	2035-07-12	LT-8511	15	7
931	1375	2036-03-13	LT-0254	3	47
932	1692	2029-05-25	LT-9665	11	13
933	7356	2028-07-29	LT-9347	7	47
934	4633	2026-10-03	LT-9833	11	25
935	8127	2034-09-18	LT-2095	22	45
936	9673	2030-02-24	LT-8015	24	37
937	2687	2027-11-25	LT-8980	15	5
938	1381	2029-05-18	LT-8461	7	6
939	5399	2032-06-20	LT-8471	4	12
940	8123	2033-07-02	LT-2139	30	43
941	9938	2033-09-12	LT-3374	30	49
942	6405	2027-11-25	LT-4540	30	49
943	8862	2031-12-24	LT-4316	7	23
944	9808	2034-04-11	LT-6454	10	49
945	4569	2027-09-14	LT-9456	13	3
946	7097	2027-11-20	LT-8333	8	2
947	8646	2027-01-09	LT-3247	14	1
948	727	2029-05-10	LT-0888	8	3
949	343	2032-05-24	LT-6670	3	41
950	9726	2033-08-30	LT-6499	21	18
951	1445	2030-05-10	LT-4604	22	5
952	4854	2033-06-30	LT-7171	6	1
953	4626	2036-02-27	LT-5441	6	1
954	5230	2036-06-17	LT-7974	11	36
955	5318	2028-01-07	LT-5658	26	19
956	9849	2032-03-30	LT-7704	30	12
957	4090	2030-06-26	LT-9960	19	26
958	5059	2034-07-19	LT-8191	18	10
959	3476	2033-01-30	LT-5088	11	21
960	6218	2035-09-24	LT-6541	1	36
961	5272	2027-10-11	LT-4964	3	10
962	4062	2029-08-16	LT-8672	26	12
963	9724	2032-09-10	LT-4358	10	26
964	8439	2029-02-25	LT-1285	17	12
965	8694	2030-01-31	LT-9475	1	41
966	1143	2027-03-06	LT-0333	26	6
967	2583	2028-06-28	LT-5326	29	4
968	1841	2035-08-04	LT-9872	15	47
969	8704	2032-11-15	LT-3119	10	16
970	4045	2032-06-16	LT-9689	16	25
971	9732	2032-03-20	LT-8108	2	1
972	8741	2032-10-30	LT-2204	20	49
973	9808	2031-02-05	LT-0283	28	29
974	3162	2028-02-12	LT-7103	10	27
975	526	2032-09-04	LT-1321	17	6
976	4178	2031-01-27	LT-5167	21	42
977	8814	2033-05-02	LT-7149	26	34
978	3228	2027-10-06	LT-8808	30	39
979	7313	2034-02-14	LT-4203	7	12
980	7742	2032-06-30	LT-7536	2	8
981	472	2031-07-08	LT-2943	15	5
982	3266	2032-10-22	LT-7843	1	33
983	1184	2028-05-01	LT-7063	21	39
984	1054	2031-09-25	LT-7779	16	38
985	315	2035-11-29	LT-0827	22	39
986	7218	2035-06-29	LT-5264	3	4
987	3742	2027-03-18	LT-9207	12	16
988	3817	2027-03-18	LT-0204	3	32
989	3786	2031-05-03	LT-6144	3	20
990	8798	2033-07-29	LT-8989	17	17
991	1546	2029-12-22	LT-1835	21	47
992	1330	2035-11-16	LT-9072	5	20
993	6107	2028-03-30	LT-3145	4	19
994	7069	2031-05-14	LT-4232	11	2
995	4629	2028-05-14	LT-9316	2	49
996	100	2034-10-17	LT-3916	22	17
997	3116	2035-06-24	LT-4362	27	4
998	2854	2036-04-25	LT-4237	13	8
999	525	2030-06-13	LT-3701	14	3
1000	9885	2034-03-10	LT-8255	5	42
1001	2663	2035-07-16	LT-9888	21	22
1002	3186	2029-11-01	LT-0350	13	23
1003	6539	2033-01-15	LT-4690	3	35
1004	2327	2028-12-02	LT-7665	24	13
1005	7343	2030-07-10	LT-5578	16	20
1006	1261	2035-01-01	LT-0278	30	29
1007	4213	2034-07-02	LT-5376	23	46
1008	5505	2033-11-27	LT-9386	14	22
1009	402	2031-11-03	LT-4942	19	7
1010	2870	2030-07-21	LT-9668	10	30
1011	4690	2030-09-15	LT-7999	6	22
1012	2649	2032-05-12	LT-4187	14	1
1013	1150	2028-08-01	LT-5267	8	7
1014	1316	2031-12-31	LT-4800	10	35
1015	1803	2031-05-31	LT-0067	19	11
1016	3141	2034-04-18	LT-9153	2	40
1017	2686	2034-11-10	LT-4681	2	32
1018	2637	2031-03-23	LT-3214	14	21
1019	5712	2030-12-30	LT-3892	17	35
1020	2533	2035-05-23	LT-1339	12	28
1021	7987	2036-06-19	LT-2143	16	39
1022	8136	2035-12-23	LT-1776	10	6
1023	9386	2032-05-05	LT-4240	30	48
1024	946	2027-04-14	LT-7167	11	35
1025	728	2028-10-15	LT-9320	6	25
1026	6495	2026-11-19	LT-4509	23	2
1027	6749	2034-07-09	LT-8389	29	42
1028	967	2028-06-02	LT-4143	26	31
1029	4992	2029-09-08	LT-5973	13	19
1030	5173	2027-12-02	LT-9089	14	21
1031	1238	2030-08-05	LT-7099	13	16
1032	8124	2028-08-15	LT-0721	30	16
1033	7245	2030-07-13	LT-5895	7	1
1034	9074	2030-12-09	LT-3121	27	49
1035	9167	2028-04-04	LT-8714	29	27
1036	932	2031-12-03	LT-6249	10	6
1037	4416	2030-12-11	LT-5519	23	16
1038	4816	2033-10-14	LT-7105	10	24
1039	2331	2031-12-29	LT-7160	8	50
1040	2066	2029-07-30	LT-6331	7	46
1041	7633	2033-07-13	LT-6886	7	36
1042	4998	2028-03-14	LT-3113	11	31
1043	1484	2030-03-26	LT-9499	12	43
1044	8157	2031-04-06	LT-4321	24	41
1045	3437	2030-06-17	LT-5075	12	41
1046	427	2031-12-12	LT-7985	22	30
1047	8456	2036-07-30	LT-6046	10	38
1048	8340	2028-11-02	LT-2029	26	50
1049	195	2032-10-23	LT-7484	18	50
1050	6862	2034-06-28	LT-5699	26	16
1051	392	2028-04-26	LT-8064	7	30
1052	4645	2026-11-03	LT-0752	26	38
1053	1758	2035-03-31	LT-7782	8	37
1054	7237	2031-09-07	LT-2179	2	1
1055	2068	2028-09-15	LT-1459	15	50
1056	1286	2030-11-06	LT-6350	28	21
1057	4788	2035-07-20	LT-7786	27	35
1058	6883	2029-02-18	LT-9112	20	49
1059	8110	2034-08-27	LT-5099	29	49
1060	2285	2033-05-16	LT-9046	8	25
1061	2447	2032-10-10	LT-5979	6	37
1062	7390	2027-02-07	LT-0009	28	20
1063	3457	2035-10-12	LT-0685	17	4
1064	5889	2036-04-13	LT-8605	16	15
1065	3520	2035-11-25	LT-6198	23	4
1066	7990	2029-08-02	LT-7121	6	45
1067	3948	2031-07-12	LT-3318	4	35
1068	5309	2033-01-13	LT-0309	6	5
1069	341	2029-02-20	LT-4831	21	41
1070	1274	2036-01-30	LT-9644	8	21
1071	6955	2031-06-26	LT-3594	13	9
1072	6994	2036-01-29	LT-9401	30	22
1073	8873	2029-04-01	LT-4610	16	22
1074	3818	2034-01-18	LT-6773	1	16
1075	5696	2027-12-07	LT-1017	1	45
1076	2298	2034-06-08	LT-3068	2	48
1077	7747	2033-09-04	LT-6706	8	24
1078	6594	2035-11-19	LT-0753	18	29
1079	3761	2034-03-07	LT-5425	30	21
1080	5686	2034-12-20	LT-0760	16	18
1081	8300	2027-02-08	LT-8667	5	17
1082	9712	2031-10-12	LT-5441	19	19
1083	3373	2032-11-28	LT-3849	20	6
1084	8088	2036-04-26	LT-4040	14	29
1085	4303	2028-12-14	LT-5059	4	5
1086	2863	2032-11-09	LT-6513	3	47
1087	5010	2028-03-26	LT-1294	18	19
1088	8734	2028-05-14	LT-7661	30	24
1089	5360	2034-03-07	LT-8214	15	2
1090	8045	2031-02-17	LT-3830	30	50
1091	8189	2035-01-10	LT-6828	24	36
1092	1965	2027-05-31	LT-1158	17	10
1093	8861	2031-04-14	LT-3653	25	18
1094	8085	2032-09-10	LT-1147	1	25
1095	4547	2035-10-13	LT-2628	3	41
1096	7462	2029-01-10	LT-9849	20	5
1097	3417	2028-08-27	LT-6013	12	19
1098	8789	2036-07-11	LT-8816	7	40
1099	8670	2028-07-04	LT-4096	19	5
1100	3775	2033-07-04	LT-6610	29	1
1101	1598	2035-11-26	LT-7439	26	12
1102	5922	2031-01-28	LT-4225	16	49
1103	5847	2033-01-21	LT-7932	17	36
1104	2129	2031-07-12	LT-0720	30	23
1105	9881	2033-02-01	LT-5796	19	18
1106	1465	2029-05-30	LT-9808	1	50
1107	4982	2029-11-29	LT-6589	21	8
1108	291	2035-12-13	LT-5336	21	14
1109	7130	2027-08-01	LT-1197	20	12
1110	4732	2031-09-20	LT-9910	16	12
1111	6513	2036-05-25	LT-2444	18	8
1112	9443	2032-05-22	LT-1366	19	1
1113	947	2030-11-11	LT-4277	17	7
1114	4519	2034-06-30	LT-2657	23	11
1115	1315	2029-01-14	LT-5044	19	19
1116	4386	2028-03-07	LT-3152	4	30
1117	394	2028-06-25	LT-2926	3	47
1118	4808	2032-08-24	LT-8855	3	24
1119	4588	2027-07-13	LT-2949	7	40
1120	2663	2032-05-16	LT-3268	28	17
1121	6105	2034-09-23	LT-6153	8	38
1122	5307	2035-11-17	LT-5858	8	49
1123	605	2029-03-08	LT-2059	21	13
1124	590	2027-03-02	LT-4103	24	15
1125	5012	2030-12-18	LT-3785	6	5
1126	2492	2035-11-28	LT-7466	4	16
1127	3879	2030-07-21	LT-8740	13	47
1129	1249	2032-10-30	LT-3608	1	35
1130	6747	2033-05-28	LT-7289	6	18
1131	8991	2030-06-09	LT-2188	21	7
1132	9130	2034-07-15	LT-9903	2	13
1133	5318	2031-11-04	LT-4050	30	9
1134	8153	2032-05-02	LT-7116	11	41
1135	7834	2036-05-31	LT-6203	22	5
1136	5214	2035-10-28	LT-8446	3	23
1137	7525	2030-05-18	LT-4578	25	23
1138	8158	2028-05-17	LT-7229	1	35
1139	2986	2030-08-14	LT-9116	27	4
1140	9647	2034-03-30	LT-2857	13	19
1141	3286	2028-05-18	LT-5974	18	38
1142	2095	2029-07-15	LT-0381	8	36
1143	1323	2032-02-22	LT-5704	19	37
1144	9430	2033-11-24	LT-2889	5	33
1145	574	2027-09-05	LT-5301	23	8
1146	6769	2030-07-22	LT-9634	6	22
1147	3848	2036-09-15	LT-4189	17	4
1148	6501	2035-05-17	LT-8966	20	18
1149	5642	2033-11-14	LT-1460	13	14
1150	1955	2029-08-29	LT-8722	4	16
1151	491	2026-10-08	LT-7407	21	35
1152	7323	2031-07-26	LT-7437	30	17
1153	3989	2036-03-07	LT-7847	21	5
1154	6275	2032-07-08	LT-0086	28	3
1155	5734	2030-04-25	LT-6683	13	49
1156	7809	2030-05-09	LT-3078	12	36
1157	1335	2027-10-19	LT-0304	7	13
1158	3583	2026-12-26	LT-6150	27	36
1159	2746	2027-03-05	LT-3176	9	33
1160	6295	2030-09-25	LT-8182	6	25
1161	1558	2036-02-13	LT-4162	4	29
1162	6092	2035-04-02	LT-0354	26	36
1163	7540	2031-07-20	LT-0756	4	15
1164	8878	2028-03-09	LT-0416	14	4
1165	9753	2027-02-07	LT-9439	7	45
1166	7449	2032-10-26	LT-2851	26	41
1167	516	2029-04-27	LT-0968	28	12
1168	4346	2030-10-24	LT-3961	8	38
1169	610	2032-01-25	LT-4017	8	45
1170	1520	2034-01-15	LT-5655	16	40
1171	2504	2032-09-30	LT-7182	7	17
1172	4114	2033-07-11	LT-4773	11	36
1173	4150	2033-09-24	LT-1489	17	7
1174	933	2030-01-04	LT-6424	12	27
1175	3286	2028-04-26	LT-7664	10	20
1176	7913	2031-03-16	LT-7674	17	12
1177	7029	2030-06-12	LT-9128	8	9
1178	1989	2036-09-01	LT-2339	2	43
1179	8806	2026-10-24	LT-5560	17	13
1180	3911	2033-11-11	LT-7927	20	9
1181	6762	2029-03-21	LT-2344	30	46
1182	5428	2034-04-14	LT-9418	28	33
1183	3885	2028-05-24	LT-9435	29	45
1184	1595	2031-03-28	LT-1359	7	48
1185	7360	2033-03-05	LT-4083	22	37
1186	2025	2032-04-18	LT-7655	19	29
1187	8787	2032-12-08	LT-1980	5	28
1188	6972	2032-02-15	LT-5560	5	37
1189	8030	2032-10-31	LT-4728	23	29
1190	6299	2033-07-22	LT-6436	28	36
1191	6379	2027-09-30	LT-3542	23	46
1192	4961	2027-06-15	LT-2727	11	28
1193	3494	2033-09-03	LT-1409	18	14
1194	7335	2035-06-11	LT-5542	12	45
1195	9852	2032-03-21	LT-4878	12	41
1196	220	2032-07-17	LT-7802	7	46
1197	6362	2033-05-12	LT-5501	8	25
1198	6168	2033-07-26	LT-1519	8	34
1199	6333	2028-01-27	LT-6444	1	11
1200	4564	2033-04-09	LT-6422	2	22
1201	344	2031-04-07	LT-4641	10	36
1202	8258	2029-10-20	LT-9866	24	45
1203	8955	2029-02-26	LT-9434	23	39
1204	3898	2028-10-09	LT-4052	6	4
1205	8812	2027-12-04	LT-6216	29	14
1206	4041	2035-07-12	LT-1481	22	37
1207	3595	2030-06-30	LT-8516	6	16
1208	1145	2035-11-15	LT-7639	3	9
1209	5654	2031-02-15	LT-6513	28	35
1210	282	2029-07-23	LT-8383	28	46
1211	8492	2032-05-09	LT-2400	17	50
1212	5329	2027-10-18	LT-6326	5	36
1213	7370	2028-01-14	LT-1339	2	16
1214	7798	2027-11-17	LT-6818	17	28
1215	7322	2028-10-10	LT-3758	6	35
1216	293	2035-08-15	LT-2586	30	16
1217	5622	2035-12-04	LT-4886	28	21
1218	5175	2027-08-30	LT-6140	18	28
1219	5957	2032-11-15	LT-0201	5	31
1220	1465	2026-12-07	LT-3296	11	48
1221	1907	2035-09-07	LT-7180	26	19
1222	4008	2028-08-21	LT-6587	27	29
1223	1691	2031-08-05	LT-6743	22	39
1224	9378	2028-12-14	LT-0378	29	33
1225	3877	2027-07-08	LT-0448	14	47
1226	158	2030-01-21	LT-4198	1	17
1227	1023	2029-07-26	LT-9143	27	17
1228	5427	2032-01-17	LT-3871	15	2
1229	6229	2029-03-13	LT-0584	20	34
1230	5883	2028-11-01	LT-3568	9	21
1231	7796	2029-05-03	LT-5780	19	11
1232	124	2032-09-09	LT-3947	4	8
1233	7392	2031-02-08	LT-7974	10	20
1234	6174	2036-05-18	LT-0083	16	3
1235	3112	2030-10-07	LT-6856	28	40
1236	4450	2031-03-25	LT-3920	18	18
1237	9781	2032-11-22	LT-7901	5	24
1238	7722	2034-07-14	LT-9646	1	8
1239	2281	2035-03-01	LT-3642	2	22
1240	8239	2030-04-10	LT-5158	17	43
1241	5186	2034-10-15	LT-3856	28	22
1242	1668	2033-01-11	LT-6029	13	45
1243	2547	2032-09-14	LT-9752	14	15
1244	4190	2035-01-13	LT-9928	14	32
1245	4247	2030-10-29	LT-5498	8	25
1246	10000	2029-09-02	LT-4738	26	23
1247	4302	2027-03-27	LT-7613	15	17
1248	4294	2028-04-25	LT-0018	3	1
1249	6323	2029-04-13	LT-0391	12	33
1250	1096	2035-11-20	LT-0239	12	46
1251	5846	2030-05-07	LT-9920	1	50
1253	757	2035-02-03	LT-0626	10	19
1254	5675	2026-11-16	LT-7260	6	11
1255	6214	2032-08-27	LT-2112	2	38
1256	6494	2034-04-04	LT-6737	13	7
1257	4643	2035-05-01	LT-6650	16	30
1258	3995	2027-09-06	LT-6655	17	2
1259	7180	2032-11-30	LT-8072	21	14
1260	4018	2032-10-08	LT-2091	23	9
1261	9375	2035-09-23	LT-2410	27	5
1262	5663	2026-12-01	LT-6038	8	18
1263	5398	2034-07-13	LT-7445	2	36
1264	9559	2028-04-12	LT-7196	8	49
1265	4423	2034-09-13	LT-9593	1	6
1266	8890	2035-07-15	LT-2792	14	7
1267	2771	2036-07-18	LT-7540	11	28
1268	4110	2031-05-23	LT-5194	23	50
1269	5489	2027-07-29	LT-6069	7	5
1270	1197	2032-06-17	LT-1805	15	10
1271	1959	2031-01-16	LT-0655	19	32
1272	177	2034-02-21	LT-5882	13	50
1273	7474	2033-10-17	LT-8876	13	32
1274	1792	2031-10-06	LT-2250	26	4
1275	8404	2032-09-09	LT-3787	26	48
1276	4059	2034-04-13	LT-3551	10	22
1278	7533	2029-11-14	LT-4386	19	5
1279	4819	2032-12-14	LT-6799	20	23
1280	5550	2033-04-20	LT-2489	24	21
1281	5733	2030-01-10	LT-9768	19	49
1282	5360	2032-01-26	LT-1647	12	35
1283	5738	2034-12-27	LT-3305	15	33
1284	3420	2027-03-27	LT-3755	2	6
1285	3424	2031-08-16	LT-0780	27	1
1286	9145	2027-08-13	LT-0463	24	21
1287	7261	2028-06-04	LT-9081	29	25
1288	9782	2033-04-19	LT-3526	29	24
1289	8885	2035-03-08	LT-0815	21	11
1290	8626	2035-12-31	LT-6577	27	18
1291	1042	2034-05-20	LT-2240	19	27
1292	3422	2036-03-20	LT-5294	23	25
1293	6650	2034-05-23	LT-0763	17	28
1294	602	2028-07-16	LT-4137	27	37
1296	2924	2029-01-29	LT-2056	18	7
1297	4860	2032-04-03	LT-7029	6	10
1298	2143	2034-06-21	LT-8346	20	5
1299	7546	2035-10-14	LT-2089	24	45
1300	6354	2030-06-17	LT-6128	22	48
1301	124	2027-08-16	LT-4537	27	42
1302	1453	2033-05-15	LT-0849	6	21
1303	2111	2028-02-16	LT-0343	5	1
1304	4469	2029-03-03	LT-9234	5	3
1305	473	2034-09-25	LT-2507	17	4
1306	6558	2026-10-31	LT-4229	29	20
1307	9946	2031-11-23	LT-8781	18	2
1308	7425	2032-03-04	LT-2409	30	32
1310	2310	2028-02-23	LT-3372	25	22
1311	1351	2035-09-19	LT-8657	1	32
1312	7436	2035-02-02	LT-2429	23	27
1313	7017	2032-11-24	LT-6020	2	8
1314	7934	2029-01-20	LT-5973	2	10
1315	2870	2033-12-12	LT-7914	12	20
1316	2048	2032-07-02	LT-6112	25	15
1317	1110	2032-01-27	LT-7186	26	23
1318	6947	2029-02-02	LT-4449	6	10
1319	5705	2033-12-27	LT-6439	16	31
1320	4242	2032-07-26	LT-2324	25	23
1321	5391	2029-11-21	LT-2727	21	33
1322	6866	2029-12-15	LT-1910	5	25
1323	9259	2030-09-28	LT-3667	28	14
1324	4275	2034-09-18	LT-3216	14	14
1325	1192	2029-06-08	LT-8838	7	21
1326	5820	2034-10-11	LT-8788	18	14
1327	5885	2030-04-11	LT-2934	16	25
1328	3424	2034-12-30	LT-2739	15	26
1329	8133	2029-03-26	LT-3822	14	3
1330	5933	2035-02-23	LT-6998	9	16
1331	3076	2034-03-29	LT-0498	15	50
1332	1442	2029-03-28	LT-3244	3	21
1333	6086	2033-04-23	LT-5620	16	16
1334	9322	2028-08-07	LT-5693	28	41
1335	4646	2030-09-26	LT-7417	7	41
1336	9813	2031-11-15	LT-0915	13	16
1337	2847	2027-04-14	LT-2836	7	5
1338	5103	2032-10-25	LT-7057	19	31
1339	5812	2027-12-18	LT-6286	29	26
1340	6156	2031-07-30	LT-9233	1	40
1341	5729	2027-01-25	LT-7637	22	23
1342	8497	2036-05-14	LT-8909	16	7
1343	7038	2027-11-05	LT-2954	3	7
1344	3310	2033-11-10	LT-9029	6	12
1346	4028	2032-05-04	LT-0110	28	39
1347	664	2032-11-04	LT-3124	10	7
1348	453	2031-06-26	LT-7748	24	42
1349	9474	2028-04-30	LT-0093	18	2
1350	9720	2029-03-13	LT-9928	1	43
1351	5682	2029-05-10	LT-2035	11	17
1352	3643	2036-09-24	LT-9746	3	49
1353	1700	2035-04-15	LT-9909	8	23
1354	7186	2028-05-12	LT-9710	13	9
1355	7146	2027-08-05	LT-5517	14	25
1356	422	2028-07-12	LT-2558	20	15
1357	8609	2034-01-05	LT-1510	20	5
1358	3612	2033-05-16	LT-4259	8	42
1359	255	2026-12-29	LT-5076	19	1
1360	8466	2027-01-26	LT-0496	20	39
1361	8331	2030-10-04	LT-2302	18	24
1362	2628	2035-10-08	LT-0048	5	30
1363	8245	2036-01-28	LT-6045	7	22
1364	7309	2033-06-21	LT-6718	1	49
1365	4597	2033-09-06	LT-8035	30	29
1366	8348	2036-01-16	LT-7312	5	18
1367	3517	2030-02-18	LT-5197	22	4
1368	1585	2032-11-19	LT-2846	13	22
1369	5992	2031-03-30	LT-6175	5	8
1370	8872	2036-03-09	LT-9573	26	24
1371	8332	2028-09-08	LT-3755	21	30
1372	5720	2032-02-27	LT-1753	10	19
1373	5964	2034-04-21	LT-1088	21	21
1374	5833	2027-07-31	LT-4008	9	28
1375	5164	2029-02-13	LT-3663	1	23
1376	6486	2031-03-20	LT-6582	4	32
1377	5934	2032-06-29	LT-1348	17	42
1378	8035	2034-01-21	LT-9492	3	30
1379	2564	2031-03-31	LT-6609	2	21
1380	1746	2028-04-28	LT-1430	1	5
1381	950	2028-11-08	LT-6769	28	21
1382	6449	2027-04-18	LT-3186	13	40
1383	3643	2027-05-09	LT-9611	27	43
1384	2818	2036-07-16	LT-8263	2	45
1385	3063	2029-11-27	LT-0076	2	2
1386	5204	2036-03-26	LT-2348	29	2
1387	8280	2032-01-23	LT-7398	5	36
1388	1001	2035-12-16	LT-0613	5	46
1389	8558	2034-04-20	LT-4910	10	49
1390	838	2031-03-21	LT-2828	25	16
1391	4381	2027-05-18	LT-5339	17	29
1392	7172	2035-11-30	LT-6110	24	33
1393	2369	2035-09-26	LT-7991	11	24
1394	7132	2036-04-25	LT-0677	17	49
1395	2103	2032-02-17	LT-2308	12	15
1396	5017	2026-12-29	LT-5988	3	5
1397	7280	2029-02-13	LT-4685	15	9
1398	8956	2030-09-19	LT-7875	25	9
1399	5668	2032-06-28	LT-7195	24	19
1400	7052	2033-01-10	LT-0180	6	41
1401	1595	2031-05-27	LT-2473	3	37
1402	7199	2031-11-05	LT-4993	6	6
1403	8108	2036-09-20	LT-5499	14	32
1404	4704	2033-04-24	LT-0714	25	33
1405	7533	2033-08-27	LT-3106	30	9
1406	430	2029-07-07	LT-1047	24	20
1407	3349	2033-12-15	LT-8613	15	38
1408	4980	2033-12-30	LT-1785	14	23
1409	3870	2027-01-12	LT-2513	22	15
1410	3409	2032-07-19	LT-1547	9	13
1411	219	2032-05-25	LT-5142	27	18
1412	8338	2036-05-26	LT-8766	27	20
1413	4292	2029-03-25	LT-1796	14	35
1415	8532	2027-04-22	LT-9574	21	46
1416	9699	2034-10-09	LT-3578	4	47
1417	5258	2030-10-02	LT-9942	10	22
1418	2381	2036-05-17	LT-1254	14	2
1419	3133	2027-11-20	LT-0036	16	31
1420	399	2032-07-26	LT-5408	11	35
1421	1151	2032-07-27	LT-8938	28	38
1422	8760	2027-08-31	LT-9660	2	2
1423	5774	2029-09-24	LT-7681	2	21
1424	822	2030-06-20	LT-1403	6	49
1425	6808	2034-07-10	LT-5118	15	9
1426	8381	2031-11-17	LT-8507	29	10
1427	5114	2032-05-08	LT-3120	12	20
1428	8312	2035-06-23	LT-0437	23	24
1429	3390	2028-10-09	LT-0288	22	38
1430	4183	2030-11-11	LT-1880	12	8
1431	6130	2027-01-26	LT-6136	11	50
1432	9046	2029-11-11	LT-6027	14	46
1433	7084	2032-01-26	LT-7903	30	26
1434	3258	2028-01-11	LT-0162	14	36
1435	2066	2027-01-12	LT-0917	26	4
1436	5842	2029-10-07	LT-6861	17	16
1437	7571	2032-03-11	LT-6518	15	3
1438	2991	2031-05-24	LT-3431	29	41
1439	7681	2026-11-24	LT-3297	12	8
1440	7646	2030-09-20	LT-2942	5	25
1441	4482	2028-12-26	LT-2771	10	45
1442	9745	2029-04-27	LT-4014	8	11
1443	1971	2034-11-23	LT-5075	28	26
1444	7653	2028-12-21	LT-3368	24	11
1445	6603	2027-05-10	LT-3564	20	50
1446	608	2031-02-04	LT-8450	27	49
1447	8070	2031-04-17	LT-0024	16	25
1448	3755	2027-01-17	LT-9537	6	10
1449	5905	2029-05-30	LT-9999	2	14
1450	9966	2030-09-13	LT-3946	27	36
1451	6026	2034-07-12	LT-3957	19	47
1452	8468	2033-05-19	LT-8574	11	12
1453	5288	2026-10-15	LT-4693	5	20
1454	4487	2030-02-26	LT-7441	9	2
1455	6609	2034-03-06	LT-8002	11	8
1456	9714	2028-10-18	LT-4846	11	14
1457	2416	2028-01-31	LT-2720	4	41
1458	1088	2030-08-30	LT-0109	15	36
1459	5853	2028-08-13	LT-4988	11	18
1460	3800	2032-06-18	LT-1957	8	50
1461	8714	2029-02-21	LT-1719	21	26
1462	971	2030-05-09	LT-9505	11	7
1463	8022	2031-03-05	LT-0223	2	15
1464	5650	2031-07-19	LT-1388	11	42
1465	4179	2033-12-15	LT-9456	7	18
1467	4562	2035-12-27	LT-8835	26	32
1468	9814	2028-12-24	LT-0017	9	30
1469	826	2033-07-06	LT-7354	1	32
1470	1730	2035-01-22	LT-0634	21	2
1471	4095	2035-09-12	LT-8866	5	33
1472	8204	2033-05-07	LT-5144	5	30
1473	3353	2029-12-19	LT-2142	15	27
1474	4334	2027-05-17	LT-9147	12	45
1475	4330	2032-06-29	LT-6441	29	16
1476	9047	2033-03-30	LT-5762	29	42
1477	818	2027-03-24	LT-5127	13	25
1478	8629	2030-01-27	LT-0048	24	17
1479	7276	2034-08-25	LT-8562	4	5
1480	975	2032-09-08	LT-1284	11	3
1481	1555	2028-06-28	LT-7719	20	4
1482	6406	2035-03-16	LT-7785	25	3
1483	7106	2027-05-09	LT-7311	14	43
1484	8714	2035-06-20	LT-9884	20	8
1485	2290	2030-05-16	LT-4496	19	34
1486	7710	2031-08-30	LT-8799	15	17
1487	503	2035-12-10	LT-3915	13	32
1488	8463	2034-07-12	LT-0882	25	40
1489	8502	2035-09-07	LT-2761	27	23
1490	6657	2034-12-10	LT-3421	24	19
1491	7916	2034-09-14	LT-1579	25	9
1492	3886	2029-09-03	LT-6536	28	40
1493	9818	2035-03-15	LT-7295	24	47
1494	6955	2030-11-25	LT-1738	10	12
1495	5031	2034-08-02	LT-1905	13	9
1496	3285	2033-01-11	LT-7633	7	11
1497	2804	2035-05-03	LT-7516	10	4
1498	1556	2030-04-21	LT-8718	17	1
1499	5683	2028-08-14	LT-0190	9	12
1500	3556	2031-11-07	LT-8628	7	46
\.


--
-- Data for Name: rango; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rango (id_rango, nombre_rango, nivel_jerarquico, sueldo_base) FROM stdin;
1	Cabo Nivel 1	1	3806.41
2	General Nivel 2	2	4503.13
3	Cabo Nivel 3	3	2967.74
4	Teniente Nivel 4	4	3097.67
5	Capitan Nivel 5	5	2907.02
6	Mayor Nivel 6	6	1272.72
7	Coronel Nivel 7	7	3887.78
8	Cabo Nivel 8	8	3449.21
9	Mayor Nivel 9	9	1541.60
10	Mayor Nivel 10	10	1414.46
11	Coronel Nivel 11	11	2667.28
12	Cabo Nivel 12	12	2222.80
13	Sargento Nivel 13	13	2765.26
14	Coronel Nivel 14	14	2059.43
15	General Nivel 15	15	3486.09
\.


--
-- Data for Name: soldado; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.soldado (id_soldado, nombres_apellidos, id_rango, id_especialidad, id_batallon, id_historial) FROM stdin;
1	Luz Serrano	15	34	55	1
2	Juan Carlos MartÃ­nez	9	16	22	2
3	Cindy Amaya Rivera	6	21	60	3
4	Luz Morales Pulido	12	14	90	4
5	Wilfredo Jaime Jaramillo GonzÃ¡lez	15	28	10	5
6	Luz HernÃ¡ndez	13	31	16	6
7	JesÃºs AndrÃ©s Medina	11	41	57	7
8	Marcela Mora	2	21	59	8
9	William Alberto DÃ­az	5	24	4	9
10	Paula Cruz Ramos	14	46	9	10
11	Lizeth RocÃ­o MartÃ­nez	11	16	78	11
13	Alejandra Liceth CastaÃ±o	4	12	81	13
14	Esther Salas	3	38	55	14
15	Viviana Polo	4	14	37	15
16	Adriana Stella LÃ³pez Gamboa	6	43	17	16
17	Alfonso BermÃºdez Morales	2	27	22	17
18	Liseth Esmeralda CuÃ©llar	9	28	100	18
19	Mauricio Sergio Contreras Vanegas	8	2	78	19
20	Edgar Antonio Forero	10	8	11	20
21	Patricia Silva Restrepo	8	1	11	21
22	Lorena Arias	7	10	59	22
23	Kelly Cecilia PeÃ±a GutiÃ©rrez	6	18	15	23
24	Alfredo Enrique Becerra	4	47	39	24
25	Eduardo PeÃ±a Tovar	8	41	5	25
26	Carolina Leonor Espinosa	3	37	16	26
27	Cecilia AngÃ©lica Valencia BenÃ­tez	5	33	51	27
28	Luz Cardona	13	35	78	28
29	Enrique Felipe Benavides	12	17	66	29
30	Humberto DÃ­az RincÃ³n	12	48	17	30
31	Natalia Ingrid SÃ¡nchez	11	42	60	31
32	Ancizar Gustavo Espinosa Posada	5	11	88	32
33	AngÃ©lica Ruth Montoya MuÃ±oz	9	12	51	33
36	Teresa Arrieta	6	42	68	36
37	Fredy RubÃ©n GonzÃ¡lez Agudelo	8	2	88	37
38	Helena Daniela Alvarado	2	48	67	38
39	Mauricio Juan FernÃ¡ndez	12	3	83	39
40	Edith Fabiola Guerrero Giraldo	7	26	31	40
41	MarÃ­a MarÃ­a DÃ­az GarcÃ­a	2	18	71	41
42	Elena HernÃ¡ndez	8	43	22	42
43	SebastiÃ¡n Rojas	13	40	49	43
44	MarÃ­a Castro	14	47	32	44
47	MarÃ­a Diana Guevara	5	49	90	47
48	Emilia Sandra Vargas Arias	2	49	59	48
49	Jair Bonilla Bustos	2	30	44	49
50	Santiago PÃ¡ez	5	50	29	50
51	Alex AndrÃ©s Perdomo	1	3	10	51
52	Rosa Barbosa Medina	10	13	10	52
53	Antonio Granados	9	22	22	53
54	Katerine Alejandra Uribe Ariza	8	29	22	54
56	Gladys Gil	14	50	64	56
57	Martha RodrÃ­guez	8	14	29	57
59	MarÃ­a Katherin GutiÃ©rrez	6	46	87	59
60	Nidia Castro	10	8	85	60
61	Mario Caro Mosquera	5	40	19	61
62	Alexander Jhon RodrÃ­guez	13	41	68	62
63	NicolÃ¡s Ovidio DÃ­az	4	42	45	63
64	Camilo MÃ©ndez Guevara	15	49	68	64
65	Miriam Rojas	5	21	71	65
66	Luis Ariza Alvarado	10	39	24	66
67	Paola Lorena GonzÃ¡lez	9	40	56	67
68	LucÃ­a Emilse Correa	15	28	2	68
70	Luis Oviedo	6	13	62	70
72	Carmenza Parra	10	25	71	72
73	Manuela Murillo Caicedo	4	5	48	73
74	RubÃ©n Bautista	3	18	56	74
75	Fredy Alfonso Arango Sierra	6	32	44	75
76	IvÃ¡n Sergio Toro	4	29	73	76
77	David Maldonado ChÃ¡vez	2	12	73	77
78	Jorge OrdÃ³Ã±ez Miranda	12	8	29	78
79	Viviana Leidy Ramos GÃ³mez	4	40	4	79
80	Ana Michel Restrepo	3	7	65	80
81	Yuly Vega SÃ¡nchez	8	16	73	81
82	Yolanda Manrique	8	1	15	82
83	Gabriel Mora	2	39	62	83
84	Rafael FlÃ³rez	11	29	16	84
85	Karol Galvis Acosta	14	37	77	85
86	MarÃ­a Claudia Fuentes Toro	14	5	66	86
87	Mercedes Josefina Mesa MartÃ­nez	12	46	22	87
88	Armando RubÃ©n Morales	11	17	39	88
89	Joan Soto Caicedo	6	15	30	89
91	Antonio Acevedo	7	47	59	91
92	Valentina Triana	8	45	40	92
93	Bernardo Cardona Mercado	1	7	16	93
94	AndrÃ©s Alberto Trujillo	12	30	55	94
95	RubÃ©n Restrepo	12	38	100	95
96	MarÃ­a Espinosa	5	39	2	96
97	Edwin Santos JimÃ©nez	13	44	84	97
98	Yamile GutiÃ©rrez RodrÃ­guez	4	19	15	98
99	Emilia Luz RamÃ­rez Bustos	12	30	66	99
100	Jhon Murillo Romero	15	46	31	100
101	Dagoberto RÃ­os Carrillo	5	26	64	101
102	LucÃ­a Palacios Arboleda	8	19	8	102
103	Sergio DÃ­az GutiÃ©rrez	5	34	37	103
104	Lorena Marcela Cruz	1	31	86	104
105	Patricia Enith Castillo	14	18	4	105
106	Natalia Cristina Cruz	15	7	91	106
107	Carlos Santiago MartÃ­nez	10	48	33	107
108	Dario VÃ­ctor Silva Silva	12	23	44	108
109	Ciro GonzÃ¡lez LÃ³pez	15	18	64	109
110	Yeny Cruz MuÃ±oz	15	32	70	110
111	Omaira MarÃ­n Vargas	2	44	50	111
112	Paula Arango GÃ³mez	13	21	73	112
113	Ferney Alberto Solano	11	20	29	113
114	Diana HernÃ¡ndez Rueda	15	1	86	114
115	Luis Galvis	8	4	56	115
116	Brayan GÃ³mez	1	10	93	116
117	Yury RocÃ­o Mosquera	1	22	52	117
118	Norma GÃ³mez Escobar	2	28	5	118
119	Antonio Freddy Ocampo GarcÃ­a	8	50	6	119
120	JosÃ© Rojas	15	3	87	120
121	MarÃ­a Adriana JimÃ©nez CuÃ©llar	2	9	44	121
122	JosÃ© Samuel Pineda	4	43	40	122
123	JesÃºs AndrÃ©s Riascos	7	46	79	123
124	Deicy GutiÃ©rrez Quintero	7	20	17	124
125	Martha Tatiana Moreno Montoya	1	37	72	125
126	Manuel Alexander PÃ©rez	12	1	17	126
127	Mery Cecilia LÃ³pez	11	37	74	127
130	Javier SÃ¡nchez	13	7	15	130
131	Yuly Alejandra Ortiz	12	12	99	131
133	Jhon Rojas	14	48	47	133
135	Jhon Palacio	12	17	93	135
136	AngÃ©lica Marina Figueroa	7	17	69	136
137	Roberto Zapata	8	18	93	137
138	Nelson RamÃ­rez	7	6	62	138
139	Darwin Javier Solano Villamizar	5	17	88	139
140	Luisa Heidy Zapata	4	28	64	140
141	Eduardo Cruz RamÃ­rez	7	5	4	141
142	JosÃ© Cruz	3	44	13	142
143	ConcepciÃ³n Romero HernÃ¡ndez	12	20	27	143
144	Juan Enrique Osorio	7	44	85	144
145	David Valderrama	6	36	47	145
146	Juliana Rojas	13	28	43	146
147	Alexis RenÃ© Pedraza Gamboa	1	34	88	147
148	Mariela Viviana CalderÃ³n	4	19	75	148
149	Wilmer JosuÃ© MartÃ­nez Delgado	4	7	43	149
150	MarÃ­a Antonia PÃ¡ez Cruz	13	46	40	150
151	CÃ©sar Nelson Fonseca	15	36	37	151
152	Yuliana Ana RamÃ­rez	4	43	96	152
153	Marina Fernanda Acosta Caicedo	2	6	50	153
154	Elena MuÃ±oz	5	2	43	154
155	NicolÃ¡s Correa	6	34	42	155
156	Yesid AndrÃ©s Guerrero Velandia	1	23	14	156
157	Emilio Armando Ceballos Moreno	3	15	100	157
158	Marina Leonor Ibarra Maldonado	8	25	100	158
159	Emilio HernÃ¡ndez Mora	1	39	97	159
160	JosÃ© BeltrÃ¡n	14	23	39	160
161	Alexander Torres Medina	7	23	83	161
162	Yineth RenterÃ­a Arias	6	39	37	162
163	Alberto Alexander LÃ³pez	2	23	22	163
164	Leidy Helena Acevedo	11	23	60	164
165	AngÃ©lica HernÃ¡ndez Castro	3	42	45	165
166	Patricia Nelly Ruiz Mena	10	19	28	166
167	Andrea Zapata	15	3	29	167
168	Diego Polo	1	47	84	168
170	Milena Torres	2	33	92	170
171	Nancy GutiÃ©rrez Bonilla	15	19	60	171
172	Olga LÃ³pez	1	15	10	172
173	Rodolfo Jeison Arango Benavides	12	39	96	173
174	Alejandra Magaly RincÃ³n Palacios	3	1	43	174
175	Lorena Mora	9	34	36	175
176	Salvador GonzÃ¡lez	3	41	34	176
177	Yesenia Mantilla	15	10	72	177
178	NicolÃ¡s MejÃ­a	5	25	63	178
179	Lina MartÃ­nez	14	37	100	179
180	VÃ­ctor Henry Chaparro Lozano	13	28	33	180
181	Antonio Domingo Rojas Mercado	11	9	95	181
182	Daniela Alejandra Ruiz	9	5	23	182
183	Milena MarÃ­a Barreto	3	17	59	183
184	Luis Acevedo	3	8	87	184
185	Marcela Elvia GonzÃ¡lez Rivera	10	47	35	185
186	Adriana Josefina Caballero Ruiz	4	6	19	186
187	Alirio John MartÃ­nez	6	15	48	187
188	Vicente Esteban Bedoya PÃ©rez	15	37	52	188
189	Juan Luis Morales	3	45	4	189
190	Laura Elena LÃ³pez	13	21	75	190
191	Adriana MarÃ­a Morales Jaimes	2	49	43	191
192	Leonardo Mauricio Blanco	10	48	3	192
193	Luis Pinto BenÃ­tez	5	50	1	193
194	Rosalba Katherine SÃ¡nchez GonzÃ¡lez	13	9	84	194
195	Katherine Marleny GonzÃ¡lez	10	46	29	195
196	MÃ³nica Dayana Duarte Rojas	8	33	96	196
197	Cecilia MarÃ­a Navarro Henao	3	43	2	197
198	Judith Luz Carvajal	15	27	95	198
199	Alejandro Jorge RodrÃ­guez Valderrama	15	7	97	199
200	Alicia Camila RodrÃ­guez	14	8	38	200
201	Anderson CalderÃ³n	2	7	97	201
203	Rosa Eugenia Castro RodrÃ­guez	10	5	45	203
204	Mauricio Willian Cardona MuÃ±oz	5	37	87	204
205	JosÃ© AndrÃ©s LÃ³pez	10	15	23	205
207	JosÃ© Ardila Castro	11	22	16	207
209	Andrea Viviana SÃ¡nchez Quiroga	14	3	44	209
210	Juan Humberto Alfonso	7	28	53	210
211	John AndrÃ©s RÃ­os	3	28	66	211
212	JosÃ© Moreno Caicedo	10	32	45	212
213	Harold Rueda Miranda	6	5	35	213
214	JesÃºs Arturo Amaya	4	18	42	214
215	Leidy Isabel Chaparro Fonseca	2	45	100	215
216	Sandra Patricia GÃ³mez	9	24	27	216
217	LucÃ­a Milena Acevedo Buitrago	12	29	31	217
218	HernÃ¡n Leonardo Escobar	10	2	42	218
219	Manuel SuÃ¡rez Andrade	12	36	21	219
220	Alberto JoaquÃ­n Valencia JimÃ©nez	1	16	31	220
221	Rodrigo Carlos Mesa GÃ³mez	5	37	76	221
222	Julia CastaÃ±o Forero	2	20	7	222
223	Nelly Martha GutiÃ©rrez	4	50	31	223
224	Luis MuÃ±oz	4	26	56	224
225	Fidel AndrÃ©s RÃ­os	9	19	22	225
226	Isabel Norma Navarro	2	9	93	226
227	AndrÃ©s Brian Figueroa	2	20	65	227
228	Yolanda PÃ¡ez	10	19	32	228
229	Jairo Delgado	1	12	71	229
230	Diego Luis Cano	14	3	35	230
231	Marina Carolina Acosta Ortiz	8	24	38	231
232	Jhon VelÃ¡squez	13	40	59	232
234	Ana Caicedo SÃ¡nchez	13	25	72	234
235	Fernando Galindo	12	28	98	235
236	Guillermo Felipe VÃ©lez Espinosa	1	19	43	236
237	Alejandro CÃ¡rdenas	9	32	77	237
238	Jaider RodrÃ­guez Giraldo	1	16	17	238
239	Marcela Cindy Ortiz RÃ­os	12	4	99	239
240	Elena Esperanza Barreto Rosero	14	17	23	240
241	Fredy Carlos Uribe MartÃ­nez	3	36	91	241
242	Ruth Consuelo Espinosa Hoyos	7	37	14	242
243	Orlando RubÃ©n Mena Castro	2	31	17	243
244	Mauricio Alexander Leal	6	17	75	244
245	Consuelo Sandra Giraldo DÃ­az	7	7	60	245
246	Rodrigo Arias	1	41	28	246
247	Eugenia Paola GarcÃ­a Gallego	4	35	14	247
248	Rosa GonzÃ¡lez Castillo	10	12	3	248
249	Oswaldo Ospina Cuesta	8	25	11	249
250	Lorena MarÃ­a Moreno	9	1	49	250
251	Eduardo Juan GarcÃ­a	8	41	45	251
252	Juliana Ariza	11	46	61	252
253	Mary Diana Barrios	14	8	22	253
254	Carlos Javier Soto Mosquera	14	36	48	254
255	Gregorio Mauricio GarcÃ­a	9	6	16	255
256	Yesid CastaÃ±eda GarcÃ­a	9	37	6	256
257	Miguel JosÃ© GarcÃ­a	5	37	63	257
258	Teresa Karina Prieto Salas	15	39	40	258
259	AndrÃ©s Carlos Ramos RodrÃ­guez	3	1	92	259
260	Juan Moreno NiÃ±o	12	37	95	260
261	Liliana Yulieth Vergara	7	13	74	261
262	FabiÃ¡n Estrada Jaramillo	6	47	13	262
263	Karen Angie Aguilar DÃ­az	12	2	45	263
264	Adalberto David MarÃ­n	1	40	29	264
265	Rosa Yohana Escobar	1	28	48	265
266	Octavio Jhon Arias CastaÃ±eda	14	48	4	266
267	Patricia JimÃ©nez GarcÃ­a	2	1	15	267
268	Felipe Diego Nieto	12	19	50	268
269	Isabel Mendoza Osorio	15	20	64	269
270	Harvey Forero	4	31	66	270
272	JesÃºs Esteban Castro PeÃ±a	12	41	10	272
273	Jorge RomÃ¡n Navarro	2	8	60	273
274	Flor DÃ­az MartÃ­nez	9	28	21	274
275	Ana Helena HernÃ¡ndez	15	21	93	275
276	Johan RaÃºl RamÃ­rez Franco	2	48	9	276
277	Didier Carlos GonzÃ¡lez LÃ³pez	4	14	43	277
278	Fernanda Jenny Quintero Pacheco	13	41	32	278
279	JosÃ© Osorio Rojas	5	15	32	279
280	AndrÃ©s NÃ©stor LondoÃ±o	2	21	46	280
281	Eduar GonzÃ¡lez	4	19	11	281
282	Cristian JosÃ© MartÃ­nez Ortiz	4	8	7	282
283	Luis Stiven Valencia	8	46	22	283
284	Yolanda Ramos	4	48	68	284
285	Lizeth DÃ­az Monsalve	6	15	66	285
286	Sonia Blanca HernÃ¡ndez Quintero	2	41	54	286
287	Felipe JosÃ© Correa Rojas	5	11	82	287
288	Ã“scar Juan Chaparro	15	11	13	288
289	Luz HernÃ¡ndez Ayala	15	36	17	289
290	Consuelo Isabel Torres	3	50	51	290
291	Sandra RodrÃ­guez RamÃ­rez	10	34	66	291
292	Enrique Acevedo	12	7	51	292
293	Flor Damaris Pacheco Rivera	11	22	1	293
294	Felipe Alejandro Rengifo	5	16	34	294
295	JosÃ© Stiven Guerra Ballesteros	4	33	81	295
296	Daniela Natalia Cabrera Franco	3	48	24	296
297	William Morales Quintero	2	20	54	297
298	Robinson AndrÃ©s BermÃºdez	6	17	45	298
299	Diana Dayana Torres	3	17	15	299
300	MarÃ­a MarÃ­a Barbosa Manrique	1	1	71	300
301	Antonio Barreto	2	33	46	301
302	Fabio Adolfo RodrÃ­guez	14	40	16	302
303	Eliana MarÃ­a GÃ³mez	10	42	82	303
304	Dayana MÃ¡rquez	9	41	70	304
305	Carolina Delgado	13	1	94	305
306	Angie Luz GÃ³mez Caicedo	5	44	52	306
307	Luz Victoria Rueda Morales	14	6	2	307
308	Manuel Villegas CastaÃ±eda	6	48	34	308
309	Rosa Ester SÃ¡nchez	14	18	85	309
310	Alejandro Carlos Giraldo CÃ³rdoba	14	44	32	310
311	Luz Guevara	9	27	3	311
312	Alexander BermÃºdez Cardona	15	33	99	312
313	Karen CastaÃ±o NiÃ±o	2	12	48	313
314	Adriana Daniela RamÃ­rez	12	30	91	314
315	Luis CÃ©sar Murcia	12	46	38	315
317	Angie Marleny BermÃºdez Ospina	12	1	66	317
318	JuliÃ¡n Maicol Prieto PÃ©rez	13	38	43	318
319	Carolina DÃ­az	10	26	14	319
320	Samuel GutiÃ©rrez	12	35	27	320
321	Guillermo SÃ¡nchez	14	2	84	321
322	MÃ³nica Gilma Barbosa Contreras	12	28	67	322
323	Enrique Diego LÃ³pez Vallejo	12	34	73	323
324	AndrÃ©s Vega	10	29	39	324
325	Sonia GarcÃ­a	8	47	57	325
327	Luz Margarita Lara MartÃ­nez	6	26	21	327
328	Silvia GÃ³mez Restrepo	6	31	91	328
329	AgustÃ­n Alexis LÃ³pez	6	20	26	329
330	Arnulfo Bernal	14	16	83	330
331	David RincÃ³n	3	8	19	331
332	JosÃ© Uribe	7	32	35	332
333	Luz Stella GutiÃ©rrez	2	35	33	333
334	Margoth Sandra Cano	10	26	28	334
335	Ana Tamayo PinzÃ³n	4	50	10	335
336	Jenny Patricia RincÃ³n	6	36	19	336
337	Paola Francia FlÃ³rez	10	14	49	337
338	MarÃ­a Moreno Camargo	8	26	77	338
339	Liliana Toro Acosta	8	39	83	339
340	Carmen Alix Montoya Duarte	4	46	15	340
341	John Edgar Corredor GonzÃ¡lez	14	36	22	341
342	Andrea Fernanda Buitrago	3	37	96	342
343	Alberto Miguel MartÃ­nez	14	37	82	343
344	Liliana Miranda Rivera	14	6	4	344
346	Jairo Ã“scar Salazar	8	35	50	346
347	Cristina Victoria Romero	12	36	72	347
348	Ester FernÃ¡ndez	12	1	64	348
349	MarÃ­a Daniela VÃ¡squez Saavedra	3	7	12	349
350	MÃ³nica Ortega	7	14	51	350
351	Rosa GÃ³mez	4	50	58	351
352	David Eduardo RenterÃ­a Caballero	8	11	78	352
353	LucÃ­a Juliana GonzÃ¡lez	10	4	73	353
354	Gustavo Becerra	8	1	77	354
355	Alexander Buitrago	2	9	6	355
356	Gabriela PÃ©rez Delgado	12	15	82	356
357	Eduard Arroyo Sarmiento	11	48	98	357
358	Marina PeÃ±a	5	30	47	358
359	Aldair PeÃ±a Rivera	6	7	1	359
360	AndrÃ©s DÃ­az	14	45	53	360
361	Andrea Rivas	4	17	4	361
362	Carlos Guerrero MuÃ±oz	10	31	39	362
363	Gina Ana Henao Vargas	10	8	11	363
364	MarÃ­a Patricia Franco	10	26	93	364
365	Omar Caballero Gil	4	34	12	365
366	Eduardo GuzmÃ¡n	9	35	72	366
368	Tania Natalia GÃ³mez Mercado	7	40	24	368
369	Luz EstefanÃ­a Sarmiento CÃ³rdoba	5	47	24	369
370	Johanna Carolina Romero	2	40	69	370
371	MarÃ­a Isabel Ortega RodrÃ­guez	12	20	57	371
372	Fernanda Molina SÃ¡nchez	7	19	33	372
373	SofÃ­a Amelia Perea Ochoa	4	19	40	373
374	Milena Mora Romero	9	48	30	374
375	Alejandra MarÃ­a Arenas Guevara	14	43	88	375
376	Ã“scar CÃ©sar Carvajal Villa	10	39	68	376
377	Nathalia Paola Bernal	8	17	94	377
378	Patricia Reyes Navarro	13	32	33	378
379	Isabel Isabel Melo Estrada	6	20	63	379
380	Gabriel SaÃºl DÃ­az	3	19	33	380
381	Harvey IvÃ¡n GarcÃ­a	1	38	17	381
382	Elizabeth Elena Molina Montenegro	14	49	74	382
383	Jorge Manuel Medina DÃ­az	2	10	78	383
384	Beatriz GarcÃ­a	5	5	70	384
385	Franco Carlos Herrera	12	6	41	385
386	Alexander Felipe GutiÃ©rrez	5	44	83	386
387	Henry David Ramos Ortiz	10	7	35	387
388	Amalia Caicedo	15	39	44	388
389	John AndrÃ©s Meza	4	49	72	389
390	Rosalba GarcÃ­a	1	14	98	390
391	CÃ©sar Carlos Salcedo	15	33	55	391
392	LucÃ­a RodrÃ­guez	7	32	67	392
393	Edgardo Jaider HernÃ¡ndez HernÃ¡ndez	9	11	99	393
394	Antonio Dario Guerra	5	38	18	394
395	Jonathan Luis Sierra Lozano	2	41	63	395
396	Antonio Fabio Quintero Sanabria	15	31	4	396
397	Cristian AndrÃ©s RodrÃ­guez	1	25	33	397
398	Ocampo FlÃ³rez	12	41	66	398
399	Albeiro Gustavo Becerra Caicedo	3	36	78	399
400	Magdalena MarÃ­a MejÃ­a	10	5	67	400
401	AndrÃ©s Roberto VÃ¡squez Bernal	1	46	47	401
402	Dairo Gil	6	19	54	402
403	Johana Restrepo	15	29	60	403
404	Esperanza Torres	2	48	32	404
405	MarÃ­a GutiÃ©rrez Uribe	6	22	1	405
406	Jhonatan DurÃ¡n	7	1	85	406
407	Dairo Jorge Sierra	6	2	7	407
409	Jorge CastrillÃ³n Vera	14	15	76	409
410	Jorge Velasco Ruiz	3	19	10	410
411	Jhon Adolfo PÃ©rez Barreto	12	24	22	411
412	JosÃ© James Vergara	6	33	22	412
413	Andrea Ortiz	4	47	55	413
414	Jairo Agudelo	1	49	6	414
415	LucÃ­a RodrÃ­guez	2	5	81	415
416	Eduardo Herney Montoya	1	31	74	416
417	Johan CÃ©sar MartÃ­nez	4	24	68	417
418	Luis Daza	14	46	91	418
419	Andrea Gloria Espitia Morales	8	10	65	419
420	Pedro Antonio Toro	11	45	37	420
421	Julia LondoÃ±o Meneses	2	14	50	421
422	Jean NarvÃ¡ez	4	42	18	422
423	JuliÃ¡n PeÃ±a Moreno	10	14	39	423
424	Henry Efrain Herrera Barrera	9	10	42	424
425	Mariana Moreno	14	17	11	425
426	Yeny Daniela DurÃ¡n	12	1	96	426
427	Beatriz Arias Ruiz	7	40	13	427
428	Elena Herrera HernÃ¡ndez	3	43	16	428
429	Marcela Juana Toro Sanabria	3	4	76	429
430	Martha Romero Ortega	15	48	78	430
432	Mercedes Castillo	14	43	78	432
434	NicolÃ¡s Riascos PeÃ±a	11	13	56	434
435	Nidia RamÃ­rez	9	25	66	435
436	Edwin GarcÃ­a	5	19	33	436
438	Carlos GarcÃ­a	15	2	46	438
439	Fernanda MarÃ­a Acosta SÃ¡nchez	7	39	88	439
440	David Juan Benavides CastaÃ±o	14	10	73	440
441	Luz Maribel PÃ©rez Mendoza	1	34	47	441
442	JesÃºs Camilo Mosquera	15	8	54	442
443	Liliana Amparo HernÃ¡ndez Castro	11	6	82	443
444	Nelson Daniel Zapata	6	34	1	444
445	Francy Diana Mosquera Romero	3	32	31	445
446	Alfonso JosÃ© Daza Mosquera	12	21	63	446
447	Ana GutiÃ©rrez Daza	1	32	47	447
448	Cristina MarÃ­a Carmona	3	29	91	448
449	Armando Pinto	1	36	42	449
450	AndrÃ©s Ruiz	12	22	26	450
451	Gloria Jenny Ruiz Polo	4	19	31	451
452	Henry Castro RodrÃ­guez	3	15	62	452
453	Nilson Orlando SÃ¡nchez	9	1	35	453
454	Doris Melissa Vargas BenÃ­tez	4	18	77	454
455	Gladis MarÃ­a HernÃ¡ndez PÃ©rez	14	21	5	455
456	Dina JimÃ©nez	5	37	23	456
457	Juan Jean Ortiz	12	49	31	457
458	Alexandra Daniela Barrera Parra	10	41	32	458
459	Paola MarÃ­a MejÃ­a	8	15	30	459
460	Milena Vargas CalderÃ³n	15	38	72	460
461	Sonia Isabel Ortiz Mosquera	8	4	42	461
462	Yineth Moreno RincÃ³n	9	17	36	462
463	Fernanda Judith MartÃ­nez RodrÃ­guez	9	30	45	463
464	Lorena MuÃ±oz Galvis	2	30	21	464
466	Eduardo Adolfo GonzÃ¡lez Giraldo	14	7	10	466
467	Alfonso Alberto Vera PÃ©rez	9	4	56	467
468	Carlos Manuel MartÃ­nez	2	28	24	468
469	Luisa GÃ³mez Franco	4	30	2	469
470	SebastiÃ¡n SebastiÃ¡n PÃ©rez	12	40	70	470
471	Pablo Libardo Burgos Caicedo	3	5	81	471
472	Armando Gallego MartÃ­nez	7	5	22	472
473	AndrÃ©s Rafael Agudelo Rivera	9	30	97	473
474	Alberto Esteban MarÃ­n Daza	15	14	84	474
475	Deiby HernÃ¡ndez Ruiz	14	21	17	475
476	Carlos PÃ©rez Rivera	6	44	48	476
477	Betty Nidia Medina	9	14	5	477
478	Mercedes Edna Ruiz NÃºÃ±ez	1	2	38	478
479	Raquel Carmen Palacios GarcÃ­a	9	21	50	479
480	Karina Lina Leal GonzÃ¡lez	5	9	4	480
481	Valeria NiÃ±o RodrÃ­guez	12	44	72	481
482	Cristian Danilo Torres	14	26	84	482
483	Rolando Luis SÃ¡nchez	5	5	63	483
484	Julio Agudelo	3	25	65	484
485	Luis EfrÃ©n Valderrama	5	48	15	485
486	Libardo GÃ³mez LÃ³pez	11	15	38	486
487	MarÃ­a Contreras GonzÃ¡lez	12	7	74	487
488	Leonardo Humberto Acevedo Ardila	4	29	40	488
489	MarÃ­a Cecilia Caicedo	7	7	43	489
490	Enrique AndrÃ©s GaitÃ¡n	1	36	24	490
491	Brayan Eduardo MartÃ­nez CalderÃ³n	14	18	67	491
492	JesÃºs Luis Contreras Cardozo	11	33	5	492
493	Johana Contreras DÃ­az	12	1	7	493
494	Jorge DÃ­az	1	5	61	494
495	Victoria MarÃ­a GutiÃ©rrez	6	49	42	495
496	RubÃ©n PatiÃ±o Cuesta	11	49	94	496
497	Enrique Jaime Valderrama	9	40	70	497
498	RocÃ­o GÃ³mez Acosta	5	35	18	498
499	Juliana GonzÃ¡lez Trujillo	8	1	87	499
500	Felipe Faber Morales	1	42	24	500
501	Nancy Mora	6	33	22	501
502	Nelcy MarÃ­a Ospina	11	29	66	502
503	JosÃ© AnÃ­bal Vera	8	38	70	503
504	JesÃºs Acosta	6	36	58	504
505	Milena Mercedes Posada	1	47	53	505
507	Josefa DÃ­az	13	49	77	507
508	YÃ©sica Trujillo	2	12	76	508
509	Consuelo Uribe Navarro	14	6	19	509
510	Liliana Cruz MartÃ­nez	2	48	57	510
511	Betty Gloria Amaya	3	24	81	511
512	Mercedes DomÃ­nguez GonzÃ¡lez	1	6	21	512
513	Vanessa Montenegro	11	19	97	513
514	Francisco JimÃ©nez Duque	15	2	36	514
516	Alcira Gloria Pardo Romero	15	25	27	516
517	AndrÃ©s Richard Arias Moreno	6	23	48	517
518	MarÃ­a Yenny Riascos	7	9	32	518
519	Margarita Herrera	14	15	29	519
520	Hilda GÃ³mez	10	39	75	520
521	Fernando Marco Guerrero	14	47	6	521
523	Humberto AndrÃ©s MejÃ­a	8	48	30	523
524	Enrique RamÃ­rez Acosta	12	10	32	524
525	MarÃ­a Alicia Anaya	4	7	81	525
526	Julia Carolina Barrios	4	8	75	526
527	Rosa MuÃ±oz Gil	12	43	85	527
528	Gladys MartÃ­nez Bernal	8	1	24	528
529	Yaneth MarÃ­a Morales HernÃ¡ndez	5	13	51	529
530	Camilo Salazar Acevedo	1	44	84	530
531	Ana GutiÃ©rrez	12	19	9	531
532	MarÃ­a Carmen GutiÃ©rrez	8	45	16	532
533	Karen Angie VelÃ¡squez	12	39	11	533
534	Natalia Paola BermÃºdez	10	37	54	534
535	Diana Arrieta RÃ­os	9	6	91	535
536	Julio Enrique HernÃ¡ndez	1	1	63	536
537	Antonio Ã“scar GuzmÃ¡n Mosquera	14	24	44	537
538	VÃ­ctor HernÃ¡n MartÃ­nez	2	36	37	538
539	Jorge Antonio Riascos	6	20	85	539
540	JosÃ© Daniel Pedraza	6	16	86	540
542	Alexander Miguel Espitia	14	12	76	542
543	Olga Xiomara Silva	1	21	75	543
544	Freddy Jorge RodrÃ­guez Henao	10	47	64	544
545	Diego Trujillo PeÃ±a	5	36	86	545
546	AndrÃ©s AdriÃ¡n VelÃ¡squez Sierra	1	50	88	546
547	AdriÃ¡n Roa FlÃ³rez	3	17	40	547
548	RocÃ­o LÃ³pez	12	19	3	548
549	Margarita Alba SÃ¡nchez	12	34	46	549
550	Gloria RamÃ­rez LeÃ³n	11	32	53	550
551	David BermÃºdez	4	1	66	551
552	Libia GuzmÃ¡n	15	30	31	552
553	Nubia Elena Romero OrdÃ³Ã±ez	1	47	42	553
554	Natalia Meza	11	47	53	554
556	Henry Daza Moreno	15	27	83	556
557	Antonio JosÃ© RodrÃ­guez RincÃ³n	3	50	92	557
558	JesÃºs Alberto Villegas DÃ­az	9	22	88	558
559	Luz Elena Pineda	13	4	42	559
561	Alonso Luis Prieto LÃ³pez	8	5	79	561
562	Katherine Mesa	10	12	49	562
563	Enrique Jhon Saavedra Rojas	7	37	3	563
564	Rosa Camila Villamizar	4	15	40	564
565	Carolina MarÃ­a Sierra	12	25	65	565
566	Eduardo Luis LondoÃ±o Granados	7	25	69	566
567	Francy Espinosa RenterÃ­a	5	18	39	567
568	Alicia Pineda	4	8	61	568
569	Paola Mery GarcÃ­a BenÃ­tez	15	16	9	569
570	Alba GarcÃ­a	9	8	66	570
571	Beatriz Milena Reyes	10	10	53	571
572	Elvira Karol PÃ©rez	14	37	41	572
573	Alejandra Guerrero Villegas	3	22	9	573
574	Kevin RodrÃ­guez Soto	6	12	65	574
575	Alix MarÃ­a Zuluaga Sierra	4	46	78	575
576	Omaira RocÃ­o Romero	13	49	15	576
577	JosÃ© Jorge MarÃ­n Rueda	8	19	84	577
578	Elizabeth RocÃ­o Cabrera Figueroa	3	17	16	578
579	NicolÃ¡s RamÃ³n GonzÃ¡lez Ramos	1	17	23	579
580	SebastiÃ¡n SebastiÃ¡n BeltrÃ¡n	2	40	37	580
581	Alexander Aguirre	5	26	7	581
582	Janeth Luz Barreto LondoÃ±o	13	11	49	582
583	Laura Mirian Palacio	3	38	26	583
584	Ana Angulo FlÃ³rez	8	31	83	584
585	CÃ©sar Jhon Restrepo GarcÃ­a	13	3	83	585
586	Milena Nelly Torres OrdÃ³Ã±ez	8	44	12	586
587	Gloria Soto	13	38	65	587
588	Milena MarÃ­a RamÃ­rez	14	10	93	588
589	Orlando Arteaga	12	34	11	589
590	Arbey CastaÃ±o Torres	6	39	51	590
591	MarÃ­a Osorio Molano	10	15	97	591
592	Margarita Quintero FlÃ³rez	9	47	68	592
593	MarÃ­a Tatiana Carvajal Restrepo	5	40	25	593
594	Liliana Granados PÃ©rez	3	6	49	594
595	Fernando Pulido	5	25	65	595
596	Yolanda Katerine Silva Yepes	11	2	58	596
597	Natalia Ana RamÃ­rez Medina	11	1	100	597
599	MarÃ­a SÃ¡nchez PÃ©rez	11	29	22	599
600	Dora Ruiz Nieto	1	37	36	600
601	Henry RodrÃ­guez	14	18	86	601
602	William Campo Correa Pedraza	10	42	41	602
603	Alberto CÃ³rdoba	3	24	17	603
604	Alejandro SÃ¡nchez	9	41	100	604
605	Miguel Fredy LÃ³pez Correa	4	29	19	605
606	JosÃ© Vargas MartÃ­nez	4	32	11	606
607	Carlos AndrÃ©s SÃ¡nchez	4	26	4	607
608	MarÃ­a GarcÃ­a Caro	15	17	9	608
609	Javier Mena	13	13	55	609
611	Fredy FabiÃ¡n BenÃ­tez	14	45	97	611
612	Alexander GarcÃ­a	15	17	81	612
613	Lina Ballesteros MuÃ±oz	3	26	63	613
614	Blanca Luz Espinosa RodrÃ­guez	15	14	14	614
615	Gloria Forero	3	43	27	615
617	IvÃ¡n Alberto Castro	8	49	49	617
618	Patricia NÃºÃ±ez MarÃ­n	2	10	22	618
619	MarÃ­a Gladys Caicedo Salgado	2	50	81	619
620	Marcela Bonilla HernÃ¡ndez	8	4	28	620
621	NÃ©stor Enrique Ortiz Rivera	12	47	3	621
622	Vanesa Lorena Salas	8	30	97	622
623	Sneider SimÃ³n Ceballos	12	45	36	623
624	Felipe Wilson Trujillo GonzÃ¡lez	2	24	52	624
625	Alberto Mesa	6	45	94	625
626	Aura Estella Romero Herrera	8	45	63	626
627	JosÃ© FlÃ³rez	11	40	75	627
628	Jaime Alejandro Herrera Sierra	4	29	34	628
629	Fabio Emilio Fuentes	15	11	14	629
630	CÃ©sar Gil	2	26	42	630
631	Johana Ortega LÃ³pez	15	26	66	631
632	JosÃ© Carlos Acosta	13	6	10	632
633	Sandra Bastidas	12	14	87	633
634	JuliÃ¡n Francisco Medina	11	40	66	634
635	AndrÃ©s Bernal	4	44	18	635
636	Luis Bautista	8	5	85	636
637	Cristian Pablo GonzÃ¡lez	14	2	93	637
638	Vanesa FlÃ³rez Mendoza	10	1	67	638
639	Anyi Elizabeth Meza	7	9	74	639
640	Jhoan JosÃ© Ramos	9	28	39	640
641	Gina Oviedo Ruiz	14	31	2	641
642	JosÃ© Guillermo RodrÃ­guez Serna	12	26	6	642
644	Giovanni VÃ¡squez SÃ¡nchez	8	46	67	644
645	Francisco AndrÃ©s GuzmÃ¡n	9	14	38	645
646	Deisy Ingrid Ardila Cano	15	43	45	646
647	Marcela Consuelo Delgado Becerra	10	6	51	647
648	Miriam Diana GÃ³mez Becerra	14	49	60	648
649	Laura Delgado Rojas	1	48	85	649
650	Ever JimÃ©nez	5	11	42	650
651	JosÃ© Carlos GutiÃ©rrez	15	21	74	651
652	SebastiÃ¡n Mora Naranjo	5	6	35	652
653	Aleida Silva Mora	8	3	88	653
654	MarÃ­a Paola Ortega	6	31	87	654
655	Julio Roger PinzÃ³n	10	49	33	655
656	AndrÃ©s Torres	6	29	48	656
657	Clemencia Moreno	13	17	16	657
658	Carlos CastaÃ±o	15	3	99	658
659	Fredy Neider Meza	4	4	47	659
660	Janneth Arrieta	8	6	42	660
661	Aura DurÃ¡n LÃ³pez	2	7	82	661
662	Luis Ã“scar Padilla Ojeda	3	29	74	662
663	VÃ­ctor LÃ³pez PeÃ±a	15	11	46	663
664	Carolina Alfonso GuzmÃ¡n	13	46	92	664
665	JosÃ© Alexander Orozco GonzÃ¡lez	7	14	48	665
666	Mercedes Maribel Cardona	10	42	10	666
667	Eduardo Vargas Herrera	12	10	2	667
668	Yadira LondoÃ±o	8	10	50	668
669	Omar William GÃ³mez Becerra	8	30	22	669
670	Ibeth Mora CortÃ©s	4	48	11	670
671	Luis Cristian Benavides Caicedo	12	25	83	671
672	Norma Luz Aguirre	8	29	90	672
673	David Enrique GarcÃ­a	12	5	40	673
674	Marcela Bastidas Carmona	5	44	33	674
675	Dora Sandra LÃ³pez SÃ¡nchez	2	33	13	675
676	Luis Mendoza VelÃ¡squez	6	10	37	676
677	Ibeth Ibeth Perdomo Osorio	3	7	60	677
678	Luis Ocampo Fuentes	4	23	100	678
679	Ignacio Becerra	10	5	78	679
680	Juan Guerrero	1	10	49	680
681	Milena Castillo	2	18	47	681
682	Luis Alberto GarcÃ©s RÃ­os	15	20	63	682
683	Paola MarÃ­a Morales Ballesteros	8	38	54	683
684	Margarita Palacios JimÃ©nez	14	32	54	684
685	Sergio Galeano	4	2	95	685
686	MarÃ­a Zulma Palacios	1	3	90	686
688	Eliana Restrepo	9	28	83	688
689	JuliÃ¡n ArÃ©valo	15	9	90	689
690	Juan Bedoya Angulo	1	11	40	690
691	Kelly RodrÃ­guez	9	31	15	691
693	AnÃ­bal William SuÃ¡rez Riascos	10	25	8	693
694	Jeferson Pineda NarvÃ¡ez	15	34	81	694
695	Milena Viviana Mercado GonzÃ¡lez	12	1	91	695
696	MarÃ­a MuÃ±oz Rangel	1	10	60	696
697	Edinson GarcÃ­a Vargas	13	39	68	697
698	Patricia Ortiz Valencia	8	20	65	698
699	Ever MartÃ­nez Guevara	1	33	48	699
701	Lilian Isabel GÃ³mez	11	36	65	701
702	Jonathan Manuel GÃ³mez Portilla	6	1	14	702
703	Marcela Patricia Maldonado Ortiz	8	44	69	703
704	Alexander Barrera	10	39	56	704
705	Sergio Parra	7	20	25	705
706	Marcela Angie SuÃ¡rez DÃ­az	7	23	37	706
707	Roger Espinosa Escobar	6	24	51	707
708	Juan Arroyo Giraldo	10	43	60	708
709	Antonio Rojas	1	43	36	709
710	JosÃ© Eduardo GÃ³mez	9	12	3	710
711	Sandra Giraldo DÃ­az	4	7	62	711
712	Andrea Yolanda Vargas RamÃ­rez	9	33	51	712
713	JosÃ© AndrÃ©s Jaimes Silva	8	45	69	713
714	Ã“scar Juan Arango Oviedo	2	27	96	714
715	Jonathan Hugo Alzate	9	30	34	715
716	Marta SÃ¡nchez Valencia	14	36	92	716
717	MarÃ­a Luz DÃ­az PeÃ±a	1	41	94	717
718	Yolanda Nubia Arias	12	29	82	718
719	Mireya MÃ©ndez Ruiz	9	22	100	719
720	MarÃ­a MarÃ­a RodrÃ­guez	12	25	61	720
722	CÃ©sar JosÃ© VÃ¡squez CastaÃ±o	9	41	77	722
723	Javier Hugo Rojas Montenegro	12	18	51	723
724	Edith Gaviria Cuesta	15	37	53	724
726	Yolanda Luz BeltrÃ¡n	5	18	61	726
727	Augusto GuzmÃ¡n	10	10	25	727
728	Nancy Sandra Benavides Navarro	14	29	35	728
729	Carolina Amanda SepÃºlveda	1	3	12	729
730	Juan Camargo	10	30	40	730
731	Flor Vanessa Bravo	5	34	3	731
732	Gerardo RenÃ© Campo	9	24	86	732
733	Dora Gamboa	11	4	49	733
734	Yudy HernÃ¡ndez Caicedo	13	7	38	734
736	Carolina MarÃ­a JimÃ©nez GarcÃ­a	4	43	33	736
737	Miguel Forero	2	35	85	737
738	John SÃ¡nchez Carmona	1	16	59	738
740	Alejandra Sandra Ospino	9	29	17	740
741	Paola MarÃ­a Sierra ChÃ¡vez	4	32	72	741
742	Juan Carlos SuÃ¡rez MejÃ­a	11	31	72	742
743	Ana Ana Rangel SuÃ¡rez	10	48	29	743
744	Leonardo Camilo Trujillo RendÃ³n	15	23	49	744
745	Emilia Amparo MuÃ±oz	7	49	78	745
746	Ruth MuÃ±oz Silva	11	2	4	746
747	AndrÃ©s Mosquera	11	27	19	747
749	Ana Diana Ospino Arteaga	3	48	47	749
750	Emerson AndrÃ©s Duarte	6	47	23	750
751	Clara Jessica Mesa	3	47	90	751
752	Alexander Juan Herrera	12	26	81	752
753	Esther Dolly Pardo Mendoza	15	47	33	753
754	Vanesa Nidia Quintero GonzÃ¡lez	9	23	14	754
755	Yaneth SÃ¡nchez SÃ¡nchez	9	26	11	755
756	Alcides Montoya	14	1	21	756
757	Mariana Mireya GÃ³mez	8	6	47	757
758	Carmen Mariela Pardo DÃ­az	4	4	2	758
759	David Alberto Acosta Rojas	6	30	71	759
760	Cristhian Triana LondoÃ±o	12	19	87	760
761	Milena Jaramillo Henao	15	40	8	761
762	Clemencia Estella PÃ©rez	2	38	70	762
763	Ingrid Lorena Zuluaga GonzÃ¡lez	12	8	27	763
764	Ricardo CastaÃ±eda Naranjo	10	46	65	764
765	Ricardo Javier Vargas	8	26	58	765
766	Orlando Javier Caicedo	14	25	85	766
767	RocÃ­o Diana ChÃ¡vez Hurtado	4	17	98	767
768	Patricia MarÃ­a Ortiz Trujillo	15	27	90	768
770	Vanessa MuÃ±oz Ariza	3	12	75	770
771	MarÃ­a Francy DurÃ¡n Guerrero	9	26	54	771
772	Yadira Olga MartÃ­nez Olaya	3	47	60	772
773	InÃ©s Angulo	13	42	87	773
774	Cecilia Acosta	5	20	82	774
775	Pedro Espinosa	3	47	31	775
776	Jair Becerra	8	29	70	776
777	Oliva Rosa Oviedo Blanco	14	47	3	777
778	Marlene PÃ©rez Orjuela	7	20	15	778
779	Victoria Yesenia Galvis	5	40	33	779
780	Orlando Gregorio RodrÃ­guez GarcÃ­a	3	47	63	780
781	Alfredo Harold Murillo	15	4	72	781
782	Yesid PeÃ±a RodrÃ­guez	14	20	77	782
783	FabiÃ¡n Osorio	12	3	88	783
784	Diego Palacios	11	20	92	784
785	Carmen Rojas Ortiz	8	31	70	785
786	Luis Bedoya	14	39	65	786
787	Jhon Ariza	13	34	10	787
788	Sandra Romero Morales	14	50	59	788
789	Myriam Andrea Gaviria GarcÃ­a	7	4	93	789
790	Carlos MartÃ­nez	15	22	33	790
791	Adriana Vanessa Ruiz	7	30	33	791
792	Ã“scar NarvÃ¡ez LÃ³pez	3	28	7	792
793	Gerson Esteban Portilla Becerra	11	28	51	793
794	MarÃ­a Paola Castillo Giraldo	12	46	54	794
795	Juan Alejandro Prieto	5	9	93	795
796	Nubia Gloria Gaviria LeÃ³n	14	30	39	796
797	Luis Carvajal RodrÃ­guez	15	8	62	797
798	Luz Patricia Barbosa	2	3	5	798
799	Jacqueline Yurany PÃ©rez LondoÃ±o	3	47	18	799
800	Alberto GonzÃ¡lez	4	18	8	800
802	Liliana Franco	7	17	52	802
803	Carolina MarÃ­a Montes	3	37	76	803
804	Edgar Ruiz JimÃ©nez	8	39	3	804
806	JuliÃ¡n Gil RÃ­os	5	46	23	806
807	Milena Ximena LÃ³pez PÃ©rez	13	3	66	807
808	Miriam PÃ©rez	9	33	41	808
809	Alberto Alejandro VelÃ¡squez	3	14	41	809
810	Brandon Zapata RincÃ³n	15	5	45	810
811	MarÃ­a Palacios Cardona	9	4	6	811
812	Lorena HernÃ¡ndez Padilla	13	26	47	812
813	Julio Cano	12	49	35	813
814	Patricia Julieth Estrada	1	41	90	814
815	Octavio Escobar	5	20	97	815
816	Eider Valencia	1	19	97	816
817	Esther Paola PÃ©rez	15	34	24	817
818	Cristian Fredy Vargas DÃ­az	8	33	40	818
819	Carlos Ernesto Benavides Romero	13	33	49	819
820	Carlos Daniel HernÃ¡ndez	2	42	37	820
821	Carlos Carlos GonzÃ¡lez	4	49	97	821
822	Teresa Cindy Lozano	13	13	46	822
823	Eduardo Cabrera	14	8	19	823
824	Pedro Fuentes MarÃ­n	13	49	80	824
825	Daniel DuvÃ¡n Soto BermÃºdez	8	6	22	825
826	Pedro Alfredo Lara Zambrano	3	30	80	826
828	Ã“scar Eduardo Vega Salgado	5	16	92	828
829	Fernanda MartÃ­nez	10	49	27	829
830	Antonio Fredy Vergara	9	12	90	830
831	Graciela CÃ³rdoba DÃ­az	8	37	73	831
832	Eugenia GarcÃ©s Rubio	13	41	5	832
833	Julia Caicedo	12	3	93	833
834	JosÃ© MuÃ±oz	9	21	35	834
835	Rafael Elkin Granados Velasco	11	41	44	835
836	Luz FlÃ³rez	9	21	57	836
837	Johan Angulo Cifuentes	12	41	34	837
838	MarÃ­a Morales	4	50	3	838
839	William JesÃºs Sandoval Perea	10	21	35	839
840	Liseth MÃ³nica GutiÃ©rrez	14	12	71	840
842	Carmen MarÃ­a RodrÃ­guez	8	20	60	842
843	Ana Isabel MuÃ±oz Vergara	1	7	8	843
844	Matilde Giraldo RincÃ³n	10	6	59	844
845	JesÃºs Luis Agudelo Alfonso	13	41	82	845
846	Miriam Natalia PÃ©rez	13	29	94	846
847	Carlos Chaparro Torres	4	12	33	847
849	Janeth Caicedo	12	29	22	849
850	Jorge Camilo MuÃ±oz	8	8	37	850
851	Yaneth LeÃ³n	6	47	80	851
852	Yolanda Eliana Cruz GuzmÃ¡n	2	33	33	852
853	Teresa RamÃ­rez	12	18	80	853
854	Magnolia Marcela Rivera	8	47	65	854
855	Marta Mariana Arango	10	7	50	855
856	Alexander Granados Bernal	10	49	13	856
858	Alonso Manuel MejÃ­a PÃ©rez	1	37	18	858
859	Daniel Toro	13	9	63	859
861	Luz Barbosa SÃ¡nchez	1	26	41	861
862	Laura Claudia CastaÃ±o DÃ­az	8	13	15	862
863	Octavio HernÃ¡ndez	12	34	35	863
864	Jorge Arango	5	35	28	864
865	Fredy Juan Fonseca	10	7	47	865
867	Roberto Carrillo	11	4	35	867
868	SaÃºl Anderson GarzÃ³n	12	42	84	868
869	LucÃ­a Vanessa Barrios LondoÃ±o	7	29	80	869
870	Claudia Rojas	9	39	99	870
871	Carmen Betancur CÃ¡rdenas	8	38	1	871
872	Lucy Cabrera Parra	5	5	5	872
873	Cristina Castellanos	2	42	63	873
874	Daniel Dario Escobar GarcÃ­a	2	35	40	874
875	Arturo ArÃ©valo	4	40	67	875
876	Jorge Hernando Mora Hurtado	10	30	68	876
877	Armando JosÃ© Osorio Ortiz	14	16	44	877
878	Sandra Lady Medina	3	15	99	878
879	Libia Cecilia Rojas	12	27	49	879
880	Rafael PÃ©rez	8	3	78	880
881	Carlos CuÃ©llar	15	39	27	881
882	Fernanda Jessica PÃ¡ez RamÃ­rez	13	39	39	882
883	Andrea LÃ³pez	15	44	46	883
884	Martha Ortiz SÃ¡nchez	13	26	77	884
885	IvÃ¡n SÃ¡nchez	10	25	95	885
887	Dario Santos	15	10	64	887
888	Ingrid Parra GÃ³mez	11	5	10	888
889	Milena CÃ¡rdenas CÃ³rdoba	8	24	26	889
890	Johana Salazar Burbano	15	23	60	890
891	Alcides Guevara	2	30	95	891
892	Jhon SÃ¡nchez	1	8	19	892
893	MarÃ­a Oviedo	14	49	35	893
894	Omar Ruiz GuzmÃ¡n	14	26	28	894
895	MarÃ­a Ortiz Ariza	4	25	14	895
897	Carlos RamÃ­rez Cantillo	13	47	60	897
899	Luis LÃ³pez Contreras	8	11	30	899
900	Dario PeÃ±a	12	5	90	900
901	JesÃºs NiÃ±o	3	29	24	901
902	Faber Gaviria Sandoval	11	28	71	902
903	Carolina Yolanda Ardila	12	2	7	903
904	Estela PeÃ±a	2	45	68	904
905	Esteban Robinson Cuesta	12	16	37	905
906	James Rafael Moreno	9	49	75	906
907	Alfredo Luis GarcÃ­a	4	31	93	907
908	Anderson Enrique Rojas Villegas	9	32	2	908
909	Manuel Guevara Herrera	7	41	18	909
910	Carlos Palacios	7	23	96	910
911	Dora Ortiz LeÃ³n	10	49	7	911
912	Paola MarÃ­a Padilla Rojas	15	49	67	912
913	Stella Daniela BolaÃ±os Ospina	3	4	14	913
914	Olga Paula Parra Hurtado	1	28	44	914
915	Luis Correa	12	28	33	915
916	Felipe Mendoza Sierra	2	32	63	916
917	Mariana Clara Torres RodrÃ­guez	13	22	4	917
918	Hernando Ramos	7	42	86	918
919	Fernando DomÃ­nguez MuÃ±oz	12	34	52	919
920	MarÃ­a Gloria LÃ³pez	2	42	25	920
921	Lizeth Tatiana MartÃ­nez Molina	11	41	22	921
922	Yaneth GutiÃ©rrez Osorio	15	49	41	922
923	JosÃ© Arley Obando Arteaga	5	18	7	923
924	Rafael Eduardo Mena	2	4	43	924
925	Nelson Polo Lozano	2	5	13	925
926	Johan Alfredo Trujillo	2	16	62	926
927	Luis JosÃ© Ortega	8	41	61	927
928	Claudia Ruby MartÃ­nez	11	38	6	928
929	Luz MarÃ­a Acosta Vergara	12	7	74	929
930	BenjamÃ­n Jhon PeÃ±a Villa	14	46	61	930
931	Elvia MarÃ­a Carrillo	5	48	7	931
932	Diana GarcÃ­a	8	41	7	932
933	Alba Andrea Vergara	13	50	78	933
934	Katherine Guevara Osorio	2	27	40	934
935	Marino LeÃ³n NarvÃ¡ez	15	38	14	935
936	MarÃ­a Torres	6	3	70	936
937	Isabel PinzÃ³n Mosquera	11	2	21	937
938	Gabriel Quintero DÃ­az	1	5	84	938
939	Mirian MarÃ­a Quiroz	3	24	84	939
940	Luis Wilmer Mosquera Betancur	10	49	75	940
941	Paola RamÃ­rez GutiÃ©rrez	1	20	15	941
942	Fabio Carlos Quintero Espinosa	7	13	55	942
943	Danny Ernesto RamÃ­rez	1	37	35	943
944	MarÃ­a Luz Paz Bautista	3	7	38	944
945	Juana Arias SuÃ¡rez	8	2	72	945
947	FabiÃ¡n Vergara DÃ­az	15	46	34	947
948	Alfredo Ruiz MarÃ­n	9	36	19	948
949	Manuel Rafael HernÃ¡ndez LÃ³pez	7	4	71	949
950	Elvia Reyes	14	45	40	950
951	Nidia Elizabeth Murcia	9	18	37	951
952	JesÃºs Fabio Galvis	12	14	54	952
953	Giovanny Juan Serna VÃ¡squez	2	11	42	953
954	Carlos Alejandro Ariza	1	28	79	954
955	MarÃ­a Ramos	11	38	34	955
956	William JimÃ©nez	15	27	79	956
957	Ramiro Fernando Cruz	3	19	12	957
958	Enrique Diego Silva	15	31	67	958
959	Edison Vega RincÃ³n	8	33	3	959
960	Maritza Miriam BohÃ³rquez	3	39	32	960
961	Enrique Vera Bustamante	10	30	100	961
962	Marcela Rivas Cardona	8	19	14	962
963	Geovanny Sandoval BermÃºdez	6	36	85	963
964	Luis Manrique	5	41	98	964
965	HernÃ¡n NicolÃ¡s Maldonado Bravo	14	15	69	965
966	Reinel AndrÃ©s MartÃ­nez	4	34	2	966
967	MarÃ­a Fajardo Perdomo	3	29	74	967
969	Humberto GonzÃ¡lez	9	35	28	969
970	Eliecer Pedro Torres Arenas	5	35	41	970
971	Vanesa ChÃ¡vez	2	14	6	971
972	David ChacÃ³n	14	11	87	972
973	Paola GonzÃ¡lez	12	34	21	973
974	Carlos GarcÃ­a	5	37	31	974
975	Milena Clara Cardozo	8	23	22	975
976	AndrÃ©s Elkin Contreras	6	31	86	976
977	Hernando Castillo LondoÃ±o	11	24	87	977
979	Alexander Alejandro Obando	7	21	66	979
980	Efrain Rigoberto SÃ¡nchez GÃ³mez	8	37	97	980
981	Olga Hilda Ramos Arango	9	47	42	981
982	Diana Cecilia RodrÃ­guez Murillo	12	35	99	982
983	Rosa Astrid Parra SÃ¡nchez	11	11	75	983
984	Juan Carlos GonzÃ¡lez Caro	12	10	21	984
985	Danny MuÃ±oz Arias	2	46	98	985
986	Marlene Daniela DÃ­az	8	1	6	986
987	Alexander GarzÃ³n	7	4	17	987
988	Julieth Liliana Zuluaga	13	6	90	988
989	Hernando LÃ³pez	14	32	74	989
990	Carolina Naranjo RamÃ­rez	1	3	66	990
991	Freddy Ricardo Quintero Gamboa	3	42	85	991
992	Eduar Carlos Ojeda	5	26	74	992
993	Miriam Palacios Salcedo	10	12	33	993
994	Segundo Alejandro LÃ³pez	7	6	82	994
995	LucÃ­a Yulieth Moreno	8	44	44	995
997	Alexander Luis Bonilla Restrepo	7	48	88	997
998	Fernando Quintero Reyes	11	40	94	998
999	MarÃ­a Andrea Polo Torres	5	32	81	999
1000	Cristian David Castillo Rivera	9	33	79	1000
1001	Esteban Camacho	4	17	57	1001
1002	Augusto Leonardo Pineda	10	19	95	1002
1003	Nora Gloria MuÃ±oz	14	18	51	1003
1004	Esperanza Tatiana LeÃ³n LÃ³pez	6	1	51	1004
1005	Uriel Escobar	8	14	29	1005
1006	Luis Caicedo	2	32	100	1006
1007	Eliecer MartÃ­nez GarcÃ­a	10	11	36	1007
1008	JesÃºs Cristobal Murillo	11	37	19	1008
1009	Fernando Jaimes Mendoza	9	49	34	1009
1010	HÃ©ctor Rico Hoyos	15	3	26	1010
1011	Mauricio Hoyos Torres	2	7	96	1011
1012	Alejandra RodrÃ­guez	15	1	65	1012
1013	Clara CÃ³rdoba Alzate	7	39	59	1013
1014	Carlos SÃ¡nchez	1	36	60	1014
1015	YazmÃ­n Daza Espitia	12	15	51	1015
1016	JosÃ© RodrÃ­guez Ariza	13	50	78	1016
1018	Alejandro Rojas	5	6	30	1018
1019	Esperanza GÃ³mez GuzmÃ¡n	12	25	35	1019
1020	AndrÃ©s Serna	14	24	21	1020
1021	David Rivera Arenas	1	46	55	1021
1022	Jennifer NarvÃ¡ez SÃ¡nchez	13	24	47	1022
1023	LucÃ­a SuÃ¡rez BeltrÃ¡n	1	30	19	1023
1024	Ã“scar RodrÃ­guez	14	24	3	1024
1025	Isabel Xiomara HernÃ¡ndez	15	43	74	1025
1026	Antonio Mauricio MarÃ­n	9	36	91	1026
1027	MÃ³nica Karina GutiÃ©rrez ChÃ¡vez	15	35	1	1027
1028	Jaime Salazar	5	21	84	1028
1029	HÃ©ctor Serrano	2	4	39	1029
1030	Carlos FlÃ³rez	13	35	23	1030
1031	Isidro GÃ³mez	3	16	41	1031
1032	Juan Jerson Arroyo MarÃ­n	7	32	94	1032
1033	Yuliana Moreno	10	6	46	1033
1034	Rosalba Perdomo	5	35	74	1034
1035	Erika Isabel Rojas	13	20	37	1035
1036	Andrea Margarita Perdomo	2	16	100	1036
1038	Andrea Beatriz Sarmiento SuÃ¡rez	6	26	99	1038
1039	Mauricio Villa CortÃ©s	10	21	19	1039
1040	Fernanda Paula MejÃ­a ArÃ©valo	7	28	32	1040
1041	Luisa PinzÃ³n Blanco	12	50	52	1041
1042	Lucy Romero LeÃ³n	3	1	87	1042
1043	Diego Diego Perea	1	31	48	1043
1044	JosÃ© Luis Monsalve	15	39	75	1044
1045	Marta Elena Trujillo Naranjo	15	7	16	1045
1046	Sergio MÃ©ndez	6	47	50	1046
1047	Alejandro Jhon LÃ³pez MarÃ­n	12	2	77	1047
1048	Patricia PeÃ±a	15	18	78	1048
1049	Esther Isabel Toro RincÃ³n	5	48	69	1049
1050	Amparo Elena PÃ©rez Duque	4	29	26	1050
1051	Mario Alzate	12	6	97	1051
1052	Amparo DÃ­az	7	10	87	1052
1054	Luz RendÃ³n RodrÃ­guez	10	9	64	1054
1055	Arley Edgar NarvÃ¡ez	14	38	36	1055
1056	SebastiÃ¡n CÃ¡ceres	12	31	78	1056
1057	Enrique Wilson Figueroa Barrera	10	35	33	1057
1058	Alfonso Felipe Rivas	6	14	29	1058
1059	RaÃºl Rueda LÃ³pez	7	30	80	1059
1060	Esperanza Luz Ramos	4	21	8	1060
1061	MarÃ­a MarÃ­a Torres JimÃ©nez	9	18	53	1061
1063	JosÃ© MartÃ­nez GutiÃ©rrez	8	32	98	1063
1064	AngÃ©lica Arroyo	10	29	63	1064
1065	Yadira MarÃ­a JimÃ©nez	15	10	74	1065
1066	Ever Gamboa Ayala	13	26	46	1066
1067	Fernanda MartÃ­nez	10	29	9	1067
1068	Edison Adolfo Castro Rojas	1	39	65	1068
1069	Liliana Vanesa MarÃ­n Gaviria	9	26	86	1069
1071	Luz Morales Rojas	3	4	80	1071
1072	Karen Sanabria	7	10	77	1072
1073	Luis Navarro PÃ©rez	13	10	31	1073
1074	MartÃ­n Jaimes	13	18	50	1074
1075	Ã“scar VÃ¡squez	14	17	88	1075
1076	Graciela Paola Correa	7	29	27	1076
1077	Claudia Rojas	7	23	28	1077
1078	Gladys Betancur PÃ©rez	9	25	98	1078
1079	Leonel John Sarmiento JimÃ©nez	8	30	16	1079
1080	MarÃ­a Johana Daza Soto	9	6	59	1080
1081	JosÃ© BermÃºdez Rivas	6	34	29	1081
1082	MarÃ­a Lida GarcÃ­a Romero	9	16	96	1082
1083	Aldemar Acosta GuzmÃ¡n	6	1	58	1083
1084	Jeison LÃ³pez	9	5	37	1084
1085	Alejandro GarcÃ­a	9	27	17	1085
1086	Miguel Triana Figueroa	9	25	76	1086
1087	Carmen Ana RamÃ­rez	8	9	7	1087
1088	Roberto Estrada	10	44	92	1088
1089	Juan MarÃ­n Rojas	12	45	57	1089
1090	Felipe RodrÃ­guez	8	38	70	1090
1091	Jorge Arias Agudelo	6	27	58	1091
1092	Anyi Ruiz	1	19	79	1092
1093	Hernando Amaya MartÃ­nez	1	8	41	1093
1094	Jairo Villamil Salazar	8	44	71	1094
1095	Alexander Daniel Valencia Mosquera	10	49	22	1095
1096	MarÃ­a VelÃ¡squez RincÃ³n	8	50	17	1096
1097	Magnolia Cardona	1	1	33	1097
1098	Anderson Benavides	4	3	22	1098
1099	JesÃºs Alberto Montoya	12	47	74	1099
1100	Nubia Claudia MartÃ­nez Ruiz	13	21	4	1100
1101	Paola Vanessa Gallego GutiÃ©rrez	13	40	26	1101
1102	Marcela Nohora LondoÃ±o LÃ³pez	7	38	85	1102
1103	Luz Barrera GutiÃ©rrez	12	18	98	1103
1104	Patricia Luz Vergara Galvis	10	9	34	1104
1105	MarÃ­a SÃ¡nchez PÃ©rez	11	2	19	1105
1106	Carlos Felipe Castillo	5	26	46	1106
1107	MarÃ­a Meza Aguilar	5	32	23	1107
1108	Eugenia Teresa Pinto	9	6	18	1108
1109	Stella SÃ¡nchez Pinto	14	12	40	1109
1110	John Ramos	13	48	95	1110
1111	Elizabeth Figueroa	15	33	11	1111
1112	Johanna Bravo	1	3	54	1112
1113	SofÃ­a RincÃ³n	10	14	47	1113
1114	Enrique AndrÃ©s Zapata	9	1	83	1114
1115	Mayra RocÃ­o Rubio	12	11	31	1115
1116	Blanca AngÃ©lica PeÃ±a SÃ¡nchez	5	46	27	1116
1117	Sandra Eugenia Duque	15	34	22	1117
1119	Pedro Esteban GonzÃ¡lez	1	34	97	1119
1120	Margarita MarÃ­a Moreno	15	1	15	1120
1121	Marcela Carmen Correa	2	35	25	1121
1122	Julio Luis Valencia	1	20	68	1122
1123	JesÃºs BermÃºdez	4	41	96	1123
1124	Julieth SÃ¡nchez Vega	12	14	90	1124
1125	Cristian Luis Acosta	1	17	45	1125
1126	Clara Carolina Mosquera	11	2	100	1126
1127	Adolfo Miguel CalderÃ³n	13	25	47	1127
1128	Ruth Heidy Torres GÃ³mez	4	24	37	1128
1130	Leandro AndrÃ©s Amaya Castro	1	12	6	1130
1131	Mary Luz Angulo DÃ­az	1	39	98	1131
1132	Ana LondoÃ±o	13	43	91	1132
1133	Paola Carrillo	2	7	21	1133
1134	Rosa Correa Sandoval	6	26	57	1134
1135	Juan Albeiro PÃ©rez	7	19	42	1135
1136	Yamile Gladys Morales	2	11	80	1136
1137	Blanca Quiroz Ibarra	5	42	22	1137
1138	Elsa Leidy Herrera	8	35	79	1138
1139	Blanca Nelly Alvarado Castillo	12	36	23	1139
1140	JuliÃ¡n Parra	5	27	82	1140
1142	Jorge PatiÃ±o	11	42	54	1142
1143	MÃ³nica Medina	6	31	96	1143
1144	Miguel Vallejo	11	21	3	1144
1145	Dagoberto Carrillo Rojas	6	6	63	1145
1146	Javier Segundo DÃ­az GarzÃ³n	15	22	19	1146
1147	Sandra MarÃ­a Giraldo	4	50	56	1147
1148	Sandra MarÃ­a Velasco	9	28	7	1148
1149	Felipe Alexis GonzÃ¡lez Mendoza	6	39	19	1149
1150	JosÃ© Barrera	4	15	78	1150
1151	Raquel SÃ¡nchez GonzÃ¡lez	15	1	8	1151
1152	Lorena Esther Castillo Molina	10	19	78	1152
1153	Liliana MarÃ­a Castro	8	39	65	1153
1154	Cristina Guerra GÃ³mez	3	36	22	1154
1155	David Wilber Rivera	15	41	10	1155
1156	Patricia GarcÃ©s Restrepo	13	37	50	1156
1157	Alexander GÃ³mez	15	16	45	1157
1159	Milena Romero Medina	10	40	5	1159
1160	Rosario Zapata	11	15	25	1160
1161	Edison SÃ¡nchez HernÃ¡ndez	1	23	3	1161
1162	Ana Cindy GarcÃ­a Ortiz	6	36	68	1162
1163	RamÃ³n Eliecer Guerrero	15	10	46	1163
1164	Yolima Ana RodrÃ­guez RodrÃ­guez	3	34	24	1164
1165	Edilson Ojeda	7	9	28	1165
1166	Yaneth BermÃºdez Herrera	1	2	69	1166
1167	IvÃ¡n PÃ©rez Delgado	1	39	9	1167
1168	Consuelo Vanessa GÃ³mez	6	4	25	1168
1169	Leonor RodrÃ­guez Barreto	3	30	82	1169
1171	Paola Torres	14	15	1	1171
1172	Luz Claudia GarcÃ­a	5	27	26	1172
1173	Sandra RamÃ­rez	10	9	76	1173
1175	AndrÃ©s Bonilla	3	48	29	1175
1176	Clemencia Rosa MuÃ±oz Bejarano	12	5	14	1176
1177	Juan Carlos Carrillo	1	32	59	1177
1178	Luz Elsa Acosta GutiÃ©rrez	2	49	82	1178
1179	Jennifer Sandra Fuentes	14	11	13	1179
1180	Nancy Sandoval Yepes	15	28	11	1180
1181	Alexander VÃ©lez Daza	10	48	41	1181
1182	HÃ©ctor Aguilar	3	26	39	1182
1183	Derly Nohora Leal DÃ­az	7	26	65	1183
1184	AndrÃ©s Acosta DÃ­az	15	48	18	1184
1185	Rodolfo PÃ©rez	9	31	60	1185
1186	AndrÃ©s Salazar	10	49	23	1186
1187	Alberto Rafael GÃ³mez	14	8	80	1187
1188	Luz Claudia Morales Mena	15	34	4	1188
1189	Andrea Romero	7	33	76	1189
1190	MarÃ­a Murillo	7	23	98	1190
1191	Mauricio VÃ¡squez Lozano	13	30	72	1191
1192	Eduardo Diego Parra	11	39	17	1192
1193	Nancy Rangel	9	17	74	1193
1194	Estella Karen BeltrÃ¡n	12	5	10	1194
1195	Jimena ChacÃ³n	4	27	11	1195
1196	Milena Zoraida Duque DÃ­az	1	28	53	1196
1197	Juan Carlos Sanabria GarzÃ³n	6	19	94	1197
1199	Yuliana DÃ­az MarÃ­n	1	48	87	1199
1200	Efrain PeÃ±a	15	19	51	1200
1202	Carolina Henao	7	40	51	1202
1203	Alejandro Osorio	10	29	81	1203
1204	Luis JesÃºs Leal Castro	8	39	72	1204
1205	Alejandra Johanna Quiroga Murcia	9	43	23	1205
1206	Patricia HernÃ¡ndez	13	19	52	1206
1207	Camilo Arias	10	19	78	1207
1208	Jhon Mosquera	8	32	11	1208
1209	Yamile Moreno Cabrera	13	35	95	1209
1210	Vanessa Mercedes Palacios GarcÃ­a	2	41	17	1210
1211	FabiÃ¡n AndrÃ©s Hoyos Amaya	8	49	97	1211
1212	Jeferson Felipe Figueroa Moreno	3	25	29	1212
1213	Gustavo Alejandro Montoya Fonseca	13	33	9	1213
1214	Yuliana Correa	2	29	38	1214
1215	Sara Barbosa CalderÃ³n	4	5	66	1215
1216	Deicy MarÃ­a RodrÃ­guez	5	21	70	1216
1217	Luis Mauricio GutiÃ©rrez	14	10	13	1217
1218	Alberto Miller Gallego	12	42	1	1218
1219	Cecilia Lara	5	20	30	1219
1220	Antonio Fernando Acevedo	13	8	59	1220
1221	Fernanda Andrea RodrÃ­guez	11	21	13	1221
1222	Richard Moreno	3	36	58	1222
1223	Julieth Emilse CortÃ©s Meneses	12	43	78	1223
1224	Mauricio Puentes	7	17	74	1224
1225	Yesid Pineda RodrÃ­guez	6	30	17	1225
1226	Dary Jaimes Pineda	13	45	15	1226
1227	SebastiÃ¡n Freddy Vargas Cruz	3	10	30	1227
1228	Martha Helena Moreno Camargo	14	36	32	1228
1229	Natalia Paola Cardozo Mercado	14	6	76	1229
1230	Eugenio Monsalve	6	1	70	1230
1231	Jorge Rico	6	23	50	1231
1232	Leidy Silva	12	29	96	1232
1233	JosÃ© DÃ­az	15	44	50	1233
1234	MarÃ­a Osorio Ruiz	3	40	29	1234
1235	Ã“scar SÃ¡nchez Torres	3	21	38	1235
1236	VÃ­ctor RamÃ­rez LÃ³pez	2	5	56	1236
1237	Marcela MarÃ­a GarcÃ­a	5	37	93	1237
1238	Samir Alonso Cruz	14	44	44	1238
1239	Alejandra Luz Ochoa	1	10	41	1239
1240	Jairo JesÃºs Trujillo Acosta	9	50	69	1240
1241	Javier Miguel GonzÃ¡lez	9	11	50	1241
1242	David Humberto Torres Guevara	2	46	40	1242
1243	AndrÃ©s Miller MejÃ­a	5	49	99	1243
1244	Javier Edwin Mendoza	15	28	80	1244
1245	Guillermo Leonel RamÃ­rez Villa	9	1	27	1245
1246	Lilia Bonilla	4	22	42	1246
1247	Carlos Francisco Forero	2	10	81	1247
1248	Carlos Mora	11	47	65	1248
1249	Manuel GarcÃ­a	11	48	21	1249
1250	Jair Velasco Cabrera	8	18	7	1250
1251	Miguel Henao	9	19	13	1251
1252	Luis Mantilla Cruz	7	48	6	1252
1253	Nancy Orozco	14	23	11	1253
1254	Antonia Nieto	5	35	65	1254
1255	Henry Edgar Solano	2	41	77	1255
1256	Isabel Patricia HernÃ¡ndez	12	7	99	1256
1258	Albeiro Pablo Escobar	14	41	55	1258
1259	Faber RamÃ­rez	6	31	60	1259
1260	Ligia Patricia Morales Quintero	7	18	31	1260
1261	CÃ©sar Fredy Trujillo	12	32	59	1261
1262	Johanna Patricia Molano Montoya	2	39	5	1262
1263	Carlos Mena	2	19	59	1263
1265	Antonio Jhon Sierra Palacios	4	38	77	1265
1266	Lucy LÃ³pez	9	6	42	1266
1267	Yeimy Becerra	15	11	66	1267
1268	JuliÃ¡n Ã“scar CÃ¡ceres	2	45	94	1268
1269	Aldemar MuÃ±oz JimÃ©nez	6	50	1	1269
1270	Mario Jhon Molina	15	36	100	1270
1271	SebastiÃ¡n AndrÃ©s BarragÃ¡n	5	49	43	1271
1272	Alfonso Pedro CortÃ©s	9	29	60	1272
1273	Kelly Amparo VÃ©lez GÃ³mez	4	12	10	1273
1274	LeÃ³n Torres Restrepo	6	35	83	1274
1275	Brayan Ospina Caicedo	13	19	53	1275
1276	Vicente Jaime Rojas	12	34	68	1276
1277	Carolina Valeria Vargas	9	41	18	1277
1278	Paola Arboleda Restrepo	14	25	100	1278
1279	Rosa BeltrÃ¡n	9	2	21	1279
1280	LucÃ­a Dolores Bedoya	8	1	63	1280
1281	SebastiÃ¡n Sanabria PÃ©rez	10	4	68	1281
1282	Edilson Mario Perea Ortiz	15	21	64	1282
1283	Juliana Dolores Moreno PÃ¡ez	5	3	22	1283
1284	Luis Sandoval Aguirre	11	47	3	1284
1286	Gabriel Villamizar MÃ©ndez	13	9	67	1286
1287	Diego Antonio MuÃ±oz	5	30	86	1287
1288	Elvira Nubia Rojas	15	22	39	1288
1289	Antonio Franco Estrada	6	10	73	1289
1290	Ã“scar GÃ³mez	5	40	65	1290
1291	Alexander Vega	10	5	95	1291
1292	Lizeth Camargo	13	45	94	1292
1293	CÃ©sar Dario Benavides DÃ­az	3	14	54	1293
1294	Judith Contreras Forero	8	50	31	1294
1295	IsaÃ­as Daniel DÃ­az Gil	9	11	86	1295
1296	Lucero Flor PÃ©rez JimÃ©nez	3	44	53	1296
1297	Luz Salgado Montoya	5	44	56	1297
1298	JosÃ© Arenas	4	12	37	1298
1299	Alex Salcedo	12	34	6	1299
1300	Emerson Israel CÃ¡rdenas DÃ­az	5	15	12	1300
1301	Laura DÃ­az Parra	10	25	43	1301
1302	Mauricio GarcÃ­a Romero	10	19	5	1302
1303	RocÃ­o Andrea Parra	9	32	72	1303
1304	Sandra Molina	4	6	77	1304
1305	Augusto Luis GÃ³mez Valencia	7	45	100	1305
1306	Arley CerÃ³n Delgado	11	22	41	1306
1307	Luz NÃºÃ±ez	8	10	46	1307
1308	Ana Maribel Camargo	10	17	27	1308
1309	Julieth GÃ³mez Romero	1	22	81	1309
1310	JosÃ© James Becerra	13	28	76	1310
1311	Camilo MartÃ­nez	4	40	55	1311
1312	Libia Luz GÃ³mez	6	40	34	1312
1313	JosÃ© Oswaldo Perdomo Zambrano	1	26	42	1313
1314	JosÃ© JosÃ© Palacios	14	3	83	1314
1315	JosÃ© Castro	13	5	37	1315
1316	Jairo DuvÃ¡n MuÃ±oz Navarro	15	26	76	1316
1317	Luis Jhon Bedoya Cardona	6	31	14	1317
1318	Enrique Emiro Ortega	12	31	48	1318
1319	Gloria Castellanos	1	39	7	1319
1320	Nelly Marlene RodrÃ­guez MartÃ­nez	8	40	90	1320
1322	Fabio GaitÃ¡n Montoya	6	47	57	1322
1323	Nelson AndrÃ©s Ariza Pineda	4	19	74	1323
1324	Claudia Carmona MartÃ­nez	11	37	38	1324
1325	MarÃ­a Gisela FernÃ¡ndez	11	22	65	1325
1326	Omaira Hoyos	10	23	65	1326
1327	JosÃ© Francisco HernÃ¡ndez Mendoza	6	25	42	1327
1328	Daniela Janeth LeÃ³n	15	26	26	1328
1329	Juan Forero CÃ³rdoba	8	48	70	1329
1330	Magda Marcela Valencia	1	17	18	1330
1332	Paola Hilda Mendoza GonzÃ¡lez	15	29	58	1332
1333	Armando Danilo Contreras GarzÃ³n	9	1	25	1333
1334	Rigoberto Anaya Barrera	3	39	1	1334
1335	Fredy PinzÃ³n RamÃ­rez	10	45	61	1335
1336	IvÃ¡n Carlos Cano Granados	3	27	42	1336
1338	Gerardo CÃ³rdoba SÃ¡nchez	6	50	51	1338
1339	Josefina Diana Cruz	6	18	33	1339
1340	Liliana Laura Arias	6	24	53	1340
1341	Angie Rosalba Carrillo	4	18	85	1341
1342	Eliana Valeria Ayala Moreno	2	2	68	1342
1563	Gloria Vargas	14	47	23	1563
1343	Blanca Dayana GutiÃ©rrez	6	20	61	1343
1344	Carlos Tamayo Mosquera	12	50	41	1344
1345	Carlos Abraham Torres Ramos	7	15	92	1345
1346	Esteban Camilo GutiÃ©rrez	12	1	81	1346
1347	Laura Valencia RodrÃ­guez	12	29	3	1347
1348	Marcela Molina Rosero	1	31	29	1348
1349	Carolina Karen Luna Zuluaga	3	48	65	1349
1350	Myriam Herrera	1	13	3	1350
1351	AndrÃ©s Vallejo	7	7	56	1351
1352	Luis Fuentes Torres	11	41	55	1352
1353	Cecilia Erika Fajardo BenÃ­tez	4	49	18	1353
1354	Fernando Samuel Polo	15	4	58	1354
1355	Yury Gina Morales Caro	8	35	37	1355
1357	Antonio Jorge GÃ³mez	14	31	53	1357
1358	Stella Margarita LÃ³pez	8	20	69	1358
1359	MarÃ­a Daniela Bernal	2	49	30	1359
1360	Alexander Ramiro Sandoval	15	37	5	1360
1361	IvÃ¡n Moreno	9	35	94	1361
1362	Carol HernÃ¡ndez	4	38	98	1362
1363	Elsa Leidy Reyes	13	15	26	1363
1364	David Gallego	15	12	70	1364
1365	Alberto Prieto	12	39	75	1365
1366	Edwin Reinaldo GarcÃ­a	7	33	35	1366
1367	Fernanda MarÃ­a SÃ¡nchez Moreno	4	12	35	1367
1368	Ramiro Bedoya	14	32	71	1368
1369	Alberto Obando Manrique	11	9	57	1369
1370	Felipe AlarcÃ³n DÃ­az	10	44	94	1370
1371	InÃ©s MuÃ±oz Gallego	5	25	79	1371
1372	Jaime Alexander Arango Bedoya	10	35	64	1372
1373	Yaneth Sandoval PÃ©rez	2	4	68	1373
1374	Yesid Betancur LÃ³pez	8	46	83	1374
1375	Nora Yohana BeltrÃ¡n Valencia	10	33	6	1375
1376	Gustavo GonzÃ¡lez MartÃ­nez	2	5	67	1376
1377	Armando GÃ³mez Padilla	4	22	28	1377
1378	Clara Carvajal Gil	11	32	79	1378
1379	Elena MarÃ­a Moreno MartÃ­nez	9	18	73	1379
1380	Patricia Lilian MuÃ±oz	13	31	37	1380
1381	Yulieth Carolina MartÃ­nez Arias	9	15	33	1381
1382	Juan SÃ¡nchez	1	4	32	1382
1383	InÃ©s Nubia GarcÃ­a SepÃºlveda	5	32	78	1383
1384	Gloria CÃ¡rdenas	2	44	26	1384
1385	JosÃ© Luis CortÃ©s Villamizar	2	26	80	1385
1386	Manuel Enrique Mora	7	10	17	1386
1387	Carmenza Marina PatiÃ±o	10	40	31	1387
1388	Andrea Salamanca	11	24	17	1388
1389	Cecilia MarÃ­a GutiÃ©rrez Uribe	15	25	11	1389
1390	Elizabeth Forero	9	26	34	1390
1391	Claudia Mary RamÃ­rez	1	38	79	1391
1392	Claudia RamÃ­rez Bustos	14	44	42	1392
1393	Alba Soto	1	37	31	1393
1394	Lucila Mayra LÃ³pez	11	41	62	1394
1395	Jeisson JosÃ© GutiÃ©rrez	3	30	73	1395
1396	Carmen Rojas GonzÃ¡lez	1	8	80	1396
1397	JosÃ© FernÃ¡ndez Maldonado	5	49	38	1397
1399	Ingrid Flor Arrieta Quintero	8	21	50	1399
1400	SofÃ­a Pardo Melo	11	27	55	1400
1402	Alberto Villamizar PÃ¡ez	1	24	11	1402
1403	IvÃ¡n JosÃ© Arango SÃ¡nchez	5	46	84	1403
1404	David GonzÃ¡lez Osorio	7	50	45	1404
1405	Josefina Alejandra SÃ¡nchez Osorio	4	27	27	1405
1406	Sonia SÃ¡nchez Medina	4	28	99	1406
1407	Diana Vanegas Rivera	3	1	33	1407
1408	JosÃ© Medina CÃ³rdoba	3	1	99	1408
1409	Teresa Luz BohÃ³rquez	15	40	44	1409
1410	Dario Acosta	2	47	49	1410
1411	Carolina BenÃ­tez	15	2	4	1411
1412	Fernanda Katherine GÃ³mez Castro	12	23	69	1412
1413	MarÃ­a Marina MartÃ­nez	9	25	72	1413
1414	Alexandra MarÃ­a Blanco Franco	6	27	36	1414
1415	Natalia Vanesa GÃ³mez	8	46	53	1415
1416	Patricia MarÃ­a Perea	9	34	19	1416
1418	Adolfo HernÃ¡ndez Toro	4	15	10	1418
1419	Patricia Camacho RincÃ³n	7	10	37	1419
1420	Fredy William Salazar	2	31	50	1420
1421	Marleny Esperanza Fuentes GÃ³mez	1	40	96	1421
1423	MÃ³nica Carolina GarcÃ­a HernÃ¡ndez	7	21	83	1423
1425	MarÃ­a Kelly Palacio	10	40	86	1425
1426	MarÃ­a HernÃ¡ndez PÃ¡ez	15	26	17	1426
1427	Beatriz Katherin Vargas	11	36	30	1427
1428	VÃ­ctor Torres	9	23	75	1428
1429	VerÃ³nica GÃ³mez	11	35	29	1429
1430	Yolanda Arroyo Ayala	15	6	8	1430
1431	JosÃ© Arboleda	10	33	56	1431
1432	Ã“scar Leonardo SÃ¡nchez	2	6	26	1432
1433	Dayana Palacios	7	20	91	1433
1434	Deisy RamÃ­rez Hoyos	2	17	16	1434
1435	MarÃ­a Gil	3	1	10	1435
1436	Vanesa Luisa Parra SÃ¡nchez	9	4	51	1436
1438	Isabel Jackeline Hurtado	4	17	42	1438
1439	Catherine Luz Salazar	14	45	38	1439
1440	Sandra GÃ³mez Valencia	10	13	42	1440
1441	Dary Constanza Melo GonzÃ¡lez	13	28	3	1441
1442	InÃ©s Jaimes	3	16	48	1442
1443	Santiago William MuÃ±oz Castillo	1	15	34	1443
1444	Carlos Acosta	11	10	60	1444
1445	Fernando JosÃ© Barrera BolÃ­var	4	39	41	1445
1446	AndrÃ©s MartÃ­nez LÃ³pez	5	6	48	1446
1447	Adriana HernÃ¡ndez	4	17	28	1447
1448	Fernando David LÃ³pez Camargo	4	38	53	1448
1449	John Manuel Arrieta Rojas	9	40	26	1449
1451	Johan Juan Palacios Angulo	2	45	53	1451
1452	Mabel Bernal CastaÃ±o	1	35	71	1452
1453	GermÃ¡n Willian VÃ¡squez	9	13	7	1453
1895	Janeth Buitrago	12	42	19	1895
1454	MarÃ­a Marcela PÃ©rez Betancur	10	25	22	1454
1456	Diego Miller GuzmÃ¡n Ospino	10	40	59	1456
1457	AndrÃ©s Cristian Fajardo Silva	13	12	21	1457
1458	JosÃ© HernÃ¡ndez	9	49	4	1458
1459	Jhon Antonio HernÃ¡ndez Osorio	7	37	13	1459
1460	MarÃ­a DurÃ¡n	6	5	40	1460
1461	Katerine MarÃ­a CortÃ©s	1	28	74	1461
1462	Elizabeth Michel GÃ³mez	7	4	69	1462
1463	JosÃ© AndrÃ©s GutiÃ©rrez RamÃ­rez	8	1	39	1463
1465	MarÃ­a Milena Ortiz	8	28	33	1465
1466	Hernando Ruiz Moreno	9	31	45	1466
1467	Milton GonzÃ¡lez	14	43	60	1467
1468	Magnolia Alba Valencia RenterÃ­a	3	33	87	1468
1469	Fernanda GarcÃ­a Tovar	1	15	78	1469
1470	Dary Julia Torres Carvajal	9	19	61	1470
1471	MarÃ­a Cruz MarÃ­n	15	6	34	1471
1472	Steven MartÃ­n CastaÃ±o BarragÃ¡n	11	19	18	1472
1473	Camilo Carmona SÃ¡nchez	14	27	90	1473
1474	Hernando Medina Polo	3	27	33	1474
1475	Patricia CalderÃ³n Cano	9	31	56	1475
1476	Elizabeth Montenegro	14	48	93	1476
1477	Silvio Francisco Mosquera Ayala	3	41	37	1477
1478	Liliana Pilar Palacio Molina	5	37	77	1478
1479	Jackeline MÃ©ndez Arboleda	10	5	86	1479
1480	David Figueroa HernÃ¡ndez	8	49	15	1480
1481	Yolanda Marleny Gaviria	7	19	2	1481
1482	Leonardo William Palacios Quiroga	5	21	27	1482
1484	AndrÃ©s Henao Vega	4	30	52	1484
1486	Miguel JosÃ© Torres VÃ©lez	5	20	65	1486
1487	Rafael Bedoya Pineda	9	2	95	1487
1488	LucÃ­a Vargas	10	36	34	1488
1489	Ã“scar MuÃ±oz Romero	15	7	95	1489
1490	MarÃ­a Martha Parra Salazar	9	24	56	1490
1491	Lorena Adriana GonzÃ¡lez	4	14	17	1491
1492	Ferney HernÃ¡ndez MartÃ­nez	10	24	82	1492
1493	JosÃ© Willian Mosquera	14	2	61	1493
1495	Pilar Fernanda Perdomo Montoya	2	50	92	1495
1496	Tatiana RamÃ­rez	9	17	97	1496
1497	Lizeth Andrea GutiÃ©rrez AlarcÃ³n	13	14	17	1497
1498	Carmenza Catalina Rojas Espinosa	1	29	22	1498
1499	Ingrid Ortiz Rengifo	11	7	30	1499
1500	Laura Yaneth Leal LondoÃ±o	3	48	86	1500
1501	Edilson Alejandro Vega	15	11	10	1501
1502	Esneider NiÃ±o	6	8	27	1502
1503	Teresa Guerrero Ochoa	1	35	23	1503
1504	William VÃ¡squez Gil	4	8	25	1504
1505	William DÃ­az	7	29	45	1505
1506	Eduardo Medina Galeano	7	24	97	1506
1507	Edwin VÃ­ctor Velandia Torres	1	39	57	1507
1508	Silvio Luis Herrera Moreno	9	15	39	1508
1509	Esteban Palacios Castillo	4	49	85	1509
1510	Wilson Enrique PÃ©rez	7	45	6	1510
1511	Eduardo GÃ³mez	6	25	7	1511
1513	Yohana Molina Valencia	8	6	31	1513
1514	Cristian Angulo VÃ¡squez	15	4	92	1514
1515	Ana Bernal	12	21	85	1515
1517	Alberto Giraldo Ocampo	3	50	92	1517
1518	Jhon HÃ©ctor Restrepo	9	16	1	1518
1519	Yolanda Beatriz CastaÃ±eda	15	21	77	1519
1520	AndrÃ©s Milton RincÃ³n Obando	9	49	45	1520
1521	MarÃ­a Tovar	1	12	21	1521
1522	Alba Julieth GonzÃ¡lez	9	4	56	1522
1523	Francisco SebastiÃ¡n GarzÃ³n PÃ©rez	9	12	23	1523
1524	AngÃ©lica MartÃ­nez	8	17	14	1524
1525	Susana Luz Bustos Morales	3	48	2	1525
1526	Felipe Juan Ramos Vega	8	9	45	1526
1527	Eduar SuÃ¡rez Gil	11	6	86	1527
1528	JesÃºs AndrÃ©s Pinto Ortega	14	27	90	1528
1529	Gabriel Carlos Nieto	1	42	95	1529
1530	Brayan Villa	1	48	56	1530
1531	Carlos PÃ¡ez Moreno	13	34	55	1531
1532	Giovanny Enrique JimÃ©nez GonzÃ¡lez	12	47	65	1532
1533	Fernanda MuÃ±oz RodrÃ­guez	6	21	1	1533
1534	Enrique GermÃ¡n GutiÃ©rrez	6	32	42	1534
1535	Juan Ismael Medina Jaimes	2	15	44	1535
1536	Juan MartÃ­nez	8	6	3	1536
1537	Alberto Humberto GonzÃ¡lez	9	9	68	1537
1538	Amanda Paola Morales Agudelo	11	29	37	1538
1539	Henry DÃ­az Camacho	4	9	79	1539
1540	MarÃ­a Adriana Ballesteros	1	46	4	1540
1541	Mauricio Duque	8	49	27	1541
1542	Guillermo Pedro GutiÃ©rrez BermÃºdez	4	21	92	1542
1543	MarÃ­a Margarita MartÃ­nez Moreno	8	42	83	1543
1544	Antonio Alberto MuÃ±oz	1	21	62	1544
1545	Laura LucÃ­a Ortiz	12	39	8	1545
1546	Aura HernÃ¡ndez CastaÃ±eda	5	45	64	1546
1547	Nelson Sierra SÃ¡nchez	14	43	5	1547
1548	Patricia Patricia BermÃºdez SÃ¡nchez	11	3	87	1548
1549	MarÃ­a Liseth Pardo BolÃ­var	8	48	62	1549
1550	JuliÃ¡n GÃ³mez	13	23	28	1550
1551	Susana MarÃ­a RodrÃ­guez	1	38	82	1551
1552	Carolina Salazar Cruz	1	15	77	1552
1553	Arturo AndrÃ©s Loaiza	13	43	84	1553
1554	Rosa RodrÃ­guez	15	21	10	1554
1555	Marcela Mercedes SuÃ¡rez Mosquera	15	44	43	1555
1556	Fernando Triana Paz	2	23	14	1556
1557	Eliecer MartÃ­nez Estrada	12	18	55	1557
1558	Melissa Luz DÃ­az	9	19	81	1558
1559	Lorena Mosquera Navarro	15	11	12	1559
1560	AndrÃ©s SuÃ¡rez SÃ¡nchez	13	27	34	1560
1561	RenÃ© Cardona	13	38	69	1561
1562	Liceth Luz RodrÃ­guez Contreras	4	13	72	1562
1564	Claudia Ospina RamÃ­rez	8	20	14	1564
1565	AndrÃ©s RodrÃ­guez	8	6	39	1565
1566	Carlos Daniel Medina	5	29	67	1566
1567	Carolina Erazo Lara	1	8	87	1567
1568	Camilo JosÃ© Bonilla	2	20	31	1568
1569	Marina Orozco MartÃ­nez	2	35	12	1569
1570	MarÃ­a Prieto Rojas	1	24	9	1570
1571	Camilo Guerra	9	32	44	1571
1572	MÃ³nica Silvia Jaimes	11	47	43	1572
1573	Liliana MarÃ­a Ospina MartÃ­nez	6	39	74	1573
1574	Lorena MarÃ­a FernÃ¡ndez	9	7	64	1574
1575	Paola Caicedo	5	13	51	1575
1576	MarÃ­a Guerrero Ortiz	2	46	58	1576
1577	Sandra Lina MuÃ±oz LondoÃ±o	11	6	60	1577
1578	NÃ©stor Pinto	2	15	96	1578
1579	Luis JesÃºs Rojas HernÃ¡ndez	14	2	14	1579
1580	Sandra Alejandra FlÃ³rez	12	13	22	1580
1581	Gilma Galindo Toro	7	42	52	1581
1582	Patricia Moreno	9	17	51	1582
1583	Rafael JosÃ© Vera	7	21	85	1583
1584	Luis Antonio HernÃ¡ndez Valencia	12	1	91	1584
1585	VÃ­ctor Palacios Amaya	6	31	70	1585
1586	Luz Barrios	8	1	44	1586
1587	RocÃ­o Marisol FlÃ³rez	2	27	56	1587
1588	Carlos David Medina	5	15	58	1588
1589	Marina Heidy Santos	8	2	18	1589
1590	Juan Torres Caro	5	30	80	1590
1591	Enrique Manuel Ariza Rosero	3	21	11	1591
1592	MarÃ­a Martha Padilla	14	21	3	1592
1594	Giovanni Carlos Rojas	7	35	29	1594
1595	MarÃ­a Luz Vargas	12	6	49	1595
1596	Marino Enrique Gaviria Bernal	12	8	42	1596
1597	Juan Valencia	1	7	58	1597
1598	Manuel Posada	3	3	39	1598
1599	Erika MarÃ­n Contreras	3	33	91	1599
1600	MarÃ­a HernÃ¡ndez Sandoval	2	27	9	1600
1601	Ana MejÃ­a	12	8	12	1601
1602	Jorge Murcia HernÃ¡ndez	13	36	33	1602
1603	Jhon PinzÃ³n	4	32	76	1603
1604	Eduardo Edisson Trujillo GarcÃ­a	8	13	100	1604
1607	Alejandro Fonseca JimÃ©nez	14	31	60	1607
1608	Yury RocÃ­o Torres	6	33	54	1608
1609	JosÃ© JosÃ© Ortiz MartÃ­nez	3	28	91	1609
1610	Alejandro Alex HernÃ¡ndez MejÃ­a	4	36	77	1610
1611	Julio PÃ©rez	1	28	66	1611
1612	Luis Maicol Moreno Arango	5	5	70	1612
1614	Sonia NiÃ±o	9	42	34	1614
1615	Martha Jenny FlÃ³rez RamÃ­rez	15	24	85	1615
1616	Carmen MarÃ­a MÃ©ndez	11	27	33	1616
1617	JesÃºs Castillo MartÃ­nez	14	23	51	1617
1618	JuliÃ¡n Camilo Uribe	15	39	53	1618
1619	Marina Torres	11	32	86	1619
1620	Alexander Caicedo LÃ³pez	7	36	80	1620
1621	Robinson Gustavo Ospina Uribe	14	43	49	1621
1622	Luz Cristina SÃ¡nchez LÃ³pez	3	28	64	1622
1623	Leonardo David Galindo	15	10	98	1623
1624	Marleny Olga Sandoval CerÃ³n	4	17	91	1624
1625	Camilo Guillermo Morales	15	37	95	1625
1626	Cristina Gallego Cardona	10	31	52	1626
1627	Steven Felipe LÃ³pez Cantillo	9	35	81	1627
1628	Yeison NÃºÃ±ez Giraldo	9	25	2	1628
1629	David Ariza HernÃ¡ndez	15	10	87	1629
1630	SofÃ­a Acevedo	4	19	16	1630
1631	Olga Gaviria Barrera	14	15	38	1631
1632	Dahiana Carolina Acevedo	15	12	11	1632
1633	Elena Valencia	9	35	80	1633
1634	Carolina Arenas	14	40	71	1634
1635	JosÃ© RubÃ©n GutiÃ©rrez	12	42	13	1635
1636	Pedro JosÃ© MartÃ­nez Monroy	13	33	72	1636
1637	AndrÃ©s Guerrero	13	26	66	1637
1638	Leidy Vanessa CÃ¡ceres	6	23	99	1638
1639	Javier Miranda MartÃ­nez	9	16	59	1639
1640	Viviana SuÃ¡rez MarÃ­n	7	15	74	1640
1641	Julio Rivera Medina	11	32	57	1641
1642	Rosalba Carolina Buitrago	6	50	34	1642
1643	Rosa Ana Cardona	1	18	90	1643
1644	Mary Johana Espinosa	15	15	9	1644
1645	Antonio Edgar Leal	6	32	19	1645
1646	InÃ©s Buitrago	13	2	99	1646
1647	Carlos GonzÃ¡lez Salazar	5	42	52	1647
1648	Daniel LÃ³pez	4	33	32	1648
1649	Dary MuÃ±oz	2	42	86	1649
1650	Luz Obando JimÃ©nez	1	46	46	1650
1651	Nancy Rosa Arenas	4	35	28	1651
1652	Ana Flor PÃ©rez Daza	15	29	4	1652
1653	Diana Arteaga	13	43	83	1653
1654	Eduardo Daniel Gaviria Agudelo	6	38	93	1654
1655	Edison Jonathan HernÃ¡ndez Arias	10	49	77	1655
1656	Lina LondoÃ±o	5	27	8	1656
1657	Santiago Fernando CastaÃ±o GarcÃ­a	10	48	96	1657
1658	Cecilia Arias	9	47	45	1658
1659	Juliana Gloria Espitia	4	37	65	1659
1660	JesÃºs Cardona PÃ©rez	7	50	5	1660
1661	Edith Luz LeÃ³n Franco	6	32	24	1661
1662	RaÃºl Ojeda	4	24	5	1662
1663	Ã“scar Pablo Vargas	13	3	92	1663
1664	MarÃ­a Diana LÃ³pez RodrÃ­guez	8	36	43	1664
1665	JesÃºs RamÃ­rez	9	17	60	1665
1666	HÃ©ctor HernÃ¡ndez	7	23	66	1666
1667	Marcela Marina Padilla Roa	14	45	97	1667
1668	Fernando Fernando GarcÃ­a DÃ­az	5	27	37	1668
1669	Jhon JimÃ©nez Castro	12	34	4	1669
1670	CÃ©sar Rojas	8	6	17	1670
1671	Angie Leidy Correa Rivera	3	17	26	1671
1672	SebastiÃ¡n Mora	15	31	93	1672
1673	Luz Virginia Sarmiento	13	7	49	1673
1674	Jorge Vanegas BeltrÃ¡n	15	48	98	1674
1675	MarÃ­a Adela CÃ¡rdenas Ruiz	14	22	90	1675
1677	Luis Lozano Camacho	4	24	78	1677
1678	JosÃ© DamiÃ¡n Velasco RodrÃ­guez	15	1	30	1678
1679	Fredy Torres Valencia	3	7	39	1679
1680	Juan Murillo	14	28	81	1680
1681	Luz Cecilia HernÃ¡ndez	15	24	33	1681
1682	Luisa GarcÃ­a	5	13	78	1682
1683	Jimmy SepÃºlveda CalderÃ³n	14	49	74	1683
1684	Alfonso Ramos Ochoa	7	11	35	1684
1685	Fernando Herrera	11	14	76	1685
1686	Patricia Becerra	12	20	62	1686
1687	Alexander Mantilla Caballero	6	12	38	1687
1688	RubÃ©n Tamayo Montes	14	9	16	1688
1689	Enrique Alberto PÃ©rez	4	39	39	1689
1690	Estela Yeimy GarcÃ­a Pardo	3	18	44	1690
1691	Melissa Elizabeth BolaÃ±os GonzÃ¡lez	1	39	58	1691
1692	Miguel LÃ³pez BarragÃ¡n	14	3	65	1692
1693	Javier JosÃ© Castillo RodrÃ­guez	8	42	11	1693
1694	MarÃ­a Jenny VÃ¡squez Castillo	11	45	27	1694
1695	Victoria Yudy Pacheco Pineda	4	30	92	1695
1696	Alexandra Josefina Anaya Sandoval	14	44	9	1696
1698	Carlos Esneider Gamboa	9	28	92	1698
1699	Alicia Ana Acevedo JimÃ©nez	5	6	80	1699
1700	Enrique Cifuentes Franco	14	24	77	1700
1701	Estiven HernÃ¡ndez	9	43	49	1701
1702	Sandra Carmen LÃ³pez	10	21	41	1702
1703	Adolfo Antonio Rivera Acevedo	3	41	10	1703
1704	Samuel MejÃ­a	1	35	97	1704
1706	Esperanza Murillo	5	48	34	1706
1707	Liliana Ramos Castro	2	34	31	1707
1708	Esperanza Quintero RamÃ­rez	15	47	18	1708
1709	JesÃºs Arias	6	35	64	1709
1710	Libia Gil	12	50	97	1710
1711	HernÃ¡n OrdÃ³Ã±ez	15	29	67	1711
1712	LucÃ­a Milena Herrera	5	15	30	1712
1713	Alejandra Vargas	14	6	66	1713
1714	Fernanda Daza Moreno	2	40	83	1714
1715	Alfonso Roa	10	14	17	1715
1716	Adriana PÃ©rez PÃ©rez	14	24	21	1716
1717	Armando JosÃ© RodrÃ­guez Valencia	9	19	93	1717
1718	Luz Martha Rivas	4	18	17	1718
1719	Yuliana GarcÃ­a Meza	13	29	79	1719
1720	GermÃ¡n Guerra HernÃ¡ndez	9	32	52	1720
1721	AdriÃ¡n Carlos Pineda Delgado	13	36	41	1721
1722	Carlos AndrÃ©s Corredor LÃ³pez	11	31	60	1722
1724	Victoria FernÃ¡ndez	14	35	99	1724
1725	Ernesto IvÃ¡n BeltrÃ¡n	11	10	10	1725
1726	Milena Betancur	12	41	16	1726
1727	Sandra Damaris JimÃ©nez Vargas	7	25	47	1727
1728	Carlos BenÃ­tez	7	18	80	1728
1729	Amparo LeÃ³n	11	42	5	1729
1730	Bernardo Antonio Sierra	5	46	73	1730
1731	Janeth Linda Gaviria MartÃ­nez	7	20	51	1731
1732	Alfonso Guerrero	7	35	43	1732
1733	Camilo Alberto Monroy	9	7	59	1733
1734	JuliÃ¡n DÃ­az	8	47	46	1734
1735	Leticia Roa	6	1	61	1735
1736	IvÃ¡n AndrÃ©s Ariza	1	11	2	1736
1737	Cristina Elena SÃ¡nchez PinzÃ³n	5	36	72	1737
1738	Sonia LucÃ­a Rivas	3	1	53	1738
1740	Roberto GarcÃ­a	13	47	57	1740
1741	Brayan Castellanos	7	12	87	1741
1742	Natalia Ruiz	8	35	61	1742
1743	EfrÃ©n Mario SÃ¡nchez	1	26	70	1743
1744	Josefina Julieth PeÃ±a	6	44	80	1744
1746	AndrÃ©s Francisco Mendoza Amaya	4	19	8	1746
1747	Paola BohÃ³rquez Serrano	10	31	69	1747
1748	Marcos Orlando MejÃ­a Zapata	6	12	84	1748
1749	Patricia FlÃ³rez Parra	9	31	4	1749
1750	Aida SuÃ¡rez MartÃ­nez	2	34	18	1750
1751	Wilmer PÃ©rez HernÃ¡ndez	3	31	45	1751
1752	Consuelo Yaneth Villamizar	12	46	40	1752
1753	Alberto GarcÃ­a Herrera	11	41	82	1753
1754	Miguel Ã“scar Ariza Caicedo	11	42	38	1754
1755	Clara Yesenia Mena PabÃ³n	3	35	65	1755
1756	Anyi Benavides	1	4	21	1756
1757	Fernando Alberto RodrÃ­guez Mesa	11	40	81	1757
1758	Marina GonzÃ¡lez Andrade	8	37	38	1758
1759	Carlos Jorge MejÃ­a Alfonso	9	42	97	1759
1760	Rafael MartÃ­nez MÃ¡rquez	12	15	95	1760
1761	Alejandro Manrique Montenegro	8	10	93	1761
1762	Esther Johanna Moreno	2	29	66	1762
1763	Jhon MartÃ­nez	2	22	13	1763
1764	GermÃ¡n Chaparro Mora	14	36	29	1764
1765	Cecilia Ruiz	7	41	21	1765
1766	Alejandro Alberto Vallejo	11	18	72	1766
1767	MarÃ­a SÃ¡nchez	9	21	16	1767
1768	MarÃ­a Elena Saavedra CortÃ©s	13	38	40	1768
1769	Javier Tamayo Arrieta	14	12	66	1769
1770	LucÃ­a Graciela MuÃ±oz	2	46	94	1770
1771	Angie Lilian Velasco	7	16	7	1771
1772	Junior LÃ³pez	14	20	86	1772
1773	Arnulfo IvÃ¡n Reyes	1	23	29	1773
1774	Tania Piedad Salgado PÃ©rez	11	28	19	1774
1775	Milena Jennifer Espitia	8	45	26	1775
1776	Eliecer Escobar MuÃ±oz	2	11	51	1776
1777	CÃ©sar Antonio Ortiz	14	34	51	1777
1778	Alberto AndrÃ©s Rojas	9	39	95	1778
1779	Fabio Juan Duarte Medina	5	19	62	1779
1780	Fernando Luis Angarita Sierra	12	39	40	1780
1781	Sandra Angarita Molina	8	9	50	1781
1782	Diego Angulo ArÃ©valo	4	24	26	1782
1896	Joan Medina	11	30	73	1896
1783	Yolanda Alicia Reyes Burbano	15	18	38	1783
1784	JosÃ© LÃ³pez SÃ¡nchez	14	15	39	1784
1785	JosÃ© Ciro Medina Guerrero	11	14	34	1785
1786	Jaider Eduardo Padilla	1	23	87	1786
1787	MarÃ­a Viviana GarcÃ­a MuÃ±oz	6	41	29	1787
1789	Fredy RamÃ³n GonzÃ¡lez	1	34	37	1789
1790	Stella Mena	8	31	18	1790
1791	Manuel Gaviria	4	18	69	1791
1792	Antonio Torres Salazar	15	19	46	1792
1793	JesÃºs Medina	6	3	74	1793
1794	RaÃºl Maldonado DÃ­az	7	5	61	1794
1795	LucÃ­a Martha Ariza	6	16	40	1795
1796	Beatriz RamÃ­rez Camargo	1	9	38	1796
1797	Angie Barrera	8	14	50	1797
1798	Ferney Roberto Pacheco Cabrera	15	39	40	1798
1799	Patricia Daniela GarcÃ­a CastaÃ±o	11	13	17	1799
1800	Andrea Andrea Mora	7	25	53	1800
1801	Mario Luis Moreno RÃ­os	3	20	23	1801
1802	Leonardo MartÃ­nez	4	32	71	1802
1803	Edith Miriam Palacios	5	19	60	1803
1804	Diana LÃ³pez Serrano	15	14	27	1804
1805	Luis CÃ³rdoba	7	39	87	1805
1806	MarÃ­a Torres Ortiz	12	19	45	1806
1807	Diana Caicedo	7	18	78	1807
1808	CÃ©sar Julio GonzÃ¡lez CalderÃ³n	3	34	71	1808
1809	Sara Alba RodrÃ­guez	11	16	86	1809
1810	Daniel GarcÃ­a	8	35	49	1810
1811	Juan Yerson MÃ©ndez	15	19	36	1811
1812	Ruth Aguilar Contreras	9	9	40	1812
1813	MarÃ­a Patricia CÃ³rdoba MartÃ­nez	10	47	55	1813
1814	Ana MarÃ­a Camargo CerÃ³n	10	46	10	1814
1816	Fernando Caro Prada	5	41	9	1816
1817	Ana PÃ©rez Cruz	9	11	53	1817
1818	Alberto Yeison Murillo Arias	14	47	7	1818
1819	David Delgado PÃ©rez	1	41	96	1819
1820	Cecilia Castro GarcÃ­a	14	3	96	1820
1821	Humberto Luis Zambrano	3	5	88	1821
1822	Marcela Adriana HernÃ¡ndez RamÃ­rez	14	27	25	1822
1823	Felipe Stiven RodrÃ­guez CalderÃ³n	4	34	13	1823
1824	Dayana VelÃ¡squez GonzÃ¡lez	1	29	19	1824
1825	Ismael CÃ©sar Villamizar	3	40	45	1825
1826	Patricia Alba Rueda Morales	13	33	61	1826
1827	Jorge Miranda	12	16	25	1827
1828	MarÃ­a Torres	8	45	86	1828
1829	Elena Alzate	8	8	86	1829
1831	MarÃ­a Sandra HernÃ¡ndez GarcÃ­a	5	41	29	1831
1832	Estella MartÃ­nez Cardona	3	13	34	1832
1833	Sandra GÃ³mez GÃ³mez	3	17	53	1833
1834	Liliana MarÃ­a VÃ¡squez Hurtado	7	44	11	1834
1835	Ana GÃ³mez Ocampo	13	37	90	1835
1836	Jair Carlos Sandoval Arias	15	27	73	1836
1837	Myriam Portilla GonzÃ¡lez	14	49	4	1837
1838	Luis Ortiz	13	24	4	1838
1839	RubÃ©n GÃ³mez	13	20	93	1839
1840	Ignacio Montoya Vargas	11	18	41	1840
1841	Enrique Torres Puentes	11	41	86	1841
1842	Luz Margarita LondoÃ±o	14	46	17	1842
1843	Juan Ruiz	11	12	71	1843
1844	Eduardo Fidel Jaramillo	12	31	50	1844
1845	Henry Moreno	5	41	79	1845
1846	David RodrÃ­guez	13	46	52	1846
1847	Isabel Caicedo Barrios	14	4	76	1847
1848	Luis Elkin Quiroga Ortega	9	32	78	1848
1849	Javier Torres FlÃ³rez	12	3	92	1849
1850	AndrÃ©s Erazo	1	24	52	1850
1851	HÃ©ctor Fredy MartÃ­nez Pedraza	4	5	18	1851
1852	Alexis Luis Paz	5	30	39	1852
1853	Alexis PÃ¡ez Guerrero	11	48	19	1853
1854	Alfonso AndrÃ©s Amaya Montoya	11	28	54	1854
1855	Hernando Vicente GarcÃ­a Delgado	9	2	19	1855
1856	Luis RÃ­os	6	31	36	1856
1857	Marina GonzÃ¡lez	14	27	70	1857
1858	Francisco Alexander Castro	5	28	39	1858
1859	Ana Cecilia RodrÃ­guez	11	42	81	1859
1860	JosÃ© HernÃ¡ndez GonzÃ¡lez	3	47	90	1860
1861	Fernando Vanegas	3	10	81	1861
1862	Diego RamÃ­rez	8	12	67	1862
1864	JesÃºs JosÃ© Gil PatiÃ±o	9	28	62	1864
1865	Andrea Liliana Herrera	4	35	16	1865
1866	Jimmy VelÃ¡squez	6	11	68	1866
1867	Luz Paula LÃ³pez Salcedo	9	10	23	1867
1868	Alberto RodrÃ­guez CÃ³rdoba	5	8	25	1868
1869	Carlos Guillermo GÃ³mez	3	9	70	1869
1870	Samuel Cabrera Tovar	14	5	33	1870
1871	Marcela Naranjo	4	9	64	1871
1872	Brayan Cuesta	3	4	19	1872
1873	Alejandro Carlos RÃ­os MarÃ­n	4	48	12	1873
1874	Luis Jairo Contreras Carmona	10	26	74	1874
1875	Luisa VelÃ¡squez	3	22	1	1875
1876	MarÃ­a Riascos Rueda	13	4	5	1876
1877	David Pineda GuzmÃ¡n	8	32	23	1877
1878	Carmen Marleny Mesa Lozano	10	33	6	1878
1879	Carlos HernÃ¡n Santos PÃ©rez	2	16	65	1879
1880	Ana Alba Contreras	14	10	1	1880
1881	Edgar Lozano Torres	5	24	88	1881
1882	Esperanza Mary RodrÃ­guez Gaviria	15	8	10	1882
1883	HÃ©ctor Cantillo	12	40	12	1883
1884	Blanca Luz FlÃ³rez Angarita	3	13	76	1884
1885	Gabriel Carlos Quintero	3	6	63	1885
1886	Paola MÃ³nica Bernal Restrepo	1	36	33	1886
1887	Fanny Juana Castillo	5	37	41	1887
1888	Damaris PeÃ±a	4	14	13	1888
1889	MarÃ­a GonzÃ¡lez	6	44	39	1889
1891	Nohora Paola Salamanca Toro	15	29	12	1891
1892	Johanna GonzÃ¡lez	6	38	21	1892
1893	Marcela Arango	11	20	54	1893
1894	RocÃ­o GarcÃ©s	2	4	50	1894
1898	Ana Esther RodrÃ­guez Silva	15	5	43	1898
1899	Reinaldo Reyes Soto	15	12	43	1899
1900	Milena Paola Delgado	8	33	5	1900
1901	Marcela Lucy MartÃ­nez Mena	10	14	73	1901
1902	Karen Medina	5	16	76	1902
1903	Eugenia Cruz	1	31	8	1903
1904	SebastiÃ¡n Gabriel SepÃºlveda	1	22	21	1904
1905	Nidia Valderrama Pacheco	13	24	23	1905
1906	Miriam Arroyo Portilla	5	46	98	1906
1908	JosÃ© Enrique LondoÃ±o MuÃ±oz	13	39	34	1908
1909	Edna Flor Murcia SuÃ¡rez	13	28	14	1909
1910	Alexander Orlando Ramos	15	33	33	1910
1911	ElÃ­as Luis Cifuentes	2	45	68	1911
1912	Luz MartÃ­nez Rojas	5	16	22	1912
1913	Isaac Pineda PÃ©rez	11	29	77	1913
1914	Marina Silva Reyes	7	46	50	1914
1916	Gisela Yina DÃ­az	6	32	60	1916
1917	Francy Salazar	11	3	74	1917
1919	HernÃ¡n JosÃ© RamÃ­rez GuzmÃ¡n	1	28	6	1919
1920	AndrÃ©s Antonio Sierra	6	3	35	1920
1921	Andrea Luz Cabrera	4	42	41	1921
1922	Lorena Yadira Carvajal Tovar	3	14	55	1922
1923	Eliecer Parra Daza	11	34	34	1923
1924	Elisa Ramos	15	19	4	1924
1925	Manuel Buitrago Cabrera	6	4	91	1925
1926	Gabriela Tulia PÃ©rez Campo	14	34	55	1926
1927	Eliecer FernÃ¡ndez Ardila	8	4	33	1927
1928	Eduardo Alberto Quintero	15	20	55	1928
1929	Manuela Lina Cardozo	13	32	12	1929
1930	Helena Medina Trujillo	12	13	86	1930
1931	Juan David Rivas Ortiz	11	19	85	1931
1932	Stella MarÃ­a PÃ©rez CastaÃ±o	11	41	59	1932
1934	SebastiÃ¡n Juan Cardona	3	40	43	1934
1935	AndrÃ©s IvÃ¡n Giraldo	5	3	5	1935
1936	Carmen MarÃ­a VÃ©lez	2	4	73	1936
1937	Jhon Sergio Arenas	10	44	41	1937
1938	Ignacio Castro Gaviria	14	4	40	1938
1939	Dany Joel Valencia Bernal	5	42	92	1939
1940	Gisela Jenny HernÃ¡ndez CastaÃ±o	11	8	57	1940
1941	MarÃ­a JazmÃ­n LÃ³pez	12	17	85	1941
1943	Edinson JuliÃ¡n GÃ³mez GarcÃ­a	3	43	66	1943
1944	Ana Mary Monroy	2	39	68	1944
1945	Luz Mary Forero Sierra	9	36	99	1945
1946	MarÃ­a Teresa MarÃ­n	10	15	49	1946
1947	Eduardo Hernando Hurtado Benavides	5	20	25	1947
1948	Miguel Alirio Rojas Sanabria	8	31	68	1948
1949	Patricia Leonor HernÃ¡ndez RodrÃ­guez	13	12	46	1949
1950	Stiven CalderÃ³n	6	18	49	1950
1951	Wilson Ronald Herrera	9	20	21	1951
1952	JosÃ© Hoyos Cardozo	4	22	94	1952
1953	Ingrid LondoÃ±o PÃ©rez	4	39	7	1953
1954	Rafael CÃ©sar VÃ¡squez	7	10	51	1954
1955	Paola Isabel RamÃ­rez Espitia	1	7	37	1955
1956	Pablo Orlando HernÃ¡ndez Sierra	10	16	4	1956
1957	MarÃ­a Juliana Arango	11	30	82	1957
1958	Luis Cristian CortÃ©s	10	25	83	1958
1959	Alfredo Cuesta	9	6	7	1959
1960	Mauricio SebastiÃ¡n MarÃ­n	4	35	72	1960
1961	Jhon Sergio Vallejo	7	43	28	1961
1963	Edwin Eliecer LondoÃ±o SÃ¡nchez	11	28	88	1963
1964	Juan MÃ¡rquez Ortega	8	4	87	1964
1965	MarÃ­a Ospina MuÃ±oz	10	17	62	1965
1966	Esther Carolina SÃ¡nchez	8	43	48	1966
1967	Joel JimÃ©nez Triana	14	45	22	1967
1968	Silvio Luis GÃ³mez Valencia	7	1	91	1968
1969	Alexander Ancizar LondoÃ±o Camacho	15	8	10	1969
1970	Mauricio Gamboa	12	3	6	1970
1971	Paola Correa Rivera	10	19	85	1971
1972	Dayana Duarte	7	13	29	1972
1973	Diego RodrÃ­guez VÃ¡squez	14	16	19	1973
1974	MarÃ­a DÃ­az	15	45	69	1974
1975	Daniel Ã“scar Espinosa	13	1	55	1975
1976	Shirley Diana Melo Castro	3	34	39	1976
1978	MarÃ­a Flor HernÃ¡ndez	13	19	26	1978
1979	Diana Marcela Vergara Zambrano	10	19	31	1979
1980	Margarita Amparo Figueroa	1	17	42	1980
1981	Vanessa MuÃ±oz PÃ©rez	1	19	75	1981
1982	Sonia GarcÃ­a	2	34	30	1982
1983	Pedro Daniel Pacheco	15	1	8	1983
1984	Luz Myriam MÃ¡rquez Contreras	13	19	37	1984
1985	InÃ©s Damaris LeÃ³n	1	26	94	1985
1986	Carlos JosÃ© Castro Espinosa	8	27	45	1986
1987	Yamile Cecilia Blanco	9	31	2	1987
1988	Samir CÃ³rdoba Aguilar	6	18	9	1988
1989	AngÃ©lica Ligia Campo	10	20	51	1989
1990	Paula Irma RodrÃ­guez ChacÃ³n	13	13	100	1990
1991	Esteban Augusto FlÃ³rez Cruz	6	23	18	1991
1992	Martha GarcÃ­a	2	31	25	1992
1993	Esteban Ruiz MartÃ­nez	14	16	42	1993
1994	Marino BeltrÃ¡n	1	43	61	1994
1995	Alberto JosÃ© GutiÃ©rrez	15	24	6	1995
1996	MarÃ­a Victoria Bernal	12	48	91	1996
1997	Astrid Bernal	5	43	34	1997
1999	Felipe Camilo Ramos Mora	6	11	28	1999
2000	Jhon Alberto VÃ¡squez CÃ¡rdenas	12	13	26	2000
2001	Dahiana Elvia MartÃ­nez Parra	6	13	72	2001
2002	Yulieth MartÃ­nez	12	38	79	2002
2004	Fernando Jeison Solano	6	50	23	2004
2005	Alexander Galindo Naranjo	2	50	94	2005
2006	Isabel MarÃ­a PÃ©rez	4	45	58	2006
2007	JosÃ© Arias	6	42	43	2007
2008	Luis MartÃ­nez RodrÃ­guez	7	31	37	2008
2009	Olga Vergara	14	20	99	2009
2010	RaÃºl Luis Zapata Cruz	5	30	42	2010
2011	CÃ©sar Sergio Triana	8	20	82	2011
2012	Isabel Adriana Camargo Montes	9	28	14	2012
2013	Stiven Fredy Caro SuÃ¡rez	12	28	23	2013
2014	Luz LucÃ­a Luna	10	39	70	2014
2015	Laura Rojas RodrÃ­guez	7	48	97	2015
2016	Alberto Galindo RÃ­os	4	24	47	2016
2017	Harold Daniel Figueroa Ruiz	6	50	24	2017
2018	Katherine Monroy	3	49	55	2018
2019	Alejandra Caballero GuzmÃ¡n	1	5	32	2019
2020	Luz Buitrago	9	16	14	2020
2021	Pablo Herrera Nieto	6	40	6	2021
2022	Alejandro Valencia	9	25	45	2022
2023	Esperanza Carolina Quiroga Sanabria	11	7	63	2023
2024	Carlos DurÃ¡n	1	50	31	2024
2025	Luz Prieto VÃ©lez	14	35	79	2025
2027	Dario Castro MartÃ­nez	7	40	82	2027
2028	Judith Maribel MuÃ±oz	9	39	34	2028
2029	Milena Amanda Carrillo	13	4	9	2029
2030	Elsa Carvajal Mosquera	2	22	45	2030
2031	AndrÃ©s Silva	1	18	96	2031
2032	Rosa Cecilia Henao Valderrama	4	26	33	2032
2033	Juan Galeano RodrÃ­guez	15	48	79	2033
2034	AndrÃ©s Alberto Acevedo Moreno	4	36	5	2034
2035	HÃ©ctor Espinosa Rivera	13	41	64	2035
2036	Leidy Castro	14	44	5	2036
2038	JosÃ© Kevin Vera	2	27	46	2038
2039	Piedad Margarita MarÃ­n	9	42	4	2039
2040	JosÃ© Camacho	15	24	90	2040
2041	Ramiro Castro Salas	10	7	81	2041
2042	MarÃ­a Rivas	3	46	55	2042
2043	AdriÃ¡n MuÃ±oz LeÃ³n	10	16	83	2043
2044	Sandra Rojas Zapata	6	16	27	2044
2045	Alexander GonzÃ¡lez	8	10	99	2045
2046	Luz Liliana Becerra Ayala	4	18	83	2046
2047	Mauricio Valencia	2	10	100	2047
2048	Marcela Arenas Ortiz	12	34	4	2048
2049	Andrea LucÃ­a Valencia MartÃ­nez	7	9	86	2049
2050	Jorge Caicedo	15	45	44	2050
2051	Edwin MartÃ­nez JimÃ©nez	14	31	99	2051
2052	Camila Ariza	6	6	30	2052
2053	JuliÃ¡n DÃ­az SÃ¡nchez	14	41	25	2053
2054	Constanza Ingrid Forero	9	11	36	2054
2055	Ana ChacÃ³n RodrÃ­guez	4	18	80	2055
2056	Pablo MartÃ­nez GarcÃ­a	11	29	34	2056
2057	Eduardo Valencia Solano	9	41	36	2057
2058	Javier HernÃ¡ndez	12	17	2	2058
2059	Cindy Padilla	8	14	72	2059
2060	Angie BenÃ­tez	9	45	29	2060
2061	Armando JesÃºs DÃ­az GarcÃ­a	5	47	81	2061
2062	Alexandra MarÃ­a Cardona Gil	2	50	73	2062
2063	MÃ³nica Ortiz	11	21	87	2063
2064	Pablo JuliÃ¡n Guerrero	12	11	3	2064
2066	AndrÃ©s Contreras Perdomo	13	16	15	2066
2067	FabiÃ¡n IvÃ¡n SuÃ¡rez Guevara	3	47	47	2067
2068	Johana Luz Serna	7	27	28	2068
2069	Margoth Amaya	1	45	57	2069
2070	Natalia Clara RodrÃ­guez FernÃ¡ndez	7	21	94	2070
2071	Gloria Blanca MartÃ­nez Barrios	15	14	3	2071
2072	Edwin CastaÃ±eda Parra	1	30	10	2072
2073	Maritza Granados	1	30	91	2073
2074	RocÃ­o Cardona	9	49	68	2074
2075	Janeth MarÃ­a Giraldo Mosquera	11	40	86	2075
2076	Marco Anaya GarcÃ©s	9	15	40	2076
2077	Carolina Romero Ruiz	11	3	39	2077
2078	Elena Acosta	14	11	1	2078
2079	Antonio JosÃ© Romero	11	8	52	2079
2080	Carlos Luis Agudelo DÃ­az	11	2	3	2080
2081	Martha Rojas	8	49	46	2081
2082	Martha RodrÃ­guez Vargas	9	26	61	2082
2083	Jairo Pedro Zambrano Barrera	9	16	19	2083
2084	Maritza DÃ­az	6	7	63	2084
2085	MarÃ­a DÃ­az	11	34	50	2085
2086	David Ricardo BermÃºdez SuÃ¡rez	11	3	97	2086
2087	Geovanny Ibarra	11	46	60	2087
2088	Sandra Adriana Molina	6	29	28	2088
2089	Mariana GÃ³mez	1	21	59	2089
2090	Bibiana Lucy Estrada Castillo	3	12	38	2090
2091	Luz Sandra Osorio CalderÃ³n	12	18	59	2091
2092	Eduardo Emilio GarcÃ­a	12	32	29	2092
2093	Elisa Acevedo JimÃ©nez	7	19	100	2093
2094	Paola Vanessa Sarmiento Duque	12	12	21	2094
2097	Shirley Adriana RodrÃ­guez	13	24	63	2097
2098	Armando Jorge Polo	10	24	41	2098
2099	Heidy Fajardo	12	46	93	2099
2100	Manuela Edith Camacho Figueroa	10	25	30	2100
2101	Luz Vargas Delgado	10	33	71	2101
2102	Leonor MarÃ­a RodrÃ­guez	9	26	70	2102
2103	LucÃ­a Sandra Caicedo	4	49	54	2103
2104	Cecilia Patricia Meneses Chaparro	3	24	64	2104
2105	Manuel Betancur	11	34	4	2105
2106	Katerine Alejandra Sanabria PinzÃ³n	8	33	46	2106
2107	Luis RamÃ³n Mendoza CortÃ©s	3	50	81	2107
2108	Blanca MarÃ­a Pardo Sierra	9	29	84	2108
2109	Alexis Romero CÃ³rdoba	5	29	90	2109
2110	JosÃ© HernÃ¡n Buitrago DomÃ­nguez	7	40	53	2110
2111	Stella LucÃ­a Jaramillo GÃ³mez	4	2	79	2111
2112	Fernando AndrÃ©s Vanegas MartÃ­nez	7	20	61	2112
2113	RubÃ©n Aguirre	7	7	2	2113
2114	HernÃ¡n RodrÃ­guez Acevedo	3	33	3	2114
2115	Martha Marleny Oviedo Alfonso	4	37	35	2115
2116	MarÃ­a Luisa GÃ³mez Bustamante	2	3	27	2116
2119	Eugenia GarcÃ­a Ospino	14	48	93	2119
2120	Diana Sandoval	15	45	67	2120
2121	Wilmer Trujillo	1	48	97	2121
2122	Manuel Giraldo Galeano	6	8	92	2122
2123	Felipe Giovanny GonzÃ¡lez GutiÃ©rrez	8	27	42	2123
2125	Elena Aguirre Jaramillo	5	20	71	2125
2126	Eliecer Morales Prieto	6	48	60	2126
2127	Carlos Felipe Trujillo	14	1	14	2127
2128	Fernanda Barbosa SÃ¡nchez	7	24	95	2128
2129	RaÃºl Ã“scar Padilla	10	26	81	2129
2130	Camilo LÃ³pez Mendoza	9	12	67	2130
2131	Darwin JosÃ© Romero	2	27	72	2131
2132	JuliÃ¡n Christian MuÃ±oz HernÃ¡ndez	3	19	69	2132
2133	Isabel Caicedo Contreras	4	7	95	2133
2134	Gabriela Angie GuzmÃ¡n Camacho	2	42	11	2134
2136	Juan Mosquera DÃ­az	7	50	17	2136
2137	Maira Ortega Pardo	14	2	67	2137
2138	Joan NÃ©stor Contreras RodrÃ­guez	2	38	69	2138
2139	Jhon SebastiÃ¡n Carmona	4	43	32	2139
2140	Martha Patricia Parra	6	39	27	2140
2141	Alix Ortiz	9	16	19	2141
2142	Vanessa SÃ¡nchez	7	18	23	2142
2143	Alix Osorio	5	22	82	2143
2144	Marina DÃ­az GonzÃ¡lez	4	13	1	2144
2146	Luis HernÃ¡ndez	10	48	16	2146
2147	AnÃ­bal Esteban FlÃ³rez	10	1	99	2147
2148	Antonio Alexander LÃ³pez	3	49	39	2148
2149	Martha MarÃ­a Correa	4	7	25	2149
2150	Jaime MartÃ­nez Aguirre	12	28	12	2150
2151	Enrique GutiÃ©rrez	13	11	91	2151
2152	IvÃ¡n Pablo Torres	1	45	21	2152
2153	Yesid Pablo Mercado PÃ©rez	15	21	19	2153
2154	Sandra DurÃ¡n	5	29	85	2154
2155	Andrea Viviana Bedoya ChacÃ³n	12	23	86	2155
2156	Felipe Marco Anaya Romero	1	44	13	2156
2157	Yeison Robinson Hoyos	10	43	11	2157
2158	Alexander Fernando Sandoval	4	16	26	2158
2160	Ana Arias Pacheco	6	27	45	2160
2161	Carlos Eduardo Gaviria	1	7	69	2161
2162	Alejandra Sanabria	1	16	45	2162
2163	Cecilia Moreno HernÃ¡ndez	1	14	1	2163
2164	Fernando Ã“scar Bonilla GarcÃ­a	15	26	88	2164
2165	Patricia Ruth Lozano Giraldo	2	6	34	2165
2166	Tatiana Galindo	8	48	100	2166
2167	MarÃ­a PeÃ±a GutiÃ©rrez	12	49	70	2167
2168	Walter Rangel MÃ¡rquez	12	14	2	2168
2169	Andrea MarÃ­a MarÃ­n	2	23	57	2169
2170	JesÃºs GonzÃ¡lez Reyes	11	29	63	2170
2171	ElÃ­as Ramiro Osorio	4	41	25	2171
2172	JesÃºs GarzÃ³n Torres	3	39	57	2172
2173	Liliana Sandra Espinosa	8	24	64	2173
2174	Julio Fernando Cruz	1	41	46	2174
2175	Marcela Enith Rosero	12	36	75	2175
2176	AndrÃ©s Moreno DurÃ¡n	8	48	24	2176
2177	Rafael AndrÃ©s Betancur PÃ©rez	11	27	31	2177
2178	Juan Mora CastaÃ±eda	4	38	97	2178
2179	Marlon HernÃ¡ndez	8	8	79	2179
2180	Walter CÃ©sar Contreras LÃ³pez	11	17	80	2180
2181	Alexis David Torres SÃ¡nchez	7	12	95	2181
2182	Diana Valeria Aguirre	15	37	29	2182
2183	Kevin RodrÃ­guez	5	46	95	2183
2184	AndrÃ©s Medina	8	29	100	2184
2185	Arley AndrÃ©s GÃ³mez DomÃ­nguez	5	40	1	2185
2186	Alexander Juan GÃ³mez	7	5	76	2186
2187	Doris Rico Carvajal	15	28	86	2187
2188	Hugo Manuel Romero	10	7	61	2188
2189	MarÃ­a Valencia	6	19	76	2189
2190	Ana Katherine Sierra RodrÃ­guez	8	28	98	2190
2191	Jairo Ortiz	8	48	87	2191
2192	Isabel Lady NarvÃ¡ez GÃ³mez	8	22	73	2192
2193	Mayerly Candelaria RodrÃ­guez	9	27	72	2193
2194	Miriam MarÃ­a Medina	11	35	54	2194
2195	AndrÃ©s JosÃ© SuÃ¡rez PÃ©rez	8	23	92	2195
2196	Yuri GÃ³mez	2	11	64	2196
2197	JosuÃ© Giraldo MartÃ­nez	9	15	42	2197
2198	Cristian Serrano	11	40	11	2198
2199	JosÃ© Gerardo Tovar	13	17	5	2199
2200	FabiÃ¡n FernÃ¡ndez Pinto	14	13	62	2200
2202	David LondoÃ±o	3	37	47	2202
2203	Rafael AndrÃ©s MartÃ­nez Reyes	9	15	36	2203
2204	Esperanza MarÃ­a Parra	3	32	84	2204
2205	Alberto Ã“scar LeÃ³n	15	32	73	2205
2206	Gina Diana Mendoza Carrillo	9	29	85	2206
2207	Emilio Juan Guerrero	14	10	49	2207
2208	Clara MuÃ±oz MartÃ­nez	5	10	79	2208
2209	Andrea Betty CÃ¡rdenas	7	17	8	2209
2210	Jhon Javier Franco	10	6	35	2210
2211	Mario Agudelo GarcÃ­a	13	18	53	2211
2212	Cristina SofÃ­a Silva	11	14	25	2212
2213	Carlos Alexander Estrada Ospino	4	23	30	2213
2214	Carolina Cristina RodrÃ­guez	8	26	6	2214
2215	Esteban MuÃ±oz	14	31	9	2215
2216	MarÃ­a Valencia	3	2	59	2216
2217	Jorge Vargas	10	5	99	2217
2218	Luz Silva	13	9	94	2218
2219	Jorge Ã“scar Torres	5	42	50	2219
2220	JosÃ© Forero	1	6	78	2220
2221	Alirio LondoÃ±o	8	38	22	2221
2222	Rosa Caballero Cruz	11	3	27	2222
2223	Raquel Maira MuÃ±oz	13	32	82	2223
2224	Blanca Maldonado Ocampo	3	33	30	2224
2225	Elena Murillo RodrÃ­guez	9	42	29	2225
2226	Diana MarÃ­a Arias Pacheco	2	33	18	2226
2227	Juan Esteban Pardo Bedoya	9	38	14	2227
2228	Humberto JesÃºs GarzÃ³n	8	1	42	2228
2229	Camilo Fernando Meza	9	43	36	2229
2230	Julieth Karen Restrepo SÃ¡nchez	12	42	94	2230
2231	Ramiro Humberto Herrera Caicedo	2	41	46	2231
2233	Fernanda Yolanda DÃ­az	1	14	18	2233
2234	Daniel Luis Carrillo Ballesteros	5	4	97	2234
2235	Felipe Moreno JimÃ©nez	4	15	14	2235
2236	Maicol Torres	11	11	8	2236
2237	Andrea PeÃ±a	12	28	64	2237
2238	Carlos HernÃ¡ndez Ortiz	3	32	43	2238
2240	Miguel Lozano	5	3	5	2240
2241	Marino Juan Cifuentes	7	32	32	2241
2242	Rodolfo GÃ³mez	8	19	28	2242
2243	Ester Mary Villegas Leal	8	43	4	2243
2244	Wilson RamÃ­rez MejÃ­a	2	41	2	2244
2245	Ruth Arteaga Ceballos	6	47	24	2245
2246	Lina Giraldo	2	25	100	2246
2247	Stiven Ã“scar Carvajal Caballero	7	18	86	2247
2248	MarÃ­a Luz Ramos	11	38	16	2248
2249	Antonio Yecid Castro Murcia	9	23	64	2249
2250	Ana Luz LÃ³pez	13	7	59	2250
2251	Isabel Yenny Castillo Guerrero	11	1	39	2251
2253	Sandra LÃ³pez	7	46	59	2253
2254	Andrea LÃ³pez Rivera	14	6	70	2254
2255	Alfredo Arrieta	1	49	70	2255
2256	Alexis GarcÃ©s Pulido	4	38	46	2256
2257	Mayra LucÃ­a Palacio	3	22	35	2257
2258	Gabriel Villamizar	1	31	27	2258
2259	Hernando Betancur	9	41	37	2259
2260	Laura Luz Erazo CÃ³rdoba	10	18	76	2260
2261	MarÃ­a ChacÃ³n PeÃ±a	1	4	36	2261
2262	Patricia GutiÃ©rrez	11	50	22	2262
2263	Milena HernÃ¡ndez	6	17	13	2263
2264	MarÃ­a Yohana SepÃºlveda Torres	1	48	60	2264
2265	Eliecer CastaÃ±eda Castillo	9	13	56	2265
2266	Adriana Torres Mendoza	5	5	3	2266
2267	Edwin Camilo Ariza	10	7	75	2267
2268	Jhon Gabriel FernÃ¡ndez	7	27	55	2268
2269	Sandra Lida Acevedo Benavides	3	47	36	2269
2270	Ana SÃ¡nchez	15	35	85	2270
2271	Sandra MarÃ­a Lozano Orozco	10	8	61	2271
2272	Gina Solano	6	22	15	2272
2273	Luis Javier Montenegro	3	38	40	2273
2274	Milena Paola Arias Mendoza	11	31	60	2274
2275	Isabel Leonor Tovar Soto	2	22	94	2275
2276	Libardo Augusto Rosero	4	19	16	2276
2278	Luis Bernardo Barreto Orozco	1	41	90	2278
2282	Johana Melba Duque Ospino	13	1	76	2282
2283	MarÃ­a Melissa Sierra	6	3	46	2283
2284	Manuel Bustos Ruiz	14	41	84	2284
2286	SofÃ­a Isabel Sanabria	14	39	38	2286
2287	Roberto Duque RodrÃ­guez	9	10	45	2287
2288	Ana GÃ³mez Chaparro	15	1	70	2288
2289	Olga Luz Palacios	4	39	100	2289
2290	Eugenia DÃ­az Rojas	9	5	93	2290
2291	NicolÃ¡s Eduardo Roa Trujillo	5	25	31	2291
2292	Daniel Arboleda	2	10	37	2292
2293	Luz Marly MartÃ­nez	10	17	13	2293
2294	Segundo Alberto Gil GÃ³mez	4	25	43	2294
2295	Carlos Pedraza FlÃ³rez	3	2	63	2295
2296	Mario Jhon Parra	10	23	18	2296
2297	Gloria MarÃ­a HernÃ¡ndez PÃ©rez	12	13	56	2297
2299	InÃ©s VÃ©lez Ortiz	9	29	80	2299
2300	MarÃ­a MartÃ­nez	2	30	90	2300
2301	Claudia Janeth Valencia	5	35	33	2301
2302	Virginia Mora	3	28	48	2302
2303	Libia Nancy Sierra Monroy	1	20	81	2303
2304	LucÃ­a Sarmiento Guerrero	1	33	37	2304
2305	Alfonso Orozco GonzÃ¡lez	8	14	72	2305
2306	Daniela Deisy Silva DÃ­az	7	23	35	2306
2307	Elizabeth Consuelo MarÃ­n GonzÃ¡lez	7	47	21	2307
2308	Erika Luz LondoÃ±o Bustamante	5	38	1	2308
2309	Dario AndrÃ©s Zapata	4	29	5	2309
2310	RaÃºl JesÃºs GarcÃ©s Hoyos	6	41	88	2310
2311	Patricia Martha GonzÃ¡lez Hoyos	4	4	8	2311
2312	Juan Wilson Angulo Ortiz	1	1	72	2312
2313	Jorge Dario Mendoza	14	22	57	2313
2314	Carlos William Zapata	12	28	55	2314
2315	Juan HernÃ¡ndez	8	25	73	2315
2316	Carlos Arias	13	12	7	2316
2317	Jhon Javier CastaÃ±o	12	29	73	2317
2319	Marcela Carol MartÃ­nez	14	32	11	2319
2320	Humberto RodrÃ­guez Ojeda	12	8	63	2320
2321	Alexander GonzÃ¡lez Montoya	12	38	90	2321
2322	Antonio Javier GuzmÃ¡n SepÃºlveda	5	41	55	2322
2323	MarÃ­a LucÃ­a Acosta	15	32	2	2323
2324	JesÃºs JesÃºs Meza Quiroga	15	35	87	2324
2325	Mayerly Juliana RodrÃ­guez Romero	7	35	3	2325
2326	SebastiÃ¡n GarcÃ­a MÃ©ndez	10	29	33	2326
2327	Andrea Sandra Mosquera	15	36	31	2327
2328	Andrea Yulieth SuÃ¡rez DÃ­az	7	22	37	2328
2329	Elena Acevedo	8	15	9	2329
2330	Jhon Mario LÃ³pez	12	37	45	2330
2332	Jairo JosÃ© Guerrero	15	16	81	2332
2333	Alberto SÃ¡nchez	9	2	67	2333
2334	RaÃºl VÃ­ctor Mora Camargo	11	50	60	2334
2335	Wilfredo DÃ­az	1	43	91	2335
2336	William Jaime MartÃ­nez	1	42	16	2336
2337	Alba Isabel Mora GuzmÃ¡n	14	28	85	2337
2339	Camila ArÃ©valo Cruz	1	17	93	2339
2340	Lina Andrea FlÃ³rez	10	2	41	2340
2341	Nohora Marcela GuzmÃ¡n Rosero	5	1	21	2341
2342	Alexander Mosquera MejÃ­a	14	3	15	2342
2343	Mercedes Restrepo	4	36	94	2343
2344	Yaneth Morales	1	42	71	2344
2345	YasmÃ­n Rita LÃ³pez	8	48	65	2345
2346	Edgardo David JimÃ©nez Palacios	2	4	33	2346
2348	Fernanda Quintero	9	3	23	2348
2349	Rafael Santiago LondoÃ±o GutiÃ©rrez	15	37	73	2349
2350	Fernando David Rangel	5	31	36	2350
2351	Milena Diana VelÃ¡squez	4	21	28	2351
2352	Ferney Diego SÃ¡nchez Buitrago	11	22	40	2352
2353	Dayana Zambrano Vargas	1	38	64	2353
2354	Sandra RamÃ­rez RodrÃ­guez	13	41	60	2354
2355	Leidy Correa	12	39	29	2355
2356	Daniela Paola HernÃ¡ndez	2	10	44	2356
2357	Johana MarÃ­a GarcÃ­a Guerrero	14	35	25	2357
2358	Estiven EfrÃ©n GonzÃ¡lez	1	20	81	2358
2359	Sara Castellanos Duarte	10	5	91	2359
2360	Cecilia InÃ©s Delgado Torres	11	12	82	2360
2361	SebastiÃ¡n Javier Morales	15	43	74	2361
2362	Carlos Mora	13	42	5	2362
2363	Daniel Luis Palacios	7	11	19	2363
2364	Alejandro SuÃ¡rez Rivera	9	19	11	2364
2365	Olga Liliana Tamayo	11	6	27	2365
2366	AdriÃ¡n GonzÃ¡lez	12	50	66	2366
2367	Paola Tatiana Quintero	10	36	90	2367
2368	Leonardo Perea	9	1	1	2368
2369	Oswaldo ArÃ©valo RamÃ­rez	8	25	74	2369
2370	Yadira Patricia Moreno Perea	10	41	54	2370
2371	Ferney Ramos SÃ¡nchez	4	21	2	2371
2373	Fernanda Alejandra LondoÃ±o Parra	5	47	38	2373
2374	Milena Triana Salazar	9	16	74	2374
2375	Heidy Patricia Morales	2	28	31	2375
2376	Julio Castillo	6	10	23	2376
2377	Edwin JosÃ© Mantilla Mendoza	4	8	12	2377
2378	Janeth Myriam Duque	4	14	5	2378
2379	Adriana Luz LÃ³pez Sandoval	3	24	37	2379
2380	Alexis Juan DurÃ¡n DÃ­az	13	33	65	2380
2381	Fredy ChÃ¡vez SÃ¡nchez	8	1	59	2381
2382	Ramiro JosÃ© SÃ¡nchez	9	25	42	2382
2383	MarÃ­a LondoÃ±o	13	21	86	2383
2385	Margarita Palacios	9	2	22	2385
2386	Mercedes Ruiz Benavides	15	39	46	2386
2387	Carlos Ospina Espinosa	2	27	13	2387
2388	Carlos VÃ­ctor Ruiz Barrios	7	48	34	2388
2389	Daniela MarÃ­a Agudelo	3	47	76	2389
2390	Patricia LÃ³pez	2	28	51	2390
2391	Sandra Prieto	14	42	66	2391
2392	Camilo Pardo JimÃ©nez	15	22	19	2392
2393	Jorge Torres GutiÃ©rrez	14	40	82	2393
2394	MarÃ­a Acosta VelÃ¡squez	9	38	59	2394
2396	Elena Reyes	5	39	79	2396
2397	Cristina MarÃ­a Guevara	10	21	69	2397
2398	Wilfredo Vergara	1	24	14	2398
2399	Ruth Carolina VelÃ¡squez Mena	6	37	11	2399
2400	Angie CÃ¡rdenas	7	35	73	2400
2401	Pedro Bedoya MuÃ±oz	11	36	74	2401
2402	Gloria Fabiola Contreras Ortiz	14	15	2	2402
2403	JesÃºs Carlos Cifuentes	4	24	58	2403
2404	Carlos Edgar Ospina Valencia	3	20	90	2404
2405	Omar Castro LÃ³pez	7	30	95	2405
2406	Luis Alejandro Parada GarcÃ­a	8	5	94	2406
2407	Hugo IvÃ¡n Ortiz Franco	15	30	50	2407
2408	AndrÃ©s Salazar	3	10	23	2408
2409	Rafael MarÃ­n LÃ³pez	11	41	82	2409
2410	Camilo Antonio GonzÃ¡lez	2	32	3	2410
2411	Alexander SuÃ¡rez NarvÃ¡ez	3	46	51	2411
2412	Juan Guerrero	15	37	99	2412
2413	Marta Rosa Figueroa	6	32	1	2413
2414	Jorge Wilson Tovar	15	24	42	2414
2415	Alexandra Barrera Silva	13	27	96	2415
2416	Julia Andrea Parra Castro	11	30	30	2416
2417	Marta Elvia Morales Rojas	10	28	97	2417
2418	Carlos JosÃ© DÃ­az Medina	13	1	75	2418
2419	Jorge Ojeda	6	31	15	2419
2420	Santos Diego Romero Morales	13	31	49	2420
2421	Mayra Monsalve	6	23	81	2421
2422	Fernando Reyes Pacheco	8	46	59	2422
2423	LeÃ³n DÃ­az	13	49	74	2423
2424	Andrea Espitia Villegas	10	43	93	2424
2425	Ovidio Ruiz	4	30	74	2425
2426	Eduardo CastaÃ±eda Castellanos	12	43	36	2426
2427	Myriam LÃ³pez Torres	8	1	58	2427
2429	IvÃ¡n Ruiz	14	10	34	2429
2430	Alirio Velandia GarcÃ­a	11	2	11	2430
2431	Juan MartÃ­nez	4	38	68	2431
2432	Alberto GÃ³mez	9	11	91	2432
2433	Darwin Jefferson Monsalve	1	2	14	2433
2434	Alejandro Jorge Jaramillo	10	43	48	2434
2435	Felipe Alberto Cuesta	1	30	78	2435
2436	HÃ©ctor SebastiÃ¡n Pacheco	3	25	2	2436
2437	Lorena Castro	4	22	15	2437
2438	Ever CastaÃ±o Duque	2	25	68	2438
2439	Laura Rojas	4	1	44	2439
2440	Manuel GarcÃ­a	2	21	45	2440
2441	Luz Lorena Bautista	7	24	37	2441
2442	Armando VÃ­ctor Fonseca DÃ­az	15	28	91	2442
2444	AndrÃ©s Fernando MuÃ±oz	6	3	61	2444
2445	Elena Alba MartÃ­nez Silva	11	30	51	2445
2446	Jorge Murillo HernÃ¡ndez	4	17	18	2446
2447	Diana Astrid MÃ¡rquez GonzÃ¡lez	1	34	95	2447
2448	Andrea GÃ³mez Medina	5	11	38	2448
2449	Eugenia Karol Arenas Ariza	5	47	86	2449
2450	Esperanza Salazar CalderÃ³n	8	19	34	2450
2451	Nelson Camilo Mosquera Carvajal	15	24	19	2451
2452	Marina Herrera	1	7	60	2452
2453	NicolÃ¡s LÃ³pez Escobar	4	33	6	2453
2454	Rafael JosÃ© MartÃ­nez PÃ©rez	2	34	87	2454
2455	Claudia Maribel Angarita	5	39	64	2455
2456	AndrÃ©s FlÃ³rez Lozano	8	4	32	2456
2457	IvÃ¡n Ardila	1	11	56	2457
2458	Antonio Villamil Osorio	7	35	96	2458
2459	Erick Ricardo Palacios	15	28	21	2459
2461	Patricia Martha Triana RodrÃ­guez	1	39	52	2461
2462	Lady Daniela Camacho GarcÃ­a	2	8	45	2462
2463	YÃ©ssica RamÃ­rez	14	19	60	2463
2464	Juan SÃ¡nchez Lara	3	14	71	2464
2465	Isabel Camargo	8	50	91	2465
2467	David Granados Bustos	5	1	55	2467
2468	Emilio Miguel Arias SuÃ¡rez	6	19	49	2468
2469	Antonio Correa Ceballos	9	38	9	2469
2470	Luisa Mery Duque Melo	4	36	80	2470
2471	DamiÃ¡n Marino Vargas	15	15	28	2471
2472	Claudia Sandra Ruiz MartÃ­nez	2	32	80	2472
2473	Eduardo Ramos	8	36	5	2473
2474	Francisco Molano RincÃ³n	9	10	100	2474
2475	Ã“scar Miguel LÃ³pez	10	42	12	2475
2476	Roberto Miguel Manrique	10	8	30	2476
2477	Leydi Valentina Barrios PÃ©rez	1	48	76	2477
2478	Yaneth Andrea Zambrano Herrera	5	48	25	2478
2479	Edwin Julio MartÃ­nez	14	44	17	2479
2480	Paola Ramos Camargo	7	39	17	2480
2481	AndrÃ©s GÃ³mez	13	40	93	2481
2482	Carlos Cristian Rivera	15	44	61	2482
2483	Jaime Meza GÃ³mez	11	10	55	2483
2484	JuliÃ¡n Hoyos Villamizar	14	10	40	2484
2485	Ibeth Salazar Toro	8	22	52	2485
2486	Nataly Liliana Silva MarÃ­n	3	35	77	2486
2487	Javier RincÃ³n	9	40	35	2487
2488	Liliana MarÃ­a Romero	9	16	77	2488
2489	Vilma Espitia DÃ­az	4	28	47	2489
2490	Vanessa Beatriz MartÃ­nez Daza	15	17	17	2490
2491	Eduard Arenas DÃ­az	12	10	40	2491
2492	JesÃºs Arias Mora	4	17	7	2492
2493	Camilo Fuentes	1	8	34	2493
2494	Luz Daniela Moreno Pineda	7	46	63	2494
2495	Alejandro ChacÃ³n	10	19	85	2495
2496	Camilo Hugo Moreno Salamanca	11	45	100	2496
2497	Luis MÃ¡rquez	10	26	41	2497
2498	Alfonso Wilmar CastaÃ±o	13	31	53	2498
2499	Carlos NÃ©stor Valencia	5	2	79	2499
2500	TomÃ¡s Cristian Murillo MuÃ±oz	2	45	98	2500
2501	NicolÃ¡s Murillo Quiroga	9	41	61	2501
2502	Patricia Helena MuÃ±oz Morales	13	28	31	2502
2503	MartÃ­n Cardona HernÃ¡ndez	2	28	11	2503
2504	Elizabeth Andrea Ibarra	4	31	79	2504
2505	Graciela Jessica Lozano	1	24	81	2505
2506	DuvÃ¡n RamÃ­rez	10	38	81	2506
2507	Alejandra Ana Rosero	7	22	12	2507
2508	Gloria Eliana Carvajal SuÃ¡rez	12	10	44	2508
2509	VÃ­ctor Emilio Burbano	8	30	79	2509
2510	Dany IvÃ¡n Medina Estrada	13	39	69	2510
2511	Enrique Pedraza	15	22	24	2511
2512	Juliana SuÃ¡rez VelÃ¡squez	6	7	99	2512
2513	Marcela Margoth Ospina	7	17	23	2513
2514	Alirio Lozano	1	8	15	2514
2515	Laura GutiÃ©rrez GuzmÃ¡n	3	40	5	2515
2516	CÃ©sar RodrÃ­guez	13	14	69	2516
2517	Esther Julieth Cruz	10	38	28	2517
2518	Uriel Fernando Romero GarcÃ­a	8	10	18	2518
2519	Paola Quiroga Barrera	15	26	82	2519
2520	Guillermo Carlos Arrieta	15	49	48	2520
2521	Silvia Lorena RincÃ³n Miranda	4	17	45	2521
2522	CÃ©sar Pulido	3	9	10	2522
2523	Fernanda Isabel Rivera	3	22	68	2523
2524	Sandra MartÃ­nez Barrera	3	40	8	2524
2525	Luis Giovanny ArÃ©valo Toro	14	41	5	2525
2526	Marina Carmona Rojas	6	46	46	2526
2527	Zoraida Mariana Arango	11	6	96	2527
2529	JosÃ© Wilfrido Reyes CÃ¡rdenas	6	34	76	2529
2531	Diana Patricia Navarro	1	41	74	2531
2532	Angie Claudia Amaya Carrillo	12	23	5	2532
2533	LucÃ­a LÃ³pez Bautista	10	13	58	2533
2534	Stiven Eduardo Pinto	8	37	61	2534
2535	Santos Enrique Bedoya	11	32	91	2535
2536	Juan DÃ­az Vargas	7	7	99	2536
2537	CÃ©sar Manuel Restrepo	2	2	61	2537
2538	Luis Guerrero	7	5	63	2538
2539	Octavio Fidel Mena	6	30	31	2539
2540	Camilo GarcÃ­a	1	7	31	2540
2541	Constanza GutiÃ©rrez Arango	1	42	71	2541
2542	Jorge PabÃ³n PÃ©rez	12	14	82	2542
2543	Edilson RodrÃ­guez	4	41	31	2543
2544	Irma MarÃ­a RodrÃ­guez	7	49	77	2544
2545	Elkin Omar Ortiz LÃ³pez	3	49	73	2545
2546	Karina Gilma Rivera	13	21	34	2546
2547	ElÃ­as JosÃ© BarragÃ¡n Galindo	7	25	74	2547
2548	AndrÃ©s Trujillo Molina	7	13	40	2548
2549	Janeth Sandra Carvajal	4	35	7	2549
2550	Katherine Amparo CastrillÃ³n	8	24	37	2550
2551	MarÃ­a Ibeth Mantilla Vergara	12	49	77	2551
2553	Leidy Paola Andrade Pineda	3	4	23	2553
2554	Jorge Ojeda Pacheco	6	24	7	2554
2555	Emma Osorio DÃ­az	12	48	17	2555
2556	Yurany Yuliana ArÃ©valo Sierra	15	4	97	2556
2557	Juan Ortega Mosquera	1	31	54	2557
2558	Dolores Hurtado	13	49	22	2558
2559	Liliana Marina Ortega Rivera	2	15	76	2559
2560	Jorge Julio Ortiz	10	24	66	2560
2561	Lorena RocÃ­o Delgado GonzÃ¡les	5	41	22	2561
2562	Nohora Luz Arango JimÃ©nez	15	40	90	2562
2563	MarÃ­a Sandra Galindo	8	13	6	2563
2564	Astrid Luz LondoÃ±o	10	25	86	2564
2567	JesÃºs PeÃ±a Rojas	11	35	52	2567
2569	Alberto Juan Silva SuÃ¡rez	12	48	6	2569
2570	Ingrid CÃ³rdoba	1	21	94	2570
2571	Manuel David SÃ¡nchez	4	47	75	2571
2573	Marina GonzÃ¡lez	15	1	42	2573
2574	Viviana Sonia Estrada DÃ­az	2	45	60	2574
2575	MarÃ­a NÃºÃ±ez RodrÃ­guez	4	35	16	2575
2576	Jessica Aguilar	2	27	7	2576
2577	RocÃ­o Matilde Vargas	2	44	64	2577
2578	JosÃ© Jhon Portilla Torres	1	49	27	2578
2579	Herney David Mendoza	14	36	3	2579
2580	Pablo CÃ©sar Meneses	12	26	86	2580
2581	Diego Enrique Santos RodrÃ­guez	11	43	85	2581
2582	Luisa Marcela CÃ¡rdenas	9	12	63	2582
2583	Luis GarcÃ­a Reyes	14	47	21	2583
2584	Miguel Caicedo Rosero	7	46	48	2584
2585	JosÃ© JosÃ© Montoya	13	17	47	2585
2586	Eduardo Cruz HernÃ¡ndez	1	44	23	2586
2587	Alfredo Lozano	14	50	58	2587
2588	MarÃ­a Salazar MuÃ±oz	3	8	8	2588
2589	MarÃ­a Cardozo	11	6	19	2589
2590	Alberto Leonel RamÃ­rez Gil	10	34	30	2590
2591	Cecilia Doris Vega	6	30	64	2591
2592	Juan Luis Meneses	9	22	91	2592
2593	Jorge Benavides Montoya	13	3	98	2593
2594	Marcela MarÃ­a PeÃ±a Rueda	6	24	69	2594
2595	Paola Eugenia Tamayo	5	40	46	2595
2596	Amparo Sara CastaÃ±eda	8	34	86	2596
2597	Augusto Ricardo PinzÃ³n PeÃ±a	1	34	73	2597
2598	Elena Mayra Arango GutiÃ©rrez	3	47	24	2598
2599	Sergio Javier Perdomo Ballesteros	1	28	34	2599
2600	Johana VelÃ¡squez FernÃ¡ndez	9	49	3	2600
2601	Abel SepÃºlveda	8	14	77	2601
2602	Yeison Robert GÃ³mez	12	6	88	2602
2603	MarÃ­a Judith GarcÃ­a GonzÃ¡lez	14	9	92	2603
2604	LucÃ­a LÃ³pez	8	12	5	2604
2605	Javier Navarro GaitÃ¡n	14	47	53	2605
2606	Julio Jhon Rojas	1	29	42	2606
2607	Javier Arias Amaya	8	42	41	2607
2608	Juan RodrÃ­guez	8	44	35	2608
2609	Silvio Cristian Montoya Soto	13	2	73	2609
2610	Esperanza Herrera Rivas	13	46	14	2610
2611	Luz MarÃ­a NÃºÃ±ez	5	1	97	2611
2612	Mariela Ingrid CortÃ©s Galvis	13	16	9	2612
2613	JuliÃ¡n SÃ¡nchez	13	48	22	2613
2614	Vanessa SofÃ­a GuzmÃ¡n Guerrero	10	46	24	2614
2615	Liliana LondoÃ±o	7	13	52	2615
2616	Felipe Bravo	4	18	55	2616
2617	MarÃ­a Aguirre	6	30	80	2617
2618	Maicol GarcÃ­a	4	27	30	2618
2619	JosÃ© Antonio Serna	2	49	60	2619
2620	Isabel GarcÃ­a	3	7	61	2620
2621	Carlos Juan Duarte	14	46	80	2621
2622	Kevin Hoyos Parra	12	41	59	2622
2623	JosÃ© Alfredo Franco RodrÃ­guez	1	15	71	2623
2624	AndrÃ©s Mauricio Aguilar	12	45	8	2624
2625	Constanza Patricia RÃ­os	10	27	40	2625
2626	Marcela RodrÃ­guez Lara	12	7	60	2626
2627	Carlos RamÃ­rez MarÃ­n	11	18	100	2627
2628	Alex Jaime Castellanos	12	36	26	2628
2629	Lucy Yamile Franco PatiÃ±o	12	38	34	2629
2630	Cristhian Eduardo VelÃ¡squez GonzÃ¡lez	8	43	6	2630
2631	Ronald LÃ³pez	13	20	44	2631
2632	Eduardo Camilo Lozano	2	48	33	2632
2633	Judith FernÃ¡ndez Mosquera	3	17	27	2633
2634	Dario Montoya	14	50	58	2634
2635	JosÃ© Alexander Galvis MarÃ­n	10	42	73	2635
2636	AndrÃ©s LondoÃ±o	10	44	81	2636
2637	Fabiola Laura Moreno	8	9	3	2637
2638	Jhon Sergio CuÃ©llar	8	42	6	2638
2639	Luz Rosa MuÃ±oz CÃ¡ceres	7	28	41	2639
2640	Elisa Flor Ibarra	13	6	13	2640
2641	Ana Molina DÃ­az	9	27	32	2641
2642	Laura Henao	15	22	41	2642
2643	Angie Pacheco	1	36	75	2643
2644	Alfredo Dario MuÃ±oz	3	24	64	2644
2645	Claudia Salazar GÃ³mez	11	37	61	2645
2646	Hernando Ortiz	12	25	69	2646
2647	Katerine Mora GutiÃ©rrez	5	40	27	2647
2648	Adolfo Luis Velasco Guerrero	3	36	18	2648
2650	Guillermo Gil Montoya	4	22	62	2650
2651	Edison Fernando Quiroga PeÃ±a	8	15	56	2651
2652	Leidy RamÃ­rez	14	47	67	2652
2653	Jorge Castro	4	17	55	2653
2654	Alejandro JosÃ© Portilla	5	32	14	2654
2655	Freddy GÃ³mez GÃ³mez	15	1	69	2655
2656	Juan Carlos GarcÃ­a Morales	9	3	87	2656
2657	David Contreras	8	14	84	2657
2658	Paola Arroyo	9	39	68	2658
2659	FabiÃ¡n Pedro Yepes	9	33	93	2659
2660	Patricia Andrea Pacheco	6	26	64	2660
2661	MarÃ­a VerÃ³nica Padilla SÃ¡nchez	14	14	12	2661
2662	Marina Ivonne Rueda PÃ©rez	7	13	86	2662
2663	Elmer Juan Castillo ChÃ¡vez	12	17	56	2663
2664	AndrÃ©s Gustavo Rojas Moreno	12	6	63	2664
2665	JosÃ© GarcÃ­a	3	13	45	2665
2666	Milena Bertha Polo	6	3	43	2666
2667	Nilson JosÃ© DÃ­az Bautista	9	5	25	2667
2668	Alejandro Daniel Lozano Campo	5	38	15	2668
2669	Lilia Moreno Velasco	14	2	72	2669
2670	Luz MarÃ­a Alvarado Benavides	13	42	69	2670
2671	Julieth VÃ¡squez GarcÃ­a	13	43	18	2671
2672	AndrÃ©s GarcÃ­a JimÃ©nez	12	50	90	2672
2673	Fabio Alfredo MarÃ­n	13	33	93	2673
2674	Humberto PÃ©rez	15	23	46	2674
2675	Sneider Valencia	13	48	88	2675
2676	David Yair Santos LÃ³pez	12	16	38	2676
2677	RocÃ­o Eliana Meneses	8	7	32	2677
2678	Alejandro AndrÃ©s Mena LÃ³pez	3	18	39	2678
2679	Osvaldo Acosta	1	30	44	2679
2680	Martha Orjuela	15	5	2	2680
2681	JesÃºs Stiven Carrillo	3	39	2	2681
2682	Sandra Claudia MarÃ­n Franco	14	12	14	2682
2683	Miriam Jacqueline GarcÃ­a Barrera	2	11	26	2683
2684	Cristhian Daza	14	31	60	2684
2686	Mireya Vargas	9	1	86	2686
2687	MarÃ­a Erika Cifuentes GonzÃ¡lez	15	27	8	2687
2688	David Roa Ortega	13	9	4	2688
2689	Jenny Angulo	2	43	2	2689
2690	Magdalena Barrios HernÃ¡ndez	14	28	35	2690
2691	Carmen Ruiz	9	8	94	2691
2692	CÃ©sar ChÃ¡vez	8	4	86	2692
2693	Sandra Martha Ruiz	10	4	42	2693
2694	Oswaldo Estrada	1	50	46	2694
2695	YÃ©ssica Arenas Pinto	6	50	34	2695
2696	MarÃ­a Moreno	1	21	46	2696
2697	Elcy Karen Yepes Pardo	5	6	58	2697
2698	Claudia Ana GarcÃ­a Vera	6	46	66	2698
2699	Rubiela Mendoza	15	47	40	2699
2700	Paola Carolina Valencia	6	18	88	2700
2701	Israel FabiÃ¡n Santos Meneses	8	48	57	2701
2702	AndrÃ©s GutiÃ©rrez Caballero	5	45	99	2702
2703	Jorge Perdomo	8	50	62	2703
2705	Gildardo Chaparro GonzÃ¡lez	6	48	17	2705
2706	David Felipe Carrillo	14	5	79	2706
2707	Dayana NarvÃ¡ez RÃ­os	9	39	54	2707
2708	Esperanza GarzÃ³n	4	1	78	2708
2709	Gladys Camargo	14	46	52	2709
2710	Rosa Lucy Estrada Medina	9	10	5	2710
2711	Alicia Aguirre	12	32	73	2711
2712	Leidy MarÃ­a NarvÃ¡ez	10	23	79	2712
2713	Cecilia Duarte Sarmiento	11	16	15	2713
2714	LeÃ³n Salazar Lozano	9	45	90	2714
2715	Omar Juan Galeano	14	19	65	2715
2716	Adolfo Arias Vallejo	3	36	21	2716
2717	MarÃ­a GutiÃ©rrez	1	5	70	2717
2718	Elena Cardona Carrillo	3	44	24	2718
2719	Marcela Romero Mora	1	32	68	2719
2720	Alexis Mosquera Perdomo	9	44	70	2720
2721	Marcela Ortiz MartÃ­nez	6	7	11	2721
2722	Alberto Acosta Benavides	9	33	83	2722
2723	MarÃ­a Diana LÃ³pez Parra	3	4	51	2723
2724	Eduardo Daniel VÃ¡squez Quintero	5	23	63	2724
2725	JosÃ© Moreno	10	33	53	2725
2726	Eugenia Sandra Salas	14	19	74	2726
2727	Santiago GÃ³mez RodrÃ­guez	13	2	5	2727
2728	Antonio JosÃ© Forero PÃ©rez	9	32	32	2728
2729	JosÃ© CÃ©sar GÃ³mez	12	25	76	2729
2731	Javier Acevedo GonzÃ¡lez	14	44	82	2731
2732	Juan Humberto RamÃ­rez CortÃ©s	9	8	86	2732
2733	Blanca Sandra Silva MuÃ±oz	10	36	24	2733
2734	Manuel MuÃ±oz BohÃ³rquez	15	1	98	2734
2735	Lilia Yaneth Gallego	7	41	85	2735
2736	Lucy Ana Acevedo	4	17	78	2736
2737	Luisa Juana Barrera	4	18	74	2737
2738	Alexander Quintero	14	47	7	2738
2739	JosÃ© Castro	12	28	66	2739
2740	JosÃ© SuÃ¡rez Acevedo	1	50	62	2740
2741	RocÃ­o Salazar	5	13	42	2741
2742	Andrea Herrera	14	9	98	2742
2743	RenÃ© Luis Fuentes Carrillo	15	31	36	2743
2746	AndrÃ©s Burgos BermÃºdez	5	44	33	2746
2747	Ana Mercado Silva	8	29	83	2747
2748	Enrique Luis Medina RodrÃ­guez	5	35	18	2748
2749	Valentina HernÃ¡ndez	12	35	2	2749
2750	RubÃ©n Nelson Mendoza Arroyo	1	11	76	2750
2751	Luis RodrÃ­guez	14	38	86	2751
2752	Cecilia Mosquera Romero	2	41	82	2752
2753	Milena Obando Valencia	2	27	57	2753
2754	Gloria RodrÃ­guez Prada	12	3	97	2754
2755	Claudia Miriam Cruz Silva	3	42	16	2755
2756	MarÃ­a Patricia Rosero	9	8	11	2756
2757	CÃ©sar Eduardo DÃ­az	12	39	38	2757
2758	Guillermo MartÃ­nez	1	33	80	2758
2759	AngÃ©lica Mora Mendoza	15	22	70	2759
2760	Carlos Solano	7	1	73	2760
2761	Fernanda Romero MejÃ­a	8	30	4	2761
2762	Nelson RincÃ³n	13	17	23	2762
2763	Felipe Henry Salazar	5	19	77	2763
2764	Jorge IvÃ¡n Rubio RincÃ³n	14	9	4	2764
2765	Omaira Arrieta Zapata	14	33	35	2765
2766	Eduard Fernando Guerra	1	42	41	2766
2767	MarÃ­a SÃ¡nchez	12	41	80	2767
2768	Jair Leonel Fuentes GutiÃ©rrez	4	10	19	2768
2769	Johan Leonel Arrieta Rivera	15	40	68	2769
2770	Rafael JesÃºs Cuesta Polo	13	48	92	2770
2771	Yaneth Judith GÃ³mez	12	1	2	2771
2772	YÃ©sica Amelia Rojas GutiÃ©rrez	9	28	53	2772
2773	Catherine Carmona CortÃ©s	6	12	78	2773
2774	AndrÃ©s Misael Quintero	15	42	2	2774
2775	Xiomara YazmÃ­n Ayala Castro	6	42	29	2775
2776	Claudia Arias	9	19	13	2776
2777	MarÃ­a Cindy VÃ¡squez FlÃ³rez	10	29	66	2777
2779	Libardo Alirio Corredor GÃ³mez	5	48	7	2779
2780	Harvey NicolÃ¡s BeltrÃ¡n Arroyo	3	6	71	2780
2781	Nubia Vilma Parra Moreno	14	33	33	2781
2782	Karen Rosario Moreno	10	10	49	2782
2783	Marina Luz Navarro RodrÃ­guez	8	10	60	2783
2784	Jaime Esteban Camacho	2	10	58	2784
2785	Estela MartÃ­nez	6	7	73	2785
2786	Jorge Guevara	15	25	42	2786
2787	Paola Hurtado Torres	10	12	64	2787
2788	Alexandra Ruiz	11	14	96	2788
2789	Jaime Velasco Vargas	2	42	39	2789
2790	Mary Consuelo Franco Reyes	5	12	68	2790
2791	Elena Lara Vera	11	6	32	2791
2793	MarÃ­a FernÃ¡ndez Moreno	4	34	65	2793
2794	Susana MarÃ­n	3	12	95	2794
2795	Camila Luisa MÃ©ndez	2	8	56	2795
2796	Diana MarÃ­a RodrÃ­guez Toro	13	10	8	2796
2797	Jhonatan Angarita	11	18	34	2797
2798	Libia FernÃ¡ndez Morales	3	17	90	2798
2799	ElÃ­as AlarcÃ³n	9	5	72	2799
2801	Gerson AndrÃ©s Ortiz	1	1	16	2801
2802	Pablo Eduardo CastaÃ±eda Acosta	10	46	53	2802
2803	MarÃ­a Ayala Valencia	11	33	85	2803
2804	Ana GuzmÃ¡n	12	12	47	2804
2805	Laura Lina Pineda	13	33	86	2805
2806	Ronal Luis Monsalve Serna	2	27	62	2806
2807	GermÃ¡n Duarte	1	25	98	2807
2808	Johanna Mendoza GarcÃ­a	8	47	39	2808
2809	Edwar Eduardo SÃ¡nchez HernÃ¡ndez	10	4	17	2809
2810	YÃ©ssica Vergara	15	6	84	2810
2811	Dayana Ana Aguilar DÃ­az	4	24	33	2811
2812	Alonso Guerrero HernÃ¡ndez	11	27	82	2812
2814	Yaneth Forero	13	38	65	2814
2815	David TomÃ¡s RodrÃ­guez	8	3	78	2815
2816	Manuel GarcÃ­a	5	11	93	2816
2817	Augusto AndrÃ©s Cifuentes	12	3	95	2817
2818	CÃ©sar Luis Rojas Erazo	7	5	10	2818
2819	Juan Soto	6	45	87	2819
2820	Luis Oviedo Morales	2	11	24	2820
2821	Valentina Martha Romero	8	50	33	2821
2822	Javier BohÃ³rquez	12	22	4	2822
2823	Laura Fanny JimÃ©nez	2	45	64	2823
2824	Jhon FlÃ³rez Erazo	6	10	36	2824
2825	Luz Fuentes	8	30	64	2825
2827	Esmeralda Milena Caballero	6	32	24	2827
2828	Yudy Parra Torres	1	28	62	2828
2829	YazmÃ­n Sandoval Gil	2	28	78	2829
2830	Ana Elena RamÃ­rez	11	35	30	2830
2831	William Carlos CerÃ³n	7	38	34	2831
2832	Dayana PÃ©rez LÃ³pez	15	24	84	2832
2833	Leonardo Ramos Sierra	4	14	15	2833
2834	Marcela Emilse MÃ©ndez Torres	9	15	50	2834
2835	Julio MartÃ­nez	14	22	69	2835
2836	Esperanza Fonseca PÃ©rez	15	15	14	2836
2837	Alejandro Alfonso Cardozo RamÃ­rez	2	7	7	2837
2838	Pablo Diego Cabrera	5	28	37	2838
2839	MarÃ­a Valderrama Medina	15	42	58	2839
2840	Diana Luz Restrepo Reyes	5	45	79	2840
2841	Javier JosÃ© Silva	6	24	36	2841
2842	Gisela Isabel LondoÃ±o Orozco	2	19	73	2842
2843	Luis RodrÃ­guez PeÃ±a	2	34	90	2843
2844	Felipe DuvÃ¡n Toro PeÃ±a	10	21	64	2844
2845	Alexis Giraldo HernÃ¡ndez	13	40	91	2845
2846	Alberto Enrique Ballesteros	10	48	43	2846
2847	Jhon Jhon Tamayo MartÃ­nez	13	15	39	2847
2848	Manuel VÃ¡squez	4	50	71	2848
2849	Felipe GonzÃ¡lez	13	3	31	2849
2850	Claudia Sara Castro CÃ¡ceres	8	9	94	2850
2851	Milena GarcÃ­a	9	19	100	2851
2852	Felipe BolaÃ±os	7	7	10	2852
2853	JosÃ© MejÃ­a Vargas	11	50	67	2853
2854	MarÃ­a Santos	7	13	71	2854
2855	Margarita Ruth Pineda	11	48	70	2855
2856	Paola Orozco	11	40	73	2856
2857	Arturo Carlos Toro Osorio	5	32	43	2857
2858	Gloria GutiÃ©rrez DÃ­az	7	5	12	2858
2859	Laura Pardo LeÃ³n	3	19	72	2859
2860	JazmÃ­n Agudelo	5	35	7	2860
2861	Walter LondoÃ±o	2	4	21	2861
2862	Ana Jaramillo	2	39	6	2862
2863	Ismael Arley LondoÃ±o Alzate	5	48	99	2863
2864	Mary Rubiela Murillo	14	21	76	2864
2865	Carlos Joan Silva Mendoza	5	12	79	2865
2866	Mary Luz GarzÃ³n	10	14	7	2866
2867	InÃ©s Moreno	12	30	69	2867
2868	Edison RamÃ­rez	4	12	28	2868
2869	HÃ©ctor Correa	8	14	83	2869
2870	JuliÃ¡n LeÃ³n HernÃ¡ndez	14	19	17	2870
2871	Gloria Edith JimÃ©nez	13	22	94	2871
2872	Carlos Duque Palacios	9	11	29	2872
2873	MarÃ­a Corredor	5	11	28	2873
2874	Luis Bonilla Arango	9	16	15	2874
2875	Walter Acevedo GarcÃ­a	11	35	56	2875
2876	Manuel Carlos Rivera	4	41	30	2876
2877	Aurora Rosa Lara	8	23	74	2877
2878	Leidy Pilar Benavides Osorio	1	25	68	2878
2879	MarÃ­a CÃ³rdoba Mora	5	19	66	2879
2880	Amparo Duque Restrepo	1	14	35	2880
2881	Carlos Escobar	14	39	46	2881
2882	Andrea Gloria Uribe LÃ³pez	7	14	78	2882
2883	John Carlos Valencia Ortiz	12	42	70	2883
2884	Eduardo GÃ³mez	3	19	21	2884
2885	Zoraida Villamil Vargas	14	12	61	2885
2886	Andrea Carolina Mendoza	11	31	93	2886
2887	Magda Bustamante	11	16	81	2887
2888	David AndrÃ©s Mendoza	15	42	67	2888
2889	Juan Benavides GarzÃ³n	4	13	74	2889
2890	Ximena Quiroz	14	24	38	2890
2891	MarÃ­a Cifuentes	9	35	3	2891
2892	Carlos Meza	5	6	77	2892
2893	Kevin Johan BermÃºdez	11	25	78	2893
2894	Jenny Diana Arrieta	11	30	99	2894
2896	Carlos Fernando Rueda Daza	1	43	81	2896
2897	Jorge Riascos CÃ¡rdenas	3	28	34	2897
2898	Fernanda MarÃ­a PeÃ±a PÃ©rez	10	15	54	2898
2899	Carlos Arboleda CortÃ©s	4	49	14	2899
2900	MarÃ­a Nayibe SuÃ¡rez Vargas	14	49	3	2900
2901	Victoria MartÃ­nez	2	9	56	2901
2902	MarÃ­a Maribel PÃ©rez	3	36	45	2902
2903	MarÃ­a Linda Salgado	5	39	4	2903
2904	Manuela LÃ³pez	14	27	87	2904
2905	Johana FernÃ¡ndez Bustos	8	35	42	2905
2906	Johan Miguel RodrÃ­guez GaitÃ¡n	12	8	27	2906
2907	Mery Cindy Ospino	14	14	12	2907
2908	Luis Jaimes	11	46	49	2908
2909	Nancy PatiÃ±o Acosta	6	21	81	2909
2910	AndrÃ©s Vargas DurÃ¡n	2	37	54	2910
2911	Margarita GarcÃ­a	1	23	59	2911
2912	Juan Pinto	10	13	51	2912
2913	Martha Vallejo	7	36	51	2913
2914	Alexander Jimmy Giraldo Vargas	9	22	37	2914
2915	Arley Becerra RamÃ­rez	11	46	58	2915
2916	Diana SÃ¡nchez	10	41	18	2916
2917	Sara Arango Salcedo	6	23	87	2917
2918	Camilo Alexander Meneses	8	40	71	2918
2919	Laura Patricia Mendoza Orjuela	7	7	100	2919
2920	Luz Cuesta Prada	12	39	98	2920
2921	Manuel JuliÃ¡n Solano Castillo	1	3	44	2921
2922	Mercedes BarragÃ¡n	3	30	32	2922
2923	Ivonne MarÃ­a Ibarra	11	27	54	2923
2924	Alba Meza	2	29	55	2924
2926	Eduardo Yeison Vargas	1	37	86	2926
2927	Katherine Cecilia NarvÃ¡ez Romero	14	41	33	2927
2929	Juan Ayala Zuluaga	8	28	79	2929
2930	Walter BeltrÃ¡n LÃ³pez	11	41	19	2930
2931	David Orozco	3	28	86	2931
2932	MarÃ­a Arteaga Caballero	9	2	82	2932
2933	JosÃ© VÃ­ctor Murillo Salcedo	10	5	7	2933
2934	Osvaldo CortÃ©s RodrÃ­guez	3	28	21	2934
2935	Mauricio Bernal Giraldo	12	34	44	2935
2936	Marco GÃ³mez Vargas	15	24	28	2936
2937	Francisco PeÃ±a	8	33	55	2937
2938	Gabriel Bernardo Sandoval	8	25	88	2938
2939	Isabel Sandra Giraldo Caballero	2	50	35	2939
2940	Diana Michel Restrepo	12	15	90	2940
2941	Milena Luz GÃ³mez Quintero	10	42	19	2941
2942	Kelly CalderÃ³n	13	26	72	2942
2943	JosÃ© GuzmÃ¡n MartÃ­nez	9	37	80	2943
2944	Juan JosÃ© Giraldo	10	47	15	2944
2945	Edgar Mauricio Tovar	7	44	88	2945
2946	Cecilia Lina GarcÃ­a	3	29	33	2946
2947	Mercedes RodrÃ­guez	13	7	12	2947
2948	Aurelio MuÃ±oz MartÃ­nez	11	34	82	2948
2949	Ricardo Barbosa	12	4	52	2949
2950	JosÃ© Gustavo Guerrero Herrera	5	23	5	2950
2951	Fredy Jhon Ospina	7	46	31	2951
2952	Marta HernÃ¡ndez DÃ­az	14	4	77	2952
2953	Kevin Mosquera	1	45	57	2953
2954	Dayana Jennifer CastrillÃ³n	4	42	58	2954
2955	JosÃ© Mora Castro	15	20	33	2955
2956	MarÃ­a Jennifer Orozco RamÃ­rez	8	28	94	2956
2957	Alejandro GÃ³mez Gallego	9	5	46	2957
2958	MarÃ­a PÃ¡ez	12	21	83	2958
2959	Javier Antonio Arboleda	9	34	80	2959
2960	Augusto Molina Duarte	2	5	8	2960
2961	Isabel Sonia RÃ­os	4	23	40	2961
2963	Jenny Carolina Ospina Ruiz	11	39	45	2963
2964	Pedro Dario Pacheco	2	37	78	2964
2966	Mauricio MartÃ­nez Castro	1	42	43	2966
2967	Javier Santiago Ospina	10	35	26	2967
2968	Laura Mora Valderrama	14	39	56	2968
2969	RenÃ© Ignacio Guevara	8	19	98	2969
2971	Johanna Zapata	12	50	35	2971
2972	Karen Consuelo Arango	12	43	35	2972
2973	CÃ©sar William Silva Orozco	11	9	85	2973
2974	Rafael Alberto Jaimes	2	50	64	2974
2975	Javier RamÃ­rez	6	1	31	2975
2976	Liliana MarÃ­a DÃ­az Miranda	11	26	45	2976
2977	Lucy Miriam MartÃ­nez	5	15	57	2977
2978	Jhon Felix PabÃ³n GonzÃ¡lez	15	31	57	2978
2979	Jonatan BermÃºdez	14	22	60	2979
2980	InÃ©s Elizabeth Castro	4	35	34	2980
2981	Javier FabiÃ¡n Agudelo	4	4	74	2981
2982	Yaneth MarÃ­a Mora	8	11	26	2982
2983	Robert JosÃ© CÃ³rdoba BermÃºdez	9	23	78	2983
2984	Stiven Estrada PÃ©rez	15	2	74	2984
2985	MarÃ­a Katherin LÃ³pez Medina	7	45	85	2985
2986	Miguel JosÃ© Romero	1	14	81	2986
2987	Nubia Esperanza Delgado SuÃ¡rez	11	48	58	2987
2988	TomÃ¡s Miguel LÃ³pez RÃ­os	4	36	49	2988
2989	Mery MarlÃ©n Agudelo Rosero	12	2	56	2989
2990	Diego CastaÃ±eda	11	15	29	2990
2991	Roberto Juan Perea FlÃ³rez	1	15	69	2991
2992	Cristobal JesÃºs Vargas	7	43	37	2992
2993	Denis Xiomara GaitÃ¡n Aguilar	12	48	57	2993
2994	Kevin Herrera	7	9	44	2994
2995	Elvira Diana Gamboa DurÃ¡n	12	18	92	2995
2996	InÃ©s Socorro Guerrero	11	16	28	2996
2997	Cristian HÃ©ctor Galindo	12	33	85	2997
2998	Jaime Humberto CÃ¡rdenas	5	31	55	2998
2999	Julio Oswaldo PeÃ±a	7	14	8	2999
3000	Arturo Juan PÃ©rez	9	1	75	3000
\.


--
-- Data for Name: vehiculo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vehiculo (id_vehiculo, placa_identificacion, tipo_vehiculo, id_base) FROM stdin;
1	YBU-045	Jeep	22
2	NWE-421	Camion de Transporte	14
3	CRC-339	Jeep	29
4	OAL-388	Ambulancia Militar	17
5	MHX-635	Camion de Transporte	50
6	XBK-382	Ambulancia Militar	29
7	KXS-718	Ambulancia Militar	18
8	YYH-950	Ambulancia Militar	21
9	HAA-836	Helicoptero	3
10	XVN-998	Helicoptero	37
11	BDW-725	Ambulancia Militar	47
12	VSJ-140	Tanque	25
13	JPY-722	Jeep	40
14	TYJ-996	Camion de Transporte	1
15	PMU-015	Jeep	28
16	CVJ-553	Camion de Transporte	39
17	DVM-973	Helicoptero	21
18	ICX-577	Jeep	21
19	LGZ-371	Helicoptero	46
20	HDS-857	Ambulancia Militar	31
21	GXF-781	Camion de Transporte	43
22	YTH-908	Camion de Transporte	25
25	PJI-739	Ambulancia Militar	49
26	PLM-808	Camion de Transporte	23
27	HAA-939	Camion de Transporte	1
28	JHW-789	Camion de Transporte	20
29	ERQ-818	Tanque	40
30	ICP-096	Helicoptero	24
31	UGZ-086	Jeep	8
32	LAE-471	Tanque	50
33	IDS-571	Tanque	3
34	QTC-237	Ambulancia Militar	11
35	RVN-529	Ambulancia Militar	23
36	UOX-874	Helicoptero	24
37	GYA-297	Helicoptero	36
38	UQC-030	Tanque	28
39	YBK-303	Tanque	38
40	EAQ-985	Jeep	40
41	HWS-971	Helicoptero	49
42	IPN-987	Camion de Transporte	17
43	YID-998	Ambulancia Militar	5
44	YZB-957	Ambulancia Militar	38
45	QSJ-648	Jeep	1
46	EEW-471	Jeep	11
47	IMN-321	Jeep	16
48	GEB-532	Ambulancia Militar	42
49	AVS-282	Camion de Transporte	38
50	WIR-116	Helicoptero	8
51	YDI-293	Tanque	30
52	KAN-370	Tanque	45
53	HFH-684	Camion de Transporte	31
54	IGC-642	Camion de Transporte	32
55	RAZ-721	Helicoptero	1
56	IXT-194	Tanque	1
57	XKY-265	Camion de Transporte	37
58	CFJ-606	Tanque	1
59	HZG-897	Jeep	23
60	NZD-602	Tanque	17
61	BPG-153	Camion de Transporte	49
62	AEI-064	Helicoptero	26
63	PLF-954	Tanque	8
64	KGZ-993	Camion de Transporte	47
65	INT-709	Tanque	14
66	IPV-441	Tanque	17
67	VKP-441	Tanque	47
68	NBC-468	Ambulancia Militar	43
69	LUJ-235	Camion de Transporte	8
70	AVW-568	Jeep	15
71	NIX-311	Camion de Transporte	3
73	XWU-765	Helicoptero	48
74	WFY-611	Camion de Transporte	41
75	MDI-159	Helicoptero	40
76	TWT-342	Ambulancia Militar	47
77	RQX-258	Camion de Transporte	33
78	BBL-053	Camion de Transporte	21
79	VBJ-045	Ambulancia Militar	38
80	AOO-747	Jeep	5
81	NKP-169	Tanque	4
82	AMK-058	Helicoptero	12
83	VMA-800	Helicoptero	30
84	DLP-023	Jeep	49
85	HEN-920	Jeep	17
86	FER-230	Ambulancia Militar	25
87	QGH-251	Tanque	32
88	ZMW-174	Ambulancia Militar	2
89	KTZ-955	Jeep	30
90	XEA-556	Ambulancia Militar	48
91	YTC-824	Tanque	28
92	OFL-899	Tanque	30
93	SYZ-970	Ambulancia Militar	11
94	NUZ-558	Tanque	40
95	XAG-327	Jeep	7
96	UXN-662	Camion de Transporte	27
97	SBK-713	Camion de Transporte	40
98	DEO-667	Tanque	47
99	DLH-940	Ambulancia Militar	3
100	JOX-524	Jeep	18
101	BMS-157	Jeep	6
102	KCJ-396	Camion de Transporte	20
103	BJQ-730	Jeep	10
104	VYD-586	Tanque	27
106	BNK-696	Ambulancia Militar	24
107	XJS-257	Camion de Transporte	3
108	EVO-473	Helicoptero	26
109	MWU-813	Camion de Transporte	8
110	ZOW-095	Jeep	33
111	IUR-649	Camion de Transporte	22
112	BNO-151	Tanque	28
113	KDJ-177	Ambulancia Militar	14
114	RXD-628	Tanque	27
115	BUT-076	Ambulancia Militar	12
116	BDG-806	Camion de Transporte	30
117	OSE-780	Helicoptero	20
118	ASW-552	Tanque	19
119	LVT-934	Tanque	37
120	VBK-684	Ambulancia Militar	12
121	RZX-889	Jeep	37
122	FLC-626	Ambulancia Militar	49
123	NQX-974	Jeep	3
124	HQK-582	Tanque	23
125	TPD-661	Ambulancia Militar	46
126	YGD-348	Helicoptero	3
127	KKG-236	Tanque	7
128	QYU-987	Ambulancia Militar	10
129	WGR-725	Helicoptero	36
130	GQY-751	Jeep	13
131	AHL-717	Jeep	5
132	QUK-136	Tanque	38
133	RBD-388	Tanque	42
134	TNU-281	Helicoptero	37
135	EEW-900	Ambulancia Militar	36
136	CWG-592	Camion de Transporte	24
137	GDI-176	Jeep	32
138	RIN-460	Ambulancia Militar	32
139	ZHQ-915	Helicoptero	20
140	WPY-067	Tanque	30
141	BER-341	Tanque	6
142	COH-099	Tanque	43
143	TZY-718	Camion de Transporte	45
144	TMU-758	Helicoptero	15
145	XHO-707	Ambulancia Militar	6
146	ANE-418	Jeep	39
147	WRG-580	Helicoptero	49
148	SXU-543	Camion de Transporte	1
149	SDQ-018	Tanque	50
150	MZV-764	Helicoptero	23
151	MCK-363	Helicoptero	33
152	LUH-167	Jeep	2
153	AIS-923	Camion de Transporte	30
154	RBL-605	Helicoptero	50
155	UGT-102	Ambulancia Militar	29
156	QKI-549	Helicoptero	19
157	MTA-907	Helicoptero	23
158	FFO-145	Helicoptero	49
159	ZCP-095	Camion de Transporte	31
160	EKO-435	Tanque	43
161	KSR-583	Tanque	50
162	LFK-251	Ambulancia Militar	45
163	SNK-828	Tanque	46
164	YFJ-874	Camion de Transporte	19
165	BAY-841	Jeep	39
166	CXB-740	Tanque	17
167	XTM-630	Ambulancia Militar	32
168	OXP-137	Tanque	12
169	QPN-014	Jeep	49
170	NMA-785	Jeep	19
171	SUE-930	Camion de Transporte	46
172	WLZ-746	Tanque	23
173	XUS-701	Camion de Transporte	27
174	EZH-551	Camion de Transporte	18
175	YYV-007	Jeep	30
176	EQZ-460	Ambulancia Militar	40
177	ZUR-622	Ambulancia Militar	40
178	WQX-062	Ambulancia Militar	37
179	TBL-525	Camion de Transporte	13
180	CAB-792	Jeep	33
181	DKY-879	Jeep	29
182	LKL-221	Ambulancia Militar	19
183	GOD-467	Tanque	10
184	RGL-840	Ambulancia Militar	36
185	GJT-719	Helicoptero	23
186	PJQ-412	Camion de Transporte	17
187	PTB-470	Jeep	4
188	VUI-076	Ambulancia Militar	21
189	PKQ-167	Jeep	38
190	QDT-687	Ambulancia Militar	24
191	UIV-094	Tanque	50
192	BRK-182	Camion de Transporte	23
193	ECF-000	Jeep	40
194	BEL-459	Camion de Transporte	25
195	FBK-853	Jeep	7
196	VNC-336	Tanque	18
197	RQS-923	Tanque	24
198	OMN-701	Tanque	42
199	EFZ-643	Helicoptero	25
200	CJM-552	Tanque	47
201	RAK-202	Camion de Transporte	43
202	VZO-826	Jeep	39
203	ZQF-505	Ambulancia Militar	19
204	QTH-055	Ambulancia Militar	45
205	HTY-966	Tanque	50
206	FRN-506	Camion de Transporte	32
207	FKP-411	Camion de Transporte	3
208	EUW-032	Camion de Transporte	13
209	AFD-582	Tanque	36
210	VUW-960	Jeep	29
211	ZNU-687	Ambulancia Militar	32
212	KJS-191	Ambulancia Militar	6
213	SOQ-852	Ambulancia Militar	18
214	MPA-955	Jeep	35
215	RFW-992	Jeep	37
216	EKC-794	Ambulancia Militar	46
217	AIY-443	Ambulancia Militar	28
218	ONL-532	Tanque	47
219	UNI-888	Camion de Transporte	17
220	MUA-617	Jeep	35
221	GFJ-714	Helicoptero	33
222	PEJ-077	Tanque	33
223	PIR-787	Camion de Transporte	32
224	MVC-077	Ambulancia Militar	25
225	JZB-709	Jeep	11
226	TDI-265	Camion de Transporte	8
227	WHM-620	Jeep	47
228	LYK-607	Tanque	40
229	KEZ-924	Tanque	25
231	XOS-064	Tanque	24
232	ALM-977	Ambulancia Militar	17
233	NHF-347	Helicoptero	37
234	RRD-096	Camion de Transporte	4
235	ORH-986	Jeep	27
237	DTO-324	Tanque	4
238	MDE-307	Camion de Transporte	30
239	KMF-860	Jeep	5
240	GIM-123	Jeep	16
241	KVU-493	Ambulancia Militar	19
242	YEO-330	Ambulancia Militar	7
243	NFZ-346	Camion de Transporte	29
244	OJL-545	Ambulancia Militar	29
245	DGS-302	Tanque	32
246	NFZ-368	Camion de Transporte	12
247	VWL-045	Ambulancia Militar	11
248	LIP-489	Ambulancia Militar	11
249	ZTW-377	Tanque	6
250	XWB-647	Jeep	24
251	EZB-666	Helicoptero	27
252	SNF-667	Ambulancia Militar	3
253	WVQ-465	Helicoptero	43
254	PVT-960	Helicoptero	23
255	WKI-542	Jeep	29
256	XUM-601	Helicoptero	41
257	FXH-532	Ambulancia Militar	6
258	PBI-800	Camion de Transporte	49
259	YFY-806	Ambulancia Militar	34
260	FMA-263	Jeep	43
261	PQR-438	Helicoptero	46
262	NHV-063	Camion de Transporte	46
263	GIV-036	Camion de Transporte	5
264	GWD-358	Helicoptero	14
265	UZF-036	Camion de Transporte	24
266	BSC-756	Camion de Transporte	18
267	OFP-557	Ambulancia Militar	20
268	HAT-242	Jeep	17
269	WYJ-558	Jeep	4
270	GQW-034	Tanque	5
271	RYK-240	Tanque	17
272	BHP-774	Ambulancia Militar	35
273	MVU-086	Ambulancia Militar	31
274	YQY-314	Jeep	46
275	OYO-896	Ambulancia Militar	25
276	OME-231	Tanque	20
277	HHX-420	Tanque	45
278	XDI-826	Jeep	35
279	UMP-815	Tanque	2
280	SEI-214	Jeep	47
281	TVY-337	Ambulancia Militar	37
282	SUX-907	Jeep	46
283	NBV-602	Jeep	36
284	YPS-926	Ambulancia Militar	27
285	DKS-010	Jeep	25
286	EPO-115	Ambulancia Militar	14
287	DJO-004	Ambulancia Militar	23
288	CIF-628	Ambulancia Militar	43
289	RKX-845	Jeep	26
290	UGC-448	Tanque	11
291	XWM-037	Jeep	49
292	XMI-332	Ambulancia Militar	33
293	DOP-045	Tanque	17
294	ICI-528	Tanque	39
295	ZSE-505	Ambulancia Militar	49
296	BEP-733	Camion de Transporte	16
297	XOJ-288	Camion de Transporte	18
298	LKX-689	Jeep	20
299	INQ-059	Jeep	23
300	DOH-665	Ambulancia Militar	49
301	YFL-555	Ambulancia Militar	43
302	NCN-159	Jeep	42
303	RAH-445	Tanque	22
304	YST-484	Tanque	16
305	WFF-640	Jeep	46
306	GUY-810	Ambulancia Militar	36
307	WNA-305	Ambulancia Militar	41
308	BOA-751	Helicoptero	4
309	DBD-910	Ambulancia Militar	49
310	UUJ-421	Jeep	11
311	TBY-517	Jeep	49
312	FZL-058	Camion de Transporte	11
313	NBK-293	Jeep	26
314	GGU-117	Tanque	49
315	EAC-174	Camion de Transporte	34
316	GXU-431	Jeep	2
317	GQY-780	Ambulancia Militar	28
318	OOG-135	Jeep	2
319	NOA-955	Ambulancia Militar	41
320	HHV-317	Ambulancia Militar	33
321	CNF-894	Camion de Transporte	38
322	PPG-823	Helicoptero	28
323	IAA-821	Helicoptero	23
324	AZD-050	Helicoptero	32
325	ACL-673	Tanque	21
326	WVZ-343	Helicoptero	22
327	ACD-461	Ambulancia Militar	49
328	ARS-724	Jeep	34
329	YTD-738	Helicoptero	8
330	IYK-092	Tanque	11
331	AQN-731	Tanque	32
332	FZT-728	Ambulancia Militar	24
333	NNI-198	Camion de Transporte	19
334	REX-204	Tanque	45
335	DEO-026	Jeep	3
336	XTU-633	Jeep	45
337	XXF-585	Helicoptero	15
338	PBL-729	Camion de Transporte	21
339	IKR-674	Jeep	3
340	MZL-403	Camion de Transporte	10
341	GRU-511	Jeep	43
342	UQG-553	Camion de Transporte	6
343	ECN-164	Tanque	4
344	NMF-445	Ambulancia Militar	18
345	RSE-306	Ambulancia Militar	33
346	TOC-172	Tanque	2
347	ZZJ-245	Jeep	26
348	CUH-448	Jeep	32
349	EZM-799	Camion de Transporte	7
350	MLM-723	Camion de Transporte	40
351	OEJ-263	Tanque	13
352	ELD-150	Helicoptero	31
353	QXT-700	Tanque	41
354	GRL-449	Camion de Transporte	1
355	DUH-626	Camion de Transporte	29
356	GNF-521	Tanque	43
357	YEX-877	Jeep	11
358	ZRF-280	Helicoptero	41
359	MNJ-326	Jeep	50
360	QEC-127	Ambulancia Militar	8
361	EIX-596	Helicoptero	20
362	TAD-108	Helicoptero	30
363	YBD-392	Helicoptero	20
364	FLE-343	Tanque	32
365	CIM-279	Jeep	25
366	HDZ-029	Helicoptero	21
367	UWF-371	Jeep	14
368	QOX-292	Jeep	39
369	VTE-957	Camion de Transporte	10
370	CVP-280	Helicoptero	28
371	LSY-802	Tanque	20
372	VCD-036	Jeep	35
373	BZH-548	Helicoptero	48
374	CKZ-620	Helicoptero	28
375	CHQ-120	Tanque	26
376	TUP-560	Jeep	23
377	LGD-791	Helicoptero	7
378	HTG-159	Ambulancia Militar	38
379	ICO-426	Helicoptero	42
380	HRY-185	Ambulancia Militar	42
381	DXQ-092	Jeep	24
382	BJJ-414	Jeep	26
383	QHD-608	Camion de Transporte	45
384	CPJ-576	Jeep	41
385	SIE-007	Tanque	8
386	RDV-330	Camion de Transporte	29
387	RWJ-545	Ambulancia Militar	18
388	NVH-826	Ambulancia Militar	18
389	ZEV-527	Tanque	47
390	RJI-846	Camion de Transporte	50
391	MRK-907	Ambulancia Militar	1
392	XBM-000	Jeep	42
393	TBI-167	Jeep	46
394	HHP-693	Jeep	45
395	OUE-481	Helicoptero	17
396	QWJ-745	Tanque	42
397	KZS-456	Ambulancia Militar	28
398	NIL-031	Ambulancia Militar	24
399	YJR-163	Helicoptero	24
400	LYV-582	Tanque	38
401	TAH-213	Camion de Transporte	46
402	SMM-342	Helicoptero	27
403	LMB-062	Jeep	6
404	FDY-974	Tanque	42
405	AGL-539	Ambulancia Militar	32
406	OSR-422	Camion de Transporte	48
407	DRJ-097	Jeep	34
408	OYE-420	Helicoptero	26
409	YEF-181	Ambulancia Militar	9
410	WBC-861	Tanque	3
411	SLC-927	Jeep	46
412	ZWK-315	Tanque	28
413	BZU-276	Ambulancia Militar	37
414	NEI-721	Helicoptero	24
415	SYJ-705	Tanque	24
416	WTE-849	Ambulancia Militar	13
417	UFO-902	Jeep	8
418	ZWU-327	Tanque	7
419	AEV-573	Helicoptero	4
420	AWY-307	Ambulancia Militar	23
421	HPA-543	Jeep	23
422	IXO-702	Ambulancia Militar	16
423	IKM-285	Ambulancia Militar	6
424	DTI-820	Helicoptero	50
425	ZME-866	Jeep	28
426	FMN-797	Jeep	5
427	PND-190	Camion de Transporte	23
428	OKS-372	Jeep	18
429	ZHK-580	Helicoptero	36
430	EMJ-108	Helicoptero	45
431	HMR-264	Ambulancia Militar	12
432	HRH-390	Tanque	22
433	ABU-744	Tanque	25
435	EJS-860	Tanque	38
436	XHT-074	Ambulancia Militar	28
437	OLE-338	Camion de Transporte	41
438	RTT-854	Jeep	31
439	MRU-103	Jeep	1
440	DGD-531	Tanque	45
441	MKY-162	Tanque	27
442	AWM-630	Jeep	38
443	XDW-086	Jeep	48
444	IJF-778	Helicoptero	32
445	WGL-650	Ambulancia Militar	22
446	SLE-217	Tanque	6
447	XXB-627	Tanque	41
448	NYF-485	Helicoptero	6
449	RTB-087	Camion de Transporte	21
450	VJS-799	Camion de Transporte	19
451	VTH-430	Ambulancia Militar	23
452	TTE-658	Helicoptero	6
453	NTG-080	Tanque	22
454	BHJ-257	Camion de Transporte	47
455	LQT-891	Helicoptero	17
456	AOW-356	Camion de Transporte	37
457	NHQ-997	Camion de Transporte	17
458	QRT-141	Ambulancia Militar	27
459	LNI-095	Ambulancia Militar	46
460	LKB-992	Helicoptero	9
461	QXI-934	Helicoptero	25
462	XOR-852	Ambulancia Militar	1
463	XZQ-009	Jeep	33
464	GBY-048	Helicoptero	33
465	BXM-972	Helicoptero	17
466	YMW-182	Jeep	46
467	WLO-208	Jeep	50
468	VCS-570	Jeep	21
469	RAL-901	Jeep	32
470	KUF-859	Helicoptero	19
471	YZK-245	Tanque	28
472	VUH-687	Jeep	45
473	XGI-069	Tanque	4
474	RUK-768	Ambulancia Militar	10
475	VKL-308	Ambulancia Militar	35
476	GTL-881	Jeep	11
477	TRP-186	Helicoptero	42
478	AMY-194	Helicoptero	26
479	NDU-394	Jeep	39
480	MFH-172	Tanque	17
481	DYM-996	Jeep	17
482	IDC-463	Ambulancia Militar	7
483	HAB-442	Camion de Transporte	36
484	JJJ-658	Jeep	14
485	UPZ-066	Camion de Transporte	45
486	RBQ-973	Tanque	7
487	CZY-107	Helicoptero	40
488	OMS-221	Tanque	17
489	JZD-832	Helicoptero	37
490	VZV-552	Helicoptero	22
491	SPC-890	Ambulancia Militar	32
492	AXG-758	Tanque	18
493	UFX-312	Camion de Transporte	5
494	PFA-248	Tanque	22
495	LKC-485	Jeep	8
496	WYL-905	Tanque	45
497	UXI-336	Jeep	21
498	XOH-759	Tanque	29
499	ZTB-056	Camion de Transporte	16
500	LHM-759	Ambulancia Militar	41
501	KAO-055	Helicoptero	43
502	TNF-781	Jeep	9
503	VTR-485	Helicoptero	28
504	TJP-866	Tanque	35
505	IAR-087	Jeep	35
506	OIX-889	Tanque	6
507	ETA-393	Camion de Transporte	47
509	RWF-875	Jeep	16
510	SXY-657	Ambulancia Militar	49
511	RTY-467	Ambulancia Militar	34
512	RAA-426	Camion de Transporte	30
513	NHR-823	Camion de Transporte	26
514	GIP-239	Helicoptero	9
515	BBU-865	Helicoptero	17
516	UIV-850	Ambulancia Militar	11
517	VEZ-964	Tanque	39
518	KOW-720	Camion de Transporte	1
519	VGC-536	Tanque	29
520	RKM-045	Ambulancia Militar	20
521	EYY-978	Helicoptero	10
522	PGR-309	Camion de Transporte	42
523	TQZ-870	Tanque	37
524	RDJ-325	Ambulancia Militar	26
525	PRV-458	Camion de Transporte	14
526	TLZ-608	Ambulancia Militar	5
527	KPV-824	Camion de Transporte	2
528	TBL-423	Tanque	1
529	CGN-897	Camion de Transporte	50
530	JNK-992	Camion de Transporte	22
531	UUR-443	Ambulancia Militar	37
532	PZA-944	Tanque	30
533	SFV-181	Jeep	39
534	YGQ-019	Camion de Transporte	30
535	CSH-605	Ambulancia Militar	15
536	VJU-998	Jeep	12
537	LYX-744	Camion de Transporte	6
538	SFA-202	Helicoptero	27
539	RQL-285	Camion de Transporte	2
540	PPH-589	Tanque	20
541	GCA-698	Tanque	3
542	BQG-563	Camion de Transporte	9
543	URN-949	Helicoptero	20
544	OLF-075	Ambulancia Militar	12
545	BQU-853	Tanque	24
546	KZT-762	Tanque	46
547	FCS-691	Camion de Transporte	49
548	WHV-277	Camion de Transporte	30
549	NRN-262	Ambulancia Militar	8
550	HID-939	Ambulancia Militar	23
551	TVM-809	Camion de Transporte	28
552	JCB-318	Tanque	40
553	UOR-916	Jeep	24
554	VTD-004	Helicoptero	18
555	PFX-928	Camion de Transporte	23
556	OQN-480	Tanque	19
557	EAZ-246	Camion de Transporte	30
558	OQO-775	Tanque	49
559	FUO-559	Helicoptero	13
561	GJK-028	Tanque	30
562	YWG-475	Ambulancia Militar	10
563	CJB-273	Tanque	4
564	CFQ-891	Tanque	21
565	VRF-755	Jeep	48
566	SEH-082	Helicoptero	31
567	TTP-224	Jeep	6
568	PRT-844	Helicoptero	39
569	OSB-208	Camion de Transporte	26
570	LNA-051	Camion de Transporte	3
571	PQT-805	Helicoptero	35
572	BBO-885	Jeep	11
573	UKJ-019	Camion de Transporte	4
574	FUT-280	Jeep	1
575	ESE-402	Jeep	4
576	ZGO-499	Helicoptero	22
577	DLL-426	Camion de Transporte	43
578	SRJ-760	Camion de Transporte	16
579	NHY-178	Ambulancia Militar	25
580	UEJ-502	Ambulancia Militar	30
581	MEM-292	Jeep	21
582	BKA-401	Ambulancia Militar	22
583	FFF-019	Camion de Transporte	22
584	NPI-961	Camion de Transporte	11
585	CHV-508	Ambulancia Militar	1
586	RPO-550	Helicoptero	16
587	OLE-093	Ambulancia Militar	38
588	YRU-325	Jeep	32
589	TSE-620	Jeep	50
591	GUJ-649	Camion de Transporte	14
592	DIU-767	Camion de Transporte	36
593	AFI-579	Helicoptero	46
594	NWD-173	Ambulancia Militar	9
595	NYB-346	Ambulancia Militar	21
596	FRY-868	Ambulancia Militar	13
597	ANL-722	Helicoptero	5
598	VHZ-983	Tanque	17
599	TRT-405	Camion de Transporte	42
600	JMK-390	Ambulancia Militar	22
601	CDF-964	Tanque	37
602	LSX-402	Tanque	8
603	UXM-360	Tanque	40
604	GYR-255	Camion de Transporte	18
605	TCF-647	Ambulancia Militar	12
606	NGP-054	Jeep	40
607	KNI-404	Helicoptero	32
608	DDS-388	Tanque	27
609	VIH-984	Tanque	10
610	UPH-021	Camion de Transporte	35
611	HNZ-892	Jeep	28
612	SYD-827	Camion de Transporte	11
613	HNZ-855	Helicoptero	9
614	DYX-723	Camion de Transporte	38
615	DGM-454	Tanque	13
616	BDD-599	Tanque	30
617	REY-438	Jeep	18
618	OFD-125	Tanque	27
619	SRP-782	Camion de Transporte	37
620	SRD-700	Tanque	36
621	PWH-877	Ambulancia Militar	7
622	XHH-419	Jeep	30
623	JCK-059	Helicoptero	46
624	KLY-675	Helicoptero	50
625	HBH-283	Jeep	23
626	VEX-232	Jeep	40
627	DSF-889	Ambulancia Militar	16
628	DLT-784	Tanque	10
629	DWT-434	Ambulancia Militar	36
630	DUD-422	Camion de Transporte	43
631	ROA-269	Jeep	16
632	NKL-864	Camion de Transporte	42
633	BON-187	Camion de Transporte	5
634	TEO-080	Camion de Transporte	34
635	VSF-365	Jeep	38
636	XYC-870	Camion de Transporte	5
637	EKH-189	Camion de Transporte	43
638	FMZ-275	Jeep	35
639	YYL-201	Jeep	3
640	YCU-921	Tanque	50
641	ZJF-538	Camion de Transporte	50
642	RDV-019	Tanque	9
643	KEE-289	Tanque	15
644	WWI-538	Camion de Transporte	38
645	ZVT-939	Camion de Transporte	12
646	QBI-782	Tanque	48
647	OPP-610	Camion de Transporte	41
648	JCM-970	Ambulancia Militar	20
649	FZM-502	Jeep	6
650	JGZ-667	Ambulancia Militar	38
651	JGB-493	Camion de Transporte	8
652	PPM-618	Helicoptero	34
653	AQF-572	Tanque	33
654	APT-554	Helicoptero	13
655	GBZ-241	Helicoptero	12
656	LDB-125	Jeep	24
657	BNL-934	Ambulancia Militar	41
658	NHS-806	Tanque	15
659	JUB-461	Tanque	32
660	WRH-271	Camion de Transporte	2
661	GFU-354	Jeep	46
662	NDN-543	Jeep	22
663	YBN-401	Ambulancia Militar	50
664	GZS-665	Jeep	3
665	OPL-290	Camion de Transporte	48
666	JHG-971	Helicoptero	20
667	QII-054	Ambulancia Militar	40
668	PNH-709	Helicoptero	4
669	AKK-071	Camion de Transporte	40
670	WMA-471	Camion de Transporte	26
671	IRK-870	Ambulancia Militar	3
672	WOD-502	Tanque	25
673	EXS-679	Helicoptero	2
674	JDM-662	Camion de Transporte	22
675	FPB-740	Helicoptero	17
676	CXK-726	Ambulancia Militar	5
677	DDT-802	Tanque	31
678	SCW-437	Tanque	9
679	LVX-240	Ambulancia Militar	31
680	SVS-583	Helicoptero	16
681	XCN-599	Jeep	28
682	QKI-657	Helicoptero	14
683	FOF-418	Helicoptero	34
684	JYZ-225	Helicoptero	3
685	CRL-902	Ambulancia Militar	43
686	XQC-325	Jeep	41
687	LJE-868	Ambulancia Militar	10
688	NES-303	Ambulancia Militar	49
689	YEN-351	Ambulancia Militar	14
690	ZZG-088	Jeep	3
691	UVZ-587	Camion de Transporte	35
692	NMP-732	Jeep	2
693	XXY-404	Camion de Transporte	19
694	LPC-640	Helicoptero	22
695	ERX-571	Ambulancia Militar	47
696	DWG-656	Ambulancia Militar	28
697	TJA-855	Jeep	32
698	XBS-020	Tanque	37
699	TRG-795	Jeep	33
700	USX-921	Helicoptero	15
701	KLB-234	Tanque	8
702	ROT-935	Ambulancia Militar	19
704	GBT-304	Ambulancia Militar	24
705	ZQW-368	Ambulancia Militar	16
706	HYH-660	Helicoptero	9
707	XQU-491	Ambulancia Militar	9
708	LQQ-074	Camion de Transporte	39
709	HFA-642	Helicoptero	2
710	XGG-569	Helicoptero	12
711	NPB-545	Tanque	24
712	XFO-704	Jeep	9
713	AEU-027	Tanque	33
714	ESN-374	Helicoptero	30
715	ABA-967	Camion de Transporte	26
716	HZW-289	Camion de Transporte	27
717	RQQ-823	Helicoptero	18
718	YFO-102	Helicoptero	27
719	JCB-527	Ambulancia Militar	42
720	IEM-594	Tanque	12
721	CCM-309	Jeep	21
722	KXN-896	Ambulancia Militar	35
723	BIH-687	Jeep	14
724	JHC-298	Jeep	20
725	OOZ-391	Tanque	36
726	EZD-009	Helicoptero	42
727	NHO-603	Camion de Transporte	36
728	UQS-967	Jeep	14
729	GKO-396	Ambulancia Militar	1
730	DMJ-046	Ambulancia Militar	21
731	NXX-309	Camion de Transporte	17
732	FQQ-467	Helicoptero	39
733	EAM-966	Camion de Transporte	7
734	KQI-249	Tanque	5
735	KTZ-206	Ambulancia Militar	26
736	UJA-042	Jeep	32
737	ORP-581	Jeep	30
738	XYP-264	Helicoptero	26
739	YLB-028	Camion de Transporte	31
740	KWZ-914	Ambulancia Militar	33
741	CLA-132	Ambulancia Militar	45
742	FNI-586	Helicoptero	19
743	XTO-329	Tanque	17
744	IPK-113	Ambulancia Militar	41
745	LQW-568	Tanque	1
746	KGL-743	Tanque	43
747	GWZ-961	Helicoptero	15
748	KIC-353	Camion de Transporte	40
749	LPO-869	Tanque	46
750	XNJ-258	Camion de Transporte	35
751	QRS-967	Helicoptero	9
752	ORA-021	Ambulancia Militar	31
753	XXB-648	Helicoptero	3
754	YSI-842	Camion de Transporte	1
755	UDF-909	Ambulancia Militar	14
756	FCY-735	Ambulancia Militar	43
757	OBB-618	Tanque	3
758	HNG-332	Helicoptero	47
759	DPS-026	Ambulancia Militar	42
760	LNZ-502	Helicoptero	5
761	JIW-003	Jeep	28
762	LKN-302	Jeep	19
763	YOI-792	Helicoptero	27
764	UMQ-345	Helicoptero	4
765	HRQ-468	Tanque	21
766	BVA-739	Tanque	47
767	OCL-223	Jeep	14
768	WPE-302	Camion de Transporte	25
769	ROX-145	Tanque	46
770	TGZ-586	Jeep	38
771	ECZ-215	Camion de Transporte	4
772	VKD-898	Helicoptero	46
773	HUU-746	Tanque	39
774	EMD-862	Camion de Transporte	39
775	YPZ-973	Ambulancia Militar	31
776	TPZ-159	Camion de Transporte	49
777	DAC-602	Camion de Transporte	18
778	ZTK-600	Ambulancia Militar	31
779	XBQ-907	Camion de Transporte	19
780	NOU-299	Ambulancia Militar	27
781	XTH-332	Camion de Transporte	13
782	PVH-389	Ambulancia Militar	30
783	ZUY-100	Jeep	5
784	QCM-070	Tanque	22
785	EOI-207	Ambulancia Militar	35
787	WRV-561	Jeep	43
788	PFP-312	Ambulancia Militar	41
789	TRV-792	Camion de Transporte	43
790	VUF-962	Tanque	30
791	OGI-123	Camion de Transporte	45
793	VJJ-015	Ambulancia Militar	20
794	TCT-768	Ambulancia Militar	16
795	RNX-371	Jeep	5
796	IXN-333	Camion de Transporte	37
797	VMG-319	Tanque	35
798	UPX-367	Ambulancia Militar	8
799	OFN-650	Ambulancia Militar	26
800	ZYN-205	Camion de Transporte	20
801	ZFK-456	Camion de Transporte	26
802	HZD-195	Helicoptero	20
803	WJW-731	Camion de Transporte	11
804	NKX-058	Camion de Transporte	48
805	DVK-509	Ambulancia Militar	40
806	EST-173	Tanque	48
807	OEZ-935	Tanque	48
808	FRR-641	Tanque	27
809	WOL-545	Tanque	3
810	PZW-503	Camion de Transporte	1
811	CGA-474	Tanque	48
812	GHT-670	Camion de Transporte	32
813	EQE-489	Ambulancia Militar	21
814	GFT-629	Ambulancia Militar	27
815	YNP-424	Tanque	34
816	QDO-103	Tanque	39
817	IKV-852	Tanque	6
818	YIE-493	Tanque	50
819	JNF-305	Camion de Transporte	48
820	WQV-791	Ambulancia Militar	49
821	QYA-184	Camion de Transporte	18
822	NJR-723	Tanque	50
823	LVY-159	Ambulancia Militar	4
824	NBY-366	Camion de Transporte	46
825	LGZ-707	Camion de Transporte	3
826	UKG-144	Camion de Transporte	35
827	JAJ-115	Camion de Transporte	1
828	TYV-646	Helicoptero	8
829	EHW-547	Jeep	21
830	IFA-220	Ambulancia Militar	32
831	GDD-465	Ambulancia Militar	8
832	TER-289	Helicoptero	39
833	CFM-117	Helicoptero	43
834	XRF-256	Helicoptero	4
835	FYO-157	Ambulancia Militar	30
836	WWV-084	Tanque	11
837	WIA-557	Ambulancia Militar	10
838	RHH-102	Ambulancia Militar	6
839	XZH-398	Ambulancia Militar	13
840	MFR-867	Jeep	3
841	JQB-750	Ambulancia Militar	27
842	EEI-025	Helicoptero	13
843	CSB-849	Camion de Transporte	35
844	SRC-687	Ambulancia Militar	4
845	CJU-603	Camion de Transporte	29
846	ABS-510	Tanque	41
847	EMQ-112	Camion de Transporte	20
848	TOV-089	Tanque	14
849	QVD-306	Camion de Transporte	13
850	MYK-706	Camion de Transporte	30
851	RMN-210	Ambulancia Militar	36
852	XOF-638	Ambulancia Militar	27
853	PLT-736	Helicoptero	47
854	PMC-782	Tanque	17
855	TEI-406	Jeep	35
856	YEM-065	Ambulancia Militar	19
857	BSX-944	Jeep	1
858	QCA-673	Helicoptero	27
859	OHE-053	Ambulancia Militar	41
860	FXU-416	Jeep	30
861	OKT-580	Helicoptero	28
862	VWT-711	Helicoptero	33
863	SZR-411	Helicoptero	14
864	TCN-635	Ambulancia Militar	36
865	PMO-567	Jeep	32
867	KZF-970	Ambulancia Militar	9
868	NZC-350	Ambulancia Militar	11
869	WKW-479	Tanque	17
870	FDE-505	Ambulancia Militar	28
871	UHI-626	Jeep	15
872	WPU-826	Tanque	36
873	UDJ-717	Tanque	36
874	TCI-017	Helicoptero	7
875	NQY-928	Camion de Transporte	46
876	ILN-536	Jeep	28
877	QSG-998	Jeep	32
879	VYC-831	Tanque	33
880	SSR-665	Camion de Transporte	14
881	NTF-187	Tanque	34
882	BQP-566	Ambulancia Militar	17
883	MNM-593	Jeep	34
884	TKT-075	Tanque	34
885	PMM-765	Ambulancia Militar	36
886	UGN-224	Camion de Transporte	16
887	XLN-673	Tanque	29
888	RGL-136	Ambulancia Militar	3
889	BYS-834	Camion de Transporte	10
890	FLN-034	Helicoptero	11
891	BTZ-254	Camion de Transporte	48
892	FVS-988	Tanque	33
893	OBK-115	Helicoptero	24
894	PAF-039	Helicoptero	38
895	UVE-099	Jeep	31
896	JWB-904	Camion de Transporte	30
897	DPM-655	Ambulancia Militar	36
898	XAX-198	Helicoptero	36
899	RSZ-187	Helicoptero	34
900	HNP-436	Jeep	4
901	NXP-930	Tanque	33
902	COT-598	Ambulancia Militar	24
903	CMD-686	Ambulancia Militar	38
904	LHE-424	Camion de Transporte	6
905	WNQ-564	Tanque	16
906	HEO-338	Tanque	5
907	UUK-600	Ambulancia Militar	16
908	ILF-019	Tanque	20
909	LOS-277	Helicoptero	23
910	KZO-613	Helicoptero	2
911	ZLI-476	Tanque	50
912	VNW-172	Helicoptero	12
913	PXT-791	Jeep	22
914	QKO-080	Camion de Transporte	43
915	NNJ-368	Tanque	45
916	ANU-559	Tanque	13
917	UXS-516	Camion de Transporte	29
918	YRF-583	Ambulancia Militar	50
919	HGZ-618	Jeep	50
921	STW-352	Jeep	6
922	PIW-886	Jeep	20
923	QEP-157	Ambulancia Militar	3
924	VRV-490	Jeep	33
925	RXI-369	Helicoptero	11
926	EZA-159	Tanque	28
927	WMJ-586	Helicoptero	48
928	DNZ-206	Ambulancia Militar	1
929	TJM-903	Tanque	4
930	OPV-673	Ambulancia Militar	48
931	AZY-927	Camion de Transporte	45
932	GGL-245	Tanque	14
933	DRQ-907	Camion de Transporte	13
934	UCI-581	Jeep	3
935	ERW-573	Ambulancia Militar	10
936	IUP-652	Ambulancia Militar	5
937	KNC-992	Tanque	22
938	HJR-487	Camion de Transporte	2
939	UDO-890	Camion de Transporte	22
940	BUP-459	Helicoptero	22
941	XSO-979	Ambulancia Militar	14
942	MMM-688	Jeep	9
943	DTX-223	Tanque	11
944	NXK-436	Jeep	1
945	DIL-166	Tanque	6
946	VPJ-197	Tanque	39
947	CNF-200	Jeep	50
948	QZZ-816	Tanque	18
949	FJF-368	Tanque	6
950	NXK-181	Ambulancia Militar	9
951	LII-983	Jeep	4
952	BHO-120	Tanque	2
953	QZT-085	Camion de Transporte	30
954	QYN-260	Tanque	48
955	YNB-853	Ambulancia Militar	34
956	IDS-353	Ambulancia Militar	12
957	KTP-795	Helicoptero	35
958	GMC-802	Helicoptero	5
959	QUQ-895	Tanque	27
960	PSS-186	Camion de Transporte	31
961	PGU-590	Ambulancia Militar	42
962	LJA-337	Camion de Transporte	49
963	HOL-304	Camion de Transporte	37
964	TYB-623	Camion de Transporte	39
965	QHT-202	Ambulancia Militar	29
966	GZM-044	Helicoptero	1
967	OEE-948	Camion de Transporte	11
968	MWX-746	Helicoptero	40
969	WZW-974	Helicoptero	27
970	CUL-098	Ambulancia Militar	41
971	XPO-919	Jeep	13
973	CPS-499	Jeep	45
974	VKY-785	Helicoptero	17
975	QEF-813	Camion de Transporte	28
976	BIO-410	Camion de Transporte	1
977	WWZ-713	Tanque	9
978	VKX-787	Helicoptero	11
979	EOD-653	Ambulancia Militar	8
980	QSS-391	Tanque	26
981	FAT-605	Helicoptero	16
982	LFD-118	Camion de Transporte	35
983	JFQ-678	Helicoptero	27
984	NLA-163	Jeep	48
985	QQN-984	Ambulancia Militar	5
986	FEZ-673	Camion de Transporte	2
987	FID-047	Helicoptero	37
988	XUG-297	Ambulancia Militar	21
989	KCW-553	Camion de Transporte	41
990	PYX-423	Helicoptero	13
991	VYM-479	Jeep	2
992	WHW-102	Ambulancia Militar	9
993	FAI-373	Helicoptero	8
994	MKZ-121	Jeep	33
995	VOD-726	Helicoptero	3
996	MVU-116	Camion de Transporte	13
997	OBB-047	Jeep	21
998	BDD-436	Camion de Transporte	10
999	URX-669	Tanque	24
1000	MJW-219	Camion de Transporte	36
\.


--
-- Name: arma_fuego arma_fuego_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.arma_fuego
    ADD CONSTRAINT arma_fuego_pkey PRIMARY KEY (id_arma);


--
-- Name: armamento armamento_numero_serie_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.armamento
    ADD CONSTRAINT armamento_numero_serie_key UNIQUE (numero_serie);


--
-- Name: armamento armamento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.armamento
    ADD CONSTRAINT armamento_pkey PRIMARY KEY (id_arma);


--
-- Name: asignacion_mision asignacion_mision_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.asignacion_mision
    ADD CONSTRAINT asignacion_mision_pkey PRIMARY KEY (id_asignacion);


--
-- Name: base_militar base_militar_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.base_militar
    ADD CONSTRAINT base_militar_pkey PRIMARY KEY (id_base);


--
-- Name: batallon batallon_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.batallon
    ADD CONSTRAINT batallon_pkey PRIMARY KEY (id_batallon);


--
-- Name: calibre calibre_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calibre
    ADD CONSTRAINT calibre_pkey PRIMARY KEY (id_calibre);


--
-- Name: categoria_arma categoria_arma_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categoria_arma
    ADD CONSTRAINT categoria_arma_pkey PRIMARY KEY (id_categoria);


--
-- Name: especialidad especialidad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.especialidad
    ADD CONSTRAINT especialidad_pkey PRIMARY KEY (id_especialidad);


--
-- Name: explosivo explosivo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.explosivo
    ADD CONSTRAINT explosivo_pkey PRIMARY KEY (id_arma);


--
-- Name: historial_medico historial_medico_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historial_medico
    ADD CONSTRAINT historial_medico_pkey PRIMARY KEY (id_historial);


--
-- Name: mision mision_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mision
    ADD CONSTRAINT mision_pkey PRIMARY KEY (id_mision);


--
-- Name: municion municion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.municion
    ADD CONSTRAINT municion_pkey PRIMARY KEY (id_municion);


--
-- Name: rango rango_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rango
    ADD CONSTRAINT rango_pkey PRIMARY KEY (id_rango);


--
-- Name: soldado soldado_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.soldado
    ADD CONSTRAINT soldado_pkey PRIMARY KEY (id_soldado);


--
-- Name: vehiculo vehiculo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehiculo
    ADD CONSTRAINT vehiculo_pkey PRIMARY KEY (id_vehiculo);


--
-- Name: vehiculo vehiculo_placa_identificacion_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehiculo
    ADD CONSTRAINT vehiculo_placa_identificacion_key UNIQUE (placa_identificacion);


--
-- Name: asignacion_mision trg_evitar_asignacion_baja_medica; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_evitar_asignacion_baja_medica BEFORE INSERT ON public.asignacion_mision FOR EACH ROW EXECUTE FUNCTION public.verificar_salud_soldado();


--
-- Name: historial_medico trg_liberar_arma_fallecido; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_liberar_arma_fallecido AFTER UPDATE ON public.historial_medico FOR EACH ROW EXECUTE FUNCTION public.liberar_arma_por_fallecimiento();


--
-- Name: arma_fuego arma_fuego_id_arma_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.arma_fuego
    ADD CONSTRAINT arma_fuego_id_arma_fkey FOREIGN KEY (id_arma) REFERENCES public.armamento(id_arma);


--
-- Name: arma_fuego arma_fuego_id_calibre_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.arma_fuego
    ADD CONSTRAINT arma_fuego_id_calibre_fkey FOREIGN KEY (id_calibre) REFERENCES public.calibre(id_calibre);


--
-- Name: armamento armamento_id_categoria_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.armamento
    ADD CONSTRAINT armamento_id_categoria_fkey FOREIGN KEY (id_categoria) REFERENCES public.categoria_arma(id_categoria);


--
-- Name: armamento armamento_id_soldado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.armamento
    ADD CONSTRAINT armamento_id_soldado_fkey FOREIGN KEY (id_soldado) REFERENCES public.soldado(id_soldado);


--
-- Name: asignacion_mision asignacion_mision_id_mision_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.asignacion_mision
    ADD CONSTRAINT asignacion_mision_id_mision_fkey FOREIGN KEY (id_mision) REFERENCES public.mision(id_mision) ON DELETE CASCADE;


--
-- Name: asignacion_mision asignacion_mision_id_soldado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.asignacion_mision
    ADD CONSTRAINT asignacion_mision_id_soldado_fkey FOREIGN KEY (id_soldado) REFERENCES public.soldado(id_soldado);


--
-- Name: batallon batallon_id_base_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.batallon
    ADD CONSTRAINT batallon_id_base_fkey FOREIGN KEY (id_base) REFERENCES public.base_militar(id_base);


--
-- Name: explosivo explosivo_id_arma_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.explosivo
    ADD CONSTRAINT explosivo_id_arma_fkey FOREIGN KEY (id_arma) REFERENCES public.armamento(id_arma);


--
-- Name: municion municion_id_base_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.municion
    ADD CONSTRAINT municion_id_base_fkey FOREIGN KEY (id_base) REFERENCES public.base_militar(id_base);


--
-- Name: municion municion_id_calibre_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.municion
    ADD CONSTRAINT municion_id_calibre_fkey FOREIGN KEY (id_calibre) REFERENCES public.calibre(id_calibre);


--
-- Name: soldado soldado_id_batallon_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.soldado
    ADD CONSTRAINT soldado_id_batallon_fkey FOREIGN KEY (id_batallon) REFERENCES public.batallon(id_batallon);


--
-- Name: soldado soldado_id_especialidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.soldado
    ADD CONSTRAINT soldado_id_especialidad_fkey FOREIGN KEY (id_especialidad) REFERENCES public.especialidad(id_especialidad);


--
-- Name: soldado soldado_id_historial_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.soldado
    ADD CONSTRAINT soldado_id_historial_fkey FOREIGN KEY (id_historial) REFERENCES public.historial_medico(id_historial);


--
-- Name: soldado soldado_id_rango_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.soldado
    ADD CONSTRAINT soldado_id_rango_fkey FOREIGN KEY (id_rango) REFERENCES public.rango(id_rango);


--
-- Name: vehiculo vehiculo_id_base_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehiculo
    ADD CONSTRAINT vehiculo_id_base_fkey FOREIGN KEY (id_base) REFERENCES public.base_militar(id_base);


--
-- PostgreSQL database dump complete
--

\unrestrict lmhjk702lhC39CUAFaUAwNxfBehDIloYG6ghsxNr39rREjM0Dbpt5uQos4XCd4O

