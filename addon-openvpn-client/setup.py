# -*- coding: utf-8 -*-
#
# Copyright (c) 2016-2018 by Lars Klitzke, lars@klitzke-web.de
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
import json
import os

import setuptools

NAME = 'openvpnclient'
# read in the long description written in the README.md file
with open(os.path.join(os.path.dirname(__file__), "README.md"), "r") as fh:
    long_description = fh.read()

with open(os.path.join(os.path.dirname(__file__), 'config.json'), "r") as config:
    __version__ = json.load(config)['version']

setuptools.setup(
    name=NAME,
    version=__version__,
    description='',
    long_description=long_description,
    long_description_content_type="text/markdown",
    author='Lars Klitzke',
    author_email='Lars@klitzke-web.de',
    entry_points={
        'console_scripts': [
            NAME + ' = openvpnclient.backend.app:run',
        ]
    },
    include_package_data=True,
    packages=setuptools.find_packages(),
    install_requires=[
        'Flask',
        'uwsgi'
    ],
    scripts=['run.sh'],
    data_files = [
        ('share/{}'.format(NAME), [
            'config.json',
            'openvpnclient.ini'
        ])
    ]
)
