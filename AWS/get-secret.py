import sys
import boto3
from botocore.exceptions import ClientError
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--name")
parser.add_argument("--profile-name", help="AWS profile")
parser.add_argument("--list", action="store_true")
args = parser.parse_args()

secrets = {
    "ddp-airbyte.pem": "ddp-airbyte PEM",
    "ddp-ui-95e38-c45763654680.json": "google service account",
    "dbsecrets": "rds databases users and passwords",
}

if args.list:
    for secret, description in secrets.items():
        print(f"{secret:50} {description}")

    sys.exit(0)

if args.name is None:
    parser.print_usage()
    sys.exit(0)


session = boto3.session.Session(profile_name=args.profile_name)
secretsmanager = session.client(service_name="secretsmanager", region_name="ap-south-1")

try:
    get_secret_value_response = secretsmanager.get_secret_value(SecretId=args.name)
except ClientError as e:
    # For a list of exceptions thrown, see
    # https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
    raise e

# Decrypts secret using the associated KMS key.
secret = get_secret_value_response["SecretString"]
print(secret)
