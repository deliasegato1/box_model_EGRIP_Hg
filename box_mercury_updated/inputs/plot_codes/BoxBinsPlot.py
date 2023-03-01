#----------------------------------------------------------
#Read Box.csv
#----------------------------------------------------------
import pandas as pd
import matplotlib.pyplot as plt
import math
from matplotlib.backends.backend_pdf import PdfPages

data = pd.read_csv('outputs/coagulation_BINS.csv',sep='\s+')

endhour = data['Time'].iloc[-1]
starthour = endhour - 48

data[data.Time == endhour]

datatoplot = data[(data.Time >= starthour) & (data.Time<= endhour)]

#pdf = PdfPages('outputs/coagulation_BINS.pdf')
col_nums = 4  # how many plots per row
row_nums = math.ceil(len(datatoplot.columns)/4)  # how many rows of plots
fig = plt.figure(figsize=(50, 30))  # change the figure size as needed
for i in range(1,len(datatoplot.columns)):
    plt.rcParams.update({'font.size': 40})
    plt.subplot(row_nums, col_nums, i)  # create subplots
    p = plt.plot(datatoplot.iloc[:,0]-starthour,datatoplot.iloc[:,i],linewidth=4)
    plt.title(datatoplot.columns.values[i])
    plt.tight_layout()

#pdf.savefig( fig.number )
#pdf.close()

plt.savefig('outputs/coagulation_BINS.png')
plt.close(fig)

#fig, axs = plt.subplots(3,4)
#fig.suptitle('Vertically stacked subplots')
#axs[0].plot(x, y)
#axs[1].plot(x, -y)
#
##%create line plot for all the species
#flag = 0
#flag2 = 0
#for i in mslice[2:size(colheaders, 2)]:
#    flag = flag + 1
#    subaxis(3, 4, flag, mstring('PL'), 0, mstring('PB'), 0.1, mstring('ML'), 0.05, mstring('MR'), 0.02, mstring('MT'), 0.07, mstring('MB'), 0.01)
#    plot(X, plotarray(mslice[:], i), mstring('k'), mstring('linewidth'), 2)
#    grid(mstring('on'))
#    title(colheaders(i))
#    xlim(mcat([0, 48]))
#    NumTicks = 5
#    L = get(gca, mstring('YLim'))
#    set(gca, mstring('YTick'), linspace(L(1), L(2), NumTicks))
#    NumTicks = 5
#    L = get(gca, mstring('XLim'))
#    set(gca, mstring('XTick'), linspace(L(1), L(2), NumTicks))
#    if (flag == 12 or i == size(colheaders, 2)):
#        if (flag2 == 0):
#            outputs / chemistry.cT.cT
#            flag2 = 1
#            flag = 0
#        else:
#            outputs / chemistry.cT.cT
#            mstring('') - pdf.cT.cT
#            flag = 0
#        end
#    end
#end
