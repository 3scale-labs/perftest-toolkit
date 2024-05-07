import logging
import string
import random
import sys
from dataclasses import dataclass
from pathlib import Path

from locust import HttpUser, task, run_single_user, constant_throughput, constant_pacing

logging.basicConfig(format='%(asctime)s %(levelname)s: %(message)s', level=logging.INFO)

@dataclass
class HostData:
    host: str
    token_url: str


def get_host(url: str):
    data = url.strip("\"")
    if data.endswith(":443"):
        data = data.strip(":443")
        data = f"{data}"
    else:
        data = f"{data}"

    return data


def get_path(path: str):
    data = path.strip("\"")
    return data

def parse_csv(csv_file: Path):
    result = HostData

    logging.info(f"loading csv file {csv_file}")

    with open(csv_file) as f:
        lines = f.readlines()
        random_line = random.choice(lines)  # Select a random line from the CSV file
        data = random_line.strip().split(",")  
        result.host = get_host(data[0])
        result.param = data[1].strip('"')

    return result


def python_version_check():
    if sys.version_info < (3, 11):
        logging.info("recommended to use python 3.11 or above and the toml configuration file")
    else:
        logging.info("recommended to use the toml configuration file format for more features")


def parse_json(json_auth: Path):
    import json
    logging.info("loading json configuration file")
    result = HostData
    with open(json_auth) as f:
        data = f.read()
        data = json.loads(data)
        result.host = get_host(data['host'])
        result.param = data['param']

    return result


def load_data():

    auth_csv = Path("3scale.csv")
    if auth_csv.is_file():
        return parse_csv(auth_csv)

    logging.error("no configuration file found, please create one")
    exit(1)


def generate_payload(payload_size):
    return ''.join([random.choice(string.ascii_letters) for _ in range(payload_size)])


auth_data = load_data()


class RhoamUser(HttpUser):
    host = auth_data.host
    param = auth_data.param
    wait_time = constant_pacing(0.207)
    request_headers = ""

    @task(40)
    def get_data(self):
        logging.warning("route: https://%s%s",self.host,self.param)
        self.client.get(f"https://{self.host}{self.param}", headers=self.request_headers, name="Get Data")


if __name__ == "__main__":
    run_single_user(RhoamUser)
