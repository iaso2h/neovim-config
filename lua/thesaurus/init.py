import sys, os, vim, glob

print("hello neovim")

# for p in vim.eval("&runtimepath").split(','):
#     globRes = glob.glob(os.path.join(p, "autoload", "thesaurus_query"))
#     if len(globRes)==1:
#         dname = os.path.dirname(globRes[0])
#         if dname not in sys.path:
#             sys.path.append(dname)
#             break
