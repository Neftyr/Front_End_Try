import yaml, json, os, shutil


def main():
    update_front_end()


def update_front_end():
    # Send the build folder
    copy_folders_to_front_end("./build", "./front_end/src/chain-info")

    # Sending the front end our config in converted into JSON format
    with open("brownie-config.yaml", "r") as brownie_config:
        config_dict = yaml.load(brownie_config, Loader=yaml.FullLoader)
        with open("./front_end/src/brownie-config.json", "w") as brownie_config_json:
            json.dump(config_dict, brownie_config_json)
        print("Front End Updated!")


def copy_folders_to_front_end(source, destination):
    # Swaping files from source(main) folder into destination(front_end)
    if os.path.exists(destination):
        shutil.rmtree(destination)
    shutil.copytree(source, destination)
