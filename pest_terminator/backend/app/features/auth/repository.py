from app.extensions import db
from app.features.auth.models import User

# Function to check if new user or existing
def get_user_by_email(email):
	return User.query.filter_by(email=email).first()

# Function to create new user in DB
def create_user(name, email, password_hash):
	user = User(name=name, email=email, password_hash=password_hash)
	db.session.add(user)
	try:
		db.session.commit()
	except Exception:
		db.session.rollback()
		raise
	return user
