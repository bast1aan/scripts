import sys
import json

if __name__ == "__main__":
    fr = sys.argv[1]
    to = sys.argv[2]
    with open(fr, 'r') as fr_fp:
        config = json.load(fr_fp)
        auths = config['auths']
        with open(to, 'w') as to_fp:
            json.dump({'auths': auths}, to_fp, indent='\t')

