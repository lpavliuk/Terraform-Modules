locals {
  datasets = {
    # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html#Concepts.DBInstanceClass.Summary
    db_instance_classes_memory_gib = {
      # db.t4g – burstable-performance instance classes with AWS Graviton2 processors
      "db.t4g.2xlarge" : 32,
      "db.t4g.xlarge"  : 16,
      "db.t4g.large"   : 8,
      "db.t4g.medium"  : 4,
      "db.t4g.small"   : 2,
      "db.t4g.micro"   : 1,
      # db.t3 – burstable-performance instance classes
      "db.t3.2xlarge"  : 32,
      "db.t3.xlarge"   : 4,
      "db.t3.large"    : 8,
      "db.t3.medium"   : 4,
      "db.t3.small"    : 2,
      "db.t3.micro"    : 1,
      # db.t2 – burstable-performance instance classes
      "db.t2.2xlarge"  : 32,
      "db.t2.xlarge"   : 16,
      "db.t2.large"    : 8,
      "db.t2.medium"   : 4,
      "db.t2.small"    : 2,
      "db.t2.micro"    : 1
    }
  }
}