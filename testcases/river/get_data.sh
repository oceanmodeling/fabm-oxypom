# SPDX-FileCopyrightText: 2025 Helmholtz-Zentrum hereon GmbH
# SPDX-License-Identifier: CC0-1.0
# SPDX-FileContributor Ovidio Garcia-Oliva <ovidio.garcia@hereon.de>

mkdir ./data
cd ./data

NAMES=( "Cuxhaven_DWD!Lufttemperatur" 
        "Cuxhaven_DWD!Windgeschwindigkeit" 
        "Cuxhaven_DWD!Windrichtung"
        "LZ_AL!Salzgehalt_(Dauermessung)"
        "FGG_Elbe_013!Sauerstoffgehalt_(Einzelmessung)"
        "FGG_Elbe_012!Sauerstoffgehalt_(Einzelmessung)"
        "LZ_AL!Wassertemperatur"
        "FGG_Elbe_013!Wassertemperatur"
        "FGG_Elbe_012!Wassertemperatur")  

for NAME in "${NAMES[@]}"; do
    FILENAME="$NAME.zip"
    URL="https://www.kuestendaten.de/DE/dynamisch/appl/data/daten_prod/prodNeuProd/direct_download/$FILENAME"
    wget $URL -O $FILENAME
    unzip $FILENAME
    TXTFILE="${NAME}.txt"
    sed -i '/^[^0-9]/ s/^/# /' "$TXTFILE" #Comment lines that are not numerical
done

cd ..