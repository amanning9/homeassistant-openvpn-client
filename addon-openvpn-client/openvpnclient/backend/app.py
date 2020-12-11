import os
import sys

from flask import Flask, request, render_template, jsonify
from werkzeug.utils import secure_filename

application = Flask(__name__, template_folder=os.path.abspath(
    os.path.join(os.path.dirname(os.path.dirname(__file__)), 'frontend')))


# upload files to the persistent storage within the docker container this application will run in
application.config['UPLOAD_FOLDER'] = '/data/'

_FILES = [
    'ca.crt',
    'client.crt',
    'client.key',
    'ta.key'
]


@application.route('/', methods=['GET', 'POST'])
def root():
    return render_template('index.html')


@application.route('/ca_crt/', methods=['POST'])
@application.route('/client_cert/', methods=['POST'])
@application.route('/client_key/', methods=['POST'])
@application.route('/ta_key/', methods=['POST'])
def upload():
    if request.method == 'POST':

        file = None

        for f in _FILES:
            if f in request.files:
                # check if the post request has the file part
                file = request.files.get(f)
                # if user does not select file, browser also
                # submit a empty part without filename

        if not file and request.files:
            # if the user send a file but that one is not supported, return a message with status code 204
            return jsonify({'message': 'The file not supported'}), 204

        filename = os.path.join(application.config['UPLOAD_FOLDER'], secure_filename(file.filename))
        print("Save file {file} into {path}".format(file=file, path=filename))
        file.save(filename)

        return jsonify({'message': 'File {} saved'.format(file.filename)}), 200


def run():
    application.run()

