import gspread
from pyspark.sql import SparkSession
from oauth2client.service_account import ServiceAccountCredentials
from google.cloud import storage
import os

# Configurações do Google Sheets
SHEET_URL = 'https://docs.google.com/spreadsheets/d/1a7oLWioF0vzcpuSCbpNjtSvPxyf5HHV5UZCn2f7nQvk/edit?gid=0'
SHEET_NAME = 'sms'

# Criação da SparkSession
spark = SparkSession.builder \
    .appName("case_uncover") \
    .config("spark.jars", "gs://spark-lib/bigquery/spark-bigquery-latest_2.12.jar") \
    .getOrCreate()

# Configuração do BigQuery
spark.conf.set("spark.sql.catalog.spark_bigquery", "org.apache.spark.sql.execution.datasources.v2.bigquery.BigQueryCatalog")
spark.conf.set("spark.sql.catalog.spark_bigquery.project", "aprendizado-450314") 

scope = [
    'https://spreadsheets.google.com/feeds',
    'https://www.googleapis.com/auth/drive'
]

# Baixar credenciais do Cloud Storage para um arquivo temporário
client_storage = storage.Client()
bucket = client_storage.bucket('dependencia_pyspark')
blob = bucket.blob('key.json')
temp_key_path = '/tmp/key.json'
blob.download_to_filename(temp_key_path)

# Carrega as credenciais do arquivo JSON baixado
creds = ServiceAccountCredentials.from_json_keyfile_name(temp_key_path, scope)

# Autentica o cliente
gspread_client = gspread.authorize(creds)

# Abre a planilha pública
sheet = gspread_client.open_by_url(SHEET_URL).worksheet(SHEET_NAME)

# Lê os dados da planilha
data = sheet.get_all_values()

# Converte os dados para um DataFrame do PySpark
headers = data[0] 
rows = data[1:]

# Remove espaços e caracteres especiais dos cabeçalhos
headers = [header.strip().replace(" ", "_") for header in headers]

# Cria o DataFrame
df = spark.createDataFrame(rows, schema=headers)

# Gravando os dados na tabela do BigQuery
df.write \
    .format("bigquery") \
    .option("table", "prep_uncover.tb_prep_public_test_crm_sms") \
    .option("temporaryGcsBucket", "tmp_dataproc_jw") \
    .mode("overwrite") \
    .save()

# Removendo o arquivo temporário
os.remove(temp_key_path)

# Finaliza a SparkSession
spark.stop()
