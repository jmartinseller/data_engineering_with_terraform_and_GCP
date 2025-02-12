#!/bin/bash
set -ex  # Ativa logs detalhados

# Copia os pacotes do GCS para a máquina local
gsutil cp gs://codigos_jw/pacotes/* /tmp/

# Instala os pacotes localmente
pip install --no-index --find-links=/tmp/ gspread