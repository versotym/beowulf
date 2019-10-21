import os
import re
from collections import defaultdict
import scipy.io as sio
import numpy as np
import json

# Load list of compounds

with open(os.path.join('..', 'src', 'unique_compounds.txt'),"r") as input_dict:
    list_of_words=[]
    for line in input_dict:
        wrds = line.strip("\n.").split(" ")
        list_of_words += [w.strip() for w in wrds]
            
# Load all words in corpus

with open(os.path.join('..', 'src', 'calgary_proce_x.txt'),"r") as input_file:
    words=[]
    for line in input_file:
        words+=line.strip("\n.").split(" ")
        
# Count compounds frequencies in entire corpus

frequencies = defaultdict(int)

for dword in list_of_words:
    if len(dword) <= 3:
        continue
    for word in words:
        if dword in word:
            frequencies[dword] += 1  

# Get 'cf' (compounds frequencies in entire corpus)

cf = list()
non_hapax_dwords = list()

for dword in frequencies:
    if dword in ('middangeard', 'heofonrice', 'heofoncyning', 'wuldorcyning'):
        cf.append(0)
    # 1 to include only non-hapax compounds | 0 to include all the compounds
    elif frequencies[dword] > 0:
        cf.append(frequencies[dword])
        non_hapax_dwords.append(dword)
    
# Get 'cvec' and 'names' (numbers of compounds in particular poems &
# list of poem titles)

title = ''
endline = '#'
comp_frequencies = defaultdict(int)
cvec = list()
names = list()

for word in words:
    if '{' in word or '}' in word:
        title = re.sub('[\{\}]', '', word)
        title = re.sub('christ3iii', 'christiii', title)
    if len(word) <= 3:
        continue    
    for dword in non_hapax_dwords:
        if dword in word:
            comp_frequencies[title] += 1

for title in comp_frequencies:
    if comp_frequencies[title] > 0:
        cvec.append(comp_frequencies[title])
        names.append(title)

# Store these to .mat file

output = {
    'cf': np.array([cf], dtype='d'),
    'cvec': np.array([cvec], dtype='d'),
    'names': np.array([names], dtype='object')
}

output['cf'] = np.transpose(output['cf'])
output['cvec'] = np.transpose(output['cvec'])
output['names'] = np.transpose(output['names'])

sio.savemat('compounds_data.mat', output)

with open('compounds_prior_names.json', 'w') as outfile:
    json.dump({'names': names}, outfile)