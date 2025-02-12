from pyspark.sql import SparkSession

# Criação da SparkSession
spark = SparkSession.builder \
    .appName("case_uncover") \
    .config("spark.jars", "gs://spark-lib/bigquery/spark-bigquery-latest_2.12.jar") \
    .getOrCreate()

# Configuração do BigQuery
spark.conf.set("spark.sql.catalog.spark_bigquery", "org.apache.spark.sql.execution.datasources.v2.bigquery.BigQueryCatalog")
spark.conf.set("spark.sql.catalog.spark_bigquery.project", "aprendizado-450314")  # Substitua pelo ID do seu projeto

# Configuração do GCS temporário
spark.conf.set("spark.hadoop.fs.gs.bucket", "gs://tmp_dataproc_jw")

# Leitura da tabela tb_raw_leads_sales no dataset raw_uncover
raw_df = spark.read \
    .format("bigquery") \
    .option("table", "raw_uncover.tb_raw_tv_radio_influencers") \
    .load()


# Gravando os dados na tabela tb_prep_leads_sales no dataset prep_uncover
raw_df.write \
    .format("bigquery") \
    .option("table", "prep_uncover.tb_prep_tv_radio_influencers") \
    .option("temporaryGcsBucket", "gs://tmp_dataproc_jw") \
    .mode("overwrite") \
    .save()

# Finaliza a SparkSession
spark.stop()