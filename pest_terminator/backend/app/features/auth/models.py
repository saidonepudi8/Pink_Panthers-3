from app.extensions import db

# Users table descripion
class User(db.Model):
	id = db.Column(db.Integer, primary_key=True)
	email = db.Column(db.String(254), unique=True, nullable=False, index=True)
	password_hash = db.Column(db.String(255), nullable=False)
	name = db.Column(db.String(120), nullable=True)
