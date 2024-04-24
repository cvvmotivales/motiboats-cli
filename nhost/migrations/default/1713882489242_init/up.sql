SET check_function_bodies = false;
CREATE TABLE public.amarre (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    "portName" text,
    id_user uuid NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now(),
    id_puerto uuid,
    mote text,
    id_imagen uuid,
    eslora numeric DEFAULT '8'::numeric,
    manga numeric DEFAULT '3'::numeric,
    "numAmarre" text,
    id_amarre_puerto uuid
);
CREATE TABLE public.amarre_alquiler (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now(),
    id_amarre uuid NOT NULL,
    id_user uuid NOT NULL,
    precio numeric NOT NULL,
    descripcion text,
    eslora numeric NOT NULL,
    manga numeric NOT NULL,
    "fechaIni" date NOT NULL,
    "fechaFin" date NOT NULL,
    activo boolean DEFAULT true
);
CREATE TABLE public.amarre_imagen (
    id integer NOT NULL,
    id_amarre uuid NOT NULL,
    id_imagen uuid NOT NULL,
    pos numeric
);
CREATE SEQUENCE public.amarre_imagen_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.amarre_imagen_id_seq OWNED BY public.amarre_imagen.id;
CREATE TABLE public.amarre_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    id_user uuid NOT NULL,
    id_user_reciever uuid,
    tipo text NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now(),
    precio numeric NOT NULL,
    id_amarre uuid NOT NULL,
    fecha_inicio date,
    fecha_fin date,
    id_amarre_destino uuid
);
CREATE TABLE public.amarre_ventas (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    id_amarre uuid NOT NULL,
    fecha date NOT NULL,
    descripcion text,
    eslora numeric NOT NULL,
    manga numeric NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now(),
    activo boolean DEFAULT true,
    id_user uuid,
    precio numeric
);
CREATE TABLE public.amarres_puerto (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    "numAmarre" text NOT NULL,
    id_puerto uuid NOT NULL,
    eslora numeric,
    manga numeric,
    calado numeric,
    situacion text
);
CREATE TABLE public.boat_port (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    id_boat uuid NOT NULL,
    id_port uuid NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now()
);
CREATE TABLE public.boats (
    id uuid NOT NULL,
    "boatName" text NOT NULL,
    fuel text NOT NULL,
    price numeric NOT NULL,
    cabins integer NOT NULL,
    bathrooms integer NOT NULL,
    location text NOT NULL,
    passengers integer NOT NULL,
    size numeric NOT NULL,
    description text NOT NULL,
    activo boolean DEFAULT true
);
CREATE TABLE public.bookings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    id_boat uuid NOT NULL,
    id_client uuid NOT NULL,
    id_user uuid,
    date date NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    comment text DEFAULT '-'::text,
    price numeric DEFAULT '0'::numeric NOT NULL
);
CREATE TABLE public.bookings_logs (
    id_booking uuid NOT NULL,
    id_status integer NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now()
);
CREATE TABLE public.change_boat_owner_log (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    type text NOT NULL,
    id_user uuid NOT NULL,
    id_boat uuid NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now()
);
CREATE TABLE public.clients (
    id uuid NOT NULL,
    name text NOT NULL,
    lastname text NOT NULL,
    direction text NOT NULL,
    tel text NOT NULL,
    email text NOT NULL,
    id_user uuid
);
CREATE TABLE public.notifications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    checked boolean DEFAULT false,
    title text NOT NULL,
    description text NOT NULL,
    type text NOT NULL,
    id_user_receiver uuid NOT NULL,
    id_boat uuid,
    id_user_sender uuid
);
CREATE TABLE public.ports (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    country text NOT NULL,
    "portName" text NOT NULL,
    region text NOT NULL,
    zone text NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now(),
    "posLat" numeric,
    "posLong" numeric,
    id_tipo uuid DEFAULT '8999698a-1d40-4e44-a7df-6364e940dd64'::uuid,
    "expiracionConcesion" text
);
CREATE TABLE public.puerto_imagen (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    id_puerto uuid NOT NULL,
    id_imagen uuid NOT NULL,
    pos numeric
);
CREATE TABLE public.status (
    id integer NOT NULL,
    status text NOT NULL
);
CREATE SEQUENCE public.status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.status_id_seq OWNED BY public.status.id;
CREATE TABLE public.tipos_puerto (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nombre text NOT NULL
);
CREATE TABLE public.user_boat (
    id uuid NOT NULL,
    id_user uuid NOT NULL,
    id_boat uuid NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now()
);
CREATE VIEW public.v_amarre_ventas AS
 SELECT ve.id,
    ve.id_amarre,
    am.id_amarre_puerto,
    am.id_puerto,
    COALESCE(pu."portName", am."portName") AS portnamelimpio,
        CASE
            WHEN ((am.id_puerto IS NOT NULL) AND (am.id_amarre_puerto IS NOT NULL)) THEN 'verde'::text
            WHEN (am.id_puerto IS NOT NULL) THEN 'naranja'::text
            ELSE 'rojo'::text
        END AS color
   FROM ((public.amarre_ventas ve
     LEFT JOIN public.amarre am ON ((ve.id_amarre = am.id)))
     LEFT JOIN public.ports pu ON ((am.id_puerto = pu.id)));
CREATE VIEW public.v_amarre_ventas_2 AS
 SELECT ve.id,
    ve.id_amarre,
    ve.precio,
    ve.eslora,
    ve.manga,
    ve.fecha,
    ve.descripcion,
    ve.activo,
    am.id_amarre_puerto,
    am.id_puerto,
    am.mote,
    COALESCE(pu."portName", am."portName") AS portnamelimpio,
        CASE
            WHEN ((am.id_puerto IS NOT NULL) AND (am.id_amarre_puerto IS NOT NULL)) THEN 'verde'::text
            WHEN (am.id_puerto IS NOT NULL) THEN 'naranja'::text
            ELSE 'rojo'::text
        END AS color
   FROM ((public.amarre_ventas ve
     LEFT JOIN public.amarre am ON ((ve.id_amarre = am.id)))
     LEFT JOIN public.ports pu ON ((am.id_puerto = pu.id)));
CREATE VIEW public.v_amarre_ventas_totales_colores AS
 SELECT v_amarre_ventas.color,
    count(*) AS count
   FROM public.v_amarre_ventas
  GROUP BY v_amarre_ventas.color;
CREATE VIEW public.v_color_count_per_port AS
 SELECT v.portnamelimpio,
    v.color,
    count(*) AS color_count
   FROM public.v_amarre_ventas_2 v
  GROUP BY v.portnamelimpio, v.color;
CREATE VIEW public.v_portname_count AS
 SELECT v.portnamelimpio,
    count(*) AS color_count
   FROM public.v_amarre_ventas_2 v
  GROUP BY v.portnamelimpio;
CREATE VIEW public.v_portname_count_and_color AS
 SELECT v.portnamelimpio,
    v.color,
    count(*) AS color_count
   FROM public.v_amarre_ventas_2 v
  GROUP BY v.portnamelimpio, v.color;
ALTER TABLE ONLY public.amarre_imagen ALTER COLUMN id SET DEFAULT nextval('public.amarre_imagen_id_seq'::regclass);
ALTER TABLE ONLY public.status ALTER COLUMN id SET DEFAULT nextval('public.status_id_seq'::regclass);
ALTER TABLE ONLY public.amarre_alquiler
    ADD CONSTRAINT amarre_alquiler_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.amarre_imagen
    ADD CONSTRAINT amarre_imagen_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.amarre_logs
    ADD CONSTRAINT amarre_logs_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.amarre
    ADD CONSTRAINT amarre_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.amarre_ventas
    ADD CONSTRAINT amarre_ventas_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.amarres_puerto
    ADD CONSTRAINT amarres_puerto_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.boat_port
    ADD CONSTRAINT boat_port_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.boats
    ADD CONSTRAINT boats_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.bookings_logs
    ADD CONSTRAINT bookings_logs_id_key UNIQUE (id);
ALTER TABLE ONLY public.bookings_logs
    ADD CONSTRAINT bookings_logs_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.change_boat_owner_log
    ADD CONSTRAINT change_boat_owner_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.ports
    ADD CONSTRAINT ports_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.puerto_imagen
    ADD CONSTRAINT puerto_imagen_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.status
    ADD CONSTRAINT status_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.tipos_puerto
    ADD CONSTRAINT tipos_puerto_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.user_boat
    ADD CONSTRAINT user_boat_id_key UNIQUE (id);
ALTER TABLE ONLY public.user_boat
    ADD CONSTRAINT user_boat_pkey PRIMARY KEY (id, id_user);
ALTER TABLE ONLY public.amarre_alquiler
    ADD CONSTRAINT amarre_alquiler_id_amarre_fkey FOREIGN KEY (id_amarre) REFERENCES public.amarre(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.amarre_alquiler
    ADD CONSTRAINT amarre_alquiler_id_user_fkey FOREIGN KEY (id_user) REFERENCES auth.users(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.amarre
    ADD CONSTRAINT amarre_id_amarre_puerto_fkey FOREIGN KEY (id_amarre_puerto) REFERENCES public.amarres_puerto(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.amarre
    ADD CONSTRAINT amarre_id_imagen_fkey FOREIGN KEY (id_imagen) REFERENCES storage.files(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.amarre
    ADD CONSTRAINT amarre_id_puerto_fkey FOREIGN KEY (id_puerto) REFERENCES public.ports(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.amarre
    ADD CONSTRAINT amarre_id_user_fkey FOREIGN KEY (id_user) REFERENCES auth.users(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.amarre_imagen
    ADD CONSTRAINT amarre_imagen_id_amarre_fkey FOREIGN KEY (id_amarre) REFERENCES public.amarre(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.amarre_imagen
    ADD CONSTRAINT amarre_imagen_id_imagen_fkey FOREIGN KEY (id_imagen) REFERENCES storage.files(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.amarre_logs
    ADD CONSTRAINT amarre_logs_id_amarre_fkey FOREIGN KEY (id_amarre) REFERENCES public.amarre(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.amarre_logs
    ADD CONSTRAINT amarre_logs_id_user_fkey FOREIGN KEY (id_user) REFERENCES auth.users(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.amarre_logs
    ADD CONSTRAINT amarre_logs_id_user_reciever_fkey FOREIGN KEY (id_user_reciever) REFERENCES auth.users(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.amarre_ventas
    ADD CONSTRAINT amarre_ventas_id_amarre_fkey FOREIGN KEY (id_amarre) REFERENCES public.amarre(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.amarre_ventas
    ADD CONSTRAINT amarre_ventas_id_user_fkey FOREIGN KEY (id_user) REFERENCES auth.users(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.amarres_puerto
    ADD CONSTRAINT amarres_puerto_id_puerto_fkey FOREIGN KEY (id_puerto) REFERENCES public.ports(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.boat_port
    ADD CONSTRAINT boat_port_id_boat_fkey FOREIGN KEY (id_boat) REFERENCES public.boats(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.boat_port
    ADD CONSTRAINT boat_port_id_port_fkey FOREIGN KEY (id_port) REFERENCES public.ports(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_id_boat_fkey FOREIGN KEY (id_boat) REFERENCES public.boats(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_id_client_fkey FOREIGN KEY (id_client) REFERENCES public.clients(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_id_user_fkey FOREIGN KEY (id_user) REFERENCES auth.users(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.bookings_logs
    ADD CONSTRAINT bookings_logs_id_booking_fkey FOREIGN KEY (id_booking) REFERENCES public.bookings(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.bookings_logs
    ADD CONSTRAINT bookings_logs_id_status_fkey FOREIGN KEY (id_status) REFERENCES public.status(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.change_boat_owner_log
    ADD CONSTRAINT change_boat_owner_id_boat_fkey FOREIGN KEY (id_boat) REFERENCES public.boats(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.change_boat_owner_log
    ADD CONSTRAINT change_boat_owner_id_user_fkey FOREIGN KEY (id_user) REFERENCES auth.users(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_id_user_fkey FOREIGN KEY (id_user) REFERENCES auth.users(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_id_boat_fkey FOREIGN KEY (id_boat) REFERENCES public.boats(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_id_user_fkey FOREIGN KEY (id_user_receiver) REFERENCES auth.users(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_id_user_sender_fkey FOREIGN KEY (id_user_sender) REFERENCES auth.users(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.ports
    ADD CONSTRAINT ports_id_tipo_fkey FOREIGN KEY (id_tipo) REFERENCES public.tipos_puerto(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.puerto_imagen
    ADD CONSTRAINT puerto_imagen_id_imagen_fkey FOREIGN KEY (id_imagen) REFERENCES storage.files(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.puerto_imagen
    ADD CONSTRAINT puerto_imagen_id_puerto_fkey FOREIGN KEY (id_puerto) REFERENCES public.ports(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.user_boat
    ADD CONSTRAINT user_boat_id_boat_fkey FOREIGN KEY (id_boat) REFERENCES public.boats(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.user_boat
    ADD CONSTRAINT user_boat_id_user_fkey FOREIGN KEY (id_user) REFERENCES auth.users(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
