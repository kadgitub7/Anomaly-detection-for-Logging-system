# Install pyspark if not already installed
from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType, IntegerType, TimestampType
from pyspark.sql import functions as F
import sys

def main():
    spark = SparkSession.builder \
        .appName("HDFS_Batch_Processor") \
        .getOrCreate()
    spark.sparkContext.setLogLevel("ERROR")

    schema = StructType([
    StructField("timestamp", StringType(), True),
    StructField("value", IntegerType(), True)
    ])
    hdfs_path = "hdfs://namenode:9000/user/data"

    try:

        print("Reading data from HDFS Now")

        df = spark.read.schema(schema).json(hdfs_path + "/*")

        final_df = df.withColumn("ingested_at", F.current_timestamp()) \
                .filter(F.col("value").isNotNull())
        final_df.show(5)
        print("Spark Job Successful")

        print("Connecting to MySQL and writing data...")
        
        db_url = "jdbc:mysql://host.docker.internal:3306/testdb"
        
        db_properties = {
            "user": "root",
            "password": "password",
            "driver": "com.mysql.cj.jdbc.Driver"
        }

        final_df.write.jdbc(
            url=db_url, 
            table="log_data", 
            mode="append", 
            properties=db_properties
        )
        
        print("Data successfully exported to MySQL Workbench Database: testdb - Table: log_data")

        print("Cleaning up HDFS landing zone")
        sc = spark.sparkContext
        Path = sc._gateway.jvm.org.apache.hadoop.fs.Path
        FileSystem = sc._gateway.jvm.org.apache.hadoop.fs.FileSystem
        conf = sc._jsc.hadoopConfiguration()
        fs = FileSystem.get(conf)

        fs.delete(Path(hdfs_path), True)
        fs.mkdirs(Path(hdfs_path))

    except Exception as e:
        print("Error during Spark processing: " + str(e))
        sys.exit(1)
if __name__ == "__main__":
    main()
