# -*- coding: utf-8 -*-
"""
Created on Fri Mar  5 16:56:40 2021

@author: iitm-swaleha
"""

import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages

starthour = 0
endhour = 48

# read photolysis_rates.csv file
data = pd.read_csv('outputs/photolysis_rates.csv',sep='\s+')
colheaders = data.columns

z = abs(data['Time']-starthour)
min_z = z[z == min(z)]
startrow = min_z.index[0]

z = abs(data['Time']-endhour)
min_z = z[z == min(z)]
endrow = min_z.index[0]
endrow = endrow + 1

plotarray = data[startrow:endrow]
X = plotarray['Time']

# create line plots for chosen height
col_nums = 5  # how many plots per row
row_nums = 4 # how many rows of plots
pdf = PdfPages('outputs/photolysis.pdf')

m = 0
for i in range(1,len(colheaders)//(col_nums*row_nums)+2):
    fig = plt.figure(figsize=(20, 10))  # change the figure size as needed
    plt.rcParams.update({'font.size': 15})
    for k in range(1,(col_nums*row_nums)+1):
        indx = k+((col_nums*row_nums)*m)
        if indx == len(colheaders):
            break
        plt.subplot(row_nums, col_nums,k)  # create subplots
        plt.plot(X,plotarray.loc[:,colheaders[indx]],linewidth=3)
        plt.xlim([min(X), max(X)])
        plt.xticks(pd.Series(range(int(min(X)),int(max(X))+2,12)))
        kwargs = {'linestyle':'dotted', 'linewidth':2}
        plt.grid(b=None, which='major', axis='x',**kwargs)
        plt.title(colheaders[indx])
        plt.tight_layout()
    m += 1
    pdf.savefig( fig.number )
    plt.close()
pdf.close()



