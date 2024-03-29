import pandas as pd
import os

# This script takes the previously created krab_data dataframe, that contains the list of every protein presenting a krab domain for every organism,
# and checks for every entries in all of the lists whether these proteins also carry a zinc finger domain or not.

accession = [elt for elt in os.listdir('results/') if elt.startswith('GC')]
full_data = []

krab_data = pd.read_csv('table_results/krab_data.csv', sep=';')
for accession_number in accession:
    with open(f"results/{accession_number}/hmm_search/tbl/ZF_processed") as reader:
        prot_list = []
        for line in reader.readlines():
            prot_name = line.split('\t')[0].split(' ')[0]
            if prot_name in krab_data.loc[krab_data['Accession'] == accession_number, 'Protein List'].iloc[0]: 
                prot_list.append(prot_name)
        full_data.append([accession_number, prot_list, len(prot_list)])

zf_data = pd.DataFrame(full_data, columns=['Accession', 'KRAB+ZF protein list', 'KRAB+ZF nb'])
zf_data.to_csv('table_results/krabzf_data.csv', sep= ';', index = False)
