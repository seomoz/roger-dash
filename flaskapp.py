from dash import app
import os

app.run(debug=os.getenv('DEBUG', ''))
