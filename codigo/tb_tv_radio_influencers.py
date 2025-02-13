from pyspark.sql import SparkSession
from pyspark.sql.functions import to_date
from pyspark.sql.functions import col

# Criação da SparkSession
spark = SparkSession.builder \
    .appName("case_uncover") \
    .config("spark.jars", "gs://spark-lib/bigquery/spark-bigquery-latest_2.12.jar") \
    .getOrCreate()

# Configuração do BigQuery
spark.conf.set("spark.sql.catalog.spark_bigquery", "org.apache.spark.sql.execution.datasources.v2.bigquery.BigQueryCatalog")
spark.conf.set("spark.sql.catalog.spark_bigquery.project", "aprendizado-450314")  # Substitua pelo ID do seu projeto

# Leitura da tabela tb_raw_leads_sales no dataset raw_uncover
raw_df = spark.read \
    .format("csv") \
    .option("header", "true") \
    .load("gs://tv_radio_influencers_files/*.csv")

# Converter a coluna 'date' para o tipo DATE
raw_df = raw_df.withColumn("date", to_date(raw_df["date"], "yyyy-MM-dd"))
raw_df = raw_df.withColumn("spent", col("spent").cast("float"))

# Gravando os dados na tabela tb_prep_leads_sales no dataset prep_uncover
raw_df.write \
    .format("bigquery") \
    .option("table", "prep_uncover.tb_prep_tv_radio_influencers") \
    .option("temporaryGcsBucket", "tmp_dataproc_jw") \
    .mode("overwrite") \
    .save()

# Finaliza a SparkSession
spark.stop()