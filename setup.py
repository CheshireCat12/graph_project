# -*- coding: utf-8 -*-
from setuptools import setup, Extension

# from distutils.core import setup, Extension
# from Cython.Build import cythonize
# import Cython.Compiler.Options

# Cython.Compiler.Options.docstrings = True

install_requires = [
    'cython',
    'numpy',
    'powerline-status',
    'pytest',
    'xmltodict',
]

extensions = [Extension(name='graph_pkg.graph.graph',
                        sources=['./graph_pkg/graph/graph.pyx'])
              ]

for e in extensions:
    e.cython_directives = {'language_level': "3",  # all are Python-3
                           'embedsignature': True}

cmp_directives = {'binding': True,
                  'language_level': "3",
                  'embedsignature': True}

# tests_require = ['pytest>=4.0.2']

setup(name='graph_pkg',
      version='0.0.1',
      description='A graph module',
      author='Anthony Gillioz',
      author_email='anthony.gillioz@outlook.com',
      install_requires=install_requires,
      setup_requires=[
          'setuptools>=18.0',  # automatically handles Cython extensions
          'cython>=0.28.4',
      ],
      # cythonize(extensions, compiler_directives=cmp_directives)
      # extra_compile_args=["-O3"],
      ext_modules=extensions
      )