import gspread
from pyspark.sql import SparkSession
from oauth2client.service_account import ServiceAccountCredentials

# Configurações do Google Sheets
SHEET_URL = 'https://docs.google.com/spreadsheets/d/1a7oLWioF0vzcpuSCbpNjtSvPxyf5HHV5UZCn2f7nQvk/edit?gid=0'
SHEET_NAME = 'email'

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

# Carrega as credenciais do arquivo JSON
creds = ServiceAccountCredentials.from_json_keyfile_name('gs://dependencia_pyspark/key.json', scope)

# Autentica o cliente
client = gspread.authorize(creds)

# Abre a planilha pública
sheet = client.open_by_url(SHEET_URL).worksheet(SHEET_NAME)

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
    .option("table", "prep_uncover.tb_prep_public_test_crm_email") \
    .option("temporaryGcsBucket", "tmp_dataproc_jw") \
    .mode("overwrite") \
    .save()

# Finaliza a SparkSession

spark.stop()