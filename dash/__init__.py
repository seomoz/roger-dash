import os
from flask import Flask
from .views.main import main

app = Flask(__name__)
app.secret_key = os.environ['APP_SECRET_KEY']

app.register_blueprint(main, url_prefix = os.getenv('HTTP_PREFIX',''))
