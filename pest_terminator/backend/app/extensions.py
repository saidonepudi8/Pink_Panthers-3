from flask_jwt_extended import JWTManager
from flask_sqlalchemy import SQLAlchemy

# Create DB and jwt instances in one spot
db = SQLAlchemy()
jwt = JWTManager()