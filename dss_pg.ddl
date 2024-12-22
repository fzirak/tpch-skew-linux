-- Sccsid:     @(#)dss.ddl	9.1.1.2     2/1/95  12:05:05
DROP TABLE IF EXISTS NATION;
CREATE TABLE NATION  ( N_NATIONKEY  INTEGER NOT NULL,
                            N_NAME       CHAR(25) NOT NULL,
                            N_REGIONKEY  INTEGER NOT NULL,
                            N_COMMENT    VARCHAR(152));

DROP TABLE IF EXISTS REGION;
CREATE TABLE REGION  ( R_REGIONKEY  INTEGER NOT NULL,
                            R_NAME       CHAR(25) NOT NULL,
                            R_COMMENT    VARCHAR(152));

DROP TABLE IF EXISTS PART;
CREATE TABLE PART  ( P_PARTKEY     INTEGER NOT NULL,
                          P_NAME        VARCHAR(55) NOT NULL,
                          P_MFGR        CHAR(25) NOT NULL,
                          P_BRAND       CHAR(10) NOT NULL,
                          P_TYPE        VARCHAR(25) NOT NULL,
                          P_SIZE        INTEGER NOT NULL,
                          P_CONTAINER   CHAR(10) NOT NULL,
                          P_RETAILPRICE DECIMAL(15,2) NOT NULL,
                          P_COMMENT     VARCHAR(23) NOT NULL );

DROP TABLE IF EXISTS SUPPLIER;
CREATE TABLE SUPPLIER ( S_SUPPKEY     INTEGER NOT NULL,
                             S_NAME        CHAR(25) NOT NULL,
                             S_ADDRESS     VARCHAR(40) NOT NULL,
                             S_NATIONKEY   INTEGER NOT NULL,
                             S_PHONE       CHAR(15) NOT NULL,
                             S_ACCTBAL     DECIMAL(15,2) NOT NULL,
                             S_COMMENT     VARCHAR(401) NOT NULL);

DROP TABLE IF EXISTS PARTSUPP;
CREATE TABLE PARTSUPP ( PS_PARTKEY     INTEGER NOT NULL,
                             PS_SUPPKEY     INTEGER NOT NULL,
                             PS_AVAILQTY    INTEGER NOT NULL,
                             PS_SUPPLYCOST  DECIMAL(15,2)  NOT NULL,
                             PS_COMMENT     VARCHAR(199) NOT NULL );

DROP TABLE IF EXISTS CUSTOMER;
CREATE TABLE CUSTOMER ( C_CUSTKEY     INTEGER NOT NULL,
                             C_NAME        VARCHAR(25) NOT NULL,
                             C_ADDRESS     VARCHAR(40) NOT NULL,
                             C_NATIONKEY   INTEGER NOT NULL,
                             C_PHONE       CHAR(15) NOT NULL,
                             C_ACCTBAL     DECIMAL(15,2)   NOT NULL,
                             C_MKTSEGMENT  CHAR(10) NOT NULL,
                             C_COMMENT     VARCHAR(117) NOT NULL);

DROP TABLE IF EXISTS ORDERS;
CREATE TABLE ORDERS  ( O_ORDERKEY       INTEGER NOT NULL,
                           O_CUSTKEY        INTEGER NOT NULL,
                           O_ORDERSTATUS    CHAR(1) NOT NULL,
                           O_TOTALPRICE     DECIMAL(15,2) NOT NULL,
                           O_ORDERDATE      DATE NOT NULL,
                           O_ORDERPRIORITY  CHAR(15) NOT NULL,  -- R
                           O_CLERK          CHAR(15) NOT NULL,  -- R
                           O_SHIPPRIORITY   INTEGER NOT NULL,
                           O_COMMENT        VARCHAR(79) NOT NULL);

DROP TABLE IF EXISTS LINEITEM;
CREATE TABLE LINEITEM ( L_ORDERKEY    INTEGER NOT NULL,
                             L_PARTKEY     INTEGER NOT NULL,
                             L_SUPPKEY     INTEGER NOT NULL,
                             L_LINENUMBER  INTEGER NOT NULL,
                             L_QUANTITY    DECIMAL(15,2) NOT NULL,
                             L_EXTENDEDPRICE  DECIMAL(15,2) NOT NULL,
                             L_DISCOUNT    DECIMAL(15,2) NOT NULL,
                             L_TAX         DECIMAL(15,2) NOT NULL,
                             L_RETURNFLAG  CHAR(1) NOT NULL,
                             L_LINESTATUS  CHAR(1) NOT NULL,
                             L_SHIPDATE    DATE NOT NULL,
                             L_COMMITDATE  DATE NOT NULL,
                             L_RECEIPTDATE DATE NOT NULL,
                             L_SHIPINSTRUCT CHAR(25) NOT NULL,  -- R
                             L_SHIPMODE     CHAR(10) NOT NULL,  -- R
                             L_COMMENT      VARCHAR(44) NOT NULL);

--DROP TABLE IF EXISTS TIME1;
--CREATE TABLE TIME1    ( T_TIMEKEY     INTEGER NOT NULL,
--                        T_ALPHA       DATE NOT NULL,
--                        T_YEAR        INTEGER NOT NULL,
--                        T_MONTH       INTEGER NOT NULL,
--                        T_WEEK        INTEGER NOT NULL,
--                        T_DAY         INTEGER NOT NULL );


ALTER TABLE PART
  ADD CONSTRAINT part_kpey
     PRIMARY KEY (P_PARTKEY);

ALTER TABLE SUPPLIER
  ADD CONSTRAINT supplier_pkey
     PRIMARY KEY (S_SUPPKEY);

ALTER TABLE PARTSUPP
  ADD CONSTRAINT partsupp_pkey
     PRIMARY KEY (PS_PARTKEY, PS_SUPPKEY);

ALTER TABLE CUSTOMER
  ADD CONSTRAINT customer_pkey
     PRIMARY KEY (C_CUSTKEY);

ALTER TABLE ORDERS
  ADD CONSTRAINT orders_pkey
     PRIMARY KEY (O_ORDERKEY);

ALTER TABLE LINEITEM
  ADD CONSTRAINT lineitem_pkey
     PRIMARY KEY (L_ORDERKEY, L_LINENUMBER);

ALTER TABLE NATION
  ADD CONSTRAINT nation_pkey
     PRIMARY KEY (N_NATIONKEY);

ALTER TABLE REGION
  ADD CONSTRAINT region_pkey
     PRIMARY KEY (R_REGIONKEY);

CREATE INDEX customer_c_mktsegment_c_custkey_idx ON customer (c_mktsegment, c_custkey) ;
CREATE INDEX customer_c_nationkey_c_custkey_idx ON customer (c_nationkey, c_custkey) ;
CREATE UNIQUE INDEX pk_customer ON customer (c_custkey) ;
CREATE INDEX line_item_l_orderkey_l_suppkey_idx ON lineitem (l_orderkey, l_suppkey) ;
CREATE INDEX lineitem_l_partkey_l_quantity_l_shipmode_idx ON lineitem (l_partkey, l_quantity, l_shipmode) ;
CREATE INDEX lineitem_l_partkey_l_suppkey_l_shipdate_l_quantity_idx ON lineitem (l_partkey, l_suppkey, l_shipdate, l_quantity) ;
CREATE UNIQUE INDEX pk_lineitem ON lineitem (l_orderkey, l_linenumber) ;
CREATE UNIQUE INDEX pk_nation ON nation (n_nationkey) ;
CREATE INDEX orders_o_custkey_idx ON orders (o_custkey) ;
CREATE INDEX orders_o_orderkey_o_orderdate_idx ON orders (o_orderkey, o_orderdate) ;
CREATE UNIQUE INDEX pk_orders ON orders (o_orderkey) ;
CREATE INDEX part_p_container_p_brand_p_partkey_idx ON part(p_container, p_brand, p_partkey) ;
CREATE INDEX part_p_type_p_partkey_idx ON part(p_type, p_partkey) ;
CREATE UNIQUE INDEX pk_part ON part (p_partkey) ;
CREATE INDEX partsupp_ps_suppkey_idx ON partsupp (ps_suppkey) ;
CREATE UNIQUE INDEX pk_partsupp ON partsupp (ps_partkey, ps_suppkey) ;
CREATE UNIQUE INDEX pk_region ON region (r_regionkey) ;
CREATE UNIQUE INDEX pk_supplier ON supplier (s_suppkey) ;
CREATE INDEX supplier_s_nationkey_s_suppkey_idx ON supplier (s_nationkey, s_suppkey) ;