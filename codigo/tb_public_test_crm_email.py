from pyspark.sql import SparkSession
import pandas as pd
import subprocess

# 🔹 Instalação das dependências no job
subprocess.run(["pip", "install", "gspread", "oauth2client"])

# Criação da SparkSession
spark = SparkSession.builder \
    .appName("case_uncover") \
    .config("spark.jars", "gs://spark-lib/bigquery/spark-bigquery-latest_2.12.jar") \
    .getOrCreate()

# Configuração do BigQuery
spark.conf.set("spark.sql.catalog.spark_bigquery", "org.apache.spark.sql.execution.datasources.v2.bigquery.BigQueryCatalog")
spark.conf.set("spark.sql.catalog.spark_bigquery.project", "aprendizado-450314")  # Seu projeto no Google Cloud

# A autenticação do Dataproc será feita automaticamente com a conta de serviço do cluster
client = gspread.authorize(None)  # Usando a autenticação automática

# Abra a Google Sheet
spreadsheet = client.open_by_url("https://docs.google.com/spreadsheets/d/1a7oLWioF0vzcpuSCbpNjtSvPxyf5HHV5UZCn2f7nQvk/edit?gid=0")
worksheet = spreadsheet.sheet2  # Escolha a aba que deseja (sheet1 é a primeira aba)

# Converta os dados da planilha para um DataFrame Pandas
data = worksheet.get_all_records()  # Pega todos os registros da aba
df = pd.DataFrame(data)  # Converte para um DataFrame do Pandas

# Converta o DataFrame do Pandas para um DataFrame do Spark
spark_df = spark.createDataFrame(df)

# Gravando os dados na tabela do BigQuery
spark_df.write \
    .format("bigquery") \
    .option("table", "prep_uncover.tb_prep_public_test_crm_email") \
    .option("temporaryGcsBucket", "tmp_dataproc_jw") \
    .mode("overwrite") \
    .save()

# Finaliza a SparkSession
spark.stop()