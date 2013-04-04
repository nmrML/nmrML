import nmrglue as ng
import matplotlib.pyplot as plt
import numpy as np
import pylab

dic,data = ng.varian.read("sucrosesample_varian/")
dic,data = ng.pipe_proc.ft(dic,data,auto=True)
pylab.plot(data)
pylab.savefig("plot_1d.png")

# 
# # Set the spectral parameters.
# udic = ng.varian.guess_udic(dic, data)
# #udic[0]['size']     = 2048
# udic[0]['complex']  = True
# #udic[0]['encoding'] = 'direct'
# #udic[0]['sw']       = 10000.000
# #udic[0]['obs']      = 600.133
# #udic[0]['car']      = 4.773 * 600.133
# udic[0]['label']    = '1H'
# 
# # convert to pipe??
# C = ng.convert.converter()
# C.from_varian(dic, data, udic)
# dic,data = C.to_pipe()
# 
# # make a unit conversion object
# uc = ng.pipe.make_uc(dic, data)
# 
# # plot the spectrum
# fig = plt.figure()
# ax = fig.add_subplot(111)
# ax.plot(uc.ms_scale(), data, 'k-')
# 
# # decorate axes
# ax.set_yticklabels([])
# ax.set_title("Protein 1D FID")
# ax.set_xlabel("Time (ms)")
# ax.set_ylim(-100000, 100000)
# 
# # save the figure
# fig.savefig("fid.png") # this can be to .pdf, .ps, etc
