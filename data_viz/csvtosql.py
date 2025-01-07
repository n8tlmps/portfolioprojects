# -*- coding: utf-8 -*-
"""
Created on Thurs June 27 2024 17:09:48 2024

@author: nate
"""

import pandas as pd
import os
from sqlalchemy import create_engine

# Specify the CSV file name
file = "listings.csv"

if os.path.isfile(file):
    # Read the CSV file into a DataFrame
    df = pd.read_csv(file)

    # Create SQLAlchemy engine to connect to MySQL Database
    engine = create_engine('mysql+mysqlconnector://root:<PASSWORD>@localhost/db')

    # Convert DataFrame to SQL table, using the file name (without extension) as the table name
    df.to_sql(name=file[:-4], con=engine, index=False, if_exists='replace')  # 'replace' will drop the table if it exists and create a new one

    print('CSV file has been successfully imported into the database.')
else:
    print(f"File {file} does not exist.")
