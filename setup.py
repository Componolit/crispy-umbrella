import re
from setuptools import setup, find_packages


with open('rflx/__init__.py') as f:
    version = re.search(r"__version__ = '(.*?)'", f.read()).group(1)

with open('README.md') as f:
    readme = f.read()

with open('requirements.txt') as f:
    requirements = f.read().splitlines()

setup(
    name='RecordFlux',
    version=version,
    description='A toolset for the dissection, generation and verification of '
                'communication protocols.',
    long_description=readme,
    long_description_content_type='text/markdown',
    author='Tobias Reiher',
    author_email='reiher@componolit.com',
    url='https://github.com/Componolit/RecordFlux',
    license='AGPL-3.0',
    classifiers=[
        'Development Status :: 3 - Alpha',
        'Environment :: Console',
        'License :: OSI Approved :: GNU Affero General Public License v3',
        'Operating System :: OS Independent',
        'Programming Language :: Ada',
        'Programming Language :: Python :: 3 :: Only',
        'Programming Language :: Python :: 3.6',
        'Programming Language :: Python :: 3.7',
        'Topic :: Communications',
        'Topic :: Security',
        'Topic :: Software Development :: Build Tools',
        'Topic :: Software Development :: Code Generators',
        'Topic :: System :: Networking',
    ],
    packages=find_packages(exclude=('tests',)),
    package_data={'rflx': ['templates/*']},
    python_requires='>=3.6',
    install_requires=[
        'pyparsing >=2.4.0',
        'z3-solver',
        'pydotplus',
    ],
    extras_require={
        'test': requirements,
    },
    scripts=['bin/rflx']
)
