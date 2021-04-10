r"""Parse all the results of Kahle Michalek (in directory ``all-qpoly/``) 
and save the results in json format in a directory ``all-qpoly-json/``.

This is a script.

To recover the data in python, for instancxe the data corresponding to the label "3", use:
```
import json

with ("all-qpoly-json/3.json") as f:
    res = json.load(f)
```

This script should run from within the directory that contains the subdirectories 
``all-qpoly/`` and ``all-qpoly-json/``
from shell with::
   python -m parse_to_json.py
 
or from within python with::
   execfile('parse_to_json.py')
"""
import json, os, barvinok_parser

OUTPUT_DIR = "all-qpoly-json/"
INPUT_DIR = "all-qpoly/"

with os.scandir(INPUT_DIR) as input_dir: # os.scandir for python >= 3.5
    for entry in input_dir:
        if entry.name.endswith(".qpoly") and entry.is_file():
            output_file = entry.name[:-len(".qpoly")] + ".json"
            print("{} -> {}".format(entry.name, output_file))
            with open(entry.path, 'r') as f:
                data = f.read()
            res = barvinok_parser.parse_function(data)
            with open(os.path.join(OUTPUT_DIR, output_file), 'w') as f:
                json.dump(res, f, indent=4)
