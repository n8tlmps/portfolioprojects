import pandas as pd
import mysql.connector
from mysql.connector import Error
import numpy as np

def dataframe_to_mysql(df, table_name, connection_config, if_exists='replace'):
    """
    Insert pandas DataFrame into MySQL table using mysql.connector
    
    Parameters:
    - df: pandas DataFrame
    - table_name: name of the MySQL table
    - connection_config: dict with connection parameters
    - if_exists: 'replace', 'append', or 'fail'
    """
    try:
        # Create connection
        cnx = mysql.connector.connect(**connection_config)
        cursor = cnx.cursor()
        
        # Handle table existence
        if if_exists == 'replace':
            cursor.execute(f"DROP TABLE IF EXISTS `{table_name}`")
        elif if_exists == 'fail':
            cursor.execute(f"SHOW TABLES LIKE '{table_name}'")
            if cursor.fetchone():
                raise ValueError(f"Table '{table_name}' already exists")
        
        # Create table if it doesn't exist or if replacing
        if if_exists in ['replace', 'fail'] or not table_exists(cursor, table_name):
            create_table_sql = generate_create_table_sql(df, table_name)
            cursor.execute(create_table_sql)
            print(f"✅ Table '{table_name}' created successfully")
        
        # Prepare INSERT statement
        columns = ', '.join([f"`{col}`" for col in df.columns])
        placeholders = ', '.join(['%s'] * len(df.columns))
        insert_sql = f"INSERT INTO `{table_name}` ({columns}) VALUES ({placeholders})"
        
        # Convert DataFrame to list of tuples, handling NaN values
        data = []
        for _, row in df.iterrows():
            row_data = []
            for value in row:
                if pd.isna(value):
                    row_data.append(None)
                elif isinstance(value, (np.integer, np.floating)):
                    row_data.append(value.item())  # Convert numpy types to Python types
                else:
                    row_data.append(value)
            data.append(tuple(row_data))
        
        # Insert data in batches for better performance
        batch_size = 1000
        total_rows = len(data)
        
        for i in range(0, total_rows, batch_size):
            batch = data[i:i+batch_size]
            cursor.executemany(insert_sql, batch)
            print(f"📝 Inserted batch {i//batch_size + 1}: {len(batch)} rows")
        
        cnx.commit()
        print(f"✅ Successfully inserted {total_rows} rows into '{table_name}'")
        
    except Error as e:
        cnx.rollback()
        print(f"❌ MySQL Error: {e}")
    except Exception as e:
        cnx.rollback()
        print(f"❌ Error: {e}")
    finally:
        if cnx.is_connected():
            cursor.close()
            cnx.close()

def table_exists(cursor, table_name):
    """Check if table exists"""
    cursor.execute(f"SHOW TABLES LIKE '{table_name}'")
    return cursor.fetchone() is not None

def generate_create_table_sql(df, table_name):
    """Generate CREATE TABLE SQL based on DataFrame dtypes"""
    columns = []
    
    for col, dtype in df.dtypes.items():
        col_name = f"`{col}`"
        
        if dtype == 'object':
            # Check if it's likely text or short string
            max_length = df[col].astype(str).str.len().max() if not df[col].empty else 0
            if max_length > 255:
                sql_type = "TEXT"
            else:
                sql_type = f"VARCHAR({max(max_length, 255)})"
        elif dtype in ['int64', 'int32']:
            sql_type = "BIGINT"
        elif dtype in ['int16', 'int8']:
            sql_type = "INT"
        elif dtype in ['float64', 'float32']:
            sql_type = "DOUBLE"
        elif dtype == 'bool':
            sql_type = "BOOLEAN"
        elif dtype == 'datetime64[ns]':
            sql_type = "DATETIME"
        else:
            sql_type = "TEXT"  # Default fallback
        
        columns.append(f"{col_name} {sql_type}")
    
    return f"CREATE TABLE `{table_name}` ({', '.join(columns)})"

def quick_insert(df, table_name, connection_config):
    """Quick and simple insert function"""
    try:
        cnx = mysql.connector.connect(**connection_config)
        cursor = cnx.cursor()
        
        # Drop and recreate table
        cursor.execute(f"DROP TABLE IF EXISTS `{table_name}`")
        
        # Auto-generate CREATE TABLE
        create_sql = generate_create_table_sql(df, table_name)
        cursor.execute(create_sql)
        
        # Insert all data
        columns = ', '.join([f"`{col}`" for col in df.columns])
        placeholders = ', '.join(['%s'] * len(df.columns))
        insert_sql = f"INSERT INTO `{table_name}` ({columns}) VALUES ({placeholders})"
        
        # Convert DataFrame to list of tuples
        data = [tuple(None if pd.isna(x) else x for x in row) for row in df.values]
        
        cursor.executemany(insert_sql, data)
        cnx.commit()
        
        print(f"✅ Quick insert: {len(df)} rows inserted into '{table_name}'")
        
    except Exception as e:
        cnx.rollback()
        print(f"❌ Error: {e}")
    finally:
        if cnx.is_connected():
            cursor.close()
            cnx.close()

# Usage Examples:
if __name__ == "__main__":
    # Your DataFrame
    df = pd.read_csv("Uncleaned_DS_jobs.csv")
    
    # Connection configuration
    config = {
        'host': 'localhost',
        'user': 'root',
        'password': 'IlokanoAko1!',
        'database': 'db',
        'autocommit': False  # We want to control commits manually
    }
    
    # Method 1: Full-featured insert
    dataframe_to_mysql(df, 'DS_jobs', config, if_exists='replace')
    
    # Method 2: Quick insert (simpler, less control)
    # quick_insert(df, 'DS_jobs_quick', config)
    
    # Method 3: Append to existing table
    # dataframe_to_mysql(df, 'DS_jobs', config, if_exists='append')